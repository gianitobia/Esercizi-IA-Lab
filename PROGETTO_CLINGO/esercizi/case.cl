%Fatti iniziali

colore(rossa).
colore(gialla).
colore(verde).
colore(blu).
colore(bianca).

bevanda(the).
bevanda(caffe).
bevanda(latte).
bevanda(birra).

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

:- abitaNaz(X,inglese) , abitaCol(Y,rossa) , X!=Y.
:- abitaNaz(X,spagnolo) , abitaAni(Y,cane) , X!=Y.
:- abitaNaz(X,giapponese) , abitaProf(Y,pittore), X!=Y.
:- abitaNaz(X,italiano) , abitaBev(Y,the), X!=Y.
:- abitaNaz(X,norvegese), X != 1.
:- abitaCol(X,verde), abitaBev(Y,caffe), X!=Y.
:- abitaCol(X,verde) , abitaCol(Y,bianca), X!=Y+1.
:- abitaProf(X,scultore) , abitaAni(Y,lumaca), X!=Y.
:- abitaProf(X,diplomatico) , abitaCol(Y,gialla), X!=Y.
:- abitaBev(X,latte), X!=3.
:- abitaNaz(X,norvegese), abitaCol(Y,blu), |X-Y|!=1.
:- abitaProf(X,violinista),abitaBev(Y,succo), X!=Y.
:- abitaAni(X,volpe), abitaProf(Y,dottore), |X-Y|!=1.
:- abitaAni(X,cavallo), abitaProf(Y,diplomatico), |X-Y|!=1.

%Regole generative
1 {abitaNaz(X,Y):casa(X)}1:-nazionalita(Y).
1 {abitaProf(X,Y):casa(X)}1:-professione(Y).
1 {abitaBev(X,Y):casa(X)}1:-bevanda(Y).
1 {abitaCol(X,Y):casa(X)}1:-colore(Y).
1 {abitaAni(X,Y):casa(X)}1:-animale(Y).



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