#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _CLRF CHR(13)+CHR(10)
/*/{Protheus.doc} RCOMR005
@description Relatório de consumo mensal específico, permitindo extrair informações históricas e projeções com base no percentual de acréscimo tendo por base o respectivo mês do ano anterior.
@author Adriano Leonardo de Souza
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
@history 23/04/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), adequação do titulo do e-mail removendo as palavras maiscuslas devido a restrições da localweb
/*/
user function RCOMR005()
	Local   _aSavArea  := GetArea()
	Local   _aSavSB1   := SB1->(GetArea())
	Private _cRotina   := "RCOMR005"
	Private cPerg      := _cRotina
	Private _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	Private _cAlias    := GetNextAlias()		//"TMPSZG"
//	Private _cQry      := ""
	Private _cTitulo   := "["+_cRotina+"] Plano de Consumo"
	//If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	 //  MsgStop('Usuário sem permissão para exportar dados para Excel, informe o Administrador!',_cRotina +"001")
	 // Return(Nil)
	//endif
	if !ApOleClient('MsExcel')
	   MsgStop('Excel não instalado!',_cRotina +"002")
	   //return nil
	endif
	if Select(_cAliasSX1)
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	ValidPerg()
	//Não deixa prosseguir sem que o usuário confirme os parâmetros
	/* FB - RELEASE 12.1.23
	while !Pergunte(cPerg,.T.)
		if MsgYesNo("Deeja cancelar a emissão do relatório?",_cRotina+"_003")
			MsgAlert("Função cancelada pelo usuário!",_cRotina+"_004")
			return nil
		endif
	enddo
	*/
	if !Pergunte(cPerg,.T.)
		MsgAlert("Função cancelada pelo usuário!",_cRotina+"_004")
		return nil
	endif
	//Se usuário não confirmar a marcação dos produtos a rotina é fechada
	if !Selecao()
		MsgAlert("Função cancelada pelo usuário!",_cRotina+"_005")
		return
	endif
	if Select (_cAlias) > 0
	   (_cAlias)->(dbCloseArea())
	endif
//	MsgRun("Aguarde... Iniciando consulta..."   ,_cTitulo,{ || _cQry := QryBuild() }) // Chamada da função responsável por montar a consulta dinâmica no banco de dados com base nos parâmetros definidos pelo usuário
	MsgRun("Aguarde... Iniciando consulta..."   ,_cTitulo,{ || QryBuild()          }) // Chamada da função responsável por montar a consulta dinâmica no banco de dados com base nos parâmetros definidos pelo usuário
//	MsgRun("Aguarde... Selecionando dados..."   ,_cTitulo,{ || SelecionaDados()    }) // Chamada da função para selecionar os dados necessários no banco de dados
	MsgRun("Aguarde... Processando relatório...",_cTitulo,{ || ProcRel()           })
	if Select (_cAlias) > 0
	   (_cAlias)->(dbCloseArea())
	endif
	if Select(_cAliasSX1)
		(_cAliasSX1)->(dbCloseArea())
	endif
	//RestArea(_aSavSB1)
	//RestArea(_aSavArea)
	if MsgYesNo("Deseja processar o relatório novamente?",_cRotina + "_005")
		ExecBlock(_cRotina)
	else
		RestArea(_aSavSB1)
		RestArea(_aSavArea)	
	endif
return
/*/{Protheus.doc} QryBuild
@description Função responsável por montar a query dinâmica de acordo com os parâmetros definidos pelo usuário.
@author Adriano Leonardo de Souza
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function QryBuild()
//	Local   _cAteMes   := MV_PAR01
//	Local   _cDeMes    := _cAteMes
	Local   _cQry      := ""
	Local   _aMeses    := {"12","11","10","09","08","07","06","05","04","03","02","01"}
	Local   _aPerMes   := {}
	Local   _nNum      := 0
	Local   _nCont     := 0
	Private _nNumMeses := MV_PAR02
	Private _cMesAux   := SubStr(MV_PAR01,1,2)
	Private _nAnoAux   := iif(len(AllTrim(Str(Val(SubStr(MV_PAR01,Len(MV_PAR01)-3,4)))))==2, SubStr(DTOS(dDataBase),1,4) + AllTrim(Str(Val(SubStr(MV_PAR01,Len(MV_PAR01)-3,4)))) , AllTrim(Str(Val(SubStr(MV_PAR01,Len(MV_PAR01)-3,4)))))
	for _nNum := 0 to 11 //Varre os parâmetros de percentual de acréscimo mensal e grava os valores em array para uso posterior
		AAdd(_aPerMes,&("MV_PAR"+AllTrim(Str(13+_nNum))))
	next	
	_cQry      := " SELECT SB1.B1_COD, SB1.B1_DESC, B1_UM " + _CLRF
	_nPosArr   := aScan(_aMeses,_cMesAux)
	for _nCont := 1 to _nNumMeses
		_cMesAux  := _aMeses[_nPosArr]
		_cMesAno  := _nAnoAux + _cMesAux
		_cAnoBase := AllTrim(Str(val(_nAnoAux)-1)) + _cMesAux
		_cQry     += " , ISNULL((SELECT ZG_QUANTID FROM " + RetSqlName("SZG") + " SZG WITH (NOLOCK) WHERE SZG.ZG_FILIAL='" + xFilial("SZG") + "' AND SZG.ZG_STATUS ='S' AND SZG.ZG_PRODUTO=SB1.B1_COD AND SZG.ZG_MESANO='" + _cAnoBase + "' AND SZG.D_E_L_E_T_='' ),0) AS [BASE" + _cMesAno + "] " + _CLRF
		_cQry     += " ,(ISNULL((SELECT ZG_QUANTID FROM " + RetSqlName("SZG") + " SZG WITH (NOLOCK) WHERE SZG.ZG_FILIAL='" + xFilial("SZG") + "' AND SZG.ZG_STATUS ='S' AND SZG.ZG_PRODUTO=SB1.B1_COD AND SZG.ZG_MESANO='" + _cAnoBase + "' AND SZG.D_E_L_E_T_='' ),0))*("+Str(1+Val(AllTrim(Str(_aPerMes[Val(_cMesAux)])))/100)+") AS [PREV" + _cMesAno + "] " + _CLRF
		_cQry     += " , ISNULL((SELECT ZG_QUANTID FROM " + RetSqlName("SZG") + " SZG WITH (NOLOCK) WHERE SZG.ZG_FILIAL='" + xFilial("SZG") + "' AND SZG.ZG_STATUS ='S' AND SZG.ZG_PRODUTO=SB1.B1_COD AND SZG.ZG_MESANO='" + _cMesAno  + "' AND SZG.D_E_L_E_T_='' ),0) AS [REAL" + _cMesAno + "] " + _CLRF
		if _nPosArr == 12
			_nPosArr := 1
			_cMesAux := _aMeses[_nPosArr]
			_nAnoAux := cValToChar(val(_nAnoAux)-1)
		else
			_nPosArr++
		endif
	next
	_cQry += " , ISNULL((SELECT SUM(B2_QATU)    FROM " + RetSqlName("SB2") + " SB2 WITH (NOLOCK) WHERE SB2.B2_FILIAL='" + xFilial("SB2") + "' AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND SB2.D_E_L_E_T_=''),0) AS [SALDO_ATU] "	 + _CLRF
	_cQry += " , ISNULL((SELECT SUM(B2_SALPEDI) FROM " + RetSqlName("SB2") + " SB2 WITH (NOLOCK) WHERE SB2.B2_FILIAL='" + xFilial("SB2") + "' AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND SB2.D_E_L_E_T_='') - (SELECT SUM(C1_QUANT-C1_QUJE) AS [QTD_SOL] FROM " + RetSqlName("SC1") + " SC1 WITH (NOLOCK) WHERE SC1.C1_FILIAL='" + xFilial("SC1") + "' AND SC1.C1_PRODUTO=SB1.B1_COD AND SC1.D_E_L_E_T_=''),0) AS ENT_PREV  " + _CLRF
	_cQry += " FROM " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) " + _CLRF
	_cQry += " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' " + _CLRF
	_cQry += "  AND SB1.B1_MARK   <> '' " + _CLRF
	_cQry += "  AND SB1.D_E_L_E_T_ = '' " + _CLRF
	_cQry += " ORDER BY B1_COD "
	//Filtra a unidade de medida do produto, apenas quando o parâmetro for preenchido, caso contrário retorna todos os tipos
	/*If !Empty(MV_PAR03)
		_cQry += "AND SB1.B1_UM='" + MV_PAR03 + "' "
	endif*/
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",GetLastQuery()[02])
	//_cQry := ChangeQuery(_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.F.)
return _cQry
/*/{Protheus.doc} ValidPerg
@description Função de registro das perguntas de usuário na tabela SX1.
@author Adriano Leonardo de Souza
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local   i, j
	local   _sAlias    := GetArea()
	local   aRegs      := {}

	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	(_cAliasSX1)->(dbGoTop())
	cPerg              := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	ATENÇÃO: Caso seja necessário alterar as ordens dos parâmetros, atente para a montagem do array _aPerMes que armazena o conteúdo dos parâmetros de percentual
	de acréscimo de janeiro à dezembro de maneira sequencial, alterar a ordem dos parâmetros pode impactar no preenchimento errado desse array.
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
	AADD(aRegs,{cPerg,"01","Até mês/ano?"  				,"","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"02","Número de meses?"			,"","","mv_ch2","N",12,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"03","De produto?" 				,"","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"	,""})
	AADD(aRegs,{cPerg,"04","Até produto?"				,"","","mv_ch4","C",15,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"	,""})
	//Início - Trecho adicionado por Adriano Leonardo em 19/08/2014 para dinamizar o processo de seleção do produto
	AADD(aRegs,{cPerg,"05","De descrição?" 				,"","","mv_ch5","C",60,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"06","Até descrição?"				,"","","mv_ch6","C",60,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	//Final  - Trecho adicionado por Adriano Leonardo em 19/08/2014 para dinamizar o processo de seleção do produto
	AADD(aRegs,{cPerg,"07","De tipo?" 	   				,"","","mv_ch7","C",02,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"08","Até tipo?" 	   				,"","","mv_ch8","C",02,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"09","De grupo?"					,"","","mv_ch9","C",04,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"10","Até grupo?"					,"","","mv_cha","C",04,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"11","De armazém?" 	   			,"","","mv_chb","C",02,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"12","Até armazém?"				,"","","mv_chc","C",02,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"13","Percent. acrés. janeiro?"	,"","","mv_chd","N",06,2,0,"G","","MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"14","Percent. acrés. fevereiro?"	,"","","mv_che","N",06,2,0,"G","","MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"15","Percent. acrés. março?"		,"","","mv_chf","N",06,2,0,"G","","MV_PAR15","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"16","Percent. acrés. abril?"		,"","","mv_chg","N",06,2,0,"G","","MV_PAR16","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"17","Percent. acrés. maio?"		,"","","mv_chh","N",06,2,0,"G","","MV_PAR17","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"18","Percent. acrés. junho?"		,"","","mv_chi","N",06,2,0,"G","","MV_PAR18","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"19","Percent. acrés. julho?"		,"","","mv_chj","N",06,2,0,"G","","MV_PAR19","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"20","Percent. acrés. agosto?"	,"","","mv_chk","N",06,2,0,"G","","MV_PAR20","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"21","Percent. acrés. setembro?"	,"","","mv_chl","N",06,2,0,"G","","MV_PAR21","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"22","Percent. acrés. outubro?"	,"","","mv_chm","N",06,2,0,"G","","MV_PAR22","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"23","Percent. acrés. novembro?"	,"","","mv_chn","N",06,2,0,"G","","MV_PAR23","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"24","Percent. acrés. dezembro?"	,"","","mv_cho","N",06,2,0,"G","","MV_PAR24","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"25","Base projeção de ano/mês?"	,"","","mv_chp","C",06,0,0,"G","","MV_PAR25","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"26","Base projeção até ano/mês?"	,"","","mv_chq","C",06,0,0,"G","","MV_PAR26","","","","","","","","","","","","","","","","","","","","","","","","",""		,""})
	for i := 1 to Len(aRegs)
		If !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_sAlias)
return
/*/{Protheus.doc} Selecao
@description Função responsável por montar MARKbrowse para escolha dos produtos que serão considerados no relatório.
@author Adriano Leonardo de Souza
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Selecao()
	Local   nOpc       := 2
	Local   bOk        := {|| nOpc := 1, oDlgProd:End()}
	Local   bCancel    := {|| nOpc := 2, oDlgProd:End()}
	Local   _cInd      := ""
	Local   _cUpd 	   := "UPDATE " + RetSqlName("SB1") + " SET B1_MARK = '' WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_MARK <> '' AND D_E_L_E_T_ = '' "
	Private oBtnOk, oBtnCanc, oMainWnd
	Private aMarcados[2]
//	Private nMarcado := 0
	Private cMarca     := GetMARK(), lInverte := .F., oMARK
//	Private aIndex     := {}
//	Private bFiltraBrw := {|| Nil}
	Private aCampos    := 	{	{"B1_MARK"    	,, " " 						},;
			          			{"B1_COD"   	,, "Código"		 			},;
				            	{"B1_DESC"  	,, "Descrição"		 		},;
						        {"B1_UM"  		,, "Unid. de Medida"	 	},;
			    		    	{"B1_TIPO" 		,, "Tipo" 					},;
						        {"B1_GRUPO"   	,, "Grupo"					}}
	//Limpa as seleções feitas anteriormente (produtos)
	If TCSQLExec(_cUpd) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_002")
	endif
	//Filtra os produtos cuja flag de seleção será zerada
	cFiltra := "SB1->B1_FILIAL = '"+xFilial("SB1")+"' .AND. SB1->B1_COD >= '" + MV_PAR03 + "' .AND. SB1->B1_COD <= '" + MV_PAR04 + "' .AND. SB1->B1_TIPO >= '" + MV_PAR07 + "' .AND. SB1->B1_TIPO <= '" + MV_PAR08 + "'.AND. SB1->B1_GRUPO >= '" + MV_PAR09 + "' .AND. SB1->B1_GRUPO <= '" + MV_PAR10 + "' .AND. SB1->B1_DESC >= '" + MV_PAR05 + "' .AND. SB1->B1_DESC <= '" + MV_PAR06 + "' "
//	If !Empty(MV_PAR03)
//		cFiltra += " .AND. SB1->B1_UM='" + MV_PAR03 + "' "
//	endif
	_cInd := CriaTrab(nil,.F.)
	//Ordenando por cliente + loja + tipo + número do título
	IndRegua("SB1",_cInd,"B1_FILIAL + B1_COD",,cFiltra,"Listando produtos...")
	//IndRegua("SB1",_cInd,"B1_FILIAL + B1_COD",,"","Selecionando produtos...")
	static oDlgProd
    //Cria tela do tipo MARKbrowse para aprovação dos títulos pertencentes ao malote selecionado
	Define MsDialog oDlgProd Title "Seleção dos produtos" From 8,0 To 28,80 Of oMainWnd
		dbSelectArea("SB1")
		SB1->(dbGoTop())
	 	@ 9,10 Say "Marque os produtos que serão considerados no relatório" Size 232,10 Pixel Of oDlgProd
	 	oMARK := MsSelect():New("SB1","B1_MARK",,aCampos,lInverte,@cMarca,{18,3,125,312})
	 	oMARK:oBrowse:lHasMARK := .T.
		oMARK:oBrowse:lCanAllMARK:=.T.
	//	oMARK:oBrowse:bAllMARK := {|| MARKAll("SB1", cMarca, @oDlgProd)}
		oMARK:oBrowse:bAllMARK := {|| MARKAll()}
        oMARK:bAval := {|| ChkMarca(oMARK,cMarca) }
        AddColMARK(oMARK,"B1_MARK")
	    @ 130,010 button "Marca Todos" Size 48,17 Action MARKAll() Of oDlgProd Pixel
	    @ 130,060 button "Desmarca Todos" Size 48,17 Action UnMARKAll() Of oDlgProd Pixel
        Define SButton oBtnOk     From 130,258 Type 1 Action Eval(bOk) Enable Of oDlgProd
        Define SButton oBtnCanc   From 130,288 Type 2 Action Eval(bCancel) Enable Of oDlgProd
	Activate MsDialog oDlgProd Centered
	If nOpc == 2
		return .F.
	endif
return .T.
/*/{Protheus.doc} MARKAll
@description Função criada para marcar todos os registros da tela de diálogo.
@author Adriano Leonardo de Souza
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function MARKAll()
	SB1->(dbGoTop())
	while !SB1->(EOF())
		while !RecLock("SB1",.F.) ; enddo
			SB1->B1_MARK := cMarca
		SB1->(MsUnLock())
		SB1->(dbCommit())
		SB1->(dbSkip())
	enddo
	SB1->(dbGoTop())
	oMARK:oBrowse:Refresh()
return .T.
/*/{Protheus.doc} UnMARKAll
@description Função criada para desmarcar todos os registros da tela de diálogo.
@author Adriano Leonardo de Souza
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function UnMARKAll()
	SB1->(dbGoTop())
	while !SB1->(EOF())
		while !RecLock("SB1",.F.) ; enddo
			SB1->B1_MARK := " "
		SB1->(MsUnLock())
		SB1->(dbCommit())
		SB1->(dbSkip())
	enddo
	SB1->(dbGoTop())
	oMARK:oBrowse:Refresh()
return .T.
/*/{Protheus.doc} ChkMarca
@description Função criada para permitir a seleção de um registro para definir quais produtos comporão o relatório.
@author Adriano Leonardo de Souza
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ChkMarca(oMARK,cMarca)
	local posicao
	Begin Sequence
		if !SB1->(EOF() .OR. BOF())
			if !Empty(SB1->B1_MARK)
				// Desmarca
				posicao := aScan(aMarcados,SB1->B1_MARK)
				if posicao > 0
					aMarcados[posicao] := ""
				endif
				while !RecLock("SB1",.F.) ; enddo
					SB1->B1_MARK := Space(2)
				SB1->(MsUnLock())
				SB1->(dbCommit())
			else
				// Marca
				if empty(aMarcados[1])
					aMarcados[1] := SB1->B1_MARK
				else
					aMarcados[2] := SB1->B1_MARK
				endif
				while !RecLock("SB1",.F.) ; enddo
					SB1->B1_MARK := cMarca
				SB1->(MsUnLock())
				SB1->(dbCommit())
			endif
			oMARK:oBrowse:Refresh()
		endif
	End Sequence
return
/*/{Protheus.doc} ProcRel
@description Processamento da rotina, com a geração das informações para o Excel.
@author Adriano Leonardo de Souza
@since 06/01/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ProcRel()
	local   oMsExcel
	local   oExcel      := FWMSEXCEL():New()
	local   _cSheet1    := "Parametros"
	local   _cSheet2    := "Quantidades"
	local   _cSheet3    := "Legenda"
	local   _cFileTMP   := cGetFile('Arquivo Arquivo XML|*.xml','Salvar arquivo',0,GetTempPath(),.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY,.F.) //Define o local onde o arquivo será gerado
	local   _cFile      := ""
	local   _aCol       := {}
	local   _aPar       := {}
//	local   _nColD      := 0
	local   _nItens     := 0
//	local   _dData      := dDataBase
//	local   _nColFim    := 5
	local   _nQtdLin    := 4
	local   _nCont      := 0
	local   _nPProd 	:= 1
	local   _x          := 0
	local   _nLin4      := 0
	local   _nLin3      := 0
	local   _nLin2      := 0
	local   _nCntMed    := 0
	local   _nCntTot    := 0
	local   _nCont6     := 0
	local   _nCont5     := 0
	local   _nCont4     := 0
	local   _nCont3     := 0
	local   _nCont2     := 0
	local   _nCnt       := 0
	local   _nCnt1      := 0
	local   _nCnt2      := 0
	local   _nCnt3      := 0
	local   _nAux       := 0
	local   _nAux2      := 0
	local   _nAno       := 0
	local   _nPosPar    := 0
	local   _nPosLeg    := 0
	local   _cMesAux2   := SubStr(MV_PAR01,1,2)
	local   _nAnoAux2   := iif(len(AllTrim(Str(Val(SubStr(MV_PAR01,Len(MV_PAR01)-3,4)))))==2, substring(dtos(ddatabase),1,4) + AllTrim(Str( Val(SubStr(MV_PAR01,Len(MV_PAR01)-3,4)))) , AllTrim(Str( Val(SubStr(MV_PAR01,Len(MV_PAR01)-3,4)))))   
	local   _cMesBkp 	:= _cMesAux2
	local   _nAnoBkp	:= _nAnoAux2
	local   _aTotais	:= {} //Posição 1 (Soma) - Posição 2 (Média)
	local   _nAddCol	:= 0
	local   _nPosCol    := 0
	local   _nProxCol   := 0
	local   _lUsrDef    := .F.
//	local   _nNumMes 	:= MV_PAR02
	private _nQtdTot    := IIf((MV_PAR02/6)<>Int(MV_PAR02/6),Int(MV_PAR02/6)+1,Int(MV_PAR02/6))
	private _nBasPrev   := 0
	private _nConBas    := 0
	private _nBasReal   := 0
	private _nBasBase   := 0
	private _cBasDife := ""
	//Verifico se o formato do arquivo foi definido corretamente
	if !empty(_cFileTMP)
		if "\"==SubStr(_cFileTMP,len(_cFileTMP),1)
			_cFileTMP := AllTrim(_cFileTMP)+GetNextAlias()+".xml"
		elseif !"\"$_cFileTMP
			_cFileTMP := GetTempPath()+_cFileTMP
			if !".XML" $ UPPER(_cFileTMP)
				_cFileTMP := StrTran(_cFileTMP,'.','')
				_cFileTMP := AllTrim(_cFileTMP)+".xml"
				_lUsrDef  := .T.
			endif
		else
			if !".XML" $ UPPER(_cFileTMP)
				_cFileTMP := StrTran(_cFileTMP,'.','')
				_cFileTMP := AllTrim(_cFileTMP)+".xml"
				_lUsrDef  := .T.
			endif
		endif
	else
		_cFileTMP := GetTempPath()+GetNextAlias()+".xml"
	endif
	oExcel:AddWorkSheet(_cSheet1)
	oExcel:AddTable(_cSheet1,_cTitulo)
	oExcel:AddColumn(_cSheet1,_cTitulo,"DESCRIÇÃO"	 ,1,1,.F.)
	oExcel:AddColumn(_cSheet1,_cTitulo,"CONTEÚDO"	 ,1,1,.F.)
	/* FB -  RELEASE 12.1.23
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))  //Grupo + Ordem
	SX1->(dbGoTop())
	cPerg := PADR(cPerg,10)
	If SX1->(dbSeek(cPerg))
		while !SX1->(EOF()) .AND. SX1->X1_GRUPO==cPerg
			AAdd(_aPar,{ SX1->X1_PERGUNT,&(SX1->X1_VAR01) })
			dbSelectArea("SX1")
			SX1->(dbSetOrder(1))  //Grupo + Ordem
			SX1->(dbSkip())
		enddo
	endif
	*/
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	(_cAliasSX1)->(dbGoTop())
	cPerg := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	If (_cAliasSX1)->(dbSeek(cPerg))
		while !(_cAliasSX1)->(EOF()) .AND. (_cAliasSX1)->X1_GRUPO==cPerg
			AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
			dbSelectArea(_cAliasSX1)
			(_cAliasSX1)->(dbSetOrder(1))  //Grupo + Ordem
			(_cAliasSX1)->(dbSkip())
		enddo
	endif
	oExcel:AddWorkSheet(_cSheet2)
	oExcel:AddTable (_cSheet2,_cTitulo)
	oExcel:AddColumn(_cSheet2,_cTitulo,"INFORMAÇÃO"	 	,1,1,.F.)
	_nAddCol++
	oExcel:AddColumn(_cSheet2,_cTitulo,PadR("PRODUTO",8),1,1,.F.)
	_nAddCol++
	oExcel:AddColumn(_cSheet2,_cTitulo,"DESCRIÇÃO" 	 	,1,1,.F.)
	_nAddCol++
	oExcel:AddColumn(_cSheet2,_cTitulo,"UM "			,1,1,.F.)
	_nAddCol++
	oExcel:AddColumn(_cSheet2,_cTitulo,"SALDO ATUAL" 	,2,1,.F.)
	_nAddCol++
	_aMesNon := {}
	AAdd(_aMesNon,{'01','JAN/'})
	AAdd(_aMesNon,{'02','FEV/'})
	AAdd(_aMesNon,{'03','MAR/'})
	AAdd(_aMesNon,{'04','ABR/'})
	AAdd(_aMesNon,{'05','MAI/'})
	AAdd(_aMesNon,{'06','JUN/'})
	AAdd(_aMesNon,{'07','JUL/'})
	AAdd(_aMesNon,{'08','AGO/'})
	AAdd(_aMesNon,{'09','SET/'})
	AAdd(_aMesNon,{'10','OUT/'})
	AAdd(_aMesNon,{'11','NOV/'})
	AAdd(_aMesNon,{'12','DEZ/'})
	//Monta as colunas dinâmicas de acordo com o número de meses escolhidos
	for _nCont2 := 1 to MV_PAR02 //Número de meses
		_cColuna := _aMesNon[Val(_cMesAux2),2]
		_cColuna += SubStr(AllTrim(_nAnoAux2),Len(AllTrim(_nAnoAux2))-1,2) //AllTrim(Str(_nAnoAux2))
		//Adiciona as colunas referentes aos meses escolhidos
		oExcel:AddColumn(_cSheet2,_cTitulo,_cColuna ,3,2,.F.)
		_nAddCol++
		//Verifica se haverá mudança de ano e define o mês a ser tratado
		if _cMesAux2 == "01"
			_cMesAux2 := "12"
			_nAnoAux2 := cValToChar(val(_nAnoAux2)-1)
		else
			_cMesAux2 := StrZero((Val(_cMesAux2)-1),2)
		endif
	next
	//Restauro os valores iniciais
	_cMesAux2 := _cMesBkp
	_nAnoAux2 := _nAnoBkp
	//Adiciona as colunas de total e percentual de créscimento totalizando a cada 6 meses (dependendo da quantidade de meses definido pelo usuário)
	for _nCnt := 1 to _nQtdTot
		oExcel:AddColumn(_cSheet2,_cTitulo,"TOTAL " + AllTrim(Str(_nCnt)) + "º 6 M" ,3,2,.F.)
		_nAddCol++
		oExcel:AddColumn(_cSheet2,_cTitulo,"%"				 	 		 			,3,2,.F.)
		_nAddCol++
	next
	_nQtdAnos := Int(_nQtdTot/2) //Importante, caso o período definido seja de até 6 meses o totalizador por ano não será apresentado, por ser idêntico ao dos seis meses
	for _nCnt1 := 1 to _nQtdAnos
		oExcel:AddColumn(_cSheet2,_cTitulo,"TOTAL " + AllTrim(Str(_nCnt1)) + "º 12 M" 	 		 ,3,2,.F.)
		_nAddCol++
	next
	for _nCnt2 := 1 to _nQtdTot
		oExcel:AddColumn(_cSheet2,_cTitulo,"MÉDIA " + AllTrim(Str(_nCnt2)) + "º 6 M"  	 		 ,3,2,.F.)
		_nAddCol++
	next
	for _nCnt3 := 1 to _nQtdAnos
		oExcel:AddColumn(_cSheet2,_cTitulo,"MÉDIA " + AllTrim(Str(_nCnt3)) + "º 12 M" 	  		 ,3,2,.F.)
		_nAddCol++
	next
	oExcel:AddColumn(_cSheet2,_cTitulo,"ESTOQUE PARA" 	  		 ,3,1,.F.)
	_nAddCol++
	oExcel:AddColumn(_cSheet2,_cTitulo,"PREV. PROX. 6 M",3,2,.F.)
	_nAddCol++
	oExcel:AddColumn(_cSheet2,_cTitulo,"ENTRADA PREV."			 ,3,2,.F.)
	_nAddCol++
	_nPProd := 1
	dbSelectArea(_cAlias)
	ProcRegua(((_cAlias)->(RecCount())*2)+1)
	(_cAlias)->(dbGoTop())
	while !(_cAlias)->(EOF())
		_aTotais	:= {} //Posição 1 (Soma) - Posição 2 (Média)
		_nBasPrev	:= 0
		_nBasReal	:= 0
		_nBasBase   := 0
		_cBasDife	:= ""
		_nConBas	:= 0
		AADD(_aTotais,Array(_nQtdTot*2)) //Base
		AADD(_aTotais,Array(_nQtdTot*2)) //Previsão
		AADD(_aTotais,Array(_nQtdTot*2)) //Real
		AADD(_aTotais,Array(_nQtdTot*2)) //Diferença
		//Inicializo o array com todos os valores zerados
		for _nAux := 1 to Len(_aTotais)
			for _nAux2 := 1 to Len(_aTotais[_nAux])
				_aTotais[_nAux][_nAux2] := 0
			next
		next
		IncProc("Processando o produto " + AllTrim((_cAlias)->B1_COD) + "...")
		//Consumo Base
		AADD(_aCol,Array(_nAddCol))
		_aCol[_nPProd+00][01] := "Cons. Base"          	//Informação
		_aCol[_nPProd+00][02] := (_cAlias)->B1_COD		//Código
		_aCol[_nPProd+00][03] := (_cAlias)->B1_DESC		//Descrição
		_aCol[_nPProd+00][04] := (_cAlias)->B1_UM		//Unidade de medida
		_aCol[_nPProd+00][05] := (_cAlias)->SALDO_ATU	//Saldo atual
		_nProxCol  := 6
		_nSemestre := 1
		//Monta as colunas dinâmicas de acordo com o número de meses escolhidos
		for _nCont3 := 1 to MV_PAR02 //Número de meses
			_cCpoBase := (_cAlias) + "->BASE" + AllTrim(_nAnoAux2) + _cMesAux2
			_aCol[_nPProd+00][_nProxCol] := &_cCpoBase
			//Verifica se haverá mudança de ano e define o mês a ser tratado
			if _cMesAux2 == "01"
				_cMesAux2 := "12"
				_nAnoAux2 := cValToChar(val(_nAnoAux2)-1)
			else
				_cMesAux2 := StrZero((val(_cMesAux2)-1),2)
			endif
			//Verifica a qual semestre pertence o mês que está sendo tratato (lembrando que se trata dos 1º, 2º, 3º seis meses, etc. e não do semestre letivo)
			If _nCont3 > (_nSemestre * 6)
				_nSemestre++
				_nValAux := 2
			else
				_nValAux := 0
			endif
			//Fórmula criada para identificar a posição do array que deverá ser manipulado, de acordo com o mês sendo tratado, totalizando por "semestre"
			_nPosArr := IIF(_nSemestre==1,(_nSemestre*(-1)) + 2, _nPosArr + _nValAux)
			_aTotais[1][_nPosArr  ] += &_cCpoBase                    			//Soma base  (?? seis meses)
			_aTotais[1][_nPosArr+1] := _aTotais[1][_nPosArr]/6		        	//Média base (?? seis meses)
			//Fórmula utilizada para identificar se o mês sendo tratado representa o final dos seis meses selecionados
			if _nCont3 == (Int(_nCont3/6)*6) .Or. _nCont3==MV_PAR02
				_nPosCol := _nProxCol+MV_PAR02+_nSemestre-1
			   //	_aCol[_nPProd+00][_nPosCol] := _aTotais[1,_nPosArr] 		//Soma base ?? seis meses
			endif
			_nProxCol++
		next
		//Restauro os valores iniciais
		_cMesAux2 := _cMesBkp
		_nAnoAux2 := _nAnoBkp
		//Previsão
		AADD(_aCol,Array(_nAddCol))
		_aCol[_nPProd+01][01] := "Previsão"        		//Informação
		_aCol[_nPProd+01][02] := (_cAlias)->B1_COD		//Código
		_aCol[_nPProd+01][03] := (_cAlias)->B1_DESC		//Descrição
		_aCol[_nPProd+01][04] := (_cAlias)->B1_UM		//Unidade de medida
		_aCol[_nPProd+01][05] := (_cAlias)->SALDO_ATU	//Saldo atual
		_nProxCol  := 6
		_nSemestre := 1
		//Monta as colunas dinâmicas de acordo com o número de meses escolhidos
		for _nCont4 := 1 to MV_PAR02 //Número de meses
			_cCpoPrev := (_cAlias) + "->PREV" + AllTrim(_nAnoAux2) + _cMesAux2
			_aCol[_nPProd+01][_nProxCol] := &_cCpoPrev
			//Avalia se o mês corrente será considerado no cálculo da média para projeção de seis meses
			if (AllTrim(_nAnoAux2) + _cMesAux2) >= (SubStr(MV_PAR25,3,4)+SubStr(MV_PAR25,1,2)) .AND. (AllTrim(_nAnoAux2) + _cMesAux2) <= (SubStr(MV_PAR26,3,4)+SubStr(MV_PAR26,1,2))
				_nBasPrev += &_cCpoPrev
				_nBasReal += &(StrTran(_cCpoPrev,"PREV","REAL"))
				_nBasBase += &(StrTran(_cCpoPrev,"PREV","BASE"))
				_nConBas++
			endif
			//Verifica se haverá mudança de ano e define o mês a ser tratado
			if _cMesAux2 == "01"
				_cMesAux2 := "12"
				_nAnoAux2 := cValToChar(val(_nAnoAux2)-1)
			else
				_cMesAux2 := StrZero((Val(_cMesAux2)-1),2)
			endif
			//Verifica a qual semestre pertence o mês que está sendo tratato (lembrando que se trata dos 1º, 2º, 3º seis meses, etc. e não do semestre letivo)
			if _nCont4 > (_nSemestre * 6)
				_nSemestre++
				_nValAux := 2
			else
				_nValAux := 0
			endif                     
			//Fórmula criada para identificar a posição do array que deverá ser manipulado, de acordo com o mês sendo tratado, totalizando por "semestre"
			_nPosArr := IIF(_nSemestre==1,(_nSemestre*(-1)) + 2, _nPosArr + _nValAux)
			_aTotais[2][_nPosArr  ] += &_cCpoPrev                    			//Soma base (?? seis meses)
			_aTotais[2][_nPosArr+1] := _aTotais[2][_nPosArr]/6		        	//Média base (?? seis meses)
			_nProxCol++
		next		
		//Restauro os valores iniciais
		_cMesAux2 := _cMesBkp
		_nAnoAux2 := _nAnoBkp
		//Real
		AADD(_aCol,Array(_nAddCol))
		_aCol[_nPProd+02][01] := "Real"					//Informação
		_aCol[_nPProd+02][02] := (_cAlias)->B1_COD		//Código
		_aCol[_nPProd+02][03] := (_cAlias)->B1_DESC		//Descrição
		_aCol[_nPProd+02][04] := (_cAlias)->B1_UM		//Unidade de medida
		_aCol[_nPProd+02][05] := (_cAlias)->SALDO_ATU	//Saldo atual
		_nProxCol  := 6
		_nSemestre := 1
		//Monta as colunas dinâmicas de acordo com o número de meses escolhidos
		for _nCont5 := 1 to MV_PAR02 //Número de meses
			_cCpoReal := (_cAlias) + "->REAL" + AllTrim(_nAnoAux2) + _cMesAux2
			_aCol[_nPProd+02][_nProxCol] := &_cCpoReal
			//Verifica se haverá mudança de ano e define o mês a ser tratado
			if _cMesAux2 == "01"
				_cMesAux2 := "12"
				_nAnoAux2 := cValToChar(val(_nAnoAux2)-1)
			else
				_cMesAux2 := StrZero((Val(_cMesAux2)-1),2)
			endif
			//Verifica a qual semestre pertence o mês que está sendo tratato (lembrando que se trata dos 1º, 2º, 3º seis meses, etc. e não do semestre letivo)
			if _nCont5 > (_nSemestre * 6)
				_nSemestre++
				_nValAux := 2
			else
				_nValAux := 0
			endif
			//Fórmula criada para identificar a posição do array que deverá ser manipulado, de acordo com o mês sendo tratado, totalizando por "semestre"
			_nPosArr := IIF(_nSemestre==1,(_nSemestre*(-1)) + 2, _nPosArr + _nValAux)
			_aTotais[3][_nPosArr  ] += &_cCpoReal                    			//Soma base (?? seis meses)
			_aTotais[3][_nPosArr+1] := _aTotais[3][_nPosArr]/6		        	//Média base (?? seis meses)
			_nProxCol++
		next
		//Restauro os valores iniciais
		_cMesAux2 := _cMesBkp
		_nAnoAux2 := _nAnoBkp
		//Diferença
		AADD(_aCol,Array(_nAddCol))
		_aCol[_nPProd+03][01] := "Diferença"			//Informação
		_aCol[_nPProd+03][02] := (_cAlias)->B1_COD		//Código
		_aCol[_nPProd+03][03] := (_cAlias)->B1_DESC		//Descrição
		_aCol[_nPProd+03][04] := (_cAlias)->B1_UM		//Unidade de medida
		_aCol[_nPProd+03][05] := (_cAlias)->SALDO_ATU	//Saldo atual
		_nProxCol  := 6
		_nSemestre := 1
		//Monta as colunas dinâmicas de acordo com o número de meses escolhidos
		for _nCont6 := 1 to MV_PAR02 //Número de meses
			_cCpoReal := (_cAlias) + "->REAL" + AllTrim(_nAnoAux2) + _cMesAux2
			_cCpoPrev := (_cAlias) + "->PREV" + AllTrim(_nAnoAux2) + _cMesAux2
			_nDiferen := (&_cCpoPrev) - (&_cCpoReal) //Diferença = Previsto - Real
			_aCol[_nPProd+03][_nProxCol] := _nDiferen
			//Verifica se haverá mudança de ano e define o mês a ser tratado
			if _cMesAux2 == "01"
				_cMesAux2 := "12"
				_nAnoAux2 := cValToChar(val(_nAnoAux2)-1)
			else
				_cMesAux2 := StrZero((Val(_cMesAux2)-1),2)
			endif
			//Verifica a qual semestre pertence o mês que está sendo tratato (lembrando que se trata dos 1º, 2º, 3º seis meses, etc. e não do semestre letivo)
			if _nCont6 > (_nSemestre * 6)
				_nSemestre++
				_nValAux := 2
			else
				_nValAux := 0
			endif
			//Fórmula criada para identificar a posição do array que deverá ser manipulado, de acordo com o mês sendo tratado, totalizando por "semestre"
			_nPosArr := IIF(_nSemestre==1,(_nSemestre*(-1)) + 2, _nPosArr + _nValAux)
			_aTotais[4][_nPosArr  ] += &_cCpoBase                    			//Soma base (?? seis meses)
			_aTotais[4][_nPosArr  ] += &_cCpoBase                    			//Soma base (?? seis meses)
			_aTotais[4][_nPosArr+1] := _aTotais[4][_nPosArr]/6		        	//Média base (?? seis meses)
			_nProxCol++
		next
		//Preenche o _aCol (matriz principal) com os totalizadores a cada seis meses
		for _nCntTot := 1 to _nQtdTot*2 Step 2
			for _nLinhas := 1 to 4
				_aCol[_nPProd+_nLinhas-1][_nProxCol] := _aTotais[_nLinhas,_nCntTot]
			next
			_nProxCol++
			//Implementa a coluna de percentual de acréscimo, decréscimo entre uma linha e outra
			_aCol[_nPProd+2-1][_nProxCol] := (_aTotais[2,_nCntTot]/_aTotais[1,_nCntTot])-1 //Linha do consumo previsto
			_aCol[_nPProd+3-1][_nProxCol] := (_aTotais[3,_nCntTot]/_aTotais[2,_nCntTot])-1 //Linha do consumo real
			_aCol[_nPProd+4-1][_nProxCol] := (_aTotais[4,_nCntTot]/_aTotais[3,_nCntTot])-1 //Linha da diferença entre previsto e real
			_nProxCol++
		next
		//Preenche o _aCol (matriz principal) com os totalizadores a cada 12 meses
		_nQtdAno := Int(MV_PAR02/12) //IIF(Int(MV_PAR02/12)==(MV_PAR02/12),(MV_PAR02/12),Int(MV_PAR02/12)+1)
		for _nAno := 1 to _nQtdAno
			for _nLinha := 1 to 4
				_nPos1 := ((4*(_nAno-1))+1)
				If _nQtdTot == 1
					_nSomAux := (_aTotais[_nLinha][_nPos1])
				else
					_nPos2 := ((4*(_nAno-1))+1)+ 2
					_nSomAux := ((_aTotais[_nLinha][_nPos1]) + (_aTotais[_nLinha][_nPos2]))
				endif
				_aCol[_nPProd+_nLinha-1][_nProxCol] := _nSomAux
			next
			_nProxCol++
		next
		//Preenche o _aCol (matriz principal) com as médias para cada seis meses
		for _nCntMed := 2 to (_nQtdTot*2) Step 2
			for _nLinhas := 1 to 4
				_aCol[_nPProd+_nLinhas-1][_nProxCol] := _aTotais[_nLinhas,_nCntMed]
			next
			_nProxCol++
		next
		//Preenche o _aCol (matriz principal) com as médias para cada doze meses	
		for _nAno := 1 to _nQtdAno
			for _nLinha := 1 to 4
				_nPos1 := ((4*(_nAno-1))+1)
				If _nQtdTot == 1
					_nMedAux := ((_aTotais[_nLinha][_nPos1])/12)
				else
					_nPos2 := ((4*(_nAno-1))+1)+2
					_nMedAux := (((_aTotais[_nLinha][_nPos1]) + (_aTotais[_nLinha][_nPos2]))/12)
				endif
				_aCol[_nPProd+_nLinha-1][_nProxCol] := _nMedAux
			next
			_nProxCol++
		next
		//Preenche o _aCol (matriz principal) com o cálculo do tempo de estoque (saldo atual/média últimos seis meses)
		for _nLin2 := 1 to 4
			_aCol[_nPProd+_nLin2-1][_nProxCol] := Int((((_cAlias)->SALDO_ATU)/(_nBasBase/_nConBas))*30)
		next
		_nProxCol++
		//Preenche o _aCol (matriz principal) com o cálculo da previsão para os próximos seis meses (saldo atual-(média últimos seis meses*6))
		for _nLin3 := 1 To 4
			_aCol[_nPProd+_nLin3-1][_nProxCol] := (((_cAlias)->SALDO_ATU)-((_nBasPrev/_nConBas)*6))
		next
		_nProxCol++
		//Preenche o _aCol (matriz principal) com a previsão de entrada para o produto (sem considerar as solicitações de compras)
		for _nLin4 := 1 to 4
			_aCol[_nPProd+_nLin4-1][_nProxCol] := ((_cAlias)->ENT_PREV)
		next
		_nProxCol++
		//Restauro os valores iniciais
		_cMesAux2 := _cMesBkp
		_nAnoAux2 := _nAnoBkp
		_nCont++
		_nPProd   := (_nCont * _nQtdLin) + 1
		(_cAlias)->(dbSkip())
	enddo
	_aLegend := {}
	//Conteúdo da aba (legenda) , com a descrição dos cálculos
	AAdd(_aLegend, {"Consumo base"				,"Refere-se ao consumo do mesmo mês no ano anterior."																					})
	AAdd(_aLegend, {"Previsão"	  				,"Consumo base considerando com percentual de acréscimo definido para o mês."															})
	AAdd(_aLegend, {"Real"	  	  				,"Consumo real do mês."																													})
	AAdd(_aLegend, {"Diferença"	  				,"Consumo previsto para o mes menos o real."																							})
	AAdd(_aLegend, {"Saldo Atual" 				,"Posição atual do produto em estoque, não considera reservas."																			})
	AAdd(_aLegend, {"Total Xº 6 Meses" 			,"Totalizador para cada período de seis meses do relatório."																			})
	AAdd(_aLegend, {"%" 						,"Percentual de acréscimo para o período, comparado à linha anterior."																	})
	AAdd(_aLegend, {"Total Xº 12 Meses" 		,"Totalizador para cada período de doze meses do relatório."																			})
	AAdd(_aLegend, {"Média Xº 6 Meses"  		,"Média para cada período de seis meses do relatório."								  													})
	AAdd(_aLegend, {"Média Xº 12 Meses" 		,"Média para cada período de doze meses do relatório, só será exibida essa coluna caso o período selecionado seja maior que 6 meses."	})
	AAdd(_aLegend, {"Estoque para"  			,"Saldo atual dividido pela média dos meses definidos como base para projeção, multiplicado por 30 dias."		  						})
	AAdd(_aLegend, {"Prev. Prox. 6 Meses"  		,"Saldo atual menos a multiplicação da média dos meses definidos como base para projeção por seis meses." 								})
	AAdd(_aLegend, {"Entr. Prev."		  		,"Soma das quantidades em pedido de compras em aberto mais a soma das quantidades em ordem de produção." 								})
	//Impressão da legenda
	oExcel:AddWorkSheet(_cSheet3)
	oExcel:AddTable (_cSheet3,_cTitulo)
	oExcel:AddColumn(_cSheet3,_cTitulo,PadR("CAMPO",10)	  	,1,1,.F.)
	oExcel:AddColumn(_cSheet3,_cTitulo,PadR("DESCRIÇÃO",15)	,1,1,.F.)
	if len(_aPar) > 0
		for _nPosPar := 1 to Len(_aPar)
			oExcel:AddRow(_cSheet1, _cTitulo, _aPar[_nPosPar])
		next
	endif
	if len(_aLegend) > 0
		for _nPosLeg := 1 to Len(_aLegend)
			oExcel:AddRow(_cSheet3, _cTitulo, _aLegend[_nPosLeg])
		next
	endif
	if Len(_aCol) > 0
		_nItens  := 0
		for _x   := 1 to Len(_aCol)
			IncProc("Finalizando itens na planilha...")
			_nItens++
			oExcel:AddRow(_cSheet2, _cTitulo, _aCol[_x])
		next
		if _nItens > 0
			IncProc("Abrindo arquivo...")
			oExcel:Activate()
			_cFile := (CriaTrab(nil, .F.) + ".xml")
			while File(_cFile)
				_cFile := CriaTrab(nil, .F.) + ".xml"
			enddo
			oExcel:GetXMLFile(_cFile)
			oExcel:DeActivate()
			if !File(_cFile)
				_cFile := ""
				Break
			endif
			//Caso não tenha sido definido um local, o arquivo será gerado na pasta TEMP
			if empty(_cFileTMP)
				_cFileTMP := GetTempPath() + GetNextAlias()+".xml"
			endif
			if file(_cFileTMP)
				if _lUsrDef
					MsgAlert("O arquivo '"+_cFileTMP+"' já existia no destino. Portanto, o nome e caminho do arquivo será alterado!",_cRotina+"_006")
				endif
				while file(_cFileTMP)
					_cFileTMP := GetTempPath() + GetNextAlias()+".xml"
				enddo
			endif
	/*		//26/08/2016 - ANDERSON C. P. COELHO - TRECHO TEMPORÁRIO UTILIZADO PARA AUDITAR OS ARQUIVOS GERADOS PELO USUÁRIO (ENVIO POR E-MAIL PARA anderson.coelho@allss.com.br;arthur.silva@allss.com.br;renan.santos@allss.com.br)
			//RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert)
				If ExistBlock("RCFGM001") .AND. DTOS(Date()) <= "20161231"
					_cMsg := "E-mail de auditoria (até 31/10/2016) dos arquivos de consumo mensal gerados pela equipe de compras da Arcolor. Qualquer dúvida, falar com Anderson, Arthur ou Renan da ALL System Solutions!"+_CLRF
					_cMsg += "<BR>     >>> Data.....: "+DTOC(Date())+_CLRF
					_cMsg += "<BR>     >>> Hora.....: "+Time()      +_CLRF
					_cMsg += "<BR>     >>> __cUserId: "+__cUserId   +_CLRF
					_cMsg += "<BR>     >>> cUserName: "+cUserName   +_CLRF
					_cMsg += "<BR>     >>> Arquivo..: "+_cFileTMP   +_CLRF
					U_RCFGM001(	"Compras Arcolor",;
								_cMsg,;
								"anderson.coelho@allss.com.br;arthur.silva@allss.com.br;livia.dcorte@allss.com.br",;
								_cFile,;
								NIL,;
								NIL,;
								"Auditoria do Relatório de Consumo Mensal",;
								.F.,;
								.F.)
				endif
			//FIM 26/08/2016 - ANDERSON C. P. COELHO - TRECHO TEMPORÁRIO UTILIZADO PARA AUDITAR OS ARQUIVOS GERADOS PELO USUÁRIO (ENVIO POR E-MAIL PARA anderson.coelho@allss.com.br;arthur.silva@allss.com.br;renan.santos@allss.com.br)
	*/
			__CopyFile(_cFile , _cFileTMP, , , .F.)
			if !file(_cFileTMP)
				if _lUsrDef
					MsgAlert("Houve uma falha de permissão na tentativa de definir o nome do arquivo como '"+_cFileTMP+"'. Portanto, o caminho/nome será reavaliado para que você não perca o relatório gerado!",_cRotina+"_007")
				endif
				_cFileTMP := GetTempPath() + GetNextAlias()+".xml"
				while file(_cFileTMP)
					_cFileTMP := GetTempPath() + GetNextAlias()+".xml"
				enddo
				if !__CopyFile(_cFile , _cFileTMP, , , .F.)
					fErase( _cFile )
					_cFile := ""
					Break
				endif
			endif
			fErase(_cFile)
			_cFile := _cFileTMP
			if !File(_cFile)
				_cFile := ""
				Break
			endif
			oMsExcel := MsExcel():New()
			oMsExcel:WorkBooks:Open(_cFile)
			oMsExcel:SetVisible(.T.)
			MsgInfo("Arquivo '"+_cFile+"' salvo no local definido!",_cRotina+"_003")
			oMsExcel := oMsExcel:Destroy()
		else
			MsgInfo("Atenção! Sem dados a serem apresentados!",_cRotina+"_004")
		endif
	endif
	FreeObj(oExcel)
	oExcel := nil
return
/*/{Protheus.doc} SelecionaDados
@description Função responsável por executar a consulta no banco de dados, utilizada como static function apenas para uso com MsgRun.
@author Adriano Leonardo de Souza
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
/*
static function	SelecionaDados()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.F.)	
return
*/
