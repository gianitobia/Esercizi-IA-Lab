calcola_euristica(pos(Ri,Ci),pos(Rf,Cf),H) :-
	Rt is Ri - Rf,
	Ct is Ci - Cf,
	H is abs(Rt) + abs(Ct).