input_image  = imread('C:\Users\spide\Desktop\tumore1.png');
% Definisci l'elemento strutturale (diamante) con un raggio di 2
SE = strel('diamond', 4);

% Erosione dell'immagine con l'elemento strutturale definito
eroded_image = imerode(input_image, SE);

% Converte l'immagine in scala di grigi se necessario
if size(eroded_image, 3) == 3
    eroded_image = rgb2gray(eroded_image);
end

%smussa gli angoli, porta a linee piu morbide nell'immage, visibili miglioramenti
%sulla linea dei polmoni
eroded_image_medfilt = medfilt2(eroded_image, [5, 5]);

grey_level = graythresh(eroded_image_medfilt);
binarized_image = imbinarize(eroded_image_medfilt, grey_level);


image_without_results = bwareaopen(binarized_image, 150);

occurences = binarized_image - image_without_results;

%Helpers.Subplot({binarized_image, image_without_results, occurences})
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Etichetta le regioni connesse nell'immagine binarizzata
[label_matrix, num_labels] = bwlabel(occurences);

% Ottiene le proprietà delle regioni connesse
region_props = regionprops(label_matrix, 'Area', 'BoundingBox', 'ConvexHull');
Helpers.Subplot({input_image})
hold on; % Abilita la sovrapposizione dei tracciati

% Itera su tutte le regioni connesse trovate
for i = 1:num_labels
    % Disegna il contorno convesso (convex hull) della regione
    plot(region_props(i).ConvexHull(:,1), region_props(i).ConvexHull(:,2), 'r', 'LineWidth', 2);
    
    % Mostra l'area della regione
    text(region_props(i).BoundingBox(1), region_props(i).BoundingBox(2) - 10, ...
        ['Area: ' num2str(regioni_prop(i).Area)], 'Color', 'yellow', 'FontSize', 10);
end

hold off;% Disbilita la sovrapposizione dei tracciati
s=1;
