; Versione proposta da P.Torasso
; questa versione � simile a quella che risolve problemi del mondo dei blocchi senza fare 
; ricorso a ricerca (cio� trova la soluzione senza backtracking), in quanto le regole che
; modellano azione sono state modificate in modo da includere molta conoscenza.
; in questo modo le regole individuano un operatore utile per raggiungere il goal.
; Questa versione migliora la precedente in quanto evita azioni inutili anche in presenza di 
; goal parziali (non per tutti i blocchi � specificata la posizione che deve essere occupata
; nello stato finale).
; questo � ottenuto estendendo la semantica di achieved asserendo che una certa situazione 
; � achieved non solo quando � presente nel goal e non deve pi� essere modificata 
; (regole check-ontable, chen-on1 e check-on2) ma anche quando il blocco in oggetto non � per 
; nulla menzionato in nessun goal (regole check-ontablebis, chen-on1bis e check-on2bis)

; dal punto di vista del pattern matching si presti particolare attenzione alla condizione
; (not (goal $? ?x  $?)) utilizzata nelle regole sopra citate


(defmodule MAIN (export ?ALL))

(deftemplate solution (slot value (default no)))
(deftemplate status (slot value (default 0))) 

(deffacts param
       (solution (value no)) (status (value 0)) (start))


 (deffacts S0
      (clear d) (on d a) (on a b ) (ontable b) 
      (ontable c) (clear c)
      (ontable e) (on f e) (clear f)
      (ontable g) (on h g) (on i h) (on j i) (on m j) (clear m)
      (handempty))
 
 
(deffacts final
     (goal ontable e) (goal on b e) (goal on a b)  (goal on j a) (goal on f j) (goal on d f) 
     (goal clear d) 
     )
 

(defrule begin 
  (declare (salience 100))(start ) => (focus CHECK))

(defrule got-solution
(declare (salience 110))
(solution (value yes))
=> (assert (stampa 0)))

(defrule stampa1
(declare (salience 110))
?f <-  (stampa ?s)
       (exec ?s $?k)
       => 
(printout t " PASSO:" ?s "   eseguita azione  " $?k crlf)
   (assert (stampa (+ ?s 1)))
   )

(defrule nogood
  (declare (salience -1))
  (solution (value no))
=> (assert (trouble)))


(defrule stampa2
(declare (salience 111))
(status (value ?n))
(stampa  ?n)
=> (halt)
)

;Ora anche le operazioni hanno una priorita'
(defrule pick
 (declare (salience 50))
 ?f1 <- (on ?x ?y)
 ?f2 <- (clear ?x)
 ?f3 <- (handempty)
       (not (achieved on ?x ?y))	;marcare i fatti come fatti gia' ottenuti
	   								;ovvero che soddisfano uno dei goal parziali
									;quindi non disfiamo delle cose che ci sono
									;utili per arrivare al goal
 ?f4 <- (status (value ?s))
=>     (assert (clear ?y) (holding ?x))
       (retract ?f1 ?f2 ?f3)
       (assert (exec ?s pick ?x ?y))
       (modify ?f4 (value (+ ?s 1))))


(defrule picktable
 ?f1 <- (ontable ?x)
 ?f2 <- (clear ?x)
 ?f3 <- (handempty)
        (not (achieved ontable ?x))
        (goal on ?x ?y)
        (clear ?y)
        (or (and (goal ontable ?y) (achieved ontable ?y))
            (and (goal on ?y ?z) (achieved on ?y ?z)))
 ?f4 <- (status (value ?s))
 =>     (assert (holding ?x))
        (retract ?f1 ?f2 ?f3)
        (assert (exec ?s picktable ?x))
        (modify ?f4 (value (+ ?s 1))))


(defrule put
   (declare (salience 20))
 ?f1 <- (holding ?x)
 ?f2 <- (clear ?y)
       (goal on ?x ?y)
       (not (achieved on ?x ?y))
       (or (and (goal ontable ?y) (achieved ontable ?y))
           (and (goal on ?y ?z) (achieved on ?y ?z)))
 ?f4 <- (status (value ?s))
=>     (assert (on ?x ?y) (clear ?x) (handempty))
       (retract ?f1 ?f2)
       (assert (exec ?s put ?x ?y))
       (focus CHECK)
       (modify ?f4 (value (+ ?s 1))))


(defrule puttable
   ?f1 <- (holding ?x)
   ?f4 <- (status (value ?s))
=>     (assert (ontable ?x) (clear ?x) (handempty))
       (retract ?f1)
       (assert (exec ?s puttable ?x))
       (focus CHECK)
       (modify ?f4 (value (+ ?s 1))))

(defmodule CHECK (import MAIN ?ALL) (export ?ALL))

(defrule check-ontable
    (declare (salience 90))
    (status (value ?s))
    (ontable ?x)
    (goal ontable ?x)
    (not (achieved ontable ?x))
 => (assert (achieved ontable ?x)))


(defrule check-ontablebis
    (declare (salience 90))
    (status (value ?s))
    (ontable ?x)
    (not (goal $? ?x  $?))
    (not (achieved ontable ?x))
 => (assert (achieved ontable ?x)))


(defrule check-on1
    (declare (salience 80))
    (status (value ?s))
    (on ?x ?y)
    (goal on ?x ?y)
    (not (achieved on ?x ?y))
    (goal ontable ?y)
    (achieved ontable ?y)
=> (assert (achieved on ?x ?y)))

(defrule check-on2
    (declare (salience 80))
    (on ?x ?y)
    (status (value ?s))
    
    (not (achieved on ?x ?y))
    (goal on ?y ?z)
    (achieved on ?y ?z)
=> (assert (achieved on ?x ?y)))


(defrule check-on1bis
    (declare (salience 80))
    (status (value ?s))
    (on ?x ?y)
    (not (goal $? ?x  $?))
    (not (achieved on ?x ?y))
    (achieved ontable ?y)
=> (assert (achieved on ?x ?y)))

(defrule check-on2bis
    (declare (salience 80))
    (on ?x ?y)
    (status (value ?s))
    (not (goal $? ?x  $?))
    (not (achieved on ?x ?y))
    (achieved on ?y ?z)
=> (assert (achieved on ?x ?y)))

(defrule goal-not-yet1
      (declare (salience 50))
      (status (value ?s))
      (goal ontable ?x) 
      (not (achieved ontable ?x))
      => (pop-focus))

(defrule goal-not-yet2
      (declare (salience 50))
      (status (value ?s))
      (goal on ?v ?z) 
      (not (achieved on ?v ?z))
      => (pop-focus))

(defrule solution-exist
 ?f <-  (solution (value no))
         => 
        (modify ?f (value yes))
        (pop-focus)
)