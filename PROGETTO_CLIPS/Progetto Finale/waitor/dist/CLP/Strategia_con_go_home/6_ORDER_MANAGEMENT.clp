(defmodule ORDER_MANAGEMENT (import PLANNER ?ALL) (export ?ALL))


;regola che inizia la ricerca dei tavoli da pulire dichiarando come target la posizione dell'agent
(defrule rec_finish_startlookfor (declare (salience 44))
	?f <- (createMacro)
	?o <- (pulisci-table (table-id ?tb))
	(K-agent (pos-r ?ra) (pos-c ?ca))
	=>
	(assert 
		(lookfor Ta ?ra ?ca)
		(counter 1)
	)
	(focus MIN_DISTANCE)
)

;regola che converte il fatto best-table in macro-action per pulirlo
(defrule rec_finish_macro (declare (salience 44))
	?f <- (createMacro)
	(best_Ta ?rta ?cta ?idta)
	(Table (table-id ?idta) (pos-r ?rta) (pos-c ?cta))
	?o <- (pulisci-table (table-id ?idta))
	?c <- (counter ?count)
	?os <- (ordine-servito ?idta ?nd ?nf)
	(not (table-found))
	=>
	(assert 
		(MacroAction (macrostep ?count) (oper Move) (param1 ?rta) (param2 ?cta))
		(MacroAction (macrostep =(+ ?count 1)) (oper CleanTable) (param1 ?rta) (param2 ?cta))
		(counter =(+ ?count 2))
		(table-found)
	)
	(retract ?o ?c ?os)
)

;regola che dopo asserito le macro-action di pulizia di un tavolo, rifa partire la ricerca di un miglior tavolo se ci sono altri tavoli da pulire dando come target il tavolo appena pulito (quindi best-table)
(defrule rec_finish_repeatlookfor (declare (salience 42))
	?f <- (createMacro)
	?o <- (pulisci-table (table-id ?tb))
	?b3 <- (best_Ta ?rta ?cta ?idta)
	?tf <- (table-found)
	=>
	(assert (lookfor Ta ?rta ?cta))
	(retract ?b3 ?tf)
	(focus MIN_DISTANCE)
)

(defrule rec_finish_lookforTrashBaskets (declare (salience 40))
	?f <- (createMacro)
	(not (pulisci-table))
	?b3 <- (best_Ta ?rta ?cta ?idta)
	?bf <- (butta-food)
	(not (butta-drink))
	?tf <- (table-found)
	=>
	(assert (lookfor TB ?rta ?cta))
	(retract ?bf ?tf ?b3)
	(focus MIN_DISTANCE)
)
(defrule rec_finish_lookforRecyclableBaskets (declare (salience 40))
	?f <- (createMacro)
	(not (pulisci-table))
	?b3 <- (best_Ta ?rta ?cta ?idta)
	(not (butta-food))
	?bd <- (butta-drink)
	?tf <- (table-found)
	=>
	(assert (lookfor RB ?rta ?cta))
	(retract ?bd  ?tf ?b3)
	(focus MIN_DISTANCE)
	
)
(defrule rec_finish_lookforTrashAndRecyclableBaskets (declare (salience 40))
	?f <- (createMacro)
	(not (pulisci-table))
	?b3 <- (best_Ta ?rta ?cta ?idta)
	?bf <- (butta-food)
	?bd <-  (butta-drink)
	?tf <- (table-found)
	=>
	(assert (lookfor TB-RB ?rta ?cta))
	(retract ?bd ?bf ?tf ?b3)
	(focus MIN_DISTANCE)
)

(defrule rec_message_finishTBandRB_conclusion (declare (salience 42))
	(not (pulisci-table (table-id ?id)))
	?f <- (createMacro)
	?b1 <- (best_TB ?rtb ?ctb)
	?b2 <- (best_RB ?rrb ?crb)
	?bc <- (best-choice TB)
	?c <- (counter ?count)
	=>
	(assert 
		(MacroAction (macrostep ?count) (oper Move) (param1 ?rtb) (param2 ?ctb))
		(MacroAction (macrostep =(+ ?count 1)) (oper EmptyFood) (param1 ?rtb) (param2 ?ctb))
		(MacroAction (macrostep =(+ ?count 2)) (oper Move) (param1 ?rrb) (param2 ?crb))
		(MacroAction (macrostep =(+ ?count 3)) (oper Release) (param1 ?rrb) (param2 ?crb))
		(macrostep 1)
	)
	(retract ?b1 ?b2 ?bc ?f ?c)
)

(defrule rec_message_finishRBandTB_conclusion (declare (salience 42))
	(not (pulisci-table (table-id ?id)))
	?f <- (createMacro)
	?b1 <- (best_TB ?rtb ?ctb)
	?b2 <- (best_RB ?rrb ?crb)
	?bc <- (best-choice RB)
	?c <- (counter ?count)
	=>
	(assert 
		(MacroAction (macrostep ?count) (oper Move) (param1 ?rrb) (param2 ?crb))
		(MacroAction (macrostep =(+ ?count 1)) (oper Release) (param1 ?rrb) (param2 ?crb))
		(MacroAction (macrostep =(+ ?count 2)) (oper Move) (param1 ?rtb) (param2 ?ctb))
		(MacroAction (macrostep =(+ ?count 3)) (oper EmptyFood) (param1 ?rtb) (param2 ?ctb))
		(macrostep 1)
	)
	(retract ?b1 ?b2 ?bc ?f ?c)
)

(defrule rec_message_finishTB_conclusion (declare (salience 40))
	(not (pulisci-table (table-id ?id)))
	?f <- (createMacro)
	?b1 <- (best_TB ?rtb ?ctb)
	?c <- (counter ?count)
	=>
	(assert 
		(MacroAction (macrostep ?count) (oper Move) (param1 ?rtb) (param2 ?ctb))
		(MacroAction (macrostep =(+ ?count 1)) (oper EmptyFood) (param1 ?rtb) (param2 ?ctb))
		(macrostep 1)
	)
	(retract ?b1 ?f ?c)
)

(defrule rec_message_finishRB_conclusion (declare (salience 40))
	(not (pulisci-table (table-id ?id)))
	?f <- (createMacro)
	?b2 <- (best_RB ?rrb ?crb)
	?c <- (counter ?count)
	=>
	(assert 
		(MacroAction (macrostep ?count) (oper Move) (param1 ?rrb) (param2 ?crb))
		(MacroAction (macrostep =(+ ?count 1)) (oper Release) (param1 ?rrb) (param2 ?crb))
		(macrostep 1)
	)
	(retract ?b2 ?f ?c)
)


;regola che converte tutti gli ordini di Order con numero di porzione di cibi pari a 0 in una sequenza di MacroAction
(defrule rec_order_lookfor1 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nf 0))
	=>
	(assert (ordine-servito ?tb ?nd ?nf))
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
	(assert (ordine-servito ?tb ?nd ?nf))
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
	(assert (ordine-servito ?tb ?nd ?nf))
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
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 4) (oper DeliveryDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rf) (param2 ?cf))
		(MacroAction (macrostep 6) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf))
		(MacroAction (macrostep 7) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 8) (oper DeliveryFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
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