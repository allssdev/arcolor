#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TK271BOK �Autor  � J�lio Soares       � Data �  25/05/13   ���
���          �          �Alter. � Adriano Leonardo   � Data �  24/04/14   ���
���          �          �Alter. � J�lio Soares       � Data �  15/06/15   ���
�������������������������������������������������������������������������͹��
���Desc.TOTVS� Esse ponto de entrada � chamado no bot�o "OK" da barra de  ���
���          � ferramentas da tela de atendimento do Call Center, antes   ���
���          � da fun��o de grava��o.                                     ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada criado para cadastro autom�tico das regras���
���          � de desconto com base nos dados do atendimento.             ���
�������������������������������������������������������������������������͹��
���_cBloq.   � Foi implementado tratamento para validar a confirma��o     ���
���          � do atendimento para quando o cadastro do cliente estiver   ���
���          � bloqueado e o atendimento possa ter vindo do processo de   ���
���          � c�pia.                                                     ���
�������������������������������������������������������������������������͹��
���_cLog     � Retiradoa fun��o RecLock do trecho de inclus�o devido a    ���
���          � falta de necessidade do mesmo uma vez que nesse ponto a    ���
���          � tabela SUA ainda n�o est� gravada.                         ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico para empresa - ARCOLOR                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
If SU7->(dbSeek(xFilial("SU7") + __cUserID,.F.,.F.))		// - Valida o perfil do usu�rio conforme cadastro dos operadores
	If SU7->U7_TIPOATE $ '2|5' // - Televendas|Tmk e Tlv
		If !Upper(AllTrim(FunName())) == "TMKA350" // - LINHA INCLUIDA PARA VALIDAR A ROTINA QUE EST� SENDO CHAMADA.
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
			//In�cio - Trecho adicionado por Adriano Leonardo em 08/05/2014
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
				_cLogx := "Inclus�o de Pedido de Vendas pelo Call Center."
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
						_cLogx := "Pr�-pedido gerou pedido de vendas."
					ElseIf SUA->UA_OPER == "3"
						_cLogx := "Atendimento gerou pedido de vendas."
					Else
						_cLogx := "Pedido de vendas alterado pelo Call Center."
					EndIf
				ElseIf M->UA_OPER == "2"		//Pr�-Pedido
					If SUA->UA_OPER == "1"
						_cLogx := "Pedido retrocedeu ao status de Pr�-Pedido."
					ElseIf SUA->UA_OPER == "3"
						_cLogx := "Atendimento foi transformado em Pr�-Pedido."
					Else
						_cLogx := "Pr�-Pedido alterado."
					EndIf
				ElseIf M->UA_OPER == "3"		//Atendimento
					If SUA->UA_OPER == "2"
						_cLogx := "Pr�-Pedido retrocedeu ao status de atendimento."
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
			//In�cio - Trecho adicionado por Adriano Leonardo em 24/04/2014 para valida��o da condi��o de pagamento
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
			//Final  - Trecho adicionado por Adriano Leonardo em 24/04/2014 para valida��o da condi��o de pagamento
		EndIf
	Else
		 _lRet := .T.
	EndIf
EndIf
	//In�cio  - Trecho adicionado por Diego Rodrigues em 15/08/2024 para valida��o de produto da linha industrial
	If (IIF(EXISTBLOCK("RTMKE035"),U_RTMKE035(),.F.))
			M->UA_XLININD := _cInd
	EndIf
	//Final  - Trecho adicionado por Diego Rodrigues em 15/08/2024 para valida��o de produto da linha industrial

RestArea(_aSavSZA)
RestArea(_aSavACO)
RestArea(_aSavACP)
RestArea(_aSavACS)
RestArea(_aSavACN)
RestArea(_aSavSUA)
RestArea(_aSavSC5)
RestArea(_aSavArea)

Return(_lRet)
