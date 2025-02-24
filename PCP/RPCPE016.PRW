#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function RPCPE016
    LOCALIZAÇÃO : Function RPCPE016 - Responsável por ajustar as quantidades de empenho quando alterar a quantidade da ordem de produção na tabela SD4
    @type  Function
    @author Diego Rodrigues
    @since 21/06/2024
    @version 1.0
    /*/
  
USER FUNCTION RPCPE016(_cOp,_nQtdPrd,_nQtdAnt)

//Atualiza empenho 
BeginSql Alias "EMPENHO"
    SELECT
        SD4.D4_FILIAL, SD4.D4_DATA, SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL, SD4.D4_TRT, SD4.D4_LOTECTL, SD4.D4_PRODUTO
        ,SD4.D4_ROTEIRO, SB1.B1_TIPO, SD4.R_E_C_N_O_ RECSD4
    FROM %table:SD4% SD4 (NOLOCK) 
    INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND SB1.B1_COD = SD4.D4_COD 
    WHERE SD4.D4_OP = %exp:_cOp% 
            --AND SD4.D4_LOTECTL = ''
            AND SD4.%notDel%
    ORDER BY SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL
EndSql

while EMPENHO->(!EOF()) 
    dbSelectArea("SD4")
    dbSetOrder(1) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
    SD4->(dbGoTo(EMPENHO->RECSD4))
    //if SD4->(MsSeek(xFilial("SD4")+ EMPENHO->D4_COD+EMPENHO->D4_OP+EMPENHO->D4_TRT+EMPENHO->D4_LOTECTL, .T.,.F.))
        //_nLoteEc := Posicione("SB1",1,xFilial("SB1")+EMPENHO->D4_PRODUTO,"SB1->B1_LE")
        Reclock("SD4",.F.)
            SD4->D4_QUANT := IF(EMPENHO->B1_TIPO == 'EM',NOROUND((SD4->D4_QUANT/_nQtdAnt) * (_nQtdPrd),0),((SD4->D4_QUANT/_nQtdAnt) * (_nQtdPrd)))
            SD4->D4_QTDEORI :=IF(EMPENHO->B1_TIPO == 'EM',NOROUND((SD4->D4_QTDEORI/_nQtdAnt) * (_nQtdPrd),0),((SD4->D4_QTDEORI/_nQtdAnt) * (_nQtdPrd)))
        SD4->(MsUnlock())
    //EndIf

dbSelectArea("EMPENHO")
EMPENHO->(dbSkip())
enddo
EMPENHO->(dbCloseArea())

Return
