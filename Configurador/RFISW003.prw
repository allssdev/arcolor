#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'APWIZARD.CH'
#include 'FILEIO.CH'
#include 'RPTDEF.CH'  
#include 'TOTVS.CH'
#include 'PARMTYPE.CH'
#include 'tbiconn.ch'
#include 'apwebsrv.ch'

#define  _CLRF CHR(13)+CHR(10)
/*/{Protheus.doc} RFISW003
@description Em fase de testes...
@author Anderson Coelho (ALL System Solutions)
@since 24/07/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFISW003()
	Teste002()
return
static function Teste002()
	Local   _lProc    := .T.
	Local   _nContJob := 0

	Private _cRotina  := "RFISW003"
	Private cIdEnt    := ""
	Private cURL      := ""
	Private _cDir     := ""		//GetPvProfString(_cRotina,"PATH"       ,"\xml\"                   ,GetAdv97())
	Private _cEmp     := ""		//GetPvProfString(_cRotina,"EMPRESA"    ,"01"                      ,GetAdv97())
	Private _cFil     := ""		//GetPvProfString(_cRotina,"FILIAL"     ,"01"                      ,GetAdv97())
	Private  _cDB     := ""		//GetPvProfString(_cRotina,"BANCOTSS"   ,"TSSP11"                  ,GetAdv97())
	Private  _cPCerts := ""		//GetPvProfString(_cRotina,"PATHCERTS"  ,"d:\protheus11\tss\certs\",GetAdv97())
	Private _nSeqJob  := 0
	Private _lGeraArq := .F.

	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_001] Iniciando a rotina de importacao dos XMLs emitidos contra a empresa...")
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_002] Verificando parametros iniciais...")
	While _lProc
		_nSeqJob++
		//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_003] Verificando existencia do JOB '"+(_cRotina+"_"+StrZero(_nSeqJob,3))+"'...")
		_cDir         := ""
		_cFil         := ""
		_lGeraArq     := .F.
		_cEmp         := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"EMPRESA"    ,""      ,GetAdv97())
		If !Empty(_cEmp)
			_cFil     := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"FILIAL"     ,""      ,GetAdv97())
			_cDir     := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"PATH"       ,""      ,GetAdv97())
			_cDB      := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"BANCOTSS"   ,""      ,GetAdv97())
			_cPCerts  := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"PATHCERTS"  ,""      ,GetAdv97())
			_lGeraArq := !Empty(_cDir)
			_lProc    := .T.
			_nContJob++
			//conout(Replicate("*",15)+"["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_004] Os processos serao executados considerando as seguintes configuracoes do server job '"+(_cRotina+"_"+StrZero(_nSeqJob,3))+"':"+_CLRF+"Empresa/Filial: "+_cEmp+"/"+_cFil+_CLRF+"Path: "+_cDir+Replicate("*",15))
			Check01()
		Else
			//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_005] JOB '"+(_cRotina+"_"+StrZero(_nSeqJob,3))+"' nao existe ou foi configurado incorretamente. Processamento abortado (para este server job)!!!")
			_lProc := .F.
		EndIf
	EndDo
	If _nContJob > 0 .AND. !_lProc
		//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_006] Execução da rotina fora do JOB...")
		Check01()
	EndIf
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_007] FINISH!!!")
return
static function Check01()
	local _lViaJob := .F.
	If !_lGeraArq
		//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_008] Os arquivos a serem obtidos serao salvos apenas na tabela 'SPED156'...")
	Else
		If !ExistDir(_cDir) .AND. MakeDir(_cDir) != 0
			//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_009] PROCESSO ABORTADO! Não foi possível criar o diretório '"+_cDir+"'. Erro: " + cValToChar( FError() ) )
			return
		EndIf
		//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_010] Definido o caminho para que os arquivos xml sejam gerados (alem da tabela 'SPED156'). Caminho: '"+_cDir+"'...")
	EndIf
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_011] Preparando ambiente...")
	If Type("cFilAnt")=="U"
		//RpcClearEnv()
		//RPCSetType(3)
		If Empty(_cEmp) .OR. Empty(_cFil) //.OR. !RpcSetEnv(_cEmp, _cFil, , , "COM")
			//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_012] Falha ao carregar o ambiente (empresa: '"+_cEmp+"' / filial: '"+_cFil+"'). PROCESSAMENTO ABORTADO!")
			return
		EndIf
		PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil MODULO "COM"
		_lViaJob := .T.
	EndIf
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_013] Iniciando processamento na empresa '"+SubStr(cNumEmp,1,2)+"' e filial '"+SubStr(cNumEmp,3,2)+"' para a captação dos arquivos XML emitidos contra '" + SM0->M0_CGC + "'...")
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_015] Carregando parametros...")
	cIdEnt   := GetIdEnt()
	cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	If Empty(_cEmp) .OR. Empty(_cFil)
		//Verifica se o serviço foi configurado - Somente o Adm pode configurar 
		If (!ReadyTss() .OR. !ReadyTss(,2))
			If PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0
				SpedNFeCFG()
			Else
				HelProg(,"FISTRFNFe")
			EndIf
		EndIf
		lEntAtiva := EntAtivTss()
		If lEntAtiva .AND. ReadyTSS()
			MsgRun("Aguarde... iniciando processamento...", "["+_cRotina+"] Rotina de captação dos arquivos XML emitidos contra '" + SM0->M0_CGC + "'.", { || ProcRotina() })
		EndIf
	Else
		ProcRotina()
	EndIf
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_016] *************************") 
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_017] Processamento finalizado!")
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_018] *************************")
	if _lViaJob
		RESET ENVIRONMENT
	endif
return
static function ProcRotina()
	Local   _cDtProc     := DTOS(Date())
	Local   _aDocs       := {}
	Local   _cQry        := ""
	Local   _cTAB001     := GetNextAlias()

	Private oWsdl        := TWsdlManager():New() 

	_cQry := " SELECT TOP 1 * "
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
	If __cUserId $ "/000000/000154/000186/"
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001",_cQry)
	EndIf
	if Select(_cTAB001) > 0
		(_cTAB001)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cTAB001,.F.,.T.)
	dbSelectArea(_cTAB001)
	(_cTAB001)->(dbGoTop())
		cIdEnt               := IIF(Empty(cIdEnt),(_cTAB001)->ID_ENT,cIdEnt)
	//	cURL                 := "https://www.nfe.fazenda.gov.br/NfeDownloadNF/NfeDownloadNF.asmx"		//"https://nfe.fazenda.sp.gov.br/ws/cadconsultacadastro2.asmx"
		cURL                 := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx"
		oWsdl:cSSLCACertFile := AllTrim(_cPCerts)+AllTrim(cIdEnt)+"_ca.pem" 
		oWsdl:cSSLCertFile   := AllTrim(_cPCerts)+AllTrim(cIdEnt)+"_cert.pem" 
		oWsdl:cSSLKeyFile    := AllTrim(_cPCerts)+AllTrim(cIdEnt)+"_key.pem"
		oWsdl:cSSLKeyPwd     := decode64(AllTrim((_cTAB001)->PASSCERT))
		//oWsdl:nSSLVersion  := 0
		//oWsdl:nSSLVersion  := 1
		oWsdl:nTimeout       := 120
	dbSelectArea(_cTAB001)
	(_cTAB001)->(dbCloseArea())
	if !oWsdl:ParseURL( cURL )
		//conout( "Erro ao efetuar o Parser na URL: " + oWsdl:cError )
		return
	endif
	// Lista as operações disponíveis
	//aOps := oWsdl:ListOperations()
	//varinfo( "", aOps )
	/*
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_019] Carregando parametros web...") 
	oWSdNfe:_URL       := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
	oWSdNfe:CUSERTOKEN := "TOTVS"
	oWSdNfe:CIDENT     := cIdEnt
	oWSdNfe:CONFIGURARPARAMETROS()
	oWSdNfe:CAMBIENTE  := oWSdNfe:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE
	oWSdNfe:CVERSAO    := oWSdNfe:OWSCONFIGURARPARAMETROSRESULT:CVERSAO
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_028] Sincronizando documentos...") 
	oWSdNfe:SINCRONIZARDOCUMENTOS()
	If Type("oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO") <> "U"
		If Type("oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO")=="A"
			_aDocs := oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO                  
		Else
			_aDocs := {oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO}
		EndIf
	ElseIf Empty(_cEmp)
		Aviso("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"] SPED - Captacao XML",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	Else
		//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_029] Erro na execucao do sincronismo dos documentos fiscais: "+IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+"...")
	EndIf
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_030] "+cValToChar(Len(_aDocs))+" documentos sincronizados. Processando informacoes coletadas...")
	For _x := 1 To Len(_aDocs)
		oWSdNfe:OWSBAIXARDOCUMENTOS:OWSDOCUMENTO                              := MANIFESTACAODESTINATARIO_ARRAYOFBAIXARDOCUMENTO():New()
		oWSdNfe:OWSBAIXARDOCUMENTOS:OWSDOCUMENTO:OWSBAIXARDOCUMENTO           := {WsClassNew("MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO") }
		oWSdNfe:OWSBAIXARDOCUMENTOS:OWSDOCUMENTO:OWSBAIXARDOCUMENTO[1]:CCHAVE := _aDocs[_x]:CCHAVE
		If oWSdNfe:BAIXARXMLDOCUMENTOS()
			//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_031] Informacoes coletadas com sucesso (chave '"+_aDocs[_x]:CCHAVE+"')...")
			If _lGeraArq
				If MemoWrite(_cDir+_aDocs[_x]:CCHAVE+"_"+DTOS(_cDtProc)+".xml",;
																		'<?xml version="1.0" encoding="UTF-8"?><nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="3.10" by="ALL System Solutions - https://allss.com.br">'+;
																		oWSdNfe:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET[1]:CNFEZIP+;
																		oWSdNfe:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET[1]:CNFEPROTZIP+;
																		'</nfeProc>')
					//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_032] Arquivo '"+_cDir+_aDocs[_x]:CCHAVE+"_"+DTOS(_cDtProc)+".xml' salvo com sucesso!")
				Else
					//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_033] Falha na gravacao do arquivo '"+_cDir+_aDocs[_x]:CCHAVE+"_"+DTOS(_cDtProc)+".xml'!")
				EndIf
			EndIf
		Else
			//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_034] Erro na obtencao do arquivo XML para a chave '"+_aDocs[_x]:CCHAVE+"': "+GetWSCError())
		EndIf
	Next
	*/
	//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_035] Finalizando execucao...")
return
static function GetIdEnt()
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
		//conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_035] >>> ERRO: "+_CLRF+IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
	EndIf
	RestArea(aArea)
return cIdEnt