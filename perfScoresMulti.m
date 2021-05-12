function [TPR,TNR,PPV,ACC,F1S] = perfScoresMulti(confMat,k)
% Popis:
% Funkce provádí výpočet vybraných úspěšnostních metrik ze získaných matic
% záměn při testování modelů.
%
% Vstupy:
% confMat - výsledné matice záměn pro jednotlivé modely v rámci křížové
%           validace ve formátu buňkového pole o rozměrech kx2, kde k je
%           počet subdatasetů během křížové validace (v prvním sloupci jsou
%           samotné matice záměn, v druhém pořadí kategorií)
% k - počet subdatasetů během křížové validace
%
% Výstupy:
% TPR - výsledná senzitivita pro každý model v rámci křížové validace jako
%       vektor
% TNR - výsledná specificita pro každý model v rámci křížové validace jako
%       vektor
% PPV - výsledná pozitivní prediktivní hodnota pro každý model v rámci
%       křížové validace jako vektor
% ACC - výsledná přesnost pro každý model v rámci křížové validace jako
%       vektor
% F1S - výsledné F-1 skóre pro každý model v rámci křížové validace jako
%       vektor
%
% Autor: Ondřej Nantl
% ===================================================================================================================
%% výpočet úspěšnostních metrik
tprMulti = zeros(3,1); tnrMulti = zeros(3,1);ppvMulti = zeros(3,1); f1sMulti = zeros(3,1);
for kFoldIdx = 1:k
    % výběr správné matice záměn
    currConfMat = confMat{kFoldIdx,1};
    sumRow = sum(currConfMat,2);
    sumCol = sum(currConfMat,1);
    % výpočet statistik pro každou kategorii
    for categoryIdx = 1:3
        tprMulti(categoryIdx) = currConfMat(categoryIdx,categoryIdx)/sumRow(categoryIdx);
        tnrMulti(categoryIdx) = (sum(currConfMat,'all') - sumRow(categoryIdx) - ...
            sumCol(categoryIdx) + currConfMat(categoryIdx,categoryIdx))...
            /(sum(currConfMat,'all') - sumRow(categoryIdx));
        ppvMulti(categoryIdx) = currConfMat(categoryIdx,categoryIdx)/sumCol(categoryIdx);
        f1sMulti(categoryIdx) = 2 * tprMulti(categoryIdx)* ppvMulti(categoryIdx)...
            /(tprMulti(categoryIdx) + ppvMulti(categoryIdx));
    end
    % uložení výsledků do výstupních proměnných
    TPR(kFoldIdx,:) = tprMulti;
    TNR(kFoldIdx,:) = tnrMulti;
    PPV(kFoldIdx,:) = ppvMulti;
    F1S(kFoldIdx,:) = f1sMulti;
    ACC(kFoldIdx,:) = sum(diag(currConfMat))/sum(currConfMat,'all');
end
end