;// __________________________________________________________________________________________

;// REGOLE PER il Clean Table

;// Operazione OK
(defrule CleanTable_OK_1 (declare (salience 20))    
	?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
            (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
    (serviceTable ?tb ?rr ?cc)
	?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld&:(> ?tld 0)) (l-food ?tlf&:(> ?tlf 0)))
	?f4<-	(cleanstatus (step ?i) (requested-by ?tb))
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


(defrule CleanTable_OK_2 (declare (salience 20))    
	?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
            (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
    (serviceTable ?tb ?rr ?cc)
	?f3 <- (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld&:(> ?tld 0)) (l-food 0))
	?f4 <- (cleanstatus (step ?i) (requested-by ?tb))
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

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))

	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)

?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink 0) (l-food ?tlf&:(> ?tlf 0)))

?f4<-	(cleanstatus (step ?i) (requested-by ?tb))
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t (+ 10  (* 3 ?tlf)))))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t (+ 10  (* 3 ?tlf)))) 
                    (l_d_waste ?dw) (l_f_waste yes))

	(modify ?f3 (step (+ ?i 1)) (time (+ ?t (+ 10  (* 3 ?tlf)))) 
                    (l-drink 0) (l-food 0) (clean yes))

	(retract ?f4)

)
;// CleanTable  ha fisicamente successo ma fatta quando non 
;// c'�  richiesta di cleanTable o dopo CheckFinish positiva



(defrule CleanTable_K0_1

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))

	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)

?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf)(clean no))

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

;// azione inutile di cleantable perch� il tavolo � gi� pulito

(defrule CleanTable_K0_2

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))

	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)

?f3<-	(tablestatus (step ?i) (table-id ?tb) (clean yes))
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30)) 
                    (l_d_waste ?dw) (l_f_waste ?fw))

	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 30)))

	(assert (penalty (+ ?p 10000)))
        (retract ?f5)
)





;// il robot tenta di fare CleanTable  ma fallisce perch� sta gi� trasportando cibo 
;// e o bevande

(defrule CleanTable_KO_3

	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))

	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-drink ?ld) (l-food ?lf))
        (test (> (+ ?ld ?lf) 0))
        (serviceTable ?tb ?rr ?cc)
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30)))

	(assert (penalty (+ ?p	500000)))
        (retract ?f5)

)    

;// L'azione di CleanTable fallisce perch� l'agente non � accanto ad un tavolo 



(defrule CleanTable_KO_4

	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))

	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceTable ?tb ?rr ?cc))
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 

	(assert (penalty (+ ?p	500000)))
        (retract ?f5)

) 

;// L'azione di CleanTable fallisce perch� la posizione indicata non 
;//contiene un tavolo 

(defrule CleanTable_KO_5

	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))

	(not (Table (table-id ?tb) (pos-r ?x) (pos-c ?y)))

?f1<-	(agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 

	(assert (penalty (+ ?p	500000)))
        (retract ?f5)

) 

;// __________________________________________________________________________________________

;// REGOLE PER il EmptyFood




;// Operazione OK

(defrule EmptyFood_OK

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))

	(TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_f_waste yes))
        (serviceTB ?trb ?rr ?cc)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)) (l_f_waste no))

)



;// Operazione inutile perch� agente non ha avanzi di cibo a bordo

(defrule EmptyFood_KO1

	(declare (salience 20))       

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))

	(TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_f_waste no))
        (serviceTB ?trb ?rr ?cc)
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)) (l_f_waste no))

        (assert (penalty (+ ?p	10000)))
        (retract ?f5)

)    



;// Operazione fallisce perch� l'agente non � adiacente a un TrashBasket

(defrule EmptyFood_KO2

	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))

	(TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceTB ?trb ?rr ?cc))
?f5<-   (penalty ?p)    
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))

        (assert (penalty (+ ?p	500000)))
        (retract ?f5)

)

;// Operazione fallisce perch� la cella indicata non � un TrashBasket

(defrule EmptyFood_KO3

	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))

	(not (TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y)))

?f1<-	(agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)    
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))

        (assert (penalty (+ ?p	500000)))
        (retract ?f5)

)

;// __________________________________________________________________________________________

;// REGOLE PER il Release (svuota contenitori bevande in RecyclableBasket)




;// Operazione OK

(defrule Release_OK

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action Release) (param1 ?x) (param2 ?y))

	(RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_d_waste yes))
        (serviceRB ?rb ?rr ?cc)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)) (l_d_waste no))

)



;// Operazione inutile perch� agente non ha contenitori di bevande a bordo

(defrule Release_KO1

	(declare (salience 20))       

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action Release) (param1 ?x) (param2 ?y))

	(RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_d_waste no))
        (serviceRB ?rb ?rr ?cc)
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)) (l_d_waste no))

        (assert (penalty (+ ?p	10000)))
        (retract ?f5)

)    


;// Operazione fallisce perch� l'agente non � adiacente a un RecyclableBasket

(defrule Release_KO2

	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action Release) (param1 ?x) (param2 ?y))

	(RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceRB ?rb ?rr ?cc))
?f5<-   (penalty ?p)    
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)))

        (assert (penalty (+ ?p	500000)))
        (retract ?f5)

)

;// Operazione fallisce perch� la cella indicata non � un RecyclableBasket

(defrule Release_KO3

	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action Release) (param1 ?x) (param2 ?y))

	(not (RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y)))

?f1<-	(agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)    
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)))

        (assert (penalty (+ ?p	500000)))
        (retract ?f5)

)


;/// REGOLE PER WAIT

(defrule WAIT

	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action Wait))

?f1<-	(agentstatus (step ?i) (time ?t))   
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 10)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 10)))

)

;// __________________________________________________________________________________________

;// REGOLE PER il prelievo di Food da food Dispenser



;// Operazione OK

(defrule load-food_OK

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))

	(FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceFD ?fd ?rr ?cc)

        (test (< (+ ?lf ?ld) 4))
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)) (l-food (+ ?lf 1)))

)



;// Operazione fallisce perch� l'agente � gi� a pieno carico

(defrule load-food_KO1

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))

	(FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceFD ?fd ?rr ?cc)

        (test (= (+ ?lf ?ld) 4))
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))

        (assert (penalty (+ ?p	100000)))
        (retract ?f5)

)    

;// Operazione fallisce perch� l'agente � gi� carico di immondizia

(defrule load-food_KO2

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))

	(FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceFD ?fd ?rr ?cc)

        (test (or (eq ?dw yes) (eq ?fw yes)))
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))

        (assert (penalty (+ ?p	500000)))
        (retract ?f5)

)


;// Operazione fallisce perch� l'agente non � adiacente a un FoodDispenser

(defrule load-food_KO3

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))

	(FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceFD ?fd ?rr ?cc))
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))

        (assert (penalty (+ ?p	500000)))
        (retract ?f5)

)

;// Operazione fallisce perch� la cella indicata non � un FoodDispenser

(defrule load-food_KO4

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))

	(not (FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y)))

?f1<-	(agentstatus (step ?i) (time ?t))
 
?f5<-   (penalty ?p)
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))

        (assert (penalty (+ ?p	500000)))
        (retract ?f5)

)


;// __________________________________________________________________________________________

;// REGOLE PER il prelievo di drink da drink Dispenser



;// Operazione OK

(defrule load-drink_OK

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))

	(DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceDD ?dd ?rr ?cc)

        (test (< (+ ?lf ?ld) 4))
=> 

	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))

	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)) (l-drink (+ ?ld 1)))

)



;// Operazione fallisce perch� l'agente � gi� a pieno carico

(defrule load-drink_KO1

	(declare (salience 20))    

?f2<-	(status (time ?t) (step ?i)) 

	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))

	(DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))

?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceDD ?dd ?rr ?cc)

        (test (= (+ ?lf ?ld) 4))
		?f5<-   (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	100000)))
    (retract ?f5)
)    

;// Operazione fallisce perch� l'agente � gi� carico di immondizia

(defrule load-drink_KO2	(declare (salience 20))    
	?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
	(DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
	?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste ?dw) (l_f_waste ?fw))
    (serviceDD ?dd ?rr ?cc)
    (test (or (eq ?dw yes) (eq ?fw yes)))
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	500000)))
    (retract ?f5)
)

;// Operazione fallisce perch� l'agente non � adiacente a un drinkDispenser

(defrule load-drink_KO3 (declare (salience 20))    
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
	(DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t)(pos-r ?rr) (pos-c ?cc))
    (not (serviceDD ?dd ?rr ?cc))
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	500000)))
    (retract ?f5)
)

;// Operazione fallisce perch� la cella indicata non � un drinkDispenser

(defrule load-drink_KO4 (declare (salience 20))    
	?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
	(not (DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y)))
	?f1 <- (agentstatus (step ?i) (time ?t))
	?f5 <- (penalty ?p)	
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	500000)))
    (retract ?f5)
)
    
;// __________________________________________________________________________________________

;// REGOLE PER LA CONSEGNA Di Food ad un tavolo

;// ��consegna Food su un tavolo che ha ordine ancora aperto
;// le penalit� di riferiscono alla durata dell'azione (4 unit� di tempo) 
;// per i punti (2) per i cibi e bevande non ancora consegnati 

(defrule delivery-food_OK (declare (salience 20))    
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
	             (l-food ?alf&:(> ?alf 0)))
	(serviceTable ?tb ?rr ?cc)
	?f3 <- (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
	?f4 <- (orderstatus (step ?i) (requested-by ?tb) (food-order ?nfo) (food-deliv ?dfo&:(< ?dfo ?nfo))
	             (drink-order ?ndo) (drink-deliv ?ddo))
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (- ?alf 1)))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (+ ?tlf 1)) (clean no))
	(modify ?f4 (step (+ ?i 1)) (time (+ ?t 4)) (food-deliv ( + ?dfo 1)))
	(assert (penalty (+ ?p	(max  1 (* 8 (+ (- ?ndo ?ddo) (- ?nfo  (+ ?dfo 1))))))))
	(retract ?f5)
)


;// assegna una penalit� nel caso in cui si tenti di consegnare un cibo ad un tavolo
;// quando l'ordinazione � gi� stata completata (ordestatus eleinato) o non � mai stato fatto




(defrule delivery-food_WRONG_2 (declare (salience 20))
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) (l-food ?alf&:(> ?alf 0)))
    (serviceTable ?tb ?rr ?cc)
	?f3 <- (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
	(not (orderstatus (step ?i) (requested-by ?tb))) 
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (- ?alf 1)))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (+ ?tlf 1)))
	(assert (penalty (+ ?p	500000)))
    (retract ?f5)
) 




;// il robot tenta di fare una delivery-food  ma non sta trasportando cibo

(defrule delivery-food_WRONG_3 (declare (salience 20))
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) (l-food ?alf&:(= ?alf 0)))
    (serviceTable ?tb ?rr ?cc)
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)))
	(assert (penalty (+ ?p	100000)))
    (retract ?f5)
)    

;// __________________________________________________________________________________________

;// REGOLE PER LA CONSEGNA Di DRINK ad un tavolo

;// ��consegna drink a un tavolo che ha ordine ancora aperto
;// le penalit� di riferiscono alla durata dell'azione (4 unit� di tempo) 
;// per i punti (2) per i cibi e bevande non ancora consegnati 


(defrule delivery-drink_OK (declare (salience 20))    
	?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) (l-drink ?ald&:(> ?ald 0)))
    (serviceTable ?tb ?rr ?cc)
	?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
	?f4<-	(orderstatus (step ?i) (requested-by ?tb) (food-order ?nfo) (food-deliv ?dfo) (drink-order ?ndo) (drink-deliv ?ddo&:(< ?ddo ?ndo)))
	?f5<-   (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (- ?ald 1)))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (+ ?tld 1)) (clean no))
	(modify ?f4 (step (+ ?i 1)) (time (+ ?t 4))  (drink-deliv ( + ?ddo 1)))
	(assert (penalty (+ ?p	(max 1 (* 8 (+ (- ?nfo ?dfo) (- ?ndo  (+ ?ddo 1))))))))
    (retract ?f5)
)





;// assegna una penalit� nel caso in cui si tenti di consegnare un cibo ad un tavolo
;// quando l'ordinazione � gi� stata completata o non � stato fatto ordine






(defrule delivery-drink_WRONG_2 (declare (salience 20))
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) (l-drink ?ald&:(> ?ald 0)))
    (serviceTable ?tb ?rr ?cc)
	?f3 <- (tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
	(not (orderstatus (step ?i) (requested-by ?tb))) 
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (- ?ald 1)))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (+ ?tld 1)))
	(assert (penalty (+ ?p	500000)))
    (retract ?f5)
) 





;// il robot tenta di fare una delivery-food  ma non sta trasportando cibo

(defrule delivery-drink_WRONG_3 (declare (salience 20))
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) (l-drink ?ald&:(= ?ald 0)))
    (serviceTable ?tb ?rr ?cc)
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)))
	(assert (penalty (+ ?p	100000)))
    (retract ?f5)
)    

;// L'azione di delivery-food o delivery-drink fallisce perch� l'agente non � accanto ad un tavolo 



(defrule delivery_WRONG_4 (declare (salience 20))
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood|DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (not (serviceTable ?tb ?rr ?cc))
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4))) 
	(assert (penalty (+ ?p	500000)))
    (retract ?f5)
) 

;// L'azione di delivery-food o o delivery-drink fallisce perch� la posizione indicata non 
;//contiene un tavolo 

(defrule delivery_WRONG_5 (declare (salience 20))
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood|DeliveryDrink) (param1 ?x) (param2 ?y))
	(not (Table (table-id ?tb) (pos-r ?x) (pos-c ?y)))
	?f1 <- (agentstatus (step ?i) (time ?t))
	?f5 <- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4))) 
	(assert (penalty (+ ?p	500000)))
    (retract ?f5)
) 

(defrule order-completed (declare (salience 18))
	(status (time ?t) (step ?i)) 
	(exec (step ?ii&:(= ?ii (- ?i 1))) (action DeliveryFood|DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (orderstatus (step ?i) (requested-by ?tb) (food-order ?nfo) (food-deliv ?dfo&:(= ?dfo ?nfo))
    (drink-order ?ndo) (drink-deliv ?ddo&:(= ?ddo  ?ndo)))
	=>    
	(retract ?f1)
)

(defrule perc-load-generation1 (declare (salience 19))
	(status (time ?t) (step ?i)) 
	(exec (step ?ii&:(= ?ii (- ?i 1))) (action DeliveryFood|DeliveryDrink|LoadDrink|LoadFood))
	(agentstatus (step ?i)  (l-drink  0) (l-food 0))	
	=>      
	(assert (perc-load (time ?t) (step ?i) (load no)))
)

(defrule perc-load-generation2 (declare (salience 19))
	(status (time ?t) (step ?i)) 
	(exec (step ?ii&:(= ?ii (- ?i 1))) (action DeliveryFood|DeliveryDrink|LoadDrink|LoadFood))
    (agentstatus (step ?i)  (l-drink  ?ld) (l-food ?lf))
    (test (> (+ ?ld ?lf) 0))	
	=>
	(assert (perc-load (time ?t) (step ?i) (load yes)))
)