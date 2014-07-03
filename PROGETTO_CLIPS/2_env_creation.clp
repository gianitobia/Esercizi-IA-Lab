
;// DEFRULE



;//imposta il valore iniziale di ciascuna cella 

(defrule creation1	

     (declare (salience 25))

     (create-map)
     (prior-cell (pos-r ?r) (pos-c ?c) (contains ?x)) 

=>

     (assert (cell (pos-r ?r) (pos-c ?c) (contains ?x)))

            

)







(defrule creation2	

	(declare (salience 24))

?f1<-	(create-history) 

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
                 (status (step 0) (time 0) (result no))
                 (penalty 0))
         (retract ?f1 ?f2)
)
