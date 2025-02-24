#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#Include 'TOTVS.ch'
#Include 'topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD166ST  ºAutor  ³Arthur Silvaº 			 Data  ³  21/08/17º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³LOCALIZAÇÃO : Function VldCodSep() - Validação da Ordem de  º±±
±±º			  Separação. é executado antes da função MSCBFSem()           º±±
±±º           DESCRIÇÃO : É utilizado para validar a Ordem de Separação   º±±
±±º           informada pelo coletor RF, permitindo ou não que o operador º±±
±±º           continue no processo de Separação.       					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function ACD166ST()
	local _lRet     := .T. 	// Customização de usuário. Caso o retorno seja falso, não finaliza a separação. 
	local _cOrdSep  := PARAMIXB[1] 
	Local _dDtIni   := ""
	Local _cNomeCb1 := ""
	Local _cCodUser := __cUserId
	Local _cUser	:= ""			

	dbSelectArea("CB1")
	CB1->(dbSetOrder(2))
	If CB1->(MsSeek(xFilial("CB1") + _cCodUser,.T.,.F.))
		_cNomeCb1 := CB1->CB1_NOME
		_cCodSep  := CB1->CB1_CODOPE
		_cUser	  := CB1->CB1_CODUSR
	EndIf
	dbSelectArea("CB7")
	CB7->(dbSetOrder(1))
	If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
		_dDtIni  := CB7->CB7_DTISEP
		_cNomeOs := CB7->CB7_NOMOP1
		If Empty(_dDtIni)
			while !RecLock("CB7",.F.) ; enddo
				CB7->CB7_CODOPE := _cCodSep
				CB7->CB7_NOMOP1 := _cNomeCb1
				CB7->CB7_DTISEP := Date()
				CB7->CB7_HRISOS := Time()
			CB7->(MsUnLock())
		ElseIf _cCodUser <> _cUser
			VtAlert("Processo de Separação/Conferência já iniciado pelo Operador '" + _cNomeOs + "' na O.S:'" + _cOrdSep + "' , verifique!","AVISO", .T.)
			_lRet := .F.
		EndIf
	EndIf
return _lRet
