(deftemplate MacroAction
	(slot macrostep)
	(slot oper (allowed-values Move LoadDrink LoadFood DeliveryFood DeliveryDrink 
                        CleanTable EmptyFood Release CheckFinish))
	(slot param1)
	(slot param2)
	(slot param3)
)


