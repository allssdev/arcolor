#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE017  �Autor  �Adriano Leonardo    � Data �  10/01/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina desenvolvida para impedir duplicidade de cadastro   ���
���          � na SZ5 (N�vel de Acesso Campos).                           ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Especifico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE017()                            

Local _lRet    := .T. 
Local _cRotina := "RFATE017"

dbSelectArea("SZ5")
dbSetOrder(1)
//Verifica se cadastro j� existe
If MsSeek(xFilial("SZ5") + Upper(Padr(M->Z5_GRUPO,24)) + Upper(Padr(M->Z5_TABELA,4)) + Upper(Padr(M->Z5_CAMPO,12)),.T.,.F.)
	_lRet := .F.
	MsgStop("J� existe um cadastro id�ntico a este!",_cRotina+"_001")
EndIf

Return(_lRet)