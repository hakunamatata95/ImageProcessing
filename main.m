inputImage  = imread('imagesProject\tumore1.png');
resultImageBin = Helpers.otsubin(inputImage);
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

imageWithoutResults = bwareaopen(binarizedImage, 150);

occurences = binarizedImage - imageWithoutResults;

% Etichetta le regioni connesse nell'immagine binarizzata
[label_matrix, num_labels] = bwlabel(occurences);

centroids = regionprops(label_matrix, 'Centroid');
% Ottiene le proprietà delle regioni connesse

imshow(inputImage);

hold on; % Abilita la sovrapposizione dei tracciati
% Itera su tutte le regioni connesse trovate
for i = 1:num_labels
    
    % Identifica la regione bianca basata sulle coordinate fornite
    region = bwselect(resultImageBin, centroids(i).Centroid(1), centroids(i).Centroid(2));
    regionProps = regionprops(region, 'Area', 'Perimeter', 'BoundingBox');

    % Trova il perimetro della parte bianca dell'immagine binarizzata
    perimeterTrack = bwperim(region,8);
    [B,L] = bwboundaries(perimeterTrack,'noholes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
    end

    %.BoundingBox sono [x, y, width, height]
    boundingBox = regionProps.BoundingBox;
    text(boundingBox(1) , boundingBox(2) - 10, ...
        ['Area: ' num2str(regionProps.Area)], 'Color', 'yellow', 'FontSize', 10);
    text(boundingBox(1), boundingBox(2) + boundingBox(4) + 10, ...
        ['Perimeter: ' num2str(regionProps.Perimeter)], 'Color', 'yellow', 'FontSize', 10);
end

hold off;% Disbilita la sovrapposizione dei tracciati
% Disegna il contorno convesso (convex hull) della regione
%plot(regionProps(i).ConvexHull(:,1), regionProps(i).ConvexHull(:,2), 'r', 'LineWidth', 2);