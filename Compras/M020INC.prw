#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M020INC   ºAutor  ³Anderson C. P. Coelho º Data ³  03/05/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada chamado na inclusão de fornecedores,      º±±
±±º          ³utilizado aqui para a inclusão de Item Contábil (tab. CTD). º±±
±±º          ³ O parâmetro "PARAMIXB" recebido pelo ponto de entrada,     º±±
±±º          ³retorna a opção selecionada pelo usuário na confirmação.    º±±
±±º          ³Isso é, o retorno 3, por exemplo, identifica que o usuário  º±±
±±º          ³cancelou a inclusão do fornecedor.                          º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcólor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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