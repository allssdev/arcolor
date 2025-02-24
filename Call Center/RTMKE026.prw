#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa � RTMKE026 �Autor  � Adriano Leonardo    � Data � 08/05/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina desenvolvida para validar se a venda do produto foi ���
���          � autorizada ao cliente, segundo cadastro clientes x produtos���
�������������������������������������������������������������������������͹��
���Uso     � Protheus 11 - Espec�fico empresa ARCOLOR                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RTMKE026()

Local _cRotina	:= "RTMKE026"
Local _aSavArea := GetArea()
Local _aSavSA7	:= SA7->(GetArea())
Local _nPosProd	:= aScan(aHeader,{|x|AllTrim(x[02])==("UB_PRODUTO")})
Local _lRet		:= .T.

If M->UA_TPOPER $ SuperGetMV("MV_OPVENDA",,"01") //Opera��es consideradas como "venda"
	dbSelectArea("SA7")
	SA7->(dbSetOrder(1)) //Filial + Cliente + Loja + Produto
	If SA7->(FieldPos("A7_AUTORIZ"))<>0
		If SA7->(MsSeek(xFilial("SA7") + M->UA_CLIENTE + M->UA_LOJA + aCols[n][_nPosProd],.T.,.F.))
			If SA7->A7_AUTORIZ == "N"
				MsgAlert("A venda deste produto n�o foi autorizada para este cliente!",_cRotina+"_001")
				_lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(_aSavSA7)
RestArea(_aSavArea)

Return(_lRet)