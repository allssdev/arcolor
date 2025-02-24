#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} 
@description Fonte para calculo de data de validade
@author		Diego Rodrigues Pereira email: diego.rodrigues@allss.com.br
@since 		14/11/2022
@version 	1.01
@see 		https://allss.com.br
@History 	
/*/

User Function RESTE010(_ddata,_cProduto)

Local _dDtValid := CtoD("//")
Local _ddatai := _ddata
Local _aArea   := GetArea()
Local _aSavSC2 := SC2->(GetArea())

_dDtValid := Ctod(DtoC(StoD(SubStr(DtoS(_ddatai),1,6) + "28") + POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"B1_PRVALID")))
_dDtValid := IIF(Substring(DtoS(_dDtValid),5,2) = '02',Ctod(DtoC(StoD(SubStr(DtoS(_dDtValid),1,6) + "28"))),Ctod(DtoC(StoD(SubStr(DtoS(_dDtValid),1,6) + "30"))))


RestArea(_aArea)
RestArea(_aSavSC2)

Return(_dDtValid)
