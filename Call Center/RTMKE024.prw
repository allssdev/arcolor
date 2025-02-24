#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ RTMKE024 ºAutor  ³ Adriano L. de Souza º Data ³ 30/04/2014   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Função desenvolvida para validar o prazo médio de pagamento   º±±
±±ºDesc.   ³ permitido para o cliente.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11  ³ Uso específico Arcolor                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RTMKE024(_cCondPag)

Local _cRotina		:= "RTMKE024"
Local _aSavTmp		:= GetArea()
Local _aSavSA1		:= SA1->(GetArea())
Local _aSavSE4		:= SE4->(GetArea())
Local _lValid  		:= .T.

Default _cCondPag 	:= M->UA_CONDPG

dbSelectArea("SA1")
SA1->(dbSetOrder(1))
//Verifico se o campo necessário foi criado (customizado)
If	SA1->(FieldPos("A1_PRAZOMD"))<>0
	//Localizo o cliente
	If SA1->(MsSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,.T.,.F.))
		//Certifico que há um prazo definido para o cliente
		If SA1->A1_PRAZOMD <> 0
			//Localizo a condição de pagamento utilizada no atendimento
			dbSelectArea("SE4")
			SE4->(dbSetOrder(1))
			If	SE4->(FieldPos("E4_PRAZOMD"))<>0
				If SE4->(MsSeek(xFilial("SE4")+_cCondPag,.T.,.F.))
					If SE4->E4_PRAZOMD > SA1->A1_PRAZOMD
						_cMsg 	:= "O prazo médio dessa condição de pagamento é superior ao permitido para este cliente!"
						If SA1->A1_COND == SE4->E4_CODIGO
							_cEnt := CHR(13) + CHR(10)
							_cMsg += _cEnt + _cEnt + "Sugestão: Altere a condição padrão definida no cadastro do cliente ou o prazo médio permitido para ele, para que essa mensagem não se repita nos próximos atendimentos!"
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