%RICERCA IN PROFONDITA' (SENZA CONTROLLO CICLI)
ric_prof(S,[]):-finale(S), !.
ric_prof(S,[Az|Resto]):-
	applicabile(Az,S),
	trasforma(Az,S,Nuovo_S),
	ric_prof(Nuovo_S,Resto).

prof :-
	iniziale(S),
	statistics(walltime,[Start,_]),
	ric_prof(S,X),
	statistics(walltime,[End,_]),
	Time is End - Start,
	write(Time).