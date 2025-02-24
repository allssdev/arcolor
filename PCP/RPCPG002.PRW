#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function RPCPG002
    LOCALIZAÇÃO : Function RPCPG002 - Responsável por validar por preencher o campo lote fornecedor quando houver alteração do lote interno
    gatilho ativado ao preencher o campo D4_LOTECTL
    DESCRIÇÃO : Permite executar a validação do usuário ao confirmar a OP.
    @type  Function
    @author Diego Rodrigues
    @since 14/02/2024
    @version 1.0
    /*/
  
USER FUNCTION RPCPG002(_cLoteIn)

Local _aArea      := GetArea()
lOCAL _cLoteFor := ""
Local _cArmz    := "%" + FormatIn(SUPERGETMV( "MV_XARMZPRI",.F.,"01"),"/")+ "%"
    
       
    BeginSql Alias "LOTFOR"
        SELECT B8_PRODUTO,B8_LOTECTL, B8_LOTEFOR, B8_DTVALID, B8_SALDO, B8_EMPENHO 
        FROM SB8010 SB8 
        WHERE SB8.D_E_L_E_T_ = '' 
        AND B8_LOCAL IN %Exp:_cArmz% 
        //AND B8_PRODUTO = %Exp:_cComp% 
        AND B8_LOTECTL = %Exp:_cLoteIn%
        GROUP BY B8_FILIAL,B8_PRODUTO,B8_LOTECTL,B8_LOTEFOR, B8_DTVALID, B8_SALDO, B8_EMPENHO, B8_LOCAL, B8_NUMLOTE
        ORDER BY B8_FILIAL,B8_PRODUTO,B8_DTVALID,B8_LOCAL,B8_LOTECTL,B8_NUMLOTE
    EndSql

    while LOTFOR->(!EOF())
        _cLoteFor := LOTFOR->B8_LOTEFOR
        LOTFOR->(dbskip())
    EndDo
    LOTFOR->(dbCloseArea())
RestArea(_aArea)
Return (_cLoteFor)
