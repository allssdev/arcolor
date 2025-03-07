#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function MA650EMP
    LOCALIZA��O : Function MA650EMP - Respons�vel por validar por preencher o campo lote fornecedor quando estiver vazio na tabela SD4
    chamada no campo D4_COD
    DESCRI��O : Permite executar a valida��o do usu�rio ao confirmar a OP.
    @type  Function
    @author Diego Rodrigues
    @since 14/02/2024
    @version 1.0
    /*/
  
  
USER FUNCTION MA650EMP()

Local _nEmp     := 0
Local aItems    := aCols       // aCols cont�m as linhas da grid de empenhos que foram processados no momento.
Local _cOp      := SD4->D4_OP  // SD4 est� posicionada na ultima op gerada
Local _cArmz    := "%" + FormatIn(SUPERGETMV( "MV_XARMZPRI",.F.,"01"),"/")+ "%"
    
    For _nEmp := 1 to Len(aItems)   
        
        BeginSql Alias "SALDOS"
            SELECT B8_PRODUTO,B8_LOTECTL, B8_LOTEFOR, B8_DTVALID, B8_SALDO, B8_EMPENHO 
            FROM SB8010 SB8 
            WHERE SB8.D_E_L_E_T_ = '' 
            AND B8_LOCAL IN %Exp:_cArmz% 
            AND B8_PRODUTO = %Exp:aItems[_nEmp][1]% 
            AND B8_LOTECTL = %Exp:aItems[_nEmp][6]%
            GROUP BY B8_FILIAL,B8_PRODUTO,B8_LOTECTL,B8_LOTEFOR, B8_DTVALID, B8_SALDO, B8_EMPENHO, B8_LOCAL, B8_NUMLOTE
            ORDER BY B8_FILIAL,B8_PRODUTO,B8_DTVALID,B8_LOCAL,B8_LOTECTL,B8_NUMLOTE
        EndSql
       If SALDOS->(!EOF())
            dbSelectArea("SD4")
            SD4->(dbSetOrder(1))
            SD4->(MsSeek(xFilial("SD4")+aItems[_nEmp][1]+_cOp+aItems[_nEmp][4]+aItems[_nEmp][6], .T.,.F.))
            If !Empty(aItems[_nEmp][6]) .and. !Empty(SALDOS->B8_LOTEFOR)
                Reclock("SD4",.F.)
                    SD4->D4_XLOTFOR := SALDOS->B8_LOTEFOR
                SD4->(MsUnlock())
            EndIf
        EndIF
        SALDOS->(dbCloseArea())
    Next

Return
