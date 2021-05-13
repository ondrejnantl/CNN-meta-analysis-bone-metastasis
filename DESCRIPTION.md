# DOKUMENTACE KE KÓDU K BP
-----------------------------------------------------------------------------------------------------------------------
## Autor: Ondřej Nantl
-----------------------------------------------------------------------------------------------------------------------
Tento repozitář obsahuje následující zdrojové kódy (soubory s příponou .m):

augmentDataset - funkce slouží k náhodné augmentaci objektů translací a rotací

classifyPatient - slouží k meta-analýze kostních nádorových lézí pro 1 pacienta, vstup ve formátu .mat

getLesions - funkce sloužící k extrakci 2.5D řezů, statistik a kategoríí zlatého standardu objektů
             v 1 CT scanu pacienta při procesu učení
             
getLesions_newPat - funkce sloužící k extrakci 2.5D řezů a statistik objektů
                    v 1 CT scanu pacienta při procesu meta-analýzy nového pacienta
                    
netBinaryCrossVal - skript sloužící k rozdělení datasetu na učení metodou křížové validace a následné učení modelů
                    k binární klasifikaci typu nádorová léze - zdravá tkáň + vyhodnocení jejich úspěšnosti
                    
netBlasticCrossVal - skript sloužící k rozdělení datasetu na učení metodou křížové validace a následné učení modelů
                     ke klasifikaci osteoblastické tkáně + vyhodnocení jejich úspěšnosti
                     
netLyticCrossVal - skript sloužící k rozdělení datasetu na učení metodou křížové validace a následné učení modelů
                   ke klasifikaci osteolytické tkáně + vyhodnocení jejich úspěšnosti
                   
netMultiCrossVal - skript sloužící k rozdělení datasetu na učení metodou křížové validace a následné učení modelů
                   k binární klasifikaci typu nádorová léze - zdravá tkáň + vyhodnocení jejich úspěšnosti
                   
perfScores - funkce sloužící pro výpočet úspněšnostních metrik pro modely zařazující pouze do dvou tříd

perfScoresMulti - funkce sloužící pro výpočet úspněšnostních metrik pro model zařazující do tří tříd

perfScoresVert - funkce sloužící pro výpočet úspněšnostních metrik vztažených na obratel pro modely zařazující 
                 pouze do dvou tříd
                 
perfScores - funkce sloužící pro výpočet úspněšnostních metrik vztažených na obratel pro model zařazující do tří tříd

prepareDataset - skript sloužící pro zisk jednotného datasetu a jeho přípravu a uložení před augmentací

ROCgraph - skript pro tvorbu průměrných ROC křivek

saveDataset - funkce sloužící k tvorbě jednotného datasetu z dat od jednotlivých pacientů



Dále tento repozitář obsahuje ve složce \models soubory .mat:

netBinaryWorksp - naučené sítě ke klasifikaci typu nádorová léze - zdravá tkáň metodou křížové validace 
                  (kategorie 1 - zdravá tkáň, kategorie 2 - nádorová léze) + dosažené výsledky
                  
netBlasticWorksp - naučené sítě ke klasifikaci osteoblastických lézí metodou křížové validace
                   (kategorie 1 - ostatní typy tkáně, kategorie 2 - osteoblastická léze) + dosažené výsledky
                   
netLyticWorksp - naučené sítě ke klasifikaci osteolytických lézí metodou křížové validace 
	               (kategorie 1 - ostatní typy tkáně, kategorie 2 - osteolytická léze) + dosažené výsledky
                 
netMulticlassWorks - naučená síť ke klasifikaci osteoblastických i osteolytických lézí současně 
                     (kategorie 0 - zdravá tkáň, kategorie 1 - osteolytická léze, kategorie 2 - osteoblastická léze)
                     + dosažené výsledky

------------------------------------------------------------------------------------------------------------------------
## Postup spouštění
### Učení modelů

1) Spustit skript prepareDataset - změnit cestu k souborům pacientů!
                                 - využívá funkce getLesions, saveDataset
3) Spustit skript netxxxxxCrossVal - provede augmentaci (funkce augmentDataset) a následně naučení modelů křížovou 
   validací a výpočet úspěšnostních metrik (funkce perfScores a perfScoresVert)
   
### Klasifikace nových pacientů

1) Spustit skript classifyPatient (provede zisk 2,5D řezů - funkce getLesions_newPat a klasifikaci všemi modely)
