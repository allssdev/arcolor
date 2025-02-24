#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} User Function nomeFunction
    Rotina específica para exportações de dados para Excel.
    @type  Function
    @author Fernando Bombardi - ALLSS
    @since 21/03/2022
    @version P12.1.33
    /*/
User Function ALLSSA01()
    //Local oPanel
    Local oNewPag
    
    Local oStepWiz   := nil as object
    Local oDlg       := nil as object
    Local oPanelBkg  := nil as object

    //Variaveis Pagina 1
    Private _aBrwSx2         := {}  as array
    Private oBrowSX2         := nil as object
    Private _cTabelaPrimaria := ""  as character
    Private _cPesquisarSx2   := ""  as character
    
    //Variveis Pagina 2
    Private _aBrwRel := {}  as array
    Private oBrowRel := nil as object

    //Variveis Pagina 3
    Private _aBrwCpo    := {}  as array
    Private oBrwCpo     := nil as object
    Private _aBrwSelCpo := {}  as array
    Private oBrwSelCpo  := nil as object

    //Variveis Pagina 4
    Private _aSelCpos  := {}
    Private oBrwCpoFil := nil
    Private _aBrwPar   := {}
    Private oBrwCpoPar := nil
    Private _cCombo1   := ""

    Private oALLSSC01 := ALLSSC01():New()

	//+--------------------------------------------------------------+
	// Carrega _aHeader
	//+--------------------------------------------------------------+	
	OpenSxs(,,,,,"SX3DIC","SX3",,.F.)
    OpenSxs(,,,,,"SX2TAB","SX2",,.F.)


    //Para que a tela da classe FWWizardControl fique no layout com bordas arredondadas
    //iremos fazer com que a janela do Dialog oculte as bordas e a barra de titulo
    //para isso usaremos os estilos WS_VISIBLE e WS_POPUP
    DEFINE DIALOG oDlg TITLE 'Exportação de tabelas Protheus' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
    oDlg:nWidth := 800
    oDlg:nHeight := 620

    oPanelBkg:= tPanel():New(0,0,"",oDlg,,,,,,400,400)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT

    //Instancia a classe FWWizard
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
    
    //----------------------
    // Pagina 1
    //----------------------
    oNewPag := oStepWiz:AddStep("1")
    //Altera a descrição do step
    oNewPag:SetStepDescription("Tabela Principal")
    //Define o bloco de construção
    oNewPag:SetConstruction({|Panel| oALLSSC01:CriarPaginaTabelaPrincipal(Panel, @_aBrwSx2, @oBrowSX2, @_cPesquisarSx2) })
    //Define o bloco ao clicar no botão Próximo
    oNewPag:SetNextAction({|| oALLSSC01:ValidarPaginaTabelaPrincipal(@_cTabelaPrimaria,@oBrowSX2) })
    //Define o bloco ao clicar no botão Cancelar
    oNewPag:SetCancelAction({|| oDlg:End() })
    
    //----------------------
    // Pagina 2
    //----------------------
    oNewPag := oStepWiz:AddStep("2", {|Panel| oALLSSC01:CriarPaginaRelacionamento(Panel, @_aBrwRel, @oBrowRel, @_cTabelaPrimaria) })
    oNewPag:SetStepDescription("Relacionamento entre tabelas")
    oNewPag:SetNextAction({|| oALLSSC01:ValidarPaginaRelacionamentoTabelas()})

    //Define o bloco ao clicar no botão Voltar
    oNewPag:SetCancelAction({|| .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .F.})
    oNewPag:SetPrevTitle("Voltar")
    
    //----------------------
    // Pagina 3
    //----------------------
    oNewPag := oStepWiz:AddStep("3", {|Panel| oALLSSC01:CriarPaginaSelecaoCampos(Panel)})
    oNewPag:SetStepDescription("Seleção de Campos")
    oNewPag:SetNextAction({|| oALLSSC01:ValidarPaginaSelecaoCampos()})
    oNewPag:SetCancelAction({|| .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .F.})
    //oNewPag:SetPrevTitle("Voltar")

    //----------------------
    // Pagina 4
    //----------------------
    oNewPag := oStepWiz:AddStep("4", {|Panel| oALLSSC01:CriarPaginaFiltros(Panel) })
    oNewPag:SetStepDescription("Filtros")
    oNewPag:SetNextAction({|| oALLSSC01:FiltrosConsultaSQL(oBrwCpoPar:AARRAY), .T., oDlg:End()})
    oNewPag:SetCancelAction({|| .T., oDlg:End()})
    oNewPag:SetCancelWhen({|| .T. })
    oNewPag:SetPrevAction({|| .F. })
    //oNewPag:SetPrevTitle("Voltar")

    oStepWiz:Activate()

    ACTIVATE DIALOG oDlg CENTER
    oStepWiz:Destroy()
Return

