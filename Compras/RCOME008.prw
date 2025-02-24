#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCOME008  �Autor  �J�lio Soares        � Data �  09/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Execblock                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Especifico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RCOME008()

Local _aSavArea := GetArea()
Local _cNomCli  := ""

If AllTrim(SF1->F1_TIPO) $ "D/B"
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1") + SF1->F1_CLIENTE + SF1->F1_LOJA,.T.,.F.))
		_cNomCli := SA1->A1_NOME
	EndIf
Else
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	If SA2->(MsSeek(xFilial("SA2") + SF1->F1_CLIENTE + SF1->F1_LOJA,.T.,.F.))
		_cNomCli := SA2->A2_NOME
	EndIf
EndIf

RestArea(_aSavArea)

Return(_cNomCli)