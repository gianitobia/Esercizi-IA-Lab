% Descrizione delle azioni

% prerequisiti per l'applicazione
apply(est,pos(R,C)) :- 
	num_col(NC), C<NC,
	C1 is C+1,
	\+ wall(pos(R,C1)).

apply(sud,pos(R,C)) :- 
	num_righe(NR), R<NR,
	R1 is R+1,
	\+ wall(pos(R1,C)).

apply(ovest,pos(R,C)) :- 
	C>1,
	C1 is C-1,
	\+ wall(pos(R,C1)).

apply(nord,pos(R,C)) :- 
	R>1,
	R1 is R-1,
	\+ wall(pos(R1,C)).

% effetto ottenuto dall'applicazione
transform(est,pos(R,C),pos(R,C1)) :- C1 is C+1.
transform(ovest,pos(R,C),pos(R,C1)) :- C1 is C-1.
transform(sud,pos(R,C),pos(R1,C)) :- R1 is R+1.
transform(nord,pos(R,C),pos(R1,C)) :- R1 is R-1.


%%%%%%% Descrizione dello scenario
% Esempio 20 x 20

num_col(20).
num_righe(20).

wall(pos(7,15)).
wall(pos(8,15)).
wall(pos(9,15)).
wall(pos(10,15)).
wall(pos(11,15)).
wall(pos(12,15)).
wall(pos(13,15)).
wall(pos(13,6)).
wall(pos(13,7)).
wall(pos(13,8)).
wall(pos(13,9)).
wall(pos(13,10)).
wall(pos(13,11)).
wall(pos(13,12)).
wall(pos(13,13)).
wall(pos(13,14)).
wall(pos(15,1)).
wall(pos(15,2)).
wall(pos(15,3)).
wall(pos(15,4)).
wall(pos(15,5)).
wall(pos(15,6)).
wall(pos(15,7)).
wall(pos(15,8)).
wall(pos(15,9)).


initial(pos(10,10)).

final(pos(20,20)).

% Definizione della strategia di Iterative Deepening
% Richiamo la strategia di ricerca con profondita' limitata
% incrementando la profondita' finche` non trovo la soluzione

% Ricerca prof limitata

% PASSO BASE della ricorsione
deep_search_lim(S,_,[]) :- final(S), !.		% utilizzo una variabile anonima perche` il limite
											% lo controllo nel passo ricorsivo
%PASSO Ricorsivo
deep_search_lim(S, Limit, [Action|Tail]) :-
	New_Limit is Limit - 1,
	New_Limit > 0, 
	apply(Action, S),
	transform(Action, S, S_Updated),
	deep_search_lim(S_Updated, New_Limit, Tail).
	
	
% Gestione dei richieami iterativi delle strategie di prof limitata
iter_deep(S, Limit, List) :- deep_search_lim(S, Limit, List), !.
iter_deep(S, Limit, List) :-
	New_Limit is Limit + 1,
	iter_deep(S, New_Limit, List).


find_solution :-
	initial(S),	
	statistics(walltime,[Start,_]),
	iter_deep(S, 1, List),
	statistics(walltime,[End,_]),
	Time is End - Start,
	write(List), nl,
	write(Time).