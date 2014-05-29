;// __________________________________________________________________________________________

;// REGOLE PER GESTIONE INFORM (in caso di request) DALL'AGENTE 

;// ������������������������������������������������������������������������������������������

;//

;// l'agente ha inviato inform che l'ordine � accettato (e va bene)
(defrule msg-order-accepted-OK (declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 accepted))
	?f2 <- (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3 <- (agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean yes))	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer accepted))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
)

;// l'agente ha inviato inform che l'ordine � accettato (e ma non sono vere le condizioni)
(defrule msg-order-accepted-KO1 (declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 accepted))
	?f2 <- (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3 <- (agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean no))	
	?f4 <- (penalty ?p)	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer accepted))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
    (assert (penalty (+ ?p 500000)))
	(retract ?f4)
)

;// l'agente ha inviato inform che l'ordine � delayed (e va bene)
(defrule msg-order-delayed-OK (declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 delayed))
	?f2 <- (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3 <- (agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean no))
    (cleanstatus (step ?i) (time ?t) (arrivaltime ?tt&:(< ?tt ?request)) (requested-by ?tb))	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer delayed))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
)



;// l'agente ha inviato inform che l'ordine � delayed (e non va bene dovrebbe essere accepted)
(defrule msg-order-delayed-KO1 (declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 delayed))
	?f2 <- (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3 <- (agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean yes))
	?f4 <- (penalty ?p)	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer delayed))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
	(assert (penalty (+ ?p 500000)))
	(retract ?f4)
)

;// l'agente ha inviato inform che l'ordine � rejected (e non va bene dovrebbe essere accepted)
(defrule msg-order-rejected-KO1 (declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 rejected))
	?f2 <- (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3 <- (agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean yes))
	?f4 <- (penalty ?p)	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer rejected))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
    (assert (penalty (+ ?p 5000000)))
	(retract ?f4)

)

;// l'agente ha inviato inform che l'ordine � rejected (e non va bene dovrebbe essere delayed)
(defrule msg-order-rejected-KO2 (declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 rejected))
	?f2 <- (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3 <- (agentstatus (step ?i) (time ?t))
	    (tablestatus (step ?i) (time ?t) (table-id ?tb) (clean no))
	    (cleanstatus (step ?i) (time ?t) (arrivaltime ?tt&:(< ?tt ?request)) (requested-by ?tb))
	?f4 <- (penalty ?p)	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer accepted))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
    (assert (penalty (+ ?p 5000000)))
	(retract ?f4)
)


;// l'agente invia un'inform  per un servizio che non � pi� pending




(defrule msg-mng-KO1 (declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request))
	(orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer ~pending))		
	?f3 <- (agentstatus (step ?i) (time ?t))
	?f4 <- (penalty ?p)
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
    (assert (penalty (+ ?p 10000)))
    (retract ?f4)
)

;// arriva un'inform per una richiesta not fatta dal tavolo
(defrule msg-mng-KO2 (declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request))
    (not (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request))) 
	?f3 <- (agentstatus (step ?i) (time ?t))
	?f4 <- (penalty ?p)
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
	(assert (penalty (+ ?p 500000)))
	(retract ?f4)
)

;// Regole per il CheckFinish

;// Operazione OK- risposta yes
(defrule CheckFinish_OK_YES (declare (salience 20))    
	?f2<- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (serviceTable ?tb ?rr ?cc)
	(tablestatus (step ?i) (table-id ?tb) (clean no))
    (msg-to-agent  (request-time ?rt)  (step ?ii) (sender ?tb) (type order))
    (not (orderstatus (step ?i) (time ?t) (requested-by ?tb)))
    (not (cleanstatus (step ?i) (arrivaltime ?at&:(> ?at ?rt)) (requested-by ?tb)))
    (test (> (- ?t ?rt)  100))
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish yes)))
)

;// Operazione OK- Risposta no
(defrule CheckFinish_OK_NO (declare (salience 20))    
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (serviceTable ?tb ?rr ?cc)
	?f3 <- (tablestatus (step ?i) (table-id ?tb) (clean no))
    (msg-to-agent  (request-time ?rt)  (step ?ii) (sender ?tb) (type order))
    (not (orderstatus (step ?i) (time ?t) (requested-by ?tb)))
    (not (cleanstatus (step ?i) (arrivaltime ?iii&:(> ?iii ?ii)) (requested-by ?tb)))
    (test (or (= (- ?t ?rt)  100) (< (- ?t ?rt)  100)))
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish no)))
)


; operazione non serve, il tavolo ha gi� richiesto cleantable 
(defrule CheckFinish_useless-1 (declare (salience 20))    
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (serviceTable ?tb ?rr ?cc)
	?f3 <- (tablestatus (step ?i) (table-id ?tb) (clean no))
    (msg-to-agent  (request-time ?rt)  (step ?ii&:(< ?ii ?i)) (sender ?tb) (type order))
    (cleanstatus (step ?i) (arrivaltime ?iii&:(> ?iii ?ii)) (requested-by ?tb))
	?f4 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish yes))
            (penalty (+ ?p 10000)))
    (retract ?f4)
)

;// operazione non serve, il tavolo � gia pulito
(defrule CheckFinish_useless-2 (declare (salience 20))
	?f2<- (status (time ?t) (step ?i))
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1<- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc)) (serviceTable ?tb ?rr ?cc)
	?f3<- (tablestatus (step ?i) (table-id ?tb) (clean yes)) ?f4<- (penalty ?p) 
	=>
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish yes)) (penalty (+ ?p 10000))) (retract ?f4)
)


;// Operazione sbagliata perch� chiede finish prima che l'ordine sia stato completato

(defrule CheckFinish_Useless-3 (declare (salience 20))
	?f2<- (status (time ?t) (step ?i))
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1<- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc)) (serviceTable ?tb ?rr ?cc)
	?f3<- (tablestatus (step ?i) (table-id ?tb) (clean no))
	(msg-to-agent (request-time ?rt) (step ?ii) (sender ?tb) (type order)) (orderstatus (step ?i) (time ?t) (requested-by ?tb)) ?f4<- (penalty ?p) 
	=>
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish no)) (penalty (+ ?p 100000))) (retract ?f4)
)

;// operazione di checkFinish fatta su tavolo che non ha fatto richiesta
(defrule CheckFinish_useless-4 (declare (salience 20))    
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (serviceTable ?tb ?rr ?cc)
	?f3 <- (tablestatus (step ?i) (table-id ?tb) (clean no))
    (not (msg-to-agent  (request-time ?rt)  (step ?ii&:(< ?ii ?i)) (sender ?tb) (type order)))
	?f4 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish no))
            (penalty (+ ?p 100000)))
    (retract ?f4)
)

;// L'azione di CheckFinish  fallisce perch� l'agente non � accanto ad un tavolo 
(defrule CheckFinish_KO_1 (declare (salience 20))
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (not (serviceTable ?tb ?rr ?cc))
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
	(assert (penalty (+ ?p	500000)))
    (retract ?f5)
) 

;// L'azione di CheckFinish fallisce perch� la posizione indicata non 
;//contiene un tavolo 

(defrule CheckFinish_KO_2 (declare (salience 20))
	?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(not (Table (table-id ?tb) (pos-r ?x) (pos-c ?y)))
	?f1 <- (agentstatus (step ?i) (time ?t))
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
	(assert (penalty (+ ?p	500000)))
    (retract ?f5)
) 