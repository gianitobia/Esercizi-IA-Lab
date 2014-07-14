;// AGENT

(defmodule AGENT (import MAIN ?ALL))





(deftemplate K-cell  (slot pos-r) (slot pos-c) 
                   (slot contains (allowed-values Wall Person  Empty Parking Table Seat TrashBasket
                                                      RecyclableBasket DrinkDispenser FoodDispenser)))



(deftemplate K-agent

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

(defrule  beginagent1

    (declare (salience 11))

    (status (step 0))

    (not (exec (step 0)))
    (prior-cell (pos-r ?r) (pos-c ?c) (contains ?x)) 

=>

     (assert (K-cell (pos-r ?r) (pos-c ?c) (contains ?x)))
)

            





 
(defrule  beginagent2

    (declare (salience 11))

    (status (step 0))

    (not (exec (step 0)))
    (initial_agentposition (pos-r ?r) (pos-c ?c) (direction ?d))
=> 
    (assert (K-agent (step 0) (time 0) (pos-r ?r) (pos-c ?c) (direction ?d)
                              (l-drink 0) (l-food 0) (l_d_waste no) (l_f_waste no)))
)


(defrule ask_act

 ?f <-   (status (step ?i))

    =>  (printout t crlf crlf)

        (printout t "action to be executed at step:" ?i)

        (printout t crlf crlf)

        (modify ?f (result no)))

(defrule exec_act
    (status (step ?i))
    (exec (step ?i))
 	=> (focus MAIN)
 )

;(defrule calculate_route
;	(status (step ?i))
;	(exec )
;)

;Definizione del modulo per il calcolo del percorso mediante l'utilizzo di A*
(defmodule CALC_MOVES (import AGENT ?ALL)(export ?ALL))

;definizione dei template necessarie per le strutture di A*
(deftemplate node
	(slot ident)		;livello a cui viene creato il nodo
	(slot gcost)		;csoto funzione g(x)
	(slot fcost)		;costo funzione h(x) = f(x) * g(x)
	(slot father) 		
	(slot pos-r)		; y
	(slot pos-c) 		; x
	(slot open)			; yes / no 
)

(deftemplate newnode	
	(slot ident)
	(slot gcost)
	(slot fcost)
	(slot father)
	(slot pos-r)		
    (slot pos-c)
)

(deftemplate agentstatus_As
	(slot step)
	(slot pos-r)
	(slot pos-c)
	(slot direction)
)

;inizializzazione delle variabili per pianificare con A*
(defrule init_var (declare (salience 50))
	(K-agent (step ?st) (pos-r ?r) (pos-c ?c) (direction ?d))
	(exec (step ?st) (action muovi_a) (pos-r ?r_g) (pos-c ?c_g))	;Da modificare
	=>
	(assert
		(agentstatus_As (step 0) (pos-r ?r) (pos-c ?c) (direction ?d))
		(goal ?r_g ?c_g)
        (node (ident 0) (gcost 0) (fcost 0) (father NA) (pos-r ?r) (pos-c ?c) (open yes)) 
        (current 0)
        (lastnode 0)
        (open-worse 0)
        (open-better 0)
        (alreadyclosed 0)
        (numberofnodes 0)
	)
)

;####################### REGOLE DI FINE PIANIFICAZIONE DI MOVIMENTO

;regola che si attiva al raggiungimento del goal
(defrule achieved-goal (declare (salience 100))
     (current ?id)
     (goal ?r ?c)
     (node (ident ?id) (pos-r ?r) (pos-c ?c) (gcost ?g))  
     => 
     (assert (stampa ?id))
)

;stampa la soluzione trovata
(defrule stampaSol (declare (salience 101))
	?f<-(stampa ?id)
    (node (ident ?id) (father ?anc&~NA))  
    
	;trova le azioni ad alto livello di A*
	;e segna che ci sono azioni da convertire 
	(exec_as ?anc ?id ?oper ?r ?c) 						
	=> 
	(printout t ?id " Eseguo azione " ?oper " da stato (" ?r "," ?c ") " crlf)
	(assert (azione ?anc ?id ?oper ?r ?c))
    (assert (stampa ?anc))
	(assert (print yes))
    (retract ?f)
)

;stampa le statistiche sull'esecuzione di A*
(defrule stampa-fine (declare (salience 102))
	?f1 <- (print yes)
	(stampa ?id)
	(node (ident ?id) (father ?anc&NA))
	(open-worse ?worse)
	(open-better ?better)
	(alreadyclosed ?closed)
	(numberofnodes ?n)  
	=>
	(printout t " stati espansi " ?n crlf)
	(printout t " stati generati gi� in closed " ?closed crlf)
	(printout t " stati generati gi� in open (open-worse) " ?worse crlf)
	(printout t " stati generati gi� in open (open-better) " ?better crlf)
	(printout t crlf)
	(printout t crlf)
	(retract ?f1)
)

(defrule convert-solution (declare (salience 99))
	?f <- (azione ?anc ?id ?oper ?r ?c)
	=>
	;(printout t ?id " Eseguo azione " ?oper " da stato (" ?r "," ?c ") " crlf)
	(assert (convert-action ?anc ?id ?oper ?r ?c))
	(focus CONVERT)
	(retract ?f)
)

;############# REGOLE DI MOVIMENTO ###########################################

;##########	OPERAZIONE VERSO SU

;regola che controlla se e' fattibile fare una operazione di movimento vero su
(defrule up-apply	(declare (salience 50))
    (current ?curr)
    (node (ident ?curr) (pos-r ?r) (pos-c ?c) (open yes))
    (K-cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking))
 	=> 
	(assert (apply ?curr north ?r ?c))
)

;Se applicabile effettuo un movimento verso su
(defrule up-exec	(declare (salience 50))
    (current ?curr)
    (lastnode ?n)
   	?f1 <- (apply ?curr north ?r ?c)
    (node (ident ?curr) (gcost ?g))
    (goal ?x ?y)
 	=>
	(assert (exec_as ?curr (+ ?n 1) north ?r ?c)
	(newnode (ident (+ ?n 1)) (pos-r (+ ?r 1)) (pos-c ?c) (gcost (+ ?g 1)) (fcost (+ (abs (- ?x (+ ?r 1))) (abs (- ?y ?c)) ?g 1))
	(father ?curr)))
  	(retract ?f1)
  	(focus NEW)
)

;##########	OPERAZIONE VERSO GIU'

(defrule down-apply		(declare (salience 50))
    (current ?curr)
    (node (ident ?curr) (pos-r ?r) (pos-c ?c) (open yes))
    (K-cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking))
 	=>
	(assert (apply ?curr south ?r ?c))
)

(defrule down-exec		(declare (salience 50))
    (current ?curr)
    (lastnode ?n)
   	?f1 <- (apply ?curr south ?r ?c)
    (node (ident ?curr) (gcost ?g))
    (goal ?x ?y)
 	=>
	(assert (exec_as ?curr (+ ?n 2) south ?r ?c)
	(newnode (ident (+ ?n 2)) (pos-r (- ?r 1)) (pos-c ?c) (gcost (+ ?g 1)) (fcost (+ (abs (- ?x (- ?r 1))) (abs (- ?y ?c)) ?g 1))
    (father ?curr)))
	(retract ?f1)
  	(focus NEW)
)

;##########	OPERAZIONE VERSO DESTRA

(defrule right-apply	(declare (salience 50))
    (current ?curr)
    (node (ident ?curr) (pos-r ?r) (pos-c ?c) (open yes))
    (K-cell (pos-c =(+ ?c 1)) (pos-r ?r) (contains Empty|Parking))
 	=> 
	(assert (apply ?curr east ?r ?c))
)

(defrule right-exec		(declare (salience 50))
    (current ?curr)
    (lastnode ?n)
   	?f1 <- (apply ?curr east ?r ?c)
    (node (ident ?curr) (gcost ?g))
    (goal ?x ?y)
 	=>
	(assert (exec_as ?curr (+ ?n 3) east ?r ?c)
    (newnode (ident (+ ?n 3)) (pos-c (+ ?c 1)) (pos-r ?r) (gcost (+ ?g 1)) (fcost (+ (abs (- ?y (+ ?c 1))) (abs (- ?x ?r)) ?g 1))
    (father ?curr)))
    (retract ?f1)
    (focus NEW)
)

;##########	OPERAZIONE VERSO SINISTRA

(defrule left-apply		(declare (salience 50))
    (current ?curr)
    (node (ident ?curr) (pos-r ?r) (pos-c ?c) (open yes))
    (K-cell (pos-c =(- ?c 1)) (pos-r ?r) (contains Empty|Parking))
 	=>
	(assert (apply ?curr west ?r ?c))
)

(defrule left-exec		(declare (salience 50))
    (current ?curr)
    (lastnode ?n)
   	?f1 <- (apply ?curr west ?r ?c)
    (node (ident ?curr) (gcost ?g))
    (goal ?x ?y)
 	=>
	(assert (exec_as ?curr (+ ?n 4) west ?r ?c)
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

;################ MODULO CONVERT A* -> AGENT OPERATIONS
(defmodule CONVERT (import CALC_MOVES ?ALL) (export ?ALL))

(deftemplate rotation
	(slot r_dir)
	(slot m_dir)
	(slot rotazione)
	(slot dir_f)
	(slot action)
)

(deffacts rotations
	;rotazione da un stato del robot UP;
	(rotation (r_dir north) (m_dir west) (rotazione west) (dir_f west) (action Turnleft))
	(rotation (r_dir north) (m_dir east) (rotazione east) (dir_f east) (action Turnright))
	(rotation (r_dir north) (m_dir south) (rotazione west) (dir_f west) (action Turnleft))
	;rotazione da uno stato del robot RIGHT;
	(rotation (r_dir east) (m_dir north) (rotazione west) (dir_f north) (action Turnleft))
	(rotation (r_dir east) (m_dir south) (rotazione east) (dir_f south) (action Turnright))
	(rotation (r_dir east) (m_dir west) (rotazione west) (dir_f north) (action Turnleft))
	;rotazione da uno stato del robot DOWN;
	(rotation (r_dir south) (m_dir east) (rotazione west) (dir_f east) (action Turnleft))
	(rotation (r_dir south) (m_dir west) (rotazione east) (dir_f west) (action Turnright))
	(rotation (r_dir south) (m_dir north) (rotazione east) (dir_f west) (action Turnright))
	;rotazione da uno stato del robot LEFT;
	(rotation (r_dir west) (m_dir north) (rotazione east) (dir_f north) (action Turnright))
	(rotation (r_dir west) (m_dir south) (rotazione west) (dir_f south) (action Turnleft))
	(rotation (r_dir west) (m_dir east) (rotazione east) (dir_f north) (action Turnright))
)

(defrule check-forward (declare (salience 50))
	;effettuiamo un forward solo quando la direzione dell'operazione e' la medesima
	;in cui si trova l'agente
	(status (step ?i) (time ?t))
	?f1 <- (convert-action ?anc ?id ?oper ?r ?c)
	?f2 <- (agentstatus_As (step ?curr) (pos-r ?rig) (pos-c ?col) (direction ?dir))
	(test (eq ?oper ?dir))
	=>
	;Da cambiare in modo che possa essere compatibile con la il deftamplate del main
	(assert (exec (step ?i) (action Forward))
	(retract ?f1)
)

;definzione metodi di rotazione a destra e sinistra
;regola si attiva solo se viene effettuato match tra tutte le
;possibili rotazioni definiti nella deffact rotations
(defrule check-rotation (declare (salience 50))
	;effettuiamo un forward solo quando la direzione dell'operazione e' la medesima
	;in cui si trova l'agente
	?f1 <- (convert-action ?anc ?id ?oper ?r ?c)
	?f2 <- (agentstatus_As (step ?curr) (direction ?dir))
	(rotation (r_dir ?dir) (m_dir ?oper) (rotazione ?rot))
	=>
	(assert (exect ?rot ?oper))
	;(assert (agent-action (step ?curr) (action turn) (direction ?rot) (pos-r ?r) (pos-c ?c)))
	;esegui una rotazione ?rot (destra o sinitra) per arrivare (o avvicinarci)
	;alla direzione ?oper dell'operazione da effettuare
)

(defrule exec-rotation (declare (salience 50))
	?f1 <- (exect ?rot ?oper)
	?f2 <- (agentstatus_As (step ?curr) (direction ?dir))
	(rotation (r_dir ?dir) (m_dir ?oper) (rotazione ?rot) (dir_f ?turn))
	=>
	(printout t " Rotation " ?rot crlf)
	(modify ?f2 (direction ?turn))
	(retract ?f1)
)

;################ MODULO NEW ################################################################

(defmodule NEW (import AGENT ?ALL) (export ?ALL))

;;;;;;;;;CHIEDERE AL PROF XKE NON RICONTROLLA IL COSTO TRA I NODI IN CLODED per riaprirli????
(defrule check-closed (declare (salience 50))
	?f1 <- (newnode (ident ?id) (pos-r ?r) (pos-c ?c))
	(node (ident ?old) (pos-r ?r) (pos-c ?c) (open no))
	?f2 <- (alreadyclosed ?a)
	=>
	(assert (alreadyclosed (+ ?a 1)))
	(retract ?f1)
	(retract ?f2)
	(pop-focus)
)

;Il nodo che sto provando a generare negli open ha un costo f(x) maggiore di un uguale
;gia' presente nella lista di open
(defrule check-open-worse (declare (salience 50))
	?f1 <- (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (gcost ?g) (father ?anc))
    (node (ident ?old) (pos-r ?r) (pos-c ?c) (gcost ?g-old) (open yes))
	(test (or (> ?g ?g-old) (= ?g-old ?g)))
	?f2 <- (open-worse ?a)
    =>
	(assert (open-worse (+ ?a 1)))
	(retract ?f1)
	(retract ?f2)
	(pop-focus)
)

;il nodo che sto genereando ha un costo f(x) inferiore al quello di uno uguale
;gia' presente in open
(defrule check-open-better (declare (salience 50))
	?f1 <- (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (gcost ?g) (fcost ?f) (father ?anc))
 	?f2 <- (node (ident ?old) (pos-r ?r) (pos-c ?c) (gcost ?g-old) (open yes))
    (test (<  ?g ?g-old))
	?f3 <- (open-better ?a)
    =>
	(assert (node (ident ?id) (pos-r ?r) (pos-c ?c) (gcost ?g) (fcost ?f) (father ?anc) (open yes)))
	(assert (open-better (+ ?a 1)))
	(retract ?f1 ?f2 ?f3)
	(pop-focus)
)

;Aggiunge un nuovo nodo da esplorare alla lista di open
;elimanando i fatti temporanei di (newnode)
(defrule add-open
	(declare (salience 49))
	?f1 <- (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (gcost ?g) (fcost ?f)(father ?anc))
	?f2 <- (numberofnodes ?a)
	=>
	(assert (node (ident ?id) (pos-r ?r) (pos-c ?c) (gcost ?g) (fcost ?f)(father ?anc) (open yes)))
	(assert (numberofnodes (+ ?a 1)))
	(retract ?f1 ?f2)
	(pop-focus)
)



