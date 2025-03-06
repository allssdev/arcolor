#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE _lEnt CHR(13) + CHR(10)
/*/{Protheus.doc} M440STTS
TODO Este ponto de entrada é executado após o fechamento da transação de liberação do pedido de venda (manual).
@description Ponto de entrada utilizado para validar a liberação do pedido de venda.
@author Júlio Soares
@since 17/06/2014
@version 1.0
@history 11/07/2014, Adriano Leonardo, Inserido tratamento para atualizar automaticamente o campo de log de status para quando o pedido for liberado e esse não ficar bloqueado por crédito, insere também no log que o mesmo foi liberado automaticamente. Foi também alterado a validação do fonte quanto a condição de pagamento para que essa validação seja realizada primeiramente.
@history 17/06/2015, Júlio Soares, Realizado o tratamento do fonte para implementações de melhoria.
@history 22/10/2019, Anderson C. P. Coelho (ALL System Solutions), Retirado o lock customizado do registro que minimizava os riscos na liberação dos pedidos de vendas pois, conforme relatado pela consultora Lívia, o risco foi praticamente eliminado pós migração do release P12.1.17 para o P12.1.25.
@history 08/10/2024, Diego Rodrigues (ALL System Solutions), Inclusão da validação e ajuste quando houver quantidade duplicada na liberação do pedido de venda
@type function
@see https://allss.com.br
/*/
user function M440STTS()
	//local _lCred	   := .F.
	local _lBlqCrd	   := .F.
	local _lBlqEst	   := .F.
	local _aSavArea	   := GetArea()
	local _aSavSC5     := SC5->(GetArea())
	local _aSavSC6     := SC6->(GetArea())
	local _aSavSUA     := SUA->(GetArea())
	local _aSavSA1     := SA1->(GetArea())
	local _aSavSA3     := SA3->(GetArea())
	local _aSavSU7     := SU7->(GetArea())                            
	local _aSavSE4     := SE4->(GetArea())
	local _aSavSC9     := SC9->(GetArea())
	local _x           := 0
	local _cLogx       := ""
	Local _aQtdDivg	   := {}
	
	private _cRotina   := 'M440STTS'
	private _aSendMail := {}
	private _cPadTxt   := 'O pedido descrito acima se encontra no setor de análise de crédito da empresa ARCÓLOR.'
	private _cText3    := SuperGetMV("MV_MAILC01",,_cPadTxt)  // - TESTE DE TEXTO PARA MENSAGENS.
	private _cText4    := SuperGetMV("MV_MAILC02",,"")
	private _cLockR      := "PEDIDO_"+SC5->C5_NUM
	public  _mailCli   := ''
	public  _mailVend  := ''
	public  _DestMsg   := ''
	public  _DestMail  := ''
	public  _cTitulo   := ''
	public  _cMsg      := ''
	public  _cMail     := ''
	public  _cAnexo    := ''
	public  _cFromOri  := ''
	public  _cBCC      := SuperGetMv("MV_FATCCO",,"") //"ale.primilla@arcolor.com.br"
	public  _cDe       := 'Administrador' // - REMETENTE PADRÃO
	public  _cPara     := ''
	public  _cAssunt   := ''
	public  _cCorp     := ''
	public  _cPrior    := ''

	//Inicio do Bloco de validação das quantidades duplicadas
	BeginSql Alias "SC9QTD"
	SELECT
		C6_NUM, C6_PRODUTO, C6_QTDVEN, C9_QUANT
	FROM
		(SELECT
		C6_NUM, C6_PRODUTO, SUM(C6_QTDVEN) C6_QTDVEN, SUM(C6_QTDENT) C6_QTDENT
		FROM SC6010 SC6 (NOLOCK)
		WHERE SC6.D_E_L_E_T_ = ''
		AND C6_NUM = %Exp:SC5->C5_NUM%
		GROUP BY C6_NUM, C6_PRODUTO) SC6X
		,
		(SELECT
		C9_PEDIDO, C9_PRODUTO, SUM(C9_QTDLIB) C9_QUANT
		FROM SC9010 SC9 (NOLOCK)
		WHERE SC9.D_E_L_E_T_ = ''
			AND C9_PEDIDO = %Exp:SC5->C5_NUM%
		GROUP BY C9_PEDIDO, C9_PRODUTO)SC9X     
	WHERE
		SC6X.C6_NUM = SC9X.C9_PEDIDO
		AND SC6X.C6_PRODUTO = SC9X.C9_PRODUTO
		AND (SC9X.C9_QUANT > SC6X.C6_QTDVEN  OR SC6X.C6_QTDENT > SC6X.C6_QTDVEN)
	EndSql	 

	SC9QTD->(dbGoTop())
	While !SC9QTD->(EOF())	.and. SC9QTD->C9_QUANT > SC9QTD->C6_QTDVEN  //Se retornar .T., significa que algum item do processo que está com saldo maior
		AADD(_aQtdDivg,{SC9QTD->C6_PRODUTO,SC9QTD->C6_QTDVEN,SC9QTD->C9_QUANT})
		SC9QTD->(dbSkip())
	EndDo
	SC9QTD->(dbCloseArea())

	If Len(_aQtdDivg) > 0
		IIF(ExistBlock("RESTE014"),U_RESTE014(SC5->C5_NUM,6),.T.)
	EndIf
	//Fim do Bloco de validação das quantidades duplicadas	

	//26/11/2024 - Diego Rodrigues - Melhoria para validar pedidos que não foram atualizados e possuem produtos da linha industrial
		BeginSql Alias "LINDSC5"
			SELECT
				B5_XLINPRO
			FROM SC6010 SC6 (NOLOCK)
			INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C6_PRODUTO 
											AND B5_FILIAL = C6_FILIAL AND B5_XLINPRO = '1'
			INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C6_NUM AND C5_XLININD = '2'
			WHERE SC6.D_E_L_E_T_ = ''
				AND C6_NUM = %Exp:SC5->C5_NUM%
			GROUP BY B5_XLINPRO, C6_NUM
		EndSql

		if LINDSC5->(!EOF())
			while !RecLock("SC5",.F.) ; enddo
				SC5->C5_XLININD := LINDSC5->B5_XLINPRO
			SC5->(MsUnLock()) 
		endif
		LINDSC5->(dbCloseArea())
	//26/11/2024 - Diego Rodrigues - Melhoria para validar pedidos que não foram atualizados e possuem produtos da linha industrial

	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))
	SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG,.T.,.F.))
	dbSelectArea("SC9")
	SC9->(dbSetOrder(1))
	if SC9->(dbSeek(xFilial("SC9") + SC5->C5_NUM))
		while !SC9->(EOF()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SC5->C5_NUM
			if !_lBlqCrd .AND. !empty(SC9->C9_BLCRED) .AND. AllTrim(SC9->C9_BLCRED) <> "10"
				_lBlqCrd := .T.
			endif
			if !_lBlqEst .AND. !empty(SC9->C9_BLEST ) .AND. AllTrim(SC9->C9_BLEST ) <> "10"
				_lBlqEst := .T.
			endif
			while !RecLock("SC9",.F.) ; enddo
				if !empty(SC5->C5_OBSSEP)
					SC9->C9_OBSSEP  := SubStr(AllTrim(SC5->C5_OBSSEP),1,Len(SC9->C9_OBSSEP ))
				endif
				if !empty(SE4->E4_DESCRI)
					SC9->C9_DESCPAG := SubStr(AllTrim(SE4->E4_DESCRI),1,Len(SC9->C9_DESCPAG))
				endif
				//Inicio do Bloco de validação das quantidades duplicadas
				If Len(_aQtdDivg) > 0
					SC9->C9_QTDLIB 	:= SC9->C9_QTDLIB/2
					SC9->C9_QTDLIB2 := SC9->C9_QTDLIB2/2
				EndIf
				//Fim do Bloco de validação das quantidades duplicadas
			SC9->(MSUNLOCK())
			dbSelectArea("SC9")
			SC9->(dbSetOrder(1))
			SC9->(dbSkip())	
		enddo
	endif
	RestArea(_aSavSC9)
	if _lRetVld
		if !_lBlqCrd
			_cLogx := "Crédito do pedido Liberado Automaticamente"
			dbSelectArea('SUA')
			SUA->(dbOrderNickName("UA_NUMSC5"))
			if SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
				while !RecLock("SUA", .F.) ; enddo
					if SUA->(FieldPos("UA_LOGSTAT"))>0
						_cLog           := Alltrim(SUA->UA_LOGSTAT)
						SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() +;
											" - " + UsrRetName(__cUserId) +	_lEnt + _cLogx
					endif
					if SUA->(FieldPos("UA_STATSC9"))>0
						if _lBlqEst
							SUA->UA_STATSC9 := "03" // bloqueado por estoque
						else
							SUA->UA_STATSC9 := "04" // liberado automaticamente
						endif
					endif
				SUA->(MsUnLock())
			endif
			// - INSERIDO EM 24/03/2014 POR JÚLIO SOARES PARA GRAVAR STATUS TAMBÉM NO QUADRO DE VENDAS.
			dbSelectArea("SC5")
			if SC5->(FieldPos("C5_LOGSTAT"))>0
				_cLog := Alltrim(SC5->C5_LOGSTAT)
				while !RecLock("SC5", .F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() +;
										" - " + UsrRetName(__cUserId) + _lEnt + _cLogx
				SC5->(MsUnLock())
			endif
		else
			_cLogx := "Crédito do pedido Aguardando Liberação."
			// - Inserido em 17/06/2015 por Júlio Soares para implementar melhorias de processo
			dbSelectArea("SUA")
			SUA->(dbOrderNickName("UA_NUMSC5"))
			if SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
				while !RecLock("SUA", .F.) ; enddo
					if SUA->(FieldPos("UA_LOGSTAT"))>0
						_cLog := Alltrim(SUA->UA_LOGSTAT)
						SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() +;
											" - " + UsrRetName(__cUserId) +	_lEnt + _cLogx
					endif
				SUA->(MsUnLock())
			endif
			dbSelectArea("SC5")
			if SC5->(FieldPos("C5_LOGSTAT"))>0
				_cLog := Alltrim(SC5->C5_LOGSTAT)
				while !RecLock("SC5", .F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() +;
										" - " + UsrRetName(__cUserId) + _lEnt + _cLogx
				SC5->(MsUnLock())
			endif
			//Gravação do status do pedido como bloqueado por crédito
			dbSelectArea('SUA')
			SUA->(dbOrderNickName("UA_NUMSC5"))
			if SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
				if SUA->(FieldPos("UA_STATSC9"))<>0
					while !RecLock("SUA", .F.) ; enddo
						SUA->UA_STATSC9 := "02"
					SUA->(MSUNLOCK())
				endif
			endif
			for _x := 1 to len(_aSendMail)
				//_aSendMail[_x]
				if AllTrim(_aSendMail[_x]) $ "SA1" // - Envia e-mail para o cliente
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					if SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
						if !empty(_DestMail)
							_DestMail += ";"+Alltrim(SA1->A1_EMAIL)
						else
							_DestMail += Alltrim(SA1->A1_EMAIL)
						endif
					endif
				elseif (Alltrim(_aSendMail[_x])) $ "SA3" // - Envia e-mail para os representantes
					dbSelectArea("SA3")
					SA3->(dbSetOrder(1))
					if SA3->(MsSeek(xFilial("SA3")+ SC5->C5_VEND1,.T.,.F.))
						if !empty(SA3->A3_EMAIL)
							if !empty(_DestMail)
								_DestMail += ";"+Alltrim(SA3->A3_EMAIL)
							else
								_DestMail += Alltrim(SA3->A3_EMAIL)
							endif
						else
							if !empty(SA3->A3_CODUSR)
								if PswSeek(SA3->A3_CODUSR,.T.)
									if !empty(_DestMsg)
										_DestMsg  += ";"+Alltrim(PswRet()[1][2])
									else
										_DestMsg  += Alltrim(PswRet()[1][2])
									endif
									if !empty(_DestMail)
										_DestMail += ";"+Alltrim(PswRet()[1][14])
									else
										_DestMail += Alltrim(PswRet()[1][14])
									endif
								endif
							endif
						endif
					endif
				elseif (Alltrim(_aSendMail[_x])) $ "SU7" // - Envia e-mail para os operadores
					//TRECHO PENDENTE
				elseif !(Alltrim(_aSendMail[_x])) $ "SA1|SA3|SU7" //- Envia e-mail para os usuários contidos no parâmetro
					if PswSeek(Alltrim(_aSendMail[_x]),.T.)
						if !empty(_DestMsg)
							_DestMsg  += ";"+Alltrim(PswRet()[01][02])
						else
							_DestMsg  += Alltrim(PswRet()[01][02])
						endif
						if !empty(_DestMail)
							_DestMail += ";"+Alltrim(PswRet()[01][14])
						else
							_DestMail += Alltrim(PswRet()[01][14])
						endif
					endif
				endif
			next
	//		MemoWrite("\2.MemoWrite\"+_cRotina+" - " +SC5->C5_NUM+ "Mail.TXT",_DestMail)
	//		MemoWrite("\2.MemoWrite\"+_cRotina+" - " +SC5->C5_NUM+ "Msg.TXT",_DestMsg)
			// - Envia mensagem via Workflow
			if !empty(_DestMsg)
				EnvWFmsg()
			else
				MSGBOX('Não foram encontrados destinatários para envio da mensagem de Workflow',_cRotina+'_005','INFO')
			endif
			// - Envia mensagem via e-mail
			if !empty(_DestMail)
				EnvWFmail()
			else
				MSGBOX('Não foram encontrados destinatários para envio do e-mail de Workflow',_cRotina+'_006','INFO')
			endif
		endif
		//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
		if ExistBlock("RFATL001")
			U_RFATL001(	SC5->C5_NUM,;
						SUA->UA_NUM,;
						_cLogx     ,;
						_cRotina    )
		endif
		// - Inserido em 17/06/2015 por Júlio Soares para implementar mensagens de log para bloqueio de estoque.
		if !_lBlqEst .OR. _lBlqCrd
			_cLogx := "Pedido em avaliação de disponibilidade de estoque."
			dbSelectArea('SUA')
			SUA->(dbOrderNickName("UA_NUMSC5"))
			if SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
				while !RecLock("SUA", .F.) ; enddo
					if SUA->(FieldPos("UA_LOGSTAT"))>0
						_cLog           := Alltrim(SUA->UA_LOGSTAT)
						SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() +;
											" - " + UsrRetName(__cUserId) +	_lEnt + _cLogx
					endif
				SUA->(MsUnLock())
			endif
			dbSelectArea("SC5")
			if SC5->(FieldPos("C5_LOGSTAT"))>0
				_cLog := Alltrim(SC5->C5_LOGSTAT)
				while !RecLock("SC5", .F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() +;
										" - " + UsrRetName(__cUserId) + _lEnt + _cLogx
				SC5->(MsUnLock())
			endif
		else
			_cLogx := "Pedido aguardando emissão o processo de Separação e Conferência."
			dbSelectArea("SUA")
			SUA->(dbOrderNickName("UA_NUMSC5"))
			if SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
				while !RecLock("SUA", .F.) ; enddo
					if SUA->(FieldPos("UA_LOGSTAT"))>0
						_cLog           := Alltrim(SUA->UA_LOGSTAT)
						SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() +;
											" - " + UsrRetName(__cUserId) +	_lEnt + _cLogx
					endif
				SUA->(MsUnLock())
			endif
			dbSelectArea("SC5")
			if SC5->(FieldPos("C5_LOGSTAT"))>0
				_cLog := Alltrim(SC5->C5_LOGSTAT)
				while !RecLock("SC5", .F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() +;
										" - " + UsrRetName(__cUserId) + _lEnt + _cLogx
				SC5->(MsUnLock())
			endif
		endif
		//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
		if ExistBlock("RFATL001")
			U_RFATL001(	SC5->C5_NUM,;
						SUA->UA_NUM,;
						_cLogx     ,;
						_cRotina    )
		endif
	// - FIM
	endif
	//if INCLUI .OR. ALTERA
		//Bloqueio realizado pelos P.E.s MA440VLD e MT410ACE e Desbloqueio realizado pelos P.E.s MT440GR, M440STTS, M410STTS e M410ABN
	UnLockByName(_cLockR)
		//Leave1Code(_cLockR)
	//endif
	RestArea(_aSavSC9)
	RestArea(_aSavSE4)
	RestArea(_aSavSU7)
	RestArea(_aSavSA3)
	RestArea(_aSavSA1)
	RestArea(_aSavSUA)
	RestArea(_aSavSC6)
	RestArea(_aSavSC5)
	RestArea(_aSavArea)
return
/*/{Protheus.doc} EnvWFmsg
@description Habilita workflow de envio de mensagem.
@author Júlio Soares
@since 17/06/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
Static Function EnvWFmsg()
	local   _cPara    := _DestMsg        // - _DestMsg
	local   _cAssunt  := 'Avaliação de crédito'
	local   _cPrior   := '0'
	local   _cText1   := "CLIENTE: "+ SC5->C5_CLIENTE +"-"+SC5->C5_LOJACLI +"   "+ALLTRIM(SC5->C5_NOMCLI)+"."
	local   _cText2   := "PEDIDO: " + SC5->C5_NUM + "."
	local   _cCorp    := _cText1 + _lEnt +_cText2 + _lEnt + _cText3
	if !empty(_DestMsg)
		if ExistBlock("RCFGM002")
			StartJob('U_RCFGM002',GetEnvServer(),.F.,_cDe,_cPara,_cAssunt,_cCorp,_cPrior)
	//		U_RCFGM002(_cDe,_cPara,_cAssunt,_cCorp,_cPrior)
		endif
	else
		MSGBOX('Não foi possível enviar a mensagem de WorkFlow para o destinatário!',_cRotina+'_003','ALERT')
	endif
return
/*/{Protheus.doc} EnvWFmail
@description Habilita workflow de envio de e-mail.
@author Júlio Soares
@since 17/06/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function EnvWFmail()
	_cTitulo  := ''
	_cMsg     := ''
	_cMail    := _DestMail // - Parâmetro
	_cAnexo   := ''
	_cFromOri := ''
	_cBCC     := SuperGetMv("MV_FATCCO",,"")
	_cCabec   := 'Análise de pedido'
	_cText1   := 'CLIENTE: ' + SC5->C5_CLIENTE + '-' + SC5->C5_LOJACLI + '   ' + ALLTRIM(SC5->C5_NOMCLI) + '.'
	_cText2   := 'PEDIDO: ' + SC5->C5_NUM + '.'
	_cRodap   := 'Avaliação de crédito'
	_cMsg += "<HTML><HEAD><TITLE></TITLE>"
	_cMsg += "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
	_cMsg += "<META content='MSHTML 6.00.6000.16735' name=GENERATOR></HEAD>"
	_cMsg += "<BODY>"   		 //Inicia conteudo do e-mail
	_cMsg += "<H4><Font Face = 'Arial' Size = '2'><P> " + _cCabec + " </P>"
	_cMsg += "<P> " + _cText1 + " <BR>"
	_cMsg += "<P> " + _cText2 + " <BR>"
	_cMsg += "<P> " + _cText3 + " "
	_cMsg += "<P> " + _cText4 + " "
	_cMsg += "<P><I>[WF TOTVS] " + _cRodap + "</I></P></H4><BR>"
	_cMsg += "<P>&nbsp;</P>"
	_cMsg += "</A></P></BODY>" //Finaliza conteudo do e-mail
	if !empty(_DestMail)
	    if ExistBlock("RCFGM001")
			StartJob('U_RCFGM001',GetEnvServer(),.F.,_cTitulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cBCC)
	//		U_RCFGM001(_cTitulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cBCC)
		endif
	else
		MSGBOX('Não foi possível enviar o e-mail de WorkFlow para o destinatário!',_cRotina+'_004','ALERT')
	endif
return
