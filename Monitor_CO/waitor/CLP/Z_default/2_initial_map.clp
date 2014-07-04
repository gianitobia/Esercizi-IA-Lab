; questa asserzione va ovviamente cambiata a seconda del tipo di ambiente che
; si utilizza
(deffacts init (create)
	(maxduration 1000)
	(initial_agentstatus
		(pos-r 1) (pos-c 5)
		(direction north)
	)
)

(deffacts initialmap
             (prior_cell (pos-r 1) (pos-c 1) (type border))
             (prior_cell (pos-r 1) (pos-c 2) (type border))
             (prior_cell (pos-r 1) (pos-c 3) (type border))
             (prior_cell (pos-r 1) (pos-c 4) (type border))
             (prior_cell (pos-r 1) (pos-c 5) (type gate))
             (prior_cell (pos-r 1) (pos-c 6) (type border))
             (prior_cell (pos-r 1) (pos-c 7) (type border))
             (prior_cell (pos-r 1) (pos-c 8) (type border))
             (prior_cell (pos-r 1) (pos-c 9) (type gate))
             (prior_cell (pos-r 1) (pos-c 10) (type border))
             (prior_cell (pos-r 1) (pos-c 11) (type border))
             (prior_cell (pos-r 2) (pos-c 1) (type border))
             (prior_cell (pos-r 2) (pos-c 2) (type urban))
             (prior_cell (pos-r 2) (pos-c 3) (type hill))
             (prior_cell (pos-r 2) (pos-c 4) (type hill))
             (prior_cell (pos-r 2) (pos-c 5) (type rural))
             (prior_cell (pos-r 2) (pos-c 6) (type rural))
             (prior_cell (pos-r 2) (pos-c 7) (type rural))
             (prior_cell (pos-r 2) (pos-c 8) (type rural))
             (prior_cell (pos-r 2) (pos-c 9) (type lake))
             (prior_cell (pos-r 2) (pos-c 10) (type rural))
             (prior_cell (pos-r 2) (pos-c 11) (type border))
             (prior_cell (pos-r 3) (pos-c 1) (type border))
             (prior_cell (pos-r 3) (pos-c 2) (type lake))
             (prior_cell (pos-r 3) (pos-c 3) (type urban))
             (prior_cell (pos-r 3) (pos-c 4) (type hill))
             (prior_cell (pos-r 3) (pos-c 5) (type urban))
             (prior_cell (pos-r 3) (pos-c 6) (type rural))
             (prior_cell (pos-r 3) (pos-c 7) (type rural))
             (prior_cell (pos-r 3) (pos-c 8) (type rural))
             (prior_cell (pos-r 3) (pos-c 9) (type rural))
             (prior_cell (pos-r 3) (pos-c 10) (type lake))
             (prior_cell (pos-r 3) (pos-c 11) (type border))
             (prior_cell (pos-r 4) (pos-c 1) (type border))
             (prior_cell (pos-r 4) (pos-c 2) (type lake))
             (prior_cell (pos-r 4) (pos-c 3) (type urban))
             (prior_cell (pos-r 4) (pos-c 4) (type urban))
             (prior_cell (pos-r 4) (pos-c 5) (type rural))
             (prior_cell (pos-r 4) (pos-c 6) (type rural))
             (prior_cell (pos-r 4) (pos-c 7) (type hill))
             (prior_cell (pos-r 4) (pos-c 8) (type rural))
             (prior_cell (pos-r 4) (pos-c 9) (type rural))
             (prior_cell (pos-r 4) (pos-c 10) (type lake))
             (prior_cell (pos-r 4) (pos-c 11) (type border))
             (prior_cell (pos-r 5) (pos-c 1) (type border))
             (prior_cell (pos-r 5) (pos-c 2) (type lake))
             (prior_cell (pos-r 5) (pos-c 3) (type lake))
             (prior_cell (pos-r 5) (pos-c 4) (type rural))
             (prior_cell (pos-r 5) (pos-c 5) (type rural))
             (prior_cell (pos-r 5) (pos-c 6) (type hill))
             (prior_cell (pos-r 5) (pos-c 7) (type rural))
             (prior_cell (pos-r 5) (pos-c 8) (type rural))
             (prior_cell (pos-r 5) (pos-c 9) (type lake))
             (prior_cell (pos-r 5) (pos-c 10) (type urban))
             (prior_cell (pos-r 5) (pos-c 11) (type border))
	         (prior_cell (pos-r 6) (pos-c 1) (type border))
             (prior_cell (pos-r 6) (pos-c 2) (type rural))
             (prior_cell (pos-r 6) (pos-c 3) (type lake))
             (prior_cell (pos-r 6) (pos-c 4) (type rural))
             (prior_cell (pos-r 6) (pos-c 5) (type hill))
             (prior_cell (pos-r 6) (pos-c 6) (type rural))
             (prior_cell (pos-r 6) (pos-c 7) (type urban))
             (prior_cell (pos-r 6) (pos-c 8) (type lake))
             (prior_cell (pos-r 6) (pos-c 9) (type urban))
             (prior_cell (pos-r 6) (pos-c 10) (type rural))
             (prior_cell (pos-r 6) (pos-c 11) (type border))
             (prior_cell (pos-r 7) (pos-c 1) (type gate))
             (prior_cell (pos-r 7) (pos-c 2) (type rural))
             (prior_cell (pos-r 7) (pos-c 3) (type rural))
             (prior_cell (pos-r 7) (pos-c 4) (type rural))
             (prior_cell (pos-r 7) (pos-c 5) (type rural))
             (prior_cell (pos-r 7) (pos-c 6) (type urban))
             (prior_cell (pos-r 7) (pos-c 7) (type lake))
             (prior_cell (pos-r 7) (pos-c 8) (type hill))
             (prior_cell (pos-r 7) (pos-c 9) (type urban))
             (prior_cell (pos-r 7) (pos-c 10) (type rural))
             (prior_cell (pos-r 7) (pos-c 11) (type gate))
             (prior_cell (pos-r 8) (pos-c 1) (type border))
             (prior_cell (pos-r 8) (pos-c 2) (type urban))
             (prior_cell (pos-r 8) (pos-c 3) (type rural))
             (prior_cell (pos-r 8) (pos-c 4) (type urban))
             (prior_cell (pos-r 8) (pos-c 5) (type rural))
             (prior_cell (pos-r 8) (pos-c 6) (type urban))
             (prior_cell (pos-r 8) (pos-c 7) (type lake))
             (prior_cell (pos-r 8) (pos-c 8) (type rural))
             (prior_cell (pos-r 8) (pos-c 9) (type hill))
             (prior_cell (pos-r 8) (pos-c 10) (type hill))
             (prior_cell (pos-r 8) (pos-c 11) (type border))
             (prior_cell (pos-r 9) (pos-c 1) (type border))
             (prior_cell (pos-r 9) (pos-c 2) (type urban))
             (prior_cell (pos-r 9) (pos-c 3) (type urban))
             (prior_cell (pos-r 9) (pos-c 4) (type rural))
             (prior_cell (pos-r 9) (pos-c 5) (type rural))
             (prior_cell (pos-r 9) (pos-c 6) (type rural))
             (prior_cell (pos-r 9) (pos-c 7) (type rural))
             (prior_cell (pos-r 9) (pos-c 8) (type lake))
             (prior_cell (pos-r 9) (pos-c 9) (type hill))
             (prior_cell (pos-r 9) (pos-c 10) (type hill))
             (prior_cell (pos-r 9) (pos-c 11) (type border))
             (prior_cell (pos-r 10) (pos-c 1) (type border))
             (prior_cell (pos-r 10) (pos-c 2) (type border))
             (prior_cell (pos-r 10) (pos-c 3) (type border))
             (prior_cell (pos-r 10) (pos-c 4) (type border))
             (prior_cell (pos-r 10) (pos-c 5) (type border))
             (prior_cell (pos-r 10) (pos-c 6) (type border))
             (prior_cell (pos-r 10) (pos-c 7) (type gate))
             (prior_cell (pos-r 10) (pos-c 8) (type border))
             (prior_cell (pos-r 10) (pos-c 9) (type border))
             (prior_cell (pos-r 10) (pos-c 10) (type border))
             (prior_cell (pos-r 10) (pos-c 11) (type border))
             )
