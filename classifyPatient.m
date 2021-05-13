% Tento skript slouží k klasifikaci lézí pro nového pacienta, jehož CT scan
% byl již klasifikován voxelovou metodou detekce kostních nádorových lézí
clear all
close all
clc
%% zisk 2.5D řezů
tic
[CAD2D, ~, ~] = getLesions_newPat('D:\data_BP\pat_22_2.mat');
timeGL = toc;
%% načtení multiclass CNN a klasifikace
tic
load('\models\netMulticlass2603WorkspAll.mat','trainedNetCell')
yPred = classify(trainedNetCell{5}, CAD2D);

% výpis délky klasifikace
timeMulticlass = toc;
disp(['Cas multiclass klasifikace: ',num2str(floor((timeGL+timeMulticlass)/60)),' min ', num2str(mod((timeGL+timeMulticlass),60)),' s'])
%% načtení CNN pro binární klasifikaci a klasifikace
tic
load('\models\netBinary2603WorkspAll.mat','trainedNetCell')
yPred = classify(trainedNetCell{2}, CAD2D);

% výpis délky klasifikace
timeBinary = toc;
disp(['Cas klasifikace nador - zdrava tkan: ',num2str(floor((timeGL+timeBinary)/60)),' min ', num2str(mod((timeGL+timeBinary),60)),' s'])
%% načtení CNN pro hypodenzní tkáň a klasifikace
tic
load('\models\netLytic2603WorkspAll.mat','trainedNetCell')
yPred = classify(trainedNetCell{4}, CAD2D);

% výpis délky klasifikace
timeLytic = toc;
disp(['Cas klasifikace hypodenznich lezi: ',num2str(floor((timeGL+timeLytic)/60)),' min ', num2str(mod((timeGL+timeLytic),60)),' s'])
%% načtení CNN pro hyperdenzní tkáň a klasifikace
tic
load('\models\netBlastic2603WorkspAll.mat','trainedNetCell')
yPred = classify(trainedNetCell{4}, CAD2D);

% výpis délky klasifikace
timeBlastic = toc;
disp(['Cas klasifikace hyperdenznich lezi: ',num2str(floor((timeGL+timeBlastic)/60)),' min ', num2str(mod((timeGL+timeBlastic),60)),' s'])
