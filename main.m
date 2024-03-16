inputImage  = imread('imagesProject\tumore1.png');
%inputImage  = imread('imagesProject\2tumori.png');
% Definisci l'elemento strutturale (diamante) con un raggio di 2
structureElement = strel('diamond', 2);


% Erosione dell'immagine con l'elbinarizedImageemento strutturale definito
erodedImage = imerode(inputImage, structureElement);
%Helpers.imsshow({inputImage, erodedImage});
% Converte l'immagine in scala di grigi se necessario
if size(erodedImage, 3) == 3
    erodedImage = rgb2gray(erodedImage);
end

%smussa gli angoli, porta a linee piu morbide nell'immage, visibili miglioramenti
%sulla linea dei polmoni
erodedImageMedfilt = medfilt2(erodedImage, [5, 5]);

binarizedImage = Helpers.otsubin(erodedImageMedfilt);

Helpers.imsshow({inputImage,binarizedImage})
imageWithoutResults = bwareaopen(binarizedImage, 150);

occurences = binarizedImage - imageWithoutResults;

% Etichetta le regioni connesse nell'immagine binarizzata
[label_matrix, num_labels] = bwlabel(occurences);


centroids = regionprops(label_matrix, 'Centroid');
% Ottiene le proprietà delle regioni connesse
% TODO: controllare utilità convexHull
regionProps = regionprops(label_matrix, 'Area', 'Perimeter', 'BoundingBox', 'ConvexHull');

resultImageBin = Helpers.otsubin(inputImage);
imshow(resultImageBin);
 
% Crea una maschera della regione di interesse
maschera_regione = poly2mask(centroids(1).Centroid(1), centroids(1).Centroid(2), size(resultImageBin, 1), size(resultImageBin, 2));

% Trova il perimetro della regione di interesse
%perimetro_regione = bwperim(maschera_regione);

% Visualizza l'immagine originale con il perimetro della regione di interesse evidenziato

%hold on; 
%plot(centroids(1).Centroid(1), centroids(1).Centroid(2), 'r.', 'MarkerSize', 20);  % Punto rosso con dimensione 20
%
%%visboundaries(perimetro_regione, 'Color', 'r', 'LineWidth', 1.5);
%hold off;














%img=resultImageBin - binarizedImage

Helpers.imsshow(resultImageBin);
hold on; % Abilita la sovrapposizione dei tracciati

% Itera su tutte le regioni connesse trovate
for i = 1:num_labels
    % Disegna il contorno convesso (convex hull) della regione
    plot(regionProps(i).ConvexHull(:,1), regionProps(i).ConvexHull(:,2), 'r', 'LineWidth', 2);

    % Mostra l'area della regione
    text(regionProps(i).BoundingBox(1), regionProps(i).BoundingBox(2) - 25, ...
        ['Area: ' num2str(regionProps(i).Area)], 'Color', 'yellow', 'FontSize', 10);
text(regionProps(i).BoundingBox(2)', regionProps(i).BoundingBox(1), ...
        ['Perimeter: ' num2str(regionProps(i).Perimeter)], 'Color', 'yellow', 'FontSize', 10);
end

hold off;% Disbilita la sovrapposizione dei tracciati
