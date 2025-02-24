#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RACDE001  ºAutor  ³Arthur Silvaº 			 Data  ³  09/08/17º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina desenvolvida para Reiniciar todo o processo de       º±±
±±º          ³Separação.		                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function RACDE001()
	Local _aSavAr  := GetArea()
	Local _aSavCB7 := CB7->(GetArea())
	Local _aSavCB8 := CB8->(GetArea())
	Local _aSavCB9 := CB9->(GetArea())
	Local _cRotina := "RACDE001"
	Local _cOrdSep := CB7->CB7_ORDSEP
	Local _cStatus := CB7->CB7_STATUS
//	Local _CQryCB7 := ""
//	Local _cQryCB8 := ""
//	Local _lRet    := .T.
	If MsgYesNo("Deseja realmente reiniciar a conferência na Ordem de Separação: "+_cOrdSep+" ?",_cRotina+"_001")
		If _cStatus <= "2"
			Begin Transaction
				dbSelectArea("CB8")
				CB8->(dbSetOrder(1))
				If CB8->(MsSeek(xFilial("CB8") + _cOrdSep, .T.,.F.))
					while !CB8->(EOF()) .AND. (CB8->CB8_FILIAL+CB8->CB8_ORDSEP) == (xFilial("CB8") + _cOrdSep )
						while !RecLock("CB8",.F.) ; enddo
							CB8->CB8_SALDOS := CB8->CB8_QTDORI
						CB8->(MSUNLOCK())
						dbSelectArea("CB8")
						CB8->(dbSetOrder(1))
						CB8->(dbSkip())
					enddo
					/*
					//Atualiza os saldos da CB8
					_CQryCB8    := " UPDATE " + RetSqlName("CB8")
					_CQryCB8    += " SET CB8_SALDOS = CB8_QTDORI	   "
					_CQryCB8    += " WHERE CB8_FILIAL = '" + xFilial("CB8") + "' "
					_CQryCB8    += "   AND CB8_ORDSEP = '" + _cOrdSep       + "' "
					_CQryCB8    += "   AND D_E_L_E_T_ = '' "
					If TCSQLExec(_CQryCB8) < 0
						MsgAlert("Problemas para voltar o status da ordem de separação!",_cRotina+"_002")
						DisarmTransaction()
						Break
					EndIf
					TcRefresh("CB8")
					*/
					//Delete Registros da Tabela CB9
					dbSelectArea("CB9")
					CB9->(dbSetOrder(1))
					If CB9->(MsSeek(xFilial("CB9") + _cOrdSep,.T.,.F.))
						while !CB9->(EOF()) .AND. (CB9->CB9_FILIAL+CB9->CB9_ORDSEP) == (xFilial("CB9") + _cOrdSep )
							while !RecLock("CB9",.F.) ; enddo
								CB9->CB9_QTESEP := 0
								CB9->(dbDelete())
							CB9->(MSUNLOCK())
							dbSelectArea("CB9")
							CB9->(dbSetOrder(1))
							CB9->(dbSkip())
						enddo
					EndIf
					dbSelectArea("CB7")
					CB7->(dbSetOrder(1))
					If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
						while !RecLock("CB7",.F.) ; enddo
							CB7->CB7_STATUS := '0'
							CB7->CB7_STATPA := '0'
							CB7->CB7_ORIGEM := '1'
						CB7->(MSUNLOCK())
					Else
						MsgAlert("Problemas para voltar o status da ordem de separação!",_cRotina+"_004")
						DisarmTransaction()
						Break
					EndIf
					/*
					//Atualiza Status da CB7
					_CQryCB7    := " UPDATE " + RetSqlName("CB7")
					_CQryCB7    += " SET CB7_STATUS = '0', CB7_STATPA = '0', CB7_ORIGEM = '1' "
					_CQryCB7    += " WHERE CB7_FILIAL = '" + xFilial("CB8") + "' "
					_CQryCB7    += "   AND CB7_ORDSEP = '" + _cOrdSep       + "' "
					_CQryCB7    += "   AND D_E_L_E_T_ = '' "
					If TCSQLExec(_CQryCB7) < 0
						MsgAlert("Problemas para voltar o status da ordem de separação!",_cRotina+"_004")
						DisarmTransaction()
						Break
					EndIf
					TcRefresh("CB7")
					*/
				Else
					MSGBOX("Problemas na tentativa de localização da Ordem de Separação '"+_cOrdSep+"'!",_cRotina+"_005","STOP")
				EndIf
			End Transaction
			MSGBOX("Processo Reiniciado com Sucesso!",_cRotina+"_006","INFO")
		Else
			MsgAlert("Processo não permitido devido ao status da Ordem de Separação!",_cRotina+"_007")
		EndIf
	EndIf
	RestArea(_aSavCB7)
	RestArea(_aSavCB8)
	RestArea(_aSavCB9)
	RestArea(_aSavAr)
return