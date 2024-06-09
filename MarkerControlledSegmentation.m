clear;
close all;

% Carica i percorsi delle immagini MRI del polmone
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
    %L'operazione di chiusura morfologica è una dilatazione seguita da un'erosione, utilizzando lo stesso elemento strutturante per entrambe le operazioni.
    fgm2 = imclose(fgm, se2);

    fgm3 = bwareaopen(fgm2, 20);
    I3 = labeloverlay(inputImage, fgm3);
    
    bw  = imbinarize(Iobrcbr);
     
    distance_transform = bwdist(bw);
    distance_labels = watershed(distance_transform);

    % La distance_transform rende il polmone bianco
    % quindi la linea di cresta si posizionerà sul massimo (bianco).
    % Watershed Ridge Lines.
    bgm = distance_labels == 0;
    
    maschera = bgm | fgm3;
    gmag2 = imimposemin(gradient_magnitude, maschera);
    L = watershed(gmag2);
    
    %Nella labels: L == 0 dilatate con elemento strutturale. Valori bgm a 2. Valori fgm3 a 3.
    labels = imdilate(L==0, ones(3,3)) + 2 * bgm + 3 * fgm3;

    %Markers and Object Boundaries Superimposed on Original Image
    I4 = labeloverlay(inputImage, labels);
    imshow(I4);
    
    exportgraphics(gcf, char(fullfile(folderToSave, 'labels_marker_controlled_.png')));

    % Colora il tumore (etichette assegnate in base ai marcatori)
    colored_img = label2rgb(L);
    bgm_filled = imfill(bgm, 'holes');
    
    bgm_filled_AND_fgm3 = bgm_filled & fgm3;

    imshow(inputImage)
    hold on

    
    [label_matrix, num_labels]  = bwlabel(bgm_filled_AND_fgm3);
    region_props_label_matrix = regionprops(label_matrix, 'Centroid', 'Area', 'Perimeter');

    image_size = size(inputImage);
    occorrenze_rilevate = false(image_size(1), image_size(2));

    if ~isempty(region_props_label_matrix)

        for i = 1:num_labels
            region = bwselect(L, region_props_label_matrix(i).Centroid(1), region_props_label_matrix(i).Centroid(2));
            regionProps = regionprops(region, 'Area', 'Perimeter', 'Centroid');
            
            % Se il centroide della rilevazione non è nel tumore per evitare
            % regioni errate del bwselect vengono impostate soglie di
            % coerenza. Se area o perimetro sono maggiori di queste soglie
            % si utilizzerà la regione processata (con area e perimetro
            % meno precisi)
            if regionProps.Area > 600 || regionProps.Perimeter > 250
                regionProps = region_props_label_matrix(i);
                region = label_matrix == i;
            end

            if ~isempty(regionProps)
                text(regionProps.Centroid(1), regionProps.Centroid(2), sprintf('Area: %d \n Perimetro: %.2f', regionProps.Area, regionProps.Perimeter), 'Color', 'yellow','FontSize', 6);
            end 
            
            %aggiorno la matrice logica di occorrenze rilevate basandomi
            %sulla selezione della regione iniziale trovata tramite il
            %centroide
            occorrenze_rilevate = occorrenze_rilevate | region;
        end
    end

    % Converti la matrice logica in uint8
    uint8Overlay = uint8(occorrenze_rilevate);

    % Converti l'immagine uint8 in una immagine RGB
    rgbOverlay = cat(3, uint8Overlay*255, uint8Overlay*0, uint8Overlay*0);  % Rosso
    overlaySeg = imshow(rgbOverlay);
    overlaySeg.AlphaData = 0.5;
    hold off;
    exportgraphics(gcf, char(fullfile(folderToSave, 'segmentazione_marker_controlled.png')));

    imshow(occorrenze_rilevate, []);
    imwrite(logical(occorrenze_rilevate), char(fullfile(folderToSave, 'marker_controlled_occorrenze_rilevate.png')));
end

 
