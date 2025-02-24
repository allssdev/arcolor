#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE _lEnt CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTA450R     ºAutor  ³Júlio Soares     º Data ³  14/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na avaliação do crédito do cliente        º±±
±±º          ³(MATA450A)para atualizar o campo da tabela SUA com o status.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function MTA450R()
	Local _aSavArea := GetArea()
	Local _aSavSC9  := SC9->(GetArea())
	Local _aSavSUA  := SUA->(GetArea())
	Local _aSavSC5  := SC5->(GetArea())
	Local _lRet     := .T.
	Local _cLogx    := ""
	Local _cRotina  := "MTA450R"
	Private _cLog   := ""

	dbSelectArea("SUA")
	SUA->(dbOrderNickName("UA_NUMSC5"))
	If SUA->(MsSeek(xFilial("SUA") + SC9->C9_PEDIDO,.T.,.F.))
		_cLog := Alltrim(SUA->UA_LOGSTAT)
		If SC9->C9_BLEST == "02" .AND. Empty(SC9->C9_BLCRED)
			_cLogx := "PEDIDO EM AVALIAÇÃO DE DISPONIBILIDADE DE ESTOQUE."
			while !RecLock("SUA", .F.) ; enddo
				SUA->UA_STATSC9 := "03"
				If SUA->(FieldPos("UA_LOGSTAT"))>0
					SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
										UsrRetName(__cUserId) + _lEnt + _cLogx
				EndIf
			SUA->(MsUnLock())
		Else
			If Empty(SUA->UA_STATSC9)
				_cLogx := "PEDIDO DE VENDA AGUARDANDO LIBERAÇÃO DE CRÉDITO."
				while !RecLock("SUA", .F.) ; enddo
					SUA->UA_STATSC9 := "02"
					If SUA->(FieldPos("UA_LOGSTAT"))>0
						SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
											UsrRetName(__cUserId) + _lEnt + _cLogx
					EndIf
				SUA->(MsUnLock())
			EndIf
		EndIf
	EndIf
	// - Inserido em 24/03/2014 por Júlio Soares para gravar status também no quadro de vendas.
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		_cLog := Alltrim(SC5->C5_LOGSTAT)
		If SC9->C9_BLEST == "02" .AND. Empty(SC9->C9_BLCRED)
			_cLogx := "PEDIDO EM AVALIAÇÃO DE DISPONIBILIDADE DE ESTOQUE"
			If SC5->(FieldPos("C5_LOGSTAT"))>0
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
										UsrRetName(__cUserId) + _lEnt + _cLogx
				SC5->(MsUnLock())
			EndIf
		Else
			_cLogx := "PEDIDO DE VENDA AGUARDANDO LIBERAÇÃO DE CRÉDITO."
			If SC5->(FieldPos("C5_LOGSTAT"))>0
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
										UsrRetName(__cUserId) + _lEnt + _cLogx
				SC5->(MsUnLock())
			EndIf
		EndIf
	EndIf
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	If ExistBlock("RFATL001")
		U_RFATL001(	SC5->C5_NUM  ,;
					SUA->UA_NUM,;
					_cLogx     ,;
					_cRotina    )
	EndIf
	// - --------------------------------------------------------------------------------------
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÌ
	//³ SUA->UA_STATSC9        ³
	//³01 - Bloqueio de Regra  ³
	//³02 - Bloqueio de Crédito³
	//³03 - Bloqueio de Estoque³
	//³04 - Pedido em Separação³
	//³05 - Pedido expedido    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÌ
	RestArea(_aSavSUA)
	RestArea(_aSavSC5)
	RestArea(_aSavSC9)
	RestArea(_aSavArea)
return(_lRet)