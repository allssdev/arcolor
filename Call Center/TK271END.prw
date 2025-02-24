#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE CENT CHR(13)+CHR(10)
/*/{Protheus.doc} TK271END
@description Ponto de entrada no OK do atendimento do Call Center, utilizado para gravação de campo auxiliar, chave para índice de pesquisa com efeito descrescente.
@author Adriano L. de Souza
@since 17/01/2014
@history 02/07/2014, Júlio Soares, Ponto de entrada utilizado para que, ao final da inclusão do atendimento de vendas, caso o tipo de divisão esteja divergente do cadastro do cliente, o risco do cliente é alterado automaticamente para 'E'. Dessa forma torna-se obrigatório a verificação do mesmo na rotina de análise de crédito do pedido. É inserido também um texto no campo de observação.
@version 1.0
@type function
@see https://allss.com.br
/*/
user function TK271END()
	Local _cRotina   := 'TK271END'
	Local _aSavArea  := GetArea()
	Local _aSavSUA	 := SUA->(GetArea())
	Local _aSavSC5	 := SC5->(GetArea())
	Local _cPed      := SUA->UA_NUM
	Local _cPedC5    := SC5->C5_NUM
	Local _cTpDivPed := SUA->UA_TPDIV
	Local _cAlias    := GetNextAlias()
	Local _nMAXSUA   := SuperGetMV("MV_MAXSUA",,10000000)
	Local _cFATOPER  := "|"+AllTrim(SuperGetMv("MV_FATOPER",,"01|ZZ|9"))+"|"
	Private _cInd := "2"
	if !SUA->UA_PROSPEC
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if SA1->(MsSeek(xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA,.T.,.F.))
			_cTpDivcli := SA1->A1_TPDIV
			if _cTpDivPed <> _cTpDivCli
				while !RecLock("SA1",.F.) ; enddo
					SA1->A1_RISCO := 'E'
				SA1->(MsUnLock())
			endif
			if SA1->A1_RISCO <> 'E' .AND. AllTrim(SUA->UA_TPOPER)$_cFATOPER
				BeginSql Alias _cAlias
					SELECT TOP 1 'A' REG				//SELECT COUNT(*) REG 
					FROM %table:SUB% SUB (NOLOCK)
						INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL  = %xFilial:SF4%
														   AND SF4.F4_DUPLIC  = %Exp:'N'%
														   AND SF4.F4_CODIGO  = SUB.UB_TES
														   AND SF4.%NotDel%
					WHERE SUB.UB_FILIAL  = %xFilial:SUB%
					  AND SUB.UB_NUM     = %Exp:SUA->UA_NUM%
					  AND SUB.%NotDel%
				EndSql
				dbSelectArea(_cAlias)
				if (_cAlias)->REG == 'A'					//if (_cAlias)->REG > 0
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					while !RecLock("SA1",.F.) ; enddo
						SA1->A1_RISCO := 'E'
					SA1->(MsUnLock())
				endif
				(_cAlias)->(dbCloseArea())
			endif
		//	dbSelectArea("SUA")
		//	SUA->(dbSetOrder(1))
		//	if SUA->(MsSeek(xFilial("SUA")+ _cPed,.T.,.F.))
				while !RecLock("SUA",.F.) ; enddo
					SUA->UA_REVERSO := _nMAXSUA-(SUA->(Recno()))
					// - Trecho alterado em 19/08/2014 por Júlio Soares - Observação estava saindo na Ordem de separação
					/*
					if empty (SUA->(UA_OBSSEP))
						SUA->(UA_OBSSEP) := DTOC(Date()) + ' - ' + Time() + ' - Usuário: ' + __cUserId + CENT +;
						 "O TIPO DE DIVISÃO DO PEDIDO NÃO É COMPATÍVEL COM O TIPO DE DIVISÃO DO CLIENTE."
					else
						SUA->(UA_OBSSEP) := Alltrim(SUA->(UA_OBSSEP)) + CENT + DTOC(Date()) + ' - ' + Time() + ' - Usuário: ' + __cUserId + CENT +;
						 "O TIPO DE DIVISÃO DO PEDIDO NÃO É COMPATÍVEL COM O TIPO DE DIVISÃO DO CLIENTE."
					endif
					*/
				SUA->(MsUnLock())
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				if SC5->(MsSeek(xFilial("SC5") + _cPedC5,.T.,.F.))
					if SC5->C5_TPDIV <> SA1->A1_TPDIV
						while !RecLock("SC5",.F.) ; enddo
							if empty(SC5->C5_OBS)
								SC5->C5_OBS := DTOC(Date()) + ' - ' + Time() + ' - Usuário: ' + __cUserId + CENT +;
								 				"O TIPO DE DIVISÃO DO PEDIDO NÃO É COMPATÍVEL COM O TIPO DE DIVISÃO DO CLIENTE."
							else
								SC5->C5_OBS := Alltrim(SC5->C5_OBS) + CENT + DTOC(Date()) + ' - ' + Time() + ' - Usuário: ' + __cUserId + CENT +;
								 				"O TIPO DE DIVISÃO DO PEDIDO NÃO É COMPATÍVEL COM O TIPO DE DIVISÃO DO CLIENTE."
							endif
						SC5->(MsUnLock())
					endif
				endif
		//	endif
	//	else
	//		MSGBOX('Cliente não encontrado, informe o administrador do sistema.',_cRotina + '_01','ALERT')
		endif
	endif
	/*
	dbSelectArea("SUA")
	SUA->(dbSetOrder(1))
	if SUA->(dbSeek(xFilial("SUA")+M->UA_NUM))
		RecLock("SUA",.F.)
			SUA->UA_REVERSO := SuperGetMV("MV_MAXSUA",,10000000)-(SUA->(Recno()))
		SUA->(MsUnlock())
	endif
	*/
	//Início  - Trecho adicionado por Diego Rodrigues em 15/08/2024 para validação de produto da linha industrial
	If (IIF(EXISTBLOCK("RTMKE035"),U_RTMKE035(),.F.))
		while !RecLock("SUA",.F.) ; enddo
			SUA->UA_XLININD := _cInd
		SUA->(MsUnLock())
	EndIf
	//Final  - Trecho adicionado por Diego Rodrigues em 15/08/2024 para validação de produto da linha industrial
	RestArea(_aSavSC5)
	RestArea(_aSavSUA)
	RestArea(_aSavArea)
return
