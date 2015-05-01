
(defmodule EVITA-PERSONA (import AGENT ?ALL) (export ?ALL))

(deftemplate pos
	(slot c)
	(slot r)
)

(deftemplate incremento
	(slot direction)
	(slot pos)
)

(deffacts increments
	(incremento (direction north) (pos (c 0) (r 1)))
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
(defrule primo-tentativo-wait-begin-V1 (declare (salience 100))
	(not (try-step))
	(status (step ?st))
	=>
	(assert 
		(posticipate 1)
		(try-step (count 1) (step ?st))
	)
	(focus POSTICIPATE)
)

(defrule primo-tentativo-wait-begin-V2 (declare (salience 100))
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
(defrule primo-tentativo-wait-end (declare (salience 100))
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

;Direction = nord;  v1 = left - up - right
(defrule check-giro-tondo-north-V1 (declare (salience 100))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction north))
	(K-cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking))
	(K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (contains Empty|Parking))
	
	=> ;percorso fattibile
	(retract ?f2)
	(assert 
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnleft) (pos_r =(+ ?r 1)) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnright ?r =(- ?c 1) p3)
		(try-action =(+ ?st 3) Forward ?r =(- ?c 1) p3)
		(try-action =(+ ?st 4) Turnright =(+ ?r 1) =(- ?c 1) p3)
		(try-action =(+ ?st 5) Forward =(+ ?r 1) =(- ?c 1) p3)

		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = nord;  v2 = right - up - left
(defrule check-giro-tondo-north-V2 (declare (salience 100))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction north))
	(K-cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	(K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnright) (pos_r =(+ ?r 1)) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnleft ?r =(+ ?c 1) p3)
		(try-action =(+ ?st 3) Forward ?r =(+ ?c 1) p3)
		(try-action =(+ ?st 4) Turnleft =(+ ?r 1) =(+ ?c 1) p3)				;;controllare
		(try-action =(+ ?st 5) Forward =(+ ?r 1) =(+ ?c 1) p3)

		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)



;Direction = est;  v1 = up - right - down
(defrule check-giro-tondo-east-V1 (declare (salience 100))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction east))
	(K-cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking))
	(K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnleft) (pos_r ?r) (pos_c =(+ ?c 1)) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnright =(+ ?r 1) ?c p3)
		(try-action =(+ ?st 3) Forward =(+ ?r 1) ?c p3)
		(try-action =(+ ?st 4) Turnright =(+ ?r 1) =(+ ?c 1) p3)
		(try-action =(+ ?st 5) Forward =(+ ?r 1) =(+ ?c 1) p3)

		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = est;  v2 = down - right - up
(defrule check-giro-tondo-east-V2 (declare (salience 100))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction east))
	(K-cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking))
	(K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnright) (pos_r ?r) (pos_c =(+ ?c 1)) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnleft =(- ?r 1) ?c p3)
		(try-action =(+ ?st 3) Forward =(- ?r 1) ?c p3)
		(try-action =(+ ?st 4) Turnleft =(- ?r 1) =(+ ?c 1) p3)
		(try-action =(+ ?st 5) Forward =(- ?r 1) =(+ ?c 1) p3)

		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)



;Direction = south;  v1 = right - down - left
(defrule check-giro-tondo-south-V1 (declare (salience 100))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction south))
	(K-cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	(K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnleft) (pos_r =(- ?r 1)) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnright ?r =(+ ?c 1) p3)
		(try-action =(+ ?st 3) Forward ?r =(+ ?c 1) p3)
		(try-action =(+ ?st 4) Turnright =(- ?r 1) =(+ ?c 1) p3)
		(try-action =(+ ?st 5) Forward =(- ?r 1) =(+ ?c 1) p3)

		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)
	
;Direction = south;  v2 = left - down - right
(defrule check-giro-tondo-south-V2 (declare (salience 100))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction south))
	(K-cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking))
	(K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnright) (pos_r =(- ?r 1)) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnleft ?r =(- ?c 1) p3)
		(try-action =(+ ?st 3) Forward ?r =(- ?c 1) p3)
		(try-action =(+ ?st 4) Turnleft =(- ?r 1) =(- ?c 1) p3)
		(try-action =(+ ?st 5) Forward =(- ?r 1) =(- ?c 1) p3)

		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)



;Direction = west;  v1 = down - left - up
(defrule check-giro-tondo-west-V1 (declare (salience 100))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction west))
	(K-cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking))
	(K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnleft) (pos_r ?r) (pos_c =(- ?c 1)) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnright =(- ?r 1) ?c p3)
		(try-action =(+ ?st 3) Forward =(- ?r 1) ?c p3)
		(try-action =(+ ?st 4) Turnright =(- ?r 1) =(- ?c 1) p3)
		(try-action =(+ ?st 5) Forward =(- ?r 1) =(- ?c 1) p3)

		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = west;  v2 = up - left - down
(defrule check-giro-tondo-west-V2 (declare (salience 100))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction west))
	(K-cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking))
	(K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (contains Empty|Parking))

	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnright) (pos_r ?r) (pos_c =(- ?c 1)) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnleft =(+ ?r 1) ?c p3)
		(try-action =(+ ?st 3) Forward =(+ ?r 1) ?c p3)
		(try-action =(+ ?st 4) Turnleft =(+ ?r 1) =(- ?c 1) p3)
		(try-action =(+ ?st 5) Forward =(+ ?r 1) =(- ?c 1) p3)

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

;Direction = west;  v1 = down - up
(defrule check-step-left-west (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction west))
	(K-cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnleft) (pos_r ?r) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnright =(- ?r 1) ?c p3)
		(try-action =(+ ?st 3) Turnright =(- ?r 1) ?c p3)
		(try-action =(+ ?st 4) Forward =(- ?r 1) ?c p3)

		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = west;  v2 = up - down
(defrule check-step-right-west (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction west))
	(K-cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnright) (pos_r ?r) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnleft =(+ ?r 1) ?c p3)
		(try-action =(+ ?st 3) Turnleft =(+ ?r 1) ?c p3)
		(try-action =(+ ?st 4) Forward =(+ ?r 1) ?c p3)

		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = west;  v2 = right - left
(defrule check-step-back-west (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction west))
	(K-cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c =(+ ?c 1)) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Turnright ?r ?c p3)
		(try-action =(+ ?st 2) Forward ?r ?c p3)
		(try-action =(+ ?st 3) Turnleft ?r =(+ ?c 1) p3)
		(try-action =(+ ?st 4) Turnleft ?r =(+ ?c 1) p3)
		
		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = south;  v1 = right - left
(defrule check-step-left-south (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction south))
	(K-cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnleft) (pos_r ?r) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnright ?r =(+ ?c 1) p3)
		(try-action =(+ ?st 3) Turnright ?r =(+ ?c 1) p3)
		(try-action =(+ ?st 4) Forward ?r =(+ ?c 1) p3)
		
		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)
	
;Direction = south;  v2 = left - right
(defrule check-step-right-south (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction south))
	(K-cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnright) (pos_r ?r) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnleft ?r =(- ?c 1) p3)
		(try-action =(+ ?st 3) Turnleft ?r =(- ?c 1) p3)
		(try-action =(+ ?st 4) Forward ?r =(- ?c 1) p3)

		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = south;  v2 = up - down
(defrule check-step-back-south (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction south))
	(K-cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Forward) (pos_r =(+ ?r 1)) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Turnright ?r ?c p3)
		(try-action =(+ ?st 2) Forward ?r ?c p3)
		(try-action =(+ ?st 3) Turnleft =(+ ?r 1) ?c p3)
		(try-action =(+ ?st 4) Turnleft =(+ ?r 1) ?c p3)
		

		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)


;Direction = nord;  v1 = left - right
(defrule check-step-left-north (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction north))
	(K-cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking))
	
	=> ;percorso fattibile
	(retract ?f2)
	(assert 
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnleft) (pos_r ?r) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnright ?r =(- ?c 1) p3)
		(try-action =(+ ?st 3) Turnright ?r =(- ?c 1) p3)
		(try-action =(+ ?st 4) Forward ?r =(- ?c 1) p3)

		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = nord;  v2 = right - left
(defrule check-step-right-north(declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction north))
	(K-cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnright) (pos_r ?r) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnleft ?r =(+ ?c 1) p3)
		(try-action =(+ ?st 3) Turnleft ?r =(+ ?c 1) p3)
		(try-action =(+ ?st 4) Forward ?r =(+ ?c 1) p3)
		
		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = nord;  v2 = down - up
(defrule check-step-back-north (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction north))
	(K-cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Forward) (pos_r =(- ?r 1)) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Turnright ?r ?c p3)
		(try-action =(+ ?st 2) Forward ?r ?c p3)
		(try-action =(+ ?st 3) Turnleft =(- ?r 1) ?c p3)
		(try-action =(+ ?st 4) Turnleft =(- ?r 1) ?c p3)
		
		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = est;  v1 = up - down
(defrule check-step-left-east (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction east))
	(K-cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Turnleft) (pos_r ?r) (pos_c ?c) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnleft ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnright =(+ ?r 1) ?c p3)
		(try-action =(+ ?st 3) Turnright =(+ ?r 1) ?c p3)
		(try-action =(+ ?st 4) Forward =(+ ?r 1) ?c p3)
		
		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = est;  v2 = down - up
(defrule check-step-right-east (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	(planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction east))
	(K-cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
				
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Forward ?r ?c p3)
		(try-action =(+ ?st 2) Turnleft =(- ?r 1) ?c p3)
		(try-action =(+ ?st 3) Turnleft =(- ?r 1) ?c p3)
		(try-action =(+ ?st 4) Forward =(- ?r 1) ?c p3)
		(try-action =(+ ?st 5) Turnright ?r ?c p3)
		
		;asserisco di posticipare
		(posticipate 6)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;Direction = est;  v2 = left - right
(defrule check-step-back-east (declare (salience 110))
	(not (route-found))
	(status (step ?st))
	?f1 <- (try-step (count 2))
	?f2 <- (planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	(K-agent (pos-r ?r) (pos-c ?c) (direction east))
	(K-cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking))
	
	=>
	(retract ?f2)
	(assert
		;asserisco l'ultima azione come planned-action dello stato in cui sono xke mi serve per
		;il posticipate, xke diventera' lultima azione da fare dopo aver posticipate tutte le altre
		(planned-action (step ?st) (action Forward) (pos_r ?r) (pos_c =(- ?c 1)) (param3 ?p3))
		
		;azioni per compiere il percorso alternativo
		(try-action ?st Turnright ?r ?c p3)
		(try-action =(+ ?st 1) Turnright ?r ?c p3)
		(try-action =(+ ?st 2) Forward ?r ?c p3)
		(try-action =(+ ?st 3) Turnleft ?r =(- ?c 1) p3)
		(try-action =(+ ?st 4) Turnleft ?r =(- ?c 1) p3)
		
		;asserisco di posticipare
		(posticipate 5)
		
		;asserisco di aver trovato un percorso
		(route-found)
	)
	(modify ?f1 (count 3))
	(focus POSTICIPATE)
)

;;;;; Dopo aver posticipato le azioni converto le try-action in planned-action
(defrule convert-giro-tondo (declare (salience 120))
	(route-found)
	?f1 <- (try-action ?st ?oper ?r ?c ?p3)
	=>
	(assert 
		(planned-action (step ?st) (action ?oper) (pos_r ?r) (pos_c ?c) (param3 ?p3))
	)
	(retract ?f1)
)

(defrule del-giro-tondo (declare (salience 115))
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