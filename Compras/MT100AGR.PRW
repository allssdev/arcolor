#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MT100AGR
@description Ponto de Entrada após a finalização de gravação do docto. de entrada e após a gravação de seus títulos a pagar correspondentes.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/01/2013
@version 1.0
@history 31/01/2014, Adriano Leonardo, Portador (default) do título.
@type function
@see https://allss.com.br
/*/
user function MT100AGR()
	Local _aSavArea  := GetArea()
	Local _aSavSCR   := SCR->(GetArea())
	Local _aSavSE2   := SE2->(GetArea())
	Local _aSavSE1   := SE1->(GetArea())
	Local _aSavSD1   := SD1->(GetArea())
	Local _aSavSF1   := SF1->(GetArea())
	Local _aPC       := {}
	Local _lRet      := .T.
	Local _lSemPC    := .F.
	//Local _cRotina   := "MT100GRV"
	Local _cNomUsr   := cUserName
	Local _dDtLib    := dDataBase
	Local _MVBCOPRIN := SuperGetMV("MV_BCOPRIN",,"001")

	if !AllTrim(SF1->F1_TIPO) $ "D|B"
		//TRECHO DE LIBERAÇÃO PARA PAGAMENTO DOS TÍTULOS A PAGAR, UMA VEZ QUE JÁ FORAM APROVADOS NAS ALÇADAS DE COMPRAS
		if SuperGetMv("MV_CTLIPAG",,.T.)
			dbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			if SD1->(MsSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.T.,.F.))
				while !SD1->(EOF()) .AND. (SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)==(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
					if !_lSemPC
						if Empty(SD1->D1_PEDIDO)
							_lSemPC := .T.
						elseif aScan(_aPC,{|x|AllTrim(x[01])==AllTrim(SD1->D1_PEDIDO)}) == 0
							AADD(_aPC,{SD1->D1_PEDIDO})
						endif
					endif
					dbSelectArea("SD1")
					SD1->(dbSetOrder(1))
					SD1->(dbSkip())
				EndDo
				If !_lSemPC
					_aPC := aSort(_aPC,,,{|x,y|x[01] > y[01]})
					for _x := 1 to Len(_aPC)
						dbSelectArea("SCR")
						SCR->(dbOrderNickName("CR_USER"))		//SCR->(dbSetOrder(2))
						if SCR->(MsSeek(xFilial("SCR") + "PC" + Padr(_aPC[_x][01],TamSx3("CR_NUM")[01]),.T.,.F.))
							while !SCR(EOF()) .AND. ;
								SCR->CR_FILIAL == xFilial("SCR") .AND. ;
								SCR->CR_NUM    == Padr(_aPC[_x][01],TamSx3("CR_NUM")[01]) .AND. ;
								_cNomUsr <> PswRet()[01][02] .AND. _dDtLib <> SCR->CR_DATALIB
								PswOrder(2)
								if PswSeek(SCR->CR_USER,.T.)
									_dDtLib  := SCR->CR_DATALIB
									_cNomUsr := PswRet()[01][02]
								endif
								dbSelectArea("SCR")
								SCR->(dbOrderNickName("CR_USER"))		//SCR->(dbSetOrder(2))
								SCR->(dbSkip())
							enddo
						endif
					next
				endif
			endif
		endif
		dbSelectArea("SE2")
		SE2->(dbSetOrder(6))
		SE2->(dbGoTop())
		if SE2->(MsSeek(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DUPL,.T.,.F.))
			While !SE2->(EOF()) .AND. SE2->E2_FILIAL == xFilial("SE2") .AND. (SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM) == (SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DUPL)
				while !RecLock("SE2",.F.) ; enddo
					if !_lSemPC
						SE2->E2_DATALIB := dDataBase
						SE2->E2_USUALIB := _cNomUsr
					endif
					SE2->E2_PORTADO := _MVBCOPRIN		//Linha adicionada por Adriano Leonardo em 31/01/2014 para definição de portador default do título a pagar	//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SE2->E2_PORTADO := SuperGetMV("MV_BCOPRIN",,"001")
				SE2->(MSUNLOCK())
				dbSelectArea("SE2")
				SE2->(dbSetOrder(6))
				SE2->(dbSkip())
			enddo
		endif
	//Início do trecho adicionado por Adriano Leonardo em 13/08/2013, para gravar o campo E1_VEND1 nos títulos NCCs (notas de devolução)
	elseif AllTrim(SF1->F1_TIPO) $ "D|B"
		dbSelectArea("SE1")
		SE1->(dbSetOrder(2))
		SE1->(dbGoTop())
		if SE1->(MsSeek(xFilial("SE1") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DUPL,.T.,.F.))
			while !SE1->(EOF()) .AND. SE1->E1_FILIAL == xFilial("SE1") .AND. (SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM) == (SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DUPL)
				while !RecLock("SE1",.F.) ; enddo
					SE1->E1_VEND1 := Posicione("SA1",1,xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA,"A1_VEND")
				SE1->(MSUNLOCK())
				dbSelectArea("SE1")
				SE1->(dbSetOrder(2))
				SE1->(dbSkip())
			enddo
		endif
	//Fim do trecho adicionado por Adriano Leonardo em 13/08/2013
	endif
	RestArea(_aSavSE1)
	RestArea(_aSavSCR)
	RestArea(_aSavSE2)
	RestArea(_aSavSD1)
	RestArea(_aSavSF1)
	RestArea(_aSavArea)
return(_lRet)