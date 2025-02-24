#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOMA004  ºAutor  ³Diego Rodrigues	   º Data ³  11/06/21 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina Desenvolvida para alteração da ordem de produção    º±±
±±º          ³ na rotina de horas de improdutivas				          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 12 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RPCPE006()

Local _aSavArea := GetArea()
Local _aSavSH6  := SH6->(GetArea())
Local _cOP  := SH6->H6_XOP
Local _cMotivo    := SH6->H6_MOTIVO
Local _cRecurso := SH6->H6_RECURSO
Local oGetv1
Local oGroupv1
Local oSayv1
Local oSButtonv1
Local oSButtonv2


Private _cOPnova := "           "
Private _cRotina := "RPCPE006"

static oDlgv

  DEFINE MSDIALOG oDlgv TITLE "ALTERAÇÃO HORAS IMPRODUTIVAS"          FROM 000, 000 TO 130, 240                     COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

    @ 007, 003 GROUP   oGroupv1 TO 058, 116 PROMPT " Informe o numero da OP" OF oDlgv                             	COLOR  0, 16777215 PIXEL
    @ 021, 005   SAY   oSayv1 				PROMPT "Ordem de Produção:"   SIZE 037, 007 OF oDlgv                    COLORS 0, 16777215 PIXEL
    @ 019, 045 MSGET   oGetv1   VAR _cOPnova  SIZE 070, 010 OF oDlgv PICTURE PesqPict("SH6","H6_OP")           VALID NAOVAZIO()  COLORS 0, 16777215 PIXEL

	    DEFINE SBUTTON oSButtonv1 FROM 040, 025 TYPE 01 OF oDlgv ENABLE Action EVAL({|| _lRet := .T., oDlgv:End()})
	    DEFINE SBUTTON oSButtonv2 FROM 040, 070 TYPE 02 OF oDlgv ENABLE Action EVAL({|| _lRet := .F., oDlgv:End()})

  ACTIVATE MSDIALOG oDlgv CENTERED
  



If !Empty(_cOPnova) .and. _lRet 
	If MsgYesNo("Deseja realmente alterar a Ordem de Produção  "+_cOP+" para : "+_cOPnova+" ?",_cRotina+"_001")
		dbSelectArea("SH6")
		SH6->(dbSetOrder(6))
		If	SH6->(MsSeek(xFilial("SH6") + _cOP+_cRecurso,.T.,.F.)) //H6_FILIAL+H6_XOP+H6_MOTIVO
				RecLock("SH6",.F.)
					H6_XOP := _cOPnova
				SH6->(MsUnLock())
			If	SC2->(MsSeek(xFilial("SC2") + SUBSTR(_cOPnova,1,6),.T.,.F.))
				RecLock("SH6",.F.)
					H6_XPRODUT := SC2->C2_PRODUTO
				SH6->(MsUnLock())
			Endif
			If	SB1->(MsSeek(xFilial("SB1") + SH6->H6_XPRODUT,.T.,.F.))
				RecLock("SH6",.F.)
					H6_XDESCRI := SB1->B1_DESC
				SH6->(MsUnLock())
			Endif
			
			
			MsgInfo("Ajuste Realizado com Sucesso!!!",_cRotina+"_002")
		EndIf
	EndIf
EndIf


RestArea(_aSavSH6)
RestArea(_aSavArea)

Return
