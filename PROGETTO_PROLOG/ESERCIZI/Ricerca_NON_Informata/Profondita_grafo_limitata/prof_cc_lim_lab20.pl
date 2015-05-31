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
% Esempio 20 x 20

num_col(20).
num_righe(20).

wall(pos(7,15)).
wall(pos(8,15)).
wall(pos(9,15)).
wall(pos(10,15)).
wall(pos(11,15)).
wall(pos(12,15)).
wall(pos(13,15)).
wall(pos(13,6)).
wall(pos(13,7)).
wall(pos(13,8)).
wall(pos(13,9)).
wall(pos(13,10)).
wall(pos(13,11)).
wall(pos(13,12)).
wall(pos(13,13)).
wall(pos(13,14)).
wall(pos(15,1)).
wall(pos(15,2)).
wall(pos(15,3)).
wall(pos(15,4)).
wall(pos(15,5)).
wall(pos(15,6)).
wall(pos(15,7)).
wall(pos(15,8)).
wall(pos(15,9)).


initial(pos(10,10)).

final(pos(20,20)).

% Strategia in profondita` su grafo, ossia con controllo per evitare cicli su stati gia' esplorati


%definizione passo base della ricorsione
deep_graph_search(S,_,[]) :- final(S), !.

%definizione passo ricorsivo
deep_graph_search(S, Explored, [Action|Tail]) :-
apply(Action, S),
transform(Action, S, S_Updated),
\+  member(S_Updated, Explored),
deep_graph_search(S_Updated, [S|Explored], Tail).
% Aggiorno la lista degli esplorati con gli stati che avevo in S
% lo stato appena generato, se non e' finale sara' aggiunto alla
% ricorsione successiva, xke salvato in S_Updated.

find_solution :-
initial(S),
statistics(walltime,[Start,_]),
deep_graph_search(S, [], List),		% [] = lista degli stati esplorati, inizialmente vuota.
statistics(walltime,[End,_]),
Time is End - Start,
write(List),
write(Time).