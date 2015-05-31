% Definizione azioni applicabili ed eseguibili
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

apply(pickup(X),S):-
	block(X),
	ord_memberchk(ontable(X),S),				
	ord_memberchk(clear(X),S),
	ord_memberchk(handempty,S).

%ord_memberchk = Controllo che in S sia presente lo stato X;

apply(putdown(X),S):-
	block(X),
	ord_memberchk(holding(X),S).
	
apply(stack(X,Y),S):-
	block(X), block(Y), X\=Y,
	ord_memberchk(holding(X),S),
	ord_memberchk(clear(Y),S).

apply(unstack(X,Y),S):-
	block(X), block(Y), X\=Y,
	ord_memberchk(on(X,Y),S),
	ord_memberchk(clear(X),S),
	ord_memberchk(handempty,S).
	
	
transform(pickup(X),S1,S2):-
	block(X),
	list_to_ord_set([ontable(X),clear(X),handempty], States_to_Remove), 	
	ord_subtract(S1, States_to_Remove, S),
	list_to_ord_set([holding(X)], States_to_Add),						
	ord_union(S,States_to_Add,S2).
	
transform(putdown(X),S1,S2):-
	block(X),
	list_to_ord_set([holding(X)], States_to_Remove),
	ord_subtract(S1, States_to_Remove,S),
	list_to_ord_set([ontable(X),clear(X),handempty], States_to_Add),
	ord_union(S, States_to_Add, S2).

transform(stack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([holding(X),clear(Y)], States_to_Remove),
	ord_subtract(S1, States_to_Remove,S),
	list_to_ord_set([on(X,Y),clear(X),handempty], States_to_Add),
	ord_union(S, States_to_Add,S2).

transform(unstack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([on(X,Y),clear(X),handempty], States_to_Remove),
	ord_subtract(S1, States_to_Remove, S),
	list_to_ord_set([holding(X), clear(Y)], States_to_Add),
	ord_union(S, States_to_Add, S2).


% Definizione dominio - Stato iniziale - Stato finale

block(a).
block(b).
block(c).
block(d).
block(e).

initial(S):-
	list_to_ord_set([on(a,b),on(b,c),ontable(c),clear(a),on(d,e),
						  ontable(e),clear(d),handempty],S).

goal(G):- list_to_ord_set([on(a,b),on(b,c),on(c,d),ontable(d),ontable(e)],G).

final(S):- goal(G), ord_subset(G,S).

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