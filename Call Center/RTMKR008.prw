#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH
#INCLUDE "SHELL.CH

#DEFINE _lEnd CHR(13) + CHR(10)
/*/{Protheus.doc} RTMKR007
@description Envio de e-mail aos CLIENTES ATIVOS com o texto DE ACORDO COM O PERGUNTE
@author Lívia Della Corte (ALL System Solutions)
@since 17/09/2018
@version 1.0
@type function
@see https://allss.com.br
@history 23/04/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), adequação do titulo do e-mail removendo as palavras maiscuslas devido a restrições da localweb
/*/
user function RTMKR008()

	private oSay1
	private oSay2
	private oSay3
	private oSay4
	private oSay5
	private oSButton1
	private oSButton2
	private oSButton3
	private oButton4
	private oGet3
	private oGet4
	private oGet5
	private oGroup1, oGroup2, oGroup4, oGroup3,oGroup5, oGroup6 :=Space(10)
	private oCombo
	private oComb1
	private oMultiGe1
	private cDrive, cDir, cNome, cExt
//	private cDrive2, cDir2, cNome2, cExt2
	private cTitulo   := "Envio de cobrança por e-mail"
	private _cRotina  := "RTMKR008"
	private cPerg     := _cRotina
	private _cArqOri  := ""
	private _cDst3    := "\comunicado\"
	private _cDst4    := "\comunicado\"
	private _nOpc     := 0
	private bOk       := { || _nOpc := 1, RotEnvMail(.T.,_cTextPad),oDlg:End()                         }
	private bCancel   := { || oDlg:End()                                     }
	private bDir      := { || _cArqOri := Lower(AllTrim(Lower(SelDirArq()))) }
	private cGet1     := SPACE(50) 
	private cGet5     := SPACE(50) 
	private cGet3     := SPACE(50) 
	private cGet4     := SPACE(50) 
	private cGet2     := "[Arcolor] - Faturas em aberto
	private cGet6     := SPACE(50)                                                                                                "
	private _cTextPad := "**Inclua aqui seu Texto**"
	private nTipo     := 1 
	private _cMsgFim  := ""
	private lPerg     := .F.
	private cTst      := "0"
	private nCombo := "4" //Inicializa com todos os emails
	private nComb1	:= "1" //Inicializa com SIm para Enviar titulos.
	private oFont2    := TFont():New("ARIAL",,14,,.T.,,,,,.F.,.F.)	 
	private oFont3    := TFont():New("ARIAL",,16,,.T.,,,,,.F.,.F.)	 
	private aItens    := {"1 - Financeiro","2 - Fiscal"     ,"3 - Comercial", "4 - Todos" } 
	private aIt1      := {"1 - Sim"   , "2 - Não"}

private _lAuth := Type("CFILANT")=="U"
If _lAuth
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina
EndIf


	static oDlg

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO 600, 850 COLORS 0, 16777215 PIXEL

	    @ 006, 013 GROUP oGroup1 TO 040, 410 PROMPT " ***   I M P O R T A N T E  *** " OF oDlg   COLOR  0, 16777215    PIXEL
	    @ 016, 020 SAY oSay1 PROMPT "Esta rotina é utilizada para o envio de e-mail aos clientes em HTML com a imagem em formato JPG em seu corpo. 				        " SIZE 350, 007 OF oDlg   COLORS 0, 16777215 FONT oFont3 PIXEL
	    @ 028, 020 SAY oSay2 PROMPT "Tenha cuidado com a informação que será enviada, pois o processo será irreversível! 	                                                                             " SIZE 350, 007 OF oDlg   COLORS 0, 16777215 FONT oFont3 PIXEL

        @ 042, 016 GROUP oGroup3 TO 020, 410 PROMPT "  Destinário(s)  " OF oDlg COLOR 0, 16777215 PIXEL	   
        @ 059, 020 SAY oSay3 PROMPT "Email(s): " SIZE 350, 007 OF oDlg   COLORS 0, 16777215 PIXEL
        @ 059, 049 MSCOMBOBOX oCombo VAR nCombo ITEMS aItens  SIZE 100, 012 OF oDlg COLORS 0, 16777215  PIXEL
	    @ 059, 151  MSGET  oGet3    	VAR    cGet3       SIZE 250, 010 OF oDlg COLORS 0, 16777215          PIXEL

   
        @ 081, 020 SAY oSay3 PROMPT "Listar Titulos em Aberto: " SIZE 350, 007 OF oDlg   COLORS 0, 16777215 PIXEL
	    @ 082, 085 MSCOMBOBOX oComb1 VAR nComb1 ITEMS aIt1 SIZE 100, 012 OF oDlg COLORS 0, 16777215  PIXEL

		@ 097, 013 GROUP oGroup2 TO 020, 410 PROMPT " Assunto" OF oDlg COLOR 0, 16777215 PIXEL	   
	    @ 102, 020  MSGET  oGet2    	VAR    cGet2       SIZE 380, 010 OF oDlg COLORS 0, 16777215          PIXEL
	
	    @ 123, 013 GROUP oGroup5 TO 270, 410 PROMPT " Texto da Mensagem " OF oDlg COLOR 0, 16777215 PIXEL	   
		@ 138, 020 GET   oMultiGe1 VAR _cTextPad OF oDlg MULTILINE SIZE 380, 110 COLORS 0, 16777215 HSCROLL PIXEL


        @ 248, 016 GROUP oGroup4 TO 010, 410 PROMPT " Arquivo Anexo" OF oDlg COLOR 0, 16777215 PIXEL	   
  	    @ 253, 020  MSGET  oGet4    	VAR    cGet4       SIZE 380, 010 OF oDlg COLORS 0, 16777215          PIXEL
	    @ 253, 365  BUTTON oButton1     PROMPT "&Anexo"  ACTION EVAL({|| nTipo := 2 ,cGet4:=  Lower(AllTrim(Lower(SelDirArq())))})      SIZE 037, 012 OF oDlg PIXEL


		DEFINE SBUTTON oSButton2 FROM 275, 250 TYPE 01 OF oDlg ENABLE  ACTION Eval(bOk    )
		DEFINE SBUTTON oSButton3 FROM 275, 290 TYPE 02 OF oDlg ENABLE ACTION Eval(bCancel)
		
		@ 275, 330  BUTTON oButton5     PROMPT "&Enviar Email TESTE"  ACTION EVAL({|| _nOpc:= 3, RotEnvMail(.T.,_cTextPad) })      SIZE 080, 012 OF oDlg PIXEL
		
		
		
	ACTIVATE MSDIALOG oDlg CENTERED
return
/*/{Protheus.doc} RotEnvMail
@description Rotina para procesamento do envio de e-mail (função chamada pela rotina 'RTMKR008').
@author Lívia Della Corte (ALL System Solutions)
@since 17/09/2018
@version 1.0
@type function
@see https:// allss.com.br
/*/
static function RotEnvMail(lEnd,_cMsgFim)
	local Titulo     := ""
	local _cMsg      := ""
	local _cMail     := ""
	local _cAnexo1   := ""
	local _cAnexo2   := "" 
	local _cFromOri  := ""
	local _cBCC      := ""
	local _cQry      := ""
	local _cLogOK    := ""
	local _cLogErro  := ""
	local _cLastMsg  := ""
	local _cDirLog   := "\2.MemoWrite\"
	local _cAlias    := GetNextAlias()
	local _cMailFrom := SuperGetMv("MV_RELFROM",,"arcolor.nfe@gmail.com")
	local _cMailUsr  := UsrRetMail(RetCodUsr())		
	local _lRCFGM001 := ExistBlock("RCFGM001")		
	local _nLogOK    := 0
	local _nLogErro  := 0
//	local _nTotMsg   := 1000
	local ncont      := 0
//	local _nContMsg  := 0
//	local _nSeqMsg   := 1

	_cMsgFim := iif(!"**Inclua aqui seu Texto**"$_cMsgFim, _cMsgFim,  STRTRAN(_cMsgFim, "**Inclua aqui seu Texto**", ""))

	if _nOpc == 1 .OR. _nOpc == 3
		_cAnexo1  := cGet3
		_cAnexo2  := cGet4
		if !Empty(_cAnexo1) .AND. File(_cAnexo1)
			SplitPath( _cAnexo1, @cDrive, @cDir, @cNome, @cExt )
			CpyT2S( (cDrive+cDir+cNome+cExt), _cDst3, .F. )
			if !File(_cDst3+cNome+cExt)
				_cDst3 := _cAnexo1
			Else
				_cDst3 := _cDst3+cNome+cExt
				SplitPath( _cDst3, @cDrive, @cDir, @cNome, @cExt )
			endif
			_cAnexo1 := (cDrive+cDir+cNome+cExt)
		endif
		if !Empty(_cAnexo2) .AND. File(_cAnexo2)
			SplitPath( _cAnexo2, @cDrive, @cDir, @cNome, @cExt )
			CpyT2S( (cDrive+cDir+cNome+cExt), _cDst4, .F. )
			if !File(_cDst4+cNome+cExt)
				_cDst4 := _cAnexo2
			Else
				_cDst4 := _cDst4+cNome+cExt
				SplitPath( _cDst4, @cDrive, @cDir, @cNome, @cExt )
			endif	
			_cAnexo2  := (cDrive+cDir+cNome+cExt)
		endif
		if  !"**Inclua aqui seu Texto**"$_cTextPad 
			if !Empty(_cTextPad) .AND. "/" $ _cTextPad
				_aTextPad := StrTokArr(_cTextPad,"/")
				for ncont := 1 to Len(_aTextPad)	
					_cMsgFim += "<BR><hr size=2 width='100%' align=center>" +  _aTextPad[ncont] +_lEnd
				next
			else
				_cMsgFim := _cTextPad
			endif		
		endif
	endif
	if !empty(_cAnexo1)
		_cMsgFim += '<img src="' + 'cid:ID_' + _cAnexo1 + '" alt="Aviso Importante!" title="AVISO IMPORTANTE"/>'
	endif
	if !lPerg
		ValidPerg(substring(nComb1,1,1))
		Pergunte(cPerg+substring(nComb1,1,1),.T.)
	endif
	if _lRCFGM001 .AND. _nOpc == 3 //se for teste envia para o usuario logado //senao envia para range de 
		U_RCFGM001(Titulo,_cMsgFim,_cMail,_cAnexo1 +";"+_cAnexo2 ,_cMailFrom,"",cGet5,.F.,.f.)
		MsgInfo("E-mail teste enviado para o endereço: " +_cMail ,_cRotina+"_004")
	endif
	
	if !Empty(_cLogOK) .AND. ExistDir(_cDirLog)
		MemoWrite(_cDirLog+_cRotina+"_LogOK.txt","Registros enviados com sucesso: " + _cLogOK)
		if File(_cDirLog+_cRotina+"_LogOK.txt")
			FOpen(_cDirLog+_cRotina+"_LogOK.txt")
		endif
	endif
	if !Empty(_cLogOK) .AND. ExistDir(_cDirLog)
		MemoWrite(_cDirLog+_cRotina+"_LogERRO.txt","Registros com ERRO no envio: " + _cLogErro)
		if File(_cDirLog+_cRotina+"_LogERRO.txt")
			FOpen(_cDirLog+_cRotina+"_LogERRO.txt")
		endif
	endif
	MsgInfo("Fim do processamento." + "Clientes com êxito: " + cValToChar(_nLogOK) +   _lEnd + "Clientes com problemas: " + cValToChar(_nLogErro)  + _lEnd,_cRotina+"_003")
return
/*/{Protheus.doc} SelDirArq
@description Seleçao de arquivo em diretorio (função chamada pela rotina 'RTMKR007').
@author Lívia Della Corte (ALL System Solutions)
@since 17/09/2018
@version 1.0
@param nTipo, numeric, Tipo do anexo
@type function
@see https:// allss.com.br
/*/
static function SelDirArq(nTipo)
	if nTipo == 1
		_cArqOri     := cGetFile("*.jpg", "Selecione o arquivo a ser enviado...",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
	else
		_cArqOri     := cGetFile("*.*", "Selecione o arquivo a ser enviado...",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
	endif
return(_cArqOri)
/*/{Protheus.doc} ValidPerg
@description Verifica se as perguntas existem na SX1. Caso não existam, as cria (função chamada pela rotina 'RTMKR007').
@author Lívia Della Corte (ALL System Solutions)
@since 17/09/2018
@version 1.0
@param nComb1, numeric, Opção do combo
@type function
@see https:// allss.com.br
/*/
static function ValidPerg(nComb1)
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

	cPerg  := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO)-1)+substring(nComb1,1,1)

	if substr(nComb1,1,1) == "1"
		_aTam  := TamSx3("A3_COD" )

		// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
		AADD(aRegs,{cPerg,"01","Do Representante      ?","","all_","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
		AADD(aRegs,{cPerg,"02","Até o Representante   ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})

		//AADD(aRegs,{cPerg,"01","Do Vendedor           ?","","all_","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
		//AADD(aRegs,{cPerg,"02","Até o Vendedor        ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022

		_aTam  := TamSx3("A1_COD" )
		AADD(aRegs,{cPerg,"03","Do Cliente            ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
		_aTam  := TamSx3("A1_LOJA")
		AADD(aRegs,{cPerg,"04","Da Loja               ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
		_aTam  := TamSx3("A1_COD" )
		AADD(aRegs,{cPerg,"05","Até o Cliente         ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par05",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
		_aTam  := TamSx3("A1_LOJA")
		AADD(aRegs,{cPerg,"06","Até a Loja            ?","","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par06",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	elseif substr(nComb1,1,1)== "2"
		_aTam  := TamSx3("A2_COD" )
		AADD(aRegs,{cPerg,"03","Do Forncedor          ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA2","",""})
		_aTam  := TamSx3("A2_LOJA")
		AADD(aRegs,{cPerg,"04","Da Loja               ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
		_aTam  := TamSx3("A2_COD" )
		AADD(aRegs,{cPerg,"05","Até o Fornecedor      ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA2","",""})
		_aTam  := TamSx3("A2_LOJA")
		AADD(aRegs,{cPerg,"06","Até a Loja            ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	else
		_aTam  := TamSx3("A3_COD" )
		// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
		AADD(aRegs,{cPerg,"01","Do Representante      ?","","all_","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
		AADD(aRegs,{cPerg,"02","Até o Representante   ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})

		//AADD(aRegs,{cPerg,"01","Do Vendedor           ?","","all_","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
		//AADD(aRegs,{cPerg,"02","Até o Vendedor        ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022

	endif
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




/*/{Protheus.doc} RotEnvMail
@description Rotina para procesamento do envio de e-mail (função chamada pela rotina 'RTMKR007').
@author Lívia Della Corte (ALL System Solutions)
@since 17/09/2018
@version 1.0
@type function
@see https:// allss.com.br
/*/
static function DestEnvMail(lEnd,nCombo)
	local Titulo     := ""
	local _cMsg      := ""
	local _cMail     := ""
	local _cAnexo1   := ""
	local _cAnexo2   := "" 
	local _cFromOri  := ""
	local _cBCC      := ""
	local _cQry      := ""
	local _cLogOK    := ""
	local _cLogErro  := ""
	local _cLastMsg  := ""
	local _cDirLog   := "\2.MemoWrite\"
	local _cAlias    := GetNextAlias()
	local _cMailFrom := SuperGetMv("MV_RELFROM",,"arcolor.nfe@gmail.com")
	local _cMailUsr  := UsrRetMail(RetCodUsr())		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do while para melhoria de perfomance, evitando assim que, no meio do loop, o sistema não tenha de ficar consultando o conteúdo do parâmetro.

	BeginSql Alias _cAlias
			SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_EMAIL, A1_EMAIL1, A1_EMAIL2
			FROM %table:SA1% SA1 (NOLOCK)
			WHERE SA1.A1_FILIAL     = %xFilial:SA1%
			  AND SA1.A1_MSBLQL     = %Exp:'2'%
			  AND LEN(LTRIM(RTRIM(SA1.A1_EMAIL))) > %Exp:3%
			  AND SA1.A1_COD  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05%
			  AND SA1.A1_LOJA BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR06%
			  AND SA1.%NotDel%
			ORDER BY A1_FILIAL, A1_COD, A1_LOJA
		EndSql
		dbSelectArea(_cAlias)
		ProcRegua((_cAlias)->(RecCount()))
		(_cAlias)->(dbGoTop())
		if !(_cAlias)->(EOF())
			while !(_cAlias)->(EOF())
				IncProc()
				_cMail    := _cMailUsr			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: UsrRetMail(RetCodUsr())
				If SUBSTR(nCombo,1) == 4
					_cMail += ";" + (_cAlias)->A1_EMAIL + ";" + (_cAlias)->A1_EMAIL1 + ";" + (_cAlias)->A1_EMAIL2
				ElseIf SUBSTR(nCombo,1) == 2
					_cMail+= ";" + (_cAlias)->A1_EMAIL
				ElseIf SUBSTR(nCombo,1) == 1
					_cMail+= ";" + (_cAlias)->A1_EMAIL2
				ElseIf SUBSTR(nCombo,1) == 3
					_cMail+= ";" + (_cAlias)->A1_EMAIL1
				EndiF
				dbSelectArea(_cAlias)
				(_cAlias)->(dbSkip())
			enddo
		endif
		dbSelectArea(_cAlias)
		(_cAlias)->(dbCloseArea())
	
return(_cMail)
