#ifdef SPANISH
	#define STR0001 "Este programa imprimira el libro mayor de la contabilidad,"
	#define STR0002 "de acuerdo con los parametros solicitados por"
	#define STR0003 "el usuario."
	#define STR0004 "A rayas"
	#define STR0005 "Administracion"
	#define STR0006 "Emision del mayor"
	#define STR0007 "EN MAYOR ANALITICO "
	#define STR0008 "EN MAYOR SINTETICO "
	#define STR0009 " DE "
	#define STR0010 " A  "
	#define STR0011 "(PRESUP)"
	#define STR0012 "(DE GEST. )"
	#define STR0013 If( cPaisLoc == "CHI", "LOTE/SUB/DOC/LINEA  H I S T O R I A L                        C/PARTIDA                      ", If( cPaisLoc == "EQU", "LOTE/SUB/DOC/LINEA  H I S T O R I A L                        C/PARTIDA                      ", "LOTE/SUB/DOC/LINEA  H I S T O R I A L                       C/PARTIDA                " ) )
	#define STR0014 "LOTE/SUB/DOC/LINEA  H I S T O R I A L                        C/PARTIDA                      DEBITO          CREDITO       SALDO ACTUAL"
	#define STR0015 "***** ANULADO POR EL OPERADOR *****"
	#define STR0016 "CUENTA- "
	#define STR0017 "Seleccionando registros..."
	#define STR0018 "Creando archivo temporal..."
	#define STR0019 "FECHA"
	#define STR0020 "T o t a l  de la  C u e n t a  ==> "
	#define STR0021 "CUENTA SIN MOV. DURANTE EL PERIODO"
	#define STR0022 "POR TRANSPORTAR :"
	#define STR0023 "DE TRANSPORTE :"
	#define STR0024 If( cPaisLoc == "MEX", "FECHA                                                                            CARGO                ABONO              SALDO ACT. ", "FECHA                                                                            DEBITO               CREDITO            SALDO ACTUAL" )
	#define STR0025 "T O T A L  G E N E R A L ==> "
	#define STR0026 "SIN MOV. DURANTE EL PERIODO"
	#define STR0027 "Deben crearse los parametros MV_LRAZABE y MV_LRAZENC. "
	#define STR0028 "Utilice como base el parametro MV_LDIARAB."
	#define STR0029 If( cPaisLoc == "MEX", "CARGO                ABONO             SALDO ACT. ", "DEBITO               CREDITO           SALDO ACTUAL" )
	#define STR0030 "El plan de gestion no esta disponible en este informe. "
	#define STR0031 If( cPaisLoc == "ARG", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "BOL", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "BRA", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "CHI", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "COL", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "COS", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "DOM", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "EUA", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "MEX", "LOTE/SUB/PLZ/LINEA H I S T O R I A L                        C/PARTIDA                       CARGO          ABONO         SALDO ACT. ", If( cPaisLoc == "PAN", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "PAR", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "PER", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "POR", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "SAL", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "URU", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", If( cPaisLoc == "VEN", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                       DEBITO         CREDITO       SALDO ACTUAL", "LOTE/SUB/PLZ/LINEA H I S T O R I A L                         C/PARTIDA                       CARGO          ABONO         SALDO ACTUAL" ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) )
	#define STR0032 If( cPaisLoc == "ARG", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                                                                                       DEBITO               CREDITO                SALDO ACTL.", If( cPaisLoc == "BOL", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "BRA", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                                                                                       DEBITO               CREDITO                SALDO ACTL.", If( cPaisLoc == "CHI", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "COL", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "COS", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "DOM", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "EUA", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "MEX", "LOTE/SUB/DOC/LINEA H I S T O R I A L                        C/PARTIDA                                                                          CARGO                ABONO                  SALDO ACT. ", If( cPaisLoc == "PAN", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "PAR", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "PER", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "POR", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "SAL", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "URU", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", If( cPaisLoc == "VEN", "LOTE/SUB/DOC/LINEA H I S T O R I A L                          C/PARTIDA                                                                                                   DEBITO               CREDITO         SALDO ACTUAL", "LOTE/SUB/PLZ/LINEA H I S T O R I A L                           C/PARTIDA                                                                                                   CARGO                ABONO           SALDO ACTUAL" ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) )
	#define STR0033 "SALDO ANTERIOR:"
	#define STR0034 "LOTE/SUB/DOC/LINEA"
	#define STR0035 "HISTORIAL"
	#define STR0036 "XPARTIDA"
	#define STR0037 If( cPaisLoc == "MEX", "CARGO", "DEBITO" )
	#define STR0038 If( cPaisLoc == "MEX", "ABONO", "CREDITO" )
	#define STR0039 "SALDO ACT."
	#define STR0040 "SEGOFI"
	#define STR0041 "CTA. "
	#define STR0042 "DESCRIPC."
	#define STR0043 "Cta. "
	#define STR0044 "Asientos Contables"
	#define STR0045 "Tot."
	#define STR0046 "Complemento"
	#define STR0047 "Atencion"
	#define STR0048 "No existen datos para los parametros especificados."
	#define STR0049 "Atencion, las columnas de los entes Cl Valor, C. Costo e Item Contable no se imprimiran en el modo vertical o en la opcion Resumido"
	#define STR0050 "Totalizadores de la Cuenta"
	#define STR0051 "Totalizadores de Transporte"
	#define STR0052 "Sucursal:"
	#define STR0053 "Linea de Fch."
	#define STR0054 "MAYOR RESUMIDO EN "
	#define STR0055 "FECHA                                                                                        DEBITO         CREDITO    SALDO ACT. "
	#define STR0056 "FORMATO: 6.1:LIBRO MAYOR ANALITICO "
	#define STR0057 "FORMATO: 6.1:LIBRO MAYOR SINTETICO "
	#define STR0058 "SUCURSAL DE ORIGEN"
	#define STR0059 "Fecha de la operacion"
	#define STR0060 "Numero correlativo del Libro diario"
	#define STR0061 "Descripcion o Glosa de la operacion"
	#define STR0062 "Deudor"
	#define STR0063 "Acreedor"
	#define STR0064 "Saldos y movimientos"
	#define STR0065 "FORMATO 6.1:LIBRO MAYOR"
	#define STR0066 "Codigo y denominacion de la cuenta contable:"
#else
	#ifdef ENGLISH
		#define STR0001 "This program will print the Accounting Ledger,"
		#define STR0002 "according to the parameters selected by the "
		#define STR0003 "user."
		#define STR0004 "Z.Form"
		#define STR0005 "Management"
		#define STR0006 "Print Accounting Ledger"
		#define STR0007 "DETAILED LEDGER IN "
		#define STR0008 "SUMMARIZED LEDGER IN "
		#define STR0009 " FROM "
		#define STR0010 " TO "
		#define STR0011 "(BUDGETED)"
		#define STR0012 "(MANAGERIAL)"
		#define STR0013 If( cPaisLoc == "CHI", "LOT/SUB/DOC/LINE    H I S T O R Y                            W/ENTRY                        ", "LOT/SUB/DOC/ROW  H I S T O R Y                               W/ENTRY                " )
		#define STR0014 "LOT /SUB/DOC/LINE  H I S T O R Y                            W/ENTRY                        DEBIT           CREDIT        CURR.BALAC."
		#define STR0015 "***** CANCELLED BY OPERATOR   *****"
		#define STR0016 "ACCOUNT "
		#define STR0017 "Selecting Records..."
		#define STR0018 "Creating Temporary File..."
		#define STR0019 "DATE"
		#define STR0020 "A c c o u n t   T o t a l    ==> "
		#define STR0021 "ACCOUNT WITHOUT MOVEMENTS IN THIS PERIOD"
		#define STR0022 "TO TRANSPORT :"
		#define STR0023 "FROM TRANSPORT :"
		#define STR0024 "DATE                                                                             DEBIT                CREDIT            CURR.BALANCE"
		#define STR0025 "G R A N D  T O T A L ==> "
		#define STR0026 "WITHOUT MOVEMENTS IN THIS PERIOD"
		#define STR0027 "The parameters MV_LRAZABE and MV_LRAZENC must be created. "
		#define STR0028 "Use the parameter MV_LDIARAB as base."
		#define STR0029 "DEBIT                CREDIT            CURRENT BALANCE    "
		#define STR0030 "The management plan is not available for this rport. "
		#define STR0031 If( cPaisLoc == "BRA", "LOT/SUB/DOC/ROW H I S T O R Y                        D/ENTRY                       DEBIT         CREDIT      CURRENT BALANCE ", "LOT /SUB/DOC/LINE  H I S T O R Y                            W/ENTRY                         DEBIT          CREDIT        CURR.BALAC." )
		#define STR0032 "LOT /SUB/DOC/LINE  H I S T O R Y                              W/ENTRY                                                                                                     DEBIT                CREDIT          CURR.BALC. "
		#define STR0033 "PREVIOUS BALANCE:"
		#define STR0034 "LOT/SUB/DOC/LINE  "
		#define STR0035 "HISTORY  "
		#define STR0036 "X ENTRY "
		#define STR0037 "DEBIT "
		#define STR0038 "CREDIT "
		#define STR0039 "CURRENT BLN"
		#define STR0040 "SEGOFI"
		#define STR0041 "ACCT."
		#define STR0042 "DESCRIPT."
		#define STR0043 "Acct."
		#define STR0044 "Accounting entries   "
		#define STR0045 "Totals"
		#define STR0046 "Complement "
		#define STR0047 "Attention"
		#define STR0048 "No data for the parameters specified.              "
		#define STR0049 "Attention. Columns of the entities Value Cl, Cost Center and Accounting Item will not be printed in portrait or Summarized"
		#define STR0050 "Account totalizers"
		#define STR0051 "Transportation totalizers"
		#define STR0052 "Branch"
		#define STR0053 "Date Line"
		#define STR0054 "LEDGER SUMMARIZED IN "
		#define STR0055 "DATE                                                                                       DEBIT      CREDIT   CURRENT BALANCE"
		#define STR0056 "FORMAT: 6.1:ANALYTIC REASON BOOK "
		#define STR0057 "FORMAT: 6.1:SYNTHETIC REASON BOOK "
		#define STR0058 "SOURCE BRANCH"
		#define STR0059 "Date of Operation"
		#define STR0060 "Journal Correlative Number"
		#define STR0061 "Description or Disallowance of Operation"
		#define STR0062 "Debtor"
		#define STR0063 "Creditor"
		#define STR0064 "Balances and Transactions"
		#define STR0065 "FORMAT 6.1:BIGGER LOGBOOK"
		#define STR0066 "Code and Denomination of Ledger Account"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este programa ir� imprimir o Raz�o Cont�bil dos lan�amentos", "Este programa ir� imprimir o Raz�o Contabil," )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "De acordo com os par�metros pedidos pelo", "de acordo com os parametros solicitados pelo" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Utilizador.", "usu�rio." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "C�digo de barras", "Zebrado" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Administra��o", "Administracao" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Emiss�o Da Raz�o Contabil�stica", "Emissao do Razao Contabil" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Raz�o anal�tico em ", "RAZAO ANALITICO EM " )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Raz�o sint�tico em ", "RAZAO SINTETICO EM " )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " de ", " DE " )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", " at� ", " ATE " )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "(or�amentado)", "(ORCADO)" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "(DE GEST�O)", "(GERENCIAL)" )
		#define STR0013 If( cPaisLoc $ "ANG|ARG|BOL|BRA|COL|COS|DOM|EQU|EUA|HAI|MEX|PAN|PAR|PER|POR|PTG|SAL|URU|VEN", "LOTE/SUB/DOC/LINHA  H I S T O R I C O                       C/PARTIDA                ", If( cPaisLoc == "CHI", "Lote/sub/doc/linha correlat. h i s t o r i a l              c/partida                      ", "LOTE/SUB/DOC/LINHA  H I S T O R I C O                       C/PARTIDA                " ) )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Lote/sub/doc/linha H I S T � R I C O                        C/partida                      D�bito          Cr�dito       Saldo Actual", "LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                      DEBITO          CREDITO       SALDO ATUAL" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "***** cancelado pelo operador *****", "***** CANCELADO PELO OPERADOR *****" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Conta - ", "CONTA - " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Registos...", "Selecionando Registros..." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "A Criar Ficheiro Tempor�rio...", "Criando Arquivo Tempor�rio..." )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Data", "DATA" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "T o t a i s  d a  c o n t a  ==> ", "T o t a i s  d a  C o n t a  ==> " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Conta Sem Movimento No Per�odo", "CONTA SEM MOVIMENTO NO PERIODO" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "A transportar :", "A TRANSPORTAR :" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "De transporte :", "DE TRANSPORTE :" )
		#define STR0024 If( cPaisLoc $ "ANG|EQU|HAI", "DATA                                                                             D�BITO               CR�DITO            SALDO ATUAL", If( cPaisLoc $ "MEX|PTG", "Data                                                                             D�bito               Cr�dito            Saldo Actual", "DATA                                                                             DEBITO               CREDITO            SALDO ATUAL" ) )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "T o t a l  g e r a l ==> ", "T O T A L  G E R A L ==> " )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Sem Movimento No Per�odo", "SEM MOVIMENTO NO PERIODO" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Devem ser criados os par�metros MV_LRAZABE e MV_LRAZENC. ", "Devem ser criados os parametros MV_LRAZABE e MV_LRAZENC. " )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Utilize Como Base O Par�metro Mv_ldiarab.", "Utilize como base o parametro MV_LDIARAB." )
		#define STR0029 If( cPaisLoc $ "ANG|EQU|HAI", "D�BITO               CR�DITO           SALDO ATUAL        ", If( cPaisLoc $ "MEX|PTG", "D�bito               cr�dito           saldo actual        ", "DEBITO               CREDITO           SALDO ATUAL        " ) )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "O plano anal�tico n�o est� dispon�vel neste relat�rio.", "O plano gerencial nao esta disponivel nesse relatorio." )
		#define STR0031 If( cPaisLoc $ "ANG|EQU|HAI", "LOTE/SUB/DOC/LINHA H I S T � R I C O                        C/PARTIDA                       D�BITO         CR�DITO       SALDO ATUAL", If( cPaisLoc $ "ARG|BOL|COL|COS|DOM|EUA|MEX|PAN|PAR|PER|POR|PTG|SAL|URU|VEN", "Lote/sub/doc/linha H I S T � R I C O                        C/partida                       D�bito         Cr�dito       Saldo Actual", If( cPaisLoc == "BRA", "LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                       DEBITO         CREDITO       SALDO ATUAL ", If( cPaisLoc == "CHI", "Lote/sub/doc/linha Correlat. H I S T O R I A L              C/partida                       D�bito         Cr�dito       Saldo Actual", "LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                       DEBITO         CREDITO       SALDO ATUAL" ) ) ) )
		#define STR0032 If( cPaisLoc $ "ANG|EQU|HAI", "LOTE/SUB/DOC/LINHA H I S T � R I C O                        C/PARTIDA                                                                                       DEBITO               CREDITO                SALDO ATUAL", If( cPaisLoc $ "ARG|BOL|BRA|COL|COS|DOM|EUA|MEX|PAN|PAR|PER|POR|PTG|SAL|URU|VEN", "LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                                                                                       DEBITO               CREDITO                SALDO ATUAL", If( cPaisLoc == "CHI", "Lote/sub/doc/linha Correlat. H I S T O R I A L              C/partida                                                                                                                D�bito               Cr�dito         Saldo Actual", "LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                                                                                       DEBITO               CREDITO                SALDO ATUAL" ) ) )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Saldo Anterior:", "SALDO ANTERIOR:" )
		#define STR0034 If( cPaisLoc $ "CHI|ANG|PTG", "Lote/sub/doc./linha", "LOTE/SUB/DOC/LINHA" )
		#define STR0035 If( cPaisLoc $ "CHI|ANG|PTG", "HIST�RICO", "HISTORICO" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Xpartida", "XPARTIDA" )
		#define STR0037 If( cPaisLoc $ "ANG|EQU|HAI", "D�BITO", If( cPaisLoc $ "MEX|PTG", "D�bito", "DEBITO" ) )
		#define STR0038 If( cPaisLoc $ "ANG|EQU|HAI", "CR�DITO", If( cPaisLoc $ "MEX|PTG", "Cr�dito", "CREDITO" ) )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "SALDO ACTUAL", "SALDO ATUAL" )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Segofi", "SEGOFI" )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Conta", "CONTA" )
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "Descri��o", "DESCRICAO" )
		#define STR0043 "Conta"
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Lan�amentos Contabil�sticos", "Lan�amentos Cont�beis" )
		#define STR0045 "Totais"
		#define STR0046 "Complemento"
		#define STR0047 "Aten��o"
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "N�o existem dados para os par�metros especificados.", "Nao existem dados para os par�metros especificados." )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "Aten��o, as colunas das entidades Cl Valor, C.Custo e Item Contabil�stico n�o ser�o impressas no modo vertical ou na op��o Resumido", "Aten��o, as colunas das entidades Cl Valor, C.Custo e Item Cont�bil  n�o ser�o impressas no modo retrato ou na op��o Resumido" )
		#define STR0050 "Totalizadores da Conta"
		#define STR0051 "Totalizadores de Transporte"
		#define STR0052 "Filial"
		#define STR0053 "Linha da Data"
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "RAZ�O RESUMIDO EM ", "RAZAO RESUMIDO EM " )
		#define STR0055 If( cPaisLoc $ "ANG|PTG", "DATA                                                                                         D�BITO         CR�DITO    SALDO ACTUAL", "DATA                                                                                         DEBITO         CREDITO    SALDO ATUAL" )
		#define STR0056 "FORMATO: 6.1:LIVRO RAZAO ANALITICO "
		#define STR0057 "FORMATO: 6.1:LIVRO RAZAO SINTETICO "
		#define STR0058 "FILIAL DE ORIGEM"
		#define STR0059 "Data da Opera��o"
		#define STR0060 "N�mero Correlativo do Livro Di�rio"
		#define STR0061 "Descri��o ou Glosa da Opera��o"
		#define STR0062 "Devedor"
		#define STR0063 "Credor"
		#define STR0064 "Saldos e Movimentos"
		#define STR0065 "FORMATO 6.1:LIVRO MAIOR"
		#define STR0066 "C�digo e Denomina��o da Conta Cont�bil:"
	#endif
#endif
