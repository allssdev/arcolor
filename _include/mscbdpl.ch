#ifdef SPANISH
	#define STR0001 "Administracion"
	#define STR0002 "A rayas"
	#define STR0003 "MSCBIMP.PRN"
	#define STR0004 "Impresion de etiqueta"
	#define STR0005 "error"
	#define STR0006 "falla en la apertura del puerto"
	#define STR0007 "falla en la apertura del puerto"
	#define STR0008 "Esperando... Falta papel "
	#define STR0009 "Esperando... Falta ribbon "
	#define STR0010 "Esperando... Impresora pausada "
	#define STR0011 "Funcion MSCBSAYMEMO no disponible para esta impresora"
	#define STR0012 "Incompatibilidad"
#else
	#ifdef ENGLISH
		#define STR0001 "Management"
		#define STR0002 "Z-form"
		#define STR0003 "MSCBIMP.PRN"
		#define STR0004 "Label reprint"
		#define STR0005 "error"
		#define STR0006 "error while opening door"
		#define STR0007 "error while opening door"
		#define STR0008 "Waiting... Lacking Paper "
		#define STR0009 "Waiting... Lacking ribbon "
		#define STR0010 "Waiting... Printer paused "
		#define STR0011 "MSCBSAYMEMO function not available for this printer"
		#define STR0012 "Incompatibility"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", , "Administracao" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", , "Zebrado" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", , "MSCBIMP.PRN" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", , "Impressao de Etiqueta" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", , "erro" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", , "falha na abertura da porta" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", , "falha na abertura da porta" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", , "Aguardando... Falta Papel " )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", , "Aguardando... Falta ribbon " )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", , "Aguardando... Impressora em Pausa " )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", , "Funcao MSCBSAYMEMO nao disponivel para esta impressora" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", , "Incompatibilidade" )
	#endif
#endif
