#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE020  �Autor  �Anderson C. P. Coelho � Data �  28/02/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock utilizado para n�o permitir a edi��o dos campos  ���
���          �C5_TPDIV e C6_TPCALC, quando existir alguma libera��o para o���
���          �pedido de vendas (faturado ou n�o), para manter a integrida-���
���          �de do processo.                                             ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.(CD Control)���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE020()

Local _aSavArea := GetArea()
Local _aSavSC9  := {}
Local _lRet     := .T.

dbSelectArea("SC9")
_aSavSC9 := SC9->(GetArea())
SC9->(dbSetOrder(1))
_lRet := !SC9->(MsSeek(xFilial("SC9") + M->C5_NUM,.T.,.F.))

RestArea(_aSavSC9)
RestArea(_aSavArea)

Return(_lRet)