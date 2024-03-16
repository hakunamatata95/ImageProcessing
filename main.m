inputImage  = imread('imagesProject\tumore1.png');
%inputImage  = imread('imagesProject\2tumori.png');
% Definisci l'elemento strutturale (diamante) con un raggio di 2
structureElement = strel('diamond', 4);


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

%Helpers.imsshow({inputImage,binarizedImage})
imageWithoutResults = bwareaopen(binarizedImage, 150);

occurences = binarizedImage - imageWithoutResults;

% Etichetta le regioni connesse nell'immagine binarizzata
[label_matrix, num_labels] = bwlabel(occurences);


centroids = regionprops(label_matrix, 'Centroid');
% Ottiene le proprietà delle regioni connesse
% TODO: controllare utilità convexHull
regionProps = regionprops(label_matrix, 'Area', 'Perimeter', 'BoundingBox', 'ConvexHull');


resultImageBin = Helpers.otsubin(inputImage);
resultImageBinGray = uint8(resultImageBin) * 255;
% Load your image (replace 'your_image.jpg' with the filename of your image)
inputImage;

% Definisci il colore con cui vuoi riempire la regione (ad esempio, rosso)
fill_color = [255, 0, 0];  % [R, G, B]



% Riempimento della regione bianca a partire dal punto del centroide
%mask_filled = imfill(resultImageBin, [round(centroids(1).Centroid(1)), round(centroids(1).Centroid(2))],8);
immagine_invertita = imcomplement(resultImageBin);
mask_filled = imfill(immagine_invertita, [round(centroids(1).Centroid(1)), round(centroids(1).Centroid(2))], 4);
%mask_filled = imfill(resultImageBin, round(centroids.Centroid));
imshow(resultImageBin);
imshow(mask_filled);
% Applica il colore alla regione riempita
image_colored = bsxfun(@times, mask_filled, reshape(fill_color, 1, 1, []));

% Visualizza l'immagine colorata
imshow(image_colored);

















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
