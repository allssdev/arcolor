#include 'parmtype.ch'
#include "totvs.ch"
/*/{Protheus.doc} MT440AT
@description Rotina respons�vel por sugerir a quantidade liberada para cada item na libera��o do pedido de vendas e executar o processo de valida��o do pedido de vendas.
@author Adriano Leonardo
@since 29/01/2013
@version 1.0
@return _lRet, logic, Passe .T., se o pedido puder ser liberado e .F., caso contr�rio.
@type function
@history 15/10/2013, J�lio Soares, Foi inserido um trecho para tratar o bloqueio da libera��o para pedidos que foram eliminados pelo processo de "Eliminacao de res�duos" onde o campo C5_NOTA contenha a letra "X".
@see https://allss.com.br
/*/
user function MT440AT()
	local _aSavArea	 := GetArea()
	local _aSavSC5 	 := SC5->(GetArea())
	local _aSavSC6 	 := SC6->(GetArea())
	local _aSavSC9 	 := SC9->(GetArea())
	local _cRotina   := "MT440AT"
	local _lRet	     := .T. //Pela estrutura da rotina padr�o x rotina de valida��o (customizada) deixar sempre como .T.
	local _cNota     := SC5->C5_NOTA
	local _cNum      := SC5->C5_NUM
	local _nBlq      := aScan(aHeader,{|x|AllTrim(x[02])=="C6_BLQ"   })
	local _nQLib     := aScan(aHeader,{|x|AllTrim(x[02])=="C6_QTDLIB"})
	// Trecho incluido por J�lio Soares em 15/10/2013 para impedir que pedidos que foram eliminados por res�duo (C5_NOTA $ 'X') sejam liberados.
	if !(Substr(_cNota,1,1)) $ "X"
		//Preenche o aCols da libera��o do pedido sugerindo a quantidade liberada caso n�o o valor atual da mesma seja igual a zero
		for _nCont := 1 to Len(aCols)
			if !aCols[_nCont][Len(aHeader)+1]
				if aCols[_nCont][Len(aHeader)] > 0
					_cTab := aCols[_nCont][Len(aHeader)-1]
					dbSelectArea(_cTab)
					_aSavTab := (_cTab)->(GetArea())
					(_cTab)->(dbSetOrder(1))
					dbGoTo(aCols[_nCont][Len(aHeader)])
					if aCols[_nCont][_nQLib] == 0
						aCols[_nCont][_nQLib] := (SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT))
					endif
					RestArea(_aSavTab)
				endif
			endif
		next
	//Trecho para validar se o pedido j� foi eliminado por res�duo.
	else
		MSGBOX('O pedido ' + (_cNum) + ' n�o pode ser liberado pois foi eliminado por res�duo.',_cRotina + '_01','STOP')
		_lRet := .F.
	endif
	RestArea(_aSavSC9)
	RestArea(_aSavSC6)
	RestArea(_aSavSC5)
	RestArea(_aSavArea)
return _lRet