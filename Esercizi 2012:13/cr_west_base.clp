(deffacts initial

  (owns Nono M1)

  (missile M1)

  (missile M2)

  (missile M3)

  (owns Boro M2)

  (owns Nono M3)

  (enemy Nono America)

  (american West)

  (american Bob)

  (sells Bob M2 Boro))



(deffacts question

   (goal criminal West))



(defrule r1 

  (american ?x)

  (weapon ?y)

  (sells ?x ?y ?z)

  (hostile ?z)

=> (assert (criminal ?x)))



(defrule r2

   (missile ?x)

   (owns Nono ?x)

=> (assert (sells West ?x Nono)))



(defrule r3

   (missile ?x)

=> (assert (weapon ?x)))



(defrule r4

   (enemy ?x America)

=> (assert (hostile ?x)))



(defrule answer

    (goal criminal ?x)

    (criminal ?x)

=>  (printout t "criminal " ?x " conseguenza logica KB"  crlf)

    (halt))



(defrule noderivation

(declare (salience -1))

(goal criminal ?x)

(not (criminal ?x))

=>  (printout t "criminal " ?x " non conseguenza logica KB"  crlf)
    (halt)
)