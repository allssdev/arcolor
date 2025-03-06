#include "totvs.ch"
/*/{Protheus.doc} RFATE057
@description Execblock utilizado para que o parametro de liberacao automatica de estoque seja preenchido automaticamente, conforme o pedido posicionado.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 27/05/2015
@version 1.0
@type function
@history 11/09/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Inserida a AjustaPv() sub-rotina utilizada para acertar o campo C6_QTDEMP conforme os pedidos de vendas liberados, para evitar os problemas gerados pelo sistema quanto ao processo de perda de liberação dos itens dos pedidos de vendas.
@history 13/01/2021, Diego Rodrigues, Retirado após atualização do sistema para acompanhamento
@see https://allss.com.br
/*/
user function RFATE057()
	//local _cRotina   := "RFATE057"
	local cPerg      := Padr("LIBAT2",len(SX1->X1_GRUPO))
	local _cAliasSX1 := "SX1"
	Private _cRotina   := "RFATE057"
	//Perguntas da liberação automática de estoque (reavaliação)
	AjustaPv()	//11/09/2020 - Sub-rotina utilizada para acertar o campo C6_QTDEMP conforme os pedidos de vendas liberados, para evitar os problemas gerados pelo sistema quanto ao processo de perda de liberação dos itens dos pedidos de vendas.
	TcRefresh("SC6")
	TcRefresh("SC9")
	Pergunte(cPerg,.F.)
	if AllTrim(FunName())=="MATA455" .OR. AllTrim(FunName())=="RFATA026"
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
		cPerg      := Padr("LIBAT2",len(SX1->X1_GRUPO))
		Pergunte(cPerg,.F.)
		dbSelectArea(_cAliasSX1)
		(_cAliasSX1)->(dbSetOrder(1))
		if (_cAliasSX1)->(MsSeek(cPerg+"01",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR01 := SC9->C9_PEDIDO
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"02",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR02 := SC9->C9_PEDIDO
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"03",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR03 := Replicate(Space(01),TamSx3("A1_COD" )[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"04",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := MV_PAR04 := Replicate("Z",TamSx3("A1_COD" )[01])
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"05",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := "19900101"
				MV_PAR05      := STOD((_cAliasSX1)->X1_CNT01)
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"06",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_CNT01 := "20491231"
				MV_PAR06      := STOD((_cAliasSX1)->X1_CNT01)
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if (_cAliasSX1)->(MsSeek(cPerg+"07",.T.,.F.))
			while !RecLock(_cAliasSX1,.F.) ; enddo
				(_cAliasSX1)->X1_PRESEL := MV_PAR07 := 1
			(_cAliasSX1)->(MSUNLOCK())
		endif
		if ExistBlock("RCFGASX1")
			U_RCFGASX1(cPerg,"01",MV_PAR01)
			U_RCFGASX1(cPerg,"02",MV_PAR02)
			U_RCFGASX1(cPerg,"03",MV_PAR03)
			U_RCFGASX1(cPerg,"04",MV_PAR04)
			U_RCFGASX1(cPerg,"05",MV_PAR05)
			U_RCFGASX1(cPerg,"06",MV_PAR06)
			U_RCFGASX1(cPerg,"07",MV_PAR07)
		endif
	endif
	TcRefresh("SC6")
	TcRefresh("SC9")
	A455LibAut("SC9")
	TcRefresh("SC6")
	TcRefresh("SC9")
	if ExistBlock("RFATL001")
		U_RFATL001(SC9->C9_PEDIDO,POSICIONE('SUA',8,FWFilial('SUA')+SC9->C9_PEDIDO ,'UA_NUM'),'Executado Reavaliação/Liberação de Estoque',"RFATE057",)
	endif
	/* 13/01/2021 - Diego Rodrigues - Retirado após atualização do sistema para acompanhamento
	if ExistBlock("RFATE068")
		ExecBlock("RFATE068")
	endif
	*/
	if ExistBlock("MTA455SLD")
		ExecBlock("MTA455SLD") 
	endif
	if ExistBlock("MTA455NL")
		ExecBlock("MTA455NL") 
	endif
return
/*/{Protheus.doc} AjustaPv (RFATE057)
@description Sub-rotina utilizada para acertar o campo C6_QTDEMP conforme os pedidos de vendas liberados, para evitar os problemas gerados pelo sistema quanto ao processo de perda de liberação dos itens dos pedidos de vendas.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 11/09/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AjustaPv()
	local _cQryU := ""
	_cQryU := " UPDATE SC6 SET C6_QTDEMP = (SELECT SUM(C9_QTDLIB) FROM "+RetSqlName("SC9")+" SC9 (NOLOCK) WHERE C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C9_PRODUTO = C6_PRODUTO AND C9_NFISCAL = '' AND SC9.D_E_L_E_T_ = '' ) "
	_cQryU += " FROM "+RetSqlName("SC6")+" SC6 (NOLOCK) "
	_cQryU += " WHERE C6_FILIAL = '" + FWFilial("SC6") + "' "
	_cQryU += "   AND C6_NUM    = '" + SC9->C9_PEDIDO  + "' "
	_cQryU += "   AND C6_BLQ    = '' "
	_cQryU += "   AND SC6.D_E_L_E_T_ = '' "
	TcSqlExec(_cQryU)
	_cQryU := ""
return
