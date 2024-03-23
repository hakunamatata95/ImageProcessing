classdef Helpers
    
    methods(Static)

        function plotBinaryImageScatter(immagine_binaria)

             % Controlla se l'input è una matrice valida
            if ~ismatrix(immagine_binaria) || ~islogical(immagine_binaria)
              error('Errore: L''input deve essere una matrice binaria (0 e 1).');
            end
    
            % Trova le coordinate dei pixel con valore 1
            [y, x] = find(immagine_binaria);
    
            % Genera il grafico a dispersione
            figure;
            scatter(x, y, 'filled');
            colormap('gray');  % Distingue 0 e 1
            axis equal;  % Mantiene le proporzioni dell'immagine
            xlabel('Colonna');
            ylabel('Riga');
            title('Grafico a dispersione dell''immagine binaria');  
        end

        function imageResized = resize(img, newWidth)
            % Calcoliamo la nuova altezza proporzionale b:h=B:H
            originalSize = size(img);
            newHeight = round(newWidth * originalSize(1) / originalSize(2));

            % Ridimensionamento dell'immagine
            new_size = [newHeight, newWidth];
            imageResized = imresize(img, new_size);
        end

        function binImage = otsubin(image)
            image = Helpers.rgb2gray(image);
            greyLevel = graythresh(image);
            binImage = imbinarize(image, greyLevel);
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

