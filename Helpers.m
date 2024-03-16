classdef Helpers
    
    %properties
    %    Property1
    %end
    
    methods(Static)
        function Show3DImage(img)
            % Calcola la somma di due numeri
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
        function Subplot(array_immagini)
            num_immagini = numel(array_immagini);
        
            % Calcola il numero di righe e colonne per disporre le immagini nei subplot
            num_colonne = ceil(sqrt(num_immagini));
            num_righe = ceil(num_immagini / num_colonne);
        
            % Crea una nuova figura
            figure;
        
            % Itera su ciascuna immagine nell'array
            for i = 1:num_immagini
                % Crea un subplot e mostra l'immagine corrente
                subplot(num_righe, num_colonne, i);
                imshow(array_immagini{i});
                title(['Immagine ', num2str(i)]);
            end
        end
        function mask=threshold(img,value)
            mask=img>value;
        end
    end
end

