(defmodule ORDER_MANAGEMENT (import PLANNER ?ALL) (export ?ALL))

(defrule rec_message_finish (declare (salience 14))
	?f <- (createMacro)
	(coda-ordini (time ?t) (step ?i) (sender ?tb) (tipo finish))
	(K-cell (pos-r ?rtr) (pos-c ?ctr) (contains TB))	;da modificare quando ci saranno piu di trash basket
	(K-cell (pos-r ?rr) (pos-c ?cr) (contains RB)) ;da modificare quando ci saranno piu di un recyclable basket
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 2) (oper CheckFinish) (param1 ?rt) (param2 ?ct))
		(macrostep 1)
	)
)

(defrule rec_message_order1 (declare (salience 12))
	?f <- (createMacro)
	(coda-ordini (time ?t) (step ?i) (sender ?tb) (tipo order)
    							  (drink ?nd) (food ?nf))
	(test (= ?nf 0))
	(K-cell (pos-r ?rd) (pos-c ?cd) (contains DD)) ;da modificare quando ci saranno piu di un drink dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd)))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct)))
		(MacroAction (macrostep 4) (oper ReleaseDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(macrostep 1)
	)
)

(defrule rec_message_order2 (declare (salience 12))
	?f <- (createMacro)
	(coda-ordini (time ?t) (step ?i) (sender ?tb) (tipo order)
    							  (drink ?nd) (food ?nf))
	(test (= ?nd 0))
	(K-cell (pos-r ?rf) (pos-c ?cf) (contains FD))	;da modificare quando ci saranno piu di food dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rf) (param2 ?cf)))
		(MacroAction (macrostep 2) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf)))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct)))
		(MacroAction (macrostep 4) (oper ReleaseFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
		(macrostep 1)
	)
)

(defrule rec_message_order3 (declare (salience 10))
	?f <- (createMacro)
	(coda-ordini (time ?t) (step ?i) (sender ?tb) (tipo order)
    							  (drink ?nd) (food ?nf))
	(K-cell (pos-r ?rf) (pos-c ?cf) (contains FD))	;da modificare quando ci saranno piu di food dispenser
	(K-cell (pos-r ?rd) (pos-c ?cd) (contains DD)) ;da modificare quando ci saranno piu di un drink dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd)))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rf) (param2 ?cf)))
		(MacroAction (macrostep 4) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf)))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rt) (param2 ?ct)))
		(MacroAction (macrostep 6) (oper ReleaseDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(MacroAction (macrostep 7) (oper ReleaseFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
		(macrostep 1)
	)
)