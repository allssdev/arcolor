#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINE001  �Autor  �Anderson C. P. Coelho � Data �  22/04/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Execblock utilizado no cnab receber banco do Brasil		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Especifico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINE001()

Local _aSavArea := GetArea()
Local _aSavSE1  := SE1->(GetArea())
Local _cRet     := ""

If SE1->(E1_SALDO*E1_DESCFIN)==0 .OR. AllTrim(SE1->E1_OCORREN)=="32" .OR. SE1->(E1_VENCTO-E1_DIADESC) < SE1->E1_EMISSAO
	_cRet := "000000"
Else
	_cRet := GRAVADATA(SE1->(E1_VENCTO-E1_DIADESC),.F.)
EndIf

RestArea(_aSavSE1)
RestArea(_aSavArea)

Return(_cRet)