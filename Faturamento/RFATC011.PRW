#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "VKEY.CH"

#define _clrf CHR(13) + CHR(10)

/*/{Protheus.doc} RFATC011
@description Rotina de consulta de Pedidos por Cliente.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 20/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFATC011()
	Local   _aSavArea := GetArea()
	Local   oButton1
//	Local   oButton2
	Local   oGroup1
	Local   oGet1
	Local   oGet2
	Local   oGet3
	Local   oSay1
	Local   oSay2
	Local   oSay3
	Private oGet4
	Private oSay4
	Private oSay5
	PRIVATE oSay11
	PRIVATE oSay12
	PRIVATE oSay15
	PRIVATE oSay16
	Private oGet5

	Private _nOrd     := 1		//Ordem dos registros na Grid2
	Private INCLUI    := .F.
	Private ALTERA    := .F.
	Private _lSeekApr := .F.
	Private aAux1     := {}
	Private aAux2     := {}
	Private aFields1  := {"C5_EMISSAO","C5_NUM", "C5_TPOPER"}
	// Alteração - Fernando Bombardi - 14/04/23 
	Private aFields2  := {	"D2_EMISSAO",;
							"D2_DOC"    ,;
							"D2_SERIE"  ,;
							"C6_ITEM"   ,;
							"C6_PRODUTO",;
							"D2_LOTECTL",;							
							"C6_DESCRI" ,;
							"C6_UM"     ,;
							"D2_QUANT"  ,;
							"D2_PRCVEN" ,;
							"D2_TOTAL"  ,;
							"C6_VALDESC",;
							"C6_DESCONT",;
							"C6_DESCTV1",;
							"C6_DESCTV2",;
							"C6_DESCTV3",;
							"C6_DESCTV4",;
							"C6_TES"    ,;
							"C6_QTDVEN" ,;
							"C6_PRCVEN" ,;
							"C6_VALOR"  ,;
							"C6_PRUNIT" }

	/*
	Private aFields2  := {	"D2_EMISSAO",;
							"D2_DOC"    ,;
							"D2_SERIE"  ,;
							"C6_ITEM"   ,;
							"C6_PRODUTO",;
							"C6_DESCRI" ,;
							"C6_UM"     ,;
							"C6_QTDVEN" ,;
							"C6_PRCVEN" ,;
							"C6_VALOR"  ,;
							"C6_VALDESC",;
							"C6_DESCONT",;
							"C6_DESCTV1",;
							"C6_DESCTV2",;
							"C6_DESCTV3",;
							"C6_DESCTV4",;
							"C6_TES"     }
	*/
	// Fim Alteração - Fernando Bombardi - 14/04/23
	Private cGet1     := IIF(FUNNAME()=="TMKA271".AND.!SUA->UA_PROSPEC,SUA->UA_CLIENTE,Space(TamSx3("A1_COD" )[01]))
	Private cGet2     := IIF(FUNNAME()=="TMKA271".AND.!SUA->UA_PROSPEC,SUA->UA_LOJA   ,Space(TamSx3("A1_LOJA")[01]))
	Private cGet3     := IIF(FUNNAME()=="TMKA271".AND.!SUA->UA_PROSPEC,SUA->UA_NOMECLI,Space(TamSx3("A1_NOME")[01]))
	Private cSay4     := SPACE(len(SB1->B1_COD))
	Private cGet4     := SPACE(len(SB1->B1_COD))
	Private cGet7     := SPACE(len(SB1->B1_DESC))
	Private cGet5     := SPACE(30)
	Private cGet11    := SPACE(len(SC5->C5_TPOPER))
	Private cGet12    := SPACE(750)
	Private cGet13    := SPACE(len(SB1->B1_COD))
	Private cGet14    := SPACE(len(SB1->B1_COD))

	Private cGet15    := SPACE(len(SB1->B1_COD))
	Private cGet16    := SPACE(len(SB1->B1_COD))
	Private cSay12    := SPACE(750)
	Private _aSize    := MsAdvSize()
	Private _cRotina  := "RFATC011"
	Private cCadastro := "Consulta de Pedidos de Vendas por Cliente"

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbGoTop())

	static oDlg
	DEFINE MSDIALOG oDlg TITLE "Consulta de Pedidos de Venda por Cliente/Produto"    FROM _aSize[1],_aSize[1] TO _aSize[6],_aSize[5]         COLORS 0, 16777215          PIXEL
	    @ _aSize[1]+003, _aSize[1]+003 GROUP       oGroup1  TO _aSize[6]*0.5/*272*/, _aSize[5]*0.5/*472*/ PROMPT " CONSULTA "                                      OF oDlg COLOR  0, 16777215          PIXEL
	    @ _aSize[1]+020, _aSize[1]+010 SAY         oSay1                PROMPT "Cliente:"                          SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
	    @ _aSize[1]+017, _aSize[1]+030 MSGET       oGet1                VAR    cGet1     VALID VAZIO().OR.AtuGe1() F3 "SA1"   SIZE 050, 010 OF oDlg COLORS 0, 16777215          PIXEL
	    @ _aSize[1]+020, _aSize[1]+085 SAY         oSay2                PROMPT "Loja:"                             SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
	    @ _aSize[1]+017, _aSize[1]+105 MSGET       oGet2                VAR    cGet2     VALID VAZIO().OR.AtuGe1() SIZE 030, 010 OF oDlg COLORS 0, 16777215          PIXEL
	    @ _aSize[1]+020, _aSize[1]+145 SAY         oSay3                PROMPT "Nome:"                             SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
        @ _aSize[1]+017, _aSize[1]+165 MSGET       oGet3                VAR    cGet3     WHEN .F.                  SIZE 150, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL

	    @ _aSize[1]+020, (_aSize[5]*0.5)-230  SAY  oSay12   PROMPT  cSay12  SIZE 030, 060 OF oDlg COLORS 8404992, 16777215          PIXEL		
        @ _aSize[1]+020, (_aSize[5]*0.5)-195  SAY  oGet12          VAR     cGet12  SIZE 030, 1000 OF oDlg COLORS 8404992, 16777215          PIXEL

	    @ _aSize[1]+020, (_aSize[5]*0.5)-290  SAY  oSay4    PROMPT  cSay4  SIZE 030, 060 OF oDlg COLORS 8404992, 16777215          PIXEL
        @ _aSize[1]+020, (_aSize[5]*0.5)-265  SAY  oGet4          VAR     cGet4  SIZE 030, 060 OF oDlg COLORS 8404992, 16777215          PIXEL
        @ _aSize[1]+020, (_aSize[5]*0.5)-245  SAY  oGet7          VAR     cGet7  SIZE 100, 1000 OF oDlg COLORS 8404992, 16777215          PIXEL

	    @ _aSize[1]+017, (_aSize[5]*0.5)-045  BUTTON oButton1      PROMPT "&Sair"    ACTION Close(oDlg)        SIZE 037, 012 OF oDlg                             PIXEL

	    @ (_aSize[6]*0.5)-015, _aSize[1]+010  SAY    oSay3 PROMPT "  F4 - Busca Produto e Lote  |  F7- Visualiza Pedido de Vendas  |  F8- Altera Cliente  |  F10- Busca por Tipo de Pedido  |  F11- Busca Por Produto  |  F12- Reordenar Itens  "     SIZE 330, 020 OF oDlg COLORS 8404992, 16777215          PIXEL
	    @ (_aSize[6]*0.5)-015, _aSize[1]+500  SAY    oSay5 PROMPT "   Total do Pedido.:"     SIZE 300, 020 OF oDlg COLORS 0, 16777215          PIXEL
	    @ (_aSize[6]*0.5)-015, _aSize[1]+560  SAY    oGet5 var  Transform(cGet5 , "@E 999,999,999,999.99")            SIZE 040, 010 OF oDlg COLORS 0, 16777215          PIXEL
  
	    fMSNewGe1()
	    fMSNewGe2()
		SetKey(VK_F4 ,{|| })
	    SetKey(VK_F4 ,{ || fLotePV() } )
		SetKey(VK_F7 ,{|| })
	    SetKey(VK_F7 ,{ || OpenPV() } )
		SetKey(VK_F8 ,{|| })
	    SetKey(VK_F8 ,{ || AltCli() } )
		SetKey(VK_F10,{|| })
	    SetKey(VK_F10,{ || PesqTPO()  } )	    
	    SetKey(VK_F11,{|| })
	    SetKey(VK_F11,{ || PesqPrd()  } )
		SetKey(VK_F12,{|| })
	    SetKey(VK_F12,{ || Reord()  } )    
	    
	    if !Empty(cGet1) .AND. !Empty(cGet2)
			AtuGe1()
		endif
	ACTIVATE MSDIALOG oDlg CENTERED
	SetKey(VK_F7 ,{|| })
	SetKey(VK_F8 ,{|| })
	SetKey(VK_F10,{|| })
	SetKey(VK_F11,{|| })
	SetKey(VK_F12,{|| })
	if ExistBlock("RTMKE028")
		//Seta atalho para tecla F4 para alterar informa??es espec?ficas no atendimento Call Center
		SetKey(VK_F8,{|| })
		SetKey(VK_F8,{|| U_RTMKE028()})
	endif
	if ExistBlock("RTMKE022")
		//Seta atalho para tecla F5 para chamar a tela de busca avan?ada
		SetKey(VK_F5,{|| })
		SetKey(VK_F5,{|| U_RTMKE022() })
	endif
	if ExistBlock("RTMKE025")
		//Seta atalho para tecla F6 para chamar a confer?ncia dos atendimentos
		SetKey(VK_F6,{|| })
		SetKey(VK_F6,{|| U_RTMKE025() })
	endif
	if ExistBlock("RFATC011")
		//Seta atalho para tecla F7 para chamar consulta dos pedidos por cliente
		SetKey(VK_F7,{|| })
		SetKey(VK_F7,{|| U_RFATC011() })
	endif
	if ExistBlock("RTMKE025")
		//Seta atalho para tecla F6 para chamar a confer?ncia dos atendimentos
		SetKey(VK_F6,{|| })
		SetKey(VK_F6,{|| U_RTMKE025() })
	endif
	RestArea(_aSavArea)
return
/*/{Protheus.doc} fMSNewGe1
@description Sub-rotina de Montagem da GetDados 1 da rotina RFATC011.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function fMSNewGe1()
	local   nX
	local   aColsEx      := {}
	local   aHeaderEx    := {}
	local   aFieldFill   := {}
	local   aAlterFields := {}
	local   _cAliasSX3   := "SX3_"+GetNextAlias()

	static oMSNewGe1

	//INICIO CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Altera??o do m?todo de pesquisa na SX3 para a fun??o OpenSXs, em decorr?ncia da migra??o de release (12.1.17 para 12.1.23) prevista para 06/2019 em produ??o.
		//OpenSxs(	<oParam1 >, ;		//Compatibilidade
		//			<oParam2 >, ;		//Compatibilidade
		//			<oParam3 >, ;		//Compatibilidade
		//			<oParam4 >, ;		//Compatibilidade
		//			<cEmpresa >, ;		//Empresa que se deseja abrir o dicion?rio, se n?o informado utilizada a empresa atual (cEmpAnt) 
		//			<cAliasSX >, ;		// Alias que ser? utilizado para abrir a tabela 
		//			<cTypeSX >, ;		// Tabela que ser? aberta 
		//			<oParam8 >, ;		//Compatibilidade
		//			<lFinal >, ;		// Indica se deve chamar a fun??o FINAL caso a tabela n?o exista (.T.)
		//			<oParam10 >, ;		//Compatibilidade
		//			<lShared >, ;		// Indica se a tabela deve ser aberta em modo compartilhado ou exclusivo (.T.)
		//			<lCreate >) 		// Indica se deve criar a tabela, caso ela n?o exista
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)		//OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.T.,,.F.,.F.)
		if Select(_cAliasSX3) > 0
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))
			for nX := 1 to len(aFields1)
				if (_cAliasSX3)->(MsSeek(aFields1[nX],.T.,.F.))
					Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
										(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
					if AllTrim((_cAliasSX3)->X3_CAMPO) == "C5_NUM"
						Aadd(aFieldFill, Space(06)             )
					else
						Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
					endif
				endif
			next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aAux1     := aClone(aColsEx)
			oMSNewGe1 := MsNewGetDados():New( _aSize[7]+040, _aSize[2]-022, (_aSize[6]*0.50)-020, ((_aSize[5]-010)*0.075)-(_aSize[2]-012), /*GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 9999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
			oMSNewGe1:bChange := {|| AtuGe2() }
		endif
		(_cAliasSX3)->(dbCloseArea())
	//FIM CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Altera??o do m?todo de pesquisa na SX3 para a fun??o OpenSXs, em decorr?ncia da migra??o de release (12.1.17 para 12.1.23) prevista para 06/2019 em produ??o.
return
/*/{Protheus.doc} fMSNewGe2
@description Sub-rotina de Montagem da GetDados 2 da rotina RFATC011.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function fMSNewGe2()
	local   nX
	local   aColsEx      := {}
	local   aHeaderEx    := {}
	local   aFieldFill   := {}
	local   aAlterFields := {}
	local   _cAliasSX3   := "SX3_"+GetNextAlias()

	static oMSNewGe2

	//INICIO CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Altera??o do m?todo de pesquisa na SX3 para a fun??o OpenSXs, em decorr?ncia da migra??o de release (12.1.17 para 12.1.23) prevista para 06/2019 em produ??o.
		//OpenSxs(	<oParam1 >, ;		//Compatibilidade
		//			<oParam2 >, ;		//Compatibilidade
		//			<oParam3 >, ;		//Compatibilidade
		//			<oParam4 >, ;		//Compatibilidade
		//			<cEmpresa >, ;		//Empresa que se deseja abrir o dicion?rio, se n?o informado utilizada a empresa atual (cEmpAnt) 
		//			<cAliasSX >, ;		// Alias que ser? utilizado para abrir a tabela 
		//			<cTypeSX >, ;		// Tabela que ser? aberta 
		//			<oParam8 >, ;		//Compatibilidade
		//			<lFinal >, ;		// Indica se deve chamar a fun??o FINAL caso a tabela n?o exista (.T.)
		//			<oParam10 >, ;		//Compatibilidade
		//			<lShared >, ;		// Indica se a tabela deve ser aberta em modo compartilhado ou exclusivo (.T.)
		//			<lCreate >) 		// Indica se deve criar a tabela, caso ela n?o exista
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)		//OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.T.,,.F.,.F.)
		if Select(_cAliasSX3) > 0
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))
			For nX := 1 To Len(aFields2)
				// Inclusão - Fernando Bombardi - 14/04/23
				if Alltrim(aFields2[nX]) $ Alltrim("C6_PRUNIT/C6_QTDVEN/C6_PRCVEN/C6_VALOR")
					Loop
				endif
				// Fim Inclusão - Fernando Bombardi - 14/04/23
				if (_cAliasSX3)->(MsSeek(aFields2[nX],.T.,.F.))
					Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
										(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
					Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
				endif
			next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aAux2     := aClone(aColsEx)
			oMSNewGe2 := MsNewGetDados():New( _aSize[7]+040, ((_aSize[5]-0010)*0.075)-(_aSize[2]-012)+002, (_aSize[6]*0.50)-020, (_aSize[5]*0.50)-002, /*GD_INSERT+GD_DELETE+GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+ZA_ITEM", aAlterFields,, 9999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
		endif
		(_cAliasSX3)->(dbCloseArea())
	//FIM CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Altera??o do m?todo de pesquisa na SX3 para a fun??o OpenSXs, em decorr?ncia da migra??o de release (12.1.17 para 12.1.23) prevista para 06/2019 em produ??o.
return
/*/{Protheus.doc} AtuGe1
@description Sub-rotina responsavel por atualizar o GetDados 1.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGe1()
	local   _lRet := !Empty(cGet1)
	if _lRet
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if empty(cGet2)
			//Set SoftSeek ON
			SA1->(MsSeek(xFilial("SA1") + cGet1,.F.,.F.))
			//Set SoftSeek OFF
			cGet2     := SA1->A1_LOJA
		else
			SA1->(MsSeek(xFilial("SA1") + cGet1 + cGet2,.F.,.F.))
		endif
		//_lRet   := ExistCpo("SA1",cGet1+cGet2,1) // Comentado por Arthur Silva devido a problemas aprensentado no retorno da fun??o.
		if _lRet .AND. SA1->(Found())
			cGet3 := SA1->A1_NOME
			AtuGet1()
			AtuGet2()
			AtuGet3()
		else
			//cGet1 := Space(TamSx3("A1_COD" )[01])
			cGet2 := Space(TamSx3("A1_LOJA")[01])
			cGet3 := Space(TamSx3("A1_NOME")[01])
		endif
	else
		cGet1 := Space(TamSx3("A1_COD" )[01])
		cGet2 := Space(TamSx3("A1_LOJA")[01])
		cGet3 := Space(TamSx3("A1_NOME")[01])
	endif
return _lRet
/*/{Protheus.doc} AtuGet1
@description Sub-rotina de atualiza??o do Get Dados 1.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGet1()
	local   _x        := 0
	local   nSC5      := 0
	local   _cTR1TMP  := GetNextAlias()
	local   cQry      := ""
	oMSNewGe1:aCols   := {}

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(dbGoTop())
	aStruSC5 := SC5->(dbStruct())

	cQry := " SELECT "
	for _x := 1 to len(aFields1)
		if _x > 1
			cQry += ", "
		endif
		cQry += aFields1[_x]
	next
	cQry += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) "                                                 + _clrf
	cQry += "  INNER JOIN " + RetSqlName("SA1") + " SA1 (NOLOCK) ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"' " + _clrf
	cQry += "                                                   AND SA1.A1_COD     = SC5.C5_CLIENTE "       + _clrf
	cQry += "                                                   AND SA1.A1_LOJA    = SC5.C5_LOJACLI "       + _clrf
	cQry += "                                                   AND SA1.D_E_L_E_T_ = '' "                   + _clrf
	cQry += "  INNER JOIN " + RetSqlName("SC6") + " SC6 (NOLOCK) ON SC6.C6_FILIAL  = SC5.C5_FILIAL "        + _clrf
	cQry += "                                                   AND SC6.C6_NUM     = SC5.C5_NUM "           + _clrf
	if !empty(cGet4)
		if _lSeekApr
			cQry += "                                           AND SC6.C6_PRODUTO LIKE '" + AllTrim(cGet4) + "%' " + _clrf
		else
			cQry += "                                           AND SC6.C6_PRODUTO    = '" + cGet4          + "'  " + _clrf
		endif
	endif
	if !empty(cGet15)	.or.  !empty(cGet16)
		cQry += "    JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) ON SD2.D2_FILIAL  = '" + xFilial("SD2") + "' "   + _clrf
		cQry += "                                                           AND SD2.D2_PEDIDO  = SC6.C6_NUM "                 + _clrf
		cQry += "                                                           AND SD2.D2_ITEMPV  = SC6.C6_ITEM "                + _clrf
		cQry += "                                                           AND SD2.D2_COD     = SC6.C6_PRODUTO "             + _clrf
		cQry += "                                                           AND SD2.D_E_L_E_T_ = '' "                         + _clrf
		If !empty(cGet15)
			cQry += "   AND SD2.D2_COD = '" + cGet15     + "'  " + _clrf	
		endif
		if 	!empty(cGet16)
			cQry += "   AND SD2.D2_LOTECTL     = '" + cGet16          + "'  " + _clrf
		endIf
	endif

	// Inclusão - Fernando Bombardi - 14/04/23
	cQry += "                                                   AND SC6.D_E_L_E_T_ = '' "                   + _clrf
	// Fim - Fernando Bombardi - 14/04/23

	cQry += "  INNER JOIN " + RetSqlName("SX5") + " SX5 (NOLOCK) ON SX5.X5_FILIAL  = SC5.C5_FILIAL "        + _clrf
	cQry += "                                                   AND SX5.X5_TABELA = 'DJ' AND  SX5.X5_CHAVE = SC5.C5_TPOPER "           + _clrf

	if !empty(cGet11)
			cQry += "   AND SC5.C5_TPOPER     = '" + cGet11          + "'  " + _clrf
	endif

	cQry += "                                                   AND SC6.D_E_L_E_T_ = '' "                   + _clrf
	cQry += " WHERE SC5.C5_FILIAL  = '" + xFilial("SC5") + "' " + _clrf
	cQry += "   AND SC5.C5_CLIENTE = '" + cGet1          + "' " + _clrf
	cQry += "   AND SC5.C5_LOJACLI = '" + cGet2          + "' " + _clrf
	cQry += "   AND SC5.C5_TIPO   <> 'D' "                      + _clrf
	//cQry += "   AND SC5.C5_TIPO   <> 'B' "                      + _clrf
	cQry += "   AND SC5.D_E_L_E_T_ = '' "                       + _clrf
	cQry += " GROUP BY C5_EMISSAO, C5_NUM ,  C5_TPOPER "                     + _clrf
	cQry += " ORDER BY C5_EMISSAO DESC, C5_NUM DESC "           + _clrf
	if Select(_cTR1TMP) > 0
		(_cTR1TMP)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cTR1TMP,.T.,.F.)
	for nSC5 := 1 To Len(aStruSC5)
		if aStruSC5[nSC5][2] <> "C" .AND.  FieldPos(aStruSC5[nSC5][1]) > 0
			TcSetField(_cTR1TMP,aStruSC5[nSC5][1],aStruSC5[nSC5][2],aStruSC5[nSC5][3],aStruSC5[nSC5][4])
		endif
	next nSC5
	dbSelectArea(_cTR1TMP)
	(_cTR1TMP)->(dbGoTop())
	While !(_cTR1TMP)->(EOF())
		_aCpos1 := {}
		for _x  := 1 To Len(aFields1)
			AADD(_aCpos1,&(_cTR1TMP+"->"+aFields1[_x]))
		next
		AADD(_aCpos1,.F.)
		AADD(oMSNewGe1:aCols,_aCpos1)
		(_cTR1TMP)->(dbSkip())
	enddo
	if Select(_cTR1TMP) > 0
		(_cTR1TMP)->(dbCloseArea())
	endif
	if empty(oMSNewGe1:aCols)
		oMSNewGe1:aCols := aClone(aAux1)
	endif
	oMSNewGe1:Refresh()
return .T.
/*/{Protheus.doc} AtuGe2
@description Sub-rotina responsavel por atualizar o GetDados 2.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGe2()
	AtuGet2()
	AtuGet3()
return .T.
/*/{Protheus.doc} AtuGet2
@description Sub-rotina de atualiza??o do Get Dados 2.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGet2()
	local   _x        := 0
	local   nSC6      := 0
	local   nSD2      := 0
	local   _cTR2TMP  := GetNextAlias()
	local   cQry      := ""
	local   aStruSC6  := {}
	local   aStruSD2  := {}
	oMSNewGe2:aCols   := {}

	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbGoTop())
	aStruSC6 := SC6->(dbStruct())
	dbSelectArea("SD2")
	SD2->(dbSetOrder(1))
	SD2->(dbGoTop())
	aStruSD2 := SD2->(dbStruct())
	cQry := " SELECT "
	for _x := 1 To Len(aFields2)
		if _x > 1
			cQry += ", "
		endif
		cQry += aFields2[_x]
	next
	cQry += " FROM " + RetSqlName("SC6") + " SC6 (NOLOCK) "                                                               + _clrf
	cQry += "     LEFT OUTER JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) ON SD2.D2_FILIAL  = '" + xFilial("SD2") + "' "   + _clrf
	cQry += "                                                           AND SD2.D2_PEDIDO  = SC6.C6_NUM "                 + _clrf
	cQry += "                                                           AND SD2.D2_ITEMPV  = SC6.C6_ITEM "                + _clrf
	cQry += "                                                           AND SD2.D2_COD     = SC6.C6_PRODUTO "             + _clrf
	cQry += "                                                           AND SD2.D_E_L_E_T_ = '' "                         + _clrf
	cQry += "  INNER JOIN " + RetSqlName("SC5") + " SC5 (NOLOCK) ON SC6.C6_FILIAL  = SC5.C5_FILIAL "        + _clrf
	cQry += "                                                   AND SC6.C6_NUM     = SC5.C5_NUM "           + _clrf
	// Inclusão - Fernando Bombardi - 14/04/23
	cQry += "                                                           AND SC5.D_E_L_E_T_ = '' "                         + _clrf	
	// Fim - Fernando Bombardi - 14/04/23
	cQry += " WHERE SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "                                                           + _clrf
	cQry += "   AND SC6.C6_NUM     = '" + oMSNewGe1:aCols[oMSNewGe1:nAT,aScan(aFields1,{|x|AllTrim(x)=="C5_NUM"})] + "' " + _clrf
	
	if !empty(cGet4)
		if _lSeekApr
			cQry += "   AND SC6.C6_PRODUTO LIKE '" + AllTrim(cGet4) + "%' "   + _clrf
		else
			cQry += "   AND SC6.C6_PRODUTO    = '" + cGet4          + "'  "   + _clrf
		endif
	endif


	if !empty(cGet11)
			cQry += "   AND SC5.C5_TPOPER     = '" + cGet11          + "'  " + _clrf
	endif
	if !empty(alltrim(cGet15))	
		cQry += "   AND SD2.D2_COD = '" + cGet15     + "'  " + _clrf		
	endIf
	if !empty(cGet16)
		cQry += "   AND SD2.D2_LOTECTL     = '" + cGet16        + "'  " + _clrf
	endif


	cQry += "   AND SC6.D_E_L_E_T_ = '' "                                                                                 + _clrf
	cQry += "ORDER BY D2_EMISSAO DESC, D2_DOC DESC, D2_ITEM ASC " + _clrf
	if Select(_cTR2TMP) > 0
		(_cTR2TMP)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cTR2TMP,.T.,.F.)
	for nSC6 := 1 to len(aStruSC6)
		if aStruSC6[nSC6][2] <> "C" .and. FieldPos(aStruSC6[nSC6][1]) > 0
			TcSetField(_cTR2TMP,aStruSC6[nSC6][1],aStruSC6[nSC6][2],aStruSC6[nSC6][3],aStruSC6[nSC6][4])
		endif
	next nSC6
	for nSD2 := 1 to len(aStruSD2)
		if aStruSD2[nSD2][2] <> "C" .and. FieldPos(aStruSD2[nSD2][1]) > 0
			TcSetField(_cTR2TMP,aStruSD2[nSD2][1],aStruSD2[nSD2][2],aStruSD2[nSD2][3],aStruSD2[nSD2][4])
		endif
	next nSD2
	dbSelectArea(_cTR2TMP)
	(_cTR2TMP)->(dbGoTop())
	if !(_cTR2TMP)->(EOF())
		while !(_cTR2TMP)->(EOF())
			_aCpos2 := {}
			for _x := 1 to len(aFields2)

				// Alteração - Fernando Bombardi - 14/04/23
				//AADD(_aCpos2,&(_cTR2TMP+"->"+aFields2[_x]))
				if &(_cTR2TMP+"->D2_TOTAL") > 0
					if Alltrim(aFields2[_x]) == "C6_VALDESC"

						if &(_cTR2TMP+"->D2_PRCVEN") < &(_cTR2TMP+"->C6_PRUNIT")

							AADD(_aCpos2,&("("+_cTR2TMP+"->C6_PRUNIT * " + _cTR2TMP + "->D2_QUANT) - "+ _cTR2TMP + "->D2_TOTAL"))

						else

							AADD(_aCpos2,&(_cTR2TMP+"->"+aFields2[_x]))

						endif

					else

						AADD(_aCpos2,&(_cTR2TMP+"->"+aFields2[_x]))

					endif
				else
					Do Case
						case Alltrim(aFields2[_x]) == "D2_QUANT"
							AADD(_aCpos2,&(_cTR2TMP+"->C6_QTDVEN"))
						case Alltrim(aFields2[_x]) == "D2_PRCVEN"
							AADD(_aCpos2,&(_cTR2TMP+"->C6_PRCVEN"))
						case Alltrim(aFields2[_x]) == "D2_TOTAL"
							AADD(_aCpos2,&(_cTR2TMP+"->C6_VALOR"))
						otherwise
							AADD(_aCpos2,&(_cTR2TMP+"->"+aFields2[_x]))
					End Case
				endif
				// Fim Alteração - Fernando Bombardi - 14/04/23
	
			next
			AADD(_aCpos2,.F.)
			AADD(oMSNewGe2:aCols,_aCpos2)
			(_cTR2TMP)->(dbSkip())
		enddo
	else
		oMSNewGe2:aCols := aClone(aAux2)
	endif
	if Select(_cTR2TMP) > 0
		(_cTR2TMP)->(dbCloseArea())
	endif
	if empty(oMSNewGe2:aCols) .OR. len(oMSNewGe2:aCols) == 0
		oMSNewGe2:aCols := aClone(aAux2)
	endif
	//For?o a primeira ordena??o por produto
	if (_nColPrd := aScan(oMSNewGe2:aHeader,{|x| AllTrim(x[02])=="C6_PRODUTO"})) > 0
		_nOrd    := _nColPrd
	endif

	cGet5 := AtuGet3()
	oGet5:Refresh()

	oMSNewGe2:aCols := aSort( oMSNewGe2:aCols, , , { |x,y| x[_nOrd] < y[_nOrd] } )
	oMSNewGe2:oBrowse:Refresh()
return .T.
/*/{Protheus.doc} OpenPV
@description Sub-rotina utilizada para abrir o pedido de vendas posicionado.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 19/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function OpenPV()
	local _aSvAr   := GetArea()
	local _aSvArC5 := SC5->(GetArea())
	local _cPedVen := ""

	if ValType(oMSNewGe1:aCols)=="A"
		_cPedVen := oMSNewGe1:aCols[oMSNewGe1:nAT,aScan(aFields1,{|x|AllTrim(x)=="C5_NUM"})]
		if !empty(_cPedVen)
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			if SC5->(MsSeek(xFilial("SC5") + _cPedVen,.T.,.F.))
				aRotina2  := {	{ "Incluir"			,"A410Barra"	,0,3},;
								{ "Alterar"			,"A410Barra"	,0,4}}
								
				aRotina3  := {	{ "Excluir"			,"A410Deleta"	,0,5,21,NIL},;
								{ "Residuo"			,"Ma410Resid"	,0,2, 0,NIL}}
								
				aRotina   := {	{ "Pesquisar"		,"AxPesqui"		,0,1,0 ,.F.},;
								{ "Visualizar"		,"A410Visual"	,0,2,0 ,NIL},;
								{ "Legenda"			,"A410Legend"	,0,3,0 ,.F.},;
								{ "Cliente"			,"U_RFATE031"	,0,6,0 ,NIL},;
								{ "Conhecimento"	,"MsDocument"	,0,4,0 ,NIL} }
				if ExistBlock("MA410MNU")
					U_MA410MNU()
				endif
			    SetKey(VK_F7 , { ||  } )
			    SetKey(VK_F8 , { ||  } )
			    SetKey(VK_F12, { ||  } )
				_lInclui := INCLUI
				_lAltera := ALTERA
				A410Visual("SC5",SC5->(Recno()),2)
				INCLUI   := _lInclui
				ALTERA   := _lAltera
			    SetKey(VK_F7 , { || OpenPV() } )
			    SetKey(VK_F8 , { || AltCli() } )
			    SetKey(VK_F12, { || Reord()  } )
			else
				MsgAlert("Pedido " + _cPedVen + " não encontrado!",_cRotina+"_001")
			endif
		endif
	endif
	RestArea(_aSvArC5)
	RestArea(_aSvAr)
return
/*/{Protheus.doc} Reord
@description Sub-rotina utilizada para reordenar grid 2 (itens).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 19/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Reord()
	local oGrp1
	local oCboBo1
	local oSBut1
	local _aSvAr    := GetArea()
	local _aItens   := {}
	local _j        := 0

	if len(oMSNewGe2:aHeader) > 0 .AND. len(oMSNewGe2:aCols) > 0
		for _j := 1 to len(oMSNewGe2:aHeader)
			AADD(_aItens,oMSNewGe2:aHeader[_j][01])
		next
		//For?o a primeira ordena??o por produto
		if (_nColPrd := aScan(oMSNewGe2:aHeader,{|x| AllTrim(x[02])=="C6_PRODUTO"})) > 0
			_nOrd := _nColPrd
		endif
		static oDlg2
		DEFINE MSDIALOG oDlg2 TITLE " Reordenação dos Registros (itens) " FROM 000, 000  TO 150, 350 COLORS 0, 16777215 PIXEL
			@ 007, 004 GROUP      oGrp1   TO 059, 171 OF oDlg2 COLOR 0, 16777215 PIXEL
			@ 023, 010 MSCOMBOBOX oCboBo1 VAR _nOrd ITEMS _aItens SIZE 156, 010 OF oDlg2 COLORS 0, 16777215 PIXEL
			DEFINE SBUTTON oSBut1 FROM 041, 137 TYPE 01 OF oDlg2 ENABLE ACTION Close(oDlg2)
		ACTIVATE MSDIALOG oDlg2 CENTERED
		if ValType(_nOrd) == "C"
			_nOrd := aScan(_aItens,_nOrd)
		endif
		oMSNewGe2:aCols := aSort( oMSNewGe2:aCols, , , { |x,y| x[_nOrd] < y[_nOrd] } )
		oMSNewGe2:oBrowse:Refresh()
	endif
	RestArea(_aSvAr)
return
/*/{Protheus.doc} AltCli
@description Sub-rotina utilizada para alterar o cliente selecionado.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 22/05/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AltCli()
	local _aSvAr := GetArea()
	if !empty(cGet1) .AND. !Empty(cGet2)
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if SA1->(MsSeek(xFilial("SA1") + cGet1 + cGet2,.T.,.F.))
		    SetKey(VK_F7 , { ||  } )
		    SetKey(VK_F8 , { ||  } )
		    SetKey(VK_F12, { ||  } )
	   	    AROTAUTO  := NIL
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			A030Altera("SA1",SA1->(RECNO()),4)
		    SetKey(VK_F7 , { || OpenPV() } )
		    SetKey(VK_F8 , { || AltCli() } )
		    SetKey(VK_F12, { || Reord()  } )
		endif
	endif
	RestArea(_aSvAr)
return
/*/{Protheus.doc} AtuGet3
@description Sub-rotina de atualiza??o do Get Dados 5.
@author Livia Della Corte (ALL System Solutions)
@since 16/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGet3()
	//////////////////////////////////////////
	//DEVER? HAVER O SAVAREA x RESTAREA?????//
	//////////////////////////////////////////
	local   _cATR3TMP := GetNextAlias()
	local   aStruSC6  := {}
	local   _cPv      := oMSNewGe1:aCols[oMSNewGe1:nAT,aScan(aFields1,{|x|AllTrim(x)=="C5_NUM"})]
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbGoTop())
	aStruSC6 := SC6->(dbStruct())
	BeginSql Alias _cATR3TMP
		SELECT SUM(SC6.C6_VALOR) C6_VALOR
		FROM %table:SC6% SC6 (NOLOCK)
		  /*  LEFT OUTER JOIN %table:SD2% SD2 (NOLOCK) ON SD2.D2_FILIAL = %xFilial:SD2%
		                                            AND SD2.D2_PEDIDO = SC6.C6_NUM
		                                            AND SD2.D2_ITEMPV = SC6.C6_ITEM
		                                            AND SD2.D2_COD    = SC6.C6_PRODUTO
		                                            AND SD2.%NotDel%*/ //Trecho comentado devido a rastreabilidade está somando itens de forma incorreta
		WHERE SC6.C6_FILIAL  = %xFilial:SC6%
		  AND SC6.C6_NUM     = %Exp:_cPv%			//Total do Pedido
		  AND SC6.%NotDel%
	EndSql
	dbSelectArea(_cATR3TMP)
	(_cATR3TMP)->(dbGoTop())
	if !(_cATR3TMP)->(EOF())
		while !(_cATR3TMP)->(EOF())
			cGet5 :=  ROUND((_cATR3TMP)->C6_VALOR, TamSx3("C6_VALOR")[02])
			(_cATR3TMP)->(dbSkip())
		enddo
	endif
	if Select(_cATR3TMP) > 0
		dbSelectArea(_cATR3TMP)
		(_cATR3TMP)->(dbCloseArea())
	endif
	oMSNewGe1:oBrowse:Refresh()
	oMSNewGe2:oBrowse:Refresh()
return cGet5
/*/{Protheus.doc} PesqPrd
@description Sub-rotina de pesquisa por Produto.
@author Livia Della Corte (ALL System Solutions)
@since 19/12/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
static function PesqPrd()
	local oGrp2
	local oSBut2
//	local _aItens   := {}
//	local _aSvAr    := GetArea()
	private oSay6
	private oGet6
	private cGet6 := Space(len(SB1->B1_COD))

	_lSeekApr     := .F.

	static oDlg3
	DEFINE MSDIALOG oDlg3 TITLE " Pesquisa Por Produto " FROM 000, 000  TO 150, 350 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
		oDlg3:lEscClose := .F.
		@ 007, 004 GROUP  oGrp2                                         TO 059, 171                                      OF oDlg3 COLOR  0, 16777215 PIXEL
		@ 023, 010 SAY    oSay6   PROMPT "Produto: "                                                       SIZE 020, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
		@ 023, 050 MSGET  oGet6   VAR    cGet6    F3 "SB1" /*VALID (VAZIO() .OR. ExistCpo("SB1",cGet6))*/  SIZE 080, 010 OF oDlg3 COLORS 0, 16777215 PIXEL
		DEFINE SBUTTON oSBut2 FROM 041, 137 TYPE 01 OF oDlg3 ENABLE ACTION IIF(valtype(oDlg3)=="O",Close(oDlg3),nil)
	ACTIVATE MSDIALOG oDlg3 CENTERED
	if !empty(cGet6)
		dbselectArea("SB1")
		SB1->(dbSetOrder(1))
		if !SB1->(MsSeek(xFilial("SB1") + cGet6,.T.,.F.))
			SB1->(MsSeek(xFilial("SB1") + AllTrim(cGet6),.F.,.F.))	//Busca aproximada
			_lSeekApr := .T.
		endif
	endif
	if !empty(cGet11)
		If !msgYesNo("Manter o Filtro do Produto: "+ cGet11 +" ?")
			cGet11:= ""
		endIf
	endif
	if !empty(cGet6) .AND. SubStr(SB1->B1_COD,1,len(AllTrim(cGet6))) == AllTrim(cGet6)
		cDescSB1 := SB1->B1_DESC
		cSay4    := "Produto: "
		oSay4:Refresh()
		cGet4    := cGet6
		oGet4:Refresh()
		if _lSeekApr
			cGet7    :=  " - PRODUTOS INICIADOS COM ESTE C?DIGO"
			oGet7:Refresh()
		else
			cGet7    :=  " - " + cDescSB1
			oGet7:Refresh()
		endif
	else
		cSay4 := SPACE(len(SB1->B1_COD ))
		oSay4:Refresh()
		cGet4 := SPACE(len(SB1->B1_COD ))
		oGet4:Refresh()
		cGet7 := SPACE(len(SB1->B1_DESC))
		oGet7:Refresh()
	endif
	atuGet1()
	atuGet2()
	atuGet3()
return .T.



/*/{Protheus.doc} //PesqPrd
@description Sub-rotina de pesquisa por tipo de pedido: .
@author Livia Della Corte (ALL System Solutions)
@since 23/11/2022
@version 1.0
@type function
@see https://allss.com.br
/*/
static function PesqTPO()
	local oGrp2
	local oSBut2
	private oSay11
	private oGet11
	private cGet11 := Space(len(SX5->X5_CHAVE))
	private cSay11

	_lSeekApr     := .F.

	static oDlg4
	DEFINE MSDIALOG oDlg4 TITLE " Pesquisa Por Tipo de Pedido de Venda " FROM 000, 000  TO 150, 350 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
		oDlg4:lEscClose := .F.
		@ 007, 004 GROUP  oGrp2                                         TO 059, 171                                      OF oDlg3 COLOR  0, 16777215 PIXEL
		@ 023, 010 SAY    oSay11   PROMPT "Tipo: "                                                       SIZE 020, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
		@ 023, 050 MSGET  oGet11   VAR    cGet11    F3 "DJTMK" SIZE 080, 010 OF oDlg4 COLORS 0, 16777215 PIXEL
		DEFINE SBUTTON oSBut2 FROM 041, 137 TYPE 01 OF oDlg4 ENABLE ACTION IIF(valtype(oDlg4)=="O",Close(oDlg4),nil)

	Activate MSDialog oDlg4 Centered 

	if !empty(cGet4)
		If !msgYesNo("Manter o Filtro do Produto: "+ cGet4 +" ?")
			cGet4:= ""
		endIf
	endif

	if !empty(cGet11)
		dbselectArea("SX5")
		SX5->(dbSetOrder(1))
		if  SX5->(MsSeek(xFilial("SX5") + "DJ"+ cGet11,.T.,.F.))
				cSay12   := "Tipo: "
				oSay12:Refresh()
				cGet12    := alltrim(SX5->X5_CHAVE) + " - " + alltrim(SX5->X5_DESCRI)
				oGet12:Refresh()
		endif
	else
		cGet11 := SPACE(len(SX5->X5_CHAVE))
		cSay12 := SPACE(len(SX5->X5_CHAVE ))
		oSay12:Refresh()
		cGet12 := SPACE(len(SX5->X5_CHAVE)+LEN(SX5->X5_DESCRI))
		oGet12:Refresh()
	endif

	atuGet1()
	atuGet2()
	atuGet3()
return .T.


/*
Static Function TabDJGrid()
Local nX := 1
Private   cFiltro := ' X5_TABELA == "DJ" .and. ('

	cFiltro+= ")"
	 dbSelectArea("SX5")
     MsFilter(cFiltro)
     oDlg4:Refresh()
return .T.*/

User Function TabDJGrid()
Local oDlg, oLbx
Local aCpos  := {}
Local aRet   := {}
Local cQuery := ""
Local cAlias := GetNextAlias()
Local lRet   := .F.
Local nX     := 1
Private aParTAB_DJ:= StrTokArr(SuperGetMV("MV_TABDJ", .F., "01/02/04/06/6 /7 /8 /Z2/Z7/Z8/ZZ" ),"/") 

// .AND. X5_CHAVE == "01" .OR. X5_CHAVE == "02" .OR. X5_CHAVE == "04" .OR. X5_CHAVE == "06" .OR. X5_CHAVE == "6 " .OR. X5_CHAVE == "7 " .OR. X5_CHAVE == "8 " .OR. X5_CHAVE == "Z2" .OR. X5_CHAVE == "Z7" .OR. X5_CHAVE == "Z8" .OR. X5_CHAVE == "ZZ"'

cQuery := " SELECT DISTINCT SX5.X5_CHAVE,  SX5.X5_DESCRI  "
cQuery +=   " FROM " + RetSqlName("SX5") + " SX5 "
cQuery +=  " WHERE SX5.D_E_L_E_T_ = ' ' "
cQuery +=    " AND SX5.X5_TABELA ='DJ' "
cQuery +=    "  and X5_CHAVE in ("

	For nX := 1 To Len(aParTAB_DJ)
		IF  nX == Len(aParTAB_DJ)
			cQuery += 	"  '" + aParTAB_DJ[nX]  + "' )"
		else 
			cQuery  += 	"  '" + aParTAB_DJ[nX]  + "' ,"
		endif
	Next

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

   While (cAlias)->(!Eof())
      aAdd(aCpos,{ (cAlias)->(X5_CHAVE), (cAlias)->(X5_DESCRI)})
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   If Len(aCpos) < 1
      aAdd(aCpos,{" "," "})
   EndIf

   DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Tipo de Pedido de Venda" FROM 0,0 TO 240,500 PIXEL

     @ 10,10 LISTBOX oLbx FIELDS HEADER 'Tipo' /*"Tipo"*/, 'Descricao' /*"Descricao"*/ SIZE 230,95 OF oDlg PIXEL

     oLbx:SetArray( aCpos )
     oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
     oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

  DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
  ACTIVATE MSDIALOG oDlg CENTER

  If Len(aRet) > 0 .And. lRet
     If Empty(aRet[1])
        lRet := .F.
     Else
        SX5->(dbSetOrder(1))
        SX5->(dbSeek(xFilial("SX5")+"DJ"+aRet[1]))
     EndIf
  EndIf
Return lRet




/*/{Protheus.doc} //PesqPrd
@description Sub-rotina de pesquisa por lote .
@author Livia Della Corte (ALL System Solutions)
@since 23/11/2022
@version 1.0
@type function
@see https://allss.com.br
/*/
static function fLotePV()
	local oGrp2
	local oSBut2
	private oSay13
	private oGet13
	private cSay13 :=SPACE(len(SX5->X5_CHAVE ))
	private cSay14 :=SPACE(len(SX5->X5_CHAVE ))
	
	private oSay14
	private oGet14
	private cSay15 :=SPACE(len(SX5->X5_CHAVE ))
	private cSay16 :=SPACE(len(SX5->X5_CHAVE ))
	


	//PesqPrd()

	static oDlg5
	DEFINE MSDIALOG oDlg5 TITLE " Pesquisa Por Lote " FROM 000, 000  TO 150, 350 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
		oDlg5:lEscClose := .F.
		@ 007, 004 GROUP  oGrp2                                         TO 059, 171                                      OF oDlg5 COLOR  0, 16777215 PIXEL
	
		@ 023, 010 SAY    oSay13   PROMPT "Produto: "                                                       SIZE 020, 007 OF oDlg5 COLORS 0, 16777215 PIXEL
		@ 023, 050 MSGET  oGet13   VAR    cGet13    F3 "SB1" /*VALID (VAZIO() .OR. ExistCpo("SB1",cGet6))*/  SIZE 080, 010 OF oDlg5 COLORS 0, 16777215 PIXEL
	
		@ 043, 010 SAY    oSay14   PROMPT "Lote: "                                                       SIZE 020, 007 OF oDlg5 COLORS 0, 16777215 PIXEL
		@ 043, 050 MSGET  oGet14   VAR    cGet14     SIZE 080, 010 OF oDlg5 COLORS 0, 16777215 PIXEL
		DEFINE SBUTTON oSBut2 FROM 041, 137 TYPE 01 OF oDlg5 ENABLE ACTION IIF(valtype(oDlg5)=="O",Close(oDlg5),nil)

	Activate MSDialog oDlg5 Centered 
	//If (!empty(cGet13) .or.  !empty(cGet14) ) .and. cGet13<> 
		cGet15    := cGet13
		cGet16    := cGet14
		cGet13    :=  SPACE(len(SX5->X5_CHAVE ))
	//	oGet13:Refresh()
		cGet14    :=  SPACE(len(SX5->X5_CHAVE ))
	//	oGet14:Refresh()
	//endIf

	atuGet1()
	atuGet2()
	atuGet3()
return .T.
