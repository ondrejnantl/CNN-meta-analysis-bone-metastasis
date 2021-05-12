function [TPR,TNR,PPV,ACC,F1S] = perfScores(confMat,k)
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
%% výpočet metrik
for kFoldIdx = 1:k
    currConfMat = confMat{kFoldIdx,1};
    sumRow = sum(currConfMat,2);
    sumCol = sum(currConfMat,1);
    % výpočet senzitivity
    TPR(kFoldIdx) = currConfMat(2,2)/sumRow(2);
    % výpočet specificity
    TNR(kFoldIdx) = currConfMat(1,1)/sumRow(1);
    % výpočet pozitivní prediktivní hodnoty
    PPV(kFoldIdx) = currConfMat(2,2)/sumCol(2);
    % výpočet úspěšnosti
    ACC(kFoldIdx) = sum(diag(currConfMat))/sum(currConfMat,'all');
    % výpočet F-1 skóre
    F1S(kFoldIdx) = 2 * TPR(kFoldIdx)* PPV(kFoldIdx)...
                            /(TPR(kFoldIdx) + PPV(kFoldIdx));
end
end