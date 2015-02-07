; Questo programma contiene il simulatore dell'agente robotico per applicazione NG-CAFÈ

;  Si noti che la parte di funzionamento dell'agente è separata
;  dal particolare problema da risolvere.
;
;  Infatti la definizione del problema in termini di 
;         mappa inziale (descritta con istanzazioni di prior_cell)
;         durata massima (maxduration)
;         stato iniziale dell'agente (in termini di initial_agentstatus)
; deve essere contenuta nel file InitMap.txt
;
;  la descrizione di quali eventi avvengono durante l'esecuzione è
;  contenuta nel file history.txt. Questo file conteine anche le informazioni
;  per specificare quali sono i cleinti e quali attività svolgono

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@--------- MAIN --------- @@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

(defmodule MAIN (export ?ALL))

;// DEFTEMPLATE

(deftemplate exec 
    (slot step)     ;// l'environment incrementa il passo 
    (slot action  (allowed-values Forward Turnright Turnleft Wait 
                                      LoadDrink LoadFood DeliveryFood DeliveryDrink 
                                      CleanTable EmptyFood Release CheckFinish Inform))
            (slot param1)
            (slot param2)
            (slot param3))


(deftemplate msg-to-agent 
           (slot request-time)
           (slot step)
           (slot sender)
           (slot type (allowed-values order finish))
           (slot  drink-order)
           (slot food-order))

        
(deftemplate status (slot step) (slot time) (slot result))  ;//struttura interna

(deftemplate perc-vision    ;// la percezione di visione avviene dopo ogni azione, fornisce informazioni sullo stato del sistema
    (slot step)
            (slot time) 
    (slot pos-r)        ;// informazioni sulla posizione del robot (riga)
    (slot pos-c)        ;// (colonna)
    (slot direction)        ;// orientamento del robot
    ;// percezioni sulle celle adiacenti al robot: (il robot é nella 5 e punta sempre verso la 2):              
             
            (slot perc1  (allowed-values  Wall Person  Empty Parking Table Seat TrashBasket
                                                          RecyclableBasket DrinkDispenser FoodDispenser))
            (slot perc2  (allowed-values  Wall Person  Empty Parking Table Seat TrashBasket
                                                          RecyclableBasket DrinkDispenser FoodDispenser))
            (slot perc3  (allowed-values  Wall Person  Empty Parking Table Seat TrashBasket
                                                          RecyclableBasket DrinkDispenser FoodDispenser))
            (slot perc4  (allowed-values  Wall Person  Empty Parking Table Seat TrashBasket
                                                          RecyclableBasket DrinkDispenser FoodDispenser))
            (slot perc5  (allowed-values  Wall Person  Empty Parking Table Seat TrashBasket
                                                          RecyclableBasket DrinkDispenser FoodDispenser))
            (slot perc6  (allowed-values  Wall Person  Empty Parking Table Seat TrashBasket
                                                          RecyclableBasket DrinkDispenser FoodDispenser))
            (slot perc7  (allowed-values  Wall Person  Empty Parking Table Seat TrashBasket
                                                          RecyclableBasket DrinkDispenser FoodDispenser))
            (slot perc8  (allowed-values  Wall Person  Empty Parking Table Seat TrashBasket
                                                          RecyclableBasket DrinkDispenser FoodDispenser))
            (slot perc9  (allowed-values  Wall Person  Empty Parking Table Seat TrashBasket
                                                          RecyclableBasket DrinkDispenser FoodDispenser))
            )



(deftemplate perc-bump      ;// percezione di urto contro persone o ostacoli
    (slot step)
            (slot time)     
    (slot pos-r)        ;// la posizione in cui si trova (la stessa in cui era prima dell'urto)
    (slot pos-c)
    (slot direction)
    (slot bump (allowed-values no yes)) ;//restituisce yes se sbatte
)


(deftemplate perc-load
            (slot step)
            (slot time)
            (slot load  (allowed-values yes no)) ) 


(deftemplate perc-finish  
            (slot step)
            (slot time)
            (slot finish (allowed-values no yes)))


(deftemplate Table (slot table-id) (slot pos-r) (slot pos-c))
(deftemplate TrashBasket (slot TB-id) (slot pos-r) (slot pos-c))
(deftemplate RecyclableBasket (slot  RB-id) (slot pos-r) (slot pos-c))
(deftemplate FoodDispenser  (slot FD-id) (slot pos-r) (slot pos-c))
(deftemplate DrinkDispenser (slot DD-id) (slot pos-r) (slot pos-c))

(deftemplate initial_agentposition (slot pos-r)  (slot pos-c) (slot direction))

(deftemplate prior-cell  (slot pos-r) (slot pos-c) 
                         (slot contains (allowed-values Wall Person  Empty Parking Table Seat TB
                                                      RB DD FD)))


(deffacts init 
    (create)
)

;; prima regola eseguita
;; legge anche initial map (prior cell), initial agent status e durata simulazione (in numero di passi)

(defrule createworld 
    ?f<-   (create) =>
           (load-facts "InitMap.txt")
           (assert (create-map) (create-initial-setting)
                   (create-history))  
           (retract ?f)
           (focus ENV))

;// SI PASSA AL MODULO AGENT SE NON  E' ESAURITO IL TEMPO (indicato da maxduration)
(defrule go-on-agent        
    (declare (salience 20))
    (maxduration ?d)
    (status (step ?t&:(< ?t ?d)))   ;// controllo sul tempo
 => 
;   (printout t crlf)
    (focus AGENT)       ;// passa il focus all'agente, che dopo un'azione lo ripassa al main.
)

;// SI PASSA AL MODULO ENV DOPO CHE AGENTE HA DECISO AZIONE DA FARE
(defrule go-on-env  
    (declare (salience 21))
?f1<-   (status (step ?t))
    (exec (step ?t))    ;// azione da eseguire al al passo T, viene simulata dall'environment
=>
;   (printout t crlf)
    (focus ENV)
)

;// quando finisce il tempo l'esecuzione si interrompe e vengono stampate le penalità
(defrule game-over  
    (declare (salience 10))
    (maxduration ?d)
    (status (step ?d))
    (penalty ?p)
=> 
    (printout t crlf " TIME OVER - Penalità accumulate: " ?p crlf crlf)
    (halt)
)


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@ --------- ENV --------- @@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

(defmodule ENV (import MAIN ?ALL))


;// DEFTEMPLATE

(deftemplate cell  (slot pos-r) (slot pos-c) 
                   (slot contains (allowed-values Wall Person  Empty Parking Table Seat TrashBasket
                                                      RecyclableBasket DrinkDispenser FoodDispenser)))

(deftemplate agentstatus 
        (slot step)
        (slot time) 
        (slot pos-r) 
        (slot pos-c) 
        (slot direction) 
        (slot l-drink)
        (slot l-food)
        (slot l_d_waste)
        (slot l_f_waste)
)


(deftemplate tablestatus    
        (slot step)
        (slot time)
        (slot table-id)
        (slot clean (allowed-values yes no))
        (slot l-drink)
        (slot l-food))

(deftemplate orderstatus    ;// tiente traccia delle ordinazioni
        (slot step)
        (slot time)         ;// tempo corrente
        (slot arrivaltime)  ;// momento in cui é arrivata l'ordinazione
        (slot requested-by) ;// tavolo richiedente
        (slot drink-order)
        (slot food-order)
        (slot drink-deliv)
        (slot food-deliv)
        (slot answer (allowed-values pending accepted delayed rejected))    
)

(deftemplate cleanstatus
        (slot step)
        (slot time)
        (slot arrivaltime)  
        (slot requested-by) ;// tavolo richiedente  
)

(deftemplate personstatus   ;// informazioni sulla posizione delle persone
        (slot step)
       	(slot time)
        (slot ident)
        (slot pos-r)
        (slot pos-c)
        (slot activity)   ;// activity seated se cliente seduto, stand se in piedi, oppure path         
        (slot move)         
)

(deftemplate personmove     ;// modella i movimenti delle persone. l'environment deve tenere conto dell'interazione di tanti agenti. Il mondo cambia sia per le azioni del robot, si per le azioni degli operatori. Il modulo environment deve gestire le interazioni. 
    (slot step)
    (slot ident)
    (slot path-id)
)

(deftemplate event          ;// gli eventi sono le richieste dei tavoli: ordini e finish
        (slot step)
        (slot type (allowed-values request finish))
        (slot source)
        (slot food)
            (slot drink)
)


;// DEFRULE

;//zona CREATION: imposta il valore iniziale di ciascuna cella 
(defrule creation1  
     (declare (salience 25))
     (create-map)
     (prior-cell (pos-r ?r) (pos-c ?c) (contains ?x)) 
=>
     (assert (cell (pos-r ?r) (pos-c ?c) (contains ?x)))
            
)
(defrule creation2  
    (declare (salience 24))
?f1<-   (create-history) 
=>
    (load-facts "history.txt")
        (retract ?f1)
)
(defrule creation3
         (declare (salience 23))
         (create-initial-setting)
         (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
=> 
         (assert (tablestatus (step 0) (time 0) (table-id ?tb) (clean yes) (l-drink 0) (l-food 0)))
)
(defrule creation411
         (declare (salience 22))
         (create-initial-setting)
         (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceTable ?tb (- ?r 1) ?c))
)
(defrule creation412
         (declare (salience 22))
         (create-initial-setting)
         (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceTable ?tb (+ ?r 1) ?c))
)
(defrule creation413
         (declare (salience 22))
         (create-initial-setting)
         (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceTable ?tb ?r (- ?c 1)))
)
(defrule creation414
         (declare (salience 22))
         (create-initial-setting)
         (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceTable ?tb ?r (+ ?c 1)))
)
(defrule creation421
         (declare (salience 22))
         (create-initial-setting)
         (TrashBasket (TB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty|Parking))
=> 
         (assert (serviceTB ?tb (- ?r 1) ?c))
)
(defrule creation422
         (declare (salience 22))
         (create-initial-setting)
         (TrashBasket (TB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty|Parking))
=> 
         (assert (serviceTB ?tb (+ ?r 1) ?c))
)
(defrule creation423
         (declare (salience 22))
         (create-initial-setting)
         (TrashBasket (TB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty|Parking))
=> 
         (assert (serviceTB ?tb ?r (- ?c 1)))
)
(defrule creation424
         (declare (salience 22))
         (create-initial-setting)
         (TrashBasket (TB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty|Parking))
=> 
         (assert (serviceTB ?tb ?r (+ ?c 1)))
)

(defrule creation431
         (declare (salience 22))
         (create-initial-setting)
         (RecyclableBasket (RB-id ?rb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty|Parking))
=> 
         (assert (serviceRB ?rb (- ?r 1) ?c))
)
(defrule creation432
         (declare (salience 22))
         (create-initial-setting)
         (RecyclableBasket (RB-id ?rb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty|Parking))
=> 
         (assert (serviceRB ?rb (+ ?r 1) ?c))
)
(defrule creation433
         (declare (salience 22))
         (create-initial-setting)
         (RecyclableBasket (RB-id ?rb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty|Parking))
=> 
         (assert (serviceRB ?rb ?r (- ?c 1)))
)
(defrule creation434
         (declare (salience 22))
         (create-initial-setting)
         (RecyclableBasket (RB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty|Parking))
=> 
         (assert (serviceRB ?tb ?r (+ ?c 1)))
)
(defrule creation441
         (declare (salience 22))
         (create-initial-setting)
         (FoodDispenser (FD-id ?fd) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceFD ?fd (- ?r 1) ?c))
)
(defrule creation442
         (declare (salience 22))
         (create-initial-setting)
         (FoodDispenser (FD-id ?fd) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceFD ?fd (+ ?r 1) ?c))
)
(defrule creation443
         (declare (salience 22))
         (create-initial-setting)
         (FoodDispenser (FD-id ?fd) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceFD ?fd ?r (- ?c 1)))
)
(defrule creation444
         (declare (salience 22))
         (create-initial-setting)
         (FoodDispenser (FD-id ?fd) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceFD ?fd ?r (+ ?c 1)))
)
(defrule creation451
         (declare (salience 22))
         (create-initial-setting)
         (DrinkDispenser (DD-id ?dd) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceDD ?dd (- ?r 1) ?c))
)
(defrule creation452
         (declare (salience 22))
         (create-initial-setting)
         (DrinkDispenser (DD-id ?dd) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceDD ?dd (+ ?r 1) ?c))
)
(defrule creation453
         (declare (salience 22))
         (create-initial-setting)
         (DrinkDispenser (DD-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceDD ?tb ?r (- ?c 1)))
)
(defrule creation454
         (declare (salience 22))
         (create-initial-setting)
         (DrinkDispenser (DD-id ?dd) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceDD ?dd ?r (+ ?c 1)))
)
(defrule creation5
         (declare (salience 21))
?f1 <-   (create-initial-setting)
?f2 <-   (create-map)
         (initial_agentposition (pos-r ?r) (pos-c ?c) (direction ?d))
=> 
         (assert (agentstatus (step 0) (time 0) (pos-r ?r) (pos-c ?c) (direction ?d)
                              (l-drink 0) (l-food 0) (l_d_waste no) (l_f_waste no))
                 (status (step 0) (time 0) (result no)) ;RESULT NO AGGIUNTO DA NOI --- CHIEDERE AL PROF
                 (penalty 0))
         (retract ?f1 ?f2)
)

;// __________________________________________________________________________________________
;// REGOLE PER GESTIONE EVENTI    
;// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

(defrule neworder1     
    (declare (salience 200))
    (status (step ?i) (time ?t))
?f1<-   (event (step ?i) (type request) (source ?tb) (food ?nf) (drink ?nd))
    (tablestatus (step ?i) (table-id ?tb) (clean yes)) 
=> 
    (assert 
        (orderstatus (step ?i) (time ?t) (arrivaltime ?t) (requested-by ?tb) 
                             (drink-order ?nd) (food-order ?nf)
                             (drink-deliv 0) (food-deliv 0)
                             (answer pending))
     
        (msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order)
                              (drink-order ?nd) (food-order ?nf))
    )
    (retract ?f1)       
           (printout t crlf crlf "** ENVIRONMENT **" crlf)
    (printout t " - " ?tb " orders " ?nf " food e " ?nd " drinks" crlf)
)

(defrule neworder2     
    (declare (salience 200))
    (status (step ?i) (time ?t))
?f1<-   (event (step ?i) (type request) (source ?tb) (food ?nf) (drink ?nd))
    (tablestatus (step ?i) (table-id ?tb) (clean no))
        (event (step ?ii&:(< ?ii ?i)) (type finish) (source ?tb))
=> 
    (assert 
        (orderstatus (step ?i) (time ?t) (arrivaltime ?t) (requested-by ?tb) 
                             (drink-order ?nd) (food-order ?nf)
                             (drink-deliv 0) (food-deliv 0)
                             (answer pending))
     
        (msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order)
                              (drink-order ?nd) (food-order ?nf))
    )
    (retract ?f1)       
    (printout t crlf crlf "** ENVIRONMENT **" crlf)
    (printout t " - " ?tb " orders " ?nf " food e " ?nd " drinks" crlf)
)

(defrule newfinish      
    (declare (salience 200))
    (status (step ?i) (time ?t))
?f1<-   (event (step ?i) (type finish) (source ?tb))
    (tablestatus (step ?i) (table-id ?tb) (clean no))
=> 
    (assert     
        (cleanstatus (step ?i) (time ?t) (arrivaltime ?t) (requested-by ?tb))
                (msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type finish))
    )
    (retract ?f1)
    (printout t crlf crlf "** ENVIRONMENT **" crlf)
    (printout t " - " ?tb " declares finish " crlf)
)
;// __________________________________________________________________________________________
;// GENERA EVOLUZIONE TEMPORALE       
;// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  

;// per ogni istante di tempo che intercorre fra l'informazione di finish di un tavolo  e 
;//  pulitura (clean) del tavolol),  l'agente prende 3 penalità

(defrule CleanEvolution1       
    (declare (salience 10))
    (status (time ?t) (step ?i))
?f1<-   (cleanstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb))
    (not (cleanstatus (step ?i)  (arrivaltime ?at) (requested-by ?tb))) 
?f2<-   (penalty ?p)
=> 
    (modify ?f1 (time ?t) (step ?i))
    (assert (penalty (+ ?p (* (- ?t ?tt) 3))))
    (retract ?f2)   
)


;// per ogni istante di tempo che intercorre fra la request e la inform, l'agente prende 50 penalità
(defrule RequestEvolution1       
    (declare (salience 10))
    (status (time ?t) (step ?i))
?f1<-   (orderstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb)
                     (answer pending))
    (not (orderstatus (step ?i) (arrivaltime ?at) (requested-by ?tb)
                     (answer ~pending)))
?f2<- (penalty ?p)
=> 
    (modify ?f1 (time ?t) (step ?i))
    (assert (penalty (+ ?p (* (- ?t ?tt) 50))))
    (retract ?f2)
)


;// penalità perchè l'ordine è stato accepted e non è ancora stato completato
(defrule RequestEvolution2       
    (declare (salience 10))
        (status (time ?t) (step ?i))
?f1<-   (orderstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb)
                     (answer accepted)
                     (drink-order ?nd) (food-order ?nf) (drink-deliv ?dd) (food-deliv ?df))
        (not (orderstatus (step ?i) (arrivaltime ?at) (requested-by ?tb)))
?f2<-   (penalty ?p)
=> 
        (modify ?f1 (time ?t) (step ?i))
    (assert (penalty (+ ?p (* (- ?t ?tt) (max 1 (* (+ (- ?nd ?dd) (- ?nf ?df)) 2))))))
    (retract ?f2)
)


;// penalità perchè l'ordine è stato delayed e non è ancora stato completato 
(defrule RequestEvolution3       
    (declare (salience 10))
        (status (time ?t) (step ?i))
?f1<-   (orderstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb)
                     (answer delayed)
                     (drink-order ?nd) (food-order ?nf) (drink-deliv ?dd) (food-deliv ?df))
        (not (orderstatus (step ?i) (arrivaltime ?at) (requested-by ?tb)))
?f2<-   (penalty ?p)
=> 
        (modify ?f1 (time ?t) (step ?i))
    (assert (penalty (+ ?p (* (- ?t ?tt) (max 1 (+ (- ?nd ?dd) (- ?nf ?df)))))))
    (retract ?f2)
)

;// 
(defrule RequestEvolution4       
    (declare (salience 10))
        (status (time ?t) (step ?i))
?f1<-   (tablestatus (step = (- ?i 1)) (time ?tt) (table-id ?tb))
        (not (tablestatus (step ?i)  (table-id ?tb)))
=> 
        (modify ?f1 (time ?t) (step ?i))
)

;// __________________________________________________________________________________________
;// GENERA MOVIMENTI PERSONE                    
;// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

;// Persona ferma non arriva comando di muoversi
(defrule MovePerson1        
    (declare (salience 10))    
    (status (step ?i) (time ?t)) 
?f1<-   (personstatus (step =(- ?i 1)) (ident ?id) (activity seated|stand))
    (not (personmove (step ?i) (ident ?id)))
=> 
    (modify ?f1 (time ?t) (step ?i))
)         
         
;// Persona ferma ma arriva comando di muoversi         
(defrule MovePerson2
   (declare (salience 10))    
        (status (step ?i) (time ?t))  
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (activity seated|stand))
 ?f2 <- (personmove (step  ?i) (ident ?id) (path-id ?m))
        => (modify  ?f1 (time ?t) (step ?i) (activity ?m) (move 0))
           (retract ?f2)
)           
  
;// La cella in cui deve  andare la persona è libera. Persona si muove. 
;// La cella di partenza è un seat in cui si trovava l'operatore
(defrule MovePerson3
   (declare (salience 10))    
        (status (step ?i) (time ?t))   
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) 
                      (activity ?m&~seated&~stand) (move ?s))
        (cell (pos-r ?x) (pos-c ?y) (contains Seat))
 ?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
        (not (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)))
 ?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Empty))
        => (modify  ?f1  (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (move (+ ?s 1)))
           (modify ?f2 (contains Person))
           (retract ?f3)        
)

;// La cella in cui deve  andare la persona è libera. Persona si muove. 
;// La cella di partenza NON un seat , per cui dopo lo spostamento 
;// dell'operatore diventa libera
(defrule MovePerson4
   (declare (salience 10))    
        (status (step ?i) (time ?t)) 
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) 
                      (activity ?m&~seated|~stand) (move ?s))
 ?f4 <- (cell (pos-r ?x) (pos-c ?y) (contains Person))
 ?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
        (not (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)))
 ?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Empty))
        => (modify  ?f1  (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (move (+ ?s 1)))
           (modify ?f2 (contains Person))
           (modify ?f4 (contains Empty))
           (retract ?f3))


;// La cella in cui deve andare il cliente è un seat e il seat non è occupata da altra persona.
;// La cella di partenza diventa libera, e l'attivita del cliente diventa seated
 (defrule MovePerson5
   (declare (salience 10))    
        (status (step ?i) (time ?t)) 
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) 
                       (activity ?m&~seated&~stand) (move ?s))
 ?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
        (not (agentstatus (time ?i) (pos-r ?r) (pos-c ?c)))
 ?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Seat))
        (not (personstatus (step ?i) (ident ?id) (pos-r ?r) (pos-c ?c) 
                       (activity seated)))
 ?f4 <- (cell (pos-r ?x) (pos-c ?y) (contains Person))
        => (modify  ?f1  (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (activity seated) (move NA))
           (modify ?f4 (contains Empty))
           (retract ?f3))

;// La cella in cui deve  andare la persona è occupata dal robot. Persona non si muove           
(defrule MovePerson_wait1
    (declare (salience 10))    
    (status (step ?i) (time ?t))
?f1<-   (personstatus (step =(- ?i 1)) (time ?tt) (ident ?id) (activity ?m&~work&~stand) (move ?s))
    (move-path ?m =(+ ?s 1) ?id ?r ?c)
    (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c))
?f2<-   (penalty ?p)
=> 
    (modify  ?f1 (time ?t) (step ?i))
    (assert (penalty (+ ?p (* (- ?t ?tt) 20))))
    (retract ?f2)
;   (printout t " - penalità aumentate" ?id " attende che il robot si sposti)" crlf)
)
                  
;// La cella in cui deve  andare la persona non è libera (ma non è occupata da robot). Persona non si muove           
(defrule MovePerson_wait2
    (declare (salience 10))    
    (status (step ?i) (time ?t))
?f1<-   (personstatus (step =(- ?i 1)) (time ?tt) (ident ?id) (activity ?m&~work&~stand) (move ?s))
    (move-path ?m =(+ ?s 1) ?id ?r ?c)
        (cell (pos-r ?r) (pos-c ?c) (contains ~Empty))
    (not (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c)))
=>
    (modify  ?f1 (time ?t) (step ?i))

)

;// La cella in cui deve andare il cliente è un seat ma il seat è occupata da altra persona.
;// il cliente resta fermo
 (defrule MovePerson_wait3
   (declare (salience 10))    
        (status (step ?i) (time ?t)) 
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) 
                       (activity ?m&~seated&~stand) (move ?s))
 ?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
        (not (agentstatus (time ?i) (pos-r ?r) (pos-c ?c)))
 ?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Seat))
        (personstatus (step ?i) (ident ?id) (pos-r ?r) (pos-c ?c) 
                       (activity seated))
        => (modify  ?f1  (step ?i) (time ?t))
           (retract ?f3))

;//La serie di mosse è stata esaurita, la persona rimane ferma dove si trova
 (defrule MovePerson_end
   (declare (salience 10))    
        (status (step ?i) (time ?t)) 
?f1<-   (personstatus (step =(- ?i 1)) (time ?tt) (ident ?id) (activity ?m&~work&~stand) (move ?s))
    (not (move-path ?m =(+ ?s 1) ?id ?r ?c))
        => (modify  ?f1  (time ?t) (step ?i) (activity stand) (move NA)) 
        )
           


;// __________________________________________________________________________________________
;// REGOLE PER GESTIONE INFORM (in caso di request) DALL'AGENTE 
;// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

;// l'agente ha inviato inform che l'ordine è accettato (e va bene)
(defrule msg-order-accepted-OK    
    (declare (salience 20))
?f1<-   (status (step ?i) (time ?t))
    (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 accepted))
?f2<-   (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))        
?f3<-   (agentstatus (step ?i) (time ?t))
    (tablestatus (step ?i) (time ?t) (table-id ?tb) (clean yes))    
=> 
    (modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
    (modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer accepted))
    (modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
)

;// l'agente ha inviato inform che l'ordine è accettato (e ma non sono vere le condizioni)
(defrule msg-order-accepted-KO1    
    (declare (salience 20))
?f1<-   (status (step ?i) (time ?t))
    (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 accepted))
?f2<-   (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))        
?f3<-   (agentstatus (step ?i) (time ?t))
    (tablestatus (step ?i) (time ?t) (table-id ?tb) (clean no)) 
?f4<-   (penalty ?p)    
=> 
    (modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
    (modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer accepted))
    (modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
        (assert (penalty (+ ?p 500000)))
    (retract ?f4)
)

;// l'agente ha inviato inform che l'ordine è delayed (e va bene)
(defrule msg-order-delayed-OK    
    (declare (salience 20))
?f1<-   (status (step ?i) (time ?t))
    (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 delayed))
?f2<-   (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))        
?f3<-   (agentstatus (step ?i) (time ?t))
    (tablestatus (step ?i) (time ?t) (table-id ?tb) (clean no))
        (cleanstatus (step ?i) (time ?t) (arrivaltime ?tt&:(< ?tt ?request)) (requested-by ?tb))    
=> 
    (modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
    (modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer delayed))
    (modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
    
)

;// l'agente ha inviato inform che l'ordine è delayed (e non va bene dovrebbe essere accepted)
(defrule msg-order-delayed-KO1    
    (declare (salience 20))
?f1<-   (status (step ?i) (time ?t))
    (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 delayed))
?f2<-   (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))        
?f3<-   (agentstatus (step ?i) (time ?t))
    (tablestatus (step ?i) (time ?t) (table-id ?tb) (clean yes))
?f4<-   (penalty ?p)    
=> 
    (modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
    (modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer delayed))
    (modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
        (assert (penalty (+ ?p 500000)))
    (retract ?f4)
)

;// l'agente ha inviato inform che l'ordine è rejected (e non va bene dovrebbe essere accepted)
(defrule msg-order-rejected-KO1    
    (declare (salience 20))
?f1<-   (status (step ?i) (time ?t))
    (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 rejected))
?f2<-   (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))        
?f3<-   (agentstatus (step ?i) (time ?t))
    (tablestatus (step ?i) (time ?t) (table-id ?tb) (clean yes))
?f4<-   (penalty ?p)    
=> 
    (modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
    (modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer rejected))
    (modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
        (assert (penalty (+ ?p 5000000)))
    (retract ?f4)
)

;// l'agente ha inviato inform che l'ordine è rejected (e non va bene dovrebbe essere delayed)
(defrule msg-order-rejected-KO2    
    (declare (salience 20))
?f1<-   (status (step ?i) (time ?t))
    (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 rejected))
?f2<-   (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))        
?f3<-   (agentstatus (step ?i) (time ?t))
        (tablestatus (step ?i) (time ?t) (table-id ?tb) (clean no))
        (cleanstatus (step ?i) (time ?t) (arrivaltime ?tt&:(< ?tt ?request)) (requested-by ?tb))
?f4<-   (penalty ?p)    
=> 
    (modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
    (modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer accepted))
    (modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
        (assert (penalty (+ ?p 5000000)))
    (retract ?f4)
)

;// l'agente invia un'inform  per un servizio che non è più pending
(defrule msg-mng-KO1    
    (declare (salience 20))
?f1<-   (status (step ?i) (time ?t))
    (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request))
    (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer ~pending))
?f3<-   (agentstatus (step ?i) (time ?t))
?f4<-   (penalty ?p)
=> 
    (modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
    (modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
        (assert (penalty (+ ?p 10000)))
        (retract ?f4)
    
)

;// arriva un'inform per una richiesta not fatta dal tavolo
(defrule msg-mng-KO2    
    (declare (salience 20))
?f1<-   (status (step ?i) (time ?t))
    (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request))
        (not (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request))) 
?f3<-   (agentstatus (step ?i) (time ?t))
?f4<-   (penalty ?p)
=> 
    (modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
    (modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
    (assert (penalty (+ ?p 500000)))
    (retract ?f4)
)

;// Regole per il CheckFinish
;// Operazione OK- risposta yes
(defrule CheckFinish_OK_YES
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
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
(defrule CheckFinish_OK_NO
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (clean no))
        (msg-to-agent  (request-time ?rt)  (step ?ii) (sender ?tb) (type order))
        (not (orderstatus (step ?i) (time ?t) (requested-by ?tb)))
        (not (cleanstatus (step ?i) (arrivaltime ?iii&:(> ?iii ?ii)) (requested-by ?tb)))
        (test (or (= (- ?t ?rt)  100) (< (- ?t ?rt)  100)))
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
    (assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish no)))
)

; operazione non serve, il tavolo ha già richiesto cleantable 
(defrule CheckFinish_useless-1
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (clean no))
        (msg-to-agent  (request-time ?rt)  (step ?ii&:(< ?ii ?i)) (sender ?tb) (type order))
        (cleanstatus (step ?i) (arrivaltime ?iii&:(> ?iii ?ii)) (requested-by ?tb))
?f4<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
    (assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish yes))
                (penalty (+ ?p 10000)))
        (retract ?f4)
)

;// operazione non serve, il tavolo è gia pulito
(defrule CheckFinish_useless-2
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (clean yes))
?f4<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
    (assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish yes))
                (penalty (+ ?p 10000)))
        (retract ?f4)
)

;// Operazione sbagliata perchè chiede finish prima che l'ordine sia stato completato
(defrule CheckFinish_Useless-3
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (clean no))
        (msg-to-agent  (request-time ?rt)  (step ?ii) (sender ?tb) (type order))
        (orderstatus (step ?i) (time ?t) (requested-by ?tb))
?f4<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
    (assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish no))
                (penalty (+ ?p 100000)))
        (retract ?f4)
)

;// operazione di checkFinish fatta su tavolo che non ha fatto richiesta
(defrule CheckFinish_useless-4
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (clean no))
        (not (msg-to-agent  (request-time ?rt)  (step ?ii&:(< ?ii ?i)) (sender ?tb) (type order)))
?f4<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
    (assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish no))
                (penalty (+ ?p 100000)))
        (retract ?f4)
)

;// L'azione di CheckFinish  fallisce perchè l'agente non è accanto ad un tavolo 
(defrule CheckFinish_KO_1
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceTable ?tb ?rr ?cc))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
    (assert (penalty (+ ?p  500000)))
        (retract ?f5)
) 

;// L'azione di CheckFinish fallisce perchè la posizione indicata non 
;//contiene un tavolo 
(defrule CheckFinish_KO_2
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
    (not (Table (table-id ?tb) (pos-r ?x) (pos-c ?y)))
?f1<-   (agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
    (assert (penalty (+ ?p  500000)))
        (retract ?f5)
) 

;// __________________________________________________________________________________________
;// REGOLE PER il Clean Table

;// Operazione OK
(defrule CleanTable_OK_1
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld&:(> ?tld 0)) (l-food ?tlf&:(> ?tlf 0)))
?f4<-   (cleanstatus (step ?i) (requested-by ?tb))
=> 
    (modify ?f2 (step (+ ?i 1)) 
                    (time (+ ?t (+ 10 
                                   (* 2 ?tld) 
                                   (* 3 ?tlf))))
        )
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld) (* 3 ?tlf)))) 
                    (l_d_waste yes) (l_f_waste yes))
    (modify ?f3 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld) (* 3 ?tlf)))) 
                    (l-drink 0) (l-food 0) (clean yes))
    (retract ?f4)
)

(defrule CleanTable_OK_2
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld&:(> ?tld 0)) (l-food 0))
?f4<-   (cleanstatus (step ?i) (requested-by ?tb))
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld)))))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld)))) 
                    (l_d_waste yes) (l_f_waste ?fw))
    (modify ?f3 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld)))) 
                    (l-drink 0) (l-food 0) (clean yes))
    (retract ?f4)
)

;// Operazione OK
(defrule CleanTable_OK_3
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (l-drink 0) (l-food ?tlf&:(> ?tlf 0)))
?f4<-   (cleanstatus (step ?i) (requested-by ?tb))
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t (+ 10  (* 3 ?tlf)))))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t (+ 10  (* 3 ?tlf)))) 
                    (l_d_waste ?dw) (l_f_waste yes))
    (modify ?f3 (step (+ ?i 1)) (time (+ ?t (+ 10  (* 3 ?tlf)))) 
                    (l-drink 0) (l-food 0) (clean yes))
    (retract ?f4)
)

;// CleanTable  ha fisicamente successo ma fatta quando non 
;// c'è  richiesta di cleanTable o dopo CheckFinish positiva
(defrule CleanTable_K0_1
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf)(clean no))
    (not (cleanstatus (step ?i) (requested-by ?tb)))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) 
                    (time (+ ?t (+ 10 
                                   (* 2 ?tld) 
                                   (* 3 ?tlf))))
        )
    (modify ?f1 (step (+ ?i 1)) 
                    (time (+ ?t (+ 10 (* 2 ?tld) (* 3 ?tlf)))) 
                    (l_d_waste yes) (l_f_waste yes))
    (modify ?f3 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld) (* 3 ?tlf))))
                    (l-drink 0) (l-food 0) (clean yes))
    (assert (penalty (+ ?p 500000)))
        (retract ?f5)
)

;// azione inutile di cleantable perchè il tavolo è già pulito
(defrule CleanTable_K0_2
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (clean yes))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 30)) 
                    (l_d_waste ?dw) (l_f_waste ?fw))
    (modify ?f3 (step (+ ?i 1)) (time (+ ?t 30)))
    (assert (penalty (+ ?p 10000)))
        (retract ?f5)
)

;// il robot tenta di fare CleanTable  ma fallisce perchè sta già trasportando cibo 
;// e o bevande
(defrule CleanTable_KO_3
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-drink ?ld) (l-food ?lf))
        (test (> (+ ?ld ?lf) 0))
        (serviceTable ?tb ?rr ?cc)
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 30)))
    (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)    

;// L'azione di CleanTable fallisce perchè l'agente non è accanto ad un tavolo 
(defrule CleanTable_KO_4
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceTable ?tb ?rr ?cc))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
    (assert (penalty (+ ?p  500000)))
        (retract ?f5)
) 

;// L'azione di CleanTable fallisce perchè la posizione indicata non 
;//contiene un tavolo 
(defrule CleanTable_KO_5
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
    (not (Table (table-id ?tb) (pos-r ?x) (pos-c ?y)))
?f1<-   (agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
    (assert (penalty (+ ?p  500000)))
        (retract ?f5)
) 


;// __________________________________________________________________________________________
;// REGOLE PER il EmptyFood

;// Operazione OK
(defrule EmptyFood_OK
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))
    (TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_f_waste yes))
        (serviceTB ?trb ?rr ?cc)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)) (l_f_waste no))
)

;// Operazione inutile perchè agente non ha avanzi di cibo a bordo
(defrule EmptyFood_KO1
    (declare (salience 20))       
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))
    (TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_f_waste no))
        (serviceTB ?trb ?rr ?cc)
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)) (l_f_waste no))
        (assert (penalty (+ ?p  10000)))
        (retract ?f5)
)    

;// Operazione fallisce perchè l'agente non è adiacente a un TrashBasket
(defrule EmptyFood_KO2
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))
    (TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceTB ?trb ?rr ?cc))
?f5<-   (penalty ?p)    
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)

;// Operazione fallisce perchè la cella indicata non è un TrashBasket
(defrule EmptyFood_KO3
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))
    (not (TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y)))
?f1<-   (agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)    
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)


;// __________________________________________________________________________________________
;// REGOLE PER il Release (svuota contenitori bevande in RecyclableBasket)

;// Operazione OK
(defrule Release_OK
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action Release) (param1 ?x) (param2 ?y))
    (RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_d_waste yes))
        (serviceRB ?rb ?rr ?cc)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)) (l_d_waste no))
)

;// Operazione inutile perchè agente non ha contenitori di bevande a bordo
(defrule Release_KO1
    (declare (salience 20))       
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action Release) (param1 ?x) (param2 ?y))
    (RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_d_waste no))
        (serviceRB ?rb ?rr ?cc)
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)) (l_d_waste no))
        (assert (penalty (+ ?p  10000)))
        (retract ?f5)
)    

;// Operazione fallisce perchè l'agente non è adiacente a un RecyclableBasket
(defrule Release_KO2
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action Release) (param1 ?x) (param2 ?y))
    (RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceRB ?rb ?rr ?cc))
?f5<-   (penalty ?p)    
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)

;// Operazione fallisce perchè la cella indicata non è un RecyclableBasket
(defrule Release_KO3
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action Release) (param1 ?x) (param2 ?y))
    (not (RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y)))
?f1<-   (agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)    
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)

;// REGOLE PER WAIT
(defrule WAIT
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action Wait))
?f1<-   (agentstatus (step ?i) (time ?t))   
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 10)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 10)))
)

;// __________________________________________________________________________________________
;// REGOLE PER il prelievo di Food da food Dispenser

;// Operazione OK
(defrule load-food_OK
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
    (FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceFD ?fd ?rr ?cc)
        (test (< (+ ?lf ?ld) 4))
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)) (l-food (+ ?lf 1)))
)

;// Operazione fallisce perchè l'agente è già a pieno carico
(defrule load-food_KO1
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
    (FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceFD ?fd ?rr ?cc)
        (test (= (+ ?lf ?ld) 4))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))
        (assert (penalty (+ ?p  100000)))
        (retract ?f5)
)    

;// Operazione fallisce perchè l'agente è già carico di immondizia
(defrule load-food_KO2
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
    (FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceFD ?fd ?rr ?cc)
        (test (or (eq ?dw yes) (eq ?fw yes)))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)

;// Operazione fallisce perchè l'agente non è adiacente a un FoodDispenser
(defrule load-food_KO3
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
    (FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceFD ?fd ?rr ?cc))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)

;// Operazione fallisce perchè la cella indicata non è un FoodDispenser
(defrule load-food_KO4
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
    (not (FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y)))
?f1<-   (agentstatus (step ?i) (time ?t))
 
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)

;// __________________________________________________________________________________________
;// REGOLE PER il prelievo di drink da drink Dispenser

;// Operazione OK
(defrule load-drink_OK
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
    (DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceDD ?dd ?rr ?cc)
        (test (< (+ ?lf ?ld) 4))
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)) (l-drink (+ ?ld 1)))
)

;// Operazione fallisce perchè l'agente è già a pieno carico
(defrule load-drink_KO1
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
    (DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceDD ?dd ?rr ?cc)
        (test (= (+ ?lf ?ld) 4))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
        (assert (penalty (+ ?p  100000)))
        (retract ?f5)
)    

;// Operazione fallisce perchè l'agente è già carico di immondizia
(defrule load-drink_KO2
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
    (DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceDD ?dd ?rr ?cc)
        (test (or (eq ?dw yes) (eq ?fw yes)))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)

;// Operazione fallisce perchè l'agente non è adiacente a un drinkDispenser
(defrule load-drink_KO3
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
    (DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t)(pos-r ?rr) (pos-c ?cc))
        (not (serviceDD ?dd ?rr ?cc))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)

;// Operazione fallisce perchè la cella indicata non è un drinkDispenser
(defrule load-drink_KO4
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
    (not (DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y)))
?f1<-   (agentstatus (step ?i) (time ?t))
 
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
        (assert (penalty (+ ?p  500000)))
        (retract ?f5)
)

    
;// __________________________________________________________________________________________
;// REGOLE PER LA CONSEGNA Di Food ad un tavolo
;// consegna Food su un tavolo che ha ordine ancora aperto
;// le penalità di riferiscono alla durata dell'azione (4 unità di tempo) 
;// per i punti (2) per i cibi e bevande non ancora consegnati 
(defrule delivery-food_OK
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action DeliveryFood) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?alf&:(> ?alf 0)))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
?f4<-   (orderstatus (step ?i) (requested-by ?tb) (food-order ?nfo) (food-deliv ?dfo&:(< ?dfo ?nfo))
                     (drink-order ?ndo) (drink-deliv ?ddo))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (- ?alf 1)))
    (modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (+ ?tlf 1)) (clean no))
    (modify ?f4 (step (+ ?i 1)) (time (+ ?t 4)) (food-deliv ( + ?dfo 1)))
    (assert (penalty (+ ?p  (max  1 (* 8 (+ (- ?ndo ?ddo) (- ?nfo  (+ ?dfo 1))))))))
        (retract ?f5)
)

;// assegna una penalità nel caso in cui si tenti di consegnare un cibo ad un tavolo
;// quando l'ordinazione è già stata completata (ordestatus eleinato) o non è mai stato fatto
(defrule delivery-food_WRONG_2
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action DeliveryFood) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?alf&:(> ?alf 0)))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
    (not (orderstatus (step ?i) (requested-by ?tb))) 
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (- ?alf 1)))
    (modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (+ ?tlf 1)))
    (assert (penalty (+ ?p  500000)))
        (retract ?f5)
) 

;// il robot tenta di fare una delivery-food  ma non sta trasportando cibo
(defrule delivery-food_WRONG_3
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action DeliveryFood) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?alf&:(= ?alf 0)))
        (serviceTable ?tb ?rr ?cc)
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)))
    (assert (penalty (+ ?p  100000)))
        (retract ?f5)
)   

;// __________________________________________________________________________________________
;// REGOLE PER LA CONSEGNA Di DRINK ad un tavolo
;// consegna drink a un tavolo che ha ordine ancora aperto
;// le penalità di riferiscono alla durata dell'azione (4 unità di tempo) 
;// per i punti (2) per i cibi e bevande non ancora consegnati 
(defrule delivery-drink_OK
    (declare (salience 20))    
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action DeliveryDrink) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-drink ?ald&:(> ?ald 0)))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
?f4<-   (orderstatus (step ?i) (requested-by ?tb) (food-order ?nfo) (food-deliv ?dfo)
                     (drink-order ?ndo) (drink-deliv ?ddo&:(< ?ddo ?ndo)))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (- ?ald 1)))
    (modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (+ ?tld 1)) (clean no))
    (modify ?f4 (step (+ ?i 1)) (time (+ ?t 4))  (drink-deliv ( + ?ddo 1)))
    (assert (penalty (+ ?p  (max 1 (* 8 (+ (- ?nfo ?dfo) (- ?ndo  (+ ?ddo 1))))))))
        (retract ?f5)
)


;// assegna una penalità nel caso in cui si tenti di consegnare un cibo ad un tavolo
;// quando l'ordinazione è già stata completata o non è stato fatto ordine
(defrule delivery-drink_WRONG_2
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action DeliveryDrink) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-drink ?ald&:(> ?ald 0)))
        (serviceTable ?tb ?rr ?cc)
?f3<-   (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
    (not (orderstatus (step ?i) (requested-by ?tb))) 
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (- ?ald 1)))
    (modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (+ ?tld 1)))
    (assert (penalty (+ ?p  500000)))
        (retract ?f5)
) 


;// il robot tenta di fare una delivery-food  ma non sta trasportando cibo
(defrule delivery-drink_WRONG_3
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action DeliveryDrink) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-drink ?ald&:(= ?ald 0)))
        (serviceTable ?tb ?rr ?cc)
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)))
    (assert (penalty (+ ?p  100000)))
        (retract ?f5)
)    

;// L'azione di delivery-food o delivery-drink fallisce perchè l'agente non è accanto ad un tavolo 
(defrule delivery_WRONG_4
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action DeliveryFood|DeliveryDrink) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-   (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceTable ?tb ?rr ?cc))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 4))) 
    (assert (penalty (+ ?p  500000)))
        (retract ?f5)
) 

;// L'azione di delivery-food o o delivery-drink fallisce perchè la posizione indicata non 
;//contiene un tavolo 
(defrule delivery_WRONG_5
    (declare (salience 20))
?f2<-   (status (time ?t) (step ?i)) 
    (exec (step ?i) (action DeliveryFood|DeliveryDrink) (param1 ?x) (param2 ?y))
    (not (Table (table-id ?tb) (pos-r ?x) (pos-c ?y)))
?f1<-   (agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)
=> 
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 4))) 
    (assert (penalty (+ ?p  500000)))
        (retract ?f5)
) 
(defrule order-completed
        (declare (salience 18))
    (status (time ?t) (step ?i)) 
    (exec (step ?ii&:(= ?ii (- ?i 1))) (action DeliveryFood|DeliveryDrink) (param1 ?x) (param2 ?y))
    (Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1 <-  (orderstatus (step ?i) (requested-by ?tb) (food-order ?nfo) (food-deliv ?dfo&:(= ?dfo ?nfo))
                     (drink-order ?ndo) (drink-deliv ?ddo&:(= ?ddo  ?ndo)))
=>    (retract ?f1)
)

; Fatta DOPO aver compiuto una azione

(defrule perc-load-generation1
        (declare (salience 19))
    (status (time ?t) (step ?i)) 
    (exec (step ?ii&:(= ?ii (- ?i 1))) (action DeliveryFood|DeliveryDrink|LoadDrink|LoadFood))
        (agentstatus (step ?i)  (l-drink  0) (l-food 0))    
=>      (assert (perc-load (time ?t) (step ?i) (load no)))
)
(defrule perc-load-generation2
        (declare (salience 19))
    (status (time ?t) (step ?i)) 
    (exec (step ?ii&:(= ?ii (- ?i 1))) (action DeliveryFood|DeliveryDrink|LoadDrink|LoadFood))
        (agentstatus (step ?i)  (l-drink  ?ld) (l-food ?lf))
        (test (> (+ ?ld ?lf) 0))    
=>      (assert (perc-load (time ?t) (step ?i) (load yes)))
)

;//  REGOLE PER MOVIMENTO
(defrule forward-north-ok 
    (declare (salience 20))    
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
    (cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking))
=> 
    (modify ?f1 (pos-r (+ ?r 1)) (step (+ ?i 1)) (time (+ ?t 2)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))        
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: Forward" crlf) 
;   (printout t " - in direzione: north" crlf)
;   (printout t " - nuova posizione dell'agente: (" (+ ?r 1) "," ?c ")" crlf)   
) 
 
(defrule forward-north-bump 
    (declare (salience 20))    
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
    (cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains ~Empty&~Parking))
?f3<-   (penalty ?p)
=> 
    (modify ?f1  (step (+ ?i 1)) (time (+ ?t 2)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
    (assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction north) (bump yes)))
    (retract ?f3)
    (assert (penalty (+ ?p 10000000)))
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - penalità +10000000 (Forward-north-bump): " (+ ?p 10000000) crlf)
)
 
(defrule forward-south-ok 
    (declare (salience 20))    
?f2<-   (status (step ?i) (time ?t))  
    (exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
    (cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking))
=> 
    (modify ?f1 (pos-r (- ?r 1)) (step (+ ?i 1)) (time (+ ?t 2)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))    
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: Forward" crlf) 
;   (printout t " - in direzione: south" crlf)
;   (printout t " - nuova posizione dell'agente: (" (- ?r 1) "," ?c ")" crlf)
)
  
(defrule forward-south-bump 
    (declare (salience 20))    
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
    (cell (pos-r =(- ?r 1)) (pos-c ?c) (contains ~Empty&~Parking))
?f3<-   (penalty ?p)
=> 
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 2)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
    (assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction south) (bump yes)))
    (retract ?f3)
    (assert (penalty (+ ?p 10000000)))
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - penalità +10000000 (forward-south-bump): " (+ ?p 10000000) crlf)
) 

(defrule forward-west-ok 
    (declare (salience 20))    
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
    (cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking))
=> 
    (modify ?f1 (pos-c (- ?c 1)) (step (+ ?i 1)) (time (+ ?t 2)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))    
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: Forward" crlf) 
;   (printout t " - in direzione: west" crlf)
;   (printout t " - nuova posizione dell'agente: (" ?r "," (- ?c 1) ")" crlf)   
)

(defrule forward-west-bump 
    (declare (salience 20))    
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
    (cell (pos-r ?r) (pos-c =(- ?c 1)) (contains ~Empty&~Parking))
?f3<-   (penalty ?p)
=> 
    (modify  ?f1  (step (+ ?i 1)) (time (+ ?t 2)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
    (assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction west) (bump yes)))
    (retract ?f3)
    (assert (penalty (+ ?p 10000000)))
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - penalità +10000000 (forward-west-bump): " (+ ?p 10000000) crlf)
)

(defrule forward-east-ok 
    (declare (salience 20))    
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))
    (cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking))
=> 
    (modify  ?f1 (pos-c (+ ?c 1)) (step (+ ?i 1)) (time (+ ?t 2)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))    
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: Forward" crlf) 
;   (printout t " - in direzione: east" crlf)
;   (printout t " - nuova posizione dell'agente: (" ?r "," (+ ?c 1) ")" crlf)
) 

(defrule forward-east-bump 
    (declare (salience 20))    
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))
    (cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains ~Empty&~Parking))
?f3<-   (penalty ?p)
=> 
    (modify  ?f1  (step (+ ?i 1)) (time (+ ?t 2)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
    (assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction east) (bump yes)))
    (retract ?f3)
    (assert (penalty (+ ?p 10000000)))
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - penalità +10000000 (forward-east-bump): " (+ ?p 10000000) crlf)
)

(defrule turnleft1
    (declare (salience 20))      
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Turnleft))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
    (cell (pos-r ?r) (pos-c ?c))
=>  
    (modify  ?f1 (direction south) (step (+ ?i 1)) (time (+ ?t 1)) )
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)) )       
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: turnleft" crlf)    
;   (printout t " - nuova direzione dell'agente: south" crlf)
)

(defrule turnleft2
    (declare (salience 20))      
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Turnleft))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
    (cell (pos-r ?r) (pos-c ?c))
=> 
    (modify  ?f1 (direction east) (step (+ ?i 1)) (time (+ ?t 1)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))        
;   (printout t " ENVIRONMENT:" crlf)
;       (printout t " - azione eseguita: turnleft" crlf)    
;       (printout t " - nuova direzione dell'agente: east" crlf)
)

(defrule turnleft3
    (declare (salience 20))      
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Turnleft))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))
    (cell (pos-r ?r) (pos-c ?c))
=> 
    (modify  ?f1 (direction north) (step (+ ?i 1)) (time (+ ?t 1)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))        
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: turnleft" crlf)    
;   (printout t " - nuova direzione dell'agente: north" crlf)
)

(defrule turnleft4
    (declare (salience 20))      
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Turnleft))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
    (cell (pos-r ?r) (pos-c ?c))
=> 
    (modify  ?f1 (direction west) (step (+ ?i 1)) (time (+ ?t 1)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))        
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: turnleft" crlf)    
;   (printout t " - nuova direzione dell'agente: west" crlf)
)

(defrule turnright1
    (declare (salience 20))      
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Turnright))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
    (cell (pos-r ?r) (pos-c ?c))
=> 
    (modify  ?f1 (direction north) (step (+ ?i 1))  (time (+ ?t 1)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))        
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: turnright" crlf)   
;   (printout t " - nuova direzione dell'agente: north" crlf)
)

(defrule turnright2
    (declare (salience 20))      
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Turnright))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
    (cell (pos-r ?r) (pos-c ?c))
=> 
    (modify  ?f1 (direction west) (step (+ ?i 1)) (time (+ ?t 1)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))        
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: turnright" crlf)   
;   (printout t " - nuova direzione dell'agente: west" crlf)
)

(defrule turnright3
    (declare (salience 20))      
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Turnright))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c) (direction east))
    (cell (pos-r ?r) (pos-c ?c))
=> 
    (modify ?f1 (direction south) (step (+ ?i 1)) (time (+ ?t 1)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))        
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: turnright" crlf)   
;   (printout t " - nuova direzione dell'agente: south" crlf)
)

(defrule turnright4
    (declare (salience 20))      
?f2<-   (status (step ?i) (time ?t)) 
    (exec (step ?i) (action  Turnright))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
    (cell (pos-r ?r) (pos-c ?c))
=> 
    (modify ?f1 (direction east) (step (+ ?i 1)) (time (+ ?t 1)))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))        
;   (printout t " ENVIRONMENT:" crlf)
;   (printout t " - azione eseguita: turnright" crlf)   
;   (printout t " - nuova direzione dell'agente: east" crlf)
)

;// __________________________________________________________________________________________
;// REGOLE PER PERCEZIONI VISIVE (N, S, E, O)          
;// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
(defrule percept-north
    (declare (salience 5))
?f1<-   (agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction north)) 
    (cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (contains ?x1))
    (cell (pos-r =(+ ?r 1)) (pos-c ?c)      (contains ?x2))
    (cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains ?x3))
    (cell (pos-r ?r)        (pos-c =(- ?c 1)) (contains ?x4))
    (cell (pos-r ?r)        (pos-c ?c)      (contains ?x5))
    (cell (pos-r ?r)        (pos-c =(+ ?c 1)) (contains ?x6))
    (cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains ?x7))
    (cell (pos-r =(- ?r 1)) (pos-c ?c)      (contains ?x8))
    (cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains ?x9))
=> 
    (assert     
        (perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction north) 
            (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
            (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
            (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
        )
    )
    (focus MAIN)
)

(defrule percept-south
    (declare (salience 5))
?f1<-   (agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction south)) 
    (cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains ?x1))
    (cell (pos-r =(- ?r 1)) (pos-c ?c)      (contains ?x2))
    (cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains ?x3))
    (cell (pos-r ?r)    (pos-c =(+ ?c 1)) (contains ?x4))
    (cell (pos-r ?r)    (pos-c ?c)      (contains ?x5))
    (cell (pos-r ?r)    (pos-c =(- ?c 1)) (contains ?x6))
    (cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains ?x7))
    (cell (pos-r =(+ ?r 1)) (pos-c ?c)      (contains ?x8))
    (cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (contains ?x9))
=> 
    (assert     
        (perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction south) 
            (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
            (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
            (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
        )
    )
    (focus MAIN)
)

(defrule percept-east
    (declare (salience 5))
?f1<-   (agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction east)) 
    (cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains ?x1))
    (cell (pos-r ?r)    (pos-c =(+ ?c 1)) (contains ?x2))
    (cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains ?x3))
    (cell (pos-r =(+ ?r 1)) (pos-c ?c)      (contains ?x4))
    (cell (pos-r ?r)    (pos-c ?c)      (contains ?x5)) 
    (cell (pos-r =(- ?r 1)) (pos-c ?c)      (contains ?x6))
    (cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1))   (contains ?x7))
    (cell (pos-r ?r)        (pos-c =(- ?c 1)) (contains ?x8))
    (cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains ?x9))
=>  
    (assert     
        (perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction east) 
            (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
            (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
            (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
        )
    )
    (focus MAIN)
)

(defrule percept-west
    (declare (salience 5))
?f1<-   (agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction west)) 
    (cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains ?x1))
    (cell (pos-r ?r)    (pos-c =(- ?c 1)) (contains ?x2))
    (cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (contains ?x3))
    (cell (pos-r =(- ?r 1)) (pos-c ?c)      (contains ?x4))
    (cell (pos-r ?r)    (pos-c ?c)      (contains ?x5))
    (cell (pos-r =(+ ?r 1)) (pos-c ?c)      (contains ?x6))
    (cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains ?x7))   
    (cell (pos-r ?r)    (pos-c =(+ ?c 1)) (contains ?x8))   
    (cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains ?x9))
=> 
    (assert     
        (perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction west) 
            (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
            (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
            (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
        )
    )
    (focus MAIN)
)


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@ --------- AGENT --------- @@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



; L'agente conosce il mondo con fatti di tipo K-qualcosa. 
; Tali fatti (K-agent e K-cell), rappresentano l'ultima informazione consistente che l'agente ha.
; La rappresentazione fine del tempo è in questa applicazione inutile: ci limitamo a conoscere l'ultimo stato.
(defmodule AGENT (import MAIN ?ALL) (export ?ALL))


; Stato di una cella dal punto di vista dell'agente 
(deftemplate K-cell  (slot pos-r) (slot pos-c) 
                   (slot contains (allowed-values Wall Person  Empty Parking Table Seat TrashBasket
                                                      RecyclableBasket DrinkDispenser FoodDispenser)))

; Mantiene lo step in cui è stata effettuata l'ultima percezione (onde evitare loop su una stessa percezione)
(deftemplate last-perc (slot step))

(deftemplate K-agent
        (slot step)
        (slot time) 
        (slot pos-r) 
        (slot pos-c) 
        (slot direction) 
        (slot l-drink)
        (slot l-food)
        (slot l_d_waste)
        (slot l_f_waste)
)

; Trasforma le prior-cell (quelle definite a monte nell'ambiente) in K-cell
(defrule  beginagent1
    (declare (salience 11))
    (status (step 0))
    (not (beginagent-done)) ;Andranno cancellate probabilmente
    (prior-cell (pos-r ?r) (pos-c ?c) (contains ?x)) 
=>
     (assert (K-cell (pos-r ?r) (pos-c ?c) (contains ?x)))
)
            
; Valorizza il K-agent con la sua posizione iniziale (sempre presa dalla mappa)
(defrule  beginagent2
    (declare (salience 11))
    (status (step 0))
    (not (beginagent-done)) ;Andranno cancellate probabilmente
    (initial_agentposition (pos-r ?r) (pos-c ?c) (direction ?d))
=> 
    (assert (K-agent (step 0) (time 0) (pos-r ?r) (pos-c ?c) (direction ?d)
                              (l-drink 0) (l-food 0) (l_d_waste no) (l_f_waste no)))
    ; la percezione precedente alla prima "non esiste" (è a step -1)
    (assert (last-perc (step -1)))
    (assert (beginagent-done))
)

; Da una piccola interfaccia per chiedere un goal all'agente
(defrule ask-plan
    (declare (salience 4))
?f <-   (status (step ?i))
(not (planned-action $?)); Non ci sono azioni da mandare in esecuzione
(not (planned-goal $?))
(not (TRY ONE GOAL ONLY))
   => 
        (printout t crlf crlf " == AGENT ==" crlf) (printout t "Give me a goal to plan and exec (planned-goal ROW COL)" crlf)
        (assert (planned-goal 2 10))
        (assert (TRY ONE GOAL ONLY))
    ;    (assert (planned-goal 9 4))
    ;    (assert (planned-goal 6 10))
    ;    (assert (planned-goal 2 7))
    ;    (assert (planned-goal 4 5))
        (modify ?f (result no)))


; Esegue una pianificazione ed esecuzione del goal
(defrule start-planning
    (declare (salience 3))
    (K-agent (pos-r ?r) (pos-c ?c))
    (planned-goal ?goal-r ?goal-c )
 => (printout t crlf " == AGENT ==" crlf) (printout t "Starting to plan (" ?r ", "?c ") --> (" ?goal-r ", "?goal-c ")" crlf crlf)
        (assert (something-to-plan)) ; Avvisa che A star ha qualcosa da fare
        (focus PLANNER))

; Decodifica una azione data dal piano (planned-action) in forma di exec per l'ENV
(defrule decode-plan-execute
        (declare (salience 2))
 ?f <-   (status (step ?i))
 ?f2 <- (planned-action ?id ?oper ?r ?c) ; r e c non vengono utilizzati, ma possono essere utili da tenere nel fatto
=>
        (modify ?f (result no)) ; CHIEDERE AL PROF
        (retract ?f2)
        (assert (exec (step ?i) (action ?oper))) ) ; andrà in esecuzione effettivamente


; Esegue una singola exec del piano
(defrule exec-act
        (declare (salience 2))

    (status (step ?i))
    (exec (step ?i) (action ?oper))
 =>      (printout t crlf  "== AGENT ==" crlf) (printout t "Start the execution of the move: " ?oper)
        (focus MAIN))

(defrule end-plan-execute
        (declare (salience 1))
    (not (planned-action $?))
    ?f <- (status (result no)) ; QUESTA SERVE PER ESEGUIRE UN SOLO GOAL.
    => (printout t crlf " @@ AGENT @@ " crlf) (printout t "The execution of the plan is completed.")
        (modify ?f (result done)) ; ORA CHE VOGLIAMO UN SOLO GOAL.
    )



;// __________________________________________________________________________________________
;// REGOLE PER INTERPRETARE LE PERCEZIONI VISIVE (N, S, E, O)          
;// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

; Le percezioni modificano le K-cell (agente orientato west)
(defrule k-percept-west
	(declare (salience 2))
    (status (step ?s))
    ?ka <- (K-agent) ; recupera il K-agent
    ?fs <- (last-perc (step ?old-s))
    (test (> ?s ?old-s))
    (perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west) 
    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9))

    ?f1 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
    ?f2 <- (K-cell (pos-r ?r)   (pos-c =(- ?c 1)))
    ?f3 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
    ?f4 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f5 <- (K-cell (pos-r ?r)   (pos-c ?c) )
    ?f6 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c) )
    ?f7 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1))) 
    ?f8 <- (K-cell (pos-r ?r)   (pos-c =(+ ?c 1)))  
    ?f9 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
=> 
    (modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west)) ; Modifica il K-agent
    (modify ?f1 (contains ?x1))
    (modify ?f2 (contains ?x2))
    (modify ?f3 (contains ?x3))
    (modify ?f4 (contains ?x4))
    (modify ?f5 (contains ?x5))
    (modify ?f6 (contains ?x6))
    (modify ?f7 (contains ?x7))
    (modify ?f8 (contains ?x8))
    (modify ?f9 (contains ?x9))
    (modify ?fs (step ?s))
)

; Le percezioni modificano le K-cell (agente orientato east)
(defrule k-percept-east
	(declare (salience 2))
    (status (step ?s))
    ?ka <- (K-agent)
    ?fs <- (last-perc (step ?old-s))
    (test (> ?s ?old-s))
    (perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east) 
    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9))

    ?f1 <- (K-cell (pos-r ?r)   (pos-c =(+ ?c 1)))
    ?f2 <- (K-cell (pos-r ?r)   (pos-c =(+ ?c 1)))
    ?f3 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
    ?f4 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f5 <- (K-cell (pos-r ?r)   (pos-c ?c))
    ?f6 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f7 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1))) 
    ?f8 <- (K-cell (pos-r ?r)   (pos-c =(- ?c 1)))  
    ?f9 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
=> 
    (modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east)) ; Modifica il K-agent       
    (modify ?f1 (contains ?x1))
    (modify ?f2 (contains ?x2))
    (modify ?f3 (contains ?x3))
    (modify ?f4 (contains ?x4))
    (modify ?f5 (contains ?x5))
    (modify ?f6 (contains ?x6))
    (modify ?f7 (contains ?x7))
    (modify ?f8 (contains ?x8))
    (modify ?f9 (contains ?x9))
    (modify ?fs (step ?s))
)

; Le percezioni modificano le K-cell (agente orientato south)
(defrule k-percept-south
	(declare (salience 2))
    (status (step ?s))
    ?ka <- (K-agent)
    ?fs <- (last-perc (step ?old-s))
    (test (> ?s ?old-s))
    (perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south) 
    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9))

    ?f1 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
    ?f2 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f3 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
    ?f4 <- (K-cell (pos-r ?r)   (pos-c =(+ ?c 1)))
    ?f5 <- (K-cell (pos-r ?r)   (pos-c ?c))
    ?f6 <- (K-cell (pos-r ?r)   (pos-c =(- ?c 1)))
    ?f7 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
    ?f8 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f9 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
=> 
    (modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south)) ; Modifica il K-agent        
    (modify ?f1 (contains ?x1))
    (modify ?f2 (contains ?x2))
    (modify ?f3 (contains ?x3))
    (modify ?f4 (contains ?x4))
    (modify ?f5 (contains ?x5))
    (modify ?f6 (contains ?x6))
    (modify ?f7 (contains ?x7))
    (modify ?f8 (contains ?x8))
    (modify ?f9 (contains ?x9))
    (modify ?fs (step ?s))
)

; Le percezioni modificano le K-cell (agente orientato north)
(defrule k-percept-north
	(declare (salience 2))
    (status (step ?s))
    ?ka <- (K-agent)
    ?fs <- (last-perc (step ?old-s))
    (test (> ?s ?old-s))
    (perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction north) 
    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9))

    ?f1 <- (K-cell (pos-r =(+ ?r 1))    (pos-c =(- ?c 1)))
    ?f2 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f3 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
    ?f4 <- (K-cell (pos-r ?r)       (pos-c =(- ?c 1)))
    ?f5 <- (K-cell (pos-r ?r)       (pos-c ?c))
    ?f6 <- (K-cell (pos-r ?r)       (pos-c =(+ ?c 1)))
    ?f7 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
    ?f8 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f9 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
=> 
    (modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction north)) ; Modifica il K-agent
    (modify ?f1 (contains ?x1))
    (modify ?f2 (contains ?x2))
    (modify ?f3 (contains ?x3))
    (modify ?f4 (contains ?x4))
    (modify ?f5 (contains ?x5))
    (modify ?f6 (contains ?x6))
    (modify ?f7 (contains ?x7))
    (modify ?f8 (contains ?x8))
    (modify ?f9 (contains ?x9))
    (modify ?fs (step ?s))
)
    

    
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@ --------- PLANNER --------- @@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
(defmodule PLANNER (import AGENT ?ALL) (export ?ALL))

(deftemplate node (slot ident) (slot gcost) (slot fcost) (slot father) (slot pos-r)
                  (slot pos-c) (slot open) (slot direction))

(deftemplate newnode (slot ident) (slot gcost) (slot fcost) (slot father) (slot pos-r)
                  (slot pos-c) (slot direction))

; ############################# STATO INIZIALE #############################
; Verrà ridefinito in seguito con i valori del K-agent (dalla regola init-first-node)
; È definito -1 l'ident per permettere alla regola init-first-node di essere attivabile
; e di generare il nodo iniziale partendo dal K-agent
;(deffacts S0
;      (node (ident -1) (gcost 0) (fcost 0) (father NA) (pos-r 0) (pos-c 0) (direction north) (open yes)) 
;      (current 0)
;      (lastnode 0)
;      (open-worse 0)
;      (open-better 0)
;      (alreadyclosed 0)
;      (numberofnodes 0))

; Vecchia versione: ora il goal è dato in input
;(deffacts final
;      (planned-goal 9 4))


; Inizializza lo stato iniziale a partire da K-agent
(defrule init-first-node
(declare (salience 150)) ; assolutamente la prima regola ad essere eseguita
?ka <- (K-agent (pos-r ?r) (pos-c ?c) (direction ?d) )
(not (node)) ; non ci devono essere nodi definiti (quindi A star è all'inizio)
(something-to-plan) ; e qualcosa da pianificare (onde evitare loops di A star (nel senso del modulo))
=>
    (assert 
        (current 0)
        (lastnode 0)
        (open-worse 0)
        (open-better 0)
        (alreadyclosed 0)
        (numberofnodes 0)
        (node (ident 0) (gcost 0) (fcost 0) (father NA) (pos-r ?r) (pos-c ?c) (direction ?d) (open yes)))
)

(defrule achieved-goal
(declare (salience 100))
     (current ?id) ; Dato il corrente id
     (planned-goal ?r ?c) ; C'è questo goal
     (node (ident ?id) (pos-r ?r) (pos-c ?c) (gcost ?g)) ; Il nodo corrente è quello goal
        => (printout t " Esiste soluzione per goal (" ?r "," ?c ") con costo "  ?g crlf)
           (assert (stampa ?id)) ; Parte la stampa degli operatori
           )

(defrule stampaSol
(declare (salience 101))
?f<-(stampa ?id)
    (node (ident ?id) (father ?anc&~NA))  
    (plan-exec ?anc ?id ?oper ?r ?c)
=> (printout t " Eseguo azione " ?oper " da stato (" ?r "," ?c ") " crlf)
    (assert (planned-action ?id ?oper ?r ?c)) ; Fatti che l'agente leggerà per andare ad eseguire il piano
   (assert (stampa ?anc))
   (retract ?f)
)

(defrule print-fine
(declare (salience 102))
       (stampa ?id)
       (node (ident ?id) (father ?anc&NA))
       (open-worse ?worse)
       (open-better ?better)
       (alreadyclosed ?closed)
       (numberofnodes ?n )  
=> (printout t " stati espansi " ?n crlf)
   (printout t " stati generati già in closed " ?closed crlf)
   (printout t " stati generati già in open (open-worse) " ?worse crlf)
   (printout t " stati generati già in open (open-better) " ?better crlf)
    (focus PLAN-DEL) ; Va in DEL
)


; ######################### FORWARD ########################
; Dice che up è applicabile con ?r e ?c
(defrule forward-north-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction north) (open yes))
        (K-cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking)) ; devo verificare che non vi siano
   => (assert (apply ?curr forward-north ?r ?c)))


; Esegue effettivamente la up
(defrule forward-north-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n) ;ultimo nodo
 ?f1<-  (apply ?curr forward-north ?r ?c) ;ci vuole l'apply
        (node (ident ?curr) (gcost ?g)) ;prende il nodo corrente
        (planned-goal ?x ?y) ;ci serve per calcolare h (la funzione di Manhattan)
   =>   (assert (plan-exec ?curr (+ ?n 1) Forward ?r ?c) ; Azione definitiva, forward
        (newnode (ident (+ ?n 1)) (pos-r (+ ?r 1)) (pos-c ?c) (direction north) ;vado su
            (gcost (+ ?g 2)) (fcost (+ (abs (- ?x (+ ?r 1))) (abs (- ?y ?c)) ?g 2)) ;identifico il nodo come n+1, g = g+1, f = h+g
        ; La h è calcolata on the fly
        (father ?curr))) 
        (retract ?f1)
        (focus PLAN-NEW))


; Dice che up è applicabile con ?r e ?c
(defrule forward-south-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction south) (open yes))
        (K-cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking)) ; devo verificare che non vi siano
   => (assert (apply ?curr forward-south ?r ?c)))


; Esegue effettivamente la up
(defrule forward-south-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n) ;ultimo nodo
 ?f1<-  (apply ?curr forward-south ?r ?c) ;ci vuole l'apply
        (node (ident ?curr) (gcost ?g)) ;prende il nodo corrente
        (planned-goal ?x ?y) ; ci serve per calcolare h (la funzione di Manhattan)
   =>   (assert (plan-exec ?curr (+ ?n 1) Forward ?r ?c) ; Azione definitiva, forward
        (newnode (ident (+ ?n 1)) (pos-r (- ?r 1)) (pos-c ?c) (direction south);vado su
            (gcost (+ ?g 2)) (fcost (+ (abs (- ?x (- ?r 1))) (abs (- ?y ?c)) ?g 2)) ;identifico il nodo come n+1, g = g+1, f = h+g
        ; La h è calcolata on the fly
        (father ?curr))) 
        (retract ?f1)
        (focus PLAN-NEW))

; Dice che up è applicabile con ?r e ?c
(defrule forward-east-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction east) (open yes))
        (K-cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking)) ; devo verificare che non vi siano cose dentro
   => (assert (apply ?curr forward-east ?r ?c)))


; Esegue effettivamente la up
(defrule forward-east-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n) ;ultimo nodo
 ?f1<-  (apply ?curr forward-east ?r ?c) ;ci vuole l'apply
        (node (ident ?curr) (gcost ?g)) ;prende il nodo corrente
        (planned-goal ?x ?y) ; ci serve per calcolare h (la funzione di Manhattan)
   =>   (assert (plan-exec ?curr (+ ?n 1) Forward ?r ?c) ; Azione definitiva, forward
        (newnode (ident (+ ?n 1)) (pos-r ?r) (pos-c (+ ?c 1)) (direction east);vado su
            (gcost (+ ?g 2)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y (+ ?c 1))) ?g 2)) ;identifico il nodo come n+1, g = g+1, f = h+g
        ; La h è calcolata on the fly
        (father ?curr))) 
        (retract ?f1)
        (focus PLAN-NEW))


; Dice che up è applicabile con ?r e ?c
(defrule forward-west-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction west) (open yes))
        (K-cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking)) ; devo verificare che non vi siano
   => (assert (apply ?curr forward-west ?r ?c)))


; Esegue effettivamente la up
(defrule forward-west-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n) ;ultimo nodo
 ?f1<-  (apply ?curr forward-west ?r ?c) ;ci vuole l'apply
        (node (ident ?curr) (gcost ?g)) ;prende il nodo corrente
        (planned-goal ?x ?y) ; ci serve per calcolare h (la funzione di Manhattan)
   =>   (assert (plan-exec ?curr (+ ?n 1) Forward ?r ?c) ; Azione definitiva, forward
        (newnode (ident (+ ?n 1)) (pos-r ?r) (pos-c (- ?c 1)) (direction west);vado su
            (gcost (+ ?g 2)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y (- ?c 1))) ?g 2)) ;identifico il nodo come n+1, g = g+1, f = h+g
        ; La h è calcolata on the fly
        (father ?curr))) 
        (retract ?f1)
        (focus PLAN-NEW))


; ############### TURNLEFT #############
(defrule turnleft-north-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction north) (open yes))
   => (assert (apply ?curr turnleft-north ?r ?c))
              )

(defrule turnleft-north-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnleft-north ?r ?c)
        (node (ident ?curr) (gcost ?g))
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 2) Turnleft ?r ?c)
              (newnode (ident (+ ?n 2)) (pos-r ?r) (pos-c ?c) (direction west)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1))     ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnleft-south-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction south) (open yes))
   => (assert (apply ?curr turnleft-south ?r ?c))
              )

(defrule turnleft-south-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnleft-south ?r ?c)
        (node (ident ?curr) (gcost ?g))
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 2) Turnleft ?r ?c)
              (newnode (ident (+ ?n 2)) (pos-r ?r) (pos-c ?c) (direction east)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnleft-east-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction east) (open yes))
   => (assert (apply ?curr turnleft-east ?r ?c)))

(defrule turnleft-east-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnleft-east ?r ?c)
        (node (ident ?curr) (gcost ?g) )
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 2) Turnleft ?r ?c)
              (newnode (ident (+ ?n 2)) (pos-r ?r) (pos-c ?c) (direction north)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnleft-west-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction west) (open yes))
   => (assert (apply ?curr turnleft-west ?r ?c))
              )

(defrule turnleft-west-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnleft-west ?r ?c)
        (node (ident ?curr) (gcost ?g) )
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 2) Turnleft ?r ?c)
              (newnode (ident (+ ?n 2)) (pos-r ?r) (pos-c ?c) (direction south)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))


; ############### TURNRIGHT #############
(defrule turnright-north-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction north) (open yes))
   => (assert (apply ?curr turnright-north ?r ?c)))

(defrule turnright-north-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnright-north ?r ?c)
        (node (ident ?curr) (gcost ?g))
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 3) Turnright ?r ?c)
              (newnode (ident (+ ?n 3)) (pos-r ?r) (pos-c ?c) (direction east)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnright-south-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction south) (open yes))
   => (assert (apply ?curr turnright-south ?r ?c)))

(defrule turnright-south-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnright-south ?r ?c)
        (node (ident ?curr) (gcost ?g) )
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 3) Turnright ?r ?c)
              (newnode (ident (+ ?n 3)) (pos-r ?r) (pos-c ?c) (direction west)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnright-east-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction east) (open yes))
   => (assert (apply ?curr turnright-east ?r ?c)))

(defrule turnright-east-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnright-east ?r ?c)
        (node (ident ?curr) (gcost ?g) )
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 3) Turnright ?r ?c)
              (newnode (ident (+ ?n 3)) (pos-r ?r) (pos-c ?c) (direction south)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnright-west-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction west) (open yes))
   => (assert (apply ?curr turnright-west ?r ?c)))

(defrule turnright-west-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnright-west ?r ?c)
        (node (ident ?curr) (gcost ?g))
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 3) Turnright ?r ?c)
              (newnode (ident (+ ?n 3)) (pos-r ?r) (pos-c ?c) (direction north)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

; Ne cerca uno nuovo (perché il branching di ?curr è stato tutto espletato)
(defrule change-current
         (declare (salience 49)) ; Salience leggermente più bassa: eseguita quando non c'è altro di applicabile (una azione)
?f1 <-   (current ?curr)
?f2 <-   (node (ident ?curr)) ;nodo corrente
         (node (ident ?best&:(neq ?best ?curr)) (fcost ?bestcost) (open yes)) ; Scelgo un nodo open tale che  
         (not (node (ident ?id&:(neq ?id ?curr)) (fcost ?gg&:(< ?gg ?bestcost)) (open yes))); non ne esista uno diverso da quello di sopra, in open e tale per cui ha costo migliore di quello di prima
?f3 <-   (lastnode ?last) 
   =>    (assert (current ?best) (lastnode (+ ?last 4))) ; Il nuovo corrente non è più quello corrente ma best (un nuovo id)
         (retract ?f1 ?f3)
         (modify ?f2 (open no))) 

; La strategia termina quando la lista open è vuota
(defrule close-empty
         (declare (salience 49))
?f1 <-   (current ?curr)
?f2 <-   (node (ident ?curr))
         (not (node (ident ?id&:(neq ?id ?curr))  (open yes)))
     => 
         (retract ?f1)
         (modify ?f2 (open no))
         (printout t " fail (last  node expanded " ?curr ")" crlf)
         (halt))       

; ############################################# 
; Modulo PLAN-NEW: NECESSARIO PER IL PLANNER
; ############################################
(defmodule PLAN-NEW (import PLANNER ?ALL) (export ?ALL))

; Il newnode è un doppione di un nodo già chiuso
(defrule check-closed
(declare (salience 50)) 
 ?f1 <-    (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d)) ;se ho generato un nodo per la posizione r e c orientato d
           (node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (open no)) ;c'è un nodo che ha quello stato ed è già in closed
 ?f2 <-    (alreadyclosed ?a) ; contatore di nodi chiusi
    =>
           (assert (alreadyclosed (+ ?a 1))) ; contatore di nodi chiusi
           (retract ?f1) ;retracto e butto via, tanto l'avevo già chiuso
           (retract ?f2)
           (pop-focus))

; Cancella nodo nuovo che sia peggiore di uno già nella coda
(defrule check-open-worse
(declare (salience 50)) 
 ?f1 <-    (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (father ?anc)) ;il nuovo nodo
           (node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g-old) (open yes)) ;ma ne esiste un altro, sempre in open, che ha già costo migliore di quello appena aperto
           (test (or (> ?g ?g-old) (= ?g-old ?g)))
 ?f2 <-    (open-worse ?a)
    =>
           (assert (open-worse (+ ?a 1))) ;butto via
           (retract ?f1)
           (retract ?f2)
           (pop-focus))

; Cancella nodo vecchio in coda che sia peggiore di uno appena trovato
(defrule check-open-better
(declare (salience 50)) 
 ?f1 <-    (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f) (father ?anc))
 ?f2 <-    (node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g-old) (open yes))
           (test (<  ?g ?g-old))
 ?f3 <-    (open-better ?a)
    =>     (assert (node (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f) (father ?anc) (open yes)))
           (assert (open-better (+ ?a 1)))
           (retract ?f1 ?f2 ?f3)
           (pop-focus))

; Se nessuna delle precedenti è eseguito, lo metto semplicemente come nuovo nodo (newnode diventa un nodo a tutti gli effetti)
(defrule add-open
       (declare (salience 49))
 ?f1 <-    (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f)(father ?anc))
 ?f2 <-    (numberofnodes ?a)
    =>     (assert (node (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f)(father ?anc) (open yes)))
           (assert (numberofnodes (+ ?a 1)))
           (retract ?f1 ?f2)
           (pop-focus))


; ############################################# 
; Modulo PLAN-DEL: NECESSARIO PER IL PLANNER (cancellare)
; ############################################
(defmodule PLAN-DEL (import PLANNER ?ALL))

; Rimuove prima di tutto i node
(defrule remove-node-facts
     (declare (salience 1))
    ?f <- (node) ; qualsiasi nodo tranne quello con ident -1 (che genereremo successivamente)
    => (retract ?f)
) 

; Poi rimuove i plan exec
(defrule clean-plan-exec-facts
     (declare (salience 1))    
    ?f <- (plan-exec $?)
    => (retract ?f)
)

; Poi ristabilisce la situazione per il prossimo planning
(defrule delete-general
    ?f <- (current $?)
    ?f2 <- (lastnode $?)
    ?f3 <- (open-worse $?)
    ?f4 <- (open-better $?)
    ?f5 <- (alreadyclosed $?)
    ?f6 <- (numberofnodes $?)
    ?f7 <- (stampa $?)
    => (retract ?f) (retract ?f2) (retract ?f3) (retract ?f4) (retract ?f5) (retract ?f6) (retract ?f7)
)

; Rimuove il goal
(defrule remove-goal-fact
    ?f <- (planned-goal $?)
    => (retract ?f)
) 

(defrule back-to-planner
    (declare (salience -1))
    ?f <- (something-to-plan)
    =>
    (retract ?f) ; Fatto che informa l'agente in merito al dover eseguire un piano (che è stato preparato)
    (pop-focus) ; Torniamo al planner
    (pop-focus) ; Torniamo all'agente (facendo una POP)
)


; Cose in merito alla percezione: a quanto pare la capienza del drink dispenser è (max) 3. Quindi l'ENV tiene da conto la quantità di roba caricata e se supera il limite, gestisce le penalità correttamente.
; Il nostro intento quindi è quello di, tramite la recezione di una perc-load, tenere conto di quanti caricamenti sono stati effettuati. 
; Ma la perc-load è ricevuta sia in caso di Delivery che in caso di Load quindi non possiamo usarla per modificare il K-agent. Inoltre, ci fornisce solo yes o no (se è carico o no) e questo rende le informazioni poco utili.

