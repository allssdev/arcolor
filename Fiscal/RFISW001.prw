#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
//#INCLUDE "SPEDNFE.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "SHELL.CH"

#DEFINE TAMMAXXML  400000 //- Tamanho maximo do XML em  bytes
#DEFINE VBOX       080
#DEFINE HMARGEM    030
#DEFINE _CLRF      CHR(13) + CHR(10)
//-----------------------------------------------------------------------
/*/{Protheus.doc} RFISW001
Funcao realiza a consulta do contribuinte (SA1 e SA2) junto ao Sintegra-SEFAZ.

@author  Anderson Coelho
@since 24/07/2017
@version 1.0

@see https://allss.com.br
/*/
//-----------------------------------------------------------------------
user function RFISW001()
	Local   _nOk      := 0
	Local   _nNot     := 0
	Local   _nRecno   := 0
	Local   _cAlias   := ""
	Local   _cAliHist := "SZJ"
	Local   _cUF      := ""
	Local   _cIE      := ""
	Local   _cCgc     := ""
	Local   _cCod     := ""
	Local   _cLoja    := ""
	Local _cAliasSX3 := "SX3_"+GetNextAlias()
	
	Private cIdEnt    := ""
	Private _cRotina  := "RFISW001_"+cValToChar(Randomize(1, 100000))
	Private _aUfSinte := {}
	Private _lUpdate  := .F.
	Private _lConOut  := .T.
	private _nSeq       := 1
	private _cEmp       := IIF(type("CFILANT")=="U",GetPvProfString("RFISW001_"+StrZero(_nSeq,3),"EMPRESA"   ,"",GetAdv97()),SubStr(cNumEmp,1,2))
	private _cFil       := IIF(type("CFILANT")=="U",GetPvProfString("RFISW001_"+StrZero(_nSeq,3),"FILIAL"    ,"",GetAdv97()),SubStr(cNumEmp,3,2))

	_bEmp := "IIF(type('CFILANT')=='U',GetPvProfString('RFISW001_'+StrZero(_nSeq,3),'EMPRESA'   ,'',GetAdv97()),SubStr(cNumEmp,1,2))"
	_bFil := "IIF(type('CFILANT')=='U',GetPvProfString('RFISW001_'+StrZero(_nSeq,3),'FILIAL'    ,'',GetAdv97()),SubStr(cNumEmp,3,2))"

	_bUfSinte :="SuperGetMv('"+"MV_UFSINTE"+"',,)"
	_bUpdate  := "SuperGetMv('MV_ATUSINT',,.F.)"
	_bConOut  := "SuperGetMv('MV_MSGSINT',,.T.)"

	//CONOUT("["+_cRotina+"]"+Replicate(">",20))
	while !Empty(_cEmp) .AND. !Empty(_cFil)
		//CONOUT("["+_cRotina+"_001 - "+DTOC(date())+" - "+Time()+"] INICIANDO PROCESSAMENTO DA ROTINA... Preparando para logar na empresa '"+_cEmp+"', filial '"+_cFil+"'...")
		//RpcClearEnv()
		//RPCSetType(3)
		//If RpcSetEnv(_cEmp, _cFil, , , "FIN")
		PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil MODULO 'FIN'  FUNNAME _cRotina
			//CONOUT("["+_cRotina+"_002A - "+DTOC(date())+" - "+Time()+"] Login na empresa '"+_cEmp+"', filial '"+_cFil+"' efetuado com sucesso. Colhendo os parâmetros iniciais...")
			_aUfSinte :=  &(_bUfSinte)
			_lUpdate  := &(_bUpdate)
			_lConOut  := &(_bConOut)
			cIdEnt    := GetIdEnt()
			If !Empty(cIdEnt)
				////if _lConOut;//CONOUT("["+_cRotina+"_003A - "+DTOC(date())+" - "+Time()+"] Parâmetros obtidos...");endif
			Else
				////if _lConOut;//CONOUT("["+_cRotina+"_003B - "+DTOC(date())+" - "+Time()+"] Problemas na obtenção dos parâmetros. Realizando segunda alternativa para a obtenção...");endif
				BeginSql Alias "TAB001"
					SELECT TOP 1 * FROM TSSP11.dbo.SPED001 SP01 WHERE SP01.CNPJ = %Exp:SM0->M0_CGC% AND SP01.%NotDel%
				EndSql
				MemoWrite("\2.MemoWrite\"+SubStr(_cRotina,1,AT("_",_cRotina)-1)+"_QRY_001",GetLastQuery()[02])
				dbSelectArea("TAB001")
					cIdEnt := TAB001->ID_ENT
				TAB001->(dbCloseArea())
			EndIf
			////if _lConOut;//CONOUT("["+_cRotina+"_004 - "+DTOC(date())+" - "+Time()+"] Carregando o ambiente Sped para início da consulta...");endif
			If SpedEntAtiv() .AND. IsReady()
				//Verifico a existência da tabela de Históricos do Sintegra, para gravação posterior
				OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
				dbSelectArea(_cAliasSX3)
				(_cAliasSX3)->(dbSetOrder(1))
				If !SX3->(MsSeek(_cAliHist,.T.,.F.))
					_cAliHist := ""
				EndIf
				////if _lConOut;//CONOUT("["+_cRotina+"_005A - "+DTOC(date())+" - "+Time()+"] Ambiente carregado com sucesso! Carregando clientes e fornecedores para andamento às consultas...");endif
				BeginSql Alias "CONSTMP"
						SELECT A1_FILIAL, %Exp:RetSqlName("SA1")% TAB, SA1.R_E_C_N_O_ REC, A1_EST, A1_CGC, A1_INSCR, A1_COD, A1_LOJA
						FROM %table:SA1% SA1 (NOLOCK)
						WHERE SA1.A1_FILIAL                 = %xFilial:SA1%
						  AND len(ltrim(rtrim(SA1.A1_CGC))) = %Exp:14%
						  AND SA1.A1_MSBLQL                <> %Exp:"1"%
						  AND SA1.A1_EST                  NOT IN ('  ','EX')
						  AND SA1.%NotDel%
					UNION ALL
						SELECT A2_FILIAL A1_FILIAL, %Exp:RetSqlName("SA2")% TAB, SA2.R_E_C_N_O_ REC, A2_EST A1_EST, A2_CGC A1_CGC, A2_INSCR A1_INSCR, A2_COD A1_COD, A2_LOJA A1_LOJA
						FROM %table:SA2% SA2 (NOLOCK)
						WHERE SA2.A2_FILIAL                 = %xFilial:SA2%
						  AND len(ltrim(rtrim(SA2.A2_CGC))) = %Exp:14%
						  AND SA2.A2_MSBLQL                <> %Exp:"1"%
						  AND SA2.A2_EST               NOT IN ('  ','EX')
						  AND SA2.%NotDel%
					ORDER BY A1_FILIAL, A1_EST, A1_CGC, A1_INSCR
				EndSql
			//	MemoWrite("\2.MemoWrite\"+SubStr(_cRotina,1,AT("_",_cRotina)-1)+"_QRY_002.txt",GetLastQuery()[02])
				dbSelectArea("CONSTMP")
				If !CONSTMP->(EOF())
					////if _lConOut;//CONOUT("["+_cRotina+"_006A - "+DTOC(date())+" - "+Time()+"] Clientes e Fornecedores carregados. Serão processadas '"+cValToChar(CONSTMP->(RecCount()))+"' consultas ao Sintegra...");endif
					CONSTMP->(dbGoTop())
					While !CONSTMP->(EOF())
						_cAlias := CONSTMP->TAB
						_nRecno := CONSTMP->REC
						_cUF    := CONSTMP->A1_EST
						_cIE    := CONSTMP->A1_INSCR
						_cCgc   := CONSTMP->A1_CGC
						_cCod   := CONSTMP->A1_COD
						_cLoja  := CONSTMP->A1_LOJA
						If (SubStr(_cAlias,1,3))->(FieldPos(SubStr(_cAlias,2,2)+"_MSGSINT"))>0
							////if _lConOut;//CONOUT("["+_cRotina+"_007A - "+DTOC(date())+" - "+Time()+"] Dando início ao processamento da consulta para o Alias '"+_cAlias+"', Recno '"+cValToChar(_nRecno)+"' (as informações da consulta serão gravadas no campo '"+SubStr(_cAlias,2,2)+"_MSGSINT"+"')...");endif
							If ConsCad(_cAlias,_nRecno,_cUF,_cIE,_cCgc,_cCod,_cLoja,_cAliHist)
								////if _lConOut;//CONOUT("["+_cRotina+"_008A - "+DTOC(date())+" - "+Time()+"] Alias '"+_cAlias+"', Recno '"+cValToChar(_nRecno)+"' processado com sucesso!");endif
								_nOk++
							Else
								////if _lConOut;//CONOUT("["+_cRotina+"_008B - "+DTOC(date())+" - "+Time()+"] Problemas ao processar o Alias '"+_cAlias+"', Recno '"+cValToChar(_nRecno)+"'!");endif
								_nNot++
							EndIf
						Else
							////if _lConOut;//CONOUT("["+_cRotina+"_007B - "+DTOC(date())+" - "+Time()+"] Dando início ao processamento da consulta para o Alias '"+_cAlias+"', Recno '"+cValToChar(_nRecno)+"' (as informações da consulta serão gravadas no campo '"+SubStr(_cAlias,2,2)+"_MSGSINT"+"')...");endif
							_nNot++
						EndIf
						dbSelectArea("CONSTMP")
						CONSTMP->(dbSkip())
					EndDo
					CONSTMP->(dbGoTop())
					////if _lConOut;//CONOUT("["+_cRotina+"_009 - "+DTOC(date())+" - "+Time()+"] Consulta ao Sintegra finalizada, sendo processados '"+cValToChar(_nOk)+"' registros com sucesso e '"+cValToChar(_nNot)+"' com problemas, do total de '"+cValToChar(CONSTMP->(RecCount()))+"' registros. Verifique!!!");endif
				Else
					/////if _lConOut;//CONOUT("["+_cRotina+"_006B - "+DTOC(date())+" - "+Time()+"] Nenhum Cliente e/ou Fornecedor a processar!!!");endif
				EndIf
				dbSelectArea("CONSTMP")
				CONSTMP->(dbCloseArea())
			Else
				////if _lConOut;//CONOUT("["+_cRotina+"_005B - "+DTOC(date())+" - "+Time()+"] Problemas com o ambiente. Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!");endif
			EndIf
		//Else
		//	//CONOUT("["+_cRotina+"_002B - "+DTOC(date())+" - "+Time()+"] Não foi possível logar na empresa '"+_cEmp+"', filial '"+_cFil+"'!!!")
		//EndIf
		RESET ENVIRONMENT
		_nSeq++
		_cEmp := &(_bEmp)
		_cFil := &(_bFil)
	enddo
	//CONOUT("["+_cRotina+"]"+Replicate("<",20))
return
static function ConsCad(_cAlias,_nRecno,_cUF,_cIE,_cCgc,_cCod,_cLoja,_cAliHist)
	Local   cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local   _cQry     := ""
	Local   _cMsg     := ""
	Local   _cEst     := ""
	Local   _cCnpj    := ""
	Local   _cSitua   := ""
	Local   nX        := 0
	Local   _x        := 0
	Local   _aInfo    := {}
    Local  _cAliHist := ""
	Local	_bMacro1  := "type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) == valtype(_aInfo[_x][03])"
	Local	_bMacro2  := "type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) == 'D'    .AND. valtype(_aInfo[_x][03]) == 'C' .AND.  '/' $_aInfo[_x][03]"
	Local	_bMacro3  := "type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) == 'D'    .AND. valtype(_aInfo[_x][03]) == 'C' .AND. !'/'$_aInfo[_x][03]"
	Local	_bMacro4  := "type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) == 'N'    .AND. valtype(_aInfo[_x][03]) == 'C'"
	Local	_bMacro5  := "type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) $ '/C/M/' .AND. valtype(_aInfo[_x][03]) == 'D'"
	Local	_bMacro6  := "type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) $ '/C/M/' .AND. valtype(_aInfo[_x][03]) == 'N'"

	Private oWS

	//if _lConOut;//CONOUT("["+_cRotina+"_007A.001 - "+DTOC(date())+" - "+Time()+"] Construindo informaões iniciais a partir do Web Services...");endif

	oWs             := WsNFeSBra() :New()
	oWs:cUserToken  := "TOTVS"
	oWs:cID_ENT		:= cIdEnt
	oWs:cUF		    := _cUF
	oWs:cCNPJ		:= IIF(Len(AllTrim(_cCgc))==14,AllTrim(_cCgc),"")
	oWs:cCPF		:= IIF(Len(AllTrim(_cCgc)) <14,AllTrim(_cCgc),"")
	oWs:cIE		    := StrTran(StrTran(StrTran(Alltrim(_cIE),".",""),"-",""),"/","")
	oWs:_URL        := AllTrim(cURL)+"/NFeSBRA.apw"
	VarInfo("["+_cRotina+"_007A.002 - "+DTOC(date())+" - "+Time()+"] OBJETO 'oWs' >>>", oWs)
	//if _lConOut;//CONOUT("["+_cRotina+"_007A.003 - "+DTOC(date())+" - "+Time()+"] Iniciando consulta ao Sintegra...");endif
	If oWs:CONSULTACONTRIBUINTE()
		//if _lConOut;//CONOUT("["+_cRotina+"_007A.004A - "+DTOC(date())+" - "+Time()+"] Conexão ao Sintegra realizada com sucesso...");endif
		If Type("oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE") <> "U"
			//if _lConOut;//CONOUT("["+_cRotina+"_007A.005A - "+DTOC(date())+" - "+Time()+"] Estrutura de retorno válida:");endif
			VarInfo("["+_cRotina+"_007A.006A - "+DTOC(date())+" - "+Time()+"] OBJETO 'oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE' >>>", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE)
			If ( Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE) > 0 )
				//if _lConOut;//CONOUT("["+_cRotina+"_007A.007A - "+DTOC(date())+" - "+Time()+"] Processando informações retornadas pelo Sintegra...");endif
				nX        := Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE)
				_aInfo    := {}
				_cQry     := ""
				_cMsg     := ""
				_cEst     := ""
		   		_cCnpj    := ""
		   		_cSitua   := ""
		   		If ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cUF) <> "U" .AND. !Empty(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cUF)
		   			_cEst   := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cUF
		   		EndIf
		   		If ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCnpj   ) <> "U" .AND. !Empty(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCnpj)
		   			_cCnpj  := StrZero(VAL(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCnpj),14)
		   		ElseIf ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCPf) <> "U" .AND. !Empty(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCPf )
		   			_cCnpj  := StrZero(VAL(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCPf ),11)
		   		EndIf
		   		If ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cSituacao) <> "U" .AND. !Empty(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cSituacao)
		   			_cSitua := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cSituacao
					If _cSitua == "1"
						_cSitua := "Habilitado"		//AllTrim(_cSitua)+" - Habilitado"
					ElseIf _cSitua == "0"
						_cSitua := "Não Habilitado"	//AllTrim(_cSitua)+" - Não Habilitado"
				//	ElseIf !Empty(_cSitua)
				//		_cSitua := ""				//AllTrim(_cSitua)+" - Desconhecido"
					EndIf
		   		EndIf
		   		//_aInfo:
		   		//     01 - Campo
		   		//     02 - Descrição da Informação
		   		//     03 - Conteúdo
		   		AADD(_aInfo,{SubStr(_cAlias,2,2)+"_DTNASC" , "Início das Atividades.: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dInicioAtividade            ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dInicioAtividade            , "  /  /  "), "_DTINIAT"})
				AADD(_aInfo,{SubStr(_cAlias,2,2)+"_NOME"   , "Razão Social..........: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRazaoSocial                ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRazaoSocial                , ""        ), "_NOME   "})
				AADD(_aInfo,{SubStr(_cAlias,2,2)+"_NREDUZ" , "Nome Fantasia.........: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cFantasia                   ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cFantasia                   , ""        ), "_NREDUZ "})
				AADD(_aInfo,{SubStr(_cAlias,2,2)+"_REGIME" , "Regime de Apuração....: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRegimeApuracao             ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRegimeApuracao             , ""        ), "_REGIME "})
				AADD(_aInfo,{SubStr(_cAlias,2,2)+"_CNAE"   , "CNAE..................: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCnae                       ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCnae                       , ""        ), "_CNAE   "})
				AADD(_aInfo,{SubStr(_cAlias,2,2)+"_CGC"    , "CNPJ..................: ", _cCnpj                                                                                                                                                                                                                       , "_CGC    "})
			   	AADD(_aInfo,{SubStr(_cAlias,2,2)+"_INSCR"  , "Inscr.Estadual........: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cIE                         ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cIE                         , ""        ), "_INSCR  "})
			   	AADD(_aInfo,{""                            , "Inscrição Atual.......: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cIEAtual                    ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cIEAtual                    , ""        ), "_INSCRAT"})
			   	AADD(_aInfo,{""                            , "Inscrição Única.......: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cIEUnica                    ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cIEUnica                    , ""        ), "_INSCRUN"})
				AADD(_aInfo,{SubStr(_cAlias,2,2)+"_ATIVO"  , "Situação..............: ", _cSitua                                                                                                                                                                                                                      , "_SITUACA"})
				AADD(_aInfo,{SubStr(_cAlias,2,2)+"_DTFIMV" , "Data da Baixa.........: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dBaixa                      ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dBaixa                      , "  /  /  "), "_DTBAIXA"})
			  	AADD(_aInfo,{SubStr(_cAlias,2,2)+"_DTSITUA", "Data da Última Siuação: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dUltimaSituacao             ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dUltimaSituacao             , "  /  /  "), "_DTSITUA"})
			  	If Type("oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE["+cValToChar(nX)+"]:OWSENDERECO") <> "U"
					AADD(_aInfo,{SubStr(_cAlias,2,2)+"_END"    , "Endereço..............: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cLogradouro     ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cLogradouro     , ""        ) + ", " + IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cNumero         ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cNumero, ""), "_END    "})
//					AADD(_aInfo,{SubStr(_cAlias,2,2)+"_NUM"    , "Número................: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cNumero         ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cNumero         , ""        )})
					AADD(_aInfo,{SubStr(_cAlias,2,2)+"_COMPLEM", "Complemento...........: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cComplemento    ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cComplemento    , ""        ), "_COMPLEM"})
				   	AADD(_aInfo,{SubStr(_cAlias,2,2)+"_EST"    , "UF....................: ", _cEst                                                                                                                                                                                                                        , "_EST    "})
					AADD(_aInfo,{SubStr(_cAlias,2,2)+"_CODESTS", "Cod. UF Sintegra......: ", IIF(!Empty(_cEst) .And. valtype(_aUfSinte)=="A"                                                                                             , SubStr(_aUfSinte[aScan(_aUfSinte,{|x| _cEst$x})],1,2)                                        , ""        ), "_CODUF  "})
					AADD(_aInfo,{SubStr(_cAlias,2,2)+"_COD_MUN", "Cód.Município.........: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cCodigoMunicipio) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cCodigoMunicipio, ""        ), "_COD_MUN"})
					AADD(_aInfo,{SubStr(_cAlias,2,2)+"_BAIRRO" , "Bairro................: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cBairro         ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cBairro         , ""        ), "_BAIRRO "})
					AADD(_aInfo,{SubStr(_cAlias,2,2)+"_MUN"    , "Município.............: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cMunicipio      ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cMunicipio      , ""        ), "_MUN    "})
					AADD(_aInfo,{SubStr(_cAlias,2,2)+"_CEP"    , "CEP:..................: ", IIF(ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cCEP            ) <> "U", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:OWSENDERECO:cCEP            , ""        ), "_CEP    "})
				EndIf
				_cMsg := "Informações obtidas automaticamente junto ao Sintegra em " + DTOC(Date()) + " as " + Time() + ":" + _CLRF
				_cMsg += replicate("-",len(_cMsg)-len(_CLRF)) + _CLRF
				//Atualizo o Histórico de Consulta ao Sintegra na tabela específica
				If !Empty(_cAliHist) //.AND. TCCanOpen( RetSqlName(_cAliHist) )
					dbSelectArea(_cAliHist)
					(_cAliHist)->(dbSetOrder(1))
					RecLock(_cAliHist,.T.)
					If (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+"_FILIAL")) > 0
						&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+"_FILIAL")  := xFilial(_cAliHist)
					EndIf
					If (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+"_TIPO")) > 0
						&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+"_TIPO")    := IIF(SubStr(_cAlias,1,3)=="SA1","C","F")
					EndIf
					If (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+"_CODIGO")) > 0
						&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+"_CODIGO")  := _cCod
					EndIf
					If (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+"_LOJA")) > 0
						&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+"_LOJA")    := _cLoja
					EndIf
					If (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+"_DATA")) > 0
						&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+"_DATA")    := Date()
					EndIf
					If (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+"_HORA")) > 0
						&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+"_HORA")    := Time()
					EndIf
					If (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+"_IPREQ")) > 0
						&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+"_IPREQ")   := GETCLIENTIP()
					EndIf
					If (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+"_USERREQ")) > 0
						&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+"_USERREQ") := __CUSERID + " - " + CUSERNAME
					EndIf
					If (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+"_MSBLQL")) > 0
						&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+"_MSBLQL")  := "2"
					EndIf
				EndIf
				//Inicio o cômputo das informações campo a campo
				_cQry := " UPDATE "+_cAlias+_CLRF+" SET "
					for _x := 1 to len(_aInfo)
						//Mensagem
						_cMsg += _aInfo[_x][02]
						If ValType(_aInfo[_x][03])=="D"
							_cMsg += dtoc(_aInfo[_x][03])
						ElseIf ValType(_aInfo[_x][03])=="N"
							_cMsg += cValToChar(_aInfo[_x][03])
						ElseIf ValType(_aInfo[_x][03])<>"C"
							_cMsg += "Erro: Tipo '"+ValType(_aInfo[_x][03])+"'"
						Else
							_cMsg += _aInfo[_x][03]
						EndIf
						_cMsg += _CLRF
						//Gravação das informações de Histórico das Consultas
						If !Empty(_cAliHist) .AND. (_cAliHist)->(FieldPos(SubStr(_cAliHist,2,2)+_aInfo[_x][04])) > 0	//.AND. TCCanOpen( RetSqlName(_cAliHist) )
							
							If &(_bMacro1) //type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) == valtype(_aInfo[_x][03])
								&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+_aInfo[_x][04])  := _aInfo[_x][03]
							ElseIf &(_bMacro2) //type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) == "D"    .AND. valtype(_aInfo[_x][03]) == "C" .AND.  "/"$_aInfo[_x][03]
								&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+_aInfo[_x][04])  := ctod(_aInfo[_x][03])
							ElseIf &(_bMacro3) //type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) == "D"    .AND. valtype(_aInfo[_x][03]) == "C" .AND. !"/"$_aInfo[_x][03]
								&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+_aInfo[_x][04])  := stod(_aInfo[_x][03])
							ElseIf &(_bMacro4) //type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) == "N"    .AND. valtype(_aInfo[_x][03]) == "C"
								&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+_aInfo[_x][04])  := val(_aInfo[_x][03])
							ElseIf &(_bMacro5) //type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) $ "/C/M/" .AND. valtype(_aInfo[_x][03]) == "D"
								&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+_aInfo[_x][04])  := dtos(_aInfo[_x][03])
							ElseIf &(_bMacro6) //type(SubStr(_cAliHist,2,2)+_aInfo[_x][04]) $ "/C/M/" .AND. valtype(_aInfo[_x][03]) == "N"
								&(_cAliHist+"->"+SubStr(_cAliHist,2,2)+_aInfo[_x][04])  := cvaltochar(_aInfo[_x][03])
							EndIf
						EndIf
						//Query para update
						If !Empty(_aInfo[_x][01]) .AND. (SubStr(_cAlias,1,3))->(FieldPos(_aInfo[_x][01]))>0
							If _x > 1
								_cQry += ", "
							EndIf
							_cQry += _aInfo[_x][01] + " = "
							//+ IIF(TamSx3(_aInfo[_x][01])[03]=="D", "'"+dtos(ctod(_aInfo[_x][03]))+"'", IIF(TamSx3(_aInfo[_x][01])[03]=="C", "'"+_aInfo[_x][03]+"'", _aInfo[_x][03]))
							If TamSx3(_aInfo[_x][01])[03]=="D" .OR. ValType(_aInfo[_x][03])=="C"
								If ValType(_aInfo[_x][03])=="D"
									_cQry += "'"+dtos(_aInfo[_x][03])+"'"
								ElseIf ValType(_aInfo[_x][03])=="N"
									_cQry += "'"+cValToChar(_aInfo[_x][03])+"'"
								ElseIf TamSx3(_aInfo[_x][01])[03]=="D" .AND. ValType(_aInfo[_x][03])=="C" .AND. "/"$_aInfo[_x][03]
									_cQry += "'"+dtos(ctod(_aInfo[_x][03]))+"'"
								Else
									_cQry += "'"+_aInfo[_x][03]+"'"
								EndIf
							ElseIf TamSx3(_aInfo[_x][01])[03]=="N"
								If ValType(_aInfo[_x][03])=="D"
									_cQry += dtos(_aInfo[_x][03])
								ElseIf ValType(_aInfo[_x][03])=="N"
									_cQry += cValToChar(_aInfo[_x][03])
								Else
									_cQry += _aInfo[_x][03]
								EndIf
							Else
								_cQry += "'"+_aInfo[_x][03]+"'"
							EndIf
						EndIf
					next
					//Gravação das informações de Histórico das Consultas
					If !Empty(_cAliHist) //.AND. TCCanOpen( RetSqlName(_cAliHist) )
						(_cAliHist)->(MsUnLOck())
					EndIf
				_cQry += " WHERE R_E_C_N_O_ = " + cValToChar(_nRecno)
				_cMsg += Replicate("-",50)
				////if _lConOut;//CONOUT("["+_cRotina+"_007A.008 - "+DTOC(date())+" - "+Time()+"] Gravando informações retornadas, no campo '"+(SubStr(_cAlias,2,2)+"_MSGSINT")+"'...");endif
				dbSelectArea(SubStr(_cAlias,1,3))
				(SubStr(_cAlias,1,3))->(dbSetOrder(1))
				(SubStr(_cAlias,1,3))->(dbGoTo(_nRecno))
				RecLock(SubStr(_cAlias,1,3),.F.)
					&(SubStr(_cAlias,1,3)+"->"+SubStr(_cAlias,2,2)+"_MSGSINT") := _cMsg
				(SubStr(_cAlias,1,3))->(MSUNLOCK())
				//ATUALIZA CAMPOS DA TABELA
				If _lUpdate
					////if _lConOut;//CONOUT("["+_cRotina+"_007A.008 - "+DTOC(date())+" - "+Time()+"] Realizando UPDATE na tabela '"+_cAlias+"', conforme a seguinte estrutura de dados:");endif
					VarInfo("["+_cRotina+"_007A.009 - "+DTOC(date())+" - "+Time()+"] ARRAY '_aInfo' >>>", _aInfo)
					If TCSQLExec(_cQry)<0
						////if _lConOut;//CONOUT("["+_cRotina+"_007A.010B - "+DTOC(date())+" - "+Time()+"] Problemas na execução do UPDATE na tabela '"+_cAlias+"'."+_CLRF+"[TCSQLError] " + TCSQLError());endif
					Else
						////if _lConOut;//CONOUT("["+_cRotina+"_007A.010A - "+DTOC(date())+" - "+Time()+"] UPDATE na tabela '"+_cAlias+"', processado com sucesso!!!");endif
					EndIf
					TcRefresh(SubStr(_cAlias,1,3))
				EndIf
			Else
				////if _lConOut;//CONOUT("["+_cRotina+"_007A.007B - "+DTOC(date())+" - "+Time()+"] Nenhuma informação a ser processada, conforme retorno obtido pelo Sintegra...");endif
			EndIf
		Else
			////if _lConOut;//CONOUT("["+_cRotina+"_007A.005B - "+DTOC(date())+" - "+Time()+"] Estrutura de retorno inválida:");endif
			VarInfo("["+_cRotina+"_007A.006B - "+DTOC(date())+" - "+Time()+"] OBJETO 'oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE' >>>", oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE)
		EndIf	
	Else
		////if _lConOut;//CONOUT("["+_cRotina+"_007A.004B - "+DTOC(date())+" - "+Time()+"] Não foi possível realizar a consulta ao Sintegra. Verifique o erro a seguir: "+If(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)));endif
	EndIf
return
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função para verificar se a empresa esta ativa ou não para o SPED NF-e³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function SpedEntAtiv()
	Local cEntAtiv	:= AllTrim(GetNewPar("MV_SPEDENT","S"))
	Local lOk		:= .T.
	Local lEntAtiva := .T.
	Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	//if _lConOut;//CONOUT("["+_cRotina+"_004.001 - "+DTOC(date())+" - "+Time()+"] Verificando conexão com o TSS...");endif
	If IsReady()
		//if _lConOut;//CONOUT("["+_cRotina+"_004.002A - "+DTOC(date())+" - "+Time()+"] TSS ativo. Colhendo o ID da Entidade...");endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o codigo da entidade                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		cIdEnt := GetIdEnt()
		//if _lConOut;//CONOUT("["+_cRotina+"_004.003 - "+DTOC(date())+" - "+Time()+"] Processando informações com o ID '"+cIdEnt+"' da Entidade...");endif
		If !Empty(cEntAtiv)
			//if _lConOut;//CONOUT("["+_cRotina+"_004.004 - "+DTOC(date())+" - "+Time()+"] Inicializando objeto 'oWS'...");endif
			oWS            := WSSPEDADM():New()
			oWS:_URL       := AllTrim(cURL)+"/SPEDADM.apw"	
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:nOpc       := Iif(cEntAtiv=="N",2,1)
			lOk            := oWs:ENTIDADEATIVA()
			//if _lConOut;//CONOUT("["+_cRotina+"_004.005 - "+DTOC(date())+" - "+Time()+"] Objeto 'oWS' carregado...");endif
		EndIf
		If Empty(cIdEnt) .OR. ((lOk == .T. .OR. lOk == Nil) .AND. cEntAtiv $ " N")
			//if _lConOut;//CONOUT("["+_cRotina+"_004.006B - "+DTOC(date())+" - "+Time()+"] Entidade desativada para operar no SPED! Entre em contato com o Administrador do sistema!");endif
			lEntAtiva := .F.
		ElseIf lEntAtiva
			//if _lConOut;//CONOUT("["+_cRotina+"_004.006A - "+DTOC(date())+" - "+Time()+"] Entidade ativada para processamento...");endif
		Else
			//if _lConOut;//CONOUT("["+_cRotina+"_004.006C - "+DTOC(date())+" - "+Time()+"] Entidade desativada para operar no SPED! Entre em contato com o Administrador do sistema!");endif
		EndIf
	Else
		//if _lConOut;//CONOUT("["+_cRotina+"_004.002B - "+DTOC(date())+" - "+Time()+"] O TSS não está ativo!");endif
		lEntAtiva := .F.
	EndIf
return(lEntAtiva)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetIdEnt  ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function GetIdEnt()
	Local oWs
	Local aArea      := GetArea()
	Local cIdEnt     := ""
	Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
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
	oWS:_URL                   := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		//if _lConOut;//CONOUT("["+_cRotina+"_007 - "+DTOC(date())+" - "+Time()+"] Erro: " + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)));endif
	EndIf
	RestArea(aArea)
return(cIdEnt)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsReady   ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a conexao com a Totvs Sped Services pode ser    ³±±
±±³          ³estabelecida                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: URL do Totvs Services SPED                        OPC³±±
±±³          ³ExpN2: nTipo - 1 = Conexao ; 2 = Certificado             OPC³±±
±±³          ³ExpL3: Exibe help                                        OPC³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function IsReady(cURL,nTipo,lHelp)
	Local oWS
	Local nX       := 0
	Local cHelp    := ""
	Local lRetorno := .F.

	DEFAULT nTipo := 1
	DEFAULT lHelp := .F.

	If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)
		_cAliasSX6 := "SX6_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX6,"SX6",,.F.)
		dbSelectArea(_cAliasSX6)
		(_cAliasSX6)->(dbSetOrder(1))
		
		RecLock(_cAliasSX6,.T.)
			(_cAliasSX6)->X6_FIL     := xFilial( "SX6" )
			(_cAliasSX6)->X6_VAR     := "MV_SPEDURL"
			(_cAliasSX6)->X6_TIPO    := "C"
			(_cAliasSX6)->X6_DESCRIC := "URL SPED NFe"
		(_cAliasSX6)->(MsUnLock())
		PutMV("MV_SPEDURL",cURL)
	EndIf

	SuperGetMv() //Limpa o cache de parametros - nao retirar

	DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o servidor da Totvs esta no ar                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWs := WsSpedCfgNFe():New()
	oWs:cUserToken := "TOTVS"
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If oWs:CFGCONNECT()
		lRetorno := .T.
	Else
		If lHelp
			//if _lConOut;//CONOUT("["+_cRotina+"_010 - "+DTOC(date())+" - "+Time()+"] Erro: " + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)));endif
		EndIf
		lRetorno := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o certificado digital ja foi transferido                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo <> 1 .And. lRetorno
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := GetIdEnt()
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"		
		If oWs:CFGReady()
			lRetorno := .T.
		Else
			If nTipo == 3
				cHelp := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				If lHelp .And. !"003" $ cHelp
					//if _lConOut;//CONOUT("["+_cRotina+"_011 - "+DTOC(date())+" - "+Time()+"] " + cHelp);endif
					lRetorno := .F.
				EndIf		
			Else
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o certificado digital ja foi transferido                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 2 .And. lRetorno
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := GetIdEnt()
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"		
		If oWs:CFGStatusCertificate()
			If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
				For nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
					If oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO-30 <= Date()
						//if _lConOut;//CONOUT("["+_cRotina+"_012 - "+DTOC(date())+" - "+Time()+"] O certificado digital irá vencer em: "+Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO));endif
				    EndIf
				Next nX		
			EndIf
		EndIf
	EndIf
return(lRetorno)