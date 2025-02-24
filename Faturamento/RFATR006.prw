#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณRFATR006  บ Autor ณ Anderson C. P. Coelho บ Data ณ  15/03/13บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de itens conferidos x a conferir.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function RFATR006()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "ORDEM DE SEPARAวรO - A conferir x conferido"
Local Titulo       	 := "ORDEM DE SEPARAวรO - A conferir x conferido"
Local Cabec1       	 := ""
Local Cabec2       	 := ""
Local nLin           := 80
Local Imprime      	 := .T.
//Local aOrd         := {}

Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private nLastKey     := 0
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private nTipo        := 18
Private Limite       := 120
Private CbTxt        := Space(10)
Private tamanho      := "M"
Private nomeprog     := "RFATR006"
Private cString      := "CB7"
Private wnrel        := nomeprog
Private cPerg		 := nomeprog
Private _cRotina     := nomeprog

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return
EndIf

dbSelectArea("CB7")
CB7->(dbSetOrder(1))

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,/*aOrd*/,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo) 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuno  ณRUNREPORT   บ Autor ณAnderson C. P. Coelho บ Data ณ  16/03/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescrio ณ Processamento da impressใo                                 บฑฑ
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
cQuery1 := "SELECT *, CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CB7Z.CB7_OBS1)) CB7_OBS1 "
cQuery1 += "FROM (
	cQuery1 += " SELECT CB7.R_E_C_N_O_ RECCB7, CB8.CB8_PEDIDO, (CASE WHEN CBG_CODPRO IS NULL THEN CB8_PROD ELSE CBG_CODPRO END) CBG_CODPRO, SB1.B1_DESC, "
	cQuery1 += "        SUM(CB8.CB8_QTDORI) CB8_QTDORI, SUM(CBGX.CBG_QTDE) CBG_QTDE "
	cQuery1 += " FROM "                  + RetSqlName("CB7") + " CB7 "
	cQuery1 += "       FULL OUTER JOIN ( "
	cQuery1 += "                         SELECT CBG1.CBG_ORDSEP CBG_ORDSEP, CBG1.CBG_CODPRO CBG_CODPRO, SUM(CBG1.CBG_QTDE) CBG_QTDE "
	cQuery1 += "                         FROM ( "
	cQuery1 += "                                SELECT CBG_ORDSEP, CBG_CODPRO, MAX(CBG_CODCON) CBG_CODCON "
	cQuery1 += "                                FROM " + RetSqlName("CBG") + " CBG "
	cQuery1 += "                                WHERE CBG.D_E_L_E_T_<>'*' "
	cQuery1 += "                                  AND CBG.CBG_FILIAL = '" + xFilial("CBG") + "' "
	cQuery1 += "                                GROUP BY CBG_ORDSEP, CBG_CODPRO "
	cQuery1 += "                               ) CBG2, " + RetSqlName("CBG") + " CBG1 "
	cQuery1 += "                         WHERE CBG1.D_E_L_E_T_<>'*' "
	cQuery1 += "                           AND CBG1.CBG_FILIAL = '" + xFilial("CBG") + "' "
	cQuery1 += "                           AND CBG1.CBG_ORDSEP = CBG2.CBG_ORDSEP "
	cQuery1 += "                           AND CBG1.CBG_CODPRO = CBG2.CBG_CODPRO "
	cQuery1 += "                           AND CBG1.CBG_CODCON = CBG2.CBG_CODCON "
	cQuery1 += "                         GROUP BY CBG1.CBG_ORDSEP, CBG1.CBG_CODPRO "
	cQuery1 += "                       ) CBGX ON                       CBGX.CBG_ORDSEP = CB7.CB7_ORDSEP "
	cQuery1 += "       LEFT OUTER JOIN " + RetSqlName("CB8") + " CB8 ON CB8.D_E_L_E_T_<> '*' "
	cQuery1 += "                                                    AND CB8.CB8_FILIAL = '"+ xFilial("CB8") + "' "
	cQuery1 += "                                                    AND CB8.CB8_ORDSEP = CB7.CB7_ORDSEP  "
	cQuery1 += "                                                    AND CB8.CB8_PROD   = (CASE WHEN CBG_CODPRO IS NULL THEN CB8_PROD ELSE CBG_CODPRO END) "
	cQuery1 += "       LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_<>'*' "
	cQuery1 += "                                                    AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery1 += "                                                    AND SB1.B1_COD     = (CASE WHEN CBG_CODPRO IS NULL THEN CB8_PROD ELSE CBG_CODPRO END) "
	cQuery1 += " WHERE CB7.D_E_L_E_T_      <> '*' "
	cQuery1 += "   AND CB7.CB7_FILIAL       = '" + xFilial ("CB7") + "' "
	cQuery1 += "   AND CB7.CB7_ORDSEP BETWEEN '" + (mv_par01)      + "'  AND '" + (mv_par02)     + "' "			// De Separa็ใo, At้ Separa็ใo
	cQuery1 += "   AND CB7.CB7_DTINIS BETWEEN '" + DTOS(mv_par03)  + "'  AND '" + DTOS(mv_par04) + "' "			// De Data, At้ Data 
	cQuery1 += "   AND CB7.CB7_CLIENT BETWEEN '" + (mv_par05)      + "'  AND '" + (mv_par07)     + "' "			// De Cliente, At้ Cliente
	cQuery1 += "   AND CB7.CB7_LOJA   BETWEEN '" + (mv_par06)      + "'  AND '" + (mv_par08)     + "' "			// De Loja, At้ Loja
	cQuery1 += " GROUP BY CB7.R_E_C_N_O_, CB8.CB8_PEDIDO, (CASE WHEN CBG_CODPRO IS NULL THEN CB8_PROD ELSE CBG_CODPRO END), SB1.B1_DESC "
cQuery1 += "     ) SEP, " + RetSqlName("CB7") + " CB7Z "
cQuery1 += "WHERE CB7Z.R_E_C_N_O_ = SEP.RECCB7 "
cQuery1 += "ORDER BY CB7_ORDSEP, CBG_CODPRO "
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
	If MsSeek(xFilial("SC5") + TRBTMP->CB7_PEDIDO,.T.,.F.)
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
   	@nLin,001    PSAY "SEPARAวรO:    " + TRBTMP->CB7_ORDSEP + " - " + DTOC(STOD(TRBTMP->CB7_DTEMIS)) + " - " + TRBTMP->CB7_HREMIS
	@nLin,060    PSAY "PEDIDO:       " + TRBTMP->CB7_PEDIDO
	nLin++
	@nLin,001    PSAY _cCliFor
	nLin++
    @nLin,001    PSAY "CONFERENTE:   " + TRBTMP->CB7_NOMOP2
	nLin++
	@nLin,001    PSAY "DT TษRMINO:   " + DTOC(STOD(TRBTMP->CB7_DTFIMS)) // TRATAMENTO PARA DATA
	@nLin,060    PSAY "HR TษRMINO:   " + SubStr(TRBTMP->CB7_HRFIMS,1,2)+":"+SubStr(TRBTMP->CB7_HRFIMS,3,2)
   	nLin++
   	@nLin,001    PSAY "OBSERVAวีES:  " + TRBTMP->CB7_OBS1
    nLin++
    @nLin,000    PSAY Replicate(".",Limite)
   	nLin += 2
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
		    @nLin,000    PSAY " PEDIDO  PRODUTO         DESCRIวรO                                                       QUANTIDADE            STATUS   "
			nLin++
		    @nLin,000    PSAY "                                                                                 A CONFERIR       CONFERIDA             "
			nLin++
		    @nLin,000    PSAY " ______  _______________ __________________________________________________  ______________  ______________  ___________"
			nLin++
//                              XXXXXX  XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999.99  999,999,999.99  XXXXXXXXXXX
//                             01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                                       10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220
		EndIf
	    @nLin,001    PSAY TRBTMP->CB8_PEDIDO
		@nLin,009    PSAY TRBTMP->CBG_CODPRO
		@nLin,025    PSAY TRBTMP->B1_DESC
	    @nLin,077    PSAY TRBTMP->CB8_QTDORI          Picture '@E 999,999,999.99'
	    @nLin,093    PSAY TRBTMP->CBG_QTDE            Picture '@E 999,999,999.99'
	    @nLin,110    PSAY IIF((TRBTMP->CB8_QTDORI - TRBTMP->CBG_QTDE)<>0,"DIVERGENTE!","OK!")
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

cPerg         := PADR(cPerg,10)

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