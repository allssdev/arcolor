#INCLUDE 'rwmake.ch'
#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'topconn.ch'
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH
#INCLUDE "SHELL.CH

#DEFINE _CLRF CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOMW001  ºAutor  ³Anderson C. P. Coelho º Data ³  21/10/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina em testes.                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ALLJ001()

Local   _lProc    := .T.
Local   _nContJob := 0

Private _cRotina  := "ALLJ001"
Private cIdEnt    := ""
Private cURL      := ""
Private _cDir     := ""		//GetPvProfString(_cRotina,"PATH"       ,"\xml\"        ,GetAdv97())
Private _cEmp     := ""		//GetPvProfString(_cRotina,"EMPRESA"    ,"01"           ,GetAdv97())
Private _cFil     := ""		//GetPvProfString(_cRotina,"FILIAL"     ,"01"           ,GetAdv97())
Private _nSeqJob  := 0
Private _lGeraArq := .T.

While _lProc
	_nSeqJob++
	_cDir         := ""
	_cFil         := ""
	_lGeraArq     := .F.
	_cEmp         :="01" //"GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"EMPRESA"    ,"",GetAdv97())
	If !Empty(_cEmp)
		_cFil     := "01"// GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"FILIAL"     ,"",GetAdv97())
		_cDir     := "\xml\" //GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"PATH"       ,"",GetAdv97())		//"\xml\"
		_lGeraArq := !Empty(_cDir)
		_lProc    := .T.
		_nContJob++
		Check01()
	Else
		_lProc := .F.
	EndIf
EndDo
If _nContJob > 0 .AND. !_lProc
	Check01()
EndIf


Return

Static Function Check01()

Local   cFilMani  := "FILTMANIFEST"

If !_lGeraArq .and. !ExistDir(_cDir) .AND. MakeDir(_cDir) != 0
		Return
	
EndIf
If Type("cFilAnt")=="U"

	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil FUNNAME _cRotina
EndIf

dbSelectArea("C00")
cFilMani := SM0->M0_CODIGO+SM0->M0_CODFIL+cFilMani
cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
cIdEnt   := GetIdEnt()
MV_PAR01 := Replicate(" ",Len(C00->C00_CNPJEM))
MV_PAR02 := Replicate("9",Len(C00->C00_CNPJEM))
MV_PAR03 := Replicate(" ",Len(C00->C00_SERNFE))
MV_PAR04 := Replicate("Z",Len(C00->C00_SERNFE))
MV_PAR05 := Replicate(" ",Len(C00->C00_NUMNFE))
MV_PAR06 := Replicate("9",Len(C00->C00_NUMNFE))
MV_PAR07 := 0			//Mês
MV_PAR08 := ""			//Ano
MV_PAR09 := ""			//Status
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

Return

Static Function ProcRotina()

Local   _cDtProc   := DTOS(Date())
Local   _aDocs     := {}
Local   oWSdNfe    := WSMANIFESTACAODESTINATARIO():NEW()

conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_019] Carregando parametros web...") 
oWSdNfe:_URL       := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
oWSdNfe:CUSERTOKEN := "TOTVS"
oWSdNfe:CIDENT     := cIdEnt
oWSdNfe:CONFIGURARPARAMETROS()
oWSdNfe:CAMBIENTE  := oWSdNfe:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE
oWSdNfe:CVERSAO    := oWSdNfe:OWSCONFIGURARPARAMETROSRESULT:CVERSAO
conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_028] Sincronizando documentos...") 
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
	conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_029] Erro na execucao do sincronismo dos documentos fiscais: "+IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+"...")
EndIf
conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_030] "+cValToChar(Len(_aDocs))+" documentos sincronizados. Processando informacoes coletadas...")
For _x := 1 To Len(_aDocs)
	oWSdNfe:OWSBAIXARDOCUMENTOS:OWSDOCUMENTO                              := MANIFESTACAODESTINATARIO_ARRAYOFBAIXARDOCUMENTO():New()
	oWSdNfe:OWSBAIXARDOCUMENTOS:OWSDOCUMENTO:OWSBAIXARDOCUMENTO           := {WsClassNew("MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO") }
	oWSdNfe:OWSBAIXARDOCUMENTOS:OWSDOCUMENTO:OWSBAIXARDOCUMENTO[1]:CCHAVE := _aDocs[_x]:CCHAVE
	If oWSdNfe:BAIXARXMLDOCUMENTOS()
		conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_031] Informacoes coletadas com sucesso (chave '"+_aDocs[_x]:CCHAVE+"')...")
		If _lGeraArq
			If MemoWrite(_cDir+_aDocs[_x]:CCHAVE+"_"+DTOS(_cDtProc)+".xml",;
																	'<?xml version="1.0" encoding="UTF-8"?><nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="3.10" by="ALL System Solutions - https://allss.com.br">'+;
																	oWSdNfe:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET[1]:CNFEZIP+;
																	oWSdNfe:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET[1]:CNFEPROTZIP+;
																	'</nfeProc>')
				conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_032] Arquivo '"+_cDir+_aDocs[_x]:CCHAVE+"_"+DTOS(_cDtProc)+".xml' salvo com sucesso!")
			Else
				conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_033] Falha na gravacao do arquivo '"+_cDir+_aDocs[_x]:CCHAVE+"_"+DTOS(_cDtProc)+".xml'!")
			EndIf
		EndIf
	Else
		conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_034] Erro na obtencao do arquivo XML para a chave '"+_aDocs[_x]:CCHAVE+"': "+GetWSCError())
	EndIf
Next

conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_035] Finalizando execucao...")

Return

Static Function GetIdEnt()

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
//	conout("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_035] >>> ERRO: "+_CLRF+IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
EndIf

RestArea(aArea)

Return(cIdEnt)