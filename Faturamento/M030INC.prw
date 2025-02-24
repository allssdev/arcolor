#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M030INC   �Autor  �Anderson C. P. Coelho � Data �  03/05/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada chamado na inclus�o de clientes, utilizado���
���          �aqui para a inclus�o de Item Cont�bil (tabela CTD).         ���
���          � O par�metro "PARAMIXB" recebido pelo ponto de entrada,     ���
���          �retorna a op��o selecionada pelo usu�rio na confirma��o.    ���
���          �Isso �, o retorno 3, por exemplo, identifica que o usu�rio  ���
���          �cancelou a inclus�o do cliente.                             ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arc�lor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M030INC()

Local _aSavArea := GetArea()
Local _aSavSA1  := SA1->(GetArea())
Local _aSavSRA  := SRA->(GetArea())
Local _aSavCTD  := CTD->(GetArea())
Local _cRotina  := "M030INC"

If PARAMIXB == 0	//PARAMIXB <> 3
	dbSelectArea("CTD")
	CTD->(dbSetOrder(1))			//CTD_FILIAL+CTD_ITEM
	If !CTD->(dbSeek(xFilial("CTD") + Padr("C"+(SA1->A1_COD+SA1->A1_LOJA),TamSx3("CTD_ITEM")[01])))
		while !RecLock("CTD",.T.) ; enddo
			CTD->CTD_FILIAL := xFilial("CTD")
			CTD->CTD_ITEM   := "C"+(SA1->A1_COD+SA1->A1_LOJA)
			CTD->CTD_ITLP   := "C"+(SA1->A1_COD+SA1->A1_LOJA)
			CTD->CTD_DESC01 := SA1->A1_CGC + " - " + SA1->A1_NREDUZ
			CTD->CTD_CLASSE := "2"
			CTD->CTD_NORMAL := "2"
			CTD->CTD_BLOQ   := "2"
			CTD->CTD_CLOBRG := "2"
			CTD->CTD_ACCLVL := "1"
			CTD->CTD_DTEXIS := STOD('20150101')		//Date()
	Else
		while !RecLock("CTD",.F.) ; enddo
			CTD->CTD_ITLP   := "C"+(SA1->A1_COD+SA1->A1_LOJA)
			CTD->CTD_DESC01 := SA1->A1_CGC + " - " + SA1->A1_NREDUZ
			CTD->CTD_CLASSE := "2"
			CTD->CTD_NORMAL := "2"
			CTD->CTD_BLOQ   := "2"
			CTD->CTD_CLOBRG := "2"
			CTD->CTD_ACCLVL := "1"
	EndIf
	CTD->(MSUNLOCK())
EndIf

RestArea(_aSavCTD)
RestArea(_aSavSRA)
RestArea(_aSavSA1)
RestArea(_aSavArea)

Return NIL