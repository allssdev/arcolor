#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa � RTMKE027 �Autor  � Adriano Leonardo    � Data � 08/05/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina desenvolvida para validar se a venda do produto foi ���
���          � autorizada ao cliente, segundo cadastro clientes x produtos���
�������������������������������������������������������������������������͹��
���Uso     � Protheus 11 - Espec�fico empresa ARCOLOR                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RTMKE027(_lValidFim)

Local _cRotina		:= "RTMKE027"
Local _aSavArea 	:= GetArea()
Local _aSavSA7		:= SA7->(GetArea())
Local _nPosProd		:= aScan(aHeader,{|x|AllTrim(x[02])==("UB_PRODUTO")})
Local _nPosItem		:= aScan(aHeader,{|x|AllTrim(x[02])==("UB_ITEM")})
Local _lRet			:= .T.
Local _nBkpLin 		:= n
Local _cMsgItem 	:= ""

Default _lValidFim 	:= .F.

If M->UA_TPOPER $ SuperGetMV("MV_OPVENDA",,"01") .And. _nPosProd>0 .And. _nPosItem>0//Opera��es consideradas como "venda"
	//Avalio cada item para identificar se a integridade da substitui��o do tipo de opera��o
	For n := 1 To Len(aCols)
		If !aCols[n][Len(aCols[n])] //Verifico se a linha est� deletada
			dbSelectArea("SA7")
			SA7->(dbSetOrder(1)) //Filial + Cliente + Loja + Produto
			If SA7->(FieldPos("A7_AUTORIZ"))<>0
				If SA7->(MsSeek(xFilial("SA7") + M->UA_CLIENTE + M->UA_LOJA + aCols[n][_nPosProd],.T.,.F.))
					If SA7->A7_AUTORIZ == "N"
						_cMsgItem += "Item: " + AllTrim(aCols[n][_nPosItem]) + " - Produto: " + AllTrim(aCols[n][_nPosProd]) + CHR(13) + CHR(10)
						_lRet     := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	If !_lRet
		//Analiso de onde veio a chamada da rotina para tratar a mensagem de alerta
		If !_lValidFim
			_cAlert := "A troca para esse tipo de opera��o n�o � poss�vel, porque um ou mais produtos n�o est�o autorizados para comercializa��o para este cliente!"
		Else
			_cAlert := "Um ou mais produtos n�o est�o autorizados para comercializa��o para este cliente!"
		EndIf
		_cAlert += CHR(13) + CHR(10) + "Caso deseje visualizar a rela��o de itens bloqueados, clique em 'Visualizar'."
		_nAux := Aviso(_cRotina+"_002",_cAlert,{"Abandonar","Visualisar"})
		If _nAux == 2
			MsgAlert(_cMsgItem,_cRotina+"_002")
		EndIf
	EndIf
EndIf

//Restauro a �rea de trabalho original
n := _nBkpLin
RestArea(_aSavSA7)
RestArea(_aSavArea)

Return(_lRet)