#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

/*/{Protheus.doc} User Function nomeFunction
    Rotina especifica para gravação da amarrção do Produto x Fornecedor
    @type  Function
    @author Fernando Bombardi   
    @since 08/12/2023
    /*/
User Function RCOMA005(_cCodPrd,cA120Forn,cA120Loj)
Local nOpc := 3
Local oModel := Nil

    oModel := FWLoadModel('MATA061')
    oModel:SetOperation(nOpc)
    oModel:Activate()

        //Cabeçalho
        oModel:SetValue('MdFieldSA5','A5_PRODUTO',_cCodPrd)
        oModel:SetValue('MdFieldSA5','A5_NOMPROD', Posicione("SB1",1,FWXFilial("SB1")+_cCodPrd,"B1_DESC"))

        //Grid
        oModel:SetValue('MdGridSA5','A5_FORNECE',cA120Forn  )
        oModel:SetValue('MdGridSA5','A5_LOJA'   ,cA120Loj   )
        oModel:SetValue('MdGridSA5','A5_NOTA'   ,5          )
        oModel:SetValue('MdGridSA5','A5_SITU' ,"A"          )
        oModel:SetValue('MdGridSA5','A5_SKPLOT' ,"01"       )
        oModel:SetValue('MdGridSA5','A5_TEMPLIM' ,1         )
        oModel:SetValue('MdGridSA5','A5_FABREV' ,"1"        )
        oModel:SetValue('MdGridSA5','A5_TIPATU' ,"2"        )
        

    If oModel:VldData()
        oModel:CommitData()
    Endif

    oModel:DeActivate()
    oModel:Destroy()

Return 
