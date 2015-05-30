% Definizione azioni applicabili ed eseguibili
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

applicabile(pickup(X),S):-
	block(X),
	ord_memberchk(ontable(X),S),
	ord_memberchk(clear(X),S),
	ord_memberchk(handempty,S).
	
applicabile(putdown(X),S):-
	block(X),
	ord_memberchk(holding(X),S).
	
applicabile(stack(X,Y),S):-
	block(X), block(Y), X\=Y,
	ord_memberchk(holding(X),S),
	ord_memberchk(clear(Y),S).

applicabile(unstack(X,Y),S):-
	block(X), block(Y), X\=Y,
	ord_memberchk(on(X,Y),S),
	ord_memberchk(clear(X),S),
	ord_memberchk(handempty,S).
	
	
trasforma(pickup(X),S1,S2):-
	block(X),
	list_to_ord_set([ontable(X),clear(X),handempty],DLS),
	ord_subtract(S1,DLS,S),
	list_to_ord_set([holding(X)],ALS),
	ord_union(S,ALS,S2).
	
trasforma(putdown(X),S1,S2):-
	block(X),
	list_to_ord_set([holding(X)],DLS),
	ord_subtract(S1,DLS,S),
	list_to_ord_set([ontable(X),clear(X),handempty],ALS),
	ord_union(S,ALS,S2).

trasforma(stack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([holding(X),clear(Y)],DLS),
	ord_subtract(S1,DLS,S),
	list_to_ord_set([on(X,Y),clear(X),handempty],ALS),
	ord_union(S,ALS,S2).

trasforma(unstack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([on(X,Y),clear(X),handempty],DLS),
	ord_subtract(S1,DLS,S),
	list_to_ord_set([holding(X),clear(Y)],ALS),
	ord_union(S,ALS,S2).


% Definizione dominio - Stato iniziale - Stato finale

%:- use_module(library(lists)).
%:- use_module(library(ordsets)).

% esempio Prof. Torasso
block(a).
block(b).
block(c).
block(d).
block(e).
block(f).
block(g).
block(h).
block(i).


iniziale(S):-
	list_to_ord_set([ clear(f),clear(a), clear(d), clear(g), 
			ontable(f), on(a,b), on(b,c), ontable(c), on(d,e), ontable(e), on(g,h), on(h,i), ontable(i), handempty],S).

goal(G):- list_to_ord_set([on(a,b),on(b,c),on(c,g),ontable(g),on(d,e),on(e,f),
	ontable(f),on(h,i),ontable(i)],G).

finale(S):- goal(G), ord_subset(G,S).

% Strategia in profondita` su alberi