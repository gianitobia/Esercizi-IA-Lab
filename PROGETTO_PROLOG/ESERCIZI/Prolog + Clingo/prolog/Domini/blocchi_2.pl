:- use_module(library(lists)).
:- use_module(library(ordsets)).

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

