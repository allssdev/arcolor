#include "totvs.ch"
#include "topconn.ch"
/*/{Protheus.doc} MTA455NL
@description Ap�s a Nova Libera��o de Estoque do pedido de vendas, grava algumas informa��es na SC9.   
Neste caso, estamos utilizando para a "Nova Libera��o" de estoque, ap�s limpar o campo data "C9_DTLIBCR"
 seja realimentado pelo conte�do do campo anteriormente gravado na SC5->C5_DTLIBCR. 
@author Anderson C. P Coelho (ALLSS Solu��es em Sistemas)
@since 15/08/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
user function MTA455NL()
	local _aArea   := GetArea()
	local _aSvSC5  := SC5->(GetArea())
	local _aSvSC9  := SC9->(GetArea())
	local _aSvSE4  := SE4->(GetArea())
	local _cQUpd1  := ""
	local _cDesPag := ""
	local _cRotina := "MTA455NL"
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	if SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		dbSelectArea("SE4")
		SE4->(dbSetOrder(1))
		if SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG,.T.,.F.))
			_cDesPag := SubStr(AllTrim(SE4->E4_DESCRI),1,Len(SC9->C9_DESCPAG))
		else
			_cDesPag := ""
		endif
		_cQUpd1 := " UPDATE  " + RetSqlName("SC9") 
		_cQUpd1 += " SET C9_DTLIBCR = '" + DTOS(SC5->C5_DTLIBCR) + "' " 
		_cQUpd1 += " ,  C9_OBSSEP   = '" + SubStr(AllTrim(SC5->C5_OBSSEP),1,Len(SC9->C9_OBSSEP )) + "' " 
		_cQUpd1 += " ,  C9_DESCPAG  = '" + _cDesPag  + "' " 
		_cQUpd1 += " WHERE C9_PEDIDO  = '" + SC9->C9_PEDIDO + "' " 
		if TCSQLExec(_cQUpd1) < 0
			MSGSTOP("[TCSQLError] " + TCSQLError(),_cRotina+"_001",'STOP')
		endif
	endif
	RestArea(_aSvSE4)
	RestArea(_aSvSC5)
	RestArea(_aSvSC9)
	RestArea(_aArea)
return
