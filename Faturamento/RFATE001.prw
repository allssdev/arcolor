#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE001  ºAutor  ³Anderson C. P. Coelho º Data ³  20/02/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para alterar o TES dos produtos no PV, º±±
±±º          ³quando o campo C5_TPDIV contiver '4', para PV Normal,       º±±
±±º          ³chamado na validação deste campo.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus 11 - Específico para a empresa Arcolor.(CD Control)º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE001()

Local _aSvA     := GetArea()
Local _aSvSF4   := {}
Local _aSvSC6   := {}
Local _nBkp     := n
Local _cRVarBkp := __ReadVar
Local nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"  })
Local nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT" })
Local nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN" })
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN" })
Local nPDtEntr  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENTREG" })
Local nPProd    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"    })
Local nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"  })
Local nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
Local nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
Local nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"   })
Local nPProvEnt := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PROVENT"})
Local nPosCfo	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_CF"     })
Local _nPosCalc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TPCALC" })
Local _nPosEsp  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_COD_E"  })
Local _cTES     := ""
Local _lRet     := .T.

Private _lRTMKE006 := Existblock("RTMKE006")
Private _cTESPADQ  := SuperGetMV("MV_TESPADQ",,"901")
Private _cTESPAD1  := SuperGetMV("MV_TESPAD1",,"999")

dbSelectArea("SA2")
_aSvSA2 := SA2->(GetArea())
dbSelectArea("SA1")
_aSvSA1 := SA1->(GetArea())
dbSelectArea("SF4")
_aSvSF4 := SF4->(GetArea())
dbSelectArea("SC6")
_aSvSC6 := SC6->(GetArea())

If AllTrim(M->C5_TIPO) == "N"
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,.T.,.F.)
	For n := 1 To Len(aCols)
		If _lRTMKE006
			Execblock("RTMKE006")
		EndIf
		If !aCols[n][Len(aHeader)+1]
			//A1_TPDIV: 0=0;1=33,33;2=50;3=66,66;4=100;5=DUPLO		{%Normal}
			_lQuant   := .T.
			_lCalcula := .F.
			_nFator   := 1
			If IIF(Empty(M->C5_TPDIV),SA1->A1_TPDIV,M->C5_TPDIV) == "0"
				_nFator   := 0
				_lCalcula := .T.
			ElseIf IIF(Empty(M->C5_TPDIV),SA1->A1_TPDIV,M->C5_TPDIV) == "1"
				_nFator   := 0.3333
				_lCalcula := .T.
				_lQuant   := AllTrim(aCols[n][_nPosCalc]) == "Q"
			ElseIf IIF(Empty(M->C5_TPDIV),SA1->A1_TPDIV,M->C5_TPDIV) == "2"
				_nFator   := 0.5
				_lCalcula := .T.
				_lQuant   := AllTrim(aCols[n][_nPosCalc]) == "Q"
			ElseIf IIF(Empty(M->C5_TPDIV),SA1->A1_TPDIV,M->C5_TPDIV) == "3"
				_nFator   := 0.6666
				_lCalcula := .T.
				_lQuant   := AllTrim(aCols[n][_nPosCalc]) == "Q"
			ElseIf IIF(Empty(M->C5_TPDIV),SA1->A1_TPDIV,M->C5_TPDIV) == "4"
				_nFator   := 1
				_lCalcula := .F.
			ElseIf IIF(Empty(M->C5_TPDIV),SA1->A1_TPDIV,M->C5_TPDIV) == "5"
				_nFator   := 0.5
				_lCalcula := .T.
				_lQuant   := .T.
			EndIf
			If _lCalcula
				If !_lQuant .AND. Empty(aCols[n][_nPosEsp])
					dbSelectArea("SB1")
					dbSetOrder(1)
					If MsSeek(xFilial("SB1") + aCols[n][nPProd],.T.,.F.) .AND. !Empty(SB1->B1_COD_E)
						aCols[n][_nPosEsp] := SB1->B1_COD_E
					EndIf
				EndIf
			EndIf
		EndIf
		If AllTrim(IIF(Empty(M->C5_TPDIV),SA1->A1_TPDIV,M->C5_TPDIV)) == "0"
			_cTES := ""
			dbSelectArea("SF4")
			dbSetOrder(1)
			If MsSeek(xFilial("SF4") + aCols[n][nPTES],.T.,.F.)
				If !Empty(SF4->F4_TESALTQ)
					_cTES := SF4->F4_TESALTQ
				Else
					_cTES := AllTrim( _cTESPADQ )
				EndIf
			Else
				_cTES     := AllTrim( _cTESPADQ )
			EndIf
			dbSelectArea("SF4")
			dbSetOrder(1)
			If MsSeek(xFilial("SF4") + _cTES,.T.,.F.)
				aCols[n][nPTES] := SF4->F4_CODIGO
			EndIf
			__ReadVar := "M->C6_TES"
			If Empty(aCols[n][nPTES])
				dbSelectArea("SB1")
				dbSetOrder(1)
				If MsSeek(xFilial("SB1")+aCols[n][nPProd],.T.,.F.)
					IF Empty(SB1->B1_TS)
						&(__ReadVar) := aCols[n][nPTES] := AllTrim( _cTESPAD1 )
					Else 
						&(__ReadVar) := aCols[n][nPTES] := SB1->B1_TS
					EndIf
				EndIf
			Else 
				&(__ReadVar) := aCols[n][nPTES]
			EndIf

			_cAliasSX3 := "SX3_"+GetNextAlias()
			OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))

			If (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)),.T.,.F.))
				_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
				If !Empty(_cValid)
					&_cValid
				EndIf
			EndIf
			If _lRet .AND. ExistTrigger(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)))
				RunTrigger(2,n)
				EvalTrigger()
			EndIf
		EndIf
	Next
EndIf

__ReadVar := _cRVarBkp
n         := _nBkp

RestArea(_aSvSA2)
RestArea(_aSvSA1)
RestArea(_aSvSF4)
RestArea(_aSvSC6)
RestArea(_aSvA)

Return(_lRet)