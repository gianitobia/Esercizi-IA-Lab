(defmodule MIN_DISTANCE (import ORDER_MANAGEMENT ?ALL) (export ?ALL))

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////					ZONA Di Cercasi FoodDispenser									////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(defrule nearFD_start (declare (salience 12))
	(lookfor FD)
	=>
	(assert (best_FD 10000 10000))
)

(defrule nearFD_exec (declare (salience 10))
	(lookfor FD)
	(K-agent (pos-r ?ra) (pos-c ?ca))
	(FoodDispenser (pos-r ?rfd) (pos-c ?cfd))
	?f <- (best_FD ?rb ?cb)
	(test 
		(> 
			(+ (abs (- ?ra ?rb)) (abs (- ?ca ?cb))) 
			(+ (abs (- ?ra ?rfd)) (abs (- ?ca ?cfd)))
		)
	)
	=>
	(retract ?f)
	(assert (best_FD ?rfd ?cfd))
)

(defrule nearFD_end (declare (salience 8))
	?f <- (lookfor FD)
	(best_FD ?rfd ?cfd)
	=>
	(retract ?f)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////					ZONA Di Cercasi DrinkDispenser									////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(defrule nearDD_start (declare (salience 12))
	(lookfor DD)
	=>
	(assert (best_DD 10000 10000))
)

(defrule nearDD_exec (declare (salience 10))
	(lookfor DD)
	(K-agent (pos-r ?ra) (pos-c ?ca))
	(DrinkDispenser (pos-r ?rdd) (pos-c ?cdd))
	?f <- (best_DD ?rb ?cb)
	(test 
		(> 
			(+ (abs (- ?ra ?rb)) (abs (- ?ca ?cb))) 
			(+ (abs (- ?ra ?rdd)) (abs (- ?ca ?cdd)))
		)
	)
	=>
	(retract ?f)
	(assert (best_DD ?rdd ?cdd))
)

(defrule nearDD_end (declare (salience 8))
	?f <- (lookfor DD)
	(best_DD ?rdd ?cdd)
	=>
	(retract ?f)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////					ZONA Di Cercasi TrashBasket										////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(defrule nearTB_start (declare (salience 12))
	(lookfor TB)
	=>
	(assert (best_TB 10000 10000))
)

(defrule nearTB_exec (declare (salience 10))
	(lookfor TB)
	(K-agent (pos-r ?ra) (pos-c ?ca))
	(TrashBasket (pos-r ?rtb) (pos-c ?ctb))
	?f <- (best_TB ?rb ?cb)
	(test 
		(> 
			(+ (abs (- ?ra ?rb)) (abs (- ?ca ?cb))) 
			(+ (abs (- ?ra ?rtb)) (abs (- ?ca ?ctb)))
		)
	)
	=>
	(retract ?f)
	(assert (best_TB ?rtb ?ctb))
)

(defrule nearTB_end (declare (salience 8))
	?f <- (lookfor TB)
	(best_TB ?rtb ?ctb)
	=>
	(retract ?f)
)


;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////					ZONA Di Cercasi RecyclableBasket								////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(defrule nearRB_start (declare (salience 12))
	(lookfor RB)
	=>
	(assert (best_RB 10000 10000))
)

(defrule nearRB_exec (declare (salience 10))
	(lookfor RB)
	(K-agent (pos-r ?ra) (pos-c ?ca))
	(RecyclableBasket (pos-r ?rrb) (pos-c ?crb))
	?f <- (best_RB ?rb ?cb)
	(test 
		(> 
			(+ (abs (- ?ra ?rb)) (abs (- ?ca ?cb))) 
			(+ (abs (- ?ra ?rrb)) (abs (- ?ca ?crb)))
		)
	)
	=>
	(retract ?f)
	(assert (best_RB ?rrb ?crb))
)

(defrule nearRB_end (declare (salience 8))
	?f <- (lookfor RB)
	(best_RB ?rrb ?crb)
	=>
	(retract ?f)
)