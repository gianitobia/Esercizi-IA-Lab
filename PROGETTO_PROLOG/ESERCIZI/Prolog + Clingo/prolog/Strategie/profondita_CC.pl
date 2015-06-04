%RICERCA IN PROFONDITA' (CON CONTROLLO CICLI)
%il secondo parametro di ric_prof e' la lista degli stati visitati
ric_prof_cc(S,_,[]):-finale(S), !.
ric_prof_cc(S,Visitati,[Az|Resto]):-
	applicabile(Az,S),
	trasforma(Az,S,Nuovo_S),
	\+ member(Nuovo_S, Visitati),
	ric_prof_cc(Nuovo_S,[S|Visitati],Resto).
	

prof_cc :-
	iniziale(S),
	statistics(walltime,[Start,_]),
	ric_prof_cc(S,[],Lista),
	statistics(walltime,[End,_]),
	Time is End - Start,
	writeln(Lista),
	writeln(Time).