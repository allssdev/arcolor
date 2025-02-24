#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RTMKE023 �Autor  � Adriano L. de Souza � Data � 24/04/2014   ���
��������������������������������������������������������������������������͹��
���Desc.   � Fun��o desenvolvida para validar a parcela m�nima permitida   ���
���Desc.   � pela condi��o de pagamento.                                   ���
���Desc.   � Par�metro esperado:                                           ���
���Desc.   � Valor m�nimo permitido (num�rico)                             ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

User Function RTMKE023(_nValMin)

Local _cRotina		:= "RTMKE023"
Local _aSavTmp		:= GetArea()
Local _lValid  		:= .T.
Local _nPrzMed 		:= 0
Local _cCondPg 		:= M->UA_CONDPG
Local _nVlrTot 		:= aValores[6] //Valor l�quido do atendimento
Local _nTotIpi		:= MaFisRet(1,"NF_VALIPI")
Local _nTotST		:= MaFisRet(1,"NF_VALSOL")
Local _dData		:= dDataBase
Local _aParcelas	:= {}
Local _nParMin		:= 0
Default _nValMin	:= 0

If _nValMin > 0
	_aParcelas := Condicao(_nVlrTot,_cCondPg,_nTotIPI,_dData,_nTotST)
	
	//Seleciono a parcela m�nima
	For _nCont := 1 To Len(_aParcelas)
		If _nCont == 1 .Or. _aParcelas[_nCont,2]<_nParMin
			_nParMin := _aParcelas[_nCont,2]
		EndIf
	Next
	
	//Verifico se a menor parcela � inferior ao m�nimo permitido
	If _nValMin > _nParMin
		_lValid := .F.
		MsgAlert("Condi��o de pagamento inv�lida, o valor de uma ou mais parcelas seria inferior a R$" + AllTrim(Transform(_nValMin,PesqPict("SE4","E4_MINIMO"))) + " que � o m�nimo estabelecido para ela, altere a condi��o de pagamento antes de continuar!",_cRotina+"_001")
	EndIf
	
EndIf

RestArea(_aSavTmp)

Return(_lValid)