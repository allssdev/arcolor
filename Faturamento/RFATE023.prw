#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���Programa  �RFATE023 �Autor  �Thiago Silva de Almeida  �Data � 25/03/13 ���
�������������������������������������������������������������������������͹��
���Descri��o �Execblok para retornar o nome do cliente ou fornecedor no   ���
���          �campo virtual nomeado C9_NOMCLI.                            ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE023()

Local _aSavArea := GetArea()
Local _cNomCli 	:= ""

dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())
dbSelectArea("SA2")
_aSavSA2 := SA2->(GetArea())
dbSelectArea("SC5")
_aSavSC5 := SC5->(GetArea())
SC5->(dbSetOrder(1))

If MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.)
	If !AllTrim(SC5->C5_TIPO) $ "D/B"
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
			_cNomCli := SA1->A1_NOME
		EndIf
	Else
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		If SA2->(MsSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
			_cNomCli := SA2->A2_NOME
		EndIf
	EndIf  
EndIf

RestArea(_aSavSA2)
RestArea(_aSavSA1)
RestArea(_aSavSC5)
RestArea(_aSavArea)

Return(_cNomCli)