#include "totvs.ch"

/*/{Protheus.doc} RPCPG001
    Gatilho para gravar lote anterior no empenho multiplo.
    @type  Function
    @author Fernando Bombardi
    @since 16/12/2023
    /*/
User Function RPCPG001(_cLoteNov)
Local _aArea      := GetArea()
Local _nPosLotAnt := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_XLOTANT"})

if !aCols[n][Len(aHeader)+1] 
    if !aCols[n][Len(aHeader)] == 0 
        SD4->(dbGoTo(aCols[n][Len(aHeader)]))
        aCols[n,_nPosLotAnt] := SD4->D4_LOTECTL
    else
        aCols[n,_nPosLotAnt] := ""
    endif
endif

RestArea(_aArea)
Return(_cLoteNov)
