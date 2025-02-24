#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���Programa  �RFATE024 �Autor  �Thiago Silva de Almeida  �Data � 26/03/13 ���
�������������������������������������������������������������������������͹��
���Descri��o �Execblok para retornar o saldo disponivel em estoque campo  ���
���          �campo virtual nomeado C9_SALDISP.                           ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE024()

Local _aSavArea := GetArea()
Local _nRet     := 0

dbSelectArea("SB2")
SB2->(dbSetOrder(1))
If SB2->(MsSeek(xFilial("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL,.T.,.F.))
	_nRet := SaldoSB2(,,,,,"SB2")
EndIf

RestArea(_aSavArea)                                    

Return(_nRet)