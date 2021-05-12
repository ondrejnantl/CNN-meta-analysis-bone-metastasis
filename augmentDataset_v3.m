function [varargout] = augmentDataset_v3(trainIms,trainLabels,trainStats,trainObjects,trainVertID,trainPatID,catObjCount)
% Popis:
% Funkce provádí augmentaci datasetu získáného funkcí getLesions pomocí
% náhodné translace, rotace a zmenšení. Počet výstupních objektů v každé
% kategorii lze ovlivnit pomocí vstupu.
% 
% Vstupy:
% trainIms - 2.5D řezy vstupních objektů jako matice, rozměr je KxLx3xM, 
%            kde K je výška, L šířka a M je počet objektů
% trainLabels - referenční kategorie objektů pro trénink ve formátu 
%               řádkového vektoru o délce M, kde M je počet objektů        
% trainStats - statistické parametry vypočtené v getLesions jako matice v
%              rozměru MxK, kde M je počet objektů a K je počet parametrů
% trainObjects - vyjmuté bounding boxy objektů sloužící k vlastní augmentaci
%                ve formátu buňkového pole s rozměry Mx1, kde M je počet objektů
% trainVertID - vektor obsahující příslušnost objektu k obratli s rozměry
%               Mx1, kde M je počet objektů
% catObjCount - skalár určující počet objektů v každé kategorii po
%               augmentaci
% Výstupy:
% augmentedIms - 2.5D řezy vstupních objektů jako matice, rozměr je KxLx3xM, 
%            kde K je výška, L šířka a M je počet objektů
% augmentedLabels - referenční kategorie objektů pro trénink ve formátu 
%               řádkového vektoru         
% augmentedStats - statistické parametry vypočtené v getLesions jako matice v
%              rozměru MxK, kde M je počet objektů a K je počet parametrů
% augmentedVertID - vektor obsahující příslušnost objektu k obratli s rozměry
%               Mx1, kde M je počet objektů
% 
% Autor: Ondřej Nantl
% ===================================================================================================================
%% zpracování vstupů
%% inicializace objektu augmentace
augmenter = imageDataAugmenter('RandRotation',[0 360], 'RandScale',[0.65 1],...
                               'RandXTranslation',[-5 5], 'RandYTranslation',[-5 5]);
%% příprava augmentace
healthyCount = sum(trainLabels == 0);
lyticCount = sum(trainLabels == 1);
blasticCount = sum(trainLabels == 2);
% catObjCount = 2000;

numOfAugmentHealthy = round(catObjCount/healthyCount) - 1;
numOfAugmentLytic = round(catObjCount/lyticCount) - 1;
numOfAugmentBlastic = round(catObjCount/blasticCount) - 1;
totalNumOfAugment = sum([healthyCount lyticCount blasticCount]~=0 & [healthyCount lyticCount blasticCount]~=Inf)...
                    *catObjCount;

augmentedIms = zeros(24,24,3,totalNumOfAugment);
augmentedLabels = zeros(totalNumOfAugment,1);
augmentedStats = zeros(totalNumOfAugment,5);
augmentedVertID = zeros(totalNumOfAugment,1);
augmentedPatID = zeros(totalNumOfAugment,1);

augcutsid = 1;
%% vlastní augmentace
for objectid = 1:size(trainIms,4)
    augmentedIms(:,:,:,augcutsid) = trainIms(:,:,:,objectid);
    augmentedLabels(augcutsid,1) = trainLabels(objectid);
    augmentedStats(augcutsid,:) = trainStats(objectid,:);
    augmentedVertID(augcutsid,1) = trainVertID(objectid);
    augmentedPatID(augcutsid,1) = trainPatID(objectid);
    
    % augmentace lytických objektů
    if trainLabels(objectid,1) == 1
        for augmentid = 1:numOfAugmentLytic
            centroid = floor(size(trainObjects{objectid})./2);
            % náhodná rotace a translace objektu
            augmentedObject = augment(augmenter,trainObjects{objectid}); 
            % zisk řezů
            augmentedIms(:,:,1,augcutsid+augmentid) = imresize(augmentedObject(:,:,centroid(3)),[24 24]);
            augmentedIms(:,:,2,augcutsid+augmentid) = imresize(permute(augmentedObject(:,centroid(2),:),[1 3 2]),[24 24]);
            augmentedIms(:,:,3,augcutsid+augmentid) = imresize(permute(augmentedObject(centroid(1),:,:),[2 3 1]),[24 24]);
            % přenos zlatého standardu a statistik
            augmentedLabels(augcutsid+augmentid,1) = trainLabels(objectid);
            augmentedStats(augcutsid+augmentid,:) = trainStats(objectid,:);
            augmentedVertID(augcutsid+augmentid,1) = trainVertID(objectid);
            augmentedPatID(augcutsid+augmentid,1) = trainPatID(objectid);
        end
        augcutsid = augcutsid + numOfAugmentLytic + 1;
        
    % augmentace blastických objektů    
    elseif trainLabels(objectid,1) == 2
        for augmentid = 1:numOfAugmentBlastic
            centroid = floor(size(trainObjects{objectid})./2);
            % náhodná rotace a translace objektu
            augmentedObject = augment(augmenter,trainObjects{objectid}); 
            % zisk řezů
            augmentedIms(:,:,1,augcutsid+augmentid) = imresize(augmentedObject(:,:,centroid(3)),[24 24]);
            augmentedIms(:,:,2,augcutsid+augmentid) = imresize(permute(augmentedObject(:,centroid(2),:),[1 3 2]),[24 24]);
            augmentedIms(:,:,3,augcutsid+augmentid) = imresize(permute(augmentedObject(centroid(1),:,:),[2 3 1]),[24 24]);
            % přenos zlatého standardu a statistik
            augmentedLabels(augcutsid+augmentid,1) = trainLabels(objectid);
            augmentedStats(augcutsid+augmentid,:) = trainStats(objectid,:);
            augmentedVertID(augcutsid+augmentid,1) = trainVertID(objectid);
            augmentedPatID(augcutsid+augmentid,1) = trainPatID(objectid);
        end
        augcutsid = augcutsid + numOfAugmentBlastic + 1;
     
     % augmentace zdravých objektů    
     elseif trainLabels(objectid,1) == 0
        for augmentid = 1:numOfAugmentHealthy
            centroid = floor(size(trainObjects{objectid})./2);
            % náhodná rotace a translace objektu
            augmentedObject = augment(augmenter,trainObjects{objectid}); 
            % zisk řezů
            augmentedIms(:,:,1,augcutsid+augmentid) = imresize(augmentedObject(:,:,centroid(3)),[24 24]);
            augmentedIms(:,:,2,augcutsid+augmentid) = imresize(permute(augmentedObject(:,centroid(2),:),[1 3 2]),[24 24]);
            augmentedIms(:,:,3,augcutsid+augmentid) = imresize(permute(augmentedObject(centroid(1),:,:),[2 3 1]),[24 24]);
            % přenos zlatého standardu a statistik
            augmentedLabels(augcutsid+augmentid,1) = trainLabels(objectid);
            augmentedStats(augcutsid+augmentid,:) = trainStats(objectid,:);
            augmentedVertID(augcutsid+augmentid,1) = trainVertID(objectid);
            augmentedPatID(augcutsid+augmentid,1) = trainPatID(objectid);
        end
        augcutsid = augcutsid + numOfAugmentHealthy + 1;
     end
end
varargout{1} = augmentedIms;
varargout{2} = augmentedLabels;
varargout{3} = augmentedStats;
varargout{4} = augmentedVertID;
varargout{5} = augmentedPatID;
end