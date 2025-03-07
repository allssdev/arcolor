#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE026  �Autor  �Anderson C. P. Coelho � Data �  05/04/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock criado para retornar o nome do cliente ou        ���
���Desc.     � fornecedor de acordo com o tipo de nota de sa�da.          ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Especifico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE026()

Local _aSavArea := GetArea()
Local _cRotina  := 'RFATE026'
Local _cNomCli  := ""

If AllTrim(SF2->F2_TIPO) $ "D/B"
	dbSelectArea("SA2")
	dbSetOrder(1)
	If MsSeek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA,.T.,.F.)
		_cNomCli := SA2->A2_NOME
	EndIf
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	If MsSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,.T.,.F.)
		_cNomCli := SA1->A1_NOME
	EndIf
EndIf

RestArea(_aSavArea)

Return(_cNomCli)