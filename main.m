inputImage  = imread('imagesProject\tumore1.png');
% Definisci l'elemento strutturale (diamante) con un raggio di 2
structureElement = strel('diamond', 4);

% Erosione dell'immagine con l'elbinarizedImageemento strutturale definito
erodedImage = imerode(inputImage, structureElement);

% Converte l'immagine in scala di grigi se necessario
if size(erodedImage, 3) == 3
    erodedImage = rgb2gray(erodedImage);
end

%smussa gli angoli, porta a linee piu morbide nell'immage, visibili miglioramenti
%sulla linea dei polmoni
erodedImageMedfilt = medfilt2(erodedImage, [5, 5]);

binarizedImage = Helpers.otsubin(erodedImageMedfilt);


image_without_results = bwareaopen(binarizedImage, 150);

occurences = binarizedImage - image_without_results;

% Etichetta le regioni connesse nell'immagine binarizzata
[label_matrix, num_labels] = bwlabel(occurences);

% Ottiene le proprietà delle regioni connesse
regionProps = regionprops(label_matrix, 'Area', 'BoundingBox', 'ConvexHull');
Helpers.imsshow({inputImage})
hold on; % Abilita la sovrapposizione dei tracciati

% Itera su tutte le regioni connesse trovate
for i = 1:num_labels
    % Disegna il contorno convesso (convex hull) della regione
    plot(regionProps(i).ConvexHull(:,1), regionProps(i).ConvexHull(:,2), 'r', 'LineWidth', 2);
    
    % Mostra l'area della regione
    text(regionProps(i).BoundingBox(1), regionProps(i).BoundingBox(2) - 10, ...
        ['Area: ' num2str(regionProps(i).Area)], 'Color', 'yellow', 'FontSize', 10);
end

hold off;% Disbilita la sovrapposizione dei tracciati
