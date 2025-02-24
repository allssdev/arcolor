#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT120ALT � Autor �Anderson C. P. Coelho � Data �  17/04/17 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada na altera��o do pedido de compras, utili- ���
���Desc.     � zado para impedir a altera��o do pedido gerado como paga-  ���
���Desc.     � mento de comiss�o.                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
user function MT120ALT()
	Local _cRotina	:= "MT120ALT"
	Local _aSavArea := GetArea()
	Local _lRet		:= .T.
	If Altera
		dbSelectArea("SE3")
		If SE3->(dbOrderNickName("E3_PEDCOM")) //Filial + Pedido de compra
			//Verifico se o pedido de compra foi gerado como pagamento de comiss�o
			If SE3->(dbSeek(xFilial("SE3")+SC7->C7_NUM))
				_lRet := .F.
				MsgStop("Este pedido est� vinculado ao pagamento de uma comiss�o e n�o poder� ser alterado!",_cRotina + "_001")
			EndIf
		Else
			MsgAlert("Aten��o! Problemas encontrados no sistema. Reporte a seguinte mensagem ao Administrador (sua opera��o ocorrer� sem preocupa��es): "+_cRotina+"_001",_cRotina+"_001")
		EndIf
	EndIf
	RestArea(_aSavArea)
return(_lRet)