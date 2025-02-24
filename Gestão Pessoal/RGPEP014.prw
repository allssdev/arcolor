#include 'protheus.ch'
#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RGPEP014
@description Função de usuário para uso exclusivo no calculo do dissidio retroativo, para recalculo das verbas de tipo "I-Informado" que estão com referencia zerada. 
@obs função utilizada no roteiro de calculo "RES" 
@author Rodrigo Telecio (ALLSS - rodrigo.telecio@allss.com.br)
@since 26/10/2020
@version 1.00 (P12.1.25)
@type function
@return nulo, nenhum, nada é retornado para a fórmula
@history 26/10/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Aplicação no ambiente de produção
@see https://allss.com.br
/*/
user function RGPEP014()
local aSavArea  := GetArea()
local aSavSR8   := SR8->(GetArea())
local aSavSRA   := SRA->(GetArea())
local aSavSRV   := SRV->(GetArea())
local aSavSRC   := SRC->(GetArea())
local aSavRGB   := RGB->(GetArea())
local aSavRCF   := RCF->(GetArea())
local aSavRCG   := RCG->(GetArea())
local aSavRCA   := RCA->(GetArea())
local aSavSRR   := SRR->(GetArea())
local aSavSRF   := SRF->(GetArea())
local lRet		:= .T.
if lRescDis
	nPerc 		:= Round(((SRA->RA_SALARIO - SRG->RG_SALMES) * 100) / SRG->RG_SALMES,2)
	for nX := 1 to Len(aPD)
		if aPd[nX,4] == 0 .AND. aPd[nX,7] == "I"
	 	   	//if RetValSRV(aPd[nX,1], SRA->RA_FILIAL, "RV_VALDISS") == "1"
	 	   		if SubStr(DtoS(aPd[nX,18]),1,6) < AllTrim(cPeriodo)
					aPd[nX,5]	:= aPd[nX,5] * (1 + (nPerc/100))
					aPd[nX,19]	:= aPd[nX,5]
				endif
			//endif
		endif
	next nX
endif
RestArea(aSavSRR)
RestArea(aSavSRF)
RestArea(aSavSR8)
RestArea(aSavSRA)
RestArea(aSavSRV)
RestArea(aSavSRC)
RestArea(aSavRGB)
RestArea(aSavRCF)
RestArea(aSavRCG)
RestArea(aSavRCA)
RestArea(aSavArea)
return lRet