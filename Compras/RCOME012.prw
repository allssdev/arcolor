#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RCOME012
//Descrição Genérica..: Execblock utilizado para disparar os gatilhos e validações pertinentes ao campo C7_TES no pedido de compras,
//                      disparado pela validação dos campos:
//     * C7_PRODUTO
//     * C7_QUANT
//     * C7_PRECO
//     * C7_TOTAL
@author Anderson C. P. Coelho
@since 24/04/2017
@version 1.0.0

@type function
/*/
user function RCOME012()
	Local _aSavArea := GetArea()
	Local _aSavSC7  := SC7->(GetArea())
	Local _aSavSB1  := SB1->(GetArea())
	Local _cRVarBk  := ReadVar()
	Local _nPProd   := aScan(aHeader,{|x| AllTrim(x[02]) == "C7_PRODUTO"})
	Local _nPTes    := aScan(aHeader,{|x| AllTrim(x[02]) == "C7_TES"})
	Local _cRet     :´= ""
	Local _cProd    := IIF(AllTrim(__ReadVar)=="M->C7_PRODUTO",&(__ReadVar),aCols[n][_nPProd])
	Local _lValid   := .T.
	Local _cAliasSX3 := GetNextAlias()
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1") + _cProd,.T.,.F.))
		If SB1->(FieldPos("B1_TEAUX")) > 0
			_cRet := SB1->B1_TEAUX
		Else
			_cRet := SB1->B1_TE
		EndIf
	EndIf
	If Empty(_cRet)
		_cRet := IIF(AllTrim(__ReadVar)=="M->C7_TES",&(__ReadVar),aCols[n][_nPTes]) //M->C7_TES - Alterado por Renan, pois estava apresentando erro 
	EndIf
	__ReadVar    := "M->C7_TES"
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
	__ReadVar := _cRVarBk
	RestArea(_aSavSB1)
	RestArea(_aSavSC7)
	RestArea(_aSavArea)
return(.T.)