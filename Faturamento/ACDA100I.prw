#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACDA100I  �Autor  �Anderson C. P. Coelho � Data �  21/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para valida��o dos itens marcados, para   ���
���          �gera��o das ordens de separa��o.                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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