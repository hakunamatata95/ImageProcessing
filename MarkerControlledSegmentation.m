clear;
close all;

% Carica l'immagine MRI del polmone
examplesFolders = Helpers.elenca_file_con_prefisso('Dataset', 'lung');


for j = 1 : size(examplesFolders,2)
    
    folderToSave = fullfile('Dataset', examplesFolders(j));
    inputImage  = imread(char(fullfile(folderToSave, 'trainingImage.png')));
    inputImage = Helpers.rgb2gray(inputImage);
    
    % Ridimensionamento dell'immagine
    inputImage = Helpers.resize(inputImage, 256);
    
  % Opening-by-Reconstruction: eseguo imerode ed imreconstruct.
    
    % Escludo porzioni bianche troppo piccole per essere riconducibili a
    % tumori (in genere si tratta di alveoli polmonari)
    se = strel("diamond", 3);
    Ie = imerode(inputImage,se);
    i_open_by_reconstr = imreconstruct(Ie, inputImage);
  %___________________
  
  
  % Opening-Closing-by-Reconstruction
    i_open_by_reconstr_dilated = imdilate(i_open_by_reconstr, se);
    
    %imreconstruct(marker, mask). Il marker è l'immagine erosa che
    %ricostruiamo con mask.
    %Avendo dilatato Iobrd marker potrebbe essere "maggiore" di mask quindi
    %uso imcomplement

    %imcomplement: complement of image 255 - pixel_intensity
    Iobrcbr = imreconstruct(imcomplement(i_open_by_reconstr_dilated), imcomplement(i_open_by_reconstr));
    Iobrcbr = imcomplement(Iobrcbr);
  %___________________

  %CALCOLO GRADIENTE

    %[gmag_alternativo, gdir_alternativo] = imgradient(I);

    % Matrici di Sobel
    sobel_x = [-1 0 1; -2 0 2; -1 0 1]; % Sobel kernel per Gx
    sobel_y = [-1 -2 -1; 0 0 0; 1 2 1]; % Sobel kernel per Gy
    
    % Applicazione della convoluzione dell'immagine con i kernel Sobel
    gradiente_x = imfilter(double(Iobrcbr), sobel_x);
    gradiente_y = imfilter(double(Iobrcbr), sobel_y);
    
    % Calcolo del gradiente con Sobel
    gradient_magnitude = sqrt(gradiente_x.^2 + gradiente_y.^2);
    
    gradient_direction = atan2(gradiente_y, gradiente_x);
    gradient_direction_deg = rad2deg(gradient_direction);
    
  %___________________

    %Regional Maxima of Opening-Closing by Reconstruction
    fgm = imregionalmax(Iobrcbr);

    %Modified Regional Maxima Superimposed on Original Image
    se2 = strel(ones(3, 3));
    fgm2 = imclose(fgm, se2);
    fgm3 = imerode(fgm2,se2);

    fgm4 = bwareaopen(fgm3, 20);
    I3 = labeloverlay(inputImage, fgm4);
    
    bw  = imbinarize(Iobrcbr);
     
    distance_transform = bwdist(bw);
    DL = watershed(distance_transform);

    %Watershed Ridge Lines. La distance_transform rende il polmone bianco
    %quindi la linea di cresta si posizionerà sul massimo (bianco)
    bgm = DL == 0;
    
    maschera = bgm | fgm4;
    gmag2 = imimposemin(gradient_magnitude, maschera);
    L = watershed(gmag2);
    
    %Nella labels: L == 0 dilatate con elemento strutturale. Valori bgm a 2. Valori fgm4 a 3.
    labels = imdilate(L==0, ones(3,3)) + 2 * bgm + 3 * fgm4;

    %Markers and Object Boundaries Superimposed on Original Image
    I4 = labeloverlay(inputImage, labels);
    imshow(I4);
    
    % Colora il tumore (etichette assegnate in base ai marcatori)
    colored_img = label2rgb(L);
    bgm_filled = imfill(bgm, 'holes');
    
    bgm_filled_AND_fgm4 = bgm_filled & fgm4;

    
    imshow(inputImage)
    hold on
    overlaySeg = imshow(bgm_filled_AND_fgm4);
    overlaySeg.AlphaData = 0.5;
    title("Colored Labels Superimposed Transparently on Original Image");
    
    [label_matrix, num_labels]  = bwlabel(bgm_filled_AND_fgm4);
    regionProps = regionprops(label_matrix, 'Centroid');
    
    for i = 1:num_labels
        region = bwselect(L, regionProps(i).Centroid(1), regionProps(i).Centroid(2));
        regionProps = regionprops(region, 'Area', 'Perimeter', 'Centroid');
        text(regionProps.Centroid(1), regionProps.Centroid(2), sprintf('Area: %d \n Perimetro: %.2f', regionProps.Area, regionProps.Perimeter), 'Color', 'red','FontSize', 15);
    end

    hold off;
    saveas(gcf, char(fullfile(folderToSave, 'segmentazione_marker_controlled.png')));
end

 
