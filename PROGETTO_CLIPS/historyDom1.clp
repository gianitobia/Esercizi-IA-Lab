(personstatus 	

	(step 0)
        (time 0)

	(ident C1)

	(pos-r 7)

	(pos-c 3)

	(activity seated))

(personstatus 	

	(step 0)
        (time 0)

	(ident C2)

	(pos-r 8)

	(pos-c 10)

	(activity seated))


(personstatus 	

	(step 0)
        (time 0)

	(ident C3)

	(pos-r 3)

	(pos-c 4)

	(activity seated))
		
(event (step 1) (type request) (source T4) (food 1) (drink 1)) 
(event (step 5) (type request) (source T3) (food 3) (drink 2)) 
(event (step 9) (type finish) (source T4))
(event (step 12) (type request) (source T4) (food 0) (drink 2)) 

(personmove (step 2) (ident C1) (path-id P1))

(personmove (step 9) (ident C1) (path-id P2))

(move-path P1 1 C1  7 2)
(move-path P1 2 C1  6 2)
(move-path P1 3 C1  5 2)
(move-path P1 4 C1  4 2)


(move-path P2 1 C1  5 2)
(move-path P2 2 C1  5 3)
(move-path P2 3 C1  5 4)
(move-path P2 4 C1  4 4)
(move-path P2 5 C1  3 4)
(move-path P2 6 C1  4 5)


