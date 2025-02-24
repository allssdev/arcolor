#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function RPCPE014
    LOCALIZAÇÃO : Function RPCPE014 - Responsável por validar por preencher o campo lote quando estiver vazio na tabela SD4
    chamada no campo D4_COD - X3_VLDUSR IIF(EXISTBLOCK("RPCPE014"),EXECBLOCK("RPCPE014"),.T.) 
    DESCRIÇÃO : Permite executar a validação do usuário ao confirmar a OP.
    @type  Function
    @author Diego Rodrigues
    @since 10/01/2024
    @version 1.0
    /*/
  
USER FUNCTION RPCPE014()

Local _nItemEmpenho := 0
Local _cComp := M->D4_COD
Local _nPosCod := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_PRODUTO"})
Local _cRet := .T.

For _nItemEmpenho :=1 to 1
     BeginSql Alias "ESTRUTURA"
        SELECT 
            G1_FILIAL, G1_REVFIM, G1_COD, G1_COMP
        FROM SG1010 SG1 (NOLOCK)
            WHERE SG1.D_E_L_E_T_ = ''
            AND G1_COMP = %exp:_cComp% 
            AND G1_COD = %exp:cValToChar(aCols[_nItemEmpenho,_nPosCod])% 
        GROUP BY G1_FILIAL, G1_REVFIM, G1_COD, G1_COMP
        HAVING SG1.G1_REVFIM = (SELECT MAX(G1_REVFIM) FROM SG1010 WHERE G1_COD = SG1.G1_COD AND D_E_L_E_T_ = '')
    EndSql

    if EMPTY(ESTRUTURA->G1_COMP)
        MsgAlert("Produto não pertence a estrutura. Favor verificar o produto correto para inclusão no empenho","Atenção_RCPE014_001")
    _cRet := .F.
    endif
    ESTRUTURA->(dbCloseArea())
Next

Return _cRet


