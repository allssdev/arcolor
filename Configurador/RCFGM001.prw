#INCLUDE "TOTVS.CH"
//#INCLUDE "PROTHEUS.CH"
//#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "FILEIO.CH"
#DEFINE ENT (CHR(13)+CHR(10))
/*/{Protheus.doc} RCFGM001
Rotina genérica para envio de e-mails.
@author Anderson C. P. Coelho (anderson.coelho@allss.com.br) - ALLSS Soluções em Sistemas
@since 18/05/2013
@version P12.1.33
@type function
@history 08/10/2013, Adriano Leonardo, Implementação de ajustes de melhoria.
@history 11/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ativação da funcionalidade de envio de cópia de e-mail para os endereços passados por parâmetro à rotina.
@see https://allss.com.br
/*/
user function RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cCOculta,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCopia)
	local   ncont     := 0

	Private oServer
	Private oMessage
	Private nMOb
	Private nErr      := 0
	Private _lSSL     := SuperGetMv("MV_RELSSL" ,,.F.)           // Usa SSL Seguro
	Private _lTLS     := SuperGetMv("MV_RELTLS" ,,.F.)           // Usa TLS Seguro
	Private _lConfirm := .F.	                                 // Confirmação de leitura
	Private cPopAddr  := IIF(!":"$SuperGetMv("MV_RELPOP3" ,,"pop.arcolor.com.br" ),SuperGetMv("MV_RELPOP3" ,,"pop.arcolor.com.br" ),SubStr(SuperGetMv("MV_RELPOP3" ,,"pop.arcolor.com.br" ),1,AT(":",SuperGetMv("MV_RELPOP3" ,,"pop.arcolor.com.br" ))-1))		 // Endereco do servidor POP3	******
	Private cSMTPAddr := IIF(!":"$SuperGetMv("MV_RELSERV" ,,"smtp.arcolor.com.br"),SuperGetMv("MV_RELSERV" ,,"smtp.arcolor.com.br"),SubStr(SuperGetMv("MV_RELSERV" ,,"smtp.arcolor.com.br"),1,AT(":",SuperGetMv("MV_RELSERV" ,,"smtp.arcolor.com.br"))-1))		 // Endereco do servidor SMTP
	Private cPOPPort  := (SuperGetMv("MV_RELPORP" ,,110))		 // Porta do servidor POP		******
	Private cSMTPPort := (SuperGetMv("MV_RELPORS" ,,587))		 // Porta do servidor SMTP		******
	Private cUser     := (SuperGetMv("MV_RELAUSR" ,,"nfe@arcolor.com.br"))		 // Usuario que ira realizar a autenticação
	Private cPass     := (SuperGetMv("MV_RELAPSW" ,,"a1i2b3@2016"))		 // Senha do usuario
	Private nSMTPTime := (SuperGetMv("MV_RELTIME" ,,120))		 // Timeout SMTP
	Private _cFrom    := (SuperGetMv("MV_RELFROM" ,,"nfe@arcolor.com.br"))		 // Remetente da mensagem
	Private _cTo      := ""                             		 // Destinatário da mensagem
	Private _cCC      := ""                            			 // Cópia da mensagem
	Private _cBCC     := ""                             		 // Cópia oculta
	Private _cRotina  := "RCFGM001"
	Private _lMultAnex:= .F.
	Private _cLogo    := "\system\EmailArcolor.jpg"                            // Logotipo da empresa
							
	Default _cAssunto := "[WF] MENSAGEM AUTOMÁTICA"
	Default Titulo    := ""
	Default _cMsg     := ""
	Default _cMail    := ""
	Default _cAnexo   := ""
	Default _cFromOri := ""
	Default _cCopia   := ""
	Default _cCOculta := ""
	Default _lExcAnex := .T.
	Default _lAlert   := .T.
	Default _lHtmlOk  := .F.

	Public _aAnexTemp := ""
	Public _lRetMail  := .T.

	if !Empty(_cMail)
		_cMail 	:= AllTrim(_cMail)
		while Len(_cMail) > 0 .AND. SubStr(_cMail,Len(_cMail),1) == ";"
			_cMail := SubStr(_cMail,1,Len(_cMail)-1)
		enddo
		_cTo 	:= _cMail
	endif
	if !Empty(_cCopia)
		_cCopia := AllTrim(_cCopia)
		while Len(_cMail) > 0 .AND. SubStr(_cCopia,Len(_cCopia),1) == ";"
			_cCopia := SubStr(_cCopia,1,Len(_cCopia)-1)
		enddo
		_cCC 	:= _cCopia
	endif
	if !Empty(_cCOculta)
		_cMail 	:= AllTrim(_cCOculta)
		while Len(_cCOculta) > 0 .AND. SubStr(_cCOculta,Len(_cCOculta),1) == ";"
			_cCOculta := SubStr(_cCOculta,1,Len(_cCOculta)-1)
		enddo
		_cBCC 	:= _cCOculta
	endif

	If !Empty(Titulo)
		_cAssunto := AllTrim(_cAssunto) + " - " + AllTrim(Titulo)
	EndIf
	If Empty(_cTo)
		If _lAlert
			MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] E-mail não informado para destino!",_cRotina+"_001")
		EndIf
		_lRetMail := .F.
		return _lRetMail
	EndIf	
	// Instancia um novo TMailManager
	oServer := tMailManager():New()
	If _lSSL
		// Usa SSL na conexao
		oServer:SetUseSSL(_lSSL)
	EndIf
	If _lTLS
		//Define no envio de e-mail o uso de STARTTLS durante o protocolo de comunicação (Indica se, verdadeiro .T., utilizará a comunicação segura através de SSL/TLS; caso contrário, .F.)
		oServer:SetUseTLS(_lTLS)
	EndIf
	//Inicializa
	oServer:Init(cPopAddr, cSMTPAddr, cUser, cPass, cPOPPort, cSMTPPort)
	//Define o Timeout SMTP
	If oServer:SetSMTPTimeout(nSMTPTime) != 0
		If _lAlert
			MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Falha ao definir timeout!",_cRotina+"_002")
		EndIf
		_lRetMail := .F.
		return _lRetMail
	EndIf
	// Conecta ao servidor
	nErr := oServer:SMTPConnect()
	//nErr := oServer:IMAPConnect()
	//nErr := oServer:IMAPDisconnect()
	If nErr <> 0
		If _lAlert
			MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Falha ao conectar: " + AllTrim(Str(nErr)) + " - " + AllTrim(oServer:GetErrorString(nErr)) + "!",_cRotina+"_003")
		EndIf
		//oServer:SmtpDisconnect()
		//oServer:IMAPDisconnect()
		_lRetMail := .F.
		return _lRetMail
	EndIf
	//oMailManager:SetUseRealID(.T.)		//Define o tipo de identificação, no servidor de e-mail IMAP - Internet Message Access Protocol, para utilização do ID único da mensagem para a busca de mensagens.
	// Realiza autenticação no servidor
	nErr := oServer:SmtpAuth(cUser, cPass)
	If nErr <> 0
		If _lAlert
			MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Falha ao autenticar: " + AllTrim(Str(nErr)) + " - " + AllTrim(oServer:getErrorString(nErr)) + "!",_cRotina+"_004")
		EndIf
		oServer:SmtpDisconnect()
		//oServer:IMAPDisconnect()
		_lRetMail := .F.
		return _lRetMail
	EndIf
	// Cria uma nova mensagem atraves da Classe TMailMessage
	oMessage := tMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom := AllTrim(_cFrom)
	oMessage:cTo   := AllTrim(_cTo)
	If !Empty(_cCC)
		oMessage:cCC   := AllTrim(_cCC)
	EndIf
	If !Empty(_cBCC)
		oMessage:cBCC := AllTrim(_cBCC)
	EndIf
	oMessage:cSubject := AllTrim(_cAssunto)
	if !_lHtmlOk
		_cTexto := "<html>"
		_cTexto += "	<head>"
		_cTexto += "		<title>"
		_cTexto += "			" + oMessage:cSubject
		_cTexto += "		</title>"
		_cTexto += "	</head>"
		_cTexto += "	<body>"
		_cTexto += "		<hr size=2 width='100%' align=center>"
		_cTexto += "		<BR>"
		_cTexto += 			StrTran(_cMsg,CHR(10),"<BR>")
		_cTexto += "		<BR>"
		If !Empty(_cLogo)
			_cTexto += "		<img width='500' height='200' src='cid:ID_" + _cLogo + "'>"
		EndIf
		_cTexto += "		<hr size=2 width='100%' align=center>"
		_cTexto += "		<BR>"
		_cTexto += "	</body>"
		_cTexto += "</html>"
	else
		_cTexto := _cMsg
	endif
	oMessage:cBody := _cTexto
	oMessage:MsgBodyType("text/html")
	//Para solicitar confimação de envio
	If _lConfirm
		oMessage:SetConfirmRead(.T.)
	EndIf
	//informo o server que iremos trabalhar com ID real da mensagem
	//oMailManager:SetUseRealID(.T.)
	//Adiciono attach (anexo)
	//Trecho adicionado por Adriano Leonardo em 26/08/2013
	If !Empty(_cAnexo) .And. ";" $ _cAnexo
		_aAnexo := StrTokArr(_cAnexo,";")
		_lMultAnex := .T.
		For ncont:=1 To Len(_aAnexo)	
			If oMessage:AttachFile(_aAnexo[ncont]) < 0
				If _lAlert
					If !MsgYesNo(DTOC(Date()) + " " + Time() + " - " + "[ALERT] Falha ao anexar o arquivo '"+_aAnexo[ncont]+"'! Continua mesmo assim?",_cRotina+"_005A")
						oServer:SmtpDisconnect()
						_lRetMail := .F.
						return _lRetMail
					EndIf
				EndIf
	
			Else
				//Adiciono uma tag informando que é um attach e o nome do arq
				//oMessage:AddAtthTag( 'Content-Disposition: attachment; filename=' + _cAnexo)
				oMessage:AddAttHTag("Content-ID: <ID_" + _aAnexo[ncont] + ">")
			EndIf
		Next
	EndIf                                                      
	//Fim do trecho adicionado por Adriano Leonardo em 26/08/2013
	//If !Empty(_cAnexo) // Linha comentada por Adriano Leonardo em 26/08/2013 para melhoria na rotina(linha substituta logo abaixo)
	//Adiciono um attach (anexo)
	If !Empty(_cLogo)
		If oMessage:AttachFile(_cLogo) < 0
				If !MsgYesNo(DTOC(Date()) + " " + Time() + " - " + "[ALERT] Falha ao anexar o arquivo '"+_cAnexo+"'! Continua mesmo assim?",_cRotina+"_005B")
					oServer:SmtpDisconnect()
					//oServer:IMAPDisconnect()
					_lRetMail := .F.
					return _lRetMail
				EndIf
		Else
			oMessage:AddAttHTag("Content-ID: <ID_" + _cLogo + ">")
		EndIf
	EndIf
	If !Empty(_cAnexo) .And. !_lMultAnex
		If oMessage:AttachFile(_cAnexo) < 0
			If _lAlert
				If !MsgYesNo(DTOC(Date()) + " " + Time() + " - " + "[ALERT] Falha ao anexar o arquivo '"+_cAnexo+"'! Continua mesmo assim?",_cRotina+"_005C")
					oServer:SmtpDisconnect()
					//oServer:IMAPDisconnect()
					_lRetMail := .F.
					return _lRetMail
				EndIf
			EndIf
		Else
			//Adiciono uma tag informando que é um attach e o nome do arq
			//oMessage:AddAtthTag( 'Content-Disposition: attachment; filename=' + _cAnexo)
			oMessage:AddAttHTag("Content-ID: <ID_" + _cAnexo + ">")
		EndIf
	EndIf
	If !Empty(_cFromOri)
		oMessage:cFrom := _cFromOri
	EndIf
	// Envia a mensagem
	nErr := oMessage:Send(oServer)
	If nErr <> 0
		If _lAlert
			MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Falha ao enviar: " + AllTrim(Str(nErr)) + " - " + AllTrim(oServer:GetErrorString(nErr)) + "!",_cRotina+"_006")
		EndIf
		oServer:SmtpDisconnect()
		//oServer:IMAPDisconnect()
		_lRetMail := .F.
		return _lRetMail
	EndIf
	//Desconecto do servidor
	If oServer:SmtpDisconnect() /*oServer:IMAPDisconnect()*/ != 0
		If _lAlert
			MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Erro ao desconectar do servidor SMTP!",_cRotina+"_007")
		EndIf
	//	_lRetMail := .F.
	//	return _lRetMail
	EndIf
	//Início - Trecho adicionado por Adriano Leonardo em 08/10/2013 para melhoria na rotina
	_aAnexTemp := _cAnexo
	//Fim  - Trecho adicionado por Adriano Leonardo em 08/10/2013 para melhoria na rotina
	//_lRetMail := .T.
return _lRetMail
