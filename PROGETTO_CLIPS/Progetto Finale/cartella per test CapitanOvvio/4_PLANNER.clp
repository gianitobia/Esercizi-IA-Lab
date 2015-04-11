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

;Definzione del template per le azioni ad alto livello per la gestioni dei comportamenti del robot
(deftemplate MacroAction
	(slot macrostep)
	(slot oper (allowed-values 	Move 
								LoadDrink 
								LoadFood 
								DeliveryFood 
								DeliveryDrink 
                        		CleanTable 
								EmptyFood 
								Release 
								CheckFinish))
	(slot param1)
	(slot param2)
	(slot param3)
)

(defrule deleteMacroStep (declare (salience 350))
	(not (MacroAction))
	?f <- (macrostep ?i)
	=>
	(retract ?f)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////					ZONA DI CONVERSIONE DA MACRO A PLANNEDACTION					////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;;Nel caso in cui viene trovato una macro di tipo Move si scatena il modulo Movement   ---	(Sguinzagliamo La Star)
(defrule convertMacroToMove (declare (salience 300))
	?s <- (something-to-plan)															
	(step ?curr)
	?f1 <- (macrostep ?i)
	?f2 <- (MacroAction (macrostep ?i) (oper Move) (param1 ?goal-r) (param2 ?goal-c))
	=>
	(assert (goal ?goal-r ?goal-c))
	(retract ?f1 ?f2 ?s)
	(assert (macrostep =(+ ?i 1)))
	(focus MOVEMENT)
)

;Nel caso in cui vengono trovate tutti gli altri tipi di Macro basta convertire direttamente la macro in una planned action

; 1	-- 	CheckFinish
(defrule convertMacroToCheckFinish (declare (salience 300))
	?s <- (something-to-plan)
	(step ?curr)
	?f1 <- (macrostep ?i)
	?f2 <- (MacroAction (macrostep ?i) (oper CheckFinish) (param1 ?rf) (param2 ?cf))
	=>
	(assert (planned-action
					(step ?curr)
					(action CheckFinish)
					(pos_r ?rf)
					(pos_c ?cf)
			)
	)
	(retract ?f1 ?s ?f2)
	(assert (macrostep =(+ ?i 1)))
	(pop-focus)
)

; 2	-- 	CleanTable
(defrule convertMacroToCleanTable (declare (salience 300))
	?s <- (something-to-plan)
	(step ?curr)
	?f1 <- (macrostep ?i)
	?f2 <- (MacroAction (macrostep ?i) (oper CleanTable) (param1 ?rf) (param2 ?cf))
	=>
	(assert (planned-action
					(step ?curr)
					(action CleanTable)
					(pos_r ?rf)
					(pos_c ?cf)
			)
	)
	(retract ?f1 ?s ?f2)
	(assert (macrostep =(+ ?i 1)))
	(pop-focus)
)

; 3	-- 	EmptyFood
(defrule convertMacroToEmptyFood (declare (salience 300))
	?s <- (something-to-plan)
	(step ?curr)
	?f1 <- (macrostep ?i)
	?f2 <- (MacroAction (macrostep ?i) (oper EmptyFood) (param1 ?rf) (param2 ?cf))
	=>
	(assert (planned-action
					(step ?curr)
					(action EmptyFood)
					(pos_r ?rf)
					(pos_c ?cf)
			)
	)
	(retract ?f1 ?s ?f2)
	(assert (macrostep =(+ ?i 1)))
	(pop-focus)
)

; 3	-- 	Release
(defrule convertMacroToRelease (declare (salience 300))
	?s <- (something-to-plan)
	(step ?curr)
	?f1 <- (macrostep ?i)
	?f2 <- (MacroAction (macrostep ?i) (oper Release) (param1 ?rf) (param2 ?cf))
	=>
	(assert (planned-action
					(step ?curr)
					(action Release)
					(pos_r ?rf)
					(pos_c ?cf)
			)
	)
	(retract ?f1 ?s ?f2)
	(assert (macrostep =(+ ?i 1)))
	(pop-focus)
)


;;Se la macro é un delivery o un load di drink o food allora bisognerá fare tante planned action quante sono scritte nella quantitá 
;per far ció generiamo una planned-action e decrementiamo di uno la quantitá fino a che la macroaction non avrá quantitá 0 
;e quindi si potra cancellare la macroaction e andare avanti con le macroaction il comportamento é uguale 
;sia per le load che per i delivery di cibo e bevande

; Cancellazione della Macroaction con qnt pari a 0
(defrule eliminateMacroToLoadOrDelivery (declare (salience 298))
	?s <- (something-to-plan)
	(step ?curr)
	?f1 <- (macrostep ?i)
	?f2 <- (MacroAction (macrostep ?i) (oper ?oper) (param1 ?rm) (param2 ?cm) (param3 0))
	=>
	(assert (macrostep =(+ ?i 1)))
	(retract ?f1 ?s ?f2)
)

; Decremento delle unita' per ciascuna plannedAction generata 
(defrule convertMacroToLoadOrDelivery (declare (salience 295))
	?s <- (something-to-plan)
	(step ?curr)
	?f2 <- (MacroAction (macrostep ?i) (oper ?oper) (param1 ?rm) (param2 ?cm) (param3 ?nm))
	=>
	(assert (planned-action
					(step ?curr)
					(action ?oper)
					(pos_r ?rm)
					(pos_c ?cm)
			)
	)
	(retract ?s)							;f1 dovrebbe rimanere presente x essere cancellata della regola sopra?
	(modify ?f2 (param3 =(- ?nm 1)))
	(pop-focus)
)


;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////						  GESTIONE DELLE AZIONI DA COMPIERE							////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;Nel caso in cui non ci siano Macro da eseguire ma ci siano ordini in attesa, passiamo il focus all'order management
(defrule createNewMacros (declare (salience 290))
	?s <- (something-to-plan)
	(step ?curr)
	(not (MacroAction))
	(coda-ordini)
	=>
	(assert (createMacro))
	(focus ORDER_MANAGEMENT)
)

;Nel caso in cui non ci siano ne ordini ne macro da eseguire asserisco la planned-action di Wait
;da aggiungere un controllo che io sia al centro della stanza e semmai andarci
(defrule createWaiAction (declare (salience 290))
	?s <- (something-to-plan)
	(step ?curr)
	(not (MacroAction))
	(not (coda-ordini))
	=>
	(assert (planned-action
					(step ?curr)
					(action Wait)					;Da rivedere per capire cosa sia meglio far fare al robot.
			)
	)
	(retract ?s)
	(pop-focus)
)


;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////						  ZONA COME BACK DA MODULO MOVEMENT							////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;Cancelliamo l'ultimo step di a* in modo da non finire sulla casella dell'obiettivo
(defrule delete-last-step (declare (salience 99))
	?f2 <- (deleted no)
	?f1 <- (planned-move-inv
				(step ?curr)
				(action ?act)
				(pos_r ?r)
				(pos_c ?c)
	)
	=>
	(printout t "Step cancellato: " ?curr crlf)
	(retract ?f1 ?f2)
)
	

(defrule invert-move-action (declare (salience 98))
	?f <- (planned-move-inv
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
	(retract ?f)
)