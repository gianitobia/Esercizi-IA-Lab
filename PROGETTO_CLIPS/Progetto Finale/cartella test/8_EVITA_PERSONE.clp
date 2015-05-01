
(defmodule EVITA-PERSONA (import AGENT ?ALL) (export ?ALL))

(deftemplate incremento
	(slot direction)
	(slot P1-r)
	(slot P1-c)
	(slot P2-r)
	(slot P2-c)
	(slot P3-r)
	(slot P3-c)
	(slot P4-r)
	(slot P4-c)
	(slot P5-r)
	(slot P5-c)
	(slot P6-r)
	(slot P6-c)
)

(deffacts increments
	
	(incremento (direction north) 
		(P1-r 1) (P1-c -1)
		(P2-r 1) (P2-c 0) 
		(P3-r 1) (P3-c -1) 
		(P4-r 0) (P4-c -1) 
		(P5-r 0) (P5-c 1) 
		(P6-r -1) (P6-c 0)
	)
	
	(incremento (direction east) 
		(P1-r 1) (P1-c 1) 
		(P2-r 0) (P2-c 1) 
		(P3-r -1) (P3-c 1) 
		(P4-r 1) (P4-c 0) 
		(P5-r -1) (P5-c 0) 
		(P6-r 0) (P6-c -1)
	)
	
	(incremento (direction south) 
		(P1-r -1) (P1-c 1) 
		(P2-r -1) (P2-c 0) 
		(P3-r -1) (P3-c -1) 
		(P4-r 0) (P4-c 1)
		(P5-r 0) (P5-c -1) 
		(P6-r 1) (P6-c 0)
	)
	
	(incremento (direction west) 
		(P1-r 1) (P1-c -1) 
		(P2-r 0) (P2-c -1) 
		(P3-r -1) (P3-c -1) 
		(P4-r 1) (P4-c 0) 
		(P5-r -1) (P5-c 0) 
		(P6-r 0) (P6-c 1)
	)
)	


(deftemplate try-step
	(slot count)
	(slot step)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////						PRIMO STEP	->	WAIT						////////////////		
;///////////////////////////////////////////////////////////////////////////////////////////////////

;Se e' la prima volta che entro allora vuol dire che faccio un primo tentativo di wait, xke magari 
;la persona occupa la cella che a me serve ma solo per uno step, al prossimo si sospetera' 
;e la cella diventera' libera
(defrule primo-tentativo-wait-begin-V1 (declare (salience 140))
	(not (try-step))
	(status (step ?st))
	=>
	(assert 
		(posticipate 1)
		(try-step (count 1) (step ?st))
	)
	(focus POSTICIPATE)
)

(defrule primo-tentativo-wait-begin-V2 (declare (salience 140))
	(status (step ?st))
	?f1 <- (try-step (step ?i))
	(test (> ?st (+ ?i 1)))				;mi serve per controlla che rifaccio il wait 
	=>
	(assert 
		(posticipate 1)
	)
	(modify ?f1 (count 1) (step ?st))
	(focus POSTICIPATE)
)

;dopo aver posticipato tutte le planned action dico al robot di aspettare
(defrule primo-tentativo-wait-end (declare (salience 140))
	?f1 <- (try-step (count 1))
	?f2 <- (posticipate-exec)
	(status (step ?st))
	=>
	(assert 
		(planned-action (step ?st) (action Wait))	
	)
	(modify ?f1 (count 2))
	(retract ?f2)
	(pop-focus)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////					SECONDO STEP	->		GIRO-TONDO				////////////////		
;///////////////////////////////////////////////////////////////////////////////////////////////////

;Se dopo il wait sono ancora bloccato vuol dire che sono in una fase di stallo perche' la persona
;sta aspettando che la cella in cui si trova il robot si liberi ed il robot ha come target la cella
;in cui si trova ora la persona;

;in base alla posizione e direzione del robot controllo le celle attorno e vedo quale percorso e'
;fattibile per aggirare la persona incontrata;

;v1 = left - up - right
(defrule check-giro-tondo-V1 (declare (salience 140))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction ?dir))
	(incremento (direction ?dir) 
		(P1-r ?p1_r) (P1-c ?p1_c)
		(P2-r ?p2_r) (P2-c ?p2_c)  
		(P4-r ?p4_r) (P4-c ?p2_c) 
	)
	(K-cell (pos-r =(+ ?r ?p1_r)) (pos-c =(+ ?c ?p1_c)) (contains Empty|Parking))
	(K-cell (pos-r =(+ ?r ?p4_r)) (pos-c =(+ ?c ?p4_c)) (contains Empty|Parking))
	
	=>;percorso fattibile
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnleft) (pos_r =(+ ?r ?p2_r)) (pos_c =(+ ?c ?p2_c)) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnright =(+ ?r ?p4_r) =(+ ?c ?p4_c) p3)
		(try-action =(+ ?st 3) Forward =(+ ?r ?p4_r) =(+ ?c ?p4_c) p3)
		(try-action =(+ ?st 4) Turnright =(+ ?r ?p1_r) =(+ ?c ?p1_c) p3)
		(try-action =(+ ?st 5) Forward =(+ ?r ?p1_r) =(+ ?c ?p1_c) p3)
		
		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;v2 = right - up - left
(defrule check-giro-tondo-V2 (declare (salience 140))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction ?dir))
	(incremento (direction ?dir) 
		(P3-r ?p3_r) (P3-c ?p3_c)
		(P2-r ?p2_r) (P2-c ?p2_c)  
		(P5-r ?p5_r) (P5-c ?p5_c) 
	)
	(K-cell (pos-r =(+ ?r ?p3_r)) (pos-c =(+ ?c ?p3_c)) (contains Empty|Parking))
	(K-cell (pos-r =(+ ?r ?p5_r)) (pos-c =(+ ?c ?p5_c)) (contains Empty|Parking))
	
	=>;percorso fattibile
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnright) (pos_r =(+ ?r ?p2_r)) (pos_c =(+ ?c ?p2_c)) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnleft =(+ ?r ?p5_r) =(+ ?c ?p5_c) ?p3)
		(try-action =(+ ?st 3) Forward =(+ ?r ?p5_r) =(+ ?c ?p5_c) ?p3)
		(try-action =(+ ?st 4) Turnleft =(+ ?r ?p3_r) =(+ ?c ?p3_c) ?p3)
		(try-action =(+ ?st 5) Forward =(+ ?r ?p3_r) =(+ ?c ?p3_c) ?p3)
		
		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////							CHECK STEP								////////////////		
;///////////////////////////////////////////////////////////////////////////////////////////////////

(defrule check-step-left (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	(planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction ?dir))
	(incremento 
		(direction ?dir)
		(P4-r ?P4-r) (P4-c ?P4-c)
	)
	(K-cell (pos-r =(+ ?r ?P4-r)) (pos-c =(+ ?c ?P4-c)) (contains Empty|Parking))
	=>
	(assert
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c ?p3)
		(try-action =(+ ?st 1) Forward ?r ?c ?p3)
		(try-action =(+ ?st 2) Turnright =(+ ?r ?P4-r) =(+ ?c ?P4-c) ?p3)
		(try-action =(+ ?st 3) Turnright =(+ ?r ?P4-r) =(+ ?c ?P4-c) ?p3)
		(try-action =(+ ?st 4) Forward =(+ ?r ?P4-r) =(+ ?c ?P4-c) ?p3)
		(try-action =(+ ?st 5) Turnleft ?r ?c ?p3)
		
		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

(defrule check-step-right (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	(planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction ?dir))
	(incremento 
		(direction ?dir)
		(P5-r ?P5-r) (P5-c ?P5-c)
	)
	(K-cell (pos-r =(+ ?r ?P5-r)) (pos-c =(+ ?c ?P5-c)) (contains Empty|Parking))
	=>
	(assert
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c ?p3)
		(try-action =(+ ?st 1) Forward ?r ?c ?p3)
		(try-action =(+ ?st 2) Turnleft =(+ ?r ?P5-r) =(+ ?c ?P5-c) ?p3)
		(try-action =(+ ?st 3) Turnleft =(+ ?r ?P5-r) =(+ ?c ?P5-c) ?p3)
		(try-action =(+ ?st 4) Forward =(+ ?r ?P5-r) =(+ ?c ?P5-c) ?p3)
		(try-action =(+ ?st 5) Turnright ?r ?c ?p3)
		
		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

(defrule check-step-back (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	(planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction ?dir))
	(incremento 
		(direction ?dir)
		(P6-r ?P6-r (P6-c ?P6-c)
	)
	(K-cell (pos-r =(+ ?r ?P6-r)) (pos-c =(+ ?c ?P6-c)) (contains Empty|Parking))
	=>
	(assert
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c ?p3)
		(try-action =(+ ?st 1) Turnright ?r ?c ?p3)
		(try-action =(+ ?st 2) Forward ?r ?c ?p3)
		(try-action =(+ ?st 3) Turnleft =(+ ?r ?P6-r) =(+ ?c ?P6-c) ?p3)
		(try-action =(+ ?st 4) Turnleft =(+ ?r ?P6-r) =(+ ?c ?P6-c) ?p3)
		(try-action =(+ ?st 5) Forward =(+ ?r ?P6-r) =(+ ?c ?P6-c) ?p3)
		
		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;;;;; Dopo aver posticipato le azioni converto le try-action in planned-action
(defrule convert-giro-tondo (declare (salience 150))
	(route-found)
	?f1 <- (try-action ?st ?oper ?r ?c ?p3)
	=>
	(assert 
		(planned-action (step ?st) (action ?oper) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	)
	(retract ?f1)
)

(defrule del-giro-tondo (declare (salience 145))
	?f1 <- (route-found)
	?f2 <- (try-step)
	?f3 <- (posticipate-exec)
	(not (try-action ?st ?oper ?r ?c ?p3))
	=>
	(retract ?f1 ?f2 ?f3)
	(pop-focus)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////					TERZO STEP	->		REPLANNING					////////////////		
;///////////////////////////////////////////////////////////////////////////////////////////////////
(defrule start-replan-move-action (declare (salience 100))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 3))
	(not (delete-planned-action))
	=>
	(assert (delete-planned-action))
)

(defrule delete-plan (declare (salience 95))
	(not (route-found))
	(status (step ?st))
	(try-step (count 3))
	(delete-planned-action)
	?pa <- (planned-action)
	=>
	(retract ?pa)
)

(defrule replan (declare (salience 90))
	(not (route-found))
	(not (planned-action))
	?f <- (macrostep ?i)
	?mc <- (MacroAction (macrostep ?i) (param1 ?r) (param2 ?c))
	?f1 <- (try-step (count 3))
	=>
	(assert 
		(MacroAction (macrostep =(- ?i 1)) (param1 ?r) (param2 ?c) (oper Move))
		(macrostep =(- ?i 1))
	)
	(retract ?f1 ?f)
	(pop-focus)
)