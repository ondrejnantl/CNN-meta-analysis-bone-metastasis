function [varargout] = saveDataset(dataPath)
% Popis:
% Funkce provádí kompletaci datasetu z dat o extrahovaných lézích od více 
% pacientů.
% 
% Vstup: dataPath - cesta k .mat souborům pro jednotlivé pacienty, složka
%                   obsahuje pouze tyto soubory
%                   Příklad: 'D:\data\' 
%
% Výstup: datasetIms - 4-D numerické pole obsahující jednotlivé navzájem 
%                      kolmé řezy vybraných získaných objektů a jejich 
%                      augmentované podoby, rozměr je 32 x 32 x 3 x počet 
%                      objektů
%         datasetLabels - sloupcový vektor udávající kategorii daného objektu
%                         odvozenou od expertní anotace
%         datasetStats - matice obsahující vybrané statistické parametry
%                        objektů
%         datasetObjects - buňkové pole obsahující vyříznutý bounding box 
%                          objektů pro augmentaci
%         datasetVertID - sloupcový vektor obsahující pro každou lézi ID
%                         obratle, ze kterého pochází
%         datasetPatID - sloupcový vektor obsahující pro každou lézi ID
%                         pacienta, ze kterého pochází
%
% Autor: Ondřej Nantl
% ==========================================================================
%% načtení souborů ve složce a spojení objektů od dílčích pacientů do 1 datasetu

% zjištění obsahu složky zadané jako vstup
dataList = what(dataPath);
datasetSize = 0;

% cyklus pro zpracování dat od 1 pacienta
for i = 1:size(dataList.mat, 1)
    disp(['Nacitam zaznam:' dataList.mat{i}])
    % volání funkce getLesions
    [CAD25D, CADLabels, CADStats, CADObjects,CADVertID] = getLesions([dataPath '\' dataList.mat{i}]);
    
    % připojení získaných dat k výstupu
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