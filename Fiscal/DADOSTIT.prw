#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} DADOSTIT
Ponto de Entrada localizado ap�s a grava��o das informa��es padr�o do tributo para t�tulo a ser gerado no financeiro. Isso vale para todos os impostos processados na fun��o GravaTit(). Deve ser utilizado para complementar ou alterar os valores referentes ao n�mero da Guia de Recolhimento e data de vencimento do t�tulo da guia de recolhimento.
@author Rodrigo Telecio - ALLSS Solu��es em Sistemas (rodrigo.telecio@allss.com.br)
@since 13/05/2022
@version P12.1.33
@type Function
@obs Sem observa��es
@see https://allss.com.br
@history 13/05/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Vers�o inicial de rotina.
@history 13/05/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Altera��o dos crit�rios de data de vencimento (F6_DTVENC) e data de pagamento (F6_DTPAGTO).
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
