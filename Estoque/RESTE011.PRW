#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} 
@description Fonte para geração do lote interno Arcolor
@author		Diego Rodrigues Pereira email: diego.rodrigues@allss.com.br
@since 		05/12/2023
@version 	1.01
@see 		https://allss.com.br
@History 	
/*/

User Function RESTE011(_cProduto)

Local _aArea   := GetArea()
Local _aSavSD1 := SD1->(GetArea())
Local _cLoteCtl := ""
Local _cCodProd := _cProduto
lOCAL _cLoteFor := M->D1_LOTEFOR
//Local _cArmz    := "%" + FormatIn(SUPERGETMV( "MV_XARMZPRI",.F.,"01"),"/")+ "%"
    
       
    BeginSql Alias "LOTFOR"
        SELECT B8_PRODUTO,B8_LOTECTL, B8_LOTEFOR, B8_DTVALID, B8_SALDO, B8_EMPENHO 
        FROM SB8010 SB8 
        WHERE SB8.D_E_L_E_T_ = '' 
        //AND B8_LOCAL IN %Exp:_cArmz% 
        AND B8_PRODUTO = %Exp:_cCodProd%
        AND B8_LOTEFOR = %Exp:_cLoteFor%
        GROUP BY B8_FILIAL,B8_PRODUTO,B8_LOTECTL,B8_LOTEFOR, B8_DTVALID, B8_SALDO, B8_EMPENHO, B8_LOCAL, B8_NUMLOTE
        ORDER BY B8_FILIAL,B8_PRODUTO,B8_DTVALID,B8_LOCAL,B8_LOTECTL,B8_NUMLOTE
    EndSql

   If LOTFOR->(!EOF())
        _cLoteCtl := LOTFOR->B8_LOTECTL
        LOTFOR->(dbskip())
   Else
    _cLoteCtl := "A"+NextLote(_cProduto,"L")
   EndIf
   LOTFOR->(dbCloseArea()) 
RestArea(_aArea)
RestArea(_aSavSD1)

Return(_cLoteCtl)
