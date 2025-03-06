#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} RPCPE018
@description Rotina responsável por bloquear o usuários no cadastro de usuários versus operações(TABELA ZZB)
@author  Diego Rodrigues
@since   24/02/2025
@version P12.1.25 - 1.00
@see https://allss.com.br
/*/

User Function RPCPE018()

Local _aSavArea     := GetArea()
Local _aSavZZB      := ZZB->(GetArea())
Local _cRotina      := "RPCPE018"
Local aRegistros    := {}
Local nI            := 0
Local _cAliasZZB    := GetNextAlias()
Local oGetv1
Local oGroupv1
Local oSayv1
Local oSButtonv1
Local oSButtonv2

Private _cUsuaOri   := ZZB_USRNOM
Private _cUsuaNew   := "      " 



static oDlgv

  DEFINE MSDIALOG oDlgv TITLE "Bloqueio de Usuário"          FROM 000, 000 TO 150, 340                     COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

    @ 007, 003 GROUP   oGroupv1 TO 078, 172 PROMPT "Informe o usuário para Copia" OF oDlgv              COLOR  0, 16777215 PIXEL
    @ 021, 005   SAY   oSayv1 				PROMPT "Do Usuário:"   SIZE 037, 007 OF oDlgv                     COLORS 0, 16777215 PIXEL
    @ 019, 045 MSGET   oGetv1   VAR _cUsuaOri SIZE 070, 010 OF oDlgv PICTURE PesqPict("ZZB","ZZB_USRNOM")  VALID NAOVAZIO()  COLORS 0, 16777215 PIXEL
    @ 040, 005   SAY   oSayv1 			PROMPT "Para Usuário:"   SIZE 037, 007 OF oDlgv                     COLORS 0, 16777215 PIXEL
    @ 039, 045 MSGET   oGetv1   VAR _cUsuaNew  SIZE 070, 010 OF oDlgv PICTURE PesqPict("ZZB","ZZB_USRNOM")  VALID NAOVAZIO()  COLORS 0, 16777215 PIXEL

	    DEFINE SBUTTON oSButtonv1 FROM 060, 025 TYPE 01 OF oDlgv ENABLE Action EVAL({|| _lRet := .T., oDlgv:End()})
	    DEFINE SBUTTON oSButtonv2 FROM 060, 070 TYPE 02 OF oDlgv ENABLE Action EVAL({|| _lRet := .F., oDlgv:End()})

  ACTIVATE MSDIALOG oDlgv CENTERED
  

    If !Empty(_cUsuaOri) .and. !Empty(_cUsuaNew) .and. _lRet 
        If MsgYesNo("Deseja realmente Copiar todo o cadastro do usuário "+_cUsuaOri+" ?",_cRotina+"_001")
            // Busca registros vinculados ao usuÃ¡rio de origem
            aRegistros := {}
            if Select(_cAliasZZB) > 0
			    (_cAliasZZB)->(dbCloseArea())
		    endif
            BEGINSQL ALIAS _cAliasZZB
                %noparser%
                SELECT  ZZB_CODOPE
                        ,ZZB_CODUSR
                        ,ZZB_USRNOM
                        ,ZZB_NOMUSR
                        ,ZZB_OPERAC
                        ,ZZB_PRODUT
                        ,ZZB_CCUSTO
                        ,ZZB_ATIVO 
						,ISNULL(USR_ID,'') ID_USER
						,ISNULL(USR_CODIGO,'') COD_USER
						,ISNULL(USR_NOME,'') NOM_USER
                FROM %table:ZZB% ZZB (NOLOCK)
                LEFT JOIN SYS_USR USR (NOLOCK) ON USR.%notDel% AND USR_CODIGO = %exp:_cUsuaNew%
                WHERE ZZB.%notDel%
                AND ZZB_USRNOM = %exp:_cUsuaOri%
                ORDER BY ZZB_OPERAC, ZZB_PRODUT
            ENDSQL

            (_cAliasZZB)->(DbGoTop()) 
            While !EOF() 
                AAdd(aRegistros, {  (_cAliasZZB)->COD_USER,;
                                    (_cAliasZZB)->ID_USER,;
                                    (_cAliasZZB)->COD_USER,;
                                    (_cAliasZZB)->NOM_USER,;
                                    (_cAliasZZB)->ZZB_OPERAC,;
                                    (_cAliasZZB)->ZZB_PRODUT,;
                                    (_cAliasZZB)->ZZB_CCUSTO,;
                                    (_cAliasZZB)->ZZB_ATIVO})
                (_cAliasZZB)->(DbSkip())
            EndDo
            (_cAliasZZB)->(DbCloseArea())

        // Verifica se existe registros para copiar
            If Len(aRegistros) == 0
                MsgInfo("Nenhum registro encontrado para o usuário: " + _cUsuaOri, "Atenção")
                Return
            EndIf

        // Insere os registros para o novo usuÃ¡rio
                DbSelectArea("ZZB")
                For nI := 1 To Len(aRegistros)
                    RecLock("ZZB", .T.)
                    ZZB_CODOPE := aRegistros[nI][1]
                    ZZB_CODUSR := aRegistros[nI][2]
                    ZZB_USRNOM := aRegistros[nI][3]
                    ZZB_NOMUSR := aRegistros[nI][4]
                    ZZB_OPERAC := aRegistros[nI][5]
                    ZZB_PRODUT := aRegistros[nI][6]
                    ZZB_CCUSTO := aRegistros[nI][7]
                    ZZB_ATIVO  := '1'
                    MsUnlock()
                Next
            MsgInfo("Registros copiados com sucesso para o usuário: " + _cUsuaNew, "Sucesso")
        EndIf
    Else
        MsgInfo("O campo de usuário está em branco. A copia não foi concluída.",_cRotina+"_002")
    EndIf


RestArea(_aSavZZB)
RestArea(_aSavArea)

Return



