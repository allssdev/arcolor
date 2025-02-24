#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDA100I  ºAutor  ³Anderson C. P. Coelho º Data ³  21/03/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para validação dos itens marcados, para   º±±
±±º          ³geração das ordens de separação.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ACDA100I()

Local _aSavArea := GetArea()
Local _aSavSC9  := {}
Local _cRotina  := "ACDA100I"
Local _lRet     := SC9->(IsMark("C9_OK",ThisMark(),ThisInv())) 
Local _cMarca   := SC9->C9_OK
Local _cPedido  := SC9->C9_PEDIDO

dbSelectArea("SC9")
_aSavSC9 := SC9->(GetArea())

If _lRet
	SC9->(dbSetOrder(1))
	SC9->(dbGoTop())
	_lRet := SC9->(MsSeek(xFilial("SC9") + _cPedido,.T.,.F.))
	While _lRet .AND. !SC9->(EOF()) .AND. xFilial("SC9") == SC9->C9_FILIAL .AND. _cPedido == SC9->C9_PEDIDO
		_lRet := SC9->(IsMark("C9_OK",ThisMark(),ThisInv())) .AND. Empty(SC9->(C9_BLEST+C9_BLCRED+C9_BLOQUEI))
		SC9->(dbSkip())
	EndDo
EndIf

RestArea(_aSavSC9)
RestArea(_aSavArea)

Return(_lRet)