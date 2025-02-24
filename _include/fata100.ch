#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Copiar"
	#define STR0007 "Mantenimiento de reglas de negocio"
	#define STR0008 "Negociacion"
	#define STR0009 "Comercializacion"
	#define STR0010 "Descuentos"
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "Copy"
		#define STR0007 "Maintenance of Business Rules"
		#define STR0008 "Negotiation"
		#define STR0009 "Commercialization"
		#define STR0010 "Discounts"
	#else
		#define STR0001  "Pesquisar"
		#define STR0002  "Visualizar"
		#define STR0003  "Incluir"
		#define STR0004  "Alterar"
		#define STR0005  "Excluir"
		#define STR0006  "Copiar"
		Static STR0007 := "Manutencao das Regras de Negocio"
		Static STR0008 := "Negociacao"
		Static STR0009 := "Comercializacao"
		#define STR0010  "Descontos"
	#endif
#endif

#ifndef SPANISH
#ifndef ENGLISH
	STATIC uInit := __InitFun()

	Static Function __InitFun()
	uInit := Nil
	If Type('cPaisLoc') == 'C'

		If cPaisLoc == "ANG"
			STR0007 := "Manutenção Dos Regulamentos De Negócio"
			STR0008 := "Negociação"
			STR0009 := "Comercialização"
		ElseIf cPaisLoc == "PTG"
			STR0007 := "Manutenção Dos Regulamentos De Negócio"
			STR0008 := "Negociação"
			STR0009 := "Comercialização"
		EndIf
		EndIf
	Return Nil
#ENDIF
#ENDIF
