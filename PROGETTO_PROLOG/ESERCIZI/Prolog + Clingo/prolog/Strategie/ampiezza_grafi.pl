% Ricerca in ampiezza su grafi
% il secondo parametro è la lista degli stati già visitati

ric_amp_grafi([nodo(S,LISTA_AZ)|_],LISTA_AZ,_):- finale(S).

ric_amp_grafi([nodo(S,LISTA_AZ)|RESTO],SOL,Visitati):-
	\+ member(S,Visitati), % true solo se S non è stato visitato
	espandi(nodo(S,LISTA_AZ),LISTA_SUCC),
	append(Visitati,[S],Nuovo_Visitati),	
	append(RESTO,LISTA_SUCC,CODA),
	ric_amp_grafi(CODA,SOL,Nuovo_Visitati).

ric_amp_grafi([nodo(_,_)|RESTO],SOL,Visitati):-
	ric_amp_grafi(RESTO,SOL,Visitati).


espandi(nodo(S,LISTA_AZ),LISTA_SUCC):-
	findall(AZ,applicabile(AZ,S),AZIONI),
	successori(nodo(S,LISTA_AZ),AZIONI,LISTA_SUCC).
	
successori(_,[],[]).
successori(nodo(S,LISTA_AZ),[AZ|RESTO],[nodo(NUOVO_S,NUOVA_LISTA_AZ)|ALTRI]):-
	trasforma(AZ,S,NUOVO_S),
	append(LISTA_AZ,[AZ],NUOVA_LISTA_AZ),
	successori(nodo(S,LISTA_AZ),RESTO,ALTRI).
	

ampiezza:- 
	statistics(walltime, [Start,_]),
	iniziale(S),
	ric_amp_grafi([nodo(S,[])],SOL,[]),
     statistics(walltime, [End,_]),
     Time is End - Start,
	write(Time),nl,
	write(SOL).

