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
    preprocessedImg = imadjust(inputImage);

    %lung_015 viene rilevato grazie a questo filtro a ottengo un falso
    %positivo
    %preprocessedImg = wiener2(preprocessedImg);
    
    se = strel("diamond", 3);
    marker = imerode(preprocessedImg,se);
    preprocessedImg = imreconstruct(marker, preprocessedImg);
    
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
    soglia_intensita = 85;
    markers(preprocessedImg > soglia_intensita) = 1;
    
    % Marcatori esterni (ad esempio, basati sulla distanza)
    distanza_margine = 0.005;
    markers(bwdist(imdilate(markers, strel('diamond', 1))) <= distanza_margine) = 2;
    %markers(bwdist(markers, 'euclidean') <= distanza_margine) = 2;
    %markers = bwdist(~markers);
    markersInverted = -markers;
    modified_gradient = imimposemin(gradient_magnitude, markersInverted);
    
    % Segmentazione watershed
    segmentazione = watershed(modified_gradient);
    segmentazione(~markers) = 0;

    % Colora il tumore (etichette assegnate in base ai marcatori)
    colored_img = label2rgb(segmentazione);
    
    imshow(segmentazione, []);
    % Visualizza l'immagine segmentata
    %imshow(colored_img)
    
    imshow(inputImage)
    hold on
    overlaySeg = imshow(colored_img);
    overlaySeg.AlphaData = 0.5;
    title("Colored Labels Superimposed Transparently on Original Image");
    
    [label_matrix, num_labels]  = bwlabel(segmentazione);
    regionProps = regionprops(label_matrix, 'Centroid', 'Area', 'Perimeter');
    
    for i = 1:num_labels
        text(regionProps(i).Centroid(1), regionProps(i).Centroid(2), sprintf('Area: %d \n Perimetro: %.2f', regionProps(i).Area, regionProps(i).Perimeter), 'Color', 'red','FontSize', 10);
    end
    hold off;
    saveas(gcf, char(fullfile(folderToSave, 'segmentazione_marker_controlled.png')));
end

 
