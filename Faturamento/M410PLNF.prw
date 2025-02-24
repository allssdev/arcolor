#include "totvs.ch"
/*/{Protheus.doc} M410PLNF
Ponto de Entrada chamado após o cálculo da planilha financeira do pedido de vendas, utilizado para alterar as regras de cálculo no controle do CD. [Específico para a Arcolor (CD Control)]
@author Anderson C. P. Coelho
@since 19/02/2013
@version 1.0
@param aCabPed, array, Informações do cabeçalho do pedido de vendas.
@param aItemPed, array, Itens do pedido de vendas.
@param cAliasSC5, characters, Alias do pedido de vendas (SC5).
@type function
@see https://allss.com.br
@history 23/12/2020, Anderson C. P. Coelho, Correção de error.log na chamada da rotina de criação da SX3 pela função OpenSxs.
@history 24/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Correção de error_log conforme documentação ao longo do código-fonte.
/*/
user function M410PLNF(aCabPed,aItemPed,cAliasSC5)
	local _aSvAr      := GetArea()
	local _aSvSC5     := SC5->(GetArea())
	local _aSvSC6     := SC6->(GetArea())
	local _aSvSF4     := SF4->(GetArea())
	local _aSvSF7     := SF7->(GetArea())
	local _aSvSFM     := SFM->(GetArea())
	local _aSvSA1     := SA1->(GetArea())
	local _aSvSA2     := SA2->(GetArea())
	local _aSvSA4     := SA4->(GetArea())
	local _aSvSB1     := SB1->(GetArea())
	local _aColBk     := {}
	local aFields     := {}
	local _aParBkp    := {}
	local _nContPar   := 1
	local _nItens     := 0
	local _nLenaHea   := 0
	local nPTotal     := 0
	local nPValDesc   := 0
	local nPPrUnit    := 0
	local nPPrcVen    := 0
	local nPQtdVen    := 0
	local nPDtEntr    := 0
	local nPProduto   := 0
	local nPTES       := 0
	local nPNfOri     := 0
	local nPSerOri    := 0
	local nPItemOri   := 0
	local nPIdentB6   := 0
	local nPItem      := 0
	local nPProvEnt   := 0
	local nPosCfo	  := 0
	local _nPosCF	  := 0
	local _nPosCalc   := 0
	local _nPosEsp    := 0
	local _nPArm      := 0
	local _nPQtEmp    := 0
	local _nPQtdLib   := 0
	local _nPQtEnt    := 0
	local _nParBk     := 0
	local nX          := 0
	local _x          := 0
	local _lCalcula   := .F.
//	local _cTpPv      := ""
	local _xTIPO      := ""
	local _cAliasSX3  := "SX3_"+GetNextAlias()
	//************************************************************
	// INICIO
	// ARCOLOR - Declaração de varíaveis para não gerar error_log
	// RODRIGO TELECIO em 24/08/2022
	//************************************************************
	local _lRet       := .T.
	// FIM
	//************************************************************
	default aCabPed   := {}
	default aItemPed  := {}
	default cAliasSC5 := "M"

	//Guardo os parâmetros e refaço para que o faturamento não saia prejudicado
	_xTIPO := 'Type("MV_PAR"+StrZero(_nContPar,2))'
	while &_xTIPO <> "U"
		AADD(_aParBkp,{("MV_PAR"+StrZero(_nContPar,2)),&("MV_PAR"+StrZero(_nContPar,2))})
		_nContPar++
	enddo
	if Select(_cAliasSX3) > 0
		(_cAliasSX3)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
	if len(aItemPed) > 0 .AND. len(aCabPed) > 0		//Arrays preenchidos pelo relatório RMATR730 (Pré-Nota)
		aCols      := aClone(aItemPed)
		cAliasSC5  := "SC5"
		aFields    := {	"C6_ITEM"					,;		//1
						"C6_PRODUTO"				,;		//2
						"C6_DESCRI"					,;		//3
						"C6_TES"					,;		//4
						"C6_CF"						,;		//5
						"C6_UM"						,;		//6
						"C6_QTDVEN"					,;		//7
						"C6_PRCVEN"					,;		//8
						"C6_NOTA"					,;		//9
						"C6_SERIE"					,;		//10
						"C6_CLI"					,;		//11
						"C6_LOJA"					,;		//12
						"C6_VALOR"					,;		//13
						"C6_ENTREG"					,;		//14
						"C6_DESCONT"				,;		//15
						"C6_LOCAL"					,;		//16
						"C6_QTDEMP"					,;		//17
						"C6_QTDLIB"					,;		//18
						"C6_QTDENT"					,;		//19
						"C6_COD_E"					,;		//20
						"C6_TPCALC"					,;		//21
						"C6_VALDESC"				,;		//22
						"C6_PRUNIT"					,;		//23
						"C6_NFORI"					,;		//24
						"C6_SERIORI"				,;		//25
						"C6_ITEMORI"				,;		//26
						"C6_IDENTB6"				,;		//27
						"C6_CLASFIS"				 }		//28
		aHeader    := {}
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(2))
		for nX := 1 to len(aFields)
			if (_cAliasSX3)->(MsSeek(aFields[nX],.T.,.F.))
				AADD(aHeader,{	(_cAliasSX3)->X3_TITULO,;
								(_cAliasSX3)->X3_CAMPO      ,;
								(_cAliasSX3)->X3_PICTURE    ,;
								(_cAliasSX3)->X3_TAMANHO    ,;
								(_cAliasSX3)->X3_DECIMAL    ,;
								(_cAliasSX3)->X3_VALID      ,;
								(_cAliasSX3)->X3_USADO      ,;
								(_cAliasSX3)->X3_TIPO       ,;
								(_cAliasSX3)->X3_F3         ,;
								(_cAliasSX3)->X3_CONTEXT    ,;
								(_cAliasSX3)->X3_CBOX       ,;
								(_cAliasSX3)->X3_RELACAO      } )
			endif
		next nX
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5") + aCabPed[07],.T.,.F.))
	else
		_nLenaHea  := len(aHeader)
	endif
	nPTotal    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"  })
	nPValDesc  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
	nPPrUnit   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT" })
	nPPrcVen   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN" })
	nPQtdVen   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN" })
	nPDtEntr   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENTREG" })
	nPProduto  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	nPTES      := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"    })
	nPNfOri    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"  })
	nPSerOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
	nPItemOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
	nPIdentB6  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
	nPItem     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"   })
	nPosCfo	   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CF"     })
	_nPosCF    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CLASFIS"})
	_nPosCalc  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TPCALC" })
	_nPosEsp   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_COD_E"  })
	_nPArm     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"  })
	_nPQtEmp   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDEMP" })
	_nPQtdLib  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB" })
	_nPQtEnt   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDENT" })
	_aColBk    := aClone(aCols)
	_nItens    := Len(aCols)
	if AllTrim(&(cAliasSC5+"->C5_TIPO")) == "N"
		Pergunte("MTA410",.F.)
		for _x := 1 to len(aCols)
			if len(aItemPed) == 0
				//Pergunte("MTA410",.F.)
				if MV_PAR04 == 1 .AND. aCols[_x][Len(aHeader)] > 0	//Tratamento dado apenas para o Pedido de Vendas, uma vez que o relatório do Pré-Nota já realiza os seus filtros
					dbSelectArea("SC6")
					SC6->(dbSetOrder(1))
					SC6->(dbGoTo(aCols[_x][Len(aHeader)]))
					if SC6->(EOF()) .OR. SC6->C6_QTDENT >= SC6->C6_QTDVEN .OR. SC6->C6_BLQ == "R"
						Loop
					endif
				endif
			endif
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			if !SB1->(MsSeek(xFilial("SB1") + aCols[_x][nPProduto],.T.,.F.))
				Loop
			endif
			if _nLenaHea == 0 .OR. !aCols[_x][_nLenaHea+1]
				//A1_TPDIV: 0=0;1=33,33;2=50;3=66,66;4=100;5=DUPLO		{%Normal}
				_lQuant   := .T.
				_lCalcula := .F.
				_nFator   := 1
				if &(cAliasSC5+"->C5_TPDIV") == "0"
					_nFator   := 0
					_lCalcula := .T.
				elseif &(cAliasSC5+"->C5_TPDIV") == "1"
					_nFator   := 0.3333
					_lCalcula := .T.
					_lQuant   := AllTrim(aCols[_x][_nPosCalc]) == "Q"
				elseif &(cAliasSC5+"->C5_TPDIV") == "2"
					_nFator   := 0.5
					_lCalcula := .T.
					_lQuant   := AllTrim(aCols[_x][_nPosCalc]) == "Q"
				elseif &(cAliasSC5+"->C5_TPDIV") == "3"
					_nFator   := 0.6666
					_lCalcula := .T.
					_lQuant   := AllTrim(aCols[_x][_nPosCalc]) == "Q"
				elseif &(cAliasSC5+"->C5_TPDIV") == "4"
					_nFator   := 1
					_lCalcula := .F.
				elseif &(cAliasSC5+"->C5_TPDIV") == "5"
					_nFator   := 0.5
					_lCalcula := .T.
					_lQuant   := .T.
				endif
				if _lCalcula
					if !_lQuant .AND. !Empty(SB1->B1_COD_E) //.AND. Empty(aCols[_x][_nPosEsp])
						_aColBk[_x][_nPosEsp] := SB1->B1_COD_E
					endif
					dbSelectArea("SF4")
					SF4->(dbSetOrder(1))
					if SF4->(MsSeek(xFilial("SF4") + aCols[_x][nPTES],.T.,.F.)) .AND. ;
							((_lQuant.AND.!Empty(SF4->F4_TESALTQ)).OR.(!_lQuant.AND.!Empty(SF4->F4_TESALTV))) .AND. ;
							AllTrim(SF4->F4_DUPLIC)=="S"
						MAFISALT("IT_PRCUNI"  ,aCols[_x][nPPrcVen],_x)
						MAFISALT("IT_DESCONTO",0                  ,_x)
						_nQtVda   := MAFISRET(_x,"IT_QUANT"   )
						_nPreco   := MAFISRET(_x,"IT_PRCUNI"  )
						_nDesco   := MAFISRET(_x,"IT_DESCONTO")
						MAFISALT("IT_VALMERC", a410Arred(_nQtVda*_nPreco, "D2_TOTAL"), _x)
						_nVlMerc  := MAFISRET(_x,"IT_VALMERC" )
						_nQtVdaA  := 0
						_nPrecoA  := 0
						_nVlMercA := 0
						_cRVarBkp := ReadVar()
						_nBkp     := IIF(Type("n")<>"U",n,1)
						_cBkpCpo  := aCols[_x][nPTes  ]
						_cBkCfo   := aCols[_x][nPosCfo]
						_cBkClFis := aCols[_x][_nPosCF]
						if _nFator == 0
							__ReadVar := "M->C6_TES"
							aCols[_x][nPTes] := &(__ReadVar) := IIF(_lQuant,SF4->F4_TESALTQ,SF4->F4_TESALTV)
							MAFISALT("IT_TES",IIF(_lQuant,SF4->F4_TESALTQ,SF4->F4_TESALTV),_x)
							if AllTrim(cAliasSC5) == "M"
								if (_cAliasSX3)->(MsSeek("C6_TES",.T.,.F.))
									_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
									if !Empty(_cValid)
										_lRet := &_cValid
										Alert("Erro apresentado, relativo ao TES " + aCols[_x][nPTes] + ". O TES original será retomado!")
									endif
								endif
								if _lRet .AND. ExistTrigger("UB_TES")
									RunTrigger(2,_x)
									EvalTrigger()
								else
									aCols[_x][nPTes] := &(__ReadVar) := _cBkpCpo
								endif
							endif
							n         := _nBkp
							__ReadVar := _cRVarBkp
						elseif _nFator <> 1
							_lRet     := .T.
							__ReadVar := "M->C6_TES"
							aCols[_x][nPTes] := &(__ReadVar) := IIF(_lQuant,SF4->F4_TESALTQ,SF4->F4_TESALTV)
							if AllTrim(cAliasSC5) == "M"
								if (_cAliasSX3)->(MsSeek("C6_TES",.T.,.F.))
									_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
									if !Empty(_cValid)
										if !(_lRet := &_cValid)
											Alert("Erro apresentado, relativo ao TES " + aCols[_x][nPTes] + ". O TES original será retomado!")
										endif
									endif
								endif
							endif
							aCols[_x][nPTes  ] := &(__ReadVar) := _cBkpCpo
							aCols[_x][nPosCfo] := _cBkCfo
							aCols[_x][_nPosCF] := _cBkClFis
							n                  := _nBkp
							__ReadVar          := _cRVarBkp
							if _lRet
								_nItens++
								if _lQuant
	//								_nQtVdaA  := Round(_nQtVda *_nFator, 0)		//a410Arred(_nQtVda *_nFator , "D2_QUANT" )
									_nQtVdaA  := (_nQtVda *_nFator)				//a410Arred(_nQtVda *_nFator , "D2_QUANT" )
									if INT(_nQtVdaA) == 0
										_nQtVdaA  := 1
									endif
									_nQtVdaA  := Round(_nQtVdaA,0)
									_nVlMercA := a410Arred(_nQtVdaA*_nPreco , "D2_TOTAL" )
									MAFISALT("IT_QUANT"   , _nQtVdaA , _x)
									MAFISALT("IT_VALMERC" , _nVlMercA, _x)
								else
									_nPrecoA  := a410Arred(_nPreco *_nFator , "D2_PRCVEN")
									_nVlMercA := a410Arred(_nQtVda *_nPrecoA, "D2_TOTAL" )
									MAFISALT("IT_QUANT"   , _nQtVda  , _x)
									MAFISALT("IT_VALMERC" , _nVlMercA, _x)
								endif
								_cTES := IIF(_lQuant,SF4->F4_TESALTQ,SF4->F4_TESALTV)
								dbSelectArea("SF4")
								SF4->(dbSetOrder(1))
								if SF4->(MsSeek(xFilial("SF4") + aCols[_x][nPTES],.T.,.F.)) .AND. ((_lQuant.AND.!Empty(SF4->F4_TESALTQ)).OR.(!_lQuant.AND.!Empty(SF4->F4_TESALTV))) .AND. AllTrim(SF4->F4_DUPLIC)=="S"
									if SF4->(MsSeek(xFilial("SF4") + IIF(_lQuant,SF4->F4_TESALTQ,SF4->F4_TESALTV),.T.,.F.))
										_cTES := SF4->F4_CODIGO
									endif
								endif
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Agrega os itens para a funcao fiscal         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								MaFisAdd(	aCols[_x][nPProduto],;   	// 1-Codigo do Produto ( Obrigatorio )
											_cTES ,;	// 2-Codigo do TES ( Opcional )
											a410Arred(_nQtVda-_nQtVdaA,"D2_QUANT"),;  	// 3-Quantidade ( Obrigatorio )
											a410Arred(_nPreco-_nPrecoA,"D2_PRCVEN"),;	// 4-Preco Unitario ( Obrigatorio )
											_nDesco,; 			// 5-Valor do Desconto ( Opcional )
											"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
											"",;				// 7-Serie da NF Original ( Devolucao/Benef )
											/*nRecOri*/,;		// 8-RecNo da NF Original no arq SD1/SD2
											0,;					// 9-Valor do Frete do Item ( Opcional )
											0,;					// 10-Valor da Despesa do item ( Opcional )
											0,;					// 11-Valor do Seguro do item ( Opcional )
											0,;					// 12-Valor do Frete Autonomo ( Opcional )
											a410Arred(_nVlMerc-_nVlMercA,"D2_TOTAL") )			// 13-Valor da Mercadoria ( Obrigatorio )
							else
								_nItens--
							endif
						endif
					endif
				endif
			endif
		next
		if AllTrim(cAliasSC5) == "M"
			&(cAliasSC5+"->C5_ACRCALC") := MaFisRet(,"NF_VALIPI") + MaFisRet(,"NF_VALSOL")
		endif
	endif
	aCols := aClone(_aColBk)
	//Retomo os parâmetros anteriormente preservados
		_nContPar := 1
		for _nParBk := 1 to len(_aParBkp)
			&(_aParBkp[_nParBk][01]) := _aParBkp[_nParBk][02]
		next
	//Fim da Retomada dos parâmetros anteriormente preservados
	if Select(_cAliasSX3) > 0
		(_cAliasSX3)->(dbCloseArea())
	endif
	RestArea(_aSvSC5)
	RestArea(_aSvSC6)
	RestArea(_aSvSF4)
	RestArea(_aSvSF7)
	RestArea(_aSvSFM)
	RestArea(_aSvSA1)
	RestArea(_aSvSA2)
	RestArea(_aSvSA4)
	RestArea(_aSvSB1)
	RestArea(_aSvAr )
return
