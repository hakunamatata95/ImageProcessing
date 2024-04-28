classdef Helpers
    
    methods(Static)

        function datasetfolderstructuring(mrisTrainingPath, mrisLabelPath)
            baseFolder = 'Dataset';
            % Creazione della cartella
            if ~exist(baseFolder, 'dir')
                mkdir(baseFolder);
            end
            
            % Salva un'immagine nella cartella appena creata
            trainingFileNames = Helpers.elenca_file_con_prefisso(mrisTrainingPath, 'lung');
            %labelFileNames = Helpers.elenca_file_con_prefisso(mrisLabelPath, 'lung');

            for i = 1 : size(trainingFileNames,2)
                exampleName = char(strtok(trainingFileNames(i), "."));
                exampleFolderName = fullfile(baseFolder, exampleName);
                if ~exist(exampleFolderName, 'dir')
                    mkdir(exampleFolderName);
                end
                 
                [trainingImage,labelImage] = Helpers.calculate_images_for_training_and_label(fullfile(mrisTrainingPath, char(trainingFileNames(i))), ...
                    fullfile(mrisLabelPath , char(trainingFileNames(i))));

                if ~exist(exampleFolderName, 'dir')
                    mkdir(exampleFolderName);
                else
                    rmdir(exampleFolderName, 's');
                    mkdir(exampleFolderName);
                end

                imwrite(trainingImage, fullfile(baseFolder, exampleName ,'trainingImage.png'));
                imwrite(labelImage, fullfile(baseFolder, exampleName ,'labelImage.png'));
            end
             
        end
        
        function fileNames = elenca_file_con_prefisso(folderPath, prefisso)
             % Ottieni una lista di tutti i file nella cartella specificata
             listaFiles = dir(fullfile(folderPath, [prefisso, '*']));
             
             % Estrai i nomi dei file dalla struttura 'listaFiles'
             fileNames = {listaFiles.name};
        end


        function [imageTraining, imageLabel] = calculate_images_for_training_and_label(imagePath, labelPath)
            % Calcoliamo la nuova proporzione in base ai dati niftiread
            label = niftiread(labelPath);
            [imageLabel, depth] = Helpers.search_max_region_in_label(label); 
             
            imageTraining = niftiread(imagePath);
            infoTraining = niftiinfo(imagePath);
            imageTraining = Helpers.extractyimage(imageTraining, depth);
   
            imageTraining = imrotate(Helpers.mriproportionadjustement(imageTraining, infoTraining), 90); 
            imageTraining = Helpers.imagenormalize(imageTraining);
 
            infoLabel = niftiinfo(labelPath);

            imageLabel = imrotate(Helpers.mriproportionadjustement(imageLabel, infoLabel), 90);
        end
        
        function image_corrected = mriproportionadjustement(image, info)
            x = info.ImageSize(1) * info.PixelDimensions(1);
            y = info.ImageSize(3) * info.PixelDimensions(3);
            new_size = [x, y];

            image_corrected = imresize(image,new_size);
        end

        function img_normalized = imagenormalize(image)
            min_val = min(image(:)); % Trova il valore minimo dei pixel
            max_val = max(image(:)); % Trova il valore massimo dei pixel
            img_normalized = (double(image) - min_val) / (max_val - min_val); % Normalizza l'immagine
        end

        function imageResized = resize(img, newWidth)
            % Calcoliamo la nuova altezza proporzionale b:h=B:H
            originalSize = size(img);
            newHeight = round(newWidth * originalSize(1) / originalSize(2));

            % Ridimensionamento dell'immagine
            new_size = [newHeight, newWidth];
            imageResized = imresize(img, new_size);
        end

        %TODO: rivedere il nome del metodo
        function binImage = otsubin(image)
            image = Helpers.rgb2gray(image);
            greyLevel = graythresh(image);
            binImage = imbinarize(image, greyLevel);
        end

        function [image, depth] = search_max_region_in_label(mri)
            depth = 0;
            maxArea = 0;
            for i = 1 : size(mri, 2)
                extractedImage = Helpers.extractyimage(mri, i);
                extractedImageBin = Helpers.otsubin(extractedImage);
                [regions, num_labels] = bwlabel(extractedImageBin);
                
                props = regionprops(regions, 'Area');
                for j = 1 : num_labels
                    if props(j).Area > maxArea
                        maxArea = props(j).Area;
                        depth = i;
                        image = extractedImageBin;
                    end
                end
            end

        end 

        function imageFromMRI = extractyimage(mri, depth)
            if depth < -size(mri, 2) || depth > size(mri, 2)
                error('Depth is wrong'); 
            end
            %sqeeze rimuove le dimensioni unitarie quindi rende la
            %dimensione dell'immagine da MxYxN a MxN per Y=1
            imageFromMRI = squeeze(mri(:, depth, :));

            %ELENCO PIANI
            %frontal = squeeze(mri(:, :, depth));
            %sagittal = squeeze(mri(depth, :, :));
            %horizontal = squeeze(mri(:, depth, :));
        end

        function show3dimage(img)
            figure;
            subplot(1,3,1);
            imshow(squeeze(img(:, :, round(size(img, 3)/2))), []);
            title('Piano mediano (X)');
            subplot(1,3,2);
            imshow(squeeze(img(:, round(size(img, 2)/2), :)), []);
            title('Piano mediano (Y)');
            subplot(1,3,3);
            imshow(squeeze(img(round(size(img, 1)/2), :, :)), []);
            title('Piano mediano (Z)');
        end  

        function imsshow(arrayImgs, namesImgs)
            numImgs = numel(arrayImgs);
            
            % Se nomi_immagini non è fornito o ha meno elementi di array_immagini, inizializza con 'A'
            if ~exist('namesImgs', 'var') || isempty(namesImgs)
                namesImgs = zeros(0, 1);
            end

            numNamesImgs = numel(namesImgs);

            % Calcola il numero di righe e colonne per disporre le immagini nei subplot
            num_colonne = ceil(sqrt(numImgs));
            num_righe = ceil(numImgs / num_colonne);
        
            % Crea una nuova figura
            figure;
        
            % Itera su ciascuna immagine nell'array
            for i = 1 : numImgs
                % Crea un subplot e mostra l'immagine corrente
                subplot(num_righe, num_colonne, i);
                imshow(arrayImgs{i});

                % Imposta il titolo dell'immagine
                if i <= numNamesImgs
                    title(namesImgs{i});
                else
                    titleImage=['Img ' , num2str(i)];
                    title(titleImage);
                end
            end
        end

        function mask = threshold(img,value)
            mask = img > value;
        end

        function img = rgb2gray(img)
            if size(img, 3) == 3
                img = rgb2gray(img);
            end
        end
    end
end

