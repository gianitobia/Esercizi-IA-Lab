;iniziamo con il conderare come codificare gli stati
(defmodule MAIN (export ?ALL))
;Valore per controllare che sia stata trovata la soluzione
(deftemplate solution (slot value (default no)))
;definisco i valori di partenza per la strategia
(deffacts param
	(solution (value no)) (maxdepth 1)
)

;definiamo lo stato s0
(deffacts S0
	(status 0 ontable b NA NA)
	(status 0 ontable c NA NA)
	(status 0 handempty NA NA)
	(status 0 clear b NA)
	(status 0 clear c NA)
	
)

(deffacts final
	(goal on b c)
	(goal ontable c NA)
)

(defrule got-solution
(declare (salience 100))
(solution (value yes)) 
=> (halt))

(defrule no-solution
	(declare (salience -2))
	(solution (value no))
	?f <- (maxdepth ?d)
	=>
	(printout t "non c'e' la soluzione al livello di profondita' " ?d crlf)
	(reset)
	(retract ?f)
	(assert (maxdepth =(+ ?d 1)))
)

;definiamo gli operatori
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PICK @@@@@@@@@@@@@@@@@@@@@@@@
(defrule pick
	(status ?s handempty NA NA)
	(status ?s on ?x ?y)
	(status ?s clear ?x NA)
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (exec ?s pick ?x ?y))
	=>
	(assert (apply ?s pick ?x ?y))
)	

(defrule apply-pick1
	(apply ?s pick $?)
	?f <- (status ?t $?)
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule apply-pick2
	(apply ?s pick $?)
	?f <- (exec ?t $?)
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule apply-pick3
	?f <- (apply ?s pick ?x ?y)
	=>
	(retract ?f)
	(assert (delete ?s on ?x ?y))
	(assert (delete ?s clear ?x))
	(assert (delete ?s handempty))
	(assert (status (+ ?s 1) clear ?y))
	(assert (status (+ ?s 1) holding ?x))
	(assert (current ?s))
	(assert (news (+ ?s 1)))
	(focus CHECK)
	(assert (exec ?s pick ?x ?y))
)

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PICK-TABLE @@@@@@@@@@@@@@@@@@@
(defrule pick-table
	(status ?s handempty NA NA)
	(status ?s ontable ?x $?)
	(status ?S clear ?x $?)
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (exec ?s pick-table ?x NA))
	=>
	(assert (apply ?s pick-table ?x))
)

(defrule apply-pick-table1
	(apply ?s pick-table $?)
	?f <- (status ?t $?)
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule apply-pick-table2
	(apply ?s pick-table $?)
	?f <- (exec ?t $?)
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule apply-pick-table3
	?f <- (apply ?s pick-table ?x)
	=>
	(retract ?f)
	(assert (delete ?s ontable ?x))
	(assert (delete ?s clear ?x))
	(assert (delete ?s handempty))
	(assert (status (+ ?s 1) holding ?x))
	(assert (current ?s))
	(assert (news (+ ?s 1)))
	(focus CHECK)
	(assert (exec ?s pick-table ?x NA))
)

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PUT @@@@@@@@@@@@@@@@@@@@@@
(defrule put
	(status ?s holding ?x)
	(status ?s clear ?y)
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (exec ?s put ?x ?y))
	=>
	(assert (apply ?s put ?x ?y))
)

(defrule apply-put1
	(apply ?s put $?)
	?f <- (status ?t $?)
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule apply-put2
	(apply ?s put $?)
	?f <- (exec ?t $?)
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule apply-put3
	?f <- (apply ?s put ?x ?y)
	=>
	(retract ?f)
	(assert (delete ?s holding ?x))
	(assert (delete ?s clear ?y))
	(assert (status (+ ?s 1) clear ?x))
	(assert (status (+ ?s 1) on ?x ?y))
	(assert (status (+ ?s 1) handempty))
	(assert (current ?s))
	(assert (news (+ ?s 1)))
	(focus CHECK)
	(assert (exec ?s put ?x ?y))
)

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PUTABLE @@@@@@@@@@@@@@@@@
(defrule puttable
	(status ?s holding ?x)
	(maxdepth ?d)
	(test (< ?s ?d))
	(not (exec ?s puttable ?x))
	=>
	(assert (apply ?s puttable ?x))
)

(defrule apply-puttable1
	(apply ?s puttable $?)
	?f <- (status ?t $?)
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule apply-puttable2
	(apply ?s puttable $?)
	?f <- (exec ?t $?)
	(test (> ?t ?s))
	=>
	(retract ?f)
)

(defrule apply-puttable3
	?f <- (apply ?s puttable ?x)
	=>
	(retract ?f)
	(assert (delete ?s holding ?x))
	(assert (status (+ ?s 1) clear ?x))
	(assert (status (+ ?s 1) ontable ?x))
	(assert (status (+ ?s 1) handempty))
	(assert (current ?s))
	(assert (news (+ ?s 1)))
	(focus CHECK)
	(assert (exec ?s puttable ?x))
)

(defmodule CHECK (import MAIN ?ALL) (export ?ALL))

;in questo modulo voglio controllare lo stato del sistema
;controllo la soluzione con la regola solution-exist

;regola di completamento del nuovo stato - perche' ho solo un pezzo
;del nuovo stato 
;copio nel nuovo stato tutto cio' che era vero nello stato precedente
;e che non dovevano essere cancellati;
;current e' lo stato in cui sono
;news e' il nuovo stato in cui ci troviamo
;se non rappresentassimo lo stato completo potremmo perdere il goal
;infatti la regola di completamento a saliece piu' alta;
(defrule comp
    (declare (salience 100))
    (current ?s)
    (status ?s ?op ?x ?y)
    (not (delete ?s ?op ?x ?y))
 => (assert (status (+ ?s 1) ?op ?x ?y)))

 ;poiche il goal non e' atomico
 ;devo controllare che tutti i sotto-goal devono essere soddisfatti
 ;quindi vado avanti per controllare gli altri sotto-goal
(defrule goal-not-yet
      (declare (salience 50))
      (news ?s)
      (goal ?op ?x ?y)
      (not (status ?s ?op ?x ?y))
      => (assert (task go-on)) 
         (assert (ancestor (- ?s 1)))
         (focus NEW)
)

;regola di default che viene attivata solo se entriamo in check
;e non c'e' nulla da attivare con prioprita' maggiore 
(defrule solution-exist 
 		?f <-  (solution (value no))
         => 
        (modify ?f (value yes))
		(focus STAMPA)
)

(defmodule STAMPA (import CHECK ?ALL) (export ?ALL))

;(defrule stampaStrada_ordinata (declare (salience 10))
;	(solution (value yes))
;	(exec 0 $?ex)
;	(news ?s)
;	=>
;	(printout t "stato 0 " ?ex  crlf))
;	(assert (succ 1))
;	(assert (level_max ?s))
;)

;(defrule stampaSucc_ordinata
;	?succ <- (succ ?s)
;	(level_max ?m)
;	(exec ?s $?ex)
;	(test (>= ?m ?s))
;	=>
;	(printout t "stato " ?s " " ?ex  crlf)
;	(retract ?succ)
;	(assert (succ =(+ ?s 1)))
;)



;(defrule stampaStrada (declare (salience 10))
;	(solution (value yes))
;	(news ?s)
;	?f <- (exec =(- ?s 1) $?ex)
;	=>
;	(printout t "stato " ?s " " ?ex  crlf)
;	(assert (prec =(- ?s 1)))	
;)

;(defrule stampaSucc
;	?p <- (prec ?s)
;	?f <- (exec ?s $?ex)
;	=>
;	(printout t "stato " ?s " " ?ex  crlf)
;	(retract ?p)
;	(assert (prec =(- ?s 1)))
;)

(defrule stato-corrente
  (declare (salience -1))
  => (assert (current-view 0))
)
  
(defrule stampa
  ?v <- (current-view ?s)
  ?f <- (exec ?s $?y)
  (maxdepth ?d)
  (test (<= ?s ?d))
  => (printout t "e'stata eseguita l'azione " $?y " nello stato " ?s " con id "?f crlf) (retract ?v) (assert (current-view (+ ?s 1)))
)

(defrule popmodule
   (current-view ?s)
   (maxdepth ?d)
   (test (> ?s ?d))
   => (pop-focus)
)

(defmodule NEW (import CHECK ?ALL) (export ?ALL))
;Serve per capire se lo stato generato e' effettivamenete nuovo
;oppure e' uguale ad uno stato antenato gia' generato
(defrule check-ancestor
    (declare (salience 50))
?f1 <- (ancestor ?a) 
    (or (test (> ?a 0)) (test (= ?a 0)))
    (news ?s)
    (status ?s ?op ?x ?y)
    (not (status ?a ?op ?x ?y)) 
    =>
    (assert (ancestor (- ?a 1)))
    (retract ?f1)
    (assert (diff ?a)))

(defrule all-checked
       (declare (salience 25))
       (diff 0) 
?f2 <- (news ?n)
?f3 <- (task go-on) =>
       (retract ?f2)
       (retract ?f3)
       (focus DEL))

(defrule already-exist
?f <- (task go-on)
      => (retract ?f)
         (assert (remove newstate))
         (focus DEL))

(defmodule DEL (import NEW ?ALL))          
       
(defrule del1
(declare (salience 50))
?f <- (delete $?)
=> (retract ?f))

(defrule del2
(declare (salience 100))
?f <- (diff ?)
=> (retract ?f))

(defrule del3
(declare (salience 25))
       (remove newstate)
       (news ?n)
 ?f <- (status ?n ?  ? ?)
=> (retract ?f))

(defrule del4
(declare (salience 10))
?f1 <- (remove newstate)
?f2 <- (news ?n)
=> (retract ?f1)
   (retract ?f2))

(defrule done
 ?f <- (current ?x) => 
(retract ?f)
(pop-focus)
(pop-focus)
(pop-focus))


