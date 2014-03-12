(deffacts fatti1
	(plane p1)  
	(plane p2)
	(airport Roma)	
	(airport Parigi)
	(airport Vienna)
	(cargo c1)
	(cargo c2)
	(cargo c3)
	(is-in c1 Parigi)	
	(is-in c2 Roma)
	(is-in c3 Roma)
	(empty p1)	
	(empty p2)
	(at p1 Roma)	
	(at p2 Vienna)
)

(deffacts goal
	(goal p2 Roma c1)
)

(defrule soluzione (declare (salience 1))
	(goal ?p ?a ?c)
	(at ?p ?a)
	(empty ?p)
	(is-in ?c ?a)
	=>
	(printout t "aereo" ?p " scarica " ?c " a " ?a crlf)
	(halt)
)

(defrule move
	(plane ?p)
	(airport ?s)
	(airport ?d)
	(test (neq ?s ?d))
	?f1 <- (at ?p ?s)
	=>	
	(retract ?f1)
	(assert (at ?p ?d))
)


(defrule load
	(plane ?p)
	(airport ?a)
	(cargo ?c)
	(at ?p ?a)
	?f1 <- (is-in ?c ?a)
	?f2 <- (empty ?p)
	=>
	(retract ?f1)
	(retract ?f2)
	(assert (loaded ?c ?p))
)

(defrule unload
	(plane ?p)
	(airport ?a)
	(cargo ?c)
	(at ?p ?a)
	?f1 <- (loaded ?c ?p)
	=>	
	(retract ?f1)
	(assert (is-in ?c ?a) (empty ?p))
)
