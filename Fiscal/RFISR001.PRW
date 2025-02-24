#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "FWBROWSE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFISR001  บAutor  ณJ๚lio Soares        บ Data ณ  25/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relat๓rio de documentos cancelados.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ

*/

User Function RFISR001()

cabec1   := "                                                RELAวรO DE DOCUMENTOS DE SAIDA CANCELADOS"
cabec2   := " Documento-S้rie  Cliente/loja  Nome do cliente                                     Est   Dt.Emiss    Dt.Cancel       Valor Doc "
cabec3   := ""
wnrel    := "RFISR001"
_cRotina := "RFISR001"
Titulo   := "Relat๓rio de documentos cancelados por "
cDesc1   := "Este programa irแ emitir todos"
cDesc2   := "os documentos cancelados conforme"
cDesc3   := "informa็๕es dos parโmetros"
cString  := "SF2"
nLastKey := 0
aReturn  := { "Especial", 1,"Faturamento", 2, 2, 1, "",1 }
nomeprog := _cRotina
cPerg    := _cRotina
_nLin    := 100
m_pag    := 1
aOrd	 := {}
tamanho  := "M" //132
nTipo    := 18
MV_PAR08 := 3

Private _nPuladas := 0 //Linha adicionada por Adriano Leonardo em 05/12/2013 para implementa็ใo de novas funcionalidades
Private _lEnt := + CHR(13) + CHR(10)
Private _cBanco := 'SuperGetMv("MV_TSSBANC",,"TSSP12_PRODUCAO")'

Private _lJob       := Type("CFILANT")=="U"    

If _lJob
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina tables "SA1", "SA3", "SF2"
Endif

_cBanco := SuperGetMv("MV_TSSBANC",,"TSSP12_PRODUCAO")

// Verifica as perguntas selecionadas
ValidPerg()

// - Apresenta tela de sele็ใo dos parโmetros
pergunte(cPerg,.F.)
//If !Pergunte(cPerg,.T.) //Apresenta tela dos parโmetros antes de abrir a tela de configura็๕es da impressใo.
//	Return
//EndIf

// Envia controle para a funcao SETPRINT
wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,"","","",.F.)

If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

If MV_PAR07 == 1
	Titulo := AllTrim(Titulo) + " Emissao"
ElseIf MV_PAR07 == 2
	Titulo := AllTrim(Titulo) + " Cancelamento"
EndIf	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|lEnd| RptDetail(@lEnd)})
Return

// Cria แrea de trabalho
Static Function RptDetail(lEnd)
_cQry   := ""
_cQryF1 := ""
_cQryF2 := ""

	//Linha adicionada por Adriano Leonardo em 07/03/2014 - adapta็ใo da query para contemplar as notas de entrada
	//_cQry := "SELECT * FROM ( " +_lEnt 
	_cQryF2 := " SELECT F2_EMISSAO,F2_SERIE,F2_DOC, " +_lEnt
	_cQryF2 += "    ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),NFE_ID))    ,'') AS NFE_ID, " +_lEnt
	_cQryF2 += "    F2_CLIENTE, F2_EST, F2_LOJA, " +_lEnt
	 //Linha adicionada por Adriano Leonardo em 03/02/2014 para corre็ใo da rotina
	_cQryF2 += "	  CASE WHEN F2_TIPO NOT IN ('D','B') THEN A1_NOME ELSE A2_NOME END AS [NOME], " +_lEnt
	_cQryF2 += "	  A1_NREDUZ, F2_VALBRUT, " +_lEnt
	_cQryF2 += "    ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),NFE_CHV))   ,'') AS NFE_CHV,SF2.F2_CHVNFE, " +_lEnt
	_cQryF2 += "    ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),F2_MOTEXCL)),'') AS F2_MOTEXCL, " +_lEnt
	_cQryF2 += "    ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),XMOT_SEFR)) ,'') AS XMOT_SEFR, " +_lEnt
	_cQryF2 += "    F2_DTEXCLS, " +_lEnt
	_cQryF2 += "    ISNULL(CAST(CASE WHEN LEN(DTREC_SEFR)<>8  THEN '' ELSE DTREC_SEFR END AS NVARCHAR),'') AS DTREC_SEFR, " +_lEnt
	//Linha adicionada por Adriano Leonardo em 04/12/2013
	_cQryF2 += "	  (SELECT TOP 1 SD2.D2_PEDIDO FROM " + RetSqlName("SD2") + " SD2 WHERE SD2.D2_DOC=F2_DOC AND SD2.D2_SERIE=F2_SERIE AND SD2.D2_CLIENTE=F2_CLIENTE AND SD2.D_E_L_E_T_=SF2.D_E_L_E_T_ AND SD2.D2_EMISSAO=SF2.F2_EMISSAO) AS [D2_PEDIDO] " +_lEnt
	_cQryF2 += " FROM " + RetSqlName("SF2") + " SF2 " +_lEnt
	_cQryF2 += "    LEFT JOIN " + RetSqlName("SA1") + " SA1 " +_lEnt
	_cQryF2 += "       ON  SF2.F2_CLIENTE  = SA1.A1_COD " +_lEnt
	_cQryF2 += " 	     AND SF2.F2_LOJA     = SA1.A1_LOJA " +_lEnt
	//Inํcio - Trecho adicionado por Adriano Leonardo em 03/02/2014 para corre็ใo
	_cQryF2 += " 	     AND SA1.D_E_L_E_T_='' " +_lEnt
	_cQryF2 += " 	     AND SA1.A1_FILIAL='"+ xFilial("SA1") +"' " +_lEnt
	_cQryF2 += "    LEFT JOIN " + RetSqlName("SA2") + " SA2 " +_lEnt
	_cQryF2 += "       ON  SF2.F2_CLIENTE  = SA2.A2_COD " +_lEnt
	_cQryF2 += " 	     AND SF2.F2_LOJA     = SA2.A2_LOJA " +_lEnt
	_cQryF2 += " 	     AND SA2.D_E_L_E_T_='' " +_lEnt
	_cQryF2 += " 	     AND SA2.A2_FILIAL='"+ xFilial("SA2") +"' " +_lEnt
	//Final  - Trecho adicionado por Adriano Leonardo em 03/02/2014 para corre็ใo
	_cQryF2 += "    LEFT JOIN "+_cBanco+".dbo.SPED054 S54 " +_lEnt
	_cQryF2 += "       ON  S54.D_E_L_E_T_='' and S54.NFE_ID      = (SF2.F2_SERIE + SF2.F2_DOC) " +_lEnt
//	_cQryF2 += "       --AND S54.NFE_CHV     = SF2.F2_CHVNFE "
	_cQryF2 += " 	     AND ((S54.XMOT_SEFR  LIKE '%Deneg%' OR S54.XMOT_SEFR LIKE '%DENEG%') OR (S54.XMOT_SEFR LIKE '%Inuti%' OR S54.XMOT_SEFR LIKE '%INUTI%')) " +_lEnt
	_cQryF2 += " WHERE SF2.F2_FILIAL       = '" + xFilial("SF2") + "' " +_lEnt
	_cQryF2 += "       AND SF2.F2_SERIE    BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " +_lEnt
	_cQryF2 += "       AND SF2.F2_DOC      BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " +_lEnt

    If MV_PAR07 == 1
		_cQryF2 += "   AND SF2.F2_EMISSAO  BETWEEN '" + (DTOS(mv_par05)) + "' AND '" + (DTOS(mv_par06)) + "' " +_lEnt
    ElseIf MV_PAR07 == 2	
		_cQryF2 += "   AND (SF2.F2_DTEXCLS  BETWEEN '" + (DTOS(mv_par05)) + "' AND '" + (DTOS(mv_par06)) + "' " +_lEnt
		_cQryF2 += "   OR   DTREC_SEFR      BETWEEN '" + (DTOS(mv_par05)) + "' AND '" + (DTOS(mv_par06)) + "') " +_lEnt
	EndIf
	_cQryF2 += "       AND (SF2.D_E_L_E_T_ = '*'  " +_lEnt
	_cQryF2 += "       OR S54.XMOT_SEFR    LIKE '%Deneg%' " +_lEnt
	_cQryF2 += "       OR S54.XMOT_SEFR    LIKE '%Inuti%' " +_lEnt
	_cQryF2 += "       ) " +_lEnt
	
	//Inํcio - Trecho adicionado por Adriano Leonardo em 07/03/2014 - para inclusใo de avalia็ใo tamb้m das notas de entrada
	//_cQry += "    UNION ALL " +_lEnt

	//cQryF1 := "SELECT F1_EMISSAO,F1_SERIE,F1_DOC, " +_lEnt
	_cQryF1 := "SELECT F1_EMISSAO[F2_EMISSAO],F1_SERIE[F2_SERIE],F1_DOC[F2_DOC], " +_lEnt
	_cQryF1 += "ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),NFE_ID))    ,'') AS NFE_ID, " +_lEnt
	//cQryF1 += "F1_FORNECE, F1_EST, F1_LOJA, " +_lEnt
	_cQryF1 += "F1_FORNECE[F2_CLIENTE], F1_EST[F2_EST], F1_LOJA[F2_LOJA], " +_lEnt
	_cQryF1 += "CASE WHEN F1_TIPO NOT IN ('D','B') THEN A2_NOME ELSE A1_NOME END AS [NOME], " +_lEnt
	//_cQryF1 += " 	  CASE WHEN F1_TIPO NOT IN ('D','B') THEN A2_NREDUZ ELSE A1_NREDUZ END AS [A2_NREDUZ], " +_lEnt
	_cQryF1 += " 	  CASE WHEN F1_TIPO NOT IN ('D','B') THEN A2_NREDUZ ELSE A1_NREDUZ END AS [A1_NREDUZ], " +_lEnt
	//_cQryF1 += " 	  F1_VALBRUT, " +_lEnt
	_cQryF1 += " 	  F1_VALBRUT[F2_VALBRUT], " +_lEnt
	//_cQryF1 += "     ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),NFE_CHV))   ,'') AS NFE_CHV,SF1.F1_CHVNFE, " +_lEnt
	_cQryF1 += "     ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),NFE_CHV))   ,'') AS NFE_CHV,SF1.F1_CHVNFE[F2_CHVNFE], " +_lEnt
	//_cQryF1 += "     ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),'(Nota de entrada) - Cancelada')),'') AS F1_MOTEXCL, " +_lEnt
	_cQryF1 += "     ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),'(Nota de entrada) - Cancelada')),'') AS F2_MOTEXCL, " +_lEnt
	_cQryF1 += "     ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),XMOT_SEFR)) ,'') AS XMOT_SEFR, " +_lEnt
	//_cQryF1 += "     '' AS [F1_DTEXCLS], " +_lEnt
	_cQryF1 += "     '' AS [F2_DTEXCLS], " +_lEnt
	_cQryF1 += "     ISNULL(CAST(CASE WHEN LEN(DTREC_SEFR)<>8  THEN '' ELSE DTREC_SEFR END AS NVARCHAR),'') AS DTREC_SEFR, " +_lEnt
	_cQryF1 += " 	 (SELECT TOP 1 SD1.D1_PEDIDO "                                   +_lEnt
	_cQryF1 += "       FROM "  + RetSqlName("SD1") + " SD1 "                         +_lEnt
	_cQryF1 += "       WHERE SD1.D1_DOC = F1_DOC "                                   +_lEnt
	_cQryF1 += "       AND SD1.D1_SERIE = F1_SERIE "                                 +_lEnt
	_cQryF1 += "       AND SD1.D1_FORNECE = F1_FORNECE "                             +_lEnt
	_cQryF1 += "       AND SD1.D_E_L_E_T_ = SF1.D_E_L_E_T_ "                         +_lEnt
	_cQryF1 += "       AND SD1.D1_EMISSAO = SF1.F1_EMISSAO "                         +_lEnt
	_cQryF1 += "     ) AS [D2_PEDIDO] "                                              +_lEnt
	_cQryF1 += "  FROM "  + RetSqlName("SF1") + " SF1 "                              +_lEnt
	_cQryF1 += "     LEFT JOIN "  + RetSqlName("SA1") + "  SA1 "                     +_lEnt
	_cQryF1 += "        ON  SF1.F1_FORNECE  = SA1.A1_COD "                           +_lEnt
	_cQryF1 += "  	    AND SF1.F1_LOJA     = SA1.A1_LOJA "                          +_lEnt
	_cQryF1 += "  	    AND SA1.D_E_L_E_T_  = '' "                                   +_lEnt
	_cQryF1 += "  	    AND SA1.A1_FILIAL   = '" + xFilial("SA1") + "' "             +_lEnt
	_cQryF1 += "     LEFT JOIN "  + RetSqlName("SA2") + " SA2 "                      +_lEnt
	_cQryF1 += "        ON  SF1.F1_FORNECE  = SA2.A2_COD "                           +_lEnt
	_cQryF1 += "  	    AND SF1.F1_LOJA     = SA2.A2_LOJA "                          +_lEnt
	_cQryF1 += "  	    AND SA2.D_E_L_E_T_='' "                                      +_lEnt
	_cQryF1 += "  	    AND SA2.A2_FILIAL='"+ xFilial("SA2") +"' "                   +_lEnt
	_cQryF1 += "     LEFT JOIN "+_cBanco+".dbo.SPED054 S54 "                              +_lEnt
	_cQryF1 += "        ON S54.D_E_L_E_T_=''  AND S54.NFE_ID      = (SF1.F1_SERIE + SF1.F1_DOC) "          +_lEnt
	_cQryF1 += "  	    AND ((UPPER(S54.XMOT_SEFR)  LIKE '%DENEG%') "                +_lEnt
	_cQryF1 += "  	    OR (UPPER(S54.XMOT_SEFR) LIKE '%INUTI%')) "                  +_lEnt
	_cQryF1 += "  WHERE SF1.F1_FILIAL       = '" + xFilial("SF1") + "' "             +_lEnt
	_cQryF1 += "  AND SF1.F1_SERIE    BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " +_lEnt
	_cQryF1 += "  AND SF1.F1_DOC      BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " +_lEnt
	//Linha comentada por Adriano Leonardo em 03/06/2014 para corre็ใo
	//_cQryF1 += "AND SF1.F1_FORMUL='S' " 
	//Linha comentada por Adriano Leonardo em 03/06/2014 para corre็ใo
	//_cQryF1 += "AND SF1.F1_CHVNFE<>'' "
	_cQryF1 += "  AND (NFE_ID<>''  OR F1_CHVNFE<>'') " +_lEnt
	_cQryF1 += "  AND SF1.F1_EMISSAO  BETWEEN '" + (DTOS(mv_par05)) + "' AND '" + (DTOS(mv_par06)) + "' " +_lEnt
	_cQryF1 += "  AND (SF1.D_E_L_E_T_ = '*' " +_lEnt
	_cQryF1 += "  OR UPPER(S54.XMOT_SEFR)    LIKE '%DENEG%' " +_lEnt
	_cQryF1 += "  OR UPPER(S54.XMOT_SEFR)    LIKE '%INUTI%' " +_lEnt
	_cQryF1 += "  ) " +_lEnt

	//_cQry += "     ) AUX " +_lEnt
	//Final  - Trecho adicionado por Adriano Leonardo em 07/03/2014 - para inclusใo de avalia็ใo tamb้m das notas de entrada

	// - Trecho inserido por J๚lio Soares para montagem da query conforme parโmetros inseridos.
	If MV_PAR08 == 1
		_cQry := _cQryF2
	ElseIf MV_PAR08 == 2
		_cQry := _cQryF1
		_cQry += " ORDER BY F1_DOC, F1_DTDIGIT "
	ElseIf MV_PAR08 == 3
		_cQry := "SELECT * FROM ( " +_lEnt 
		_cQry += _cQryF2
		_cQry += " 	UNION ALL " +_lEnt
		_cQry += _cQryF1	
	    _cQry += "     ) AUX " +_lEnt
	EndIf

	If MV_PAR08 == 3 .Or. MV_PAR08 == 1
		If MV_PAR07 == 1 
			_cQry += " ORDER BY F2_DOC, F2_EMISSAO " +_lEnt
		ElseIf MV_PAR07 == 2
			_cQry += " ORDER BY F2_DOC, F2_DTEXCLS, DTREC_SEFR " +_lEnt
		EndIf
    EndIf

	//Gera arquivo txt com query
    
	If __cUserId == "000000"
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
	EndIf
    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TRA",.T.,.F.)
	dbSelectArea("TRA")
	TRA->(dbSetOrder(0))
	SetRegua(RecCount())
	TRA->(dbGoTop())
	While !(TRA->(EOF())) .And. !lEnd

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
		If lAbortPrint
			@ 00,00 PSay "CANCELADO PELO OPERADOR"
			Exit
		EndIf

	// Imprime o cabe็alho
	If _nLin > 60
		_nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif                                    
	_nLin	++

   // Impressใo dos resultados

	@ _nLin, 002 PSay TRA->F2_DOC + '-' + TRA->F2_SERIE
	@ _nLin, 018 PSay TRA->F2_CLIENTE + '/' + TRA->F2_LOJA
	@ _nLin, 030 PSay (SUBSTR(TRA->NOME,1,50))
	@ _nLin, 084 PSay TRA->F2_EST
	@ _nLin, 090 Psay STOD(F2_EMISSAO)
	If !Empty (TRA->F2_DTEXCLS) //.And. Empty(TRA->DTREC_SEFR)
		@ _nLin, 102 Psay (STOD(TRA->F2_DTEXCLS))
	ElseIf Empty (TRA->F2_DTEXCLS)
		@ _nLin, 102 Psay (STOD(TRA->DTREC_SEFR))
	EndIf
	@ _nLin, 115 PSay "R$ "
	@ _nLin, 120 PSay TRA->F2_VALBRUT Picture '@E 99,999,999.99'
	_nLin++
	If !Empty (TRA->F2_MOTEXCL)
		If Len(Alltrim(TRA->F2_MOTEXCL))>120
			@ _nLin, 002 PSay "Pedido - " + AllTrim(TRA->D2_PEDIDO) + " - " + "Motivo "
			@ _nLin, 030 PSay SUBSTR(Alltrim(TRA->F2_MOTEXCL),1,120  )
		_nLin++
			@ _nLin, 015 PSay SUBSTR(Alltrim(TRA->F2_MOTEXCL),120,240)
		_nLin++
			@ _nLin, 015 PSay SUBSTR(Alltrim(TRA->F2_MOTEXCL)+ " - " + AllTrim(TRA->XMOT_SEFR),240,360)
		Else
			@ _nLin, 002 PSay "Pedido - " + AllTrim(TRA->D2_PEDIDO) + " - " + "Motivo "
			@ _nLin, 030 PSay SUBSTR(Alltrim(TRA->F2_MOTEXCL)+ " - " + AllTrim(TRA->XMOT_SEFR),1,120  )
		EndIf
	ElseIf !Empty (TRA->XMOT_SEFR)
		If Len(Alltrim(TRA->XMOT_SEFR))>120
			@ _nLin, 002 PSay "Motivo "
			@ _nLin, 015 PSay SUBSTR(Alltrim(TRA->XMOT_SEFR),1,120  )
			_nLin++
			@ _nLin, 015 PSay SUBSTR(Alltrim(TRA->XMOT_SEFR),120,240)
			_nLin++
			@ _nLin, 015 PSay SUBSTR(Alltrim(TRA->XMOT_SEFR),240,360)
        Else 
			@ _nLin, 002 PSay "Motivo "
			@ _nLin, 015 PSay SUBSTR(Alltrim(TRA->XMOT_SEFR),1,120  )        
        EndIf
	Else
		@ _nLin, 002 PSay "Motivo "
		@ _nLin, 015 PSay "Nใo encontrado ou nใo informado "	
	EndIf
	_nLin++
	@ _nLin, 000 Psay REPLICATE("_",132)
	dbSelectArea("TRA")
	dbSetOrder(0)
	dbSkip()
EndDo

dbSelectArea("TRA")
TRA->(dbCloseArea())

//Inํcio - Trecho adicionado por Adriano Leonardo em 04/12/2013 para implementa็ใo de novas funcionalidades

If MV_PAR08 == 1 .Or. MV_PAR08 == 3
	_cQry2 := " SELECT SF2.F2_SERIE, MIN(SF2.F2_DOC) AS [NUM_MIN], MAX(SF2.F2_DOC) AS [NUM_MAX] FROM " + RetSqlName("SF2") + " SF2 " +_lEnt
	_cQry2 += " WHERE SF2.F2_EMISSAO  BETWEEN '" + (DTOS(mv_par05)) + "' AND '" + (DTOS(mv_par06)) + "' " +_lEnt
	_cQry2 += " AND SF2.F2_SERIE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " +_lEnt
	_cQry2 += " AND SF2.F2_CLIENTE<>'999999' " +_lEnt
	_cQry2 += " GROUP BY SF2.F2_SERIE " +_lEnt
	/*
	If __cUserId == "000000"
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cQry2)
	EndIf
	*/
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry2),"TRB",.T.,.F.)
	
	dbSelectArea("TRB")
	dbSetOrder(0)
	
	While !EOF() .And. !lEnd
			
	 	_cQry3 := " SELECT TEMP.F2_DOC, TEMP.F2_SERIE " +_lEnt
		_cQry3 += "  FROM " +_lEnt
		_cQry3 += " ( " +_lEnt
		_cQry3 += " SELECT TOP (" + STR(VAL(TRB->NUM_MAX) - VAL(TRB->NUM_MIN)) + " + 1) '" + TRB->F2_SERIE + "' AS F2_SERIE, " +_lEnt
		_cQry3 += " (REPLICATE('0',9-LEN(ROW_NUMBER() OVER(ORDER BY SF2A.F2_DOC)-1+'" + TRB->NUM_MIN + "'))+ CAST((ROW_NUMBER() OVER(ORDER BY SF2A.F2_DOC)-1)+'" + TRB->NUM_MIN + "' AS VARCHAR(9))) AS F2_DOC " +_lEnt
		_cQry3 += " , 'AUX' AS AUX " +_lEnt
		_cQry3 += " FROM " + RetSqlName("SF2") + " SF2A " +_lEnt
		_cQry3 += " UNION ALL " +_lEnt
		_cQry3 += " SELECT F2_SERIE, " +_lEnt
		_cQry3 += " F2_DOC, " +_lEnt
		_cQry3 += " CASE WHEN SF2.F2_CLIENTE='999999' THEN 'INU' ELSE 'SF2' END AUX FROM " + RetSqlName("SF2") + " SF2 " +_lEnt
		_cQry3 += " WHERE (SF2.F2_EMISSAO BETWEEN '" + (DTOS(mv_par05)) + "' AND '" + (DTOS(mv_par06)) + "' OR SF2.F2_CLIENTE='999999') " +_lEnt
		_cQry3 += " AND SF2.F2_SERIE='" + TRB->F2_SERIE + "' " +_lEnt
		_cQry3 += " UNION ALL " +_lEnt
		_cQry3 += " SELECT F1_SERIE, F1_DOC, 'SF1' AS AUX FROM " + RetSqlName("SF1") + " SF1 " +_lEnt
		_cQry3 += " WHERE SF1.F1_EMISSAO BETWEEN '" + (DTOS(mv_par05)) + "' AND '" + (DTOS(mv_par06)) + "' " +_lEnt
		_cQry3 += " AND SF1.F1_SERIE='" + TRB->F2_SERIE + "' " +_lEnt
		_cQry3 += " AND SF1.F1_FORMUL='S' " +_lEnt
		_cQry3 += " ) TEMP " +_lEnt
		_cQry3 += " GROUP BY TEMP.F2_DOC, TEMP.F2_SERIE " +_lEnt
		_cQry3 += " HAVING (COUNT(TEMP.F2_DOC)=1) " +_lEnt
		_cQry3 += " ORDER BY TEMP.F2_DOC " +_lEnt
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry3),"TRC",.T.,.F.)
		
		dbSelectArea("TRC")
		dbSetOrder(0)
		dbGoTop()
		
		While !EOF() .And. !lEnd
		
	 		_cQry4 := " SELECT COUNT(F2_DOC) AS [QUANT] " +_lEnt
	 		_cQry4 += "	FROM " + RetSqlName("SF2") + "  SF2 " +_lEnt
	 		_cQry4 += "	WHERE SF2.F2_DOC='" + AllTrim(TRC->F2_DOC) + "' " +_lEnt
	 		_cQry4 += "	AND SF2.F2_SERIE='" + AllTrim(TRC->F2_SERIE) + "' " +_lEnt
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry4),"TRD",.T.,.F.)
			
			dbSelectArea("TRD")
			dbSetOrder(0)
			
	 		If TRD->QUANT == 0    
	 		
		 		_cQry5 := " SELECT COUNT(F1_DOC) AS [QUANT] " +_lEnt
				_cQry5 += " FROM " + RetSqlName("SF1") + " SF1 " +_lEnt
				_cQry5 += " WHERE SF1.F1_DOC='" + AllTrim(TRC->F2_DOC) + "' " +_lEnt
				_cQry5 += " AND SF1.F1_SERIE='" + AllTrim(TRC->F2_SERIE) + "' " +_lEnt
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry5),"TRE",.T.,.F.)
				
				dbSelectArea("TRE")
				dbSetOrder(0)
			
	 	 		If TRE->QUANT == 0    
	 	 		
		 			If _nPuladas ==0
						_nLin += 2      
					Else 
						_nLin ++
					EndIf
					
					// Imprime o cabe็alho
					If _nLin > 60
						_nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
					EndIf
					
					If _nPuladas==0
						@ _nLin, 002 PSay "Nota(s) nใo encontrada(s)"
						_nLin++
					EndIf
					
					// Imprime o cabe็alho
					If _nLin > 60
						_nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
					EndIf
					
					@ _nLin, 002 PSay AllTrim(TRC->F2_DOC) + Replicate(' ',9-Len(AllTrim(TRC->F2_DOC))) + "-" + AllTrim(TRC->F2_SERIE) + Replicate(' ',3-Len(AllTrim(TRC->F2_SERIE)))
					
			 		_nPuladas++
				EndIf
		
				dbSelectArea("TRE")
				dbCloseArea()
			EndIf
			dbSelectArea("TRD")
			dbCloseArea()
			dbSelectArea("TRC")
			dbSetOrder(0)
			dbSkip()
		EndDo
		dbSelectArea("TRC")
		dbCloseArea()
	    dbSelectArea("TRB")
	    dbSetOrder(0)
	    dbSkip()
	EndDo
	dbSelectArea("TRB")
	dbCloseArea()
EndIf
//Final  - Trecho adicionado por Adriano Leonardo em 04/12/2013 para implementa็ใo de novas funcionalidades

//ณIMPRESSAOณ

SET DEVICE TO SCREEN

// Se saํda para disco, ativa SPOOL
If aReturn[5] == 1
	dbcommitAll()
	Set Printer TO
	OurSpool(wnRel)
EndIf
MS_FLUSH()

//ElseIF MV_PAR06 == "T"
//	ACRESCENTA TIPOS POR PARยMETRO
//EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณJ๚lio Soares        บ Data ณ  01/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo das perguntas dos parโmetros.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa Arcolor                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local i
Local j
_sAlias := Alias()
DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs :={}

AADD(aRegs,{cPerg,"01","De S้rie           " ,"","","mv_ch1","C",03,0,0,"G",""           ,"mv_par01",""       ,"","","","",""            ,"","","","","     ","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"02","At้ S้rie          " ,"","","mv_ch2","C",03,0,0,"G","NaoVazio()" ,"mv_par02",""       ,"","","","",""            ,"","","","","     ","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"03","De Nota            " ,"","","mv_ch3","C",09,0,0,"G",""           ,"mv_par03",""       ,"","","","",""            ,"","","","","     ","","","","","","","","","","","","","","SF2",""})
AADD(aRegs,{cPerg,"04","At้ Nota           " ,"","","mv_ch4","C",09,0,0,"G","NaoVazio()" ,"mv_par04",""       ,"","","","",""            ,"","","","","     ","","","","","","","","","","","","","","SF2",""})
AADD(aRegs,{cPerg,"05","De Emissใo         " ,"","","mv_ch5","D",08,0,0,"G",""           ,"mv_par05",""       ,"","","","",""            ,"","","","","     ","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"06","At้ Emissใo        " ,"","","mv_ch6","D",08,0,0,"G","NaoVazio()" ,"mv_par06",""       ,"","","","",""            ,"","","","","     ","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"07","Emite por?         " ,"","","mv_ch7","N",01,0,0,"C",""           ,"mv_par07","Emissao","","","","","Cancelamento","","","","","     ","","","","","","","","","","","","","",""   ,""})
// - Inserido por J๚lio Soares para inserir parโmetro que possibilita a sele็ใo de documentos de entrada, saํda ou ambas.
//AADD(aRegs,{cPerg,"08","Tipo de documento? " ,"","","mv_ch8","N",01,0,0,"C",""           ,"mv_par08","Saํdas ","","","","","Entradas    ","","","","","Ambas","","","","","","","","","","","","","",""   ,""})

For i:=1 To Len(aRegs)
	If !MsSeek(cPerg+aRegs[i,2],.T.,.F.)
		RecLock("SX1",.T.)
		For j:=1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		MsUnlock()
	EndIf
Next
DbSelectArea(_sAlias)
Return()

/*
//If MV_PAR06 == "DOC"                             
	_cQry := " SELECT F2_EMISSAO, F2_SERIE,F2_DOC, F2_CLIENTE, F2_EST, F2_LOJA, A1_NOME, A1_NREDUZ, F2_VALBRUT, "
	_cQry += " ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),F2_MOTEXCL)),'') AS F2_MOTEXCL, F2_DTEXCLS, "
	_cQry += " ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),XMOT_SEFR)),'') AS XMOT_SEFR "
	_cQry += " FROM " + RetSqlName("SF2") + " SF2 "	
	_cQry += "    INNER JOIN " + RetSqlName("SA1") + " SA1 "
	_cQry += "       ON  SF2.F2_CLIENTE  = SA1.A1_COD  "
	_cQry += " 		 AND SF2.F2_LOJA     = SA1.A1_LOJA "
//	_cQry += "    LEFT JOIN SPED054 S54 " // Foi realizado altera็ใo por J๚lio Soares em 26/09/2013 para implementar tratamento ao Banco do TSS que foi separado do Protheus
	_cQry += "    LEFT JOIN " + _cBanco + ".dbo.SPED054 S54 " 
	_cQry += "       ON  S54.NFE_ID      = (SF2.F2_SERIE + SF2.F2_DOC)"
//	_cQry += "       AND S54.NFE_CHV     = SF2.F2_CHVNFE "	// Retirado por J๚lio Soares em 02/10/2013 para apresentar a data das inutilizadas
	_cQry += "       AND ((S54.XMOT_SEFR LIKE '%Deneg%' OR S54.XMOT_SEFR LIKE '%DENEG%')  "
	_cQry += "       OR  (S54.XMOT_SEFR  LIKE '%Inuti%' OR S54.XMOT_SEFR LIKE '%INUTI%')) "
	_cQry += " WHERE SF2.F2_FILIAL       = '" + xFilial("SF2") + "' "
//	_cQry += "       AND SF2.D_E_L_E_T_  = '*' "
	_cQry += "       AND SF2.F2_SERIE    BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	_cQry += "       AND SF2.F2_DOC      BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
    If     MV_PAR07 == 1
		_cQry += "   AND SF2.F2_EMISSAO  BETWEEN '" + (DTOS(mv_par05)) + "' AND '" + (DTOS(mv_par06)) + "' "
    ElseIf MV_PAR07 == 2	
		_cQry += "   AND SF2.F2_DTEXCLS  BETWEEN '" + (DTOS(mv_par05)) + "' AND '" + (DTOS(mv_par06)) + "' "
	EndIf
	_cQry += "       AND (SF2.D_E_L_E_T_ = '*' "
	_cQry += "       OR S54.XMOT_SEFR    LIKE '%Deneg%') "
    If     MV_PAR07 == 1
		_cQry += " ORDER BY SF2.F2_DOC, F2_EMISSAO "
    ElseIf MV_PAR07 == 2
	    _cQry += " ORDER BY SF2.F2_DOC, F2_DTEXCLS "
	EndIf
*/
