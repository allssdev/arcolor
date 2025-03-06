#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TK271BOK ºAutor  ³ Júlio Soares       º Data ³  25/05/13   º±±
±±º          ³          ºAlter. ³ Adriano Leonardo   º Data ³  24/04/14   º±±
±±º          ³          ºAlter. ³ Júlio Soares       º Data ³  15/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.TOTVS³ Esse ponto de entrada é chamado no botão "OK" da barra de  º±±
±±º          ³ ferramentas da tela de atendimento do Call Center, antes   º±±
±±º          ³ da função de gravação.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada criado para cadastro automático das regrasº±±
±±º          ³ de desconto com base nos dados do atendimento.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º_cBloq.   ³ Foi implementado tratamento para validar a confirmação     º±±
±±º          ³ do atendimento para quando o cadastro do cliente estiver   º±±
±±º          ³ bloqueado e o atendimento possa ter vindo do processo de   º±±
±±º          ³ cópia.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º_cLog     ³ Retiradoa função RecLock do trecho de inclusão devido a    º±±
±±º          ³ falta de necessidade do mesmo uma vez que nesse ponto a    º±±
±±º          ³ tabela SUA ainda não está gravada.                         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico para empresa - ARCOLOR                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TK271BOK()

Local _aSavArea  := GetArea()
Local _aSavSC5   := SC5->(GetArea())
Local _aSavSUA   := SUA->(GetArea())
Local _aSavACO   := ACO->(GetArea())
Local _aSavACP   := ACP->(GetArea())
Local _aSavACS   := ACS->(GetArea())
Local _aSavACN   := ACN->(GetArea())
Local _aSavSZA   := SZA->(GetArea())
Local _cLogx     := ""
Local _nPProd  	 := aScan(aHeader,{|x|AllTrim(x[02])=="UB_PRODUTO"})
//Local n		 := 0

Private _lRet    := .T.
Private _cRotina := "TK271BOK"
Private _cInd := "2"

dbSelectArea("SU7")                                                                                                                              
SU7->(dbOrderNickName("U7_CODUSU"))		//dbSetOrder(4)// - U7_FILIAL+U7_CODUSU
If SU7->(dbSeek(xFilial("SU7") + __cUserID,.F.,.F.))		// - Valida o perfil do usuário conforme cadastro dos operadores
	If SU7->U7_TIPOATE $ '2|5' // - Televendas|Tmk e Tlv
		If !Upper(AllTrim(FunName())) == "TMKA350" // - LINHA INCLUIDA PARA VALIDAR A ROTINA QUE ESTÁ SENDO CHAMADA.
			//Private _cRotina   := "TK271BOK"
			Private _cBloq     := Alltrim(SA1->A1_MSBLQL)
			Private _cAtend    := M->UA_NUM
			Private _cCli      := M->UA_CLIENTE
			Private _cLoja     := M->UA_LOJA
			Private _cNome     := M->UA_DESCCLI
			Private _cOper     := M->UA_OPER
			Private _cCodreg   := ""
			Private _nPProd    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_PRODUTO"})
			Private _nPDesc    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESC"   })
			Private _nPFator   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_CODFATR"})
			Private _cMVPAR    := SuperGetMV("MV_REGDIAS",.T.,"30")
			Private _lEnt      := + CHR(13) + CHR(10)
			//Início - Trecho adicionado por Adriano Leonardo em 08/05/2014
			If ExistBlock("RTMKE027")
				_lRet := U_RTMKE027(.T.)
				If !_lRet
					Return(_lRet)
				EndIf
				RestArea(_aSavSZA)
				RestArea(_aSavACO)
				RestArea(_aSavACP)
				RestArea(_aSavACS)
				RestArea(_aSavACN)
				RestArea(_aSavSUA)
				RestArea(_aSavSC5)
				RestArea(_aSavArea)
			EndIf
			//Final -  Trecho adicionado por Adriano Leonardo em 08/05/2014
/*
			If INCLUI .AND. (M->UA_OPER) == "1"
				_cLogx := "Inclusão de Pedido de Vendas pelo Call Center."
				If ExistBlock("RFATL001") .AND. !Empty(_cLogx)
					U_RFATL001(	M->UA_NUMSC5,;
								M->UA_NUM,;
								_cLogx,;
								_cRotina)
				EndIf
			EndIf
*/
			If ALTERA
				If M->UA_OPER == "1"			//Pedido           
					If SUA->UA_OPER == "2"
						_cLogx := "Pré-pedido gerou pedido de vendas."
					ElseIf SUA->UA_OPER == "3"
						_cLogx := "Atendimento gerou pedido de vendas."
					Else
						_cLogx := "Pedido de vendas alterado pelo Call Center."
					EndIf
				ElseIf M->UA_OPER == "2"		//Pré-Pedido
					If SUA->UA_OPER == "1"
						_cLogx := "Pedido retrocedeu ao status de Pré-Pedido."
					ElseIf SUA->UA_OPER == "3"
						_cLogx := "Atendimento foi transformado em Pré-Pedido."
					Else
						_cLogx := "Pré-Pedido alterado."
					EndIf
				ElseIf M->UA_OPER == "3"		//Atendimento
					If SUA->UA_OPER == "2"
						_cLogx := "Pré-Pedido retrocedeu ao status de atendimento."
					ElseIf SUA->UA_OPER == "1"
						_cLogx := "Pedido retrocedeu ao status de atendimento."
					Else
						_cLogx := "Atendimento alterado."
					EndIf
				EndIf
			EndIf
			If SUA->(FieldPos("UA_LOGSTAT"))>0
				_cLog         := Alltrim(M->UA_LOGSTAT)
				M->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + ;
								" - " + UsrRetName(__cUserId) + _lEnt + _cLogx
			EndIf
			//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
			If ExistBlock("RFATL001") .AND. !Empty(_cLogx)
				U_RFATL001(	M->UA_NUMSC5,;
							M->UA_NUM,;
							_cLogx,;
							_cRotina)
			EndIf
			//Início - Trecho adicionado por Adriano Leonardo em 24/04/2014 para validação da condição de pagamento
			If _lRet .AND. ExistBlock("RTMKE023")
				_aSavSE4 := SE4->(GetArea())
				dbSelectArea("SE4")
				SE4->(dbSetOrder(1))
				If SE4->(MsSeek(xFilial("SE4")+M->UA_CONDPG,.T.,.F.)) .And. SE4->(FieldPos("E4_MINIMO")<>0)
					_nMinimo := SE4->E4_MINIMO
					_lRet    := U_RTMKE023(_nMinimo)
				EndIf
				RestArea(_aSavSE4)
			EndIf
			//Final  - Trecho adicionado por Adriano Leonardo em 24/04/2014 para validação da condição de pagamento
		EndIf
	Else
		 _lRet := .T.
	EndIf
EndIf
	//Início  - Trecho adicionado por Diego Rodrigues em 15/08/2024 para validação de produto da linha industrial
	If (IIF(EXISTBLOCK("RTMKE035"),U_RTMKE035(),.F.))
			M->UA_XLININD := _cInd
	EndIf
	//Final  - Trecho adicionado por Diego Rodrigues em 15/08/2024 para validação de produto da linha industrial

RestArea(_aSavSZA)
RestArea(_aSavACO)
RestArea(_aSavACP)
RestArea(_aSavACS)
RestArea(_aSavACN)
RestArea(_aSavSUA)
RestArea(_aSavSC5)
RestArea(_aSavArea)

Return(_lRet)
