classdef Helpers
    
    methods(Static)

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

        function depth = search_max_region_in_label(mri)
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
                    end
                end
            end
        end 

        function imageFromMRI = extractyimage(mri, depth)
            if depth < -size(mri, 2) || depth > size(mri, 2)
                error('Depth is wrong'); 
            end
            imageFromMRI = squeeze(mri(:, depth, :));
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

