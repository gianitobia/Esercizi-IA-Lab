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


% Strategia in profondita` su grafo con limite, ossia con controllo per evitare cicli su stati gia' esplorati


%definizione passo base della ricorsione
deep_graph_lim_search(S,_,_,[]) :- final(S), !.

%definizione passo ricorsivo
deep_graph_lim_search(S, Limit,Explored, [Action|Tail]) :-
	New_Limit is Limit - 1,
	New_Limit > 0, 
	apply(Action, S),
	transform(Action, S, S_Updated),
	\+  member(S_Updated, Explored),
	deep_graph_lim_search(S_Updated, New_Limit,[S|Explored], Tail).
	% Aggiorno la lista degli esplorati con gli stati che avevo in S
	% lo stato appena generato, se non e' finale sara' aggiunto alla 
	% ricorsione successiva, xke salvato in S_Updated.

find_solution :-
	initial(S),
	Limit is 21,			%imposto il limite della profondita'
	statistics(walltime,[Start,_]),
	deep_graph_lim_search(S, Limit,[], List),		% [] = lista degli stati esplorati, inizialmente vuota.
	statistics(walltime,[End,_]),
	Time is End - Start,
	write(List),
	write(Time).