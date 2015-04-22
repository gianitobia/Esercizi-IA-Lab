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
	(lookfor Ta ?ra ?ca)
	=>
	(assert (best_Ta 10000 10000 nullo))
)

(defrule nearTaFinish_exec1 (declare (salience 18))
	(lookfor Ta ?ra ?ca)
	(pulisci-table (table-id ?tid))
	(Table (table-id ?tid) (pos-r ?rta) (pos-c ?cta))
	?f <- (best_Ta ?rb ?cb ?id)
	(ordine-servito ?tid ?nd ?nf)
	(test 
		(> 
			(+ (abs (- ?ra ?rb)) (abs (- ?ca ?cb))) 
			(+ (abs (- ?ra ?rta)) (abs (- ?ca ?cta)))
		)
	)
	(test (= ?nd 0))
	=>
	(retract ?f)
	(assert 
		(best_Ta ?rta ?cta ?tid)
		(butta-food)
	)
)

(defrule nearTaFinish_exec2 (declare (salience 18))
	(lookfor Ta ?ra ?ca)
	(pulisci-table (table-id ?tid))
	(Table (table-id ?tid) (pos-r ?rta) (pos-c ?cta))
	?f <- (best_Ta ?rb ?cb ?id)
	(ordine-servito ?tid ?nd ?nf)
	(test 
		(> 
			(+ (abs (- ?ra ?rb)) (abs (- ?ca ?cb))) 
			(+ (abs (- ?ra ?rta)) (abs (- ?ca ?cta)))
		)
	)
	(test (= ?nf 0))
	=>
	(retract ?f)
	(assert 
		(best_Ta ?rta ?cta ?tid)
		(butta-drink)
	)
)

(defrule nearTaFinish_exec3 (declare (salience 16))
	(lookfor Ta ?ra ?ca)
	(pulisci-table (table-id ?tid))
	(Table (table-id ?tid) (pos-r ?rta) (pos-c ?cta))
	?f <- (best_Ta ?rb ?cb ?id)
	(ordine-servito ?tid ?nd ?nf)
	(test 
		(> 
			(+ (abs (- ?ra ?rb)) (abs (- ?ca ?cb))) 
			(+ (abs (- ?ra ?rta)) (abs (- ?ca ?cta)))
		)
	)
	=>
	(retract ?f)
	(assert 
		(best_Ta ?rta ?cta ?tid)
		(butta-food)
		(butta-drink)
	)
)

(defrule nearTaFinish_end (declare (salience 8))
	?f <- (lookfor Ta ?ra ?ca)
	(best_Ta ?rtb ?ctb)
	=>
	(retract ?f)
)


;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////					ZONA Di Cercasi TrashBasket										////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(defrule nearTB_start (declare (salience 12))
	(lookfor TB ?sR ?sC)
	=>
	(assert (best_TB 10000 10000))
)

(defrule nearTB_exec (declare (salience 10))
	(lookfor TB ?ra ?ca)
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
	?f <- (lookfor TB ?sR ?sC)
	(best_TB ?rtb ?ctb)
	=>
	(retract ?f)
)


;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////					ZONA Di Cercasi RecyclableBasket								////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(defrule nearRB_start (declare (salience 12))
	(lookfor RB ?sR ?sC)
	=>
	(assert (best_RB 10000 10000))
)

(defrule nearRB_exec (declare (salience 10))
	(lookfor RB ?ra ?ca)
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
	?f <- (lookfor RB ?sR ?sC)
	(best_RB ?rrb ?crb)
	=>
	(retract ?f)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////					ZONA Di Cercasi RecyclableBasket e TrashBasket					/////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(defrule nearRB_start (declare (salience 12))
	(lookfor TB-RB ?sR ?sC)
	=>
	(assert 
		(best_RB 10000 10000)
		(best_TB 10000 10000)
	)
)






