(defmodule ORDER_MANAGEMENT (import PLANNER ?ALL) (export ?ALL))

;regola che converte tutti gli ordini di checkFinish in una sequenza di MacroAction
(defrule rec_finish_lookfor (declare (salience 44))
	?f <- (createMacro)
	?o <- (pulisci-table (table-id ?tb))
	=>
	(assert (lookfor Ta))
	(focus MIN_DISTANCE)
)

(defrule rec_message_finishTB (declare (salience 44))
	?f <- (createMacro)
	?b1 <- (best_TB ?rtb ?ctb)
	?b2 <- (best_RB ?rrb ?crb)
	?b3 <- (best_Ta ?rta ?cta ?idta)
	?bc <- (best-choice TB)
	(Table (table-id ?idta) (pos-r ?rta) (pos-c ?cta))
	?o <- (pulisci-table (table-id ?idta))
	=>
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rta) (param2 ?cta))
		(MacroAction (macrostep 2) (oper CleanTable) (param1 ?rta) (param2 ?cta))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rtb) (param2 ?ctb))
		(MacroAction (macrostep 4) (oper EmptyFood) (param1 ?rtb) (param2 ?ctb))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rrb) (param2 ?crb))
		(MacroAction (macrostep 6) (oper Release) (param1 ?rrb) (param2 ?crb))
		(macrostep 1)
	)
	(retract ?f ?o ?b1 ?b2 ?b3 ?bc)
)

(defrule rec_message_finishRB (declare (salience 44))
	?f <- (createMacro)
	?b1 <- (best_TB ?rtb ?ctb)
	?b2 <- (best_RB ?rrb ?crb)
	?b3 <- (best_Ta ?rta ?cta ?idta)
	?bc <- (best-choice RB)
	(Table (table-id ?idta) (pos-r ?rta) (pos-c ?cta))
	?o <- (pulisci-table (table-id ?idta))
	=>
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rta) (param2 ?cta))
		(MacroAction (macrostep 2) (oper CleanTable) (param1 ?rta) (param2 ?cta))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rrb) (param2 ?crb))
		(MacroAction (macrostep 4) (oper Release) (param1 ?rrb) (param2 ?crb))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rtb) (param2 ?ctb))
		(MacroAction (macrostep 6) (oper EmptyFood) (param1 ?rtb) (param2 ?ctb))
		(macrostep 1)
	)
	(retract ?f ?o ?b1 ?b2 ?b3 ?bc)
)

;regola che converte tutti gli ordini di Order con numero di porzione di cibi pari a 0 in una sequenza di MacroAction
(defrule rec_order_lookfor1 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nf 0))
	=>
	(assert (lookfor DD))
	(focus MIN_DISTANCE)
)

(defrule rec_order_createMacro1 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nf 0))
	?b <- (best_DD ?rd ?cd) 		;da modificare quando ci saranno piu di un drink dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o ?b)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 4) (oper DeliveryDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(macrostep 1)
	)
)

;regola che converte tutti gli ordini di Order con numero di porzione di bevande pari a 0 in una sequenza di MacroAction
(defrule rec_order_lookfor2 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nd 0))
	=>
	(assert (lookfor FD))
	(focus MIN_DISTANCE)
)

(defrule rec_message_createMacro2 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nd 0))
	?b <- (best_FD ?rf ?cf) 		;da modificare quando ci saranno piu di food dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o ?b)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rf) (param2 ?cf))
		(MacroAction (macrostep 2) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf))				
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 4) (oper DeliveryFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
		(macrostep 1)
	)
)

;regola che converte tutti gli ordini di Order con numero di porzione di cibi e bevande diverso da 0 in una sequenza di MacroAction
(defrule rec_order_lookfor3 (declare (salience 10))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	=>
	(assert (lookfor FD) (lookfor DD))
	(focus MIN_DISTANCE)
)

(defrule rec_message_createMacro3_plus4 (declare (salience 10))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (drink ?nd) (food ?nf))
	?b1 <- (best_FD ?rf ?cf)	
	?b2 <- (best_DD ?rd ?cd) 	
	(test (> (+ ?nd ?nf) 4))
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o ?b1 ?b2)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 6) (oper DeliveryDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rf) (param2 ?cf))
		(MacroAction (macrostep 4) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 7) (oper DeliveryFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
		(Macrostep (step 1))
	)
)

(defrule rec_message_createMacro3 (declare (salience 8))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (drink ?nd) (food ?nf))
	?b1 <- (best_FD ?rf ?cf)	
	?b2 <- (best_DD ?rd ?cd) 	
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o ?b1 ?b2)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rf) (param2 ?cf))
		(MacroAction (macrostep 4) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 6) (oper DeliveryDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(MacroAction (macrostep 7) (oper DeliveryFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
		(macrostep 1)
	)
)


;Da aggiungere le regole per generare piu` macroaction in modo da poter prendere e consegnare piu` bevande e drink