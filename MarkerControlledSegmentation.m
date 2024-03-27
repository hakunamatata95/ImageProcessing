% Carica l'immagine MRI del polmone
img = imread('imagesProject\tumore1.png');

img = Helpers.rgb2gray(img);

% Ridimensionamento dell'immagine
preprocessedImg = Helpers.resize(img, 770);
preprocessedImg = wiener2(preprocessedImg);

se = strel("diamond",4);
marker = imerode(preprocessedImg,se);
preprocessedImg = imreconstruct(marker ,preprocessedImg);

%Helpers.imsshow({img, preprocessedImg}, {'Original Image', 'After preprocessingImage'});
% Applicazione dell'operatore Sobel per migliorare i gradienti lungo gli assi orizzontali e verticali
sobel_x = [-1 0 1; -2 0 2; -1 0 1]; % Sobel kernel per Gx
sobel_y = [-1 -2 -1; 0 0 0; 1 2 1]; % Sobel kernel per Gy

% Applicazione della convoluzione dell'immagine con i kernel Sobel
gradiente_x = imfilter(double(preprocessedImg), sobel_x);
gradiente_y = imfilter(double(preprocessedImg), sobel_y);

% Calcolo del gradiente con Sobel
gradient_magnitude = sqrt(gradiente_x.^2 + gradiente_y.^2);

% Definizione dei marcatori
markers = zeros(size(preprocessedImg));

% Marcatori interni (ad esempio, basati sull'intensità)
soglia_intensita = 80; % Regola questo valore in base all'immagine
markers(preprocessedImg > soglia_intensita) = 1;

% Marcatori esterni (ad esempio, basati sulla distanza)
distanza_margine = 0.005; % Regola questo valore in base alle dimensioni del tumore
markers(bwdist(imdilate(markers, strel('diamond', 1))) <= distanza_margine) = 2;

modified_gradient = imimposemin(gradient_magnitude, markers);
% Segmentazione watershed
segmentazione = watershed(modified_gradient);

% Colora il tumore (etichette assegnate in base ai marcatori)
colored_img = label2rgb(segmentazione);

Helpers.plotBinaryImageScatter(logical(segmentazione));
imshow(segmentazione);
% Visualizza l'immagine segmentata
%imshow(colored_img)

figure
imshow(img)
hold on
overlaySeg = imshow(colored_img);
overlaySeg.AlphaData = 0.5;
title("Colored Labels Superimposed Transparently on Original Image");

regioni = bwlabel(segmentazione);
[label_matrix, num_labels]  = bwlabel(segmentazione);
regionProps = regionprops(label_matrix, 'Centroid', 'Area');

for i = 1:num_labels
  text(regionProps(i).Centroid(1), regionProps(i).Centroid(2), sprintf('Area: %d', regionProps(i).Area), 'Color', 'red');
end


 
