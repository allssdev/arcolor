#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} RPCPE017
@description Rotina responsável por bloquear o usuários no cadastro de usuários versus operações(TABELA ZZB)
@author  Diego Rodrigues
@since   24/02/2025
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/

User Function RPCPE017()

Local _aSavArea := GetArea()
Local _aSavZZB  := ZZB->(GetArea())
Local _cRotina := "RPCPE017"
Local oGetv1
Local oGroupv1
Local oSayv1
Local oSButtonv1
Local oSButtonv2

Private _cUsuario  := ZZB_USRNOM


static oDlgv

  DEFINE MSDIALOG oDlgv TITLE "Bloqueio de Usuário"          FROM 000, 000 TO 130, 240                     COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

    @ 007, 003 GROUP   oGroupv1 TO 058, 116 PROMPT "Informe o usuário para Bloqueio" OF oDlgv              COLOR  0, 16777215 PIXEL
    @ 021, 005   SAY   oSayv1 				PROMPT "Usuário:"   SIZE 037, 007 OF oDlgv                     COLORS 0, 16777215 PIXEL
    @ 019, 045 MSGET   oGetv1   VAR _cUsuario SIZE 070, 010 OF oDlgv PICTURE PesqPict("ZZB","ZZB_USRNOM")  VALID NAOVAZIO()  COLORS 0, 16777215 PIXEL

	    DEFINE SBUTTON oSButtonv1 FROM 040, 025 TYPE 01 OF oDlgv ENABLE Action EVAL({|| _lRet := .T., oDlgv:End()})
	    DEFINE SBUTTON oSButtonv2 FROM 040, 070 TYPE 02 OF oDlgv ENABLE Action EVAL({|| _lRet := .F., oDlgv:End()})

  ACTIVATE MSDIALOG oDlgv CENTERED
  


    If !Empty(_cUsuario) .and. _lRet 
        If MsgYesNo("Deseja realmente Bloquear todos os cadastros do usuário "+_cUsuario+" ?",_cRotina+"_001")
            cQry := " UPDATE "+RetSQLName("ZZB")
            cQry += " SET ZZB_ATIVO = '2' "
            cQry += " FROM ZZB010 ZZB (NOLOCK) "
            cQry += " WHERE ZZB.D_E_L_E_T_ = '' "
            cQry += " AND ZZB_FILIAL = '"+xFilial("ZZB")+"'"
            cQry += " AND ZZB_USRNOM = '"+_cUsuario+"'"
        EndIf
        if TCSQLExec(cQry) < 0
            MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_001")
        Else
             MsgInfo("Os cadastros do usuário "+_cUsuario+" foram bloqueados com sucesso.",_cRotina+"_002")
        EndIf
    Else
        MsgInfo("O campo de usuário está em branco. Bloqueio não concluido.",_cRotina+"_003")
    EndIf


RestArea(_aSavZZB)
RestArea(_aSavArea)

Return
