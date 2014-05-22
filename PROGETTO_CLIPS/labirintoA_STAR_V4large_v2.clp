;usiamo come funzione euristica la distanza di Manhattan

;MODULO MAIN
(defmodule MAIN (export ?ALL))

;definizione del template del nodo
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

;definizione della struttura della cella del labirinto
(deftemplate cell 
      (slot pos-r)		; y
      (slot pos-c) 		; x
      (slot contains (allowed-values  wall gate empty))
)

(deftemplate agentstatus
	(slot step)
	(slot pos-r)
	(slot pos-c)
	(slot direction)
	(slot penality)
)

(deftemplate rotation
	(slot r_dir)
	(slot m_dir)
	(slot rotazione)
	(slot dir_f)
)

;iniziali
(deffacts init-agent
	(agentstatus
		(step 0)
		(pos-r 0)
		(pos-c 4)
		(direction up)
		(penality 0)
	)
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

;   Rappresentazione grafica del labirinto
;   - - - - - - - -

;   |W|W|W|W|W|G|W|W|W|W|W|W|W|G|W|W|	10
;    - - - - - - - - - - - - - - - -
;   |W| | | |W| | |W| | | | |W| | |W|	9
;    - - - - - - - - - - - - - - - -
;   |W| | | |W| | |W| | | | |W| | |W|	8
;    - - - - - - - - - - - - - - - -
;   |W| | | |W| | |W|W|W| | |W|W| |W|	7
;    - - - - - - - - - - - - - - - -
;   |W| | | |W| | | | |W| | |W| | |G|	6
;    - - - - - - - - - - - - - - - -
;   |W| | | |W| | |W| |W| |W|W| |W|W|	5
;    - - - - - - - - - - - - - - - -
;   |W| |W| | | | |W| | | | |W| | |W|	4
;    - - - - - - - - - - - - - - - -
;   |W| |W| | |W|W|W|W| |W|W|W|W| |W	3
;    - - - - - - - - - - - - - - - -
;   |W| | |W|W| |x|W| | |W| |W| | |W	2
;    - - - - - - - - - - - - - - - -
;   |W| |X| | | |W| | | | | | | |W|W|	1
;    - - - - - - - - - - - - - - - -
;   |W|W|W|W|G|W|W|W|W|W|W|W|G|W|W|W|	0
;    - - - - - - - - - - - - - - - -
;    0 1 2 3 4 5 6 7 8 9 101112131415

;formalizzazione della struttura del labirinto mediante celle
(deffacts domain
	
    (cell (pos-r 0) (pos-c 0) (contains wall))
	(cell (pos-r 0) (pos-c 1) (contains wall))
	(cell (pos-r 0) (pos-c 2) (contains wall))
	(cell (pos-r 0) (pos-c 3) (contains wall))
	(cell (pos-r 0) (pos-c 4) (contains gate))
	(cell (pos-r 0) (pos-c 5) (contains wall))
	(cell (pos-r 0) (pos-c 6) (contains wall))
	(cell (pos-r 0) (pos-c 7) (contains wall))
    (cell (pos-r 0) (pos-c 8) (contains wall))
	(cell (pos-r 0) (pos-c 9) (contains wall))
	(cell (pos-r 0) (pos-c 10) (contains wall))
	(cell (pos-r 0) (pos-c 11) (contains wall))
	(cell (pos-r 0) (pos-c 12) (contains gate))
	(cell (pos-r 0) (pos-c 13) (contains wall))
	(cell (pos-r 0) (pos-c 14) (contains wall))	
	(cell (pos-r 0) (pos-c 15) (contains wall))
	(cell (pos-r 1) (pos-c 0) (contains wall))
	(cell (pos-r 1) (pos-c 1) (contains empty))
	(cell (pos-r 1) (pos-c 2) (contains empty))
	(cell (pos-r 1) (pos-c 3) (contains empty))
	(cell (pos-r 1) (pos-c 4) (contains empty))
	(cell (pos-r 1) (pos-c 5) (contains empty))
	(cell (pos-r 1) (pos-c 6) (contains wall))
	(cell (pos-r 1) (pos-c 7) (contains empty))
    (cell (pos-r 1) (pos-c 8) (contains empty))
	(cell (pos-r 1) (pos-c 9) (contains empty))
	(cell (pos-r 1) (pos-c 10) (contains empty))
	(cell (pos-r 1) (pos-c 11) (contains empty))
	(cell (pos-r 1) (pos-c 12) (contains empty))
	(cell (pos-r 1) (pos-c 13) (contains empty))
	(cell (pos-r 1) (pos-c 14) (contains wall))
	(cell (pos-r 1) (pos-c 15) (contains wall))
	(cell (pos-r 2) (pos-c 0) (contains wall))
	(cell (pos-r 2) (pos-c 1) (contains empty))
	(cell (pos-r 2) (pos-c 2) (contains empty))
	(cell (pos-r 2) (pos-c 3) (contains wall))
	(cell (pos-r 2) (pos-c 4) (contains wall))
	(cell (pos-r 2) (pos-c 5) (contains empty))
	(cell (pos-r 2) (pos-c 6) (contains empty))
	(cell (pos-r 2) (pos-c 7) (contains wall))
	(cell (pos-r 2) (pos-c 8) (contains empty))
	(cell (pos-r 2) (pos-c 9) (contains empty))
	(cell (pos-r 2) (pos-c 10) (contains wall))
	(cell (pos-r 2) (pos-c 11) (contains empty))
	(cell (pos-r 2) (pos-c 12) (contains wall))
	(cell (pos-r 2) (pos-c 13) (contains empty))
	(cell (pos-r 2) (pos-c 14) (contains empty))
	(cell (pos-r 2) (pos-c 15) (contains wall))
	(cell (pos-r 3) (pos-c 0) (contains wall))
	(cell (pos-r 3) (pos-c 1) (contains empty))
	(cell (pos-r 3) (pos-c 2) (contains wall))
	(cell (pos-r 3) (pos-c 3) (contains empty))
	(cell (pos-r 3) (pos-c 4) (contains empty))
	(cell (pos-r 3) (pos-c 5) (contains wall))
	(cell (pos-r 3) (pos-c 6) (contains wall))
	(cell (pos-r 3) (pos-c 7) (contains wall))
	(cell (pos-r 3) (pos-c 8) (contains wall))
	(cell (pos-r 3) (pos-c 9) (contains empty))
	(cell (pos-r 3) (pos-c 10) (contains wall))
	(cell (pos-r 3) (pos-c 11) (contains empty))
	(cell (pos-r 3) (pos-c 12) (contains wall))
	(cell (pos-r 3) (pos-c 13) (contains wall))
	(cell (pos-r 3) (pos-c 14) (contains empty))
	(cell (pos-r 3) (pos-c 15) (contains wall))
	(cell (pos-r 4) (pos-c 0) (contains wall))
	(cell (pos-r 4) (pos-c 1) (contains empty))
	(cell (pos-r 4) (pos-c 2) (contains wall))
	(cell (pos-r 4) (pos-c 3) (contains empty))
	(cell (pos-r 4) (pos-c 4) (contains empty))
	(cell (pos-r 4) (pos-c 5) (contains empty))
	(cell (pos-r 4) (pos-c 6) (contains empty))
	(cell (pos-r 4) (pos-c 7) (contains wall))
    (cell (pos-r 4) (pos-c 8) (contains  empty))
	(cell (pos-r 4) (pos-c 9) (contains  empty))
	(cell (pos-r 4) (pos-c 10) (contains wall))
	(cell (pos-r 4) (pos-c 11) (contains  empty))
	(cell (pos-r 4) (pos-c 12) (contains wall))
	(cell (pos-r 4) (pos-c 13) (contains  empty))
	(cell (pos-r 4) (pos-c 14) (contains  empty))
	(cell (pos-r 4) (pos-c 15) (contains wall))
	(cell (pos-r 5) (pos-c 0) (contains wall))
	(cell (pos-r 5) (pos-c 1) (contains empty))
	(cell (pos-r 5) (pos-c 2) (contains empty))
	(cell (pos-r 5) (pos-c 3) (contains empty))
	(cell (pos-r 5) (pos-c 4) (contains wall))
	(cell (pos-r 5) (pos-c 5) (contains empty))
	(cell (pos-r 5) (pos-c 6) (contains empty))
	(cell (pos-r 5) (pos-c 7) (contains wall))
	(cell (pos-r 5) (pos-c 8) (contains  empty))
	(cell (pos-r 5) (pos-c 9) (contains wall))
	(cell (pos-r 5) (pos-c 10) (contains wall))
	(cell (pos-r 5) (pos-c 11) (contains wall))
	(cell (pos-r 5) (pos-c 12) (contains wall))
	(cell (pos-r 5) (pos-c 13) (contains  empty))
	(cell (pos-r 5) (pos-c 14) (contains wall))
	(cell (pos-r 5) (pos-c 15) (contains wall))
	(cell (pos-r 6) (pos-c 0) (contains wall))
	(cell (pos-r 6) (pos-c 1) (contains empty))
	(cell (pos-r 6) (pos-c 2) (contains empty))
	(cell (pos-r 6) (pos-c 3) (contains empty))
	(cell (pos-r 6) (pos-c 4) (contains wall))
	(cell (pos-r 6) (pos-c 5) (contains empty))
	(cell (pos-r 6) (pos-c 6) (contains empty))
	(cell (pos-r 6) (pos-c 7) (contains  empty))
    (cell (pos-r 6) (pos-c 8) (contains  empty))
	(cell (pos-r 6) (pos-c 9) (contains wall))
	(cell (pos-r 6) (pos-c 10) (contains  empty))
	(cell (pos-r 6) (pos-c 11) (contains  empty))
	(cell (pos-r 6) (pos-c 12) (contains wall))
	(cell (pos-r 6) (pos-c 13) (contains  empty))
	(cell (pos-r 6) (pos-c 14) (contains  empty))
	(cell (pos-r 6) (pos-c 15) (contains gate))
	(cell (pos-r 7) (pos-c 0) (contains wall))
	(cell (pos-r 7) (pos-c 1) (contains empty))
	(cell (pos-r 7) (pos-c 2) (contains empty))
	(cell (pos-r 7) (pos-c 3) (contains empty))
	(cell (pos-r 7) (pos-c 4) (contains wall))
	(cell (pos-r 7) (pos-c 5) (contains empty))
	(cell (pos-r 7) (pos-c 6) (contains empty))
	(cell (pos-r 7) (pos-c 7) (contains wall))
    (cell (pos-r 7) (pos-c 8) (contains wall))
	(cell (pos-r 7) (pos-c 9) (contains wall))
	(cell (pos-r 7) (pos-c 10) (contains  empty))
	(cell (pos-r 7) (pos-c 11) (contains  empty))
	(cell (pos-r 7) (pos-c 12) (contains wall))
	(cell (pos-r 7) (pos-c 13) (contains wall))
	(cell (pos-r 7) (pos-c 14) (contains  empty))
	(cell (pos-r 7) (pos-c 15) (contains wall))
	(cell (pos-r 8) (pos-c 0) (contains wall))
	(cell (pos-r 8) (pos-c 1) (contains empty))
	(cell (pos-r 8) (pos-c 2) (contains empty))
	(cell (pos-r 8) (pos-c 3) (contains empty))
	(cell (pos-r 8) (pos-c 4) (contains wall))
	(cell (pos-r 8) (pos-c 5) (contains empty))
	(cell (pos-r 8) (pos-c 6) (contains empty))
	(cell (pos-r 8) (pos-c 7) (contains wall))
    (cell (pos-r 8) (pos-c 8) (contains  empty))
	(cell (pos-r 8) (pos-c 9) (contains  empty))
	(cell (pos-r 8) (pos-c 10) (contains  empty))
	(cell (pos-r 8) (pos-c 11) (contains  empty))
	(cell (pos-r 8) (pos-c 12) (contains wall))
	(cell (pos-r 8) (pos-c 13) (contains  empty))
	(cell (pos-r 8) (pos-c 14) (contains  empty))
	(cell (pos-r 8) (pos-c 15) (contains wall))
	(cell (pos-r 9) (pos-c 0) (contains wall))
	(cell (pos-r 9) (pos-c 1) (contains empty))
	(cell (pos-r 9) (pos-c 2) (contains empty))
	(cell (pos-r 9) (pos-c 3) (contains empty))
	(cell (pos-r 9) (pos-c 4) (contains wall))
	(cell (pos-r 9) (pos-c 5) (contains empty))
	(cell (pos-r 9) (pos-c 6) (contains empty))
	(cell (pos-r 9) (pos-c 7) (contains wall))
    (cell (pos-r 9) (pos-c 8) (contains  empty))
	(cell (pos-r 9) (pos-c 9) (contains  empty))
	(cell (pos-r 9) (pos-c 10) (contains  empty))
	(cell (pos-r 9) (pos-c 11) (contains  empty))
	(cell (pos-r 9) (pos-c 12) (contains wall))
	(cell (pos-r 9) (pos-c 13) (contains  empty))
	(cell (pos-r 9) (pos-c 14) (contains  empty))
	(cell (pos-r 9) (pos-c 15) (contains wall))
	(cell (pos-r 10) (pos-c 0) (contains wall))
	(cell (pos-r 10) (pos-c 1) (contains wall))
	(cell (pos-r 10) (pos-c 2) (contains wall))
	(cell (pos-r 10) (pos-c 3) (contains wall))
	(cell (pos-r 10) (pos-c 4) (contains wall))
	(cell (pos-r 10) (pos-c 5) (contains gate))
	(cell (pos-r 10) (pos-c 6) (contains wall))
	(cell (pos-r 10) (pos-c 7) (contains wall))
    (cell (pos-r 10) (pos-c 8) (contains wall))
	(cell (pos-r 10) (pos-c 9) (contains wall))
	(cell (pos-r 10) (pos-c 10) (contains wall))
	(cell (pos-r 10) (pos-c 11) (contains wall))
	(cell (pos-r 10) (pos-c 12) (contains wall))
	(cell (pos-r 10) (pos-c 13) (contains gate))
	(cell (pos-r 10) (pos-c 14) (contains wall))
	(cell (pos-r 10) (pos-c 15) (contains wall))
)

;definizione nodo di partenza / Goal
(deffacts S0
      (node (ident 0) (gcost 0) (fcost 0) (father NA) (pos-r 0) (pos-c 4) (open yes)) 
      (current 0)
      (lastnode 0)
      (open-worse 0)
      (open-better 0)
      (alreadyclosed 0)
      (numberofnodes 0)
)

(deffacts final
      (goal 10 5)
)

;###################### REGOLE ################################################################

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
    (exec ?anc ?id ?oper ?r ?c)
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
	(numberofnodes ?n )  
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


;############# REGOLE DI MOVIMENTO ############################################################

;##########	OPERAZIONE VERSO SU

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


;################ MODULO CONVERT ############################################################
(defmodule CONVERT (import MAIN ?ALL) (export ?ALL))

;(deftemplate agentstatus
;	(slot step)
;	(slot pos-r)
;	(slot pos-c)
;	(slot direction (allowed-values up down right left))
;	(slot penality)
;)

(defrule check-forward (declare (salience 50))
	;effettuiamo un forward solo quando la direzione dell'operazione e' la medesima
	;in cui si trova l'agente
	?f1 <- (convert-action ?anc ?id ?oper ?r ?c)
	?f2 <- (agentstatus (step ?curr) (pos-r ?rig) (pos-c ?col) (direction ?dir) (penality ?pen))
	(test (eq ?oper ?dir))
	=>
	;(assert (agent-action (step ?curr) (action forward) (direction ?dir) (pos-r ?r) (pos-c ?c)))
	(assert (exect forward ?oper ?r ?c))
	(retract ?f1)
)

;definizione delle forward nelle 4 direzioni
(defrule exec-forward-nord (declare (salience 50))
	;effettuaimo un forward verso SU
	?f1 <- (exect forward up ?r ?c)
	?f2 <- (agentstatus (step ?curr) (pos-r ?rig) (pos-c ?col))
	=>
	(printout t " forward NORD " crlf)
	(printout t " " crlf)
	(modify ?f2 (step =(+ ?curr 1)) (pos-r =(+ ?rig 1)))
	(retract ?f1)
	(pop-focus)
)

(defrule exec-forward-est (declare (salience 50))
	;effettuaimo un forward verso destra
	?f1 <- (exect forward right ?r ?c)
	?f2 <- (agentstatus (step ?curr) (pos-r ?rig) (pos-c ?col))
	=>
	(printout t " forward EST " crlf)
	(printout t " " crlf)
	(modify ?f2 (step =(+ ?curr 1)) (pos-c =(+ ?col 1)))
	(retract ?f1)
	(pop-focus)
)

(defrule exec-forward-sud (declare (salience 50))
	;effettuaimo un forward verso giu'
	?f1 <- (exect forward down ?r ?c)
	?f2 <- (agentstatus (step ?curr) (pos-r ?rig) (pos-c ?col))
	=>
	(printout t " forward SUD " crlf)
	(printout t " " crlf)
	(modify ?f2 (step =(+ ?curr 1)) (pos-r =(- ?rig 1)))
	(retract ?f1)
	(pop-focus)
)

(defrule exec-forward-ovest (declare (salience 50))
	;effettuaimo un forward verso destra
	?f1 <- (exect forward left ?r ?c)
	?f2 <- (agentstatus (step ?curr) (pos-r ?rig) (pos-c ?col))
	=>
	(printout t " forward OVEST " crlf)
	(printout t " " crlf)
	(modify ?f2 (step =(+ ?curr 1)) (pos-c =(- ?col 1)))
	(retract ?f1)
	(pop-focus)
)

;definzione metodi di rotazione a destra e sinistra
;regola si attiva solo se viene effettuato match tra tutte le
;possibili rotazioni definiti nella deffact rotations
(defrule check-rotation (declare (salience 50))
	;effettuiamo un forward solo quando la direzione dell'operazione e' la medesima
	;in cui si trova l'agente
	?f1 <- (convert-action ?anc ?id ?oper ?r ?c)
	?f2 <- (agentstatus (step ?curr) (direction ?dir))
	(rotation (r_dir ?dir) (m_dir ?oper) (rotazione ?rot))
	=>
	(assert (exect ?rot ?oper))
	;(assert (agent-action (step ?curr) (action turn) (direction ?rot) (pos-r ?r) (pos-c ?c)))
	;esegui una rotazione ?rot (destra o sinitra) per arrivare (o avvicinarci)
	;alla direzione ?oper dell'operazione da effettuare
)

(defrule exec-rotation (declare (salience 50))
	?f1 <- (exect ?rot ?oper)
	?f2 <- (agentstatus (step ?curr) (direction ?dir))
	(rotation (r_dir ?dir) (m_dir ?oper) (rotazione ?rot) (dir_f ?turn))
	=>
	(printout t " Rotation " ?rot crlf)
	(modify ?f2 (direction ?turn))
	(retract ?f1)
)

;################ MODULO NEW ################################################################

(defmodule NEW (import MAIN ?ALL) (export ?ALL))

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