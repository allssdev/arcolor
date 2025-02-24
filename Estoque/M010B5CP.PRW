#Include 'Protheus.ch'
#include 'FWMVCDef.ch'

/*/{Protheus.doc} M010B5CP
@description RPonto de Entrada que permite limpar o conteúdo dos campos de complemento de produto(SB5) quando executada a função de cópia de produto para o cadastro de produtos que atualiza o complemento.
@author  Diego Rodrigues
@since   15/12/2022
@version P12.1.2210 - 1.00
@see https://allss.com.br
/*/
User Function M010B5CP()
Local lRet      := .T.
Local oModel    := Nil
Local nOpcx     := 0
Local lCopy     := .F.
Local lIsMvc    := ( Type( 'ParamIXB' ) == 'A' )
 
If lIsMvc
    oModel  := ParamIXB[ 1 ]
    nOpcx   := ParamIXB[ 2 ]
    lCopy   := ParamIXB[ 3 ]
     
    //oModel:LoadValue( 'B5_XDESCET',"" )
    oModel:LoadValue( 'B5_XCORETQ', "" )
    //oModel:LoadValue( 'B5_XMODETQ', "" )
    
EndIf

If M->B1_TIPO == "PA"
MsgInfo("Revisar as informacoes referente as etiquetas na aba ACD do complemento do produto.",;
"Favor verificar os campos 'Desc Etiqueta', 'Cor Etiqueta', 'Mod Etiqueta'","ATENCAO")
Endif

Return lRet

/*
#Include 'Protheus.ch'
 
User Function M010B5CP()
Local lRet      := .T.

    M->B5_XDESCET   := ""
    M->B5_XCORETQ   := ""
    M->B5_XMODETQ   := ""
   
Return lRet
*/
