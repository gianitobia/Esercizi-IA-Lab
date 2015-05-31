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

% Stategia di ricerca in ampiezza sul grafo

% PASSO BASE della ricorsione
breadth_graph_search([node(S,Act_List)|_],Act_List,_):- final(S).

% passo ricorsivo
breadth_graph_search([node(S,Act_List)|Tail],SOL,Explored):-
	\+ member(S,Explored), % true solo se S non è stato visitato
	explore(node(S,Act_List),List_Succ),
	append(Explored,[S],New_Explored),	
	append(Tail,List_Succ,New_Tail),
	breadth_graph_search(New_Tail,SOL,New_Explored).

% regola per scegliere da quale nodo ripartire con l'esplorazione, se il nodo appena considerato ha lista di successori vuota.
breadth_graph_search([node(_,_)|Tail],SOL,Explored):-
	breadth_graph_search(Tail,SOL,Explored).

% Espando tutti i successori di un particolare nodo, in base al numero di azioni che posso esseguire in quello step.
explore(node(S,Act_List),List_Succ):-
	findall(Act,apply(Act,S),Act_to_exec),
	successors(node(S,Act_List),Act_to_exec,List_Succ).
	
%genero ricorsivamente tutti i successori, applicando le trasformazioni per le azioni possibili
successors(_,[],[]).
successors(node(S,Act_List), [Act|Tail], [node(New_S,New_Act_List)|Other_Succ]):-
	transform(Act,S,New_S),
	append(Act_List,[Act],New_Act_List),
	successors(node(S,Act_List),Tail,Other_Succ).

find_solution :-
	statistics(walltime,[Start,_]),
	initial(S),
	breadth_graph_search([node(S, [])], SOL, []),
	statistics(walltime,[End,_]),
	Time is End - Start,
	write(Time),nl,
	write(SOL).