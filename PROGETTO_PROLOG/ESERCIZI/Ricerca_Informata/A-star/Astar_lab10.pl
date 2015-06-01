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
% Esempio 10 x 10

num_col(10).
num_righe(10).

wall(pos(2,5)).
wall(pos(3,5)).
wall(pos(4,5)).
wall(pos(5,5)).
wall(pos(6,5)).
wall(pos(7,5)).
wall(pos(7,1)).
wall(pos(7,2)).
wall(pos(7,3)).
wall(pos(7,4)).
wall(pos(5,7)).
wall(pos(6,7)).
wall(pos(7,7)).
wall(pos(8,7)).
wall(pos(4,7)).
wall(pos(4,8)).
wall(pos(4,9)).
wall(pos(4,10)).

initial(pos(4,2)).

final(pos(7,9)).

% Definizione euristica
calcola_euristica(pos(Ri,Ci),pos(Rf,Cf),H) :-
	Rt is Ri - Rf,
	Ct is Ci - Cf,
	H is abs(Rt) + abs(Ct).

% Lista Explored = Lista Closed
% RICERCA A*
% il secondo parametro è la lista degli stati visitati

ric_astar(List_Open,_,Act_List):- 
	member(node(_,_,S,Act_List),List_Open),
	final(S).
	
ric_astar(List_Open,Explored,SOL) :-
	member(node(F,G,S,Act_List),List_Open), % true se la lista non è vuota
	ord_del_element(List_Open,node(F,G,S,Act_List),Tail), % rimuovo l'elemento dalla lista ordinata
	\+ member(S,Explored), % true se lo stato S non è stato già visitato
	explore(node(F,G,S,Act_List),List_Succ),
	append(Explored,[S],New_Explored),
	list_to_ord_set(List_Succ,Successors), % ordino la lista trasformandola in un ordset
	ord_union(Tail,Successors,New_Tail), % unisce gli elementi dei due ordset e li ordina
	ric_astar(New_Tail,New_Explored,SOL).

ric_astar(List_Open,Explored,SOL):-
	member(node(F,G,S,Act),List_Open),
	ord_del_element(List_Open,node(F,G,S,Act),Tail),
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
	
find_solution :-
	initial(S),
	goal(G),
	calculates_heuristic(S,G,H),
	list_to_ord_set([node(H,0,S,[])],Initial),
	statistics(walltime,[Start,_]),
	ric_astar(Initial,[],SOL),
	statistics(walltime,[End,_]),
	Time is End - Start,
	write(SOL),nl,
	write(Time).