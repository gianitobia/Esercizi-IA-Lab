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
	
idastar :-
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