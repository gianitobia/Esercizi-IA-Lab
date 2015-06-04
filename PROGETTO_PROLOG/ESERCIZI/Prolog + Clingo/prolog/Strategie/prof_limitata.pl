%RICERCA A PROFONDITA' LIMITATA (SENZA CONTROLLO CICLI)
%il secondo parametro di ric_prof_lim e' la profondita'
ric_prof_lim(S,_,[]):-finale(S), !.
ric_prof_lim(S,P,[Az|Resto]):-
	P1 is P-1, %decremento P1 fino a quando non e' 0, in questo caso ho raggiunto la profondità massima
	P1>0,
	applicabile(Az,S),
	trasforma(Az,S,Nuovo_S),
	ric_prof_lim(Nuovo_S,P1,Resto).

prof_lim :-
	iniziale(S),
	X is 25, % quale valore diamo? 5 va bene? facciamo 10?
	statistics(walltime,[Start,_]),
	ric_prof_lim(S,X,Lista),
	statistics(walltime,[End,_]),
	Time is End - Start,
	write(Lista),
	write(Time).