(defrule X1_r1
	(a 1)
	(b 0)
	=> (assert (ox1 1))
)

(defrule X1_r2
	(a 0)
	(b 1)
	=> (assert (ox1 1))
)

(defrule X1_r3
	(a 0)
	(b 0)
	=> (assert (ox1 0))
)

(defrule X1_r4
	(a 1)
	(b 1)
	=> (assert (ox1 0))
)

(defrule X2_r1
	(c_in 1)
	(ox1 1)
	=> (assert (sum 0))
)

(defrule X2_r2
	(c_in 0)
	(ox1 0)
	=> (assert (sum 0))
)

(defrule X2_r3
	(c_in 1)
	(ox1 0)
	=> (assert (sum 1))
)

(defrule X2_r4
	(c_in 0)
	(ox1 1)
	=> (assert (sum 1))
)

(defrule A1_r1
	(a 1)
	(b 0)
	=> (assert (oa1 0))
)

(defrule A1_r2
	(a 0)
	(b 1)
	=> (assert (oa1 0))
)

(defrule A1_r3
	(a 0)
	(b 0)
	=> (assert (oa1 0))
)

(defrule A1_r4
	(a 1)
	(b 1)
	=> (assert (oa1 1))
)

(defrule A2_r1
	(c_in 1)
	(ox1 1)
	=> (assert (oa2 1))
)

(defrule A2_r2
	(c_in 0)
	(ox1 0)
	=> (assert (oa2 0))
)

(defrule A2_r3
	(c_in 1)
	(ox1 0)
	=> (assert (oa2 0))
)

(defrule A2_r4
	(c_in 0)
	(ox1 1)
	=> (assert (oa2 0))
)

(defrule O1_r1
	(oa1 1)
	(oa2 1)
	=> (assert (c_out 1))
)

(defrule O1_r2
	(oa1 1)
	(oa2 0)
	=> (assert (c_out 1))
)

(defrule O1_r3
	(oa1 0)
	(oa2 1)
	=> (assert (c_out 1))
)

(defrule O1_r4
	(oa1 0)
	(oa2 0)
	=> (assert (c_out 0))
)

(deffacts dati_input
	(a 0)
	(b 1)
	(c_in 1)
)