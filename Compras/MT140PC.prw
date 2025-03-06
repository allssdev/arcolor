
#INCLUDE "RwMake.ch"
#Include 'Protheus.ch'


User Function MT140PC()

Local lret := PARAMIXB[1] 
local cProd := supergetmv("MV_PCPROD",,"2295",)
local nx  := 1

For nx:= 1 to len(aCols)
    if alltrim(aCols[nx][2])$cProd
        lret := .F. // Retorno False para não validar o parâmetro MV_PCNFE
        exit
    endIf
next

Return lret
