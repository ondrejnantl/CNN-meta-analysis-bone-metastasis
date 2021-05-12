function [varargout] = saveDataset_v3(dataPath)
% Popis:
% Funkce provádí kompletaci datasetu z dat o extrahovaných lézích od více 
% pacientů.
% 
% Vstup: dataPath - cesta k .mat souborům pro jednotlivé pacienty
% 
% Výstup: datasetFeatures - 4-D numerické pole obsahující všechny
%                           extrahované 2.5D řezy objektů od všech pacientů
%         datasetLabels - odpovídající kategorie pro jednotlivé objekty 
% 
% Autor: Ondřej Nantl
% ==========================================================================
%% načtení souborů ve složce a spojení objektů od dílčích pacientů do 1 datasetu
dataList = what(dataPath);
datasetSize = 0;
for i = 1:size(dataList.mat, 1)
    disp(['Nacitam zaznam:' dataList.mat{i}])
    [CAD25D, CADLabels, CADStats, CADObjects,CADVertID] = getLesions_v4([dataPath '\' dataList.mat{i}]);
    datasetIms(:,:,:,datasetSize+1:datasetSize+size(CAD25D,4)) = CAD25D(:,:,:,:);
    datasetLabels(datasetSize+1:datasetSize+size(CADLabels,1),:) = CADLabels(:,:);
    datasetStats(datasetSize+1:datasetSize+size(CADStats,1),:) = CADStats(:,:);
    datasetObjects(datasetSize+1:datasetSize+size(CADObjects,1)) = CADObjects(:);
    datasetVertID(datasetSize+1:datasetSize+size(CADStats,1)) = CADVertID(:,:);
    datasetPatID(datasetSize+1:datasetSize+size(CADLabels,1)) = i;
    datasetSize = numel(datasetLabels);
    disp(['Zpracovany byl zaznam:' dataList.mat{i}])
    disp(['Hotovo je:' num2str(i*100/size(dataList.mat,1)) ' %'])
end
varargout{1} = datasetIms;
varargout{2} = datasetLabels;
varargout{3} = datasetStats;
varargout{4} = datasetObjects';
varargout{5} = datasetVertID';
varargout{6} = datasetPatID';
end