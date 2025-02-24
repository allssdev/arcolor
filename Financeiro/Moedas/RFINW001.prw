#include 'totvs.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'ap5mail.ch'

#define _CLRF CHR(13)+CHR(10)

/*/{Protheus.doc} RFINW001
@description Rotina executada via job, para atualização automática das moedas na SM2, conforme o Banco Central do Brasil
@author Anderson C. P. Coelho
@since 11/10/2017
@version P12.1.23 - 003
@type function

@history 27/08/2018, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Foi realizada uma alteração substancial, de maneira a não mais colher as taxas das moedas pela URL simples, mas através do consumo de WebServices.
@history 06/01/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Implementada a gravação das moedas na tabela SYE do SIGAEIC a pedido do SIGAEIC.
@history 11/05/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Implementado o cadastramento da moeda nos feriados e finais de semana, bem como efetuada a limpeza de trechos não utilizados.
@history 14/05/2020, Vinícius Lessa (ALLSS Soluções em Sistemas), Foi realizada uma melhoria no processo de definição dos destinatários para recebimento do e-mail de atualização.

@see https://allss.com.br
/*/

User Function RFINW001()
	Local   _lProc    := type("cFilAnt") == "U"
	Local   _nContJob := 0
	Local   _cSeqPar  := "2"
	Private _cRotina  := "RFINW001"
	Private cCadastro := OemToAnsi("Atualização das Moedas")
	Private _cEmp     := ""		//GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"EMPRESA"    ,"",GetAdv97())
	Private _cFil     := ""		//GetPvProfString(_cRotina,"FILIAL"     ,"01"           ,GetAdv97())
	Private _nSeqJob  := 0
	Private _nMaxMoed := 0
	If _lProc
		Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Início da Rotina via Schedule (Com ambiente preparado).")
		while _lProc
			_nSeqJob++
			_cFil         := ""
			_cEmp         := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"EMPRESA"    ,"",GetAdv97())
			If !Empty(_cEmp)
				_cFil     := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"FILIAL"     ,"",GetAdv97())
				_lProc    := .T.
				_nMaxMoed := 0
				_nContJob++
				If AbreAmb(_cEmp,_cFil)
					Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Ambiente preparado na empresa: "+cValTochar(_cEmp)+", Filial: "+cValTochar(_cEmp)+".")
					Private _cUrl     := AllTrim(SuperGetMv("MV_URLBCB",,"https://www4.bcb.gov.br/Download/fechamento/"))
					_cSeqPar := "2"
					while ValType(SuperGetMv("MV_SIMBCB"+_cSeqPar,,nil))=="C" .and. _cSeqPar < "6"
						Private &("nPosM" +_cSeqPar) := nil
						Private &("cMsg"  +_cSeqPar) := nil
						Private &("cMoeda"+_cSeqPar) := SuperGetMv("MV_SIMBCB"+_cSeqPar,,"")
						_cSeqPar      := Soma1(_cSeqPar,1,.F.,.F.)
						_nMaxMoed++
					enddo
					ImpMJob2(.T.,.F.)
					Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Resetando o ambiente.")
					RESET ENVIRONMENT
				Else
					_lProc := .F.
				EndIf
			Else
				_lProc := .F.
			EndIf
		enddo
	Else
		Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Início da Rotina via Schedule (Sem ambiente preparado).")
		_nMaxMoed := 0
		_cEmp     := SubStr(cNumEmp,1,2)
		_cFil     := SubStr(cNumEmp,3,2)
		_cSeqPar  := "2"
		while valtype(SuperGetMv("MV_SIMBCB"+_cSeqPar,,nil))=="C" .and. _cSeqPar < "6"
			Private &("nPosM" +_cSeqPar) := nil
			Private &("cMsg"  +_cSeqPar) := nil
			Private &("cMoeda"+_cSeqPar) := SuperGetMv("MV_SIMBCB"+_cSeqPar,,"")
			_cSeqPar := Soma1(_cSeqPar,1,.F.,.F.)
			_nMaxMoed++
		enddo
		_cUrl := AllTrim(SuperGetMv("MV_URLBCB",,"https://www4.bcb.gov.br/Download/fechamento/"))
		ImpMoedasMan()
	EndIf
	Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Fim do processamento da rotina...")
return
//Abre o ambiente
static function AbreAmb(_cEmp,_cFil)
	Local   _lRet := .T.
	default _cEmp := "01"
	default _cFil := "01"
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil FUNNAME _cRotina TABLES "SM2","CTP"
	_lRet := type("cFilAnt")<>"U"
return(_lRet)
// Função para Interface com Usuário
static function ImpMoedasman()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpcA			:= 1
	////////////////////////////////////////////////////////////////////////
	// Gera interface com o usuário                                        
	/////////////////////////////////////////////////////////////////////// 
	/* Desnecessário!!
	aAdd(aSays,OemToAnsi("Esta rotina tem como objetivo importar as moedas do Banco Central do Brasil."  ))
	aAdd(aSays,OemToAnsi(""																		   		 ))
	aAdd(aSays,OemToAnsi(""																				 )) 
	aAdd(aSays,OemToAnsi(""																				 ))
	aAdd(aSays,OemToAnsi(""																				 ))
	aAdd(aButtons, { 1,.T.						,{|o| (nOpca := 1,o:oWnd:End())   						 }})
	aAdd(aButtons, { 2,.T.						,{|o| (nOpca := 0,o:oWnd:End())							 }})
	FormBatch( cCadastro, aSays, aButtons )
	If nOpcA == 1
		Processa({|lEnd| ImpMJob2(.F.,@lEnd)},"["+_cRotina+"] "+cCadastro,"Atualizando moedas...",.F.)
	EndIf*/
	Processa({|lEnd| ImpMJob2(.F.,@lEnd)},"["+_cRotina+"] "+cCadastro,"Atualizando moedas...",.F.)
return
//27/08/2018 - Anderson Coelho - NOVA ROTINA, CONSUMINDO O WEBSERVICES. SUBSTITUI A Imp_old()
//vide códigos das moedas no comentário ao final deste PRW.
static function ImpMJob2(lJob,lEnd)
	local 	_cSeqPar      	:= 	"2"
	local 	_cMsg         	:= 	""
	local 	_cMsgMail     	:= 	""
	local 	aMoedas       	:= 	{}
	local 	aMoedasRef    	:= 	{}
	local 	nX            	:= 	0
	local 	lAchou        	:= 	.F.
	local 	cPara			:= 	""
	local 	_aDest			:= 	Separa(AllTrim(SuperGetMV("MV_MAILMOE",,"000000")),";",.F.) // SuperGetMv("MV_MAILMOE",,nil) + SuperGetMv("MV_MAILMO2",,nil)
	local	_nCount			:=	0
	local   _dDtGrv         := STOD("")
	Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Início do processamento da Static Function ImpMJob2.")
	while valtype(SuperGetMv("MV_CODBCB"+_cSeqPar,,nil))=="N" .and. _cSeqPar <= "5"
		if !empty(SuperGetMv("MV_CODBCB"+_cSeqPar,,nil))
			aMoedasRef := U_RFINW003(SuperGetMv("MV_CODBCB"+_cSeqPar,,nil))
			if !empty(aMoedasRef) //.AND. VAL(StrTran(StrTran(aMoedasRef:_RESPOSTA:_SERIE:_DATA:_ANO:TEXT,".",""),",",".")) > 0
				Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Colhendo valor da variável 'MV_CODBCB"+cValTochar(_cSeqPar)+"'.")
				lAchou := .T.
				AADD(aMoedas,{	stod(StrZero(VAL(aMoedasRef:_RESPOSTA:_SERIE:_DATA:_ANO:TEXT),4)+StrZero(VAL(aMoedasRef:_RESPOSTA:_SERIE:_DATA:_MES:TEXT),2)+StrZero(VAL(aMoedasRef:_RESPOSTA:_SERIE:_DATA:_DIA:TEXT),2)),;
								aMoedasRef:_RESPOSTA:_SERIE:_CODIGO:TEXT,;
								0,;
								AllTrim(aMoedasRef:_RESPOSTA:_SERIE:_CODIGO:TEXT)+" - "+StrTran(SubStr(AllTrim(aMoedasRef:_RESPOSTA:_SERIE:_NOME:TEXT),AT(" - ",AllTrim(aMoedasRef:_RESPOSTA:_SERIE:_NOME:TEXT))+3),"Livre - ","")/*SuperGetMv("MV_SIMBCB"+_cSeqPar,,"")*/,;
								VAL(StrTran(StrTran(aMoedasRef:_RESPOSTA:_SERIE:_VALOR:TEXT,".",""),",",".")),;
								0,;
								0,;
								0})
			elseif Empty(aMoedasRef)
									  //Se é JOB, Simbola da Moeda	   , Código da Moeda
				_aMoedRet := ImpMoeTwo(lJob		, &("cMoeda"+_cSeqPar) , SuperGetMv("MV_CODBCB"+_cSeqPar,,nil))
				AADD(aMoedas,{ 	_aMoedRet[1][1]	,;
							   	_aMoedRet[1][2]	,;
								_aMoedRet[1][3]	,;
								_aMoedRet[1][4]	,;
								_aMoedRet[1][5]	,;
								_aMoedRet[1][6]	,;
								_aMoedRet[1][7]	,;
								_aMoedRet[1][8]	})
			endif
		endif
		_cSeqPar       := Soma1(_cSeqPar,1,.F.,.F.)
	enddo
	if lAchou .AND. Len(aMoedas) > 0
		////////////////////////////////////////////////////////////////////////
		// Efetua a gravacao na tabela de moedas                               
		///////////////////////////////////////////////////////////////////////
		Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Início da montagem do HTML e gravação das moedas.")
		_cMsgMail := ""
		_cMsgMail += '<b><font size="3" face="Arial">E-mail enviado atrav&eacute;s do Protheus</font></b><br></BR>' + _CLRF
		_cMsgMail += '<font size="2" face="Arial">As taxas de moedas foram atualizadas no ERP Protheus.</font><p>&nbsp;</P>' //+ _CLRF
		_cMsgMail += '<table border="0" width="100%" bgcolor="#FFFFFF">' + _CLRF
		_cMsgMail += '<tr>' + _CLRF
		_cMsgMail += '   <td width="30%"><font size="3" face="Arial"><b>MOEDA       </b></font></td>'// + _CLRF
		_cMsgMail += '   <td width="30%"><font size="3" face="Arial"><b>TAXA        </b></font></td>'// + _CLRF
		_cMsgMail += '   <td width="20%"><font size="3" face="Arial"><b>DATA        </b></font></td>'// + _CLRF
		_cMsgMail += '   <td width="20%"><font size="3" face="Arial"><b>CADASTRO    </b></font></td>'// + _CLRF
		_cMsgMail += '</tr>' + _CLRF
		for nX := 1 to len(aMoedas)
			cMsgx   := 	" MOEDA "+cValToChar(nX+1)+" - "+AllTrim(aMoedas[nX][04])+;
						" - TAXA "+Transform(aMoedas[nX][05],PesqPict("SM2","M2_MOEDA"+cValToChar(nX)))
			if SM2->(FieldPos("M2_MOEDA"+cValToChar(nX+1))) > 0
				dbSelectArea("SM2")
				SM2->(dbSetOrder(1))
				_dDtGrv := aMoedas[nX][01]+1
				while DATAVALIDA(aMoedas[nX][01]+1,.T.) >= _dDtGrv
					lGrava  := !SM2->(dbSeek(dtos(_dDtGrv)))
					while !RecLock("SM2",lGrava) ; enddo
						Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - SM2, Gravando dados do campo 'M2_MOEDA"+cValToChar(nx+1)+"'.")
						SM2->M2_DATA	                    := _dDtGrv
						SM2->M2_INFORM                      := "S"
						&("SM2->M2_MOEDA"+cValToChar(nX+1)) := aMoedas[nX][05]
					SM2->(MsUnLock())
					_dDtGrv++
				enddo
			endif
			////////////////////////////////////////////////////////////////
			// Efetua a gravacao na tabela de cambio (CTP)				  //
			////////////////////////////////////////////////////////////////			
			dbSelectArea("CTP")   
			CTP->(dbSetOrder(1))    //CTP_FILIAL   + DTOS(CTP_DATA)                          + CTP_MOEDA
			_dDtGrv := aMoedas[nX][01]+1
			while DATAVALIDA(aMoedas[nX][01]+1,.T.) >= _dDtGrv
				lGrava := !CTP->(dbSeek(xFilial("CTP") + dtos(_dDtGrv) + PadL(cValToChar(nX+1),Len(CTP->CTP_MOEDA), "0")))
				while !RecLock("CTP",lGrava) ; enddo
					CTP->CTP_FILIAL	:= xFilial("CTP")
					CTP->CTP_DATA	:= _dDtGrv
					CTP->CTP_MOEDA	:= PadL(cValToChar(nX+1),Len(CTP->CTP_MOEDA), "0")
					CTP->CTP_BLOQ	:= "2" 
					CTP->CTP_TAXA	:= aMoedas[nX][05]
				CTP->(MsUnLock())
				_dDtGrv++
			enddo

			////////////////////////////////////////////////////////////////
			//Efetua a gravacao na tabela de cambio na tabela SYE do EIC  //
			////////////////////////////////////////////////////////////////
/*			dbSelectArea("SYE")
			//SYE->(dbSetOrder(1))
			//lGrava := SYE->(!dbSeek(xFilial("SYE")+dtos(_dData)+Padr(SuperGetMv("MV_SIMBCB"+_cSeqPar,,""),len(SYE->YE_MOEDA))))
			SYE->(dbOrderNickName("YEMOEFIN"))		
			// CASO ENCONTRE O REGISTRO NA TABELA, ELE ATUALIZA O MESMO (RECLOCK(VAR,.F.))
							 //YE_FILIAL    	   + DTOS(YE_DATA)							 + YE_MOE_FIN
			_dDtGrv := aMoedas[nX][01]+1
			while DATAVALIDA(aMoedas[nX][01]+1,.T.) >= _dDtGrv
				lGrava := !SYE->(dbSeek(xFilial("SYE") + dtos(_dDtGrv) + Padr(cValToChar(nX+1),len(SYE->YE_MOE_FIN))))
				while !RecLock("SYE",lGrava) ; enddo
					Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - SYE, Gravando dados da tabela SYE.")
					SYE->YE_FILIAL	:= xFilial("SYE")
					SYE->YE_DATA	:= _dDtGrv
					SYE->YE_MOEDA	:= Padr(SuperGetMv("MV_SIMBCB"+cValToChar(nX+1),,""),len(SYE->YE_MOEDA))
					SYE->YE_VLCON_C	:= aMoedas[nX][05]
					SYE->YE_VLFISCA	:= aMoedas[nX][05]
					SYE->YE_TX_COMP	:= aMoedas[nX][05]
					SYE->YE_MOE_FIN	:= cValToChar(nX+1)
				SYE->(MsUnLock())
				_dDtGrv++
			enddo */
			If !lJob
				_cMsg += cMsgx+_CLRF
			EndIf
			_dDtGrv := aMoedas[nX][01]+1
			while DATAVALIDA(aMoedas[nX][01]+1,.T.) >= _dDtGrv
				_cMsgMail += '<tr>' //+ _CLRF
				_cMsgMail += '   <td width="30%"><font size="2" face="Arial">'                    + AllTrim(AllTrim(aMoedas[nX][04]))                                    + '</font></td>' 		// + _CLRF
				_cMsgMail += '   <td width="30%"><font size="3" Color="#0000FF" face="Arial"><b>' + Transform(aMoedas[nX][05],PesqPict("SM2","M2_MOEDA"+cValToChar(nX))) + '</b></font></td>'	// + _CLRF
				_cMsgMail += '   <td width="20%"><font size="2" face="Arial">'                    + DTOC(aMoedas[nX][01])                                                + '</font></td>'		// + _CLRF
				_cMsgMail += '   <td width="20%"><font size="2" face="Arial">'                    + DTOC(_dDtGrv)                                                        + '</font></td>' 		// + _CLRF
				_cMsgMail += '</tr>' //+ _CLRF
				_dDtGrv++
			enddo
		next
		//Fecha Tabela
		_cMsgMail += '</table>'		
		_cMsgMail += "<br><br><p>Fonte: https://www3.bcb.gov.br/sgspub/JSP/sgsgeral/FachadaWSSGS.wsdl - obtido em " + dtoc(date()) + " as " + Time() + ", automaticamente.</p>"
		_cMsgMail += "<br><p><i>OBS.: E-mail enviado automaticamente pelo sistema. Por favor não responda!</i></p>"
		_cMsgMail += '<p align="center"><a href="https://allss.com.br"><img style="border: none; width: 80px; max-width: 80px !important; height: 150px; max-height: 50px !important;" src="https://allss.com.br/allssmail.jpg" alt="ALL System Solutions"/></a><br><a href="https://allss.com.br"><i><font face="Arial" size=1 color="#808080">Powered by ALLSS Soluções em Sistemas.</font></i></a></p>'
		// Define Destinatário
		if ValType(_aDest) == "A" .AND.Len(_aDest) > 0
			Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Definindo destinatário de envio.")
			For _nCount	:= 1 to Len(_aDest)
				// Se já NÃO estiver contido
				if (!AllTrim(Lower(UsrRetMail(_aDest[_nCount]))) $ cPara) .AND. (!AllTrim(_aDest[_nCount]) $ cPara)
					if !Empty(cPara)
						cPara	+=	";"
					endif					
					if "@" $ AllTrim(_aDest[_nCount])
						cPara	+=	AllTrim(Lower(_aDest[_nCount]))					// Caso seja um e-mail FIXO
					else
						if !Empty(AllTrim(Lower(UsrRetMail(_aDest[_nCount]))))
							cPara	+=	AllTrim(Lower(UsrRetMail(_aDest[_nCount])))	// Caso seja ID de usuário
						endif
					endif
				endif
			Next
		endif
		If ExistBlock("RCFGM001") .AND. !Empty(cPara)
			Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Chamando a rotina RCFGM001 para envio de e-mail aos destinatários: " + cValToChar(cPara))
			if U_RCFGM001(	cCadastro /*_cTitulo*/,;
						_cMsgMail /*_cMsg*/,;
						cPara /*_cMail*/,;
						/*_cAnexo*/,;
						/*_cFromOri*/,;
						/*_cBCC*/,;
						"Atualização Automática - Taxas de Moedas (versão 003)" /*_cAssunto*/,;
						.F. /*_lExcAnex*/,;
						!lJob /*_lAlert*/ )
				Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - E-mail enviado com sucesso para os destinatários: " + cValToChar(cPara))
			else
				Conout("["+_cRotina+"]"+DTOC(Date())+" - "+Time()+" - Falha no envio do E-mail!")
			endif
		EndIf
	EndIf
return nil

						 //Se é JOB	, Simbola da Moeda	, Código da Moeda
Static Function ImpMoeTwo( lJob		, _cSimbMoe			, _cCodMoe)
	Local _aMoeRst		:= {}
	Local _cSeqPar      := "2"
	Local _cMsg         := ""
	Local _cMsgMail     := ""
	Local cMoedas       := nil
	Local aMoedas       := {}
	Local aMoedasRef    := {}
	Local aMoedasAux    := {}
	Local nX            := 0
	Local _nDias        := 1
	Local lAchou        := .F.
	Private cHeaderGet  := ""
	
	_cUrl	:= "https://www4.bcb.gov.br/Download/fechamento/"
	
	// RELEASE 12.1.23
	Private _bSIMBCB := "valtype(SuperGetMv('MV_SIMBCB'+_cSeqPar,,nil))"
	
	// Pega as moedas do site do BACEN
	If !lAchou
		//Pega a planilha do dia útil anterior
		while !lAchou .AND. _nDias <= 30
			//		   HTTPSGet( < cURL >									, < cCertificate >	, < cPrivKey >		, < cPassword >	, [ cGETParms ]	, [ nTimeOut ]	, [ aHeadStr ]	, [ @cHeaderRet ], [ lClient ]  )
			cMoedas := HTTPSGet(_cUrl+AllTrim(dtos(date()-_nDias))+".csv"	, "\certs\000001_all.pem", "\certs\000001_key.pem", ""			, ""			, 120			, NIL		    , @cHeaderGet					)		//HttpGet(_cUrl+AllTrim(dtos(date()-_nDias))+".csv")
			lAchou  := stod(SubStr(cMoedas,7,4)+SubStr(cMoedas,4,2)+SubStr(cMoedas,1,2)) == date()-_nDias
			_nDias++
		enddo
	EndIf

	If lAchou .AND. !Empty(cMoedas)
		// Substitui as virgulas para convesao de string para valor
		cMoedas := StrTran(cMoedas,",",".")

		// Transforma em array retirando as quebras de linhas
		aMoedasRef := StrToArray(cMoedas, _CLRF) 
		If !lJob
			ProcRegua(Len(aMoedasRef))
		EndIf

		for nX := 1 to len(aMoedasRef)
			// Transforma o array em colunas
			aMoedasAux := StrToArray(aMoedasRef[nX],";")
			
			// Código Bacen
			if aMoedasAux[4] == _cSimbMoe
				// Gera o array colunado para trabalho
				aAdd(_aMoeRst,{	stod(SubStr(aMoedasAux[1],7,4)+SubStr(aMoedasAux[1],4,2)+SubStr(aMoedasAux[1],1,2)),;
							cValToChar(_cCodMoe)						,;
							0											,;
							cValToChar(_cCodMoe) + " - " + aMoedasAux[4],;
							Val(aMoedasAux[5])							,;
							0											,;
							0											,;
							0											})	
			endif
			If !lJob  
				IncProc("Em processamento, aguarde...")
			EndIf
			
			if len(_aMoeRst) > 0
				return _aMoeRst
			endif		
		next nX
	else
		nil
	endif

return _aMoeRst
