#include 'protheus.ch'
#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RGPEP012
@description Função de usuário para recalculo dos adicionais noturnos, para funcionarios mensalistas, fator 220 horas 
@obs função utilizada no roteiro de calculo "FOL" 
@author Rodrigo Telecio (ALLSS - rodrigo.telecio@allss.com.br)
@since 24/09/2020
@version 1.00 (P12.1.25)
@type function
@return nulo, nenhum, nada é retornado para a fórmula
@history 24/09/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Aplicação no ambiente de produção
@see https://allss.com.br
/*/
user function RGPEP012()
local nSalHora  := 0
local nDiasC	:= SuperGetMV("MV_XDIAADN",.F.,30) 
local cTab 		:= ""
local cPd  		:= ""
//local cRotina	:= "RGPEP012"
local nPerc		:= 0
local aPdTmp	:= {}
local nX		:= 0
local nSalInc	:= 0
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
if SRA->RA_TIPOPGT == "M"
	if SRA->RA_CATFUNC $ "M"
		cTab 		:= GetNextAlias()
		BeginSql Alias cTab
			SELECT 
				RV_COD
			FROM 
				%table:SRV% SRV (NOLOCK) 
			WHERE RV_FILIAL    = %xFilial:SRV% 
				AND RV_TIPOCOD = '1'
				AND RV_INCORP  = 'S' 
				AND RV_HE      = 'S'
				AND SRV.%NotDel% 
			ORDER BY 
				RV_COD
		EndSql
		//MemoWrite(GetTempPath()+cRotina+"_QRY_001.txt",GetLastQuery()[02])
		dbSelectArea(cTab)
		while !(cTab)->(EOF())
			if !empty(cPd)
				cPd += ","
			endif
			cPd += (cTab)->RV_COD
			dbSelectArea(cTab)
			(cTab)->(dbSkip())
		enddo
		(cTab)->(dbCloseArea())
		if !empty(cPd)
			if ',' $ cPd
				aPdTmp := Separa(cPd,",")
				for nX := 1 to Len(aPdTmp)
					if Len(aPd) > 0 .AND. FLocaliaPd(aPdTmp[nX]) > 0 .AND. aPd[FLocaliaPd(aPdTmp[nX]),9] <> "D"
						nSalInc := Round(aPd[FLocaliaPd(aPdTmp[nX]),5],TamSx3("RC_VALOR")[02])
					endif
				next nX
			endif		
		endif		
		nSalHora 	:= Round((SRA->RA_SALARIO + nSalInc) / (nDiasC * SRA->RA_HRSDIA),TamSx3("RA_HRSDIA")[02])
		cPd 		:= SuperGetMV("MV_XRUBADN",.F.,"018,019")
		if !empty(cPd)
			if ',' $ cPd
				aPdTmp := Separa(cPd,",")
				for nX := 1 to Len(aPdTmp)
					if Len(aPd) > 0 .AND. FLocaliaPd(aPdTmp[nX]) > 0 .AND. aPd[FLocaliaPd(aPdTmp[nX]),9] <> "D"
						nPerc := Posicione("SRV",1,FWFilial("SRV")+aPdTmp[nX],"RV_PERC")
						if nPerc > 0
							aPd[FLocaliaPd(aPdTmp[nX]),5] := Round((nSalHora * (nPerc/100)) * aPd[FLocaliaPd(aPdTmp[nX]),4],TamSx3("RC_VALOR")[02])
						endif
					endif
				next nX
			endif		
		endif	
	endif
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
return