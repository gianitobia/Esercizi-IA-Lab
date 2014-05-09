p([1,2,3,4,5]).


concat([], L, L).
concat([H|T], L, [H|T1]) :- concat(T, L, T1).

/*
posso chiedere a prolog di ragionare all'indietro sulla concatenazione:
- append(X,Y, [a,b,c,d]).
	X = [],
	Y = [a, b, c, d] ;
	
	X = [a],
	Y = [b, c, d] ;
	
	X = [a, b],
	Y = [c, d] ;
	
	X = [a, b, c],
	Y = [d] ;
	
	X = [a, b, c, d],
	Y = [] ;

primo elemento della lista
- p([X|Y])
	X = 1,
	Y = [2, 3, 4, 5].

ultimo elemento bisogna calcolarsi il predicato

concatenazione alla fine
- p(X), append(X, [0], Z).
X = [1, 2, 3, 4, 5],
Z = [1, 2, 3, 4, 5, 0].
*/

/* Versione NAIVE*/ 
inv([], []).
inv([H|T], LR):- inv(T, TR), append(TR, [H], LR).

rev_iter([], Res, Res).
rev_iter([H|T], ACC, Res) :- rev_iter(T, [H|ACC], Res).
reverse2(L, LR) :- rev_iter(L, [], LR).

/*Palindromo*/
palindromo(X) :- reverse(X,X)

/*Permutazione degli elementi di una lista*/
permut([],[]).
permut(List, [Element|Permutation]) :- select(Element, List, Rest), permut(Rest, Permutation).

/*fattoriale*/
fatt(0,1).
fatt(N,Y):- N>0, N1 is N-1, fatt(N1,Y1), Y is Y1 * N. 
/*in questo modo non valuto il risultato ma ottengo un risultato simbolico  quindi sostiuisco a = , is*/

lung([],0).
lung([X|T], N):- lung(T, NT), N is NT+1.

int([],S2,[]).
int([X|REST], S2, [X|REST1]) :- member(X,S2), !, int(REST,S2,REST1).
int([_|REST], S2, REST1) :- int(REST, S2, REST1).
/* Simbolo ! indica il CUT, ovvero la potatura di alcuni rami nell'albero di derivazione
   riducendo il numero di scelte possibili da eseguire */



