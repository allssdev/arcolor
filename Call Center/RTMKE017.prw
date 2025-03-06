#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RTMKE017 บAutor  ณAdriano Leonardo    บ Data ณ  18/12/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por restaurar os valores de desconto e  บฑฑ
ฑฑบ          ณ acr้scimo originais ap๓s a altera็ใo do tipo de opera็ใo   บฑฑ
ฑฑบ          ณ do atendimento do Call Center.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RTMKE017(_cTpCham)

Local _aSavAr  := GetArea()
Local _nBkp    := IIF(Type("n")<>"U",n,1)
Local _nBkpFor := 0
Local _nReg    := 1
Local _nCont   := Len(aCols)
Local _nPAcrP  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREPOR"})
Local _nPAcr   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACRE"   })
Local _nPAcrV  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREVAL"})
Local _nPVAcr  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALACRE"})
Local _nPDesc  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESC"   })
Local _nPVDes  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDESC"})
Local _nPDescA := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCAUX"})
Local _nPVDesA := aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDAUX"})
Local _cRVarBk := ReadVar()
Local _cRotina := "RTMKE017"
Local _lRet    := .T.
Local _cValid  := ".T."

Default _cTpCham := "C"

If _cTpCham == "I"
	_nCont := _nReg  := n
EndIf
For n := _nReg To _nCont
	_nBkpFor := n
	If aCols[n][Len(aHeader)+1]
		Loop
	EndIf
	If aCols[n][_nPDescA] <> 0
		__ReadVar  := "M->UB_DESC"
		M->UB_DESC := aCols[n][_nPDesc] := aCols[n][_nPDescA]

		_cAliasSX3 := "SX3_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(2))
		If (_cAliasSX3)->(MsSeek("UB_DESC",.T.,.F.))
			_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
			If Empty(_cValid)
				_cValid  := ".T."
			EndIf
			_lRet := &_cValid
		EndIf
		__ReadVar  := "M->UB_DESC"
		M->UB_DESC := aCols[n][_nPDesc] := aCols[n][_nPDescA]
		If _lRet .AND. ExistTrigger("UB_DESC")
			RunTrigger(1)
			EvalTrigger()
		EndIf
		(_cAliasSX3)->(dbCloseArea())
	EndIf
	If aCols[n][_nPVDesA] <> 0
		__ReadVar     := "M->UB_VALDESC"
		M->UB_VALDESC := aCols[n][_nPVDes] := aCols[n][_nPVDesA]

		_cAliasSX3 := "SX3_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(2))
		If (_cAliasSX3)->(MsSeek("UB_VALDESC",.T.,.F.))
			_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
			If Empty(_cValid)
				_cValid  := ".T."
			EndIf
			_lRet := &_cValid
		EndIf
		__ReadVar     := "M->UB_VALDESC"
		M->UB_VALDESC := aCols[n][_nPVDes] := aCols[n][_nPVDesA]
		If _lRet .AND. ExistTrigger("UB_VALDESC")
			RunTrigger(1)
			EvalTrigger()
		EndIf
		(_cAliasSX3)->(dbCloseArea())
	EndIf
	If aCols[n][_nPAcrP] <> 0
		__ReadVar  := "M->UB_ACRE"
		M->UB_ACRE := aCols[n][_nPAcr] := aCols[n][_nPAcrP]
		_cAliasSX3 := "SX3_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(2))
		If (_cAliasSX3)->(MsSeek("UB_ACRE",.T.,.F.))
			_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
			If Empty(_cValid)
				_cValid  := ".T."
			EndIf
			_lRet := &_cValid
		EndIf		
		__ReadVar  := "M->UB_ACRE"
		M->UB_ACRE := aCols[n][_nPAcr] := aCols[n][_nPAcrP]
		If _lRet .AND. ExistTrigger("UB_ACRE")
			RunTrigger(1)
			EvalTrigger()
		EndIf
		(_cAliasSX3)->(dbCloseArea())
	EndIf
	If aCols[n][_nPAcrV] <> 0
		__ReadVar     := "M->UB_VALACRE"
		M->UB_VALACRE := aCols[n][_nPVAcr] := aCols[n][_nPAcrV]
		_cAliasSX3 := "SX3_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(2))
		If (_cAliasSX3)->(MsSeek("UB_VALACRE",.T.,.F.))
			_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
			If Empty(_cValid)
				_cValid  := ".T."
			EndIf
			_lRet := &_cValid
		EndIf
		__ReadVar     := "M->UB_VALACRE"
		M->UB_VALACRE := aCols[n][_nPVAcr] := aCols[n][_nPAcrV]
		If _lRet .AND. ExistTrigger("UB_VALACRE")
			RunTrigger(1)
			EvalTrigger()
		EndIf
		(_cAliasSX3)->(dbCloseArea())
	EndIf
	n := _nBkpFor
Next
n         := _nBkp
__ReadVar := _cRVarBk
RestArea(_aSavAr)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao estiver usando a entrada automaticaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (Type("lTk271Auto")=="U" .OR. !lTk271Auto) .AND. Type("oGetTlv:oBrowse")<>"U"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta o refresh na GetDados para garantir que todas as informacoes estejam visiveis para o Operadorณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oGetTlv:oBrowse:Refresh(.T.)
EndIf

Return(_lRet)
