#include 'parmtype.ch'
#include "totvs.ch"
/*/{Protheus.doc} MT440GR
@description Ponto de Entrada na confirma��o de libera��o dos pedidos de vendas, utilizado retirar a flag de Lock da transa��o.
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 08/10/2019
@version 1.0
@type function
@return _lRet, l�gico, Se valida ou n�o a opera��o, sobrepondo assim a confirma��o padr�o.
@history 22/10/2019, Anderson C. P. Coelho (ALLSS Solu��es em Sistemas), Retirado o lock customizado do registro que minimizava os riscos na libera��o dos pedidos de vendas pois, conforme relatado pela consultora L�via, o risco foi praticamente eliminado p�s migra��o do release P12.1.17 para o P12.1.25. 
@see https://allss.com.br
/*/
user function MT440GR()
	local _aSavArea	 := GetArea()
	local _aSavSC5 	 := SC5->(GetArea())
	local _aSavSC6 	 := SC6->(GetArea())
	local _aSavSC9 	 := SC9->(GetArea())
	local _x         := 0
//	local _cLockR    := "PEDIDO_"+SC5->C5_NUM+"_"+DTOS(Date())
	local _nPQtLib   := aScan(aHeader,{|x|AllTrim(x[02])=="C6_QTDLIB"})
	local _lRet      := .T.
	for _x := 1 to Len(aCols)
		if !aCols[_x][Len(aHeader)+1] .AND. aCols[_x][Len(aHeader)] > 0 .and. _lRet
			dbSelectArea("SC6")
			SC6->(dbGoTo(aCols[_x][Len(aHeader)]))	//A �ltima coluna do aCols se refere ao Recno na SC6
			if aCols[_x ][_nPQtLib]  > (SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT))
				_lRet := .F.
			endif
		endif
	next
	//Bloqueio realizado pelos P.E.s MA440VLD e MT410ACE e Desbloqueio realizado pelos P.E.s MT440GR, M410STTS e M410ABN
	//UnLockByName(_cLockR)
//	Leave1Code(_cLockR)
	RestArea(_aSavSC9)
	RestArea(_aSavSC6)
	RestArea(_aSavSC5)
	RestArea(_aSavArea)
return _lRet