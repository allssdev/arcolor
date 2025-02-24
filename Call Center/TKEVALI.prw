#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TKEVALI   �Autor  �Anderson C. P. Coelho � Data �  22/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para a valida��o da linha dos itens do    ���
���          �atendimento Call Center.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TKEVALI()

Local _aSavArea := GetArea()
Local _lRet     := .T.

If ExistBlock("RTMKE009") .AND. !aCols[n][Len(aHeader)+1]
	_lRet := ExecBlock("RTMKE009")
EndIf

RestArea(_aSavArea)

Return(_lRet)