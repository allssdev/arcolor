#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
//#INCLUDE "FINA330.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA240PA   �Autor  �Arthur Silva        � Data �  16/04/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � O ponto de entrada FA240PA permite a sele��o de PA com     ���
���          �movimento banc�rio na tela de Border� de pagamento.         ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA240PA()

Local _lRet := .T.		//.T., para o sistema permitir a sele��o de PA (com mov. Banc�rio) e .F. para n�o permitir.

Return(_lRet)