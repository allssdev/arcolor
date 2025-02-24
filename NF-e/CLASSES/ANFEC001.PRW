#include 'protheus.ch'
USER FUNCTION ANFEC001(); return //DUMMY //DUMMY
/*/{Protheus.doc} ANFEC001
    @description Classe utilizada para a importação de arquivos de CT-e.
    @author Anderson Coelho (ALLSS)
    @since 19/12/2019
    @version version
    @see https://allss.com.br
/*/
Class ANFEC001
	data   _nSeq     as numeric
	data   _nSeqJob  as numeric
	data   _nStart   as numeric
	data   _cRotina  as character

    Method NEW() CONSTRUCTOR
    Method ConsultarNFe()
    Method GerarXML()
    Method UltimoNSU()
    Method GetIdEnt()
EndClass
/*/{Protheus.doc} NEW
    @description Instanciamento inicial da classe.
    @author Anderson Coelho (ALLSS)
    @since 19/12/2019
    @version 1.0
    @see https://allss.com.br
/*/
Method NEW() class ANFEC001
	::_nSeq    := 1
	::_nSeqJob := 0
	::_nStart  := Seconds()
	::_cRotina := "ANFEC001"
return 
/*/{Protheus.doc} ConsultarNFe
    @description Metodo para realizar a consulta do NF-e
    @author Anderson Coelho (ALLSS)
    @since 19/12/2019
    @version 1.0
    @see https://allss.com.br
/*/
Method ConsultarNFe(_cNSU) class ANFEC001
	local   _cC00Tmp        := GetNextAlias()
	local   _cTAB001        := GetNextAlias()
	local   _cTABURL        := GetNextAlias()
	local   _lRet           := Nil
	local   _cQry           := ""
	local   _cMsg           := ""
	local   _oWsdl          := Nil
	local   _cMsgRet        := ""
	local   _lRetUrl        := NIL
	local   cError          := ""
	local   cWarning        := ""
	local   cXmlGZip        := ""
	local   ctpAmb          := "1"		//1=Produção
	local   _nDOC           := 0
	local   _aNSU           := {}
	local   _nQTDDOC        := 0

	private _cDB            := Alltrim(SuperGetMV("MV_XDBTSS", .F., "P12_TSSPRODUCAO"))
	private _cCNPJ          := SM0->M0_CGC
	private _cCODUF         := SUBSTR(SM0->M0_CODMUN,1,2)
	private cURL            := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	private cIdEnt          := ::GetIdEnt()

	::_nSeq                 := 1
	::_nSeqJob              := 0
	::_nStart               := Seconds()

	FwLogMsg(	"INFO",;
				nil,;
				_cRotina,;
				_cRotina+"_NFE",;
				_cRotina+"_NFE_"+StrZero(_nSeq),;
				StrZero(_nSeq),;
				"Processando coleta das chaves para consulta à SEFAZ...",;
				0,;
				(Seconds()-_nStart),;
				{} ) ; _nSeq++
	//Verifica se o serviço foi configurado - Somente o Adm pode configurar 
	if (!ReadyTss() .OR. !ReadyTss(,2))
		if PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0
			SpedNFeCFG()
		else
			HelProg(,"FISTRFNFe")
		endif
	endif
	lEntAtiva := EntAtivTss()
	if lEntAtiva .AND. ReadyTSS()
		FwLogMsg(	"ERROR",;
					nil,;
					_cRotina,;
					_cRotina+"_NFE",;
					_cRotina+"_NFE_"+StrZero(_nSeq),;
					StrZero(_nSeq),;
					"##### TSS INATIVO! #####",;
					0,;
					(Seconds()-_nStart),;
					{} ) ; _nSeq++
		return .F.
	endif
	_cQry := " SELECT TOP 1 ID_ENT, PASSCERT "
	If Empty(_cDB)
		_cQry += " FROM SPED001 SP01 (NOLOCK) "
	Else
		_cQry += " FROM "+AllTrim(_cDB)+".dbo.SPED001 SP01 (NOLOCK) "
	EndIf
	_cQry += " WHERE "
	If !Empty(cIdEnt)
		_cQry += "SP01.ID_ENT     = '"+AllTrim(cIdEnt)+"' "
	Else
		_cQry += "SP01.CNPJ       = '"+SM0->M0_CGC    +"' "
	EndIf
	_cQry += " 	 AND SP01.D_E_L_E_T_ = '' "
	//If __cUserId $ "/000000/000154/000186/"
		MemoWrite(GetTempPath()+_cRotina+"_QRY_001",_cQry)
	//EndIf
	if Select(_cTAB001) > 0
		(_cTAB001)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cTAB001,.F.,.T.)
	dbSelectArea(_cTAB001)
	(_cTAB001)->(dbGoTop())
		cIdEnt:= IIF(empty(cIdEnt),(_cTAB001)->ID_ENT,cIdEnt)
		_cQry := " SELECT TOP 1 CONTEUDO "
		if empty(_cDB)
			_cQry += " FROM SPED000 (NOLOCK) "
		else
			_cQry += " FROM "+AllTrim(_cDB)+".dbo.SPED000 (NOLOCK) "
		endif
		_cQry += " WHERE ID_ENT = '"+cIdEnt+"' AND PARAMETRO = 'MV_VERSAO' "
		_cQry += " 	 AND D_E_L_E_T_ = '' "
		//If __cUserId $ "/000000/000154/000186/"
			MemoWrite(GetTempPath()+::_cRotina+"_QRY_002A",_cQry)
		//EndIf
		if Select(_cTABURL) > 0
			(_cTABURL)->(dbCloseArea())
		endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cTABURL,.F.,.T.)
		_cVersao := IIF((_cTABURL)->(EOF()) .OR. empty((_cTABURL)->CONTEUDO), "4.00", AllTrim((_cTABURL)->CONTEUDO))
		if Select(_cTABURL) > 0
			(_cTABURL)->(dbCloseArea())
		endif
		_cQry := " SELECT TOP 1 URL "
		if empty(_cDB)
			_cQry += " FROM SPED158 (NOLOCK) "
		else
			_cQry += " FROM "+AllTrim(_cDB)+".dbo.SPED158 (NOLOCK) "
		endif
		_cQry += " WHERE SERVICO = 'NFEDISTRIBUICAODFE' AND AMBIENTE = '"+cTpAmb+"' AND VERSAO = '"+_cVersao+"' "
		_cQry += " 	 AND D_E_L_E_T_ = '' "
		//If __cUserId $ "/000000/000154/000186/"
			MemoWrite(GetTempPath()+::_cRotina+"_QRY_002B",_cQry)
		//EndIf
		if Select(_cTABURL) > 0
			(_cTABURL)->(dbCloseArea())
		endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cTABURL,.F.,.T.)
		dbSelectArea(_cTABURL)
		if !(_cTABURL)->(EOF()) .AND. !empty((_cTABURL)->URL)
			cURL             := AllTrim((_cTABURL)->URL)$"?WSDL"
 		else
 			cURL             := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
 		endif
		if Select(_cTABURL) > 0
			(_cTABURL)->(dbCloseArea())
		endif
		_oWsdl                  := TWsdlManager():New()
		_oWsdl:cSSLCACertFile   := Alltrim(SuperGetMV("MV_XCERTCA", .F., "\certs\000001_ca.pem"  ))
		_oWsdl:cSSLCertFile     := Alltrim(SuperGetMV("MV_XCERTIF", .F., "\certs\000001_cert.pem"))
		_oWsdl:cSSLKeyFile      := Alltrim(SuperGetMV("MV_XCERTKY", .F., "\certs\000001_key.pem" ))
		_oWsdl:cSSLKeyPwd       := decode64(AllTrim((_cTAB001)->PASSCERT                         ))    //Senha do certificado digital
		_oWsdl:lSSLInsecure     := .T.
		_oWsdl:nSSLVersion      := 0
		_oWsdl:nTimeout         := 120
	if Select(_cTAB001) > 0
		(_cTAB001)->(dbCloseArea())
	endif
	_lRetUrl := _oWsdl:ParseURL(cURL)
	if _lRetUrl == .F.
		FwLogMsg(	"ERROR",;
					nil,;
					::_cRotina,;
					::_cRotina+"_NFE",;
					::_cRotina+"_NFE_"+StrZero(::_nSeq),;
					StrZero(::_nSeq),;
					"Erro ParseURL: " + _oWsdl:cError,;
					0,;
					(Seconds()-::_nStart),;
					{} ) ; ::_nSeq++
		return
	endif
	// Lista os Metodos do serviço
	_aOps := _oWsdl:ListOperations()
	// Define a operação
	_lRet := _oWsdl:SetOperation("NFEDistDFeInteresse")
	if _lRet == .F.
		FwLogMsg(	"ERROR",;
					nil,;
					::_cRotina,;
					::_cRotina+"_NFE",;
					::_cRotina+"_NFE_"+StrZero(::_nSeq),;
					StrZero(::_nSeq),;
					"Erro SetOperation: " + _oWsdl:cError,;
					0,;
					(Seconds()-::_nStart),;
					{} ) ; ::_nSeq++
		return
	endif
/*
	_cMsg  := '<?xml version="1.0" encoding="utf-8"?>'                                                             + CRLF
	_cMsg  += '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                         + CRLF
	_cMsg  += '    <soapenv:Header/>'                                                                              + CRLF
	_cMsg  += '    <soapenv:Body>'                                                                                 + CRLF
	_cMsg  += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'   + CRLF
	_cMsg  += '                <nfeDadosMsg>'                                                                      + CRLF
	_cMsg  += '                    <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'          + CRLF
	_cMsg  += '                        <tpAmb>'+cTpAmb+'</tpAmb>'                                                  + CRLF
	_cMsg  += '                        <cUFAutor>'+Alltrim(_cCODUF)+'</cUFAutor>'                                  + CRLF
	_cMsg  += '                        <CNPJ>'+AllTrim(_cCNPJ)+'</CNPJ>'                                           + CRLF
	_cMsg  += '                         <consChNFe>'                                                               + CRLF
	_cMsg  += '                              <chNFe>'+_cChrStr+'</chNFe>'                                          + CRLF
	_cMsg  += '                         </consChNFe>'                                                              + CRLF
//	_cMsg  += '                         <consNSU>'                                                                 + CRLF
//	_cMsg  += '                              <NSU>'+Replicate("$",15)+'</NSU>'                                     + CRLF
//	_cMsg  += '                         </consNSU>'                                                                + CRLF
	_cMsg  += '                    </distDFeInt>'                                                                  + CRLF
	_cMsg  += '                </nfeDadosMsg>'                                                                     + CRLF
	_cMsg  += '            </nfeDistDFeInteresse>'                                                                 + CRLF
	_cMsg  += '        </soapenv:Body>'                                                                            + CRLF
	_cMsg  += '    </soapenv:Envelope>'                                                                            + CRLF
*/
	_cMsg  := '<?xml version="1.0" encoding="utf-8"?>'                                                             + CRLF
	_cMsg  += '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                         + CRLF
	_cMsg  += '    <soapenv:Header/>'                                                                              + CRLF
	_cMsg  += '    <soapenv:Body>'                                                                                 + CRLF
	_cMsg  += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'   + CRLF
	_cMsg  += '                <nfeDadosMsg>'                                                                      + CRLF
	_cMsg  += '                    <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'          + CRLF
	_cMsg  += '                        <tpAmb>'+cTpAmb+'</tpAmb>'                                                  + CRLF
	_cMsg  += '                        <cUFAutor>'+Alltrim(_cCODUF)+'</cUFAutor>'                                  + CRLF
	_cMsg  += '                        <CNPJ>'+AllTrim(_cCNPJ)+'</CNPJ>'                                           + CRLF
	_cMsg  += '                       <distNSU>'                                                                   + CRLF
	_cMsg  += '                            <ultNSU>' + _cNSU + '</ultNSU>'                                         + CRLF
	_cMsg  += '                       </distNSU>'                                                                  + CRLF
	_cMsg  += '                   </distDFeInt>'                                                                   + CRLF
	_cMsg  += '               </nfeDadosMsg>'                                                                      + CRLF
	_cMsg  += '       </nfeDistDFeInteresse>'                                                                      + CRLF
	_cMsg  += '   </SOAP-ENV:Body>'                                                                                + CRLF
	_cMsg  += '</SOAP-ENV:Envelope>'                                                                               + CRLF

	// Envia uma mensagem SOAP personalizada ao servidor
	_lRet := _oWsdl:SendSoapMsg( _cMsg )
	if _lRet == .F.
		FwLogMsg(	"ERROR",;
					nil,;
					::_cRotina,;
					::_cRotina+"_NFE",;
					::_cRotina+"_NFE_"+StrZero(::_nSeq),;
					StrZero(::_nSeq),;
					"Erro SendSoapMsg: " + _oWsdl:cError,;
					0,;
					(Seconds()-::_nStart),;
					{} ) ; ::_nSeq++
		FwLogMsg(	"ERROR",;
					nil,;
					::_cRotina,;
					::_cRotina+"_NFE",;
					::_cRotina+"_NFE_"+StrZero(::_nSeq),;
					StrZero(::_nSeq),;
					"Erro SendSoapMsg FaultCode: " + _oWsdl:cFaultCode,;
					0,;
					(Seconds()-::_nStart),;
					{} ) ; ::_nSeq++
		return
	endif
	_cMsgRet := _oWsdl:GetSoapResponse()
	FwLogMsg(	"INFO",;
				nil,;
				::_cRotina,;
				::_cRotina+"_NFE",;
				::_cRotina+"_NFE_"+StrZero(::_nSeq),;
				StrZero(::_nSeq),;
				"RETORNO --> "+_cMsgRet,;
				0,;
				(Seconds()-::_nStart),;
				{} ) ; ::_nSeq++
	//Transforma a resposta em um objeto
	oXmlDocZip := XmlParser(_cMsgRet, "_", @cError, @cWarning)
	//Se existir Warning, mostra no console.log
	if ! empty(cWarning)
		FwLogMsg(	"WARNING",;
					nil,;
					::_cRotina,;
					::_cRotina+"_NFE",;
					::_cRotina+"_NFE_"+StrZero(::_nSeq),;
					StrZero(::_nSeq),;
					"Alerta cWarning: " + cWarning,;
					0,;
					(Seconds()-::_nStart),;
					{} ) ; ::_nSeq++
	endif
	//Se houve erro, não permitirá prosseguir
	if ! empty(cError)
		FwLogMsg(	"ERROR",;
					nil,;
					::_cRotina,;
					::_cRotina+"_NFE",;
					::_cRotina+"_NFE_"+StrZero(::_nSeq),;
					StrZero(::_nSeq),;
					"Erro cError: " + cError,;
					0,;
					(Seconds()-::_nStart),;
					{} ) ; ::_nSeq++
		lContinua := .F.
	endif
	if (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A") 
		_nQTDDOC := LEN(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP)
		for _nDOC := 1 TO _nQTDDOC
			//Se a tag DocZip existir (for diferente de Undefinied)
			if (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[" + ALLTRIM(STR(_nDOC)) + "]") != "U")
				//Pega tag que contém XML em zip
				cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[_nDOC]:TEXT
				//Gera arquivo XML
				_cNSU    := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[_nDOC]:_NSU:TEXT
				if !::GerarXML(cXmlGZip, _cNSU )
					_cNSU := "YYYYYYYYYYYYYYY"
				endif
			else
				FwLogMsg(	"ERROR",;
							nil,;
							::_cRotina,;
							::_cRotina+"_NFE",;
							::_cRotina+"_NFE_"+StrZero(::_nSeq),;
							StrZero(::_nSeq),;
							"Ocorreu algum problema no momento de baixar o arquivo da sefaz!",;
							0,;
							(Seconds()-::_nStart),;
							{} ) ; ::_nSeq++
				_cNSU := ""
			endif
		next
	else
		//Se a tag DocZip existir (for diferente de Undefinied)
		if (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
			//Pega tag que contém XML em zip
			cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
			//Gera arquivo XML
			_cNSU    := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_NSU:TEXT
			::GerarXML(cXmlGZip, _cNSU )
			_cNSU := "XXXXXXXXXXXXXXX"
		else
			_cSTAT   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
			_cMOTIVO := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
			FwLogMsg(	"INFO",;
						nil,;
						::_cRotina,;
						::_cRotina+"_NFE",;
						::_cRotina+"_NFE_"+StrZero(::_nSeq),;
						StrZero(::_nSeq),;
						_cSTAT + " - " + _cMOTIVO,;
						0,;
						(Seconds()-::_nStart),;
						{} ) ; ::_nSeq++
			DO CASE
				CASE ALLTRIM(_cSTAT) == "137" //Nenhum documento localizado.
					_cNSU := "XXXXXXXXXXXXXXX"
				CASE ALLTRIM(_cSTAT) == "656" //Rejeicao: Consumo indevido
					_cNSU := ""
				CASE ALLTRIM(_cSTAT) == "589" //Rejeicao: Numero de NSU informado superior ao maior NSU da base de dados do Ambiente Nacional.
					_cNSU := "XXXXXXXXXXXXXXX"
				OTHERWISE //Problema indertiminado aborta a importacao
					FwLogMsg(	"ERROR",;
								nil,;
								::_cRotina,;
								::_cRotina+"_NFE",;
								::_cRotina+"_NFE_"+StrZero(::_nSeq),;
								StrZero(::_nSeq),;
								"ERRO INDETERMINADO - STAT: " + _cSTAT + " - Descrição: " + _cMOTIVO + " - " + DTOC(Date())+" - "+TIME(),;
								0,;
								(Seconds()-::_nStart),;
								{} ) ; ::_nSeq++
					_cNSU := "XXXXXXXXXXXXXXX"
			END CASE
		endif
	endif
	AADD(_aNSU,{_cNSU ,_nQTDDOC})
return _aNSU
/*/{Protheus.doc} GerarXML
     @description Geração do arquivo XML.
     @author user
     @since 20/12/2019
     @version version
     @see https://allss.com.br
/*/
Method GerarXML(_cConteudo, _cChave) class ANFEC001
	local _aArea      := getArea()
	local _cArquivo   := _cChave + ".xml"
	local _cDiretorio := Alltrim( GetNewPar("MV_NGINN","\Neogrid\bin\IN") ) //Alltrim(SuperGetMV("MV_X_BXDIR", .F., "C:\TOTVS\XML\"))
	local _nTamanho   := 0
	local _cUnXML     := ""
	local _cDecode64  := ""
	local _cArqFull   := ""
	local _lHouveErro := .F.
	local _cError     := ""
	local _cWarning   := ""
	local _lRet       := .T.
	//Se o último caracter do diretório não for \, será barra \
	if SubStr(_cDiretorio, Len(_cDiretorio), 1) != "\"
		_cDiretorio += "\"
	endif
	//Define o caminho final do arquivo
	_cArqFull  := _cDiretorio + _cArquivo
	//Pega o tamanho e descriptografa o conteúdo
	_nTamanho  := Len(_cConteudo)
	_cDecode64 := Decode64(_cConteudo)
	if GzStrDecomp(_cDecode64, _nTamanho, @_cUnXML)
		//Se o diretório não existir, cria
		if !ExistDir(_cDiretorio)
			MakeDir(_cDiretorio)
		endif
		//Converte String para padrao Windows
		_cUncomp    := ENCODEUTF8(OemToAnsi(AllTrim(_cUnXML)) )
		//Transforma xml CT-e em um objeto
		oXmlNFe     := XmlParser(_cUncomp, "_", @_cError, @_cWarning)
		if ValType(oXmlNFe) == "U"
			_lRet   := .F.
		endif
		if _lRet
			if ValType(XmlChildEx(oXmlNFe,"_NFEPROC")) == "U"
				return .F.
			endif
			if ValType(XmlChildEx(oXmlNFe:_NFEPROC:_NFE:_INFNFE:_Ide,"_TOMA3")) == "O"
				if AllTrim(oXmlNFe:_NFEPROC:_NFE:_INFNFE:_Ide:_Toma3:_TOMA:Text) <> "0"
					return .F.
				endif
				if AllTrim(oXmlNFe:_NFEPROC:_NFE:_INFNFE:_Rem:_CNPJ:Text) <> ALLTRIM(_cCNPJ)
					return .F.
				endif
			else
				return .F.
			endif
		endif
		//Cria o arquivo com o conteúdo
		_nLenUncomp := Len( _cUncomp )
		_nHandle    := FCreate( _cDiretorio+_cArquivo )
		FWrite( _nHandle, _cUncomp, _nLenUncomp )
		FClose( _nHandle )
	//Se não deu certo, mostra mensagem no console.log
	else
		FwLogMsg(	"ERROR",;
					nil,;
					::_cRotina,;
					::_cRotina+"_NFE",;
					::_cRotina+"_NFE_"+StrZero(::_nSeq),;
					StrZero(::_nSeq),;
					"[GerarXML] - Houve algum erro na descompactação do arquivo!",;
					0,;
					(Seconds()-::_nStart),;
					{} ) ; ::_nSeq++
		_lHouveErro := .T.
	endif
    //Se houve erro, zera o nome do arquivo para retornar em branco
    if _lHouveErro
		_cArqFull := ""
	endif
	RestArea(_aArea)
return .T.
/*/{Protheus.doc} UltimoNSU
    @description Metodo para verificar ultimo NSU
    @author Anderson Coelho (ALLSS)
    @since 02/01/2020
    @version version
    @see https://allss.com.br
/*/
Method UltimoNSU() class ANFEC001
	local _cNSU    := GetnextAlias()
	local _cULTNSU := "000000000000000"
	BEGINSQL ALIAS _cNSU
		SELECT MAX(CKO_ARQXML) AS CKO_ARQXML
		FROM CKOCOL CKO (NOLOCK)
		WHERE CKO_FILIAL  = %xFilial:CKO% 
		  AND CKO_ARQXML <> '                                                            ' 
		  AND CKO.%notDel%
	ENDSQL
	if !(_cNSU)->(EOF())
		if !empty(ALLTRIM((_cNSU)->CKO_ARQXML))
			_cULTNSU := SUBSTR(ALLTRIM((_cNSU)->CKO_ARQXML),1,15)
		else
			_cULTNSU := "000000000000000"
		endif
	else
		_cULTNSU := "000000000000000"
	endif
	(_cNSU)->(dbCloseArea())
return _cULTNSU
/*/{Protheus.doc} GetIdEnt
    @description Metodo para buscar a entidade no TSS
    @author Anderson C. P. Coelho (ALLSS)
    @since 18/02/2020
    @version version
    @see https://allss.com.br
/*/
Method GetIdEnt() class ANFEC001
	Local oWs
	Local aArea      := GetArea()
	Local lUsaGesEmp := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWS                        := WsSPEDAdm():New()
	oWS:cUSERTOKEN             := "TOTVS"	
	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	ElseIf Empty(_cEmp)
		Aviso( "["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_035] Captacao de XML",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	Else
		//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_035] >>> ERRO: "+CRLF+IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
	EndIf
	RestArea(aArea)
return cIdEnt