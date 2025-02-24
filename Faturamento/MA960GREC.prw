#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} MA960GREC
Ponto de Entrada para preenchimento dos campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE e F6_CODPROD de acordo com o código de receita e UF.
@author Rodrigo Telecio - ALLSS Soluções em Sistemas (rodrigo.telecio@allss.com.br)
@since 19/04/2022
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br
@history 19/04/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Versão inicial de rotina.
@history 25/04/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Correção de retorno (numérico) das posições 1 e 4 do array _aParam e implementação do campo ZZA_CODARE.
@history 13/05/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adequações diversas para GNRE 2.00.
/*/
user function MA960GREC() 
local _aParam       := {0,'','',0,''} //Parâmetros de retorno default
local _cReceita     := PARAMIXB[1]    //Código de Receita da guia atual
local _cUF          := PARAMIXB[2]    //Sigla da UF da guia atual
local _aArea        := GetArea()
local _aAreaSF6     := SF6->(GetArea())
dbSelectArea("ZZA")
ZZA->(dbSetOrder(1))
if ZZA->(dbSeek(FwFilial("ZZA") + _cUF + _cReceita))
    _aParam := {Val(ZZA->ZZA_TIPOGN),ZZA->ZZA_DOCORI,ZZA->ZZA_DETREC,Val(ZZA->ZZA_CODPRO),ZZA->ZZA_CODARE}
endif
RestArea(_aAreaSF6)
RestArea(_aArea)
Return _aParam
