#include "totvs.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT250TOK
    (long_description)
    @type  Function
    @author user
    @since 16/12/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MT250TOK()
Local _aArea := GetArea()
Local _lRet := .T.

    dbSelectArea("SD4")
    SD4->(dbSetOrder(2))
    If SD4->(MsSeek(FWFilial("SD4")+M->D3_OP,.T.,.F.))
        while !SD4->(EOF()) .AND. SD4->D4_FILIAL == FWFilial('SC2') .AND. SD4->D4_OP == Padr(M->D3_OP,len(SD4->D4_OP))
                dbSelectArea("SB1")
                SB1->(dbSetOrder(1))
                If SB1->(MsSeek(FWFilial("SB1")+SD4->D4_COD,.T.,.F.))
                    If SB1->B1_RASTRO == 'L' .and. Empty(SD4->D4_LOTECTL)
                        ShowHelpDlg("[MT250TOK_E002]", {"A Ordem de Produção: " + M->D3_OP + " possui empenho com lotes em branco!",""},5,;
                                            {"Revise os empenhos da Ordem de Produção para realizar o apontamento de produção.",""},5)
                        _lRet := .F.
                    EndIf
                EndIf
                SD4->(Dbskip())
        EndDo
    EndIf

    dbSelectArea("SC2")
    dbSetOrder(1)
    if dbSeek(FWXFilial("SC2")+M->D3_OP)
        if Empty(SC2->C2_XINIOP)
            ShowHelpDlg("[MT250TOK_E001]", {"A Ordem de Produção: " + M->D3_OP + " não possui revisão de empenho gerada!",""},5,;
                                        {"Revise os empenhos da Ordem de Produção para realizar o apontamento de produção.",""},5)
            _lRet := .F.
        endif
    endif

    // Verificação na tabela de inventário (SB2 ou tabela específica)
    dbSelectArea("SB2")
    SB2->(dbSetOrder(1))
    If SB2->(MsSeek(FWFilial("SB2")+M->D3_COD+M->D3_LOCAL,.T.,.F.))
        If !Empty(SB2->B2_DINVFIM) .and. SB2->B2_LOCAL = '01'
            cLocCqOrig  := '09'
            M->D3_LOCAL := '09'
        EndIf
    EndIf

RestArea(_aArea)
Return(_lRet)
