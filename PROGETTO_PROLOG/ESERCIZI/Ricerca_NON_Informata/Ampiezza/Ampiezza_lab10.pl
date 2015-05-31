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