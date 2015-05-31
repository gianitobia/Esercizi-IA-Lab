% Definizione azioni applicabili ed eseguibili
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

apply(pickup(X),S):-
	block(X),
	ord_memberchk(ontable(X),S),
	ord_memberchk(clear(X),S),
	ord_memberchk(handempty,S).
	
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
	list_to_ord_set([ontable(X),clear(X),handempty],States_to_Remove),
	ord_subtract(S1,States_to_Remove,S),
	list_to_ord_set([holding(X)],States_to_Add),
	ord_union(S,States_to_Add,S2).
	
transform(putdown(X),S1,S2):-
	block(X),
	list_to_ord_set([holding(X)],States_to_Remove),
	ord_subtract(S1,States_to_Remove,S),
	list_to_ord_set([ontable(X),clear(X),handempty],States_to_Add),
	ord_union(S,States_to_Add,S2).

transform(stack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([holding(X),clear(Y)],States_to_Remove),
	ord_subtract(S1,States_to_Remove,S),
	list_to_ord_set([on(X,Y),clear(X),handempty],States_to_Add),
	ord_union(S,States_to_Add,S2).

transform(unstack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([on(X,Y),clear(X),handempty],States_to_Remove),
	ord_subtract(S1,States_to_Remove,S),
	list_to_ord_set([holding(X),clear(Y)],States_to_Add),
	ord_union(S,States_to_Add,S2).


% Definizione dominio - Stato initial - Stato finale
% esempio Prof. Torasso
block(a).
block(b).
block(c).
block(d).
block(e).
block(f).
block(g).
block(h).


initial(S):-
	list_to_ord_set([clear(a), clear(c), clear(d), clear(e), clear(f), clear(g), clear(h), on(a,b), ontable(b), ontable(c), ontable(d), ontable(e), ontable(f), ontable(g), ontable(h), handempty],S).

goal(G):- list_to_ord_set([on(a,b),on(b,c),on(c,d),on(d,e),
	ontable(e)],G).

final(S):- goal(G), ord_subset(G,S).

% Strategia in profondita` su grafo, ossia con controllo per evitare cicli su stati gia' esplorati


%definizione passo base della ricorsione
deep_graph_search(S,_,[]) :- final(S), !.

%definizione passo ricorsivo
deep_graph_search(S, Explored, [Action|Tail]) :-
	apply(Action, S),
	transform(Action, S, S_Updated),
	\+  member(S_Updated, Explored),
	deep_graph_search(S_Updated, [S|Explored], Tail).
	% Aggiorno la lista degli esplorati con gli stati che avevo in S
	% lo stato appena generato, se non e' finale sara' aggiunto alla 
	% ricorsione successiva, xke salvato in S_Updated.

find_solution :-
	initial(S),
	statistics(walltime,[Start,_]),
	deep_graph_search(S, [], List),		% [] = lista degli stati esplorati, inizialmente vuota.
	statistics(walltime,[End,_]),
	Time is End - Start,
	write(List),
	write(Time).