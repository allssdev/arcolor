#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} TITICMST
Ponto de entrada utilizado para grava��o de dados adicionais nos t�tulos a pagar (recolhimento de ST) gerados automaticamente no momento do faturamento de uma nota de sa�da.
@author Adriano L. de Souza
@since 10/01/2014
@version P12.1.33
@type Function
@obs Sem observa��es
@see https://allss.com.br
@history 13/05/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Altera��o dos crit�rios de data de vencimento (E2_VENCTO) e vencimento real (E2_VENCREA).
/*/
user function TITICMST()
local _aSavArea := GetArea()
local _aSavSE2  := SE2->(GetArea())
local cOrigem   := PARAMIXB[1]
local cTipoImp  := PARAMIXB[2]
local _dData	:= ddatabase
local _nDVencto := SuperGetMv("MV_DATAPAG",.F.,5)
//Altera t�tulos de ST que tiveram origem no faturamento de um pedido de venda
if AllTrim(cOrigem) == "MATA460A" .OR. AllTrim(cOrigem) == "RFATA002"
	SE2->E2_HIST 	:= "Nota Fiscal: " + AllTrim(SF2->F2_DOC) +  "-" + AllTrim(SF2->F2_SERIE)
	SE2->E2_OBS 	:= "Nota Fiscal: " + AllTrim(SF2->F2_DOC) +  " - " + AllTrim(SF2->F2_SERIE) + " / Cliente/Fornecedor: " + AllTrim(SF2->F2_CLIENTE) + " Loja: " + AllTrim(SF2->F2_LOJA)
	//SE2->E2_VENCTO 	:= dDataBase
	//SE2->E2_VENCREA := DataValida(dDataBase)
	SE2->E2_VENCTO  := DataValida(_dData + _nDVencto,.T.)
	SE2->E2_VENCREA := DataValida(_dData + _nDVencto,.T.)
	SE2->E2_PORTADO := SuperGetMV("MV_BCOPRIN",,"001") //Linha adicionada por Adriano Leonardo em 31/01/2014 para defini��o de portador default
endif
RestArea(_aSavSE2)
RestArea(_aSavArea)
return nil
