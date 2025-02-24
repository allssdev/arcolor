#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} RPCPR004
ExecBlock responsável por realizar o cálculo da necessidade de um produto no ajuste de empenho com base na quantidadea ser recuperada (saldo empenhado).
@author Adriano Leonardo
@since 24/09/2013
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br
@history 14/09/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adequação de rotina para funcionamento na rotina Empenho Multiplo (MATA381).
/*/
user function RPCPR004()
Local _aSavArea 	:= GetArea()
Local _aSavSC2  	:= SC2->(GetArea())
Local _nRet     	:= 0
local nPosQtd    	:= 0
local nPosQtdOri	:= 0
local nPosQtdAnt    := 0
local nPosQtdRec	:= 0
local nPosEmpAnt	:= 0
//Empenho Simples
if AllTrim(FunName()) $ "MATA380"
	_nRet     		:= M->D4_QUANT
	//Verifica se este empenho está vinculado a uma ordem de produção
	if Empty(M->D4_OP)
		return(_nRet)
	endif
	_nQtdAnte 		:= M->D4_QTDANTE //M->D4_EMPANTE
	_nQtdOrdP 		:= M->D4_QTDEORI
	//Faz os cálculos do saldo de empenho, com base nos ajustes feitos por conta da recuperação de produtos
	if M->D4_QTDRECU < 0
		_nRet 		:= M->D4_EMPANTE + (_nQtdOrdP - _nQtdAnte)//_nQtdAnte - (_nQtdAnte-_nQtdOrdP)
	elseif _nQtdAnte <= _nQtdOrdP
		_nRet 		:= M->D4_EMPANTE + (_nQtdOrdP - _nQtdAnte)
	elseif _nQtdAnte > _nQtdOrdP
		_nRet 		:= _nQtdAnte + (_nQtdAnte - _nQtdOrdP)
	endif
//Empenho Múltiplo	
elseif AllTrim(FunName()) $ "MATA381"
	nPosQtd    		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_QUANT"  })
	nPosQtdOri		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_QTDEORI"})
	nPosQtdAnt    	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_QTDANTE"})
	nPosQtdRec		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_QTDRECU"})
	nPosEmpAnt		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_EMPANTE"})
	nPosCompon		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_COD"})
	nPosProdut		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D4_PRODUTO"})
	if !aCols[n,Len(aHeader) + 1]
		_nRet     		:= aCols[n,nPosQtd]
		_cComp			:= aCols[n,nPosCompon]
		_cProd			:= aCols[n,nPosProdut]
		//Verifica se este empenho está vinculado a uma ordem de produção
		if Empty(cOP)
			return(_nRet)
		endif
		_nQtdAnte 		:= aCols[n,nPosQtdAnt] //M->D4_EMPANTE
		_nQtdOrdP 		:= aCols[n,nPosQtdOri]
		_nQtdSld		:= aCols[n,nPosQtd]
		
		//Faz os cálculos do saldo de empenho, com base nos ajustes feitos por conta da recuperação de produtos
		if aCols[n,nPosQtdRec] < 0
			_nRet 		:= aCols[n,nPosEmpAnt] + (_nQtdOrdP - _nQtdAnte)//_nQtdAnte - (_nQtdAnte-_nQtdOrdP)
		elseif _nQtdAnte <= _nQtdOrdP
			_nRet 		:= aCols[n,nPosEmpAnt] + (_nQtdOrdP - _nQtdAnte)
			//_nRet 		:= _nQtdSld + (_nQtdOrdP - _nQtdAnte )
		elseif _nQtdAnte > _nQtdOrdP
			_nRet 		:= _nQtdAnte + (_nQtdAnte - _nQtdOrdP)
		endif
	endif
endif
RestArea(_aSavSC2)
RestArea(_aSavArea)
return(_nRet)
