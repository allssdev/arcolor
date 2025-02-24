#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M103LSE2  �Autor  � J�lio Soares      � Data �  03/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para realizar a valida��o das   ���
���          � datas de vencimento para os documentos de entrada.         ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M103LSE2()

Local _lRet := .T.
// - Rotina desativada em 07/08/15 por J�lio Soares ap�s discutir processo com o Sr. Marco Antonio.
/*
If !Empty(aCols[n][02])
	If aCols[n][02] - _aDuplic[n][01] > 5
		MSGBOX('A data de vencimento da ' + cValToChar(n) + '� linha da condi��o de pagamento n�o pode ser maior que 5 dias da condi��o escolhida no pedido de compras','M103LSE2_001','ALERT')
		_lRet := .F.
	EndIf
	If _aDuplic[n][01] - aCols[n][02] > 5
		MSGBOX('A data de vencimento da ' + cValToChar(n) + '� linha da condi��o de pagamento n�o pode ser menor que 5 dias da condi��o escolhida no pedido de compras','M103LSE2_001','ALERT')
		_lRet := .F.
	EndIf
EndIf
*/
Return(_lRet)