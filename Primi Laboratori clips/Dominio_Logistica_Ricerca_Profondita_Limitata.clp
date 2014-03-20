(defmodule MAIN (export ?ALL))

(deftemplate solution (slot value (default no))) 
(deffacts param
       (solution (value no)) (maxdepth 1)))

(deffacts S0
      (cargo c1) (cargo c2) (cargo c3)
      (place Parigi) (place Roma) (place Vienna)
      (airplane a1) (airplane a2) (airplane a3) 
      (status 0 is-in c1  Roma)
      (status 0 is-in c2  Roma)	  
      (status 0 is-in c2  Roma)
      (status 0 empty a2 NA)
      (status 0 empty a1 NA)  
      (status 0 at a1 Roma) 
      (status 0 at a2 Parigi)
      (status 0 at a3 Parigi)	  
      )

(deffacts final
      (goal is-in c1  Parigi) (goal is-in c2  Parigi) (goal is-in c3  Parigi))



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

(defrule move
   (airplane ?a)
   (status ?s at ?a ?from)
   (place ?from)
   (place ?to&:(neq ?to ?from))
   (maxdepth ?d)
    (test (< ?s ?d))
      (not (exec ?s move ?a ?from ?to)) 
   => (assert (apply ?s move ?a ?from ?to)))
   
;regola che mi serve per pulire gli stati successivi a quello in cui mi trovo
;che derivano da inferenza fatte in precedenza
;quindi dopo che torno indietro per backtracking devo assicurarmi di cancellare
;tutte le inferenze fatte in modo da non avere vecchi stati
(defrule apply-move1
        (apply ?s move $?)
 ?f <-  (status ?t ? ? ?)
        (test (> ?t ?s))
 =>     (retract ?f))

(defrule apply-move2
       (apply ?s move $?)
?f <-  (exec ?t $?)				;Se e' una operazione e' stata gia' eseguita ad un livello t > s
       (test (> ?t ?s))
 =>    (retract ?f))

(defrule apply-move3
?f <- (apply ?s move ?a ?from ?to)
 =>    (retract ?f)
      (assert (delete ?s at ?a ?from))
      (assert (status (+ ?s 1) at ?a ?to))
      (assert (current ?s))
      (assert (news (+ ?s 1)))
      (focus CHECK)
      (assert (exec ?s move ?a ?from ?to)))

(defrule load
   (airplane ?a)
   (status ?s empty ?a ?)
   (status ?s at ?a ?p)
   (status ?s is-in ?c ?p)
   (cargo ?c)
   (place ?p)
   (maxdepth ?d)
   (test (< ?s ?d))
   (not (exec ?s load ?a ?c ?p)) 
   => (assert (apply ?s load ?a ?c ?p)))

(defrule apply-load1
        (apply ?s load $?)
 ?f <-  (status ?t ? ? ?)
        (test (> ?t ?s))
 =>     (retract ?f))

(defrule apply-load2
        (apply ?s load $?)
?f <-  (exec ?t $?)
       (test (> ?t ?s))
 =>    (retract ?f))

(defrule apply-load3
?f <- (apply ?s load ?a ?c ?p)
 =>   (retract ?f)
      (assert (delete ?s empty ?a NA))
      (assert (delete ?s is-in ?c ?p))
      (assert (status (+ ?s 1) loaded ?c ?a))
      (assert (current ?s))
      (assert (news (+ ?s 1)))
      (focus CHECK)							
	  ;Anziche' avere tutte le regole tutte insieme possiamo dividerle
	  ;in moduli in modo da divdiere le regole in base al contesto in cui
	  ;sono focalizzate, pertanto il motore inferenziale si concentrera'
	  ;solo sul sottoinsieme di regole di un modulo
	  ;(focus CHECK) -> l'interprete si focalizza solo sul modulo CHECK
	  ;funziona attraverso uno stack di focus prendendo l'ultimo inserito
	  ;Si esce dal focus solo se non c'e' piu' nessuna regola attivabile
	  ;Attraverso il comando di (pop focus)
	  ;L'ordine non e' importante
	  ;(la regola dovrebbe essere ultimata prima di passare ad un nuovo FOCUS)
	  ;le variabili viene legata nell'antecedente della regola
	  ;quindi nel conseguente si fa riferimento al valore precedente fissato; 
      (assert (exec ?s load ?a ?c ?p)))


(defrule unload
   (airplane ?a)
   (status ?s loaded ?c ?a)
   (cargo ?c)
   (status ?s at ?a ?p)
   (place ?p)
   (maxdepth ?d)
   (test (< ?s ?d))
   (not (exec ?s unload ?a ?c ?p)) 
   => (assert (apply ?s unload ?a ?c ?p)))

(defrule apply-unload1
        (apply ?s unload $?)
 ?f <-  (status ?t ? ? ?)
        (test (> ?t ?s))
 =>     (retract ?f))

(defrule apply-unload22
        (apply ?s unload $?)
 ?f <-  (exec ?t $?)
        (test (> ?t ?s))
 =>     (retract ?f))

(defrule apply-unload3
?f <- (apply ?s unload ?a ?c ?p)
 =>   (retract ?f)
      (assert (delete  ?s loaded ?c ?a))
      (assert (status (+ ?s 1) is-in ?c ?p))
      (assert (status (+ ?s 1) empty ?a NA))
      (assert (current ?s))
      (assert (news (+ ?s 1)))
      (focus CHECK)
      (assert (exec ?s unload ?a ?c ?p))
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


;Come faccio a trovare i passi che mi han portato alla soluzione:

;Posso usare le exect???
;SO
;exec  0  move a1 parigi Roma  ---- apply 0 load a2 c2 roma
;S1
;exec 1 load a1 c1 roma
;S2
;exec 2 move a1 roma parigi
;S3
;non lo posso usare xke mi servono per memorizzare le operazioni gia' fatte
;per il backtraking, in modo da non rifare le strade che so per certo
;non funzionare

;Ma possiamo considerare gli indici degli exect per ciascun livello
;il fatto exect con un valore di indice piu' alto ad ogni livello
;e' quello eseguito nell'ultimo cammino che ci ha portato alla soluzione