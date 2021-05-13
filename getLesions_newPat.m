function [varargout] = getLesions_newPat(dataPath)
% Popis:
% Funkce na extrakci 2.5D řezů o nádorových lézích z CT snímků výstupu CAD algoritmu
% 
% Vstup: dataPath - cesta k .mat souboru obsahujícím originální CT scan
%                   (proměnná im), segmentovaná těla a výběžky obratlů 
%                   (proměnná regions),vektor omezující páteř v CT datech
%                   (proměnná positions_roi), označené léze CAD algoritmem
%                   (proměnná res_v4cnn)
%                   Obrazy ve složce musí mít všechny stejnou velikost a
%                   formát
%                   Příklad: 'D:\Images\pat_02_0.mat' - načte data 1 pacienta 
%                   ze složky s daty
%
% Výstup: CADcuts - 4-D numerické pole obsahující jednotlivé navzájem 
%                   kolmé řezy vybraných získaných objektů a jejich 
%                   augmentované podoby, rozměr je 24 x 24 x 3 x počet objektů
%         outStats - matice obsahující vybrané statistické parametry
%                    objektů
%         objects - buňkové pole obsahující bounding box objektů    
% 
% Autor: Ondřej Nantl
%==========================================================================
load(dataPath,'im','regions','res_v4cnn','positions_roi','dcm_info')
%% extrahování oblasti obratlových těl z CT dat a z výstupu CAD algoritmu
dataSpine = dcm_info.RescaleSlope.*im(positions_roi(1):positions_roi(2),...
            positions_roi(3):positions_roi(4), positions_roi(5):positions_roi(6)) + dcm_info.RescaleIntercept;
dataSpineCAD = res_v4cnn(positions_roi(1):positions_roi(2),positions_roi(3):positions_roi(4),...
               positions_roi(5):positions_roi(6));
regionsSpine = regions(positions_roi(1):positions_roi(2),positions_roi(3):positions_roi(4),...
               positions_roi(5):positions_roi(6));
clear('im', 'res_v4cnn', 'positions_roi')

% omezení oblasti zájmu na obratlová těla
regionsSpine(regionsSpine == 2) = 0; 
CADReg = dataSpineCAD.*regionsSpine;
clear('regions')

disp('Nactena a predzpracovana data')
%% extrahování lézí z výstupu CAD algoritmu
% analýza spojených komponent
CADConn = bwconncomp(CADReg,18); 

% získání informací o objektech a matice s označenými objekty
CADConnProps = regionprops3(CADConn);   
CADConnMat = labelmatrix(CADConn);
CADBound = round(CADConnProps.BoundingBox(:,:));

disp('Provedena analyza spojenych komponent')
%% výpočet statistických příznaků

% určení počtu objektů, rozměrů CT dat a prealokace proměnné pro cyklus
imBounds = size(dataSpine);
objectCount = size(CADConnProps, 1);
CADObjectsStats = int16(zeros(objectCount,5));

for cadLesID = 1:objectCount
    % výpočet statistik
    objectVol = dataSpine(CADConnMat == cadLesID);
    CADObjectsStats(cadLesID,:) = [mean(objectVol),...
                                   CADConnProps.Volume(cadLesID),...
                                   moment(objectVol, 2),...
                                   moment(objectVol, 3),...
                                   moment(objectVol, 4)];
end

disp('Proveden vypocet statistik objektu')
%% zisk 2D řezů přeškálovaných na 24x24 pixelů

% pralokace proměnných pro výstup
objects = cell(1,1);
CADcuts = zeros(24,24,3,1);
outStats = zeros(1,5);
chosencutsid = 1;

% výběr lézí s jasnou kategorií a větších než zvolená velikost
for cadcutsid = 1:objectCount
    if  CADConnProps.Volume(cadcutsid) > 20
        
        % vymezení objektu pro zisk řezů
        centroid = round(CADConnProps.Centroid(cadcutsid,:));

        idx = CADBound(cadcutsid,2)-1:CADBound(cadcutsid,2)+CADBound(cadcutsid,5)+1;
        idy = CADBound(cadcutsid,1)-1:CADBound(cadcutsid,1)+CADBound(cadcutsid,4)+1;
        idz = CADBound(cadcutsid,3)-1:CADBound(cadcutsid,3)+CADBound(cadcutsid,6)+1;
        idx(idx < 1) = [];
        idy(idy < 1) = [];
        idz(idz < 1) = [];
        idx(idx > imBounds(1)) = [];
        idy(idy > imBounds(2)) = [];
        idz(idz > imBounds(3)) = [];
        
        % zisk objektů
        objects{chosencutsid} = dataSpine(idx,idy,idz);
        
        % zisk 2.5D řezů
        CADcuts(:,:,1,chosencutsid) = imresize(dataSpine(idx,idy,centroid(3)),[24 24]);
        CADcuts(:,:,2,chosencutsid) = imresize(permute(dataSpine(idx,centroid(1),idz),[1 3 2]),[24 24]);
        CADcuts(:,:,3,chosencutsid) = imresize(permute(dataSpine(centroid(2),idy,idz),[2 3 1]),[24 24]);

        % zisk statistik objektu
        outStats(chosencutsid,:) = CADObjectsStats(cadcutsid,:);
        chosencutsid = chosencutsid + 1;
    else
        continue
    end
end

varargout{1} = CADcuts;
varargout{2} = outStats;
varargout{3} = objects';

disp('Proveden zisk 2.5D rezu')