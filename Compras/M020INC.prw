#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M020INC   �Autor  �Anderson C. P. Coelho � Data �  03/05/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada chamado na inclus�o de fornecedores,      ���
���          �utilizado aqui para a inclus�o de Item Cont�bil (tab. CTD). ���
���          � O par�metro "PARAMIXB" recebido pelo ponto de entrada,     ���
���          �retorna a op��o selecionada pelo usu�rio na confirma��o.    ���
���          �Isso �, o retorno 3, por exemplo, identifica que o usu�rio  ���
���          �cancelou a inclus�o do fornecedor.                          ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arc�lor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M020INC()

Local _aSavArea := GetArea()
Local _aSavSA2  := SA2->(GetArea())
Local _aSavCTD  := CTD->(GetArea())
Local _cRotina  := "M020INC"
Local _nOpc		:= PARAMIXB

//If PARAMIXB == 0	//PARAMIXB <> 3  // Comentado por Arthur Silva em 24/07/2017 devido ao PARAMIXB estar trazendo valores Nulos.
If Inclui
	dbSelectArea("CTD")
	CTD->(dbSetOrder(1))			//CTD_FILIAL+CTD_ITEM
	If !CTD->(dbSeek(xFilial("CTD") + Padr("F"+(SA2->A2_COD+SA2->A2_LOJA),TamSx3("CTD_ITEM")[01])))
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL := xFilial("CTD")
		CTD->CTD_ITEM   := "F"+(SA2->A2_COD+SA2->A2_LOJA)
		CTD->CTD_ITLP   := "F"+(SA2->A2_COD+SA2->A2_LOJA)
		CTD->CTD_DESC01 := SA2->A2_CGC + " - " + SA2->A2_NREDUZ
		CTD->CTD_CLASSE := "2"
		CTD->CTD_NORMAL := "2"
		CTD->CTD_BLOQ   := "2"
		CTD->CTD_CLOBRG := "2"
		CTD->CTD_ACCLVL := "1"
		CTD->CTD_DTEXIS := STOD('20150101')		//Date()
	Else
		RecLock("CTD",.F.)
		CTD->CTD_ITLP   := "F"+(SA2->A2_COD+SA2->A2_LOJA)
		CTD->CTD_DESC01 := SA2->A2_CGC + " - " + SA2->A2_NREDUZ
		CTD->CTD_CLASSE := "2"
		CTD->CTD_NORMAL := "2"
		CTD->CTD_BLOQ   := "2"
		CTD->CTD_CLOBRG := "2"
		CTD->CTD_ACCLVL := "1"
	EndIf
	CTD->(MSUNLOCK())
EndIf

RestArea(_aSavCTD)
RestArea(_aSavSA2)
RestArea(_aSavArea)

Return NIL