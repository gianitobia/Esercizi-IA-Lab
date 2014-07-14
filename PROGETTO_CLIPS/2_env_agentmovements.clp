;//  REGOLE PER MOVIMENTO

;// REGOLE MOVIMENTO A* di Base

;##########	OPERAZIONE VERSO SU'
;regola che controlla se e' fattibile fare una operazione di movimento vero su
(defrule up-apply	(declare (salience 50))
    (current ?curr)
    (node (ident ?curr) (pos-r ?r) (pos-c ?c) (open yes))
    (cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains empty|gate))
 	=> 
	(assert (apply ?curr up ?r ?c))
)

;Se applicabile effettuo un movimento verso su
(defrule up-exec	(declare (salience 50))
    (current ?curr)
    (lastnode ?n)
   	?f1 <- (apply ?curr up ?r ?c)
    (node (ident ?curr) (gcost ?g))
    (goal ?x ?y)
 	=>
	(assert (exec ?curr (+ ?n 1) up ?r ?c)
	(newnode (ident (+ ?n 1)) (pos-r (+ ?r 1)) (pos-c ?c) (gcost (+ ?g 1)) (fcost (+ (abs (- ?x (+ ?r 1))) (abs (- ?y ?c)) ?g 1))
	(father ?curr)))
  	(retract ?f1)
  	(focus NEW)
)

;##########	OPERAZIONE VERSO GIU'
(defrule down-apply		(declare (salience 50))
    (current ?curr)
    (node (ident ?curr) (pos-r ?r) (pos-c ?c) (open yes))
    (cell (pos-r =(- ?r 1)) (pos-c ?c) (contains empty|gate))
 	=>
	(assert (apply ?curr down ?r ?c))
)

(defrule down-exec		(declare (salience 50))
    (current ?curr)
    (lastnode ?n)
   	?f1 <- (apply ?curr down ?r ?c)
    (node (ident ?curr) (gcost ?g))
    (goal ?x ?y)
 	=>
	(assert (exec ?curr (+ ?n 2) down ?r ?c)
	(newnode (ident (+ ?n 2)) (pos-r (- ?r 1)) (pos-c ?c) (gcost (+ ?g 1)) (fcost (+ (abs (- ?x (- ?r 1))) (abs (- ?y ?c)) ?g 1))
    (father ?curr)))
	(retract ?f1)
  	(focus NEW)
)

;##########	OPERAZIONE VERSO DESTRA
(defrule right-apply	(declare (salience 50))
    (current ?curr)
    (node (ident ?curr) (pos-r ?r) (pos-c ?c) (open yes))
    (cell (pos-c =(+ ?c 1)) (pos-r ?r) (contains empty|gate))
 	=> 
	(assert (apply ?curr right ?r ?c))
)
(defrule right-exec		(declare (salience 50))
    (current ?curr)
    (lastnode ?n)
   	?f1 <- (apply ?curr right ?r ?c)
    (node (ident ?curr) (gcost ?g))
    (goal ?x ?y)
 	=>
	(assert (exec ?curr (+ ?n 3) right ?r ?c)
    (newnode (ident (+ ?n 3)) (pos-c (+ ?c 1)) (pos-r ?r) (gcost (+ ?g 1)) (fcost (+ (abs (- ?y (+ ?c 1))) (abs (- ?x ?r)) ?g 1))
    (father ?curr)))
    (retract ?f1)
    (focus NEW)
)

;##########	OPERAZIONE VERSO SINISTRA
(defrule left-apply		(declare (salience 50))
    (current ?curr)
    (node (ident ?curr) (pos-r ?r) (pos-c ?c) (open yes))
    (cell (pos-c =(- ?c 1)) (pos-r ?r) (contains empty|gate))
 	=>
	(assert (apply ?curr left ?r ?c))
)

(defrule left-exec		(declare (salience 50))
    (current ?curr)
    (lastnode ?n)
   	?f1 <- (apply ?curr left ?r ?c)
    (node (ident ?curr) (gcost ?g))
    (goal ?x ?y)
 	=>
	(assert (exec ?curr (+ ?n 4) left ?r ?c)
	(newnode (ident (+ ?n 4)) (pos-c (- ?c 1)) (pos-r ?r) (gcost (+ ?g 1)) (fcost (+ (abs (- ?y (- ?c 1))) (abs (- ?x ?r)) ?g 1))
    (father ?curr)))
  	(retract ?f1)
  	(focus NEW)
)


;##########################################################################################
;Regola per selezionare il nodo piu' promettente in termini di costo (g+h) anche da livelli precedendi del grafo
(defrule change-current		(declare (salience 49))
	?f1 <- (current ?curr)
	?f2 <- (node (ident ?curr))
	(node (ident ?best&:(neq ?best ?curr)) (fcost ?bestcost) (open yes))
	(not (node (ident ?id&:(neq ?id ?curr)) (fcost ?gg&:(< ?gg ?bestcost)) (open yes)))
	?f3 <- (lastnode ?last)
	=>
	(assert (current ?best) (lastnode (+ ?last 5)))	;Branching factor + 1 perche' inpila gli stati :D
	(retract ?f1 ?f3)
	(modify ?f2 (open no))
) 

;controlla che la lista di open non sia vuota -altrimenti segnala l'errore
(defrule close-empty	(declare (salience 49))
	?f1 <- (current ?curr)
	?f2 <- (node (ident ?curr))
	(not (node (ident ?id&:(neq ?id ?curr))  (open yes)))
	;se sono arrivata a questo livello e non posso fare operazioni in nessuno degli altri nodi
	;generati agli altri livelli (xke in tutti in closed), inserisco il nodo in CLOSED e stampo Errore;
	=> 
	(retract ?f1)
	(modify ?f2 (open no))
	(printout t " fail (last  node expanded " ?curr ")" crlf)
	(halt)
)  




































;//  REGOLE PER MOVIMENTO





(defrule forward-north-ok 

	(declare (salience 20))    

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Forward))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))

	(cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking))

=> 

	(modify ?f1 (pos-r (+ ?r 1)) (step (+ ?i 1)) (time (+ ?t 2)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))		

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: Forward" crlf)	

;	(printout t " - in direzione: north" crlf)

;	(printout t " - nuova posizione dell'agente: (" (+ ?r 1) "," ?c ")" crlf)	

) 

 

(defrule forward-north-bump 

	(declare (salience 20))    

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Forward))

?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))

	(cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains ~Empty&~Parking))

?f3<-   (penalty ?p)

=> 

	(modify ?f1  (step (+ ?i 1)) (time (+ ?t 2)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))

	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction north) (bump yes)))

	(retract ?f3)

	(assert (penalty (+ ?p 10000000)))

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - penalit‡ +10000000 (Forward-north-bump): " (+ ?p 10000000) crlf)

)

 

(defrule forward-south-ok 

	(declare (salience 20))    

?f2<-	(status (step ?i) (time ?t))  

	(exec (step ?i) (action  Forward))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))

	(cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking))

=> 

	(modify ?f1 (pos-r (- ?r 1)) (step (+ ?i 1)) (time (+ ?t 2)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))	

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: Forward" crlf)	

;	(printout t " - in direzione: south" crlf)

;	(printout t " - nuova posizione dell'agente: (" (- ?r 1) "," ?c ")" crlf)

)

  

(defrule forward-south-bump 

	(declare (salience 20))    

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Forward))

?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))

	(cell (pos-r =(- ?r 1)) (pos-c ?c) (contains ~Empty&~Parking))

?f3<-   (penalty ?p)

=> 

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 2)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))

	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction south) (bump yes)))

	(retract ?f3)

	(assert (penalty (+ ?p 10000000)))

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - penalit‡ +10000000 (forward-south-bump): " (+ ?p 10000000) crlf)

) 


;controlla che sia possibile effettuare un forward a sinistra
(defrule forward-west-ok 	(declare (salience 20))    
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Forward))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))

	(cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking))

=> 

	(modify ?f1 (pos-c (- ?c 1)) (step (+ ?i 1)) (time (+ ?t 2)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))	

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: Forward" crlf)	

;	(printout t " - in direzione: west" crlf)

;	(printout t " - nuova posizione dell'agente: (" ?r "," (- ?c 1) ")" crlf)	

)


;come forword-north-bump
(defrule forward-west-bump 	(declare (salience 20))    
	?f2 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action  Forward)
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
	(cell (pos-r ?r) (pos-c =(- ?c 1)) (contains ~Empty&~Parking))
	?f3 <- (penalty ?p)
	=>
	(modify  ?f1  (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction west) (bump yes)))
	(retract ?f3)
	(assert (penalty (+ ?p 10000000)))
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - penalit‡ +10000000 (forward-west-bump): " (+ ?p 10000000) crlf)
)


;controlla che sia possibile effettuare un forward a destra
(defrule forward-east-ok 	(declare (salience 20))    
 	?f2 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action  Forward))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))
	(cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	=> 
	(modify  ?f1 (pos-c (+ ?c 1)) (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))	
	
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: Forward" crlf)	
;	(printout t " - in direzione: east" crlf)
;	(printout t " - nuova posizione dell'agente: (" ?r "," (+ ?c 1) ")" crlf)
) 


;come forword-north-bump
(defrule forward-east-bump 	(declare (salience 20))    
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Forward))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))
	(cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains ~Empty&~Parking))
	?f3 <- (penalty ?p)
	=> 
	(modify  ?f1  (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction east) (bump yes)))
	(retract ?f3)
	(assert (penalty (+ ?p 10000000)))

;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - penalit‡ +10000000 (forward-east-bump): " (+ ?p 10000000) crlf)
)


;;;;;;Definzioni delle possibili rotazioni da una direzione all'altra
(defrule turnleft1 	(declare (salience 20))      
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnleft))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
	(cell (pos-r ?r) (pos-c ?c))
	=>
	(modify  ?f1 (direction south) (step (+ ?i 1)) (time (+ ?t 1)) )
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnleft" crlf)	
;	(printout t " - nuova direzione dell'agente: south" crlf)
)


(defrule turnleft2	(declare (salience 20))      
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnleft))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
	(cell (pos-r ?r) (pos-c ?c))
	=>
	(modify  ?f1 (direction east) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		
	
;	(printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: turnleft" crlf)	
;   (printout t " - nuova direzione dell'agente: east" crlf)
)


(defrule turnleft3	(declare (salience 20))      
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnleft))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))
	(cell (pos-r ?r) (pos-c ?c))
	=> 
	(modify  ?f1 (direction north) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnleft" crlf)	
;	(printout t " - nuova direzione dell'agente: north" crlf)
)


(defrule turnleft4 	(declare (salience 20))      
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnleft))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
	(cell (pos-r ?r) (pos-c ?c))
	=> 
	(modify  ?f1 (direction west) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnleft" crlf)	
;	(printout t " - nuova direzione dell'agente: west" crlf)
)


(defrule turnright1	 (declare (salience 20))      
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnright))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
	(cell (pos-r ?r) (pos-c ?c))
	=> 
	(modify  ?f1 (direction north) (step (+ ?i 1))  (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnright" crlf)	
;	(printout t " - nuova direzione dell'agente: north" crlf)
)


(defrule turnright2	 (declare (salience 20))      
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnright))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
	(cell (pos-r ?r) (pos-c ?c))
	=> 
	(modify  ?f1 (direction west) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnright" crlf)	
;	(printout t " - nuova direzione dell'agente: west" crlf)
)


(defrule turnright3	 (declare (salience 20))      
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnright))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c) (direction east))
	(cell (pos-r ?r) (pos-c ?c))
	=> 
	(modify ?f1 (direction south) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnright" crlf)	
;	(printout t " - nuova direzione dell'agente: south" crlf)
)


(defrule turnright4  (declare (salience 20))      
	?f2 <- (status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnright))
	?f1 <- (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
	(cell (pos-r ?r) (pos-c ?c))
	=> 
	(modify ?f1 (direction east) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnright" crlf)	
;	(printout t " - nuova direzione dell'agente: east" crlf)
)