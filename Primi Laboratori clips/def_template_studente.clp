(deftemplate studente
	(slot matr (default ?NONE))
	(slot iscritto-a)
	(slot corso-di-laurea (allowed-values INF MAT ING FIS))
)

(defrule poli
	(studente (corso-di-laurea ING))
	=> (assert (iscritto-a POLI))
)
#viene creato un solo fatto (iscritto-a POLI)

(defrule poli2
	(studente (matr ?x) (corso-di-laurea ING))
	=> (assert (iscritto-a ?x POLI))
)
#e' creato un nuovo fatto per ogni studente trovato (iscritto-a matr POLI)

(defrule poli3
	?f1 <- (stud (corso-di-laurea ING))
	=> (modify ?f1 (iscritto-a PoliTO))
)
#viene modificato il fatto di partenza per cui si e' valida la precondizione
#bisogna controllare nelle precondizioni che non sia gia' impostato PoliTo come iscritto
#altrimenti si crea un Loop infinito di nuovi fatti.

#posso usare le deffacts
(deffacts pippo
	(nonno luca giorgio)
	(studente (matr 105))
)

#se esco dai vincoli impostati dalla deftemplate CLIPS me lo comunica e non crea il fatto
#(assert (studente (matr 102) (iscritto-a Unito) (corso-di-laurea FILO)))
#(assert (studente (iscritto-a Unito) (corso-di-laurea MAT)))


#creo istanze singole
(assert (studente (matr 100) (iscritto-a Unito) (corso-di-laurea MAT)))
(assert (studente (matr 101) (corso-di-laurea MAT)))

#se non specifico lo slot degli allowed-value lui lo imposta in automatico con il primo della lista
(assert (studente (matr 102) (iscritto-a Unito)))
(assert (studente (matr 300)) (studente (matr 301) (corso-di-laurea ING)))

#Posso cancellare dei fatti
(retract 3)

#modifichiamo un fatto non ordinato
#le modifche cancella il fatto nella WM e ne crea uno nuovo uguale ma con le modifiche apportate
(modify 4 (iscritto-a Unito))
(modify 5 (corso-di-laurea FILO))

