#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} RFINA006
Rotina chamada para criar o título de ST no contas a pagar. Rotina foi criada temporariamente para esse fim, devido a Problema na rotina padrão de criação no faturamento via Coletor(Faturamento Automático).
@author Arthur Silva (ALLSS Soluções em Sistemas)
@since 10/04/2018
@version 1.0
@type function
@see https://allss.com.br
@history 19/04/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Alteração dos critérios de data de vencimento (F6_DTVENC) e data de pagamento (F6_DTPAGTO).
@history 13/05/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adequação para preenchimento dos campos necessários para GNRE 2.00.
@history 17/09/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adequação para geração da guia de recolhimento de ICMS-ST (FECP) para GNRE 2.00.
@history 14/10/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Correção para geração da guia de recolhimento de ICMS-ST (FECP) para GNRE 2.00.
@history 14/12/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Correção para geração da guia de recolhimento de ICMS-ST (FECP) com valor correto no título no contas a pagar para GNRE 2.00.
@history 26/04/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação do fonte para não gerar nota fiscal da rotina padrão MATA460A.
/*/
user function RFINA006()
local _aSavArea 	:= GetArea()
local _aSavSF2  	:= SF2->(GetArea())
local _cNumICM  	:= ""
local _cInsc		:= ""
local _cCnpj		:= ""
local _cNome		:= ""
local _cX5Tab		:= ""
local _cX5Chav		:= ""
local _cBanc    	:= ""
local _cOperNf  	:= "2"
local _cTpMov		:= "S"
local _cSX5TMP  	:= GetNextAlias()
local _cAliasSD2 	:= GetNextAlias()
local _cSerie   	:= SF2->F2_SERIE
local _cDoc     	:= SF2->F2_DOC
local _cClien   	:= SF2->F2_CLIENTE
local _cLoja    	:= SF2->F2_LOJA
local _nValSt    	:= SF2->F2_ICMSRET
local _nVlFecpST 	:= 0
local _cEst			:= SF2->F2_EST
local _cTpNf		:= SF2->F2_TIPO
local _nMes     	:= Month(ddatabase)
local _nAno     	:= Year(ddatabase)	
local _dData		:= ddatabase
local _nDVencto 	:= SuperGetMv("MV_DATAPAG",.F.,5)
local _lGerou 		:= .F.
local _cCodRec  	:= SuperGetMv("MV_RECEINF",.F.,'100099')
local _cCodFecp  	:= SuperGetMv("MV_GNFPDIF",.F.,'100129')
local _aRetPE		:= {}

//*******************************************************************************************
// INICIO
// ARCOLOR - Adequação para não gerar a guia de recolhimento de ICMS-ST (FECP) quando a nota 
// fiscal for gerada pela rotina MATA460A
// Diego Rodrigues em 26/04/2023
//**
If FUNNAME()<>"MATA460A"

//*******************************************************************************************
// INICIO
// ARCOLOR - Adequação para geração da guia de recolhimento de ICMS-ST (FECP) para GNRE 2.00.
// RODRIGO TELECIO em 16/09/2022
//*******************************************************************************************
	if Select(_cAliasSD2) > 0
		(_cAliasSD2)->(dbCloseArea())
	endif
	BeginSql Alias _cAliasSD2
		SELECT TOP 1
			SUM(SD2.D2_VFECPST) AS D2_VFECPST
		FROM
			%Table:SD2% AS SD2 (NOLOCK)
		WHERE
			SD2.D2_FILIAL 		= %xFilial:SD2%
			AND SD2.D2_DOC 		= %Exp:SF2->F2_DOC%
			AND SD2.D2_SERIE 	= %Exp:SF2->F2_SERIE%
			AND SD2.D2_CLIENTE 	= %Exp:SF2->F2_CLIENTE%
			AND SD2.D2_LOJA 	= %Exp:SF2->F2_LOJA%
			AND SD2.D2_EMISSAO  = %Exp:SF2->F2_EMISSAO%
			AND SD2.%NotDel%
	EndSql
	dbSelectArea(_cAliasSD2)
	(_cAliasSD2)->(dbGoTop())
	while !(_cAliasSD2)->(EOF())
		_nVlFecpST 	:= (_cAliasSD2)->D2_VFECPST
		(_cAliasSD2)->(dbSkip())
	enddo
	(_cAliasSD2)->(dbCloseArea())
	if _nVlFecpST > 0 .AND. _cEst <> "SP"
		_nValSt 		:= _nValSt - _nVlFecpST
		if Select(_cSX5TMP) > 0
			(_cSX5TMP)->(dbCloseArea())
		endif
		BeginSql Alias _cSX5TMP
			SELECT
				SX5.X5_TABELA, SX5.X5_CHAVE, SX5.X5_DESCRI
			FROM
				%Table:SX5% AS SX5 (NOLOCK)
			WHERE
				SX5.X5_FILIAL     = %xFilial:SX5%
				AND SX5.X5_TABELA = '53'
				AND SX5.X5_CHAVE  = 'ICMS'
				AND SX5.%NotDel%
		EndSql
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if SA1->(dbSeek(FwFilial("SA1") + _cClien + _cLoja,.T.,.F.))
			_cInsc 		:= SA1->A1_INSCR
			_cCnpj 		:= SA1->A1_CGC
			_cBanc 		:= SA1->A1_BCO1
		endif
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		if SA2->(dbSeek(FwFilial("SA2") + "FAZEND" + _cEst,.T.,.F.))
			_cNome 		:= SA2->A2_NREDUZ
		endif
		dbSelectArea(_cSX5TMP)
		(_cSX5TMP)->(dbGoTop())
		_cX5Tab	 		:= (_cSX5TMP)->X5_TABELA
		_cX5Chav 		:= (_cSX5TMP)->X5_CHAVE
		_cNumICM 		:= StrZero(Val((_cSX5TMP)->X5_DESCRI) + 1,TamSx3("E2_NUM")[01])
		dbSelectArea("SF6")
		SF6->(dbSetOrder(3))
		if !SF6->(dbSeek(FwFilial("SF6") + _cOperNf + _cTpNf + _cDoc + _cSerie + _cClien + _cLoja ,.T.,.F.))
			_lGerou := .T.
			while !RecLock("SF6",.T.) ;enddo
				SF6->F6_FILIAL  := xFilial("SF6")
				SF6->F6_NUMERO  := "ICM" + _cNumICM
				SF6->F6_EST     := _cEst
				SF6->F6_TIPOIMP := '3'
				SF6->F6_VALOR   := _nVlFecpST
				SF6->F6_INSC    := _cInsc
				SF6->F6_DTARREC := _dData
				SF6->F6_DTVENC  := DataValida(_dData + _nDVencto,.T.)
				SF6->F6_MESREF  := _nMes
				SF6->F6_ANOREF  := _nAno
				SF6->F6_CODREC  := _cCodFecp
				SF6->F6_DOC     := _cDoc
				SF6->F6_SERIE   := _cSerie
				SF6->F6_CLIFOR  := _cClien
				SF6->F6_LOJA    := _cLoja
				SF6->F6_OPERNF  := _cOperNf
				SF6->F6_TIPODOC := _cTpNf
				SF6->F6_DTPAGTO := DataValida(_dData + _nDVencto,.T.)
				SF6->F6_CNPJ    := _cCnpj
				SF6->F6_FECP    := '1'
				SF6->F6_SDOC    := '1'
				if ExistBlock("MA960GREC")
					_aRetPE := ExecBlock("MA960GREC",.F.,.F.,{_cCodFecp,_cEst})
					if Len(_aRetPE) > 0
						SF6->F6_TIPOGNU := StrZero(_aRetPE[1],2)
						SF6->F6_DOCORIG := _aRetPE[2]
						SF6->F6_DETRECE := _aRetPE[3]
						SF6->F6_CODPROD := _aRetPE[4]
					endif
				endif
			SF6->(MsUnlock())
		endif
		dbSelectArea("CDC")
		CDC->(dbSetOrder(1))
		if !CDC->(dbSeek(FwFilial("CDC") + _cTpMov + _cDoc + _cSerie + _cClien + _cLoja ,.T.,.F.)) .AND. _lGerou
			while !RecLock("CDC",.T.) ;enddo
				CDC->CDC_FILIAL  := FwFilial("CDC")
				CDC->CDC_TPMOV   := _cTpMov
				CDC->CDC_DOC     := _cDoc
				CDC->CDC_SERIE   := _cSerie
				CDC->CDC_CLIFOR  := _cClien
				CDC->CDC_LOJA    := _cLoja
				CDC->CDC_GUIA    := "ICM" + _cNumICM
				CDC->CDC_UF      := _cEst
				CDC->CDC_IFCOMP  := '000001'
				CDC->CDC_SDOC    := '1'
			CDC->(MsUnlock())
		endif
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1))
		if !SE2->(MsSeek(xFilial("SE2") + "ICM" + _cNumICM,.T.,.F.)) .AND. _lGerou
			while !RecLock("SE2",.T.) ;enddo
				SE2->E2_FILIAL  := xFilial("SE2")
				SE2->E2_PREFIXO := "ICM"
				SE2->E2_NUM     := _cNumICM 
				SE2->E2_TIPO    := "TX"
				SE2->E2_NATUREZ := "205035"
				SE2->E2_FORNECE := "FAZEND"
				SE2->E2_LOJA    := _cEst
				SE2->E2_NOMFOR  := _cNome
				SE2->E2_EMISSAO := _dData
				SE2->E2_VENCTO  := DataValida(_dData + _nDVencto,.T.)
				SE2->E2_VENCREA := DataValida(_dData + _nDVencto,.T.)
				SE2->E2_VALOR   := _nVlFecpST
				SE2->E2_EMIS1   := _dData
				SE2->E2_HIST    := "Nota Fiscal: " + _cDoc + "-" + _cSerie
				SE2->E2_LA	    := "N"
				SE2->E2_SALDO   := _nVlFecpST
				SE2->E2_VENCORI := DataValida(_dData + _nDVencto,.T.)
				SE2->E2_MOEDA   := 1
				SE2->E2_VLCRUZ  := _nVlFecpST
				SE2->E2_FLUXO   := ""
				SE2->E2_ORIGEM  := "MATA460A"
				SE2->E2_PORTADO := _cBanc
				SE2->E2_FILORIG := "01"
			SE2->(MsUnlock())
		endif
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
		if SF2->(dbSeek(FwFilial("SF2") + _cDoc + _cSerie,.T.,.F.)) .AND. _lGerou
			while !RecLock("SF2",.F.) ;enddo
				SF2->F2_NTFECP 	:= "ICM" + _cNumICM
			SF2->(MsUnlock())
		endif
		dbSelectArea("SX5")
		SX5->(dbSetOrder(1))  //X5_TABELA+X5_CHAVE                                                                                                  
		if SX5->(dbSeek(FwFilial("SX5") + _cX5Tab + _cX5Chav,.T.,.F.)) .AND. _lGerou
			while !RecLock("SX5",.F.) ;enddo
				SX5->X5_DESCRI  := _cNumICM
				SX5->X5_DESCSPA := _cNumICM
				SX5->X5_DESCENG := _cNumICM
			SX5->(MsUnlock())
		endif
	endif
// FIM
//*******************************************************************************************
	if _nValSt > 0 .AND. _cEst <> "SP"
		if Select(_cSX5TMP) > 0
			(_cSX5TMP)->(dbCloseArea())
		endif
		BeginSql Alias _cSX5TMP
			SELECT X5_TABELA, X5_CHAVE, X5_DESCRI
			FROM %Table:SX5% SX5 (NOLOCK)
			WHERE X5_FILIAL   	= %xFilial:SX5%
				AND X5_TABELA 	= '53'
				AND X5_CHAVE  	= 'ICMS'
				AND SX5.%NotDel%
		EndSql
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if SA1->(MsSeek(xFilial("SA1") + _cClien + _cLoja,.T.,.F.))
			_cInsc := SA1->A1_INSCR
			_cCnpj := SA1->A1_CGC
			_cBanc := SA1->A1_BCO1
		endif
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		if SA2->(MsSeek(xFilial("SA2") + "FAZEND" + _cEst,.T.,.F.)) //Deixado o "FAZEND" como fixo, devido ao padrão de código definido para criação das taxas no contas a pagar, onde o Código(FAZEND) é para todos somente mudando a loja de acordo com o estado.
			_cNome := SA2->A2_NREDUZ
		endif
		dbSelectArea(_cSX5TMP)
		(_cSX5TMP)->(dbGoTop())
		_cX5Tab	 := (_cSX5TMP)->X5_TABELA
		_cX5Chav := (_cSX5TMP)->X5_CHAVE
		_cNumICM := StrZero(VAL((_cSX5TMP)->X5_DESCRI)+1,TamSx3("E2_NUM")[01]) //"ICMTESTE" //"ICM" + (Alltrim((_cSX5TMP)->X5_DESCRI)+1) // PREFIXO + NUM
		dbSelectArea("SF6")
		SF6->(dbSetOrder(3))  //F6_FILIAL+F6_OPERNF+F6_TIPODOC+F6_DOC+F6_SERIE+F6_CLIFOR+F6_LOJA 
		if !SF6->(MsSeek(xFilial("SF6") + _cOperNf + _cTpNf + _cDoc + _cSerie + _cClien + _cLoja ,.T.,.F.))
			_lGerou := .T.
			while !RecLock("SF6",.T.) ;enddo
				SF6->F6_FILIAL  := xFilial("SF6")
				SF6->F6_NUMERO  := "ICM"+_cNumICM
				SF6->F6_EST     := _cEst
				SF6->F6_TIPOIMP := '3' // IMPOSTO ST
				SF6->F6_VALOR   := _nValSt
				SF6->F6_INSC    := _cInsc 
				//SF6->F6_DTARREC := Date()
				SF6->F6_DTARREC := _dData
				SF6->F6_DTVENC  := DataValida(_dData + _nDVencto,.T.)
				SF6->F6_MESREF  := _nMes
				SF6->F6_ANOREF  := _nAno
				//SF6->F6_CODREC  := '100099'
				SF6->F6_CODREC  := _cCodRec
				SF6->F6_DOC     := _cDoc
				SF6->F6_SERIE   := _cSerie
				SF6->F6_CLIFOR  := _cClien
				SF6->F6_LOJA    := _cLoja
				SF6->F6_OPERNF  := _cOperNf
				SF6->F6_TIPODOC := _cTpNf
				SF6->F6_DTPAGTO := DataValida(_dData + _nDVencto,.T.)
				SF6->F6_CNPJ    := _cCnpj
				SF6->F6_FECP    := '2'
				SF6->F6_SDOC    := '1'
				//------------------------------------------------
				//INICIO - Preenchimento dos campos para GNRE 2.00
				//------------------------------------------------
				if ExistBlock("MA960GREC")
					_aRetPE := ExecBlock("MA960GREC",.F.,.F.,{_cCodRec,_cEst})
					if Len(_aRetPE) > 0
						SF6->F6_TIPOGNU := StrZero(_aRetPE[1],2)
						SF6->F6_DOCORIG := _aRetPE[2]
						SF6->F6_DETRECE := _aRetPE[3]
						SF6->F6_CODPROD := _aRetPE[4]
					endif
				endif
				//FIM
				//------------------------------------------------
			SF6->(MsUnlock())
		endif
		dbSelectArea("CDC")
		CDC->(dbSetOrder(1))  //CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF
		if !CDC->(MsSeek(xFilial("CDC") + _cTpMov + _cDoc + _cSerie + _cClien + _cLoja ,.T.,.F.)) .and. _lGerou
			while !RecLock("CDC",.T.) ;enddo
				CDC->CDC_FILIAL  := xFilial("CDC")
				CDC->CDC_TPMOV   := _cTpMov
				CDC->CDC_DOC     := _cDoc
				CDC->CDC_SERIE   := _cSerie
				CDC->CDC_CLIFOR  := _cClien
				CDC->CDC_LOJA    := _cLoja
				CDC->CDC_GUIA    := "ICM"+_cNumICM
				CDC->CDC_UF      := _cEst
				CDC->CDC_IFCOMP  := '000001'
				CDC->CDC_SDOC    := '1'
			CDC->(MsUnlock())
		endif
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1))  //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		if !SE2->(MsSeek(xFilial("SE2") + "ICM"+_cNumICM,.T.,.F.)) .and. _lGerou
			while !RecLock("SE2",.T.) ;enddo
				SE2->E2_FILIAL  := xFilial("SE2")
				SE2->E2_PREFIXO := "ICM"
				SE2->E2_NUM     := _cNumICM 
				SE2->E2_TIPO    := "TX"
				SE2->E2_NATUREZ := "205035"
				SE2->E2_FORNECE := "FAZEND"
				SE2->E2_LOJA    := _cEst
				SE2->E2_NOMFOR  := _cNome
				//SE2->E2_EMISSAO := Date()
				//SE2->E2_VENCTO  := Date()
				//SE2->E2_VENCREA := Date()				
				SE2->E2_EMISSAO := _dData
				SE2->E2_VENCTO  := DataValida(_dData + _nDVencto,.T.)
				SE2->E2_VENCREA := DataValida(_dData + _nDVencto,.T.)
				SE2->E2_VALOR   := _nValSt
				//SE2->E2_EMIS1   := Date()
				SE2->E2_EMIS1   := _dData
				SE2->E2_HIST    := "Nota Fiscal: " + _cDoc +"-"+ _cSerie
				SE2->E2_LA	    := "N"
				SE2->E2_SALDO   := _nValSt
				SE2->E2_VENCORI := DataValida(_dData + _nDVencto,.T.)
				SE2->E2_MOEDA   := 1
				SE2->E2_VLCRUZ  := _nValSt
				SE2->E2_FLUXO  := ""
				SE2->E2_ORIGEM  := "MATA460A"
				SE2->E2_PORTADO := _cBanc
				SE2->E2_FILORIG := "01"
			SE2->(MsUnlock())
		endif
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))  //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
		if SF2->(MsSeek(xFilial("SF2") + _cDoc +_cSerie,.T.,.F.)) .and. _lGerou
			while !RecLock("SF2",.F.) ;enddo
				SF2->F2_NFICMST := "ICM"+_cNumICM
			SF2->(MsUnlock())
		endif
		dbSelectArea("SX5")
		SX5->(dbSetOrder(1))  //X5_TABELA+X5_CHAVE                                                                                                  
		if SX5->(MsSeek(FWFilial("SX5") + _cX5Tab +_cX5Chav,.T.,.F.)) .and. _lGerou
			while !RecLock("SX5",.F.) ;enddo
				SX5->X5_DESCRI  := _cNumICM
				SX5->X5_DESCSPA := _cNumICM
				SX5->X5_DESCENG := _cNumICM
			SX5->(MsUnlock())
		endif
		if Select(_cSX5TMP) > 0
			(_cSX5TMP)->(dbCloseArea())
		endif
	endif

Endif
RestArea(_aSavSF2)
RestArea(_aSavArea)
return
