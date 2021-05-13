function [varargout] = getLesions(dataPath)
% Popis:
% Funkce na extrakci dat o nádorových lézích z CT snímků, dat anotovaných 
% expertů a výstupu CAD algoritmu
% 
% Vstup: dataPath - cesta k .mat souboru obsahujícím originální CT scan
%                   (proměnná im), segmentovaná těla a výběžky obratlů 
%                   (proměnná regions),vektor omezující páteř v CT datech
%                   (proměnná positions_roi), označené léze od experta
%                   (proměnná im_ozn3), označené léze CAD algoritmem
%                   (proměnná res_v4cnn)
%                   Obrazy ve složce musí mít všechny stejnou velikost a
%                   formát
%                   Příklad: 'D:\Images\pat_02_0.mat' - načte data 1 pacienta 
%                   ze složky s daty
%
% Výstup: CAD2dot5D - 4-D numerické pole obsahující jednotlivé navzájem 
%                     kolmé řezy vybraných získaných objektů a jejich 
%                     augmentované podoby, rozměr je 24 x 24 x 3 x počet objektů
%         outLabels - sloupcový vektor udávající kategorii daného objektu
%                     odvozenou od expertní anotace
%         outStats - matice obsahující vybrané statistické parametry
%                    objektů
%         objects - buňkové pole obsahující vyříznutý bounding box objektů 
%                   pro augmentaci
%         outVertID - sloupcový vektor obsahující pro každou lézi ID
%                     obratle, ze kterého pochází
%
% Autor: Ondřej Nantl
%==========================================================================
load(dataPath,'im','regions','im_ozn3','res_v4cnn','positions_roi','dcm_info','class')
%% extrahování oblasti obratlových těl z CT dat, dat anotovaných expertem a výstupu CAD algoritmu
dataSpine = dcm_info.RescaleSlope.*im(positions_roi(1):positions_roi(2),...
            positions_roi(3):positions_roi(4), positions_roi(5):positions_roi(6)) + dcm_info.RescaleIntercept;
dataSpineExp1 = im_ozn3(positions_roi(1):positions_roi(2), positions_roi(3):positions_roi(4),...
                positions_roi(5):positions_roi(6));
dataSpineCAD = res_v4cnn(positions_roi(1):positions_roi(2),positions_roi(3):positions_roi(4),...
               positions_roi(5):positions_roi(6));
regionsSpine = regions(positions_roi(1):positions_roi(2),positions_roi(3):positions_roi(4),...
               positions_roi(5):positions_roi(6));
classSpine = class(positions_roi(1):positions_roi(2),positions_roi(3):positions_roi(4),...
             positions_roi(5):positions_roi(6));
clear('im', 'im_ozn3', 'res_v4cnn', 'positions_roi','class')

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
%% určení podobnosti objektu z výstupu CAD algoritmu s anotací experta a přiřazení ground truth labelu

% prealokace proměnných pro cyklus, určení počtu objektů a velikosti CT scanu
imBounds = size(dataSpine);
objectCount = size(CADConnProps, 1);
CADObjectsStats = int16(zeros(objectCount,5));
lesionPercExp1 = zeros(objectCount,3);
expLabels = zeros(objectCount,1);
vertID = zeros(objectCount,1);

for cadLesID = 1:objectCount
    vertID(cadLesID) = mode(classSpine(CADConnMat == cadLesID),'all');
    
    % určení zastoupení typů tkáně v objektu                          
    for i = 0:2
        typeExpLesion1 = sum((dataSpineExp1(CADConnMat == cadLesID) == i));
        lesionPercExp1(cadLesID,i+1) = typeExpLesion1/numel(CADConnMat(CADConnMat == cadLesID));
    end
    [maxPerc1, maxLPerEIter1] = max(lesionPercExp1(cadLesID,2:3));
    
    % tvorba labelu 
    if (maxLPerEIter1 == 1 && maxPerc1 > 0.1) 
        expLabels(cadLesID) = 1;
    elseif (maxLPerEIter1 == 2 && maxPerc1 > 0.1)
        expLabels(cadLesID) = 2;
    elseif lesionPercExp1(cadLesID, 1) > 0.9
        expLabels(cadLesID) = 0;
    else
        expLabels(cadLesID) = 3;
    end
    
    % výpočet statistik
    objectVol = dataSpine(CADConnMat == cadLesID);
    if expLabels(cadLesID) ~= 3
        CADObjectsStats(cadLesID,:) = [mean(objectVol),...
                                       CADConnProps.Volume(cadLesID),...
                                       moment(objectVol, 2),...
                                       moment(objectVol, 3),...
                                       moment(objectVol, 4)];
    end
end

disp('Provedeno prirazeni zlateho standardu')
%% zisk 2D řezů přeškálovaných na 24x24 pixelů a labelů

% prealokace výstupních proměnných
objects = cell(1,1);
CADcuts = zeros(24,24,3,1);
outLabels = zeros(1,1);
outStats = zeros(1,5);
outVertID = zeros(1,1);
chosencutsid = 1;

% výběr lézí s jasnou kategorií a větších než zvolená velikost
for cadcutsid = 1:objectCount
    if expLabels(cadcutsid) ~= 3 && CADConnProps.Volume(cadcutsid) > 20
        
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

        % zisk zlatého standardu a statistik objektu
        outLabels(chosencutsid,1) = expLabels(cadcutsid);
        outStats(chosencutsid,:) = CADObjectsStats(cadcutsid,:);
        outVertID(chosencutsid) = vertID(cadcutsid);
        chosencutsid = chosencutsid + 1;
    else
        continue
    end
end

varargout{1} = CADcuts;
varargout{2} = outLabels;
varargout{3} = outStats;
varargout{4} = objects';
varargout{5} = outVertID;

disp('Proveden zisk 2.5D rezu')