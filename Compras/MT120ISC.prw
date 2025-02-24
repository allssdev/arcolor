#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATR015 �Autor�Marcelo Vieira Evangelista�Data  � 17/01/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Carregar campo criado pelo usuario na Solicitacao de compra.���
���          �no pedido de compra                                         ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT120ISC()

Local _aSavArea := GetArea()

If nTipoPed != 2
	aCols[n][gdFieldPos("C7_JUSTCOM")] := SC1->C1_JUSCOM
EndIf

RestArea(_aSavArea)

Return(Nil)