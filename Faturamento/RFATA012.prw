#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���Programa  �RFATA012�Autor  �Anderson C. P. Coelho � Data � 15/10/13    ���
�������������������������������������������������������������������������͹��
���Descri��o � Rotina utilizada para a altera��o do pedido de vendas,     ���
���          � para que as regras de neg�cios sejam realizadas.           ���
���          � Esta rotina � chamada pelo ponto de entrada TMKVFIM.       ���
���          � Antigamente, era chamada via StartJob, mas n�o mais!       ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	_cLog += "Dados das Vari�veis:" + CHR(13) + CHR(10)
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
				_cLog += "Aten��o! Verifique o pedido de vendas gerado: " + _cPed + "." + CHR(13) + CHR(10)
				_cLog += MostraErro() + CHR(13) + CHR(10) + CHR(13) + CHR(10)
			//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
			EndIf
			MsgAlert("Aten��o! Verifique o pedido de vendas gerado: " + _cPed + ".",_cRotina+"_001")
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
				_cLog += "Aten��o! Verifique o pedido de vendas gerado: " + _cPed + "." + CHR(13) + CHR(10)
				_cLog += MostraErro() + CHR(13) + CHR(10) + CHR(13) + CHR(10)
			//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
			EndIf
			MsgAlert("Aten��o! Verifique o pedido de vendas gerado: " + _cPed + ".",_cRotina+"_001")
			MostraErro()
		ElseIf _lGeraLog
			_cLog += "[" + DTOC(Date()) + " - " + Time() + "]" + CHR(13) + CHR(10)
			_cLog += "Pedido de vendas atualizado: " + _cPed + "." + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
			//In�cio - Trecho adicionado por Adriano Leonardo em 22/07/2014 para resumo dos bloqueio por regra na confirma��o do atendimento
			_lMostra := .F.
			_aSavSU7 := SU7->(GetArea())
			_aSavSC5 := SC5->(GetArea())
			dbSelectArea("SU7")
			If SU7->(FieldPos("U7_RESUMO"))<>0 //Certifico que o campo existe (campo customizado)
				SU7->(dbOrderNickName("U7_CODUSU"))		//dbSetOrder(4) //Filial + C�digo do usu�rio
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
						AutoGrLog("RESUMO DE ITENS BLOQUEADOS POR REGRA DE NEG�CIO:")
						AutoGrLog(" ")
						AutoGrLog("Pedido: " + _cPed)
						AutoGrLog(_cMsgBlq)
						MostraErro()
					EndIf
				EndIf
			EndIf
			RestArea(_aSavSU7)
			RestArea(_aSavSC5)
			//Final  - Trecho adicionado por Adriano Leonardo em 22/07/2014 para resumo dos bloqueio por regra na confirma��o do atendimento
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
	_cLog += "Conclu�do!" + CHR(13) + CHR(10)
//	MemoWrite("\2.Memowrite\log_"+_cRotina+".txt",_cLog)
EndIf

//U_RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cBCC)

Return(_lRet)