
#include "totvs.ch"
/*/{Protheus.doc} MTA381GRV
    O Ponto de entrada MTA381GRV � utilizado para realizar opera��es complementares ap�s a inclus�o, altera��o e exclus�o de um item de ajuste de empenho mod II.
    @type  Function
    @author Ferando Bombardi
    @since 16/12/2023
    /*/
User Function MTA381GRV()
Local _lAlter := PARAMIXB[2]
Local _lVisul := PARAMIXB[3]

    if (_lAlter) .or. (_lVisul)
        oRPCPC005 := RPCPC005():NEW()
        oRPCPC005:GravarIniOP()
    endif    

Return


