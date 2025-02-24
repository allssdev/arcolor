#include "totvs.ch"
/*/{Protheus.doc} RTMKE007
@description EXECBLOCK  para disparar os gatilhos apartir do campo cód. do cliente no callcenter.
@author Renan Felipe
@since 29/12/2012
@version 1.0
@return _lRet, Retorno ok?
@type function
@see https://allss.com.br
/*/
user function RTMKE007()
	//No Início da rotina, salvar o ReadVar:
	local   _aSavArea  := GetArea()
	local   _nBkp      := n
	local   _nPVerRn   := aScan(aHeader,{|x|AllTrim(x[02])==IIF(AllTrim(FunName())$"/MATA410/MATA440/","C6_VERIFRN","UB_VERIFRN")})
	local   _nPPrd     := aScan(aHeader,{|x|AllTrim(x[02])==IIF(AllTrim(FunName())$"/MATA410/MATA440/","C6_PRODUTO","UB_PRODUTO")})
	local   _nPAcrP    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREPOR"})
	local   _nPAcr     := aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACRE"   })
	local   _nPAcrV    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREVAL"})
	local   _nPVAcr    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALACRE"})
	local   _nPDesc    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESC"   })
	local   _nPVDes    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDESC"})
	local   _nPDescA   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCAUX"})
	local   _nPVDesA   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDAUX"})
	local   _lRet      := .T.
	local   _lRTMKE017 := ExistBlock("RTMKE017")		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o P.E. existe ou não (várias vezes).
	local   _cRotina   := "RTMKE007"

	// Início - Trecho adicionado por Adriano Leonardo em 24/06/2014 para adicionar validação no campo de tipo de operação
	if ((FunName()=="TMKA271" .OR. FunName()=="MATA410" .OR. FunName()=="MATA440" .OR. AllTrim(FunName())=="RTMKI001" .OR. AllTrim(FunName())=="RPC") .AND. ("_TPOPER" $ ReadVar()))
		_cTpOper := ReadVar()
		_lRet := ExistCpo("SX5","DJ"+&_cTpOper)
		if !_lRet
			return _lRet
		endif
	endif
	// Final  - Trecho adicionado por Adriano Leonardo em 24/06/2014 para adicionar validação no campo de tipo de operação
	if Existblock("RTMKE006") .AND. (INCLUI .OR. ALTERA)
		dbSelectArea("SA1")
		_aSavSA1 := SA1->(GetArea())
		dbSelectArea("SUS")
		_aSavSUS := SUS->(GetArea())
		dbSelectArea("SB1")
		_aSavSB1 := SB1->(GetArea())
		dbSelectArea("SF4")
		_aSavSF4 := SF4->(GetArea())
		dbSelectArea("SUA")
		_aSavSUA := SUA->(GetArea())
		dbSelectArea("SUB")
		_aSavSUB := SUB->(GetArea())
		dbSelectArea("SC5")
		_aSavSC5 := SC5->(GetArea())
		dbSelectArea("SC6")
		_aSavSC6 := SC6->(GetArea())
		dbSelectArea("SC9")
		_aSavSC9 := SC9->(GetArea())
		//TK273DesCab()
		if AllTrim(ReadVar()) == "M->UB_PRODUTO"
			_nCont := _nReg  := n
		else
			_nReg  := 1
			_nCont := Len(aCols)
			//Início - Trecho adicionado por Adriano Leonardo em 24/06/2014 para inibir validação dos itens enquanto só existir uma linha em branco
				if Len(aCols) == 1	.And. Empty(aCols[n,_nPPrd])
					_nCont := 0
				endif
			//Final  - Trecho adicionado por Adriano Leonardo em 24/06/2014 para inibir validação dos itens enquanto só existir uma linha em branco
		endif
		for n := _nReg to _nCont
			_nBkpFor := n
			if aCols[n][Len(aHeader)+1]
				Loop
			endif
			if Altera .AND. _nPVerRn > 0
				aCols[n][_nPVerRn] := ""
			endif
			MsgRun("Aguarde... Atualizando o item "+AllTrim(aCols[n][_nPPrd])+"...",_cRotina,{ || Execblock("RTMKE006") })
			if AllTrim(FunName())<>"MATA410" .AND. AllTrim(FunName())<>"MATA440"
				_lContin := (aCols[n][_nPAcrP ] > 0 .AND. aCols[n][_nPAcrP ] <> aCols[n][_nPAcr ]) .OR. ;
							(aCols[n][_nPAcrV ] > 0 .AND. aCols[n][_nPAcrV ] <> aCols[n][_nPVAcr]) .OR. ;
							(aCols[n][_nPDescA] > 0 .AND. aCols[n][_nPDescA] <> aCols[n][_nPDesc]) .OR. ;
							(aCols[n][_nPVDesA] > 0 .AND. aCols[n][_nPVDesA] <> aCols[n][_nPVDes])
				if _lContin
					if _lRTMKE017		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: ExistBlock("RTMKE017")
						n := _nBkpFor
						MsgRun("Aguarde... Atualizando o produto "+AllTrim(aCols[n][_nPPrd])+"...",_cRotina,{ || U_RTMKE017("I") })
					endif
				endif
			endif
			n := _nBkpFor
		next
		n := _nBkp
		RestArea(_aSavSA1)
		RestArea(_aSavSUS)
		RestArea(_aSavSB1)
		RestArea(_aSavSF4)
		RestArea(_aSavSUA)
		RestArea(_aSavSUB)
		RestArea(_aSavSC5)
		RestArea(_aSavSC6)
		RestArea(_aSavSC9)
	endif
	RestArea(_aSavArea)
return _lRet
