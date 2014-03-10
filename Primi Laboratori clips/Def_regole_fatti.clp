(defrule r1 (nonno luca mario) => (assert (nipote mario luca)))

(defrule r2
	(nonno luca mario)
	(padre mario luisa)
	=>
	(assert (bisnonno luca luisa))
)

(assert (nonno luca mario))
(assert (padre mario luisa) (padre mario giorgio))
