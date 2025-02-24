#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCOMA003  �Autor  �Adriano Leonardo      � Data �21/03/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina desenvolvida para chama a rotina padr�o de pedido de���
���          � compras, somente para que o funname seja diferente do      ���
���          � padr�o, para tratamento espec�fico da origem do pedido se  ���
���          � pelo departamento de compras ou outro departamento.        ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a Arcolor.                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RCOMA003()

Local _aArea := GetArea()

MATA121() //Chamada da rotina padr�o de pedido de compra

RestArea(_aArea)

Return()