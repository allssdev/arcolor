#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RTMKE020 º Autor ³Adriano Leonardo      º Data ³  27/01/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Execblock utilizado para calcular o fator do desconto com  º±±
±±º          ³ base nos descontos 1, 2, 3 e 4 dos itens do atendimento.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RTMKE020()

Local _aSavArea := GetArea()
Local _cRVarBk  := __ReadVar
Local _cContCpo := &(_cRVarBk)
Local _nAux	    := 100
Local _nPCFat   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_CODFATR"})
Local _nPosDesc := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESC"   })
Local _nPosDesA := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCAUX"})
Local _nPsFator := aScan(aHeader,{|x|AllTrim(x[02])=="UB_FATOR"  })
Local _cPesqSZA := ""
Local _aDesc    := {}

AAdd(_aDesc,aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV1"}))
AAdd(_aDesc,aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV2"}))
AAdd(_aDesc,aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV3"}))
AAdd(_aDesc,aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCTV4"}))
//Varre o array com os campos de desconto para calcular o desconto em cascata
For _nCont := 1 To Len(_aDesc)
	If aCols[n,_aDesc[_nCont]] > 0
		_nAux := _nAux - (_nAux * ((aCols[n,_aDesc[_nCont]])/100))
 	EndIf
 	_nFator   := (100 - _nAux)
	_cPesqSZA += Padr(Str(aCols[n][_aDesc[_nCont]]),TamSx3("ZA_DESC"+cValToChar(_nCont))[01])
Next
If !Empty(_cPesqSZA)
	dbSelectArea("SZA")
	SZA->(dbOrderNickName("ZA_DESC1"))		//ZA_FILIAL+STR(ZA_DESC1)+STR(ZA_DESC2)+STR(ZA_DESC3)+STR(ZA_DESC4)+ZA_MSBLQL
	If SZA->(MsSeek(xFilial("SZA") + _cPesqSZA + "2"))
		aCols[n][_nPCFat] := SZA->ZA_CODIGO
	ElseIf SZA->(MsSeek(xFilial("SZA") + _cPesqSZA + " "))
		aCols[n][_nPCFat] := SZA->ZA_CODIGO
	EndIf
EndIf
//Disparo as valiações e gatilhos do campo de percentual de desconto, por conta da atualização dos valores
__ReadVar     := "M->UB_DESC"
M->UB_DESC := aCols[n][_nPosDesc] := _nFator //Atualizo o aCols e memória com o fator calculado
If _nPosDesA > 0
	aCols[n,_nPosDesA] := _nFator //Gravo o percentual de desconto em campo auxiliar para preservar o desconto em caso de troca do tipo de operação
EndIf
If _nPsFator > 0
	aCols[n,_nPsFator] := _nFator //Gravo o fator de desconto em campo informativo
EndIf
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
	If _lRet .AND. ExistTrigger("UB_DESC")
		RunTrigger(1)
		EvalTrigger()
	EndIf
EndIf

If ExistBlock("RTMKE037")
	ExecBlock("RTMKE037")
EndIf
//Restauro o __ReadVar
__ReadVar    := _cRVarBk
&(__ReadVar) := _cContCpo
(_cAliasSX3)->(dbCloseArea())
RestArea(_aSavArea)

Return(_nFator)
