#ifdef SPANISH
	#define STR0001 "Administracion"
	#define STR0002 "A rayas"
	#define STR0003 "Impresion de etiqueta"
	#define STR0004 "error"
	#define STR0005 "DECLARACAO_DE_VARIAVEIS"
	#define STR0006 "falla en la apertura del puerto"
	#define STR0007 "Esperando... Buffer lleno o falta papel o falta ribbon o impressora pausada"
	#define STR0008 "Funcion MSCBSAYMEMO no disponible para esta impresora"
	#define STR0009 "Incompatibilidad"
	#define STR0010 "Esperando... Buffer lleno o falta papel o falta ribbon o impresora pausada"
	#define STR0011 "Funcion MSCBSAYMEMO no disponible para esta impresora"
	#define STR0012 "Incompatibilidad "
#else
	#ifdef ENGLISH
		#define STR0001 "Management"
		#define STR0002 "Z-form"
		#define STR0003 "Label Printing"
		#define STR0004 "error"
		#define STR0005 "VARIABLE_STATEMENT"
		#define STR0006 "error while opening door"
		#define STR0007 "Waiting... Buffer full or Paper Lacking or Ribbon Lacking or Printer Paused"
		#define STR0008 "MSCBSAYMEMO function not available for this printer"
		#define STR0009 "Incompatibility"
		#define STR0010 "Waiting... Buffer full or Paper Lacking or Ribbon Lacking or Printer Paused"
		#define STR0011 "MSCBSAYMEMO function not available for this printer"
		#define STR0012 "Incompatibility "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", , "Administracao" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", , "Zebrado" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", , "Impressao de Etiqueta" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", , "erro" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", , "DECLARACAO_DE_VARIAVEIS" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", , "falha na abertura da porta" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", , "Aguardando... Buffer cheio ou Falta Papel ou Falta Ribbon ou Impressora em Pausa" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", , "Funcao MSCBSAYMEMO nao disponivel para esta impressora" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", , "Incompatibilidade" )
		#define STR0010 "Aguardando... Buffer cheio ou Falta Papel ou Falta Ribbon ou Impressora em Pausa"
		#define STR0011 "Fun��o MSCBSAYMEMO n�o dispon�vel para esta impressora"
		#define STR0012 "Incompatibilidade "
	#endif
#endif
