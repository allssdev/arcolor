#include 'protheus.ch'
#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} className
    Classe contendo os metodos da rotina Wizard Report
    @author Fernando Bombardi - ALLSS
    @since 24/03/2022
    @version P12.1.33
    /*/
Class ALLSSC01 from longnameclass

	Method New() CONSTRUCTOR
	Method CriarPaginaTabelaPrincipal()
	Method ValidarPaginaTabelaPrincipal()
	Method CriarPaginaRelacionamento()
	Method ValidarPaginaRelacionamentoTabelas()
	Method CriarPaginaSelecaoCampos()
	Method CriarPaginaFiltros()
	Method CarregarTabelas()
	Method PesquisarTabela()
	Method IncluirRelacionamentosTabelas()
	Method BrowserTabelaDominio()
	Method BrowserExpressoesContraDominio()
	Method BuscarExpressoesTabelaContraDominio()
	Method IncluirTabelaContraDominio()
	Method PesquisarTabelaContraDominio()
	Method IncluirCampoGridSelecionados()
	Method IncluirTodosCamposGridSelecionados()
	Method RemoverTodosCamposGridSelecionados()
	Method RemoverCampoGridSelecionados()
	Method ValidarPaginaSelecaoCampos()
	Method IncluirParametroCampo()
	Method ExcluirParametroCampo()
	Method FiltrosConsultaSQL()
	Method BuscarDadosCampoSX3()
	Method GerarPlanilhaExcel()
	Method MontarQuerySQL()

EndClass

/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 24/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method New() Class ALLSSC01
Return

//--------------------------
// Construção da página 1
//--------------------------
/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 24/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method CriarPaginaTabelaPrincipal(oPanel, _aBrwSx2, oBrowSX2, _cPesquisarSx2) Class ALLSSC01

	Local oTGet2
	Local oTButton1

	oSay1:= TSay():New(08,10,{||'Selecionar a tabela principal para ser utilizada pelo relatório.'},oPanel,,,,,,.T.,,,200,20)

	::CarregarTabelas()
	if len(_aBrwSx2) <= 0
		aADD(_aBrwSx2,{"",""})
	endif

	oBrowSX2 := TWBrowse():New(20,10,382,150,,;
		{'Tabela','Descricao'},;
		{30,100}, oPanel,,,,,{|| Alert("Clique") },,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrowSX2:SetArray(_aBrwSx2)

	// Monta a linha a ser exibina no Browse
	oBrowSX2:bLine := {||{ _aBrwSx2[oBrowSX2:nAt,01] ,;
		_aBrwSx2[oBrowSX2:nAT,02] } }

	//oSay2:= TSay():New(170,10,{||'Pesquisar'},oPanel,,,,,,.T.,,,200,20)
	_cPesquisarSx2 := Space(3)
	oTGet2 := tGet():New(180,10,{|u| if(PCount()>0,_cPesquisarSx2:=u,_cPesquisarSx2)}, oPanel ,50,09,"@!",{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"HSPSX2","_cPesquisarSx2")
	oTButton1 := TButton():New( 180, 065, "Pesquisar",oPanel,{|| ::PesquisarTabela(_cPesquisarSx2) }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )

Return


//----------------------------------------
// Validação do botão Próximo da página 1
//----------------------------------------
/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 24/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method ValidarPaginaTabelaPrincipal(_cTabelaPrimaria,oBrowSX2) Class ALLSSC01

	_cTabelaPrimaria := _aBrwSx2[oBrowSX2:nAt,01]

Return .T.

//--------------------------
// Construção da página 2
//--------------------------
/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 24/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method CriarPaginaRelacionamento(oPanel, _aBrwRel, oBrowRel, _cTabelaPrimaria) Class ALLSSC01

	oSay1:= TSay():New(08,10,{||'Selecionar relecionamento entre tabelas.'},oPanel,,,,,,.T.,,,200,20)

	aADD(_aBrwRel,{"","",""})

	oBrowRel := TWBrowse():New(20,10,382,150,,;
		{'Tabela Relacionada ','Expressão Tabela Principal','Expressão Tabela','Expressão Tabela Relacionada'},;
		{100,200,200}, oPanel,,,,,{|| /*NILL*/ },,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrowRel:SetArray(_aBrwRel)

	// Monta a linha a ser exibina no Browse
	oBrowRel:bLine := {||{ _aBrwRel[oBrowRel:nAt,01], _aBrwRel[oBrowRel:nAT,02], _aBrwRel[oBrowRel:nAT,03] } }

	_cCSSInc := "QPushButton {"
	_cCSSInc += " background-image: url(rpo:BMPINCLUIR.PNG);background-repeat: none; margin: 2px;"
	_cCSSInc += " border-style: outset;"
	_cCSSInc += " border-width: 2px;"
	_cCSSInc += " border: 1px solid #C0C0C0;"
	_cCSSInc += " border-radius: 5px;"
	_cCSSInc += " border-color: #C0C0C0;"
	_cCSSInc += " font: bold 12px Arial;"
	_cCSSInc += " padding: 6px;"
	_cCSSInc += "}"

	oBtnIncluir := TButton():New(180,010,"  "	,oPanel,{|| ::IncluirRelacionamentosTabelas() },15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnIncluir:SetCss(_cCSSInc)

	_cCSSExc := "QPushButton {"
	_cCSSExc += " background-image: url(rpo:BMPDEL.PNG);background-repeat: none; margin: 2px;"
	_cCSSExc += " border-style: outset;"
	_cCSSExc += " border-width: 2px;"
	_cCSSExc += " border: 1px solid #C0C0C0;"
	_cCSSExc += " border-radius: 5px;"
	_cCSSExc += " border-color: #C0C0C0;"
	_cCSSExc += " font: bold 12px Arial;"
	_cCSSExc += " padding: 6px;"
	_cCSSExc += "}"

	oBtnExcluir := TButton():New(180,030,"  "	,oPanel,{|| Alert('Botão Imprimir com efeito') },15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExcluir:SetCss(_cCSSExc)

Return

/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 24/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method ValidarPaginaRelacionamentoTabelas() Class ALLSSC01




Return(.T.)

//--------------------------
// Construção da página 3
//--------------------------
/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 24/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method CriarPaginaSelecaoCampos(oPanel) Class ALLSSC01
	Local _nTabsCpos := 0
	Local _cInTabCpo := ""
	Local _lTabCon   := .F.


	_cInTabCpo := Alltrim(_cTabelaPrimaria)

	for _nTabsCpos := 1 to len(oBrowRel:AARRAY)
		if !EMPTY(oBrowRel:AARRAY[_nTabsCpos,01])
			_lTabCon := .T.
			_cInTabCpo += "/" + Alltrim(oBrowRel:AARRAY[_nTabsCpos,01])
		endif
	next

	_cQry := "SELECT X3_ARQUIVO,X3_ORDEM, X3_CAMPO, X3_TITULO "
	_cQry += " FROM SX3" + cEmpAnt + "0 SX3 "
	_cQry += " WHERE "
	if _lTabCon
		_cQry += " X3_ARQUIVO IN " + FormatIn(_cInTabCpo, "/") + " AND "
	else
		_cQry += " X3_ARQUIVO = '" + _cInTabCpo + "' AND "
	endif
	_cQry += " X3_CONTEXT <> 'V' AND "	
	_cQry += " SX3.D_E_L_E_T_ = '' "
	_cQry += " ORDER BY X3_ARQUIVO,X3_ORDEM "
	TCQUERY _cQry NEW ALIAS "SX3QRY"

	if SX3QRY->(!EOF())
		while SX3QRY->(!EOF())
			aADD(_aBrwCpo,{ Alltrim(SX3QRY->X3_CAMPO), Alltrim(SX3QRY->X3_TITULO)})
			SX3QRY->(dbSkip())
		enddo
	endif
	SX3QRY->(dbCloseArea())

	oBrwCpo := TWBrowse():New(20,10,160,150,,;
		{'Campo','Descricao'},;
		{50,100}, oPanel,,,,,{|| Alert("Clique") },,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrwCpo:SetArray(_aBrwCpo)

	// Monta a linha a ser exibina no Browse
	oBrwCpo:bLine := {||{ _aBrwCpo[oBrwCpo:nAt,01] ,;
		_aBrwCpo[oBrwCpo:nAT,02] } }

	/////////////////////////////////////////////////////////////

	aADD(_aBrwSelCpo,{"",""})

	oBrwSelCpo := TWBrowse():New(20,230,160,150,,;
		{'Campo','Descricao'},;
		{50,100}, oPanel,,,,,{|| Alert("Clique") },,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrwSelCpo:SetArray(_aBrwSelCpo)

	// Monta a linha a ser exibina no Browse
	oBrwSelCpo:bLine := {||{ _aBrwSelCpo[oBrwSelCpo:nAt,01] ,;
		_aBrwSelCpo[oBrwSelCpo:nAT,02] } }


	_cCSSExc := "QPushButton {"
	_cCSSExc += " background-image: url(rpo:PMSSETADIR_MDI.PNG);background-repeat: none; margin: 2px;"
	_cCSSExc += " border-style: outset;"
	_cCSSExc += " border-width: 2px;"
	_cCSSExc += " border: 1px solid #C0C0C0;"
	_cCSSExc += " border-radius: 5px;"
	_cCSSExc += " border-color: #C0C0C0;"
	_cCSSExc += " font: bold 12px Arial;"
	_cCSSExc += " padding: 6px;"
	_cCSSExc += "}"

	oBtnExcluir := TButton():New(50,190,"  "	,oPanel,{|| ::IncluirCampoGridSelecionados() },15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExcluir:SetCss(_cCSSExc)


	_cCSSExc := "QPushButton {"
	_cCSSExc += " background-image: url(rpo:PGNEXT_MDI.PNG);background-repeat: none; margin: 2px;"
	_cCSSExc += " border-style: outset;"
	_cCSSExc += " border-width: 2px;"
	_cCSSExc += " border: 1px solid #C0C0C0;"
	_cCSSExc += " border-radius: 5px;"
	_cCSSExc += " border-color: #C0C0C0;"
	_cCSSExc += " font: bold 12px Arial;"
	_cCSSExc += " padding: 6px;"
	_cCSSExc += "}"

	oBtnExcluir := TButton():New(65,190,"  "	,oPanel,{|| ::IncluirTodosCamposGridSelecionados() },15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExcluir:SetCss(_cCSSExc)


	_cCSSExc := "QPushButton {"
	_cCSSExc += " background-image: url(rpo:PMSSETAESQ_MDI.PNG);background-repeat: none; margin: 2px;"
	_cCSSExc += " border-style: outset;"
	_cCSSExc += " border-width: 2px;"
	_cCSSExc += " border: 1px solid #C0C0C0;"
	_cCSSExc += " border-radius: 5px;"
	_cCSSExc += " border-color: #C0C0C0;"
	_cCSSExc += " font: bold 12px Arial;"
	_cCSSExc += " padding: 6px;"
	_cCSSExc += "}"

	oBtnExcluir := TButton():New(90,190,"  "	,oPanel,{|| ::RemoverCampoGridSelecionados() },15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExcluir:SetCss(_cCSSExc)


	_cCSSExc := "QPushButton {"
	_cCSSExc += " background-image: url(rpo:PGPREV_MDI.PNG);background-repeat: none; margin: 2px;"
	_cCSSExc += " border-style: outset;"
	_cCSSExc += " border-width: 2px;"
	_cCSSExc += " border: 1px solid #C0C0C0;"
	_cCSSExc += " border-radius: 5px;"
	_cCSSExc += " border-color: #C0C0C0;"
	_cCSSExc += " font: bold 12px Arial;"
	_cCSSExc += " padding: 6px;"
	_cCSSExc += "}"

	oBtnExcluir := TButton():New(105,190,"  "	,oPanel,{|| ::RemoverTodosCamposGridSelecionados() },15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExcluir:SetCss(_cCSSExc)

Return

//--------------------------
// Construção da página 4
//--------------------------
/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 24/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method CriarPaginaFiltros(oPanel) Class ALLSSC01
Local _nTabsCpos := 0
Local _aItems:= {'De\Ate','Unico'}

	/////////////////////////////////////////////////////////////
	for _nTabsCpos := 1 to len(oBrwSelCpo:AARRAY)
		aADD(_aSelCpos, {Alltrim(oBrwSelCpo:AARRAY[_nTabsCpos,01]),Alltrim(oBrwSelCpo:AARRAY[_nTabsCpos,02])} )
	next

	oBrwCpoFil := TWBrowse():New(20,10,160,180,,;
		{'Campo','Descricao'},;
		{50,100}, oPanel,,,,,{|| /*Alert("Clique")*/ },,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrwCpoFil:SetArray(_aSelCpos)

	// Monta a linha a ser exibina no Browse
	oBrwCpoFil:bLine := {||{ _aSelCpos[oBrwCpoFil:nAt,01] ,;
		_aSelCpos[oBrwCpoFil:nAT,02] } }

	/////////////////////////////////////////////////////////////
    _cCombo1:= _aItems[1]
    oCombo1 := TComboBox():New(20,230,{|u|if(PCount()>0,_cCombo1:=u,_cCombo1)},;
    _aItems,160,20,oPanel,,{|| /*Alert('Mudou item da combo')*/ };
    ,,,,.T.,,,,,,,,,'_cCombo1')

	/////////////////////////////////////////////////////////////
    aADD(_aBrwPar,{"","","","",""})

	oBrwCpoPar := TWBrowse():New(50,230,160,150,,;
		{'Campo','Descricao','F3','Tipo Where','Tipo'},;
		{50,50,50,30,30}, oPanel,,,,,{|| /*Alert("Clique")*/ },,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrwCpoPar:SetArray(_aBrwPar)

	// Monta a linha a ser exibina no Browse
	oBrwCpoPar:bLine := {||{ _aBrwPar[oBrwCpoPar:nAt,01] ,;
		_aBrwPar[oBrwCpoPar:nAT,02],_aBrwPar[oBrwCpoPar:nAT,03],_aBrwPar[oBrwCpoPar:nAT,04],_aBrwPar[oBrwCpoPar:nAT,05]} }
	
	/////////////////////////////////////////////////////////////
	_cCSSExc := "QPushButton {"
	_cCSSExc += " background-image: url(rpo:BMPINCLUIR.PNG);background-repeat: none; margin: 2px;"
	_cCSSExc += " border-style: outset;"
	_cCSSExc += " border-width: 2px;"
	_cCSSExc += " border: 1px solid #C0C0C0;"
	_cCSSExc += " border-radius: 5px;"
	_cCSSExc += " border-color: #C0C0C0;"
	_cCSSExc += " font: bold 12px Arial;"
	_cCSSExc += " padding: 6px;"
	_cCSSExc += "}"

	oBtnExcluir := TButton():New(30,190,"  "	,oPanel,{|| ::IncluirParametroCampo() },15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExcluir:SetCss(_cCSSExc)

	/////////////////////////////////////////////////////////////
	_cCSSExc := "QPushButton {"
	_cCSSExc += " background-image: url(rpo:BMPDEL.PNG);background-repeat: none; margin: 2px;"
	_cCSSExc += " border-style: outset;"
	_cCSSExc += " border-width: 2px;"
	_cCSSExc += " border: 1px solid #C0C0C0;"
	_cCSSExc += " border-radius: 5px;"
	_cCSSExc += " border-color: #C0C0C0;"
	_cCSSExc += " font: bold 12px Arial;"
	_cCSSExc += " padding: 6px;"
	_cCSSExc += "}"

	oBtnExcluir := TButton():New(45,190,"  "	,oPanel,{|| ::ExcluirParametroCampo() },15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExcluir:SetCss(_cCSSExc)


Return

/*/{Protheus.doc} methodName
	(long_description)
	@author Fernando Bombardi - ALLSS
	@since 05/04/2022
	@version P12.1.33
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method IncluirParametroCampo() class ALLSSC01


	if ::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],3) <> "N"

		if Alltrim(_cCombo1) == 'De\Ate'

			if Empty(_aBrwPar[oBrwCpoPar:nAt,01])

				_aBrwPar[oBrwCpoPar:nAt,01] := _aSelCpos[oBrwCpoFil:nAt,01]
				_aBrwPar[oBrwCpoPar:nAT,02] := _aSelCpos[oBrwCpoFil:nAT,02] + " de?"
				_aBrwPar[oBrwCpoPar:nAT,03] := ::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],1)
				_aBrwPar[oBrwCpoPar:nAT,04] := "B1"
				_aBrwPar[oBrwCpoPar:nAT,05] := ::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],3)				

				aADD(oBrwCpoPar:AARRAY, {_aSelCpos[oBrwCpoFil:nAt,01],_aSelCpos[oBrwCpoFil:nAt,02] + " ate?", ::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],1),"B2",::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],3) } )

			else

				aADD(oBrwCpoPar:AARRAY, {_aSelCpos[oBrwCpoFil:nAt,01],_aSelCpos[oBrwCpoFil:nAt,02] + " de?", ::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],1),"B1",::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],3) } )
				aADD(oBrwCpoPar:AARRAY, {_aSelCpos[oBrwCpoFil:nAt,01],_aSelCpos[oBrwCpoFil:nAt,02] + " ate?", ::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],1),"B2",::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],3) } )

			endif
		else

			if Empty(_aBrwPar[oBrwCpoPar:nAt,01])

				_aBrwPar[oBrwCpoPar:nAt,01] := _aSelCpos[oBrwCpoFil:nAt,01]
				_aBrwPar[oBrwCpoPar:nAT,02] := _aSelCpos[oBrwCpoFil:nAT,02] + "?"	
				_aBrwPar[oBrwCpoPar:nAT,03] := ::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],1)
				_aBrwPar[oBrwCpoPar:nAT,04] := "U"
				_aBrwPar[oBrwCpoPar:nAT,05] := ::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],3)

			else

				aADD(oBrwCpoPar:AARRAY, {_aSelCpos[oBrwCpoFil:nAt,01],_aSelCpos[oBrwCpoFil:nAt,02] + "?", _aSelCpos[oBrwCpoPar:nAT,02] := ::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],1),"U",::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],3) } )

			endif

		endif
	else

		MsgAlert("Não é permitido criar parâmetros de filtro para campos numéricos.","[ALLSSC01_001] - Atenção")

	endif

	oBrwCpoPar:Refresh()

Return

/*/{Protheus.doc} methodName
	(long_description)
	@author Fernando Bombardi - ALLSS
	@since 05/04/2022
	@version P12.1.33
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method ExcluirParametroCampo() class ALLSSC01

	Adel(oBrwCpoPar:AARRAY,oBrwCpoPar:nAt)
	Asize(oBrwCpoPar:AARRAY,Len(oBrwCpoPar:AARRAY)-1)
	if len(oBrwCpoPar:AARRAY) <= 0
		aADD(oBrwCpoPar:AARRAY,{"","","","",""})
	endif
	oBrwCpoPar:Refresh()

Return 


/*/{Protheus.doc} CarregarTabelas
    (long_description)
    @type  Static Function
    @author Fernando Bombardi - ALLSS
    @since 22/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Method  CarregarTabelas() Class ALLSSC01

	dbSelectArea("SX2TAB")
	SX2TAB->(dbGoTop())
	SX2TAB->(dbSetOrder(1))
	while SX2TAB->(!EOF())
		aADD(_aBrwSx2,{SX2TAB->X2_CHAVE,SX2TAB->X2_NOME})
		SX2TAB->(dbSkip())
	enddo

Return


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Fernando Bombardi - ALLSS
    @since 22/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Method PesquisarTabela(_cTabelaPesquisa) Class ALLSSC01
	Local _nItTabela := 0 as numeric

	for _nItTabela := 1 to len(_aBrwSx2)
		if alltrim(_cTabelaPesquisa) == alltrim(_aBrwSx2[_nItTabela,01])
			oBrowSX2:nAt := _nItTabela
			oBrowSX2:Refresh()
		endif
	next

Return

/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 25/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method IncluirRelacionamentosTabelas() Class ALLSSC01
	Local oButton1
	Local oButton2
	Local oButton3
	Local oGet1
	Local _cTabCot := Space(3)

	Private _aBrwCont := {}
	Private _aBrwDomi := {}
	Private oBrwSX9e as object
	Private oBrwSX9p as object

	Static oDlgRel

	DEFINE MSDIALOG oDlgRel TITLE "Incluir Relacionamento entre Tabelas" FROM 000, 000  TO 500, 600 COLORS 0, 16777215 PIXEL

	::BrowserTabelaDominio()

	@ 089, 011 MSGET oGet1 VAR _cTabCot SIZE 061, 010 OF oDlgRel COLORS 0, 16777215 PIXEL

	::BrowserExpressoesContraDominio()

	@ 089, 080 BUTTON oButton1 PROMPT "&Pesquisar" SIZE 040, 010 OF oDlgRel ACTION ::PesquisarTabelaContraDominio(_cTabCot) PIXEL
	@ 232, 246 BUTTON oButton2 PROMPT "&Incluir" SIZE 046, 011 OF oDlgRel ACTION ::IncluirTabelaContraDominio() PIXEL
	@ 232, 195 BUTTON oButton3 PROMPT "&Cancelar" SIZE 046, 011 OF oDlgRel ACTION oDlgRel:End() PIXEL

	ACTIVATE MSDIALOG oDlgRel CENTERED

Return

/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 25/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method BrowserTabelaDominio() class ALLSSC01
//------------------------------------------------                                               

	_cQry := "SELECT X9_CDOM AS TABELA, X2_NOME, 'D' AS ORIGX9 "
	_cQry += "FROM "
	_cQry += "  SX9" + Alltrim(cEmpAnt) + "0 SX9 INNER JOIN SX2" + Alltrim(cEmpAnt) + "0 SX2 "
	_cQry += "            ON SX9.X9_CDOM = SX2.X2_CHAVE "
	_cQry += " 	WHERE "
	_cQry += " 		SX9.X9_DOM = '" + _cTabelaPrimaria + "' AND "
	_cQry += " 		SX9.D_E_L_E_T_ = '' AND "
	_cQry += "      SX2.D_E_L_E_T_ = '' "
	_cQry += " 	GROUP BY X9_CDOM, X2_NOME "
	_cQry += " UNION "
	_cQry += "SELECT X9_DOM AS TABELA, X2_NOME, 'C' AS ORIGX9 "
	_cQry += "FROM "
	_cQry += "  SX9" + Alltrim(cEmpAnt) + "0 SX9 INNER JOIN SX2" + Alltrim(cEmpAnt) + "0 SX2 "
	_cQry += "            ON SX9.X9_DOM = SX2.X2_CHAVE "
	_cQry += " 	WHERE "
	_cQry += " 		SX9.X9_CDOM = '" + _cTabelaPrimaria + "' AND "
	_cQry += " 		SX9.D_E_L_E_T_ = '' AND "
	_cQry += "      SX2.D_E_L_E_T_ = '' "
	_cQry += " 	GROUP BY X9_DOM, X2_NOME "
	_cQry += "	ORDER BY TABELA, X2_NOME "
	TCQUERY _cQry NEW ALIAS "SX9QRY"

	dbSelectArea("SX9QRY")
	IF SX9QRY->(!EOF())
		WHILE SX9QRY->(!EOF())
			Aadd(_aBrwDomi,{Alltrim(SX9QRY->TABELA),Alltrim(SX9QRY->X2_NOME),SX9QRY->ORIGX9})
			SX9QRY->(dbSkip())
		ENDDO

	ENDIF
	SX9QRY->(dbCloseArea())

	oBrwSX9p := TWBrowse():New( 011, 005,286,071,,;
		{'Tabela','Descricao','Tipo'},;
		{30,100,30}, oDlgRel,,,,  {|| ::BuscarExpressoesTabelaContraDominio(_aBrwDomi[oBrwSX9p:nAt,01],_aBrwDomi[oBrwSX9p:nAT,03] ) }  ,{|| /*Alert("Clique")*/ },,,,,,,.F.,,.T.,,.F.,,, )
	oBrwSX9p:SetArray(_aBrwDomi)

	// Monta a linha a ser exibina no Browse
	oBrwSX9p:bLine := {||{ _aBrwDomi[oBrwSX9p:nAt,01] ,;
		_aBrwDomi[oBrwSX9p:nAT,02],_aBrwDomi[oBrwSX9p:nAT,03] } }

Return

/*/{Protheus.doc} methodName
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 25/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method BrowserExpressoesContraDominio() class ALLSSC01
//------------------------------------------------ 

	oBrwSX9e := TWBrowse():New( 109,005,289,114,,;
		{'Expressao da tabela Dominio','Expressao da tabela Relacionada'},;
		{100,100}, oDlgRel,,,,,{|| /*Alert("Clique")*/ },,,,,,,.F.,,.T.,,.F.,,, )
	oBrwSX9e:SetArray(_aBrwCont)
	// Monta a linha a ser exibina no Browse
	oBrwSX9e:bLine := {||{ _aBrwCont[oBrwSX9e:nAt,01] ,;
		_aBrwCont[oBrwSX9e:nAT,02] } }

Return

/*/{Protheus.doc} BuscarExpressoesTabelaContraDomini
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 25/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method BuscarExpressoesTabelaContraDominio(_cTabelaContraDominio,_cTipoTab) class ALLSSC01
	Local _nItTabela := 0

	if len(oBrwSX9e:AARRAY) > 0
		for _nItTabela := 1 to len(oBrwSX9e:AARRAY)
			ADel( oBrwSX9e:AARRAY,_nItTabela )
		next
		ADel( oBrwSX9e:AARRAY, 1 )
	endif

	if _cTipoTab == 'D'
		_cQry := "SELECT X9_CDOM, X9_EXPDOM, X9_EXPCDOM "
		_cQry += "FROM "
		_cQry += "  SX9" + Alltrim(cEmpAnt) + "0 SX9 "
		_cQry += " 	WHERE "
		_cQry += " 		SX9.X9_DOM = '" + _cTabelaPrimaria + "' AND "
		_cQry += " 		SX9.X9_CDOM = '" + _cTabelaContraDominio + "' AND "
		_cQry += " 		SX9.D_E_L_E_T_ = '' "
		_cQry += " 	ORDER BY X9_CDOM "
	else
		_cQry := "SELECT X9_CDOM, X9_EXPDOM, X9_EXPCDOM "
		_cQry += "FROM "
		_cQry += "  SX9" + Alltrim(cEmpAnt) + "0 SX9 "
		_cQry += " 	WHERE "
		_cQry += " 		SX9.X9_DOM = '" + _cTabelaContraDominio  + "' AND "
		_cQry += " 		SX9.X9_CDOM = '" + _cTabelaPrimaria + "' AND "
		_cQry += " 		SX9.D_E_L_E_T_ = '' "
		_cQry += " 	ORDER BY X9_CDOM "
	endif

	TCQUERY _cQry NEW ALIAS "SX9QRY"

	dbSelectArea("SX9QRY")
	IF SX9QRY->(!EOF())
		WHILE SX9QRY->(!EOF())
			if len(oBrwSX9e:AARRAY) <= 0 .AND. len(_aBrwCont) <= 0
				Aadd(_aBrwCont,{Alltrim(SX9QRY->X9_EXPDOM),Alltrim(SX9QRY->X9_EXPCDOM)})
			else
				if len(oBrwSX9e:AARRAY) == 1 .AND. oBrwSX9e:AARRAY[1] == NIL
					oBrwSX9e:AARRAY[1] := {Alltrim(SX9QRY->X9_EXPDOM), Alltrim(SX9QRY->X9_EXPCDOM)}
				else
					Aadd(oBrwSX9e:AARRAY,{Alltrim(SX9QRY->X9_EXPDOM), Alltrim(SX9QRY->X9_EXPCDOM)})
				endif
			endif
			SX9QRY->(dbSkip())
		ENDDO
	ENDIF
	SX9QRY->(dbCloseArea())

	_cCntDel := 0
	for _nItTabela := 1 to len(oBrwSX9e:AARRAY)
		if oBrwSX9e:AARRAY[_nItTabela] == NIL
			_cCntDel += 1
		endif
	next

	if _cCntDel > 0
		ASort( oBrwSX9e:AARRAY )
		ASize( oBrwSX9e:AARRAY, (len(oBrwSX9e:AARRAY) - _cCntDel) )
	endif

	oBrwSX9e:Refresh()
	oDlgRel:Refresh()

Return

/*/{Protheus.doc} IncluirTabelaContraDominio
    (long_description)
    @author Fernando Bombardi 
    @since 28/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method IncluirTabelaContraDominio() class ALLSSC01

	if len(oBrowRel:AARRAY) == 1 .AND. EMPTY(_aBrwRel[oBrowRel:nAt,01])
		oBrowRel:AARRAY[1] := {_aBrwDomi[oBrwSX9p:nAt,01], _aBrwCont[oBrwSX9e:nAt,01],_aBrwCont[oBrwSX9e:nAt,02]}
	else
		Aadd(oBrowRel:AARRAY,{_aBrwDomi[oBrwSX9p:nAt,01], _aBrwCont[oBrwSX9e:nAt,01],_aBrwCont[oBrwSX9e:nAt,02]})
	endif

	oDlgRel:End()
	oBrowRel:Refresh()

Return


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Fernando Bombardi - ALLSS
    @since 28/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Method PesquisarTabelaContraDominio(_cTabCot) Class ALLSSC01
	Local _nItTabela := 0 as numeric

	for _nItTabela := 1 to len(_aBrwDomi)
		if alltrim(_cTabCot) == alltrim(_aBrwDomi[_nItTabela,01])
			oBrwSX9p:nAt := _nItTabela
			oBrwSX9p:Refresh()

			::BuscarExpressoesTabelaContraDominio(_aBrwDomi[oBrwSX9p:nAt,01],_aBrwDomi[oBrwSX9p:nAt,03])

		endif
	next

Return

/*/{Protheus.doc} IncluirCampoGridSelecionados
    (long_description)
    @author Fernando Bombardi - ALLSS
    @since 31/03/2022
    @version P12.1.33
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method IncluirCampoGridSelecionados() class ALLSSC01

	if len(oBrwSelCpo:AARRAY) == 1 .AND. EMPTY(_aBrwSelCpo[oBrwSelCpo:nAt,01])
		oBrwSelCpo:AARRAY[1][1] := _aBrwCpo[oBrwCpo:nAt,01]
		oBrwSelCpo:AARRAY[1][2] := _aBrwCpo[oBrwCpo:nAT,02]
	else
		Aadd(oBrwSelCpo:AARRAY, { _aBrwCpo[oBrwCpo:nAt,01], _aBrwCpo[oBrwCpo:nAT,02] } )
	endif

	oBrwSelCpo:Refresh()

Return

/*/{Protheus.doc} methodName
	(long_description)
	@author Fernando Bombardi - ALLSS
	@since 31/03/2022
	@version P12.1.33
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method IncluirTodosCamposGridSelecionados() class ALLSSC01
	Local _nItTabela := 0

	if len(oBrwSelCpo:AARRAY) > 0

		for _nItTabela := 1 to len(oBrwSelCpo:AARRAY)
			ADel( oBrwSelCpo:AARRAY,_nItTabela )
		next
		ADel( oBrwSelCpo:AARRAY, 1 )

		for _nItTabela := 1 to len(oBrwCpo:AARRAY)
			if _nItTabela == 1
				oBrwSelCpo:AARRAY[1] := { oBrwCpo:AARRAY[_nItTabela,01], oBrwCpo:AARRAY[_nItTabela,02] }
			else
				Aadd(oBrwSelCpo:AARRAY, { oBrwCpo:AARRAY[_nItTabela,01], oBrwCpo:AARRAY[_nItTabela,02] } )
			endif

		next

	endif

	oBrwSelCpo:Refresh()

Return

/*/{Protheus.doc} methodName
	(long_description)
	@author Fernando Bombardi - ALLSS
	@since 31/03/2022
	@version P12.1.33
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method RemoverTodosCamposGridSelecionados() class ALLSSC01
	Local _nItTabela := 0

	for _nItTabela := 1 to len(oBrwSelCpo:AARRAY)
		ADel( oBrwSelCpo:AARRAY,_nItTabela )
	next

	ADel( oBrwSelCpo:AARRAY, 1 )
	Asize( oBrwSelCpo:AARRAY,1)

	oBrwSelCpo:AARRAY[1] := { "", "" }

	oBrwSelCpo:Refresh()

Return

/*/{Protheus.doc} RemoverCampoGridSelecionados
	(long_description)
	@author Fernando Bombardi - ALLSS
	@since 31/03/2022
	@version P12.1.33
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method RemoverCampoGridSelecionados() class ALLSSC01

	ADel( oBrwSelCpo:AARRAY , oBrwSelCpo:nAt )
	//ASort( oBrwSelCpo:AARRAY)
	ASize( oBrwSelCpo:AARRAY, len(oBrwSelCpo:AARRAY) - 1 )

	if len(oBrwSelCpo:AARRAY) <= 0
		aADD(oBrwSelCpo:AARRAY,{ "", "" })
	endif

	oBrwSelCpo:Refresh()

Return


/*/{Protheus.doc} ValidarPaginaSelecaoCampos
	(long_description)
	@author Fernando Bombardi - ALLSS
	@since 05/04/2022
	@version P12.1.33
	/*/
Method ValidarPaginaSelecaoCampos() Class ALLSSC01

Return .T.

/*/{Protheus.doc} BuscarDadosCampoSX3
	(long_description)
	@author Fernando Bombardi - ALLSS
	@since 06/04/2022
	@version P12.1.33
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method BuscarDadosCampoSX3(_cCpo,_cDefInf) Class ALLSSC01
Local _cF3 := ""

	_cQry := "SELECT * "
	_cQry += " FROM SX3" + cEmpAnt + "0 SX3 "
	_cQry += " WHERE "
	_cQry += " X3_CAMPO = '" + _cCpo + "' AND "
	_cQry += " SX3.D_E_L_E_T_ = '' "
	_cQry += " ORDER BY X3_ARQUIVO,X3_ORDEM "
	TCQUERY _cQry NEW ALIAS "SX3QRY"

	if SX3QRY->(!EOF())
		Do Case
			Case _cDefInf == 1
				_cF3 = SX3QRY->X3_F3
			Case _cDefInf == 2
				_cF3 = SX3QRY->X3_TAMANHO
			Case _cDefInf == 3
				_cF3 = SX3QRY->X3_TIPO
		End Case			
	endif
	SX3QRY->(dbCloseArea())

Return(_cF3)

/*/{Protheus.doc} methodName
	(long_description)
	@author Fernando Bombardi - ALLSS
	@since 06/04/2022
	@version P12.1.33
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method FiltrosConsultaSQL(_aParam) class ALLSSC01
Local _aPergs  := {}
Local _nItPar  := 0
Local _dDataDe  := FirstDate(Date())
Local _dDataAt  := LastDate(Date())

for _nItPar := 1 to len(_aParam)
	Do Case
		Case _aParam[_nItPar,04] == "B1"
			aAdd(_aPergs, {1, _aParam[_nItPar,02], iif(_aParam[_nItPar,05]<>"D",CriaVar(_aParam[_nItPar,01]),_dDataDe),  "",             ".T.",        _aParam[_nItPar,03], ".T.", iif(_aParam[_nItPar,05]<>"D",::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],2),60),  .F.})
		Case _aParam[_nItPar,04] == "B2"
			aAdd(_aPergs, {1, _aParam[_nItPar,02], iif(_aParam[_nItPar,05]<>"D",CriaVar(_aParam[_nItPar,01]),_dDataAt),  "",             ".T.",        _aParam[_nItPar,03], ".T.", iif(_aParam[_nItPar,05]<>"D",::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],2),60),  .F.})
		Otherwise
			aAdd(_aPergs, {1, _aParam[_nItPar,02], iif(_aParam[_nItPar,05]<>"D",CriaVar(_aParam[_nItPar,01]),dDataBase),  "",             ".T.",        _aParam[_nItPar,03], ".T.", iif(_aParam[_nItPar,05]<>"D",::BuscarDadosCampoSX3(_aSelCpos[oBrwCpoFil:nAt,01],2),60),  .F.})
	End Case
next

If ParamBox(_aPergs, "Informe os parâmetros")
    ::MontarQuerySQL(oBrowRel:AARRAY,oBrwSelCpo:AARRAY,oBrwCpoPar:AARRAY)
EndIf

Return 

/*/{Protheus.doc} GerarPlanilhaExcel
	ng_description)
	
	@since 06/04/2022
	@version P12.1.33
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method GerarPlanilhaExcel(_aCampos) Class ALLSSC01
Local aArea       := GetArea()
Local oFWMsExcel
Local oExcel
Local cArquivo    := GetTempPath()+"rel_wizard_"+DTOS(dDataBase)+".xml"
Local _nItCpos    := 0
     
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 02 - Produtos
    oFWMsExcel:AddworkSheet("Dados Exportados")
        //Criando a Tabela
	
		//{'Sequencia','Contrato','Placa','Cliente','Loja','Descricao','Usuario','Data','Hora','Funcao','Filial Orig.','Ambiente','Tabela','Operacao'},;
		oFWMsExcel:AddTable("Dados Exportados","Dados")

		_cArrayCpo := "{"
		for _nItCpos := 1 to len(_aCampos)
        	oFWMsExcel:AddColumn("Dados Exportados","Dados", _aCampos[_nItCpos,02],1)
			if _nItCpos == 1
				if ::BuscarDadosCampoSX3(Alltrim(_aCampos[_nItCpos,01]),3) == "D"
					_cArrayCpo += "DTOC(STOD(QRYREL->" + _aCampos[_nItCpos,01] + "))"
				else
					_cArrayCpo += "QRYREL->" + _aCampos[_nItCpos,01]
				endif
			else
				if ::BuscarDadosCampoSX3(Alltrim(_aCampos[_nItCpos,01]),3) == "D"
					_cArrayCpo += ",DTOC(STOD(QRYREL->" + _aCampos[_nItCpos,01] + "))"
				else
					_cArrayCpo += ",QRYREL->" + _aCampos[_nItCpos,01]
				endif
			endif
		next
		_cArrayCpo += "}"
		
        //Criando as Linhas... Enquanto não for fim da query
        While QRYREL->(!EOF())
			oFWMsExcel:AddRow("Dados Exportados","Dados",&(_cArrayCpo))
			QRYREL->(dbSkip())
        Enddo
     
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
RestArea(aArea)
Return

/*/{Protheus.doc} MontarQuerySQL
	(long_description)
	@author Fernando Bombardi - ALLSS
	@since 06/04/2022
	@version P12.1.33
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method MontarQuerySQL(_aJoin,_aCampos,_aParam) class ALLSSC01
Local _cCampos := ""
Local _cJoin   := ""
Local _cParam  := ""
Local _nItJoin := 0
Local _nItCpos := 0
Local _nItParm := 0

if len(_aJoin) > 0 .and. !Empty(_aJoin[01,01])
	for _nItJoin := 1 to len(_aJoin)
		if _nItJoin == 1
			_cJoin += " FROM " + RetSqlName(_cTabelaPrimaria) + " " + _cTabelaPrimaria
			_cJoin += " LEFT JOIN " + RetSqlName(_aJoin[_nItJoin,01]) + " " + _aJoin[_nItJoin,01]  + " ON " + _aJoin[_nItJoin,02] + " = " + _aJoin[_nItJoin,03]	+ " AND " +	_aJoin[_nItJoin,01] + ".D_E_L_E_T_ = ''"		
		else
			_cJoin += " LEFT JOIN " + RetSqlName(_aJoin[_nItJoin,01]) + " " + _aJoin[_nItJoin,01]  + " ON " + _aJoin[_nItJoin,02] + " = " + _aJoin[_nItJoin,03]	+ " AND " +	_aJoin[_nItJoin,01] + ".D_E_L_E_T_ = ''"
		endif
	next
else
	_cJoin += " FROM " + RetSqlName(_cTabelaPrimaria) + " " + _cTabelaPrimaria	
endif

for _nItCpos := 1 to len(_aCampos)
	if _nItCpos == 1
		if ::BuscarDadosCampoSX3(Alltrim(_aCampos[_nItCpos,01]),3) == "M"
			_cCampos += "ISNULL(CAST(CAST(" + Alltrim(_aCampos[_nItCpos,01]) + " AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS " + Alltrim(_aCampos[_nItCpos,01])
		else
			_cCampos += Alltrim(_aCampos[_nItCpos,01])
		endif
	else
		if ::BuscarDadosCampoSX3(Alltrim(_aCampos[_nItCpos,01]),3) == "M"
			_cCampos += ",ISNULL(CAST(CAST(" + Alltrim(_aCampos[_nItCpos,01]) + " AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS " + Alltrim(_aCampos[_nItCpos,01])
		else
			_cCampos += "," + Alltrim(_aCampos[_nItCpos,01])
		endif
	endif
next

for _nItParm := 1 to len(_aParam)
	Do Case
		Case Alltrim(_aParam[_nItParm,4]) = "B1"
			if Alltrim(_aParam[_nItParm,5]) <> "D"
				_cParam += _aParam[_nItParm,01] + " BETWEEN '" + &("MV_PAR"+StrZero(_nItParm,2)) + "' "
			else
				_cParam += _aParam[_nItParm,01] + " BETWEEN '" + DTOS(&("MV_PAR"+StrZero(_nItParm,2))) + "' "
			endif
		Case Alltrim(_aParam[_nItParm,4]) = "B2"
			if Alltrim(_aParam[_nItParm,5]) <> "D"
				_cParam += " AND '" + &("MV_PAR"+StrZero(_nItParm,2)) + "' AND "
			else
				_cParam += " AND '" + DTOS(&("MV_PAR"+StrZero(_nItParm,2))) + "' AND "				
			endif
		Case Alltrim(_aParam[_nItParm,4]) = "U"
			if Alltrim(_aParam[_nItParm,5]) <> "D"
				_cParam += _aParam[_nItParm,01] + " = '" + &("MV_PAR"+StrZero(_nItParm,2)) + "' AND "
			else
				_cParam += _aParam[_nItParm,01] + " = '" + DTOS(&("MV_PAR"+StrZero(_nItParm,2))) + "' AND "
			endif
	End Case
next

_cQry := " SELECT " 
_cQry += _cCampos 
_cQry += _cJoin 
_cQry += " WHERE "
_cQry += _cParam
_cQry += _cTabelaPrimaria + ".D_E_L_E_T_ = ''"
TCQUERY _cQry NEW ALIAS "QRYREL"

if QRYREL->(!EOF())
	MsgRun("Gerando relatório em Excel..." ,"Aguarde" ,{|| ::GerarPlanilhaExcel(_aCampos) })
endif
QRYREL->(dbSkip())

Return 
