calcola_euristica(S,G,H):-
        member(X,G),
	    ord_del_element(G,X,R),
	    \+ member(X,S),!,
	    calcola_euristica(S,R,H1),
	    H is H1+1.

calcola_euristica(S,G,H):-
	   member(X,G),
	   ord_del_element(G,X,R),
	   calcola_euristica(S,R,H).

calcola_euristica(_,[],0).