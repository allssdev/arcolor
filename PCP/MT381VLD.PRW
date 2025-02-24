#include "Totvs.ch"

/*/{Protheus.doc} MT381VLD
    Ponto de Entrada, localizado na validação de Ajuste Empenho Mod. 2, utilizado para confirmar a gravação do Ajuste Empenho Modelo 2.
    @type  Function
    @author Fernando Bombardi
    @since 06/12/2023
    /*/
User Function MT381VLD()
Local _lAlter := PARAMIXB[2]
Local _nX := 0

    if (_lAlter) .and. Len(aInflt) > 0
        oRPCPC004 := RPCPC004():NEW()
        oRPCPC004:imprimirRelatorioDeAlteracaoDeEmpenho()
    endif
return(.T.)
