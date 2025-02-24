#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function RPCPE012
    LOCALIZAÇÃO : Function RPCPE012 - Responsável por validar por preencher o campo lote quando estiver vazio na tabela SD4
    DESCRIÇÃO : Permite executar a validação do usuário ao confirmar a OP.
    @type  Function
    @author Diego Rodrigues
    @since 06/12/2023
    @version 1.0
    /*/
  
USER FUNCTION RPCPE012(_cOp)

Local _cArmz    := "%" + FormatIn(SUPERGETMV( "MV_XARMZPRI",.F.,"01"),"/")+ "%"
Local _cProdExc := SUPERGETMV( "MV_XPREXEM",.F.,"")
Local _cProdAnt := ""
Local _cLoteAnt := ""
Local _nQtdETot := 0
Local _nQEmpSld := 0
Local _nQEmpAtu := 0
Local _cProdSld := ""
Local _nQuant := 0

//Atualiza empenho 
BeginSql Alias "EMPENHO"
    SELECT
        SD4.D4_FILIAL, SD4.D4_DATA, SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL, SD4.D4_TRT, SD4.D4_LOTECTL, SD4.D4_PRODUTO, SD4.D4_ROTEIRO, SD4.D4_OPERAC
    FROM %table:SD4% SD4 (NOLOCK) 
    INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND SB1.B1_COD = SD4.D4_COD AND SB1.B1_TIPO NOT IN ('PI') 
    WHERE SD4.D4_OP = %exp:_cOp% 
            AND SD4.D4_LOTECTL = ''
            AND SD4.%notDel%
    ORDER BY SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL
EndSql

while EMPENHO->(!EOF()) .and. !EMPENHO->D4_COD$_cProdExc
    dbSelectArea("SD4")
    dbSetOrder(1) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
    if SD4->(MsSeek(xFilial("SD4")+ EMPENHO->D4_COD+EMPENHO->D4_OP+EMPENHO->D4_TRT+EMPENHO->D4_LOTECTL, .T.,.F.))

        BeginSql Alias "SALDOS"
            SELECT B8_PRODUTO,B8_LOTECTL, B8_LOTEFOR,B8_DTVALID, B8_SALDO, B8_EMPENHO 
            ,ISNULL((SELECT SUM(D4_QUANT) FROM SD4010 SD4 (NOLOCK)
                    INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP 
                                            AND SUBSTRING(C2_NUM,1,1) <> 'Z'
                    WHERE SD4.D_E_L_E_T_ = '' AND SD4.D4_COD = SB8.B8_PRODUTO AND D4_LOTECTL = B8_LOTECTL AND D4_QUANT > 0),0) EMPSD4
            ,ISNULL((SELECT SUM(DD_QUANT) FROM SDD010 SDD
					WHERE SDD.D_E_L_E_T_ = '' AND SDD.DD_PRODUTO = SB8.B8_PRODUTO AND DD_LOTECTL = B8_LOTECTL AND DD_QUANT > 0),0) EMPSDD
            FROM SB8010 SB8 (NOLOCK)
            WHERE SB8.D_E_L_E_T_ = '' 
            AND B8_LOCAL IN %Exp:_cArmz% 
            AND B8_PRODUTO = %Exp:EMPENHO->D4_COD%
            AND (CASE WHEN B8_LOTECTL = 'UNICO' THEN 0 ELSE 1 END) = 1
            AND (B8_SALDO - ISNULL((SELECT SUM(D4_QUANT) FROM SD4010 SD4 (NOLOCK)
                    INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP 
                                            AND SUBSTRING(C2_NUM,1,1) <> 'Z'
                    WHERE SD4.D_E_L_E_T_ = '' AND SD4.D4_COD = SB8.B8_PRODUTO AND D4_LOTECTL = B8_LOTECTL AND D4_QUANT > 0),0)) > 0 
            //--AND (B8_SALDO - B8_EMPENHO) > 0
            GROUP BY B8_FILIAL,B8_PRODUTO,B8_LOTECTL,B8_LOTEFOR,B8_DTVALID, B8_SALDO, B8_EMPENHO, B8_LOCAL, B8_NUMLOTE
            ORDER BY B8_FILIAL,B8_PRODUTO,B8_DTVALID,B8_LOCAL,B8_LOTECTL,B8_NUMLOTE
        EndSql

        while SALDOS->(!EOF())
            If EMPENHO->D4_COD = SALDOS->B8_PRODUTO .and. Empty(SD4->D4_LOTECTL) .and. (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD)) >= SD4->D4_QUANT .and. _cProdAnt <> SD4->D4_COD 
                        Reclock("SD4",.F.)
                        SD4->D4_LOTECTL := SALDOS->B8_LOTECTL
                        SD4->D4_XLOTFOR := SALDOS->B8_LOTEFOR
                        SD4->D4_DTVALID := Stod(SALDOS->B8_DTVALID)
                        SD4->(MsUnlock())
            ElseIf EMPENHO->D4_COD = SALDOS->B8_PRODUTO .and. Empty(SD4->D4_LOTECTL) .and. (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD)) > 0 .and. (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD)) < SD4->D4_QUANT .and. _cProdAnt <> SD4->D4_COD 
                    _nQtdETot := SD4->D4_QUANT
                    _nQEmpSld := SD4->D4_QUANT - (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD))
                    _nQEmpAtu := (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD))
                    _cProdSld := SD4->D4_COD
                    Reclock("SD4",.F.)
                        SD4->D4_QUANT := (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD))
                        SD4->D4_QTDEORI := (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD))
                        SD4->D4_LOTECTL := SALDOS->B8_LOTECTL
                        SD4->D4_XLOTFOR := SALDOS->B8_LOTEFOR
                        SD4->D4_DTVALID := Stod(SALDOS->B8_DTVALID)
                    SD4->(MsUnlock())
                    _cLoteAnt := SALDOS->B8_LOTECTL
            ElseIf (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD)) <= _nQEmpSld .and. !Empty(_cProdSld) .and. _nQEmpSld <> _nQtdETot
                    Reclock("SD4",.T.)
                        SD4->D4_FILIAL :=  EMPENHO->D4_FILIAL
                        SD4->D4_COD := _cProdSld
                        SD4->D4_LOCAL := EMPENHO->D4_LOCAL
                        SD4->D4_OP   := EMPENHO->D4_OP
                        SD4->D4_DATA := Stod(EMPENHO->D4_DATA)
                        SD4->D4_QTDEORI := (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD))
                        SD4->D4_QUANT := (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD))
                        SD4->D4_LOTECTL := SALDOS->B8_LOTECTL
                        SD4->D4_XLOTFOR := SALDOS->B8_LOTEFOR
                        SD4->D4_DTVALID := Stod(SALDOS->B8_DTVALID)
                        SD4->D4_PRODUTO := EMPENHO->D4_PRODUTO
                        SD4->D4_ROTEIRO := EMPENHO->D4_ROTEIRO
                        SD4->D4_OPERAC := EMPENHO->D4_OPERAC
                    SD4->(MsUnlock())
                    _nQEmpSld := _nQEmpSld - (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD)) 
                    _nQEmpAtu := _nQEmpAtu + (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD))
                    _cLoteAnt := SALDOS->B8_LOTECTL
            ElseIf (SALDOS->B8_SALDO - (SALDOS->EMPSD4+SALDOS->EMPSDD)) >= _nQEmpSld .and. !Empty(_cProdSld) .and. _nQEmpSld <> _nQtdETot
                    Reclock("SD4",.T.)
                        SD4->D4_FILIAL :=  EMPENHO->D4_FILIAL
                        SD4->D4_COD := _cProdSld
                        SD4->D4_LOCAL := EMPENHO->D4_LOCAL
                        SD4->D4_OP   := EMPENHO->D4_OP
                        SD4->D4_DATA := Stod(EMPENHO->D4_DATA)
                        SD4->D4_QTDEORI := _nQEmpSld
                        SD4->D4_QUANT := _nQEmpSld
                        SD4->D4_LOTECTL := SALDOS->B8_LOTECTL
                        SD4->D4_XLOTFOR := SALDOS->B8_LOTEFOR
                        SD4->D4_DTVALID := Stod(SALDOS->B8_DTVALID)
                        SD4->D4_PRODUTO := EMPENHO->D4_PRODUTO
                        SD4->D4_ROTEIRO := EMPENHO->D4_ROTEIRO
                        SD4->D4_OPERAC := EMPENHO->D4_OPERAC
                    SD4->(MsUnlock())
                    _nQEmpSld := _nQEmpSld + _nQEmpAtu
                    _cLoteAnt := SALDOS->B8_LOTECTL
            ElseIf _cProdAnt == SD4->D4_COD .and. _cLoteAnt == SALDOS->B8_LOTECTL
                    SD4->(dbSetOrder(1))
                    If SD4->(MsSeek(xFilial("SD4")+_cProdAnt+_cOp+_cTrtAnt+_cLoteAnt, .T.,.F.))
                        _nQuant := SD4->D4_QUANT
                        RecLock("SD4",.F.)
                            SD4->(DbDelete())
                        SD4->(MsUnLock())
                    EndIf
                    If SD4->(MsSeek(xFilial("SD4")+EMPENHO->D4_COD+EMPENHO->D4_OP+EMPENHO->D4_TRT+EMPENHO->D4_LOTECTL, .T.,.F.))
                        Reclock("SD4",.F.)
                            SD4->D4_QUANT := SD4->D4_QTDEORI + _nQuant
                            SD4->D4_QTDEORI := SD4->D4_QTDEORI + _nQuant
                            SD4->D4_LOTECTL := SALDOS->B8_LOTECTL
                            SD4->D4_XLOTFOR := SALDOS->B8_LOTEFOR
                            SD4->D4_DTVALID := Stod(SALDOS->B8_DTVALID)
                        SD4->(MsUnlock())
                    EndIf
            Endif
        SALDOS->(dbSkip())
        EndDo

            If _nQEmpSld <> 0 .and. _nQEmpSld < _nQtdETot
                Reclock("SD4",.T.)
                    SD4->D4_FILIAL :=  EMPENHO->D4_FILIAL
                    SD4->D4_COD := _cProdSld
                    SD4->D4_LOCAL := EMPENHO->D4_LOCAL
                    SD4->D4_OP   := EMPENHO->D4_OP
                    SD4->D4_DATA := Stod(EMPENHO->D4_DATA)
                    SD4->D4_QTDEORI := _nQEmpSld
                    SD4->D4_QUANT := _nQEmpSld
                    SD4->D4_LOTECTL := ""
                    //SD4->D4_DTVALID := ""
                    SD4->D4_PRODUTO := EMPENHO->D4_PRODUTO
                    SD4->D4_ROTEIRO := EMPENHO->D4_ROTEIRO
                    SD4->D4_OPERAC := EMPENHO->D4_OPERAC
                SD4->(MsUnlock())
            EndIf
        endif
    _cProdAnt := EMPENHO->D4_COD
    _cTrtAnt  := EMPENHO->D4_TRT
    _cLoteAnt := ""
    _nQtdETot := 0
    _nQEmpSld := 0
    _nQEmpAtu := 0
    _cProdSld := ""
    
SALDOS->(dbCloseArea())
dbSelectArea("EMPENHO")
EMPENHO->(dbSkip())
enddo
EMPENHO->(dbCloseArea())

Return
