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

goal(pos(7,9)).

final(S):-goal(S).

% Definizione euristica
calculates_heuristic(pos(Ri,Ci),pos(Rf,Cf),H) :-
	Rt is Ri - Rf,
	Ct is Ci - Cf,
	H is abs(Rt) + abs(Ct).

% Ricerca IDA*

:-dynamic
	new_deep/1.

deep_graph_lim_search(S,_,_,[]) :- 
	final(S), 
	new_deep(P), % trovo le due profondità 
	actual_deep(I),
	retract(new_deep(P)), % le rimuovo con le retract
	retract(actual_deep(I)),!.

deep_graph_lim_search(S,Actual_Dist,Explored,[Act|Tail]) :-
%	writeln(S),
	Actual_Dist>1,
	New_Dist is Actual_Dist-1,
	apply(Act,S),
	transform(Act,S,New_S),
	\+ member(New_S, Explored), % true solo se Nuovo_S non e' stato visitato
	deep_graph_lim_search(New_S,New_Dist,[S|Explored],Tail).

% nel caso in cui siamo arrivati alla profondità finale, trovo la nuova profondità
deep_graph_lim_search(S,Actual_Dist,_,_) :- !,
	Actual_Dist==1,
	goal(Goal),
	calculates_heuristic(S,Goal,H),
	actual_deep(G),
	F is G+H,
	(new_deep(F1) ->  % se esiste new_deep(P) allora fa il controllo altrimenti aggiunge la nuova profondità
		min(F1,F); 
		assert(new_deep(F))),
	fail. % fallisco e reitero
	
% se X > Y allora rimuovo la profondità finale X ed aggiungo la nuova Y	
min(X,Y) :- 
	(Y<X -> 
		retract(new_deep(X)),
		assert(new_deep(Y))).

%procedura iterativa che richiama deep_graph_lim_search
%parametri di iter_deep: stato, profondità, lista_azioni		
iter_deep(S,Actual_Dist,Act_List) :- deep_graph_lim_search(S,Actual_Dist,[],Act_List),writeln('qui'), !.

iter_deep(S,_,Act_List):-
	retract(actual_deep(I)),
	write(I),
	tab(5),
	new_deep(F),
	retract(new_deep(F)),
	assert(actual_deep(F)),
	writeln(F),
	iter_deep(S,F,Act_List).
	
find_solution :-
	writeln('start'),
	initial(S),
	goal(G),
	calculates_heuristic(S,G,H),
	statistics(walltime, [Start,_]),
	assert(actual_deep(H)),
	iter_deep(S,H,Act_List),
	statistics(walltime,[End,_]),
	Time is End - Start,
	writeln(Act_List),
	writeln(Time).