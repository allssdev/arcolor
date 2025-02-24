#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRTMKE033  บAutor  ณAnderson C. P. Coelho บ Data ณ  20/05/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Execblock de autotiza็ใo para altera็ใo do Atendimento Callบฑฑ
ฑฑบ          ณCenter quando este estiver utilizando uma tabela de pre็os  บฑฑ
ฑฑบ          ณfora da vig๊ncia ou diferente da definida no cadastro do    บฑฑ
ฑฑบ          ณcliente. Este execblock ้ chamado na rotina "RTMKE006" que  บฑฑ
ฑฑบ          ณhoje jแ ้ chamado na valida็ใo dos campos UB_PRODUTO e      บฑฑ
ฑฑบ          ณUB_QUANT.                                                   บฑฑ
ฑฑบ          ณ Somente os usuแrios definidos no parโmetro "MV_AUTTABP"    บฑฑ
ฑฑบ          ณterใo acesso a esta autoriza็ใo.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ22/05/2015 - Rotina anteriormente solicitada pelo Mแrio, masบฑฑ
ฑฑบ          ณainda nใo aprovada para a produ็ใo.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RTMKE033()

Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oGet1
Local oGet2
Local oSButton1
Local oSButton2
Local _aSavArea   := GetArea()
Local _aSavDA0    := {}
Local _aSavDA1    := {}
Local _aSavSC5    := {}
Local _aSavSC6    := {}
Local _aSavSUA    := {}
Local _aSavSUB    := {}
Local _aSavSA1    := {}
Local _nPosPrd    := 0
Local _nPosQtd    := 0
Local _cTabP      := ""
Local _cProd      := ""
Local _cQuant     := ""
Local _cCli       := ""
Local _cTabC      := ""
Local _lRet       := .F.
Local _lAval      := .F.
Local _lAtiva     := AllTrim(__cUserId) == "000000"

Private _cRotina  := "RTMKE033"
Private cGet1     := Padr(cUserName,50)
Private cGet2     := Space(100)

dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())
dbSelectArea("SUS")
_aSavSUS := SUS->(GetArea())
dbSelectArea("SUA")
_aSavSUA := SUA->(GetArea())
dbSelectArea("SUB")
_aSavSUB := SUB->(GetArea())
dbSelectArea("SC5")
_aSavSC5 := SC5->(GetArea())
dbSelectArea("SC6")
_aSavSC6 := SC6->(GetArea())
dbSelectArea("DA1")
_aSavDA1 := DA1->(GetArea())
dbSelectArea("DA0")
_aSavDA0 := DA0->(GetArea())
If _lAtiva .AND. ALTERA
	If AllTrim(FunName())$"TMKA271"
		_cTabP       := M->UA_TABELA
		_cCli        := M->UA_CLIENTE+M->UA_LOJA
		If !lProspect
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1")+_cCli,.T.,.F.))
			_cTabC   := SA1->A1_TABELA
		Else
			dbSelectArea("SUS")
			SUS->(dbSetOrder(1))
			SUS->(MsSeek(xFilial("SA1")+_cCli,.T.,.F.))
			_cTabC   := SUS->US_TABELA
		EndIf
		If AllTrim(ReadVar()) == "M->UB_PRODUTO"
			_cProd   := M->UB_PRODUTO
			_nPosQtd := aScan(aHeader,{|x| AllTrim(x[2])=="UB_QUANT"  })
			_cQuant  := STRZERO(aCols[n][_nPosQtd],TamSx3("DA1_QTDLOT")[01],TamSx3("DA1_QTDLOT")[02])
		ElseIf AllTrim(ReadVar()) == "M->UB_QUANT"
			_nPosPrd := aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
			_cProd   := aCols[n][_nPosPrd]
			_cQuant  := STRZERO(M->UB_QUANT       ,TamSx3("DA1_QTDLOT")[01],TamSx3("DA1_QTDLOT")[02])
		Else
			_nPosPrd := aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
			_cProd   := aCols[n][_nPosPrd]
			_nPosQtd := aScan(aHeader,{|x| AllTrim(x[2])=="UB_QUANT"  })
			_cQuant  := STRZERO(aCols[n][_nPosQtd],TamSx3("DA1_QTDLOT")[01],TamSx3("DA1_QTDLOT")[02])
		EndIf
	ElseIf AllTrim(FunName())$"MATA410"
		_cTabP       := M->C5_TABELA
		_cCli        := M->C5_CLIENTE+M->C5_LOJACLI
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+_cCli,.T.,.F.))
		_cTabC       := SA1->A1_TABELA
		If AllTrim(ReadVar()) == "M->C6_PRODUTO"
			_cProd   := M->C6_PRODUTO
			_nPosQtd := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN" })
			_cQuant  := STRZERO(aCols[n][_nPosQtd],TamSx3("DA1_QTDLOT")[01],TamSx3("DA1_QTDLOT")[02])
		ElseIf AllTrim(ReadVar()) == "M->C6_QTDVEN"
			_nPosPrd := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
			_cProd   := aCols[n][_nPosPrd]
			_cQuant  := STRZERO(M->C6_QTDVEN      ,TamSx3("DA1_QTDLOT")[01],TamSx3("DA1_QTDLOT")[02])
		Else
			_nPosPrd := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
			_cProd   := aCols[n][_nPosPrd]
			_nPosQtd := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN" })
			_cQuant  := STRZERO(aCols[n][_nPosQtd],TamSx3("DA1_QTDLOT")[01],TamSx3("DA1_QTDLOT")[02])
		EndIf
	Else
		Return
	EndIf
	If _cTabC <> _cTabP
		_lAval := .T.
	Else
		dbSelectArea("DA0")
		DA0->(dbSetOrder(1))
		If !Empty(_cTabP) .AND. DA0->(MsSeek(xFilial("DA0")+Padr(_cTabP,Len(DA0->DA0_CODTAB))))
			If	AllTrim(DA0->DA0_ATIVO)  == "1"                                   .AND. ;
				Date()                   >= DA0->DA0_DATDE                        .AND. ;
				(Empty(DA0->DA0_DATATE) .OR. Date() <= DA0->DA0_DATATE)
				dbSelectArea("DA1")
				DA1->(dbSetOrder(1))
				If DA1->(MsSeek(xFilial("DA1")+Padr(_cTabP,Len(DA1->DA1_CODTAB))+Padr(_cProd,Len(DA1->DA1_CODPRO)), .T.,.F.)) .AND. !DA1->(EOF()) .AND. xFilial("DA1") == DA1->DA1_FILIAL .AND. _cTabP == Padr(_cTabP,Len(DA1->DA1_CODTAB)) .AND. _cProd == Padr(_cProd,Len(DA1->DA1_CODPRO)) .AND. VAL(_cQuant) <= VAL(DA1->DA1_INDLOT)
					While !DA1->(EOF()) .AND. xFilial("DA1") == DA1->DA1_FILIAL .AND. _cTabP == Padr(_cTabP,Len(DA1->DA1_CODTAB)) .AND. _cProd == Padr(_cProd,Len(DA1->DA1_CODPRO))
						If VAL(_cQuant) <= VAL(DA1->DA1_INDLOT)
							If	AllTrim(DA1->DA1_ATIVO ) == "1" .AND. Date() >= DA1->DA1_DATVIG
								_lAval := .F.
							Else
								_lAval := .T.
							EndIf
							Exit
						EndIf
						dbSelectArea("DA1")
						DA1->(dbSetOrder(1))
						DA1->(dbSkip())
					EndDo
				Else
					_lAval := .T.
				EndIf
			Else
				_lAval := .T.
			EndIf
		Else
			_lAval := .T.
		EndIf
	EndIf
	Static oDlg
	If _lAval
		  DEFINE MSDIALOG oDlg TITLE "Tabela de Pre็os fora da vig๊ncia" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
			oDlg:lEscClose := .F.

		    @ 007, 004 GROUP oGroup1 TO 092, 245 PROMPT " Autoriza็ใo para Altera็ใo de Pedido com Tabela de Pre็os fora da vig๊ncia " OF oDlg COLOR 0, 16777215 PIXEL
		    @ 025, 011   SAY oSay1 PROMPT "Este pedido estแ vinculado a uma tabela de pre็os fora da vig๊ncia. Sendo assim, nใo serแ possํvel alterแ-lo sem a autoriza็ใo do responsแvel." SIZE 222, 018 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 045, 010   SAY oSay2 PROMPT "Usuแrio: " SIZE 026, 007 OF oDlg                  COLORS 0, 16777215          PIXEL
		    @ 042, 037 MSGET oGet1    VAR cGet1       SIZE 200, 010 OF oDlg VALID NAOVAZIO() COLORS 0, 16777215          PIXEL
		    @ 060, 010   SAY oSay3 PROMPT "Senha:"    SIZE 025, 007 OF oDlg                  COLORS 0, 16777215          PIXEL
		    @ 057, 037 MSGET oGet2    VAR cGet2       SIZE 200, 010 OF oDlg                  COLORS 0, 16777215 PASSWORD PIXEL

		    DEFINE SBUTTON oSButton1 FROM 075, 160 TYPE 01 OF oDlg ENABLE Action (_lRet := ValidAuth())
		    DEFINE SBUTTON oSButton2 FROM 075, 210 TYPE 02 OF oDlg ENABLE Action EVAL({|| _lRet := .F., oDlg:End()})

		  ACTIVATE MSDIALOG oDlg CENTERED

		If !_lRet
			MsgStop("Usuแrio nใo autenticado!",_cRotina+"_001")
		EndIf
	Else
		_lRet := .T.
	EndIf
Else
	_lRet := .T.
EndIf

RestArea(_aSavSC6)
RestArea(_aSavSC5)
RestArea(_aSavDA1)
RestArea(_aSavDA0)
RestArea(_aSavSUS)
RestArea(_aSavSA1)
RestArea(_aSavSUB)
RestArea(_aSavSUA)
RestArea(_aSavArea)

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidAuth บAutor  ณAnderson C. P. Coelho บ Data ณ  20/05/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de valida็ใo da senha digitada.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidAuth()

Local _lValid := .F.

If !Empty(cGet1) .AND. !Empty(cGet2)
	If ("#"+AllTrim(cGet1)+"#")$AllTrim(SuperGetMv("MV_AUTTABP",,"#Administrador#0000125#900000#900001#900002#"))
		PswOrder(2)
		If PswSeek(AllTrim(cGet1),.T.)
			If (_lValid := PswName(AllTrim(cGet2)))
				oDlg:End()
			Else
				MsgAlert("Senha Incorreta!",_cRotina+"_002")
				cGet1   := Space(050)
				cGet2   := Space(100)
			EndIf
		Else
			MsgAlert("Usuแrio nใo encontrado!",_cRotina+"_003")
			cGet1   := Space(050)
			cGet2   := Space(100)
		EndIf
	Else
		MsgAlert("Usuแrio nใo autorizado!",_cRotina+"_004")
		cGet1   := Space(050)
		cGet2   := Space(100)
	EndIf
Else
	cGet1AF   := Space(050)
	cGet2AF   := Space(100)
	MsgAlert("Preencha as informa็๕es corretamente!",_cRotina+"_005")
EndIf

Return(_lValid)