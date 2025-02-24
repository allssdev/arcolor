#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR004  บ Autor ณ ALESSANDRO VILLAR  บ Data ณ  26/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATำRIO DE ORDEM DE SEPARAวรO.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function RFATR004(_cRotOrig)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "ORDEM DE SEPARAวรO"
Local titulo       	 := "ORDEM DE SEPARAวรO"
Local nLin           := 80
//                   ITEM  PRODUTO                          DESCRIวรO                       QUANTIDADE    ARMAZEM  ENDEREวO  LOTE        STATUS
//                   XX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXX  XX       XXXXXX    XXXXXXXXXX  [    ]
//                   01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//                             10        20        30        40        50        60        70        80        90        100       110       120       130
Local Cabec1       	 := ""
Local Cabec2       	 := ""
Local imprime      	 := .T.
//Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132 //Limite da pแgina: 80 - 132 - 220 // P - M - G
Private tamanho      := "M" //"G" - Alterado por Adriano Leonardo em 25/03/13
Private nomeprog     := "RFATR004"
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private cString      := "CB7"
Private wnrel        := nomeprog
Private cPerg		 := nomeprog
Private _cRotina     := nomeprog

Default _cRotOrig    := ""

dbSelectArea("CB7")
CB7->(dbSetOrder(1))
ValidPerg()
If AllTrim(_cRotOrig) == "ACD100GI"
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
		wnrel    := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)
	Else
		Return
	EndIf
ElseIf FunName()=="RFATA006"
	If !Empty(TRBTMP->C9_ORDSEP)
		Pergunte(cPerg,.F.)
		MV_PAR01 := TRBTMP->C9_ORDSEP
		MV_PAR02 := TRBTMP->C9_ORDSEP
		MV_PAR03 := STOD("19900101")
		MV_PAR04 := STOD("20491231")
		MV_PAR05 := ""
		MV_PAR06 := ""
		MV_PAR07 := Replicate("Z",TamSx3("A1_COD" )[01])
		MV_PAR08 := Replicate("Z",TamSx3("A1_LOJA")[01])
		wnrel    := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)
	Else
		Return
	EndIf
Else
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	wnrel    := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)
EndIf

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo) 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno  ณRUNREPORT บ Autor ณ ALESSANDRO VILLAR    บ Data ณ  26/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ RELATำRIO DE ORDEM DE SEPARAวรO                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
  
//Local nOrdem
Local _cNumOrd := ""

//--------------------------------------------------------------------------------------
// Variแveis utilizadas para parametros 
// mv_par01	   De Separa็ใo
// mv_par02    At้ Separa็ใo
// mv_par03	   De Data
// mv_par04    At้ Data
// mv_par05	   De Cliente
// mv_par06    Da Loja    
// mv_par07    At้ Cliente
// mv_par08    At้ Loja
//--------------------------------------------------------------------------------------
cQuery1 := " SELECT DISTINCT CB7.CB7_ORDSEP, CB8.CB8_PEDIDO, CB7.CB7_DTINIS, CB7.CB7_DTEMIS, CB7.CB7_HRINIS, CB7.CB7_HREMIS, CB7.CB7_CLIENT, CB7.CB7_CODOPE, CB7.CB7_CODOP2, "
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
cQuery1 += " AND CB7.CB7_ORDSEP BETWEEN '" + (mv_par01)      +"'  AND '"+ (mv_par02)     +"' " 			// De Separa็ใo, At้ Separa็ใo
//cQuery1 += " AND CB7.CB7_DTINIS BETWEEN '" + DTOS(mv_par03)  +"'  AND '"+ DTOS(mv_par04) +"' "			// De Data, At้ Data 
cQuery1 += " AND CB7.CB7_DTEMIS BETWEEN '" + DTOS(mv_par03)  +"'  AND '"+ DTOS(mv_par04) +"' "			// De Data, At้ Data 
cQuery1 += " AND CB7.CB7_CLIENT BETWEEN '" + (mv_par05)      +"'  AND '"+ (mv_par07)     +"' "			// De Cliente, At้ Cliente
cQuery1 += " AND CB7.CB7_LOJA   BETWEEN '" + (mv_par06)      +"'  AND '"+ (mv_par08)     +"' "			// De Loja, At้ Loja
cQuery1 += " ORDER BY CB7.CB7_ORDSEP, SB1.B1_ENDPAD, SB1.B1_DESC, CB8.CB8_PROD, CB8.CB8_ITEM "
cQuery1 := ChangeQuery(cQuery1)
If __cUserId=="000000"
//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",cQuery1)
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"TRBTMP",.T.,.F.)  

dbSelectArea("TRBTMP")
SetRegua(RecCount())
dbGoTop()
While !TRBTMP->(EOF())
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	_cCliFor := ""
	dbSelectArea("SC5")
	dbSetOrder(1)
	If MsSeek(xFilial("SC5") + TRBTMP->CB8_PEDIDO,.T.,.F.)
		If AllTrim(SC5->C5_TIPO) $ "D/B"
			dbSelectArea("SA2")
			dbSetOrder(1)
			If MsSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.)
				_cCliFor := "FORNEC.:      "  + SA2->A2_NOME
			EndIf
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			If MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.)
				_cCliFor := "CLIENTE:      "  + SA1->A1_NOME
			EndIf
		EndIf
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
	// N. Separa็ใo:                      Pedido:                                  Data:                                  Hora:
	// XXXXXX                             XXXXXX                                   XXXXXXXX                               XXXXXX
	// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//           10        20        30        40        50        60        70        80        90        100       110       120       130 
	@nLin,00     PSAY "N. SEPARACAO:  " + TRBTMP->CB7_ORDSEP 
//	@nLin,35     PSAY "PEDIDO:  " + TRBTMP->CB8_PEDIDO
	@nLin,70     PSAY _cCliFor
	nLin++ 
	// CLIENTE:                                                                    CONFERENTE:
	// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                    XXXXXX 
	// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//           10        20        30        40        50        60        70        80        90        100       110       120       130
	@nLin,35     PSAY "DATA:  " + DTOC(STOD(TRBTMP->CB7_DTEMIS)) // TRATAMENTO PARA DATA
	@nLin,70     PSAY "HORA:  " + TRBTMP->CB7_HREMIS
	@nLin,00     PSAY "CONFERENTE:  "   + TRBTMP->CB7_NOMOP2
	nLin++
    @nLin,00     PSAY "OBSERVAวีES:  "  + AllTrim(TRBTMP->CB7_OBS1)
   	nLin++
    @nLin,00     PSAY Replicate("_",132)
   	nLin++
   	@nLin,00     PSAY "N. SEPARACAO:  " + TRBTMP->CB7_ORDSEP
//	@nLin,35     PSAY "PEDIDO:       "  + TRBTMP->CB8_PEDIDO
	@nLin,70     PSAY _cCliFor
	nLin++
    @nLin,00     PSAY "SEPARADOR:  "    + TRBTMP->CB7_NOMOP1
	@nLin,36     PSAY "DATA INอCIO:  "  + DTOC(STOD(TRBTMP->CB7_DTEMIS)) // TRATAMENTO PARA DATA
	@nLin,70     PSAY "HORA INอCIO:  "  + TRBTMP->CB7_HREMIS
   	nLin++
   	@nLin,00     PSAY "OBSERVAวีES:  "  + AllTrim(TRBTMP->CB7_OBS1)
    nLin++
    @nLin,00     PSAY Replicate("_",132)
   	nLin+= 2  
	_nVez    := 0
    _cNumOrd := TRBTMP->CB7_ORDSEP
	While !TRBTMP->(EOF()) .AND. _cNumOrd == TRBTMP->CB7_ORDSEP
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Impressao do cabecalho do relatorio. . .                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nLin > 55 .OR. (!Empty(_cNumOrd) .AND. _cNumOrd <> TRBTMP->CB7_ORDSEP)
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin  := 8
			_nVez := 0
		EndIf
		_nVez++
		If _nVez == 1
//		    @nLin,00     PSAY "ITEM    PEDIDO    PRODUTO            DESCRIวรO                         QUANTIDADE      ARMAZEM   ENDEREวO     STATUS       LOTE    "
		    @nLin,00     PSAY "ITEM              PRODUTO            DESCRIวรO                         QUANTIDADE      ARMAZEM   ENDEREวO     STATUS           "
			nLin++
		EndIf
	    // ITEM    PEDIDO    PRODUTO            DESCRIวรO                         QUANTIDADE      ARMAZEM   ENDEREวO     STATUS         LOTE
	    //  XX     XXXXXX    XXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXX       XX     XXXXXXXXXX   [    ]         XXXXXXXXXX   
	    // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	    //           10        20        30        40        50        60        70        80        90        100       110       120       130
	    @nLin,01     PSAY TRBTMP->CB8_ITEM 
		//@nLin,08     PSAY TRBTMP->CB8_PEDIDO   	
		@nLin,08     PSAY TRBTMP->CB8_PROD
		@nLin,18     PSAY TRBTMP->B1_DESC
	    @nLin,37     PSAY TRBTMP->CB8_QTDORI Picture '@E 999,999,999.99' //12
		@nLin,67     PSAY TRBTMP->CB8_LOCAL
	    @nLin,90     PSAY TRBTMP->B1_ENDPAD
	    @nLin,97     PSAY "[    ]"
		//@nLin,110   PSAY TRBTMP->CB8_LOTECT		
		nLin++
		@nLin,00     PSAY Replicate("-",132)  // Nesse trecho irแ pontilhar abaixo de cada item descrito na rela็ใo                            
		nLin++
		dbSelectArea("TRBTMP")
		TRBTMP->(dbSkip())			// Avanca o ponteiro do registro no arquivo
	EndDo
EndDo
dbSelectArea("TRBTMP")
TRBTMP->(dbCloseArea())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
EndIf

MS_FLUSH()

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณAlessandro          บ Data ณ  05/03/13   บฑฑ
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