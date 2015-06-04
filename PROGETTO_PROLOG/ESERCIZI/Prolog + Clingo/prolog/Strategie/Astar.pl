:- use_module(library(lists)).
:- use_module(library(ordsets)).

% Lista Visitati = Lista Closed
% RICERCA A*
% il secondo parametro è la lista degli stati visitati

ric_astar(Lista_Open,_,Lista_AZ):- 
	member(nodo(_,_,S,Lista_AZ),Lista_Open),
	finale(S).
	
ric_astar(Lista_Open,Visitati,SOL) :-
	member(nodo(F,G,S,Lista_AZ),Lista_Open), % true se la lista non è vuota
	ord_del_element(Lista_Open,nodo(F,G,S,Lista_AZ),Resto), % rimuovo l'elemento dalla lista ordinata
	\+ member(S,Visitati), % true se lo stato S non è stato già visitato
	espandi(nodo(F,G,S,Lista_AZ),LISTA_SUCC),
	append(Visitati,[S],Nuovo_Visitati),
	list_to_ord_set(LISTA_SUCC,Successivi), % ordino la lista trasformandola in un ordset
	ord_union(Resto,Successivi,Coda), % unisce gli elementi dei due ordset e li ordina
	ric_astar(Coda,Nuovo_Visitati,SOL).

ric_astar(Lista_Open,Visitati,SOL):-
	member(nodo(F,G,S,AZ),Lista_Open),
	ord_del_element(Lista_Open,nodo(F,G,S,AZ),RESTO),
	member(S,Visitati),
	ric_astar(RESTO,Visitati,SOL).


espandi(nodo(F,G,S,Lista_AZ),LISTA_SUCC) :-
	findall(AZ,applicabile(AZ,S),Azioni),
	successori(nodo(F,G,S,Lista_AZ),Azioni,LISTA_SUCC).
	
successori(_,[],[]).
successori(nodo(F,G,S,Lista_AZ),[AZ|Resto],
			[nodo(Nuovo_F,Nuovo_G,Nuovo_S,Nuovo_Lista_AZ)|Altri]) :-
	trasforma(AZ,S,Nuovo_S),
	append(Lista_AZ,[AZ],Nuovo_Lista_AZ),
	Nuovo_G is G+1,
	goal(Finale),
	calcola_euristica(Nuovo_S,Finale,H),
	Nuovo_F is Nuovo_G+H,
	successori(nodo(F,G,S,Lista_AZ),Resto,Altri).
	
astar :-
	iniziale(S),
	goal(G),
	calcola_euristica(S,G,H),
	list_to_ord_set([nodo(H,0,S,[])],Iniziale),
	statistics(walltime,[Start,_]),
	ric_astar(Iniziale,[],SOL),
	statistics(walltime,[End,_]),
	Time is End - Start,
	write(SOL),nl,
	write(Time).