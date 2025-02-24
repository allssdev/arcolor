#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} RPCPR003
ExecBlock responsável por realizar o cálculo da necessidade de um produto no ajuste de empenho com base na quantidade a ser recuperada. (Empenho)
@author Adriano Leonardo
@since 24/09/2013
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br
@history 14/09/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adequação de rotina para funcionamento na rotina Empenho Multiplo (MATA381).
@history 22/02/2024, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação de rotina para funcionamento quando houver mais de um lote no empenho
/*/
user function RPCPR003()               
local _aSavArea 	:= GetArea()
local _aSavSC2  	:= SC2->(GetArea())	
local _nRet     	:= 0
local nPosQtdOri    := 0
local nPosQtdAnt    := 0
local nPosQtdRec	:= 0
local nPosCompon	:= 0
local nPosProdut	:= 0
Local _cComp		:= ""
Local _cProd		:= ""
//Empenho Simples
if AllTrim(FunName()) $ "MATA380"
	_nRet     		:= M->D4_QTDEORI
	//Verifica se este empenho está vinculado a uma ordem de produção
	if Empty(M->D4_OP)
		RestArea(_aSavSC2)
		RestArea(_aSavArea)
		return(_nRet)
	endif
	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))
	SC2->(dbGoTop())
	if SC2->(MsSeek(FwFilial("SC2") + M->D4_OP,.T.,.F.))
		_nQtdAnte 	:= M->D4_QTDANTE // Quantidade anterior (Quantidade original do empenho)
		_nQtdOrdP 	:= SC2->C2_QUANT // Quantidade definida na ordem de produção
		_nQtdRecu 	:= M->D4_QTDRECU // Quantidade do produto a ser recuperada
		//Proporcionaliza o empenho com base na quantidade a ser recuperada
		_nRet 		:= (_nQtdAnte / _nQtdOrdP) * (_nQtdOrdP + _nQtdRecu)
	endif
//Empenho Múltiplo	
elseif Alltrim(FunName()) $ "MATA381"
	nPosQtdOri    	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_QTDEORI"})
	nPosQtdAnt   	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_QTDANTE"})
	nPosQtdRec		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_QTDRECU"})
	nPosCompon		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_COD"})
	nPosProdut		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_PRODUTO"})
	if !aCols[n,Len(aHeader) + 1]
		_nRet     		:= aCols[n,nPosQtdOri]
		_cComp			:= aCols[n,nPosCompon]
		_cProd			:= aCols[n,nPosProdut]
		//Verifica se este empenho está vinculado a uma ordem de produção
		if Empty(cOP)
			RestArea(_aSavSC2)
			RestArea(_aSavArea)
			return(_nRet)
		endif
		dbSelectArea("SC2")
		SC2->(dbSetOrder(1))
		SC2->(dbGoTop())
		if SC2->(MsSeek(FwFilial("SC2") + cOP,.T.,.F.))
			_nQtdAnte 	:= aCols[n,nPosQtdAnt] 	// Quantidade anterior (Quantidade original do empenho)
			_nQtdOrdP 	:= SC2->C2_QUANT 		// Quantidade definida na ordem de produção
			_nQtdRecu 	:= aCols[n,nPosQtdRec] 	// Quantidade do produto a ser recuperada
			BeginSql Alias "TMPSD4"
				SELECT SUM(D4_QTDEORI) D4_QTEORI,
	 				   SUM(D4_QUANT) D4_QUANT,
					   COUNT(*) AS QTDLOTE
				FROM %table:SD4% SD4 (NOLOCK)
				WHERE SD4.D4_FILIAL     = %xFilial:SD4%
				AND SD4.D4_COD     = %Exp:_cComp%
				AND SD4.D4_OP     = %Exp:cOP%
				AND SD4.%NotDel%
				HAVING COUNT(*) > 1
			EndSql
			_cQry :=  GetLastQuery()[2]
			dbSelectArea("TMPSD4")
			if TMPSD4->(!EOF())
				//Ajusta o empenho com base na quantidade total quando houver mais de um lote
				_nQtdTot	:= TMPSD4->D4_QTEORI
				_nRet 		:= (_nQtdTot / _nQtdOrdP) * (_nQtdOrdP + _nQtdRecu)-_nQtdTot+_nQtdAnte
			Else
				//Proporcionaliza o empenho com base na quantidade a ser recuperada
				_nRet 		:= (_nQtdAnte / _nQtdOrdP) * (_nQtdOrdP + _nQtdRecu)
			endif
			TMPSD4->(dbCloseArea())


		endif
	endif
endif
RestArea(_aSavSC2)
RestArea(_aSavArea)
return(_nRet)

/*	BeginSql Alias "ESTRUTURA"
				SELECT G1_FILIAL, G1_REVFIM, G1_COD, G1_COMP,G1_QUANT 
				FROM %table:SG1% SG1
				WHERE 
					SG1.G1_FILIAL = %xFilial:SG1%  
					AND SG1.G1_COD = %exp:_cProd%
					AND SG1.G1_COMP = %exp:_cComp%
					AND SG1.D_E_L_E_T_ = ''
				GROUP BY G1_FILIAL, G1_REVFIM, G1_COD, G1_COMP,G1_QUANT
				HAVING SG1.G1_REVFIM = (SELECT MAX(G1_REVFIM) FROM %table:SG1% WHERE G1_COD = SG1.G1_COD AND D_E_L_E_T_ = '')
			EndSql
*/
