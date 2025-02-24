#include 'totvs.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'apwebsrv.ch'
#include 'restful.ch'
#include 'xmlxfun.ch'
#include 'tbiconn.ch'
#include 'fileio.ch'
#include 'ap5mail.ch'
#define _CLRF CHR(13)+CHR(10)
/*/{Protheus.doc} RFINW004
@description Rotina executada via job, para atualização automática das moedas nas tabelas 'SM2' e 'CTP', conforme o webservices do Portal Brasileiro de Dados Abertos (http://dados.gov.br/dataset/).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 29/10/2019
@version P12.1.25 - 001
@type function
@see https://allss.com.br
/*/
user function RFINW004()
	local   _lProc    := type("cFilAnt")=="U"
	private _cRotina  := "RFINW004"
	private cCadastro := OemToAnsi("Atualização das Moedas")
	private _cEmp     := ""
	private _cFil     := ""
	private _cSeqPar  := "2"
	private _bSIMBCB  := "SuperGetMv('MV_SIMBCB'+_cSeqPar,,nil)"
	private _cIdLog   := _cRotina+"_"+DTOS(Date())+"_"+StrTran(Time(),":","")
	private _nSeqJob  := 0
	private _nStart   := Seconds()

	FwLogMsg("DEBUG", _cIdLog, _cRotina, _cRotina, "001", "001", "Iniciando a rotina...", 0, (Seconds()-_nStart), {})
	FwLogMsg("DEBUG", _cIdLog, _cRotina, _cRotina, "002", "002", "Verificando parametros iniciais...", 0, (Seconds()-_nStart), {})
	if _lProc
		while _lProc
			_nSeqJob++
			FwLogMsg("DEBUG", _cIdLog, _cRotina, _cRotina, "003", "003", "Verificando existencia do JOB '"+(_cRotina+"_"+StrZero(_nSeqJob,3))+"'...", 0, (Seconds()-_nStart), {})
			_cFil         := ""
			_cEmp         := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"EMPRESA"    ,"",GetAdv97())
			if !empty(_cEmp)
				_cFil     := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"FILIAL"     ,"",GetAdv97())
				_lProc    := .T.
				FwLogMsg("DEBUG", _cIdLog, _cRotina, _cRotina, "004", "004", "Os processos serao executados considerando as seguintes configuracoes do server job '"+(_cRotina+"_"+StrZero(_nSeqJob,3))+"':"+_CLRF+"Empresa/Filial: "+_cEmp+"/"+_cFil+Replicate("*",15), 0, (Seconds()-_nStart), {})
				if AbreAmb(_cEmp,_cFil)
					_cSeqPar := "2"
					ImpMJob(.T.,.F.)
					RESET ENVIRONMENT
				else
					FwLogMsg("ERROR", _cIdLog, _cRotina, _cRotina, "005", "005", "Não foi possível abrir a Empresa/Filial: "+_cEmp+"/"+_cFil+". Processamento abortado!", 0, (Seconds()-_nStart), {})
					_lProc := .F.
				endif
			else
				FwLogMsg("ERROR", _cIdLog, _cRotina, _cRotina, "006", "006", "JOB '"+(_cRotina+"_"+StrZero(_nSeqJob,3))+"' nao existe ou foi configurado incorretamente. Processamento abortado (para este server job)!!!", 0, (Seconds()-_nStart), {})
				_lProc := .F.
			endif
		enddo
	else
		_cEmp     := SubStr(cNumEmp,1,2)
		_cFil     := SubStr(cNumEmp,3,2)
		FwLogMsg("INFO", _cIdLog, _cRotina, _cRotina, "007", "007", "Execução manual na Empresa/Filial "+_cEmp+"/"+_cFil+_CLRF+Replicate("*",15), 0, (Seconds()-_nStart), {})
		ImpMan()
	endif
	FwLogMsg("INFO", _cIdLog, _cRotina, _cRotina, "008", "008", "Processamento concluído!!!", 0, (Seconds()-_nStart), {})
return
/*/{Protheus.doc} AbreAmb (RFINW004)
@description Sub-rotina para a abertura do ambiente no Protheus.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 29/10/2019
@version P12.1.25 - 001
@type function

@param _cEmp, caracter, Código da Empresa a ser acessada.
@param _cFil, caracter, Código da Filial a ser acessada.

@return _lRet, lógico, Informa se houve sucesso no acesso do ambiente para a realização das operações.

@see https://allss.com.br
/*/
static function AbreAmb(_cEmp,_cFil)
	local   _lRet := .T.
	default _cEmp := "01"
	default _cFil := "01"
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil FUNNAME _cRotina TABLES "SM2","CTP"
	_lRet := type("cFilAnt")<>"U"
return _lRet
/*/{Protheus.doc} ImpMan (RFINW004)
@description Sub-rotina de interface com o usuário para o cadastro das moedas, quando a rotina for chamada via menu.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 29/10/2019
@version P12.1.25 - 001
@type function
@see https://allss.com.br
/*/
static function ImpMan()
	local aSays			:= {}
	local aButtons		:= {}
	local nOpcA			:= 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera interface com o usuário                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	/*aAdd(aSays,OemToAnsi("Esta rotina tem como objetivo importar as moedas do Banco Central do Brasil."  ))
	aAdd(aSays,OemToAnsi(""																		   		 ))
	aAdd(aSays,OemToAnsi(""																				 )) 
	aAdd(aSays,OemToAnsi(""																				 ))
	aAdd(aSays,OemToAnsi(""																				 ))
	aAdd(aButtons, { 1,.T.						,{|o| (nOpca := 1,o:oWnd:End())   						 }})
	aAdd(aButtons, { 2,.T.						,{|o| (nOpca := 0,o:oWnd:End())							 }})
	FormBatch( cCadastro, aSays, aButtons )
	if nOpcA == 1
		Processa({|lEnd| ImpMJob(.F.,@lEnd)},"["+_cRotina+"] "+cCadastro,"Atualizando moedas...",.F.)
	endif*/
	
	 ImpMJob(.F.,@lEnd)
return
/*/{Protheus.doc} AbreAmb (RFINW004)
@description Sub-rotina de consumo do webservices público para a obtenção das taxas das moedas previstas nos parâmetros iniciados por 'MV_SIMBCB?'.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 29/10/2019
@version P12.1.25 - 001
@type function
@param lJob, lógico, Informa se a rotina foi ou não chamada via JOB.
@param lEnd, lógico, Informa se a rotina foi encerrada manualmente ou não (conteúdo conforme ação do usuário no fluxo do processamento, quando for o caso).
@see https://allss.com.br
/*/
static function ImpMJob(lJob,lEnd)
	local   _cMsg         := ""
	local   _cMsgMail     := ""
	local   _cParFix      := ""
	local   _cHeaderRet   := ""
	local   _cHttpRet     := ""
	local   _cUrlRaiz     := AllTrim(SuperGetMv("MV_URLBCBE",,"https://olinda.bcb.gov.br"))		//URL EndPoint
	local   _cUrlPath     := AllTrim(SuperGetMv("MV_URLBCBR",,"/olinda/servico/PTAX/versao/v1/odata/CotacaoMoedaDia(moeda=@moeda,dataCotacao=@dataCotacao)"))	//Continuação da URL, onde encontram-se os recursos a serem pesquisados.
	local   _cMail        := AllTrim(SuperGetMv("MV_MAILMOE",,nil))
	local   _cData        := ""
	local   _dData        := DataValida(dDataBase,.F.)
	local   _aHeader      := {}
	local   aMoedas       := {}
	local   aMoedasRef    := {}
	local   aMoedasTmp    := {}
	local   _nTimeOut     := 120
	local   nX            := 0
	local   _nReg         := 0
	local   _nLimite      := 15
	local   _nCont        := 0
	local   _lAchou       := .F.
	local   _lPaliat      := .T.						//******CAMINHO PALIATIVO PARA A ROTINA********
	local   _oMoedas      := FWRest():New(_cUrlRaiz)
	local   _oJson        := nil

	FwLogMsg("DEBUG", _cIdLog, _cRotina, _cRotina, "009", "009", "***************** "+_cRotina+" - MOEDAS (INICIO) *********************", 0, (Seconds()-_nStart), {})
	AADD(_aHeader,"Content-Type: application/json")
	AADD(_aHeader,"encoding: UTF-8")
	//AADD(_aHeader,"$format: json")
	//AADD(_aHeader,"$filter: tipoBoletim eq 'Fechamento PTAX'")
	//Informações dinâmicas
	//AADD(_aHeader,"")		//Moeda
	//AADD(_aHeader,"")		//Data da Cotação
	_cParFix := "$format=json"
	_cParFix += "&$filter=tipoBoletim eq 'Fechamento PTAX'"		//A expressão "eq" indica "Igual a" (vide documentação em 'https://olinda.bcb.gov.br/olinda/servico/ajuda')
//	//_cParFix += "&$select=cotacaoCompra"
	_cSeqPar := "2"
//	while &("valtype("+_bSIMBCB+")") == "C" .and. 
		_oJson  := nil
		_dData  := DataValida(dDataBase,.F.)
		_cData  := DTOS(_dData)
		_cData  := SubStr(_cData,5,2)+"-"+SubStr(_cData,7,2)+"-"+SubStr(_cData,1,4)		//Formato: MM-DD-AAAA
		_lAchou := .F.
		_cCont  := 0
		if _lPaliat
			_cUrlRaiz := "https://www4.bcb.gov.br/Download/fechamento/"
			_cUrlPath := ""
			while !_lAchou .AND. _nLimite > _nCont
				_cUrlPath   := DTOS(_dData)+".csv"
				_cHttpRet   := HttpGet(_cUrlRaiz+_cUrlPath,"",_nTimeOut,_aHeader,@_cHeaderRet)
				if (_lAchou := "200 OK"$_cHeaderRet)
					Exit
				endif
				_dData  := DataValida(_dData-1,.F.)
				_cData  := DTOS(_dData)
				_cData  := SubStr(_cData,5,2)+"-"+SubStr(_cData,7,2)+"-"+SubStr(_cData,1,4)		//Formato: MM-DD-AAAA
				_nCont++
			enddo
			if _lAchou .AND. !empty(_cHttpRet)
				_cHttpRet  := StrTran(_cHttpRet,",",".")
				aMoedasRef := StrToArray(_cHttpRet, _CLRF)
				_nCont:= 0
				while &("valtype("+_bSIMBCB+")") == "C" .And. _nCont<6
					if ";"+&(_bSIMBCB)+";" $ _cHttpRet
						aMoedasTmp := Separa(aMoedasRef[aScan(aMoedasRef,{|x| ";"+&(_bSIMBCB)+";" $ x})],";")
						AADD(aMoedas,{	_cSeqPar,;										//01 - Sequencia da Moeda
										aMoedasTmp[4],;									//02 - Símbolo da moeda
										aMoedasTmp[1],;									//03 - Data da Cotação
										DataValida(CTOD(aMoedasTmp[1])+1,.T.),;			//04 - Data do Cadastro no Protheus
										0,;												//05 - Paridade da Compra da Moeda
										0,;												//06 - Paridade da Venda da Moeda
										val(aMoedasTmp[5]),;							//07 - Cotação de Compra da Moeda
										val(aMoedasTmp[6]),;							//08 - Cotação de Venda da Moeda
										"Fechamento" })									//09 - Tipo do Boletim
					endif
					_cSeqPar := Soma1(_cSeqPar,1,.F.,.F.)
					_nCont++
				enddo
			else
				//Não encontrou nada
			endif
		else
			while !_lAchou .AND. _nLimite > _nCont
				//_aHeader[len(_aHeader)-1] := "@moeda: '"+AllTrim(&(_bSIMBCB))+"'"
				//_aHeader[len(_aHeader)-0] := "@dataCotacao: '"+_cData+"'"
				_oMoedas:setPath(_cUrlPath+"?"+_cParFix+"&@moeda='"+AllTrim(&(_bSIMBCB))+"'&@dataCotacao='"+_cData+"'")
				//_oMoedas:setPath(_cUrlPath)
				if (_lAchou := _oMoedas:GET(_aHeader))
					exit
				else
					_oMoedas:GetLastError()
				endif
				_dData  := DataValida(_dData-1,.F.)
				_cData  := DTOS(_dData)
				_cData  := SubStr(_cData,5,2)+"-"+SubStr(_cData,7,2)+"-"+SubStr(_cData,1,4)		//Formato: MM-DD-AAAA
				_nCont++
			enddo
			if _lAchou
				FWJsonDeserialize(_oMoedas:GetResult(),@_oJson)
				if _oJson == nil .OR. valtype(_oJson:VALUE) <> "A" .OR. len(_oJson:VALUE) == 0
					//Json retornou sem conteúdo
				else
					//Pego sempre o último elemento do array obtido no JSON
					_nReg := len(_oJson:VALUE)
					AADD(aMoedas,{	_cSeqPar,;												//01 - Sequencia da Moeda
									&(_bSIMBCB),;											//02 - Símbolo da moeda
									_oJson:VALUE[_nReg]:dataHoraCotacao,;					//03 - Data da Cotação
									DataValida(_oJson:VALUE[_nReg]:dataHoraCotacao+1,.T.),;	//04 - Data do Cadastro no Protheus
									_oJson:VALUE[_nReg]:paridadeCompra,;					//05 - Paridade da Compra da Moeda
									_oJson:VALUE[_nReg]:paridadeVenda,;						//06 - Paridade da Venda da Moeda
									_oJson:VALUE[_nReg]:cotacaoCompra,;						//07 - Cotação de Compra da Moeda
									_oJson:VALUE[_nReg]:cotacaoVenda,;						//08 - Cotação de Venda da Moeda
									_oJson:VALUE[_nReg]:tipoBoletim })						//09 - Tipo do Boletim
				endif
			else
				//Não encontrei nenhuma moeda nos dias definidos
			endif
		endif
	//	_cSeqPar := Soma1(_cSeqPar,1,.F.,.F.)
	//enddo
	if _lAchou .AND. Len(aMoedas) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a gravacao na tabela de moedas                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cMsgMail := ""
		_cMsgMail += '<b><font size="3" face="Arial">E-mail enviado atrav&eacute;s do Protheus</font></b><br></BR>' + _CLRF
		_cMsgMail += '<font size="2" face="Arial">As taxas de moedas foram atualizadas no ERP Protheus.</font><p>&nbsp;</P>' + _CLRF
		_cMsgMail += '<table border="0" width="100%" bgcolor="#FFFFFF">' + _CLRF
		_cMsgMail += '<tr>' + _CLRF
		_cMsgMail += '   <td width="30%"><font size="3" face="Arial"><b>MOEDA       </b></font></td>' + _CLRF
		_cMsgMail += '   <td width="30%"><font size="3" face="Arial"><b>TAXA        </b></font></td>' + _CLRF
		_cMsgMail += '   <td width="20%"><font size="3" face="Arial"><b>DATA        </b></font></td>' + _CLRF
		_cMsgMail += '   <td width="20%"><font size="3" face="Arial"><b>CADASTRO    </b></font></td>' + _CLRF
		_cMsgMail += '</tr>' + _CLRF
		for nX := 1 to len(aMoedas)
			//aMoedas[nX][01]		//Sequencia da moeda
			//aMoedas[nX][02]		//Símbolo da moeda
			//aMoedas[nX][03]		//Data da Cotação
			//aMoedas[nX][04]		//Data do Cadastro no Protheus
			//aMoedas[nX][05]		//Paridade da Compra da Moeda
			//aMoedas[nX][06]		//Paridade da Venda da Moeda
			//aMoedas[nX][07]		//Cotação de Compra da Moeda
			//aMoedas[nX][08]		//Cotação de Venda da Moeda
			//aMoedas[nX][09]		//Tipo do Boletim
			if SM2->(FieldPos("M2_MOEDA"+AllTrim(aMoedas[nX][01]))) > 0
				cMsgx   := 	" MOEDA "+AllTrim(aMoedas[nX][01])+" - "+AllTrim(aMoedas[nX][02])+;
							" - TAXA "+Transform(aMoedas[nX][07],PesqPict("SM2","M2_MOEDA"+AllTrim(aMoedas[nX][01])))
				dbSelectArea("SM2")
				SM2->(dbSetOrder(1))
				lGrava := !SM2->(dbSeek(dtos(aMoedas[nX][04])))
				while !RecLock("SM2",lGrava) ; enddo
					SM2->M2_DATA                                := aMoedas[nX][04]
					&("SM2->M2_MOEDA"+AllTrim(aMoedas[nX][01])) := aMoedas[nX][07]
					SM2->M2_INFORM                              := "S"
				SM2->(MsUnLock())
			endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua a gravacao na tabela de cambio                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("CTP")   
			CTP->(dbSetOrder(1))
			lGrava := !CTP->(dbSeek(xFilial("CTP")+dtos(aMoedas[nX][04])+PadL(AllTrim(aMoedas[nX][01]),Len(CTP->CTP_MOEDA), "0") ))
			while !RecLock("CTP",lGrava) ; enddo
				CTP->CTP_FILIAL	:= xFilial("CTP")
				CTP->CTP_DATA	:= aMoedas[nX][04]
				CTP->CTP_MOEDA	:= PadL(AllTrim(aMoedas[nX][01]),Len(CTP->CTP_MOEDA), "0")
				CTP->CTP_BLOQ	:= "2"
				CTP->CTP_TAXA	:= aMoedas[nX][07]
			CTP->(MsUnLock())
			FwLogMsg("DEBUG", _cIdLog, _cRotina, _cRotina, "010", "010", cMsgx, 0, (Seconds()-_nStart), {})
			if !lJob
				_cMsg += cMsgx+_CLRF
			endif
			_cMsgMail += '<tr>' + _CLRF
			_cMsgMail += '   <td width="30%"><font size="2" face="Arial">'                    + AllTrim(aMoedas[nX][01])+" - "+AllTrim(aMoedas[nX][02])  + '</font></td>' + _CLRF
			_cMsgMail += '   <td width="30%"><font size="3" Color="#0000FF" face="Arial"><b>' + Transform(aMoedas[nX][07],PesqPict("SM2","M2_MOEDA"+AllTrim(aMoedas[nX][01]))) + '</b></font></td>' + _CLRF
			_cMsgMail += '   <td width="20%"><font size="2" face="Arial">'                    + aMoedas[nX][03]                                          + '</font></td>' + _CLRF
			_cMsgMail += '   <td width="20%"><font size="2" face="Arial">'                    + DTOC(aMoedas[nX][04])                                    + '</font></td>' + _CLRF
			_cMsgMail += '</tr>' + _CLRF
		next
		//Fecha Tabela
		_cMsgMail += '</table>' + _CLRF
		_cMsgMail += '<br><p>Fonte: '+_cUrlRaiz+_cUrlPath+'     - obtido em '+dtoc(date())+' as '+Time()+', automaticamente.</p>' + _CLRF
		_cMsgMail += '<br><br><p><i>OBS.: E-mail enviado automaticamente pelo sistema. Por favor não responda!</i></p>' + _CLRF
		_cMsgMail += '<br><br><br><p align="center"><a href="https://allss.com.br"><img style="border: none; width: 80px; max-width: 80px !important; height: 150px; max-height: 50px !important;" src="https://allss.com.br/allssmail.jpg" alt="ALL System Solutions"/></a><br><a href="https://allss.com.br"><i><font face="Arial" size=1 color="#808080">Powered by ALLSS Soluções em Sistemas.</font></i></a></p><br>' + _CLRF
		if ExistBlock("RCFGM001")
			MemoWrite("\2.Memowrite\"+_cRotina+"_moedas.txt",_cMsgMail)
			U_RCFGM001(	cCadastro /*_cTitulo*/,;
						NoAcento(_cMsgMail) /*_cMsg*/,;
						_cMail,;
						/*_cAnexo*/,;
						/*_cFromOri*/,;
						/*_cBCC*/,;
						"Atualização Automática - Taxas de Moedas (versão 004)" /*_cAssunto*/,;
						.F. /*_lExcAnex*/,;
						!lJob /*_lAlert*/ )
		endif
	endif
	FwLogMsg("DEBUG", _cIdLog, _cRotina, _cRotina, "011", "011", "***************** "+_cRotina+" - MOEDAS (FIM) *********************", 0, (Seconds()-_nStart), {})
return nil
/*/{Protheus.doc} NoAcento (RFINW004)
@description Sub-rotina de retirada dos acentos para o envio da mensagem de cadastro das moedas por e-mail.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 29/10/2019
@version P12.1.25 - 001
@type function
@param cString, caracter, Texto a ser convertido.
@return cString, caracter, Texto convertido pela sub-função.
@see https://allss.com.br
/*/
static function NoAcento(cString)
	local cChar  := ""
	local nX     := 0 
	local nY     := 0
	local cVogal := "aeiouAEIOU"
	local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	local cTrema := "äëïöü"+"ÄËÏÖÜ"
	local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
	local cTio   := "ãõÃÕ"
	local cCecid := "çÇ"
	local cMaior := "&lt;"
	local cMenor := "&gt;"
	for nX:= 1 to len(cString)
		cChar:=SubStr(cString, nX, 1)
		if cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif
			nY:= At(cChar,cCircu)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif
			nY:= At(cChar,cTrema)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif
			nY:= At(cChar,cCrase)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			endif
			nY:= At(cChar,cTio)
			if nY > 0          
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			endif
			nY:= At(cChar,cCecid)
			if nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			endif
		endif
	next
	if cMaior$ cString 
		cString := strTran( cString, cMaior, "" ) 
	endif
	if cMenor$ cString 
		cString := strTran( cString, cMenor, "" )
	endif
	cString := StrTran( cString, CRLF, " " )
return cString