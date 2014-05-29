;// _______________________________________________________________________________________________________________________
;// ENV                                                                                                                   
;// �����������������������������������������������������������������������������������������������������������������������

(defmodule ENV (import MAIN ?ALL))

;// DEFTEMPLATE
(deftemplate cell  
	(slot pos-r)
	(slot pos-c) 
    (slot contains (allowed-values Wall Person  Empty Parking Table Seat TrashBasket RecyclableBasket DrinkDispenser FoodDispenser))
)

(deftemplate agentstatus 
	(slot step)
    (slot time)
	(slot pos-r) 
	(slot pos-c) 
	(slot direction) 
	(slot l-drink)
    (slot l-food)
    (slot l_d_waste)
    (slot l_f_waste)
)

(deftemplate tablestatus	
	(slot step)
    (slot time)
	(slot table-id)
	(slot clean (allowed-values yes no))
	(slot l-drink)
    (slot l-food)
)

(deftemplate orderstatus	;// tiente traccia delle ordinazioni
	(slot step)
    (slot time)				;// tempo corrente
	(slot arrivaltime)		;// momento in cui � arrivata l'ordinazione
	(slot requested-by)		;// tavolo richiedente
	(slot drink-order)
    (slot food-order)
    (slot drink-deliv)
    (slot food-deliv)
    (slot answer (allowed-values pending accepted delayed rejected))	
)

(deftemplate cleanstatus
	(slot step)
    (slot time)
	(slot arrivaltime)
	(slot requested-by)	;// tavolo richiedente	
)

(deftemplate personstatus 	;// informazioni sulla posizione delle persone
	(slot step)
    (slot time)
	(slot ident)
	(slot pos-r)
	(slot pos-c)
	(slot activity)   ;// activity seated se cliente seduto, stand se in piedi, oppure path  		
    (slot move)			
)

(deftemplate personmove		
	;// modella i movimenti delle persone. l'environment deve tenere conto dell'interazione di tanti agenti. 
	;//Il mondo cambia sia per le azioni del robot, si per le azioni degli operatori. Il modulo environment deve gestire le interazioni. 
	(slot step)
	(slot ident)
	(slot path-id)
)

(deftemplate event   		;// gli eventi sono le richieste dei tavoli: ordini e finish
	(slot step)
	(slot type (allowed-values request finish))
	(slot source)
	(slot food)
    (slot drink)
)

(deftemplate rotation
	(slot r_dir)
	(slot m_dir)
	(slot rotazione)
	(slot dir_f)
)

(deffacts rotations
	;rotazione da un stato del robot UP;
	(rotation (r_dir up) (m_dir left) (rotazione left) (dir_f left))
	(rotation (r_dir up) (m_dir right) (rotazione right) (dir_f right))
	(rotation (r_dir up) (m_dir down) (rotazione left) (dir_f left))
	;rotazione da uno stato del robot RIGHT;
	(rotation (r_dir right) (m_dir up) (rotazione left) (dir_f up))
	(rotation (r_dir right) (m_dir down) (rotazione right) (dir_f down))
	(rotation (r_dir right) (m_dir left) (rotazione left) (dir_f up))
	;rotazione da uno stato del robot DOWN;
	(rotation (r_dir down) (m_dir right) (rotazione left) (dir_f right))
	(rotation (r_dir down) (m_dir left) (rotazione right) (dir_f left))
	(rotation (r_dir down) (m_dir up) (rotazione right) (dir_f left))
	;rotazione da uno stato del robot LEFT;
	(rotation (r_dir left) (m_dir up) (rotazione right) (dir_f up))
	(rotation (r_dir left) (m_dir down) (rotazione left) (dir_f down))
	(rotation (r_dir left) (m_dir right) (rotazione right) (dir_f up))
)

;// DEFRULE



;// __________________________________________________________________________________________

;// REGOLE PER GESTIONE EVENTI    

;// ������������������������������������������������������������������������������������������

;//



(defrule neworder1 (declare (salience 200))
	(status (step ?i) (time ?t))
	?f1 <- (event (step ?i) (type request) (source ?tb) (food ?nf) (drink ?nd))
	(tablestatus (step ?i) (table-id ?tb) (clean yes)) 
	=> 
	(assert 
		(orderstatus (step ?i) (time ?t) (arrivaltime ?t) (requested-by ?tb) 
                             (drink-order ?nd) (food-order ?nf)
                             (drink-deliv 0) (food-deliv 0)
                             (answer pending))
		(msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order)
                              (drink-order ?nd) (food-order ?nf))
	)
	(retract ?f1)		
	(printout t crlf " ENVIRONMENT:" crlf)
	(printout t " - " ?tb " orders " ?nf " food e " ?nd " drinks" crlf)
)

(defrule neworder2 (declare (salience 200))
	(status (step ?i) (time ?t))
	?f1<-	(event (step ?i) (type request) (source ?tb) (food ?nf) (drink ?nd))
	(tablestatus (step ?i) (table-id ?tb) (clean no))
	(event (step ?ii&:(< ?ii ?i)) (type finish) (source ?tb))
	=> 
	(assert 
		(orderstatus (step ?i) (time ?t) (arrivaltime ?t) (requested-by ?tb) 
                             (drink-order ?nd) (food-order ?nf)
                             (drink-deliv 0) (food-deliv 0)
                             (answer pending))
		(msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order)
                              (drink-order ?nd) (food-order ?nf))
	)
	(retract ?f1)		
	(printout t crlf " ENVIRONMENT:" crlf)
	(printout t " - " ?tb " orders " ?nf " food e " ?nd " drinks" crlf)
) 

(defrule newfinish (declare (salience 200))
	(status (step ?i) (time ?t))
	?f1 <- (event (step ?i) (type finish) (source ?tb))
	(tablestatus (step ?i) (table-id ?tb) (clean no))
	=> 
	(assert 	
		(cleanstatus (step ?i) (time ?t) (arrivaltime ?t) (requested-by ?tb))
                (msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type finish))
	)
	(retract ?f1)
	(printout t crlf " ENVIRONMENT:" crlf)
	(printout t " - " ?tb " declares finish " crlf)
)

;// __________________________________________________________________________________________

;// GENERA EVOLUZIONE TEMPORALE       

;// ������������������������������������������������������������������������������������������  



;// per ogni istante di tempo che intercorre fra l'informazione di finish di un tavolo  e 
;//  pulitura (clean) del tavolol),  l'agente prende 3 penalit�




(defrule CleanEvolution1 (declare (salience 10))
	(status (time ?t) (step ?i))
	?f1 <- (cleanstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb))
	(not (cleanstatus (step ?i)  (arrivaltime ?at) (requested-by ?tb))) 
	?f2 <- (penalty ?p)
	=> 
	(modify ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) 3))))
	(retract ?f2)	
)

;// per ogni istante di tempo che intercorre fra la request e la inform, l'agente prende 50 penalit�

(defrule RequestEvolution1 (declare (salience 10))
	(status (time ?t) (step ?i))
	?f1 <- (orderstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb) (answer pending))
	(not (orderstatus (step ?i) (arrivaltime ?at) (requested-by ?tb) (answer ~pending)))
	?f2<- (penalty ?p)
	=> 
	(modify ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) 50))))
	(retract ?f2)
)

;// penalit� perch� l'ordine � stato accepted e non � ancora stato completato

(defrule RequestEvolution2 (declare (salience 10))
    (status (time ?t) (step ?i))
	?f1 <- (orderstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb)
           (answer accepted)
           (drink-order ?nd) (food-order ?nf) (drink-deliv ?dd) (food-deliv ?df))
    (not (orderstatus (step ?i) (arrivaltime ?at) (requested-by ?tb)))
	?f2 <- (penalty ?p)
	=> 
    (modify ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) (max 1 (* (+ (- ?nd ?dd) (- ?nf ?df)) 2))))))
	(retract ?f2)
)

;// penalit� perch� l'ordine � stato delayed e non � ancora stato completato 

(defrule RequestEvolution3 (declare (salience 10))
    (status (time ?t) (step ?i))
	?f1 <- (orderstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb)
           (answer delayed)
           (drink-order ?nd) (food-order ?nf) (drink-deliv ?dd) (food-deliv ?df))
    (not (orderstatus (step ?i) (arrivaltime ?at) (requested-by ?tb)))
	?f2 <- (penalty ?p)
	=> 
    (modify ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) (max 1 (+ (- ?nd ?dd) (- ?nf ?df)))))))
	(retract ?f2)
)

;// 

(defrule RequestEvolution4 (declare (salience 10))
	(status (time ?t) (step ?i))
	?f1 <- (tablestatus (step = (- ?i 1)) (time ?tt) (table-id ?tb))
    (not (tablestatus (step ?i)  (table-id ?tb)))
	=> 
    (modify ?f1 (time ?t) (step ?i))
)

;// __________________________________________________________________________________________

;// GENERA MOVIMENTI PERSONE                    

;// ������������������������������������������������������������������������������������������

;// Persona ferma non arriva comando di muoversi

(defrule MovePerson1 (declare (salience 10))    
	(status (step ?i) (time ?t)) 
	?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (activity seated|stand))
	(not (personmove (step ?i) (ident ?id)))
	=> 
	(modify ?f1 (time ?t) (step ?i))
)         

         

;//;//Persona ferma ma arriva comando di muoversi         

(defrule MovePerson2 (declare (salience 10))    
    (status (step ?i) (time ?t))  
	?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (activity seated|stand))
	?f2 <- (personmove (step  ?i) (ident ?id) (path-id ?m))
    => (modify  ?f1 (time ?t) (step ?i) (activity ?m) (move 0))
    (retract ?f2)
)           

;// La cella in cui deve  andare la persona � libera. Persona si muove. 

;// La cella di partenza � un seat in cui si trovava l'operatore

(defrule MovePerson3 (declare (salience 10))    
    (status (step ?i) (time ?t))   
	?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) (activity ?m&~seated&~stand) (move ?s))
    (cell (pos-r ?x) (pos-c ?y) (contains Seat))
	?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
    (not (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)))
	?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Empty))
    => 
	(modify  ?f1  (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (move (+ ?s 1)))
    (modify ?f2 (contains Person))
    (retract ?f3)		
)

;// La cella in cui deve  andare la persona � libera. Persona si muove. 

;// La cella di partenza NON un seat , per cui dopo lo spostamento 

;// dell'operatore diventa libera

(defrule MovePerson4 (declare (salience 10))    
	(status (step ?i) (time ?t)) 
	?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) (activity ?m&~seated|~stand) (move ?s))
	?f4 <- (cell (pos-r ?x) (pos-c ?y) (contains Person))
 	?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
    (not (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)))
	?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Empty))
    =>
	(modify  ?f1  (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (move (+ ?s 1)))
    (modify ?f2 (contains Person))
    (modify ?f4 (contains Empty))
    (retract ?f3)
)

;// La cella in cui deve andare il cliente � un seat e il seat non � occupata da altra persona.
;// La cella di partenza diventa libera, e l'attivita del cliente diventa seated

(defrule MovePerson5 (declare (salience 10))    
	(status (step ?i) (time ?t)) 
	?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) (activity ?m&~seated&~stand) (move ?s))
	?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
    (not (agentstatus (time ?i) (pos-r ?r) (pos-c ?c)))
	?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Seat))
    (not (personstatus (step ?i) (ident ?id) (pos-r ?r) (pos-c ?c) (activity seated)))
	?f4 <- (cell (pos-r ?x) (pos-c ?y) (contains Person))
	=> 
	(modify  ?f1  (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (activity seated) (move NA))
    (modify ?f4 (contains Empty))
    (retract ?f3)
)


;// La cella in cui deve  andare la persona � occupata dal robot. Persona non si muove           

(defrule MovePerson_wait1 (declare (salience 10))    
	(status (step ?i) (time ?t))
	?f1 <- (personstatus (step =(- ?i 1)) (time ?tt) (ident ?id) (activity ?m&~work&~stand) (move ?s))
	(move-path ?m =(+ ?s 1) ?id ?r ?c)
	(agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c))
	?f2 <- (penalty ?p)
	=> 
	(modify  ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) 20))))
	(retract ?f2)
;	(printout t " - penalit� aumentate" ?id " attende che il robot si sposti)" crlf)
)

;// La cella in cui deve  andare la persona non � libera (ma non � occupata da robot). Persona non si muove           

(defrule MovePerson_wait2 (declare (salience 10))    
	(status (step ?i) (time ?t))
	?f1<-	(personstatus (step =(- ?i 1)) (time ?tt) (ident ?id) (activity ?m&~work&~stand) (move ?s))
	(move-path ?m =(+ ?s 1) ?id ?r ?c) (cell (pos-r ?r) (pos-c ?c) (contains ~Empty))
	(not (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c)))
	=>
	(modify  ?f1 (time ?t) (step ?i))
)

;// La cella in cui deve andare il cliente � un seat ma il seat � occupata da altra persona.
;// il cliente resta fermo

(defrule MovePerson_wait3 (declare (salience 10))    
	(status (step ?i) (time ?t)) 
	?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) (activity ?m&~seated&~stand) (move ?s))
	?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
	(not (agentstatus (time ?i) (pos-r ?r) (pos-c ?c)))
	?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Seat)) 
	(personstatus (step ?i) (ident ?id) (pos-r ?r) (pos-c ?c) (activity seated))
    => 
	(modify  ?f1  (step ?i) (time ?t))
    (retract ?f3)
)
;//La serie di mosse � stata esaurita, la persona rimane ferma dove si trova

(defrule MovePerson_end (declare (salience 10))    
	(status (step ?i) (time ?t)) 
	?f1<-	(personstatus (step =(- ?i 1)) (time ?tt) (ident ?id) (activity ?m&~work&~stand) (move ?s))
	(not (move-path ?m =(+ ?s 1) ?id ?r ?c))
	=> 
	(modify  ?f1  (time ?t) (step ?i) (activity stand) (move NA)) 
)



;// __________________________________________________________________________________________
;// REGOLE PER PERCEZIONI VISIVE (N,S,E,O)          
;// ������������������������������������������������������������������������������������������ 

(defrule percept-north (declare (salience 5))
	?f1<-	(agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction north)) 
	(cell (pos-r =(+ ?r 1))	(pos-c =(- ?c 1)) 	(contains ?x1))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c)  		(contains ?x2))
	(cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) 	(contains ?x3))
	(cell (pos-r ?r) 		(pos-c =(- ?c 1)) 	(contains ?x4))
	(cell (pos-r ?r) 		(pos-c ?c)  		(contains ?x5))
	(cell (pos-r ?r) 		(pos-c =(+ ?c 1)) 	(contains ?x6))
	(cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) 	(contains ?x7))
	(cell (pos-r =(- ?r 1)) (pos-c ?c)  		(contains ?x8))
	(cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) 	(contains ?x9))
	=> 
	(assert 	
		(perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction north) 
			(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
			(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
			(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
		)
	)
	(focus MAIN)
)



(defrule percept-south (declare (salience 5))
	?f1<-	(agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction south)) 
	(cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) 	(contains ?x1))
	(cell (pos-r =(- ?r 1)) (pos-c ?c)  		(contains ?x2))
	(cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) 	(contains ?x3))
	(cell (pos-r ?r)  		(pos-c =(+ ?c 1)) 	(contains ?x4))
	(cell (pos-r ?r)  		(pos-c ?c)  		(contains ?x5))
	(cell (pos-r ?r)  		(pos-c =(- ?c 1)) 	(contains ?x6))
	(cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) 	(contains ?x7))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c)  		(contains ?x8))
	(cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) 	(contains ?x9))
=> 
	(assert 	
		(perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction south) 
			(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
			(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
			(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
		)
	)
	(focus MAIN)
)



(defrule percept-east (declare (salience 5))
	?f1<-	(agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction east)) 
	(cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) 	(contains ?x1))
	(cell (pos-r ?r)  		(pos-c =(+ ?c 1)) 	(contains ?x2))
	(cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) 	(contains ?x3))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c)  		(contains ?x4))
	(cell (pos-r ?r)  		(pos-c ?c)  		(contains ?x5))	
	(cell (pos-r =(- ?r 1)) (pos-c ?c)  		(contains ?x6))
	(cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1))	(contains ?x7))
	(cell (pos-r ?r)		(pos-c =(- ?c 1)) 	(contains ?x8))
	(cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) 	(contains ?x9))
	=> 	
	(assert 	
		(perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction east) 
			(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
			(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
			(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
		)
	)
	(focus MAIN)
)



(defrule percept-west (declare (salience 5))
	?f1<-	(agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction west)) 
	(cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) 	(contains ?x1))
	(cell (pos-r ?r)  		(pos-c =(- ?c 1)) 	(contains ?x2))
	(cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1))	(contains ?x3))
	(cell (pos-r =(- ?r 1)) (pos-c ?c)  	  	(contains ?x4))
	(cell (pos-r ?r)  		(pos-c ?c)  	  	(contains ?x5))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c)  	  	(contains ?x6))
	(cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) 	(contains ?x7))	
	(cell (pos-r ?r)  		(pos-c =(+ ?c 1)) 	(contains ?x8))	
	(cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) 	(contains ?x9))
	=> 
	(assert 	
		(perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction west) 
			(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
			(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
			(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
		)
	)
	(focus MAIN)
)