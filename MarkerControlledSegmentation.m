% Carica l'immagine MRI del polmone
img = imread('imagesProject\tumore1.png');

img = Helpers.rgb2gray(img);
img= imgaussfilt(img, 2);
% Ridimensionamento dell'immagine
img_resized = Helpers.resize(img, 770);
% Applicazione dell'operatore Sobel per migliorare i gradienti lungo gli assi orizzontali e verticali
sobel_x = [-1 0 1; -2 0 2; -1 0 1]; % Sobel kernel per Gx
sobel_y = [-1 -2 -1; 0 0 0; 1 2 1]; % Sobel kernel per Gy

% Applicazione della convoluzione dell'immagine con i kernel Sobel
gradiente_x = imfilter(double(img_resized), sobel_x);
gradiente_y = imfilter(double(img_resized), sobel_y);

% Calcolo del gradiente totale utilizzando la magnitudine del gradiente
gradiente_magnitudine = sqrt(gradiente_x.^2 + gradiente_y.^2);

% Calcolo dell'angolo del gradiente
%gradiente_angolo = atan2(gradiente_y, gradiente_x);

% TODO: minimi o massimi nell'articolo. Trova i massimi locali nell'immagine del gradiente   
marcatori_interni = imregionalmax(gradiente_magnitudine);

% Trova i marcatori esterni
distanza_trasformata = bwdist(marcatori_interni);
marcatori_esterni = imextendedmin(distanza_trasformata, 0.1);

% Unisci i marcatori interni ed esterni
marcatori = imimposemin(gradiente_magnitudine, marcatori_interni | marcatori_esterni);

% Calcola la segmentazione watershed
segmentazione = watershed(marcatori, 8);


Helpers.imsshow({img, label2rgb(segmentazione)}, {'Immagine originale', 'Segmentazione Watershed'});

% Calcola l'area del tumore utilizzando l'analisi dei componenti connessi
regioni = bwlabel(segmentazione);
tumore_area = max(histcounts(regioni, 'BinMethod', 'integers'));

% Visualizza l'area del tumore
disp(['L''area del tumore è: ', num2str(tumore_area), ' pixel']);
