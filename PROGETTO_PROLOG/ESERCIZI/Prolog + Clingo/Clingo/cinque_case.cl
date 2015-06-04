%FATTI INIZIALI
nazionalita(giapponese;inglese;italiano;norvegese;spagnolo).
professione(diplomatico;dottore;pittore;scultore;violinista).
animale(cane;cavallo;lumaca;volpe;zebra).
bevanda(aranciata;caffe;latte;succo;te).
colore(bianco;blu;giallo;rosso;verde).
casa(1..5).

%REGOLE IMPOSTE DAL PROBLEMA
f1 :- ownNaz(X,inglese), ownCol(X,rosso).
f2 :- ownNaz(X,spagnolo), ownAnim(X,cane).
f3 :- ownNaz(X,giapponese), ownProf(X,pittore).
f4 :- ownNaz(X,italiano), ownBev(X,te).
f5 :- ownNaz(1,norvegese).
f6 :- ownCol(X,verde), ownBev(X,caffe).
f7 :- ownCol(X,verde), ownCol(Y,bianco), X=Y+1.
f8 :- ownProf(X,scultore), ownAnim(X,lumaca).
f9 :- ownProf(X,diplomatico), ownCol(X,giallo).
f10 :- ownBev(3,latte).
f11 :- ownNaz(X,norvegese), ownCol(Y,blu), near(X,Y).
f12 :- ownProf(X,violinista), ownBev(X,succo).
f13 :- ownAnim(X,volpe), ownProf(Y,dottore), near(X,Y).
f14 :- ownAnim(X,cavallo), ownProf(Y,diplomatico), near(X,Y).

%VINCOLO ADIACENZA CASE
near(X,Y) :- casa(X), casa(Y), |X-Y|=1.

%REGOLE + ESPRESSIONE VINCOLI PER MEZZO DI AGGREGATI
%AD OGNI CASA E' ASSOCIATA UNA ED UNA SOLA NAZIONALITA', PROFESSIONE, ECC...
1{ ownNaz(X,Y): casa(X) }1 :- nazionalita(Y).
1{ ownProf(X,Y): casa(X) }1 :- professione(Y).
1{ ownAnim(X,Y): casa(X) }1 :- animale(Y).
1{ ownBev(X,Y): casa(X) }1 :- bevanda(Y).
1{ ownCol(X,Y): casa (X) }1 :- colore(Y).

%VINCOLI DI INTEGRITA'
:- ownNaz(X,Y), ownNaz(X,Z), Y!=Z.
:- ownProf(X,Y), ownProf(X,Z), Y!=Z.
:- ownAnim(X,Y), ownAnim(X,Z), Y!=Z.
:- ownBev(X,Y), ownBev(X,Z), Y!=Z.
:- ownCol(X,Y), ownCol(X,Z), Y!=Z.

#show ownNaz/2.
#show ownProf/2.
#show ownAnim/2.
#show ownBev/2.
#show ownCol/2.