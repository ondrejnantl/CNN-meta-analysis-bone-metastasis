function [resultsPerVert,resultsPerVertMean] = perfScoresVert(forCVIms,forCVLabels,...
                                               forCVPatID,forCVVertID,CV,k,trainedNetCell)
% Popis:
% Funkce provádí výpočet úspěšnostních metrik(TPR,TNR,PPV,F1S,ACC) pro 
% jednotlivé obratle a modely, výpočet průměrných úspěšnostních metrik na 
% obratel přes všechny modely a také vykreslení boxplotů průměrných 
% úspěšnostních metrik.
% 
% Vstupy:
% forCVIms - 2.5D řezy vstupních objektů jako matice, rozměr je KxLx3xM, 
%            kde K je výška, L šířka a M je počet objektů
% forCVLabels - referenční kategorie objektů pro trénink ve formátu 
%               řádkového vektoru o délce M, kde M je počet objektů        
% forCVPatID - vektor obsahující příslušnost objektu k pacientovi v rámci 
%              databáze s rozměry Mx1, kde M je počet objektů
% forCVVertID - vektor obsahující příslušnost objektu k obratli s rozměry
%               Mx1, kde M je počet objektů
% CV - matice obsahující ID pacientů pro daný fold křížové validace
% k - počet foldů v křížové validaci jako integer
% trainedNetCell - buňkové pole obsahující jednotlivé natrénované sítě
%                  během křížové validace, rozměr je Kx1, kde K je počet 
%                  opakování křížové validace
%
% Výstupy:
% resultsPerVert - 3D numerické pole obsahující jednotlivé metriky pro 
%                  každý obratel a model, rozměr je Nx5xK, kde N je počet 
%                  hodnocených obratlů a K počet modelů v křížové validaci 
% resultsPerVertMean - matice obsahující jednotlivé průměrné metriky pro 
%                      každý obratel napříč modely model, rozměr je Nx5,kde
%                      N je počet hodnocených obratlů
% 
% Autor: Ondřej Nantl
% ===================================================================================================================
%% výpočet metrik na obratel
resultsPerVert = zeros(max(forCVVertID),5,k);
for kFoldIdx = 1:k
    % vytažení testovacích dat z datasetu
    testIdx = (forCVPatID == CV(kFoldIdx,1) |forCVPatID == CV(kFoldIdx,2));
    forTestIms = forCVIms(:,:,:,testIdx);
    forTestLabels = forCVLabels(testIdx,:);
    forTestVertID = forCVVertID(testIdx,:);
    % predikce kategorií pomocí modelu
    predCat = classify(trainedNetCell{kFoldIdx,1},forTestIms);
    for vertIdx = 1:max(forCVVertID)
        % vytvoření matic záměn pro současný model a obratel
        currConfMat = confusionmat(forTestLabels(forTestVertID == vertIdx),...
                      predCat(forTestVertID == vertIdx));
        sumRow = sum(currConfMat,2);
        sumCol = sum(currConfMat,1);
        % výpočet úspěšnostních metrik 
        resultsPerVert(vertIdx,1,kFoldIdx) = currConfMat(2,2)/sumRow(2);
        resultsPerVert(vertIdx,2,kFoldIdx) = currConfMat(1,1)/sumRow(1);
        resultsPerVert(vertIdx,3,kFoldIdx) = currConfMat(2,2)/sumCol(2);
        resultsPerVert(vertIdx,4,kFoldIdx) = 2 * resultsPerVert(vertIdx,1,kFoldIdx)*...
                                              resultsPerVert(vertIdx,3,kFoldIdx)...
                                              /(resultsPerVert(vertIdx,1,kFoldIdx) +...
                                              resultsPerVert(vertIdx,3,kFoldIdx));
        resultsPerVert(vertIdx,5,kFoldIdx) = sum(diag(currConfMat))/sum(currConfMat,'all');
    end
end
% výpočet průměru úspěšnostních metrik na obratel přes modely
resultsPerVertMean = mean(resultsPerVert,3,'omitnan');
%% vykreslení těchto průměru do boxplotu
figure
boxplot(resultsPerVertMean,'Labels',{'Se','Sp','PPV','F1','Acc'})
title('Krabicový graf úspěšnostních metrik')
ylim([-0.1 1.1])
end