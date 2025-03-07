#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE033  �Autor  �J�lio Soares        � Data �  12/06/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock criado para retornar o nome do fornecedor ou     ���
���Desc.     � cliente de acordo com o tipo de nota de sa�da.             ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Especifico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE033()

Local _aSavArea := GetArea()
Local _cRotina  := 'RFATE026'
Local _cNomCli  := ""

If AllTrim(SF1->F1_TIPO) $ "D/B"
	dbSelectArea("SA1")
	dbSetOrder(1)
	If MsSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA,.T.,.F.)
		_cNomCli := SA1->A1_NOME
	EndIf
Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	If MsSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,.T.,.F.)
		_cNomCli := SA2->A2_NOME
	EndIf
EndIf
       
RestArea(_aSavArea)

Return(_cNomCli)