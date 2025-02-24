#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ RFATE043 ºAutor  ³ Adriano L. de Souza º Data ³ 02/05/2014   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Execblock de validação da condição de pagamento no pedido de  º±±
±±º        ³ vendas, esse execblock será chamado na rotina de validação do º±±
±±º        ³ pedido via fórmula e retornar se o mesmo poderá ou não ser    º±±
±±º        ³ liberado.                                                     º±±
±±º        ³ Obs. Essa validação só será processada em pedidos de saldo.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11  ³ Uso específico Arcolor                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RFATE043(_cCondPag,_lAlert)

Local _cRotina		:= "RFATE043"
Local _aSavTmp		:= GetArea()
Local _aSavSA1		:= SA1->(GetArea())
Local _aSavSE4		:= SE4->(GetArea())
Local _lValid  		:= .T.
Default _cCondPag 	:= M->C5_CONDPG2

dbSelectArea("SA1")
dbSetOrder(1)

//Verifico se o campo necessário foi criado (customizado) e se o pedido não é de devolução ou beneficiamento
If	SA1->(FieldPos("A1_PRAZOMD"))<>0 .And. !(M->C5_TIPO $ "B|D") .And. AllTrim(Upper(M->C5_SALDO))=="S"
	
	//Localizo o cliente
	If SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
		
		//Certifico que há um prazo definido para o cliente
		If SA1->A1_PRAZOMD <> 0
			
			//Localizo a condição de pagamento utilizada no atendimento
			dbSelectArea("SE4")
			dbSetOrder(1)
			If	SE4->(FieldPos("E4_PRAZOMD"))<>0
				If SE4->(dbSeek(xFilial("SE4")+_cCondPag))
					If SE4->E4_PRAZOMD > SA1->A1_PRAZOMD
						_cMsg 	:= "O prazo médio dessa condição de pagamento é superior ao permitido para este cliente!"
						If SA1->A1_COND == SE4->E4_CODIGO
							_cEnt := CHR(13) + CHR(10)
							_cMsg += _cEnt + _cEnt + "Sugestão: Altere a condição de pagamento padrão definida no cadastro do cliente ou o prazo médio permitido para ele, para que essa mensagem não se repita nos próximos pedidos desse cliente!"
						EndIf
						MsgAlert(_cMsg,_cRotina+"_001")
						_lValid := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

//Restauro a área de trabalho inicial
RestArea(_aSavSE4)
RestArea(_aSavSA1)
RestArea(_aSavTmp)

Return(_lValid)