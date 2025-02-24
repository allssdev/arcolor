#include "totvs.ch"
/*/{Protheus.doc} RTMKE006
EXECBLOCK  para disparar os gatilhos a partir do campo código do produto no callcenter (CD Control).
@author Renan Felipe
@since 29/12/2012
@version P12.1.2310
@type function
@see https://allss.com.br
@history 11/03/2014, Adriano Leonardo, Nesta rotina foi inclusa a sugestão do desconto no atendimento, com base nas regras de negócios seguindo prioridades específicas da empresa.
@history 12/01/2024, Rodrigo Telecio (rodrigo.telecio@allss.com.br), #7110 - Adequações no processo de faturamento de consignado.
/*/
user function RTMKE006()
	//No Início da rotina, salvar o ReadVar:
	Local _aSavAr  		:= GetArea()
	Local _aSavSUA      := SUA->(GetArea())
	Local _aSavSUB      := SUB->(GetArea())
	Local _aSavSB1      := SB1->(GetArea())
	Local _aSavSF4      := SF4->(GetArea())
	Local _aSavSUS      := SUS->(GetArea())
	Local _aSavSU7      := SU7->(GetArea())
	Local _aSavSA1      := SA1->(GetArea())
	Local _aSavSA7      := SA7->(GetArea())
	Local _aSavSX3      := iif(Select("SX3") > 0, SX3->(GetArea()), {})
	Local _cAliasSX3    := GetNextAlias()
	Local _cAliQry      := GetNextAlias()
	Local _cRVarBkp		:= __ReadVar
	Local _cContBkp		:= &(_cRVarBkp)
	Local _cRotina 		:= "RTMKE006"
	Local _cFName       := UPPER(AllTrim(FunName()))
	Local _cCpoCab 		:= iif(_cFName=="MATA410".OR._cFName=="MATA440".OR._cFName=="RFATA012","C5_","UA_")
	Local _cCpoIte 		:= iif(_cFName=="MATA410".OR._cFName=="MATA440".OR._cFName=="RFATA012","C6_","UB_")
	Local _nBkp    		:= n
	Local _nPAtu   		:= aScan(aHeader,{|x|AllTrim(x[02])==SubStr(__ReadVar,AT(_cCpoIte,__ReadVar))})
	Local _nPProd  		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"PRODUTO"                   )})
	Local _nPOper  		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"OPER"                      )})
	Local nPLocal  		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte + "LOCAL"                   )})
	Local _nPTES   		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"TES"                       )})
	Local _nQuant  		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"QUANT"                     )})
	Local _nCodfat		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"CODFATR"                   )})
	Local _nPDesc1 		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"DESCTV1"                   )})
	Local _nPDesc2 		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"DESCTV2"                   )})
	Local _nPDesc3 		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"DESCTV3"                   )})
	Local _nPDesc4 		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"DESCTV4"                   )})
	Local _cFator  		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"FATOR"                     )})
	Local _nPDesc  		:= aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"DESC"                      )})
	Local _nPDescA 		:= iif(_cFName=="TMKA271" .OR. _cFName=="RTMKI001" .OR. _cFName=="RPC",aScan(aHeader,{|x|AllTrim(x[02])==(_cCpoIte+"DESCAUX")}),0)
	Local _lRet    		:= .T.
	Local _cValid		:= ".T."
//	Local _cLog    	  	:= ""		//Variável de cômputo do tempo de processamento
	Local _cCodReg      := ""
	Local _cCodFat      := iif(_nCodfat>0,CriaVar(_cCpoIte+"CODFATR"),"")
	Local _cTESAD1      := AllTrim(SuperGetMV("MV_TESPAD1",,"999"))
	Local _nDesc1       := 0
	Local _nDesc2       := 0
	Local _nDesc3       := 0
	Local _nDesc4       := 0
	Local _nSugDes      := SuperGetMV("MV_SUGDESC",,0)
	Local _lU7SuDes     := SU7->(FieldPos("U7_SUGDESC"))<>0
	Local _lA7DesFat    := SA7->(FieldPos("A7_DESCFAT"))<>0
	Local _nPDescon     := TamSx3("ACN_DESCON")[02]
	//**********************************************************************
	// INICIO
	// ARCOLOR - Adequação para preenchimento do armazém de forma automática
	// dependendo do tipo de operação a ser praticada no cabeçalho do 
	// orçamento/pedido de venda
	// RODRIGO TELECIO em 12/01/2024
	//**********************************************************************	
	local cTpOper   	:= AllTrim(SuperGetMV("MV_XTPOVLD",.F.,"VC"))
	// FIM
	//**********************************************************************
	Private _nDescAux 	:= 0

//	_cLog += "[000] Início: " + DTOC(Date()) + " " + Time() + CRLF
	if ExistBlock("RTMKE033") .AND. !(_lRet := U_RTMKE033())
//		_cLog += "[011] Finish: " + DTOC(Date()) + " " + Time() + CRLF
//		if AllTrim(__cUserId)=="000000"
//			MemoWrite("\2.MemoWrite\"+_cRotina+"_LOG_002.TXT",_cLog)
//		endif
		if len(_aSavSX3) > 0
			RestArea(_aSavSX3)
		endif
		RestArea(_aSavSUA)
		RestArea(_aSavSUB)
		RestArea(_aSavSUS)
		RestArea(_aSavSU7)
		RestArea(_aSavSA7)
		RestArea(_aSavSA1)
		RestArea(_aSavSB1)
		RestArea(_aSavSF4)
		RestArea(_aSavAr)
		return _lRet
	endif
	//INICIO CUSTOM. ALLSS - 20/05/2019 - Anderson Coelho - Alteração do método de pesquisa na SX3 para a função OpenSXs, em decorrência da migração de release (12.1.17 para 12.1.23) prevista para 06/2019 em produção.
		//OpenSxs(	<oParam1 >, ;		//Compatibilidade
		//			<oParam2 >, ;		//Compatibilidade
		//			<oParam3 >, ;		//Compatibilidade
		//			<oParam4 >, ;		//Compatibilidade
		//			<cEmpresa >, ;		//Empresa que se deseja abrir o dicionário, se não informado utilizada a empresa atual (cEmpAnt) 
		//			<cAliasSX >, ;		// Alias que será utilizado para abrir a tabela 
		//			<cTypeSX >, ;		// Tabela que será aberta 
		//			<oParam8 >, ;		//Compatibilidade
		//			<lFinal >, ;		// Indica se deve chamar a função FINAL caso a tabela não exista (.T.)
		//			<oParam10 >, ;		//Compatibilidade
		//			<lShared >, ;		// Indica se a tabela deve ser aberta em modo compartilhado ou exclusivo (.T.)
		//			<lCreate >) 		// Indica se deve criar a tabela, caso ela não exista
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)		//OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.T.,,.F.,.F.)		
		if Select(_cAliasSX3) <= 0
			MsgAlert("Atenção! Problemas na abertura do dicionário 'SX3' via função 'OPENSXS'. Informe a ocorrência ao Administrador!",_cRotina+"_001")
			_cAliasSX3 := "SX3"
			_lRet      := .F.
			if len(_aSavSX3) > 0
				RestArea(_aSavSX3)
			endif
			RestArea(_aSavSUA)
			RestArea(_aSavSUB)
			RestArea(_aSavSUS)
			RestArea(_aSavSU7)
			RestArea(_aSavSA7)
			RestArea(_aSavSA1)
			RestArea(_aSavSB1)
			RestArea(_aSavSF4)
			RestArea(_aSavAr)
			return _lRet
		endif
		dbSelectArea(_cAliasSX3)
	//FIM CUSTOM. ALLSS - 20/05/2019 - Anderson Coelho - Alteração do método de pesquisa na SX3 para a função OpenSXs, em decorrência da migração de release (12.1.17 para 12.1.23) prevista para 06/2019 em produção.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Trecho inserido por Júlio Soares em 19/12/2013 para atualizar os descontos do item do atendimento/pedido             ³
	//³com o conteúdo respectivo das regras de desconto.                                                                    ³
	//³Para o funcionamento dessa validação é necessário que o campo de validação do usuário (X3_VLDUSER) esteja            ³
	//³preenchido com a função (iif(EXISTBLOCK("RTMKE006"),EXECBLOCK("RTMKE006"),.T.)) para os campos UB_PRODUTO e UB_QUANT.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	_cLog += "[001] Início da sugestão de desconto: " + DTOC(Date()) + " " + Time() + CRLF
	if _cFName=="TMKA271" .OR. _cFName=="RTMKI001" .OR. _cFName=="RPC"
		/*
		MV_SUGDESC = 0 -- Não sugere desconto (temporariamente está sugerindo com base nas definições antigas)
		MV_SUGDESC = 1 -- Sugere desconto com base nas regras de negócios
		MV_SUGDESC = 2 -- Sugere desconto com base no último pedido faturado
		*/
		if !empty(aCols[n][_nPProd]) .AND. _nSugDes==1
			_lSEspecif := .F. //Sugere apenas desconto específico do grupo de vendas
			//Salvo a área atual
			_aSavSU7 := SU7->(GetArea())
			dbSelectArea("SU7")
			SU7->(dbOrderNickName("U7_COD"))		//dbSetOrder(1) //Filial + Código do operador
			if SU7->(MsSeek(xFilial("SU7")+M->UA_OPERADO,.T.,.F.))
				if _lU7SuDes
					if SU7->U7_SUGDESC=="S" //Verifico o cadastro do operador para avaliar se o desconto será sugerido ou não
						_lSEspecif := .F.
					else
						_lSEspecif := .T.
					endif
				else
					MsgAlert("Informe ao Administrador que o campo U7_SUGDESC precisa ser criado!", _cRotina + "_001")
				endif
			endif
	        //Restauro o posicionamento inicial da tabela
			RestArea(_aSavSU7)
			//Consulta utilizada para selecionar a regra a ser sugerida no atendimento
			//IMPORTANTE: Ao alterar essa query, atentar para que as mesmas alterações sejam feitas na query do ponto de entrada FT100RNI
			_cQuery := " SELECT NIVEL,ACN_CODREG,ACN_CODFAT,ACN_DESCV1,ACN_DESCV2,ACN_DESCV3,ACN_DESCV4,ACN_PROMOC,ACN_DESCON " + CRLF
			_cQuery += " FROM ( " + CRLF
			//AVALIO SE HÁ REGRA POR CLIENTE - NIVEL 1
			_cQuery += "	SELECT 1 AS [NIVEL], ACN_CODREG, ACN_CODPRO, ACN_DESCON, ACN_QUANTI, ACN_PROMOC, ACN_CODFAT, ACN_DESCV1, ACN_DESCV2, ACN_DESCV3, ACN_DESCV4 " + CRLF
			_cQuery += "    FROM " + RetSqlName("ACN") + " ACN (NOLOCK) " + CRLF
			_cQuery += "		INNER JOIN " + RetSqlName("ACS") + " ACS (NOLOCK) ON ACS.ACS_FILIAL   = '" + xFilial("ACS") + "' " + CRLF
			_cQuery += "  					AND ACS.ACS_CODCLI   = '" + M->UA_CLIENTE  + "' " + CRLF
			_cQuery += "  					AND ACS.ACS_LOJA     = '" + M->UA_LOJA     + "' " + CRLF
			_cQuery += " 					AND (ACS.ACS_DATATE  = '' OR ACS.ACS_DATDE  <= '" + DTOS(dDataBase) + "') " + CRLF
			_cQuery += " 					AND (ACS.ACS_DATATE  = '' OR ACS.ACS_DATATE >= '" + DTOS(dDataBase) + "') " + CRLF
			_cQuery += "					AND ACS.ACS_CODREG   = ACN.ACN_CODREG " + CRLF
			_cQuery += "					AND ACS.D_E_L_E_T_ = '' " + CRLF
			_cQuery += "		INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_FILIAL    = '" + xFilial("SB1")    + "' " + CRLF
			_cQuery += "  					AND SB1.B1_COD       = '" + aCols[n][_nPProd] + "' " + CRLF
			_cQuery += "  					AND (SB1.B1_COD      = ACN.ACN_CODPRO OR (SB1.B1_GRUPO <> '' AND SB1.B1_GRUPO = ACN.ACN_GRPPRO)) " + CRLF
			_cQuery += "  					AND SB1.D_E_L_E_T_ = '' " + CRLF
			_cQuery += "  		WHERE ACN.ACN_FILIAL  = '" + xFilial("ACN") + "' " + CRLF
			_cQuery += " 		  AND (ACN.ACN_DATINI = '' OR ACN.ACN_DATINI <= '" + DTOS(dDataBase) + "') " + CRLF
			_cQuery += " 		  AND (ACN.ACN_DATFIM = '' OR ACN.ACN_DATFIM >= '" + DTOS(dDataBase) + "') " + CRLF
			_cQuery += "  		  AND ACN.ACN_QUANTI >= " + Str(aCols[n][_nQuant]) + CRLF
			_cQuery += "		  AND ACN.ACN_QUANTI  = (SELECT MIN(AUX.ACN_QUANTI) " + CRLF
			_cQuery += "								 FROM " + RetSqlName("ACN") + " AUX " + CRLF
			_cQuery += "								 WHERE AUX.ACN_FILIAL  = '" + xFilial("ACN") + "' " + CRLF
			_cQuery += "								   AND AUX.ACN_QUANTI >= " + Str(aCols[n][_nQuant]) + CRLF
			_cQuery += "								   AND AUX.ACN_CODREG  = ACN.ACN_CODREG " + CRLF
			_cQuery += "	                               AND (AUX.ACN_CODPRO = ACN.ACN_CODPRO AND AUX.ACN_GRPPRO = ACN.ACN_GRPPRO) " + CRLF
			_cQuery += "	                               AND AUX.D_E_L_E_T_  = '' " + CRLF
			_cQuery += "								) " + CRLF
			_cQuery += "		  AND ACN.D_E_L_E_T_  = '' " + CRLF
			_cQuery += " UNION ALL " + CRLF
			//AVALIO SE HÁ REGRA POR GRUPO - NIVEL 2
			_cQuery += "	SELECT 2 AS [NIVEL], ACN_CODREG, ACN_CODPRO, ACN_DESCON, ACN_QUANTI, ACN_PROMOC, ACN_CODFAT, ACN_DESCV1, ACN_DESCV2, ACN_DESCV3, ACN_DESCV4 "
			_cQuery += "	FROM " + RetSqlName("ACN") + " ACN (NOLOCK) " + CRLF
			_cQuery += "		INNER JOIN " + RetSqlName("ACS") + " ACS (NOLOCK) ON ACS.ACS_FILIAL   = '" + xFilial("ACS") + "' " + CRLF
			_cQuery += " 					AND (ACS.ACS_DATATE  = '' OR ACS.ACS_DATDE  <= '" + DTOS(dDataBase) + "') " + CRLF
			_cQuery += " 					AND (ACS.ACS_DATATE  = '' OR ACS.ACS_DATATE >= '" + DTOS(dDataBase) + "') " + CRLF
			_cQuery += "					AND ACS.ACS_CODREG   = ACN.ACN_CODREG " + CRLF
			_cQuery += "					AND ACS.D_E_L_E_T_ = '' " + CRLF
			_cQuery += "		INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_FILIAL    = '" + xFilial("SB1")    + "' " + CRLF
			_cQuery += "  					AND SB1.B1_COD       = '" + aCols[n][_nPProd] + "' " + CRLF
			_cQuery += "  					AND (SB1.B1_COD      = ACN.ACN_CODPRO OR (SB1.B1_GRUPO <> '' AND SB1.B1_GRUPO = ACN.ACN_GRPPRO)) " + CRLF
			_cQuery += "  					AND SB1.D_E_L_E_T_   = '' " + CRLF
			_cQuery += "		INNER JOIN " + RetSqlName("SA1") + " SA1 (NOLOCK) ON SA1.A1_FILIAL    = '" + xFilial("SA1") + "' " + CRLF
			_cQuery += "  					AND SA1.A1_COD       = '" + M->UA_CLIENTE + "' " + CRLF
			_cQuery += "  					AND SA1.A1_LOJA      = '" + M->UA_LOJA + "' " + CRLF
			_cQuery += "  					AND SA1.A1_GRPVEN   <> '' " + CRLF
			_cQuery += "  					AND SA1.A1_GRPVEN    = ACS.ACS_GRPVEN " + CRLF
			_cQuery += "  					AND SA1.D_E_L_E_T_   = '' " + CRLF
			_cQuery += "  		WHERE ACN.ACN_FILIAL  = '" + xFilial("ACN") + "' " + CRLF
			_cQuery += " 		  AND (ACN.ACN_DATINI = '' OR ACN.ACN_DATINI <= '" + DTOS(dDataBase) + "') " + CRLF
			_cQuery += " 		  AND (ACN.ACN_DATFIM = '' OR ACN.ACN_DATFIM >= '" + DTOS(dDataBase) + "') " + CRLF
			_cQuery += "  		  AND ACN.ACN_QUANTI >= " + Str(aCols[n][_nQuant]) + CRLF
			_cQuery += "		  AND ACN.ACN_QUANTI  = (SELECT MIN(AUX.ACN_QUANTI) " + CRLF
			_cQuery += "								 FROM " + RetSqlName("ACN") + " AUX (NOLOCK) " + CRLF
			_cQuery += "								 WHERE AUX.ACN_FILIAL  = '" + xFilial("ACN") + "' " + CRLF
			_cQuery += "								   AND AUX.ACN_QUANTI >= " + Str(aCols[n][_nQuant]) + CRLF
			_cQuery += "								   AND AUX.ACN_CODREG  = ACN.ACN_CODREG " + CRLF
			_cQuery += "	                               AND (AUX.ACN_CODPRO = ACN.ACN_CODPRO AND AUX.ACN_GRPPRO = ACN.ACN_GRPPRO) " + CRLF
			_cQuery += "	                               AND AUX.D_E_L_E_T_  = '' " + CRLF
			_cQuery += "								) " + CRLF
			_cQuery += "		  AND ACN.D_E_L_E_T_  = '' " + CRLF
			if !_lSEspecif
				_cQuery += "UNION ALL " + CRLF
				//AVALIO SE HÁ REGRA PROMOCIONAL - NIVEL 3
				_cQuery += "	SELECT 3 AS [NIVEL], ACN_CODREG, ACN_CODPRO, ACN_DESCON, ACN_QUANTI, ACN_PROMOC, ACN_CODFAT, ACN_DESCV1, ACN_DESCV2, ACN_DESCV3, ACN_DESCV4 " + CRLF
				_cQuery += "	FROM " + RetSqlName("ACN") + " ACN (NOLOCK) " + CRLF
				_cQuery += "		INNER JOIN " + RetSqlName("ACS") + " ACS (NOLOCK) ON ACS.ACS_FILIAL  = '" + xFilial("ACS") + "' " + CRLF
				_cQuery += " 			AND (ACS.ACS_DATATE = '' OR ACS.ACS_DATDE  <= '" + DTOS(dDataBase) + "') " + CRLF
				_cQuery += " 			AND (ACS.ACS_DATATE = '' OR ACS.ACS_DATATE >= '" + DTOS(dDataBase) + "') " + CRLF
				_cQuery += "  			AND ACS.ACS_CODCLI  = '' " + CRLF
				_cQuery += "  			AND ACS.ACS_GRPVEN  = '' " + CRLF
				_cQuery += "			AND ACS.ACS_CODREG  = ACN.ACN_CODREG " + CRLF
				_cQuery += "			AND  ACS.D_E_L_E_T_ = '' " + CRLF
				_cQuery += "		INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_FILIAL    = '" + xFilial("SB1")    + "' " + CRLF
				_cQuery += "  					AND SB1.B1_COD       = '" + aCols[n][_nPProd] + "' " + CRLF
				_cQuery += "  					AND (SB1.B1_COD      = ACN.ACN_CODPRO OR (SB1.B1_GRUPO <> '' AND SB1.B1_GRUPO = ACN.ACN_GRPPRO)) " + CRLF
				_cQuery += "  					AND SB1.D_E_L_E_T_   = '' " + CRLF
				_cQuery += "  	WHERE ACN.ACN_FILIAL  = '" + xFilial("ACN") + "' " + CRLF
				_cQuery += " 	  AND (ACN.ACN_DATINI = '' OR ACN.ACN_DATINI <= '" + DTOS(dDataBase) + "') " + CRLF
				_cQuery += " 	  AND (ACN.ACN_DATFIM = '' OR ACN.ACN_DATFIM >= '" + DTOS(dDataBase) + "') " + CRLF
				_cQuery += "	  AND ACN.ACN_QUANTI >= " + Str(aCols[n][_nQuant]) + CRLF
				_cQuery += "	  AND ACN.ACN_QUANTI  = (SELECT MIN(AUX.ACN_QUANTI) " + CRLF
				_cQuery += "							 FROM " + RetSqlName("ACN") + " AUX (NOLOCK) " + CRLF
				_cQuery += "							 WHERE AUX.ACN_FILIAL  = '" + xFilial("ACN") + "' " + CRLF
				_cQuery += "							   AND AUX.ACN_QUANTI >= " + Str(aCols[n][_nQuant]) + CRLF
				_cQuery += "							   AND AUX.ACN_CODREG  = ACN.ACN_CODREG " + CRLF
				_cQuery += "                               AND (AUX.ACN_CODPRO = ACN.ACN_CODPRO AND AUX.ACN_GRPPRO = ACN.ACN_GRPPRO) " + CRLF
				_cQuery += "                               AND AUX.D_E_L_E_T_  = '' " + CRLF
				_cQuery += "							) " + CRLF
				_cQuery += "	  AND ACN.D_E_L_E_T_  = '' " + CRLF
			endif
			_cQuery += " ) REGRAS " + CRLF
			_cQuery += " ORDER BY REGRAS.ACN_PROMOC, REGRAS.NIVEL "
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAliQry,.F.,.F.)
			dbSelectArea(_cAliQry)
			_cCodReg := ""
			_cCodFat := CriaVar(_cCpoIte+"CODFATR")
			_nDesc1	 := 0
			_nDesc2	 := 0
			_nDesc3	 := 0
			_nDesc4	 := 0
			if !(_cAliQry)->(EOF())
				_nDescAux := Round((_cAliQry)->ACN_DESCON,_nPDescon) //Desconto permitido selecionado
				_cCodReg  := (_cAliQry)->ACN_CODREG
				_cCodFat  := (_cAliQry)->ACN_CODFAT
				_nDesc1	  := (_cAliQry)->ACN_DESCV1
				_nDesc2	  := (_cAliQry)->ACN_DESCV2
				_nDesc3	  := (_cAliQry)->ACN_DESCV3
				_nDesc4	  := (_cAliQry)->ACN_DESCV4			
			endif
			while (_cAliQry)->(!EOF())
				if Round((_cAliQry)->ACN_DESCON,_nPDescon) > _nDescAux .OR. AllTrim((_cAliQry)->ACN_PROMOC)=='1'
					_nDescAux	:= Round((_cAliQry)->ACN_DESCON,_nPDescon) //Desconto permitido selecionado
					_cCodReg 	:= (_cAliQry)->ACN_CODREG
					_cCodFat 	:= (_cAliQry)->ACN_CODFAT
					_nDesc1	 	:= (_cAliQry)->ACN_DESCV1
					_nDesc2	 	:= (_cAliQry)->ACN_DESCV2
					_nDesc3	 	:= (_cAliQry)->ACN_DESCV3
					_nDesc4	 	:= (_cAliQry)->ACN_DESCV4
					//Verifico se a regra em questão foi definida como prioritária, se sim, não avalio as demais
					if (_cAliQry)->ACN_PROMOC=='1'
						Exit
					endif
				endif
				dbSelectArea(_cAliQry)
				(_cAliQry)->(dbSkip())
			enddo
			dbSelectArea(_cAliQry)
			(_cAliQry)->(dbCloseArea())
			if _nCodFat > 0
				aCols[n][_nCodFat] := _cCodFat
			endif
			if _nPDesc1 > 0
				aCols[n][_nPDesc1] := _nDesc1
			endif
			if _nPDesc2 > 0
				aCols[n][_nPDesc2] := _nDesc2
			endif
			if _nPDesc3 > 0
				aCols[n][_nPDesc3] := _nDesc3
			endif
			if _nPDesc4 > 0
				aCols[n][_nPDesc4] := _nDesc4
			endif
			if _nPDesc > 0
				aCols[n][_nPDesc ] := _nDescAux
			endif
			//Se a tela for do atendimento do Call Center, gravo o percentual de desconto em campo auxiliar para tratamento em outras rotinas, não remover
			if _nPDescA > 0
				aCols[n][_nPDescA] := _nDescAux
			endif
			__ReadVar    := "M->"+_cCpoIte+"DESC"
			&(__ReadVar) := aCols[n][_nPDesc ]
			if !empty(&(__ReadVar))
				_lValid  := .T.
				(_cAliasSX3)->(dbSetOrder(2))
				if (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)),.T.,.F.))
					_cValid := AllTrim((_cAliasSX3)->X3_VALID + iif(!empty((_cAliasSX3)->X3_VALID).AND.!empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
					if !empty(_cValid)
						_lValid := &_cValid
					endif
				endif
				if _lValid .AND. ExistTrigger(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)))
					RunTrigger(2,n)
				endif
			endif
		elseif !empty(aCols[n][_nPProd]) .AND. _nSugDes==2
			//Início - Trecho adicionado por Adriano Leonardo em 13/05/2014 Sugestão de desconto com base na amarração Cliente x Produto
			dbSelectArea("SA7")
			SA7->(dbSetOrder(1)) //Filial + Cliente + Loja + Produto
			if SA7->(MsSeek(xFilial("SA7")+M->UA_CLIENTE+M->UA_LOJA+aCols[n][_nPProd],.T.,.F.))
				_cCodFat := CriaVar(_cCpoIte+"CODFATR")
				_nDesc1	 := 0
				_nDesc2	 := 0
				_nDesc3	 := 0
				_nDesc4	 := 0
				_nDescAux:= 0
				//Verifico se a quantidade (vendida) do último pedido faturado é maior ou igual a quantidade atual
				if _lA7DesFat
					if SA7->A7_QUANT >= aCols[n][_nQuant]
						_nDesc1 := _nDescAux := SA7->A7_DESCFAT
					endif
				else
					MsgAlert("Informe ao Administrador que o campo A7_DESCFAT precisa ser criado!", _cRotina + "_002")
					//A7_DESCFAT - Numérico - Tamanho(5,2) - Como não usado
				endif
				if _nCodFat > 0
					aCols[n][_nCodFat] := _cCodFat
				endif
				if _nPDesc1 > 0
					aCols[n][_nPDesc1] := _nDesc1
				endif
				if _nPDesc2 > 0
					aCols[n][_nPDesc2] := _nDesc2
				endif
				if _nPDesc3 > 0
					aCols[n][_nPDesc3] := _nDesc3
				endif
				if _nPDesc4 > 0
					aCols[n][_nPDesc4] := _nDesc4
				endif
				if _nPDesc > 0
					aCols[n][_nPDesc ] := _nDescAux
				endif
				//Se a tela for do atendimento do Call Center, gravo o percentual de desconto em campo auxiliar para tratamento em outras rotinas, não remover
				if _nPDescA > 0
					aCols[n][_nPDescA] := _nDescAux
				endif
				__ReadVar    := "M->"+_cCpoIte+"DESC"
				&(__ReadVar) := aCols[n][_nPDesc ]
				if !empty(&(__ReadVar))
					_lValid  := .T.
					(_cAliasSX3)->(dbSetOrder(2))
					if (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)),.T.,.F.))
						_cValid := AllTrim((_cAliasSX3)->X3_VALID + iif(!empty((_cAliasSX3)->X3_VALID).AND.!empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
						if !empty(_cValid)
							_lValid := &_cValid
						endif
					endif
					if _lValid .AND. ExistTrigger(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)))
						RunTrigger(2,n)
					endif
				endif
			endif
			//Final  - Trecho adicionado por Adriano Leonardo em 13/05/2014 Sugestão de desconto com base na amarração Cliente x Produto
		/*
		//Início - Trecho adicionado por Adriano Leonardo em 17/10/2014 para inclusão de novo critério de sugestão de desconto
		elseif !empty(aCols[n][_nPProd]) .AND. _nSugDes==3 //Sugestão com base no último pedido do cliente (em construção)
			//AVALIO SE HÁ REGRA POR CLIENTE - NIVEL 1
			BeginSql Alias _cAliQry
				SELECT 1 AS [NIVEL], ACN_CODREG, ACN_CODPRO, ACN_DESCON, ACN_QUANTI, ACN_PROMOC, ACN_CODFAT, ACN_DESCV1, ACN_DESCV2, ACN_DESCV3, ACN_DESCV4
				FROM %table:ACN% ACN (NOLOCK)
						INNER JOIN %table:ACS% ACS (NOLOCK) ON ACS.ACS_FILIAL = %xFilial:ACS%
												AND ACS.ACS_CODCLI   = %Exp:M->UA_CLIENTE%
												AND ACS.ACS_LOJA     = %Exp:M->UA_LOJA%
												AND (ACS.ACS_DATATE  = '' OR ACS.ACS_DATDE  <= %Exp:DTOS(dDataBase)%)
												AND (ACS.ACS_DATATE  = '' OR ACS.ACS_DATATE >= %Exp:DTOS(dDataBase)%)
												AND ACS.ACS_CODREG   = ACN.ACN_CODREG
												AND ACS.%NotDel%
						INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL  = %xFilial:SB1%
												AND SB1.B1_COD       = %Exp:aCols[n][_nPProd]%
												AND (SB1.B1_COD      = ACN.ACN_CODPRO OR (SB1.B1_GRUPO <> '' AND SB1.B1_GRUPO = ACN.ACN_GRPPRO))
												AND SB1.%NotDel%
				WHERE ACN.ACN_FILIAL  = %xFilial:ACN%
				  AND (ACN.ACN_DATINI = %Exp:''% OR ACN.ACN_DATINI <= %Exp:DTOS(dDataBase)%)
				  AND (ACN.ACN_DATFIM = %Exp:''% OR ACN.ACN_DATFIM >= %Exp:DTOS(dDataBase)%)
				  AND ACN.ACN_QUANTI >= %Exp:Str(aCols[n][_nQuant])%
				  AND ACN.ACN_QUANTI  = (SELECT MIN(AUX.ACN_QUANTI)
										 FROM %table:ACN% AUX (NOLOCK)
										 WHERE AUX.ACN_FILIAL  = %xFilial:ACN%
										   AND AUX.ACN_CODREG  = ACN.ACN_CODREG
										   AND (AUX.ACN_CODPRO = ACN.ACN_CODPRO AND AUX.ACN_GRPPRO = ACN.ACN_GRPPRO)
										   AND AUX.ACN_QUANTI >= %Exp:Str(aCols[n][_nQuant])%
										   AND AUX.%NotDel%
										)
				  AND ACN.%NotDel%
			EndSql
			dbSelectArea(_cAliQry)
			_cCodReg := ""
			_cCodFat := CriaVar(_cCpoIte+"CODFATR")
			_nDesc1	 := 0
			_nDesc2	 := 0
			_nDesc3	 := 0
			_nDesc4	 := 0
			if !(_cAliQry)->(EOF())
				_nDescAux := Round((_cAliQry)->ACN_DESCON,_nPDescon) //Desconto permitido selecionado
				_cCodReg  := (_cAliQry)->ACN_CODREG
				_cCodFat  := (_cAliQry)->ACN_CODFAT
				_nDesc1	  := (_cAliQry)->ACN_DESCV1
				_nDesc2	  := (_cAliQry)->ACN_DESCV2
				_nDesc3	  := (_cAliQry)->ACN_DESCV3
				_nDesc4	  := (_cAliQry)->ACN_DESCV4			
			endif
			while !(_cAliQry)->(EOF())
				if Round((_cAliQry)->ACN_DESCON,_nPDescon) > _nDescAux .OR. AllTrim((_cAliQry)->ACN_PROMOC)=='1'
					_nDescAux	:= Round((_cAliQry)->ACN_DESCON,_nPDescon) //Desconto permitido selecionado
					_cCodReg 	:= (_cAliQry)->ACN_CODREG
					_cCodFat 	:= (_cAliQry)->ACN_CODFAT
					_nDesc1	 	:= (_cAliQry)->ACN_DESCV1
					_nDesc2	 	:= (_cAliQry)->ACN_DESCV2
					_nDesc3	 	:= (_cAliQry)->ACN_DESCV3
					_nDesc4	 	:= (_cAliQry)->ACN_DESCV4
					//Verifico se a regra em questão foi definida como prioritária, se sim, não avalio as demais
					if AllTrim((_cAliQry)->ACN_PROMOC)=='1'
						Exit
					endif
				endif
				dbSelectArea(_cAliQry)
				(_cAliQry)->(dbSkip())
			EndDo
			dbSelectArea(_cAliQry)
			(_cAliQry)->(dbCloseArea())
			if _nCodFat > 0
				aCols[n][_nCodFat] := _cCodFat
			endif
			if _nPDesc1 > 0
				aCols[n][_nPDesc1] := _nDesc1
			endif
			if _nPDesc2 > 0
				aCols[n][_nPDesc2] := _nDesc2
			endif
			if _nPDesc3 > 0
				aCols[n][_nPDesc3] := _nDesc3
			endif
			if _nPDesc4 > 0
				aCols[n][_nPDesc4] := _nDesc4
			endif
			if _nPDesc > 0
				aCols[n][_nPDesc ] := _nDescAux
			endif
			//Se a tela for do atendimento do Call Center, gravo o percentual de desconto em campo auxiliar para tratamento em outras rotinas, não remover
			if _nPDescA > 0
				aCols[n][_nPDescA] := _nDescAux
			endif
			__ReadVar    := "M->"+_cCpoIte+"DESC"
			&(__ReadVar) := aCols[n][_nPDesc ]
			if !empty(&(__ReadVar))
				_lValid  := .T.
				(_cAliasSX3)->(dbSetOrder(2))
				if (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)),.T.,.F.))
					_cValid := AllTrim((_cAliasSX3)->X3_VALID + iif(!empty((_cAliasSX3)->X3_VALID).AND.!empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
					if !empty(_cValid)
						_lValid := &_cValid
					endif
				endif
				if _lValid .AND. ExistTrigger(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)))
					RunTrigger(2,n)
				endif
			endif
		//Final  - Trecho adicionado por Adriano Leonardo em 17/10/2014 para inclusão de novo critério de sugestão de desconto
		*/
		endif
	endif
//	_cLog += "[002] Término da sugestão de desconto: " + DTOC(Date()) + " " + Time() + CRLF
//	_cLog += "[003] Início do processamento da troca da operação: " + DTOC(Date()) + " " + Time() + CRLF
	if !empty(aCols[n][_nPProd])
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		if SB1->(MsSeek(xFilial("SB1")+aCols[n][_nPProd],.T.,.F.))
			_lAtuTpO := .F.
			if _cCpoCab=="C5_" .AND. AllTrim(&("M->"+_cCpoCab+"TIPO"))=="N"   // Se tipo de pedido for normal.
				dbSelectArea("SA1")               	
				SA1->(dbSetOrder(1))
				if SA1->(MsSeek(xFilial("SA1") + M->(C5_CLIENTE+C5_LOJACLI),.T.,.F.))
					//Trata para quando o pedido for "VENDA"
					if (iif(empty(&("M->"+_cCpoCab+"TPDIV")),SA1->A1_TPDIV,&("M->"+_cCpoCab+"TPDIV")) == "0") .AND. ;
						AllTrim(&("M->"+_cCpoCab+"TPOPER")) $ AllTrim("01")
						&("M->"+_cCpoCab+"TPOPER") := "ZZ"
						_lAtuTpO                   := .T.
					endif
					//Trata para quando o pedido for troca ou bonificação
					if (iif(empty(&("M->"+_cCpoCab+"TPDIV")),SA1->A1_TPDIV,&("M->"+_cCpoCab+"TPDIV")) == "0") .AND. ;
						AllTrim(&("M->"+_cCpoCab+"TPOPER")) $ AllTrim("04|6|7|8")
						&("M->"+_cCpoCab+"TPOPER") := "Z2"
						_lAtuTpO                   := .T.
					endif
				endif
			elseif Type("lProspect")<>"U"
				if !lProspect
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					if SA1->(MsSeek(xFilial("SA1") + &("M->"+_cCpoCab+"CLIENTE") + &("M->"+_cCpoCab+"LOJA"),.T.,.F.))
						// Alterado por Júlio Soares em 14/06/2013 para tratar os tipos de operações 02 (Simples remessa), 04 (Bonificação), e 6 (Amostra)
						if (iif(empty(&("M->"+_cCpoCab+"TPDIV")),SA1->A1_TPDIV,&("M->"+_cCpoCab+"TPDIV")) == "0") .AND. ;
							AllTrim(&("M->"+_cCpoCab+"TPOPER")) $ "01"
							&("M->"+_cCpoCab+"TPOPER") := "ZZ"
							_lAtuTpO                   := .T.
						endif
						if (iif(empty(&("M->"+_cCpoCab+"TPDIV")),SA1->A1_TPDIV,&("M->"+_cCpoCab+"TPDIV")) == "0") .AND. ;
							AllTrim(&("M->"+_cCpoCab+"TPOPER")) $ AllTrim("04|6|7|8")
							&("M->"+_cCpoCab+"TPOPER") := "Z2"
							_lAtuTpO                   := .T.
						endif
					endif
				endif
			endif
			if !_lAtuTpO
				//Alteração implementada para atualizar para parâmetro.
				if &("M->"+_cCpoCab+"TPDIV") == "0" .AND. AllTrim(&("M->"+_cCpoCab+"TPOPER")) $ "01"
					&("M->"+_cCpoCab+"TPOPER") := "ZZ"
				endif
				if &("M->"+_cCpoCab+"TPDIV") == "0" .AND. AllTrim(&("M->"+_cCpoCab+"TPOPER")) $ Alltrim("04|6|7|8")
					&("M->"+_cCpoCab+"TPOPER") := "ZZ"
				endif
			endif
		endif
//		_cLog += "[004] Início da execução dos tipos de operação: " + DTOC(Date()) + " " + Time() + CRLF
		__ReadVar    := "M->"+_cCpoIte+"OPER"
		&(__ReadVar) := aCols[n][_nPOper] := &("M->"+_cCpoCab+"TPOPER")
		if !empty(&(__ReadVar))
			(_cAliasSX3)->(dbSetOrder(2))
			if (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)),.T.,.F.))
				_cValid := AllTrim((_cAliasSX3)->X3_VALID + iif(!empty((_cAliasSX3)->X3_VALID).AND.!empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
				if !empty(_cValid)
					&_cValid
				endif
			endif
			if _lRet .AND. ExistTrigger(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)))
				RunTrigger(2,n)
			endif
			//**********************************************************************
			// INICIO
			// ARCOLOR - Adequação para preenchimento do armazém de forma automática
			// dependendo do tipo de operação a ser praticada no cabeçalho do 
			// orçamento/pedido de venda
			// RODRIGO TELECIO em 12/01/2024
			//**********************************************************************			
			if AllTrim(&(__ReadVar)) $ cTpOper
				&("M->" + _cCpoIte + "LOCAL") := aCols[n][nPLocal] := AllTrim(&(__ReadVar))
				if _lRet .AND. ExistTrigger(AllTrim(_cCpoIte + "LOCAL"))
					RunTrigger(2,n)
				endif
			else
				&("M->" + _cCpoIte + "LOCAL") := aCols[n][nPLocal] := iif(!Empty(AllTrim(SB1->B1_LOCPAD)),SB1->B1_LOCPAD,"01")
				if _lRet .AND. ExistTrigger(AllTrim(_cCpoIte + "LOCAL"))
					RunTrigger(2,n)
				endif				
			endif
			// FIM
			//**********************************************************************			
		endif
		__ReadVar := "M->"+_cCpoIte+"TES"
		if empty(aCols[n][_nPTES])
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			if SB1->(MsSeek(xFilial("SB1")+aCols[n][_nPProd],.T.,.F.))
				if empty(SB1->B1_TS)
					&(__ReadVar) := aCols[n][_nPTES] := _cTESAD1
				else 
					&(__ReadVar) := aCols[n][_nPTES] := SB1->B1_TS
				endif
			endif
		else 
			&(__ReadVar) := aCols[n][_nPTES]
		endif
		(_cAliasSX3)->(dbSetOrder(2))
		if (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)),.T.,.F.))
			_cValid := AllTrim((_cAliasSX3)->X3_VALID + iif(!empty((_cAliasSX3)->X3_VALID).AND.!empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
			if !empty(_cValid)
				&_cValid
			endif
		endif
		if _lRet .AND. ExistTrigger(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)))
			RunTrigger(2,n)
			EvalTrigger()
		endif
	else
//		_cLog += "[004] Início da execução dos tipos de operação: " + DTOC(Date()) + " " + Time() + CRLF
		__ReadVar    := "M->"+_cCpoIte+"OPER"
		&(__ReadVar) := aCols[n][_nPOper] := &("M->"+_cCpoCab+"TPOPER")
		if !empty(&(__ReadVar))
			(_cAliasSX3)->(dbSetOrder(2))
			if (_cAliasSX3)->(MsSeek(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)),.T.,.F.))
				_cValid := AllTrim((_cAliasSX3)->X3_VALID + iif(!empty((_cAliasSX3)->X3_VALID).AND.!empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
				if !empty(_cValid)
					&_cValid
				endif
			endif
			if _lRet .AND. ExistTrigger(AllTrim(SubStr(__ReadVar,AT(">",__ReadVar)+1)))
				RunTrigger(2,n)
			endif
			//**********************************************************************
			// INICIO
			// ARCOLOR - Adequação para preenchimento do armazém de forma automática
			// dependendo do tipo de operação a ser praticada no cabeçalho do 
			// orçamento/pedido de venda
			// RODRIGO TELECIO em 12/01/2024
			//**********************************************************************
			if AllTrim(&(__ReadVar)) $ cTpOper
				&("M->" + _cCpoIte + "LOCAL") := aCols[n][nPLocal] := AllTrim(&(__ReadVar))
				if _lRet .AND. ExistTrigger(AllTrim(_cCpoIte + "LOCAL"))
					RunTrigger(2,n)
				endif
			else
				&("M->" + _cCpoIte + "LOCAL") := aCols[n][nPLocal] := "01"
				if _lRet .AND. ExistTrigger(AllTrim(_cCpoIte + "LOCAL"))
					RunTrigger(2,n)
				endif				
			endif
			// FIM
			//**********************************************************************
		endif
	endif
//	_cLog += "[005] Término de execução dos tipos de operação: " + DTOC(Date()) + " " + Time() + CRLF
	//Início  - Trecho adicionado por Adriano Leonardo em 15/09/2014 para forçar o gatilho da TES no final do processo
	//_cLog += "[006] Início do redisparo dos gatilhos de TES: " + DTOC(Date()) + " " + Time() + CRLF
	//if ExistBlock("RTMKE030")
	//	ExecBlock("RTMKE030")
	//endif
	//_cLog += "[007] Início do redisparo dos gatilhos de TES: " + DTOC(Date()) + " " + Time() + CRLF
	//Final - Trecho adicionado por Adriano Leonardo em 15/09/2014 para forçar o gatilho da TES no final do processo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fim trecho inserido por Júlio Soares em 19/12/2013 para atualizar os descontos do item do atendimento/pedido        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Select(_cAliasSX3) > 0
		(_cAliasSX3)->(dbCloseArea())
	endif
//	_cLog += "[008] Início dos refresh na GetDados: " + DTOC(Date()) + " " + Time() + CRLF
	if (_cFName=="MATA410" .OR. _cFName=="RFATA012") .AND. Type('oBrowse')<>"U"
		oBrowse:Refresh()
	endif
	if (_cFName=="MATA410" .OR. _cFName=="RFATA012") .AND. Type('oGetDb:oBrowse')<>"U"
		oGetDb:oBrowse:Refresh()
	endif
	if (_cFName=="MATA410" .OR. _cFName=="RFATA012") .AND. Type('oGetPV')<>"U"
		oGetPV:Refresh()
	endif
	if (_cFName=="MATA410" .OR. _cFName=="RFATA012") .AND. Type('oGetDad:oBrowse')<>"U"
		oGetDad:oBrowse:Refresh()
		Ma410Rodap()
	endif
	if (_cFName=="TMKA271" .OR. _cFName=="RTMKI001" .OR. _cFName=="RPC") .AND. Type('oGetTlv:oBrowse')<>"U"
		oGetTlv:oBrowse:Refresh(.T.)
	endif
	/*
	if Type('GetObjBrow()')<>"U"
		GetObjBrow():Default()
		GetObjBrow():Refresh()
	endif
	*/
//	_cLog += "[009] Início dos refresh nas GetDados: " + DTOC(Date()) + " " + Time() + CRLF

	//No Final da rotina, restaure o ReadVar
	n            := _nBkp
	__ReadVar    := _cRVarBkp
	&(__ReadVar) := _cContBkp

	if len(_aSavSX3) > 0
		RestArea(_aSavSX3)
	endif
	RestArea(_aSavSUA)
	RestArea(_aSavSUB)
	RestArea(_aSavSUS)
	RestArea(_aSavSU7)
	RestArea(_aSavSA7)
	RestArea(_aSavSA1)
	RestArea(_aSavSB1)
	RestArea(_aSavSF4)
	RestArea(_aSavAr)
//	_cLog += "[010] Finish: " + DTOC(Date()) + " " + Time() + CRLF
//	if AllTrim(__cUserId)=="000000"
//		MemoWrite("\2.MemoWrite\"+_cRotina+"_LOG_001.TXT",_cLog)
//	endif
return _lRet
