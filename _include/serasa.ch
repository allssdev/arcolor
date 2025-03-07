#ifdef SPANISH
	#define STR0001 "SERASA - RELATO"
	#define STR0002 "   El objetivo de esta rutina es generar archivo preformateado para sistema SERASA/"
	#define STR0003 " RELATO  ( Informe de comportamiento en Negocios ), segun los parametros de la    "
	#define STR0004 "rutina y manual de homologacion de  SERASA."
	#define STR0005 "Mensual"
	#define STR0006 "Quincenal"
	#define STR0007 "Semanal"
	#define STR0008 "Diaria"
	#define STR0009 "Periodicidad ajustada Para: "
	#define STR0010 "Fecha Inicial"
	#define STR0011 "Fecha Final"
	#define STR0012 "SERASA - Producto resumido ( String de Dados - IP23 )"
	#define STR0013 "Error: Fallo en el intento de ajustar el Repositorio"
	#define STR0014 "Error: Fallo en el intento de crear el Repositorio"
#else
	#ifdef ENGLISH
		#define STR0001 "SERASA - REPORT"
		#define STR0002 "   The aim of this routine is to generate a preformatted file for the system"
		#define STR0003 "SERASA/REPORT (Behavior in Business Report ), according to the routine parameters"
		#define STR0004 " and SERASA agreement manual."
		#define STR0005 "Monthly"
		#define STR0006 "Fortnightly"
		#define STR0007 "Weekly"
		#define STR0008 "Daily"
		#define STR0009 "Periodicity adjusted for:"
		#define STR0010 "Initial Date"
		#define STR0011 "Final Date"
		#define STR0012 "SERASA - Summarized Product ( Data String - IP23 )"
		#define STR0013 "Error: Failure while adjusting replacement"
		#define STR0014 "Error: Failure while creating replacement"
	#else
		Static STR0001 := "SERASA - RELATO"
		Static STR0002 := "   Esta rotina tem como objetivo gerar o arquivo pre-formatado para o sistema SERASA/"
		Static STR0003 := " RELATO  ( Relatorio de comportamento em Negocios ),  conforme  os  parametros  da"
		Static STR0004 := "rotina e o manual de homologacao da SERASA."
		#define STR0005  "Mensal"
		#define STR0006  "Quinzenal"
		#define STR0007  "Semanal"
		Static STR0008 := "Diaria"
		#define STR0009  "Periodicidade ajustada para: "
		#define STR0010  "Data Inicial"
		#define STR0011  "Data Final"
		Static STR0012 := "SERASA - Produto Resumido ( String de Dados - IP23 )"
		Static STR0013 := "Erro: Falha na tentativa de ajustar o Repositorio"
		Static STR0014 := "Erro: Falha na tentativa de criar o Repositorio"
	#endif
#endif

#ifndef SPANISH
#ifndef ENGLISH
	STATIC uInit := __InitFun()

	Static Function __InitFun()
	uInit := Nil
	If Type('cPaisLoc') == 'C'

		If cPaisLoc == "ANG"
			STR0001 := "Serasa - Relato"
			STR0002 := "   Este Procedimento Tem Como Objectivo Criar O Ficheiro Pr�-formatado Para O Sistema Serasa/"
			STR0003 := " relato  ( relat�rio de comportamento em neg�cios ),  cofacturaorme  os  par�metros  da"
			STR0004 := "Rotina E O Manual De Homologa��o Da Serasa."
			STR0008 := "Di�ria"
			STR0012 := "Serasa - produto resumido ( cadeia de caracteres de dados - ip23 )"
			STR0013 := "Erro: Falha Na Tentativa De Ajustar O Reposit�rio"
			STR0014 := "Erro: Falha Na Tentativa De Criar O Reposit�rio"
		ElseIf cPaisLoc == "PTG"
			STR0001 := "Serasa - Relato"
			STR0002 := "   Este Procedimento Tem Como Objectivo Criar O Ficheiro Pr�-formatado Para O Sistema Serasa/"
			STR0003 := " relato  ( relat�rio de comportamento em neg�cios ),  cofacturaorme  os  par�metros  da"
			STR0004 := "Rotina E O Manual De Homologa��o Da Serasa."
			STR0008 := "Di�ria"
			STR0012 := "Serasa - produto resumido ( cadeia de caracteres de dados - ip23 )"
			STR0013 := "Erro: Falha Na Tentativa De Ajustar O Reposit�rio"
			STR0014 := "Erro: Falha Na Tentativa De Criar O Reposit�rio"
		EndIf
		EndIf
	Return Nil
#ENDIF
#ENDIF
