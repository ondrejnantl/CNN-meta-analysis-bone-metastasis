% Tento skript slouží k naučení modelu nádor — zdravá tkáň s využitím
% augmentace datasetu a následné křížové validace a následnému vyhodnocení
% úspěšnosti klasifikace (a to i na obratel)

clear all
close all
clc

%% augmentace

% načtení připraveného datasetu po preprocessingu - nutno přepsat na
% vlastní cestu k datasetu
load('datasetPreprocessed.mat')

% augmentace
forCVLabels(forCVLabels==2) = 1;
numOfAugObj = 2400;
[forCVIms,forCVLabels,forCVStats,forCVVertID,forCVPatID] = augmentDataset(forCVIms,...
                 forCVLabels,forCVStats,forCVObjects,forCVVertID,forCVPatID,numOfAugObj);
forCVLabels = categorical(forCVLabels);

% vykreslení zastoupení objektu podle pacientů a podle kategorií pro
% pacienty — slouží pro rozdělení do křížové validace
figure; histogram(forCVPatID)
figure;for i = 1:10; subplot(2,5,i); histogram(forCVLabels(forCVPatID == i)); title(num2str(i));end
%% příprava křížové validace

% určení počtu foldů
k = 5;

% rozdělení pacientů do foldů
CV = [3 7; 1 8; 5 9; 2 6; 4 10];
%% inicializace a učení sítě

% inicializace vrstev
layers = [imageInputLayer([24 24 3],'Normalization', 'zscore')
          convolution2dLayer(3, 16, 'Padding', 'same')
          batchNormalizationLayer
          reluLayer
          maxPooling2dLayer(2, 'Stride',2)
          convolution2dLayer(3, 32, 'Padding', 'same')
          batchNormalizationLayer
          reluLayer
          maxPooling2dLayer(2, 'Stride', 2)
          convolution2dLayer(3, 64, 'Padding', 'same')
          batchNormalizationLayer
          reluLayer
          fullyConnectedLayer(512)
          dropoutLayer(0.5)
          fullyConnectedLayer(2)
          softmaxLayer
          classificationLayer];
      
% inicializace trénovacího nastavení     
trainOpt = trainingOptions('adam','Plots','none',...
                   'InitialLearnRate',0.0001, 'Shuffle', 'every-epoch',...
                   'GradientDecayFactor',0.92,'SquaredGradientDecayFactor',0.97,...
                   'Epsilon',1e-8, 'L2Regularization',0.00001,'MaxEpochs',15,...
                   'MiniBatchSize',256);

% trénink sítí při křížové validaci
trainedNetCell = cell(k,1);
confMat = cell(k,2);
for kFold = 1:k
    % rozdělení na testovací a trénovací dataset pro daný fold
    testIdx = (forCVPatID == CV(kFold,1) |forCVPatID == CV(kFold,2));
    trainIdx = ~testIdx;
    forTrainIms = forCVIms(:,:,:,trainIdx);
    forTrainLabels = forCVLabels(trainIdx,:);
    forTestIms = forCVIms(:,:,:,testIdx);
    forTestLabels = forCVLabels(testIdx,:);
    % naučení modelu v daném foldu a uložení dat pro vyhodnocení
    [trainedNetCell{kFold},~] = trainNetwork(forTrainIms,forTrainLabels,layers,trainOpt);
    [predTest,scores] = classify(trainedNetCell{kFold,1},forTestIms);
    [confMat{kFold,1},confMat{kFold,2}] = confusionmat(forTestLabels, predTest);
    results.GTCat{kFold} = forTestLabels;
    results.PredCat{kFold} = predTest;
    results.TestIdx{kFold} = testIdx;
    results.Scores{kFold} = scores;
end

%% vyhodnocení kvality modelů

% výpočet úspěšnostních metrik
[results.TPR,results.TNR,results.PPV,results.ACC,results.F1S] = perfScores(confMat,k);

% výpočet úspěšnostních metrik na obratel a vykreslení boxplotů
[resultsPerVert,resultsPerVertMean] = perfScoresVert(forCVIms,forCVLabels,...
                                      forCVPatID,forCVVertID,CV,k,trainedNetCell);
% tvorba ROC křivky
cats = categories(forCVLabels);

% výpočet hodnot dílčích ROC křivek pro každý fold a výpočet parametru AUC
for kFold = 1:k
    currTestLabels = results.GTCat{kFold};
    currScores = results.Scores{kFold};
    [X(:,kFold),Y(:,kFold),~,results.AUC(:,kFold)] = perfcurve(currTestLabels,currScores(:,2),cats{2},'XVals',linspace(0,1,202));
end

% zprůměrování ROC křivek
avgX = mean(X,2);
avgY = mean(Y,2);

% vypsání průměrných hodnot metrik a jejich směrodatných odchylek
disp(['TPR: ',num2str(mean(results.TPR)),' +- ',num2str(std(results.TPR)),...
      ';','TNR: ',num2str(mean(results.TNR)),' +- ',num2str(std(results.TNR)),...
      ';','PPV: ',num2str(mean(results.PPV)),' +- ',num2str(std(results.PPV))])
disp(['F1S: ',num2str(mean(results.F1S)),' +- ',num2str(std(results.F1S)),...
      ';','ACC: ',num2str(mean(results.ACC)),' +- ',num2str(std(results.ACC)),...
      ';','AUC: ',num2str(mean(results.AUC)),' +- ',num2str(std(results.AUC))])

% uložení dat z workspace
save('netBinaryWorkspAll.mat')