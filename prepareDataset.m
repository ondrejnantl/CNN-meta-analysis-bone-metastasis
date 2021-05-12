clear all
close all
clc

%% zisk datasetu
% volání funkce pro extrakci potenciálních lézí
[datasetIms, datasetLabels, datasetStats, datasetObjects,datasetVertID,datasetPatID] = saveDataset_v3('D:\data_BP');

% uložení datasetu po zisku lézí
save('dataset05032021.mat','datasetIms', 'datasetLabels','datasetStats','datasetObjects','datasetVertID','datasetPatID')
%% příprava trénovacího datasetu

%load('D:\andyn\OneDrive - Vysoké učení technické v Brně\bakalarka\data\getLesionsOutput032021\dataset05032021.mat',...
%    'datasetIms', 'datasetLabels','datasetStats','datasetObjects','datasetVertID', 'datasetPatID')

% určení počtů lézí podle kategorie pro každého pacienta
for patID = 1:10
    for lesionCat = 0:2
        lesionCount(patID,lesionCat+1) = sum(datasetPatID == patID & datasetLabels == lesionCat);
    end
end

% zjištění indexů lézí a nastavení počtu objektů k augmentaci
idxH = find(datasetLabels==0);
idxL = find(datasetLabels==1);
idxB = find(datasetLabels==2);
minNumOfLyObjects = 60;
minNumOfBlObjects = 100;
minNumOfNegObjects = 600;

% indexy pro náhodný výběr dat k tréninku a testování modelů
randIDNegObj = randperm(length(idxH),minNumOfNegObjects);
randIDLyObj = randperm(length(idxL),minNumOfLyObjects);
randIDBlObj = randperm(length(idxB),minNumOfBlObjects);

% výběr objektů z datasetu pro křížovou validaci
forCVIms = datasetIms(:,:,:,[idxH(randIDNegObj); idxL(randIDLyObj); idxB(randIDBlObj)]);
forCVLabels = datasetLabels([idxH(randIDNegObj); idxL(randIDLyObj); idxB(randIDBlObj)],:);
forCVStats = datasetStats([idxH(randIDNegObj); idxL(randIDLyObj); idxB(randIDBlObj)],:);
forCVObjects = datasetObjects([idxH(randIDNegObj); idxL(randIDLyObj); idxB(randIDBlObj)]);
forCVVertID = datasetVertID([idxH(randIDNegObj); idxL(randIDLyObj); idxB(randIDBlObj)],:);
forCVPatID = datasetPatID([idxH(randIDNegObj); idxL(randIDLyObj); idxB(randIDBlObj)],:);

% uložení preprocesovaného datasetu
% save('datasetPreprocessed.mat')