#include "protheus.ch"

/*/{Protheus.doc} User Function MA651FIL
    LOCALIZAÇÃO : Function A651Filtra - Função responsável por filtrar a tabela de Ordens de Produção, antes da execução do Browse.
    DESCRIÇÃO : Filtra ordens de produção após o filtro padrão.
    @type  Function
    @author Diego Rodrigues
    @since 01/07/2024
    @version 1.0
/*/

User Function MA651FIL()

Local cFiltro := ParamIXB[1] //Filtro Padrão ( cFirmaCond )
Local _cUsrProd := SuperGetMV("MV_XUSRPROD",,"000000")
Local _cProduto := "      "
Local oGetv1
Local oGroupv1
Local oSayv1
Local oSButtonv1
Local oSButtonv2

If !__cUserId$_cUsrProd
  static oDlgv

  DEFINE MSDIALOG oDlgv TITLE "Informe o Produto para produzir"          FROM 000, 000 TO 130, 240         COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

    @ 007, 003 GROUP oGroupv1 TO 058, 116 PROMPT " Informe o Produto para produzir"   OF oDlgv                COLOR  0, 16777215 PIXEL
    @ 021, 005   SAY   oSayv1 PROMPT "Cod. Produto"     SIZE 037, 007                 OF oDlgv                COLORS 0, 16777215 PIXEL
    @ 019, 045 MSGET   oGetv1    VAR _cProduto          SIZE 070, 010                 OF oDlgv PICTURE "@!"   COLORS 0, 16777215 PIXEL
	 
	DEFINE SBUTTON oSButtonv1 FROM 039, 048 TYPE 1 ACTION (oDlgv:End())  ENABLE OF oDlgv
	DEFINE SBUTTON oSButtonv2 FROM 039,074 TYPE 2 ACTION ( oDlgv:End())  ENABLE OF oDlgv

  ACTIVATE MSDIALOG oDlgv CENTERED

  If !Empty(_cProduto)
  cFiltro += " .And. C2_PRODUTO = '"+_cProduto+"' "
  EndIF
EndIf

cFiltro += " .And. SUBSTRING(C2_NUM,1,1) <> 'Z'"


Return( cFiltro )
