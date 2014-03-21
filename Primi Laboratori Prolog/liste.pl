/*
	In prolog posso rappresentare le liste come un albero sbilanciato da un lato
	ogni ramo dell'albero contiene il valore ed il link al ramo successivo
	
	NOTAZIONE INTERNA
	In prolog le liste si indicano con il .    ---   .(X,y) -> x qualsiasi cosa, y deve essere una lista
	es => 	.(a, .(b,.(c, [])))
	[] = lista_vuoto (fine lista)
	
	NELLA SINTASSI LA POSSO SCRIVERE come [a, b, c] == .(a, .(b,.(c, [])))
	Nel programma possiam scrivere [a | y] con:
		-	a, elemento della lista
		-	y, la restante parte della lista
	Lista con almeno un elemento
*/

p([1,2,3,4,5,6,7,8,9]).

/*
	- p([X|Y]).
		X = 1,
		Y = [2, 3, 4, 5, 6, 7, 8, 9].
	Restituisce la lista con i X il primo elemento ed in Y tutti i rimanenti
	Le lista sono da considerarsi come degli insiemi matematici
	(X e' un insieme che contiene 1)

	- p([X,Y|Z]).
		X = 1,
		Y = 2,
		Z = [3, 4, 5, 6, 7, 8, 9].
	Lista in cui il X contiene due elementi
	Y la restante parte

	- p([_|Y]).	->	_  prolog ci permette di utilizzarlo al posto di una variabile che utlizzeremmo una volta sola

	member(X,L) -> predicato che ci permette de controllare se un elemento fa parte della lista
	X -> elmento da cercare
	L -> Lista in cui cercare
*/
member(X, [ X | _ ]).
member(X, [ _ | L ]) :- member(X,L). 