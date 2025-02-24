#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MSMGADD.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "XMLXFUN.CH"

#DEFINE _CLRF CHR(13)+CHR(10)

/*/{Protheus.doc} RFINE011
@description Monta tela da ficha financeira conforme dados solicitados pelo cliente.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 10/09/2013
@version 2.0
@history 04/12/2013, Júlio Soares, Implementada a coluna de pedido conforme solicitação do cliente.
@history 14/04/2014, Júlio Soares, Incluida a visualização por cliente ou aglutinado pelo CNPJ centralizador.
@history 15/10/2019, Anderson Coelho (ALLSS Soluções em Sistemas), Ficha Financeira remodelada para o padrão FWMBrowse, conforme solicitação do Sr. Mário. A rotina ainda será testada com maior profundidade antes de ser inserida em produção pela consultora Lívia Della Corte.
@history 22/10/2019, Anderson Coelho (ALLSS Soluções em Sistemas), Error.log corrigido na chamada da função Pergunte e Nova Ficha Financeira inserida em produção, conforme ativação realizada por meio do novo parâmetro criado para este fim ("AR_NEWFFIN").
@param _cOrigem, caracter, Origem da chamada da rotina (para identificar se foi chamada pela tecla F11.)
@type function
@see https://allss.com.br
/*/
user function RFINE011(_cOrigem)
	local _lNewRot := SuperGetMv("AR_NEWFFIN",,.T.)
	if !ExistBlock("FNE11MVC") .OR. !_lNewRot
		FFAntiga(_cOrigem)
	else
		U_FNE11MVC(_cOrigem)
	endif
return
/*/{Protheus.doc} FNE11MVC (RFINE011)
@description Nova Ficha Financeira.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 10/09/2013
@version 2.0
@history 22/10/2019, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Implementada em produção a nova Ficha Financeira solicitada pelo Sr. Mário pós migração de release P12.1.17 x P12.1.25, com o objetivo de tornar a resolução da tela e suas fontes nos mesmos padrões dos mBrowsers da TOTVS.
@param _cOrigem, caracter, Origem da chamada da rotina (para identificar se foi chamada pela tecla F11.)
@type function
@see https://allss.com.br
/*/
user function FNE11MVC(_cOrigem)
//	local   _oBwBkp11 := IIF(Type("oBrowse"  )<>"U", oBrowse  , NIL)
//	local   _oDlBkp11 := IIF(Type("oDlg"     )<>"U", oDlg     , NIL)
	Local nx
	local   _cCadBkp  := IIF(Type("cCadastro")<>"U", cCadastro, NIL)
	local   _cTitBkp  := IIF(Type("Titulo"   )<>"U", Titulo   , NIL)
	local   _aArea    := GetArea()
	local   _aSvSA1   := SA1->(GetArea())
	local   _aSvSC5   := SC5->(GetArea())
	local   _aSvSC6   := SC6->(GetArea())
	local   _aSvSC7   := SC7->(GetArea())
	local   _aSvSUA   := SUA->(GetArea())
	local   _aSvSUB   := SUB->(GetArea())
	local   _aSvACF   := ACF->(GetArea())
	local   _aSvSE1   := SE1->(GetArea())
	local   _aSvSE5   := SE5->(GetArea())
	local   _aSvSD1   := SD1->(GetArea())
	local   _aSvSD2   := SD2->(GetArea())
	local   _aSvSF1   := SF1->(GetArea())
	local   _aSvSF2   := SF2->(GetArea())
	local   _aSize    := MsAdvSize()
	local   _aStruSE1 := SE1->(dbStruct())
	local   _lIncBkp  := IIF(type("INCLUI")=="L",INCLUI,.F.)
	local   _lAltBkp  := IIF(type("ALTERA")=="L",ALTERA,.F.)

	local   _oDlgF11  as object
	local   _oBrwF11  as object
	local   _oTmpTab  as object
//	local   oColumn   as object
	local   _aColumn  as array
	local   _aStru    as array
	local   _cQuery   as character
	local   _cInsert  as character
	local   _cCli     as character
	local   _cLoja    as character
	local   cNomcli   as character
	local   _cCGCent  as character
	local   _cData1   as character
	local   _cData2   as character
	local   _cTabIns  as character

	private _cPerg    := "FIC010"
	private _cRotina  := "RFINE011"
	private _cAliQry  := GetNextAlias()
	private _cAlias   := CriaTrab(,.F.)
	private _aRotBkp  := IIF(type("aRotina")<>"U",aRotina,{})
	private aRotina   := IIF(ExistBlock("FNE11M"),U_FNE11M(),{})

	INCLUI  := .F.
	ALTERA  := .F.

//	aPosGet := MsObjGetPos(_aSize[3]-_aSize[1], 315,{{003,033,073,103}} )
	ValidPerg()
	if AllTrim(_cOrigem) == "F11" .OR. __cUserId $ SuperGetMV("MV_FICHFIN",,"000000")
		// Alterado em 22/10/2013 por Júlio Soares para _cPerg (False) a pedido do Sr. Mario que solicitou a NÃO apresentação
		// dos parâmetros na entrada da tela.
		Pergunte(_cPerg,.F.)
			RestArea(_aSvSE1)
			RestArea(_aSvSE5)
			RestArea(_aSvSA1)
			RestArea(_aSvSC5)
			RestArea(_aSvSC6)
			RestArea(_aSvSC7)
			RestArea(_aSvSUA)
			RestArea(_aSvSUB)
			RestArea(_aSvACF)
			RestArea(_aSvSD1)
			RestArea(_aSvSD2)
			RestArea(_aSvSF1)
			RestArea(_aSvSF2)
			RestArea(_aArea)
	else
		if !Pergunte(_cPerg,.T.)
			RestArea(_aSvSE1)
			RestArea(_aSvSE5)
			RestArea(_aSvSA1)
			RestArea(_aSvSC5)
			RestArea(_aSvSC6)
			RestArea(_aSvSC7)
			RestArea(_aSvSUA)
			RestArea(_aSvSUB)
			RestArea(_aSvACF)
			RestArea(_aSvSD1)
			RestArea(_aSvSD2)
			RestArea(_aSvSF1)
			RestArea(_aSvSF2)
			RestArea(_aArea)
			return
		endif
	endif
	if type("cFilAux")=="U"
		public cFilAux := FwFilial()
	endif
	// Identifica por onde a rotina está sendo chamada para determinar os parâmetros do cliente posicionado
	if (Alias() == "SC9" .OR. UPPER(Alltrim(FunName()))=="MATA450")   // SC9 ou Tela de análise de crédito do pedido
		_cCli    := SC9->C9_CLIENTE
		_cLoja   := SC9->C9_LOJA
	elseif (Alias() == "SC5" .OR. UPPER(Alltrim(FunName()))=="MATA410") // Tela de companhamento de pedido
		if Alias() == "SA1"
			_cCli    := SA1->A1_COD
			_cLoja   := SA1->A1_LOJA
		elseif type("M->C5_CLIENTE") == "C"
			_cCli    := M->C5_CLIENTE
			_cLoja   := M->C5_LOJACLI
		else
			_cCli    := SC5->C5_CLIENTE
			_cLoja   := SC5->C5_LOJACLI
		endif
	elseif UPPER(Alltrim(FunName()))=="RFATA026" // Tela de companhamento de pedido
		if Alias() == "SA1"
			_cCli    := SA1->A1_COD
			_cLoja   := SA1->A1_LOJA
		elseif type(Alias()+"->C9_CLIENTE") == "C"
			_cCli    := (Alias())->C9_CLIENTE
			_cLoja   := (Alias())->C9_LOJA
		elseif type("C9_CLIENTE") == "C"
			_cCli    := C9_CLIENTE
			_cLoja   := C9_LOJA
		else
			_cCli    := ""
			_cLoja   := ""
		endif
	elseif Alias() == "ACF" .OR. (TkGetTipoAte() == "3" .OR. (type("nFolder")=="N" .AND. nFolder==3)) .OR. UPPER(Alltrim(FunName()))=="TMKA350" // Tela de atendimento receptivo do Telecobrança
		if Alias() == "SA1"
			_cCli    := SA1->A1_COD
			_cLoja   := SA1->A1_LOJA
		elseif type("M->ACF_CLIENT") == "C"
			_cCli    := M->ACF_CLIENT
			_cLoja   := M->ACF_LOJA
		else
			_cCli    := ACF->ACF_CLIENT
			_cLoja   := ACF->ACF_LOJA
		endif
	elseif Alias() == "SUA" .OR. (TkGetTipoAte() == "2" .OR. (type("nFolder")=="N" .AND. nFolder==2)) // Tela de atendimento
		if Alias() == "SA1"
			_cCli    := SA1->A1_COD
			_cLoja   := SA1->A1_LOJA
		elseif type("M->UA_CLIENTE") == "C"
			_cCli    := M->UA_CLIENTE
			_cLoja   := M->UA_LOJA
		else
			_cCli    := SUA->UA_CLIENTE
			_cLoja   := SUA->UA_LOJA
		endif
	elseif Alias() == "SUC" .OR. (TkGetTipoAte() == "1" .OR. (type("nFolder")=="N" .AND. nFolder==1)) // Tela de Telemarketing
		if Alias() == "SA1"
			_cCli    := SA1->A1_COD
			_cLoja   := SA1->A1_LOJA
		elseif type("M->UC_CLIENTE") == "C"
			_cCli    := M->UC_CLIENTE
			_cLoja   := M->UC_LOJA
		else
			_cCli    := SUC->UC_CLIENTE
			_cLoja   := SUC->UC_LOJA
		endif
	elseif Alias() == "SF2" // Documento de Saída
		_cCli    := SF2->F2_CLIENTE
		_cLoja   := SF2->F2_LOJA
	elseif Alias() == "SE1" // Títulos a Receber
		if Alias() == "SA1"
			_cCli    := SA1->A1_COD
			_cLoja   := SA1->A1_LOJA
		elseif type("M->E1_CLIENTE") == "C"
			_cCli    := M->E1_CLIENTE
			_cLoja   := M->E1_LOJA
		else
			_cCli    := SE1->E1_CLIENTE
			_cLoja   := SE1->E1_LOJA
		endif
	else
		_cCli    := SA1->A1_COD
		_cLoja   := SA1->A1_LOJA
	endif
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	if !empty(_cCli) .AND. SA1->(MsSeek(FWFilial("SA1") + _cCli + _cLoja,.T.,.F.))
		cNomcli  := SA1->A1_NOME
		_cCGCent := SA1->A1_CGCCENT
	else
		RestArea(_aSvSE1)
		RestArea(_aSvSE5)
		RestArea(_aSvSA1)
		RestArea(_aSvSC5)
		RestArea(_aSvSC6)
		RestArea(_aSvSC7)
		RestArea(_aSvSUA)
		RestArea(_aSvSUB)
		RestArea(_aSvACF)
		RestArea(_aSvSD1)
		RestArea(_aSvSD2)
		RestArea(_aSvSF1)
		RestArea(_aSvSF2)
		RestArea(_aArea)
		return
	endif
	if !empty(MV_PAR01) .AND. type("MV_PAR01") == 'D'
		_cData1 := DtoC(MV_PAR01)
	else
		_cData1 := "01/01/2000"
	endif
	if !empty (MV_PAR02) .AND. type("MV_PAR02") == 'D'
		_cData2 := DtoC(MV_PAR02)
	else
		_cData2 := "31/12/2049"
	endif
	if Select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	endif
	if Select(_cAliQry) > 0
		(_cAliQry)->(dbCloseArea())
	endif
	_cQuery := ""
	if MV_PAR05 == 2
		_cQuery += " AND SE1.E1_TIPO <> 'PR' "
	endif
	_cQuery += " AND SE1.E1_PREFIXO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
	if MV_PAR17 == 1
		_cQuery += " AND SE1.E1_CLIENTE   = '"+_cCli   +"' "
		_cQuery += " AND SE1.E1_LOJA      = '"+_cLoja  +"' "
	else
		_cQuery += " AND SE1.E1_CGCCENT   = '"+_cCGCent+"' "
	endif
	_cQuery += " AND SE1.E1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
	_cQuery += " AND SE1.E1_VENCREA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	if MV_PAR11 == 2
		_cQuery += " AND SE1.E1_NUMLIQ    = '' "
		_cQuery += " AND SE1.E1_TIPOLIQ   = '' "
	endif
	_cQuery := "%"+_cQuery+"%"
	BeginSql Alias _cAliQry
/*
		SELECT 
				  E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CARTEIR, E1_EMISSAO, E1_PEDIDO, E1_VALOR
				, E1_SALDO, E1_VENDRES, E1_VENCTO, E1_BAIXA, E1_NUMBCO, E1_OBSTIT, E1_CLIENTE, E1_LOJA
				, E1_NOMCLI, E1_CGCCENT, ISNULL(F2_CONDESC,'') [F2_CONDESC], SE1.R_E_C_N_O_ RECSE1, (ROW_NUMBER() OVER (ORDER BY E1_VENCTO DESC, E1_EMISSAO DESC, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA)) REG
*/
		SELECT 
				  E1_FILIAL, E1_PEDIDO, E1_EMISSAO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CARTEIR
				, ISNULL(F2_CONDESC,'') [F2_CONDESC], E1_VALOR, E1_SALDO, E1_VENDRES, E1_VENCTO
				, (CASE WHEN E1_SALDO <> E1_VALOR and E1_SALDO > 0    THEN '' ELSE E1_BAIXA END) E1_BAIXA
				, E1_OBSTIT, E1_NUMBCO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_CGCCENT, E1_PREFIXO
				, SE1.R_E_C_N_O_ RECSE1
				, (ROW_NUMBER() OVER (ORDER BY E1_VENCTO DESC, E1_EMISSAO DESC, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA)) REG
		FROM %table:SE1% SE1 (NOLOCK)
			LEFT JOIN %table:SF2% SF2 (NOLOCK) ON SF2.F2_FILIAL   = (CASE WHEN %xFilial:SE1% = %Exp:Space(Len(SE1->E1_FILIAL))% OR %xFilial:SEF2% = %Exp:Space(Len(SF2->F2_FILIAL))% THEN %xFilial:SF2% ELSE SE1.E1_FILIAL END)				//%xFilial:SF2%
									AND SF2.F2_DUPL    = SE1.E1_NUM
									AND SF2.F2_PREFIXO = SE1.E1_PREFIXO
									AND SF2.F2_CLIENTE = SE1.E1_CLIENTE
									AND SF2.F2_LOJA    = SE1.E1_LOJA
									AND SF2.%NotDel%
		WHERE SE1.E1_FILIAL = %xFilial:SE1%
		  AND SE1.%NotDel%
		  %Exp:_cQuery%
		ORDER BY E1_VENCTO DESC, E1_EMISSAO DESC, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA
	EndSql
	for nX := 1 to len(_aStruSE1)
		if _aStruSE1[nX][2] <> "C" .And. FieldPos(_aStruSE1[nX][1]) <> 0
			TcSetField(_cAliQry,_aStruSE1[nX][1],_aStruSE1[nX][2],_aStruSE1[nX][3],_aStruSE1[nX][4])
		endif
	next nX
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",GetLastQuery()[2])
	dbSelectArea(_cAliQry)
	(_cAliQry)->(dbGoTop())
	_aStru   := (_cAliQry)->(dbStruct())
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_CPOS_QRY_001.TXT",VarInfo(">>> _aStru >>>",_aStru,,.T.,.F.))
	_oTmpTab := FWTemporaryTable():New(_cAlias)
	_oTmpTab:SetFields(_aStru)
	//_oTmpTab:AddIndex("Indice1", {"REG","E1_VENCTO","E1_EMISSAO","E1_FILIAL","E1_PREFIXO","E1_NUM","E1_PARCELA"})
	_oTmpTab:Create()
	_cTabIns := _oTmpTab:GetRealName()
	_cInsert := " INSERT INTO "+_cTabIns+_CLRF
/*
	_cInsert += " 		( 	      E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CARTEIR, E1_EMISSAO, E1_PEDIDO, E1_VALOR "+_CLRF
	_cInsert += " 				, E1_SALDO, E1_VENDRES, E1_VENCTO, E1_BAIXA, E1_NUMBCO, E1_OBSTIT, E1_CLIENTE, E1_LOJA "+_CLRF
	_cInsert += " 				, E1_NOMCLI, E1_CGCCENT, F2_CONDESC, RECSE1 "+_CLRF			//, REG
//	_cInsert += " 				, D_E_L_E_T_, R_E_C_N_O_, R_E_C_D_E_L_ "+_CLRF
*/
	_cInsert += " 		( 	      E1_FILIAL, E1_PEDIDO, E1_EMISSAO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CARTEIR "+_CLRF
	_cInsert += " 				, F2_CONDESC, E1_VALOR, E1_SALDO, E1_VENDRES, E1_VENCTO, E1_BAIXA "+_CLRF
	_cInsert += " 				, E1_OBSTIT, E1_NUMBCO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_CGCCENT, E1_PREFIXO, RECSE1 "+_CLRF
	_cInsert += " 		) "+_CLRF
/*
	_cInsert += " 		SELECT 	  E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CARTEIR, E1_EMISSAO, E1_PEDIDO, E1_VALOR "+_CLRF
	_cInsert += " 				, E1_SALDO, E1_VENDRES, E1_VENCTO, E1_BAIXA, E1_NUMBCO, E1_OBSTIT, E1_CLIENTE, E1_LOJA "+_CLRF
	_cInsert += " 				, E1_NOMCLI, E1_CGCCENT, ISNULL(F2_CONDESC,'') [F2_CONDESC], SE1.R_E_C_N_O_ RECSE1 "+_CLRF		//, (ROW_NUMBER() OVER (ORDER BY E1_VENCTO DESC, E1_EMISSAO DESC, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA)) REG
*/
	_cInsert += " 		SELECT 	  E1_FILIAL, E1_PEDIDO, E1_EMISSAO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CARTEIR "+_CLRF
	_cInsert += " 				, ISNULL(F2_CONDESC,'') [F2_CONDESC], E1_VALOR, E1_SALDO, E1_VENDRES, E1_VENCTO "+_CLRF
	_cInsert += " 				, (CASE WHEN E1_SALDO <> E1_VALOR and E1_SALDO > 0    THEN '' ELSE E1_BAIXA END) E1_BAIXA "+_CLRF
	_cInsert += " 				, E1_OBSTIT, E1_NUMBCO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_CGCCENT, E1_PREFIXO "+_CLRF
	_cInsert += " 				, SE1.R_E_C_N_O_ RECSE1 "+_CLRF
//	_cInsert += " 				, (ROW_NUMBER() OVER (ORDER BY E1_VENCTO DESC, E1_EMISSAO DESC, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA)) REG "+_CLRF
//	_cInsert += " 				, SE1.D_E_L_E_T_, SE1.R_E_C_N_O_, SE1.R_E_C_D_E_L_ "+_CLRF
	_cInsert += " 		FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+_CLRF
	_cInsert += " 			LEFT JOIN "+RetSqlName("SF2")+" SF2 (NOLOCK) ON SF2.F2_FILIAL   = (CASE WHEN '"+xFilial("SE1")+"' = '"+Space(Len(SE1->E1_FILIAL))+"' OR '"+xFilial("SF2")+"' = '"+Space(Len(SF2->F2_FILIAL))+"' THEN '"+xFilial("SF2")+"' ELSE SE1.E1_FILIAL END) "+_CLRF
	_cInsert += " 									AND SF2.F2_DUPL    = SE1.E1_NUM "+_CLRF
	_cInsert += " 									AND SF2.F2_PREFIXO = SE1.E1_PREFIXO "+_CLRF
	_cInsert += " 									AND SF2.F2_CLIENTE = SE1.E1_CLIENTE "+_CLRF
	_cInsert += " 									AND SF2.F2_LOJA    = SE1.E1_LOJA "+_CLRF
	_cInsert += " 									AND SF2.D_E_L_E_T_ = '' "+_CLRF
	_cInsert += " 		WHERE SE1.E1_FILIAL    = '"+xFilial("SE1")+"' "+_CLRF
	_cInsert += " 		  AND SE1.D_E_L_E_T_   = '' "+_CLRF
	_cInsert += " 		  "+StrTran(_cQuery,"%","")+_CLRF
	_cInsert += " 		ORDER BY E1_VENCTO DESC, E1_EMISSAO DESC, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA "+_CLRF
//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cInsert)
	if TcSqlExec(_cInsert) < 0
		MsgStop("Problemas na formação da tabela temporária de dados!"+_CLRF+TCSQLError(),_cRotina+"_007")
	endif
	//Define a janela do Browse
	//_oDlgF11  := TDialog():New(0, 0, 600, 800,,,,,,,,,,.T.)
	//_oDlgF11  := TDialog():New(_aSize[1],_aSize[1],_aSize[6],_aSize[5],"["+_cRotina+"] Ficha Financeira",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	_oDlgF11    := MsDialog():New(_aSize[1],_aSize[1],_aSize[6],_aSize[5],"["+_cRotina+"] Ficha Financeira - "+FWFilialName(),,,,,CLR_BLACK,CLR_WHITE,,,.T.,,,,.T.)

	// Define o Browse
	_oBrwF11 := FWMBrowse():New()
//	_oBrwF11 := FWBrowse():New(_oDlgF11)
//	_oBrwF11 := FWMBrowse():New(_oDlgF11)
//	_oBrwF11:SetDataTable(.T.)

	//Indica o container para criação do Browse
	_oBrwF11:SetOwner(_oDlgF11)

	//Define o identificador do Browse utiliza na gravação das configurações no profile do usuário.
    //Deve ser utilizado quando existir mais de um Browse na rotina. 
    //Obs.: o tamanho máximo do ID deve ser de 4 (quatro) caracteres
	_oBrwF11:SetProfileID(_cRotina+"_"+__cUserId)

	//Descrição do browse
	_oBrwF11:SetDescription("Cliente: "+_cCli+"/"+_cLoja+" - "+Capital(AllTrim(cNomcli))+"     |     Período: "+_cData1+"  a  "+_cData2)

	//Query do browse
	//_oBrwF11:SetDataQuery(_cAlias)
	//_oBrwF11:GetQuery()		//GetLastQuery()[2]

	//Definição do Alias do Browse
	_oBrwF11:SetAlias(_cAlias)

	//Define o Menudef
	_oBrwF11:SetMenuDef("FNE11M")

	//Desativa a possibilidade de exclusão de linhas do browse
	//_oBrwF11:SetDelete( .F., {|| nil} )

	//Desativa a inserção de novas linhas no Browse pelo usuário
	//_oBrwF11:SetInsert(.F.)

	//Habilita a utilização do localizador de registros no Browse (Passar o Code-Block executado para localização das informações, caso não seja informado será utilizado o padrão).
	//_oBrwF11:SetLocate()

	//Desliga a exibição dos detalhes
	//_oBrwF11:DisableDetails()

	// Cria uma coluna de marca/desmarca
	//oColumn := _oBrwF11:AddMarkColumns({||If(.T./*Função de Marca/desmaca*/,'LBOK','LBNO')},{|_oBrwF11|/*Função de DOUBLECLICK*/},{|_oBrwF11|/* Função de HEADERCLICK*/})
 
	// Cria uma coluna de status
	//oColumn := _oBrwF11:AddStatusColumns({||If(.T./*Função de avaliação de status*/,'BR_VERDE','BR_VERMELHO')},{|_oBrwF11|/*Função de DOUBLECLICK*/})

	//Definição de ação para o duplo clique da linha
	_oBrwF11:SetDoubleClick( {|| U_FNE11C() } )
 
	//Definição de cor da linha posicionada
	//_oBrwF11:SetBlkBackColor({|| Str(CLR_LIGHTGRAY) }) 
	//_oBrwF11:SetBlkBackColor({|| Str(CLR_WHITE)     }) 
 
	//Definição de cor da fonte da linha posicionada
	//_oBrwF11:SetBlkColor(Str(CLR_LIGHTGRAY))
	//_oBrwF11:SetBlkColor(Str(CLR_WHITE)    )

	//Indica a imagem que será apresentada ao lado do título da coluna.
		//nColumn	Numérico	Indica coluna que será apresentada a imagem.
		//cResource	Caracter	Indica a imagem que será apresentada ao lado da coluna.	
	//_oBrwF11:SetHeaderImage( < nColumn>, < cResource> )

	// Adiciona legenda no Browse
	_oBrwF11:AddLegend('E1_SALDO == E1_VALOR .AND.  Empty(E1_BAIXA)              .AND. !AllTrim(E1_TIPO) $ "RA/NCC"' ,"BR_VERDE"   ,"Título em Aberto")
	_oBrwF11:AddLegend('E1_SALDO == E1_VALOR .AND.  Empty(E1_BAIXA)              .AND.  AllTrim(E1_TIPO) $ "RA/NCC"' ,"BR_BRANCO"  ,"Título do tipo NCC ou RA, em aberto")
	_oBrwF11:AddLegend('E1_SALDO  > 0        .AND.  E1_SALDO         < E1_VALOR'                                     ,"BR_AZUL"    ,"Título baixado parcialmente")
	_oBrwF11:AddLegend('E1_SALDO == 0        .AND. !AllTrim(E1_TIPO) $ "RA/NCC"'                                     ,"BR_VERMELHO","Titulo totalmente baixado")
	_oBrwF11:AddLegend('E1_SALDO == 0        .AND.  AllTrim(E1_TIPO) $ "RA/NCC"'                                     ,"BR_PRETO"   ,"Título a receber com baixa total por compensação com um NCC ou o próprio título do tipo NCC que encontra-se totalmente baixado (resolvido)")
//	_oBrwF11:AddLegend('E1_SALDO == 0                                                                                ,"BR_AMARELO" ,"Título pago com cheque")

	// Adiciona as colunas do Browse
	_aColumn := {}
	for nX   := 1 to len(_aStru)
		AADD(_aColumn,FWBrwColumn():New())
		&('_aColumn['+cValToChar(len(_aColumn))+']:SetData({|| '+_cAlias+'->'+_aStru[nX][1]+' })')
		
		If _aStru[nX][1]$"E1_TIPO/E1_CARTEIR/E1_PREFIXO/E1_VENDRES/E1_FILIAL/E1_PARCELA/E1_LOJA"
			_aColumn[len(_aColumn)]:SetSize(_aStru[nX][3]+20)
		Elseif _aStru[nX][1]$"E1_PEDIDO/E1_CLIENTE"
			_aColumn[len(_aColumn)]:SetSize(_aStru[nX][3]+60)	
		Elseif _aStru[nX][1]$"E1_VALOR/E1_SALDO"
			_aColumn[len(_aColumn)]:SetSize(_aStru[nX][3]+110)	
		Elseif _aStru[nX][1]$"F2_CONDESC"
			_aColumn[len(_aColumn)]:SetSize(_aStru[nX][3]+150)	
				Elseif _aStru[nX][1]$"E1_OBSTIT/F2_CONDESC"
			_aColumn[len(_aColumn)]:SetSize(_aStru[nX][3]+200)						
		Else
			_aColumn[len(_aColumn)]:SetSize(_aStru[nX][3]+90)
		EndIf	
		_aColumn[len(_aColumn)]:SetDecimal(_aStru[nX][4])
		_aColumn[len(_aColumn)]:lAutoSize := .F.
		
		if FieldPos(_aStru[nX][1])
			If "E1_BAIXA"$_aStru[nX][1]
				_aColumn[len(_aColumn)]:SetTitle("Dt Pagto")
			Else
				_aColumn[len(_aColumn)]:SetTitle(RetTitle(_aStru[nX][1]))
			EndIf
			
			_aColumn[len(_aColumn)]:SetPicture(X3Picture(_aStru[nX][1]))
		else
			_aColumn[len(_aColumn)]:SetTitle("Not Found "+cValtoChar(nX))
		endif
	next nX
	_oBrwF11:SetColumns(_aColumn)

	//Campos do browse a serem apresentados no filtro da tela
	//if len(_aFields)
		//_oBrwF11:SetFieldFilter(_aFields)
		//_oBrwF11:SetFilterRelation( < aFilterRelation>, < bChgFields> ) 
	//endif

	//_oBrwF11:Refresh()

	// Ativação do Browse
	_oBrwF11:Activate()

	// Ativação da janela - centralizada
	//_oDlgF11:Activate(,,,.T.,{|| .T.},,{|| nil},,)
	//_oDlgF11:Activate(,,,.T.)
	_oDlgF11:Activate(,,,.T.,,,)

	DBCommitAll()
	DBUnlockAll()
	if Select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	endif
	if Select(_cAliQry) > 0
		(_cAliQry)->(dbCloseArea())
	endif
	if Select(_cTabIns) > 0
		(_cTabIns)->(dbCloseArea())
	endif
	//DBCloseAll()
	if valtype(_oBrwF11) == "O"
		FreeObj(_oBrwF11)
	endif
	if valtype(_oDlgF11) == "O"
		FreeObj(_oDlgF11)
	endif
	if valtype(_oTmpTab) == "O"
		_oTmpTab:Delete()
	endif
//	oDlg      := _oDlBkp11
//	oBrowse   := _oBwBkp11
	cCadastro := _cCadBkp
	Titulo    := _cTitBkp
	aRotina   := _aRotBkp
	INCLUI    := _lIncBkp
	ALTERA    := _lAltBkp
	RestArea(_aSvSE5)
	RestArea(_aSvSE1)
	RestArea(_aSvSA1)
	RestArea(_aSvSC5)
	RestArea(_aSvSC6)
	RestArea(_aSvSC7)
	RestArea(_aSvSUA)
	RestArea(_aSvSUB)
	RestArea(_aSvACF)
	RestArea(_aSvSD1)
	RestArea(_aSvSD2)
	RestArea(_aSvSF1)
	RestArea(_aSvSF2)
	RestArea(_aArea)
return
/*/{Protheus.doc} FNE11M (FNE11MVC)
@description Montagem dos menus da rotina de nova ficha financeira.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/10/2019
@version 2.0
@type function
@see https://allss.com.br
/*/
user function FNE11M()
	local _aRet as Array
	_aRet := {	{"&Abrir Documento"  ,"U_FNE11A()",0,2,0,nil},;
				{"Posição do &Título","U_FNE11C()",0,2,0,nil},;
				{"&Parâmetros"       ,"U_FNE11P()",0,1,0,nil} }
/*
	local aRotina as Array
//	ADD OPTION aRotina TITLE "Pesquisar"          ACTION 'AxPesqui'         OPERATION 1 ACCESS 0 //"Pesquisar"
//	ADD OPTION aRotina TITLE "Visualizar"         ACTION 'VIEWDEF.FNE11MVC' OPERATION 2 ACCESS 0 //"Visualizar"
//	ADD OPTION aRotina TITLE "Incluir"            ACTION 'VIEWDEF.FNE11MVC' OPERATION 3 ACCESS 0 //"Incluir"
//	ADD OPTION aRotina TITLE "Alterar"            ACTION 'VIEWDEF.FNE11MVC' OPERATION 4 ACCESS 0 //"Alterar"
//	ADD OPTION aRotina TITLE "Excluir"            ACTION 'VIEWDEF.FNE11MVC' OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE "&Abrir Título"      ACTION 'U_FNE11A()'       OPERATION 6 ACCESS 0 //"Abrir Título"
	ADD OPTION aRotina TITLE "Posição do &Título" ACTION 'U_FNE11C()'       OPERATION 6 ACCESS 0 //"Consulta Posição do Título"
	ADD OPTION aRotina TITLE "&Parâmetros"        ACTION 'U_FNE11P()'       OPERATION 6 ACCESS 0 //"Parâmetros"
return aRotina
*/
return _aRet
/*/{Protheus.doc} FNE11A (FNE11MVC)
@description Sub-função da rotina de nova ficha financeira, para a abertura do documento selecionado.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/10/2019
@version 2.0
@type function
@see https://allss.com.br
/*/
user function FNE11A()		//Função de abertura do título a receber
	local   _nRecSE1  := (_cAlias)->RECSE1
	local   _aSvAr    := GetArea()
	local   _aSvA1    := SA1->(GetArea())
	local   _aSvC5    := SC5->(GetArea())
	local   _aSvE1    := SE1->(GetArea())
	local   _aSvF1    := SF1->(GetArea())
	local   _aSvF2    := SF2->(GetArea())
	local   _aSvRot   := IIF(type("aRotina")<>"U",aRotina,{})
	local   _cFlBkp   := cFilAnt
	SE1->(dbGoTo(_nRecSE1))
	MsgRun("Abrindo o documento posicionado...",_cRotina,{ || AbreDoc() })
	//AbreDoc()
	cFilAnt := _cFlBkp
	aRotina := _aSvRot
	RestArea(_aSvE1)
	RestArea(_aSvA1)
	RestArea(_aSvC5)
	RestArea(_aSvF1)
	RestArea(_aSvF2)
	RestArea(_aSvAr)
return
/*/{Protheus.doc} FNE11C (FNE11MVC)
@description Sub-função da rotina de nova ficha financeira, para a abertura da posição do título a receber posicionado.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/10/2019
@version 2.0
@type function
@see https://allss.com.br
/*/
user function FNE11C()		//Função de consulta da Posição do Título a Receber
	local   _nRecSE1  := (_cAlias)->RECSE1
	local   _aSvAr    := GetArea()
	local   _aSvA1    := SA1->(GetArea())
	local   _aSvC5    := SC5->(GetArea())
	local   _aSvE1    := SE1->(GetArea())
	local   _aSvF1    := SF1->(GetArea())
	local   _aSvF2    := SF2->(GetArea())
	local   _aSvA2    := SA2->(GetArea())
	local   _aSvRot   := IIF(type("aRotina")<>"U",aRotina,{})
	local   _cFlBkp   := cFilAnt
	SE1->(dbGoTo(_nRecSE1))
	cFilAnt := IIF(empty(SE1->E1_FILIAL),cFilAnt,SE1->E1_FILIAL)
	FC040Con()
	cFilAnt := _cFlBkp
	aRotina := _aSvRot
	RestArea(_aSvA2)
	RestArea(_aSvE1)
	RestArea(_aSvA1)
	RestArea(_aSvC5)
	RestArea(_aSvF1)
	RestArea(_aSvF2)
	RestArea(_aSvAr)
return
/*/{Protheus.doc} FNE11P (FNE11MVC)
@description Sub-função da rotina de nova ficha financeira, para a apresentação dos parâmetros da rotina.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/10/2019
@version 2.0
@type function
@see https://allss.com.br
/*/
user function FNE11P()		//Função de apresentação dos parâmetros das rotinas correlatas
	Pergunte(_cPerg,.T.)
return
/*/{Protheus.doc} antiga (RFINE011)
@description Ficha Financeira antiga.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 10/09/2013
@version 1.0
@param _cOrigem, caracter, Origem da chamada da rotina (para identificar se foi chamada pela tecla F11.)
@type function
@see https://allss.com.br
/*/
static function FFAntiga(_cOrigem)
	Local   nX
//	Local   nPos
	Local   _aArea      := GetArea()
	Local   _aSvSE1     := SE1->(GetArea())
	Local   _aSvSA1     := SA1->(GetArea())
	Local   _aSvSC5     := SC5->(GetArea())
	Local   _aSvSF1     := SF1->(GetArea())
	Local   _aSvSF2     := SF2->(GetArea())
	Local   _aStruSE1   := SE1->(dbStruct())
	Local   _aDados     := {} 
	Local   _aSizeTl    := MsAdvSize()
	Local   _oBwBkp11   := IIF(Type("oBrowse")<>"U", oBrowse, NIL)
	Local   _cRotina    := "RFINE011"
	Local   _cAlias     := GetNextAlias()
	Local   _cCli       := ""
	Local   _cLoja      := ""
	Local   _cCGCent    := ""
	Local   cNomcli     := ""
//	Local   _cLegen     := ""
//	Local   _cNFOrig    := ""
	Local   _cQuery     := ""
//	local   oFont1      := TFont():New("CALIBRI",,026,,.T.,,,,,.F.,.F.) 
	local   oFont2      := TFont():New("CALIBRI",,023,,.T.,,,,,.F.,.F.)  
	local   oFont3      := TFont():New("CALIBRI",,019,,.F.,,,,,.F.,.F.)  

//	Private aHeader     := {}
	Private _oSayFF
	Private _oDlgFF
	Private _oLbxFF
	Private _o00        := LoadBitmap( GetResources(), "BR_MARROM"  )
	Private _o01        := LoadBitmap( GetResources(), "BR_VERDE"   )
	Private _o02        := LoadBitmap( GetResources(), "BR_BRANCO"  )
	Private _o03        := LoadBitmap( GetResources(), "BR_AZUL"    )
	Private _o04        := LoadBitmap( GetResources(), "BR_VERMELHO")
	Private _o05        := LoadBitmap( GetResources(), "BR_PRETO"   )
	Private _o06        := LoadBitmap( GetResources(), "BR_AMARELO" )
	Private _cPerg      := "FIC010"
	Private INCLUI      := IIF(Type("INCLUI")=="L",INCLUI,.F.)
	Private ALTERA      := IIF(Type("ALTERA")=="L",ALTERA,.T.)

	default _cOrigem    := ""

//	memowrite("c:\temp\rfine011_size.txt",varinfo("> > > _aSizeTl > > > ",_aSizeTl))

	// - Inserido em 14/05/2018 por Arthur Silva para previnir erro na rotina
		if Select(_cAlias) > 0
			(_cAlias)->(dbCloseArea())
		endif
	// - Fim
	//SetKey(VK_F11, { || })
	dbSelectArea("SE1")
	dbSelectArea("SA1")
	ValidPerg()
	// Implementado por Júlio Soares em 28/10/2013 para não ter que alterar todos os processos da rotina
	// validando o usuário que não precisa que a tela dos parâmetros seja apresentada.
	If AllTrim(_cOrigem) == "F11" .OR. __cUserId $ SuperGetMV("MV_FICHFIN",,"000000")
		// Alterado em 22/10/2013 por Júlio Soares para _cPerg (False) a pedido do Sr. Mario que solicitou a NÃO apresentação
		// dos parâmetros na entrada da tela.
		Pergunte(_cPerg,.F.)
	Else
		If !Pergunte(_cPerg,.T.)
			RestArea(_aSvSE1)
			RestArea(_aSvSA1)
			RestArea(_aSvSC5)
			RestArea(_aSvSF1)
			RestArea(_aSvSF2)
			RestArea(_aArea)
			return
		EndIf
	EndIf
	If Type("cFilAux")=="U"
		Public cFilAux := xFilial()
	EndIf
	// Identifica por onde a rotina está sendo chamada para determinar os parâmetros do cliente posicionado
	if (Alias() == "SC9" .OR. UPPER(Alltrim(FunName()))=="MATA450")   // SC9 ou Tela de análise de crédito do pedido
		_cCli    := SC9->C9_CLIENTE
		_cLoja   := SC9->C9_LOJA
	elseif (Alias() == "SC5" .OR. UPPER(Alltrim(FunName()))=="RFATA026") // Tela de companhamento de pedido
		_cCli    := SC5->C5_CLIENTE
		_cLoja   := SC5->C5_LOJACLI
	elseif Alias() == "ACF" // Tela de companhamento de pedido
		_cCli    := ACF->ACF_CLIENT
		_cLoja   := ACF->ACF_LOJA
	elseif Alias() == "SUA" // Tela de atendimento
		_cCli    := SUA->UA_CLIENTE
		_cLoja   := SUA->UA_LOJA
	elseif Alias() == "SF2" // Documento de Saída
		_cCli    := SF2->F2_CLIENTE
		_cLoja   := SF2->F2_LOJA
	elseif Alias() == "SE1" // Títulos a Receber
		_cCli    := SE1->E1_CLIENTE
		_cLoja   := SE1->E1_LOJA
	else
		_cCli    := SA1->A1_COD
		_cLoja   := SA1->A1_LOJA
	endif
	
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	if SA1->(dbSeek(xFilial("SA1") + _cCli + _cLoja))
		cNomcli  := SA1->A1_NOME
		_cCGCent := SA1->A1_CGCCENT
	endif
	// Executa a pesquisa no banco de dados
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	if MV_PAR05 == 2
		_cQuery += " AND SE1.E1_TIPO <> 'PR' "
	endif
	_cQuery += " AND SE1.E1_PREFIXO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
	If MV_PAR17 == 1
		_cQuery += " AND SE1.E1_CLIENTE   = '"+_cCli   +"' "
		_cQuery += " AND SE1.E1_LOJA      = '"+_cLoja  +"' "
	Else
		_cQuery += " AND SE1.E1_CGCCENT   = '"+_cCGCent+"' "
	EndIf
	_cQuery += " AND SE1.E1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
	_cQuery += " AND SE1.E1_VENCREA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	If MV_PAR11 == 2
		_cQuery += " AND SE1.E1_NUMLIQ    = '' "
		_cQuery += " AND SE1.E1_TIPOLIQ   = '' "
	EndIf
	_cQuery := "%"+_cQuery+"%"
	BeginSql Alias _cAlias
		SELECT E1_FILIAL, E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CARTEIR,E1_EMISSAO,E1_PEDIDO,E1_VALOR,
				E1_SALDO,E1_VENDRES,E1_VENCTO,E1_BAIXA,E1_NUMBCO,E1_OBSTIT,E1_CLIENTE,E1_LOJA,
				E1_NOMCLI,E1_CGCCENT,ISNULL(F2_CONDESC,'')[E1_CONDESC],SE1.R_E_C_N_O_ RECSE1
		FROM %table:SE1% SE1 (NOLOCK)
			LEFT JOIN %table:SF2% SF2 (NOLOCK) ON SF2.F2_FILIAL = (CASE WHEN %xFilial:SE1% = %Exp:Space(Len(SE1->E1_FILIAL))% OR %xFilial:SEF2% = %Exp:Space(Len(SF2->F2_FILIAL))% THEN %xFilial:SF2% ELSE SE1.E1_FILIAL END)				//%xFilial:SF2%
									AND SF2.F2_DUPL    = SE1.E1_NUM
									AND SF2.F2_PREFIXO = SE1.E1_PREFIXO
									AND SF2.F2_CLIENTE = SE1.E1_CLIENTE
									AND SF2.F2_LOJA    = SE1.E1_LOJA
									AND SF2.%NotDel%
	//	WHERE SE1.E1_FILIAL    = %xFilial:SE1%
	//	  AND SE1.%NotDel%
		WHERE SE1.%NotDel%
		  %Exp:_cQuery%
		ORDER BY E1_VENCTO DESC, E1_EMISSAO DESC, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA
	EndSql
	For nX := 1 To Len(_aStruSE1)
		If _aStruSE1[nX][2] <> "C" .And. FieldPos(_aStruSE1[nX][1]) <> 0
			TcSetField(_cAlias,_aStruSE1[nX][1],_aStruSE1[nX][2],_aStruSE1[nX][3],_aStruSE1[nX][4])
		EndIf
	Next nX
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGoTop())
	If (_cAlias)->(EOF())
		(_cAlias)->(dbCloseArea())
		Aviso("ATENÇÃO!","Não existem títulos para este cliente.",{" <<< &Voltar"},2,"Não Há Títulos!")
	Else 
		_aSize := {	02                              , ;
					TamSx3("E1_PREFIXO")[01]+15     , ;
					TamSx3("E1_NUM"    )[01]+25     , ;
					TamSx3("E1_PARCELA")[01]+10     , ;
					40								, ;
					TamSx3("E1_TIPO"   )[01]+10     , ;
					TamSx3("E1_CARTEIR")[01]+10     , ;
					TamSx3("E1_EMISSAO")[01]+35     , ;
					TamSx3("E1_PEDIDO" )[01]+15     , ;
					TamSx3("E1_VALOR"  )[01]+25     , ;
					TamSx3("E1_SALDO"  )[01]+25     , ;
					TamSx3("E1_VENDRES")[01]+25     , ;
					TamSx3("E1_VENCTO" )[01]+35     , ;
					TamSx3("E1_BAIXA"  )[01]+35     , ;
					TamSx3("E1_NUMBCO" )[01]+35     , ;
					TamSx3("E1_OBSTIT" )[01]+25     , ;
					TamSx3("E1_CLIENTE")[01]+25     , ;
					TamSx3("E1_LOJA"   )[01]+25     , ;
					TamSx3("E1_NOMCLI" )[01]+25     , ;
					TamSx3("E1_CGCCENT")[01]+25     , ;
					TamSx3("E1_FILIAL" )[01]+10     , ;
					10                                }
		While !(_cAlias)->(EOF())
			_cLeg := "00"
			If (_cAlias)->E1_SALDO == (_cAlias)->E1_VALOR .AND. Empty((_cAlias)->E1_BAIXA) .AND. !AllTrim((_cAlias)->E1_TIPO) $ "RA/NCC"
				_cLeg := "01"		//VERDE    - Título em Aberto
			ElseIf (_cAlias)->E1_SALDO == (_cAlias)->E1_VALOR .AND. Empty((_cAlias)->E1_BAIXA) .AND. AllTrim((_cAlias)->E1_TIPO) $ "RA/NCC"
				_cLeg := "02"		//BRANCO   - Título do tipo NCC ou RA, em aberto
			ElseIf (_cAlias)->E1_SALDO > 0 .AND. (_cAlias)->E1_SALDO < (_cAlias)->E1_VALOR
				_cLeg := "03"		//AZUL     - Título baixado parcialmente
			ElseIf (_cAlias)->E1_SALDO == 0 .AND. !AllTrim((_cAlias)->E1_TIPO) $ "RA/NCC"
				_cLeg := "04"		//VERMELHO - Titulo totalmente baixado
			ElseIf (_cAlias)->E1_SALDO == 0 .AND. AllTrim((_cAlias)->E1_TIPO) $ "RA/NCC"
				_cLeg := "05"		//PRETO    - Título a receber com baixa total por compensação com um NCC ou o próprio título do tipo NCC que encontra-se totalmente baixado (resolvido).
			/*ElseIf (_cAlias)->E1_SALDO == 0
				_cLeg := "06"		//AMARELO   - Título pago com cheque.*/
			EndIf
			// Alterado em 16/07/2013 por Júlio Soares na inclusão da coluna que apresenta a informação se o Vendedor é ou não responsável pela venda.
			aAdd(_aDados,{	_cLeg                                              , ;
							(_cAlias)->E1_PREFIXO                            , ;
							(_cAlias)->E1_NUM                                , ;
							(_cAlias)->E1_PARCELA                            , ;
							(_cAlias)->E1_CONDESC                            , ;
							(_cAlias)->E1_TIPO                               , ;
							(_cAlias)->E1_CARTEIR                            , ;
							(_cAlias)->E1_EMISSAO                            , ;
							(_cAlias)->E1_PEDIDO                             , ;
							(_cAlias)->E1_VALOR                              , ;
							(_cAlias)->E1_SALDO                              , ;
							(_cAlias)->E1_VENDRES                            , ;
							(_cAlias)->E1_VENCTO                             , ;
							(_cAlias)->(IIF(E1_SALDO == 0,E1_BAIXA,STOD(""))), ;
							(_cAlias)->E1_NUMBCO                             , ;
							(_cAlias)->E1_OBSTIT                             , ;
							(_cAlias)->E1_CLIENTE                            , ;
							(_cAlias)->E1_LOJA                               , ;
							(_cAlias)->E1_NOMCLI                             , ;
							(_cAlias)->E1_CGCCENT                            , ;						
							(_cAlias)->E1_FILIAL                             , ;						
							(_cAlias)->RECSE1 } )
			(_cAlias)->(dbSkip())
		EndDo
		(_cAlias)->(dbCloseArea())
		// Trecho inserido para evitar a apresentação de erros
		If !Empty(MV_PAR01) .AND. Type("MV_PAR01") == 'D'
			_cData1 := DtoC(MV_PAR01)
		Else
			_cData1 := "01/01/2000"
		EndIf
		If !Empty (MV_PAR02) .AND. Type("MV_PAR02") == 'D'
			_cData2 := DtoC(MV_PAR02)
		Else
			_cData2 := "31/12/2049"
		EndIf
		DEFINE MSDIALOG _oDlgFF TITLE "["+_cRotina+"] - Ficha Financeira"    FROM _aSizeTl[1],_aSizeTl[1] TO _aSizeTl[6],_aSizeTl[5]                           COLORS 0, 16777215          PIXEL
		    @ _aSizeTl[1]+003, _aSizeTl[1]+003 GROUP       oGroup1  TO _aSizeTl[6]*0.50, _aSizeTl[5]*0.50 PROMPT ""                                 OF _oDlgFF COLOR  0, 16777215          PIXEL
		    @ _aSizeTl[1]+011, _aSizeTl[1]+010 SAY         oSay1                PROMPT "Cliente:"                      FONT oFont3    SIZE 050, 010 OF _oDlgFF COLORS 0, 16777215          PIXEL
		    @ _aSizeTl[1]+010, _aSizeTl[1]+040 SAY         oGet1                PROMPT _cCli+"/"+_cLoja+" - "+cNomcli  FONT oFont2    SIZE 300, 010 OF _oDlgFF COLORS 0, 16777215          PIXEL
		    @ _aSizeTl[1]+011, _aSizeTl[1]+370 SAY         oSay2                PROMPT "Período:"                      FONT oFont3    SIZE 050, 010 OF _oDlgFF COLORS 0, 16777215          PIXEL
		    @ _aSizeTl[1]+010, _aSizeTl[1]+400 SAY         oGet2                PROMPT _cData1 + "   a    " + _cData2  FONT oFont2    SIZE 200, 010 OF _oDlgFF COLORS 0, 16777215          PIXEL

			// Alteração - Fernando Bombardi - ALLSS - 02/03/2022

			@ _aSizeTl[1]+025, _aSizeTl[1]+010 ListBox _oLbxFF Fields Header("  "         ),;
								OemToAnsi("Prfx"       ),;
								OemToAnsi("Titulo"     ),;
								OemToAnsi("Parc"       ),;
								OemToAnsi("Cond Pagto" ),;
								OemToAnsi("Tipo"       ),;
								OemToAnsi("Cart"       ),;
								OemToAnsi("Emiss"      ),;
								OemToAnsi("Pedido"     ),;
								OemToAnsi("Valor Orig."),;	
								OemToAnsi("Saldo"      ),;
								OemToAnsi("Rep. Resp."),;
								OemToAnsi("Vencimento" ),;
								OemToAnsi("Dt Pagto"   ),;
								OemToAnsi("Nosso Num"  ),;
								OemToAnsi("Observações"),;
								OemToAnsi("Cliente"    ),;
								OemToAnsi("Loja"       ),;
								OemToAnsi("Nome"       ),;
								OemToAnsi("CNPJ Centr."),;
								OemToAnsi("Filial"     )  FONT oFont3  Size _aSizeTl[6]*0.75, _aSizeTl[5]*0.25 Pixel
			/*
			@ _aSizeTl[1]+025, _aSizeTl[1]+010 ListBox _oLbxFF Fields Header("  "         ),;
								OemToAnsi("Prfx"       ),;
								OemToAnsi("Titulo"     ),;
								OemToAnsi("Parc"       ),;
								OemToAnsi("Cond Pagto" ),;
								OemToAnsi("Tipo"       ),;
								OemToAnsi("Cart"       ),;
								OemToAnsi("Emiss"      ),;
								OemToAnsi("Pedido"     ),;
								OemToAnsi("Valor Orig."),;	
								OemToAnsi("Saldo"      ),;
								OemToAnsi("Vend. Resp."),;
								OemToAnsi("Vencimento" ),;
								OemToAnsi("Dt Pagto"   ),;
								OemToAnsi("Nosso Num"  ),;
								OemToAnsi("Observações"),;
								OemToAnsi("Cliente"    ),;
								OemToAnsi("Loja"       ),;
								OemToAnsi("Nome"       ),;
								OemToAnsi("CNPJ Centr."),;
								OemToAnsi("Filial"     )  FONT oFont3  Size _aSizeTl[6]*0.75, _aSizeTl[5]*0.25 Pixel
			*/

			// Fim - Fernando Bombardi - ALLSS - 02/03/2022


//								OemToAnsi("Filial"     )  FONT oFont3  /*FIELDSIZES 40, 80*/ Size _aSizeTl[6]*1.11, _aSizeTl[5]*0.20 Pixel  
	  		_oLbxFF:SetArray(_aDados)
			// Alterado em 16/07/2013 por Júlio Soares na inclusão da coluna que apresenta a informação se o Vendedor é ou não responsável pela venda.							
			_oLbxFF:bLine := {|| { &("_o" + AllTrim(_aDados[_oLbxFF:nAT,01]))												, ; // 
												(_aDados[_oLbxFF:nAT,02]) 												, ; // 
												(_aDados[_oLbxFF:nAT,03]) 												, ; // 
												(_aDados[_oLbxFF:nAT,04]) 												, ; // 
												(_aDados[_oLbxFF:nAT,05]) 												, ; // 
												(_aDados[_oLbxFF:nAT,06]) 												, ; // 
												(_aDados[_oLbxFF:nAT,07]) 												, ; // 
											DTOC(_aDados[_oLbxFF:nAt,08]) 												, ; // 
												(_aDados[_oLbxFF:nAT,09]) 												, ; // 
								  Padl(Transform(_aDados[_oLbxFF:nAT,10]  ,"@E 999,999,999.99"),TamSx3("E1_VALOR")[01]) , ; // 
								  Padl(Transform(_aDados[_oLbxFF:nAT,11]  ,"@E 999,999,999.99"),TamSx3("E1_SALDO")[01]) , ; // 
								  				(_aDados[_oLbxFF:nAT,12]) 												, ; // 
											DTOC(_aDados[_oLbxFF:nAT,13]) 												, ; // 
											DTOC(_aDados[_oLbxFF:nAT,14]) 												, ; // 
												(_aDados[_oLbxFF:nAT,15]) 												, ; // 
												(_aDados[_oLbxFF:nAT,16]) 												, ; // 
												(_aDados[_oLbxFF:nAT,17]) 												, ; // 
												(_aDados[_oLbxFF:nAT,18]) 												, ; // 
												(_aDados[_oLbxFF:nAT,19]) 												, ; // 
												(_aDados[_oLbxFF:nAT,20]) 												, ; // 
												(_aDados[_oLbxFF:nAT,21]) 												, ; // 
												(_aDados[_oLbxFF:nAT,22]) } } 
			//Fa040Legenda("SE1")
			Define SButton From _aSizeTl[1]+010, (_aSizeTl[5]*0.5)-120 Type 14 Enable Of _oDlgFF Action {|_cFlBkp| SE1->(dbGoTo(_aDados[_oLbxFF:nAT,22])), _cFlBkp := cFilAnt, cFilAnt := cFilAnt                                           , AbreDoc() , cFilAnt := _cFlBkp}
			Define SButton From _aSizeTl[1]+010, (_aSizeTl[5]*0.5)-090 Type 15 Enable Of _oDlgFF Action {|_cFlBkp| SE1->(dbGoTo(_aDados[_oLbxFF:nAT,22])), _cFlBkp := cFilAnt, cFilAnt := IIF(Empty(SE1->E1_FILIAL),cFilAnt,SE1->E1_FILIAL) , FC040Con(), cFilAnt := _cFlBkp}
			Define SButton From _aSizeTl[1]+010, (_aSizeTl[5]*0.5)-060 Type 20 Enable Of _oDlgFF Action ( _oDlgFF:End())
			Define SButton From _aSizeTl[1]+010, (_aSizeTl[5]*0.5)-030 Type 17 Enable Of _oDlgFF Action ( Pergunte(_cPerg,.T.))	
			//Trecho utilizado para reduzir o tamanho das colunas da Ficha Financeira de acordo com o tamanho do conteúdo.
			/*
			_oLbxFF:ACOLSIZES := ARRAY(LEN(_oLbxFF:AARRAY[01]))
			for _nTm := 1 to len(_oLbxFF:ACOLSIZES)
				_oLbxFF:ACOLSIZES[_nTm] := 1
			next 
			*/
			_oLbxFF:ACOLSIZES := aClone(_aSize)
		ACTIVATE MSDIALOG _oDlgFF CENTERED
		/*
//		Define MsDialog _oDlgFF Title "Ficha Financeira - (Período de " + DtoC(mv_par01) + " a " + DtoC(mv_par02) + ")" From  0, 0 To 500,1200 Colors 0, 16777215 Pixel STYLE DS_MODALFRAME// Inibe o botao "X" da tela
//		Define MsDialog _oDlgFF Title "RFINE011 - Ficha Financeira" From  0, 0 To 892,1650 FONT oFont1 Colors 16777215 Pixel  //STYLE DS_MODALFRAME     // Inibe o botao "X" da tela
		Define MsDialog _oDlgFF Title "["+_cRotina+"] - Ficha Financeira" From  _aSizeTl[1],_aSizeTl[1] To _aSizeTl[6],_aSizeTl[5] FONT oFont1 Colors 16777215 Pixel  //STYLE DS_MODALFRAME     // Inibe o botao "X" da tela
			_oDlgFF:lEscClose := .T.//Não permite fechar a tela com o "Esc"
		// Alterado em 16/07/2013 por Júlio Soares na inclusão da coluna que apresenta a informação se o Vendedor é ou não responsável pela venda.
		// Alterado em por Júlio Soares para inclusão do numero do pedido do documento na f
			@ 07, 010 SAY _oSayFF PROMPT  "Código/Loja .:"					         FONT oFont2	 SIZE 080, 050 OF _oDlgFF COLORS 4194304, 16777215 PIXEL 
			@ 07, 090 SAY _oSayFF PROMPT Alltrim(_cCli+" / "+_cLoja+"  -  "+cNomcli) FONT oFont3	 SIZE 300, 050 OF _oDlgFF COLORS 4194304, 16777215 PIXEL 
			@ 07, 398 SAY _oSayFF PROMPT "Período .:"  						         FONT oFont2	 SIZE 080, 050 OF _oDlgFF COLORS 4194304, 16777215 PIXEL 
			@ 07, 448 SAY _oSayFF PROMPT  _cData1 + "   a    " + _cData2         	 FONT oFont3	 SIZE 200, 050 OF _oDlgFF COLORS 4194304, 16777215 PIXEL 
			@ 28, 010 ListBox _oLbxFF Fields Header("  "         ),;
								OemToAnsi("Prfx"       ),;
								OemToAnsi("Titulo"     ),;
								OemToAnsi("Parc"       ),;
								OemToAnsi("Cond Pagto" ),;
								OemToAnsi("Tipo"       ),;
								OemToAnsi("Cart"       ),;
								OemToAnsi("Emiss"      ),;
								OemToAnsi("Pedido"     ),;
								OemToAnsi("Valor Orig."),;	
								OemToAnsi("Saldo"      ),;
								OemToAnsi("Vend. Resp."),;
								OemToAnsi("Vencimento" ),;
								OemToAnsi("Dt Pagto"   ),;
								OemToAnsi("Nosso Num"  ),;
								OemToAnsi("Observações"),;
								OemToAnsi("Cliente"    ),;
								OemToAnsi("Loja"       ),;
								OemToAnsi("Nome"       ),;
								OemToAnsi("CNPJ Centr."),;
								OemToAnsi("Filial"     )  FONT oFont3  FIELDSIZES 40,80 Size 812,364 Pixel  
	  		_oLbxFF:SetArray(_aDados)
			// Alterado em 16/07/2013 por Júlio Soares na inclusão da coluna que apresenta a informação se o Vendedor é ou não responsável pela venda.							
			_oLbxFF:bLine := {|| { &("_o" + AllTrim(_aDados[_oLbxFF:nAT,01]))												, ; // 
												(_aDados[_oLbxFF:nAT,02]) 												, ; // 
												(_aDados[_oLbxFF:nAT,03]) 												, ; // 
												(_aDados[_oLbxFF:nAT,04]) 												, ; // 
												(_aDados[_oLbxFF:nAT,05]) 												, ; // 
												(_aDados[_oLbxFF:nAT,06]) 												, ; // 
												(_aDados[_oLbxFF:nAT,07]) 												, ; // 
											DTOC(_aDados[_oLbxFF:nAt,08]) 												, ; // 
												(_aDados[_oLbxFF:nAT,09]) 												, ; // 
								  Padl(Transform(_aDados[_oLbxFF:nAT,10]  ,"@E 999,999,999.99"),TamSx3("E1_VALOR")[01]) , ; // 
								  Padl(Transform(_aDados[_oLbxFF:nAT,11]  ,"@E 999,999,999.99"),TamSx3("E1_SALDO")[01]) , ; // 
								  				(_aDados[_oLbxFF:nAT,12]) 												, ; // 
											DTOC(_aDados[_oLbxFF:nAT,13]) 												, ; // 
											DTOC(_aDados[_oLbxFF:nAT,14]) 												, ; // 
												(_aDados[_oLbxFF:nAT,15]) 												, ; // 
												(_aDados[_oLbxFF:nAT,16]) 												, ; // 
												(_aDados[_oLbxFF:nAT,17]) 												, ; // 
												(_aDados[_oLbxFF:nAT,18]) 												, ; // 
												(_aDados[_oLbxFF:nAT,19]) 												, ; // 
												(_aDados[_oLbxFF:nAT,20]) 												, ; // 
												(_aDados[_oLbxFF:nAT,21]) 												, ; // 
												(_aDados[_oLbxFF:nAT,22]) } } 
	
		//Fa040Legenda("SE1")
		Define SButton From 420,490 Type 14 Enable Of _oDlgFF Action {|_cFlBkp| SE1->(dbGoTo(_aDados[_oLbxFF:nAT,22])), _cFlBkp := cFilAnt, cFilAnt := cFilAnt                                           , AbreDoc() , cFilAnt := _cFlBkp}
		Define SButton From 420,530 Type 15 Enable Of _oDlgFF Action {|_cFlBkp| SE1->(dbGoTo(_aDados[_oLbxFF:nAT,22])), _cFlBkp := cFilAnt, cFilAnt := IIF(Empty(SE1->E1_FILIAL),cFilAnt,SE1->E1_FILIAL) , FC040Con(), cFilAnt := _cFlBkp}
		Define SButton From 420,570 Type 20 Enable Of _oDlgFF Action ( _oDlgFF:End())
		Define SButton From 420,610 Type 17 Enable Of _oDlgFF Action ( Pergunte(_cPerg,.T.))	
		//Trecho utilizado para reduzir o tamanho das colunas da Ficha Financeira de acordo com o tamanho do conteúdo.
		//_oLbxFF:ACOLSIZES := ARRAY(LEN(_oLbxFF:AARRAY[01]))
		//for _nTm := 1 to len(_oLbxFF:ACOLSIZES)
		//	_oLbxFF:ACOLSIZES[_nTm] := 1
		//next 
		_oLbxFF:ACOLSIZES := aClone(_aSize)
		Activate MsDialog _oDlgFF Centered
		*/
	EndIf
	if Select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	endif

	oBrowse := _oBwBkp11

	RestArea(_aSvSE1)
	RestArea(_aSvSA1)
	RestArea(_aSvSC5)
	RestArea(_aSvSF1)
	RestArea(_aSvSF2)
	RestArea(_aArea)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AbreDoc   ºAutor  ³Anderson C. P. Coelho º Data ³  28/05/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Sub-Rotina utilizada para abrir o respectivo Docto. de Entr.º±±
±±º          ³ou saida, ou ainda o titulo a receber posicionado.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} AbreDoc
@description Programa para abertura do documento selecionado (NF de entrada, de saída ou título a receber, conforme o caso).
@author Júlio Soares
@since 28/05/2015
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AbreDoc()
	Local 	_aSvAr   	:= GetArea()
	Local   _aSvSE1     := SE1->(GetArea())
	Local   _aSvSA1     := SA1->(GetArea())
	Local   _aSvSC5     := SC5->(GetArea())
	Local   _aSvSF1     := SF1->(GetArea())
	Local   _aSvSF2     := SF2->(GetArea())
	Local _lAchou  := .F.
	Local _cFlAnBk := cFilAnt

	dbSelectArea("SE1")
	if !Empty(xFilial("SE1"))
		cFilAnt := SE1->E1_FILIAL
	endif
	If AllTrim(SE1->E1_TIPO) == "NCC"
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))
	//	If SF1->(MsSeek(xFilial("SF1")                                +;
		If SF1->(MsSeek(IIF(Empty(xFilial("SE1")),xFilial("SE1"),cFilAnt)+;
						Padr(SE1->E1_NUM    ,TamSx3("F1_DOC"    )[01])+;
						Padr(SE1->E1_PREFIXO,TamSx3("F1_SERIE"  )[01])+;
						Padr(SE1->E1_CLIENTE,TamSx3("F1_FORNECE")[01])+;
						Padr(SE1->E1_LOJA   ,TamSx3("F1_LOJA"   )[01])+;
						Padr("D"            ,TamSx3("F1_TIPO"   )[01]),.T.,.F.) )
			A103NFiscal("SF1",SF1->(Recno()),2)
			_lAchou := .T.
		EndIf
	ElseIf AllTrim(SE1->E1_TIPO) == "NF"
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
	//	If SF2->(MsSeek(xFilial("SF2")                                +;
		If SF2->(MsSeek(IIF(Empty(xFilial("SE1")),xFilial("SE1"),cFilAnt)+;
						Padr(SE1->E1_NUM    ,TamSx3("F2_DOC"    )[01])+;
						Padr(SE1->E1_PREFIXO,TamSx3("F2_SERIE"  )[01])+;
						Padr(SE1->E1_CLIENTE,TamSx3("F2_CLIENTE")[01])+;
						Padr(SE1->E1_LOJA   ,TamSx3("F2_LOJA"   )[01]),.T.,.F.))
			Mc090Visual("SF2",SF2->(Recno()),2)
			_lAchou := .T.
		EndIf
	EndIf
	If !_lAchou
		FA280Visua("SE1",SE1->(Recno()),2)
	EndIf
	cFilAnt := _cFlAnBk
	RestArea(_aSvSE1)
	RestArea(_aSvSA1)
	RestArea(_aSvSC5)
	RestArea(_aSvSF2)
	RestArea(_aSvSF1)
	RestArea(_aSvAr)
return
/*/{Protheus.doc} Fechar
@description Programa para fechar a janela aberta.
@author Júlio Soares
@since 20/03/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
/*
static function Fechar()
	_oDlgFF:End()
	// DESATIVADO ALTERAÇÃO EM 21/08/15 POR JÚLIO SOARES APÓS SOLICITAÇÃO DO SR. MARIO
	SetKey(VK_F11, { || FICHAFINAN() })
	// Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
	//SetKey( VK_F11,{|| MsgAlert( "Tecla [ F11 ] foi alterada para [ Ctrl + F11 ]" , "Protheus11" )})
	//SetKey( K_CTRL_F11, { || })
	//SetKey( K_CTRL_F11, { || FICHACINAN() })
return
*/
/*/{Protheus.doc} ValidPerg
@description Programa para informar os parâmetros da rotina a ser utilizada pela rotina principal.
@author Júlio Soares
@since 10/10/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()   

	Local i       := 0
	Local j       := 0
	Local _aAlias := GetArea()
	Local _aTam   := {}
	Local aRegs   := {}
	


	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	_cPerg        := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))   //FIC010
	_aTam         := TamSx3("E1_EMISSAO")
	AADD(aRegs,{_cPerg,"01","Da Emissao ?                  ","","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_emis_de" ,""       ,""      ,""       ,"","",""               ,""               ,""               ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"02","Ate a Emissao ?               ","","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_emis_ate",""       ,""      ,""       ,"","",""               ,""               ,""               ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := TamSx3("E1_VENCREA")
	AADD(aRegs,{_cPerg,"03","Do Vencimento ?               ","","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_ven_de"  ,""       ,""      ,""       ,"","",""               ,""               ,""               ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"04","Ate o Vencimento ?            ","","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_ven_ate" ,""       ,""      ,""       ,"","",""               ,""               ,""               ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"05","Considera Provisor. ?         ","","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par05"   ,"Sim"    ,"Si"    ,"Yes"    ,"","","Nao"            ,"No"             ,"No"             ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := TamSx3("E1_PREFIXO")
	AADD(aRegs,{_cPerg,"06","Do Prefixo ?                  ","","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par06"   ,""       ,""      ,""       ,"","",""               ,""               ,""               ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"07","Ate Prefixo ?                 ","","","mv_ch7",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par07"   ,""       ,""      ,""       ,"","",""               ,""               ,""               ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"08","Considera Faturados ?         ","","","MV_CH8",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par08"   ,"Sim"    ,"Si"    ,"Yes"    ,"","","Nao"            ,"No"             ,"No"             ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"09","Considera Liquidados ?        ","","","MV_CH9",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par09"   ,"Sim"    ,"Si"    ,"Yes"    ,"","","Nao"            ,"No"             ,"No"             ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"10","Pedidos com Itens Bloqueados ?","","","MV_CH0",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par10"   ,"Sim"    ,"Si"    ,"Yes"    ,"","","Nao"            ,"No"             ,"No"             ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"11","Tit. Gerados por Liquidacao ? ","","","MV_CHA",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par11"   ,"Sim"    ,"Si"    ,"Yes"    ,"","","Nao"            ,"No"             ,"No"             ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"12","Considera Saldo ?             ","","","MV_CHB",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par12"   ,"Normal" ,"Normal","Regular","","","Corrigido"      ,"Corregido"      ,"Adjusted"       ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"13","Considera Lojas ?             ","","","MV_CHC",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par13"   ,"Sim"    ,"Si"    ,"Yes"    ,"","","Nao"            ,"No"             ,"No"             ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"14","TES gera duplicata ?          ","","","MV_CHD",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par14"   ,"Todas"  ,"Todas" ,"All"    ,"","","Gera Duplicatas","Gen. fact. cred","Gener.trade not","","","Nao Gera Duplic","Nao gen fac crd","Don't gen.tr.nt","","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"15","Considera RA ?                ","","","MV_CHE",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par15"   ,"Sim"    ,"Si"    ,"Yes"    ,"","","Nao"            ,"No"             ,"No"             ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"16","Exibe dias a vencer ?         ","","","MV_CHF",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par16"   ,"Sim"    ,"Si"    ,"Yes"    ,"","","Nao"            ,"No"             ,"No"             ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	_aTam         := {01,00,"N"}
	AADD(aRegs,{_cPerg,"17","Aglutina por CNPJ Central?    ","","","MV_CHG",_aTam[3],_aTam[1],_aTam[2],1,"C","NAOVAZIO()","mv_par17"   ,"Nao"    ,"No"    ,"No"     ,"","","Sim"            ,"Si"             ,"Yes"            ,"","",""               ,""               ,""               ,"","","","","","","","","","","","","","",""})
	/* FB - RELASE 12.1.23
	For i := 1 To Len(aRegs)
		If !SX1->(dbSeek(_cPerg+aRegs[i,2]))
			while !RecLock("SX1",.T.) ; enddo
				For j := 1 To FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Else              
						Exit
					EndIf
				Next
			SX1->(MsUnLock())
		EndIf
	Next
	*/
	For i := 1 To Len(aRegs)
		If !(_cAliasSX1)->(dbSeek(_cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				For j := 1 To FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Else              
						Exit
					EndIf
				Next
			(_cAliasSX1)->(MsUnLock())
		EndIf
	Next	
	RestArea(_aAlias)
return
