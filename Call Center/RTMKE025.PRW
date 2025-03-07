#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE _lEnt CHR(13) + CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa � RTMKE025 �Autor  � J�lio Soares        � Data � 07/05/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina utilizada para atualizar os campos de data, hora e  ���
���          � o log do usuario que realizou a confer�ncia do atendimento ���
���          � sendo validado na libera��o do pedido.                     ���
�������������������������������������������������������������������������͹��
���Uso     � Protheus 11 - Espec�fico para a empresa ARCOLOR.             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RTMKE025()

Local _cRotina     := "RTMKE025"
Local _aSavArea    := GetArea()
Local _aSavSUA     := SUA->(GetArea())

Private _cPed      := "" //IIF(Type("UA_NUMSC5")<>"U",UA_NUMSC5,"")
Private _cPreped   := SUA->UA_NUM
Private _cCli      := SUA->UA_CLIENTE
Private _cLoja     := SUA->UA_LOJA

dbSelectArea("SUA")
SUA->(dbSetOrder(1))
If !AllTrim(SUA->UA_STATUS) $ 'LIB/NF./CAN' .OR. SUA->UA_DOC $ 'XXX'/*.AND. !(AllTrim(SUA->UA_OPER)) == '1'*/
	If MSGBOX('Deseja conferir o pr�-pedido: '+ _cPreped +' ?',_cRotina + '_001','YESNO')
		If SUA->(MsSeek(xFilial("SUA")+_cPreped,.T.,.F.))
			nReg   := SUA->(Recno())
			_cPed  := SUA->UA_NUMSC5
			//GravaArred() //Fun��o para corre��o dos calculos de valores arrendondando para 2 casas decimais.
			ALTERA 	   := .T. //Adequa��o da variavel ALTERA para .T. quando utilizado a conferencia de pedido, ajuste necess�rio devido a nova release 12.1.2410
            // - Abre a tela de confer�ncia do atendimento
			TK271CallCenter("SUA",nReg,4)
			If MSGBOX('Deseja confirmar a confer�ncia do pedido ' + _cPreped + ' ?',_cRotina+'_002','YESNO')
				_cLogx := "Pr�-Pedido '"+_cPreped+"' conferido!"
				RecLock("SUA",.F.)
					If SUA->(FieldPos("UA_DTCONFR")) > 0
						SUA->UA_DTCONFR := Date()
					EndIf
					If SUA->(FieldPos("UA_HRCONFR")) > 0               	
						SUA->UA_HRCONFR := Time()
					EndIf
					If SUA->(FieldPos("UA_USRCONF")) > 0
						SUA->UA_USRCONF := UsrRetName(__cUserId)
					EndIf
					If SUA->(FieldPos("UA_LOGSTAT")) > 0
						_cLog           := Alltrim(SUA->UA_LOGSTAT)
						SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
											UsrRetName(__cUserId) + _lEnt + _cLogx
					EndIf
				SUA->(MSUNLOCK())
				If !Empty(SUA->UA_NUMSC5)
					_cLogx := "Pedido de vendas conferido."
					_cPed      := IIF(Type("UA_NUMSC5")<>"U",UA_NUMSC5,"")
					dbSelectArea("SC5")
					SC5->(dbSetOrder(1))
					If SC5->(MsSeek(xFilial("SC5")+_cPed,.T.,.F.))
						RecLock("SC5",.F.)
							If SC5->(FieldPos("C5_DTCONFR")) <> 0
								SC5->C5_DTCONFR := Date() // SUA->(UA_DTCONFR)
							EndIf
							If SC5->(FieldPos("C5_HRCONFR")) <> 0
								SC5->C5_HRCONFR := Time() // SUA->(UA_HRCONFR)
							EndIf
							If SC5->(FieldPos("C5_USRCONF")) <> 0
								SC5->C5_USRCONF := UsrRetName(__cUserId) // SUA->(UA_USRCONF)
							EndIf							
							If SC5->(FieldPos("C5_LOGSTAT")) <> 0
								_cLog           := Alltrim(SC5->C5_LOGSTAT)
								SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() +" - " +;
													UsrRetName(__cUserId) + _lEnt + _cLogx
							EndIf
						SC5->(MSUNLOCK())
					EndIf
					//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
					If ExistBlock("RFATL001")
						U_RFATL001(	SUA->UA_NUMSC5,;
									SUA->UA_NUM,;
									_cLogx,;
									_cRotina)
					EndIf
				Else
					//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
					If ExistBlock("RFATL001")
						U_RFATL001(	"",;
									SUA->UA_NUM,;
									_cLogx,;
									_cRotina)
					EndIf
					_cLogx := "Pedido de Vendas '"+SUA->UA_NUMSC5+"' n�o localizado para confer�ncia!!!"
					//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
					If ExistBlock("RFATL001")
						U_RFATL001(	"",;
									SUA->UA_NUM,;
									_cLogx,;
									_cRotina)
					EndIf
					MSGBOX(_cLogx,_cRotina+'_004','STOP')
				EndIf
			EndIf
		Else    
			MSGBOX('Pr�-pedido ' + _cPreped+' n�o encontrado. INFORME O ADMINISTRADOR DO SISTEMA!',_cRotina + '_005','ALERT')
		EndIf
	EndIf
Else
	If SUA->UA_STATUS $ "LIB"
		_cLogx := " N�O � POSS�VEL REALIZAR A CONFERENCIA DESSE PEDIDO [J� LIBERADO] "
	ElseIF SUA->UA_STATUS $ "NF"
		_cLogx := " N�O � POSS�VEL REALIZAR A CONFERENCIA DESSE PEDIDO [J� FATURADO] "
	ElseIF SUA->UA_STATUS $ "CAN"
		_cLogx := " N�O � POSS�VEL REALIZAR A CONFERENCIA DESSE PEDIDO [CANCELADO] "
	ElseIf SUA->UA_DOC $ 'XXX'
		_cLogx := " N�O � POSS�VEL REALIZAR A CONFERENCIA DESSE PEDIDO [ELIMINADO] "	
	Else
		_cLogx := " N�O � POSS�VEL REALIZAR A CONFERENCIA DESSE PEDIDO [VERIFIQUE] "
	EndIf
	_cLogx      := "Tentativa de confer�ncia frustrada: "+_cLogx
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	If ExistBlock("RFATL001")
		U_RFATL001(	_cPed,;
					_cPreped,;
					_cLogx,;
					_cRotina)
	EndIf
	MSGBOX(_cLogx,_cRotina+"_006",'STOP')
EndIf

RestArea(_aSavSUA)
RestArea(_aSavArea)

Return()

Static Function GravaArred()
		cQry := " UPDATE "+RetSQLName("SUB")
		cQry += " SET UB_VRUNIT = ROUND(UB_VRUNIT,2) "
		cQry += " , UB_VLRITEM = ROUND(UB_QUANT * ROUND(UB_VRUNIT,2),2) "
		cQry += " , UB_VALDESC = ROUND(UB_QUANT * ROUND(UB_PRCTAB,2),2) - ROUND(UB_QUANT * ROUND(UB_VRUNIT,2),2) "
		cQry += " FROM SUB010 SUB (NOLOCK) "
		cQry += " INNER JOIN SUA010 SUA (NOLOCK) ON SUA.D_E_L_E_T_ = '' AND UA_NUM = UB_NUM AND UA_NUMSC5 = '' "
		cQry += " WHERE SUB.D_E_L_E_T_ = '' "
		cQry += " AND UB_FILIAL = '"+xFilial("SUB")+"' "
		cQry += " AND UA_EMISSAO >= '20250201' "
		cQry += " AND ROUND((UB_QUANT * ROUND(UB_VRUNIT,2)),2) <> UB_VLRITEM "
	
		TcSQLExec(cQry)
return
