%RICERCA CON ITERATIVE DEEPENING (SENZA CONTROLLO CICLI)
%il secondo parametro di ric_prof_lim e' la profondita'
%il terzo parametro di ric_prof_lim e' la lista delle azioni
ric_prof_lim(S,_,[]):-finale(S), !.
ric_prof_lim(S,P,[Az|Resto]):-
	P1 is P-1,
	P1>0,
	applicabile(Az,S),
	trasforma(Az,S,Nuovo_S),
	ric_prof_lim(Nuovo_S,P1,Resto).

%procedura iterativa che richiama ric_prof_lim
%parametri di iter_deep: stato, profondità, lista_azioni		
iter_deep(S,P,Lista):-ric_prof_lim(S,P,Lista), !.
iter_deep(S,P,Lista):-
	P1 is P+1, 
	iter_deep(S,P1,Lista).
	
start_iter_deep :-
	iniziale(S),
	statistics(walltime, [Start,_]),
	iter_deep(S,1,Lista),
	statistics(walltime, [End,_]),
	Time is End - Start,
	write(Lista),nl,
	write(Time).