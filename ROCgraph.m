% Tento skript slouží k vykreslení ROC křivek pro vytvořené modely
% meta-analýzy kostních nádorových lézí s využitím CNN
%
% Pro spuštění je nutné přepsat cesty k souborům obsahující data o ROC
% křivkách a úspěšnostních metrikách
%% načtení dat k vykreslení pro všechny modely
avgMulti = load('D:\andyn\OneDrive - Vysoké učení technické v Brně\bakalarka\data\net042021\netMulticlass2004WorkspAll.mat',...
                'avgX','avgY','results');
avgLytic = load('D:\andyn\OneDrive - Vysoké učení technické v Brně\bakalarka\data\net032021\netLytic2603WorkspAll.mat',...
                'avgX','avgY','results');
avgBlastic = load('D:\andyn\OneDrive - Vysoké učení technické v Brně\bakalarka\data\net032021\netBlastic2603WorkspAll.mat',...
                  'avgX','avgY','results');
avgBinary = load('D:\andyn\OneDrive - Vysoké učení technické v Brně\bakalarka\data\net042021\netBinary2104WorkspAll.mat',...
                  'avgX','avgY','results');              

%% samotné vykreslení
figure;
for i = 1:3
    
    % vykreslení ROC křivky multiclass modelu
    ROCm{i} = plot(avgMulti.avgX(:,i),avgMulti.avgY(:,i),'--');
    hold on
    
    % vykreslení operačního bodu multiclass modelu
    OPm{i} = scatter(1-mean(avgMulti.results.TNR(:,i)),mean(avgMulti.results.TPR(:,i)),'r*');
    hold on
end

% vykreslení ROC křivky modelu pro lytickou tkáň
ROCl = plot(avgLytic.avgX,avgLytic.avgY);
hold on

% vykreslení operačního bodu modelu pro lytickou tkáň
OPl = scatter(1-mean(avgLytic.results.TNR),mean(avgLytic.results.TPR),'r*');
hold on

% vykreslení ROC křivky modelu pro blastickou tkáň
ROCbl = plot(avgBlastic.avgX,avgBlastic.avgY);
hold on

% vykreslení operačního bodu modelu pro blastickou tkáň
OPbl=scatter(1-mean(avgBlastic.results.TNR),mean(avgBlastic.results.TPR),'r*');

% vykreslení ROC křivky modelu pro binární model
ROCbi = plot(avgBinary.avgX,avgBinary.avgY);
hold on

% vykreslení operačního bodu modelu pro binární model
OPbi=scatter(1-mean(avgBinary.results.TNR),mean(avgBinary.results.TPR),'r*');

% přidání popisku a legendy
xlabel('1 - Specificita')
ylabel('Senzitivita')
title('ROC křivky navržených CNN')
legend([ROCm{1},ROCm{2},ROCm{3},ROCl,ROCbl,ROCbi],{'Zdravá multiclass','Osteolytická multiclass','Osteoblastická multiclass',...
        'Osteolytická','Osteoblastická','Nádor — zdravá tkáň'})