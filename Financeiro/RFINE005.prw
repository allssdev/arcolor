#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINE005  �Autor  �Adriano Leonardo    � Data �  09/05/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina desenvolvida com o objetivo de retornar o endere�o de���
���          �cobran�a do cliente que ser� utilizado no CNAB e no boleto. ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINE005()

Local _aSavArea := GetArea()
Local _cMunicCo := ""
Local _cRotina	:= "RFINE005"

dbSelectArea("SA1")
If !Empty(SA1->A1_MUNC)
	_cMunicCo := SA1->A1_MUNC
Else
	MsgInfo("O munic�pio de cobran�a do cliente " + AllTrim(SA1->A1_COD) + " - " + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME) + " n�o foi preenchido!",_cRotina+"_001")
EndIf

RestArea(_aSavArea)

Return(_cMunicCo)