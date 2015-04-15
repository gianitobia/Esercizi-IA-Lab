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
;////////////////////			ZONA Di Cercasi Table per CheckFinish con anche TB e RB					////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(defrule nearTaFinish_start (declare (salience 20))
	(lookfor Ta)
	=>
	(assert (best_Ta 10000 10000))
)

(defrule nearTaFinish_exec (declare (salience 18))
	(lookfor Ta)
	(K-agent (pos-r ?ra) (pos-c ?ca))
	(Table (table-id ?tid) (pos-r ?rta) (pos-c ?cta))
	(pulisci-table (table-id ?tid))
	?f <- (best_Ta ?rb ?cb)
	(test 
		(> 
			(+ (abs (- ?ra ?rb)) (abs (- ?ca ?cb))) 
			(+ (abs (- ?ra ?rta)) (abs (- ?ca ?cta)))
		)
	)
	=>
	(retract ?f)
	(assert (best_Ta ?rta ?cta ?tid))
)
(defrule nearTBFinish_start (declare (salience 15))
	(lookfor Ta)
	(best_Ta ?rt ?ct)
	=>
	(assert (best_TB 10000 10000))
)

(defrule nearRBFinish_start (declare (salience 15))
	(lookfor Ta)
	(best_Ta ?rt ?ct)
	=>
	(assert (best_RB 10000 10000))
)

(defrule nearTBFinish_exec (declare (salience 18))
	(lookfor Ta)
	(TrashBasket (pos-r ?rtb) (pos-c ?ctb))
	(best_Ta ?rta ?cta ?idta)
	?f <- (best_TB ?rbtb ?cbtb)
	(test 
		(> 
			(+ (abs (- ?rta ?rtb)) (abs (- ?cta ?ctb))) 
			(+ (abs (- ?rta ?rbtb)) (abs (- ?cta ?cbtb)))
		)
	)
	=>
	(retract ?f)
	(assert (best_TB ?rtb ?ctb))
)

(defrule nearRBFinish_exec (declare (salience 18))
	(lookfor Ta)
	(RecyclableBasket (pos-r ?rrb) (pos-c ?crb))
	(best_Ta ?rta ?cta ?idta)
	?f <- (best_RB ?rbrb ?cbrb)
	(test 
		(> 
			(+ (abs (- ?rta ?rrb)) (abs (- ?cta ?crb))) 
			(+ (abs (- ?rta ?rbrb)) (abs (- ?cta ?cbrb)))
		)
	)
	=>
	(retract ?f)
	(assert (best_RB ?rrb ?crb))
)

(defrule bestChoiceFinishTB (declare (salience 16))
	(lookfor Ta)
	(best_Ta ?rta ?cta ?idta)
	(best_RB ?rbrb ?cbrb)
	(best_TB ?rbtb ?cbtb)
	(test 
		(> 
			(+ (abs (- ?rta ?rbrb)) (abs (- ?cta ?cbrb))) 
			(+ (abs (- ?rta ?rbtb)) (abs (- ?cta ?cbtb)))
		)
	)
	=>
	(assert (best-choice TB))
)

(defrule bestChoiceFinishRB (declare (salience 16))
	(lookfor Ta)
	(best_Ta ?rta ?cta ?idta)
	(best_RB ?rbrb ?cbrb)
	(best_TB ?rbtb ?cbtb)
	(test 
		(>  
			(+ (abs (- ?rta ?rbtb)) (abs (- ?cta ?cbtb)))
			(+ (abs (- ?rta ?rbrb)) (abs (- ?cta ?cbrb)))
		)
	)
	=>
	(assert (best-choice RB))
)

(defrule bestTBIfChoiceRBStart (declare (salience 14))
	(lookfor Ta)
	(best-choice RB)
	(best_RB ?rbrb ?cbrb)
	?f<-(best_TB ?rbtb ?cbtb)
	=>
	(assert (best_TB 10000 10000))
)

(defrule bestRBIfChoiceTBStart (declare (salience 14))
	(lookfor Ta)
	(best-choice TB)
	(best_TB ?rbrb ?cbrb)
	?f<-(best_RB ?rbtb ?cbtb)
	=>
	(assert (best_RB 10000 10000))
)

(defrule bestTBIfChoiceRBExec (declare (salience 12))
	(lookfor Ta)
	(TrashBasket (pos-r ?rtb) (pos-c ?ctb))
	(best_RB ?rbrb ?cbrb)
	?f <- (best_TB ?rbtb ?cbtb)
	(test 
		(> 
			(+ (abs (- ?rbrb ?rtb)) (abs (- ?cbrb ?ctb))) 
			(+ (abs (- ?rbrb ?rbtb)) (abs (- ?cbrb ?cbtb)))
		)
	)
	=>
	(retract ?f)
	(assert (best_TB ?rtb ?ctb))
)

(defrule bestRBIfChoiceTBExec (declare (salience 12))
	(lookfor Ta)
	(RecyclableBasket (pos-r ?rrb) (pos-c ?crb))
	(best_TB ?rbtb ?cbtb)
	?f <- (best_RB ?rbrb ?cbrb)
	(test 
		(> 
			(+ (abs (- ?rbtb ?rrb)) (abs (- ?cbtb ?crb))) 
			(+ (abs (- ?rbtb ?rbrb)) (abs (- ?cbtb ?cbrb)))
		)
	)
	=>
	(retract ?f)
	(assert (best_RB ?rrb ?crb))
)

(defrule nearTaFinish_end (declare (salience 8))
	?f <- (lookfor Ta)
	(best_FD ?rta ?cta ?tid)
	(best_RB ?rbrb ?cbrb)
	(best_TB ?rbtb ?cbtb)
	=>
	(retract ?f)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////					ZONA Di Cercasi TrashBasket										////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(defrule nearTB_start (declare (salience 12))
	(lookfor TB)
	(best )
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