(defmodule MAIN (export ?ALL))

(deftemplate solution (slot value (default no))) 

(deffacts param
       (solution (value no)) (maxdepth 1))

(deffacts S0
	(status 0 clear a) (status 0 on a b ) (status 0 ontable b) 
	      (status 0 ontable c) (status 0 clear c)
	      (status 0 ontable d) (status 0 clear d)
	      (status 0 ontable e) (status 0 clear e)
	      (status 0 ontable f) (status 0 clear f)
	      (status 0 ontable g) (status 0 clear g)
	      (status 0 ontable h) (status 0 clear h)
	      (status 0 handempty)
)

(deffacts final
      (goal on  a b) (goal ontable e) (goal on b c) (goal on c d) (goal on d e)
)

 
(defrule got-solution
(declare (salience 100))
(solution (value yes)) 
=> (halt))

(defrule noSolution (declare (salience -1))
      (solution (value no))
      (maxdepth ?d)
      =>
      (printout t "No solutions find at level " ?d crlf)
      (reset)
      (assert (maxdepth =(+ ?d 1)))
      (run)
)      


(defrule pick
   (status ?s on ?x ?y)
   (status ?s clear ?x)
   (status ?s handempty)
   (maxdepth ?d)
   (test (< ?s ?d))
   (not (exec ?s pick ?x ?y))
   =>  
   (assert (apply ?s pick ?x ?y))
)

;rimuove tutti gli stati ad un indice maggiore in quello in cui sto
;faccio pulizia prima di provare un altro cammino

(defrule apply-pick1
        (apply ?s pick $?)  
 ?f <-  (status ?t $?)    
        (test (> ?t ?s))
 =>     (retract ?f))

;rimuove l'exec

(defrule apply-pick2
       (apply ?s pick $?)
?f <-  (exec ?t $?)     
       (test (> ?t ?s))
 =>    (retract ?f))       

(defrule apply-pick3 
   ?f <- (apply ?s pick ?x ?y)
   =>  
   (retract ?f)
   (assert (status (+ ?s 1) clear ?y))
   (assert (status (+ ?s 1) holding ?x))
   (assert (delete ?s on ?x ?y))
   (assert (delete ?s clear ?x))
   (assert (delete ?s handempty))
   (assert (current ?s))
   (assert (news (+ ?s 1)))
   (focus CHECK)
   (assert (exec ?s pick ?x ?y))   
)

(defrule picktable
   (status ?s ontable ?x)   
   (status ?s clear ?x) 
   (status ?s handempty)
   (maxdepth ?d)
   (test (< ?s ?d))
   (not (exec ?s picktable ?x))
   =>
   (assert (apply ?s picktable ?x))    
)

(defrule apply-picktable1
        (apply ?s picktable $?)  
 ?f <-  (status ?t $?)    
        (test (> ?t ?s))
 =>     (retract ?f))


(defrule apply-picktable2
       (apply ?s picktable ?x)
?f <-  (exec ?t $?)     
       (test (> ?t ?s))
 =>    (retract ?f))       

(defrule apply-picktable3
   ?f <- (apply ?s picktable ?x)
   =>  
   (retract ?f)
   (assert (status (+ ?s 1) holding ?x))
   (assert (delete ?s ontable ?x))
   (assert (delete ?s clear ?x))
   (assert (delete ?s handempty))
   (assert (current ?s))
   (assert (news (+ ?s 1)))
   (focus CHECK)
   (assert (exec ?s picktable ?x))   
)

(defrule put
   (status ?s holding ?x ) 
   (status ?s clear ?y)
   (maxdepth ?d)
   (test (< ?s ?d))
   (not (exec ?s put ?x ?y))
   =>  
   (assert (apply ?s put ?x ?y))
)

;rimuove tutti gli stati ad un indice maggiore in quello in cui sto
;faccio pulizia prima di provare un altro cammino

(defrule apply-put1
        (apply ?s put ?x ?y)  
 ?f <-  (status ?t $?)    
        (test (> ?t ?s))
 =>     (retract ?f))

;rimuove l'exec

(defrule apply-put2
       (apply ?s put ?x ?y)
?f <-  (exec ?t $?)     
       (test (> ?t ?s))
 =>    (retract ?f))       

(defrule apply-put3
   ?f <- (apply ?s put ?x ?y)
   =>  
   (retract ?f)
   (assert (status (+ ?s 1) on ?x ?y))
   (assert (status (+ ?s 1) clear ?x))
   (assert (status (+ ?s 1) handempty))
   (assert (delete ?s clear ?y))
   (assert (delete ?s holding ?x))
   (assert (current ?s))
   (assert (news (+ ?s 1)))
   (focus CHECK)
   (assert (exec ?s put ?x ?y))   
)


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
 ?f <-  (status ?t $?)    
        (test (> ?t ?s))
 =>     (retract ?f))


(defrule apply-puttable2
       (apply ?s puttable $?)
?f <-  (exec ?t $?)     
       (test (> ?t ?s))
 =>    (retract ?f))       

(defrule apply-puttable3
   ?f <- (apply ?s puttable ?x)
   =>  
   (retract ?f)
   (assert (status (+ ?s 1) handempty))
   (assert (status (+ ?s 1) clear ?x))
   (assert (status (+ ?s 1) ontable ?x))
   (assert (delete ?s holding ?x))
   (assert (current ?s))
   (assert (news (+ ?s 1)))
   (focus CHECK)
   (assert (exec ?s puttable ?x))   
)
 

(defmodule CHECK (import MAIN ?ALL) (export ?ALL))

(defrule comp
    (declare (salience 100))
    (current ?s)
    (status ?s ?op $?args)
    (not (delete ?s ?op $?args))
 => (assert (status (+ ?s 1) ?op $?args)))

(defrule goal-not-yet
      (declare (salience 50))
      (news ?s)
      (goal ?op $?args)
      (not (status ?s ?op $?args))
      => (assert (task go-on)) 
         (assert (ancestor (- ?s 1)))
         (focus NEW))

(defrule solution-exist
 ?f <-  (solution (value no))
         => 
        (modify ?f (value yes))
        (focus PRINTPLAN)
)

(defmodule PRINTPLAN (import CHECK ?ALL) (export ?ALL))

(defglobal ?*path* = "")

(deffunction updatepath (?s ?ex)
   (bind ?a (str-cat "status: " ?s " action: "))
   (progn$ (?field ?ex)
      (bind ?a (str-cat ?a ?field " "))
   )
   (bind ?*path* ?a ?*path* )
)

(defrule printPlan (declare (salience 10))
     (solution (value yes))
     (current ?s)
     (exec ?s $?ex)
      => 
     (updatepath ?s ?ex)
     (assert (prec =(- ?s 1)))     
)

(defrule printPrecOp
   ?p <- (prec ?s)
   ?f <- (exec ?s $?ex)
   =>
     (updatepath ?s ?ex)
     (retract ?p)
     (assert (prec =(- ?s 1)))	
)

(defrule readyPlan
  ?f <- (prec -1)
      (maxdepth ?d) 
       =>
      (printout t "Solution find at level " ?d  crlf)
      (progn$ (?field ?*path*)
          (printout t ?field crlf)
       )
       (retract ?f)
)

(defmodule NEW (import CHECK ?ALL) (export ?ALL))

(defrule check-ancestor
    (declare (salience 50))
?f1 <- (ancestor ?a) 
    (or (test (> ?a 0)) (test (= ?a 0)))
    (news ?s)
    (status ?s ?op $?args)
    (not (status ?a ?op $?args)) 
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
 ?f <- (status ?n $?)
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