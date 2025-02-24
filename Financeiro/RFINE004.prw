#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINE004  �Autor  �Adriano Leonardo    � Data �  09/05/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina desenvolvida com o objetivo de retornar o endere�o de���
���          �cobran�a do cliente que ser� utilizado no CNAB e no boleto. ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINE004()

Local _aSavArea := GetArea()
Local _cEnderec := ""
Local _cRotina	:= "RFINE004"

dbSelectArea("SA1")

If !Empty(SA1->A1_ENDCOB)
	_cEnderec := SA1->A1_ENDCOB
Else
	MsgInfo("O endere�o de cobran�a do cliente " + AllTrim(SA1->A1_COD) + " - " + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME) + " n�o foi preenchido!",_cRotina+"_001")
EndIf

RestArea(_aSavArea)

Return(_cEnderec)