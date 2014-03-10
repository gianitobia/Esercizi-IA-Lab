#fatti non ordinati
#Definizione di un template
#ogni attributo va in un singolo slot, possiamo impostare il tipo
(deftemplate stud
	(slot s1 (type SYMBOL))				#imposto che il valore deve essere una Stringa
	(slot s2 (type INTEGER))
	(slot s3 (default PIPPO))			#se non viene specificato si imposta PIPPO
	(slot s4 							
		(allowed-values a1, a2, an)
	)									#valori possibili accettabili
	(slot s5 
		(type INTEGER) (range (10 50))
	)
)

#posso combinare le varie property di ogni slot.
#Limite: dentro uno slot non posso impostare che a riempire uno slot sia un tipo definito altrove;

#per istanziare oggetto di tipo stud
(assert (stud (s1 b1) (s2 b2)) ...)