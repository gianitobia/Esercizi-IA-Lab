1 {casa(X,Nazionalita,Colore,Professione,Animale,Bevanda): 
		nazionalita(Nazionalita), 
		colore(Colore), 
		bevanda(Bevanda), 
		animale(Animale), 
		professione(Professione)}1 :- X=1..5.

colore(rossa).
colore(gialla).
colore(verde).
colore(blu).
colore(bianca).

bevanda(the).
bevanda(caffe).
bevanda(latte).
bevanda(succo).
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

:- casa(X1,)
#show casa/6.