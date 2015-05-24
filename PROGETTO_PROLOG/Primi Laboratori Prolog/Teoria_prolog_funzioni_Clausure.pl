/*
	Un programma in prolog e' un insieme (una lista) di regole in generale.
	A.							-> Formula Atomiche
	A :- B1, ... , Bn.			-> Regola
	
	FORMULA ATOMICA
		p(t1, ..., tn) -> padre(nicola, luigi) oppure genitore(X,Y).
			con ti = (termini) costanti (con la lettera minuscola) oppure numeri ---> ATOMI.
			con ti = (termini) variabili (con lettera maiuscola).
			con ti = funzione f(t1,...,tn) nei nuovi termini tn. 
				es. funzione +(2,3), ma il + e' solo un simbolo non ha alcuna semantica associata

		p = simbolo di predicato che deve iniziare sempre con la lettera minuscola.
	
	REGOLA = successione in AND (,) di formule atomiche
	
	Consideriamo un esempio di rappresentazione dei numeri naturale.
	In logica non abbiamo tutti i numeri naturali definiti.
	Quindi consideriamo:
		-	0 come forma base;
		-	s(X) successore del numero X;
	
	Formalizzazione della somma:
		X = primo numero
		Y = secondo numero
	`	Z = risultato dell'operazione
		s(X) = successore di un numero X
*/

sum(0,X,X).
sum(s(X),Y,s(Z)):- sum(X,Y,Z).

/*
	A  || NOT B1 || NOT B2 ... || NOT Bn
	A  || NOT(B1 || B2 ... || Bn)
	A  <- (B1 & B2 & ... & Bn)
	
	Clausure definite:		CLAUDURE DI HORN
	A <- B  ==  A || not(B)

	Programmazione logica tratta solo una sotto parte della logica
	quella rappresentabile con CLAUSURE DI HORN.
*/