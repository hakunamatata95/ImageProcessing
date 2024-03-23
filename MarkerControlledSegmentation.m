% Carica l'immagine MRI del polmone
img = imread('imagesProject\tumore1.png');

img = Helpers.rgb2gray(img);

% Ridimensionamento dell'immagine
img_resized = Helpers.resize(img, 700);
% Applicazione dell'operatore Sobel per migliorare i gradienti lungo gli assi orizzontali e verticali
sobel_x = [-1 0 1; -2 0 2; -1 0 1]; % Sobel kernel per Gx
sobel_y = [-1 -2 -1; 0 0 0; 1 2 1]; % Sobel kernel per Gy

% Applicazione della convoluzione con i kernel Sobel
gradiente_x = imfilter(double(img_resized), sobel_x);
gradiente_y = imfilter(double(img_resized), sobel_y);
%gradiente_x = conv2(double(img), sobel_x, 'same');
%gradiente_y = conv2(double(img), sobel_y, 'same');

% Calcolo del gradiente totale utilizzando la magnitudine del gradiente
gradiente_magnitudine = sqrt(gradiente_x.^2 + gradiente_y.^2);


% Calcolo dell'angolo del gradiente
%gradiente_angolo = atan2(gradiente_y, gradiente_x);

Helpers.imsshow({img,gradiente_magnitudine}, {'Immagine originale', 'Gradiente Magnitudine'});

% Trova i minimi locali nell'immagine del gradiente
marcatori_interni = imregionalmin(gradiente_magnitudine);

% Trova i marcatori esterni
distanza_trasformata = bwdist(marcatori_interni);
marcatori_esterni = imextendedmin(distanza_trasformata, 0.8);

% Unisci i marcatori interni ed esterni
marcatori = imimposemin(gradiente_magnitudine, marcatori_interni | marcatori_esterni);

% Calcola la segmentazione watershed
segmentazione = watershed(marcatori, 8);

Helpers.imsshow({img_resized,label2rgb(segmentazione)}, {'Immagine originale', 'Segmentazione Watershed'});

% Calcola l'area del tumore utilizzando l'analisi dei componenti connessi
regioni = bwlabel(segmentazione);
tumore_area = max(histcounts(regioni, 'BinMethod', 'integers'));

% Visualizza l'area del tumore
disp(['L''area del tumore è: ', num2str(tumore_area), ' pixel']);
