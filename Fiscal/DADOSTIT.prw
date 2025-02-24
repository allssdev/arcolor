#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} DADOSTIT
Ponto de Entrada localizado após a gravação das informações padrão do tributo para título a ser gerado no financeiro. Isso vale para todos os impostos processados na função GravaTit(). Deve ser utilizado para complementar ou alterar os valores referentes ao número da Guia de Recolhimento e data de vencimento do título da guia de recolhimento.
@author Rodrigo Telecio - ALLSS Soluções em Sistemas (rodrigo.telecio@allss.com.br)
@since 13/05/2022
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br
@history 13/05/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Versão inicial de rotina.
@history 13/05/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Alteração dos critérios de data de vencimento (F6_DTVENC) e data de pagamento (F6_DTPAGTO).
/*/
user function DADOSTIT()
local _aArea        := GetArea()
local _aSF6Area     := SF6->(GetArea())
local _cOrigem	    := PARAMIXB[1]
local _dData	    := ddatabase
local _nDVencto     := SuperGetMv("MV_DATAPAG",.F.,5)
if AllTrim(_cOrigem) == "MATA460A" .OR. AllTrim(_cOrigem) == "RFATA002"
    SF6->F6_DTVENC  := DataValida(_dData + _nDVencto,.T.)
    SF6->F6_DTPAGTO := DataValida(_dData + _nDVencto,.T.)
endif
RestArea(_aSF6Area)
RestArea(_aArea)
return nil
