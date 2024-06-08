clear;
close all;

% Carica i percorsi delle immagini MRI del polmone
examplesFolders = Helpers.elenca_file_con_prefisso('Dataset', 'lung');

for j = 1 : size(examplesFolders,2)

    folderToSave = fullfile('Dataset', examplesFolders(j));
    inputImage  = imread(char(fullfile(folderToSave, 'trainingImage.png')));

    inputImage = Helpers.resize(inputImage, 256);
    
    % Erosione con elemento strutturale (diamante) con un raggio di 2
    structureElement = strel('diamond', 2);
    erodedImage = imerode(inputImage, structureElement);
  
    % Conversione immagine in scala di grigi se necessario
    erodedImage = Helpers.rgb2gray(erodedImage);
    
    %smussa gli angoli, porta a linee piu morbide nell'immagine. Visibili miglioramenti
    %sulla linea dei polmoni
    erodedImageMedfilt = medfilt2(erodedImage, [5, 5]);

    %Binarizzazione immagine con soglia graythresh Otsu
    binarizedImage = Helpers.otsubin(erodedImageMedfilt);
    imshow(binarizedImage);
    imageWithoutResults = bwareaopen(binarizedImage, 500);
    
    occurrences = binarizedImage - imageWithoutResults;
    imshow(occurrences);
    title("Tumori rilevati");
    exportgraphics(gcf, char(fullfile(folderToSave, 'soglia_occorrenze_rilevate.png')));
    
    % Etichettatura deòle regioni connesse nell'immagine binarizzata
    [label_matrix, num_labels] = bwlabel(occurrences);
    % Calcolo centroidi delle regioni connesse sulle occorrenze rilevate
    centroids = regionprops(label_matrix, 'Centroid');
    
    inputImageBin = Helpers.otsubin(inputImage);
    imshow(inputImage);
    
    hold on; % Abilita la sovrapposizione dei tracciati
    for i = 1:num_labels
        
        % Seleziona la regione bianca, sulle coordinate fornite,
        % dell'immagine iniziale binarizzata. In modo da ottenere area e
        % perimetro precisi
        region = bwselect(inputImageBin, centroids(i).Centroid(1), centroids(i).Centroid(2));
        regionProps = regionprops(region, 'Area', 'Perimeter', 'Centroid');
        
        % Se le props delle regioni analizzate sono eccessive significa che
        % sono stati rilevati bordi errati (principalmente a causa di
        % tumori a contatto con le pareti del polmone)
        if ~isempty(regionProps) && (regionProps.Area > 600 || regionProps.Perimeter > 250)
            % Calcolo delle regionprops sulle occorrenze rilevate (con aree
            % e perimetri erosi, quindi minori)
            region = bwselect(occurrences, centroids(i).Centroid(1), centroids(i).Centroid(2));
            regionProps = regionprops(region, 'Area', 'Perimeter', 'Centroid');
        end 

        % Trova il perimetro della parte bianca dell'immagine binarizzata
        perimeterTrack = bwperim(region, 8);
        B = bwboundaries(perimeterTrack, 'noholes');
        for k = 1:length(B)
            boundary = B{k};
            plot(boundary(:, 2), boundary(:, 1), 'r', 'LineWidth', 1)
        end
    
        if ~isempty(regionProps)
            text(regionProps.Centroid(1), regionProps.Centroid(2), ...
                sprintf('Area: %d \n Perimetro: %.2f', regionProps.Area, regionProps.Perimeter), 'Color', 'yellow', 'FontSize', 10);
        
            disp([' idxs: ' folderToSave  ' ' num2str(i) ' Area: ' num2str(regionProps.Area) ' Perimeter: ' num2str(regionProps.Perimeter)]);
        end 
    end
    
    hold off;% Disbilita la sovrapposizione dei tracciati

    title("Risultati Segmentazione a Soglia");
    exportgraphics(gcf, char(fullfile(folderToSave, 'segmentazione_a_soglia.png')));
      
end    

