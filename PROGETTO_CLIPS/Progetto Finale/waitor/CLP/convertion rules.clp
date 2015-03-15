(deftemplate MacroAction
	(slot macrostep)
	(slot oper (allowed-values Move LoadDrink LoadFood))
	(slot param1)
	(slot param2)
	(slot param3)
)

(defrule rec_message_finish (declare (salience x+4))
	
)

(defrule rec_message_order (declare (salience x+2))
	(msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order)
    							  (drink-order ?nd) (food-order ?nf))
	(test (> ?nd 0))
	(test (> ?nf 0))
	(K-cell (pos-r ?rf) (pos-c ?cf) (contains FD))	;da modificare quando ci saranno piu di food dispenser
	(K-cell (pos-r ?rd) (pos-c ?cd) (contains DD)) ;da modificare quando ci saranno piu di un drink dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd)))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rf) (param2 ?cf)))
		(MacroAction (macrostep 4) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf)))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rt) (param2 ?ct)))
		(MacroAction (macrostep 6) (oper ReleaseDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(MacroAction (macrostep 7) (oper ReleaseFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
	)
)

(defrule rec_message_order (declare (salience x))
	(msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order)
    							  (drink-order ?nd) (food-order ?nf))
	(test (> ?nd 0))
	(K-cell (pos-r ?rd) (pos-c ?cd) (contains DD)) ;da modificare quando ci saranno piu di un drink dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd)))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct)))
		(MacroAction (macrostep 4) (oper ReleaseDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
	)
)

(defrule rec_message_order (declare (salience x))
	(msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order)
    							  (drink-order ?nd) (food-order ?nf))
	(test (> ?nf 0))
	(K-cell (pos-r ?rf) (pos-c ?cf) (contains FD))	;da modificare quando ci saranno piu di food dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rf) (param2 ?cf)))
		(MacroAction (macrostep 2) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf)))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct)))
		(MacroAction (macrostep 4) (oper ReleaseFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
	)
)