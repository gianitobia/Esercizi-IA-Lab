(defmodule ORDER_MANAGEMENT (import PLANNER ?ALL) (export ?ALL))

;regola che converte tutti gli ordini di checkFinish in una sequenza di MacroAction
(defrule rec_message_finish (declare (salience 44))
	?f <- (createMacro)
	?o <- (pulisci-table (table-id ?tb))
	(K-cell (pos-r ?rtr) (pos-c ?ctr) (contains TB))				;da modificare quando ci saranno piu di trash basket
	(K-cell (pos-r ?rr) (pos-c ?cr) (contains RB)) 					;da modificare quando ci saranno piu di un recyclable basket
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 2) (oper CleanTable) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rtr) (param2 ?ctr))
		(MacroAction (macrostep 4) (oper EmptyFood) (param1 ?rtr) (param2 ?ctr))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rr) (param2 ?cr))
		(MacroAction (macrostep 6) (oper Release) (param1 ?rr) (param2 ?cr))
		(macrostep 1)
	)
)

;regola che converte tutti gli ordini di Order con numero di porzione di cibi pari a 0 in una sequenza di MacroAction
(defrule rec_message_order1 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nf 0))
	(K-cell (pos-r ?rd) (pos-c ?cd) (contains DD)) 		;da modificare quando ci saranno piu di un drink dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 4) (oper DeliveryDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(macrostep 1)
	)
)

;regola che converte tutti gli ordini di Order con numero di porzione di bevande pari a 0 in una sequenza di MacroAction
(defrule rec_message_order2 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nd 0))
	(K-cell (pos-r ?rf) (pos-c ?cf) (contains FD))		;da modificare quando ci saranno piu di food dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rf) (param2 ?cf))
		(MacroAction (macrostep 2) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf))				
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 4) (oper DeliveryFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
		(macrostep 1)
	)
)

;regola che converte tutti gli ordini di Order con numero di porzione di cibi e bevande diverso da 0 in una sequenza di MacroAction
(defrule rec_message_order3_plus4 (declare (salience 10))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (drink ?nd) (food ?nf))
	(K-cell (pos-r ?rf) (pos-c ?cf) (contains FD))	;da modificare quando ci saranno piu di food dispenser
	(K-cell (pos-r ?rd) (pos-c ?cd) (contains DD)) ;da modificare quando ci saranno piu di un drink dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	(test (> (+ ?nd ?nf) 4))
	=>
	(retract ?f ?o)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 6) (oper DeliveryDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rf) (param2 ?cf))
		(MacroAction (macrostep 4) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 7) (oper DeliveryFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
		(macrostep 1)
	)
)

(defrule rec_message_order3 (declare (salience 10))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (drink ?nd) (food ?nf))
	(K-cell (pos-r ?rf) (pos-c ?cf) (contains FD))	;da modificare quando ci saranno piu di food dispenser
	(K-cell (pos-r ?rd) (pos-c ?cd) (contains DD)) ;da modificare quando ci saranno piu di un drink dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o)
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