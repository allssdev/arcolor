#include "RwMake.ch"
#include "Protheus.ch"
/*/{Protheus.doc} RTMKE034
@description Rotina desenvolvida para envios de emails aos clientes conforme texto desejado para clientes.
@author Arthur Silva (ALL System Solutions)
@since 09/03/2017
@version 1.0
@type function
@see https://allss.com.br
@history 23/04/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), adequação do titulo do e-mail removendo as palavras maiscuslas devido a restrições da localweb
/*/
user function RTMKE034()
	Private _cRotina    := "RTMKE034"
	Private cPerg     	:= _cRotina

	ValidPerg()
	if !Pergunte(cPerg,.T.)
		return .F.
	else
		Processa( { |lEnd| TextoMail(lEnd) }, "[" + _cRotina + "] Envio de e-mail aos clientes ativos", "Processando informações...", .T.)
	endif
return
/*/{Protheus.doc} TextoMail
@description Tela para que o usuário informe o texto para o envio do email.
@author Arthur Silva (ALL System Solutions)
@since 09/03/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function TextoMail(lEnd)
	local   oFont1      := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)    
	local   _cMail      := ""
	local   _cFromOri   := ""
	local   _cSA1TMP    := GetNextAlias()
	local   _lRCFGM001  := ExistBlock("RCFGM001")			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o P.E. existe ou não (várias vezes).

	private _cTextPad 	:= "" // Texto Padrão para o conteúdo do e-mail
	private Titulo	  	:= ""
	private _cAnexo   	:= ""
	private oGroup1
	private oSButton1
	private oSay1
	private oMultiGe1

	static oDlg
	DEFINE MSDIALOG oDlg TITLE "Envio de E-mail aos clientes Arcolor" FROM 000, 000  TO 550, 800 COLORS 0, 16777215 PIXEL
		@ 003, 003 GROUP oGroup1   TO 265, 400 PROMPT "Texto Padrão para Envio Automático de E-mails"                  OF oDlg              COLOR  0, 16777215 PIXEL
		@ 021, 010 SAY   oSay1                 PROMPT "INFORME ABAIXO O TEXTO PARA O ENVIO DOS E-MAILS." SIZE 300, 020 OF oDlg FONT oFont1	COLORS 0, 16777215 PIXEL
		@ 037, 010 GET   oMultiGe1 VAR _cTextPad OF oDlg MULTILINE SIZE 370, 218 COLORS 0, 16777215 HSCROLL                                                    PIXEL
	DEFINE SBUTTON oSButton1 FROM 018, 355 TYPE 01 OF oDlg ENABLE ACTION (oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED
	If Empty(_cTextPad)
		MsgStop("Email não enviado pois não foi digitado nenhum texto!",_cRotina+"_001")
		return .F.
	EndIf
	If MsgYesNo("Deseja enviar o e-mail para os clientes indicados nos parâmetros?",_cRotina+"_002")
		BeginSql Alias _cSA1TMP
			SELECT A1_COD, A1_LOJA, A1_EMAIL
			FROM %table:SA1% SA1 (NOLOCK)
			WHERE SA1.A1_FILIAL   = %xFilial:SA1%
				AND SA1.A1_COD    BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR03%
				AND SA1.A1_LOJA   BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR04%
				AND SA1.A1_MSBLQL <> '1'
				AND SA1.A1_EMAIL  <> ''
				AND SA1.A1_BCO1   <> 'FUN'
				AND SA1.%NotDel%
			ORDER BY A1_COD, A1_LOJA
		EndSql
		dbSelectArea(_cSA1TMP)
		ProcRegua((_cSA1TMP)->(RecCount()))
		(_cSA1TMP)->(dbGoTop())
		while !(_cSA1TMP)->(EOF())
			IncProc('Pocessando Envio dos Emails...')
			_cMail    := (_cSA1TMP)->A1_EMAIL
			If _lRCFGM001		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: ExistBlock("RCFGM001")
				//U_RCFGM001(Titulo,_cTextPad,_cMail,_cAnexo,_cFromOri,"","[ARCÓLOR - INFORMATIVO] - EMAIL AUTOMÁTICO ") //Chamada da rotina responsável pelo envio de e-mails
				U_RCFGM001(Titulo,_cTextPad,_cMail,_cAnexo,_cFromOri,"","[Arcolor - Informativo] - E-mail Automatico ") //Chamada da rotina responsável pelo envio de e-mails
			EndIf
			dbSelectArea(_cSA1TMP)
			(_cSA1TMP)->(dbSkip())
			Sleep(10000)
		enddo
		if Select(_cSA1TMP) > 0
			(_cSA1TMP)->(dbCloseArea())
		endif
	EndIf
return
/*/{Protheus.doc} ValidPerg
@description Valida se as perguntas já existem no arquivo SX1 e caso não encontre as cria no arquivo.
@author Arthur Silva (ALL System Solutions)
@since 09/03/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aAlias    := GetArea()
	local aRegs     := {}
	local _aTam      := {}
	local _x         := 0
	local _y         := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	_cPerg           := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam            := TamSx3("A1_COD" )
	AADD(aRegs,{cPerg,"01","De Cliente					  ?","","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G",""          	,"mv_par01","","","",""                     ,"","","","",""			,"","","","",""		,"","","","","","","","","","","SA1",""})
	_aTam            := TamSx3("A1_LOJA")
	AADD(aRegs,{cPerg,"02","Da Loja						  ?","","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G",""          	,"mv_par02","","","",""                     ,"","","","",""			,"","","","",""		,"","","","","","","","","","",""   ,""})
	_aTam            := TamSx3("A1_COD" )
	AADD(aRegs,{cPerg,"03","Até Cliente					  ?","","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()"	,"mv_par03","","","",Replicate("Z",_aTam[1]),"","","","",""			,"","","","",""		,"","","","","","","","","","","SA1",""})
	_aTam            := TamSx3("A1_LOJA")
	AADD(aRegs,{cPerg,"04","Até Loja					  ?","","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()"	,"mv_par04","","","",Replicate("Z",_aTam[1]),"","","","",""			,"","","","",""		,"","","","","","","","","","",""   ,""})
	for _x := 1 To Len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[_x,2],.T.,.F.))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for _y := 1 to FCount()
					if _y <= len(aRegs[_x])
						FieldPut(_y,aRegs[_x,_y])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	RestArea(_aAlias)
return
