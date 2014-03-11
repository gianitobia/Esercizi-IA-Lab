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

(defrule unloaded
	(plane ?p)
	?f1 <- (airport ?s)
	(airport ?d)
	(airport ?d &:(nq ?s ?d))
	(at ?p ?s)
	=>
	(assert (at ?p ?d))
	(retract ?f1)
)