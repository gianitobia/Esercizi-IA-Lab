;// PLANNER
;Questo modulo si occupa di pianificare le azioni
;che l'agente dovra' fare eseguire per arrivare ad un dato goal
(defmodule PLANNER (import AGENT ?ALL) (export ?ALL))

;Definizone del template per le azioni pieanificate
(deftemplate planned-action
	(slot step)
	(slot action)		;azioni da far effettuare al robot
	(slot pos_r)		;riga da dove viene effettuata l'azione 
	(slot pos_c) 		;colonna da dove si effettua l'azione
)

;definizione del template per i goal a cui bisogna arrivare
;possiamo definire dei goal a vari livelli di astrazione
;piu' il valore e' alto piu' l'azione e' specifica
(deftemplate planned-goal
	(slot level)
	(slot ordine)		;0 -> N; successione di passi ad uno stesso livello di astrazione
	(slot action)		;tipo di azione richiesta dal goal
	(slot pos_r)		;riga della posizione finale del robot
	(slot pos_c) 		;colonna della posione finale del robot
)




;===========================================================================================================================
;===========================================================================================================================
;===========================================================================================================================
;Modulo per il calcolo del percorso mediante l'utilizzo di A*
;PAINIFICAZIONE -> AZIONI PER GOAL -> CONVERSIONE AZIONI IN BASSO LIVELLO
(defmodule CALC_PATH (import PLANNER ?ALL) (export ?ALL))

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

;Definizione di uno stato agente, (interna da A*, per simulare il movimento)
(deftemplate agentstatus_As
	(slot step)
	(slot pos-r)
	(slot pos-c)
	(slot direction)
)

;inizializzazione delle variabili per pianificare con A*
(defrule init_var (declare (salience 50))
	(K-agent (step ?st) (pos-r ?r) (pos-c ?c) (direction ?d))
	=>
	(assert
		(agentstatus_As (step 0) (pos-r ?r) (pos-c ?c) (direction ?d))
        (node (ident 0) (gcost 0) (fcost 0) (father NA) (pos-r ?r) (pos-c ?c) (open yes)) 
        (current 0)
        (lastnode 0)
        (open-worse 0)
        (open-better 0)
        (alreadyclosed 0)
        (numberofnodes 0)
	)
)


;############################################################
;######   REGOLE DI FINE PIANIFICAZIONE DI MOVIMENTO   ######
;############################################################

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
	?f <- (stampa ?id)
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

;Avvio la conversione delle azioni in (planned-action)
(defrule convert-solution (declare (salience 99))
	?f <- (azione ?anc ?id ?oper ?r ?c)
	=>
	;(printout t ?id " Eseguo azione " ?oper " da stato (" ?r "," ?c ") " crlf)
	(assert (convert-action ?anc ?id ?oper ?r ?c))
	(focus CONVERT)
	(retract ?f)
)

;############################################################
;###########         REGOLE DI MOVIMENTO         ############
;############################################################


;OPERAZIONI VERSO SU
;regola che controlla se e' possibile fare una operazione di movimento verso su
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
	(assert 
		(exec_as ?curr (+ ?n 1) north ?r ?c)
		(newnode 	
				(ident (+ ?n 1)) 
				(pos-r (+ ?r 1)) 
				(pos-c ?c) 
				(gcost (+ ?g 1)) 
				(fcost (+ (abs (- ?x (+ ?r 1))) (abs (- ?y ?c)) ?g 1))  ;distanza L1
				(father ?curr)
		)
	)
  	(retract ?f1)
  	(focus NEW)
)


;##########	OPERAZIONE VERSO GIU'
;regola che controlla se e' possibile fare una operazione di movimento verso giu'
(defrule down-apply	  (declare (salience 50))
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
	(assert 
		(exec_as ?curr (+ ?n 2) south ?r ?c)
		(newnode 
			(ident (+ ?n 2))
			(pos-r (- ?r 1)) 
			(pos-c ?c) 
			(gcost (+ ?g 1)) 
			(fcost (+ (abs (- ?x (- ?r 1))) (abs (- ?y ?c)) ?g 1))	;distanza L1
    		(father ?curr)
		)
	)
	(retract ?f1)
  	(focus NEW)
)


;##########	OPERAZIONE VERSO DESTRA
;regola che controlla se e' possibile fare una operazione di movimento verso destra
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
	(assert 
		(exec_as ?curr (+ ?n 3) east ?r ?c)
    	(newnode 
			(ident (+ ?n 3)) 
			(pos-c (+ ?c 1)) 
			(pos-r ?r) 
			(gcost (+ ?g 1)) 
			(fcost (+ (abs (- ?y (+ ?c 1))) (abs (- ?x ?r)) ?g 1))	;distanza L1
    		(father ?curr)
		)
	)
    (retract ?f1)
    (focus NEW)
)


;##########	OPERAZIONE VERSO SINISTRA
;regola che controlla se e' possibile fare una operazione di movimento verso sinistra
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
	(assert 
		(exec_as ?curr (+ ?n 4) west ?r ?c)
		(newnode 
			(ident (+ ?n 4)) 
			(pos-c (- ?c 1)) 
			(pos-r ?r) 
			(gcost (+ ?g 1)) 
			(fcost (+ (abs (- ?y (- ?c 1))) 
			(abs (- ?x ?r)) ?g 1))
    		(father ?curr)
		)
	)
  	(retract ?f1)
  	(focus NEW)
)

;############################################################
;###########      REGOLE DI SELEZIONE NODO       ############
;############################################################

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

;controlla che la lista di open non sia vuota altrimenti segnala l'errore
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
	(halt)		;da modifcare per evitare che si blocchi il programma
)




;===========================================================================================================================
;===========================================================================================================================
;===========================================================================================================================
;Modulo per la generazione di nuovi nodi di A* e la gestione del miglior nodo current
(defmodule NEW (import CALC_PATH ?ALL) (export ?ALL))

;Non vengono ricontrollati i nodi in CLOSED(gia' esplorati) xke la funzione distanza che
;utilizziamo e` monotona e quindi non succedera' di doverli riaprirli;
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


;Aggiunge un nuovo nodo da esplorare alla lista di open elimanando i fatti temporanei di (newnode)
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




;===========================================================================================================================
;===========================================================================================================================
;===========================================================================================================================
;Modulo per la conversione tra azioni di generiche di A* --> (planned-action) 
(defmodule CONVERT (import CALC_PATH ?ALL) (export ?ALL))

;Definizione della base di conoscenza per le rotazioni
(deftemplate rotation
	(slot r_dir)
	(slot m_dir)
	(slot rotazione)
	(slot dir_f)	
	(slot action)			;azione da comunicare al robot;
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

;regole per pianificare un forward

;regole per modificare la rappresentazione interna dell'agent per il movimento
;converto in forward verso SU
(defrule exec-forward-nord	(declare (salience 60))
	?f1 <- (convert-action ?anc ?id north ?r ?c)
	?f2 <- (agentstatus_As (step ?curr) (pos-r ?rig) (pos-c ?col) (direction north))
	=>
	(printout t " forward NORD " crlf)
	(modify ?f2 (step =(+ ?curr 1)) (pos-r =(+ ?rig 1)))
	(assert 
			(planned-action 
					(step ?curr) 
					(action Forward)
					(pos_r ?rig)
					(pos_c ?col)  
			)
	)
	(retract ?f1)
	(pop-focus)
)


;converto in forward verso destra
(defrule exec-forward-east	(declare (salience 60))
	?f1 <- (convert-action ?anc ?id east ?r ?c)
	?f2 <- (agentstatus_As (step ?curr) (pos-r ?rig) (pos-c ?col) (direction east))
	=>
	(printout t " forward EAST " crlf)
	(modify ?f2 (step =(+ ?curr 1)) (pos-c =(+ ?col 1)))
	(assert 
			(planned-action
					(step ?curr)
					(action Forward)
					(pos_r ?rig)
					(pos_c ?col)
			)
	)
	(retract ?f1)
	(pop-focus)
)


;converto in forward verso giu
(defrule exec-forward-south	 (declare (salience 60))
	?f1 <- (convert-action ?anc ?id south ?r ?c)
	?f2 <- (agentstatus_As (step ?curr) (pos-r ?rig) (pos-c ?col) (direction south))
	=>
	(printout t " forward SOUTH " crlf)
	(modify ?f2 (step =(+ ?curr 1)) (pos-r =(- ?rig 1)))
	(assert 
			(planned-action
					(step ?curr)
					(action Forward)
					(pos_r ?rig)
					(pos_c ?col)
			)
	)
	(retract ?f1)
	(pop-focus)
)


;converto in forward verso giu
(defrule exec-forward-west	 (declare (salience 60))
	?f1 <- (convert-action ?anc ?id west ?r ?c)
	?f2 <- (agentstatus_As (step ?curr) (pos-r ?rig) (pos-c ?col) (direction west))
	=>
	(printout t " forward WEST " crlf)
	(modify ?f2 (step =(+ ?curr 1)) (pos-c =(- ?col 1)))
	(assert 
			(planned-action
					(step ?curr)
					(action Forward)
					(pos_r ?rig)
					(pos_c ?col)
			)
	)
	(retract ?f1)
	(pop-focus)
)

;definzione metodi di rotazione a destra e sinistra
;regola si attiva solo se viene effettuato match tra tutte le
;possibili rotazioni definite nella deffact rotations
(defrule exec-rotation (declare (salience 50))
	;effettuiamo un forward solo quando la direzione dell'operazione e' la medesima
	;in cui si trova l'agente
	?f1 <- (convert-action ?anc ?id ?oper ?r ?c)
	?f2 <- (agentstatus_As (step ?curr) (direction ?dir))
	(rotation (r_dir ?dir) (m_dir ?oper) (rotazione ?rot) (dir_f ?turn) (action ?act))
	=>
	(printout t " Rotation " ?act crlf)
	(modify ?f2 (step =(+ ?curr 1)) (direction ?turn))
	(assert 
			(planned-action
					(step ?curr)
					(action ?act)
					(pos_r ?rig)
					(pos_c ?col)
			)
	)
	;esegui una rotazione ?rot (destra o sinitra) per arrivare (o avvicinarci)
	;alla direzione ?oper dell'operazione da effettuare
)




;===========================================================================================================================
;===========================================================================================================================
;===========================================================================================================================
;Modulo per la cancellazione di tutti i fatti relativi ad un planning gia' eseguito o fallito
(defmodule DEL_PLANNER (import PLANNER ?ALL) (export ?ALL))

