threshold_area = 100; % Soglia dell'area minima del tumore (in pixel)
max_area_ratio = 0.5; % Rapporto massimo tra l'area del tumore e l'area del polmone
threshold_eccentricity = 0.8;
lung_image  = imread('C:\Users\spide\Desktop\Screenshot_2024-03-11_205136.png'); 
  
% Pre-elaborazione dell'immagine
lung_gray = rgb2gray(lung_image);
lung_smoothed = imgaussfilt(lung_gray, 3); % Applica un filtro gaussiano per ridurre il rumore
imshow(lung_smoothed);
% Rilevamento dei bordi utilizzando l'operatore di Sobel
edges = edge(lung_smoothed, 'sobel');

% Analisi delle regioni connesse per individuare le anomalie (possibili tumori)
connected_regions = bwconncomp(edges);

% Calcolo delle proprietà delle regioni connesse (ad esempio area, perimetro, eccentricità)
region_props = regionprops(connected_regions, 'Area', 'Perimeter', 'Eccentricity');

% Filtraggio delle regioni che potrebbero rappresentare un tumore
tumor_regions = [];
for i = 1:length(region_props)
    % Definire qui i criteri per identificare un tumore, ad esempio basato su area, eccentricità, ecc.
    if (region_props(i).Area > threshold_area) && (region_props(i).Eccentricity > threshold_eccentricity)
        tumor_regions = [tumor_regions i];
    end
end

% Sovrapposizione delle regioni individuate sull'immagine originale
tumor_overlay = zeros(size(lung_gray));
for i = 1:length(tumor_regions)
    tumor_overlay(connected_regions.PixelIdxList{tumor_regions(i)}) = 255; % Imposta il valore a 255 per le regioni tumorali
end

% Visualizzazione dell'immagine con le regioni tumorali individuate
imshowpair(lung_gray, tumor_overlay, 'montage');
title('Individuazione del tumore');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BW  = imread('D:\Immagini\aaaaa.png');
aa = imfill(BW,'holes');
imshow(aa);
input_image  = imread('C:\Users\spide\Desktop\aaaaaaa.png');
binarizedImage = imbinarize(input_image,level);
BW2 = imfill(binarizedImage,'holes');
figure
imshow(BW2)
title('Filled Image')
level = graythresh(input_image);

% Definisci l'elemento strutturale (diamante) con un raggio di 2
%SE = strel('diamond', 2);

% Erosione dell'immagine con l'elemento strutturale definito
%%%%%%%%eroded_image = imerode(input_image, SE);

% Visualizza il risultato dell'erosione
figure;

fill = imfill(binarizedImage,'holes');
imshowpair(binarizedImage, fill, 'montage');
title('Comparazione tra immagine originale e immagine erosa');

 

figure;
imshowpair(input_image,tumore,'montage');
title('Comparazione tra immagine originale e immagine erosa binarizzata');

bware = bwareaopen(tumore, 100);
figure;
imshowpair(tumore,bware,'montage');
title('Comparazione tra immagine erosa e immagine con bwareaopen');

fill = imfill(tumore);
figure;
imshowpair(tumore, fill,'montage');
title('Comparazione tra immagine erosa e immagine con imfill');

figure;
imshowpair(bware,fill,'montage');
title('Comparazione tra immagine con bwareaopen e immagine con imfill');
























% Carica il dataset di addestramento
trainData = 'C:\LM_AI\Image Processing\Task06_Lung\imagesTr';

labelData = 'C:\LM_AI\Image Processing\Task06_Lung\labelsTr';

% Creare un loop per leggere i file .nii.gz dal dataset di addestramento
trainingFiles = dir(fullfile(trainData, '*.nii.gz'));
trainingFiles = trainingFiles(~startsWith({trainingFiles.name}, '.')); % Escludi i file che iniziano con un punto
% Creare una cella per memorizzare le immagini di addestramento e le loro maschere
trainingImages = cell(length(trainingFiles), 1);
trainingMasks = cell(length(trainingFiles), 1);

for i = 1:length(trainingFiles)
    % Leggere il file .nii.gz
    %nii = niftiread(fullfile(trainData, trainingFiles(i).name));
    nii = niftiread(fullfile(trainData, trainingFiles(i).name));
    % Estrai l'immagine e la maschera dalla struttura .nii
    img = nii(:, :, :, 1); % Supponiamo che l'immagine sia il primo volume nel file .nii
    Helpers.Show3DImage(img);
     
  
    grayThreshold = graythresh(I);
    % Applica la segmentazione basata su soglia
    tumorMask = img > 0.7; % Ad esempio, utilizziamo una soglia arbitraria di 0.7
    0
    helpers(tumorMask)
    % Aggiungi l'immagine e la maschera ai set di addestramento
    trainingImages{i} = img;
    trainingMasks{i} = tumorMask;
end

% Ora hai il set di addestramento composto da coppie di immagini e maschere.
% Puoi utilizzare queste coppie per allenare un algoritmo di segmentazione più avanzato, 
% come la segmentazione region-based o la segmentazione watershed, se necessario.









% Definisci il percorso del file .nii.gz
file_path = 'C:\LM_AI\Image Processing\Task06_Lung\labelsTr\lung_003.nii.gz';

% Usa niftiread per leggere il file
volume = niftiread(file_path);

% Visualizza una slice dell'immagine
slice_index = 50; % Puoi cambiare questo valore per vedere diverse slice
imshow(volume(:,:,slice_index), []);

% Se vuoi leggere anche le informazioni di header, usa niftiinfo
info = niftiinfo(file_path);




% Carica l'immagine di esempio
img = imread('percorso_del_file_immagine');

% Converte l'immagine in scala di grigi
img_gray = rgb2gray(img);

% Applica un filtro di mediana per ridurre il rumore
img_filtered = medfilt2(img_gray, [3, 3]);

% Calcola la soglia usando il metodo di Otsu
threshold = graythresh(img_filtered);

% Applica la soglia per ottenere un'immagine binaria
bw_img = imbinarize(img_filtered, threshold);

% Rimuovi gli oggetti più piccoli
bw_img = bwareaopen(bw_img, 100);

% Visualizza l'immagine binaria risultante
imshow(bw_img);

% Calcola i contorni degli oggetti nell'immagine binaria
contours = bwboundaries(bw_img);

% Visualizza l'immagine originale sovrapposta ai contorni
hold on;
for k = 1:length(contours)
    boundary = contours{k};
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
end
hold off;





