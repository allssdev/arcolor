#include 'protheus.ch'
#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RGPEP015
@description Função de usuário para uso exclusivo no calculo do vale refeição
@author Diego Rodrigues (ALLSS - diego.rodrigues@allss.com.br)
@since 25/03/2021
@version 1.00 (P12.1.25)
@type function
@history 25/03/2021, Diego Rodrigues (diego.rodrigues@allss.com.br), Aplicação no ambiente de produção
@see https://allss.com.br
/*/
user function RGPEP015()
local aSavArea  := GetArea()
local aSavSRA   := SRA->(GetArea())
local aSavSRV   := SRV->(GetArea())
local aSavSRC   := SRC->(GetArea())
local lRet		:= .T.

if SRA->RA_DEPTO = "000000700"
    M_DIASVALREF := 0
    FDELPD("499",,,"FOL")
    FGERAVERBA('499',M_DIASVALREF * M_VALREF,M_DIASVALREF,,,,,,,,.T.,,,,,,,,)
else

    M_DIASVALREF := (FBUSCAPD('499','H',,,'FOL')* -1)  
    FDELPD("499",,,"FOL")
    FGERAVERBA('499',M_DIASVALREF * M_VALREF,M_DIASVALREF,,,,,,,,.T.,,,,,,,,)  
EndIF
	

RestArea(aSavSRA)
RestArea(aSavSRV)
RestArea(aSavSRC)
RestArea(aSavArea)
return lRet
