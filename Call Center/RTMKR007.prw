#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
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
user function RTMKR007()
	private oGroup1
	private oSay1
	private oSay2
//	private oSay3
//	private oSay4
//	private oSay5
	private oSButton1
	private oSButton2
	private oSButton3
	private oButton4
	private oGet3
	private oGet4
	private oGet5
//	private oGroup2
	private oGroup4
	private oGroup3
	private oGroup5
//	private oGroup6
	private oCombo
	private oComb1
	private oMultiGe1
	private cDrive, cDir, cNome, cExt
//	private cDrive2, cDir2, cNome2, cExt2
	private cTitulo   := "Envio de Comunicado via e-mail"
	private _cRotina  := "RTMKR007"
	private cPerg     := _cRotina
	private _cArqOri  := ""
	private _cDst3    := "\comunicado\"
	private _cDst4    := "\comunicado\"
	private _nOpc     := 0
	private bOk       := { || _nOpc := 1, RotEnvMail(.T.,_cTextPad),oDlg:End()                         }
	private bCancel   := { || oDlg:End()                                     }
	private bDir      := { || _cArqOri := Lower(AllTrim(Lower(SelDirArq()))) }
	private cGet3     := SPACE(50) 
	private cGet4     := SPACE(50) 
	private cGet5     := "[Arcolor] - Comunicado                                                                                               "
	private _cTextPad := "**Inclua aqui seu Texto**"
	private nTipo     := 1 
	private _cMsgFim  := ""
	private lPerg     := .F.
	private cTst      := "0"
	private nCombo
	private nComb1
	private oFont2    := TFont():New("ARIAL",,14,,.T.,,,,,.F.,.F.)	 
	private oFont3    := TFont():New("ARIAL",,16,,.T.,,,,,.F.,.F.)	 
	private aItens    := {"Sem Tratamento","À Empresa "     ,"Ao Cliente " } 
	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	private aIt1      := {"1 - Cliente"   , "2 - Fornecedor","3 - Representate"}
	//private aIt1      := {"1 - Cliente"   , "2 - Fornecedor","3 - Vendedor"}
	// FIm - Fernando Bombardi - ALLSS - 02/03/2022

	static oDlg

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO 600, 850 COLORS 0, 16777215 PIXEL

	    @ 010, 014 GROUP oGroup1 TO 050, 420 PROMPT " ***   I M P O R T A N T E  *** " OF oDlg   COLOR  0, 16777215    PIXEL
	    @ 022, 020 SAY oSay1 PROMPT "Esta rotina é utilizada para o envio de e-mail aos clientes em HTML com a imagem em formato JPG em seu corpo. 				        " SIZE 350, 007 OF oDlg   COLORS 0, 16777215 FONT oFont3 PIXEL
	    @ 032, 020 SAY oSay2 PROMPT "Tenha cuidado com a informação que será enviada, pois o processo será irreversível! 	                                                                             " SIZE 350, 007 OF oDlg   COLORS 0, 16777215 FONT oFont3 PIXEL

        @ 052, 014 GROUP oGroup3 TO 080, 420 PROMPT " Imagem do E-mail " OF oDlg COLOR 0, 16777215 PIXEL
        @ 063, 020  MSGET  oGet3  VAR    cGet3      SIZE 380, 010 OF oDlg COLORS 0, 16777215          PIXEL
  	    @ 063, 370  BUTTON oSButton1    PROMPT "&Imagem" ACTION    EVAL({|| nTipo := 1 ,cGet3:=  Lower(AllTrim(Lower(SelDirArq())))})          SIZE 037, 012 OF oDlg PIXEL

        @ 082, 014 GROUP oGroup4 TO 110, 420 PROMPT " Arquivo Anexo" OF oDlg COLOR 0, 16777215 PIXEL	   
  	    @ 093, 020  MSGET  oGet4    	VAR    cGet4       SIZE 380, 010 OF oDlg COLORS 0, 16777215          PIXEL
	    @ 093, 370  BUTTON oButton1     PROMPT "&Anexo"  ACTION EVAL({|| nTipo := 2 ,cGet4:=  Lower(AllTrim(Lower(SelDirArq())))})      SIZE 037, 012 OF oDlg PIXEL

		@ 112, 014 GROUP oGroup5 TO 140, 420 PROMPT " Assunto" OF oDlg COLOR 0, 16777215 PIXEL	   
	    @ 123, 020  MSGET  oGet5    	VAR    cGet5       SIZE 390, 010 OF oDlg COLORS 0, 16777215          PIXEL
	 
        @ 142, 014 GROUP oGroup5 TO 170, 420 PROMPT "  Destinário(s)  " OF oDlg COLOR 0, 16777215 PIXEL	   
        @ 153, 020 MSCOMBOBOX oCombo VAR nCombo ITEMS aItens SIZE 100, 012 OF oDlg COLORS 0, 16777215  PIXEL
   
        @ 153, 140 SAY oSay2 PROMPT "Tipo de Destinatário: " SIZE 350, 007 OF oDlg   COLORS 0, 16777215 PIXEL
	    @ 153, 198 MSCOMBOBOX oComb1 VAR nComb1 ITEMS aIt1 SIZE 100, 012 OF oDlg COLORS 0, 16777215  PIXEL
   
	    @ 153, 310  BUTTON oButton4     PROMPT "&Gera Filtro"  ACTION EVAL({|| lPerg:= .T.,ValidPerg(substring(nComb1,1,1)), Pergunte((cPerg+substring(nComb1,1,1)),.T.)})      SIZE 037, 012 OF oDlg PIXEL

	    @ 178, 330  BUTTON oButton5     PROMPT "&Enviar Email TESTE"  ACTION EVAL({|| _nOpc:= 3, RotEnvMail(.T.,_cTextPad) })      SIZE 080, 012 OF oDlg PIXEL

	    @ 192, 014 GROUP oGroup5 TO 270, 420 PROMPT " Texto da Mensagem " OF oDlg COLOR 0, 16777215 PIXEL	   
		@ 203, 020 GET   oMultiGe1 VAR _cTextPad OF oDlg MULTILINE SIZE 390, 060 COLORS 0, 16777215 HSCROLL PIXEL

		DEFINE SBUTTON oSButton2 FROM 275, 330 TYPE 01 OF oDlg ENABLE  ACTION Eval(bOk    )
		DEFINE SBUTTON oSButton3 FROM 275, 360 TYPE 02 OF oDlg ENABLE ACTION Eval(bCancel)
	ACTIVATE MSDIALOG oDlg CENTERED
return
/*/{Protheus.doc} RotEnvMail
@description Rotina para procesamento do envio de e-mail (função chamada pela rotina 'RTMKR007').
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
	local _cMailUsr  := UsrRetMail(RetCodUsr())		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do while para melhoria de perfomance, evitando assim que, no meio do loop, o sistema não tenha de ficar consultando o conteúdo do parâmetro.
	local _lRCFGM001 := ExistBlock("RCFGM001")		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do while para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o P.E. existe ou não (várias vezes).
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
		/*if  !"**Inclua aqui seu Texto**"$_cTextPad 
			if !Empty(_cTextPad) .AND. "/" $ _cTextPad
				_aTextPad := StrTokArr(_cTextPad,"/")
				for ncont := 1 to Len(_aTextPad)	
					_cMsgFim += "<BR><hr size=2 width='100%' align=center>" +  _aTextPad[ncont] +_lEnd
				next
			else
				_cMsgFim := _cTextPad
			endif		
		endif*/
	endif
	if !empty(_cAnexo1)
		_cMsgFim += '<img src="' + 'cid:ID_' + _cAnexo1 + '" alt="Aviso Importante!" title="AVISO IMPORTANTE"/>'
	endif
	if !lPerg
		ValidPerg(substring(nComb1,1,1))
		Pergunte(cPerg+substring(nComb1,1,1),.T.)
	endif
	if _lRCFGM001 .AND. _nOpc == 3 //se for teste envia para o usuario logado //senao envia para range de 
		_cMail   :=  UsrRetMail(RetCodUsr())  
		U_RCFGM001(Titulo,_cMsgFim,_cMail,_cAnexo1 +";"+_cAnexo2 ,_cMailFrom,"",cGet5,.F.,.f.)
		MsgInfo("E-mail teste enviado para o endereço: " +_cMail ,_cRotina+"_004")
	else
		if substr(nComb1,1,1) == "1" 
			BeginSql Alias _cAlias
				SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_EMAIL, A1_NOME
				FROM %table:SA1% SA1 (NOLOCK)
				WHERE SA1.A1_FILIAL     = %xFilial:SA1%
				  AND SA1.A1_MSBLQL     = %Exp:'2'%
				  AND LEN(LTRIM(RTRIM(SA1.A1_EMAIL))) > %Exp:3%
				  AND SA1.A1_COD  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05%
				  AND SA1.A1_LOJA BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR06%
				  AND SA1.A1_VEND BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				  AND SA1.A1_CGC IN ('44916197000189','10285316000120','05344805000176','10350189000104','09885369000101','11301194000181','21613636000189',
									'21132129000123','07703338000159','32113075000175','41030289000179','27025343000167','29710113000162','14531828000180',
									'32136235000100','10358117000103','04362003000126','00315314000426','00315314000507','14995886000165','08996297000107',
									'06005081000107','23311351000119','43411126000161','05163127000145','39606270000186','28693649000154','03162569000141',
									'07096180000104','70188966000180','31114545000152','07597287000128','33131438000168','08624989000116','18075730000117',
									'04105465000168','29034991000105','03732160000202','47621572000151','03007360000103','14166061000138','03095827000203',
									'09510036000190','20274194000120','14796895000127','19084576000102','04951738000195','20422277000110','24794435000113',
									'29052084000199','04218524000104','41065491000136','22526554000160','03086302000112','09347995000136','24070518000160',
									'26404510000118','11229342000102','02864000000165','25020960000144','23239933000131','10923900000164','40866254000101',
									'33814144000130','10497345000156','21745622000119','11247751000123','31152092000159','02751896000176','23605486000197',
									'40538165000136','15916066000101','16830738000116','29907113000157','04481850000100','33013586000188','05292012000150',
									'01813841000180','12417363000106','17079953000190','08734249000132','10473963000328','20789915000135','22275703000165',
									'03909100000123','11173744000124','39392452000100','00914285000176','08911961000160','07990101000104','07901660000192',
									'20988384000100','00130978000178','20997304000182','40838088000130','12637426000130','06048822000129','25935231000118',
									'47585809000196','07621036000131','10681932000109','19425120000169','14028128000178','14028128000259','69947224000101',
									'11792458000147','11540327000172','13552234000193','08316449000175','41058504000140','16722325000118','10426436000109',
									'04545677000166','02313380000140','50087962000106','11400020000176','11400020000338','27909305000177','08584745000157',
									'08741723000153','10302738000167','52444559000104','12815437000162','01856942000139','25079673000100','38015891000122',
									'26775300000136','07147609000137','24407389000152','08474565000112','25965923000109','28591632000196','24761133000149',
									'08033958000190','20687643000162','11306812000186','07554790000104','05970259000189','18702187000130','26205197000199',
									'40870891000151','28839316000190','11172464000100','08936606000145','43673068000144','01501601000140','05903086000186',
									'05903086000429','40834939000176','12010179000147','09542770000130','16526504000180','18642395000191','33762567000154',
									'43943600000104','26656094000145','24382905000131','27930381000164','37267268000102','08052860000180','02349328000143',
									'06191994000157','29279992000110','08792445000163','27896202000110','41017963000185','24856537000116','27839886000118',
									'30484025000179','11357765000108','28118502000130','16577885000126','21947143000185','18318771000197','08658880000108',
									'15260223000165','31033966000159','09028567000140','24599262000182','17578643000110','03996024000130','08822678000161',
									'27376196000170','11681244000101','13476112000165','38416360000141','27006407000182','12286800000108','18517750000109',
									'15150911000172','08515435000180','17000476000125','12041387000103','06080324000325','06080324000163','06080324000244',
									'14284146000110','28041255000111','08111354000115','08181653000126','21641481000194','09566316000110','20706483000151',
									'18373695000112','02098360000101')
				  AND SA1.%NotDel%
				ORDER BY A1_FILIAL, A1_COD, A1_LOJA
			EndSql
			dbSelectArea(_cAlias)
			ProcRegua((_cAlias)->(RecCount()))
			(_cAlias)->(dbGoTop())
			if !(_cAlias)->(EOF()) //.AND. !lEnd
				while !(_cAlias)->(EOF()) //.AND. !lEnd
					IncProc()
					_cMail    := (_cAlias)->A1_EMAIL //_cMailUsr			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: UsrRetMail(RetCodUsr())
					_cLastMsg := iif("Sem Tratamento"$nCombo,"Prezado(a) " ,nCombo) + "  "+(_cAlias)->A1_NOME  + _lEnd
					if _lRCFGM001 .AND. U_RCFGM001(Titulo,_cLastMsg+ _lEnd+_cMsgFim,_cMail,;
					iif(len(_cAnexo1)>1,_cAnexo1,"") +";"+iif(len(_cAnexo2)>1,_cAnexo2,"") ,_cMailFrom,"",cGet5,.F.,.f.)
						_cLogOK   += (_cAlias)->A1_COD+(_cAlias)->A1_LOJA+" - "+(_cAlias)->A1_NOME  + _lEnd
						_nLogOK++
					Else
						_cLogErro += (_cAlias)->A1_COD+(_cAlias)->A1_LOJA+" - "+(_cAlias)->A1_NOME  + _lEnd
						_nLogErro++
					endif
					dbSelectArea(_cAlias)
					(_cAlias)->(dbSkip())
				enddo
			Else
				_cLogErro += "Nada a Processar!"
				_nLogErro++
				MsgAlert(_cLogErro,_cRotina+"_006")
			endif
			dbSelectArea(_cAlias)
			(_cAlias)->(dbCloseArea())
		elseif substr(nComb1,1,1) == "2"
			BeginSql Alias _cAlias
				SELECT A2_FILIAL, A2_COD, A2_LOJA, A2_NOME
				FROM %table:SA2% SA2 (NOLOCK)
				WHERE SA2.A2_FILIAL     = %xFilial:SA2%
				  AND SA2.A2_MSBLQL     = %Exp:'2'%
				  AND LEN(LTRIM(RTRIM(SA2.A2_EMAIL))) > %Exp:3%
				  AND SA2.A2_COD  BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR03%
				  AND SA2.A2_LOJA BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR04%
				  AND SA2.%NotDel%
				ORDER BY A2_FILIAL, A2_COD, A2_LOJA
			EndSql
			dbSelectArea(_cAlias)
			ProcRegua((_cAlias)->(RecCount()))
			(_cAlias)->(dbGoTop())
			if !(_cAlias)->(EOF()) //.AND. !lEnd
				while !(_cAlias)->(EOF()) //.AND. !lEnd
					IncProc()
					_cMail    := _cMailUsr			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: UsrRetMail(RetCodUsr())
					_cLastMsg := iif( "Sem Tratamento"$nCombo,"Prezado(a) " ,nCombo) + "  "+(_cAlias)->A2_NOME  + _lEnd			
					if _lRCFGM001 .AND. U_RCFGM001(Titulo,_cLastMsg + _lEnd+_cMsgFim,_cMail,iif(len(_cAnexo1)>1,_cAnexo1,"") +";"+iif(len(_cAnexo2)>1,_cAnexo2,"") ,_cMailFrom,"",cGet5,.F.,.f.)
						_cLogOK   += (_cAlias)->A2_COD+(_cAlias)->A2_LOJA+" - "+(_cAlias)->A2_NOME  + _lEnd
						_nLogOK++
					Else
						_cLogErro += (_cAlias)->A2_COD+(_cAlias)->A2_LOJA+" - "+(_cAlias)->A2_NOME  + _lEnd
						_nLogErro++
					endif
					dbSelectArea(_cAlias)
					(_cAlias)->(dbSkip())
				enddo
			else
				_cLogErro += "Nada a Processar!"
				_nLogErro++
				MsgAlert(_cLogErro,_cRotina+"_007")
			endif
			dbSelectArea(_cAlias)
			(_cAlias)->(dbCloseArea())
		else
			BeginSql Alias _cAlias
				SELECT A3_FILIAL, A3_COD, A3_LOJA, A3_NOME
				FROM %table:SA3% SA3 (NOLOCK)
				WHERE SA3.A3_FILIAL     = %xFilial:SA3%
				  AND SA3.A3_MSBLQL     = %Exp:'2'%
				  AND LEN(LTRIM(RTRIM(SA3.A3_EMAIL))) > %Exp:3%
				  AND SA3.A3_COD  BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				  AND SA3.%NotDel%
				ORDER BY A3_FILIAL, A3_COD, A3_LOJA
			EndSql
			dbSelectArea(_cAlias)
			ProcRegua((_cAlias)->(RecCount()))
			(_cAlias)->(dbGoTop())
			if !(_cAlias)->(EOF()) //.AND. !lEnd
				while !(_cAlias)->(EOF()) //.AND. !lEnd
					IncProc()
					_cMail    := _cMailUsr			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: UsrRetMail(RetCodUsr())
					_cLastMsg := iif( "Sem Tratamento"$nCombo,"Prezado(a) " ,nCombo) + "  "+(_cAlias)->A3_NOME  + _lEnd			
					if _lRCFGM001 .AND. U_RCFGM001(Titulo,	_cLastMsg  + _lEnd +  _cMsgFIM   ,_cMail,_iif(len(_cAnexo1)>1,_cAnexo1,"") +";"+iif(len(_cAnexo2)>1,_cAnexo2,""),_cMailFrom,"",cGet5,.F.,.f.)
						_cLogOK   += (_cAlias)->A3_COD+(_cAlias)->A3_LOJA+" - "+(_cAlias)->A3_NOME  + _lEnd
						_nLogOK++
					Else
						_cLogErro += (_cAlias)->A3_COD+(_cAlias)->A3_LOJA+" - "+(_cAlias)->A3_NOME  + _lEnd
						_nLogErro++
					endif
					dbSelectArea(_cAlias)
					(_cAlias)->(dbSkip())
				enddo
			else
				_cLogErro += "Nada a Processar!"
				_nLogErro++
				MsgAlert(_cLogErro,_cRotina+"_008")
			endif
			dbSelectArea(_cAlias)
			(_cAlias)->(dbCloseArea())
		endif
		 _cAnexo1  := ""
		 _cAnexo2  := ""
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
