% Carica l'immagine MRI del polmone
img = imread('imagesProject\tumore1.png');

%if size(img, 3) == 3
%    img = rgb2gray(img);
%end

img = Helpers.rgb2gray(img);

% Pre-processamento dell'immagine (ad esempio, riduzione del rumore, miglioramento del contrasto)
%img_preprocessed = imadjust(img);

% Definiamo la larghezza desiderata della nuova immagine
new_width = 700;

% Calcoliamo la nuova altezza proporzionale b:h=B:H
original_size = size(img);
new_height = round(new_width * original_size(1) / original_size(2));

% Ridimensionamento dell'immagine
new_size = [new_height, new_width];
img_resized = imresize(img, new_size);

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

% Visualizzazione dell'immagine originale e del gradiente magnitudine
figure;
subplot(1, 2, 1), imshow(img), title('Immagine originale');
subplot(1, 2, 2), imshow(gradiente_magnitudine, []), title('Gradiente Magnitudine');

% Trova i minimi locali nell'immagine del gradiente
marcatori_interni = imregionalmin(gradiente_magnitudine);

% Trova i marcatori esterni
distanza_trasformata = bwdist(marcatori_interni);
marcatori_esterni = imextendedmin(distanza_trasformata, 0.8);

% Unisci i marcatori interni ed esterni
marcatori = imimposemin(gradiente_magnitudine, marcatori_interni | marcatori_esterni);

% Calcola la segmentazione watershed
segmentazione = watershed(marcatori, 8);

% Visualizza l'immagine originale e la segmentazione
figure;
subplot(1, 2, 1), imshow(img_resized), title('Immagine originale');
subplot(1, 2, 2), imshow(label2rgb(segmentazione)), title('Segmentazione Watershed');

% Calcola l'area del tumore utilizzando l'analisi dei componenti connessi
regioni = bwlabel(segmentazione);
tumore_area = max(histcounts(regioni, 'BinMethod', 'integers'));

% Visualizza l'area del tumore
disp(['L''area del tumore è: ', num2str(tumore_area), ' pixel']);

imshow(gradiente_totale);
% Identificazione dei marcatori (ad esempio, usando la ricerca dei massimi locali)
marcatori = imregionalmax(gradiente_totale);

% Definizione delle regioni di sfondo
sfondo = imopen(img_resized, strel('disk', 15));

% Calcolo delle distanze euclidee dai marcatori ai pixel dell'immagine
dist = bwdist(~marcatori);

% Segmentazione Marker Controlled
seg = watershed(dist);

% Applicazione delle regioni di sfondo alla segmentazione
seg(~marcatori) = 0;

% Visualizzazione dei risultati
figure;
subplot(1,2,1), imshow(img), title('Immagine MRI del polmone');
subplot(1,2,2), imshow(label2rgb(seg)), title('Segmentazione dei tumori');