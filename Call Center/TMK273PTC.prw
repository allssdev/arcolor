#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} TMK273PTC
@description Ponto de Entrada executado ap�s a transforma��o do Prospect em cliente (retorno l�gico).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 17/12/2012
@version 1.0
@return .T., l�gico, Valida��o da transforam��o de Prospect em Cliente.
@type function
@see https://allss.com.br
/*/
user function TMK273PTC()
	Local _aSavArea := GetArea()
	Local _aSavSA1  := SA1->(GetArea())
	Local _aSavSUS  := SUS->(GetArea())
	dbSelectArea("SA1")
	SA1->(MSUNLOCK())
	while !RecLock("SA1",.F.) ; enddo
		SA1->A1_RISCO := "E"
	SA1->(MSUNLOCK())
	RestArea(_aSavSA1)
	RestArea(_aSavSUS)
	RestArea(_aSavArea)
return .T.