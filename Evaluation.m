clear;
close all;

% Carica i percorsi delle immagini MRI del polmone
examplesFolders = Helpers.elenca_file_con_prefisso('Dataset', 'lung');

newSize = [256, 256];

TPThreshold = 0;
TNThreshold = 0;
FPThreshold = 0;
FNThreshold = 0;

TPMarkerControlled = 0;
TNMarkerControlled = 0;
FPMarkerControlled = 0;
FNMarkerControlled = 0;

% Cicla tutte le immagini di test
for j = 1 : size(examplesFolders,2)
    
    folderToSave = fullfile('Dataset', examplesFolders(j));
    thresholdOccurences = imread(char(fullfile(folderToSave, 'soglia_occorrenze_rilevate.png')));
    markerControlledOccurences = imread(char(fullfile(folderToSave, 'marker_controlled_occorrenze_rilevate.png')));
    labels = imread(char(fullfile(folderToSave, 'labelImage.png')));

    % Effettua il resize delle immagini per standardizzarle
    thresholdOccurences = imresize(thresholdOccurences, newSize);
    markerControlledOccurences = imresize(markerControlledOccurences, newSize);
    labels = imresize(labels, newSize);

    % Calcola le matrici di confusione per il Threshold
    [TP, TN, FP, FN] = Helpers.calculate_metrics(labels, thresholdOccurences);

    % Somma i valori delle matrici di confusione
    TPThreshold = TPThreshold + TP;
    TNThreshold = TNThreshold + TN;
    FPThreshold = FPThreshold + FP;
    FNThreshold = FNThreshold + FN;

    % Calcola le matrici di confusione per il Marker Controlled
    [TPa, TNa, FPa, FNa] = Helpers.calculate_metrics(labels, markerControlledOccurences);

    % Somma i valori delle matrici di confusione
    TPMarkerControlled = TPMarkerControlled + TPa;
    TNMarkerControlled = TNMarkerControlled + TNa;
    FPMarkerControlled = FPMarkerControlled + FPa;
    FNMarkerControlled = FNMarkerControlled + FNa;
end

% Calcola Accuracy, True Positive Rate e True Negative Rate per il
% Threshold
ACCThreshold = (TPThreshold + TNThreshold) / (TPThreshold + TNThreshold + FPThreshold + FNThreshold);
TPRThreshold = TPThreshold / (TPThreshold + FNThreshold);
TNRThreshold = TNThreshold / (TNThreshold + FPThreshold);

% Calcola Accuracy, True Positive Rate e True Negative Rate per il
% Marker Controlled
ACCMarkerControlled = (TPMarkerControlled + TNMarkerControlled) / (TPMarkerControlled + TNMarkerControlled + FPMarkerControlled + FNMarkerControlled);
TPRMarkerControlled = TPMarkerControlled / (TPMarkerControlled + FNMarkerControlled);
TNRMarkerControlled = TNMarkerControlled / (TNMarkerControlled + FPMarkerControlled);

% Stampa dei risultati
fprintf('-----THRESHOLD-----\n');

fprintf('TPThreshold = %d\n', TPThreshold);
fprintf('TNThreshold = %d\n', TNThreshold);
fprintf('FPThreshold = %d\n', FPThreshold);
fprintf('FNThreshold = %d\n', FNThreshold);

fprintf('ACCThreshold = %.4f\n', ACCThreshold);
fprintf('TPRThreshold = %.4f\n', TPRThreshold);
fprintf('TNRThreshold = %.4f\n', TNRThreshold);

fprintf('-----MARKER CONTROLLED-----\n');

fprintf('TPMarkerControlled = %d\n', TPMarkerControlled);
fprintf('TNMarkerControlled = %d\n', TNMarkerControlled);
fprintf('FPMarkerControlled = %d\n', FPMarkerControlled);
fprintf('FNMarkerControlled = %d\n', FNMarkerControlled);

fprintf('ACCMarkerControlled = %.4f\n', ACCMarkerControlled);
fprintf('TPRMarkerControlled = %.4f\n', TPRMarkerControlled);
fprintf('TNRMarkerControlled = %.4f\n', TNRMarkerControlled);
