examplesFolders = Helpers.elenca_file_con_prefisso('Dataset', 'lung');


for j = 1 : size(examplesFolders,2)
    folderToSave = fullfile('Dataset', examplesFolders(j));
    inputImage  = imread(char(fullfile(folderToSave, 'trainingImage.png')));

    inputImage = Helpers.resize(inputImage, 256);

    resultImageBin = Helpers.otsubin(inputImage);
    imshow(resultImageBin);
    %inputImage  = imread('imagesProject\2tumori.png');
    % Definisci l'elemento strutturale (diamante) con un raggio di 2
    structureElement = strel('diamond', 2);
    
    % Erosione dell'immagine con l'elbinarizedImageemento strutturale definito
    erodedImage = imerode(inputImage, structureElement);
    %Helpers.imsshow({inputImage, erodedImage});
    
    % Converte l'immagine in scala di grigi se necessario
    erodedImage = Helpers.rgb2gray(erodedImage);
    
    %smussa gli angoli, porta a linee piu morbide nell'immage, visibili miglioramenti
    %sulla linea dei polmoni
    erodedImageMedfilt = medfilt2(erodedImage, [5, 5]);
    
    binarizedImage = Helpers.otsubin(erodedImageMedfilt);
    imshow(binarizedImage);
    imageWithoutResults = bwareaopen(binarizedImage, 500);
    
    occurrences = binarizedImage - imageWithoutResults;
    imshow(occurrences);
    saveas(gcf, char(fullfile(folderToSave, 'occorrenze_rilevate.png')));
    
    % Etichetta le regioni connesse nell'immagine binarizzata
    [label_matrix, num_labels] = bwlabel(occurrences);
    
    centroids = regionprops(label_matrix, 'Centroid');
    % Ottiene le proprietà delle regioni connesse
    
    imshow(inputImage);
    
    hold on; % Abilita la sovrapposizione dei tracciati
    % Itera su tutte le regioni connesse trovate
    for i = 1:num_labels
        
        % Identifica la regione bianca basata sulle coordinate fornite

        region = bwselect(resultImageBin, centroids(i).Centroid(1), centroids(i).Centroid(2));
        regionProps = regionprops(region, 'Area', 'Perimeter', 'Centroid');
        
        if ~isempty(regionProps) && (regionProps.Area > 600 || regionProps.Perimeter > 250)
            region = bwselect(occurrences, centroids(i).Centroid(1), centroids(i).Centroid(2));
            regionProps = regionprops(region, 'Area', 'Perimeter', 'Centroid');
        end 

        % Trova il perimetro della parte bianca dell'immagine binarizzata
        perimeterTrack = bwperim(region,8);
        [B,L] = bwboundaries(perimeterTrack,'noholes');
        for k = 1:length(B)
            boundary = B{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
        end
    
        %.BoundingBox sono [x, y, width, height]
        if ~isempty(regionProps)
            text(regionProps.Centroid(1), regionProps.Centroid(2), ...
                sprintf('Area: %d \n Perimetro: %.2f', regionProps.Area, regionProps.Perimeter), 'Color', 'yellow', 'FontSize', 10);
        
        disp([' idxs: ' folderToSave  ' ' num2str(i) ' Area: ' num2str(regionProps.Area) ' Perimeter: ' num2str(regionProps.Perimeter)]);
        end 
    end
    
    hold off;% Disbilita la sovrapposizione dei tracciati
    saveas(gcf, char(fullfile(folderToSave, 'segmentazione_a_soglia.png')));
    %f = getframe(gcf);
    %result = f.cdata;
    %imwrite(result, examplesFolders(j));
    
end    
% Disegna il contorno convesso (convex hull) della regione
%plot(regionProps(i).ConvexHull(:,1), regionProps(i).ConvexHull(:,2), 'r', 'LineWidth', 2);