#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function RCPPE019
    LOCALIZAÇÃO : Function RPCPE019 - Responsável por validar os saldos antes de converter a numeração das ordens previstas para as firmes.
    DESCRIÇÃO : Permite executar a validação do usuário ao confirmar a OP.
    @type  Function
    @author Diego Rodrigues
    @since 06/02/2025
    @version 1.0
    /*/
User Function RPCPE019(_cProduto)

Local   _aSavArea := GetArea()
Local   _aSavSD4  := SD4->(GetArea())
Local   _aSavSB1  := SB1->(GetArea())
Local   _aSavSD3  := SD3->(GetArea())
Local   _aSavSH6  := SH6->(GetArea())
Local   _aSavSC2  := SC2->(GetArea())
//Local _cRotina       := "RPCPE019"
Local _lRet          := .T.
Local _cAliasSG1     := GetNextAlias()
Local _cAliasSGF     := GetNextAlias()
Private _aItSemSld   := {}
Private _cPicQtd     := PesqPict("SC2","C2_QUANT")


dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+_cProduto,.T.,.F.))
    If !Empty(SB1->B1_OPERPAD)

        //Valida Roteiro
        BeginSql Alias _cAliasSGF
            SELECT
                G1_COD COD_PA, B1_DESC DESCRICAO_PA, G1_COMP COD_COMPONENTE
            FROM SG1010 SG1 (NOLOCK) 
            INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_MSBLQL <> '1'  AND SB1.B1_COD = G1_COD AND B1_TIPO IN ('PA') AND B1_OPERPAD <> ''
            WHERE SG1.D_E_L_E_T_ = ''
            AND G1_COD = %Exp:_cProduto% 
            AND NOT EXISTS ( SELECT TOP 1 1
                            FROM SGF010 SGF (NOLOCK)
                            WHERE SGF.D_E_L_E_T_ = ''
                            AND SGF.GF_PRODUTO = SG1.G1_COD
                            AND SGF.GF_COMP = SG1.G1_COMP
                            AND SGF.GF_TRT = SG1.G1_TRT)
            GROUP BY G1_COD, G1_COMP, B1_DESC,G1_REVFIM
            HAVING SG1.G1_REVFIM = (SELECT MAX(G1_REVFIM) FROM SG1010 WHERE G1_COD = SG1.G1_COD AND D_E_L_E_T_ = '')
            ORDER BY G1_COD, G1_COMP
        EndSql

        If (_cAliasSGF)->(!EOF())
            ShowHelpDlg("[RPCPE019_E001]", {"Alteração na estrutura do produto: " + _cProduto,""},5,;
                                            {"Informe o Responsavel pelo roteiro de produtos",""},5)
            _lRet := .F.
        (_cAliasSGF)->(dbSkip())
        EndIf
        //Excluo a tabela temporária
        if Select(_cAliasSGF) > 0
            (_cAliasSGF)->(dbCloseArea())   
        endif

        BeginSql Alias _cAliasSG1
            SELECT
                GF_PRODUTO, GF_COMP
            FROM SGF010 SGF (NOLOCK)
            INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_MSBLQL <> '1'  AND SB1.B1_COD = GF_PRODUTO AND B1_TIPO IN ('PA') AND B1_OPERPAD <> ''
            WHERE SGF.D_E_L_E_T_ = ''
            AND SGF.GF_PRODUTO = %Exp:_cProduto% 
            AND NOT EXISTS ( SELECT TOP 1 1
                            FROM SG1010 SG1 (NOLOCK)
                            WHERE SG1.D_E_L_E_T_ = ''
                            AND SG1.G1_COD = SGF.GF_PRODUTO
                            AND SG1.G1_COMP = SGF.GF_COMP
                            AND SG1.G1_TRT = SGF.GF_TRT
                            GROUP BY G1_COD, G1_REVFIM
                            HAVING SG1.G1_REVFIM = (SELECT MAX(G1_REVFIM) FROM SG1010 WHERE G1_COD = SG1.G1_COD AND D_E_L_E_T_ = '')
                            )
        EndSql

        If (_cAliasSG1)->(!EOF()) .AND. _lRet
            ShowHelpDlg("[RPCPE019_E002]", {"Alteração na estrutura do produto: " + _cProduto,""},5,;
                                            {"Informe o Responsavel pelo roteiro de produtos",""},5)
            _lRet := .F.
        (_cAliasSG1)->(dbSkip())
        EndIf
        //Excluo a tabela temporária
        if Select(_cAliasSG1) > 0
            (_cAliasSG1)->(dbCloseArea())   
        endif
    EndIf
EndIf
RestArea(_aSavSC2)
RestArea(_aSavSD3)
RestArea(_aSavSH6)
RestArea(_aSavSB1)
RestArea(_aSavSD4)
RestArea(_aSavArea)
Return(_lRet)
