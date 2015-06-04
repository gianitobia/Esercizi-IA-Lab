% Ricerca IDA*

:-dynamic
	prof_finale/1.

ric_prof_lim(S,_,_,[]) :- finale(S), 
	prof_finale(P), % trovo le due profondità 
	prof_iniziale(I),
	retract(prof_finale(P)), % le rimuovo con le retract
	retract(prof_iniziale(I)),!.

ric_prof_lim(S,N,Visitati,[Az|Resto]) :-
	writeln(S),
	N>1,
	N1 is N-1,
	applicabile(Az,S),
	trasforma(Az,S,Nuovo_S),
	\+ member(Nuovo_S, Visitati), % true solo se Nuovo_S non e' stato visitato
	ric_prof_lim(Nuovo_S,N1,[S|Visitati],Resto).

% nel caso in cui siamo arrivati alla profondità finale, trovo la nuova profondità
ric_prof_lim(S,N,_,_) :- !,
	N==1,
	goal(Goal),
	calcola_euristica(S,Goal,H),
	prof_iniziale(G),
	F is G+H,
	(prof_finale(F1) ->  % se esiste prof_finale(P) allora fa il controllo altrimenti aggiunge la nuova profondità
		maggiore(F1,F); 
		assert(prof_finale(F))),
	fail. % fallisco e reitero
	
% se X > Y allora rimuovo la profondità finale X ed aggiungo la nuova Y	
maggiore(X,Y) :- 
	(X>Y -> 
		retract(prof_finale(X)),
		assert(prof_finale(Y))).

%procedura iterativa che richiama ric_prof_lim
%parametri di iter_deep: stato, profondità, lista_azioni		
iter_deep(S,N,Lista) :- ric_prof_lim(S,N,[],Lista),writeln('qui'), !.

iter_deep(S,_,Lista):-
	retract(prof_iniziale(I)),write(I),tab(5),
	prof_finale(F),
	retract(prof_finale(F)),
	assert(prof_iniziale(F)),
	writeln(F),
	iter_deep(S,F,Lista).
	
idastar :-
	writeln('iniziamo'),
	iniziale(S),
	goal(G),
	calcola_euristica(S,G,H),
	statistics(walltime, [Start,_]),
	assert(prof_iniziale(H)),
	iter_deep(S,H,Lista),
	statistics(walltime,[End,_]),
	Time is End - Start,
	writeln(Lista),
	writeln(Time).