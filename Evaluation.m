clear;
close all;

% Carica i percorsi delle immagini MRI del polmone
examplesFolders = Helpers.elenca_file_con_prefisso('Dataset', 'lung');

newSize = [128, 128];

TPThreshold = 0;
TNThreshold = 0;
FPThreshold = 0;
FNThreshold = 0;

TPMarkerControlled = 0;
TNMarkerControlled = 0;
FPMarkerControlled = 0;
FNMarkerControlled = 0;

for j = 1 : size(examplesFolders,2)
    
    folderToSave = fullfile('Dataset', examplesFolders(j));
    thresholdOccurences = imread(char(fullfile(folderToSave, 'soglia_occorrenze_rilevate.png')));
    markerControlledOccurences = imread(char(fullfile(folderToSave, 'marker_controlled_occorrenze_rilevate.png')));
    labels = imread(char(fullfile(folderToSave, 'labelImage.png')));

    thresholdOccurences = imresize(thresholdOccurences, newSize);
    markerControlledOccurences = imresize(markerControlledOccurences, newSize);
    labels = imresize(labels, newSize);

    [TP, TN, FP, FN] = Helpers.calculate_metrics(labels, thresholdOccurences);

    TPThreshold = TPThreshold + TP;
    TNThreshold = TNThreshold + TN;
    FPThreshold = FPThreshold + FP;
    FNThreshold = FNThreshold + FN;

    [TPa, TNa, FPa, FNa] = Helpers.calculate_metrics(labels, markerControlledOccurences);

    TPMarkerControlled = TPMarkerControlled + TPa;
    TNMarkerControlled = TNMarkerControlled + TNa;
    FPMarkerControlled = FPMarkerControlled + FPa;
    FNMarkerControlled = FNMarkerControlled + FNa;
end

ACCThreshold = (TPThreshold + TNThreshold) / (TPThreshold + TNThreshold + FPThreshold + FNThreshold);
TPRThreshold = TPThreshold / (TPThreshold + FNThreshold);
TNRThreshold = TNThreshold / (TNThreshold + FPThreshold);

ACCMarkerControlled = (TPMarkerControlled + TNMarkerControlled) / (TPMarkerControlled + TNMarkerControlled + FPMarkerControlled + FNMarkerControlled);
TPRMarkerControlled = TPMarkerControlled / (TPMarkerControlled + FNMarkerControlled);
TNRMarkerControlled = TNMarkerControlled / (TNMarkerControlled + FPMarkerControlled);

% Stampa dei risultati
fprintf('ACCThreshold = %.4f\n', ACCThreshold);
fprintf('TPRThreshold = %.4f\n', TPRThreshold);
fprintf('TNRThreshold = %.4f\n', TNRThreshold);

fprintf('ACCMarkerControlled = %.4f\n', ACCMarkerControlled);
fprintf('TPRMarkerControlled = %.4f\n', TPRMarkerControlled);
fprintf('TNRMarkerControlled = %.4f\n', TNRMarkerControlled);
