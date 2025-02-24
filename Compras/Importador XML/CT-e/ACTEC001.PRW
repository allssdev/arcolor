#include 'protheus.ch'

USER FUNCTION ACTEC001(); RETURN 

/*/{Protheus.doc} ACTEC001
    (long_description)
    @author Fernando Bombardi (ALLss)
    @since 19/12/2019
    @version version
    /*/
Class ACTEC001
    Method NEW() CONSTRUCTOR
    Method ConsultarCTe()
    Method GerarXML()
    Method UltimoNSU()    
EndClass

/*/{Protheus.doc} NEW
    Metodo constructor
    @author Fernando Bombardi (ALLSS)
    @since 19/12/2019
    @version 1.0
    /*/
Method NEW() class ACTEC001
    
Return 

/*/{Protheus.doc} ConsultarCTe
    Metodo para realizar a consulta do CT-e
    @author Fernando Bombardi (ALLSS)
    @since 19/12/2019
    @version 1.0
    /*/
Method ConsultarCTe(_cNSU) class ACTEC001
    Local _lRet     := Nil
    Local _cMsg     := ""
    Local _oWsdl    := Nil
    Local _cMsgRet  := ""
    Local _cRetUrl  := Alltrim(SuperGetMV("MV_XURLCTE", .F., ""))
    Local cError    := ""
    Local cWarning  := ""
    Local cXmlGZip  := ""
    LOCAL _nDOC     := 0
    Local _aNSU     := {}
    Local _nQTDDOC  := 0
    local _cStatus 	:= ""
    Private _cCNPJ  := SM0->M0_CGC
    Private _cCODUF := SUBSTR(SM0->M0_CODMUN,1,2)


    _oWsdl := TWsdlManager():New()
    _oWsdl:cSSLCACertFile   := Alltrim(SuperGetMV("MV_XCERTCA", .F., "\certs\000001_ca.pem")) //"\certs\000012_ca.pem"
    _oWsdl:cSSLCertFile     := Alltrim(SuperGetMV("MV_XCERTIF", .F., "\certs\000001_cert.pem")) //"\certs\000012_cert.pem"
    _oWsdl:cSSLKeyFile      := Alltrim(SuperGetMV("MV_XCERTKY", .F., "\certs\000001_key.pem")) //"\certs\000012_key.pem"
    _oWsdl:cSSLKeyPwd       := Alltrim(SuperGetMV("MV_XCERPSW", .F., "YXJjb2xvcjE5")) //
    _oWsdl:lSSLInsecure     := .T.
    _oWsdl:nSSLVersion      := 0
    _oWsdl:nTimeout         := 120
    
    _lRetUrl := _oWsdl:ParseURL(_cRetUrl)
    if _lRetUrl == .F.
        Return
    endif

   // Lista os Metodos do serviço
    _aOps := _oWsdl:ListOperations()

    // Define a operação
    _lRet := _oWsdl:SetOperation("cteDistDFeInteresse")
    If _lRet == .F.
        return
    EndIf

    _cMsg  := '<?xml version="1.0" encoding="UTF-8" standalone="no" ?>'
    _cMsg  += '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope" xmlns:SOAP-ENC="http://www.w3.org/2003/05/soap-encoding" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns1="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'
    _cMsg  += '<SOAP-ENV:Header/>'
    _cMsg  += '<SOAP-ENV:Body>'
    _cMsg  += '<cteDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'
    _cMsg  += '<cteDadosMsg>'
    _cMsg  += '<distDFeInt xmlns="http://www.portalfiscal.inf.br/cte" versao="1.00">'
    _cMsg  += '<tpAmb>1</tpAmb>'
    _cMsg  += '<cUFAutor>' + Alltrim(_cCODUF) + '</cUFAutor>'
    _cMsg  += '<CNPJ>' + AllTrim(_cCNPJ) + '</CNPJ>'
    _cMsg  += '<distNSU>'
    _cMsg  += '<ultNSU>' + _cNSU + '</ultNSU>'
    _cMsg  += '</distNSU>'
    _cMsg  += '</distDFeInt>'
    _cMsg  += '</cteDadosMsg>'
    _cMsg  += '</cteDistDFeInteresse>'
    _cMsg  += '</SOAP-ENV:Body>'
    _cMsg  += '</SOAP-ENV:Envelope>'

    // Envia uma mensagem SOAP personalizada ao servidor
    _lRet := _oWsdl:SendSoapMsg( _cMsg )
    If _lRet == .F.
          Return
    EndIf
    
    _cMsgRet := _oWsdl:GetSoapResponse()

    //Transforma a resposta em um objeto
    oXmlDocZip := XmlParser(_cMsgRet, "_", @cError, @cWarning)    
                    
    //Se houve erro, não permitirá prosseguir
    If ! Empty(cError)
        lContinua := .F.
    EndIf 
  
    If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A") 

        _nQTDDOC := LEN(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP)

        FOR _nDOC := 1 TO _nQTDDOC

            //Se a tag DocZip existir (for diferente de Undefinied)
            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[" + ALLTRIM(STR(_nDOC)) + "]") != "U")
        
                //Pega tag que contém XML em zip
                cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[_nDOC]:TEXT                  
                //Gera arquivo XML
                _cNSU    := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[_nDOC]:_NSU:TEXT                                                            
                If !::GerarXML(cXmlGZip, _cNSU )
                	PUTMV("MV_XNSUCTE",_cNSU)
                   _cNSU := "YYYYYYYYYYYYYYY"
                Endif
            else 
            	PUTMV("MV_XNSUCTE",_cNSU)//Ultima consulta atualiza aqui.           
            	_cNSU := ""
            endif
        NEXT

    ELSE
        //Se a tag DocZip existir (for diferente de Undefinied)
        If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
      
           //Pega tag que contém XML em zip
            cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
                    
            //Gera arquivo XML
            _cNSU    := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_NSU:TEXT
            PUTMV("MV_XNSUCTE",_cNSU)//Ultima consulta atualiza aqui. 
            ::GerarXML(cXmlGZip, _cNSU )
            _cNSU := "XXXXXXXXXXXXXXX"
        else
            
            _cSTAT := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
            _cMOTIVO := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
            _cStatus := "[ERRO] - STAT: " + _cSTAT + " - Descrição: " + _cMOTIVO + " - " + TIME()
            
            PUTMV("MV_XNSUCTE",_cNSU)//Ultima consulta atualiza aqui.                  
			if ALLTRIM(_cSTAT) == "656" //Rejeicao: Consumo indevido
			 	_cNSU := ""                
			 Elseif ALLTRIM(_cSTAT)$"589/137" // 589 Rejeicao: Numero de NSU informado superior ao maior NSU da base de dados do Ambiente Nacional.
			 	_cNSU := "XXXXXXXXXXXXXXX"	  // 137 Nenhum documento localizado.
			 Else //Problema indertiminado aborta a importacao
			   	_cNSU := "XXXXXXXXXXXXXXX"                
			Endif
        Endif
    Endif

    aADD(_aNSU,{_cNSU ,_nQTDDOC,_cStatus})

return(_aNSU)

/*/{Protheus.doc} GerarXML
     (long_description)
     @author user
     @since 20/12/2019
     @version version
     /*/
Method GerarXML(_cConteudo, _cChave) class ACTEC001
    Local _aArea      := getArea()
    Local _cArquivo   := _cChave + ".xml"
    Local _cDiretorio :=  Alltrim(SuperGetMV("MV_NGINN", .F., "C:\TOTVS\XML\"))  + "CTE"
     Local _nTamanho   := 0
    Local _cUnXML     := ""
    Local _cDecode64  := ""
    Local _cArqFull   := ""
    Local _lHouveErro := .F.
    Local _cError     := ""
    Local _cWarning   := ""
    Local _lRet       := .T.
    

    //Se o último caracter do diretório no for \, será barra \
    If SubStr(_cDiretorio, Len(_cDiretorio), 1) != "\"
        _cDiretorio += "\"
    EndIf
     
    //Define o caminho final do arquivo
    _cArqFull := _cDiretorio + _cArquivo
     
    //Pega o tamanho e descriptografa o contedo
    _nTamanho  := Len(_cConteudo)
    _cDecode64 := Decode64(_cConteudo)
      
    If GzStrDecomp(_cDecode64, _nTamanho, @_cUnXML)

        //Se o diretrio no existir, cria
        If !ExistDir(_cDiretorio)
            MakeDir(_cDiretorio)
        EndIf
         
        //Converte String para padrao Windows
        _cUncomp    := ENCODEUTF8(OemToAnsi(AllTrim(_cUnXML)) )

        //Transforma xml CT-e em um objeto
        oXmlCte := XmlParser(_cUncomp, "_", @_cError, @_cWarning)
        If ValType(oXmlCte) == "U"
            _lRet := .F.
        Endif

       iF _lRet

            IF ValType(XmlChildEx(oXmlCte,"_CTEPROC")) == "U"
                RETURN(.F.)
            ENDIF
		    /*TAG   _TOMA:    
		    0-Remetente;
		    1-Expedidor;
		    2-Recebedor;
		    3-Destinatário.*/      

           // IF ValType(XmlChildEx(oXmlCte:_CTEPROC:_CTE:_INFCTE:_Ide,"_TOMA3")) == "O"
             //   IF AllTrim(oXmlCte:_CTEPROC:_CTE:_INFCTE:_Ide:_Toma3:_TOMA:Text) <> "0" //Buscamos notas contra o CPF da Arcolar.
             //       RETURN(.F.)
             //   ENDIF
               // IF AllTrim(oXmlCte:_CTEPROC:_CTE:_INFCTE:_Rem:_CNPJ:Text) <> ALLTRIM(_cCNPJ) //remetente nao pode ser da Arcolar.
               //     RETURN(.F.)
             //   ENDIF
            //ELSE
             //   RETURN(.F.)            
           // ENDIF

	        
           //Cria o arquivo com o conteúdo
            _nLenUncomp := Len( _cUncomp )
	        _nHandle    := FCreate( _cDiretorio+_cArquivo )
	        FWrite( _nHandle, _cUncomp, _nLenUncomp )
	        FClose( _nHandle )   
        EndIf
    //Se no deu certo, mostra mensagem no console.log
    Else
     _lHouveErro := .T.
    EndIf
    //Se houve erro, zera o nome do arquivo para retornar em branco
    If _lHouveErro
        _cArqFull := ""
    EndIf
 
    RestArea(_aArea)
Return(.T.)

/*/{Protheus.doc} UltimoNSU
    Metodo para verificar ultimo NSU
    @author Fernando Bombardi
    @since 02/01/2020
    @version version
    /*/
Method UltimoNSU() class ACTEC001

local _cULTNSU := SuperGetMV("MV_XNSUCTE", .F., "000000000000000") 

Return(_cULTNSU)