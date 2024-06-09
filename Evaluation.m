clear;
close all;

% Carica i percorsi delle immagini MRI del polmone
examplesFolders = Helpers.elenca_file_con_prefisso('Dataset', 'lung');

newSize = [128, 128];


for j = 1 : size(examplesFolders,2)
    
    folderToSave = fullfile('Dataset', examplesFolders(j));
    thresholdOccurences = imread(char(fullfile(folderToSave, 'soglia_occorrenze_rilevate.png')));
    markerControlledOccurences = imread(char(fullfile(folderToSave, 'marker_controlled_occorrenze_rilevate.png')));
    labels = imread(char(fullfile(folderToSave, 'labelImage.png')));

    thresholdOccurences = imresize(thresholdOccurences, newSize);
    markerControlledOccurences = imresize(markerControlledOccurences, newSize);
    labels = imresize(labels, newSize);

    [TP, TN, FP, FN, ACC, TPR, TNR] = Helpers.calculate_metrics(labels, thresholdOccurences);

end