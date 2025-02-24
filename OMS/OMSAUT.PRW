#include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MSMGADD.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "XMLXFUN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} OMSAUT

@author Livia Della Corte
@since 09/01/2020
@version 1.0

/*/
User Function OMSAUT()
Local	oBrw		:=	FWmBrowse():New()

    oBrw:SetDescription("Inclusao de Carga") //Cadastro de Consolidação do E-Social                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
    oBrw:SetAlias('DAK')
    oBrw:SetMenuDef( 'OMSAUT' )
    oBrw:Activate()


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Livia Della Corte
@since 09/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()


Local aRotina := {}

aAdd( aRotina, { 'Visualizar', 'VIEWDEF.OMSAUT', 0, 2, 0, NIL } ) 
aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.OMSAUT', 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.OMSAUT', 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.OMSAUT', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir'  , 'VIEWDEF.OMSAUT', 0, 8, 0, NIL } )

Return aRotina

Return FWMVCMenu( "OMSAUT" )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author Livia Della Corte
@since 09/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT93 	:= 	FWFormStruct( 1, 'DAK' )
Local oStruT94 	:= 	FWFormStruct( 1, 'DAI' )

Local oModel 	:= 	MPFormModel():New( 'OMSAUT' )

oModel:AddFields('MODEL_DAK',, oStruT93)
                                         
oModel:AddGrid('MODEL_DAI', 'MODEL_DAK', oStruT94)             
oModel:GetModel( 'MODEL_DAI' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_DAI' ):SetUniqueLine({'DAI_NODE'}) 
oModel:SetRelation( 'MODEL_DAI' , { { 'DAI_FILIAL' , 'xFilial( "DAI" )' } , { 'DAI_COD' , 'DAK_COD' } } , T94->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_DAI" ):SetPrimaryKey( { "DAI_COD" } )                                                                                                                                  

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Livia Della Corte
@since 09/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 		:= 	FWLoadModel( 'OMSAUT' )
Local oStruT93 	:= 	FWFormStruct( 2, 'DAK' )
Local oStruT94	:= 	FWFormStruct( 2, 'DAI' )
Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_DAK', oStruT93, 'MODEL_DAK' )
oView:EnableTitleView( 'VIEW_DAK', "Carga" ) 
                                             
oView:AddGrid ( 'VIEW_DAI', oStruT94, 'MODEL_DAI' )
oView:EnableTitleView( 'VIEW_DAI', "Itens da Carga")

oView:CreateHorizontalBox( 'FIELDSDAK', 20 )
oView:CreateHorizontalBox( 'GRIDDAI', 80)

oView:SetOwnerView( 'VIEW_DAK', 'FIELDSDAK' )
oView:SetOwnerView( 'VIEW_DAI', 'GRIDDAI' )

Return oView

