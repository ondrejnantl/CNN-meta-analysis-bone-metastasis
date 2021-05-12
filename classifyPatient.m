clear all
close all
clc
%% zisk 2.5D řezů a kategorií podle experta
tic
[CAD2D, CADStats, ~] = getLesions_newPat('D:\data_BP\pat_22_2.mat');
timeGL = toc;
%% načtení multiclass CNN a klasifikace
tic
load('D:\andyn\OneDrive - Vysoké učení technické v Brně\bakalarka\data\net032021\netMulticlass2603WorkspAll.mat','trainedNetCell')
yPred = classify(trainedNetCell{5}, CAD2D);
timeMulticlass = toc;
disp(['Cas multiclass klasifikace: ',num2str(floor((timeGL+timeMulticlass)/60)),' min ', num2str(mod((timeGL+timeMulticlass),60)),' s'])
%% načtení CNN pro binární klasifikaci a klasifikace
tic
load('D:\andyn\OneDrive - Vysoké učení technické v Brně\bakalarka\data\net032021\netBinary2603WorkspAll.mat','trainedNetCell')
yPred = classify(trainedNetCell{2}, CAD2D);
timeBinary = toc;
disp(['Cas klasifikace nador - zdrava tkan: ',num2str(floor((timeGL+timeBinary)/60)),' min ', num2str(mod((timeGL+timeBinary),60)),' s'])
%% načtení CNN pro hypodenzní tkáň a klasifikace
tic
load('D:\andyn\OneDrive - Vysoké učení technické v Brně\bakalarka\data\net032021\netLytic2603WorkspAll.mat','trainedNetCell')
yPred = classify(trainedNetCell{4}, CAD2D);
timeLytic = toc;
disp(['Cas klasifikace hypodenznich lezi: ',num2str(floor((timeGL+timeLytic)/60)),' min ', num2str(mod((timeGL+timeLytic),60)),' s'])
%% načtení CNN pro hyperdenzní tkáň a klasifikace
tic
load('D:\andyn\OneDrive - Vysoké učení technické v Brně\bakalarka\data\net032021\netBlastic2603WorkspAll.mat','trainedNetCell')
yPred = classify(trainedNetCell{4}, CAD2D);
timeBlastic = toc;
disp(['Cas klasifikace hyperdenznich lezi: ',num2str(floor((timeGL+timeBlastic)/60)),' min ', num2str(mod((timeGL+timeBlastic),60)),' s'])
