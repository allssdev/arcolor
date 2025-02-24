#include 'totvs.ch'
#include 'protheus.ch'
#include 'rptdef.ch'

/*/{Protheus.doc} ACDA30VP
O objetivo deste ponto de entrada é permitir ao usuário incluir validações particulares referente a esta tabela na geração do mestrede inventário quando o mesmo é por produto. Valido apenas para geração automática do mestre de inventário.
@author Diego Rodrigues Pereira
@since 06/06/2023
@version 1.0
@type function
@see https://allss.com.br
@history 06/06/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Ponto de entrada para filtrar o tipo de produto e produtos com saldo na geração do mestre de inventário
@history 15/02/2024, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação do fonte para inserir box de pergunta para qual tipo será gerado.
/*/

User Function ACDA30VP()

Local lRet      := .F.
//Local _cTipprd  := Space(2)
//Local oDlg1	    := Nil
//Local oTipo     := Nil
Local _cTipprd := SuperGetMV("MV_XTIPINV",,"PI")

    /*DEFINE MSDIALOG oDlg1 TITLE "Informe o Tipo de Produto" FROM 000,000 TO 150,550 PIXEL
    @040,015 SAY "Informe o Tipo de Produto:  " PIXEL
    @040,120 MSGET oTipo VAR _cTipprd SIZE 050,08 OF oDlg1 PICTURE "@!" PIXEL 
    @058,120 BUTTON "Ok" SIZE 40,10 PIXEL ACTION (oDlg1:End())
    ACTIVATE DIALOG oDlg1 CENTERED*/

    dbSelectArea("SB2") 
    SB2->(DbSetOrder(1))
    SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"01"))
    nSaldo := SaldoSB2()
    // Customizações do usuário
    If SB1->B1_TIPO = Alltrim(_cTipprd) .and. nSaldo > 0 .and. SB1->B1_MSBLQL <> '1'
        lRet:= .T.
    EndIf

Return (lRet)
