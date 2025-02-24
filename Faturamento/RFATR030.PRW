#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATR030  ºAutor  ³Júlio Soares           Data ³  09/05/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão da Invoice Arcolor USA                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Especifico para a empresa Arcolor USA.       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATR030(_cPv,_dEmisNF,_lImprime, _lEnvMail, cDanfe, _cHora)

Local _aSvArea         := GetArea()
Local _aSvSF2          := {}
Local _aSvSD2          := {}

Private _nNumPag       := 0
Private _nLin          := 0
Private _nLimite       := 2900
Private _nSaltoL       := 35
Private _nValMerc      := 0
Private _nTotalNf      := 0
Private _nValIPI       := 0
Private _nValFr        := 0
Private _cRotina       := "RFATR030"
Private Titulo         := _cRotina+"_INVOICE"
Private cPerg          := "RFATR030"
Private _cFromOri      := ""
Private _cMail         := ""
Private _cMsg          := ""
Private _cAnexo        := ""
Private _cPesW         := ""
Private _cPesN         := ""
Private _cPackg        := ""

Private _nPesW         := 0
Private _nPesN         := 0
Private _nPackg        := 0

Private _cMenInfo      := ""
Private _cObsCond	   := ""
Private _cNumTit       := ""
Private _cPrefix	   := ""
Private _cCarteir	   := ""
Private _cDescPag      := ""
Private _lEnt          := + CHR(13) + CHR(10)
Private _cEst          := ""

Default _cPv           := ""
Default _dEmisNF       := STOD("")
Default _lImprime	   := .F.
Private _lAuto		   := _lImprime
Default _lEnvMail	   := .F.
Private _lEnvBol       := _lEnvMail
Default cDanfe		   := ""
Private _cDanfe		   := cDanfe
Default _cHora		   := ""    

Private _cHoraAux	   := _cHora
Private _cTimeMin	   := ""
Private _cTimeMax	   := ""


dbSelectArea("SF2")
_aSvSF2 := SF2->(GetArea())
dbSelectArea("SD2")
_aSvSD2 := SD2->(GetArea())

If !Empty(_cHoraAux)
	_nVariac := SuperGetMv("MV_VARIAMI",,5) //Parâmetro com delay máximo entre faturamento da nota e geração do romaneio
	cHora 	 := SUBSTR(_cHoraAux, 1, 2)
	cMinutos := SUBSTR(_cHoraAux, 4, 2)
	If (Val(cMinutos)+_nVariac)>59
		cHoraMax 	:= StrZero(Val(cHora)+1,2)
		cMinuMax	:= StrZero((Val(cMinutos)-60)+_nVariac,2)
	Else
		cHoraMax 	:= StrZero(Val(cHora),2)
		cMinuMax	:= StrZero(Val(cMinutos)+_nVariac,2)
	EndIf
	If (Val(cMinutos)-_nVariac)<0
		cHoraMin 	:= StrZero(Val(cHora)-1,2)
		cMinuMin	:= StrZero((Val(cMinutos)-60)-_nVariac,2)
	Else
		cHoraMin 	:= StrZero(Val(cHora),2)
		cMinuMin	:= StrZero(Val(cMinutos)-_nVariac,2)
	EndIf
	_cTimeMin := AllTrim(cHoraMin) + ":" + AllTrim(cMinuMin)
	_cTimeMax := AllTrim(cHoraMax) + ":" + AllTrim(cMinuMax)
EndIf

ValidPerg()

If FunName() == "RFATR030"
	If !Pergunte(cPerg,.T.)
		RestArea(_aSvSD2)
		RestArea(_aSvSF2)
		RestArea(_aSvArea)
		Return
	Else
		_cFromOri := AllTrim(UsrRetMail(__cUserId))
	EndIf
Else
	Pergunte(cPerg,.F.)
	If Empty(_cPv)
		dbSelectArea("SF2")
		dbSelectArea("SD2")
		SD2->(dbSetOrder(3))
		If SD2->(MsSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA,.T.,.F.))
			_cPv     := SD2->D2_PEDIDO
			_dEmisNF := SD2->D2_EMISSAO
		EndIf
	EndIf
	If !Empty(_cPv)
		MV_PAR01 := _cPv
		MV_PAR02 := _dEmisNF
		MV_PAR03 := 1
	Else
		If !Pergunte(cPerg,.T.)
			RestArea(_aSvSD2)
			RestArea(_aSvSF2)
			RestArea(_aSvArea)
			Return
		EndIf
	EndIf
EndIf

// Exibe tela de carregamento da rotina
Processa({|lEnd|Imprime(@lEnd)},Titulo,"Processing printing...",.T.)

RestArea(_aSvSD2)
RestArea(_aSvSF2)
RestArea(_aSvArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Imprime  ºAutor  ³Júlio Soares          º Data ³  09/05/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processamento e impressão do relatório                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±a±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Imprime(lEnd)

Local cDrive, cDir, cNome, cExt
Local _cArq            := ""
Local lFormaTMSPrinter := .T.
Local nUsaPDF          := IMP_PDF	//IMP_SPOOL
Private _cTerms := ""
Private _cCond  := ""

cQuery1 := " SELECT F2_EST[EST],D2_CLIENTE[CLIENTE],D2_LOJA[LOJA],F2_EMISSAO[EMISSAO],F2_COND[CONDPG],D2_TIPO[TIPO],D2_PEDIDO[PEDIDO],D2_ITEMPV[ITEM]," + _lEnt
cQuery1 += " 		D2_COD[CODIGO],B1_DESC[DESCRICAO],B1_POSIPI[NCM],D2_UM[UM],D2_QUANT [QUANT], D2_SEGUM[UM2] ,D2_QTSEGUM[QUANT2],(D2_TOTAL/D2_QUANT) [PRECO]," + _lEnt
cQuery1 += " 		D2_TOTAL [VALMERC],D2_SERIE [SERIE], D2_DOC [DOC], D2_VALBRUT [TOTALNF], D2_VALIPI [TAX], F2_FRETE [FRETE]," + _lEnt
//cQuery1 += " 		B1_PESBRU[PBRUTO], B1_PESO[PLIQUI],F2_VOLUME1 [VOLUME], F2_ESPECI1[ESPEC]" + _lEnt
cQuery1 += " 		(B1_PESBRU*D2_QUANT)[PBRUTO],(B1_PESO*D2_QUANT)[PLIQUI],F2_VOLUME1 [VOLUME], F2_ESPECI1[ESPEC]" + _lEnt

cQuery1 += " FROM " + RetSqlName("SF2") + " SF2" + _lEnt

cQuery1 += " 	INNER JOIN " + RetSqlName("SD2") + " SD2 " + _lEnt
cQuery1 += " 		ON SD2.D_E_L_E_T_  = '' " + _lEnt
cQuery1 += " 		AND SD2.D2_FILIAL  = '" + xFilial("SD2") + "' " + _lEnt
cQuery1 += " 		AND SD2.D2_EMISSAO = SF2.F2_EMISSAO " + _lEnt
cQuery1 += " 		AND SD2.D2_DOC     = SF2.F2_DOC     " + _lEnt
cQuery1 += " 		AND SD2.D2_SERIE   = SF2.F2_SERIE   " + _lEnt
cQuery1 += " 		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE " + _lEnt
cQuery1 += " 		AND SD2.D2_LOJA    = SF2.F2_LOJA" + _lEnt

cQuery1 += " 	INNER JOIN " + RetSqlName("SB1") + " SB1" + _lEnt
cQuery1 += " 		ON SB1.D_E_L_E_T_ = ''" + _lEnt
cQuery1 += " 		AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' " + _lEnt
cQuery1 += " 		AND SD2.D2_COD    = SB1.B1_COD" + _lEnt
cQuery1 += " 		AND SD2.D2_TP     = SB1.B1_TIPO	" + _lEnt

cQuery1 += " WHERE SF2.D_E_L_E_T_ = '' " + _lEnt
cQuery1 += " AND SF2.F2_FILIAL   = '" + xFilial("SF2") + "' " + _lEnt
cQuery1 += " AND SF2.F2_EMISSAO  = '" + DTOS(MV_PAR02) + "' " + _lEnt
cQuery1 += " AND SD2.D2_PEDIDO   = '" + MV_PAR01 + "' " + _lEnt
cQuery1 += " GROUP BY F2_EST,D2_CLIENTE,D2_LOJA,F2_EMISSAO,F2_COND,D2_TIPO,D2_PEDIDO,D2_ITEMPV,D2_COD,B1_DESC,B1_DESC_E ,B1_POSIPI," + _lEnt
cQuery1 += " 		D2_UM,D2_QUANT,D2_SEGUM,D2_QTSEGUM,D2_TOTAL,D2_SERIE,D2_DOC,D2_VALBRUT,D2_VALIPI,B1_PESBRU, B1_PESO, F2_VOLUME1,F2_ESPECI1,F2_FRETE" + _lEnt
cQuery1 += " ORDER BY D2_CLIENTE,D2_LOJA,F2_EMISSAO,D2_PEDIDO,D2_ITEMPV,B1_DESC_E" + _lEnt

cQuery1 := ChangeQuery(cQuery1)
//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",cQuery1)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"TRE",.T.,.F.)

dbSelectArea("TRE")
ProcRegua(TRE->(RecCount()))
TRE->(dbGoTop())
If !TRE->(EOF())
	_cArq := StrTran(Titulo," ","_")+"_"+DTOS(dDataBase)+StrTran(Time(),":","")+".rel"
	Private oPrn           := FWMSPrinter():New(_cArq,nUsaPDF,lFormaTMSPrinter,,.T.,.F.,,"",.F.,.T.,.F.,.T.)
	Private oFont06        := TFont():New( "Arial",,06,,.F.,,,,.F.,.F. )
	Private oFont07        := TFont():New( "Arial",,07,,.F.,,,,.F.,.F. )
	Private oFont08        := TFont():New( "Arial",,08,,.F.,,,,.F.,.F. )
	Private oFont09        := TFont():New( "Arial",,09,,.F.,,,,.F.,.F. )
	Private oFont10        := TFont():New( "Arial",,10,,.F.,,,,.F.,.F. )
	Private oFont11        := TFont():New( "Arial",,11,,.F.,,,,.F.,.F. )
	Private oFont12        := TFont():New( "Arial",,12,,.F.,,,,.F.,.F. )
	Private oFont13        := TFont():New( "Arial",,13,,.F.,,,,.F.,.F. )
	Private oFont14        := TFont():New( "Arial",,14,,.F.,,,,.F.,.F. )
	Private oFont15        := TFont():New( "Arial",,15,,.F.,,,,.F.,.F. )
	Private oFont16        := TFont():New( "Arial",,16,,.F.,,,,.F.,.F. )
	Private oFont17        := TFont():New( "Arial",,17,,.F.,,,,.F.,.F. )
	Private oFont18        := TFont():New( "Arial",,18,,.F.,,,,.F.,.F. )
	Private oFont19        := TFont():New( "Arial",,19,,.F.,,,,.F.,.F. )
	Private oFont20        := TFont():New( "Arial",,20,,.F.,,,,.F.,.F. )
	Private oFont06N       := TFont():New( "Arial",,06,,.T.,,,,.F.,.F. )
	Private oFont07N       := TFont():New( "Arial",,07,,.T.,,,,.F.,.F. )
	Private oFont08N       := TFont():New( "Arial",,08,,.T.,,,,.F.,.F. )
	Private oFont09N       := TFont():New( "Arial",,09,,.T.,,,,.F.,.F. )
	Private oFont10N       := TFont():New( "Arial",,10,,.T.,,,,.F.,.F. )
	Private oFont11N       := TFont():New( "Arial",,11,,.T.,,,,.F.,.F. )
	Private oFont12N       := TFont():New( "Arial",,12,,.T.,,,,.F.,.F. )
	Private oFont13N       := TFont():New( "Arial",,13,,.T.,,,,.F.,.F. )
	Private oFont14N       := TFont():New( "Arial",,14,,.T.,,,,.F.,.F. )
	Private oFont15N       := TFont():New( "Arial",,15,,.T.,,,,.F.,.F. )
	Private oFont16N       := TFont():New( "Arial",,16,,.T.,,,,.F.,.F. )
	Private oFont17N       := TFont():New( "Arial",,17,,.T.,,,,.F.,.F. )
	Private oFont18N       := TFont():New( "Arial",,18,,.T.,,,,.F.,.F. )
	Private oFont19N       := TFont():New( "Arial",,19,,.T.,,,,.F.,.F. )
	Private oFont20N       := TFont():New( "Arial",,20,,.T.,,,,.F.,.F. )
	Private oFont24N       := TFont():New( "Arial",,24,,.T.,,,,.F.,.F. )

	//oPrn:SetLandScape()	// Orientação do Papel (Paisagem)
	oPrn:SetPortrait()		// Orientação do Papel (Retrato)
	oPrn:SetPaperSize(9)	// Tamanho da Folha (9 = A4)
	//oPrn:Setup()
	//oPrn:SetPortrait()    // Orientação do Papel (Retrato)
	//	oPrn:cPathPDF := "C:\"
	_cPv   := ""
	_nCont := 0
	While !TRE->(EOF()) .AND. !lEnd
	_nCont++
	IncProc(cValToChar(_nCont))
		If _cPv <> (TRE->(PEDIDO))
			If _nCont > 1
				If (_nLin+(_nSaltoL*4)) > _nLimite
					oPrn:EndPage()
					oPrn:StartPage()
					ImpCab()
					CabDocto(2)
				EndIf
				_nLin     += _nSaltoL
				oPrn:Say(_nLin, 1500,"PRODUCTS"                                            , oFont16N, 0100,   ,,1)
				oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValMerc,"@E 999,999,999,999.99"), oFont14 , 2000,200,,1,1)

				_nLin     += _nSaltoL + 0010
				oPrn:Say(_nLin, 1500,"SALES TAX"                                           , oFont16N, 0100,   ,,1)
				oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValIPI ,"@E 999,999,999,999.99"), oFont14 , 2000,200,,1,1)

				_nLin     += _nSaltoL + 0010
				oPrn:Say(_nLin, 1500,"FREIGHT"                                             , oFont16N, 0100,   ,,1)
				oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValFr  ,"@E 999,999,999,999.99"), oFont14 , 2000,200,,1,1)

				_nLin     += _nSaltoL + 0015
				oPrn:Say(_nLin, 1500,"TOTAL VALUE"                                         , oFont18N, 0100,   ,,1)
				oPrn:SayAlign(_nLin-0025, 0150,Transform(_nTotalNf,"@E 999,999,999,999.99"), oFont16N, 2000,200,,1,1)
				oPrn:EndPage()

				_nValMerc := 0
				_nTotalNf := 0
				_nValIPI  := 0
			EndIf
			oPrn:StartPage()
			ImpCab()
			CabDocto(1)
		EndIf
		If _nLin > _nLimite
			oPrn:EndPage()
			oPrn:StartPage()
			ImpCab()
			CabDocto(2)
		EndIf

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1") + TRE->CODIGO,.T.,.F.))
		// Products
		_lProd := 0050
		oPrn:BOX(_nLin, _lProd,_nLin-0036,_lProd)
		oPrn:Say(_nLin, _lProd+15,(TRE->(CODIGO))                                   , oFont12 ,100,,,3)
		// Descripitions
		_lDescri := 0245
		oPrn:BOX(_nLin, _lDescri,_nLin-0036,_lDescri)
		oPrn:Say(_nLin, _lDescri+5,SubStr(SB1->(B1_DESC),1,60)                       , oFont12 ,100,,,3)
		// - Informa campo do NCM quando se trata de exportação HTC
		_lHTC := 1185
		If (TRE->(EST)) == 'EX'
			oPrn:BOX(_nLin, _lHTC,_nLin-0036,_lHTC)
			oPrn:Say(_nLin, _lHTC+5,(TRE->(NCM))                                  , oFont12 ,100,,,3)
		_cEst := (TRE->(EST))
		EndIf
		// UM
		_lUM := 1345
		oPrn:BOX(_nLin, _lUM,_nLin-0036,_lUM)
		oPrn:Say(_nLin, _lUM+15,(TRE->(UM))                                       , oFont12 ,100,,,3)
		// Quantity
		_lQuant := 1435
		oPrn:BOX(_nLin, _lQuant,_nLin-0036,_lQuant)
		oPrn:Say(_nLin, _lQuant+5,Transform(TRE->(QUANT)   ,"@E 999,999,999,999")  , oFont12 ,100,,,1)
		// Packging
		_lPack := 1650
		oPrn:BOX(_nLin, _lPack,_nLin-0036,_lPack)
		oPrn:Say(_nLin, _lPack+5,Transform(TRE->(QUANT2)   ,"@E 999,999,999,999")  , oFont12 ,100,,,1)
		// Unit Price
		_lPrice := 1870		
		oPrn:BOX(_nLin, _lPrice,_nLin-0036,_lPrice)
		oPrn:Say(_nLin, _lPrice + 5,Transform(TRE->(PRECO) ,"@E 999,999,999,999.99"), oFont12 ,100,,,1)
		// Amount
		_lMount := 2050
		oPrn:BOX(_nLin, _lMount,_nLin-0036,_lMount)
		oPrn:Say(_nLin, _lMount+5,Transform(TRE->(VALMERC) ,"@E 999,999,999,999.99"), oFont12 ,100,,,1)
		// Linha final
		oPrn:BOX(_nLin, 2250,_nLin-0036,2250)

		_nLin     += _nSaltoL
		_nValMerc += (TRE->(VALMERC))
		_nTotalNf += (TRE->(TOTALNF))
		_nValIPI  += (TRE->(TAX))
		_nValFr   := (TRE->(FRETE))
		_nPesW    += (TRE->(PBRUTO))
		_nPesN    += (TRE->(PLIQUI))
		_nPackg   += (TRE->(VOLUME))
		_cPv      := (TRE->(PEDIDO))
		_cNumTit  := (TRE->(DOC))
		_cPrefix  := (TRE->(SERIE))
		_cCond    := (TRE->(CONDPG))

		dbSelectArea("TRE")
		TRE->(dbSkip())
	EndDo
	If lEnd
		Alert("Relatório Abortado!")
		Return
	EndIf                                                       
	// - MONTA AS LINHAS COM ESPAÇO NO FINAL DA IMPRESSÃO DOS PRODUTOS

	// Products
	oPrn:BOX(_nLin, _lProd,_nLin-0036,_lProd)
	// Descripition
	oPrn:BOX(_nLin, _lDescri,_nLin-0036,_lDescri)
	// HTC
	If _cEst == 'EX'
		oPrn:BOX(_nLin, _lHTC,_nLin-0036,_lHTC)
	EndIf
	//Unity Packaging
	oPrn:BOX(_nLin, _lUM,_nLin-0036,_lUM)
	//Quantity
	oPrn:BOX(_nLin, _lQuant,_nLin-0036,_lQuant)
	//Packing
	oPrn:BOX(_nLin, _lPack,_nLin-0036,_lPack)
	//Unit Price
	oPrn:BOX(_nLin, _lPrice,_nLin-0036,_lPrice)
	// Amount
	oPrn:BOX(_nLin, _lMount,_nLin-0036,_lMount)
	// Final de coluna
	oPrn:BOX(_nLin, 2250,_nLin-0036,2250)
	_nLin     += _nSaltoL
	// Imprime linha
	oPrn:Line(_nLin-0035,0050,_nLin-0035,2250, ,"-8")
	_nValTot := (_nValFr + _nTotalNf)

	If (_nLin+(_nSaltoL*4)) > _nLimite
		oPrn:EndPage()
		oPrn:StartPage()
		ImpCab()
		CabDocto(2)
	EndIf
	// - IMPRIME OS TOTAIS
	oPrn:Line(_nLin+0001, 0001, _nLin+0001, 2250, ,"-8")
	_nLin     += _nSaltoL + 0010

	oPrn:Say(_nLin, 1500,"PRODUCTS"                                            , oFont14N, 100,    ,,1)
	oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValMerc,"@E 999,999,999,999.99"), oFont12 , 2000,200,,1,1)
	_nLin     += _nSaltoL + 0010

	oPrn:Say(_nLin, 1500,"SALES TAX"                                           , oFont14N, 100 ,   ,,1)
	oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValIPI ,"@E 999,999,999,999.99"), oFont12 , 2000,200,,1,1)
	_nLin     += _nSaltoL + 0010

	oPrn:Say(_nLin, 1500,"FREIGHT"                                             , oFont14N, 0100,   ,,1)
	oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValFr  ,"@E 999,999,999,999.99"), oFont12 , 2000,200,,1,1)
	_nLin     += _nSaltoL+ 0015

	oPrn:Say(_nLin, 1500,"TOTAL VALUE"                                         , oFont16N, 100,    ,,1)
	oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValTot ,"@E 999,999,999,999.99"), oFont14N, 2000,200,,1,1)

 	If (_cEst) == 'EX'
		oPrn:Say(_nLin, 0030, " Gross Weight(Kg): "+ Transform(_nPesW,"@E 999,999.999"), oFont14 , 0100,   ,,3)
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 0030, " Net Weight(Kg):   "+ Transform(_nPesN,"@E 999,999.999"), oFont14 , 0100,   ,,3)
		_nLin     += _nSaltoL

	Else
		oPrn:Say(_nLin, 0030, " Gross Weight(Lb): "+ Transform((_nPesW*2.2),"@E 999,999.999"), oFont14 , 0100,   ,,3)
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 0030, " Net Weight(Lb):   "+ Transform((_nPesN*2.2),"@E 999,999.999"), oFont14 , 0100,   ,,3)
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 0030, " Package:      " + (cValToChar(_nPackg)) + " - " +(ALLTRIM(TRE->(ESPEC))) , oFont14, 0100,   ,,3)
		_nLin     += _nSaltoL+ 0030

	EndIf
	_cEnd   := ((Alltrim(SM0->M0_ENDCOB)) + " - " + (ALLTRIM(SM0->M0_CIDCOB)) + " - " + (ALLTRIM(SM0->M0_ESTCOB))) + "."
	_cTerms += "Payments are to be made in US dollars." + CHR(13)+CHR(10)
	_cTerms += "Unless otherwise specified all invoices are due " +(ALLTRIM(POSICIONE("SE4",1,xFilial("SE4")+ (_cCond),"E4_DESCRI"))) + " from date of Shipment." + CHR(13)+CHR(10)
	_cTerms += "Invoice prices WILL BE THOSE IN EFFECT AT TIME OF SHIPMENT. " + CHR(13)+CHR(10)
	_cTerms += "All prices are FOB/MIAMI FL." + CHR(13)+CHR(10)
	_cTerms += "All orders are invoiced upon shipment." + CHR(13)+CHR(10)
	_cTerms += "Arcolor USA accepts payment of invoices by check and bank deposit All Checks must be mailed to: " + CHR(13)+CHR(10)
	_cTerms += (_cEnd) + CHR(13)+CHR(10)
	_cTerms += "Arcolor reserves the right to charge interest on invoices not paid by the due date at the rate of 2% (two percent) per month "
	_cTerms += "or at the maximum lesser rate permitted by law."
//	_cTerms += "" + CHR(13)+CHR(10)
//	_cTerms += "" + CHR(13)+CHR(10)

	oPrn:Line(_nLin-0035,0050,_nLin-0035,2250, ,"-8")
	oPrn:Say(_nLin, 0100,"Terms & Conditions" , oFont14N , 100,,,3)
	_nLin     += _nSaltoL+ 0030

	_cTermCond := ""
	_nTerms    := MlCount(_cTerms,120)
	For _x := 1 To _nTerms
		_cTermCond := MemoLine(_cTerms,120,_x)
		While !Empty(_cTermCond)
			If CHR(13) + CHR(10) $ _cTermCond
				_cMsgCond := SubStr(_cTermCond,1,AT(CHR(13)+CHR(10),_cTermCond))
			Else
				_cMsgCond := _cTermCond
			EndIf
			_nLin += _nSaltoL
			oPrn:Say(_nLin, 0055,_cMsgCond, oFont14, 100,,,3)
			_cTermCond := SubStr(_cTermCond,Len(_cMsgCond)+1)
		EndDo
  	Next

	// - Mensagem da Invoice
	dbSelectArea("SC5")
	dbSetOrder(1)
	_cMens := ""
	If MsSeek(xFilial("SC5") + TRE->PEDIDO,.T.,.F.)
		If !(Empty(SC5->C5_MENPAD))
			_CMsgPad := (AllTrim(FORMULA(SC5->(C5_MENPAD))))

			_nTamMsg := MlCount(_cMsgPad,120)
			For _k := 1 To _nTamMsg
				_cMens := MemoLine(_cMsgPad,120,_k)
				While !Empty(_cMens)
					If CHR(13) + CHR(10) $ _cMens
						_cMsg := SubStr(_cMens,1,AT(CHR(13)+CHR(10),_cMens))
					Else
						_cMsg := _cMens
					EndIf
					_nLin += _nSaltoL
					oPrn:Say(_nLin, 0045,_cMsg, oFont10, 100,,,3)
					_cMens := SubStr(_cMens,Len(_cMsg)+1)
				EndDo
		  	Next

		EndIf
	EndIf

	oPrn:EndPage()
	oPrn:Preview()

	If File(oPrn:cPathPDF+StrTran(_cArq,".rel",".pdf"))
		dbSelectArea("SC5")
		dbSetOrder(1)
		dbGoTop()                     
		_cTpDiv   := ""
		_cTransp  := ""
		If MsSeek(xFilial("SC5")+_cPv,.T.,.F.)
			_cTpDiv  := SC5->(C5_TPDIV)
			_cTransp := SC5->(C5_TRANSP)
			If !(SC5->C5_TIPO $ "D/B")
				dbSelectArea("SA1")
				dbSetOrder(1)
				If MsSeek(xFilial("SA1")+SC5->C5_CLIENTE + SC5->C5_LOJACLI)
					_cCarteir := SA1->A1_CDCART
				EndIf
			EndIf
		EndIf
		/*
		If (ExistBlock("RFINR005") .Or. ExistBlock("RFINR017")) .And. !Empty(_cMail) .And. (_cTpDiv == "0" .Or. _lEnvBol) .And. (SuperGetMv("MV_AUTOBOL",,.T.) .Or. AllTrim(__cUserId)=='000000')
			_cNewArq := "\workflow\"+StrTran(_cArq,".rel",".pdf")
			_cAnexo  := (oPrn:cPathPDF+StrTran(_cArq,".rel",".pdf"))
			CpyT2S(_cAnexo, "\boletos", .F.)
			If _cTpDiv<>"0" //.And. !(_cTransp $ SuperGetMv("MV_AIBTRAN" ,,"NÃO DEFINIDO" ))
				If ExistBlock("RFINR005") .And. AllTrim(_cCarteir)<>"17"
					U_RFINR005(_cPrefix, _cNumTit, .T., .T. , .T. , .F., StrTran(_cNewArq,"\workflow\","\boletos\"),,,,_cDanfe,_cMail)
				ElseIf ExistBlock("RFINR017")
					U_RFINR017(_cPrefix, _cNumTit, .T., .T. , .T. , .F., StrTran(_cNewArq,"\workflow\","\boletos\"),,,,_cDanfe,_cMail)
				EndIf
			Else
				If ExistBlock("RFINR005") .And. AllTrim(_cCarteir)<>"17"
					U_RFINR005(_cPrefix, _cNumTit, .T., .T. , .T. , .F., StrTran(_cNewArq,"\workflow\","\boletos\"),,,,_cDanfe,_cMail)
				ElseIf ExistBlock("RFINR017")
					U_RFINR017(_cPrefix, _cNumTit, .T., .T. , .T. , .F., StrTran(_cNewArq,"\workflow\","\boletos\"),,,,_cDanfe,_cMail)
				EndIf
			EndIf
		ElseIf (MV_PAR03 == 1 .OR. FunName()=="SPEDNFE") .AND. !_lAuto .AND. ExistBlock("RCFGM001") .AND. !Empty(_cMail) .AND. ;
		MsgYesNo("Want to send this document to the email " + AllTrim(_cMail) + " at this time?",_cRotina+"_002")
			_cAnexo  := (oPrn:cPathPDF+StrTran(_cArq,".rel",".pdf"))
			_cMsg    := ""
//			_cMsg    += "Prezado cliente, pedimos que confira a sua solicitação em anexo. " + _lEnt
//			_cMsg    += "Em caso de dúvidas e/ou problemas, solicitamos que entre em contato conosco." + _lEnt + _lEnt + _lEnt
//			_cMsg    += "Atenciosamente, " + _lEnt + _lEnt
//			_cMsg    += "Departamento de Vendas"
			_cNewArq := ""
			_cNewArq := "\workflow\"+StrTran(_cArq,".rel",".pdf")
			CpyT2S(_cAnexo, "\workflow", .F.)
			_cAnexo  := _cNewArq
			_cCco := SuperGetMv("MV_FATCCO",,"")
			U_RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cCco)
		EndIf
		*/
		FErase(_cAnexo)
	EndIf
Else
	MsgAlert("There is no data to be printed.",_cRotina+"_001")
EndIf
TRE->(dbCloseArea())

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCab    ºAutor  ³Júlio Soares          º Data ³ 09/05/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-rotina de impressão do cabeçalho do relatório.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpCab()

cBitMap1:= ("arcolorUSA") + (".bmp")
_nNumpag++
_nLin := 0010

oPrn:Line(_nLin, 0001, _nLin, 2250, ,"-8")
_nLin += _nSaltoL

//oPrn:Say(_nLin, 0015,ALLTRIM(cUserName)          , oFont09N, 100,,,3)
oPrn:Say(_nLin, 2100,"Pág. "+cValToChar(_nNumpag), oFont09N, 100,,,3)
_nLin += _nSaltoL

//oPrn:Say(_nLin, 0015,DTOC(dDataBase)+" "+Time()  , oFont09N, 100,,,3)

oPrn:Say(_nLin, 1000,"INVOICE"  , oFont20N, 100,,,3)

//oPrn:Say(_nLin, 2100,_cRotina                    , oFont09N, 100,,,3)
_nLin += _nSaltoL-0010

oPrn:Line(_nLin, 0001, _nLin, 2250, ,"-8")

_nLin += _nSaltoL
oPrn:BOX(_nLin,0005,_nLin+00225,2300)	   //box cabeçalho
oPrn:BOX(_nLin,1750,_nLin+00225,1750)	   //linha divisão da logo
/*
oPrn:BOX(_nLin+00225,0005,_nLin+0475,2300) // Box cabeçálho inferior
oPrn:BOX(_nLin+00225,0900,_nLin+0475,0900) // Linha divisão 1
oPrn:BOX(_nLin+00225,1800,_nLin+0475,1800) // Linha divisão 2
*/
oPrn:SayBitmap(_nLin+0015,1750+0015,cBitMap1,450,200)

_nLin += _nSaltoL + 00025
oPrn:Say(_nLin,0015, (Alltrim(SM0->M0_NOMECOM)) ,ofont20N,100,,,3)

_nLin += _nSaltoL +00015

oPrn:Say(_nLin,0010, " ADDRESS "                                             ,ofont16N,100,,,3)
//oPrn:Say(_nLin,0450, (Alltrim(SM0->M0_ENDCOB) + " - " + Alltrim(SM0->M0_BAIRCOB))  ,ofont16 ,100,,,3)
oPrn:Say(_nLin,0450, (Alltrim(SM0->M0_ENDCOB))  ,ofont16 ,100,,,3)
_nLin += _nSaltoL + 00010
oPrn:Say(_nLin,0010, " CITY "                                            ,ofont16N,100,,,3)
oPrn:Say(_nLin,0150, (ALLTRIM(SM0->M0_CIDCOB))                           ,ofont16 ,100,,,3)
oPrn:Say(_nLin,0450, "STATE "                                            ,ofont16N,100,,,3)
oPrn:Say(_nLin,0600, (ALLTRIM(SM0->M0_ESTCOB))                           ,ofont16 ,100,,,3)
oPrn:Say(_nLin,0700, "ZIP CODE "                                         ,ofont16N,100,,,3)
oPrn:Say(_nLin,1000, (ALLTRIM(SM0->M0_CEPCOB))                           ,ofont16 ,100,,,3)
//oPrn:Say(_nLin,1200, "EIN "                                              ,ofont16N,100,,,3)
//oPrn:Say(_nLin,1300, (Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"))    ,ofont16 ,100,,,3)
//oPrn:Say(_nLin,0010," City          " + (SM0->M0_CIDCOB) + "  State   " +(SM0->M0_ESTCOB) + "  PostCode   " + (SM0->M0_CEPCOB) + "  EIN " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),ofont16N,100,,,3)
_nLin += _nSaltoL + 0010

oPrn:Say(_nLin,0010," Phone  "                                           ,ofont16N,100,,,3)
oPrn:Say(_nLin,0150,(ALLTRIM(SM0->M0_TEL))                               ,ofont16 ,100,,,3)
oPrn:Say(_nLin,0450,"Fax  "                                              ,ofont16N,100,,,3)
oPrn:Say(_nLin,0600,(ALLTRIM(SM0->M0_FAX))                               ,ofont16 ,100,,,3)
oPrn:Say(_nLin,0900,"Email  "                                            ,ofont16N,100,,,3)
oPrn:Say(_nLin,1100,"info@arcolor-usa.com"                               ,ofont16 ,100,,,3)

_nLin += _nSaltoL +00015

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CabDocto  ºAutor  ³Júlio Soares          º Data ³ 09/05/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Sub-Rotina utilizada para imprimir as informações de        º±±
±±º          ³cabeçalho do documento.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CabDocto(_nOpc)

If _nOpc == 1

	cQuery2 := " SELECT DISTINCT D2_DOC "                       + _lEnt
	cQuery2 += " FROM " + RetSqlName("SD2") + " SD2 "           + _lEnt
	If !Empty(_cHoraAux)
		cQuery2 += " INNER JOIN " + RetSqlName("SF2") + " SF2 " + _lEnt
		cQuery2 += " ON SD2.D2_DOC=SF2.F2_DOC "                 + _lEnt
		cQuery2 += " AND SD2.D2_SERIE=SF2.F2_SERIE "            + _lEnt
		cQuery2 += " AND SD2.D2_CLIENTE=SF2.F2_CLIENTE "        + _lEnt
		cQuery2 += " AND SD2.D2_LOJA=SF2.F2_LOJA "              + _lEnt
	EndIf
	cQuery2 += " WHERE SD2.D_E_L_E_T_    = '' " + _lEnt
	cQuery2 += "   AND SD2.D2_FILIAL     = '" + xFilial("SD2") + "' " + _lEnt
	cQuery2 += "   AND SD2.D2_PEDIDO     = '" + TRE->PEDIDO    + "' " + _lEnt
	cQuery2 += "   AND SD2.D2_EMISSAO    = '" + TRE->EMISSAO   + "' " + _lEnt
	cQuery2 += "   AND SD2.D2_SERIE     <> '" + TRE->SERIE     + "' " + _lEnt
	cQuery2 += "   AND SD2.D2_DOC       <> '" + TRE->DOC       + "' " + _lEnt
	If !Empty(_cHoraAux)
		cQuery2 += " AND SF2.D_E_L_E_T_             = '' "                                   + _lEnt
		cQuery2 += " AND SF2.F2_FILIAL              = '" + xFilial("SF2") + "' "             + _lEnt
		cQuery2 += " AND SF2.F2_HORA  BETWEEN '" + _cTimeMin + "' AND '" + _cTimeMax + "' "	 + _lEnt
	EndIf     
	cQuery2 := ChangeQuery(cQuery1)
	/*
	If __cUserId=="000000"
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.txt",cQuery2)
	EndIf
	*/
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"TRE2TMP",.T.,.F.)
	dbSelectArea("TRE2TMP")
	_cDoc := ""
	If !TRE2TMP->(EOF())
		_cDoc := TRE2TMP->DOC
	EndIf
	TRE2TMP->(dbCloseArea())
	_nLin += _nSaltoL

	_cNomCli := ""
	_cEndCli := ""
	_cEndEnt := ""	
	_cTelCli := ""
	_cMail   := ""
	_cPesW   := ""
	_cPesN   := ""
	_cPackg  := ""
	If TRE->TIPO $ "D/B"
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		If SA2->(MsSeek(xFilial("SA2")+TRE->CLIENTE+TRE->LOJA,.T.,.F.))
			_cNomCli := (ALLTRIM(SA2->(A2_NOME)))
			_cEndCli := (AllTrim(SA2->A2_END)) + (IIF(!empty(SA2->(A2_BAIRRO)),+ "  -  " + (AllTrim(SA2->A2_BAIRRO)),+ (AllTrim(SA2->A2_BAIRRO))))
			_cEndCl2 := (AllTrim(SA2->A2_MUN)) + " / " + (SA2->(A2_EST)) + "  -  " + (AllTrim(SA2->A2_CEP))
			_cTelCli := (IIF(!Empty(SA2->A2_DDI),(AllTrim(SA2->A2_DDI)),""))+(IIF(!Empty(SA2->A2_DDD),"("+AllTrim(SA2->A2_DDD)+") ","")) + (AllTrim(SA2->A2_TEL))
			_cMail   := AllTrim(LOWER(SA2->A2_EMAIL))
		EndIf
	Else
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+TRE->CLIENTE+TRE->LOJA,.T.,.F.))
			_cNomCli := (ALLTRIM(SA1->(A1_NOME)))
			_cEndCli := AllTrim(SA1->A1_END) + (IIF(!Empty(SA1->(A1_BAIRRO)), + "  -  " + (AllTrim(SA1->A1_BAIRRO)),+ (AllTrim(SA1->A1_BAIRRO))))
			_cEndCl2 := AllTrim(SA1->A1_MUN) + (IIF(!Empty(SA1->(A1_EST)), + " " + SA1->(A1_EST),+ SA1->(A1_EST))) + (IIF (!Empty(SA1->(A1_CEP)),+ " - " +AllTrim(SA1->(A1_CEP)), +AllTrim(SA1->(A1_CEP))))
			_cEndEnt := AllTrim(SA1->A1_ENDENT) + (IIF(!Empty(SA1->(A1_BAIRROE)),+ " - "+AllTrim(SA1->A1_BAIRROE),+AllTrim(SA1->A1_BAIRROE)))
			_cEndEn2 := AllTrim(SA1->A1_MUNE) + (IIF(!Empty(SA1->(A1_ESTE)), + " " + SA1->(A1_ESTE), + SA1->(A1_ESTE))) + (IIF(!Empty(SA1->(A1_CEPE)),+" - "+AllTrim(SA1->(A1_CEPE)),+AllTrim(SA1->(A1_CEPE))))
			_cTelCli := (IIF(!Empty(SA1->(A1_DDI)),AllTrim(SA1->(A1_DDI)),"")) + (IIF(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->(A1_DDD))+") ","")) + (AllTrim(SA1->A1_TEL))
			_cMail   := AllTrim(LOWER(SA1->A1_EMAIL))
			_cCarteir:= SA1->A1_CDCART
		EndIf
	EndIf
	oPrn:Say(_nLin, 0050,"SOLD TO", oFont14N, 100,,,3)
	oPrn:Say(_nLin, 1100,"SHIP TO", oFont14N, 100,,,3)
	_nLin += _nSaltoL

	If (Len (_cNomCli)) >= 30
		_cNomCl1 := Substr(Alltrim(_cNomCli),1,30)
		oPrn:Say(_nLin, 0030,(_cNomCl1) , oFont14, 100,,,3)
		oPrn:Say(_nLin, 0930,(_cNomCl1) , oFont14, 100,,,3)

		oPrn:Say(_nLin, 1800,"INVOICE No# " , oFont14N , 100,,,3)	
		oPrn:Say(_nLin, 2030,(AllTrim(TRE->(DOC))), oFont14 , 100,,,3)
		_nLin += _nSaltoL

		_cNomCl2 := Substr(Alltrim(_cNomCli),31,80)
		oPrn:Say(_nLin, 0030,ALLTRIM(_cNomCl2) /*+ " - " + (TRE->(CLIENTE))+"-"+(TRE->(LOJA))*/, oFont14, 100,,,3)
		oPrn:Say(_nLin, 0930,ALLTRIM(_cNomCl2) /*+ " - " + (TRE->(CLIENTE))+"-"+(TRE->(LOJA))*/, oFont14, 100,,,3)
		_nLin += _nSaltoL		
	Else
		_cNomCli := _cNomCli
		oPrn:Say(_nLin, 0030,(Alltrim(_cNomCli)) /*+ " - " + (TRE->(CLIENTE))+"-"+(TRE->(LOJA))*/, oFont14, 100,,,3)
		oPrn:Say(_nLin, 0930,(Alltrim(_cNomCli)) /*+ " - " + (TRE->(CLIENTE))+"-"+(TRE->(LOJA))*/, oFont14, 100,,,3)

		oPrn:Say(_nLin, 1800,"INVOICE No# " , oFont14N , 100,,,3)	
		oPrn:Say(_nLin, 2030,(AllTrim(TRE->(SERIE)))+"/"+(AllTrim(TRE->(DOC))), oFont14 , 100,,,3)
		_nLin += _nSaltoL
	EndIf

	oPrn:Say(_nLin, 0030,(_cEndCli), oFont14, 100,,,3)
	oPrn:Say(_nLin, 0930,(_cEndEnt), oFont14, 100,,,3)
	oPrn:Say(_nLin, 1800,"DATE " , oFont14N, 100,,,3)
//	oPrn:Say(_nLin, 2050,(DTOC(STOD(TRE->(EMISSAO)))) , oFont14, 100,,,3)
	oPrn:Say(_nLin, 2030,((cMonth((STOD(TRE->(EMISSAO))))) + ' - ' + cValToChar(day(STOD(TRE->(EMISSAO)))) +' - '+ cValtoChar(year(STOD(TRE->(EMISSAO))))) , oFont14, 100,,,3)

	_nLin += _nSaltoL	

	oPrn:Say(_nLin, 0030,(_cEndCl2), oFont14, 100,,,3)
	oPrn:Say(_nLin, 0930,(_cEndEn2), oFont14, 100,,,3)
	oPrn:Say(_nLin, 1800,"PO# "    , oFont14N , 100,,,3)
//	oPrn:Say(_nLin, 2050,(TRE->(PEDIDO)) , oFont14 , 100,,,3)	
	oPrn:Say(_nLin, 2030,(POSICIONE("SC5",1,xFilial("SC5")+(TRE->(PEDIDO)),Alltrim("SC5->C5_PEDCLI2"))) , oFont14 , 100,,,3)	

	_nLin += _nSaltoL

	oPrn:Say(_nLin, 0030, IIF(!Empty(_cTelCli),"Phone " + (_cTelCli),""), oFont14, 100,,,3)
	oPrn:Say(_nLin, 0930, IIF(!Empty(_cTelCli),"Phone " + (_cTelCli),""), oFont14, 100,,,3)
	oPrn:Say(_nLin, 1800,"ORDER# " , oFont14N , 100,,,3)
	oPrn:Say(_nLin, 2030,(cValtoChar(TRE->(PEDIDO)))  , oFont14 , 100,,,3)

	_nLin += _nSaltoL

	dbSelectArea("SE4")
	If SE4->(FieldPos("E4_OBSNOTA"))<>0
		_cCondPag := Posicione("SC5",1,xFilial("SC5")+(TRE->PEDIDO)	,"C5_CONDPAG")
		_cObsCond := AllTrim(Posicione("SE4",1,xFilial("SE4")+_cCondPag,"E4_OBSNOTA"))						
	EndIf
	_nLin += _nSaltoL
EndIf

_nLin += _nSaltoL

oPrn:Say(_nLin, 0100,"Product"         , oFont14N, 100,,,3)
oPrn:Say(_nLin, 0300,"Description"     , oFont14N, 100,,,3)
If (TRE->(EST)) == 'EX'
	oPrn:Say(_nLin, 1250,"HTS"         , oFont14N, 100,,,3)
EndIf
oPrn:Say(_nLin, 1350,"Unit"           , oFont14N, 100,,,3)
oPrn:Say(_nLin, 1455,"Quantity"        , oFont14N, 100,,,3)
oPrn:Say(_nLin, 1695,"Packaging"       , oFont14N, 100,,,3)
oPrn:Say(_nLin, 1875,"Unit Price"      , oFont14N, 100,,,3)
oPrn:Say(_nLin, 2095,"Amount"          , oFont14N, 100,,,3)

_nLin += _nSaltoL-0010
oPrn:Say(_nLin, 1350," Pack"        , oFont14N, 100,,,3)

_nLin += _nSaltoL-0010
oPrn:Line(_nLin, 0050, _nLin, 2250, ,"-8")
_nLin += _nSaltoL

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpParc   ºAutor  ³Júlio Soares          º Data ³ 09/05/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Sub-Rotina utilizada para trazer as parcelas a receber      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpParc()

Local _aSavArea := GetArea()
Local _nParc    := 0
Local _aColPar  := {0030,0700,1370}

_cQry := " SELECT E1_PARCELA, E1_VENCTO, E1_VALOR "
_cQry += " FROM " + RetSqlName("SE1") + " SE1 "
If !Empty(_cHoraAux)
	_cQry += " INNER JOIN " + RetSqlName("SF2") + " SF2 "
	_cQry += " ON SE1.E1_NUM=SF2.F2_DOC "
	_cQry += " AND SE1.E1_PREFIXO=SF2.F2_SERIE "
	_cQry += " AND SE1.E1_CLIENTE=SF2.F2_CLIENTE "
	_cQry += " AND SE1.E1_LOJA=SF2.F2_LOJA "
EndIf
_cQry += " WHERE SE1.D_E_L_E_T_       = '' "
_cQry += "   AND SE1.E1_FILIAL        = '" + xFilial("SE1")   + "' "
_cQry += "   AND SE1.E1_TIPO          = 'NF' "
_cQry += "   AND SE1.E1_PEDIDO        = '" + (TRE->(PEDIDO))  + "' "
_cQry += "   AND SE1.E1_EMISSAO       = '" + (TRE->(EMISSAO)) + "' "
_cQry += "   AND SE1.E1_CLIENTE       = '" + (TRE->(CLIENTE)) + "' "
_cQry += "   AND SE1.E1_LOJA          = '" + (TRE->(LOJA))    + "' "
If !Empty(_cHoraAux)
	_cQry += " AND SF2.D_E_L_E_T_             = '' "
	_cQry += " AND SF2.F2_FILIAL              = '" + xFilial("SF2") + "' "
	_cQry += " AND SF2.F2_HORA  BETWEEN '" + _cTimeMin + "' AND '" + _cTimeMax + "' "
EndIf
_cQry += "ORDER BY E1_VENCTO, E1_PARCELA, E1_PREFIXO, E1_VALOR "
_cQry   := ChangeQuery(_cQry)
/*
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_003.TXT",_cQry)
EndIf
*/

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SE1TMP",.T.,.F.)
dbSelectArea("SE1TMP")

SE1TMP->(dbGoTop())

If !SE1TMP->(EOF())
	_nLin += 0005
	While !SE1TMP->(EOF())
		_nLin    += _nSaltoL
		_nCntPar := 0
		While !SE1TMP->(EOF()) .AND. _nCntPar < 3
			_nCntPar++
			_nParc++
			oPrn:Say(_nLin, _aColPar[_nCntPar],"PAYMENT " + cValToChar(_nParc) + ": " + DTOC(STOD(SE1TMP->E1_VENCTO)) + Space(02) + Transform(SE1TMP->E1_VALOR,"@E 999,999,999,999.99"), oFont10, 100,,CLR_HBLUE,3)
			dbSelectArea("SE1TMP")
			SE1TMP->(dbSkip())
		EndDo
	EndDo
	_nLin += 0005
EndIf

dbSelectArea("SE1TMP")
SE1TMP->(dbCloseArea())

RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATR030  ºAutor  ³Júlio Soares           Data ³  09/05/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se as perguntas existem na SX1. Caso não existam,  º±±
±±º          ³as cria.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

cPerg         := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Pedido de Vendas      ?","","","mv_ch1" ,"C",06,0,0,"G","","mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SC5","",""})
AADD(aRegs,{cPerg,"02","Emissão NF            ?","","","mv_ch2" ,"D",08,0,0,"G","","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"03","Envia E-Mail p/Cliente?","","","mv_ch3" ,"N",01,0,0,"C","","mv_par03","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""   ,"",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(MsSeek(cPerg+aRegs[i,2],.T.,.F.))
		RecLock("SX1",.T.)
		For j := 1 To FCount()
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

Return()