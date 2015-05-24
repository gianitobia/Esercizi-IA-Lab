/* 
	nomi:
		- costanti/identificatori: lettera iniziale minuscola;
		- variabili: lettera iniziale maiuscola;
	
	In prolog non c'e' memoria di stato per le variabile,
	le variabili sono variabili logiche.
	
	Una volta che un valore e' associato ad una variabile
	quel valore rimane tale per tutta la computazione;

	Non si usano cicli ma si usa la ricorsione.
 */
femmina(luisa).
femmina(carla).
femmina(maria).
femmina(anna).

madre(luisa, carla).
madre(carla, maria).
madre(carla, giovanni).
madre(maria, giorgio).

padre(nicola, luigi).
padre(luigi, maria).
padre(luigi, anna).
padre(luigi, giovanni).
padre(antonio, carla).


/*
	Per visualizzare eventuali piu' di un risultato clicchiamo su ';'
	Utilizziamo la virgola tra le condizioni per considerare l'AND tra esse.

madre(carla, X), padre(luigi, X).
*/

/*
	Definizione delle regole in prolog
*/
genitore(X,Y) :- padre(X,Y).
genitore(X,Y) :- madre(X,Y).

/*
	Uso il dif per assicurarmi che x e y siano diversi, 
	altrimenti otterrei che tutte le femmine sono sorelle di se stesse
*/
sorella(X,Y) :- femmina(X), genitore(Z,X), genitore(Z, Y), dif(X,Y).

/*
	Predicato antenato:
	- bisogna capire come gestire l'iterazione, xke biosgna gestire sull'albero
	delle parentele un cammino di lunghezza arbitraria sullo stesso ramo.

	- Non e' presente la definizione di ciclo e bisogna usare la ricorsione.
	- Definiamo quindi il passo di stop della ricorsione (in modo che prima o poi termini)
	- Definiamo successivamente il passo ricorsivo in generale
*/
antenato(X,Y) :- genitore(X,Y).						/* Passo Base */
antenato(X,Y) :- genitore(X,Y), antenato(X,Y).		/* Passo Ricorsivo */