;// PLANNER
;Questo modulo si occupa di pianificare le azioni
;che l'agente dovra' eseguire per arrivare ad un dato goal
(defmodule PLANNER (import AGENT ?ALL) (export ?ALL))

;Definizone del template per le azioni pieanificate
(deftemplate planned-move-inv
	(slot step)
	(slot action)		;azioni da far effettuare al robot
	(slot pos_r)		;riga da dove viene effettuata l'azione 
	(slot pos_c) 		;colonna da dove si effettua l'azione
)

(defrule temp (declare (salience 100))
	(planned-goal (pos_r ?goal-r) (pos_c ?goal-c))
	=>
	(assert (goal ?goal-r ?goal-c))
	(focus MOVEMENT)
)

(defrule invert-move-action (declare (salience 99))
	(planned-move-inv
		(step ?curr)
		(action ?act)
		(pos_r ?r)
		(pos_c ?c)
	)
	=>
	(assert (planned-action
					(step ?curr)
					(action ?act)
					(pos_r ?r)
					(pos_c ?c)
			)
	)
)