;// PLANNER
;Questo modulo si occupa di pianificare le azioni
;che l'agente dovra' eseguire per arrivare ad un dato goal
(defmodule PLANNER (import AGENT ?ALL) (export ?ALL))

(defrule temp (declare (salience 100))
	(planned-goal (pos_r ?goal-r) (pos_c ?goal-c))
	=>
	(assert (goal ?goal-r ?goal-c))
	(focus MOVEMENT)
)