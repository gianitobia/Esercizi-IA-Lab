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



(defrule forward-west-ok 

	(declare (salience 20))    

?f2<-	(status (step ?i) (time ?t)) 

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



(defrule forward-west-bump 

	(declare (salience 20))    

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Forward))

?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))

	(cell (pos-r ?r) (pos-c =(- ?c 1)) (contains ~Empty&~Parking))

?f3<-   (penalty ?p)

=> 

	(modify  ?f1  (step (+ ?i 1)) (time (+ ?t 2)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))

	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction west) (bump yes)))

	(retract ?f3)

	(assert (penalty (+ ?p 10000000)))

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - penalit‡ +10000000 (forward-west-bump): " (+ ?p 10000000) crlf)

)



(defrule forward-east-ok 

	(declare (salience 20))    

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Forward))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))

	(cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking))

=> 

	(modify  ?f1 (pos-c (+ ?c 1)) (step (+ ?i 1)) (time (+ ?t 2)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))	

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: Forward" crlf)	

;	(printout t " - in direzione: east" crlf)

;	(printout t " - nuova posizione dell'agente: (" ?r "," (+ ?c 1) ")" crlf)

) 



(defrule forward-east-bump 

	(declare (salience 20))    

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Forward))

?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))

	(cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains ~Empty&~Parking))

?f3<-   (penalty ?p)

=> 

	(modify  ?f1  (step (+ ?i 1)) (time (+ ?t 2)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))

	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction east) (bump yes)))

	(retract ?f3)

	(assert (penalty (+ ?p 10000000)))

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - penalit‡ +10000000 (forward-east-bump): " (+ ?p 10000000) crlf)

)



(defrule turnleft1

	(declare (salience 20))      

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Turnleft))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))

	(cell (pos-r ?r) (pos-c ?c))

=>	

	(modify  ?f1 (direction south) (step (+ ?i 1)) (time (+ ?t 1)) )

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)) )		

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: turnleft" crlf)	

;	(printout t " - nuova direzione dell'agente: south" crlf)

)



(defrule turnleft2

	(declare (salience 20))      

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Turnleft))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))

	(cell (pos-r ?r) (pos-c ?c))

=> 

	(modify  ?f1 (direction east) (step (+ ?i 1)) (time (+ ?t 1)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)

;     	(printout t " - azione eseguita: turnleft" crlf)	

;     	(printout t " - nuova direzione dell'agente: east" crlf)

)



(defrule turnleft3

	(declare (salience 20))      

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Turnleft))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))

	(cell (pos-r ?r) (pos-c ?c))

=> 

	(modify  ?f1 (direction north) (step (+ ?i 1)) (time (+ ?t 1)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: turnleft" crlf)	

;	(printout t " - nuova direzione dell'agente: north" crlf)

)



(defrule turnleft4

	(declare (salience 20))      

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Turnleft))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))

	(cell (pos-r ?r) (pos-c ?c))

=> 

	(modify  ?f1 (direction west) (step (+ ?i 1)) (time (+ ?t 1)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: turnleft" crlf)	

;	(printout t " - nuova direzione dell'agente: west" crlf)

)



(defrule turnright1

	(declare (salience 20))      

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Turnright))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))

	(cell (pos-r ?r) (pos-c ?c))

=> 

	(modify  ?f1 (direction north) (step (+ ?i 1))  (time (+ ?t 1)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: turnright" crlf)	

;	(printout t " - nuova direzione dell'agente: north" crlf)

)



(defrule turnright2

	(declare (salience 20))      

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Turnright))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))

	(cell (pos-r ?r) (pos-c ?c))

=> 

	(modify  ?f1 (direction west) (step (+ ?i 1)) (time (+ ?t 1)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: turnright" crlf)	

;	(printout t " - nuova direzione dell'agente: west" crlf)

)



(defrule turnright3

	(declare (salience 20))      

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Turnright))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c) (direction east))

	(cell (pos-r ?r) (pos-c ?c))

=> 

	(modify ?f1 (direction south) (step (+ ?i 1)) (time (+ ?t 1)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: turnright" crlf)	

;	(printout t " - nuova direzione dell'agente: south" crlf)

)



(defrule turnright4

	(declare (salience 20))      

?f2<-	(status (step ?i) (time ?t)) 

	(exec (step ?i) (action  Turnright))

?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))

	(cell (pos-r ?r) (pos-c ?c))

=> 

	(modify ?f1 (direction east) (step (+ ?i 1)) (time (+ ?t 1)))

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		

;	(printout t " ENVIRONMENT:" crlf)

;	(printout t " - azione eseguita: turnright" crlf)	

;	(printout t " - nuova direzione dell'agente: east" crlf)

)