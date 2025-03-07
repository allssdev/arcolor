#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function RPCPG002
    LOCALIZA��O : Function RPCPG002 - Respons�vel por validar por preencher o campo lote fornecedor quando houver altera��o do lote interno
    gatilho ativado ao preencher o campo D4_LOTECTL
    DESCRI��O : Permite executar a valida��o do usu�rio ao confirmar a OP.
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
