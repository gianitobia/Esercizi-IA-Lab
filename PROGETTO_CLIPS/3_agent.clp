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






