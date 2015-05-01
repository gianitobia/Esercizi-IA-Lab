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