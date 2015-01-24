;// AGENT

(defmodule AGENT (import MAIN ?ALL)(export ?ALL))


(deftemplate K-cell
	(slot pos-r) 
	(slot pos-c) 
    (slot contains (allowed-values 	Wall 
									Person  
									Empty 
									Parking 
									Table 
									Seat 
									TrashBasket
                                    RecyclableBasket 
									DrinkDispenser 
									FoodDispenser
					)
	)
)



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
 
(defrule beginagent2	(declare (salience 11))
    (status (step 0))
    (not (exec (step 0)))
    (initial_agentposition (pos-r ?r) (pos-c ?c) (direction ?d))
=> 
    (assert (K-agent 
				(step 0) 
				(time 0) 
				(pos-r ?r) 
				(pos-c ?c) 
				(direction ?d)
                (l-drink 0) 
				(l-food 0) 
				(l_d_waste no) 
				(l_f_waste no)
			)
	)
)

;Imposto il goal  ---> Dovra' essere pianificato in planner il goal da eseguire
(defrule ask-plan (declare (salience 4))
	?f <- (status (step ?i))
	(not (planned-action $?))
	(not (planned-goal $?))
	=>
	(printout t crlf crlf " == AGENT ==" crlf) 
	(printout t "Give me a goal to plan and exec (planned-goal ROW COL)" crlf)
	(assert (planned-goal 3 9))
	(modify ?f (result no))
)

;Pianifico i passi per arrivare al goal
(defrule start-plannig	(declare (salience 3))
	(status (step ?i) (time ?t))
	(K-agent (pos-r ?r) (pos-c ?c))
	(planned-goal ?goal-r ?goal-c)
	=>
	(printout t crlf " == AGENT ==" crlf)
	(printout t "Starting to plan (" ?r ", "?c ") --> (" ?goal-r ", "?goal-c ")" crlf crlf)
	(assert (printGUI (time ?t) 							;Per usare la console di stampa
					  (step ?i) 
					  (source "AGENT") (verbosity 2) 
					  (text  "Starting to plan: (%p1, %p2) --> (%p3, %p4)") 
					  (param1 ?r) 
					  (param2 ?c) 
					  (param3 ?goal-r)
					  (param4 ?goal-c)
			)
	)
    (assert (something-to-plan)) ; Avvisa il planner che deve pianificare
    (focus PLANNER)
)




(defrule ask_act
	?f <- (status (step ?i))
    =>  
	(printout t crlf crlf)
    (printout t "action to be executed at step:" ?i)
    (printout t crlf crlf)
	(modify ?f (result no))
)

(defrule exec_act
    (status (step ?i))
    (exec (step ?i))
 	=> 
	(focus MAIN)
)






