#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINE007  �Autor  �Adriano Leonardo    � Data �  09/05/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina desenvolvida com o objetivo de retornar o CEP de     ���
���          �cobran�a do cliente que ser� utilizado no CNAB e no boleto. ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINE007()

Local _aSavArea := GetArea()
Local _cCepCobr := ""
Local _cRotina	:= "RFINE007"

dbSelectArea("SA1")
If !Empty(SA1->A1_CEPC)
	_cCepCobr := SA1->A1_CEPC
Else
	MsgInfo("O CEP de cobran�a do cliente " + AllTrim(SA1->A1_COD) + " - " + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME) + " n�o foi preenchido!",_cRotina+"_001")
EndIf

RestArea(_aSavArea)

Return(_cCepCobr)