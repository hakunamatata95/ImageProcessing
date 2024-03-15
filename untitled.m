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

%bware = bwareaopen(tumore, 100);
image_without_results = bwareaopen(binarized_image, 150);

results = binarized_image - image_without_results;

Helpers.Subplot({binarized_image, image_without_results, results})

%fill = imfill(tumore, 'holes');
