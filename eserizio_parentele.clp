;; definizione regole
(defrule goal-achieved

(declare (salience 100))
	(goal S ?x ?y)
        (S ?x ?y)
          =>
	(printout t crlf ?x "  sibling of " ?y crlf)
        (halt)
)

(defrule R1
	(A ?x ?y) => (assert (S ?y ?x))
)

(defrule R2
	(P ?x ?y) => (assert (A ?x ?y))
)

(defrule R3
	(P ?x ?z) (A ?z ?y)=>(assert (A ?x ?y))
)

(defrule R4
	(F ?x ?y) => (assert (P ?x ?y))
)

(defrule R5
	(M ?x ?y) => (assert (P ?x ?y))
)

(defrule R6
	(HC ?x ?y) (H ?x) (MA ?x) (H ?y) => (assert (F ?x ?y))
)

(defrule R7
	(HC ?x ?y) (H ?x) (FE ?x) (H ?y) => (assert (M ?x ?y))
)

;;definizione fatti
(deffacts fatti
	(H P1)
	(H P2)
	(H P3)
	(H P4)
	(H P5)
	(H P6)
	(H P7)
	(H P8)
	(H P9)
	(H P10)
	(MA P2)
	(MA P3)
	(MA P6)
	(MA P7)
	(MA P9)
	(FE P1)
	(FE P4)
	(FE P5)
	(FE P8)
	(FE P10)
	(HC P1 P3)
	(HC P1 P4)
	(HC P5 P7)
	(HC P5 P10)
	(HC P4 P8)
	(HC P4 P9)
	(HC P6 P2)
	(HC P7 P8)
	(HC P7 P9)
	(HC P10 P6)
)

(deffacts final (goal S P2 P6))