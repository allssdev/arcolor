#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M410VRES  ºAutor  ³Júlio Soares       º Data ³  21/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.TOTVS³ Este ponto de entrada é executado após a confirmação da    º±±
±±º          ³ eliminação de residuos no pedido de venda e antes do inicioº±±
±±º          ³ da transação do mesmo.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Essa rotina está sendo utilizado para a atualização das    º±±
±±º          ³ legendas tanto para os pedidos de vendas (SC5) quanto para º±±
±±º          ³ o atendimento (SUA) referente.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M410VRES()

Local    _aSavArea := GetArea()
Local    _aSavSC5  := SC5->(GetArea())
Local    _aSavSUA  := SUA->(GetArea())
Local    _cRotina  := "M410VRES"
Local    _cLogx    := "Resíduo Eliminado"
Local    _cCli     := SC5->C5_CLIENTE
Local    _cLoja    := SC5->C5_LOJACLI
Local    _cNum     := SC5->C5_NUM

Private  _lRet     := .T.
Private  _lEnt     := CHR(13) + CHR (10)
Private  _cLog     := ""

// Precisa verificar se está liberado para eliminação
If Upper(AllTrim(FunName()))=="MATA410" .OR. Upper(AllTrim(FunName()))=="MATA500"
	while !RecLock('SC5',.F.) ; enddo
		SC5->C5_SALDO := 'R'
		// - Inserido em 24/03/2014 por Júlio Soares para gravar status também no quadro de vendas.
		If SC5->(FieldPos("C5_LOGSTAT"))>0
			_cLog           := Alltrim(SC5->C5_LOGSTAT)
			SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
								UsrRetName(__cUserId)+ _lEnt + _cLogx
		EndIf
		// - --------------------------------------------------------------------------------------
	SC5->(MsUnlock())
	dbSelectArea('SUA')
	SUA->(dbOrderNickName("UA_NUMSC5"))
	If SUA->(MsSeek(xFilial('SUA')+_cNum,.T.,.F.))
		while !RecLock('SUA',.F.) ; enddo
			SUA->UA_CODCANC := '*'
			If SUA->(FieldPos("UA_LOGSTAT")) > 0
				_cLog           := Alltrim(SUA->UA_LOGSTAT) + _lEnt
				SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
									UsrRetName(__cUserId) + _lEnt + _cLogx
			EndIf
			// Implementado por Júlio Soares em 11/12/2013 após realizar atualizações na legenda.
			If SUA->(FieldPos("UA_STATSC9")) > 0
				SUA->UA_STATSC9 := ''
			EndIf
		SUA->(MsUnlock())
	Else
		MSGBOX('Numero do atendimento não encontrado, informe o Administrador do sistema com o n° do pedido => '+ _cNum,_cRotina+'_01','ALERT')
	EndIf
EndIf
//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
If ExistBlock("RFATL001")
	U_RFATL001(	SC5->C5_NUM,;
				SUA->UA_NUM,;
				_cLogx     ,;
				_cRotina    )
EndIf
RestArea(_aSavSUA )
RestArea(_aSavSC5 )
RestArea(_aSavArea)

Return(_lRet)