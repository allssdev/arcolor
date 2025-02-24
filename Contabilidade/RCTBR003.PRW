#include "totvs.ch"
/*/{Protheus.doc} RCTBR003
@description Relatório Contábil de conciliação das movimentações da Folha
@author Anderson Coelho (ALLSS Soluções em Sistemas)
@since 11/12/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
user Function RCTBR003()
	local oReport
	local oSection
	local _cRotina := "RCTBR003"
	local _cAlias  := GetNextAlias()
	private _cPerg := _cRotina

	ValidPerg()
	if !Pergunte(_cPerg)
		return
	endif
	if Select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	endif
	//Classe TREPORT
	oReport := TReport():New(_cRotina,"Conciliação Contábil da Folha de Pagamento",_cPerg,{|oReport| ReportPrint(oReport,oSection,_cAlias)})
	//Seção 1
	oSection := TRSection():New(oReport,'Folha')
	//Definição das colunas de impressão da seção 1
	TRCell():New(oSection, "RD_FILIAL"      , _cAlias, RetTitle("RD_FILIAL" )    , PesqPict( "SRD", "RD_FILIAL" ), TamSX3("RD_FILIAL" )[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RD_CC"          , _cAlias, RetTitle("RD_CC"     )    , PesqPict( "SRD", "RD_CC"     ), TamSX3("RD_CC"     )[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "CTT_DESC01"     , _cAlias, RetTitle("CTT_DESC01")    , PesqPict( "CTT", "CTT_DESC01"), TamSX3("CTT_DESC01")[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RD_DEPTO"       , _cAlias, RetTitle("RD_DEPTO"  )    , PesqPict( "SRD", "RD_DEPTO"  ), TamSX3("RD_DEPTO"  )[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "QB_DESCRIC"     , _cAlias, RetTitle("QB_DESCRIC")    , PesqPict( "SQB", "QB_DESCRIC"), TamSX3("QB_DESCRIC")[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RD_PD"          , _cAlias, RetTitle("RD_PD"     )    , PesqPict( "SRD", "RD_PD"     ), TamSX3("RD_PD"     )[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RV_DESC"        , _cAlias, RetTitle("RV_DESC"   )    , PesqPict( "SRV", "RV_DESC"   ), TamSX3("RV_DESC"   )[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RV_TIPOCOD"     , _cAlias, RetTitle("RV_TIPOCOD")    , PesqPict( "SRV", "RV_TIPOCOD"), TamSX3("RV_TIPOCOD")[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	if SRV->(FieldPos("RV_VBDPARA")) > 0
		TRCell():New(oSection, "RV_VBDPARA" , _cAlias, RetTitle("RV_VBDPARA")    , PesqPict( "SRV", "RV_VBDPARA"), TamSX3("RV_VBDPARA")[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	endif
	TRCell():New(oSection, "RD_VALOR"       , _cAlias, RetTitle("RD_VALOR"  )    , PesqPictQt( "RD_VALOR"       ), TamSX3("RD_VALOR")[01]+TamSX3("RD_VALOR")[02]+2, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "DEBITO"         , _cAlias, "Débito"                  , PesqPict( "CT1", "CT1_CONTA" ), TamSX3("CT1_CONTA" )[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "DESCR_D"        , _cAlias, "Descr. Débito"           , PesqPict( "CT1", "CT1_DESC01"), TamSX3("CT1_DESC01")[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "CREDITO"        , _cAlias, "Crédito"                 , PesqPict( "CT1", "CT1_CONTA" ), TamSX3("CT1_CONTA" )[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "DESCR_C"        , _cAlias, "Descr. Crédito"          , PesqPict( "CT1", "CT1_DESC01"), TamSX3("CT1_DESC01")[01], /*lPixel*/, /*{|| code-block de impressao }*/)
	oReport:PrintDialog()
	if Select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	endif
return
/*/{Protheus.doc} ReportPrint
@description Relatório Contábil de conciliação das movimentações da Folha
@author Anderson Coelho (ALLSS Soluções em Sistemas)
@since 11/12/2020
@version 1.0
@type function
@param oReport , object, Objeto do relatório
@param oSection, object, Objeto da Seção do relatório
@see https://allss.com.br
/*/
static function ReportPrint(oReport,oSection,_cAlias)
	#IFDEF TOP
		BEGIN REPORT QUERY oSection
			BeginSql alias _cAlias
				SELECT	RD_FILIAL,
						RD_CC,
						CTT_DESC01,
						RD_DEPTO,
						QB_DESCRIC,
						RD_PD,
						RV_DESC,
						RV_TIPOCOD,
						RV_VBDPARA,
						SUM(RD_VALOR) RD_VALOR,
						DEBITO,
						(CASE WHEN DEBITO  = '' THEN '' ELSE (SELECT TOP 1 CT1_DESC01 FROM %table:CT1% CT1 (NOLOCK) WHERE CT1_FILIAL = %xFilial:CT1% AND CT1_CONTA = DEBITO  AND CT1.%NotDel%) END) [DESCR_D],
						CREDITO,
						(CASE WHEN CREDITO = '' THEN '' ELSE (SELECT TOP 1 CT1_DESC01 FROM %table:CT1% CT1 (NOLOCK) WHERE CT1_FILIAL = %xFilial:CT1% AND CT1_CONTA = CREDITO AND CT1.%NotDel%) END) [DESCR_C]
				FROM ( 
						SELECT	RD_FILIAL,
								RD_CC,
								ISNULL(CTT_DESC01,'') CTT_DESC01,
								RD_DEPTO,
								ISNULL(QB_DESCRIC,'') QB_DESCRIC,
								RD_PD,
								ISNULL(RV_VBDPARA,'') RV_VBDPARA,
								ISNULL(RV_DESC   ,'')  RV_DESC,
								(CASE 
									WHEN ISNULL(RV_TIPOCOD,0) = 1 THEN 'Provento'
									WHEN ISNULL(RV_TIPOCOD,0) = 2 THEN 'Desconto'
									WHEN ISNULL(RV_TIPOCOD,0) = 3 THEN 'Base (Provento)'
									WHEN ISNULL(RV_TIPOCOD,0) = 4 THEN 'Base (Desconto)'
									ELSE ''
								END) RV_TIPOCOD,
								RD_VALOR,
								(CASE
									WHEN RD_CC   = '1000' THEN ISNULL(RV_CC1000D,'')
									WHEN RD_CC   = '2000' THEN ISNULL(RV_CC2000D,'')
									WHEN RD_CC   = '3000' THEN ISNULL(RV_CC3000D,'')
									WHEN RD_CC   = '4000' THEN ISNULL(RV_CC4000D,'')
									WHEN RD_CC   = '5000' THEN ISNULL(RV_CC5000D,'')
									ELSE ''
								END) DEBITO,
								(CASE
									WHEN RD_CC   = '1000' THEN ISNULL(RV_CC1000C,'')
									WHEN RD_CC   = '2000' THEN ISNULL(RV_CC2000C,'')
									WHEN RD_CC   = '3000' THEN ISNULL(RV_CC3000C,'')
									WHEN RD_CC   = '4000' THEN ISNULL(RV_CC4000C,'')
									WHEN RD_CC   = '5000' THEN ISNULL(RV_CC5000C,'')
									ELSE ''
								END) CREDITO
						FROM %table:SRD% SRD (NOLOCK)
							LEFT OUTER JOIN %table:SRV% SRV (NOLOCK) ON RV_FILIAL    = %xFilial:SRV%
																	AND RV_COD       = RD_PD
																	AND SRV.%NotDel%
							LEFT OUTER JOIN %table:CTT% CTT (NOLOCK) ON CTT_FILIAL   = %xFilial:CTT%
																	AND CTT_CUSTO    = RD_CC
																	AND CTT.%NotDel%
							LEFT OUTER JOIN %table:SQB% SQB (NOLOCK) ON QB_FILIAL    = %xFilial:SQB%
																	AND QB_DEPTO     = RD_DEPTO
																	AND SQB.%NotDel%
						WHERE RD_FILIAL        = %xFilial:SRD%
						  AND RD_PERIODO       = %Exp:MV_PAR01%
						  AND RD_CC      BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
						  AND RD_DEPTO   BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
						  AND RD_PD      BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
						  AND SRD.%NotDel%
					) XXX
				GROUP BY
						RD_FILIAL,
						RD_CC,
						CTT_DESC01,
						RD_DEPTO,
						QB_DESCRIC,
						RD_PD,
						RV_DESC,
						RV_TIPOCOD,
						RV_VBDPARA,
						DEBITO,
						CREDITO
				ORDER BY RD_FILIAL, RD_CC, RD_DEPTO, RV_TIPOCOD, RD_PD
			EndSql
		END REPORT QUERY oSection 
		oSection:Print()
	#ENDIF
return
/*/{Protheus.doc} ValidPerg
@description Função utilizada para verificar se as perguntas definidas na rotina existem no dicionário 'SX1'. Caso não existam, as cria para apresentação ao usuário e uso na rotina.
@author Anderson Coelho (ALLSS Soluções em Sistemas)
@since 11/12/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aArea := GetArea()
	local _aTam  := {}
	local _aRegs := {}
	local i      := 0
	local j      := 0
	_cAliasSX1   := "SX1"
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	_cPerg := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam  := TamSX3("RD_PERIODO")
	AADD(_aRegs,{_cPerg,"01","Ano e Mês (AAAAMM):","","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","RCH"   ,"",""})
	_aTam  := TamSX3("RD_CC"     )
	AADD(_aRegs,{_cPerg,"02","Do Centro de Custo?","","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","CTT"   ,"",""})
	AADD(_aRegs,{_cPerg,"03","Ao Centro de Custo?","","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par03",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","CTT"   ,"",""})
	_aTam  := TamSX3("RD_DEPTO"  )
	AADD(_aRegs,{_cPerg,"04","Do Departamento?"   ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SQB"   ,"",""})
	AADD(_aRegs,{_cPerg,"05","Ao Departamento?"   ,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par05",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SQB"   ,"",""})
	_aTam  := TamSX3("RD_PD"     )
	AADD(_aRegs,{_cPerg,"06","Da Verba?"          ,"","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par06",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SRV"   ,"",""})
	AADD(_aRegs,{_cPerg,"07","Até a Verba?"       ,"","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par07",""                 ,"","","","",""               ,"","","","",""					,"","","","","","","","","","","","","","SRV"   ,"",""})
	for i := 1 to len(_aRegs)
		if !(_cAliasSX1)->(dbSeek(_cPerg+_aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= Len(_aRegs[i])
						FieldPut(j,_aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_aArea)
return
