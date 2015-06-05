%Fatti iniziali

colore(rossa).
colore(gialla).
colore(verde).
colore(blu).
colore(bianca).

bevanda(the).
bevanda(caffe).
bevanda(latte).
bevanda(succo).

professione(dottore).
professione(diplomatico).
professione(pittore).
professione(scultore).
professione(violinista).

animale(cane).
animale(lumaca).
animale(volpe).
animale(zebra).
animale(cavallo).

nazionalita(inglese).
nazionalita(spagnolo).
nazionalita(giapponese).
nazionalita(italiano).
nazionalita(norvegese).

casa(1..5).

f1 :- abitaNaz(X,inglese) , abitaCol(X,rossa).
f2 :- abitaNaz(X,spagnolo) , abitaAni(X,cane).
f3 :- abitaNaz(X,giapponese) , abitaProf(X,pittore).
f4 :- abitaNaz(X,italiano) , abitaBev(X,the).
f5 :- abitaNaz(1,norvegese).
f6 :- abitaCol(X,verde), abitaBev(X,caffe).
f7 :- abitaCol(X,verde) , abitaCol(X,bianca).
f8 :- abitaProf(X,scultore) , abitaAni(X,lumaca).
f9 :- abitaProf(X,diplomatico) , abitaCol(X,gialla).
f10 :- abitaBev(3,latte).
f11 :- abitaNaz(X,norvegese), abitaCol(Y,blu), |X-Y|=1.
f12 :- abitaProf(X,violinista),abitaBev(X,succo).
f13 :- abitaAni(X,volpe), abitaProf(Y,dottore), |X-Y|=1.
f14 :- abitaAni(X,cavallo), abitaProf(Y,diplomatico), |X-Y|=1.

%Regole generative
1 {abitaNaz(X,Y):casa(X)}1:-nazionalita(Y).
1 {abitaProf(X,Y):casa(X)}1:-professione(Y).
1 {abitaBev(X,Y):casa(X)}1:-bevanda(Y).
1 {abitaCol(X,Y):casa(X)}1:-colore(Y).
1 {abitaAni(X,Y):casa(X)}1:-animale(Y).

1 { 
	abitaNaz(X,Y);
	abitaCol(X,C);
	abitaProf(X,P);
	abitaBev(X,B);
	abitaAni(X,A)
	
} 1 :- nazionalita(Y), colore(C), professione(P), bevanda(B), animale(A), casa(X). 

:- abitaNaz(X,Y), abitaNaz(X,Z), Y!=Z.
:- abitaCol(X,Y), abitaCol(X,Z), Y!=Z.
:- abitaBev(X,Y), abitaBev(X,Z), Y!=Z.
:- abitaProf(X,Y), abitaProf(X,Z), Y!=Z.
:- abitaAni(X,Y), abitaAni(X,Z), Y!=Z.

#show abitaNaz/2.
#show abitaAni/2.
#show abitaBev/2.
#show abitaProf/2.
#show abitaCol/2.