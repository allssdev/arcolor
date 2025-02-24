#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR045  บ Autor ณ Arthur Silva  	 บ Data ณ  03/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsavel pela impressใo do Picking List/Pr้ Sep. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function RFATR045(_cRotOrig)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤall_ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cDesc1         	:= "Este programa tem como objetivo imprimir relatorio "
Private cDesc2         	:= "de acordo com os parametros informados pelo usuario."
Private cDesc3         	:= "PICKING LIST / PRษ SEPARAวรO"
Private titulo       	:= "PICKING LIST / PRษ SEPARAวรO"
Private cCadastro       := titulo
Private nLin           	:= 0080
Private lEnd         	:= .F.
Private lAbortPrint  	:= .F.
Private CbTxt        	:= ""
Private limite       	:= 132 						//Limite da pแgina: 80 - 132 - 220 // P - M - G
Private tamanho      	:= "G"
Private nomeprog     	:= "RFATR045"
Private nTipo        	:= 18
Private aReturn      	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     	:= 0
Private cbtxt        	:= Space(10)
Private cbcont       	:= 00
Private CONTFL       	:= 01
Private m_pag        	:= 01
Private _cImpAtu        := ""
Private cString      	:= "SC9"
Private wnrel        	:= nomeprog
Private cPerg		 	:= nomeprog
Private _cRotina     	:= nomeprog
Private aCol		 	:= {}
Private _nNumPagina	 	:= 0

Default _cRotOrig       := ""

dbSelectArea("SC9")
SC9->(dbSetOrder(1))
ValidPerg()

If AllTrim(_cRotOrig)=="RFATA026"
	If !Empty((_cTbTmp1)->C9_PEDIDO)
		Pergunte(cPerg,.F.)
		MV_PAR01 := (_cTbTmp1)->C9_PEDIDO
		MV_PAR02 := (_cTbTmp1)->C9_PEDIDO
		MV_PAR03 := STOD("19900101")
		MV_PAR04 := STOD("20491231")
		MV_PAR05 := ""
		MV_PAR06 := ""
		MV_PAR07 := Replicate("Z",TamSx3("A1_COD" )[01])
		MV_PAR08 := Replicate("Z",TamSx3("A1_LOJA")[01])
//		wnrel    := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)
	Else
		Return
	EndIf
Else
	If !Pergunte(cPerg,.T.)
		Return
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
	oBrowse:Refresh()
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno  ณRunReport บ Autor ณ Arthur Silva  	 	 บ Data ณ  03/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Processamento e impressใo do relat๓rio					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(_cRotOrig)

Local _cNumPed 	:= ""

Private oPrn   	:= TMSPrinter():New()
Private oFont1 	:= TFont():New( "Arial",,07,,.T.,,,,,.F. ) //-ok
Private oFont2 	:= TFont():New( "Arial",,10,,.F.,,,,,.F. ) //-ok
Private oFont3 	:= TFont():New( "Arial",,12,,.T.,,,,,.F. ) //-ok
Private oFont4 	:= TFont():New( "Arial",,12,,.F.,,,,,.F. ) //-ok
Private oFont5 	:= TFont():New( "Arial",,18,,.F.,,,,,.F. ) //-ok
Private nLinAd	:= 0005
Private nLinAdj	:= 0035

//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
// Variแveis utilizadas para parametros 
// mv_par01	   De Pedido
// mv_par02    At้ Pedido
// mv_par03	   De Data
// mv_par04    At้ Data
// mv_par05	   De Cliente
// mv_par06    Da Loja    
// mv_par07    At้ Cliente
// mv_par08    At้ Loja
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 

BeginSql Alias "TRBTMPX"
	SELECT *
		FROM %Table:SC9% C9
			  INNER JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL  = %xFilial:SB1%
											 AND SB1.B1_COD     = C9.C9_PRODUTO
											 AND SB1.%NotDel%
		WHERE C9.C9_PEDIDO BETWEEN %Exp:mv_par01%        AND %Exp:mv_par02%
			AND C9.C9_BLCRED = ''
			AND C9.C9_BLEST NOT IN ('', '10')
			AND C9_DATALIB BETWEEN %Exp:DTOS(mv_par03)%  AND %Exp:DTOS(mv_par04)%
			AND C9.C9_CLIENTE BETWEEN %Exp:mv_par05%        AND %Exp:mv_par07%
			AND C9.C9_LOJA BETWEEN %Exp:mv_par06%        AND %Exp:mv_par08%
			AND C9.%NotDel%
		ORDER BY C9_PEDIDO, B1_DESC, C9_ITEM, C9_PRODUTO
EndSql
//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.txt",GetLastQuery()[02])
dbSelectArea("TRBTMPX")
ProcRegua(RecCount())
TRBTMPX->(dbGoTop())

If !TRBTMPX->(EOF())
	oPrn:Setup()
	oPrn:SetPaperSize(9) 			// Ajusta o tamanho da pแgina
	oPrn:SetPortRait()
	While !TRBTMPX->(EOF())
		IncProc("Imprimindo O.S. '"+TRBTMPX->C9_PEDIDO+"'...")
		_cCliFor := ""

		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		If SC5->(MsSeek(xFilial("SC5") + TRBTMPX->C9_PEDIDO,.T.,.F.))
			If AllTrim(SC5->C5_TIPO) $ "D/B"
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				If SA2->(MsSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
					_cCliFor := "FORNEC.:    "  + SA2->A2_NOME
				EndIf
			Else
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
					_cCliFor := "CLIENTE:    "  + SA1->A1_NOME
				EndIf
			EndIf
		EndIf
		oPrn:StartPage()
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 	
		//Chamada do cabe็alho
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 		
		ImpCab()
		nLin+=0050
		oPrn:line(nLin,0060,nLin,2300)	//Cria uma linha

		nlin+=0100
	    oPrn:Say(nLin,0060,"PEDIDO:   "      + AllTrim(TRBTMPX->C9_PEDIDO)         													,oFont3,100,,,3)
		oPrn:Say(nLin,0600,_cCliFor                                                													,oFont3,100,,,3)
		nLin+=0100
	    oPrn:Say(nLin,0060,"DATA:   "        + DTOC(STOD(TRBTMPX->C9_DATALIB))      													,oFont3,100,,,3)
	    nLin+=0100
	    oPrn:Say(nLin,0060,"OBSERVACOES: ",oFont3,100,,,3)
	    nLin+=0050
	    For _x := 1 To Len(memoline(TRBTMPX->(C9_OBSSEP),,))
			If !(Empty(memoline(Alltrim(TRBTMPX->C9_OBSSEP),85,_x)))
			    oPrn:Say(nLin,0100,	memoline(Alltrim(TRBTMPX->C9_OBSSEP),85,_x),oFont4,100,,,3)
			    nLin+=0050
			EndIf
		Next
		nLin+=0050
		oPrn:line(nLin,0060,nLin,2300)	//Cria uma linha
	    nLin+=0020

	   	_nVez    := 0
	    _cNumPed := TRBTMPX->C9_PEDIDO
		While !TRBTMPX->(EOF()) .AND. _cNumPed == TRBTMPX->C9_PEDIDO
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Impressao do cabecalho dos itens. . .                            	ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			_nVez++
			If _nVez == 1
			    nLin+=0020
	        	ImpProduto()
			EndIf
		    nLin+=0100
		    oPrn:Say(nLin,acol[1,1],(TRBTMPX->C9_ITEM)									,	oFont3	,100,	,,3)
		    oPrn:Say(nLin,acol[2,1],(TRBTMPX->C9_PRODUTO)								,	oFont3	,100,	,,3)
		    oPrn:Say(nLin,acol[3,1],(TRBTMPX->B1_DESC)									,	oFont3	,100,	,,3)
		    oPrn:Say(nLin,acol[4,1],Transform(TRBTMPX->C9_QTDLIB, "@E 999,999,999.99")	,	oFont3	,100,	,,3)
		    oPrn:Say(nLin,acol[5,1],(TRBTMPX->B1_UM)    								,	oFont3	,100,	,,3)
		    oPrn:Say(nLin,acol[6,1],("[        ]")										,	oFont3	,100,	,,3)
//		    oPrn:Say(nLin,acol[7,1],("[        ]")										,	oFont3	,100,	,,3)
//		    oPrn:Say(nLin,acol[6,1],(TRBTMPX->B1_ENDPAD)									,	oFont3	,100,	,,3)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ	    
		    //Quebra de pแgina		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ	    
			If nLin > 3150 
				SaltPag()
				RodPe()
				oPrn:EndPage()
				oPrn:StartPage()
				ImpCab()
				nLin+=0050
				oPrn:line(nLin,0060,nLin,2300)	//Cria uma linha
				nLin += 0100
				ImpProduto()
			EndIf
			dbSelectArea("TRBTMPX")
			TRBTMPX->(dbSkip())					// Avanca o ponteiro do registro no arquivo
		EndDo
		RodPe()
		oPrn:EndPage()
		dbSelectArea("TRBTMPX")
	EndDo
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza a execucao do relatorio...                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If AllTrim(_cRotOrig)$"/RFATA026/"
		oPrn:Print()
	Else
		oPrn:Preview()
	EndIf
EndIf
dbSelectArea("TRBTMPX")
TRBTMPX->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSaltPag   บ Autor ณ Arthur Silva  	 บ Data ณ  03/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc	   	 ณFuncao para imprimir a expressใo Continua	  	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPrograma Principal                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/            

Static Function SaltPag()

nLin += 0045
oPrn:Say(nLin,aCol[2,1],"****************  CONTINUA ...  ****************",                    		oFont1,100,,,3)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpProduto  บ Autor ณ Arthur Silva  	 บ Data ณ  03/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc	   	 ณFuncao para imprimir o cabe็alho dos itens 	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPrograma Principal                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpProduto()

aCol 	:= {	{0060,"ITEM"				 	,3},;
 				{0250,"PRODUTO"					,3},;
				{0500,"DESCRICAO"				,3},;
				{1700,"QUANT"			 		,3},;
				{2000,"UM"	    			 	,3},;
 				{2155,"STATUS"			 		,3}}

For _x:=1 To Len(aCol)
	oPrn:Say(nLin,aCol[_x,1],aCol[_x,2],oFont3,100,,,aCol[_x,3])
Next		    

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpCab    บ Autor ณ Arthur Silva  	 บ Data ณ  03/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de Impressใo do Cabe็alho							  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpCab()

Local _cLogo := FisxLogo("1")
nLin 	     := 120

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//Quadro para o Logotipo
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//oPrn:SayBitmap(nLin+0030,0055,_cLogo,0600,0500/5.322033 )
oPrn:SayBitmap(nLin-0020,0280,_cLogo,0250,0200 )

oPrn:Box(nLin,0050,nLin+0150,0700)//QUADRO DO LOGO
oPrn:Box(nLin,0710,nLin+0150,1850)//QUADRO CENTRAL
oPrn:Box(nLin,1860,nLin+0150,2300)//QUADRO DA DIREITA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//Quadro central
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
oPrn:Say(nLin+0050,1220,"     PICKING LIST / PRษ SEPARAวรO",								oFont5 	,100,CLR_RED	,,2)
                                                                         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//Quadro da direita 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
_nNumPagina ++
oPrn:Say(nLin+0010,2100,(nomeprog),										   			oFont3 	,100,CLR_RED	,,2)
oPrn:Say(nLin+0060,2100,DToC(DATE()) + " - " + TIME(),								oFont2	,100,			,,2)
oPrn:Say(nLin+0090,2100,"Pแgina " + AllTrim(Str(_nNumPagina)),                      oFont2	,100,			,,2)
nLin 	+= 0150
nLinAd	:= 1000

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRodPe  บ Autor ณ Arthur Silva  	 บ Data ณ  03/10/17   	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o rodap้ das paginas                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RodPe()

nLin := 3300
//_nNumPagina ++
oPrn:Box(nLin,0050,nLin+0075,2300)
oPrn:Say(nLin,0080,"Impresso em: " + DToC(DATE()) + " - " + TIME() + " por " + AllTrim(cUserName) + "  -  Via Impressa: " + _cImpAtu, oFont2,100,,,3)
oPrn:Say(nLin,2000,"Pแgina " + AllTrim(Str(_nNumPagina)),                                         		oFont2,100,,,3)

Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บ Autor ณ Arthur Silva  	 บ Data ณ  03/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se as perguntas existem na tabela SX1, as criando บฑฑ
ฑฑบ          ณcaso nใo existam.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","De Separa็ใo?" 	  		,"","","mv_ch1","C",06,0,0,"G",""          ,"mv_par01","","","","      "  ,"","","","","","","","","","","","","","","","","","","","","CB7",""})
AADD(aRegs,{cPerg,"02","At้ Separa็ใo?"	  		,"","","mv_ch2","C",06,0,0,"G","NaoVazio()","mv_par02","","","","ZZZZZZ"  ,"","","","","","","","","","","","","","","","","","","","","CB7",""})
AADD(aRegs,{cPerg,"03","De Data?" 	  		    ,"","","mv_ch3","D",08,0,0,"G",""          ,"mv_par03","","","","20000101","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"04","At้ Data?"	  		    ,"","","mv_ch4","D",08,0,0,"G","NaoVazio()","mv_par04","","","","20491231","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"05","De Cliente?" 	  		,"","","mv_ch5","C",06,0,0,"G",""          ,"mv_par05","","","",""        ,"","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"06","Da Loja?"    	  		,"","","mv_ch6","C",02,0,0,"G",""          ,"mv_par06","","","",""        ,"","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"07","At้ Cliente?"	  		,"","","mv_ch7","C",06,0,0,"G","NaoVazio()","mv_par07","","","","ZZZZZZ"  ,"","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"08","At้ Loja?"   	  		,"","","mv_ch8","C",02,0,0,"G","NaoVazio()","mv_par08","","","","ZZ"      ,"","","","","","","","","","","","","","","","","","","","",""   ,""})
	  	
For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	If !MsSeek(cPerg+aRegs[i,2],.T.,.F.)
		RecLock("SX1",.T.)
		For j:=1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_sAlias)

Return