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

% Definizione euristica
calculates_heuristic(S,G,H):-
        member(X,G),
	    ord_del_element(G,X,R),
	    \+ member(X,S),!,
	    calculates_heuristic(S,R,H1),
	    H is H1+1.

calculates_heuristic(S,G,H):-
	   member(X,G),
	   ord_del_element(G,X,R),
	   calculates_heuristic(S,R,H).

calculates_heuristic(_,[],0).

% Lista Explored = Lista Closed
% RICERCA A*
% il secondo parametro è la lista degli stati visitati

ric_astar([node(_,_,S,Act_List)|_],Explored,Act_List):- 
	final(S), 
	length(Explored, L_Exp), write('Numero di nodi esplorati: '), write(L_Exp),nl.
	
ric_astar([node(F,G,S,Act_List)|List_Open],Explored,SOL) :-
	ord_del_element(List_Open,node(F,G,S,Act_List),Tail), % rimuovo l'elemento dalla lista ordinata
	\+ member(S,Explored), % true se lo stato S non è stato già visitato
	explore(node(F,G,S,Act_List),List_Succ),
	append(Explored,[S],New_Explored),
	clean_successors(List_Succ,Explored,New_List_Succ),
	list_to_ord_set(New_List_Succ,Successors), % ordino la lista trasformandola in un ordset
	ord_union(Tail,Successors,New_Tail), % unisce gli elementi dei due ordset e li ordina
	ric_astar(New_Tail,New_Explored,SOL).

ric_astar([node(F,G,S,Act_List)|List_Open],Explored,SOL):-
	ord_del_element(List_Open,node(F,G,S,Act_List),Tail),
	member(S,Explored),
	ric_astar(Tail,Explored,SOL).


explore(node(F,G,S,Act_List),List_Succ) :-
	findall(Act,apply(Act,S),Actions),
	successors(node(F,G,S,Act_List),Actions,List_Succ).
	
successors(_,[],[]).
successors(node(F,G,S,Act_List),[Act|Tail],
			[node(New_F,New_G,New_S,New_Act_List)|Other_Succ]) :-
	transform(Act,S,New_S),
	append(Act_List,[Act],New_Act_List),
	New_G is G+1,
	goal(Final),
	calculates_heuristic(New_S,Final,H),
	New_F is New_G+H,
	successors(node(F,G,S,Act_List),Tail,Other_Succ).
	
clean_successors([],_,[]).	
clean_successors([node(F,G,S,Act_List)|List_Succ],Explored,[node(F,G,S,Act_List)|New_List_Succ]):-
	\+ member(S,Explored),
	clean_successors(List_Succ,Explored,New_List_Succ).

clean_successors([node(_,_,S,_)|List_Succ],Explored,New_List_Succ):-
	member(S,Explored),
	clean_successors(List_Succ,Explored,New_List_Succ).
		
find_solution :-
	initial(S),
	goal(G),
	calculates_heuristic(S,G,H),
	list_to_ord_set([node(H,0,S,[])],Initial),
	statistics(walltime,[Start,_]),
	ric_astar(Initial,[],SOL),
	statistics(walltime,[End,_]),
	Time is End - Start,
	write('Tempo trascorso: '),
	write(Time),nl,
	write(SOL).