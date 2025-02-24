#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "tbicode.ch"
#INCLUDE "colors.ch"
#INCLUDE "rptdef.ch"  
#INCLUDE "fwprintsetup.ch"
#INCLUDE "parmtype.ch"
#INCLUDE 'apvt100.ch'
#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'

#DEFINE _CLRF CHR(13)+CHR(10)

#DEFINE MAXPASSO    4
//Entry Point - Pontos de Entrada
#DEFINE EP_M460MKB  01
#DEFINE EP_M461IMPF 02
#DEFINE EP_SF2460I  03
#DEFINE EP_M460IPI  04
#DEFINE EP_M460ICM  05
#DEFINE EP_M460SOLI 06
#DEFINE EP_MSD2UM2  07
#DEFINE EP_MSD2460  08
#DEFINE EP_MTASF2   09
#DEFINE EP_F440COM  10
#DEFINE EP_M460IREN 11
#DEFINE EP_M460ISS  12
#DEFINE EP_M460VISS 13
#DEFINE EP_M460ATEC 14
#DEFINE EP_M460NITE 15
#DEFINE EP_M460PROC 16
#DEFINE EP_M460QRY  17
#DEFINE EP_M460FIL  18
#DEFINE EP_M460RTPD 19
#DEFINE EP_M460FIM  20
#DEFINE EP_M460COND 21
#DEFINE EP_M460INSS 22
#DEFINE EP_M460ITPD 23
#DEFINE EP_M460ORD  24
#DEFINE EP_M460MOED 25
#DEFINE EP_M460FIT  26
#DEFINE EP_M460IPT  27
#DEFINE EP_M460QRT  28
#DEFINE EP_M460SOT  29
#DEFINE EP_MSD246T  30
#DEFINE EP_MSD2UMT  31
#DEFINE EP_SF2460T  32
#DEFINE EP_M460RAT  33
#DEFINE EP_M461ACRE 34
#DEFINE _CRLF CHR(13) + CHR(10)
/*/{Protheus.doc} RFATA002
Rotina de confer๊ncia das ordens de separa็ใo em tela (Especํfico para a empresa Arcolor - CD Control).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 27/12/2012
@version P12.1.2310
@type function
@see https://allss.com.br
@history 12/01/2024, Rodrigo Telecio (rodrigo.telecio@allss.com.br), #7110 - Adequa็๕es no processo de faturamento de consignado.
/*/
user function RFATA002(_cNumOrd,_lAltVolu)
	Local oGet1
	Local oGet2
	Local oGet3
	Local oGet4
	Local oGet5
	Local oGet6
	Local oGet7
	Local oGet10
	Local oGrp1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9
	Local oSay10
	Local oButton1
	Local oButton2
	Local oButton3
	Local oMultiGe1
	Local oMultiGe2
	Local _oCodBar
	Local _nTamCBar    := 30

	Private aFieldFill := {}
	Private _lVisual   := .F.
	Private _lAlter    := .F.
	Private _lPesVol   := .F.
	Private _lGerouNF  := .F.
	Private _lReflesh  := .F.
	Private _lHabPLis  := GetMV("MV_PLCONF") //SuperGetMV("MV_PLCONF",,.F.)		//Habilita o tratamento dos itens por volume para o Packing List?
	Private _lRetFun   := .F.
	Private lCont	   := .T.
	Private _cRotina   := "RFATA002"
	Private _cOrdSep   := Space(len(CB7->CB7_ORDSEP))
	Private _cPedVen   := Space(len(CB7->CB7_PEDIDO))
	Private _cCli      := Space(50)
	Private _cNumCont  := StrZero(1,len(CBG->CBG_CODCON))
	Private _cConfrt   := cUserName
	Private _nPLiq     := 0
	Private _nPBrut    := 0
	Private _nQLida    := 0
	Private _nQtConf   := 1
	Private _nVol1     := 1
//	Private _nTpVal    := 1			//Tipo de validcao: 1=Com pergunta; 2=Sem pergunta
	Private _nItNF     := 0
	Private _nPProd    := 0
	Private _nPDesc    := 0
	Private _nPQtde    := 0
	Private _nPLote    := 0
	Private _nPEnd     := 0
	Private _nPVol1    := 0
	Private _nPObs     := 0
	Private _nPObsCnf  := 0
	Private _nPArm     := 0
	Private _nPDt      := 0
	Private _nPHr      := 0
	Private _nHandle   := 0
	Private _nHdlCB    := 0
	Private _nPsBrut   := 0
	Private _nPLiqu    := 0      
	Private _nTipDiv   := 0
	Private _cEspec    := Padr("VOLUME(S)",len(SC5->C5_ESPECI1))
	Private _cCodBar   := Space(_nTamCBar)
	Private _cCodConf  := __cUserId
	Private _cNomConf  := "USER - " + cUserName
	Private cMultiGe1  := ""
	Private cMultiGe2  := ""
	Private _cErro1    := "$$ PROD. #@#@#@#@# NรO ENCONTRADO!$$"
	Private _cErro2    := "$$ PROD. #@#@#@#@# NรO PERTENCE A ESTA SEPAR.!$$"
	Private _cErro3    := "$$ QTDE. DIVERG. P/ PRODUTO #@#@#@#@#!$$"
	Private cCadastro  := "* * *  E X P E D I ว ร O  * * *"
	Private _cNota     := ""
	Private _cSerie    := ""
	Private _cNotaAux  := ""
	Private _cRoman	   := ""
//	Private _cGetSep1  := ""
//	Private _cGetSep2  := ""
//	Private _cGetSep3  := ""
	Private _cAliasSX3 := ""
//	Private _nContPar  := 0
//	Private _bTIPO     := "Type('MV_PAR'+StrZero(_nContPar,2))"

	Default _cNumOrd   := Space(len(CB7->CB7_ORDSEP))
	Default _lAltVolu  := .T.

	Private _lSolicVol := _lAltVolu
	Private _aPedido   := {}

	Public  _cSepWindBRW := 1

	If !CheckInt()
		return
	EndIf 

	_cOrdSep := _cNumOrd
	If !Empty(_cOrdSep) .AND. !ValidSep(1) .AND. !_lVisual
		_cOrdSep := Space(len(CB7->CB7_ORDSEP))
	EndIf

	dbSelectArea("CB1")
	CB1->(dbSetOrder(2))
	If CB1->(MsSeek(xFilial("CB1") + __cUserId,.T.,.F.)) .AND. AllTrim(CB1->CB1_STATUS) == "1"
		_cCodConf := CB1->CB1_CODOPE
		_cNomConf := "OPER - " + CB1->CB1_NOME
	Else
		MsgAlert("Usuแrio nใo autorizado!",_cRotina+"_050")
		return
	EndIf
	If ExistBlock("RFATE062")
		//SetKey(K_CTRL_F3,{|| U_RFATE062()})
		SetKey(VK_F11   ,{|| U_RFATE062()})
	EndIf

	_cAliasSX3 := GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
	dbSelectArea(_cAliasSX3)
	(_cAliasSX3)->(dbSetOrder(2))

	dbSelectArea("SB1")
	//Set Filter To SB1->B1_MSBLQL <> "1" .AND. !Empty(SB1->B1_CODBAR+SB1->B1_CODBAR2)
	//SB1->(dbFilter())
	_cFilSB1 := " B1_MSBLQL == '2' .AND. !Empty(B1_CODBAR+B1_CODBAR2) "
	SB1->(dbClearFilter())
	SB1->(dbSetFilter( { || &(_cFilSB1) }, _cFilSB1 ))

	static oDlg
	  DEFINE MSDIALOG     oDlg   TITLE cCadastro + " - " + _cNomConf FROM 000, 000 TO 580, 1070 COLORS 0, 16777215                                                                                           PIXEL STYLE DS_MODALFRAME
		oDlg:lEscClose := .F.
	
	    @ 002, 002 GROUP oGrp1                          TO 288, 532 PROMPT " Confer๊ncia de Pedidos para Faturamento [Tecle F12 para informar a quantidade da proxima leitura] " OF oDlg COLOR 0, 16777215                      PIXEL
	
	    @ 017, 012   SAY oSay1  PROMPT "Separa็ใo:"   SIZE 030, 007 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 014, 045 MSGET oGet1     VAR _cOrdSep       SIZE 060, 010 OF oDlg COLORS 0, 16777215                F3 "CB7"     WHEN  IIF(Empty(_cOrdSep),Empty(_cOrdSep),.F.)  VALID ValidSep(1)   PIXEL
	    @ 052, 300   SAY oSay9  PROMPT "LEITURA:"     SIZE 025, 007 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 049, 330 MSGET _oCodBar  VAR _cCodBar       SIZE 190, 010 OF oDlg COLORS 0, 16777215 /*PICTURE "@!"*/  /*PASSWORD*/  WHEN !Empty(_cOrdSep) .AND. !_lVisual   VALID EVAL({|| _nHdlCB  := GetFocus(), _lValid := Leitura(),_cCodBar := Space(_nTamCBar),_lValid}) PIXEL
	    @ 034, 300   SAY oSay7  PROMPT "Volume:"      SIZE 025, 007 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 032, 330 MSGET oGet6     VAR _nVol1         SIZE 055, 010 OF oDlg COLORS 0, 16777215 PICTURE "@E 999,999,999.99" WHEN !Empty(_cOrdSep) .AND. (!_lVisual .And. _lPesVol) VALID ValidVol()  PIXEL
	
	    @ 017, 110   SAY oSay2  PROMPT "Pedido:"      SIZE 025, 007 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 014, 132 MSGET oGet2     VAR _cPedVen       SIZE 060, 010 OF oDlg COLORS 0, 16777215                F3 "SC5"     WHEN .F.                                VALID NAOVAZIO()           PIXEL
	    @ 017, 205   SAY oSay3  PROMPT "Cliente:"     SIZE 025, 007 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 014, 235 MSGET oGet3     VAR _cCli          SIZE 285, 010 OF oDlg COLORS 0, 16777215 PICTURE "@!"                WHEN .F.                                VALID NAOVAZIO()           PIXEL
	
	    @ 029, 012   SAY oSay4  PROMPT "Observa็๕es:" SIZE 036, 007 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 037, 012   GET oMultiGe1 VAR cMultiGe1      SIZE 180, 022 OF oDlg COLORS 0, 16777215                             WHEN .F.                       MULTILINE READONLY HSCROLL          PIXEL
	
	    @ 034, 205   SAY oSay5  PROMPT "Peso Lํq.:"   SIZE 030, 007 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 032, 235 MSGET oGet4     VAR _nPLiq         SIZE 050, 010 OF oDlg COLORS 0, 16777215 PICTURE "@E 999,999,999.99" WHEN !Empty(_cOrdSep) .AND. _lPesVol    VALID POSITIVO()           PIXEL
	    @ 052, 205   SAY oSay6  PROMPT "Peso Bruto:"  SIZE 028, 007 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 049, 235 MSGET oGet5     VAR _nPBrut        SIZE 050, 010 OF oDlg COLORS 0, 16777215 PICTURE "@E 999,999,999.99" WHEN !Empty(_cOrdSep) .AND. _lPesVol    VALID POSITIVO()           PIXEL
	
	
	    @ 034, 397   SAY oSay8  PROMPT "Esp้cie:"     SIZE 025, 007 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 032, 422 MSGET oGet7     VAR _cEspec        SIZE 098, 010 OF oDlg COLORS 0, 16777215 PICTURE "@!"                WHEN !Empty(_cOrdSep) .AND. _lPesVol    VALID NAOVAZIO()           PIXEL
	
	    @ 255, 010   GET oMultiGe2 VAR cMultiGe2      SIZE 350, 030 OF oDlg COLORS 0, 16777215                             WHEN .F.                       MULTILINE  READONLY HSCROLL         PIXEL
	
	//  @ 255, 370 BUTTON oButton3 PROMPT "Peso/Vol." SIZE 037, 012 OF oDlg ACTION EVAL({|| IIF(!_lVisual .AND. _lAlter .AND. MsgYesNo("Ativa/Desativa Peso/Volume?","Peso / Volume",_cRotina+"_013"), _lPesVol := !_lPesVol,NIL)})  PIXEL
	    @ 255, 370 BUTTON oButton3 PROMPT "Peso/Vol." SIZE 037, 012 OF oDlg ACTION EVAL({|| _lPesVol := !_lPesVol })                                                                                                                 PIXEL
	    @ 255, 425 BUTTON oButton1 PROMPT "Confirma"  SIZE 037, 012 OF oDlg ACTION EVAL({|| ConfirConf()          })                                                                                                                 PIXEL
	    @ 255, 480 BUTTON oButton2 PROMPT "Cancela"   SIZE 037, 012 OF oDlg ACTION EVAL({|| Cancel()              })                                                                                                                 PIXEL
		If __cUserId $  GetMV("MV_USRFATA") //SuperGetMV("MV_USRFATA",,"000000")
			@ 271, 370 BUTTON oButton2 PROMPT "Gera NF" SIZE 037, 012 OF oDlg ACTION EVAL({||IIF(MsgYesNo("Deseja gerar a nota fiscal, sem passar pelo processo de conferencia, neste momento?",_cRotina+"_049"),NotaFiscal(1),.F.)}) PIXEL
		EndIf
	// - Trecho inserido por J๚lio para que na tela da confer๊ncia seja apresentada o nome do conferente.
	    @ 274, 415   SAY oSay10  PROMPT "Conferente:"  SIZE 037, 012 OF oDlg COLORS 0, 16777215                                                                                                PIXEL
	    @ 271, 450 MSGET oGet10     VAR _cConfrt       SIZE 070, 007 OF oDlg COLORS 0, 16777215 PICTURE "@!"                WHEN .F.                                                           PIXEL
	
		fMSNewGe1()
		SetKey(VK_F12, { || SelQtde() } )
	
	  ACTIVATE MSDIALOG oDlg CENTERED

	_cSepWindBRW := 1

	if select(_cAliasSX3) > 0
		(_cAliasSX3)->(dbCloseArea())
	endif

	SetKey(VK_F12   , { ||  } )
	//SetKey(K_CTRL_F3, { ||  } )
	SetKey(VK_F11   , { ||  } )

	dbSelectArea("SB1")
	//Set Filter To 
	//SB1->(dbFilter())
	SB1->(dbClearFilter())
	if _lRetFun
		_lRetFun := .F.
		U_RFATA002(_cOrdSep,.T.)
	endif
return
/*/{Protheus.doc} fMSNewGe1
Montagem da GetDados principal da rotina RFATA002.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 27/12/2012
@version 1.0
@type function
@see https://allss.com.br
/*/
static function fMSNewGe1()
	Local nX
	Local cDelOk       := 'ExecBlock("RFATA02D")'
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	//Local aAlterFields := {	"CBG_OBSCNF" }
	Local aAlterFields := {	"CB9_PROD",;
							"B1_DESC"   ,;
							"CB9_QTESEP",;
							"CB9_LOCAL" ,;
							"CB9_LOTECT",;
							"CB9_LCALIZ",;
							"CBG_OBS"   ,;
							"CBG_OBSCNF",;
							"CBG_DATA"  ,;
							"CBG_HORA"  }
	Local aFields      := {	"CB9_PROD",;
							"B1_DESC"   ,;
							"CB9_QTESEP",;
							"CB9_LOCAL" ,;
							"CB9_LOTECT",;
							"CB9_LCALIZ",;
							"CBG_OBS"   ,;
							"CBG_OBSCNF",;
							"CBG_DATA"  ,;
							"CBG_HORA"  ,;
							"C5_VOLUME1" }
	static oMSNewGe1

	for nX := 1 to len(aFields)
		If (_cAliasSX3)->(MsSeek(aFields[nX],.T.,.F.))
			Aadd(aHeaderEx,{	AllTrim((_cAliasSX3)->X3_TITULO),;
								(_cAliasSX3)->X3_CAMPO      ,;
								(_cAliasSX3)->X3_PICTURE    ,;
								(_cAliasSX3)->X3_TAMANHO    ,;
								(_cAliasSX3)->X3_DECIMAL    ,;
								(_cAliasSX3)->X3_VALID      ,;
								(_cAliasSX3)->X3_USADO      ,;
								(_cAliasSX3)->X3_TIPO       ,;
								(_cAliasSX3)->X3_F3         ,;
								(_cAliasSX3)->X3_CONTEXT    ,;
								(_cAliasSX3)->X3_CBOX       ,;
								(_cAliasSX3)->X3_RELACAO      } )
		EndIf
	next nX

	for nX := 1 to len(aFields)
		If (_cAliasSX3)->(MsSeek(aFields[nX],.T.,.F.))
			Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
		EndIf
	next nX
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)
	oMSNewGe1 := MsNewGetDados():New( 070, 010, 252, 520, GD_UPDATE+GD_DELETE+GD_INSERT, "AllwaysTrue", "AllwaysTrue", "+CB8_ITEM", aAlterFields,, 999, "AllwaysTrue", "", cDelOk, oDlg, aHeaderEx, aColsEx)
	_nPProd   := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="CB9_PROD"})
	_nPDesc   := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="B1_DESC"   })
	_nPQtde   := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="CB9_QTESEP"})
	_nPArm    := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="CB9_LOCAL" })
	_nPLote   := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="CB9_LOTECT"})
	_nPEnd    := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="CB9_LCALIZ"})
	_nPObs    := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="CBG_OBS"   })
	_nPObsCnf := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="CBG_OBSCNF"})
	_nPDt     := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="CBG_DATA"  })
	_nPHr     := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="CBG_HORA"  })
	_nPVol1   := aScan(oMSNewGe1:aHeader,{|x|AllTrim(x[02])=="C5_VOLUME1"})
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidSep  บAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de valida็ใo da Ordem de Separa็ใo selecionada. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ValidSep(_nTpVal)
	Local _aArea    := GetArea()
	Local _aSCB1    := CB1->(GetArea())
	Local _aSCB7    := CB7->(GetArea())
	Local _aSCB8    := CB8->(GetArea())
	Local _aSCB9    := CB9->(GetArea())
	Local _aSCBG    := CBG->(GetArea())
	Local _aSSA1    := SA1->(GetArea())
	Local _aSSA2    := SA2->(GetArea())
//	Local _aSSX3    := SX3->(GetArea())
	Local _lRet     := Vazio(_cOrdSep) .OR. ExistCpo("CB7",_cOrdSep,1)
	Local _lAtuEnd  := .F.
	Local _lAcdRet  := .F.
	Local _dDtICb7  := ""
	Local _dDtFCb7  := ""
	Local _cCodCb7  := ""
	Local _cNomeCb7 := ""
	Local _cSF2TMP  := GetNextAlias()
	Local _xF2      := 0
	//Local nItemSep
	//**********************************************************************
	// INICIO
	// ARCOLOR - Adequa็ใo para preenchimento do grid para faturamento de
	// itens atrelados ao armaz้m "VC" (especifico processo consignado)
	// RODRIGO TELECIO em 12/01/2024
	//**********************************************************************
	local cTpOper   := AllTrim(SuperGetMV("MV_XTPOVLD",.F.,"VC"))
	// FIM
	//**********************************************************************
	_cPedVen        := ""
	_cCli           := ""

	If AllTrim(FunName()) == "ACDV166" .OR. AllTrim(FunName()) == "U_RACDV166"
		_lAcdRet := .T.
	EndIf
	If !_lAcdRet .AND. _nTpVal <> 2
		//Trecho incluํdo conforme solicita็ใo do Sr. Ronie, para valida็ใo do processo de separa็ใo antes do processo de confer๊ncia
		dbSelectArea("CB7")
		CB7->(dbSetOrder(1))
		If	CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
			_cCodCb7  := CB7->CB7_CODOPE
			_cNomeCb7 := CB7->CB7_NOMOP1
			_dDtICb7  := CB7->CB7_DTISEP
			_dDtFCb7  := CB7->CB7_DTFSEP
			If _cCodCb7 == _cCodConf .AND. !__cUserId $ GetMV("MV_SEPCONF") //SuperGetMV("MV_SEPCONF",,"000000")
				MsgStop("Voc๊ nใo poderแ realizar a confer๊ncia da O.S: '" + _cOrdSep + "', o separador nใo poderแ realizar a confer๊ncia da mesma O.S.!",_cRotina+"_000")
				_lRet := _lVisual := .F.
			ElseIf Empty(_dDtICb7) 
				MsgStop("Nใo foi realizado o processo de อnicio/Encerramento de separa็ใo da O.S. '" + _cOrdSep + "'. Pe็a aos separadores para realizarem o processo!",_cRotina+"_000A")
				_lRet := _lVisual := .F.
			ElseIf Empty(_dDtFCb7)
				MsgStop("O Separador '" + Alltrim(_cNomeCb7) + "' nใo realizou o Encerramento de Separa็ใo da O.S. '" + _cOrdSep + "'. Pe็a ao separador para realizar esse processo!",_cRotina+"_000B")
				_lRet := _lVisual := .F.
			EndIf
		EndIf
	EndIf
	If _lRet
		dbSelectArea("CB1")
		CB1->(dbSetOrder(2))		//CB1_FILIAL+CB1_CODUSR
		If !CB1->(MsSeek(xFilial("CB1") + __cUserId,.T.,.F.))
			If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
				MsgStop("Usuแrio nใo autorizado!",_cRotina+"_019")
	 		Else
				VtAlert("Usuแrio nใo autorizado!","AVISO",.T.)
	 		EndIf
			_lRet    := .F.
			_lVisual := .T.
			_cOrdSep := Space(len(CB7->CB7_ORDSEP))
			_cPedVen := Space(len(SC5->C5_NUM    ))
			return(_lRet)
		EndIf
		dbSelectArea("CB7")
		CB7->(dbSetOrder(1))
		If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
			If !__cUserId $ GetMV("MV_USRFATA") .AND. _nTpVal <> 2 //SuperGetMV("MV_USRFATA",,"000000")
				If !Empty(CB7->CB7_CODOP2) .AND. CB7->CB7_CODOP2 <> CB1->CB1_CODOPE
					MsgStop("Usuario sem permissao para acessar esta Ordem de Separacao!",_cRotina+"_020")
					_lRet    := .F.
					_lVisual := .T.
					_cOrdSep := Space(len(CB7->CB7_ORDSEP))
					_cPedVen := Space(len(SC5->C5_NUM    ))
					return(_lRet)
				EndIf
			EndIf
			If Empty(CB7->CB7_CODOPE) .AND. _nTpVal <> 2
				MsgStop("Esta Ordem de Separa็ใo nใo apresenta a identifica็ใo do Separador. Opera็ใo de confer๊ncia nใo permitida!",_cRotina+"_063")
				_lRet    := .F.
				_lVisual := .T.
				_cOrdSep := Space(len(CB7->CB7_ORDSEP))
				_cPedVen := Space(len(SC5->C5_NUM    ))
				return _lRet
			EndIf
			//Conte๚do do Status: "0-Inicio;1-Separando;2-Sep.Final;3-Embalando;4-Emb.Final;5-Gera Nota;6-Imp.nota;7-Imp.Vol;8-Embarcado;9-Embarque Finalizado"
			If AllTrim(CB7->CB7_STATUS)<="1" .AND. _nTpVal <> 2
				while !RecLock("CB7",.F.) ; enddo
					CB7->CB7_STATPA := "1"		//(Pausado): 0-Nao,1-Sim
					If Empty(CB7->CB7_DTINIS)
						CB7->CB7_DTINIS := Date()
						CB7->CB7_HRINIS := StrTran(Time(),":","")
						CB7->CB7_STATUS := "1"
						CB7->CB7_CODOP2 := _cCodConf
						CB7->CB7_NOMOP2 := _cNomConf
					EndIf
				CB7->(MSUNLOCK())
			Else
				_lRet    := .F.
				_lVisual := .T.
				If AllTrim(CB7->CB7_STATUS)>="5"
					_lAtuEnd := .T.
				Else

					If (_cAliasSX3)->(MsSeek("CB7_STATUS",.T.,.F.))
						_cStatus := AllTrim((_cAliasSX3)->X3_CBOX)
					Else
						_cStatus := "0-Inicio;1-Separando;2-Sep.Final;3-Embalando;4-Emb.Final;5-Gera Nota;6-Imp.nota;7-Imp.Vol;8-Embarcado;9-Embarque Finalizado"
					EndIf
					_cStatus := SubStr(_cStatus,AT(CB7->CB7_STATUS,_cStatus),AT(";",SubStr(_cStatus,AT(CB7->CB7_STATUS,_cStatus)))-1)
					MsgAlert("Esta ordem de separa็ใo encontra-se no status ' " + _cStatus + " '. Nใo ้ possํvel prosseguir com o status de conferencia jแ finalizado!",_cRotina+"_001")
					If MsgYesNo("Deseja reiniciar o processo de confer๊ncia?",_cRotina+"_051")
						_lRet    := .T.
						_lVisual := .F.
						If _nTpVal <> 2
							while !RecLock("CB7",.F.) ; enddo
								CB7->CB7_STATPA := "1"		//(Pausado): 0-Nao,1-Sim
								If Empty(CB7->CB7_DTINIS)
									CB7->CB7_DTINIS := Date()
									CB7->CB7_HRINIS := StrTran(Time(),":","")
									CB7->CB7_STATUS := "1"
									CB7->CB7_CODOP2 := _cCodConf
									CB7->CB7_NOMOP2 := _cNomConf
								EndIf
							CB7->(MSUNLOCK())
						EndIf
					EndIf
				EndIf
			EndIf
			If _lRet
				cMultiGe1 := CB7->CB7_OBS1
				If !Empty(CB7->CB7_PEDIDO)
					_cPedVen := CB7->CB7_PEDIDO
				EndIf
			EndIf
		EndIf
		_aPv := {}
		If !Empty(_cOrdSep) .AND. ((_lRet .AND. Empty(_cPedVen)) .OR. _lAtuEnd)
			dbSelectArea("CB8")
			CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
			If CB8->(MsSeek(xFilial("CB8") + _cOrdSep,.T.,.F.))
				_aRecSF2 := {}
				_nVol1   := 0
				_cDANFE  := ""
				_cPedVen := CB8->CB8_PEDIDO
				_aSvCB8  := CB8->(GetArea())
				While !CB8->(EOF()) .AND. CB8->CB8_FILIAL == xFilial("CB8") .AND. CB8->CB8_ORDSEP == _cOrdSep
					If !Empty(CB8->CB8_PEDIDO)
						If aScan(_aPv,CB8->CB8_PEDIDO)==0
							dbSelectArea("SC5")
							SC5->(dbSetOrder(1))
							If SC5->(MsSeek(xFilial("SC5") + CB8->CB8_PEDIDO,.T.,.F.))
								AADD(_aPv,CB8->CB8_PEDIDO)
								_nSqVol := 1
								While _nSqVol <> 0
									_nSqVol++
									If SC5->(FieldPos("C5_VOLUME"+cValToChar(_nSqVol)))>0
										_nVol1 += FieldGet(FieldPos("C5_VOLUME"+cValToChar(_nSqVol)))
									Else
										_nSqVol := 0
									EndIf
								EndDo
								If _lAtuEnd
									if Select(_cSF2TMP) > 0
										(_cSF2TMP)->(dbCloseArea())
									endif
									BeginSql Alias _cSF2TMP
										SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, MAX(SF2.R_E_C_N_O_) RECSF2
										FROM %table:SF2% SF2 (NOLOCK)
												INNER JOIN %table:SD2% SD2 (NOLOCK) ON SD2.D2_FILIAL  = %xFilial:SD2%
																				   AND SD2.D2_PEDIDO  = %Exp:SC5->C5_NUM%
																				   AND SF2.F2_DOC     = SD2.D2_DOC
																				   AND SF2.F2_SERIE   = SD2.D2_SERIE
																				   AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
																				   AND SF2.F2_LOJA    = SD2.D2_LOJA
																				   AND SD2.%NotDel%
										WHERE SF2.F2_FILIAL = %xFilial:SF2%
										  AND SF2.F2_ENDEXP = %Exp:''%
										  AND SF2.%NotDel%
										GROUP BY F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA
									EndSql
									//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",GetLastQuery()[02])
									dbSelectArea(_cSF2TMP)
									If !(_cSF2TMP)->(EOF()) .AND. (_cSF2TMP)->RECSF2 > 0 .AND. aScan(_aRecSF2,{|x| x[01]==(_cSF2TMP)->RECSF2}) == 0
										While !(_cSF2TMP)->(EOF()) .AND. (_cSF2TMP)->RECSF2 > 0
											AADD(_aRecSF2,{(_cSF2TMP)->RECSF2,(_cSF2TMP)->F2_SERIE + " " + (_cSF2TMP)->F2_DOC})
											(_cSF2TMP)->(dbSkip())
										EndDo
									EndIf
									if Select(_cSF2TMP) > 0
										(_cSF2TMP)->(dbCloseArea())
									endif
								EndIf
							EndIf
						EndIf
					EndIf
					dbSelectArea("CB8")
					CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
					CB8->(dbSkip())
				EndDo
				If Len(_aRecSF2) > 0
					If _nTpVal == 2 .AND. IIF(AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166", MsgYesNo("Ordem de Separa็ใo faturada com Sucesso! Deseja informar o endere็o de expedi็ใo neste momento?",_cRotina+"_027"), VtYesNo("Ordem de Separa็ใo faturada com Sucesso! Deseja informar o endere็o de expedi็ใo neste momento?","Aviso",.T.))  //MsgYesNo("Ordem de Separa็ใo jแ faturada. Deseja informar o endere็o de expedi็ใo neste momento?",_cRotina+"_027")
						_cEndExp := EndExp()
					Else
						_cEndExp := ""
					EndIf
					If !Empty(_cEndExp)
						_cDANFE  := ""
						_cQry    := " UPDATE " + RetSqlName("SF2")
						_cQry    += " SET F2_ENDEXP = '" + _cEndExp + "' "
						_cQry    += " WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND R_E_C_N_O_ IN ('"
						for _xF2 := 1 to len(_aRecSF2)
							dbSelectArea("SF2")
							SF2->(dbSetOrder(1))
							SF2->(dbGoTo(_aRecSF2[_xF2][01]))
							If Empty(SF2->F2_ENDEXP)
								If !Empty(_cDANFE)
									_cDANFE += "', '"
								EndIf
								_cDANFE += cValToChar(_aRecSF2[_xF2][01])
							Else
								If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
									MsgAlert("Endere็o de expedi็ใo jแ preenchido para a nota fiscal/s้rie '" + SF2->F2_DOC + "/" + SF2->F2_SERIE + "'!",_cRotina+"_055")
								Else 
									VtAlert("Endere็o de expedi็ใo jแ preenchido para a nota fiscal/s้rie '" + SF2->F2_DOC + "/" + SF2->F2_SERIE + "'!","Aviso",.T.)
								EndIf
							EndIf
						next
						_cQry   += _cDANFE + "')"
					//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cQry)
						If TCSQLExec(_cQry) < 0
							MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_022")
							MsgAlert("Processo interrompido por erro!",_cRotina+"_026")
						Else
							dbSelectArea("CB7")
							CB7->(dbSetOrder(1))
							If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
								while !RecLock("CB7",.F.) ; enddo
								CB7->CB7_DTFIN  := Date()
								CB7->CB7_HRFIN  := Left(Time(),5)
								CB7->CB7_STATUS := "8"
								CB7->(MSUNLOCK())							
							EndIf
						EndIf
						dbSelectArea("SF2")
						TcRefresh("SF2")
				Else
						MsgStop("Endere็o de expedi็ใo nใo informado! Nใo serแ possํvel imprimir a DANFE ap๓s a sua autoriza็ใo!",_cRotina+"_024")
					EndIf
					If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
						cMultiGe1 := ""
						_nTamCBar := 30
						lCont	  := .T.
						_cRotina  := "RFATA002"
						_cNumOrd  := Space(len(CB7->CB7_ORDSEP))
						_cOrdSep  := Space(len(CB7->CB7_ORDSEP))
						_cPedVen  := Space(len(CB7->CB7_PEDIDO))
						_cCli     := Space(50)
						_cNumCont := StrZero(1,len(CBG->CBG_CODCON))
						_nPLiq    := 0
						_nPBrut   := 0
						_nQLida   := 0
						_nQtConf  := 1
						_nVol1    := 1
						_cEspec   := Padr("VOLUME(S)",len(SC5->C5_ESPECI1))
						_cCodBar  := Space(_nTamCBar)
						_cCodConf := __cUserId
						_cNomConf := "USER - " + cUserName
						cMultiGe1 := ""
						cMultiGe2 := ""
						_cErro1   := "$$ PROD. #@#@#@#@# NรO ENCONTRADO!$$"
						_cErro2   := "$$ PROD. #@#@#@#@# NรO PERTENCE A ESTA SEPAR.!$$"
						_cErro3   := "$$ QTDE. DIVERG. P/ PRODUTO #@#@#@#@#!$$"
						cCadastro := "* * *  E X P E D I ว ร O  * * *"
						_cNota    := ""
						_cSerie   := ""
						_nItNF    := 0
						_nPProd   := 0
						_nPDesc   := 0
						_nPQtde   := 0
						_nPLote   := 0
						_nPEnd    := 0
						_nPVol1   := 0
						_nPObs    := 0
						_nPObsCnf := 0
						_nPArm    := 0
						_nPDt     := 0
						_nPHr     := 0
						_nHandle  := 0
						_nHdlCB   := 0
						_lVisual  := .F.
						_lAlter   := .F.
						_lPesVol  := .F.
						_lGerouNF := .F.
						_lHabPLis := GetMV("MV_PLCONF") //SuperGetMV("MV_PLCONF",,.F.)		//Habilita o tratamento dos itens por volume para o Packing List?
						aFieldFill:= {}
						_nPsBrut  := 0
						_nPLiqu   := 0
						_cNotaAux := ""
						_cRoman	  := ""
						_lRet     := .F.
						_cOrdSep  := Space(len(CB7->CB7_ORDSEP))
						_cPedVen  := Space(len(SC5->C5_NUM    ))
					EndIf
				EndIf
				RestArea(_aSvCB8)
				If _nVol1 == 0
					_nVol1 := 1
				EndIf
			Else
				MsgStop("Itens da Ordens de Separa็ใo " + _cOrdSep + " nใo encontrados!",_cRotina+"_021")
				_lRet    := .F.
				_cOrdSep := Space(len(CB7->CB7_ORDSEP))
				_cPedVen := Space(len(SC5->C5_NUM    ))
			EndIf
		EndIf
		If _lRet .AND. !Empty(_cPedVen) .AND. AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
			If ExistCpo("SC5",_cPedVen,1)
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				If SC5->(MsSeek(xFilial("SC5") + _cPedVen,.T.,.F.))
					If AllTrim(SC5->C5_TIPO) $ "D/B"
						dbSelectArea("SA2")
						SA2->(dbSetOrder(1))
						If SA2->(MsSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
							_cCli := SA2->A2_COD + " " + SA2->A2_LOJA + " - " + SA2->A2_NOME
						EndIf
					Else
						dbSelectArea("SA1")
						SA1->(dbSetOrder(1))
						If SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
							_cCli := SA1->A1_COD + " " + SA1->A1_LOJA + " - " + SA1->A1_NOME
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If _lRet .AND. Empty(_cCli) .AND. AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1") + CB7->CB7_CLIENT + CB7->CB7_LOJA,.T.,.F.))
				_cCli := SA1->A1_COD + " " + SA1->A1_LOJA + " - " + SA1->A1_NOME
			Else
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA2") + CB7->CB7_CLIENT + CB7->CB7_LOJA,.T.,.F.))
					_cCli := SA2->A2_COD + " " + SA2->A1_LOJA + " - " + SA2->A2_NOME
				EndIf
			EndIf
		EndIf
		// - INCLUIDO POR JฺLIO SOARES PARA VALIDAR O SEPARADOR
		If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"		
			If _cSepWindBRW == 1 .And. !Empty(_cOrdSep)
		//		Sepbrowse()  //Comentado conforme solicita็ใo do Sr. Ronie, para valida็ใo do processo de separa็ใo antes do processo de confer๊ncia
				_cSepWindBRW++
			EndIf
		EndIf
	EndIf
	//TRECHO DESATIVADO EM 08.01.2013, CONFORME SOLICITAวรO DO SR. MARCO ANTONIO
	
	If !_lAcdRet  .AND. _nTpVal <> 2 .AND. ((_lRet .OR. _lVisual) .AND. !Empty(_cOrdSep))
		
		/*_cQry := " SELECT DISTINCT CB9_PROD PRODUTO, B1_DESC DESCRI, CB9_QTESEP QUANT, CB9_LOCAL ARM, CB9_LOTECT LOTE, CB9_LCALIZ ENDERECO, CB9_VOLUME VOLUME, CBG_OBS OBS, CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CBG_OBSCNF)) OBSCNF, CBG_DATA DTCONF, CBG_HORA HRCONF, CB9_PEDIDO PEDIDO "
		_cQry += " FROM " + RetSqlName("CB9") + " CB9, "
		_cQry +=            RetSqlName("CBG") + " CBG, "
		_cQry +=            RetSqlName("SB1") + " SB1, "
		_cQry += " 				( "
		_cQry += "					SELECT CBG_FILIAL FILIAL, CBG_EVENTO EVENTO, CBG_ORDSEP SEP, CBG_CLI CLI, CBG_LOJCLI LJ, CBG_CODPRO PROD, CBG_VOLUME VOL, MAX(CBG_DATA+CBG_HORA) DTRH "
		_cQry += "					FROM " + RetSqlName("CBG") + " CBGX "
		_cQry += "					WHERE CBGX.D_E_L_E_T_  = ''  "
		_cQry += "					  AND CBGX.CBG_FILIAL  = '" + xFilial("CBG") + "' "
		_cQry += "					  AND CBGX.CBG_EVENTO  = '09' "
		_cQry += "					  AND CBGX.CBG_ORDSEP  = '" + _cOrdSep + "' "
		_cQry += "					GROUP BY CBG_FILIAL, CBG_EVENTO, CBG_ORDSEP, CBG_CLI, CBG_LOJCLI, CBG_VOLUME, CBG_CODPRO "
		_cQry += "				 ) XXX "
		_cQry += "WHERE CBG.D_E_L_E_T_              = '' "
		_cQry += "  AND CB9.D_E_L_E_T_              = '' "
		_cQry += "  AND CB9.CB9_FILIAL              = '" + xFilial("CB9") + "' "
		_cQry += "  AND SB1.D_E_L_E_T_              = '' "
		_cQry += "  AND SB1.B1_FILIAL               = '" + xFilial("SB1") + "' "
		_cQry += "  AND SB1.B1_MSBLQL              <> '1' "
		_cQry += "  AND CBG.CBG_CODPRO              = SB1.B1_COD "
		_cQry += "  AND CBG.CBG_FILIAL              = XXX.FILIAL "
		_cQry += "  AND CBG.CBG_EVENTO              = XXX.EVENTO "
		_cQry += "  AND CBG.CBG_ORDSEP              = XXX.SEP "
		_cQry += "  AND CBG.CBG_CLI                 = XXX.CLI "
		_cQry += "  AND CBG.CBG_LOJCLI              = XXX.LJ "
		_cQry += "  AND CBG.CBG_CODPRO              = XXX.PROD "
		_cQry += "  AND (CBG.CBG_DATA+CBG.CBG_HORA) = XXX.DTRH "
		_cQry += "  AND CB9.CB9_ORDSEP              = CBG.CBG_ORDSEP "
		_cQry += "  AND CB9.CB9_VOLUME              = CBG.CBG_VOLUME "
		_cQry += "  AND CB9.CB9_PROD                = CBG.CBG_CODPRO "
		_cQry += "  AND CB9.CB9_LOCAL               = CBG.CBG_ARM "
		_cQry += "  AND CB9.CB9_LOTECT              = CBG.CBG_LOTE "
		_cQry += "  AND CB9.CB9_NUMLOT              = CBG.CBG_SLOTE "
		_cQry += "  AND CB9.CB9_LCALIZ              = CBG.CBG_END "
		_cQry += "ORDER BY CB9_VOLUME, CB9_PROD, CB9_LOCAL, CB9_LOTECT, CB9_LCALIZ, CB9_PEDIDO "
		_cQry := ChangeQuery(_cQry)
		*/

		_cQry := " SELECT DISTINCT CB8_ITEM ITEM, CB8_PROD PRODUTO, B1_DESC DESCRI, CB8_QTDORI QUANT, CB8_LOCAL ARM, CB8_LOTECT LOTE, CB8_LCALIZ ENDERECO, 0 VOLUME, CB8_OBSERV OBS, CONVERT(VARCHAR(8000),CONVERT(BINARY(8000),CB8_OBSERV)) OBSCNF, CB7_DTINIS DTCONF, CB7_HRINIS HRCONF, CB8_PEDIDO PEDIDO "
		_cQry += " FROM " + RetSqlName("CB8") + " CB8, "
		_cQry +=            RetSqlName("SB1") + " SB1, "
		_cQry +=            RetSqlName("CB7") + " CB7, "
		_cQry += "WHERE CB7.D_E_L_E_T_              = '' "
		_cQry += "  AND CB8.D_E_L_E_T_              = '' "
		_cQry += "  AND CB7.CB7_FILIAL              = '" + xFilial("CB7") + "' "
		_cQry += "  AND CB8.CB8_FILIAL              = '" + xFilial("CB8") + "' "
		_cQry += "  AND SB1.D_E_L_E_T_              = '' "
		_cQry += "  AND SB1.B1_FILIAL               = '" + xFilial("SB1") + "' "
		_cQry += "  AND SB1.B1_MSBLQL               <> '1' "
		_cQry += "  AND CB8.CB8_ORDSEP              = '" + _cOrdSep + "' "
		_cQry += "  AND CB8.CB8_PROD                = SB1.B1_COD "
		//**********************************************************************
		// INICIO
		// ARCOLOR - Adequa็ใo para preenchimento do grid para faturamento de
		// itens atrelados ao armaz้m "VC" (especifico processo consignado)
		// RODRIGO TELECIO em 12/01/2024
		//**********************************************************************
		if SC5->C5_NUM == _cPedVen
			if AllTrim(SC5->C5_TPOPER) $ cTpOper
				_cQry 	+= "	AND CB8.CB8_LOCAL IN " + FormatIn(cTpOper,"|") + " "
			else
				_cQry 	+= "	AND CB8.CB8_LOCAL = SB1.B1_LOCPAD"
			endif
		else
			_cQry 	+= "	AND CB8.CB8_LOCAL = SB1.B1_LOCPAD"
		endif
		// FIM
		//**********************************************************************
		_cQry += "  AND CB7_ORDSEP				    = CB8.CB8_ORDSEP"
		//_cQry += "ORDER BY CB8_PROD, CB8_LOCAL, CB8_LOTECT, CB8_LCALIZ, CB8_PEDIDO "
		//_cQry += "ORDER BY CB8_PEDIDO,CB8_LCALIZ,CB8_PROD "
		_cQry += "ORDER BY CB8_PEDIDO, CB8_ITEM, CB8_LOCAL, CB8_LOTECT, CB8_LCALIZ "
		_cQry := ChangeQuery(_cQry)

	//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_003",_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"TABCONF",.F.,.T.)
		dbSelectArea("TABCONF")
		If !TABCONF->(EOF())
			While !TABCONF->(EOF())
				If !Empty(oMSNewGe1:aCols[01][_nPProd])
					AADD(oMSNewGe1:aCols,ARRAY(Len(oMSNewGe1:aHeader)+1))
				EndIf
				_nLnProd := Len(oMSNewGe1:aCols)
				oMSNewGe1:aCols[_nLnProd][Len(oMSNewGe1:aHeader)+1] := .F.
				oMSNewGe1:aCols[_nLnProd][_nPProd  ]                := TABCONF->PRODUTO
				oMSNewGe1:aCols[_nLnProd][_nPDesc  ]                := TABCONF->DESCRI
				oMSNewGe1:aCols[_nLnProd][_nPQtde  ]                := TABCONF->QUANT
				oMSNewGe1:aCols[_nLnProd][_nPArm   ]                := TABCONF->ARM
				oMSNewGe1:aCols[_nLnProd][_nPLote  ]                := TABCONF->LOTE
				oMSNewGe1:aCols[_nLnProd][_nPEnd   ]                := TABCONF->ENDERECO
				oMSNewGe1:aCols[_nLnProd][_nPDt    ]                := STOD(TABCONF->DTCONF)
				oMSNewGe1:aCols[_nLnProd][_nPHr    ]                := Transform(StrTran(TABCONF->HRCONF,":",""),"99:99:99")
				oMSNewGe1:aCols[_nLnProd][_nPObsCnf]                := TABCONF->OBSCNF
				oMSNewGe1:aCols[_nLnProd][_nPObs   ]                := IIF("SUCESSO!"$TABCONF->OBS,"OK!",TABCONF->OBS)
				oMSNewGe1:aCols[_nLnProd][_nPVol1  ]                := IIF(_lHabPLis,IIF(ValType(TABCONF->VOLUME)=="C",VAL(TABCONF->VOLUME),TABCONF->VOLUME),1)
				dbSelectArea("TABCONF")
				TABCONF->(dbSkip())
			EndDo
			oMSNewGe1:Refresh()
			oMSNewGe1:oBrowse:blDblClick := { ||oMSNewGe1:EditCell() }
			/*dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1") + oMSNewGe1:aCols[_nLnProd][_nPProd  ] ,.T.,.F.))
				oMSNewGe1:aCols[_nLnProd][_nPDesc  ]                := SB1->B1_DESC
			EndIf
			*/
			_lAlter   := .T.
		EndIf
		dbSelectArea("TABCONF")
		TABCONF->(dbCloseArea())
	EndIf
	
	If _lVisual
		_lRet := _lVisual
	EndIf
	RestArea(_aSCB1)
	RestArea(_aSCB7)
	RestArea(_aSCB8)
	RestArea(_aSCB9)
	RestArea(_aSCBG)
	RestArea(_aSSA1)
	RestArea(_aSSA2)
//	RestArea(_aSSX3)
	RestArea(_aArea)
return _lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidVol  บAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de valida็ใo do Volume informado na confer๊ncia.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ValidVol()

Local _aArea  := GetArea()
Local _lRet   := IIF(ValType(_nVol1)=="N",POSITIVO(_nVol1),.F.) //Valida็ใo ValType adicionada por Adriano Leonardo em 03/09/2013 - para melhoria na rotina
Local _lPulou := .F.                   
Local _aColBk := aClone(oMSNewGe1:aCols)
Local _cCarac := IIF(type("_nGetVol")=="N",cValtoChar(_nGetVol),cValtoChar(_nVol1))
Local _cValVo := Len(_cCarac)
Local _x      := 0

If type("_nGetVol")=="U"
	private _nGetVol := 0
EndIf
//Trecho adicionado por Adriano Leonardo em 03/09/2013 - para melhoria na rotina
	If ValType(_nVol1)<>"N"
		MsgStop("O volume deve ser conte๚do n๚merico!",_cRotina+"_002.1")
	ElseIf _cValVo > 4
		MsgStop("O volume informado:" +_cCarac+ " passa do limite permitido nesse campo, informe o volume corretamente(No mแximo 4 digitos)!",_cRotina+"_002.1")
		_lRet := .f.
	EndIf
//Final do trecho adicionado por Adriano Leonardo em 03/09/2013
If _lRet .AND. Len(_aColBk) > 0
	If !( _lRet := (_nVol1 > 0 .Or. _nGetVol>0))
		MsgStop("Informa็ใo de volume obrigat๓ria!",_cRotina+"_002.2")
	Else
		//Reorganiza็ใo do clone do aCols, por volume, em ordem decrescente
		_aColBk := aSort( _aColBk, , , { |x,y| x[_nPVol1] >= y[_nPVol1] } )
		If _lHabPLis
			for _x := 1 To _aColBk[01][_nPVol1]
				If _aColBk[01][_nPVol1] > 1
					If _lPulou := (aScan(_aColBk,{|x| x[_nPVol1] == _x}) == 0)
						Exit
					EndIf
				EndIf
			next
			If !(_lRet := !_lPulou)
				MsgAlert("Aten็ใo!!! Voc๊ pulou a sequencia de volumes conferidos. Opera็ใo nใo permitida!",_cRotina+"_040")
			EndIf
		EndIf
		If _lHabPLis .AND. _lRet
			If !(_lRet := (_nVol1 == (_aColBk[01][_nPVol1])) .OR. (_nVol1 == (_aColBk[01][_nPVol1]+1)))
				_lRet  := MsgYesNo("O informado nใo ้ sequencia do maior volume conferido, para a continuidade da confer๊ncia. Confirma esta opera็ใo?",_cRotina+"_003")
			EndIf
		EndIf
	EndIf
EndIf

If _lRet
	_lSolicVol := .F.
EndIf

RestArea(_aArea)

return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRFATA02D  บAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de valida็ใo de dele็ใo dos itens da GetDados.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function RFATA02D()
	Local _aArea  := GetArea()
	Local _aColBk := aClone(oMSNewGe1:aCols)
	Local _lRet   := .F.
	Local _x      := 0

	//Em 28.03.2013 o conceito de acerto foi alterado. O acerto nใo mais zerarแ a quantidade do item, deixando o item visualmente ativo em tela. Ao contrแrio, ele gravarแ todos os registros na tabela CBG e para efeito de controle e apagarแ o registro da tela.
	//If oMSNewGe1:aCols[n][_nPQtde] > 0
		If MsgYesNo("Tem certeza de que deseja eliminar este item da confer๊ncia (Produto " + AllTrim(oMSNewGe1:aCols[n][_nPProd]) + " - " + AllTrim(oMSNewGe1:aCols[n][_nPDesc]) + ")?",_cRotina+"_004")
	//	If MsgYesNo("Tem certeza de que deseja zerar a quantidade na confer๊ncia para este item (Produto " + AllTrim(oMSNewGe1:aCols[n][_nPProd]) + " - " + AllTrim(oMSNewGe1:aCols[n][_nPDesc]) + ")?",_cRotina+"_004")
			/*
			oMSNewGe1:aCols[n][_nPQtde]    := 0
			oMSNewGe1:aCols[n][_nPObs ]    := StrTran(oMSNewGe1:aCols[n][_nPObs],"OK!","")
			oMSNewGe1:aCols[n][_nPObs ]    := StrTran(oMSNewGe1:aCols[n][_nPObs],AllTrim(StrTran(StrTran(_cErro3,"#@#@#@#@#",AllTrim(oMSNewGe1:aCols[n][_nPProd])),"$","")),"")
			While Space(02)$oMSNewGe1:aCols[n][_nPObs] .OR. "//"$oMSNewGe1:aCols[n][_nPObs] .OR. "/ /"$oMSNewGe1:aCols[n][_nPObs]
				oMSNewGe1:aCols[n][_nPObs] := StrTran(oMSNewGe1:aCols[n][_nPObs],Space(02),Space(01))
				oMSNewGe1:aCols[n][_nPObs] := StrTran(oMSNewGe1:aCols[n][_nPObs],"//"     ," / "    )
				oMSNewGe1:aCols[n][_nPObs] := StrTran(oMSNewGe1:aCols[n][_nPObs],"/ /"    ," / "    )
			EndDo
			If AllTrim(oMSNewGe1:aCols[n][_nPObs]) == "/"
				oMSNewGe1:aCols[n][_nPObs] := ""
			EndIf
			If SubStr(oMSNewGe1:aCols[n][_nPObs],1,2) == " /"
				oMSNewGe1:aCols[n][_nPObs] := SubStr(oMSNewGe1:aCols[n][_nPObs],3)
			EndIf
			If SubStr(oMSNewGe1:aCols[n][_nPObs],1,1) == "/"
				oMSNewGe1:aCols[n][_nPObs] := SubStr(oMSNewGe1:aCols[n][_nPObs],2)
			EndIf
			oMSNewGe1:aCols[n][_nPObs] := AllTrim(oMSNewGe1:aCols[n][_nPObs])
			*/
			oDlg:SetFocus(_nHdlCB)
			_lAlter   := .T.
			_dData    := Date()
			_cHora    := Time()
			//N๚mero da contagem
			_cNumCont := StrZero(1,len(CBG->CBG_CODCON))
			BeginSql Alias "NUMCONT"
				SELECT MAX(CBG_CODCON) CBG_CODCON
				FROM %table:CBG% CBG (NOLOCK)
				WHERE CBG.CBG_FILIAL = %xFilial:CBG%
				  AND CBG.CBG_ORDSEP = %Exp:_cOrdSep%
				  AND CBG.%NotDel%
			EndSql
	//		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_004.TXT",GetLastQuery()[02])
			dbSelectArea("NUMCONT")
			If !NUMCONT->(EOF())
				_cNumCont := StrZero(VAL(NUMCONT->CBG_CODCON)+1,len(CBG->CBG_CODCON))
			EndIf
			NUMCONT->(dbCloseArea())
			for _x := 1 to len(_aColBk)
				//Os logs de confer๊ncia sใo sempre gravados, em quaisquer situa็๕es!
				dbSelectArea("CBG")
				CBG->(dbSetOrder(1))
				while !RecLock("CBG",.T.) ; enddo
					CBG->CBG_FILIAL := xFilial("CBG")
					CBG->CBG_CODCON := _cNumCont
					CBG->CBG_DATA   := _dData				//_aColBk[_x][_nPDt  ]
					CBG->CBG_HORA   := _cHora				//_aColBk[_x][_nPHr  ]
					CBG->CBG_EVENTO := "09"					//Expedi็ใo
					CBG->CBG_USUARI := __cUserId
					CBG->CBG_CODOPE := _cCodConf
					CBG->CBG_CODPRO := _aColBk[_x][_nPProd]
					CBG->CBG_QTDE   := _aColBk[_x][_nPQtde]
					CBG->CBG_LOTE   := _aColBk[_x][_nPLote]
		//			CBG->CBG_SLOTE  := 
					CBG->CBG_ARM    := _aColBk[_x][_nPArm ]
					CBG->CBG_END    := _aColBk[_x][_nPEnd ]
		//			CBG->CBG_ARMDES := 
		//			CBG->CBG_NUMSEQ := 
		//			CBG->CBG_DOC    := 
		//			CBG->CBG_CODETI := 
		//			CBG->CBG_CODINV := 
		//			CBG->CBG_NOTAE  := 
		//			CBG->CBG_SERIEE := 
		//			CBG->CBG_FORN   := 
		//			CBG->CBG_LOJfor := 
		//			CBG->CBG_OP     := 
		//			CBG->CBG_TM     := 
		//			CBG->CBG_NOTAS  := 
		//			CBG->CBG_SERIES := 
					CBG->CBG_CLI    := SubStr(_cCli,1                 ,len(SA1->A1_COD ))										//_cCli := SA1->A1_COD + " " + SA1->A1_LOJA + " - " + SA1->A1_NOME
					CBG->CBG_LOJCLI := SubStr(_cCli,len(SA1->A1_COD)+2,len(SA1->A1_LOJA))
					CBG->CBG_ORDSEP := _cOrdSep
		//			CBG->CBG_ETIAUX := 
					CBG->CBG_VOLUME := cValToChar(_aColBk[_x][_nPVol1])
		//			CBG->CBG_SUBVOL := 
		//			CBG->CBG_ENDDES := 
					If _x == n
						CBG->CBG_OBS    := "ITEM EXCLUIDO DA CONFERENCIA! / " + AllTrim(_aColBk[_x][_nPObs])
						CBG->CBG_OBSCNF := "ITEM EXCLUIDO DA CONFERENCIA!"    + _CRLF + AllTrim(StrTran(StrTran(_aColBk[_x][_nPObsCnf]," $$$ ",_CRLF),"$","")) + _CRLF
						_aColBk[_x][Len(aHeader)+1] := .T.
					Else
						CBG->CBG_OBS    := AllTrim(_aColBk[_x][_nPObs])
						CBG->CBG_OBSCNF := AllTrim(StrTran(StrTran(_aColBk[_x][_nPObsCnf]," $$$ ",_CRLF),"$","")) + _CRLF
					EndIf
				CBG->(MSUNLOCK())
			next
			oMSNewGe1:aCols := {}
			for _x := 1 to len(_aColBk)
				If !_aColBk[_x][Len(aHeader)+1]
					AADD(oMSNewGe1:aCols,aClone(_aColBk[_x]))
				EndIf
				If _aColBk[_x][Len(aHeader)+1]
					dbSelectArea("CB8")
					CB8->(dbOrderNickName("CB8_PROD")) 	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
					If CB8->(MsSeek(xFilial("CB8") + _cOrdSep + _aColBk[_x][_nPProd]+_aColBk[_x][_nPLote]+_aColBk[_x][_nPEnd],.T.,.F.))
						RecLock("CB8", .F.)
							dbDelete()
						MsUnlock()  
					Endif	
				EndIf
			next
			If Len(oMSNewGe1:aCols) == 0
				Aadd(oMSNewGe1:aCols, aClone(aFieldFill))
			EndIf
			aCols   := aClone(oMSNewGe1:aCols)
			_aColBk := {}
		EndIf
	/*Else
		MsgAlert("Item com a quantidade jแ zerada!",_cRotina+"_005")
	EndIf*/
	oMSNewGe1:Refresh()
	RestArea(_aArea)
return _lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณSelQtde   บAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem da tela para a selecao da quantidade para a       บฑฑ
ฑฑบ          ณproxima leitura.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function SelQtde()

Local oGetb1
Local oGroupb1
Local oSayb1
Local oSButtonb1

_nHandle := GetFocus()
_nQtConf := 1

If !lCont
	return()
Else 
	lCont := .F.
EndIf            

static oDlgb

  DEFINE MSDIALOG oDlgb TITLE "EXPEDIวรO"          FROM 000, 000 TO 130, 240                                             COLORS 0, 16777215 PIXEL

    @ 007, 003 GROUP oGroupb1 TO 058, 116 PROMPT " Informe a quantidade para a proxima leitura "                OF oDlgb COLOR  0, 16777215 PIXEL
    @ 021, 010   SAY   oSayb1 PROMPT "Quantidade:" SIZE 037, 007 OF oDlgb                                                COLORS 0, 16777215 PIXEL
    @ 019, 045 MSGET   oGetb1    VAR _nQtConf      SIZE 060, 010 OF oDlgb PICTURE "@E 999,999,999.99" VALID Positivo()   COLORS 0, 16777215 PIXEL

    DEFINE SBUTTON oSButtonb1 FROM 039, 048 TYPE 01 OF oDlgb ENABLE ACTION (Close(oDlgb) .AND. Controle())

  ACTIVATE MSDIALOG oDlgb CENTERED

oDlg:SetFocus(_nHandle)

return

static function Controle()
	lCont := .T.
return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณEndExp    บAutor  ณAnderson C. P. Coelho บ Data ณ  11/01/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem da tela para a informa็ใo do endere็o de expedi็ใoบฑฑ
ฑฑบ          ณa ser impresso nos DANFES especํficos                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function EndExp()

Local oGetc1
Local oGroupc1
Local oSayc1
Local oSButtonc1

Private _cGetEnd  := Space(len(SF2->F2_ENDEXP))
Private _lOkEnd	  := .T.

If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
	static oDlgc
	
	  DEFINE MSDIALOG oDlgc TITLE "EXPEDIวรO"          FROM 000, 000 TO 130, 240                                             COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
		oDlgc:lEscClose := .F.
	
	    @ 007, 003 GROUP oGroupc1 TO 058, 116 PROMPT " Informe o endere็o dos volumes " OF oDlgc                             COLOR  0, 16777215 PIXEL
	    @ 021, 005   SAY   oSayc1 PROMPT "Endere็o:"   SIZE 037, 007 OF oDlgc                                                COLORS 0, 16777215 PIXEL
	    @ 019, 045 MSGET   oGetc1    VAR _cGetEnd      SIZE 070, 010 OF oDlgc PICTURE "@!"             VALID NAOVAZIO()      COLORS 0, 16777215 PIXEL
	
	    DEFINE SBUTTON oSButtonc1 FROM 039, 048 TYPE 01 OF oDlgc ENABLE ACTION IIF(MsgYesNo("Confirma a inser็ใo do endere็o " + AllTrim(_cGetEnd) + " de expedi็ใo para o processo corrente?",_cRotina+"_025"),Close(oDlgc),NIL)
	
	  ACTIVATE MSDIALOG oDlgc CENTERED
	  
	  _lSolicVol := .T. //Linha adicionada por Adriano Leonardo em 20/12/2013 para melhoria na rotina, variแvel utilizada para que o volume seja solicitado novamente caso seja conferida mais de uma ordem sequencialmente pelo botใo Gera NF
Else
	While _lOkEnd
		VTCLEAR()
		@ 0,00 VTSAY "Informe o endereco dos volumes"
		@ 1,00 VTSAY "--------------------"
		@ 3,00 VTSAY "Endere็o:" VTGET _cGetEnd             Pict "@!"		VALID VldEnd(_cGetEnd)
		VTREAD()
		
		If VTLastKey() == 27 .AND. Empty(_cGetEnd) .AND. _lOkEnd
			VTAlert("Endere็o nใo pode ser em branco, Informe o Endere็o!","Aviso",.T.)
		EndIf
	EndDo
EndIf
	
return(_cGetEnd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLeitura   บAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de processamento das leituras.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function Leitura()

Local _aSavArL  := GetArea()
Local _aSavCB8  := CB8->(GetArea())
//Local _aSavSB1  := SB1->(GetArea())
Local _lAchou   := .F.
Local _cErroPrd := ""
Local _cCodProd := ""
Local _q        := 0
Local _x        := 0

If !Empty(_cCodBar)
	dbSelectArea("SB1")
	SB1->(dbOrderNickName("B1_CODBAR"))				//B1_FILIAL + B1_CODBAR
	_lAchou := SB1->(MsSeek(xFilial("SB1") + Padr(_cCodBar,len(SB1->B1_CODBAR)),.T.,.F.))
	//QTDE. NA UNIDADE DO CำDIGO DE BARRAS 1 [EAN13]
	If _lAchou .AND. Type("SB1->B1_VOPRIN")=="N" .AND. SB1->B1_VOPRIN > 0
		_nQtConf := Round(_nQtConf * SB1->B1_VOPRIN,TamSx3("CB9_QTESEP")[02])
	EndIf
	If !_lAchou
		dbSelectArea("SB1")
		SB1->(dbOrderNickName("B1_CODBAR2"))		//B1_FILIAL + B1_CODBAR2
		_lAchou := SB1->(MsSeek(xFilial("SB1") + Padr(_cCodBar,len(SB1->B1_CODBAR2)),.T.,.F.))
		//QTDE. NA UNIDADE DO CำDIGO DE BARRAS 2 [DUM14]
		If _lAchou .AND. Type("SB1->B1_VOSEC")=="N" .AND. SB1->B1_VOSEC > 0
			_nQtConf := Round(_nQtConf * SB1->B1_VOSEC,TamSx3("CB9_QTESEP")[02])
		EndIf
	EndIf
	If !_lAchou
		If !AllTrim(StrTran(StrTran(_cErro1,"#@#@#@#@#",AllTrim(_cCodBar)),"$","")) $ (cMultiGe2+" "+_cErroPrd)
			If !Empty(_cErroPrd)
				_cErroPrd += " $$$ "
			EndIf
			_cErroPrd     += AllTrim(StrTran(_cErro1,"#@#@#@#@#",AllTrim(_cCodBar)))
		EndIf
	EndIf
	If .T.		//Condicional "Else" (relativo ao If !_lAchou), selecionado
		If _lAchou .AND. !Empty(SB1->B1_COD)
			_cCodProd := SB1->B1_COD
		Else
			_cCodProd := "#"+_cCodBar
		EndIf
		dbSelectArea("CB8")
		CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
		_lExCB8 := _lAchou .AND. CB8->(MsSeek(xFilial("CB8") + _cOrdSep + SB1->B1_COD,.T.,.F.))
		If !_lExCB8
			If !AllTrim(StrTran(StrTran(_cErro2,"#@#@#@#@#",AllTrim(SB1->B1_COD)+" ("+AllTrim(_cCodBar)+")"),"$","")) $ (cMultiGe2+" "+_cErroPrd)
				If !Empty(_cErroPrd)
					_cErroPrd += " $$$ "
				EndIf
				_cErroPrd     += AllTrim(StrTran(_cErro2,"#@#@#@#@#",AllTrim(_cCodProd)+" ("+AllTrim(_cCodBar)+")"))
			EndIf
		EndIf
		If !Empty(_cErroPrd) .AND. !_cErroPrd $ cMultiGe2
			If Empty(cMultiGe2)
				cMultiGe2     += "$$"
			EndIf
			cMultiGe2         += AllTrim(_cErroPrd)
		EndIf
		_nLnProd  := aScan( oMSNewGe1:aCols,{ |x| AllTrim(Padr(x[_nPProd],len(CB8->CB8_PROD  )) + Padr(x[_nPLote],len(CB9->CB9_LOTECT)) + ;
														  cValToChar( x[_nPVol1] ) )           == ;
												  AllTrim(Padr(_cCodProd ,len(CB8->CB8_PROD  )) + ;
	 													  Padr(IIF(!_lExCB8,Space(len(CB8->CB8_LOTECT)),CB8->CB8_LOTECT),len(CB9->CB9_LOTECT)) + ;
	 													  cValToChar( _nVol1     ) ) ;
	 											.AND. !x[Len(oMSNewGe1:aHeader)+1] ;
	 										} )
		If (_nQtConf + IIF(_nLnProd == 0, 0, oMSNewGe1:aCols[_nLnProd][_nPQtde  ])) > VAL(Transform(Replicate("9",len(CBG->CBG_QTDE))+"."+Replicate("9",TamSx3("CBG_QTDE")[02]),PesqPictQt("CBG_QTDE")))
			MsgStop("valor informado irแ estourar o campo de quantidade, favor indicar nova quantidade!",_cRotina+"_061")
		Else		//Condicional "Else" (relativo ao If !_lAchou), selecionado
			If _nLnProd == 0
				If !Empty(oMSNewGe1:aCols[01][_nPProd])
					AADD(oMSNewGe1:aCols,ARRAY(Len(oMSNewGe1:aHeader)+1))
				EndIf
				_nLnProd := Len(oMSNewGe1:aCols)
				oMSNewGe1:aCols[_nLnProd][Len(oMSNewGe1:aHeader)+1] := .F.
				oMSNewGe1:aCols[_nLnProd][_nPProd  ]                := _cCodProd
				oMSNewGe1:aCols[_nLnProd][_nPDesc  ]                := IIF(_lAchou.AND.!Empty(SB1->B1_DESC),SB1->B1_DESC,"SEM DESCRICAO!")
				oMSNewGe1:aCols[_nLnProd][_nPArm   ]                := IIF(!_lExCB8,Space(len(CB8->CB8_LOCAL )),CB8->CB8_LOCAL )
				oMSNewGe1:aCols[_nLnProd][_nPLote  ]                := IIF(!_lExCB8,Space(len(CB8->CB8_LOTECT)),CB8->CB8_LOTECT)
				oMSNewGe1:aCols[_nLnProd][_nPEnd   ]                := IIF(!_lExCB8,Space(len(CB8->CB8_LCALIZ)),CB8->CB8_LCALIZ)
				oMSNewGe1:aCols[_nLnProd][_nPVol1  ]                := IIF(_lHabPLis,_nVol1,1)
				oMSNewGe1:aCols[_nLnProd][_nPDt    ]                := Date()
				oMSNewGe1:aCols[_nLnProd][_nPHr    ]                := Time()
				oMSNewGe1:aCols[_nLnProd][_nPQtde  ]                := _nQtConf		//IIF(!_lExCB8,0,_nQtConf)
			Else
				oMSNewGe1:aCols[_nLnProd][_nPQtde  ]                += _nQtConf		//IIF(!_lExCB8,0,_nQtConf)
			EndIf
		EndIf
		If Len(oMSNewGe1:aCols) > 0
			If _nLnProd > 0 .AND. _nPObs > 0 .AND. Empty(oMSNewGe1:aCols[_nLnProd][_nPObs   ])
				oMSNewGe1:aCols[_nLnProd][_nPObs   ] := ""
			EndIf
			If _nLnProd > 0 .AND. _nPObsCnf > 0 .AND. Empty(oMSNewGe1:aCols[_nLnProd][_nPObsCnf])
				oMSNewGe1:aCols[_nLnProd][_nPObsCnf] := ""
			EndIf
			If !Empty(_cErroPrd)
				If _nLnProd > 0 .AND. _nPObs > 0 .AND. Empty(oMSNewGe1:aCols[_nLnProd][_nPObs   ])
					oMSNewGe1:aCols[_nLnProd][_nPObs       ]            := AllTrim(StrTran(StrTran(StrTran(_cErroPrd," $$$ "," / "),"$$",""),"  "," "))
				EndIf
				If _nLnProd > 0 .AND. _nPObsCnf > 0
					If Empty(oMSNewGe1:aCols[_nLnProd][_nPObsCnf])
		//				oMSNewGe1:aCols[_nLnProd][_nPObsCnf]            := AllTrim(StrTran(StrTran(_cErroPrd," $$$ ",_CRLF),"$","")) + _CRLF
						oMSNewGe1:aCols[_nLnProd][_nPObsCnf]            := AllTrim(StrTran(StrTran(StrTran(StrTran(_cErroPrd," $","$"),"$$$$",_CRLF),"$",""),_CRLF+Space(01),_CRLF)) + _CRLF
					Else
		//				oMSNewGe1:aCols[_nLnProd][_nPObsCnf]            += AllTrim(StrTran(StrTran(_cErroPrd," $$$ ",_CRLF),"$","")) + _CRLF
						oMSNewGe1:aCols[_nLnProd][_nPObsCnf]            += AllTrim(StrTran(StrTran(StrTran(StrTran(_cErroPrd," $","$"),"$$$$",_CRLF),"$",""),_CRLF+Space(01),_CRLF)) + _CRLF
					EndIf
				EndIf
			Else
				If _nPProd > 0 .AND. (_nPosPrdDvg := aScan(oMSNewGe1:aCols,{|x| x[_nPProd]==_cCodProd})) > 0
					oMSNewGe1:aCols[_nLnProd][_nPObs   ] := oMSNewGe1:aCols[_nPosPrdDvg][_nPObs   ]
					oMSNewGe1:aCols[_nLnProd][_nPObsCnf] := oMSNewGe1:aCols[_nPosPrdDvg][_nPObsCnf]
				EndIf
			EndIf
			//VALIDAวรO EM TEMPO REAL (A CADA LEITURA), RELATIVO A QUANTIDADE DIVERGENTE OU NรO
			//NESTE CASO, ESTAMOS CONSIDERANDO A QUANTIDADE DO PRODUTO PURA E SIMPLESMENTE, SEM CONSIDERAR LOTE E/OU ENDEREวO
			_nSumPrd  := 0
			_aSumProd := aClone(oMSNewGe1:aCols)
			_aSumProd := aSort( _aSumProd, , , { |x,y| (x[_nPProd]+x[_nPLote]+cValToChar(x[_nPVol1])) < (y[_nPProd]+y[_nPLote])+cValToChar(y[_nPVol1]) } )
			If Len(_aSumProd) > 0
				_nPPrd    := aScan( _aSumProd, { |x| x[_nPProd] == oMSNewGe1:aCols[_nLnProd][_nPProd] } )
			Else
				_nPPrd    := 0
			EndIf
			If _nPPrd > 0
				for _q := _nPPrd to len(_aSumProd)
					If _aSumProd[_q][_nPProd] == oMSNewGe1:aCols[_nLnProd][_nPProd]
						_nSumPrd += _aSumProd[_q][_nPQtde]
					Else
						Exit
					EndIf
				next
			EndIf
			_cErroPrd := ""
			If !SubStr(_cErro2,AT("#@#@#@#@#",_cErro2)+10,27)$oMSNewGe1:aCols[_nLnProd][_nPObs]
				_cMsg     := ""
				_nSumCB8  := 0
				dbSelectArea("CB8")
				CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
				While  !CB8->(EOF())                            .AND. ;
						CB8->CB8_FILIAL == xFilial("CB8")       .AND. ;
						CB8->CB8_ORDSEP == _cOrdSep             .AND. ;
						CB8->CB8_PROD   == oMSNewGe1:aCols[_nLnProd][_nPProd]
					_nSumCB8 += CB8->CB8_QTDORI
					dbSelectArea("CB8")
					CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
					CB8->(dbSkip())
				EndDo
				If _nSumPrd <> _nSumCB8
					_cMsg := AllTrim(StrTran(StrTran(_cErro3,"#@#@#@#@#",AllTrim(oMSNewGe1:aCols[_nLnProd][_nPProd])),"$",""))
				Else
					_cMsg := "OK!"
				EndIf
				for _x := 1 to len(oMSNewGe1:aCols)
					If oMSNewGe1:aCols[_x][_nPProd] == oMSNewGe1:aCols[_nLnProd][_nPProd]
						If Empty(oMSNewGe1:aCols[_x][_nPObs])
							oMSNewGe1:aCols[_x][_nPObs] := ""
						EndIf
						If !"OK!"$_cMsg
							oMSNewGe1:aCols[_x][_nPObs] := AllTrim(StrTran(oMSNewGe1:aCols[_x][_nPObs],"OK!",""))
						Else
							oMSNewGe1:aCols[_x][_nPObs] := AllTrim(StrTran(oMSNewGe1:aCols[_x][_nPObs],AllTrim(StrTran(StrTran(_cErro3,"#@#@#@#@#",AllTrim(oMSNewGe1:aCols[_nLnProd][_nPProd])),"$","")),""))
						EndIf
						If !_cMsg $ oMSNewGe1:aCols[_x][_nPObs]
							If !Empty(oMSNewGe1:aCols[_x][_nPObs])
								oMSNewGe1:aCols[_x][_nPObs]     := AllTrim(oMSNewGe1:aCols[_x][_nPObs]) + " / "
							EndIf
							oMSNewGe1:aCols[_x][_nPObs    ]     := AllTrim(oMSNewGe1:aCols[_x][_nPObs]) + _cMsg + " / "
						EndIf
						If Empty(oMSNewGe1:aCols[_x][_nPObsCnf])
							oMSNewGe1:aCols[_x][_nPObsCnf ]     := _cMsg + _CRLF
						ElseIf !_cMsg $ oMSNewGe1:aCols[_x][_nPObsCnf]
							oMSNewGe1:aCols[_x][_nPObsCnf ]     += _cMsg + _CRLF
						EndIf
						If !"OK!"$_cMsg
							_cErroPrd                           := AllTrim(StrTran(_cErroPrd,"OK!",""))
						EndIf
						If !_cMsg $ (cMultiGe2+" "+_cErroPrd)
							If Empty(_cErroPrd)
								_cErroPrd                   += " $$$ "
							EndIf
							_cErroPrd                       += _cMsg
						EndIf
					EndIf
					While Space(02)$oMSNewGe1:aCols[_x][_nPObs] .OR. "//"$oMSNewGe1:aCols[_x][_nPObs] .OR. "/ /"$oMSNewGe1:aCols[_x][_nPObs]
						oMSNewGe1:aCols[_x][_nPObs] := StrTran(oMSNewGe1:aCols[_x][_nPObs],Space(02),Space(01))
						oMSNewGe1:aCols[_x][_nPObs] := StrTran(oMSNewGe1:aCols[_x][_nPObs],"//"     ," / "    )
						oMSNewGe1:aCols[_x][_nPObs] := StrTran(oMSNewGe1:aCols[_x][_nPObs],"/ /"    ," / "    )
					EndDo
					If AllTrim(oMSNewGe1:aCols[_x][_nPObs]) == "/"
						oMSNewGe1:aCols[_x][_nPObs] := ""
					EndIf
					If SubStr(oMSNewGe1:aCols[_x][_nPObs],1,2) == " /"
						oMSNewGe1:aCols[_x][_nPObs] := SubStr(oMSNewGe1:aCols[_x][_nPObs],3)
					EndIf
					If SubStr(oMSNewGe1:aCols[_x][_nPObs],1,1) == "/"
						oMSNewGe1:aCols[_x][_nPObs] := SubStr(oMSNewGe1:aCols[_x][_nPObs],2)
					EndIf
					oMSNewGe1:aCols[_x][_nPObs]     := AllTrim(oMSNewGe1:aCols[_x][_nPObs])
				next
			Else
				While Space(02)$oMSNewGe1:aCols[_nLnProd][_nPObs] .OR. "//"$oMSNewGe1:aCols[_nLnProd][_nPObs] .OR. "/ /"$oMSNewGe1:aCols[_nLnProd][_nPObs]
					oMSNewGe1:aCols[_nLnProd][_nPObs] := StrTran(oMSNewGe1:aCols[_nLnProd][_nPObs],Space(02),Space(01))
					oMSNewGe1:aCols[_nLnProd][_nPObs] := StrTran(oMSNewGe1:aCols[_nLnProd][_nPObs],"//"     ," / "    )
					oMSNewGe1:aCols[_nLnProd][_nPObs] := StrTran(oMSNewGe1:aCols[_nLnProd][_nPObs],"/ /"    ," / "    )
				EndDo
				If AllTrim(oMSNewGe1:aCols[_nLnProd][_nPObs]) == "/"
					oMSNewGe1:aCols[_nLnProd][_nPObs] := ""
				EndIf
				If SubStr(oMSNewGe1:aCols[_nLnProd][_nPObs],1,2) == " /"
					oMSNewGe1:aCols[_nLnProd][_nPObs] := SubStr(oMSNewGe1:aCols[_nLnProd][_nPObs],3)
				EndIf
				If SubStr(oMSNewGe1:aCols[_nLnProd][_nPObs],1,1) == "/"
					oMSNewGe1:aCols[_nLnProd][_nPObs] := SubStr(oMSNewGe1:aCols[_nLnProd][_nPObs],2)
				EndIf
				oMSNewGe1:aCols[_nLnProd][_nPObs]     := AllTrim(oMSNewGe1:aCols[_nLnProd][_nPObs])
			EndIf
		EndIf
		oMSNewGe1:Refresh()
		_lAlter := .T.
	EndIf
EndIf

_nQtConf := 1

RestArea(_aSavCB8)
//RestArea(_aSavSB1)
RestArea(_aSavArL)

return(Empty(_cCodBar))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณConfirConfบAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de valida็ใo e confirma็ใo da confer๊ncia.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function ConfirConf()

Local _aSavArea := GetArea()
Local _aColBk   := {}
//Local _aPedido  := {}
Local _aProdD   := {}
Local _aSumPrd  := {}									//ARRAY utilizado para a soma das quantidades por produto, independente do volume
Local _aRecAlt  := {}
Local _aPrdNCnf := {}
Local _aLoteNeg := {}
Local _nSeqVol  := 0
Local _nMaxVol  := 0
Local _nSumPrd  := 0
Local _nSaldo   := 0
Local _nSumQtd  := 0
Local _nQLida   := 0
Local _e        := 0
Local _x        := 0
//Local _iNC      := 0
Local _Dvg      := 0
Local _lCont    := .T.
Local _lFatura  := .T.
Local _dData    := Date()
Local _cHora    := Time()
Local _cSB8TMP   := GetNextAlias()
Local _cMsgDvg  := ""
Local _cPrdNCnf := ""
Local _cItem    := ""
Local _cNumCont := ""
Local _cNumLot  := Space(len(CB9->CB9_NUMLOT))		//POR HORA, ESTAMOS CONSIDERANDO QUE NรO TRABALHAREMOS COM SUBLOTE
Local _cNumSer  := Space(len(CB9->CB9_NUMSER))		//POR HORA, ESTAMOS CONSIDERANDO QUE NรO TRABALHAREMOS COM NฺMERO DE SษRIE (CONCEITO RELACIONADO A CONTROLE DE ENDEREวAMENTO)
_lSolicVol 		:= .T.
dbSelectArea("CB7")
CB7->(dbSetOrder(1))
If CB7->(MsSeek(xFilial("CB7")+_cOrdSep,.T.,.F.))
	//CB7_STATUS: 0-Inicio;1-Separando;2-Sep.Final;3-Embalando;4-Emb.Final;5-Gera Nota;6-Imp.nota;7-Imp.Vol;8-Embarcado;9-Embarque Finalizado
	If VAL(CB7->CB7_STATUS) < 5
		_lFatura := .T.
	Else
		_lFatura := .F.
	EndIf
EndIf
If !((_lFatura .OR. (!_lVisual .AND. _lAlter)) .AND. MsgYesNo("Finaliza o processo de confer๊ncia neste momento?",_cRotina+"_014"))
	return NIL
EndIf
If !Empty(cMultiGe2)
	_cLog    := StrTran(StrTran(StrTran(StrTran(cMultiGe2," $","$"),"$$$$",_CRLF),"$",""),_CRLF+Space(01),_CRLF)
	//DESCOMENTAR OS DOIS TRECHOS ABAIXO, CASO SEJA NECESSมRIO DEMOSNTRAR OS LOGS NO BLOCO DE NOTAS DO WINDOWS
	/*_cArqLog := GetTempPath()+_cRotina+"_006_"+__cUserId+"_logcnf.txt"
	MemoWrite(_cArqLog,_cLog)
	If File(_cArqLog)
		MsgAlert("Foram encontradas diverg๊ncias. Tecle ENTER para apresentแ-las!",_cRotina+"_006")
		ShellExecute( "Open", _cArqLog, "", "\", 1 )
		FErase(_cArqLog)
	Else*/
//		MsgAlert("As seguintes diverg๊ncias foram encontradas durante o processo de confer๊ncia:" + _cLog,_cRotina+"_006")
//	EndIf
	//_lCont := MsgYesNo("Deseja descartar as seguintes inconsist๊ncias apuradas e prosseguir com a confirma็ใo?" + _CRLF + _cLog,_cRotina+"_007") //Linha comentada por Adriano Leonardo em 29/11/2013 para melhoria na rotina
	
	_lCont := .T. // Linha adicionada por Adriano Leonardo em 29/11/2013 em substitui็ใo a linha comentada logo acima
EndIf
If _lCont
	_aSumPrd  := {}
	_aColBk   := aClone(oMSNewGe1:aCols)
	_aColBk   := aSort( _aColBk, , , { |x,y| (cValToChar(x[_nPVol1])+x[_nPProd]+x[_nPLote]) < (cValToChar(y[_nPVol1])+y[_nPProd]+y[_nPLote]) } )
	for _x := 1 to len(_aColBk)
//		If !_aColBk[_x][Len(oMSNewGe1:aHeader)+1]
			If _aColBk[_x][_nPQtde] > 0
				//VALIDAวรO DE SEQUENCIA DE VOLUME
				If _lHabPLis .AND. !(_aColBk[_x][_nPVol1] == _nSeqVol .OR. _aColBk[_x][_nPVol1] == _nSeqVol+1 )
					MsgStop("Aten็ใo!!! Problemas com a sequencia dos volumes conferidos. Ajuste os volumes antes de prosseguir com a confirma็ใo!",_cRotina+"_008")
					_lCont := .F.
					Exit
				EndIf
				If _aColBk[_x][_nPVol1] > _nMaxVol
					_nMaxVol := _aColBk[_x][_nPVol1]
				EndIf
				_nSeqVol := _aColBk[_x][_nPVol1]
			EndIf
			//SOMA DA QUANTIDADE CONFERIDA POR PRODUTO, POR LOTE, POR ENDEREวO
			_nSumPrd := aScan(_aSumPrd,{|x| x[01]==_aColBk[_x][_nPProd] .AND. x[02]==_aColBk[_x][_nPLote] .AND. x[03]==_aColBk[_x][_nPEnd]})
			//A ฺLTIMA COLUNA DO ARRAY _aSumPrd DEVERม SER SEMPRE A QUANTIDADE!
			//QUAISQUER OUTRAS COLUNAS QUE FOREM INSERIDAS, DEVERรO SER IMEDIATAMENTE ANTES DA COLUNA DE QUANTIDADE (SEMPRE)!
			If _nSumPrd > 0
				_aSumPrd[_nSumPrd][Len(_aSumPrd[_nSumPrd])] += _aColBk[_x][_nPQtde]
			Else
				AADD(_aSumPrd,{_aColBk[_x][_nPProd],_aColBk[_x][_nPLote],_aColBk[_x][_nPEnd],_aColBk[_x][_nPQtde]})
			EndIf
//		EndIf
		DbSelectArea("SB8")
		SB8->(dbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
		If ! SB8->(dbSeek(xFilial("SB8")+_aColBk[_x][_nPProd] + "01" + _aColBk[_x][_nPLote]))
			MsgInfo("O Lote "+_aColBk[_x][_nPLote] + "do produto " + _aColBk[_x][_nPProd] + " nใo existe. Favor Conferir o lote digitado","Aten็ใo" )
			return NIL
		SB8->(Dbclosearea())
		EndIF
	next
	If _lCont
//		If _lSolicVol
//			_nVol1 := Volume() //Linha adicionada por Adriano Leonardo em 27/11/2013 para melhoria na rotina
//		EndIf
/*		If _lHabPLis
			If _nMaxVol > _nVol1
				MsgStop("Volume divergente. Por favor, proceda as corre็๕es antes de finalizar a confer๊ncia!",_cRotina+"_009")
				_lCont := .F.
			ElseIf _nMaxVol > 1 .AND. _nMaxVol < _nVol1
				MsgStop("Volume divergente com rela็ใo aos volumes conferidos!",_cRotina+"_031")
				_lCont := MsgYesNo("Continua com o processo mesmo assim?",_cRotina+"_032")
			EndIf
		ElseIf _nVol1 < 1
			MsgStop("Volume divergente. Por favor, proceda as corre็๕es antes de finalizar a confer๊ncia!",_cRotina+"_052")
			_lCont := .F.
		EndIf */
		If _lCont .AND. !_lVisual .AND. _lAlter
			cMultiGe2 := ""							//Reinicio os logs gerais para reavalia็ใo
			_aPedido  := {}
			_aProdD   := {}
			_dData    := Date()
			_cHora    := Time()
			for _x := 1 to len(_aColBk)
				If !_aColBk[_x][Len(oMSNewGe1:aHeader)+1]		//Nenhum item serแ deletado da tela (mas sim Zerado, pelo botใo de dele็ใo)
					_aRecAlt  := {}
					_cErroPrd := ""
					_cItem    := ""
					_nSaldo   := 0
					_nSumQtd  := 0
					_nSumPrd  := aScan(_aSumPrd,{|x| x[01]==_aColBk[_x][_nPProd] .AND. x[02]==_aColBk[_x][_nPLote] .AND. x[03]==_aColBk[_x][_nPEnd]})
					_nQLida   := _aSumPrd[_nSumPrd][Len(_aSumPrd[_nSumPrd])]		//A ๚ltima coluna do Array serแ sempre a da quantidade
					_aColBk[_x][_nPObs] := ""
					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))					//B1_FILIAL + B1_COD
					If !SB1->(MsSeek(xFilial("SB1") + Padr(_aColBk[_x][_nPProd],len(SB1->B1_COD)),.T.,.F.)) .AND. _aColBk[_x][_nPQtde] > 0
						If !AllTrim(StrTran(StrTran(_cErro1,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) $ _aColBk[_x][_nPObs   ]
							If !Empty(_aColBk[_x][_nPObs])
								_aColBk[_x][_nPObs] += " / "
							EndIf
							_aColBk[_x][_nPObs    ] += AllTrim(StrTran(StrTran(_cErro1,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$",""))
						EndIf
						If Empty(_aColBk[_x][_nPObsCnf ])
							_aColBk[_x][_nPObsCnf ] := AllTrim(StrTran(StrTran(_cErro1,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) + _CRLF
						ElseIf !AllTrim(StrTran(StrTran(_cErro1,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) $ _aColBk[_x][_nPObsCnf]
							_aColBk[_x][_nPObsCnf ] += AllTrim(StrTran(StrTran(_cErro1,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) + _CRLF
						EndIf
						If !AllTrim(StrTran(StrTran(_cErro1,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) $ (cMultiGe2+" "+_cErroPrd)
							If !Empty(_cErroPrd)
								_cErroPrd           += " $$$ "
							EndIf
							_cErroPrd               += AllTrim(StrTran(_cErro1,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])))
						EndIf
//						MsgStop("Aten็ใo! O produto " + _aColBk[_x][_nPProd] + " nใo existe!",_cRotina+"_042")
						_nPosDvg := ASCAN(_aProdD,{|x|AllTrim(x[01])==AllTrim(_aColBk[_x][_nPProd]).AND.x[02]==2})
						If _nPosDvg==0
							AADD(_aProdD,{_aColBk[_x][_nPProd],2,_aColBk[_x][_nPQtde],_aColBk[_x][_nPObs]})
						Else
							_aProdD[_nPosDvg][03]   += _aColBk[_x][_nPQtde]
							_aProdD[_nPosDvg][03]   := _aColBk[_x][_nPObs ]
						EndIf
					EndIf
					//DEVIDO A IMPLANTAวรO DA RASTREABILIDADE E A NECESSIDADE DE NรO UTILIZAR O LOTE INDICADO PELO SISTEMA ESSE TRECHO NรO ษ NECESSARIO
				    //PORQUE VALIDA OS LOTES NA CB8 E NA CB8 SรO OS LOTES INDICADOS PELO SISTEMA
					/*
					dbSelectArea("CB8")			//ITENS DA ORDEM DE SEPARAวรO
					CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
					If !CB8->(MsSeek(xFilial("CB8") + _cOrdSep + _aColBk[_x][_nPProd] + _aColBk[_x][_nPLote] + _aColBk[_x][_nPEnd],.T.,.F.)) .AND. _aColBk[_x][_nPQtde] > 0
						If !AllTrim(StrTran(StrTran(_cErro2,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) $ _aColBk[_x][_nPObs   ]
							If !Empty(_aColBk[_x][_nPObs])
								_aColBk[_x][_nPObs] += " / "
							EndIf
							_aColBk[_x][_nPObs    ] += AllTrim(StrTran(StrTran(_cErro2,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) + " / "
						EndIf
						If Empty(_aColBk[_x][_nPObsCnf ])
							_aColBk[_x][_nPObsCnf ] := AllTrim(StrTran(StrTran(_cErro2,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) + _CRLF
						ElseIf !AllTrim(StrTran(StrTran(_cErro2,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) $ _aColBk[_x][_nPObsCnf]
							_aColBk[_x][_nPObsCnf ] += AllTrim(StrTran(StrTran(_cErro2,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) + _CRLF
						EndIf
						If !AllTrim(StrTran(StrTran(_cErro2,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) $ (cMultiGe2+" "+_cErroPrd)
							If !Empty(_cErroPrd)
								_cErroPrd           += " $$$ "
							EndIf
							_cErroPrd               += AllTrim(StrTran(_cErro2,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])))
						EndIf
//						MsgStop("Aten็ใo! O produto " + _aColBk[_x][_nPProd] + " nใo existe na Ordem de Separa็ใo!",_cRotina+"_010")
						_nPosDvg := ASCAN(_aProdD,{|x|AllTrim(x[01])==AllTrim(_aColBk[_x][_nPProd]).AND.x[02]==2})
						If _nPosDvg==0
							AADD(_aProdD,{_aColBk[_x][_nPProd],2,_aColBk[_x][_nPQtde],_aColBk[_x][_nPObs]})
						Else
							_aProdD[_nPosDvg][03]   += _aColBk[_x][_nPQtde]
							_aProdD[_nPosDvg][04]   += _aColBk[_x][_nPObs ]
						EndIf
					
					EndIf
					*/
					If _aColBk[_x][_nPQtde] > 0 .AND. Empty(_cErroPrd)
 						dbSelectArea("CB8")
						CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
						If (CB8->(MsSeek(xFilial("CB8") + _cOrdSep + _aColBk[_x][_nPProd] + _aColBk[_x][_nPLote] + _aColBk[_x][_nPEnd],.T.,.F.)) ;
						.OR. CB8->(MsSeek(xFilial("CB8") + _cOrdSep + _aColBk[_x][_nPProd] ,.T.,.F.)) ).AND. _aColBk[_x][_nPQtde] > 0
							/*While	!CB8->(EOF())                           .AND. ;
									CB8->CB8_FILIAL == xFilial("CB8")       .AND. ;
									CB8->CB8_ORDSEP == _cOrdSep             .AND. ;
									CB8->CB8_PROD   == _aColBk[_x][_nPProd] .AND. ;
									CB8->CB8_LOTECT == _aColBk[_x][_nPLote] .AND. ;
									CB8->CB8_LCALIZ == _aColBk[_x][_nPEnd ]
							*/
								If aScan(_aPedido,CB8->CB8_PEDIDO) == 0
									AADD(_aPedido,CB8->CB8_PEDIDO)
								EndIf
								//If _nQLida > 0
									//_cItem              := _x //CB8->CB8_ITEM
								_cItem				:= CB8->CB8_ITEM
								//EndIf
								_nSumQtd            += CB8->CB8_QTDORI
								AADD(_aRecAlt,CB8->(Recno()))
								while !RecLock("CB8",.F.) ; enddo
									If funname() == "RFATA002"
										CB8->CB8_QTDORI		:= _nQLida
										CB8->CB8_SALDOS     := CB8->CB8_QTDORI - _nQLida
									Else
										CB8->CB8_SALDOS     := CB8->CB8_SALDOS - _nQLida
									EndIf
									If CB8->CB8_SALDOS  < 0
										_nQLida         := CB8->CB8_SALDOS * (-1)
										CB8->CB8_SALDOS := 0									//SALDO CONFERIDO
									Else
										_nQLida         := 0
									EndIf
								CB8->(MSUNLOCK())
								_nSaldo                 += CB8->CB8_SALDOS
								dbSelectArea("CB8")
								CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
								CB8->(dbSkip())
							//EndDo
						EndIf
						If _nQLida <> 0 //.OR. _nSaldo <> 0
							dbSelectArea("CB7")
							CB7->(dbSetOrder(1))
							If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
								while !RecLock("CB7",.F.) ; enddo
									CB7->CB7_DIVERG := "1"			//0=Nao;1=Sim
								CB7->(MSUNLOCK())
							EndIf
							If !AllTrim(StrTran(StrTran(_cErro3,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) $ _aColBk[_x][_nPObs   ]
								If !Empty(_aColBk[_x][_nPObs])
									_aColBk[_x][_nPObs] += " / "
								EndIf
								_aColBk[_x][_nPObs    ] += AllTrim(StrTran(StrTran(_cErro3,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) + " / "
							EndIf
							If Empty(_aColBk[_x][_nPObsCnf])
								_aColBk[_x][_nPObsCnf ] := AllTrim(StrTran(StrTran(_cErro3,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) + _CRLF
							ElseIf !AllTrim(StrTran(StrTran(_cErro3,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) $ _aColBk[_x][_nPObsCnf]
								_aColBk[_x][_nPObsCnf ] += AllTrim(StrTran(StrTran(_cErro3,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) + _CRLF
							EndIf
							If !AllTrim(StrTran(StrTran(_cErro3,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd])),"$","")) $ (cMultiGe2+" "+_cErroPrd)
								If Empty(_cErroPrd)
									_cErroPrd           += " $$$ "
								EndIf
								_cErroPrd               += StrTran(_cErro3,"#@#@#@#@#",AllTrim(_aColBk[_x][_nPProd]))
							EndIf
							_nPosDvg := ASCAN(_aProdD,{|x|AllTrim(x[01])==AllTrim(_aColBk[_x][_nPProd]).AND.x[02]==1})
							/*
							If _nPosDvg==0
								AADD(_aProdD,{_aColBk[_x][_nPProd],1,_aColBk[_x][_nPQtde],_aColBk[_x][_nPObs]})
							Else
								_aProdD[_nPosDvg][03]   += _aColBk[_x][_nPQtde]
								_aProdD[_nPosDvg][04]   += _aColBk[_x][_nPObs]
							EndIf
							*/
							for _e := 1 to len(_aRecAlt)
								dbSelectArea("CB8")
								dbGoTo(_aRecAlt[_e])
								while !RecLock("CB8",.F.) ; enddo
									CB8->CB8_SALDOD := IIF(CB8->CB8_SALDOS>0,CB8->CB8_SALDOS,_nQLida*(-1))				//SALDO DIVERGENTE
									_nQLida         := IIF(CB8->CB8_SALDOS>0,_nQLida        ,0 )  
								CB8->(MSUNLOCK())
							next
						
						Else
							for _e := 1 to len(_aRecAlt)
								dbSelectArea("CB8")
								CB8->(dbGoTo(_aRecAlt[_e]))
								while !RecLock("CB8",.F.) ; enddo
									CB8->CB8_SALDOD := 0																//SALDO DIVERGENTE
								CB8->(MSUNLOCK())
							next
						EndIf
					ElseIf !Empty(_aColBk[_x][_nPObs])
						dbSelectArea("CB7")
						CB7->(dbSetOrder(1))
						If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
							while !RecLock("CB7",.F.) ; enddo
							CB7->CB7_DIVERG := "1"			//0=Nao;1=Sim
							CB7->(MSUNLOCK())
						EndIf
					EndIf
					If !Empty(_cErroPrd) .AND. !StrTran(_cErroPrd,"$","") $ cMultiGe2
						If Empty(cMultiGe2)
							cMultiGe2     += "$$"
						EndIf
						cMultiGe2         += _cErroPrd
					EndIf
					If ASCAN(_aProdD,{|x|AllTrim(x[01])==AllTrim(_aColBk[_x][_nPProd]).AND.x[02]==2})==0 .AND. _aColBk[_x][_nPQtde] > 0
//						_cNumLot := Space(len(CB9->CB9_NUMLOT))		//POR HORA, ESTAMOS CONSIDERANDO QUE NรO TRABALHAREMOS COM SUBLOTE
//						_cNumSer := Space(len(CB9->CB9_NUMSER))		//POR HORA, ESTAMOS CONSIDERANDO QUE NรO TRABALHAREMOS COM NฺMERO DE SษRIE (CONCEITO RELACIONADO A CONTROLE DE ENDEREวAMENTO)
						dbSelectArea("CB9")		//ITENS SEPARADOS/CONFERIDOS
						CB9->(dbSetOrder(8))			//CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+CB9_VOLUME+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ
						If !CB9->(MsSeek(	xFilial("CB9")        + ;
											_cOrdSep              + ;
											_aColBk[_x][_nPProd]  + ;
											_aColBk[_x][_nPLote]  + ;
											_cNumLot              + ;
											_cNumSer              + ;
											cValToChar(_aColBk[_x][_nPVol1]),.T.,.F. ))
							while !RecLock("CB9",.T.) ; enddo
							CB9->CB9_FILIAL := xFilial("CB9")
							CB9->CB9_ORDSEP := _cOrdSep
//							CB9->CB9_CODETI := 
							CB9->CB9_PROD   := _aColBk[_x][_nPProd]
//							CB9->CB9_EMBALD := 
							CB9->CB9_VOLUME := cValToChar(_aColBk[_x][_nPVol1])
							/*dbSelectArea("CB8")			//ITENS DA ORDEM DE SEPARAวรO
							CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
							If CB8->(MsSeek(xFilial("CB8") + _cOrdSep + _aColBk[_x][_nPProd] + _aColBk[_x][_nPLote] + _aColBk[_x][_nPEnd],.T.,.F.))
								CB9->CB9_ITEM := CB8->CB8_ITEM
							EndIf*/
							CB9->CB9_ITEM 	:= _cItem
							CB9->CB9_SEQUEN := StrZero(aScan(oMSNewGe1:aCols,{|x|x[_nPProd]==_aColBk[_x][_nPProd].AND.x[_nPVol1]==_aColBk[_x][_nPVol1].AND.x[_nPLote]==_aColBk[_x][_nPLote].AND.x[_nPEnd]==_aColBk[_x][_nPEnd]}),len(CB9->CB9_SEQUEN))
//							CB9->CB9_DISPID := 
							CB9->CB9_ITESEP := _cItem
//							CB9->CB9_CODEMB := 
							CB9->CB9_CODSEP := _cCodConf
							CB9->CB9_LOTECT := _aColBk[_x][_nPLote]
//							CB9->CB9_NUMLOT := 
							CB9->CB9_LOCAL  := _aColBk[_x][_nPArm ]
							CB9->CB9_LCALIZ := _aColBk[_x][_nPEnd ]
//							CB9->CB9_SUBVOL := 
//							CB9->CB9_LOTSUG := 
//							CB9->CB9_SLOTSU := 
//							CB9->CB9_QTEEBQ := 
							CB9->CB9_PEDIDO := _aPedido[01]
//							CB9->CB9_NUMSER := 
//							CB9->CB9_DOC    := 
						Else
							while !RecLock("CB9",.F.) ; enddo
						EndIf
						CB9->CB9_QTESEP := _aColBk[_x][_nPQtde]
						CB9->CB9_STATUS := IIF(_nSumQtd ==_aSumPrd[_nSumPrd][Len(_aSumPrd[_nSumPrd])],"2","1")					//1=Em Aberto;2=Embalagem Finalizada;3=Embarcado
						CB9->CB9_QTEEMB := IIF(_nSumQtd==_aSumPrd[_nSumPrd][Len(_aSumPrd[_nSumPrd])],_aColBk[_x][_nPQtde],0)
						CB9->(MSUNLOCK())
					EndIf
					//Os logs de confer๊ncia sใo sempre gravados, em quaisquer situa็๕es!
					dbSelectArea("CBG")
					CBG->(dbSetOrder(1))
					while !RecLock("CBG",.T.) ; enddo
					CBG->CBG_FILIAL := xFilial("CBG")
					CBG->CBG_CODCON := _cNumCont
					CBG->CBG_DATA   := _dData				//_aColBk[_x][_nPDt  ]
					CBG->CBG_HORA   := _cHora				//_aColBk[_x][_nPHr  ]
					CBG->CBG_EVENTO := "09"					//Expedi็ใo
					CBG->CBG_USUARI := __cUserId
					CBG->CBG_CODOPE := _cCodConf
					CBG->CBG_CODPRO := _aColBk[_x][_nPProd]
					CBG->CBG_QTDE   := _aColBk[_x][_nPQtde]
					CBG->CBG_LOTE   := _aColBk[_x][_nPLote]
//					CBG->CBG_SLOTE  := 
					CBG->CBG_ARM    := _aColBk[_x][_nPArm ]
					CBG->CBG_END    := _aColBk[_x][_nPEnd ]
//					CBG->CBG_ARMDES := 
//					CBG->CBG_NUMSEQ := 
//					CBG->CBG_DOC    := 
//					CBG->CBG_CODETI := 
//					CBG->CBG_CODINV := 
//					CBG->CBG_NOTAE  := 
//					CBG->CBG_SERIEE := 
//					CBG->CBG_FORN   := 
//					CBG->CBG_LOJfor := 
//					CBG->CBG_OP     := 
//					CBG->CBG_TM     := 
//					CBG->CBG_NOTAS  := 
//					CBG->CBG_SERIES := 
					CBG->CBG_CLI    := SubStr(_cCli,1,len(SA1->A1_COD))										//_cCli := SA1->A1_COD + " " + SA1->A1_LOJA + " - " + SA1->A1_NOME
					CBG->CBG_LOJCLI := SubStr(_cCli,len(SA1->A1_COD)+2,len(SA1->A1_LOJA))
					CBG->CBG_ORDSEP := _cOrdSep
//					CBG->CBG_ETIAUX := 
					CBG->CBG_VOLUME := cValToChar(_aColBk[_x][_nPVol1])
//					CBG->CBG_SUBVOL := 
//					CBG->CBG_ENDDES := 
					_nItCols := aScan(oMSNewGe1:aCols,{|x|x[_nPProd]==_aColBk[_x][_nPProd].AND.x[_nPVol1]==_aColBk[_x][_nPVol1].AND.x[_nPLote]==_aColBk[_x][_nPLote].AND.x[_nPEnd]==_aColBk[_x][_nPEnd]})
					If Empty(_aColBk[_x][_nPObs])  

					/*
					//Trecho comentado por Adriano Leonardo em 05/12/2013 a pedido do Sr. Ronie para alterar a ordem do processo, na implementa็ใo do 
					//packlist deverแ ser retomado
					If _lSolicVol
						_nVol1 := Volume() //Linha adicionada por Adriano Leonardo em 29/11/2013 para melhoria na rotina
						If _lHabPLis
							If _nMaxVol > _nVol1
								MsgStop("Volume divergente. Por favor, proceda as corre็๕es antes de finalizar a confer๊ncia!",_cRotina+"_009")
								_lCont := .F.
							ElseIf _nMaxVol > 1 .AND. _nMaxVol < _nVol1
								MsgStop("Volume divergente com rela็ใo aos volumes conferidos!",_cRotina+"_031")
								_lCont := MsgYesNo("Continua com o processo mesmo assim?",_cRotina+"_032")
							EndIf
						ElseIf _nVol1 < 1
							MsgStop("Volume divergente. Por favor, proceda as corre็๕es antes de finalizar a confer๊ncia!",_cRotina+"_052")
							_lCont := .F.
						EndIf
					EndIf
					*/							
						CBG->CBG_OBS                             := "Conferencia realizada com sucesso!"
						If !Empty(_aColBk[_x][_nPObsCnf])
							CBG->CBG_OBSCNF                      := AllTrim(StrTran(StrTran(_aColBk[_x][_nPObsCnf]," $$$ ",_CRLF),"$","")) + _CRLF + "Conferencia realizada com sucesso!"
						Else
							CBG->CBG_OBSCNF                      := "Conferencia realizada com sucesso!"
						EndIf
						oMSNewGe1:aCols[_nItCols][_nPObsCnf]     := CBG->CBG_OBSCNF
						oMSNewGe1:aCols[_nItCols][_nPObs   ]     := "OK!"
					Else
						CBG->CBG_OBS                             := _aColBk[_x][_nPObs]
						If !Empty(_aColBk[_x][_nPObsCnf])
							CBG->CBG_OBSCNF                      := AllTrim(StrTran(StrTran(_aColBk[_x][_nPObsCnf]," $$$ ",_CRLF),"$",""))
							oMSNewGe1:aCols[_nItCols][_nPObsCnf] := CBG->CBG_OBSCNF
						EndIf
						oMSNewGe1:aCols[_nItCols][_nPObs]        := CBG->CBG_OBS
					EndIf
					CBG->(MSUNLOCK())
				EndIf
			next

		if Select(_cSB8TMP) > 0
			(_cSB8TMP)->(dbCloseArea())
		endif
		BeginSql Alias _cSB8TMP
			SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_SALDO, SUM(C9_QTDLIB) C9_QTDLIB, SC9.C9_LOTECTL
			FROM %table:SC9% SC9 (NOLOCK)
				INNER JOIN (
							 SELECT DISTINCT CB9_ORDSEP, CB9_PEDIDO, CB9_ITESEP , CB9_PROD, CB9_LOTECT
							 FROM %table:CB9% CB9 (NOLOCK) 
							 WHERE CB9.CB9_FILIAL  =  %xFilial:CB9%
							   AND CB9.CB9_ORDSEP  =  %Exp:_cOrdSep%
							   AND CB9.%NotDel%
						   ) CB9FIL        ON CB9FIL.CB9_PEDIDO  =  SC9.C9_PEDIDO
										  AND CB9FIL.CB9_ITESEP    =  SC9.C9_ITEM
										  AND CB9FIL.CB9_PROD    =  SC9.C9_PRODUTO
										  AND CB9FIL.CB9_LOTECT  =  SC9.C9_LOTECTL
										  AND CB9FIL.CB9_ORDSEP  =  SC9.C9_ORDSEP
				INNER JOIN %table:SB8% SB8 (NOLOCK) ON SB8.B8_FILIAL =  %xFilial:SB8%
										  AND SB8.B8_PRODUTO         =  SC9.C9_PRODUTO
										  AND SB8.B8_LOCAL       	 =  SC9.C9_LOCAL
										  AND (SB8.B8_SALDO)         <  SC9.C9_QTDLIB
										  AND SB8.B8_LOTECTL 		 = SC9.C9_LOTECTL
										  AND SB8.%NotDel%
			WHERE SC9.C9_FILIAL  =  %xFilial:SC9%
			  AND SC9.C9_NFISCAL =  %Exp:''%
			  AND SC9.C9_BLEST   =  %Exp:''%
			  AND SC9.C9_BLCRED  =  %Exp:''%
			  AND SC9.C9_BLOQUEI =  %Exp:''%
			  AND SC9.%NotDel%
			GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_SALDO,SC9.C9_LOTECTL
			ORDER BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_SALDO,SC9.C9_LOTECTL
		EndSql	

		dbSelectArea(_cSB8TMP)
		(_cSB8TMP)->(dbGoTop())
		While !(_cSB8TMP)->(EOF())	//Se retornar .T., significa que algum item do processo deixarแ o estoque negativo
			AADD(_aLoteNeg,{(_cSB8TMP)->B8_PRODUTO,(_cSB8TMP)->C9_LOTECTL,(_cSB8TMP)->B8_SALDO,(_cSB8TMP)->C9_QTDLIB})
			(_cSB8TMP)->(dbSkip())
		EndDo
		if Select(_cSB8TMP) > 0
			(_cSB8TMP)->(dbCloseArea())
		endif	

		If Len(_aLoteNeg) > 0
				TELAERRO(_aLoteNeg)
				return NIL	
		EndIf

		//Chama a rotina para gera็ใo da SC9 com os lotes separados baseado na CB9
			v166TcLote (_cOrdSep)
			dbUnLockAll()

			for _x := 1 to len(_aPedido)
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				If SC5->(MsSeek(xFilial("SC5") + _aPedido[_x],.T.,.F.))
					while !RecLock("SC5",.F.) ; enddo
					SC5->C5_VOLUME1    := _nVol1
					//Trecho adicionado por Adriano Leonardo em 03/07/2013 para que seja priorizada a esp้cie informada no pedido
					If Empty(SC5->C5_ESPECI1)
						SC5->C5_ESPECI1    := _cEspec
					EndIf
					/*
					If _nPLiq > 0 .And. SC5->C5_PESOL==0
						SC5->C5_PESOL  := _nPLiq
					Else
						//Linha adicionada por Adriano Leonardo em 24/06/2013 para corre็ใo do peso
						CalcPeso()
						If _nPLiqu > 0
							SC5->C5_PESOL  := _nPLiqu
						EndIf
					EndIf
					*/
					/*
					If _nPBrut > 0 .And. SC5->C5_PBRUTO==0
						SC5->C5_PBRUTO := _nPBrut
					Else
					//Linha adicionada por Adriano Leonardo em 24/06/2013 para corre็ใo do peso
						If _nPsBrut > 0
							SC5->C5_PBRUTO := _nPsBrut
						EndIf
					EndIf
					*/
					SC5->(MSUNLOCK())
				EndIf
			next
		EndIf
		_aPrdNCnf := {}
		_cPrdNCnf := ""
		dbSelectArea("CB8")			//ITENS DA ORDEM DE SEPARAวรO
		CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
		If CB8->(MsSeek(xFilial("CB8") + _cOrdSep,.T.,.F.))
			While !CB8->(EOF()) .AND. CB8->CB8_ORDSEP == _cOrdSep
				If aScan(_aColBk,{|x|	x[_nPProd]==CB8->CB8_PROD   .AND. ;
										x[_nPLote]==CB8->CB8_LOTECT .AND. ;
										x[_nPEnd ]==CB8->CB8_LCALIZ     } ) == 0
					AADD(_aPrdNCnf,{CB8->CB8_ITEM,CB8->CB8_PROD,CB8->CB8_LOTECT,CB8->CB8_LCALIZ})
				EndIf
				dbSelectArea("CB8")			//ITENS DA ORDEM DE SEPARAวรO
				CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
				CB8->(dbSkip())
			EndDo
			/*
			If Len(_aPrdNCnf) > 0
				_cPrdNCnf := "Aten็ใo!!! Os seguintes produtos ainda nใo foram conferidos: "
				for _iNC  := 1 to len(_aPrdNCnf)
					_cPrdNCnf += _CRLF + _aPrdNCnf[_iNC][02]
				next
				_lCont := .F.
			//	MsgAlert(_cPrdNCnf,_cRotina+"_044")
			EndIf
			*/
		EndIf
		If _lCont .AND. ASCAN(_aProdD,{|x| x[03] > 0}) == 0 .AND. _lFatura
			//Conte๚do do Status: "0-Inicio;1-Separando;2-Sep.Final;3-Embalando;4-Emb.Final;5-Gera Nota;6-Imp.nota;7-Imp.Vol;8-Embarcado;9-Embarque Finalizado"
			_cQry := " UPDATE CB7 "
			_cQry += " SET CB7_STATUS = (CASE "
			_cQry += "							WHEN CB8_SALDOS  = 0  THEN '2' "
			_cQry += "							ELSE                       '1' "
			_cQry += "					 END "
			_cQry += "					) "
			_cQry += " FROM " + RetSqlName("CB7") + " CB7 "
			_cQry += "                           INNER JOIN ( "
			_cQry += "                                        SELECT CB8_ORDSEP, SUM( CB8_QTDORI ) CB8_QTDORI, SUM( CB8_SALDOS ) CB8_SALDOS  "
			_cQry += "                                        FROM " + RetSqlName("CB8") + " CB8 (NOLOCK) "
			_cQry += "                                        WHERE CB8.CB8_FILIAL = '" + xFilial("CB8") + "' "
			_cQry += "                                          AND CB8.CB8_ORDSEP = '" + _cOrdSep       + "' "
			_cQry += "                                          AND CB8.D_E_L_E_T_ = '' "
			_cQry += "                                        GROUP BY CB8_ORDSEP "
			_cQry += "                                       ) IT ON IT.CB8_ORDSEP = CB7.CB7_ORDSEP "
			_cQry += " WHERE CB7.CB7_FILIAL = '" + xFilial("CB7") + "' "
			_cQry += "   AND CB7.CB7_ORDSEP = '" + _cOrdSep       + "' "
			_cQry += "   AND CB7.D_E_L_E_T_ = '' "
		//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_005.TXT",_cQry)
			If TCSQLExec(_cQry) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_016")
			Else
				dbSelectArea("CB7")
				CB7->(dbSetOrder(1))
				CB7->(dbGoTop())
				If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
					_aCB7 := CB7->(GetArea())
					//CB7_STATUS: 0-Inicio;1-Separando;2-Sep.Final;3-Embalando;4-Emb.Final;5-Gera Nota;6-Imp.nota;7-Imp.Vol;8-Embarcado;9-Embarque Finalizado
					If VAL(CB7->CB7_STATUS) > 1
						while !RecLock("CB7",.F.) ; enddo
							CB7->CB7_DIVERG := "0"
							CB7->CB7_DTFIMS := Date()
							CB7->CB7_HRFIMS := StrTran(Time(),":","")
						CB7->(MSUNLOCK())
						//Geracao da Nota Fiscal de Saida
						NotaFiscal(2)
					EndIf
					RestArea(_aCB7)
					If _lGerouNf
						cMultiGe1 := ""
						cMultiGe2 := ""
						_nTamCBar := 30
						lCont	  := .T.
						_cRotina  := "RFATA002"
						_cOrdSep  := Space(len(CB7->CB7_ORDSEP))
						_cPedVen  := Space(len(CB7->CB7_PEDIDO))
						_cCli     := Space(50)
						_cNumCont := StrZero(1,len(CBG->CBG_CODCON))
						_nPLiq    := 0
						_nPBrut   := 0
						_nQLida   := 0
						_nQtConf  := 1
						_nVol1    := 1
						_cEspec   := Padr("VOLUME(S)",len(SC5->C5_ESPECI1))
						_cCodBar  := Space(_nTamCBar)
						_cCodConf := __cUserId
						_cNomConf := "USER - " + cUserName
						cMultiGe2 := ""
						_cErro1   := "$$ PROD. #@#@#@#@# NรO ENCONTRADO!$$"
						_cErro2   := "$$ PROD. #@#@#@#@# NรO PERTENCE A ESTA SEPAR.!$$"
						_cErro3   := "$$ QTDE. DIVERG. P/ PRODUTO #@#@#@#@#!$$"
						cCadastro := "* * *  E X P E D I ว ร O  * * *"
						_cNota    := ""
						_cSerie   := ""
						_nItNF    := 0
						_nPProd   := 0
						_nPDesc   := 0
						_nPQtde   := 0
						_nPLote   := 0
						_nPEnd    := 0
						_nPVol1   := 0
						_nPObs    := 0
						_nPObsCnf := 0
						_nPArm    := 0
						_nPDt     := 0
						_nPHr     := 0
						_nHandle  := 0
						_nHdlCB   := 0
						_lVisual  := .F.
						_lAlter   := .F.
						_lPesVol  := .F.
						_lGerouNF := .F.
						_lHabPLis := GetMV("MV_PLCONF") //SuperGetMV("MV_PLCONF",,.F.)		//Habilita o tratamento dos itens por volume para o Packing List?
						aFieldFill:= {}
						_nPsBrut  := 0
						_nPLiqu   := 0
						_cNotaAux := ""
						_cRoman	  := ""
						Close(oDlg)
						_lRetFun  := .T.
						return
						//U_RFATA002(_cOrdSep,.F.)
					EndIf
				EndIf
			EndIf
			TcRefresh("CB7")
		Else
			If Len(_aProdD)+Len(_aPrdNCnf) > 0
				_cArqLog := GetTempPath()+_cRotina+"_043"+__cUserId+"_logcnf_"+DTOS(Date())+StrTran(Time(),":","")+".txt"
				_cMsgDvg := "Diverg๊ncias apontadas (Produto - Erro):"
				for _Dvg := 1 to len(_aProdD)
					_cMsgDvg += _CRLF + ">>> " + Padr(_aProdD[_Dvg  ][01],16) + " - " + _aProdD[_Dvg][04]
				next
				for _Dvg := 1 to len(_aPrdNCnf)
					_cMsgDvg += _CRLF + ">>> " + Padr(_aPrdNCnf[_Dvg][02],16) + " - " + "PRODUTO NรO CONFERIDO!"
				next
				/*If .F. .AND. AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166" .AND. MemoWrite(_cArqLog,_cMsgDvg)		//GERAวรO DO ARQUIVO TXT COM AS INCONSISTสNCIAS DESATIVADO EM 26/03/2013
					MsgAlert(_cMsgDvg,_cRotina+"_043")
					If File(_cArqLog)
						ShellExecute( "Open", _cArqLog, "", "\", 1 )
					EndIf
					FErase(_cArqLog)
				Else*/If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
					MsgAlert(_cMsgDvg,_cRotina+"_044")
				EndIf
					
			EndIf
			/*
			//Trecho comentado por Adriano Leonardo em 29/11/2013 por solicita็ใo do cliente
			If MsgYesNo("O processo nใo foi finalizado por quest๕es de diverg๊ncias. Deseja fechar esta janela (ISTO OBRIGARม O REINอCIO DO PROCESSO!)?",_cRotina+"_018")
				Close(oDlg)
			EndIf
			*/
			MsgAlert("O processo nใo foi finalizado por quest๕es de diverg๊ncias, verifique as diverg๊ncias e tente novamente. ",_cRotina+"_018") //Linha adicionada por Adriano Leonardo em 29/11/2013 para melhoria na rotina
			
		EndIf
	EndIf
EndIf

RestArea(_aSavArea)

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTELAERRO    บAutor  ณDiego Rodrigues บ Data ณ  11/08/2023   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina para demonstrar os lotes sem saldo na tela      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function TELAERRO(_aLoteErro)
Private oDlgError
Private oBrowse

//Monta o array de campos
aCpoCom := {"Produto", "Lote", "Saldo Lotes", "Qtd. Necessแrio"}

Define MsDialog oDlgError From 000,000 To 500,750 Title "Produtos sem saldo por Lote" Pixel

//Monta a barra de bot๕es
Define ButtonBar oBar size 20,20 3D TOP of oDlgError
Define Button Resource "CANCEL" Of oBar Action (::End()) //Prompt "Fechar" ToolTip "Fecha a Tela" 
oBar:bRClicked:={ || AllwaysTrue() }

@ 025,005 Say "Os produtos abaixo nใo possuem saldos ou quantidades sufientes por Lote para atender ao Pedido: " Pixel Of oDlgError

oBrowse := TWBrowse():New(3.0, 0.5, 370, 190,, aCpoCom, {50,250,50,50}, oDlgError,,,,,,,,,,,, .T.)
oBrowse:SetArray(_aLoteErro)
oBrowse:bLine := {||{ _aLoteErro[oBrowse:nAt,01],;
_aLoteErro[oBrowse:nAt,02],;
_aLoteErro[oBrowse:nAt,03],;
_aLoteErro[oBrowse:nAt,04] } }
oBrowse:Refresh()

Activate MsDialog oDlgError Centered

MsgInfo("Devido a problemas relacionados com os saldos dos produtos a Nota Fiscal nใo serแ gerada.","[RFATA002_090] - Aviso ")

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณGeraNf    บAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de Geracao da Nota Fiscal de Saida apos a       บฑฑ
ฑฑบ          ณconferencia dos volumes.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function GeraNf(_lACD)

Local _aSavAr       := GetArea()
Local nPrcVen       := 0
Local _nFator       := 0
//Local _nMaxPerg   := 20									//N๚mero mแximo de perguntas para o grupo de perguntas MT460A da SX1
//Local _nPPv       := 0
Local _xF           := 0
Local _lContinua    := .T.
Local _lQuant       := .T.
Local _lCalcula     := .F.
Local _lImpZZZ	    := .T.
Local _ImprEtVol    := IIF(AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166", MsgYesNo("Deseja imprimir as etiquetas de volume ap๓s o faturamento?",_cRotina+"_053"), VtYesNo("Deseja emitir as etiquetas de volume ap๓s faturamento?","Aviso",.T.))  
Local cSerie        := GetMV("MV_SERFATA")			//Serie da nota fiscal				//SuperGetMV("MV_SERFATA",,"1"  )
Local cSerieb       := GetMV("MV_SERFATZ")			//Serie CD							//SuperGetMV("MV_SERFATZ",,"ZZZ")
Local nItemNfb      := 0			//a460NumIt(cSerieb)				//Numero de itens por controle CD
Local nItemNf       := 0			//a460NumIt(cSerie)				//Numero de itens por Nota Fiscal
Local _NFg          := 0
Local _x            := 0
Local _ft           := 0
Local _Neg          := 0
Local _xC6          := 0
Local _pNf          := 0
Local _Es           := 0
Local _c9           := 0
Local _nParBk       := 0
Local _aPMT460A     := &(GetMV("MV_PMT460A",,"{}"))	//Sequencial de preenchimento dos parโmetros vinculados ao grupo de perguntas MT460A da SX1		//&(SuperGetMV("MV_PMT460A",,"{}"))
Local _aEstornQ     := {}
Local aPvlNfs       := {}
Local aPvlNfsb      := {}
Local _aSvSC9       := {}
Local _aItNeg       := {}
Local _cCodConf     := ""
Local _cNomConf     := "" //"USER - " + cUserName
Local _cMsgNfF      := ""
Local _cMsgNeg      := ""

Private aNotas      := {}
Private _nContPar   := 0
Private _nDiv	    := 0
Private _cNtAcd     := ""
Private cPerg       := "MT460A"
Private _bTIPO      := "Type('MV_PAR'+StrZero(_nContPar,2))"
Private _cSC9TMP    := GetNextAlias()
Private _lRCFGASX1  := ExistBlock("RCFGASX1")
Private _lRFATR040  := ExistBlock("RFATR040")
Private lMsErroauto := .F.

Public  l460Acres   := .T. //Ativa os tratamentos do fonte M460ACRE

default _lACD       := .F.

dbSelectArea("CB1")
CB1->(dbSetOrder(2))
If CB1->(MsSeek(xFilial("CB1") + __cUserId,.T.,.F.))
	_cCodConf := CB1->CB1_CODOPE
	_cNomConf := "OPER - " + CB1->CB1_NOME
EndIf
Pergunte(cPerg,.F.)
for _ft := 1 to len(_aPMT460A)
	&("MV_PAR"+StrZero(_ft,2)) := _aPMT460A[_ft]
	if _lRCFGASX1
		U_RCFGASX1(cPerg, StrZero(_ft,2), _aPMT460A[_ft])
		FkCommit()
	endif
next
//Inํcio - Trecho adicionado por Adriano Leonardo em 05/12/2013 para altera็ใo da ordem do processo na implanta็ใo do packing list deverแ ser retomado
If _lSolicVol
	_nVol1 := Volume() //Linha adicionada por Adriano Leonardo em 29/11/2013 para melhoria na rotina
	If _lHabPLis
		If _nMaxVol > _nVol1
			MsgStop("Volume divergente. Por favor, proceda as corre็๕es antes de finalizar a confer๊ncia!",_cRotina+"_009")
			_lCont := .F.
		ElseIf _nMaxVol > 1 .AND. _nMaxVol < _nVol1
			MsgStop("Volume divergente com rela็ใo aos volumes conferidos!",_cRotina+"_031")
			_lCont := MsgYesNo("Continua com o processo mesmo assim?",_cRotina+"_032")
		EndIf
	ElseIf _nVol1 < 1
		MsgStop("Volume divergente. Por favor, proceda as corre็๕es antes de finalizar a confer๊ncia!",_cRotina+"_052")
		_lCont := .F.
	EndIf
	for _x := 1 to len(_aPedido)
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		if SC5->(MsSeek(xFilial("SC5") + _aPedido[_x],.T.,.F.))
			while !RecLock("SC5",.F.) ; enddo
				SC5->C5_VOLUME1     := _nVol1
				//Trecho adicionado por Adriano Leonardo em 03/07/2013 para que seja priorizada a esp้cie informada no pedido
				If Empty(SC5->C5_ESPECI1)
					SC5->C5_ESPECI1 := _cEspec
				EndIf
			SC5->(MSUNLOCK())
			SC5->(FkCommit())
		endif
	next
EndIf
crgCB9ITESEP(_cOrdSep)
TcRefresh("CB9")			  
/*
//Final - Trecho adicionado por Adriano Leonardo em 05/12/2013 para altera็ใo da ordem do processo
BeginSql Alias _cSC9TMP
	SELECT SC9.*, SC9.R_E_C_N_O_ RECSC9, SC5.*, SC5.R_E_C_N_O_ RECSC5, SC6.*, SC6.R_E_C_N_O_ RECSC6
	FROM %table:SC9% SC9 (NOLOCK)
	    INNER JOIN (
	                 SELECT DISTINCT CB8_ORDSEP, CB8_PEDIDO, CB8_ITEM, CB8_PROD, CB8_LOTECT
	                 FROM %table:CB8% CB8 (NOLOCK)
	                 WHERE CB8.CB8_FILIAL  =  %xFilial:CB8%
	                   AND CB8.CB8_ORDSEP  =  %Exp:_cOrdSep%
	                   AND CB8.%NotDel%
	               ) CB8FIL        ON CB8FIL.CB8_PEDIDO  = SC9.C9_PEDIDO
	                              AND CB8FIL.CB8_ITEM    = SC9.C9_ITEM
	                              AND CB8FIL.CB8_PROD    = SC9.C9_PRODUTO
	                              AND CB8FIL.CB8_LOTECT  = SC9.C9_LOTECTL
	                              AND CB8FIL.CB8_ORDSEP  = SC9.C9_ORDSEP
	    INNER JOIN %table:SC6% SC6 (NOLOCK) ON SC6.C6_FILIAL      = %xFilial:SC6%
	                              AND SC6.C6_NUM         = SC9.C9_PEDIDO
	                              AND SC6.C6_PRODUTO     = SC9.C9_PRODUTO
	                              AND SC6.C6_ITEM        = SC9.C9_ITEM
	                              AND SC6.%NotDel%
	    INNER JOIN %table:SC5% SC5 (NOLOCK) ON SC5.C5_FILIAL      = %xFilial:SC5%
	                  	          AND SC5.C5_LIBEROK    <> %Exp:'E'%
	 	                          AND SC5.C5_BLQ         = %Exp:''%
	                              AND SC5.C5_NUM         = SC9.C9_PEDIDO
	                              AND SC5.%NotDel%
	WHERE SC9.C9_FILIAL  =  %xFilial:SC9%
	  AND SC9.C9_NFISCAL =  %Exp:''%
	  AND SC9.C9_BLEST   =  %Exp:''%
	  AND SC9.C9_BLOQUEI =  %Exp:''%
	  AND SC9.%NotDel%
	ORDER BY C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_LOTECTL
EndSql
*/
//Trecho alterado devido a implanta็ใo da rastreabilidade - Livia Della Corte
BeginSql Alias _cSC9TMP
	SELECT SC9.*, SC9.R_E_C_N_O_ RECSC9, SC5.*, SC5.R_E_C_N_O_ RECSC5, SC6.*, SC6.R_E_C_N_O_ RECSC6
	FROM %table:SC9% SC9 (NOLOCK)
	    INNER JOIN (
	                 SELECT DISTINCT CB9_ORDSEP, CB9_PEDIDO, CB9_ITESEP, CB9_PROD, CB9_LOTECT//, CB9_SEQUEN
	                 FROM %table:CB9% CB9 (NOLOCK)
	                 WHERE CB9.CB9_FILIAL  =  %xFilial:CB9%
	                   AND CB9.CB9_ORDSEP  =  %Exp:_cOrdSep%
	                   AND CB9.%NotDel%
					 GROUP BY CB9_ORDSEP, CB9_PEDIDO, CB9_ITESEP, CB9_PROD, CB9_LOTECT
	               ) CB9FIL        ON CB9FIL.CB9_PEDIDO  = SC9.C9_PEDIDO
	                             // AND CB9FIL.CB9_SEQUEN    = SC9.C9_SEQUEN
								  AND CB9FIL.CB9_ITESEP    = SC9.C9_ITEM
	                              AND CB9FIL.CB9_PROD    = SC9.C9_PRODUTO
	                              AND CB9FIL.CB9_LOTECT  = SC9.C9_LOTECTL
	                              AND CB9FIL.CB9_ORDSEP  = SC9.C9_ORDSEP
	    INNER JOIN %table:SC6% SC6 (NOLOCK) ON SC6.C6_FILIAL      = %xFilial:SC6%
	                              AND SC6.C6_NUM         = SC9.C9_PEDIDO
	                              AND SC6.C6_PRODUTO     = SC9.C9_PRODUTO
	                              AND SC6.C6_ITEM        = SC9.C9_ITEM
	                              AND SC6.%NotDel%
	    INNER JOIN %table:SC5% SC5 (NOLOCK) ON SC5.C5_FILIAL      = %xFilial:SC5%
	                  	          AND SC5.C5_LIBEROK    <> %Exp:'E'%
	 	                          AND SC5.C5_BLQ         = %Exp:''%
	                              AND SC5.C5_NUM         = SC9.C9_PEDIDO
	                              AND SC5.%NotDel%
	WHERE SC9.C9_FILIAL  =  %xFilial:SC9%
	  AND SC9.C9_NFISCAL =  %Exp:''%
	  AND SC9.C9_BLEST   =  %Exp:''%
	  AND SC9.C9_BLOQUEI =  %Exp:''%
	  AND SC9.%NotDel%
	ORDER BY C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_LOTECTL, CB9_ITESEP
EndSql
MemoWrite("\2.MemoWrite\ACD\QUERY\"+_cRotina+"_ordemSep_"+_cOrdSep+"_QRY_LINHA2073.TXT",GetLastQuery()[02])																										   
_cTESPADQ := GetMV("MV_TESPADQ")
_cTESPADV := GetMV("MV_TESPADV")
_aRecSC6  := {}
dbSelectArea(_cSC9TMP)
(_cSC9TMP)->(dbGoTop())
if _lContinua := !(_cSC9TMP)->(EOF())
	GetMv("MV_NUMITEN",.T.) ; SX6->(MsRUnLock()) ; SX6->(FkCommit())
	nItemNfb    := a460NumIt(cSerieb)			//Numero de itens por controle CD
	if ( GetMv("MV_NUMITEN",.T.) )
		SX6->(MsRUnLock())
	endif
	SX6->(FkCommit())
	nItemNf     := a460NumIt(cSerie)			//Numero de itens por Nota Fiscal
	if ( GetMv("MV_NUMITEN",.T.) )
		SX6->(MsRUnLock())
	endif
	SX6->(FkCommit())
	while !(_cSC9TMP)->(EOF()) .AND. _lContinua
		if aScan(_aRecSC6,{|x|x[01]==(_cSC9TMP)->RECSC6}) == 0
			SC6->(dbSetOrder(1))
			SC6->(dbGoTo((_cSC9TMP)->RECSC6))
			AADD(_aRecSC6,{(_cSC9TMP)->RECSC6,SC6->C6_PRUNIT,SC6->C6_PRCVEN,SC6->C6_TES,SC6->C6_DESCONT,SC6->C6_VALDESC})
		endif
		dbSelectArea(_cSC9TMP)
		(_cSC9TMP)->(dbSkip())
	enddo
	BEGIN TRANSACTION
		If Len(_aRecSC6) > 0
			_cQry   := " UPDATE " + RetSqlName("SC6")
			_cQry   += " SET C6_PRUNIT    = 0, "
			_cQry   += "     C6_DESCONT   = 0, "
			_cQry   += "     C6_VALDESC   = 0  "
			//Inํcio - Trecho adicionado por Adriano Leonardo em 12/05/2014 para preservar os campos C6_PRUNIT e C6_DESCONT
			dbSelectArea("SC6")		
			If SC6->(FieldPos("C6_PRCTAB"))>0 .AND. SC6->(FieldPos("C6_PERCDES"))>0
				_cQry   += ",    C6_PRCTAB	= C6_PRUNIT  "
				_cQry   += ",    C6_PERCDES	= C6_DESCONT "
			EndIf
			//Final  - Trecho adicionado por Adriano Leonardo em 12/05/2014 para preservar os campos C6_PRUNIT e C6_DESCONT
			_cQry   += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND R_E_C_N_O_ IN ('"
			for _xC6 := 1 to len(_aRecSC6)
				If _xC6 > 1
					_cQry += ",'"
				EndIf
				_cQry += cValToChar(_aRecSC6[_xC6][01]) + "'"
			next
			_cQry   += ")"
		//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_007.TXT",_cQry)
			If TCSQLExec(_cQry) < 0
				If _lACD
					VTAlert("[TCSQLError] " + TCSQLError(),"Aviso",.T.)
				Else
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_028")
				EndIf
			EndIf
			dbSelectArea("SC6")
			TcRefresh("SC6")
		EndIf
		dbSelectArea(_cSC9TMP)
		(_cSC9TMP)->(dbGoTop())
		While !(_cSC9TMP)->(EOF()) .AND. _lContinua
			_aSvSC9 := {}
			SC9->(dbSetOrder(1)         )
			SC9->(dbGoTo((_cSC9TMP)->RECSC9))
			SC5->(dbSetOrder(1)         )
			SC5->(dbGoTo((_cSC9TMP)->RECSC5))
			If SC5->C5_TIPO $ "D/B"
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				SA2->(MsSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
			Else
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
				MV_PAR17 := VAL(SA1->A1_EMGNRE)								//Gera Tํtulo a Pagar de ST?	Baseado no mesmo conte๚do do campo Emite GNRE: 1=Sim, 2=Nใo
				MV_PAR18 := VAL(SA1->A1_EMGNRE)								//Emite GNRE: 1=Sim, 2=Nใo
			EndIf
			SC6->(dbSetOrder(1))
			SC6->(dbGoTo((_cSC9TMP)->RECSC6) )
			SE4->(dbSetOrder(1))
			SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG,.T.,.F.))				//FILIAL+CONDICAO PAGTO
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO,.T.,.F.))				//FILIAL+PRODUTO
			SB2->(dbSetOrder(1))
			SB2->(MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.T.,.F.))	//FILIAL+PRODUTO+LOCAL
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES,.T.,.F.))					//FILIAL+TES
			//ANมLISE DE ESTOQUE
			_lSldEst := .T.
			
			If AllTrim(SF4->F4_ESTOQUE) == "S"
				dbSelectArea("SB2")
				_aSvB2 := SB2->(GetArea())
				SB2->(dbSetOrder(1))
				If (_lSldEst := SB2->(MsSeek(xFilial("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL,.T.,.F.)))
					_lSldEst := SB2->B2_QATU >= SC9->C9_QTDLIB
				EndIf
				If !_lSldEst
					_nPItNeg := aScan(_aItNeg,{|x| x[01]==SC9->C9_PRODUTO .AND.x[02]==SC9->C9_LOCAL .AND. x[04]==SC9->C9_LOTECTL})
					If _nPItNeg == 0
						AADD(_aItNeg,{SC9->C9_PRODUTO,SC9->C9_LOCAL,SC9->C9_QTDLIB,SC9->C9_LOTECTL})
					Else
						_aItNeg[_nPItNeg][03] += SC9->C9_QTDLIB
					EndIf
				EndIf
				RestArea(_aSvB2)
			EndIf
			
			//Controle CD
			_lQuant   := .T.
			_lCalcula := .F.
			_nFator   := 1
			If SC5->(FieldPos("C5_TPDIV"))>0 .AND. AllTrim(SC5->C5_TIPO) == "N" .AND. (!Empty(SF4->F4_TESALTQ) .OR. !Empty(SF4->F4_TESALTV))
				//A1_TPDIV: 0=0;1=33,33;2=50;3=66,66;4=100;5=DUPLO		{%Normal}
				If SC5->C5_TPDIV == "0" .OR. SC5->C5_TPDIV == "4"
					_lQuant   := .T.
					_lCalcula := .F.
					_nTipDiv  := 0
				ElseIf SC5->C5_TPDIV == "1"
					_nFator   := 0.3333
					_lCalcula := .T.
					_lQuant   := AllTrim(SC6->C6_TPCALC) == "Q"
					_nTipDiv  := 1
				ElseIf SC5->C5_TPDIV == "2"
					_nFator   := 0.5
					_lCalcula := .T.
					_lQuant   := AllTrim(SC6->C6_TPCALC) == "Q"
					_nTipDiv  := 2
				ElseIf SC5->C5_TPDIV == "3"
					_nFator   := 0.6666
					_lCalcula := .T.
					_lQuant   := AllTrim(SC6->C6_TPCALC) == "Q"
					_nTipDiv  := 3
				ElseIf SC5->C5_TPDIV == "5"
					_nFator   := 0.5
					_lCalcula := .T.
					_lQuant   := .T.
					_nTipDiv  := 5
				EndIf
				If _lCalcula
					//Preservo a SC9 corrente
					SC9->(dbSetOrder(1))
					SC9->(dbGoTo((_cSC9TMP)->RECSC9) )
					_cAliasSX3B := GetNextAlias()
					if Select(_cAliasSX3B) > 0
						(_cAliasSX3B)->(dbCloseArea())
					endif
					OpenSxs(,,,,FWCodEmp(),_cAliasSX3B,"SX3",,.F.)
					dbSelectArea(_cAliasSX3B)
					(_cAliasSX3B)->(dbSetOrder(1))
					If (_cAliasSX3B)->(MsSeek("SC9",.T.,.F.))
						While !(_cAliasSX3B)->(EOF()) .AND. AllTrim((_cAliasSX3B)->X3_ARQUIVO) == "SC9"
							If (_cAliasSX3B)->X3_CONTEXT <> "V" //.AND. X3USO(X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
								AADD(_aSvSC9,{("SC9->"+AllTrim((_cAliasSX3B)->X3_CAMPO)),&("SC9->"+AllTrim((_cAliasSX3B)->X3_CAMPO))})
							EndIf
							dbSelectArea(_cAliasSX3B)
							(_cAliasSX3B)->(dbSetOrder(1))
							(_cAliasSX3B)->(dbSkip())
						EndDo
					EndIf
					(_cAliasSX3B)->(dbCloseArea())
				EndIf
			EndIf
			If _nFator == 0
				_nFator := 1
			EndIf
			_nExec := 0
			If Len(_aSvSC9) > 0
				_nExec := 2
			Else
				_nExec := 1
			EndIf
			_nQuant  := SC9->C9_QTDLIB
			_nQuantA := 0
			_nPreco  := Round(SC9->C9_PRCVEN,2)
			_nPrecoA := 0
			for _pNf := 1 To _nExec
				If _lCalcula
					If _pNf == 1
						dbSelectArea("SC9")
						while !RecLock("SC9",.F.) ; enddo
						If _lQuant
							_nQuantA       := Round(_nQuant * _nFator,0 )					//a410Arred(_nQuant * _nFator,"D2_QUANT" )		//A410Arred(xMoeda(SC6->C6_PRCVEN,SC5->C5_MOEDA,1,dDataBase,8)*(SC6->C6_QTDVEN-SC6->C6_QTDENT),"D2_TOTAL")
							If _nQuantA <= 0
								_nQuantA := _nQuant
							EndIf
							SC9->C9_QTDLIB := _nQuantA
						Else
							_nPrecoA       := Round(a410Arred(_nPreco * _nFator,"D2_PRCVEN"),2)		//A410Arred(xMoeda(SC6->C6_PRCVEN,SC5->C5_MOEDA,1,dDataBase,8)*(SC6->C6_QTDVEN-SC6->C6_QTDENT),"D2_TOTAL")
							If _nPrecoA <= 0
								_nPrecoA := _nPreco
							EndIf
							SC9->C9_PRCVEN := Round(_nPrecoA,2)
							//Guarda a quantidade do registro da SC9 para posterior estorno, uma vez que a divisใo foi no valor e a quantidade serแ movimentada (no campo C6_QTDENT) duas vezes. Entใo, hแ o estorno, para a movimenta็ใo correta somente no registro final.
							AADD(_aEstornQ,{(_cSC9TMP)->RECSC6,SC9->C9_QTDLIB,SC9->C9_QTDLIB2,.T.})
						EndIf
						SC9->(MSUNLOCK())
					Else
						dbSelectArea("SF4")
						SF4->(dbSetOrder(1))
						_cTESAltQ := SF4->F4_TESALTQ
						_cTESAltV := SF4->F4_TESALTV
						If _lQuant
							If (_nQuant - _nQuantA) <= 0
								Exit
							EndIf
							If !SF4->(MsSeek(xFilial("SF4") + _cTESAltQ,.T.,.F.))
								SF4->(MsSeek(xFilial("SF4") + AllTrim(_cTESPADQ),.T.,.F.)) // TES padrao para as quebras de quantidade	//AllTrim(SuperGetMV("MV_TESPADQ",,"901"))
							EndIf
						Else
							If (_nPreco - _nPrecoA) <= 0
								Exit
							EndIf
							If !SF4->(MsSeek(xFilial("SF4") + _cTESAltV,.T.,.F.))
								SF4->(MsSeek(xFilial("SF4") + AllTrim(_cTESPADV),.T.,.F.)) // TES padrao para as quebras em valor		//AllTrim(SuperGetMV("MV_TESPADV",,"906"))
							EndIf
						EndIf
						_cSeq := StrZero(1,len(SC9->C9_SEQUEN))
						BeginSql Alias "SC9SEQ"
							SELECT MAX(SC9.C9_SEQUEN) C9_SEQUEN
							FROM %table:SC9% SC9 (NOLOCK)
							WHERE SC9.C9_FILIAL  =  %xFilial:SC9%
							  AND SC9.C9_PEDIDO  =  %Exp:SC9->C9_PEDIDO %
							  AND SC9.C9_ITEM    =  %Exp:SC9->C9_ITEM   %
							  AND SC9.C9_PRODUTO =  %Exp:SC9->C9_PRODUTO%
							  --AND SC9.C9_LOTECTL =  %Exp:SC9->C9_LOTECTL%	  
							  AND SC9.%NotDel%
						EndSql
					//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_008.TXT",GetLastQuery()[02])
						dbSelectArea("SC9SEQ")
						If !SC9SEQ->(EOF()) .AND. !Empty(SC9SEQ->C9_SEQUEN)
							_cSeq := Soma1(SC9SEQ->C9_SEQUEN)
						EndIf
						dbSelectArea("SC9SEQ")
						SC9SEQ->(dbCloseArea())
						dbSelectArea("SC9")
						while !RecLock("SC9",.T.) ; enddo
							for _c9 := 1 to len(_aSvSC9)
								If AllTrim(_aSvSC9[_c9][01]) == "SC9->C9_SEQUEN"
									&(_aSvSC9[_c9][01]) := _cSeq
								Else
									&(_aSvSC9[_c9][01]) := _aSvSC9[_c9][02]
								EndIf
							next
							// - Trecho adicionar em 29/04/2014 por J๚lio Soares - trecho para grava็ใo de flag na SC9
		//					If SC9->(FieldPos("C9_MARCKNF"))>0
		//						SC9->(C9_MARCKNF) := '*'
							If SC9->(FieldPos("C9_MARKNF"))>0
								SC9->C9_MARKNF := '*'
							EndIf
							// - -------------------------------------------------------------------------------------
							If _lQuant
								SC9->C9_QTDLIB := a410Arred(_nQuant - _nQuantA,"D2_QUANT" )		//A410Arred(xMoeda(SC6->C6_PRCVEN,SC5->C5_MOEDA,1,dDataBase,8)*(SC6->C6_QTDVEN-SC6->C6_QTDENT),"D2_TOTAL")
							Else
								SC9->C9_PRCVEN := Round(a410Arred(_nPreco - _nPrecoA,"D2_PRCVEN"),2)		//A410Arred(xMoeda(SC6->C6_PRCVEN,SC5->C5_MOEDA,1,dDataBase,8)*(SC6->C6_QTDVEN-SC6->C6_QTDENT),"D2_TOTAL")
							EndIf
						EndIf
						SC9->C9_TES := SF4->F4_CODIGO
					SC9->(MSUNLOCK())
				EndIf
				nPrcVen  := Round(SC9->C9_PRCVEN,2)
				If ( SC5->C5_MOEDA <> 1 )
					nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
				EndIf
				//CONOUT(ALLTRIM(STR(SC9->C9_QTDLIB)+"-"+SC9->C9_NFISCAL))
				If AllTrim(SF4->F4_MIGRA) == "S"
					Aadd(aPvlNfs,{ SC9->C9_PEDIDO,;
										SC9->C9_ITEM,;
										STRZERO((VAL(SC9->C9_SEQUEN)+1),2),;
										SC9->C9_QTDLIB,;
										nPrcVen,;
										SC9->C9_PRODUTO,;
										.F.,;
										SC9->(Recno()),;
										SC5->(RecNo()),;
										SC6->(RecNo()),;
										SE4->(RecNo()),;
										SB1->(RecNo()),;
										SB2->(RecNo()),;
										SF4->(RecNo()) } )
					//QUEBRA A NF
					//nItemNfb    := a460NumIt(cSerieb)			//Numero de itens por controle CD
					//nItemNf     := a460NumIt(cSerie)			//Numero de itens por Nota Fiscal
					//If ( GetMv("MV_NUMITEN",.T.) )
					//	SX6->(MsRUnLock())
					//EndIf
					If ( Len(aPvlNfs) > nItemNf )
						_cQry   := " UPDATE SC6 "
						_cQry   += " SET C6_TES = F4_CODIGO "
						_cQry   += " FROM " + RetSqlName("SC6")+ " SC6 "
						_cQry   += "     INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' "
						_cQry   += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND ("
						for _xF := 1 to len(aPvlNfs)
							If _xF > 1
								_cQry   += "   OR "
							EndIf
							_cQry   += "     ( SC6.R_E_C_N_O_ = "  + cValToChar(aPvlNfs[_xF][10]) + "  "
							_cQry   += "   AND SF4.R_E_C_N_O_ = "  + cValToChar(aPvlNfs[_xF][14]) + ") "
						next
						_cQry   += ") "
					//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_009.TXT",_cQry)
						If TCSQLExec(_cQry) < 0
							If _lACD
								VTAlert("Aten็ใo!!! Problemas no ajuste do TES nos documentos de saํda. Por favor, confira os documentos gerados! Abaixo, veja o erro gerado pela fun็ใo [TCSQLError]:"+_CLRF+TCSQLError(),"Aviso",.T.)
							Else
								MsgStop("Aten็ใo!!! Problemas no ajuste do TES nos documentos de saํda. Por favor, confira os documentos gerados! Abaixo, veja o erro gerado pela fun็ใo [TCSQLError]:"+_CLRF+TCSQLError(),_cRotina+"_037")
							EndIf
						EndIf
						dbSelectArea("SC6")
						//_aSvC6Upd := SC6->(GetArea())
						TcRefresh("SC6")
						//SC6->(dbGoTop())
						//RestArea(_aSvC6Upd)
						//Guardo os parโmetros e refa็o para que o faturamento nใo saia prejudicado
							_aParBkp  := {}
							_nContPar := 1
							While &(_bTIPO) <> "U"
								AADD(_aParBkp,{("MV_PAR"+StrZero(_nContPar,2)),&("MV_PAR"+StrZero(_nContPar,2))})
								_nContPar++
							EndDo
							for _ft := 1 to len(_aPMT460A)
								&("MV_PAR"+StrZero(_ft,2)) := _aPMT460A[_ft]
								If _lRCFGASX1
									U_RCFGASX1(cPerg, StrZero(_ft,2), _aPMT460A[_ft])
								EndIf
							next
						//Fim da Guarda dos parโmetros
						//Faturamento
	//					cNota := MaPvlNfs(aPvlNfs, cSerie ,lMostraCtb  ,lAglutCtb   ,lCtbOnLine  ,lCtbCusto   ,lReajusta   ,nCalAcrs ,nArredPrcLis, lAtuSA7    ,lECF        ,cEmbExp,,,,,dDataMoe)
						lMsErroauto := .F.
						cNota := MaPvlNfs(aPvlNfs, cSerie , MV_PAR01==1, MV_PAR02==1, MV_PAR03==1, MV_PAR04==1, MV_PAR05==1, MV_PAR07, MV_PAR08   , MV_PAR15==1, MV_PAR16==2,       ,,,,,MV_PAR21)
	//					P11:	 MaPvlNfs(aPvlNfs, cSerie , MV_PAR01==1, MV_PAR02==1, MV_PAR03==1, MV_PAR04==1, MV_PAR05==1, MV_PAR07, MV_PAR08   , MV_PAR15==1, MV_PAR16==2)
	//					P12:	 MaPvlNfs(aPvlNfs,cSerieNFS,lMostraCtb  ,lAglutCtb   ,lCtbOnLine  ,lCtbCusto   ,lReajuste   ,nCalAcrs ,nArredPrcLis,lAtuSA7     ,lECF        ,cEmbExp,bAtuFin,bAtuPGerNF,bAtuPvl,bFatSE1,dDataMoe)					
						if lMsErroauto
							if _lACD
								VTDispFile(NomeAutoLog(),.T.)
							else
								MostraErro()
							endif
							MsUnLockAll()
							DisarmTransaction()
							Break
							//RollbackSx8()
							_lContinua := .F.
							return _lContinua
						else
							//ConfirmSx8()
						endif
						
						//Inํcio - Trecho adicionado por Adriano Leonardo em 24/02/2014 para bloquear a transmissใo de notas antes da remontagem de parcelas
							while !Reclock("SF2",.F.) ; enddo
								SF2->F2_BLQ     := "S"
								If SF2->(FieldPos("F2_NOMCONF"))<>0
									SF2->F2_NOMCONF := _cCodConf + " - " + _cNomConf
								EndIf
							SF2->(MsUnLock())
						//Final  - Trecho adicionado por Adriano Leonardo em 24/02/2014 para bloquear a transmissใo de notas antes da remontagem de parcelas
						//	cNota := MaPvlNfs(aPvlNfs, cSerie, lMostraCtb , lAglutCtb  , lCtbOnLine , lCtbCusto  , lReajusta  , nCalAcrs,nArredPrcLis, lAtuSA7    , lECF       )
						//Retomo os parโmetros anteriormente preservados
						_nContPar := 1
						for _nParBk := 1 to len(_aParBkp)
							&(_aParBkp[_nParBk][01]) := _aParBkp[_nParBk][02]
						next
						//Fim da Retomada dos parโmetros anteriormente preservados
						_cNotaAux := cNota
						_cRoman   := cNota
						aPvlNfs   := {}
						If Empty(cNota)
							_lContinua := .F.
		//					Exit
						Else
							AADD(_aNotas,{cNota, cSerie})
							If _ImprEtVol .AND. _lRFATR040 //Impressใo das Etiquetas de Volume
								ExecBlock("RFATR040")
							EndIf
						EndIf
					EndIf
				Else
					Aadd(aPvlNfsb,{ SC9->C9_PEDIDO,;
										SC9->C9_ITEM,;
										STRZERO((VAL(SC9->C9_SEQUEN)+1),2),;
										SC9->C9_QTDLIB,;
										nPrcVen,;
										SC9->C9_PRODUTO,;
										.F.,;
										SC9->(Recno()),;
										SC5->(RecNo()),;
										SC6->(RecNo()),;
										SE4->(RecNo()),;
										SB1->(RecNo()),;
										SB2->(RecNo()),;
										SF4->(RecNo()) } )
					//QUEBRA A NF
					//nItemNfb    := a460NumIt(cSerieb)			//Numero de itens por controle CD
					//nItemNf     := a460NumIt(cSerie)			//Numero de itens por Nota Fiscal
					//If ( GetMv("MV_NUMITEN",.T.) )
					//	SX6->(MsRUnLock())
					//EndIf
					If ( Len(aPvlNfsb) > nItemNfb )
						for _Es := 1 to len(_aEstornQ)
							_cQry   := " UPDATE " + RetSqlName("SC6")
							_cQry   += " SET C6_QTDENT    = C6_QTDENT  - " + cValToChar(_aEstornQ[_Es][02])  + ", "
							_cQry   += "     C6_QTDENT2   = C6_QTDENT2 - " + cValToChar(_aEstornQ[_Es][03])  + ", "
							_cQry   += "     C6_QTDEMP    = C6_QTDEMP  + " + cValToChar(_aEstornQ[_Es][02])  + ", "
							_cQry   += "     C6_QTDEMP2   = C6_QTDEMP2 + " + cValToChar(_aEstornQ[_Es][03])
							_cQry   += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND R_E_C_N_O_ = " + cValToChar(_aEstornQ[_Es][01])
						//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_010.TXT",_cQry)
							If TCSQLExec(_cQry) < 0
								If _lACD
									VTAlert("Aten็ใo!!! Problemas no ajuste dos documentos de saํda. Por favor, contate imediatamente o administrador e lhe passe a seguintes informa็๕es: " + _CRLF + "Recno SC6 " + cValToChar(_aEstornQ[_Es][01]) + _CRLF + " Qtde. " + cValToChar(_aEstornQ[_Es][02]) + _CRLF + "Mensagem " + _cRotina+"_030. Erro [TCSQLError]: "+_CLRF+TCSQLError(),"Aviso",.T.)
								Else
									MsgStop("Aten็ใo!!! Problemas no ajuste dos documentos de saํda. Por favor, contate imediatamente o administrador e lhe passe a seguintes informa็๕es: " + _CRLF + "Recno SC6 " + cValToChar(_aEstornQ[_Es][01]) + _CRLF + " Qtde. " + cValToChar(_aEstornQ[_Es][02]) + _CRLF + "Mensagem " + _cRotina+"_030. Erro [TCSQLError]: "+_CLRF+TCSQLError(),_cRotina+"_030")
								EndIf
								_aEstornQ[_Es][Len(_aEstornQ[_Es])] := .F.
							EndIf
							dbSelectArea("SC6")
							//_aSvC6Upd := SC6->(GetArea())
							TcRefresh("SC6")
							//SC6->(dbGoTop())
							//RestArea(_aSvC6Upd)
						next
						_cQry   := " UPDATE SC6 "
						_cQry   += " SET C6_TES = F4_CODIGO "
						_cQry   += " FROM " + RetSqlName("SC6")+ " SC6 "
						_cQry   += "     INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' " 
						_cQry   += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND ("
						for _xF := 1 to len(aPvlNfsb)
							If _xF > 1
								_cQry   += "   OR "
							EndIf
							_cQry   += "     ( SC6.R_E_C_N_O_ = "  + cValToChar(aPvlNfsb[_xF][10]) + "  "
							_cQry   += "   AND SF4.R_E_C_N_O_ = "  + cValToChar(aPvlNfsb[_xF][14]) + ") "
						next
						_cQry   += ")"
					//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_011.TXT",_cQry)
						If TCSQLExec(_cQry) < 0
							If _lACD
								VTAlert("Aten็ใo!!! Problemas no ajuste do TES nos documentos de saํda. Por favor, confira os documentos gerados! Erro [TCSQLError]: "+_CLRF+TCSQLError(),"Aviso",.T.)
							Else
								MsgStop("Aten็ใo!!! Problemas no ajuste do TES nos documentos de saํda. Por favor, confira os documentos gerados! Erro [TCSQLError]: "+_CLRF+TCSQLError(),_cRotina+"_035")
							EndIf
						EndIf
						dbSelectArea("SC6")
						//_aSvC6Upd := SC6->(GetArea())
						TcRefresh("SC6")
						//SC6->(dbGoTop())
						//RestArea(_aSvC6Upd)
						//Guardo os parโmetros e refa็o para que o faturamento nใo saia prejudicado
							_aParBkp  := {}
							_nContPar := 1
							While &(_bTIPO) <> "U"
								AADD(_aParBkp,{("MV_PAR"+StrZero(_nContPar,2)),&("MV_PAR"+StrZero(_nContPar,2))})
								_nContPar++
							EndDo
							for _ft := 1 to len(_aPMT460A)
								&("MV_PAR"+StrZero(_ft,2)) := _aPMT460A[_ft]
								If _lRCFGASX1
									U_RCFGASX1(cPerg, StrZero(_ft,2), _aPMT460A[_ft])
								EndIf
							next
						//Fim da Guarda dos parโmetros
						//Faturamento
						lMsErroauto := .F.
//						cNota := MaPvlNfs(aPvlNfsb, cSerieb, MV_PAR01==1, MV_PAR02==1, MV_PAR03==1, MV_PAR04==1, MV_PAR05==1, MV_PAR07, MV_PAR08   , MV_PAR15==1, MV_PAR16==2)
						cNota := MaPvlNfs(aPvlNfsb, cSerieb, MV_PAR01==1, MV_PAR02==1, MV_PAR03==1, MV_PAR04==1, MV_PAR05==1, MV_PAR07, MV_PAR08   , MV_PAR15==1, MV_PAR16==2,       ,,,,,MV_PAR21)
						if lMsErroauto
							if _lACD
								VTDispFile(NomeAutoLog(),.T.)
							else
								MostraErro()
							endif
							MsUnLockAll()
							DisarmTransaction()
							Break
							//RollbackSx8()
							_lContinua := .F.
							return _lContinua
						else
							//ConfirmSx8()
						endif
						
						//Inํcio - Trecho adicionado por Adriano Leonardo em 24/02/2014 para bloquear a transmissใo de notas antes da remontagem de parcelas
							while !RecLock("SF2",.F.) ; enddo
								if SF2->(FieldPos("F2_BLQ"))>0
									SF2->F2_BLQ     := "S"
								endif
								If SF2->(FieldPos("F2_NOMCONF"))>0
									SF2->F2_NOMCONF := _cCodConf + " - " + _cNomConf
								EndIf
							SF2->(MsUnLock())
						//Final  - Trecho adicionado por Adriano Leonardo em 24/02/2014 para bloquear a transmissใo de notas antes da remontagem de parcelas
					//	cNota := MaPvlNfs(aPvlNfsb, cSerieb, lMostraCtb , lAglutCtb  , lCtbOnLine , lCtbCusto  , lReajusta  , nCalAcrs,nArredPrcLis, lAtuSA7    , lECF       )
						//Retomo os parโmetros anteriormente preservados
						_nContPar   := 1
						for _nParBk := 1 to len(_aParBkp)
							&(_aParBkp[_nParBk][01]) := _aParBkp[_nParBk][02]
						next
						//Fim da Retomada dos parโmetros anteriormente preservados
						_cRoman   := cNota
						aPvlNfsb  := {}
						_aEstornQ := {}
						/*	
						//Trecho adicionado por Adriano Leonardo em 24/06/2013/////
						CalcPeso()
				
						If _nPLiqu > 0 .And. _nPsBrut > 0
							while !RecLock("SC5",.F.) ; enddo
								SC5->C5_PESOL  := _nPLiqu
								SC5->C5_PBRUTO := _nPsBrut
							SC5->(MsUnlock())
						EndIf				
						*/
						///////////////////////////////////////////////////////////
						If Empty(cNota)
							_lContinua := .F.
		//					Exit
						Else
							AADD(_aNotas,{cNota, cSerieb})
							If _ImprEtVol .AND. _lRFATR040	//Impressใo das Etiquetas de Volume
								ExecBlock("RFATR040")
							EndIf
						EndIf
					EndIf
				EndIf
			next
			/*
			Aadd(aPvlNfs,{ SC9->C9_PEDIDO,;
													SC9->C9_ITEM,;
													SC9->C9_SEQUEN,;
													SC9->C9_QTDLIB,;
													nPrcVen,;
													SC9->C9_PRODUTO,;
													.F.,;
													SC9->(Recno()),;
													SC5->(RecNo()),;
													SC6->(RecNo()),;
													SE4->(RecNo()),;
													SB1->(RecNo()),;
													SB2->(RecNo()),;
													SF4->(RecNo()) } )	
			*/				  
			dbSelectArea(_cSC9TMP)
			(_cSC9TMP)->(dbSkip())
		EndDo
		If Len(aPvlNfs) > 0
			_cQry   := " UPDATE SC6 "
			_cQry   += " SET C6_TES = F4_CODIGO "
			_cQry   += " FROM " + RetSqlName("SC6")+ " SC6 "
			_cQry   += "     INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' "
			_cQry   += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND ("
			for _xF := 1 to len(aPvlNfs)
				If _xF > 1
					_cQry   += "   OR "
				EndIf
				_cQry   += "     ( SC6.R_E_C_N_O_ = "  + cValToChar(aPvlNfs[_xF][10]) + "  "
				_cQry   += "   AND SF4.R_E_C_N_O_ = "  + cValToChar(aPvlNfs[_xF][14]) + ") "
			next
			_cQry   += ")"
		//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_012.TXT",_cQry)
			If TCSQLExec(_cQry) < 0
				If _lACD
					VTAlert("Aten็ใo!!! Problemas no ajuste do TES nos documentos de saํda. Por favor, confira os documentos gerados! Erro [TCSQLError]: "+_CLRF+TCSQLError(),"Aviso",.T.)
				Else
					MsgStop("Aten็ใo!!! Problemas no ajuste do TES nos documentos de saํda. Por favor, confira os documentos gerados! Erro [TCSQLError]: "+_CLRF+TCSQLError(),_cRotina+"_038")
				EndIf
			EndIf
			dbSelectArea("SC6")
			//_aSvC6Upd := SC6->(GetArea())
			TcRefresh("SC6")
			//SC6->(dbGoTop())
			//RestArea(_aSvC6Upd)
			//Guardo os parโmetros e refa็o para que o faturamento nใo saia prejudicado
				_aParBkp  := {}
				_nContPar := 1
				While &(_bTIPO) <> "U"
					AADD(_aParBkp,{("MV_PAR"+StrZero(_nContPar,2)),&("MV_PAR"+StrZero(_nContPar,2))})
					_nContPar++
				EndDo
				for _ft := 1 to len(_aPMT460A)
					&("MV_PAR"+StrZero(_ft,2)) := _aPMT460A[_ft]
					If _lRCFGASX1
						U_RCFGASX1(cPerg, StrZero(_ft,2), _aPMT460A[_ft])
					EndIf
				next
			//Fim da Guarda dos parโmetros
			//Faturamento
				cNota := MaPvlNfs(aPvlNfs, cSerie , MV_PAR01==1, MV_PAR02==1, MV_PAR03==1, MV_PAR04==1, MV_PAR05==1, MV_PAR07, MV_PAR08   , MV_PAR15==1, MV_PAR16==2,       ,,,,,MV_PAR21)
			//	cNota := MaPvlNfs(aPvlNfs, cSerie , MV_PAR01==1, MV_PAR02==1, MV_PAR03==1, MV_PAR04==1, MV_PAR05==1, MV_PAR07, MV_PAR08   , MV_PAR15==1, MV_PAR16==2)
			//			 MaPvlNfs(aPvlNfs,cSerieNFS,lMostraCtb  ,lAglutCtb   ,lCtbOnLine  ,lCtbCusto   ,lReajuste   ,nCalAcrs ,nArredPrcLis,lAtuSA7     ,lECF        ,cEmbExp,bAtuFin,bAtuPGerNF,bAtuPvl,bFatSE1,dDataMoe)
			//Fim do faturamento
			
			//Inํcio - Trecho adicionado por Adriano Leonardo em 24/02/2014 para bloquear a transmissใo de notas antes da remontagem de parcelas
				while !RecLock("SF2",.F.) ; enddo
					SF2->F2_BLQ     := "S"
					If SF2->(FieldPos("F2_NOMCONF"))<>0
						SF2->F2_NOMCONF := _cCodConf + " - " + _cNomConf
					EndIf
				SF2->(MsUnLock())
			//Final  - Trecho adicionado por Adriano Leonardo em 24/02/2014 para bloquear a transmissใo de notas antes da remontagem de parcelas		
		//	cNota := MaPvlNfs(aPvlNfs, cSerie, lMostraCtb , lAglutCtb  , lCtbOnLine , lCtbCusto  , lReajusta  , nCalAcrs,nArredPrcLis, lAtuSA7    , lECF       )
			//Retomo os parโmetros anteriormente preservados
			_nContPar := 1
			for _nParBk := 1 to len(_aParBkp)
				&(_aParBkp[_nParBk][01]) := _aParBkp[_nParBk][02]
			next
			//Fim da Retomada dos parโmetros anteriormente preservados
			_cNotaAux := cNota
			aPvlNfs   := {}
			If Empty(cNota)
				_lContinua := .F.
			Else
				AADD(_aNotas,{cNota, cSerie})
				If _ImprEtVol .AND. ExistBlock("RFATR040")	//Impressใo das Etiquetas de Volume
					ExecBlock("RFATR040")
					_lImpZZZ := .F.
				EndIf
			EndIf
		EndIf
		If Len(aPvlNfsb) > 0
			for _Es := 1 to len(_aEstornQ)
				_cQry   := " UPDATE " + RetSqlName("SC6")
				_cQry   += " SET C6_QTDENT    = C6_QTDENT  - " + cValToChar(_aEstornQ[_Es][02])  + ", "
				_cQry   += "     C6_QTDENT2   = C6_QTDENT2 - " + cValToChar(_aEstornQ[_Es][03])  + ", "
				_cQry   += "     C6_QTDEMP    = C6_QTDEMP  + " + cValToChar(_aEstornQ[_Es][02])  + ", "
				_cQry   += "     C6_QTDEMP2   = C6_QTDEMP2 + " + cValToChar(_aEstornQ[_Es][03])
				_cQry   += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND R_E_C_N_O_ = " + cValToChar(_aEstornQ[_Es][01])
			//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_013.TXT",_cQry)
				If TCSQLExec(_cQry) < 0
					If _lACD
						VTAlert("Aten็ใo!!! Problemas no ajuste dos documentos de saํda. Por favor, contate imediatamente o administrador e lhe passe a seguintes informa็๕es: " + _CRLF + "Recno SC6 " + cValToChar(_aEstornQ[_Es][01]) + _CRLF + " Qtde. " + cValToChar(_aEstornQ[_Es][02]) + _CRLF + "Mensagem " + _cRotina+"_036. Erro [TCSQLError]: "+_CLRF+TCSQLError(),"Aviso",.T.)
					Else
						MsgStop("Aten็ใo!!! Problemas no ajuste dos documentos de saํda. Por favor, contate imediatamente o administrador e lhe passe a seguintes informa็๕es: " + _CRLF + "Recno SC6 " + cValToChar(_aEstornQ[_Es][01]) + _CRLF + " Qtde. " + cValToChar(_aEstornQ[_Es][02]) + _CRLF + "Mensagem " + _cRotina+"_036. Erro [TCSQLError]: "+_CLRF+TCSQLError(),_cRotina+"_036")
					EndIf
					_aEstornQ[_Es][Len(_aEstornQ[_Es])] := .F.
				EndIf
				dbSelectArea("SC6")
				//_aSvC6Upd := SC6->(GetArea())
				TcRefresh("SC6")
				//SC6->(dbGoTop())
				//RestArea(_aSvC6Upd)
			next
			_cQry   := " UPDATE SC6 "
			_cQry   += " SET C6_TES = F4_CODIGO "
			_cQry   += " FROM " + RetSqlName("SC6")+ " SC6 "
			_cQry   += "     INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' "
			_cQry   += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND ("
			for _xF := 1 to len(aPvlNfsb)
				If _xF > 1
					_cQry   += "   OR "
				EndIf
				_cQry   += "     ( SC6.R_E_C_N_O_ = "  + cValToChar(aPvlNfsb[_xF][10]) + "  "
				_cQry   += "   AND SF4.R_E_C_N_O_ = "  + cValToChar(aPvlNfsb[_xF][14]) + ") "
			next
			_cQry   += ")"

			If TCSQLExec(_cQry) < 0
				_cQry+=_CLRF+TCSQLError() 
				MemoWrite("\2.MemoWrite\ACD\ERRO\"+_cRotina+"_upd_014.TXT",_cQry)
			EndIf
			dbSelectArea("SC6")
			//_aSvC6Upd := SC6->(GetArea())
			TcRefresh("SC6")
			//SC6->(dbGoTop())
			//RestArea(_aSvC6Upd)
			//Guardo os parโmetros e refa็o para que o faturamento nใo saia prejudicado
				_aParBkp  := {}
				_nContPar := 1
				While &(_bTIPO) <> "U"
					AADD(_aParBkp,{("MV_PAR"+StrZero(_nContPar,2)),&("MV_PAR"+StrZero(_nContPar,2))})
					_nContPar++
				EndDo
				for _ft := 1 to len(_aPMT460A)
					&("MV_PAR"+StrZero(_ft,2)) := _aPMT460A[_ft]
					If _lRCFGASX1
						U_RCFGASX1(cPerg, StrZero(_ft,2), _aPMT460A[_ft])
					EndIf
				next
			//Fim da Guarda dos parโmetros
			//Faturamento
			lMsErroauto := .F.
			cNota := MaPvlNfs(aPvlNfsb, cSerieb, MV_PAR01==1, MV_PAR02==1, MV_PAR03==1, MV_PAR04==1, MV_PAR05==1, MV_PAR07, MV_PAR08   , MV_PAR15==1, MV_PAR16==2,       ,,,,,MV_PAR21)
		//	cNota := MaPvlNfs(aPvlNfsb, cSerieb, MV_PAR01==1, MV_PAR02==1, MV_PAR03==1, MV_PAR04==1, MV_PAR05==1, MV_PAR07, MV_PAR08   , MV_PAR15==1, MV_PAR16==2)
			if lMsErroauto
				if _lACD
					VTDispFile(NomeAutoLog(),.T.)
				else
					MostraErro()
				endif
				MsUnLockAll()
				DisarmTransaction()
				Break
				//RollbackSx8()
				_lContinua := .F.
				return _lContinua
			else
				//ConfirmSx8()
			endif
			//Inํcio - Trecho adicionado por Adriano Leonardo em 24/02/2014 para bloquear a transmissใo de notas antes da remontagem de parcelas
				while !RecLock("SF2",.F.) ; enddo
					SF2->F2_BLQ     := "S"
					If SF2->(FieldPos("F2_NOMCONF"))<>0
						SF2->F2_NOMCONF := _cCodConf + " - " + _cNomConf
					EndIf
				SF2->(MsUnlock())
			//Final  - Trecho adicionado por Adriano Leonardo em 24/02/2014 para bloquear a transmissใo de notas antes da remontagem de parcelas
		//	cNota := MaPvlNfs(aPvlNfsb, cSerieb, lMostraCtb , lAglutCtb  , lCtbOnLine , lCtbCusto  , lReajusta  , nCalAcrs,nArredPrcLis, lAtuSA7    , lECF       )
			//Retomo os parโmetros anteriormente preservados
			_nContPar := 1
			for _nParBk := 1 to len(_aParBkp)
				&(_aParBkp[_nParBk][01]) := _aParBkp[_nParBk][02]
			next
			//Fim da Retomada dos parโmetros anteriormente preservados
			_cRoman   := cNota
			aPvlNfsb  := {}
			_aEstornQ := {}
			/*	
			//Trecho adicionado por Adriano Leonardo em 24/06/2013/////
			CalcPeso()
			If _nPLiqu > 0 .And. _nPsBrut > 0
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_PESOL  := _nPLiqu
					SC5->C5_PBRUTO := _nPsBrut
				SC5->(MsUnlock())
			EndIf				
			///////////////////////////////////////////////////////////
			*/
			If Empty(cNota)
				_lContinua := .F.
			Else
				AADD(_aNotas,{cNota, cSerieb})
				If _ImprEtVol .AND. ExistBlock("RFATR040") .AND. _lImpZZZ	//Impressใo das Etiquetas de Volume
					ExecBlock("RFATR040")
				EndIf
			EndIf
		EndIf
		//Restauro o pre็o de tabela original
		for _xC6 := 1 to len(_aRecSC6)
			_cQry   := " UPDATE " + RetSqlName("SC6")
			_cQry   += " SET C6_PRUNIT    = " + cValToChar(_aRecSC6[_xC6][02]) + ", "
			_cQry   += "     C6_PRCVEN    = " + cValToChar(_aRecSC6[_xC6][03]) + ", "
			_cQry   += "     C6_TES       = " + cValToChar(_aRecSC6[_xC6][04]) + ", "
			_cQry   += "     C6_DESCONT   = " + cValToChar(_aRecSC6[_xC6][05]) + ", "
			_cQry   += "     C6_VALDESC   = " + cValToChar(_aRecSC6[_xC6][06])			
			_cQry   += " WHERE C6_FILIAL  = '"+xFilial("SC6")+"' AND R_E_C_N_O_ = " + cValToChar(_aRecSC6[_xC6][01])
		//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_015.TXT",_cQry)
			If TCSQLExec(_cQry) < 0
				If _lACD
					VTAlert("Aten็ใo!!! O pre็o de tabela do Recno " + cValToChar(_aRecSC6[_xC6][01]) + " (anote o recno, o pre็o de tabela [" + cValToChar(_aRecSC6[_xC6][02]) + "] e o pre็o do pedido [" + cValToChar(_aRecSC6[_xC6][03]) + "]) nใo foi restaurado, devido ao seguinte erro:" + _CRLF + "[TCSQLError] " + TCSQLError(),"Aviso",.T.)
				Else
					MsgStop("Aten็ใo!!! O pre็o de tabela do Recno " + cValToChar(_aRecSC6[_xC6][01]) + " (anote o recno, o pre็o de tabela [" + cValToChar(_aRecSC6[_xC6][02]) + "] e o pre็o do pedido [" + cValToChar(_aRecSC6[_xC6][03]) + "]) nใo foi restaurado, devido ao seguinte erro:" + _CRLF + "[TCSQLError] " + TCSQLError(),_cRotina+"_029")
				EndIf
			EndIf
			dbSelectArea("SC6")
			//_aSvC6Upd := SC6->(GetArea())
			TcRefresh("SC6")
			//SC6->(dbGoTop())
			//RestArea(_aSvC6Upd)
		next
	END TRANSACTION
	dbUnLockAll()
Else
	_lContinua := .F.
	If _lACD
		VTAlert("Aten็ใo!!! Nenhum Documento de Saํda gerado!","Aviso",.T.)
	Else
		MsgStop("Aten็ใo!!! Nenhum Documento de Saํda gerado!",_cRotina+"_033")
	EndIf
EndIf
dbSelectArea(_cSC9TMP)
(_cSC9TMP)->(dbCloseArea())
//Apresentacao de mensagem com os itens que geraram estoque negativo apos o faturamento
If Len(_aItNeg) > 0 .AND. !_lACD
	_cArqLog := GetTempPath()+"EstNeg_"+DTOS(Date())+StrTran(Time(),":","")+".txt"
	If Len(_aItNeg) > 1
		_cMsgNeg := "Aten็ใo!!! Os seguintes itens deixaram o ESTOQUE NEGATIVO no sistema. Por favor, informe o responsแvel, imediatamente! " + _CRLF
	Else
		_cMsgNeg := "Aten็ใo!!! O seguinte item deixou o seu ESTOQUE NEGATIVO no sistema. Por favor, informe o responsแvel imediatamente! "  + _CRLF
	EndIf
	If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
		_cMsgNeg += "Produto           Arm      Quantidade" + _CRLF
		_cMsgNeg += "---------------   ---      ----------" + _CRLF
		
			//   012345678901234567890123456789012345678901234567890
			//   0         10        20        30        40        50
			//   XXXXXXXXXXXXXXX   XX   999,999,999.99
	Else
		_cMsgNeg += "Produto        " + _CRLF
		_cMsgNeg += "---------------" + _CRLF
	EndIf			
	for _Neg := 1 to len(_aItNeg)
        If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
			_cMsgNeg += _aItNeg[_Neg][01] + Space(03) + _aItNeg[_Neg][02] + Space(03) + Transform(_aItNeg[_Neg][03],"@E 999,999,999.99") + _CRLF
        Else 
        	_cMsgNeg += _aItNeg[_Neg][01] + Space(03) + _CRLF
        EndIf
	next
	If !Empty(_cMsgNeg)
		If _lACD
			VTAlert(_cMsgNeg,"Aviso",.T.)
		Else
			MemoWrite(_cArqLog,_cMsgNeg)
			MsgAlert("ARQUIVO SALVO: " + _cArqLog + _CRLF + _cMsgNeg,_cRotina+"_041")
		EndIf
	EndIf
EndIf
//l460Acres  := .F. //Desativa os tratamentos do fonte M460ACRE
/* 
// Inํcio - O trecho a seguir foi substituํdo de lugar por Adriano Leonardo em 04/11/2013 por conta de integridade da rotina
If Len(_aNotas) > 0
	_cMsgNfF := "Os seguintes documentos de saํda foram gerados com sucesso: " + _CRLF
	for _NFg := 1 to len(_aNotas)
		_cMsgNfF += Space(5) + _aNotas[_NFg][01] + _CRLF
	next
	MsgInfo(_cMsgNfF,_cRotina+"_056")
EndIf
// Final - Trecho substituํdo de lugar por Adriano Leonardo em 04/11/2013 por conta de integridade da rotina 
/*
/*
//Trecho comentado em 25/06/2013, por conta de inconsist๊ncia encontrada no romaneio
//Corrige os pesos bruto e lํquido da nota
_cUpd := "UPDATE " + RetSqlName("SF2") + " SET "
_cUpd += "F2_PBRUTO=(SELECT F2_PBRUTO FROM " + RetSqlName("SF2") + " WHERE F2_DOC='" + _cRoman + "' AND F2_SERIE='" + SuperGetMV("MV_SERFATZ",,"ZZZ") + "' AND D_E_L_E_T_='' AND F2_FILIAL='" + xFilial("SF2") + "'), "
_cUpd += "F2_PLIQUI=(SELECT F2_PLIQUI FROM " + RetSqlName("SF2") + " WHERE F2_DOC='" + _cRoman + "' AND F2_SERIE='" + SuperGetMV("MV_SERFATZ",,"ZZZ") + "' AND D_E_L_E_T_='' AND F2_FILIAL='" + xFilial("SF2") + "')  "
_cUpd += "FROM " + RetSqlName("SF2") + " SF2 "
_cUpd += "WHERE SF2.F2_DOC='" + _cNotaAux + "' "
_cUpd += "AND SF2.F2_SERIE='" + SuperGetMV("MV_SERFATA",,"1" ) + "' "
_cUpd += "AND SF2.D_E_L_E_T_ = '' "
_cUpd += "AND SF2.F2_FILIAL  = '" + xFilial("SF2") + "' "     
_cUpd += "AND (SELECT COUNT(*) FROM " + RetSqlName("SF2") + " WHERE F2_DOC='" + _cRoman + "' AND F2_SERIE='" + SuperGetMV("MV_SERFATZ",,"ZZZ") + "' AND D_E_L_E_T_='' AND F2_FILIAL='" + xFilial("SF2") + "')>0  "
If TCSQLExec(_cUpd) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_049")
EndIf
*/
_nDiv    := _nTipDiv
_cNtAcd  := _cNotaAux
_lACD	 := IIF(AllTrim(FunName())== "ACDV166" .OR. AllTrim(FunName())== "U_RACDV166",.T.,.F.)
If _lACD
	PesoNota(_lACD, _nTipDiv)
Else
	//MsgRun("Aguarde... Calculando o peso...",cCadastro,{ || _cCalc := PesoNota(_lACD) })
	MsgRun("Aguarde... Calculando o peso...",cCadastro,{ || PesoNota(_lACD) })
EndIf
// Inํcio - O trecho a seguir foi substituํdo de lugar por Adriano Leonardo em 04/11/2013 por conta de integridade da rotina
If Len(_aNotas) > 0
	_cMsgNfF := "Os seguintes documentos de saํda foram gerados com sucesso: " + _CRLF
	for _NFg := 1 to len(_aNotas)
		_cMsgNfF += Space(5) + _aNotas[_NFg][01] + _CRLF
		//CUSTOM. ALL - DATA: 18/06/2015 - INอCIO - AUTOR: JฺLIO SOARES
			// - (NHR) - Nใo Houve Remontagem
			// - (RPF) - Remontagem Parcela Finalizado
			// - Trecho inserido para inserir valida็ใo de seguran็a para a remontagem de parcelas
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1))
			If SF2->(MsSeek( xFilial("SF2") + _aNotas[_NFg][01] + _aNotas[_NFg][02],.T.,.F.))
				while !RecLock("SF2",.F.) ; enddo
					SF2->F2_REMPARC := "NHR"
				SF2->(MSUNLOCK())
			Else
				If _lACD
					VTAlert("Documento nใo encontrado. INFORME O ADMINISTRADOR DO SISTEMA","Aviso",.T.)
				Else
					MSGBOX("Documento nใo encontrado. INFORME O ADMINISTRADOR DO SISTEMA", _cRotina + " _063","ALERT")
				EndIf
			EndIf
		//CUSTOM. ALL - DATA: 18/06/2015 - FIM - AUTOR: JฺLIO SOARES		
	next
	If _lACD
		VTAlert(_cMsgNfF,"Aviso",.T.)
	Else
		MsgInfo(_cMsgNfF,_cRotina+"_056")
	EndIf
EndIf
// Final - Trecho substituํdo de lugar por Adriano Leonardo em 04/11/2013 por conta de integridade da rotina 

RestArea(_aSavAr)

return _lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณCancel    บAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina que trata do cancelamento da tela dialog        บฑฑ
ฑฑบ          ณprincipal.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function Cancel()
	Local _lEnt  := CHR(10) + CHR(13)
	Local _cLogx := ""

	If !_lVisual .AND. _lAlter
		If MsgYesNo("Tem certeza de que deseja cancelar?",_cRotina+"_015")
			dbSelectArea("CB7")
			CB7->(dbSetOrder(1))
			If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
				while !RecLock("CB7",.F.) ; enddo
					CB7->CB7_STATPA := "0"		//(Pausado): 0-Nao,1-Sim
					CB7->CB7_STATUS := "0"		//(Pausado): 0-Nao,1-Sim
				CB7->(MSUNLOCK())
			EndIf
		EndIf
	Else
		dbSelectArea("CB7")
		CB7->(dbSetOrder(1))
		If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
	// - Alterado por J๚lio Soares em 06/01/2014 para que ordens de separa็ใo nใo sejam canceladas por engano.
	//		MSGBOX("A ordem de separa็ใo " + _cOrdSep + " poderแ ser estornada." ,_cRotina + "_016","ALERT")
			If MSGBOX("Tem certeza que deseja estornar a ordem de separa็ใo " + _cOrdSep + " ?" ,_cRotina + "_016","YESNO")
				while !RecLock("CB7",.F.) ; enddo
					CB7->CB7_STATPA := "0"		//(Pausado): 0-Nao,1-Sim
					CB7->CB7_STATUS := "0"		//(Pausado): 0-Nao,1-Sim
				CB7->(MSUNLOCK())
				_cLogx := "Ordem de separa็ใo " + _cOrdSep + " estornada."
				MSGBOX(_cLogx,_cRotina + "_016","INFO")
				// - Trecho inserido em 17/06/2015 por J๚lio Soares para implementa็ใo de melhoria.
				SUA->(dbOrderNickName("UA_NUMSC5"))
				If SUA->(MsSeek(xFilial("SUA") + SC9->C9_PEDIDO,.T.,.F.))
					while !RecLock("SUA", .F.) ; enddo
						If SUA->(FieldPos("UA_LOGSTAT"))>0
							_cLog           := Alltrim(SUA->UA_LOGSTAT)
							SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
												UsrRetName(__cUserId) + _lEnt + _cLogx
						EndIf
					SUA->(MsUnLock())
				EndIf
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				If SC5->(MsSeek(xFilial("SC5") + SC5->C5_NUM,.T.,.F.))
					If SC5->(FieldPos("C5_LOGSTAT"))>0
						_cLog := Alltrim(SC5->C5_LOGSTAT)
						while !RecLock("SC5",.F.) ; enddo
							SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
												UsrRetName(__cUserId) + _lEnt + _cLogx
						SC5->(MsUnLock())
					EndIf
				EndIf
				//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
				If !Empty(_cLogx) .AND. ExistBlock("RFATL001")
					U_RFATL001(	SC5->C5_NUM ,;
								SUA->UA_NUM,;
								_cLogx     ,;
								_cRotina    )
				EndIf
				// - Fim
			EndIf
		EndIf
	EndIf
	//If Type("oDlg")=="O"
		Close(oDlg)
		_lRetFun  := .F.
		//FreeObj(oDlg)
		//oDlg := NIL
	//EndIf
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณCheckInt  บAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina de checagem da integridade dos campos e ํndices บฑฑ
ฑฑบ          ณespecํficos da rotina. Ela verifica se os campos e ํndices  บฑฑ
ฑฑบ          ณpodem ser utilizados para a rotina.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function CheckInt()
	Local _x := 0		  
	Local _aSavArCK := GetArea()
	Local _lRet     := .T.
	Local _aInd     := {}
	//Private _x        := 0
	Private _aCpos    := {}

	//CAMPOS --> TABELA, CAMPO           , DESCRIวรO DO CAMPO
	AADD(_aCpos,{"SB1" ,"SB1->B1_VOPRIN" ,"Quantidade relativa ao C๓digo de Barras 1"                })
	AADD(_aCpos,{"SB1" ,"SB1->B1_VOSEC"  ,"Quantidade relativa ao C๓digo de Barras 2"                })
	AADD(_aCpos,{"SB1" ,"SB1->B1_CODBAR2","C๓digo de Barras 2"                                       })
	AADD(_aCpos,{"CB7" ,"CB7->CB7_OBS1"  ,"Observa็๕es da Ordem de Separa็ใo"                        })
	AADD(_aCpos,{"CB7" ,"CB7->CB7_CODOP2","C๓digo do Operador 2 [Conferente]"                        })
	AADD(_aCpos,{"CB7" ,"CB7->CB7_NOMOP2","Nome do Operador 2 [Conferente]"                          })

	//อNDICES --> TABELA, NICKNAME   ,CHAVE
	AADD(_aInd ,{"SB1"  ,"B1_CODBAR2","B1_FILIAL+B1_CODBAR2"                                         })
	AADD(_aInd ,{"CB8"  ,"CB8_PROD"  ,"CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8_LOTECT+CB8_LCALIZ+CB8_ITEM"})

	_bCpo :=  "Type(_aCpos[_x][02])"

	for _x := 1 to len(_aCpos)
		dbSelectArea(_aCpos[_x][01])
		If &(_bCpo) == "U"
			MsgStop("Aten็ใo! Falha de integridade. O campo '" + _aCpos[_x][02] + "' (" + _aCpos[_x][03] + ") nใo foi encontrado na base de dados de produtos. Por favor, informe o Admnistrador!",_cRotina+"_011")
			_lRet := .F.
		EndIf
	next
	for _x := 1 to len(_aInd)
		dbSelectArea(_aInd[_x][01])
		If Empty(dbNickIndexKey(_aInd[_x][02]))
			MsgStop("Aten็ใo! O NickName '" + _aInd[_x][02] + "' com a chave '" + _aInd[_x][03] + "', nใo foi localizado. Por favor, informe o Administrador!",_cRotina+"_012")
			_lRet := .F.
		EndIf
	next
	RestArea(_aSavArCK)
return _lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณNotaFiscalบAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Sub-Rotina para a chamada da rotina automแtica de          บฑฑ
ฑฑบ          ณfaturamento.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function NotaFiscal(_nOpcFat)
	U_RFATA02F(_nOpcFat,_cOrdSep,_cRotina,_nVol1,_cEspec,_cPedVen,.F.)
return
//Parโmetros a serem passados para a fun็ใo U_RFATA02F (nesta ordem):
//     1- _nOpcFat : Op็ใo de faturamento, sendo 1 para Faturamento Direto (botใo Gera NF, pulando o processo de confer๊ncia); 2 para faturamento ap๓s o processo de confer๊ncia
//     2- _cNumOS  : N๚mero da Ordem de Separa็ใo
//     3- _cFNam   : FunName da rotina original
//     4- _nV1     : N๚mero de volumes (gravado ou nใo na SC5)
//     5- _cE1     : Esp้cie relacionada aos volumes (gravado ou nใo na SC5)
//     6- _lAcd    : Indica que a rotina foi acionada pelo SIGAACD 
user function RFATA02F(_nOpcFat,_cNumOS,_cFNam,_nV1,_cE1,_cPedido,_lAcd)
	local   _aSavArNF  := GetArea()
	local   _aSSC5     := SC5->(GetArea())
	local   _aSCB7     := CB7->(GetArea())
	local   _aSCB8     := CB8->(GetArea())
	local   _lFat      := .T.
	local   _lParc     := .T.
	local   _nCont     := 0
//	local   _nSecs     := 0
	local   _Neg       := 0
	local   _cMsgNeg   := ""
	local   _cSB2TMP   := GetNextAlias()
	private _aNotas    := {}
	private _nVol1	   := _nV1
	private _nPLiq	   := 0
	private _nPLiqu    := 0
	private _nPBrut	   := 0
	private _nPsBrut   := 0
	private	_cPedVen   := _cPedido
	private _cCodConf  := "" //__cUserId
	private _cNomConf  := "" //"USER - " + cUserName
	private _cNota     := ""
	private _cSerie    := ""
	private _nItNF     := 0
	private _lAutFat   := .T.
	private _cUSRFATA  := GetMV("MV_USRFATA")
	private _cArqLog := ""
	private cCadastro:= "Expedi็ใo"
	default _nOpcFat   := 2
	default _cNumOS    := ""
	default _cFNam     := AllTrim(FunName())
	default _nV1       := 0
	default _cE1       := "" 
	default _cPedido   := ""
	default _lAcd      := .F.

	If type("_cOrdSep")=="U"
		_cOrdSep := _cNumOS
	EndIf
	If type("_cRotina")=="U"
		_cRotina := "RFATA002"
	EndIf

	If type("_cEspec")=="U"
		_cEspec  := _cE1
	EndIf
	dbSelectArea("CB1")
	CB1->(dbSetOrder(2))
	If CB1->(MsSeek(xFilial("CB1") + __cUserId,.T.,.F.))
		_cCodConf := CB1->CB1_CODOPE
		_cNomConf := "OPER - " + CB1->CB1_NOME
	EndIf
	If !Empty(_cOrdSep)
		dbSelectArea("CB7")
		CB7->(dbSetOrder(1))
		If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
			If AllTrim(FunName()) == "ACDV166" .OR. AllTrim(FunName()) == "U_RACDV166"
				_lSolicVol := .F.
			EndIf
			If _lSolicVol
		 		_nVol1 := Volume() //Linha adicionada por Adriano Leonardo em 27/11/2013 para melhoria na rotina
		 	EndIf
	 		If (_lFat := _nVol1 > 0 .AND. !Empty(_cEspec)) //.AND. MsgYesNo("Confirma a informa็ใo do volume? " + _CRLF + cValToChar(_nVol1) + "  " + AllTrim(_cEspec) + ".",_cRotina+"_047"))
				dbSelectArea("CB8")                          
				CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
				If AllTrim(AllTrim(FunName())) == _cFNam .AND. CB8->(MsSeek(xFilial("CB8") + _cOrdSep,.T.,.F.))
					While !CB8->(EOF()) .AND. CB8->CB8_FILIAL == xFilial("CB8") .AND. CB8->CB8_ORDSEP == _cOrdSep
						dbSelectArea("SC5")
						SC5->(dbSetOrder(1))
						If SC5->(MsSeek(xFilial("SC5") + CB8->CB8_PEDIDO,.T.,.F.))
							while !RecLock("SC5",.F.) ; enddo
								SC5->C5_VOLUME1    := _nVol1
								//Trecho adicionado por Adriano Leonardo em 03/07/2013 para que seja priorizada a esp้cie informada no pedido
								If Empty(SC5->C5_ESPECI1)
									SC5->C5_ESPECI1    := _cEspec
								EndIf
		                        // - Trecho inserido por J๚lio Soares para possibilitar a inclusใo manual do peso na gera็ใo do documento utilizando a op็ใo
		                        // "Gera NF" apenas para usuแrios autorizados.
								If __cUserId $ AllTrim(_cUSRFATA) //SuperGetMV("MV_USRFATA",,"000000")
									If _nPLiq > 0 .AND. SC5->C5_PESOL == 0
										SC5->C5_PESOL  := _nPLiq
									Else
										//Linha adicionada por Adriano Leonardo em 24/06/2013 para corre็ใo do peso
										CalcPeso()
										If _nPLiqu > 0
											SC5->C5_PESOL  := _nPLiqu
										EndIf
									EndIf
									If _nPBrut > 0 .AND. SC5->C5_PBRUTO==0
										SC5->C5_PBRUTO := _nPBrut
									Else
										//Linha adicionada por Adriano Leonardo em 24/06/2013 para corre็ใo do peso
										If _nPsBrut > 0
											SC5->C5_PBRUTO := _nPsBrut
										EndIf
									EndIf
								EndIf
							SC5->(MSUNLOCK())
							SC5->(FKCOMMIT())
						EndIf
						dbSelectArea("CB8")
						CB8->(dbOrderNickName("CB8_PROD"))	//CB8_FILIAL+CB8_ORDSEP+CB8_PROD+CB8->CB8_LOTECT+CB8->CB8_LCALIZ+CB8_ITEM
						CB8->(dbSkip())
					EndDo
				EndIf
				//A T E N ว ร O ! ! !
				//Loop de valida็ใo de estoque negativo. Nใo permite que o usuแrio saia do Loop, enquanto a situa็ใo do estoque nใo for regularizada!
				//Em 05/09/2013, o Loop foi desativado pela fun็ใo de autoriza็ใo de estoque negativo para faturamento (vide fun็ใo AuthFat())
				_aSvAr    := GetArea()
				_aSvArSX5 := SX5->(GetArea())
				_aSvArCB7 := CB7->(GetArea())
				_aSvArCB8 := CB8->(GetArea())
				_aSvArSB1 := SB1->(GetArea())
				_aSvArSB2 := SB2->(GetArea())
				_aSvArSC5 := SC5->(GetArea())
				_aSvArSC6 := SC6->(GetArea())
				_aSvArSC9 := SC9->(GetArea())
				_aSvArSE4 := SE4->(GetArea())
				_aSvArSF4 := SF4->(GetArea())

///				_cArqLog  := "C:\EstNeg_Loop_"+DTOS(Date())+StrTran(Time(),":","")+".txt"
				_lEstNg   := .T.		//PARA DESATIVAR ESTE TRECHO, COLOCAR .F. NESTA VARIAVEL
				_lAuthEN  := .F.		//Autoriza็ใo para faturamento com estoque negativo
				while (_lEstNg .AND. !_lAuthEN) //.Or. _lReflesh
					_aItNeg   := {}
					_lReflesh := .F.
					if Select(_cSB2TMP) > 0
						(_cSB2TMP)->(dbCloseArea())
					endif
					BeginSql Alias _cSB2TMP
						SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, SUM(C9_QTDLIB) C9_QTDLIB, SC9.C9_LOTECTL
						FROM %table:SC9% SC9 (NOLOCK)
						    INNER JOIN (
						                 SELECT DISTINCT CB9_ORDSEP, CB9_PEDIDO, CB9_ITESEP , CB9_PROD, CB9_LOTECT
						                 FROM %table:CB9% CB9 (NOLOCK) 
						                 WHERE CB9.CB9_FILIAL  =  %xFilial:CB9%
						                   AND CB9.CB9_ORDSEP  =  %Exp:_cOrdSep%
										   AND CB9.%NotDel%
						               ) CB9FIL        ON CB9FIL.CB9_PEDIDO  =  SC9.C9_PEDIDO
						                              AND CB9FIL.CB9_ITESEP    =  SC9.C9_ITEM
						                              AND CB9FIL.CB9_PROD    =  SC9.C9_PRODUTO
						                              AND CB9FIL.CB9_LOTECT  =  SC9.C9_LOTECTL
						                              AND CB9FIL.CB9_ORDSEP  =  SC9.C9_ORDSEP
						    INNER JOIN %table:SB2% SB2 (NOLOCK) ON SB2.B2_FILIAL =  %xFilial:SB2%
						                              AND SB2.B2_COD         =  SC9.C9_PRODUTO
						                              AND SB2.B2_LOCAL       =  SC9.C9_LOCAL
						                              AND SB2.B2_QATU        <  SC9.C9_QTDLIB
													  AND SB2.%NotDel%
						WHERE SC9.C9_FILIAL  =  %xFilial:SC9%
						  AND SC9.C9_NFISCAL =  %Exp:''%
						  AND SC9.C9_BLEST   =  %Exp:''%
						  AND SC9.C9_BLCRED  =  %Exp:''%
						  AND SC9.C9_BLOQUEI =  %Exp:''%
						  AND SC9.%NotDel%
						GROUP BY B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU,SC9.C9_LOTECTL
						ORDER BY B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU,SC9.C9_LOTECTL
					EndSql
				//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_015.TXT",GetLastQuery()[02])
					dbSelectArea(_cSB2TMP)
					(_cSB2TMP)->(dbGoTop())
					While !(_cSB2TMP)->(EOF())	//Se retornar .T., significa que algum item do processo deixarแ o estoque negativo
						AADD(_aItNeg,{(_cSB2TMP)->B2_COD,(_cSB2TMP)->B2_LOCAL,(_cSB2TMP)->B2_QATU,(_cSB2TMP)->C9_QTDLIB,(_cSB2TMP)->C9_LOTECTL})
						(_cSB2TMP)->(dbSkip())
					EndDo
					if Select(_cSB2TMP) > 0
						(_cSB2TMP)->(dbCloseArea())
					endif
					//Apresentacao de mensagem com os itens que geraram estoque negativo apos o faturamento
					If Len(_aItNeg) > 0
						If Len(_aItNeg) > 1
							_cMsgNeg := "Aten็ใo!!! Nใo serแ possํvel gerar o documento de saํda, pois os seguintes itens deixariam o ESTOQUE NEGATIVO no sistema. Por favor, informe o responsแvel imediatamente para a consecu็ใo do processo! " + _CRLF
						Else
							_cMsgNeg := "Aten็ใo!!! Nใo serแ possํvel gerar o documento de saํda, pois o seguinte item deixaria o ESTOQUE NEGATIVO no sistema. Por favor, informe o responsแvel imediatamente para a consecu็ใo do processo! "     + _CRLF
						EndIf
						_cMsgNeg += "Produto           Arm     Sld.Estoque      Necessidade" + _CRLF
						_cMsgNeg += "---------------   ---     -----------      -----------" + _CRLF
								//   0123456789012345678901234567890123456789012345678901234567890
								//   0         10        20        30        40        50        60
								//   XXXXXXXXXXXXXXX   XX   999,999,999.99   999,999,999.99
						for _Neg := 1 to len(_aItNeg)
							_cMsgNeg += _aItNeg[_Neg][01] + Space(03) + _aItNeg[_Neg][02] + Space(03) + Transform(_aItNeg[_Neg][03],"@E 999,999,999.99") + Space(03) + Transform(_aItNeg[_Neg][04],"@E 999,999,999.99") + _CRLF
						next
						If !Empty(_cMsgNeg)
							If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
								MemoWrite("\2.MemoWrite\ACD\"+_cRotina+"_EstNeg_Loop_"+DTOS(Date())+StrTran(Time(),":","")+".txt",_cMsgNeg)
								MsgAlert("ARQUIVO SALVO: " + _cArqLog + _CRLF + _cMsgNeg,_cRotina+"_054")
							Else 
								VTAlert("Nesta O.S existem produtos que deixarใo o estoque negativo, Serแ necessแrio a libera็ใo do responsแvel!","Aviso",.T.)
							EndIf
						EndIf
						//Trecho para a autoriza็ใo de responsแvel para o faturamento negativo
						//A rotina sairแ do loop, com ou sem a autoriza็ใo!
						_lAuthEN := IIF(AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166", AuthFat(), AutACD()) //Linha comentada em 09/09/2013 por Adriano Leonardo para corre็ใo
						Exit
					Else
						_lEstNg  := .F.
						_lAuthEN := .T.
					EndIf
				EndDo
				RestArea(_aSvArSX5)
				RestArea(_aSvArCB7)
				RestArea(_aSvArCB8)
				RestArea(_aSvArSB1)
				RestArea(_aSvArSB2)
				RestArea(_aSvArSC5)
				RestArea(_aSvArSC6)
				RestArea(_aSvArSC9)
				RestArea(_aSvArSE4)
				RestArea(_aSvArSF4)
				RestArea(_aSvAr)
				_aNotas   := {}
				_lGerouNf := .F.
				If !_lEstNg .OR. _lAuthEN
					//CUSTOM. ALL - 22/08/2019 - Anderson C. P. Coelho - LockByName inserido para que nใo haja concorr๊ncia na gera็ใo dos documentos de saํda, evitando assim as duplicidades ou saltos nas numera็๕es, anteriormente percebidas.
					//MsgRun("Aguarde... Processando reserva na rotina de faturamento...",cCadastro,{ || _lGerouNf := ChkLckBN(_nSecs,_cRotina) })
					//BEGIN TRANSACTION
						//Geracao da Nota Fiscal de Saida
						// - 1697 - INSERIR GRAVAวรO DO LOG SF2
						If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166" 
							MsgRun("Aguarde... Gerando o Documento de Saํda...",cCadastro,{ || _lGerouNf := GeraNf() }) 
						Else
							_lGerouNf := GeraNf(.T.)		//.T. significa que a chamada foi feita pelo ACD
						EndIf
					//END TRANSACTION
					//dbUnLockAll()
					//UnLockByName(_cRotina,.T.,.T.)		//CUSTOM. ALL - 22/08/2019 - Anderson C. P. Coelho - UnLockByName inserido para destravar o LockByName inserido para que nใo haja concorr๊ncia na gera็ใo dos documentos de saํda, evitando assim as duplicidades ou saltos nas numera็๕es, anteriormente percebidas.
//				Else
//					_lGerouNf := !_lEstNg
				EndIf
				If _lGerouNf
					//Remontagem das parcelas
					If ExistBlock("RFINE008")
						BEGIN TRANSACTION
							If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
								MsgRun("Aguarde... Avaliando e montando parcelas...",cCadastro,{ || U_RFINE008(_cPedVen,DTOS(dDataBase)) })
							Else
								U_RFINE008(_cPedVen,DTOS(dDataBase))
							EndIf
						END TRANSACTION
						FkCommit()
						//Inํcio - Trecho adicionado por Adriano Leonardo em 23/07/2014 para remontagem de parcelas considerando adiantamentos
							If ExistBlock("RFINE022")
								BEGIN TRANSACTION
									If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
										MsgRun("Aguarde... Avaliando recebimento antecipado...",cCadastro,{ || U_RFINE022(_cPedVen,DTOS(dDataBase),_aNotas) })
									Else
										U_RFINE022(_cPedVen,DTOS(dDataBase),_aNotas)
									EndIf
								END TRANSACTION
								FkCommit()
							EndIf
						//Final  - Trecho adicionado por Adriano Leonardo em 23/07/2014 para remontagem de parcelas considerando adiantamentos
	                    // Inicio - Trecho adcionado por Renan -29/12/2016- Para verificar se as parcelas estใo de acordo com o valor faturado.
							If EXISTBLOCK("RFATE063")
		                    	If U_RFATE063(_cPedVen)
		                    		_lParc := .T.
		                    	Else
		                    		_lParc := .F. 	
		                    	EndIf
		                    EndIf
						//Fim - Trecho adcionado por Renan -29/12/2016 - Para verificar se as parcelas estใo de acordo com o valor faturado
						//Inํcio - Trecho adicionado por Adriano Leonardo em 24/02/2014 para desbloquear a nota para transmissใo
							_aSavTem := SF2->(GetArea())
							for _nCont := 1 to len(_aNotas)
								dbSelectArea("SF2")
								SF2->(dbSetOrder(1))
								If SF2->(dbSeek(xFilial("SF2")+_aNotas[_nCont,1]+_aNotas[_nCont,2]))
									while !RecLock("SF2",.F.) ; enddo
										IF SF2->(FieldPos("F2_BLQ"))>0 .AND. (_lParc .OR. SF2->F2_TIPO $ "DBIP")//valida็ใo para desbloquear a gera็ใo da nota somente se as parcelas x valor faturado estiverem iguais. - Renan 29/12/2016
											SF2->F2_BLQ     := ''
										EndIf
										If SF2->(FieldPos("F2_NOMCONF"))>0
											SF2->F2_NOMCONF := _cCodConf + " - " + _cNomConf
										EndIf
									SF2->(MsUnLock())
									SF2->(FkCommit())
								EndIf
							next
							RestArea(_aSavTem)
						//Final  - Trecho adicionado por Adriano Leonardo em 24/02/2014 para desbloquear a nota para transmissใo
					EndIf
					dbSelectArea("CB7")
					while !RecLock("CB7",.F.) ; enddo
						CB7->CB7_STATUS := "5"
						CB7->CB7_NFEMIT := "1"
						CB7->CB7_NOTA   := _cNota
						CB7->CB7_SERIE  := _cSerie
						CB7->CB7_NUMITE := _nItNF
						CB7->CB7_STATPA := "0"	
						If _nOpcFat == 1		///FATURAMENTO AVULSO
							CB7->CB7_OBS1 := "PROCESSO FATURADO FORA DO PROCESSO DE CONFERสNCIA POR " + __cUserId + " EM " + DTOC(Date()) + " - " + Time() + _CRLF + AllTrim(CB7->CB7_OBS1)
						EndIf
					CB7->(MSUNLOCK())
					CB7->(FkCommit())
					ValidSep(2)
				Else
					dbSelectArea("CB7")
					while !RecLock("CB7",.F.) ; enddo
						CB7->CB7_STATUS := "0"
						CB7->CB7_NFEMIT := "0"
						CB7->CB7_STATPA := "0"	
					CB7->(MSUNLOCK())
					CB7->(FkCommit())
					MsgStop("Problemas na gera็ใo do Documento de Saํda. O processo deverแ ser reiniciado!",_cRotina+"_017")
				EndIf
				If AllTrim(FunName())<>"ACDV166" .AND. AllTrim(FunName())<>"U_RACDV166"
					cMultiGe1 := ""
					cMultiGe2 := ""
					_nTamCBar := 30
					lCont	  := .T.
					_cRotina  := "RFATA002"
					_cOrdSep  := Space(len(CB7->CB7_ORDSEP))
					_cPedVen  := Space(len(CB7->CB7_PEDIDO))
					_cCli     := Space(50)
					_cNumCont := StrZero(1,len(CBG->CBG_CODCON))
					_nPLiq    := 0
					_nPBrut   := 0
					_nQLida   := 0
					_nQtConf  := 1
					_nVol1    := 1
					_cEspec   := Padr("VOLUME(S)",len(SC5->C5_ESPECI1))
					_cCodBar  := Space(_nTamCBar)
					_cCodConf := __cUserId
					_cNomConf := "USER - " + cUserName
					cMultiGe2 := ""
					_cErro1   := "$$ PROD. #@#@#@#@# NรO ENCONTRADO!$$"
					_cErro2   := "$$ PROD. #@#@#@#@# NรO PERTENCE A ESTA SEPAR.!$$"
					_cErro3   := "$$ QTDE. DIVERG. P/ PRODUTO #@#@#@#@#!$$"
					cCadastro := "* * *  E X P E D I ว ร O  * * *"
					_cNota    := ""
					_cSerie   := ""
					_nItNF    := 0
					_nPProd   := 0
					_nPDesc   := 0
					_nPQtde   := 0
					_nPLote   := 0
					_nPEnd    := 0
					_nPVol1   := 0
					_nPObs    := 0
					_nPObsCnf := 0
					_nPArm    := 0
					_nPDt     := 0
					_nPHr     := 0
					_nHandle  := 0
					_nHdlCB   := 0
					_lVisual  := .F.
					_lAlter   := .F.
					_lPesVol  := .F.
					_lGerouNF := .F.
					_lHabPLis := GetMV("MV_PLCONF") //SuperGetMV("MV_PLCONF",,.F.)		//Habilita o tratamento dos itens por volume para o Packing List?
					aFieldFill:= {}
					_nPsBrut  := 0
					_nPLiqu   := 0
					_cNotaAux := ""
					_cRoman	  := ""
					Close(oDlg)
					_lRetFun  := .T.
				EndIf
	//			return
	//			U_RFATA002(_cOrdSep,.F.) // Linha comentada por Adriano Leonardo em 20/12/2013 para corre็ใo na rotina
				//U_RFATA002(_cOrdSep,.T.) // Linha adicionada por Adriano Leonardo em 20/12/2013 para corre็ใo na rotina
			Else
				MsgAlert("Aten็ใo!!! Volume nใo confirmado. Portanto, o faturamento nใo foi processado!",_cRotina+"_048")
				_lGerouNf := .F.
			EndIf
		Else
			MsgAlert("Aten็ใo!!! Ordem de Separa็ใo nใo encontrada!",_cRotina+"_046")
			_lGerouNf := .F.
		EndIf
	Else
		MsgAlert("Aten็ใo!!! Ordem de Separa็ใo nใo informada!",_cRotina+"_045")
		_lGerouNf := .F.
	EndIf
	RestArea(_aSSC5)
	RestArea(_aSCB7)
	RestArea(_aSCB8)
	RestArea(_aSavArNF)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCalcPeso  บAutor  ณAdriano Leonardo    บ Data ณ  01/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recalculo dos pesos liquido e bruto.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function CalcPeso()
	Local _cCliLoj  := GetMV("MV_PESOCLI",,"") //SuperGetMV("MV_PESOCLI",,"")
	Local _cEspecif := IIF(!SC5->(C5_CLIENTE+C5_LOJACLI)$_cCliLoj,GetMV("MV_SERFATZ"),'%SC9.C9_SERIENF%'	)  // SuperGetMV("MV_SERFATZ",,"ZZZ")
	Local _cTMPPES  := GetNextAlias()
	BeginSql Alias _cTMPPES
		SELECT SUM(SC9.C9_QTDLIB* SB1.B1_PESO) AS [PESOLIQU], SUM(SC9.C9_QTDLIB* SB1.B1_PESO)+(SC5.C5_VOLUME1* %Exp:AllTrim(Str(SuperGetMv("MV_FATPBRU",,0.20)))%) + (SC5.C5_VOLUME2* %Exp:AllTrim(Str(SuperGetMv("MV_FATPBRU",,0.20)))%) + (SC5.C5_VOLUME3* %Exp:AllTrim(Str(SuperGetMv("MV_FATPBRU",,0.20)))%) + (SC5.C5_VOLUME4* %Exp:AllTrim(Str(SuperGetMv("MV_FATPBRU",,0.20)))%) AS [PESOBRUT]
		FROM %table:SC9% SC9 (NOLOCK)
			INNER JOIN %table:SC6% SC6 (NOLOCK) ON SC6.C6_FILIAL   = %xFilial:SC6%
	                                  AND SC9.C9_PEDIDO   = SC6.C6_NUM
	                                //AND SC9.C9_ITEM     = SC6.C6_ITEM
	                                  AND SC9.C9_PRODUTO  = SC6.C6_PRODUTO
	                                  AND SC9.C9_LOCAL    = SC6.C6_LOCAL
	                                  AND SC6.%NotDel%
			INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL   = %xFilial:SB1%
	                                  AND SC6.C6_PRODUTO  = SB1.B1_COD
	                                  AND SC6.C6_LOCAL    = SB1.B1_LOCPAD
	                                  AND SB1.%NotDel%
			INNER JOIN %table:SC5% SC5 (NOLOCK) ON SC5.C5_FILIAL   = %xFilial:SC9%
		                              AND SC5.C5_NUM      = SC6.C6_NUM
		                              AND SC5.%NotDel%
		WHERE SC9.C9_FILIAL   = %xFilial:SC9%
		  AND SC9.C9_PEDIDO   = %Exp:_cPedVen%
		  AND SC9.C9_SERIENF  = %Exp:_cEspecif%	// Linha inserida por J๚lio Soares para que o peso dos pedidos da CACAU SHOW sejam calculados normalmente. - Nใo gera peso quando ้ gerado direto
		  AND SC9.%NotDel%
		GROUP BY SC5.C5_VOLUME1, SC5.C5_VOLUME2, SC5.C5_VOLUME3, SC5.C5_VOLUME4
	EndSql
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_016.TXT",GetLastQuery()[02])
	dbSelectArea(_cTMPPES)
	(_cTMPPES)->(dbGoTop())
		_nPsBrut := (_cTMPPES)->PESOBRUT
		_nPLiqu  := (_cTMPPES)->PESOLIQU
	(_cTMPPES)->(dbCloseArea())
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณAuthFat   บAutor  ณAnderson C. P. Coelho บ Data ณ  05/09/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de exig๊ncia de senha para a autoriza็ใo de fatura- บฑฑ
ฑฑบ          ณmento, quando este for deixar o estoque negativo.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function AuthFat()

Local _aSvAF      := GetArea()
Local _aSvAFCB7   := CB7->(GetArea())
Local oButton1AF
//Local oBtnCancel
Local oGroup1AF
Local oSay1AF
Local oSay2AF
Local oGet1AF
Local oGet2AF
Local _lRetAF     := .F.

Private cGet1AF   := Space(30)
Private cGet2AF   := Space(100)

static oDlgAF

  DEFINE MSDIALOG oDlgAF TITLE cCadastro FROM 000, 000  TO 100, 370 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
	oDlgAF:lEscClose := .F.

    @ 004, 005  GROUP oGroup1AF TO 045, 181 PROMPT " Digite a Senha para Liberacao do Faturamento com Estoque Negativo " OF oDlgAF COLOR 0, 16777215 PIXEL
    @ 017, 010    SAY oSay1AF    PROMPT "Usuแrio:"                                       SIZE 025, 007 OF oDlgAF COLORS 0, 16777215          PIXEL
    @ 015, 037  MSGET oGet1AF       VAR cGet1AF  VALID NAOVAZIO()/*.AND.UsrExist(cGet1AF)*/  SIZE 075, 010 OF oDlgAF COLORS 0, 16777215 /*F3 "USR"*/ PIXEL
    @ 030, 010    SAY oSay2AF    PROMPT "Senha:"                                         SIZE 025, 007 OF oDlgAF COLORS 0, 16777215          PIXEL
    @ 030, 037  MSGET oGet2AF       VAR cGet2AF  VALID NAOVAZIO()                        SIZE 075, 010 OF oDlgAF COLORS 0, 16777215 PASSWORD PIXEL
    @ 021, 128 BUTTON oButton1AF PROMPT "Libera" Action (_lRetAF := ValidAuth())         SIZE 037, 012 OF oDlgAF                             PIXEL
//  @ 021, 128 BUTTON oBtnCancel PROMPT "Tentar Novamente" Action (_lRetAF := _lReflesh := .F. .And. Close(oDlgAF))         SIZE 037, 012 OF oDlgAF                             PIXEL

  ACTIVATE MSDIALOG oDlgAF CENTERED

RestArea(_aSvAFCB7)
RestArea(_aSvAF)

return(_lRetAF)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidAuth บAutor  ณAnderson C. P. Coelho บ Data ณ  05/09/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de valida็ใo da senha digitada na rotina AuthFat    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal (AuthFat)                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function ValidAuth()

Local _lValidAF := .F.

If !Empty(cGet1AF) .AND. !Empty(cGet2AF)
	If AllTrim(cGet1AF)$AllTrim(GetMv("MV_AUTESTN"))
		PswOrder(2)
		If PswSeek(AllTrim(cGet1AF),.T.)
			If PswName(AllTrim(cGet2AF))
				dbSelectArea("CB7")
				CB7->(dbSetOrder(1))
				If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
					while !RecLock("CB7",.F.) ; enddo
					CB7->CB7_AUTESN := cGet1AF
					CB7->CB7_DTESTN := Date()
					CB7->CB7_HRESTN := Time()
					CB7->(MSUNLOCK()) 
				EndIf 
				_lValidAF := .T.      
				_lAutFat  := .F.
				If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
					Close(oDlgAF)
				EndIf
			Else
				If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
					MsgAlert("Senha Incorreta!",_cRotina+"_060")
				Else 
				    VtAlert("Senha Incorreta!","AVISO",.T.)
				EndIF
				cGet1AF   := Space(30)
				cGet2AF   := Space(100)
			EndIf
		Else
			If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
				MsgAlert("Usuแrio nใo encontrado!",_cRotina+"_059")
			Else 
			    VtAlert("Usuแrio nใo encontrado!","AVISO",.T.)
			EndIF
			cGet1AF   := Space(30)
			cGet2AF   := Space(100)
		EndIf
	Else
		If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
			MsgAlert("Usuแrio nใo autorizado!",_cRotina+"_058")
		Else
			VtAlert("Usuแrio nใo Autorizado!","AVISO",.T.)
		EndIf
		cGet1AF   := Space(30)
		cGet2AF   := Space(100)
	EndIf
Else
	cGet1AF   := Space(30)
	cGet2AF   := Space(100)
	If AllTrim(FunName())<> "ACDV166" .AND. AllTrim(FunName())<> "U_RACDV166"
		MsgAlert("Preencha as informa็๕es corretamente!",_cRotina+"_057")
    Else 
    	VtAlert("Preencha as informa็๕es corretamente!","AVISO", .T.)
    EndIF
EndIf

return(_lValidAF)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ PesoNota บAutor  ณAdriano Leonardo      บ Data ณ  25/06/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel pelo cแlculo do peso na nota.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal - Uso especํfico Arcolor                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function PesoNota(_lACD,_nTipDiv)
	If _nTipDiv <> 0 .AND. _nTipDiv <> 4
		//Instru็ใo update para corrigir o peso unitแrio dos produtos na SD2
		//Matriz de filtro da SD2 que sera utilizada nas Querys posteriores
		_cQryD2 := " FROM " + RetSqlName("SD2") + " SD2 (NOLOCK) " + _CRLF
		_cQryD2 += "         INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' " + _CRLF
		_cQryD2 += "                            AND SB1.B1_COD     = SD2.D2_COD " + _CRLF
		_cQryD2 += "                            AND SB1.D_E_L_E_T_ = '' " + _CRLF
		_cQryD2 += "         INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' " + _CRLF
		_cQryD2 += "                            AND SF4.F4_CODIGO  = SD2.D2_TES " + _CRLF
		_cQryD2 += "                            AND SF4.D_E_L_E_T_ = '' " + _CRLF
		_cQryD2 += " WHERE SD2.D2_FILIAL  = '" + xFilial("SD2") + "' " + _CRLF
		_cQryD2 += "   AND SD2.D2_TIPO    = 'N' " + _CRLF
		_cQryD2 += "   AND SD2.D2_PEDIDO  = '" + _cPedVen  + "' " + _CRLF
		_cQryD2 += "   AND (  (SD2.D2_DOC = '" + _cNotaAux   + "' AND SD2.D2_SERIE = '" + GetMV("MV_SERFATZ") + "') " + _CRLF     // SuperGetMV("MV_SERFATZ",,"ZZZ")
		_cQryD2 += "        OR " + _CRLF
		_cQryD2 += "          (SD2.D2_DOC = '" + _cNotaAux + "' AND SD2.D2_SERIE = '" + GetMV("MV_SERFATA") + "') " + _CRLF  // SuperGetMV("MV_SERFATA",,"1"  )
		_cQryD2 += "       ) " + _CRLF
		_cQryD2 += "   AND SD2.D_E_L_E_T_ = '' " + _CRLF
		//Atualizo o peso da SD2 somente para os itens que controlam estoque
		_cUpd1 := "UPDATE SD2  SET D2_PESO = (CASE WHEN ISNULL(F4_ESTOQUE,'N') = 'S' THEN ISNULL(B1_PESO,0) ELSE 0 END) " + _CRLF + _cQryD2
		// - LINHA INSERIDA POR JฺLIO SOARES PARA VERIFICAR PARA ARQUIVAR A QUERY EXECUTADA
	//	MemoWrite("\2.MemoWrite\"+_cRotina+"-"+_cNotaAux+"_QRY_017.TXT",_cUpd1)
		If TCSQLExec(_cUpd1) < 0
			If _lACD
				VTAlert("[TCSQLError] " + TCSQLError(),"Aviso",.T.)
			Else
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_050")
			EndIf
		EndIf
		TcRefresh("SD2")
		//Atualizo o peso da SF2 com base nos itens (cadastro de produtos) que controlam estoque (exclusivamente)
		_cUpd2 := " UPDATE SF2 " + _CRLF
		_cUpd2 += " SET F2_PBRUTO = (SELECT SUM((CASE WHEN ISNULL(F4_ESTOQUE,'N') = 'S' THEN ISNULL(B1_PESBRU,0) ELSE 0 END) * D2_QUANT)"+ _cQryD2 + "), " + _CRLF
		_cUpd2 += "     F2_PLIQUI = (SELECT SUM((CASE WHEN ISNULL(F4_ESTOQUE,'N') = 'S' THEN ISNULL(B1_PESO  ,0) ELSE 0 END) * D2_QUANT)"+ _cQryD2 + ")  " + _CRLF
		_cUpd2 += " FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) " + _CRLF
		_cUpd2 += " WHERE SF2.F2_FILIAL  = '" + xFilial("SF2") + "' " + _CRLF
		_cUpd2 += "   AND SF2.F2_TIPO          = 'N' " + _CRLF
		_cUpd2 += "   AND (  (    SF2.F2_DOC   = '" + _cNotaAux + "' " + _CRLF
		_cUpd2 += "           AND SF2.F2_SERIE = '" + GetMV("MV_SERFATA") + "'" + _CRLF   // SuperGetMV("MV_SERFATA",,"1" )
		_cUpd2 += "          ) " + _CRLF
		_cUpd2 += "        OR " + _CRLF
		_cUpd2 += "          (    SF2.F2_DOC   = '" + _cNotaAux + "' " + _CRLF
		_cUpd2 += "           AND SF2.F2_SERIE = '" + GetMV("MV_SERFATZ") + "'" + _CRLF  // SuperGetMV("MV_SERFATZ",,"ZZZ")
		_cUpd2 += "          )" + _CRLF
		_cUpd2 += "       ) " + _CRLF
		_cUpd2 += "   AND SF2.D_E_L_E_T_ = '' " + _CRLF
		// - LINHA INSERIDA POR JฺLIO SOARES PARA VERIFICAR PARA ARQUIVAR A QUERY EXECUTADA
	//	MemoWrite("\2.MemoWrite\"+_cRotina+"-"+_cRoman+"_QRY_018.TXT",_cUpd2)
		If TCSQLExec(_cUpd2) < 0
			If _lACD
				VTAlert("[TCSQLError] " + TCSQLError(),"Aviso",.T.)
			Else
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_051")
			EndIf
		EndIf
		TcRefresh("SFT")
		//Instru็ใo update para corrigir o peso unitแrio na SFT com base na SD2
		_cUpd5 := "UPDATE SFT "
		_cUpd5 += "SET FT_PESO = SD2.D2_PESO "
		_cUpd5 += "FROM " + RetSqlName("SFT") + " SFT (NOLOCK) "
		_cUpd5 += "    INNER JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) ON SD2.D2_FILIAL  = '" + xFilial("SD2") + "' "
		_cUpd5 += "                                            AND SFT.FT_PRODUTO = SD2.D2_COD "
		_cUpd5 += "                                            AND SFT.FT_ITEM    = SD2.D2_ITEM "
		_cUpd5 += "                                            AND SFT.FT_NFISCAL = SD2.D2_DOC "
		_cUpd5 += "                                            AND SFT.FT_SERIE   = SD2.D2_SERIE "
		_cUpd5 += "                                            AND SD2.D_E_L_E_T_ = '' "
		_cUpd5 += "WHERE SFT.FT_FILIAL  = '" + xFilial("SFT") + "' "
		_cUpd5 += "  AND SFT.FT_NFISCAL = '" + _cNotaAux + "' "
		_cUpd5 += "  AND SFT.FT_SERIE   = '" + GetMV("MV_SERFATA") + "' " 		//SuperGetMV("MV_SERFATA",,"1" )
		_cUpd5 += "  AND SFT.FT_PESO   <> SD2.D2_PESO "
		_cUpd5 += "  AND SFT.D_E_L_E_T_ = '' "
		// - LINHA INSERIDA POR JฺLIO SOARES PARA VERIFICAR PARA ARQUIVAR A QUERY EXECUTADA
	//	MemoWrite("\2.MemoWrite\"+_cRotina+"-"+_cNotaAux+"_QRY_019.TXT",_cUpd5)
		If TCSQLExec(_cUpd5) < 0
			If _lACD
				VTAlert("[TCSQLError] " + TCSQLError(),"Aviso",.T.)
			Else
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_054")
			EndIf
		EndIf
		TcRefresh("SFT")
	EndIf	
	//If !Empty(_cNotaAux)
	//	MemoWrite("\2.MemoWrite\"+_cRotina+_cNotaAux,_cNotaAux)
	//EndIf
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ Volume   บAutor  ณ Adriano Leonardo     บ Data ณ  27/11/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ GetDados responsแvel por solicitar o volume da nota na     บฑฑ
ฑฑบ          ณ confirma็ใo da confer๊ncia.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function Volume()

Local oGetv1
Local oGroupv1
Local oSayv1
Local oSButtonv1
Local oSButtonv2

Private _nGetVol  := 0.000

static oDlgv

  DEFINE MSDIALOG oDlgv TITLE "VOLUME"          FROM 000, 000 TO 130, 240                                             COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

    @ 007, 003 GROUP oGroupv1 TO 058, 116 PROMPT " Informe a quantidade de volumes " OF oDlgv                             	COLOR  0, 16777215 PIXEL
    @ 021, 005   SAY   oSayv1 PROMPT "Volumes:"   SIZE 037, 007 OF oDlgv                                                	COLORS 0, 16777215 PIXEL
    @ 019, 045 MSGET   oGetv1    VAR _nGetVol     SIZE 070, 010 OF oDlgv PICTURE PesqPict("SC5","C5_VOLUME1")           VALID NAOVAZIO() .And. ValidVol()  COLORS 0, 16777215 PIXEL
	 
    DEFINE SBUTTON oSButtonv1 FROM 039, 048 TYPE 01 OF oDlgv ENABLE ACTION IIF(MsgYesNo("Confirma a informa็ใo do volume? " + _CRLF + cValToChar(_nGetVol) + "  " + AllTrim(_cEspec) + ".",_cRotina+"_061"),Close(oDlgv),NIL)
    DEFINE SBUTTON oSButtonv2 FROM 039, 048 TYPE 01 OF oDlgv ENABLE ACTION Close(oDlgv)

  ACTIVATE MSDIALOG oDlgv CENTERED
  
return(_nGetVol)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Sepbrowse  บAutor  ณ J๚lio Soares     บ Data ณ  24/06/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina criada para que o conferente informe o separador    บฑฑ
ฑฑบ          ณ responsแvel.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico ARCOLOR                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


// Comentado conforme solicita็ใo do Sr. Ronie, para valida็ใo do processo de separa็ใo antes do processo de confer๊ncia(Nใo precisando mais informar o Separador na hora da confer๊ncia).
static function Sepbrowse()

Local oBut1
Local oBut2
Local oGrp
Local Separador

Private oGet1
Private oGet2                                                       
Private _cGetSep1 := Space(len(CB1->CB1_CODOPE))
Private _cGetSep2 := Space(len(CB1->CB1_NOME  ))

static oDlg1

  DEFINE MSDIALOG oDlg1 TITLE "Informe o separador responsแvel" FROM 000, 000  TO 095, 350 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
	oDlg1:lEscClose := .F.

    @ 005, 002 GROUP oGroup1 TO 030, 172 PROMPT "Separador"                  OF oDlg1 COLOR  0, 16777215                         PIXEL
    @ 012, 005 MSGET oGet1   VAR _cGetSep1                     SIZE 040, 012 OF oDlg1 COLORS 0, 16777215 F3 "CB1A" VALID _cSep() PIXEL
    @ 012, 045 MSGET oGet2   VAR _cGetSep2                     SIZE 125, 012 OF oDlg1 COLORS 0, 16777215 PICTURE "@!" WHEN .F.   PIXEL
    @ 032, 125 BUTTON oButton1           PROMPT "Confirmar"    SIZE 037, 012 OF oDlg1 ACTION Confirma()                          PIXEL

  ACTIVATE MSDIALOG oDlg1 CENTERED

return()
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _cSep   บAutor  ณ J๚lio Soares       บ Data ณ  24/06/14    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina criada para validar se o separador esta cadastrado. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
static function _cSep()
	Local _lRetSep := .F.
	dbSelectArea("CB1")
	CB1->(dbSetOrder(3))
	If CB1->(MsSeek(xFilial("CB1") + _cGetSep1,.T.,.F.))
		_cGetSep2 := CB1->CB1_NOME
		_cGetSep3 := CB1->CB1_CODUSR
		_lRetSep  := .T.
	Else
		_lRetSep  := .F.
		MsgStop("Separador nใo encontrado!",_cRotina+"_062")
	EndIf
return _lRetSep
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Confirma  บAutor  ณ J๚lio Soares      บ Data ณ  24/06/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina criada para confirmar o separador e grava-lo na     บฑฑ
ฑฑบ          ณ ordem de separa็ใo.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// Trecho comentado, para que a grava็ใo dos campos abaixo, seja realizada somente pela Rotina RFATE064(Tela de Inicio e Encerramento das Separa็๕es das O.S's)               
//static function Confirma()
	/*
	If !Empty(_cGetSep1)
		dbSelectArea("CB7")
		CB7->(dbSetOrder(1))
		If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
			while !RecLock("CB7",.F.) ; enddo		
				CB7->CB7_CODOPE := _cGetSep3
				CB7->CB7_NOMOP1 := _cGetSep2
			CB7->(MsUnLock())
		EndIf
		Close(oDlg1)
	EndIf
	*/
	//Close(oDlg1)
//return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ VldEnd  ณ Autor ณ Arthur Silva			 ณ Data ณ07/04/17 ณฑฑ
ฑฑaฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤ ฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฑฑ
ฑฑณDescricao ณ Localiza็ใo: Estแ localizado na fun็ใo FimProcesso         ณฑฑ
ฑฑณ           com o Objetivo de finalizar o processo de separa็ใo         ณฑฑ
ฑฑณ           (para itens separa).Finalidade: Este Ponto de Entrada permiteฑฑ
ฑฑณ           executar rotinas complementares no momento de finalizar o   ณฑฑ
ฑฑณ             processo de separa็ใo, se os itens forem separados.		  ณฑฑ
ฑฑaฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑaฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso ACDV166  ณ Protheus 11    -   Especํfico Arcolor  -  ALL SYSTEM SOLUTIONS ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function VldEnd(_cGetEnd)
	Local _lRet := .F.

	If Empty(_cGetEnd)
		VTAlert("Endere็o nใo pode ser em branco. Informe o Endere็o!","Aviso",.T.)
		If VTLastKey() == 27 .AND. Empty(_cGetEnd)
			VTAlert("Endere็o nใo pode ser em branco. Informe o Endere็o!","Aviso",.T.)
			_lOkEnd := .T.
	    EndIf
	ElseIf VtYesNo("Confirma a inser็ใo do endere็o '" + AllTrim(_cGetEnd) + "' de expedi็ใo para o processo corrente?","Aviso",.T.)
		_lOkEnd     := .F.
		_lRet       := .T.
	EndIf
return _lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณAutACD 	บAutor  ณArthur Silva		   บ Data ณ  16/08/17 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de exig๊ncia de senha para a autoriza็ใo de fatura- บฑฑ
ฑฑบ          ณmento, quando este for deixar o estoque negativo.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function AutACD()
	Local _aSvAF      := GetArea()
	Local _aSvAFCB7   := CB7->(GetArea())
	Private _lRetAF   := .T.
	Private cGet1AF   := Space(30)
	Private cGet2AF   := Space(100)
	While _lAutFat
		VTCLEAR()
			@ 0,00 VTSAY "Digite a Senha para Liberar Faturamento"
			@ 1,00 VTSAY "--------------------"
			@ 2,00 VTSAY "Usuแrio:" VTGET cGet1AF		//VALID NAOVAZIO()
			@ 3,00 VTSAY "Senha:" 	VTGET cGet2AF	PASSWORD  VALID (_lRetAF := ValidAuth())
		VTREAD()
		If VTLastKey() == 27 .AND. _lAutFat 
			VTAlert(" Saํda nใo permitida, solicite a Libera็ใo do Responsแvel!","Aviso",.T.)
		EndIf
	EndDo
	VTMSG("Processando...",1)
	RestArea(_aSvAFCB7)
	RestArea(_aSvAF)
return _lRetAF
/*/{Protheus.doc} ChkLckBN
Sub-rotina para realizar o LockByName da rotina, evitando assim o encavalamento de mais de um user na rotina de faturamento.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 04/09/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
/*
static function ChkLckBN(_cRotina)
	local _nSecs := Seconds()
	while !LockByName(_cRotina,.T.,.T.)
		if (Seconds()-_nSecs) > 120				//Se o tempo de espera exceder 120 segundos, continua o processamento...
			UnLockByName(_cRotina,.T.,.T.)		//CUSTOM. ALL - 22/08/2019 - Anderson C. P. Coelho - UnLockByName inserido para destravar o LockByName inserido para que nใo haja concorr๊ncia na gera็ใo dos documentos de saํda, evitando assim as duplicidades ou saltos nas numera็๕es, anteriormente percebidas.
		endif
	enddo
return
*/


static function crgCB9ITESEP(_cOrdem)
local  _cCB9TMP :=GetNextAlias()
local _cUpd1:=""
local nY :=1

if Select(_cCB9TMP) > 0
		(_cCB9TMP)->(dbCloseArea())
endif
BeginSql Alias _cCB9TMP
	SELECT CB9_FILIAL,CB9_ORDSEP,CB9_PROD,CB9_SEQUEN,CB9_CODSEP,  CB9_PEDIDO , CB9_ITESEP, R_E_C_N_O_ RECB9
	FROM %table:CB9% CB9 (NOLOCK)
	WHERE CB9.CB9_FILIAL = %xFilial:CB9%
		AND CB9.CB9_ORDSEP = %Exp:_cOrdem%
		AND CB9.%NotDel%
EndSql

dbSelectArea(_cCB9TMP)
While !(_cCB9TMP)->(EOF()) 
	_cUpd1:= " update CB9010 SET CB9_SEQUEN = '" + PadL(CvALTOCHAR(nY),2, "0") + "'  where R_E_C_N_O_ = " + cvaltochar((_cCB9TMP)->RECB9)
 	TCSQLExec(_cUpd1)
	nY++
	(_cCB9TMP)->(dbSkip())
End
if Select(_cCB9TMP) > 0
	(_cCB9TMP)->(dbCloseArea())
endif
	

static function crgSC9ITE(_cOrdem)
local  _cCB9TMP :=GetNextAlias()
local _cUpd1:=""
local _nY :=1

if Select(_cCB9TMP) > 0
		(_cSC9TMP)->(dbCloseArea())
endif
BeginSql Alias _cSC9TMP
	SELECT C9_FILIAL,C9_ORDSEP,C9_PRODUTO, C9_SEQUEN ,  C9_PEDIDO , C9_ITEM, R_E_C_N_O_ RESC9
	FROM %table:SC9% SC9 (NOLOCK)
	WHERE SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_ORDSEP = %Exp:_cOrdem%
		AND SC9.%NotDel%
EndSql

dbSelectArea(_cSC9TMP)
While !(_cSC9TMP)->(EOF()) 
	_cUpd1:= " update SC9010 SET  C9_SEQUEN ='01' , C9_ITEM ='" + PadL(CValToChar(_nY),2, "0") + "'  where R_E_C_N_O_ = " +CValToChar((_cSC9TMP)->RESC9)
	 TCSQLExec(_cUpd1)
	_nY++
	(_cSC9TMP)->(dbSkip())
End
if Select(_cSC9TMP) > 0
	(_cSC9TMP)->(dbCloseArea())
endif

/*/
A partir deste ponto sใo fun็๕es padr๕es do rdmake ACDV166, utilizadas para facilitar o processo.
// -------------------------------------------------------------------------------------
/*/

Static Function v166TcLote (cOrdSep)
                                         
Local aAreaCB7 		:= CB7->(GetArea()) 
Local aAreaCB8 		:= CB8->(GetArea()) 
Local aAreaCB9 		:= CB9->(GetArea())  
Local aAreaSC6 		:= SC6->(GetArea())  
Local aAreaSC9 		:= SC9->(GetArea())  
Local aEmpPronto 	:= {}
Local aItensTrc 	:= {}
//Local lLoteSug 		:= .F. 
Local nQtdSep		:= 0
Local nX			:= 0
Local nPos			:= 0 
//Local nSaldoLote 	:= 0
Local cItemAnt   	:= ""
//Local cQuery     	:= ""
Local cAliasSC9  	:= ""

CB9->(DbSetOrder(1))
SC6->(DbSetOrder(1))
CB7->(DbSetOrder(1))
CB7->(MsSeek(xFilial("CB7")+cOrdSep))
CB9->(MsSeek(xFilial("CB9")+cOrdSep))
SC6->(MsSeek(xFilial("SC6")+CB9->CB9_PEDIDO+CB9->CB9_ITESEP))

	SC9->(DbSetOrder(17))
	cAliasSC9 := GetNextAlias()
	BeginSql Alias cAliasSC9
		SELECT C9_PEDIDO,C9_ITEM,C9_PRODUTO,C9_LOTECTL,C9_LOCAL, C9_QTDLIB, C9_ORDSEP
		FROM %table:SC9% SC9 (NOLOCK)
		WHERE C9_FILIAL  = %xFilial:SC9%
		 	AND C9_ORDSEP  = %Exp:cOrdSep%
		 	AND SC9.%NotDel%
		ORDER BY C9_PEDIDO,C9_ITEM,C9_PRODUTO
	EndSql	 

		(cAliasSC9)->(DbGotop())
		While (cAliasSC9)->(!EOF()) .and. (cAliasSC9)->C9_ORDSEP == cOrdSep
			If SC9->(MsSeek(xFilial("SC9")+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM+cOrdSep))	
					//SDC->(dbGoTo((cAliasSC9)->SDCREC))
					//While SC9->(!EOF()) .and. (cAliasSC9)->C9_PRODUTO == SC9->C9_PRODUTO .and. cOrdSep == SC9->C9_ORDSEP
						dbSelectArea("SDC")//้ dessa forma para refazer a SDC no estorno da SC9
						DBSetOrder(1) 
						If	dbSeek(xFilial("SDC") + (cAliasSC9)->C9_PRODUTO + (cAliasSC9)->C9_LOCAL + "SC6" + (cAliasSC9)->C9_PEDIDO + (cAliasSC9)->C9_ITEM)	
							RecLock("SDC",.F.)
								SDC->(dbDelete())
							SDC->(MsUnlock())
						EndIf
						
						DbSelectArea("SBF")
						SBF->(dbSetOrder(2)) //BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI                                                                              
						SBF->(dbSeek(xFilial("SBF")+(cAliasSC9)->C9_PRODUTO + (cAliasSC9)->C9_LOCAL + (cAliasSC9)->C9_LOTECTL))
						If SBF->BF_LOTECTL = (cAliasSC9)->C9_LOTECTL
							Reclock("SBF",.F.)
								SBF->BF_EMPENHO := SBF->BF_EMPENHO - (cAliasSC9)->C9_QTDLIB
								If SBF->BF_EMPENHO < 0
									SBF->BF_EMPENHO := 0
								EndIf
							SBF->(MsUnlock())
						EndIF
						DbSelectArea("SB1")
						SB1->(dbSetOrder(1)) 
						SB1->(dbSeek(xFilial("SB1")+(cAliasSC9)->C9_PRODUTO))
						If SB1->B1_CONV <> 0
							Reclock("SBF",.F.)
							SBF->BF_EMPEN2 := ROUND(SBF->BF_EMPENHO/SB1->B1_CONV,2)
							SBF->(MsUnlock())
						EndIf
						SBF->(Dbclosearea())
						
						
						SC9->(a460Estorna())
					//EndDo
			Endif
			(cAliasSC9)->(DbSkip())
		Enddo 
         
CB9->(DbSetOrder(11)) // CB9_FILIAL+CB9_ORDSEP+CB9_ITESEP+CB9_PEDIDO
CB7->(DbSetOrder(1))	 // CB7_FILIAL+CB7_ORDSEP
CB7->(MsSeek(xFilial("CB7")+cOrdSep))
CB9->(MsSeek(xFilial("CB9")+cOrdSep))



	cAliasCB9 := GetNextAlias()
	BeginSql Alias cAliasCB9
		SELECT CB9_PEDIDO,CB9_ITESEP,CB9_PROD,CB9_LOCAL,CB9_LOTECT, SUM(CB9_QTESEP) CB9_QTESEP, CB9_NUMLOT
		FROM %table:CB9% CB9 (NOLOCK) 
		WHERE CB9_FILIAL  = %xFilial:CB9%
		  AND CB9_ORDSEP  = %Exp:cOrdSep%
		  AND CB9.%NotDel%
		GROUP BY CB9_PEDIDO,CB9_ITESEP,CB9_PROD,CB9_LOCAL,CB9_LOTECT, CB9_NUMLOT
		ORDER BY CB9.CB9_PROD, CB9.CB9_LOTECT
	EndSql	  


	(cAliasCB9)->(DbGotop())
	While (cAliasCB9)->(!EOF()) //.and. SC9->C9_PEDIDO = (cAliasSC9)->C9_PEDIDO .and.  SC9->C9_ITEM = (cAliasSC9)->C9_ITEM
			nPos := aScan (aItensTrc,{|x| x[1]+x[2]+x[5] == (cAliasCB9)->CB9_PEDIDO+(cAliasCB9)->CB9_ITESEP+(cAliasCB9)->CB9_LOTECT})
			If nPos == 0 
				aAdd(aItensTrc, {(cAliasCB9)->CB9_PEDIDO, (cAliasCB9)->CB9_ITESEP, (cAliasCB9)->CB9_QTESEP, (cAliasCB9)->CB9_LOTECT, (cAliasCB9)->CB9_NUMLOT,(cAliasCB9)->CB9_PROD, (cAliasCB9)->CB9_LOCAL})
				nQtdSep += (cAliasCB9)->CB9_QTESEP
			Else 
				aItensTrc[nPos][4] 	+= (cAliasCB9)->CB9_QTESEP
				nQtdSep 			+= (cAliasCB9)->CB9_QTESEP
			EndIf                  
		(cAliasCB9)->(DbSkip())
	Enddo
         
For nX := 1 to Len(aItensTrc)
		If SC6->(MsSeek(xFilial("SC6")+aItensTrc[nX][1]+aItensTrc[nX][2]))
			If cItemAnt != aItensTrc[nX][1]+aItensTrc[nX][2]
				aEmpPronto := LoadEmpEst(.F.,.F.)
				//MaLibDoFat(SC6->(Recno()),nQtdSep,.T.,.T.,.F.,.F.,.F.,.F.,NIL,{||SC9->C9_ORDSEP := cOrdSep},aEmpPronto,.T.)
				MaLibDoFat(SC6->(Recno()),aEmpPronto[1][5],.T.,.T.,.F.,.F.,.F.,.F.,NIL,{||SC9->C9_ORDSEP := cOrdSep},aEmpPronto,.T.)
			EndIf
		EndIf
		cItemAnt := aItensTrc[nX][1]+aItensTrc[nX][2]
Next nX	

RestArea(aAreaCB7)
RestArea(aAreaCB8)
RestArea(aAreaCB9)
RestArea(aAreaSC6)
RestArea(aAreaSC9)

Return

Static Function LoadEmpEst(lLotSug,lTroca)
	Local aEmp:={}
	Local aEtiqueta:={}
	Default lLotSug := .T.
	Default lTroca  := .F.

	CB9->(DBSetOrder(11))
	CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+SC6->C6_ITEM+SC6->C6_NUM))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP+CB9_ITESEP+CB9_PEDIDO == xFilial("CB9")+CB7->CB7_ORDSEP+SC6->C6_ITEM+SC6->C6_NUM)
		If !lLotSug .And. lTroca
			nPos :=ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[11] == CB9->(CB9_LOTECT+CB9_NUMLOTE+CB9_LCALIZ+CB9_NSERSU+CB9_LOCAL)})
			If !CB9->(a166VldSC9(1,CB9_PEDIDO+CB9_ITESEP+CB9_SEQUEN+CB9_PROD))
				If Empty(nPos)
					CB9->(aadd(aEmp,{CB9_LOTECT, ;								                  // 1
									CB9_NUMLOTE,;								                  // 2
									CB9_LCALIZ, ;								                  // 3
									CB9_NSERSU,;                                             // 4
									CB9_QTESEP,;								                  // 5
									ConvUM(CB9_PROD,CB9_QTESEP,0,2),;                        // 6
									a166DtVld(CB9_PROD,CB9_LOCAL,CB9_LOTECT, CB9_NUMLOTE),;  // 7
									,;                 						                  // 8
									,;									                         // 9
									,;									                         // 10
									CB9_LOCAL,;								                  // 11
									0}))								                         // 12
				Else
					aEmp[nPos,5] +=CB9->CB9_QTESEP
				EndIf
			EndIf	
		ElseIf !lLotSug
			nPos :=ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[11] == CB9->(CB9_LOTECT+CB9_NUMLOTE+CB9_LCALIZ+CB9_NSERSU+CB9_LOCAL)})
			If Empty(nPos)
				CB9->(aadd(aEmp,{CB9_LOTECT, ;								                  // 1
								CB9_NUMLOTE,;								                  // 2
								CB9_LCALIZ, ;								                  // 3
								CB9_NSERSU,;                                             // 4
								CB9_QTESEP,;								                  // 5
								ConvUM(CB9_PROD,CB9_QTESEP,0,2),;                        // 6
								a166DtVld(CB9_PROD,CB9_LOCAL,CB9_LOTECT, CB9_NUMLOTE),;  // 7
								,;                 						                  // 8
								,;									                         // 9
								,;									                         // 10
								CB9_LOCAL,;								                  // 11
								0}))								                         // 12
			Else
				aEmp[nPos,5] +=CB9->CB9_QTESEP
			EndIf
		Else 
			nPos :=ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[11] == CB9->(CB9_LOTSUG+CB9_SLOTSUG+CB9_LCALIZ+CB9_NSERSU+CB9_LOCAL)})
			If Empty(nPos)
				CB9->(aadd(aEmp,{CB9_LOTSUG,;								                  // 1
								CB9_SLOTSUG,;								                  // 2
								CB9_LCALIZ,;								                  // 3
								CB9_NSERSU,;                                             // 4
								CB9_QTESEP,;								                  // 5
								ConvUM(CB9_PROD,CB9_QTESEP,0,2),;                        // 6
								a166DtVld(CB9_PROD,CB9_LOCAL,CB9_LOTECT, CB9_NUMLOTE),;  // 7
								,;                                                       // 8
								,;                                                       // 9
								,;                                                       // 10
								CB9_LOCAL,;								                  // 11
								0}))								                         // 12
			Else
				aEmp[nPos,5] +=CB9->CB9_QTESEP
			EndIf
		EndIf
		If ! Empty(CB9->CB9_CODETI)
			aEtiqueta := CBRetEti(CB9->CB9_CODETI,"01")
			If ! Empty(aEtiqueta)
				aEtiqueta[13]:= CB7->CB7_NOTA
				aEtiqueta[14]:= CB7->CB7_SERIE
				CBGrvEti("01",aEtiqueta,CB9->CB9_CODETI)
			EndIf
		EndIf
		CB9->(DBSkip())
	EndDo
Return aEmp

Static Function a166VldSC9(nOrdem,cChave)
	Local aAreaAnt := GetArea()
	Local aAreaSC9 := SC9->(GetArea())
	Local lRet     := .F.

	SC9->(DbSetOrder(nOrdem))
	lRet := SC9->(MsSeek(xFilial("SC9")+cChave))

	RestArea(aAreaSC9)
	RestArea(aAreaAnt)
Return lRet

Static Function a166DtVld(cProd,cLocal,cLote,cSubLote)
	Local aAreaAnt := GetArea()
	Local aAreaSB8 := SB8->(GetArea())
	Local dDtVld   := CTOD("")

	// Indice 3 - SB8 - FILIAL + PRODUTO + LOCAL + LOTECTL + NUMLOTE + DTOS(B8_DTVALID)
	dDtVld := Posicione("SB8",3,xFilial("SB8")+cProd+cLocal+cLote+cSubLote,"B8_DTVALID")

	RestArea(aAreaSB8)
	RestArea(aAreaAnt)
Return dDtVld
