//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Topconn.ch"
  
//Variáveis Estáticas
Static cTitulo := "Embalagens Recicláveis"

  /*/{Protheus.doc} User Function nomeFunction
      Rotina para definição se a embalagem é reciclada.
      @type  Function
      @author Fernando Bombardi - ALLSS
      @since 02/06/2022
      @version P12.1.33
      /*/
User Function RPCPA007()
    Local aArea      := GetArea()

    Private aCpoInfo := {}
    Private aCampos  := {}
    Private aCpoData := {}
    Private oTable   := Nil

    Private oBrowse
    Private _oRPCPC001 := RPCPC001():NEW()

    FwMsgRun(,{ || fLoadData() }, cTitulo, 'Carregando dados...')

    oMarkBrow := FwMarkBrowse():New()
    oMarkBrow:SetAlias('TRB')
    oMarkBrow:SetTemporary()
    oMarkBrow:SetColumns(aCampos)
    oMarkBrow:SetDescription(cTitulo)
    oMarkBrow:Activate()

    If(Type('oTable') <> 'U')

        oTable:Delete()
        oTable := Nil

    Endif

    RestArea(aArea)

Return Nil
 
Static Function MenuDef()
Local aRot := {}

    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION '_oRPCPC001:FormularioComponente(1,TRB->TRB_COD)' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Alterar'    ACTION '_oRPCPC001:FormularioComponente(4,TRB->TRB_COD)' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Pesquisar'  ACTION 'U_RPCPA07P()'                                    OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3    

Return aRot

Static Function fLoadData
Local nI        := 0

    If(Type('oTable') <> 'U')

        oTable:Delete()
        oTable := Nil

    Endif

    oTable     := FwTemporaryTable():New('TRB')

    aCampos     := {}
    aCpoInfo := {}
    aCpoData := {}

    aAdd(aCpoInfo, {'Produto'           , '@!'                         , 1})
    aAdd(aCpoInfo, {'Descricao'         , '@!'                         , 1})
    aAdd(aCpoInfo, {'Componente'        , '@!'                         , 1})
    aAdd(aCpoInfo, {'Descricao'         , '@!'                         , 1})
    aAdd(aCpoInfo, {'Emb. Rec.?'        , '@!'                         , 1})

    aAdd(aCpoData, {'TRB_COD'   , TamSx3('G1_COD')[3]    , TamSx3('G1_COD')[1]    , 0})
    aAdd(aCpoData, {'TRB_DESC'  , TamSx3('B1_DESC')[3]   , TamSx3('B1_DESC')[1]   , 0})
    aAdd(aCpoData, {'TRB_COMP'  , TamSx3('G1_COMP')[3]   , TamSx3('G1_COMP')[1]   , 0})
    aAdd(aCpoData, {'TRB_DESC2' , TamSx3('B1_DESC')[3]   , TamSx3('B1_DESC')[1]   , 0})
    aAdd(aCpoData, {'TRB_EMBREC', TamSx3('G1_XEMBREC')[3], TamSx3('G1_XEMBREC')[1], 0})    

    For nI := 1 To Len(aCpoData)

        aAdd(aCampos, FwBrwColumn():New())

        aCampos[Len(aCampos)]:SetData( &('{||' + aCpoData[nI,1] + '}') )
        aCampos[Len(aCampos)]:SetTitle(aCpoInfo[nI,1])
        aCampos[Len(aCampos)]:SetPicture(aCpoInfo[nI,2])
        aCampos[Len(aCampos)]:SetSize(aCpoData[nI,3])
        aCampos[Len(aCampos)]:SetDecimal(aCpoData[nI,4])
        aCampos[Len(aCampos)]:SetAlign(aCpoInfo[nI,3])

    Next nI    

    oTable:SetFields(aCpoData)

    //Cria índice com colunas setadas anteriormente
    oTable:AddIndex("PRODUTO"   , {"TRB_COD"}  )
    oTable:AddIndex("COMPONENTE", {"TRB_COMP"} )
    oTable:AddIndex("PRODCOMPO" , {"TRB_COD","TRB_COMP"} )

    oTable:Create()

    _cQry := "SELECT G1_COD, "
    _cQry += "(SELECT B1_DESC FROM " + RetSqlName("SB1") +" PRD WHERE PRD.B1_COD = SG1.G1_COD AND PRD.D_E_L_E_T_ = '') AS B1_DESC2, "
    _cQry += "G1_COMP, "
    _cQry += "B1_DESC, "
    _cQry += "G1_XEMBREC "
    _cQry += "FROM " + RetSqlName("SG1") + " SG1 INNER JOIN " + RetSqlName("SB1") +" SB1 "
    _cQry += "ON SG1.G1_COMP = SB1.B1_COD "  
    _cQry += "WHERE "
    _cQry += "SG1.G1_FILIAL = '" + xFilial("SG1") + "'""
    _cQry += "AND SG1.D_E_L_E_T_ = '' "
    _cQry += "AND SB1.B1_TIPO = 'EM' "
    _cQry += "AND SB1.D_E_L_E_T_ = '' "
    _cQry += "ORDER BY G1_COD, G1_COMP "
    TCQUERY _cQry NEW ALIAS "TMPSG1"

    DbSelectArea('TRB')

    While(!TMPSG1->(EoF()))

        RecLock('TRB', .T.)

            TRB->TRB_COD    := TMPSG1->G1_COD
            TRB->TRB_DESC   := TMPSG1->B1_DESC2
            TRB->TRB_COMP   := TMPSG1->G1_COMP
            TRB->TRB_DESC2  := TMPSG1->B1_DESC
            TRB->TRB_EMBREC := TMPSG1->G1_XEMBREC

        TRB->(MsUnlock())

        TMPSG1->(DbSkip())

    EndDo

    TRB->(DbGoTop())

    TMPSG1->(DbCloseArea())

Return
/*/{Protheus.doc} RPCPA07L
    Funcao para definir os dados da pesquisa.
    @type  function
    @author Fernando Bombardi - ALSS
    @since 06/06/2022
    @version P12.1.33
/*/
User Function RPCPA07P()
	Local _cDADOPESQ := CriaVar("CN9_NUMERO",.F.)
	Private oDlgPesq

	oDlgPesq := TDialog():New(00, 000, 130, 430,"Pesquisa",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	aItems:= {'PRODUTO','COMPONENTE'}
	_cTIPO:= aItems[1]
    oTIPO := TComboBox():New(10,20,{|u|if(PCount()>0,_cTIPO:=u,_cTIPO)},;
    aItems,075,15,oDlgPesq,,{|| oPESQDADO:Refresh() };
    ,,,,.T.,,,,,,,,,'_cTIPO')

	oPESQDADO := TGet():Create(oDlgPesq,{|u| If(Pcount()>0,_cDADOPESQ:=u,_cDADOPESQ)},030, 020,150,011,,{|x| .T. },,,,,,.T.,,,,,,,,,,"_cDADOPESQ",,,,,,,/*descricao*/,1 )

	oBtnPesquisar := TButton():New(028, 175,"Pesquisar"	,oDlgPesq,;
	{|| RPCPA07L(_cDADOPESQ,_cTIPO) },;
	30,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	oBtnCancelar := TButton():New(060, 175,"Cancelar"	,oDlgPesq,;
	{|| oDlgPesq:End() },;
	30,15,,,.F.,.T.,.F.,,.F.,,,.F. )    

	oDlgPesq:Activate(,,,.T.,{|| .T.},,{|| .T. } )

Return

/*/{Protheus.doc} RPCPA07L
    Funcao para localizar dados na pesquisa.
    @type  function
    @author Fernando Bombardi - ALSS
    @since 06/06/2022
    @version P12.1.33
/*/
Static Function RPCPA07L(_cDADOPESQ,_cTIPO)

    dbSelectArea("TRB")
    TRB->(dbGoTop())
    Do Case
        Case alltrim(_cTIPO) == "PRODUTO"
            TRB->(dbSetOrder(1))
            dbSeek(Alltrim(_cDADOPESQ))
            oMarkBrow:Refresh()
            oDlgPesq:End()
        Case alltrim(_cTIPO) == "COMPONENTE"
            TRB->(dbSetOrder(2))
            dbSeek(Alltrim(_cDADOPESQ))
            oDlgPesq:End()
            oMarkBrow:Refresh()
    End Case

Return
