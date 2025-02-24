#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ RTMKE023 ºAutor  ³ Adriano L. de Souza º Data ³ 24/04/2014   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Função desenvolvida para validar a parcela mínima permitida   º±±
±±ºDesc.   ³ pela condição de pagamento.                                   º±±
±±ºDesc.   ³ Parâmetro esperado:                                           º±±
±±ºDesc.   ³ Valor mínimo permitido (numérico)                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11  ³ Uso específico Arcolor                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RTMKE023(_nValMin)

Local _cRotina		:= "RTMKE023"
Local _aSavTmp		:= GetArea()
Local _lValid  		:= .T.
Local _nPrzMed 		:= 0
Local _cCondPg 		:= M->UA_CONDPG
Local _nVlrTot 		:= aValores[6] //Valor líquido do atendimento
Local _nTotIpi		:= MaFisRet(1,"NF_VALIPI")
Local _nTotST		:= MaFisRet(1,"NF_VALSOL")
Local _dData		:= dDataBase
Local _aParcelas	:= {}
Local _nParMin		:= 0
Default _nValMin	:= 0

If _nValMin > 0
	_aParcelas := Condicao(_nVlrTot,_cCondPg,_nTotIPI,_dData,_nTotST)
	
	//Seleciono a parcela mínima
	For _nCont := 1 To Len(_aParcelas)
		If _nCont == 1 .Or. _aParcelas[_nCont,2]<_nParMin
			_nParMin := _aParcelas[_nCont,2]
		EndIf
	Next
	
	//Verifico se a menor parcela é inferior ao mínimo permitido
	If _nValMin > _nParMin
		_lValid := .F.
		MsgAlert("Condição de pagamento inválida, o valor de uma ou mais parcelas seria inferior a R$" + AllTrim(Transform(_nValMin,PesqPict("SE4","E4_MINIMO"))) + " que é o mínimo estabelecido para ela, altere a condição de pagamento antes de continuar!",_cRotina+"_001")
	EndIf
	
EndIf

RestArea(_aSavTmp)

Return(_lValid)