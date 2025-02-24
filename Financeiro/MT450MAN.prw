#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � MT450MAN �Autor  � Adriano L. de Souza � Data �  16/07/2014  ���
��������������������������������������������������������������������������͹��
��� Desc.  � Ponto de entrada para validar a libera��o de cr�dito manual do���
���        � pedido de venda, utilizado para avaliar o v�nculo do pedido   ���
���        � com poss�veis t�tulos RAs/NCCs.                               ���
���        � Rotina validada em 19/08/2014                                 ���
��������������������������������������������������������������������������͹��
���Uso     � Protheus11 - Espec�fico para a empresa Arcolor.               ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
������������������������������������������������������������������������������
*/

User Function MT450MAN()

Local _cRotina 	:= "MT450MAN"
Local _aSavArea	:= GetArea()
Local _lRet		:= .T.

//If __cUserId=="000000"
	//Chamada da rotina de v�nculo de adiantamento com pedido de venda
	If ExistBlock("RFINE021")
		_lRet := U_RFINE021()
		//Verifica��o de seguran�a para garantir retorno l�gico para o ponto de entrada
		If _lRet == Nil
			_lRet := .T.
		EndIf
	EndIf
//EndIf

RestArea(_aSavArea)

Return(_lRet)