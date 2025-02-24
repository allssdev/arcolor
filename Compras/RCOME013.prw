#include 'totvs.ch'
/*/{Protheus.doc} RCOME013
@description Execblock utilizado para disparar os gatilhos e validaÃ§Ãµes pertinentes ao campo C7_TES no documento de entrada, disparado pela validaÃ§Ã£o dos campos:
//     * D1_COD
//     * D1_QUANT
//     * D1_VUNIT
//     * D1_TOTAL
//     * D1_TES
@author Anderson C. P. Coelho (ALLSS SoluÃ§Ãµes em Sistemas)
@since 12/01/2021
@version 1.0.0
@type function
@history 13/01/2021, Diego Rodrigues, ajuste na posição da variavel _ReadVar
@history 21/04/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Inserida regra para que tal validação não seja executada quanto integração TOTVS Colaboração x Documento de entrada ou pré-nota entrada.
@see https://allss.com.br
/*/
user function RCOME013(_cRet)
Local _aSavArea  := GetArea()
Local _aSavSF4   := SF4->(GetArea())
Local _aSavSF1   := SF1->(GetArea())
Local _aSavSD1   := SD1->(GetArea())
Local _aSavSB1   := SB1->(GetArea())
Local _cRVarBk   := ReadVar()
Local _nPProd    := aScan(aHeader,{|x| AllTrim(x[02]) == "D1_COD"})
Local _nPTes     := aScan(aHeader,{|x| AllTrim(x[02]) == "D1_TES"})
Local _cProd     := IIF(AllTrim(__ReadVar)=="M->D1_COD",&(__ReadVar),aCols[n][_nPProd])
Local _cAliasSX3 := GetNextAlias()
Local _lValid    := .T.
Default _cRet    := ""
if !FunName() $ "COMXCOL"	
	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(FWFilial("SB1") + _cProd,.T.,.F.))
		if empty(_cRet) .OR. !SF4->(MsSeek(FWFilial("SF4") + _cRet,.T.,.F.))
			If SB1->(FieldPos("B1_TEAUX")) > 0
				_cRet := SB1->B1_TEAUX
			Else
				_cRet := SB1->B1_TE
			EndIf
		endif
	EndIf
	__ReadVar    := "M->D1_TES"
	If Empty(_cRet)
		_cRet := IIF(AllTrim(__ReadVar)=="M->D1_TES",&(__ReadVar),aCols[n][_nPTes])
	EndIf
	//__ReadVar    := "M->D1_TES"
	&(__ReadVar) := _cRet
	If !Empty(&(__ReadVar))
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(2))
		If (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)),.T.,.F.))
			_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
			If !Empty(_cValid)
				_lValid := &_cValid
			EndIf
		EndIf
		If _lValid .AND. ExistTrigger(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)))
			RunTrigger(2,n)
		EndIf
	EndIf
endif	
__ReadVar := _cRVarBk
RestArea(_aSavSB1)
RestArea(_aSavSF4)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavArea)
return .T.
