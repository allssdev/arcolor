#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} RFATR013
Função responsavel pela impressão da Ordem de Separação conforme solicitação do cliente alteração da rotina RFATR004 Alterada a logica de Say para Oprn
@author Desconhecido
@since 25/03/2013
@version P12
@type Function
@obs Sem observações
@see https://allss.com.br
@history 05/09/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adequação da consulta principal corringindo chave de relacionamento SBE x CB8.
/*/
user function RFATR013(_cRotOrig)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cDesc1         	:= "Este programa tem como objetivo imprimir relatorio "
	Private cDesc2         	:= "de acordo com os parametros informados pelo usuario."
	Private cDesc3         	:= "ORDEM DE SEPARAÇÃO"
	Private titulo       	:= "ORDEM DE SEPARAÇÃO"
	Private cCadastro       := titulo
	Private nLin           	:= 0080
	Private lEnd         	:= .F.
	Private lAbortPrint  	:= .F.
	Private limite       	:= 132 						//Limite da página: 80 - 132 - 220 // P - M - G
	Private tamanho      	:= "G"
	Private nomeprog     	:= "RFATR013"
	Private nTipo        	:= 18
	Private aReturn      	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     	:= 0
	Private cbtxt        	:= Space(10)
	Private cbcont       	:= 00
	Private CONTFL       	:= 01
	Private m_pag        	:= 01
	Private _cImpAtu        := ""
	Private cString      	:= "CB7"
	Private wnrel        	:= nomeprog
	Private cPerg		 	:= nomeprog
	Private _cRotina     	:= nomeprog
	Private aCol		 	:= {}
	Private _nNumPagina	 	:= 0

	Default _cRotOrig       := ""

	dbSelectArea("CB7")
	CB7->(dbSetOrder(1))
	ValidPerg()
	If AllTrim(_cRotOrig) == "ACD100GI" .OR. AllTrim(_cRotOrig) == "ACD100M"
		If !Empty(CB7->CB7_ORDSEP)
			Pergunte(cPerg,.F.)
			MV_PAR01 := CB7->CB7_ORDSEP
			MV_PAR02 := CB7->CB7_ORDSEP
			MV_PAR03 := STOD("19900101")
			MV_PAR04 := STOD("20491231")
			MV_PAR05 := ""
			MV_PAR06 := ""
			MV_PAR07 := Replicate("Z",TamSx3("A1_COD" )[01])
			MV_PAR08 := Replicate("Z",TamSx3("A1_LOJA")[01])
	//		wnrel    := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)
		Else
			return
		EndIf
	ElseIf AllTrim(_cRotOrig)=="RFATA006" .Or. AllTrim(_cRotOrig)=="RFATA026" //_cAliTmp - alias da RFATA026
			Pergunte(cPerg,.T.)
	ElseIf AllTrim(_cRotOrig)=="MA455MNU"
		If !Empty(SC9->C9_ORDSEP)
			Pergunte(cPerg,.F.)
			MV_PAR01 := SC9->C9_ORDSEP
			MV_PAR02 := SC9->C9_ORDSEP
			MV_PAR03 := STOD("19900101")
			MV_PAR04 := STOD("20491231")
			MV_PAR05 := ""
			MV_PAR06 := ""
			MV_PAR07 := Replicate("Z",TamSx3("A1_COD" )[01])
			MV_PAR08 := Replicate("Z",TamSx3("A1_LOJA")[01])
	//		wnrel    := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)
		Else
			return
		EndIf
	Else
		If !Pergunte(cPerg,.T.)
			return
		EndIf
	//	wnrel    := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)
	EndIf
	If ExistBlock("RCFGASX1")
		U_RCFGASX1(cPerg,"01",MV_PAR01)
		U_RCFGASX1(cPerg,"02",MV_PAR02)
		U_RCFGASX1(cPerg,"03",MV_PAR03)
		U_RCFGASX1(cPerg,"04",MV_PAR04)
		U_RCFGASX1(cPerg,"05",MV_PAR05)
		U_RCFGASX1(cPerg,"06",MV_PAR06)
		U_RCFGASX1(cPerg,"07",MV_PAR07)
		U_RCFGASX1(cPerg,"08",MV_PAR08)
	EndIf
	/*
	If nLastKey == 27
		Return
	EndIf
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	EndIf
	nTipo := If(aReturn[4]==1,15,18)
	*/
	//RptStatus({|| RunReport()},Titulo) 
	Processa({|| RunReport(_cRotOrig)},Titulo,"Aguarde... processando impressao...",.F.)
	If Type("oBrowse")=="O" 
		//oBrowse:ChangeTopBot(.T.)
		oBrowse:Refresh()
	EndIf
	/*
	If Type("_oObj")=="O"
		_oObj:Default()
		_oObj:Refresh()
	EndIf
	*/
return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o  ³RunReport º Autor ³  Desconhecido        º Data ³  25/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Processamento e impressão do relatório					  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function RunReport(_cRotOrig)
	Local _cNumOrd 	:= ""
	Local _nRecCB7  := 0
	local _x
	Private oPrn   	:= TMSPrinter():New()
	Private oFont1 	:= TFont():New( "Arial",,07,,.T.,,,,,.F. ) //-ok
	Private oFont2 	:= TFont():New( "Arial",,10,,.F.,,,,,.F. ) //-ok
	Private oFont3 	:= TFont():New( "Arial",,12,,.T.,,,,,.F. ) //-ok
	Private oFont4 	:= TFont():New( "Arial",,12,,.F.,,,,,.F. ) //-ok
	Private oFont5 	:= TFont():New( "Arial",,18,,.F.,,,,,.F. ) //-ok
	Private nLinAd	:= 0005
	Private nLinAdj	:= 0035
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	// Variáveis utilizadas para parametros 
	// mv_par01	   De Separação
	// mv_par02    Até Separação
	// mv_par03	   De Data
	// mv_par04    Até Data
	// mv_par05	   De Cliente
	// mv_par06    Da Loja    
	// mv_par07    Até Cliente
	// mv_par08    Até Loja
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	/*
	cQuery0 := " SELECT SUM(SB1.B1_PESO * CB8.CB8_QTDORI) AS [PESO_TOTAL] "
	cQuery0 += " FROM "                  + RetSqlName("CB7") + " CB7 "
	cQuery0 += "       INNER JOIN "      + RetSqlName("CB8") + " CB8 ON CB8.D_E_L_E_T_ = '' "
	cQuery0 += "                                                    AND CB8.CB8_FILIAL = '"+ xFilial("CB8") + "' "
	cQuery0 += "                                                    AND CB8.CB8_ORDSEP = CB7.CB7_ORDSEP "
	cQuery0 += "       LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = '' "
	cQuery0 += "                                                    AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery0 += "                                                    AND SB1.B1_COD     = CB8.CB8_PROD "
	cQuery0 += " WHERE CB7.D_E_L_E_T_     = '' "
	cQuery0 += " AND CB7.CB7_FILIAL       = '" + xFilial ("CB7") +"' "
	cQuery0 += " AND CB7.CB7_ORDSEP BETWEEN '" + (mv_par01)      +"'  AND '"+ (mv_par02)     +"' " 			// De Separação, Até Separação
	cQuery0 += " AND CB7.CB7_DTEMIS BETWEEN '" + DTOS(mv_par03)  +"'  AND '"+ DTOS(mv_par04) +"' "			// De Data, Até Data 
	cQuery0 += " AND CB7.CB7_CLIENT BETWEEN '" + (mv_par05)      +"'  AND '"+ (mv_par07)     +"' "			// De Cliente, Até Cliente
	cQuery0 += " AND CB7.CB7_LOJA   BETWEEN '" + (mv_par06)      +"'  AND '"+ (mv_par08)     +"' "			// De Loja, Até Loja
	//If __cUserId=="000000"
	//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_000.txt",cQuery0)
	//EndIf                 
	//cQuery0 := ChangeQuery(cQuery0)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery0),"TRBPES",.T.,.F.)
	*/
	BeginSql Alias "TRBPES"
		SELECT SUM(SB1.B1_PESO * CB8.CB8_QTDORI) AS [PESO_TOTAL]
		FROM %table:CB7% CB7
			  INNER JOIN      %table:CB8% CB8 ON CB8.CB8_FILIAL = %xFilial:CB8%
											 AND CB8.CB8_ORDSEP = CB7.CB7_ORDSEP
											 AND CB8.%NotDel%
			  LEFT OUTER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL  = %xFilial:SB1%
											 AND SB1.B1_COD     = CB8.CB8_PROD
											 AND SB1.%NotDel%
		WHERE CB7.CB7_FILIAL       = %xFilial:CB7%
		  AND CB7.CB7_ORDSEP BETWEEN %Exp:mv_par01%       AND %Exp:mv_par02%
		  AND CB7.CB7_DTEMIS BETWEEN %Exp:DTOS(mv_par03)% AND %Exp:DTOS(mv_par04)% 
		  AND CB7.CB7_CLIENT BETWEEN %Exp:mv_par05%       AND %Exp:mv_par07%
		  AND CB7.CB7_LOJA   BETWEEN %Exp:mv_par06%       AND %Exp:mv_par08%
		  AND CB7.%NotDel%
	EndSql
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",GetLastQuery()[02])
	dbSelectArea("TRBPES")
	_nPesoTtl := TRBPES->Peso_Total
	TRBPES->(dbCloseArea())
	/*
	cQuery1 := " SELECT DISTINCT CB7.CB7_ORDSEP, CB8.CB8_PEDIDO, CB7.CB7_DTINIS, CB7.CB7_DTEMIS, CB7.CB7_HRINIS, CB7.CB7_HREMIS, CB7.CB7_CLIENT, CB7.CB7_CODOPE, CB7.CB7_CODOP2,CB8.CB8_NOTA,CB8.CB8_SERIE, "
	cQuery1 += "				 CB7.CB7_NOMOP1, CB7.CB7_NOMOP2, CB8.CB8_ORDSEP,CB8.CB8_ITEM, CB8.CB8_PROD, SB1.B1_DESC, SB1.B1_UM, CB8.CB8_QTDORI, CB8.CB8_LOCAL, SB1.B1_ENDPAD, CB8.CB8_LOTECT, "
	cQuery1 += "				 CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CB7.CB7_OBS1)) CB7_OBS1 "
	cQuery1 += " FROM "                  + RetSqlName("CB7") + " CB7 "
	cQuery1 += "       INNER JOIN "      + RetSqlName("CB8") + " CB8 ON CB8.D_E_L_E_T_<> '*' "
	cQuery1 += "                                                    AND CB8.CB8_FILIAL = '"+ xFilial("CB8") + "' "
	cQuery1 += "                                                    AND CB8.CB8_ORDSEP = CB7.CB7_ORDSEP "
	cQuery1 += "       LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_<>'*' "
	cQuery1 += "                                                    AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery1 += "                                                    AND SB1.B1_COD     = CB8.CB8_PROD "
	cQuery1 += " WHERE CB7.D_E_L_E_T_    <> '*' "
	cQuery1 += " AND CB7.CB7_FILIAL       = '" + xFilial ("CB7") +"' "
	cQuery1 += " AND CB7.CB7_ORDSEP BETWEEN '" + (mv_par01)      +"'  AND '"+ (mv_par02)     +"' " 			// De Separação, Até Separação
	//cQuery1 += " AND CB7.CB7_DTINIS BETWEEN '" + DTOS(mv_par03)  +"'  AND '"+ DTOS(mv_par04) +"' "			// De Data, Até Data 
	cQuery1 += " AND CB7.CB7_DTEMIS BETWEEN '" + DTOS(mv_par03)  +"'  AND '"+ DTOS(mv_par04) +"' "			// De Data, Até Data 
	cQuery1 += " AND CB7.CB7_CLIENT BETWEEN '" + (mv_par05)      +"'  AND '"+ (mv_par07)     +"' "			// De Cliente, Até Cliente
	cQuery1 += " AND CB7.CB7_LOJA   BETWEEN '" + (mv_par06)      +"'  AND '"+ (mv_par08)     +"' "			// De Loja, Até Loja
	//cQuery1 += " ORDER BY CB7.CB7_ORDSEP, SB1.B1_ENDPAD, CB8.CB8_ITEM, CB8.CB8_PROD "     // EXCLUIDO O ENDEREÇO PARA ORDEM DE SEPARAÇÃO
	cQuery1 += " ORDER BY CB7.CB7_ORDSEP, SB1.B1_DESC, CB8.CB8_ITEM, CB8.CB8_PROD "
	//If __cUserId=="000000"
	//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",cQuery1)
	//EndIf
	//cQuery1 := ChangeQuery(cQuery1)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"TRBTMPX",.T.,.F.)
	*/
	/*BeginSql Alias "TRBTMPX"
		SELECT CB7.*, CB7.R_E_C_N_O_ RECCB7, CB8.CB8_PEDIDO, CB8.CB8_NOTA, CB8.CB8_SERIE
				, CB8.CB8_ITEM, CB8.CB8_PROD, SB1.B1_DESC, SB1.B1_UM, CB8.CB8_QTDORI, CB8.CB8_LOCAL
				, SB1.B1_ENDPAD, CB8.CB8_LOTECT, CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CB7.CB7_OBS1)) CB7_OBS1
		FROM %table:CB7% CB7
			  INNER JOIN      %table:CB8% CB8 ON CB8.CB8_FILIAL = %xFilial:CB8%
											 AND CB8.CB8_ORDSEP = CB7.CB7_ORDSEP
											 AND CB8.%NotDel%
			  LEFT OUTER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL  = %xFilial:SB1%
											 AND SB1.B1_COD     = CB8.CB8_PROD
											 AND SB1.%NotDel%
		WHERE CB7.CB7_FILIAL       = %xFilial:CB7%
		  AND CB7.CB7_ORDSEP BETWEEN %Exp:mv_par01%        AND %Exp:mv_par02%
		  AND CB7.CB7_DTEMIS BETWEEN %Exp:DTOS(mv_par03)%  AND %Exp:DTOS(mv_par04)% 
		  AND CB7.CB7_CLIENT BETWEEN %Exp:mv_par05%        AND %Exp:mv_par07%
		  AND CB7.CB7_LOJA   BETWEEN %Exp:mv_par06%        AND %Exp:mv_par08%
		  AND CB7.%NotDel%
		ORDER BY CB7.CB7_ORDSEP, SB1.B1_DESC, CB8.CB8_ITEM, CB8.CB8_PROD
	EndSql*/
	BeginSql Alias "TRBTMPX"
		SELECT
			ISNULL(BE_LOCALIZ,'ZZZZZ') ENDERECO,CB7.*, CB7.R_E_C_N_O_ RECCB7, CB8.CB8_PEDIDO, CB8.CB8_NOTA, CB8.CB8_SERIE,
			CB8.CB8_ITEM, CB8.CB8_PROD, SB1.B1_DESC, SB1.B1_UM, CB8.CB8_QTDORI, CB8.CB8_LOCAL,
			SB1.B1_ENDPAD, CB8.CB8_LOTECT, CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CB7.CB7_OBS1)) CB7_OBS1
		FROM 
			%table:CB7% CB7
			INNER JOIN
				%table:CB8% CB8 
			ON 
				CB8.CB8_FILIAL     = %xFilial:CB8%
				AND CB8.CB8_ORDSEP = CB7.CB7_ORDSEP
				AND CB8.%NotDel%
			LEFT OUTER JOIN
				%table:SB1% SB1 
			ON
				SB1.B1_FILIAL  	   = %xFilial:SB1%
				AND SB1.B1_COD     = CB8.CB8_PROD
				AND SB1.%NotDel%
			LEFT OUTER JOIN 
				%table:SBE% SBE 
			ON 
				SBE.BE_FILIAL      = %xFilial:SBE%
				AND SBE.BE_LOCAL   = CB8.CB8_LOCAL
				AND SBE.BE_LOCALIZ = CB8.CB8_LCALIZ
				AND SBE.%NotDel%
		WHERE
			CB7.CB7_FILIAL           = %xFilial:CB7%
		  	AND CB7.CB7_ORDSEP BETWEEN %Exp:mv_par01%        AND %Exp:mv_par02%
		  	AND CB7.CB7_DTEMIS BETWEEN %Exp:DTOS(mv_par03)%  AND %Exp:DTOS(mv_par04)% 
		  	AND CB7.CB7_CLIENT BETWEEN %Exp:mv_par05%        AND %Exp:mv_par07%
		 	AND CB7.CB7_LOJA   BETWEEN %Exp:mv_par06%        AND %Exp:mv_par08%
		  	AND CB7.%NotDel%
		ORDER BY
			CB7.CB7_ORDSEP, SBE.BE_LOCALIZ, CB8.CB8_PROD
	EndSql
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.txt",GetLastQuery()[02])
	dbSelectArea("TRBTMPX")
	ProcRegua(RecCount())
	TRBTMPX->(dbGoTop())
	If !TRBTMPX->(EOF())
		oPrn:Setup()
		oPrn:SetPaperSize(9) 			// Ajusta o tamanho da página
		oPrn:SetPortRait()
		While !TRBTMPX->(EOF())
			IncProc("Imprimindo O.S. '"+TRBTMPX->CB7_ORDSEP+"'...")
			If CB7->(FieldPos("CB7_IMPR")) > 0
				If !Empty(TRBTMPX->CB7_IMPR)
					MsgInfo("Atenção! A Ordem de Separação '"+TRBTMPX->CB7_ORDSEP+"' já foi impressa. Reimpressão permitida somente mediante senha!",_cRotina+"_001")
					If !AutReimp()
						MsgStop("Reimpressão da Ordem de Separação '"+TRBTMPX->CB7_ORDSEP+"' não permitida!",_cRotina+"_002")
						_cNumOrd := TRBTMPX->CB7_ORDSEP
						While !TRBTMPX->(EOF()) .AND. _cNumOrd == TRBTMPX->CB7_ORDSEP
							dbSelectArea("TRBTMPX")
							TRBTMPX->(dbSkip())
						EndDo
						Loop
					EndIf
				EndIf
				If Empty(TRBTMPX->CB7_IMPR)
					_cImpAtu := StrZero(1,Len(TRBTMPX->CB7_IMPR))
				Else
					_cImpAtu := Soma1(TRBTMPX->CB7_IMPR)
				EndIf
			EndIf
			_cCliFor := ""
			_cEst	 := ""
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			If SC5->(MsSeek(xFilial("SC5") + TRBTMPX->CB8_PEDIDO,.T.,.F.))
				If AllTrim(SC5->C5_TIPO) $ "D/B"
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))
					If SA2->(MsSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
						_cCliFor := "FORNEC.:    "  + SA2->A2_NOME
						_cEst 	 := "EST.:    "  + SA2->A2_EST
					EndIf
				Else
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					If SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
						_cCliFor := "CLIENTE:    "  + SA1->A1_NOME
						_cEst 	 := "EST.:    "  + SA1->A1_EST
					EndIf
				EndIf
			EndIf
			oPrn:StartPage()
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
			//Chamada do cabeçalho
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 		
			ImpCab()
			nLin+=0050
			oPrn:line(nLin,0060,nLin,2300)	//Cria uma linha
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 			    
			//Canhoto do Conferente
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 		    
			nLin+=0100
			oPrn:Say(nLin,0060,"SEPARACAO:   " + TRBTMPX->CB7_ORDSEP + "      PESO LIQUIDO:   " +  Transform(_nPesoTtl, "@E 999,999.999"),oFont3,100,,,3)
			nLin+=0100
			oPrn:Say(nLin,0060,"PEDIDO:   "      + AllTrim(TRBTMPX->CB8_PEDIDO)         													,oFont3,100,,,3)
			oPrn:Say(nLin,0600,_cCliFor                                                													,oFont3,100,,,3)
			oPrn:Say(nLin,2050,_cEst                                                													,oFont3,100,,,3)
			nLin+=0100
			oPrn:Say(nLin,0060,"CONFERENTE:   "  + TRBTMPX->CB7_NOMOP2                  													,oFont3,100,,,3)
			oPrn:Say(nLin,1400,"DATA:   "        + DTOC(STOD(TRBTMPX->CB7_DTEMIS))      													,oFont3,100,,,3)
			oPrn:Say(nLin,1800,"HORA:   "        + TRBTMPX->CB7_HREMIS                  													,oFont3,100,,,3)
			nLin+=0100
			// - Trecho alterado em 29/07/2015 por Júlio Soares a fim de tratar a impressão da observação no relatório
			oPrn:Say(nLin,0060,"OBSERVACOES: ",oFont3,100,,,3)
			nLin+=0100
			For _x := 1 To Len(memoline(TRBTMPX->(CB7_OBS1),,))
				If !(Empty(memoline(Alltrim(TRBTMPX->CB7_OBS1),85,_x)))
					oPrn:Say(nLin,0100,	memoline(Alltrim(TRBTMPX->CB7_OBS1),85,_x),oFont4,100,,,3)
					nLin+=0050
				EndIf
			Next
			nLin+=0050
			// - FIM
			/*
			oPrn:Say(nLin,0060,"OBSERVACOES: "   + SUBSTRING(AllTrim(StrTran(StrTran(TRBTMPX->CB7_OBS1,CHR(13)," "),CHR(10),"")),1,75)	,oFont3,100,,,3)
			nLin+=0100                                                                                                
			oPrn:Say(nLin,0060,	SUBSTRING(AllTrim(StrTran(StrTran(TRBTMPX->CB7_OBS1,CHR(13)," "),CHR(10),"")),76,90)						,oFont3,100,,,3)
			nLin+=0100
			oPrn:Say(nLin,0060,	SUBSTRING(AllTrim(StrTran(StrTran(TRBTMPX->CB7_OBS1,CHR(13)," "),CHR(10),"")),256,90)					,oFont3,100,,,3)
			nLin+=0200
			*/
			oPrn:line(nLin,0060,nLin,2300)	//Cria uma linha
			nLin+=0020
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 		
			//Canhoto do Separador
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 		    
			oPrn:Say(nLin,0060,"SEPARACAO:   " + TRBTMPX->CB7_ORDSEP + "      PESO LIQUIDO:   " +  Transform(_nPesoTtl, "@E 999,999.999"),oFont3,100,,,3)
			nLin+=0100
			oPrn:Say(nLin,0060,"PEDIDO:   "      + TRBTMPX->CB8_PEDIDO                  													,oFont3,100,,,3)
			oPrn:Say(nLin,0600,_cCliFor                                                													,oFont3,100,,,3)
			nLin+=0100	
			oPrn:Say(nLin,0060,"SEPARADOR:   "   + TRBTMPX->CB7_NOMOP1                  													,oFont3,100,,,3)
			oPrn:Say(nLin,1400,"DATA:   "        + DTOC(STOD(TRBTMPX->CB7_DTEMIS))      													,oFont3,100,,,3)
			oPrn:Say(nLin,1800,"HORA:   "        + TRBTMPX->CB7_HREMIS                  													,oFont3,100,,,3)
			nLin+=0100
			// - Trecho alterado em 29/07/2015 por Júlio Soares a fim de tratar a impressão da observação no relatório
			oPrn:Say(nLin,0060,"OBSERVACOES: ",oFont3,100,,,3)
			nLin+=0100
			For _x := 1 To Len(memoline(TRBTMPX->(CB7_OBS1),,))
				If !(Empty(memoline(Alltrim(TRBTMPX->CB7_OBS1),85,_x)))
					oPrn:Say(nLin,0100,	memoline(Alltrim(TRBTMPX->CB7_OBS1),85,_x),oFont4,100,,,3)
					nLin+=0050
				EndIf
			Next
			nLin+=0050
			// - FIM
			/*
			oPrn:Say(nLin,0060,"OBSERVACOES: "   + SUBSTRING(AllTrim(StrTran(StrTran(TRBTMPX->CB7_OBS1,CHR(13)," "),CHR(10),"")),1,75)	,oFont3,100,,,3)
			nLin+=0100                                                                                                
			oPrn:Say(nLin,0060,	SUBSTRING(AllTrim(StrTran(StrTran(TRBTMPX->CB7_OBS1,CHR(13)," "),CHR(10),"")),76,90)						,oFont3,100,,,3)
			nLin+=0100
			oPrn:Say(nLin,0060,	SUBSTRING(AllTrim(StrTran(StrTran(TRBTMPX->CB7_OBS1,CHR(13)," "),CHR(10),"")),256,90)					,oFont3,100,,,3)
			nLin+=0200
			*/
			oPrn:line(nLin,0060,nLin,2300)	//Cria uma linha
			_nVez    := 0
			_nRecCB7 := TRBTMPX->RECCB7
			_cNumOrd := TRBTMPX->CB7_ORDSEP
			While !TRBTMPX->(EOF()) .AND. _cNumOrd == TRBTMPX->CB7_ORDSEP
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impressao do cabecalho dos itens. . .                            	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_nVez++
				If _nVez == 1
					nLin+=0020
					ImpProduto()
				EndIf
				nLin+=0100
				oPrn:Say(nLin,acol[1,1],(TRBTMPX->CB8_ITEM)									,	oFont3	,100,	,,3)
				oPrn:Say(nLin,acol[2,1],(TRBTMPX->CB8_PROD)									,	oFont3	,100,	,,3)
				oPrn:Say(nLin,acol[3,1],(TRBTMPX->B1_DESC)									,	oFont3	,100,	,,3)
				oPrn:Say(nLin,acol[4,1],(TRBTMPX->CB8_LOTECT)    							,	oFont3	,100,	,,3)
				oPrn:Say(nLin,acol[5,1],("[              ]")    							,	oFont3	,100,	,,3)
				oPrn:Say(nLin,acol[6,1],Transform(TRBTMPX->CB8_QTDORI, "@E 999,999.99")		,	oFont3	,100,	,,3)
				oPrn:Say(nLin,acol[7,1],(TRBTMPX->B1_UM)    								,	oFont3	,100,	,,3)
				oPrn:Say(nLin,acol[8,1],("[        ]")										,	oFont3	,100,	,,3)
	//		    oPrn:Say(nLin,acol[7,1],("[        ]")										,	oFont3	,100,	,,3)
	//		    oPrn:Say(nLin,acol[6,1],(TRBTMPX->B1_ENDPAD)									,	oFont3	,100,	,,3)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	    
				//Quebra de página		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	    
				If nLin > 3150 
					SaltPag()
					RodPe(_cNumOrd)
					oPrn:EndPage()
					oPrn:StartPage()
					ImpCab()
					nLin+=0050
					oPrn:line(nLin,0060,nLin,2400)	//Cria uma linha
					nLin += 0100
					ImpProduto()
				EndIf
				dbSelectArea("TRBTMPX")
				TRBTMPX->(dbSkip())					// Avanca o ponteiro do registro no arquivo
			EndDo
			RodPe(_cNumOrd)
			oPrn:EndPage()
			//Controle de Impressão
			If _nRecCB7 > 0 .AND. CB7->(FieldPos("CB7_IMPR")) > 0
				dbSelectArea("CB7")
				CB7->(dbSetOrder(1))
				CB7->(dbGoTo(_nRecCB7))
				while !RecLock("CB7",.F.) ; enddo
					CB7->CB7_IMPR := _cImpAtu
				CB7->(MSUNLOCK())
			EndIf
			dbSelectArea("TRBTMPX")
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a execucao do relatorio...                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(_cRotOrig)$"/RFATA006/ACD100GI/ACD100M/MA455MNU/"
			oPrn:Print()
		Else
			oPrn:Preview()
		EndIf
	EndIf
	dbSelectArea("TRBTMPX")
	TRBTMPX->(dbCloseArea())
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SaltPag   ºAutor  ³ Desconhecido       º Data ³  26/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc	   	 ³Funcao para imprimir a expressão Continua	  	              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Programa Principal                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function SaltPag()
	nLin += 0045
	oPrn:Say(nLin,aCol[2,1],"****************  CONTINUA ...  ****************",                    		oFont1,100,,,3)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpProduto  ºAutor  ³Henrique Lombardi º Data ³  26/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc	   	 ³Funcao para imprimir o cabeçalho dos itens 	              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Programa Principal                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpProduto()
local _x
	aCol 	:= {	{0060,"ITEM"				 	,3},;
					{0250,"PRODUTO"					,3},;
					{0500,"DESCRICAO"				,3},;
					{1650,"LOTE SU."				,3},;
					{1850,"LOTE SE."				,3},;
					{2050,"QUANT"			 		,3},;
					{2250,"UM"	    			 	,3},;
					{2345,"STATUS"			 		,3}}
	//				{1750,"ENDERECO"		 		,3},;
	//Alteração 2
	/*aCol 	:= {	{0060,"ITEM"				 	,3},;
					{0250,"PRODUTO"					,3},;
					{0500,"DESCRICAO"				,3},;
					{1350,"QUANT"			 		,3},;
					{1600,"UM"	    			 	,3},;
					{1750,"ENDERECO"		 		,3},;
					{2155,"STATUS"			 		,3}}*/
	//Alteração 1
	/*aCol 	:= {	{0060,"ITEM"				 	,3},;
					{0300,"PRODUTO"					,3},;
					{0540,"DESCRICAO"				,3},;
					{1300,"QUANT"			 		,3},;
					{1550,"UM"	    			 	,3},;
					{1700,"ENDERECO"		 		,3},;
					{2150,"STATUS"			 		,3}}*/
	for _x := 1 To len(aCol)
		oPrn:Say(nLin,aCol[_x,1],aCol[_x,2],oFont3,100,,,aCol[_x,3])
	next
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCab    ºAutor  ³ Desconhecido       º Data ³  25/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de Impressão do Cabeçalho							  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpCab()
	local _cLogo := FisxLogo("1")
	nLin 	     := 120
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Quadro para o Logotipo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//oPrn:SayBitmap(nLin+0030,0055,_cLogo,0600,0500/5.322033 )
	oPrn:SayBitmap(nLin-0020,0280,_cLogo,0250,0200 )

	oPrn:Box(nLin,0050,nLin+0150,0700)//QUADRO DO LOGO
	oPrn:Box(nLin,0710,nLin+0150,1850)//QUADRO CENTRAL
	oPrn:Box(nLin,1860,nLin+0150,2300)//QUADRO DA DIREITA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Quadro central
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	oPrn:Say(nLin+0050,1220,"     ORDEM  DE  SEPARAÇÃO",								oFont5 	,100,CLR_RED	,,2)
                                                                         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Quadro da direita 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	_nNumPagina ++
	oPrn:Say(nLin+0010,2100,(nomeprog),										   			oFont3 	,100,CLR_RED	,,2)
	oPrn:Say(nLin+0060,2100,DToC(DATE()) + " - " + TIME(),								oFont2	,100,			,,2)
	oPrn:Say(nLin+0090,2100,"Página " + AllTrim(Str(_nNumPagina)),                      oFont2	,100,			,,2)
	nLin 	+= 0150
	nLinAd	:= 1000
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RodPe  ºAutor  ³ Desconhecido          º Data ³  25/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o rodapé das paginas                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function RodPe(_cNumOrd)
	nLin := 3300
	//_nNumPagina ++
	oPrn:Box(nLin,0050,nLin+0075,2300)
	oPrn:Say(nLin,0080,"Impresso em: " + DToC(DATE()) + " - " + TIME() + " por " + AllTrim(cUserName) + "  -  Via Impressa: " + _cImpAtu + "  -  SEPARACAO: " + _cNumOrd, oFont2,100,,,3)
	oPrn:Say(nLin,2000,"Página " + AllTrim(Str(_nNumPagina)),                                         		oFont2,100,,,3)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³ Henrique Lombardi  º Data ³  25/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se as perguntas existem na tabela SX1, as criando º±±
±±º          ³caso não existam.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ValidPerg()
local _sAlias := GetArea()
local aRegs   := {}
local i, j
_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))
cPerg         := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
AADD(aRegs,{cPerg,"01","De Separação?" 	  		,"","","mv_ch1","C",06,0,0,"G",""          ,"mv_par01","","","","      "  ,"","","","","","","","","","","","","","","","","","","","","CB7",""})
AADD(aRegs,{cPerg,"02","Até Separação?"	  		,"","","mv_ch2","C",06,0,0,"G","NaoVazio()","mv_par02","","","","ZZZZZZ"  ,"","","","","","","","","","","","","","","","","","","","","CB7",""})
AADD(aRegs,{cPerg,"03","De Data?" 	  		    ,"","","mv_ch3","D",08,0,0,"G",""          ,"mv_par03","","","","20000101","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"04","Até Data?"	  		    ,"","","mv_ch4","D",08,0,0,"G","NaoVazio()","mv_par04","","","","20491231","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"05","De Cliente?" 	  		,"","","mv_ch5","C",06,0,0,"G",""          ,"mv_par05","","","",""        ,"","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"06","Da Loja?"    	  		,"","","mv_ch6","C",02,0,0,"G",""          ,"mv_par06","","","",""        ,"","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"07","Até Cliente?"	  		,"","","mv_ch7","C",06,0,0,"G","NaoVazio()","mv_par07","","","","ZZZZZZ"  ,"","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"08","Até Loja?"   	  		,"","","mv_ch8","C",02,0,0,"G","NaoVazio()","mv_par08","","","","ZZ"      ,"","","","","","","","","","","","","","","","","","","","",""   ,""})
for i := 1 to len(aRegs)
	If !(_cAliasSX1)->(MsSeek(cPerg+aRegs[i,2],.T.,.F.))
		while !RecLock(_cAliasSX1,.T.) ; enddo
			For j:=1 To FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Else
					Exit
				EndIf
			Next
		(_cAliasSX1)->(MsUnlock())
	EndIf
next
RestArea(_sAlias)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AutReimp  ºAutor  ³Anderson C. P. Coelho º Data ³  05/09/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de exigência de senha para a autorização de fatura- º±±
±±º          ³mento, quando este for deixar o estoque negativo.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function AutReimp()
Local _aSvAF      := GetArea()
Local oButton1AF
Local oGroup1AF
Local oSay1AF
Local oSay2AF
Local oGet1AF
Local oGet2AF
Local _lRetAF     := .F.
Private cGet1AF   := Space(030)
Private cGet2AF   := Space(100)
Static oDlgAF
DEFINE MSDIALOG oDlgAF TITLE cCadastro FROM 000, 000  TO 100, 370 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
	oDlgAF:lEscClose := .F.
	@ 004, 005  GROUP oGroup1AF TO 045, 181 PROMPT " Digite a Senha para Reimpressão da Ordem de Separação " OF oDlgAF COLOR 0, 16777215 PIXEL
	@ 017, 010    SAY oSay1AF    PROMPT "Usuário:"                                       SIZE 025, 007 OF oDlgAF COLORS 0, 16777215          PIXEL
	@ 015, 037  MSGET oGet1AF       VAR cGet1AF  VALID NAOVAZIO()                        SIZE 075, 010 OF oDlgAF COLORS 0, 16777215 /*F3 "USR"*/ PIXEL
	@ 030, 010    SAY oSay2AF    PROMPT "Senha:"                                         SIZE 025, 007 OF oDlgAF COLORS 0, 16777215          PIXEL
	@ 030, 037  MSGET oGet2AF       VAR cGet2AF  VALID NAOVAZIO()                        SIZE 075, 010 OF oDlgAF COLORS 0, 16777215 PASSWORD PIXEL
	@ 021, 128 BUTTON oButton1AF PROMPT "Reimprime" Action (_lRetAF := ValidAuth())      SIZE 037, 012 OF oDlgAF                             PIXEL
ACTIVATE MSDIALOG oDlgAF CENTERED
RestArea(_aSvAF)
return(_lRetAF)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidAuth ºAutor  ³Anderson C. P. Coelho º Data ³  05/09/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de validação da senha digitada na rotina AuthFat    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal (AuthFat)                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ValidAuth()
	local _lValidAF := .F.
	If !Empty(cGet1AF) .AND. !Empty(cGet2AF)
		PswOrder(2)
		If PswSeek(AllTrim(cGet1AF),.T.)
			If PswName(AllTrim(cGet2AF))
				dbSelectArea("CB7")
				CB7->(dbSetOrder(1))
				If CB7->(MsSeek(xFilial("CB7") + TRBTMPX->CB7_ORDSEP,.T.,.F.)) .AND. CB7->(FieldPos("CB7_AUTREI")) > 0 .AND. CB7->(FieldPos("CB7_DTAREI")) > 0 .AND. CB7->(FieldPos("CB7_HRAREI")) > 0
					RecLock("CB7",.F.)
					CB7->CB7_AUTREI := cGet1AF
					CB7->CB7_DTAREI := Date()
					CB7->CB7_HRAREI := Time()
					CB7->(MSUNLOCK()) 
				EndIf 
				_lValidAF := .T.
				Close(oDlgAF)
			Else
				MsgAlert("Senha Incorreta!",_cRotina+"_003")
				cGet1AF   := Space(30)
				cGet2AF   := Space(100)
			EndIf
		Else
			MsgAlert("Usuário não encontrado!",_cRotina+"_004")
			cGet1AF   := Space(30)
			cGet2AF   := Space(100)
		EndIf
	Else
		cGet1AF   := Space(30)
		cGet2AF   := Space(100)
		If !MsgYesNo("Informações de autenticação não preenchidas corretamente. Deseja tentar novamente?",_cRotina+"_005")
			Close(oDlgAF)
		EndIf
	EndIf
return(_lValidAF)
