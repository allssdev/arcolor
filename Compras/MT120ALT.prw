#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT120ALT º Autor ³Anderson C. P. Coelho º Data ³  17/04/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na alteração do pedido de compras, utili- º±±
±±ºDesc.     ³ zado para impedir a alteração do pedido gerado como paga-  º±±
±±ºDesc.     ³ mento de comissão.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
user function MT120ALT()
	Local _cRotina	:= "MT120ALT"
	Local _aSavArea := GetArea()
	Local _lRet		:= .T.
	If Altera
		dbSelectArea("SE3")
		If SE3->(dbOrderNickName("E3_PEDCOM")) //Filial + Pedido de compra
			//Verifico se o pedido de compra foi gerado como pagamento de comissão
			If SE3->(dbSeek(xFilial("SE3")+SC7->C7_NUM))
				_lRet := .F.
				MsgStop("Este pedido está vinculado ao pagamento de uma comissão e não poderá ser alterado!",_cRotina + "_001")
			EndIf
		Else
			MsgAlert("Atenção! Problemas encontrados no sistema. Reporte a seguinte mensagem ao Administrador (sua operação ocorrerá sem preocupações): "+_cRotina+"_001",_cRotina+"_001")
		EndIf
	EndIf
	RestArea(_aSavArea)
return(_lRet)