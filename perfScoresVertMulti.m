function [resultsPerVert,resultsPerVertMean] = perfScoresVertMulti(forCVIms,forCVLabels,...
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
%% výpočet úspěšnostních metrik na obratel
% prealokace proměnných do paměti
tprMulti = zeros(3,1); tnrMulti = zeros(3,1); ppvMulti = zeros(3,1); f1sMulti = zeros(3,1); 
resultsPerVert = zeros(max(forCVVertID),5,2,k);
for kFoldIdx = 1:k
    % výběr dat pro zisk predikovaných kategorií v rámci foldu
    testIdx = (forCVPatID == CV(kFoldIdx,1) |forCVPatID == CV(kFoldIdx,2));
    forTestIms = forCVIms(:,:,:,testIdx);
    forTestLabels = forCVLabels(testIdx,:);
    forTestVertID = forCVVertID(testIdx,:);
    predCat = classify(trainedNetCell{kFoldIdx,1},forTestIms);
    for vertIdx = min(forCVVertID):max(forCVVertID)
        % tvorba matice záměn pro právě posuzovaný obratel a fold
        currConfMat = confusionmat(forTestLabels(forTestVertID == vertIdx),...
                      predCat(forTestVertID == vertIdx));
        sumRow = sum(currConfMat,2);
        sumCol = sum(currConfMat,1);
        % výpočet metrik pro každou kategorii
        for categoryIdx = 1:3
            tprMulti(categoryIdx) = currConfMat(categoryIdx,categoryIdx)/sumRow(categoryIdx);
            tnrMulti(categoryIdx) = (sum(currConfMat,'all') - sumRow(categoryIdx) - ...
                                     sumCol(categoryIdx) + currConfMat(categoryIdx,categoryIdx))...
                                     /(sum(currConfMat,'all') - sumRow(categoryIdx));
            ppvMulti(categoryIdx) = currConfMat(categoryIdx,categoryIdx)/sumCol(categoryIdx);
            f1sMulti(categoryIdx) = 2 * tprMulti(categoryIdx)* ppvMulti(categoryIdx)...
                                    /(tprMulti(categoryIdx) + ppvMulti(categoryIdx));
        end
        % uložení výsledků pro výpočet průměru - pouze osteolytický a
        % osteoblastický typ
        resultsPerVert(vertIdx,1,1:2,kFoldIdx) = tprMulti(2:3);
        resultsPerVert(vertIdx,2,1:2,kFoldIdx) = tnrMulti(2:3);
        resultsPerVert(vertIdx,3,1:2,kFoldIdx) = ppvMulti(2:3);
        resultsPerVert(vertIdx,4,1:2,kFoldIdx) = f1sMulti(2:3);
        resultsPerVert(vertIdx,5,1:2,kFoldIdx) = sum(diag(currConfMat))/sum(currConfMat,'all');
    end
end
%% výpočet průměrných hodnot v rámci křížové validace a vykreslení boxplotů
resultsPerVertMean = mean(resultsPerVert,4,'omitnan');
for i = 1:2
    figure
    boxplot(resultsPerVertMean(2:end,:,i),'Labels',{'Se','Sp','PPV','F1','Acc'})
    title('Krabicový graf úspěšnostních metrik')
    ylim([-0.1 1.1])
end