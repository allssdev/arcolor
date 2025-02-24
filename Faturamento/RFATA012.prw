#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  ³RFATA012ºAutor  ³Anderson C. P. Coelho º Data º 15/10/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Rotina utilizada para a alteração do pedido de vendas,     º±±
±±º          ³ para que as regras de negócios sejam realizadas.           º±±
±±º          ³ Esta rotina é chamada pelo ponto de entrada TMKVFIM.       º±±
±±º          ³ Antigamente, era chamada via StartJob, mas não mais!       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATA012(_aCab,_aItPV,_cPed,_cEmpFil,_lJob)

Local _lGeraLog     := .T.
Local _lRet         := .T.
Local _cRotina      := "RFATA012"

Private lMsErroAuto := .F.
Private _cQUpd1 := ""

Default _aCab       := {}
Default _aItPV      := {}
Default _cPed       := ""
Default _cEmpFil    := ""
Default _lJob       := .F.


If _lGeraLog
	_cLog := "[" + DTOC(Date()) + " - " + Time() + "]" + CHR(13) + CHR(10)
	_cLog += "Dados das Variáveis:" + CHR(13) + CHR(10)
	_cLog += "********************" + CHR(13) + CHR(10)
	_cLog += "_aCab: " + cValToChar(Len(_aCab)) + CHR(13) + CHR(10)
	_cLog += "_aItPv: " + cValToChar(Len(_aItPv)) + CHR(13) + CHR(10)
	_cLog += "_cPed: " + _cPed + CHR(13) + CHR(10)
	_cLog += "_cEmpFil: " + _cEmpFil + CHR(13) + CHR(10)
	_cLog += "_lJob: " + IIF(_lJob,".T.",".F.") + CHR(13) + CHR(10) + CHR(13) + CHR(10)
	_cLog += "MENSAGENS:" + CHR(13) + CHR(10)
	_cLog += "**********" + CHR(13) + CHR(10)
//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
EndIf
If Len(_aCab) > 0 .AND. Len(_aItPV) > 0 .AND. !Empty(_cPed) .AND. !Empty(_cEmpFil)
	If _lJob
		RpcClearEnv()
		RpcSetType(3)
		//RpcSetEnv( SubStr(_cEmpFil,1,2),SubStr(_cEmpFil,3,2),,,'FAT',GetEnvServer())
		PREPARE ENVIRONMENT EMPRESA SubStr(_cEmpFil,1,2) FILIAL SubStr(_cEmpFil,3,2) FUNNAME _cRotina
		SetModulo( "SIGAFAT", "FAT" )
	EndIf
	_cFunName := FunName()
	SetFunName("MATA410")
	If _lJob
		MSExecAuto({|x,y,z| mata410(x,y,z)},_aCab,_aItPV,4)
		_lRet := !lMsErroAuto
		If lMsErroAuto
			If _lGeraLog
				_cLog += "[" + DTOC(Date()) + " - " + Time() + "]" + CHR(13) + CHR(10)
				_cLog += "Atenção! Verifique o pedido de vendas gerado: " + _cPed + "." + CHR(13) + CHR(10)
				_cLog += MostraErro() + CHR(13) + CHR(10) + CHR(13) + CHR(10)
			//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
			EndIf
			MsgAlert("Atenção! Verifique o pedido de vendas gerado: " + _cPed + ".",_cRotina+"_001")
			MostraErro()
		ElseIf _lGeraLog
			_cLog += "[" + DTOC(Date()) + " - " + Time() + "]" + CHR(13) + CHR(10)
			_cLog += "Pedido de vendas atualizado: " + _cPed + "." + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
		EndIf
	Else
		/*
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		If SC5->(dbSeek(xFilial("SC5") + _cPed))
			A410Altera("SC5",SC5->(Recno()),4)
		EndIf
		*/
		MsgRun("Aguarde... Atualizando o pedido de vendas " + _cPed + "...",_cRotina,{ || MSExecAuto({|x,y,z| mata410(x,y,z)},_aCab,_aItPV,4) })
		//FIM do trecho adicionado por Anderson C. P. Coelho em 07/01/2015
		_lRet := !lMsErroAuto
		If lMsErroAuto
			If _lGeraLog
				_cLog += "[" + DTOC(Date()) + " - " + Time() + "]" + CHR(13) + CHR(10)
				_cLog += "Atenção! Verifique o pedido de vendas gerado: " + _cPed + "." + CHR(13) + CHR(10)
				_cLog += MostraErro() + CHR(13) + CHR(10) + CHR(13) + CHR(10)
			//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
			EndIf
			MsgAlert("Atenção! Verifique o pedido de vendas gerado: " + _cPed + ".",_cRotina+"_001")
			MostraErro()
		ElseIf _lGeraLog
			_cLog += "[" + DTOC(Date()) + " - " + Time() + "]" + CHR(13) + CHR(10)
			_cLog += "Pedido de vendas atualizado: " + _cPed + "." + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
			//Início - Trecho adicionado por Adriano Leonardo em 22/07/2014 para resumo dos bloqueio por regra na confirmação do atendimento
			_lMostra := .F.
			_aSavSU7 := SU7->(GetArea())
			_aSavSC5 := SC5->(GetArea())
			dbSelectArea("SU7")
			If SU7->(FieldPos("U7_RESUMO"))<>0 //Certifico que o campo existe (campo customizado)
				SU7->(dbOrderNickName("U7_CODUSU"))		//dbSetOrder(4) //Filial + Código do usuário
				If SU7->(MsSeek(xFilial("SU7")+__cUserId,.T.,.F.))
					If SU7->U7_RESUMO=="S"
						_lMostra := .T.
					Else
						_lMostra := .F.
					EndIf
				EndIf
			EndIf
			If _lMostra
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+_cPed))
					_cMsgBlq := SC5->C5_OBSBLQ
					If !Empty(_cMsgBlq)
						AutoGrLog(" ")
						AutoGrLog("RESUMO DE ITENS BLOQUEADOS POR REGRA DE NEGÓCIO:")
						AutoGrLog(" ")
						AutoGrLog("Pedido: " + _cPed)
						AutoGrLog(_cMsgBlq)
						MostraErro()
					EndIf
				EndIf
			EndIf
			RestArea(_aSavSU7)
			RestArea(_aSavSC5)
			//Final  - Trecho adicionado por Adriano Leonardo em 22/07/2014 para resumo dos bloqueio por regra na confirmação do atendimento
		EndIf
	EndIf
	If _lGeraLog
		_cLog += "[" + DTOC(Date()) + " - " + Time() + "]" + CHR(13) + CHR(10)
		_cLog += "Finalizando..." + CHR(13) + CHR(10) + CHR(13) + CHR(10)
	//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
	EndIf
	SetFunName(_cFunName)
	If !Empty(SC5->C5_OBSBLQ)

		_cQUpd1 := " UPDATE  " + RetSqlName("SUA") 
		_cQUpd1 += " SET  UA_OBSBLQ   = '" + SC5->C5_OBSBLQ  + "' " +_lEnt
		_cQUpd1 += " WHERE UA_NUMSC5  = '" + _cPed    + "' " + _lEnt
		MemoWrite("\2.MemoWrite\TMK\"+_cRotina+"_"+_cPed+"_"+StrTran(Time(),":","")+"_UPD_001.TXT",_cQUpd1)
		If TCSQLExec(_cQUpd1) < 0
			MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_001",'STOP')
		EndIf
	
	EndIf
EndIf
If _lGeraLog
	_cLog += "[" + DTOC(Date()) + " - " + Time() + "]" + CHR(13) + CHR(10)
	_cLog += "Concluído!" + CHR(13) + CHR(10)
//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
EndIf

//U_RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cBCC)

Return(_lRet)