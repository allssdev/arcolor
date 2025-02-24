#INCLUDE 'rwmake.ch'
#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'topconn.ch'
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

#DEFINE _CLRF CHR(13)+CHR(10)
/*/{Protheus.doc} RFISA006
//Execblock utilizado para colher a tabela de alíquotas da Lei de Transparência no IBPT online, por meio da URL URL: http://iws.ibpt.org.br/api/Produtos.
//Recomendamos que esta rotina seja chamada via Schedule
@author Anderson C. P. Coelho
@since 06/02/2017
@country Brazil
@version Protheus 11.8 - Revisão 1.0.0

@type function

@param MV_IBPTTK, caracter, Token para acesso ao site do IBPT para a coleta da tabela de aliquotas da Lei de Transparencia. URL: http://iws.ibpt.org.br/api/Produtos.
@param MV_IBPTURL, caracter, URL do IBPT para obtenção da tabela de tributos relativa a Lei de Transparência.

@return nulo

@history 2017-02-06, Anderson C. P. Coelho, Criação da rotina
@history 2017-02-14, Anderson C. P. Coelho, Validação da rotina (alteração na gravação dos dados - ao invés de SB1/SYD/EL0, passa-se a gravar na tabela CLK)
/*/
user function RFISA006()
	Private _cRotina   := "RFISA006"
	Private _cToken    := ""
	Private _cUrl      := ""
	Private _cEmp      := ""		//GetPvProfString(_cRotina,"EMPRESA"    ,"01"           ,GetAdv97())
	Private _cFil      := ""		//GetPvProfString(_cRotina,"FILIAL"     ,"01"           ,GetAdv97())
	Private _nSeqJob   := 0
	Private _nContJob  := 0
	Private _lProc     := .T.

	//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_001] Iniciando a rotina...")
	//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_002] Verificando parametros iniciais...")
	While _lProc
		_nSeqJob++
		//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_003] Verificando existencia do JOB '"+(_cRotina+"_"+StrZero(_nSeqJob,3))+"'...")
		_cFil         := ""
		_cEmp         := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"EMPRESA"    ,"",GetAdv97())
		If !Empty(_cEmp)
			_cFil     := GetPvProfString(_cRotina+"_"+StrZero(_nSeqJob,3),"FILIAL"     ,"",GetAdv97())
			_lProc    := .T.
			_nContJob++
			//CONOUT(Replicate("*",15)+"["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_004] Os processos serao executados considerando as seguintes configuracoes do server job '"+(_cRotina+"_"+StrZero(_nSeqJob,3))+"':"+_CLRF+"Empresa/Filial: "+_cEmp+"/"+_cFil)
			Check01()
		Else
			//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_005] JOB '"+(_cRotina+"_"+StrZero(_nSeqJob,3))+"' nao existe ou foi configurado incorretamente. Processamento abortado (para este server job)!!!")
			_lProc := .F.
		EndIf
	EndDo
	If !_lProc .AND. _nContJob == 0
		//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_006] Execução da rotina fora do JOB...")
		Check01()
	EndIf

	//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_007] FINISH!!!")

	return
static function Check01()
	Local oObjJson
	Local _cQry      := ""
	Local _cRet      := ""
	Local _cAlias    := ""
	Local cErro      := ""
	Local cHeadRet   := ""
	Local _cGParams  := ""
	Local _cHeadGt   := ""
	Local _cRet      := ""
	Local _cParam    := ""
	Local nTimeOut   := 200
	Local _aHeader   := {}
	Local _lProc     := .T.

	//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_008] Preparando ambiente...")
	//If Type("cFilAnt")=="U"
		RpcClearEnv()
		RPCSetType(3)
		If Empty(_cEmp) .OR. Empty(_cFil) .OR. !RpcSetEnv(_cEmp, _cFil, , , "FIS")
			//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_009] Falha ao carregar o ambiente (empresa: '"+_cEmp+"' / filial: '"+_cFil+"'). PROCESSAMENTO ABORTADO!")
			return
		EndIf
	//EndIf

	//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_010] Iniciando processamento na empresa '"+SubStr(cNumEmp,1,2)+"' e filial '"+SubStr(cNumEmp,3,2)+"' para o CNPJ '" + SM0->M0_CGC + "'...")

	_cUrl      := SuperGetMv("MV_IBPTURL",,"http://iws.ibpt.org.br/api/Produtos")		//URL para acesso ao IBPT
	_cToken    := SuperGetMv("MV_IBPTTK",,""              						)		//Token para acesso ao IBPT

	/*
	aadd(_aHeader,'GET '   + AllTrim(_cUrl) + ' HTTP/1.1 ')
	aadd(_aHeader,'Host '   + AllTrim(_cHost)             )
	aadd(_aHeader,'Accept: application/json'              )
	aadd(_aHeader,'Content-Type: application/json'        )
	aadd(_aHeader,'token: ' + _cToken                     )
	aadd(_aHeader,'cnpj: '  + AllTrim(SM0->M0_CGC)        )
	//aadd(_aHeader,'cache-Control: no-cache'               )
	//aadd(_aHeader,'pragma: no-cache'                      )
	aadd(_aHeader,'User-Agent: TOTVS (compatible; Protheus '+GetBuild()+')')
	*/
	#IFDEF TOP
		_cAlias	:= GetNextAlias()						// Pega o proximo Alias Disponivel
		BeginSql Alias _cAlias
			SELECT DISTINCT B1_POSIPI 
			FROM %table:SB1% SB1
			WHERE SB1.B1_FILIAL  = %xFilial:SB1% 
			  AND SB1.B1_POSIPI <> '' 
			  //AND SB1.B1_CODBAR <> '' 
			  //AND SB1.B1_MSBLQL <> '1'
			  //AND SB1.B1_TIPO   IN ('PA','PI','MP','EM')
			  AND SB1.%NotDel%
			//ORDER BY B1_TIPO, B1_COD
		EndSql
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",GetLastQuery()[02])
		dbSelectArea(_cAlias)
		(_cAlias)->(dbGoTop())
		While !(_cAlias)->(EOF())
			_cParam := "token="+_cToken
			_cParam += "&cnpj="+AllTrim(SM0->M0_CGC)
			_cParam += "&codigo="+AllTrim((_cAlias)->B1_POSIPI)
			_cParam += "&uf="+AllTrim(SM0->M0_ESTENT)
			_cParam += "&ex=0"
			//_cParam += "&codigoInterno="+AllTrim((_cAlias)->B1_COD)
			//_cParam += "&descricao="+AllTrim((_cAlias)->B1_DESC)
			//_cParam += "&unidadeMedida="+AllTrim((_cAlias)->B1_UM)
			//_cParam += "&gtin="+AllTrim((_cAlias)->B1_CODBAR)
			_cRet := HttpGet(_cUrl,_cParam,nTimeOut,_aHeader,@cHeadRet)
			MemoWrite("\2.MemoWrite\"+_cRotina+" - HTTPGET - _aHeader.txt",VarInfo(_cRotina+"_011 - HTTPGET (_aHeader)", _aHeader))
			MemoWrite("\2.MemoWrite\"+_cRotina+" - HTTPGET - _cRet.txt"   ,VarInfo(_cRotina+"_012 - HTTPGET (_cRet)"   , _cRet   ))
				//RFISA006_012 - HTTPGET (_cRet) -> C (  296) [{"Codigo":"19012000","UF":"SP","EX":0,"Descricao":"Misturas e pastas,p/prepar.prods.padaria, pastelaria,etc","Nacional":13.45,"Estadual":12.00,"Importado":27.73,"Municipal":0.00,"Tipo":"0","VigenciaInicio":"01/01/2017","VigenciaFim":"30/06/2017","Chave":"W7m9E1","Versao":"17.1.A","Fonte":"IBPT"}]
			MemoWrite("\2.MemoWrite\"+_cRotina+" - HTTPGET - cErro.txt"   ,VarInfo(_cRotina+"_013 - HTTPGET (cErro)"   , cErro   ))
				//RFISA006_013 - HTTPGET (cErro) -> C (    4) [OK]
			MemoWrite("\2.MemoWrite\"+_cRotina+" - HTTPGET - cHeadRet.txt",VarInfo(_cRotina+"_014 - HTTPGET (cHeadRet)", cHeadRet))
				/*
					RFISA006_014 - HTTPGET (cHeadRet) -> C (  289) [HTTP/1.1 200 OK
					Cache-Control: no-cache
					Pragma: no-cache
					Content-Type: application/json; charset=utf-8
					Expires: -1
					Server: Microsoft-IIS/8.5
					X-AspNet-Version: 4.0.30319
					X-Powered-By: ASP.NET
					Access-Control-Allow-Origin: *
					Date: Tue, 07 Feb 2017 01:08:41 GMT
					Content-Length: 296
				*/
			If HTTPGetStatus(cErro) <> 200
				//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_015] ERRO de HTTPGetStatus: " + cValToChar(HTTPGetStatus(cErro)))
			Else
				If !FWJsonDeserialize(_cRet,@oObjJson)
					//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_016] ERRO de FWJsonDeserialize!")
				Else
					MemoWrite("\2.MemoWrite\"+_cRotina+" - HTTPGET - FWJsonDeserialize - oObjJson.txt",VarInfo(_cRotina+"_017 - FWJsonDeserialize (oObjJson)", oObjJson))
					/*
						{
						  "Codigo": "19012000",
						  "UF": "SP",
						  "EX": 0,
						  "Descricao": "Misturas e pastas,p/prepar.prods.padaria, pastelaria,etc",
						  "Nacional": 13.45,
						  "Estadual": 12,
						  "Importado": 27.73,
						  "Municipal": 0,
						  "Tipo": "0",
						  "VigenciaInicio": "01/01/2017",
						  "VigenciaFim": "30/06/2017",
						  "Chave": "W7m9E1",
						  "Versao": "17.1.A",
						  "Fonte": "IBPT"
						}
					*/
					/*
						RFISA006_017 - FWJsonDeserialize (oObjJson) -> OBJECT (   14) [...]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):CHAVE -> C (    6) [W7m9E1]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):CODIGO -> C (    8) [19012000]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):DESCRICAO -> C (   56) [Misturas e pastas,p/prepar.prods.padaria, pastelaria,etc]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):ESTADUAL -> N (   15) [        12.0000]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):EX -> N (   15) [         0.0000]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):FONTE -> C (    4) [IBPT]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):IMPORTADO -> N (   15) [        27.7300]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):MUNICIPAL -> N (   15) [         0.0000]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):NACIONAL -> N (   15) [        13.4500]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):TIPO -> C (    1) [0]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):UF -> C (    2) [SP]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):VERSAO -> C (    6) [17.1.A]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):VIGENCIAFIM -> C (   10) [30/06/2017]
						     RFISA006_017 - FWJsonDeserialize (oObjJson):VIGENCIAINICIO -> C (   10) [01/01/2017]
					*/
					/*
					_cQry := " UPDATE " + RetSqlName("SYD")
					_cQry += " SET YD_ALIQIMP = " + cValToChar(oObjJson:nacional+oObjJson:estadual+oObjJson:municipal)
					_cQry += "   , YD_ALIQIM2 = " + cValToChar(oObjJson:importado                                    )
					_cQry += " WHERE YD_TEC   = '"+AllTrim(oObjJson:codigo)+"' AND D_E_L_E_T_ = '' "
					If TCSQLExec(_cQry)<0
						//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_018] ERRO na atualização da SYD (NCM '"+AllTrim(oObjJson:codigo)+"'): [TCSQLError] " + TCSQLError())
					Else
						//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_020] Atualização da SYD (NCM '"+AllTrim(oObjJson:codigo)+"') realizada com sucesso!")
					EndIf
					_cQry := " UPDATE " + RetSqlName("EL0")
					_cQry += " SET EL0_ALIQIM = " + cValToChar(oObjJson:nacional+oObjJson:estadual+oObjJson:municipal)
					_cQry += "   , EL0_ALIQI2 = " + cValToChar(oObjJson:importado                                    )
					_cQry += " WHERE EL0_COD  = '"+AllTrim(oObjJson:codigo)+"' AND D_E_L_E_T_ = '' "
					If TCSQLExec(_cQry)<0
						//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_021] ERRO na atualização da EL0 (NCM '"+AllTrim(oObjJson:codigo)+"'): [TCSQLError] " + TCSQLError())
					Else
						//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_022] Atualização da EL0 (NCM '"+AllTrim(oObjJson:codigo)+"') realizada com sucesso!")
					EndIf
					_cQry := " UPDATE " + RetSqlName("SB1")
					_cQry += " SET B1_IMPNCM   = (CASE WHEN B1_IMPORT = 'S' THEN " + cValToChar(oObjJson:importado) + " ELSE " + cValToChar(oObjJson:nacional+oObjJson:estadual+oObjJson:municipal) + " END) "
					_cQry += " WHERE B1_POSIPI = '" + AllTrim(oObjJson:codigo) + "' AND D_E_L_E_T_ = '' "
					If TCSQLExec(_cQry)<0
						//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_023] ERRO na atualização da SB1 (NCM '"+AllTrim(oObjJson:codigo)+"'): [TCSQLError] " + TCSQLError())
					Else
						//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_024] Atualização da SB1 (NCM '"+AllTrim(oObjJson:codigo)+"') realizada com sucesso!")
					EndIf
					*/
					dbSelectArea("CLK")
					CLK->(dbSetOrder(2))	//CLK_FILIAL+CLK_CODNCM+CLK_EX+CLK_UF+DTOS(CLK_DTINIV)+DTOS(CLK_DTFIMV)
					If CLK->(dbSeek(xFilial("CLK") + Padr(oObjJson:codigo,Len(CLK->CLK_CODNCM))))
						RecLock("CLK",.F.)
					Else
						RecLock("CLK",.T.)
						CLK->CLK_FILIAL := xFilial("CLK")
						CLK->CLK_CODNCM := oObjJson:codigo
						CLK->CLK_CODNBS := ""
					EndIf
					CLK->CLK_UF     := oObjJson:uf
					CLK->CLK_EX     := cValToChar(oObjJson:ex)
					CLK->CLK_DESCR  := UPPER(oObjJson:descricao)
					CLK->CLK_ALQNAC := oObjJson:nacional
					CLK->CLK_ALQEST := oObjJson:estadual
					CLK->CLK_ALQIMP := oObjJson:importado
					CLK->CLK_ALQMUN := oObjJson:municipal
					CLK->CLK_DTINIV := CTOD(oObjJson:vigenciainicio)
					CLK->CLK_DTFIMV := CTOD(oObjJson:vigenciafim)
					CLK->CLK_VERSAO := oObjJson:versao
					CLK->CLK_FONTE  := oObjJson:fonte
					CLK->(MSUNLOCK())
					//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_025] Atualização da CLK (NCM '"+AllTrim(oObjJson:codigo)+"') realizada com sucesso!")
					dbSelectArea("SYD")
					SYD->(dbSetOrder(1))	//YD_FILIAL+YD_TEC+YD_EX_NCM+YD_EX_NBM
					If !SYD->(dbSeek(xFilial("SYD") + Padr(oObjJson:codigo,Len(SYD->YD_TEC))))
						RecLock("SYD",.T.)
						SYD->YD_FILIAL := xFilial("SYD")
						SYD->YD_TEC    := oObjJson:codigo
						SYD->YD_DESC_P := UPPER(oObjJson:descricao)
						SYD->(MSUNLOCK())
						//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_026] NCM '"+AllTrim(oObjJson:codigo)+"' incluído com sucesso na tabela SYD!")
					EndIf
				EndIf
			EndIf
			dbSelectArea(_cAlias)
			(_cAlias)->(dbSkip())
		EndDo
		(_cAlias)->(dbCloseArea())
	#ELSE
		//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_018] ROTINA PREPARADA APENAS PARA TOPCONNECT. PROCESSAMENTO ABORTADO!!!")
	#ENDIF
	//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_019] *************************") 
	//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_020] Processamento finalizado!")
	//CONOUT("["+DTOC(Date())+" "+Time()+" - "+_cRotina+"_021] *************************")
return