#include "totvs.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT680VAL  
    (long_description)
    @type  Function Retorna se pode prosseguir ou não com a validação de inclusão do Apontamento  
    @author user http://tdn.totvs.com/pages/releaseview.action?pageId=6089410 
    @since 23/07/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function MT680VAL()
Local   _aSavArea := GetArea()
Local   _aSavSD4  := SD4->(GetArea())
Local   _aSavSB1  := SB1->(GetArea())
Local   _aSavSD3  := SD3->(GetArea())
Local   _aSavSH6  := SH6->(GetArea())
Local   _aSavSC2  := SC2->(GetArea())
Local _lRet := .T.

    dbSelectArea("SD4")
    SD4->(dbSetOrder(2))
    If SD4->(MsSeek(FWFilial("SD4")+M->H6_OP,.T.,.F.))
        while !SD4->(EOF()) .AND. SD4->D4_FILIAL == FWFilial('SC2') .AND. SD4->D4_OP == Padr(M->H6_OP,len(SD4->D4_OP)) 
            If SD4->D4_OPERAC == Padr(M->H6_OPERAC,len(SD4->D4_OPERAC))
                dbSelectArea("SB1")
                SB1->(dbSetOrder(1))
                If SB1->(MsSeek(FWFilial("SB1")+SD4->D4_COD,.T.,.F.))
                    If SB1->B1_RASTRO == 'L' .and. Empty(SD4->D4_LOTECTL)
                        ShowHelpDlg("[MT681TOK_E001]", {"A Ordem de Produção: " + M->H6_OP + " possui empenho com lotes em branco!",""},5,;
                                            {"Revise os empenhos da Ordem de Produção para realizar o apontamento de produção.",""},5)
                        _lRet := .F.
                    EndIf
                EndIf
            EndIf
        SD4->(Dbskip())
        EndDo
    EndIf

    dbSelectArea("SC2")
    dbSetOrder(1)
    if dbSeek(FWXFilial("SC2")+M->H6_OP)
        if Empty(SC2->C2_XINIOP)
            ShowHelpDlg("[MT681TOK_E002]", {"A Ordem de Produção: " + M->H6_OP + " não possui revisão de empenho gerada!",""},5,;
                                        {"Revise os empenhos da Ordem de Produção para realizar o apontamento de produção.",""},5)
            _lRet := .F.
        endif
    endif

RestArea(_aSavSC2)
RestArea(_aSavSD3)
RestArea(_aSavSH6)
RestArea(_aSavSB1)
RestArea(_aSavSD4)
RestArea(_aSavArea)
Return(_lRet)
