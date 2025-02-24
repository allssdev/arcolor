#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE _cEnter CHR(13)+CHR(10)
/*/{Protheus.doc} RFINE021
@description Rotina responsável pelo vínculo entre pedidos de vendas e títulos de crédito (RAs e NCCs).
Este vínculo será obrigatório em pedidos que utilizem condição de pagamento com adiantamento no momento da liberação de crédito e apenas sugerido nos casos em que a condição não possui adiantamento, mas o cliente possui títulos de crédito.
Nos demais casos a rotina poderá ser executada através da tecla F6, estando o pedido posicionado.
@obs O vínculo dos títulos com o pedido está sendo feito na tabela SZH e não irá aproveitar o recurso padrão de adiantamento do pedido de vendas (FIE) por conta de tratamento posterior.
@author Adriano L. de Souza
@since 14/07/2014
@version 1.0
@param _lOpen, lógico, Define a abertura ou não da tela.
@type function
@see https://allss.com.br
/*/
user function RFINE021(_lOpen)
	local   btnIncluir
	local   btnConfirmar
	local   btnFechar
	local   lblLimite
	local   lblNumPedi
	local   lblPedido
	local   lblVlrLimit
	local   lblVlrSelec
	local   lblCondPg
	local   _aSavArea   := GetArea()
	local   _aSavSC9    := SC9->(GetArea())
	local   _aSavSC5    := SC5->(GetArea())
	local   _aSavSC6    := SC6->(GetArea())
	local   cNumPedi    := SC9->C9_PEDIDO
	local   _cTMPCNT    := GetNextAlias()
	local   _cCondPg    := ""
	local   _lVldObr    := .F.
	local   _lCont      := .F.
	local   oFont1      := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	local   oFont2      := TFont():New("MS Sans Serif",,016,,.T.,,,,,.F.,.F.)

	private oMark
	private lblSelecionado
	private _cRotina    := "RFINE021"
	private _cQTmp		:= GetNextAlias()
	private _cTabTmp	:= GetNextAlias()
	private cMark		:= GetMARK()
	private _cDescPg	:= ""
	private _cQry		:= ""
	private nMarcado    := 0
	private _nLimite	:= 0
	private _nValSel	:= 0
	private _nVlrComp	:= 0
	private _nTamBtn	:= 54
	private _nEspPad	:= 8
	private _nTamMark	:= 2
	private _lRetCmp	:= .T.
	private lInverte    := .F.
	//Monta array com dimensões da tela
	private aSizFrm		:= MsAdvSize()
	private aMarcados[2]

	public _lRetm		:= .T.

	default _lOpen		:= .F.

	//Verifico se a tela já está aberta ou se o item já foi faturado
	if oDlg<>Nil .OR. !Empty(SC9->C9_NFISCAL)
		return _lRetCmp
	endif
	//Verifico se o pedido possui condição de pagamento com adiantamento ou se existe algum título a ser compensado
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1)) //Filial + Pedido
	if SC5->(MsSeek(xFilial("SC5")+SC9->C9_PEDIDO,.T.,.F.))
		_cCondPg := SC5->C5_CONDPAG
		dbSelectArea("SE4")
		SE4->(dbSetOrder(1)) //Filial + Código
		if SE4->(MsSeek(xFilial("SE4")+_cCondPg,.T.,.F.))
			_lVldObr := AllTrim(SE4->E4_CTRADT)=="1"
			_cDescPg := "(" + AllTrim(SE4->E4_CODIGO) + " - " + AllTrim(SE4->E4_DESCRI) + ")"
		endif
	endif
	if Type("cPerg")=="U"
//		public _cRotina := 'MA450MNU'
		public cPerg    := Padr('MA450MNU',len(SX1->X1_GRUPO))
	else
		cPerg           := Padr(cPerg,len(SX1->X1_GRUPO))
	endif
	Pergunte(cPerg,.F.) //MA450MNU - parâmetros da rotina
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	||³Atenção: alterações na query abaixo poderão impactar no resultado de _cQryAux||
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	//Monto a consulta para retornar os títulos que poderão ser vinculados ao pedido em questão
	_cQry := " SELECT * " + _cEnter
	_cQry += " FROM ( " + _cEnter
	//A primeira avaliação é na tabela SE1 para trazer os títulos que não foram relacionados
	_cQry += "       SELECT 0 AS [TM_RECSZH], R_E_C_N_O_  AS [TM_RECSE1], '' AS [E1_MARK] " + _cEnter
	_cQry += "            , E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMERAZ " + _cEnter
	_cQry += "            , E1_SALDO-ISNULL((SELECT SUM(ISNULL(ZH_VALOR,0)) " + _cEnter
	_cQry += "                        FROM " + RetSqlName("SZH") + " SZH (NOLOCK) " + _cEnter
	_cQry += "                        WHERE SZH.D_E_L_E_T_ = '' " + _cEnter
	_cQry += "                          AND SZH.ZH_FILIAL  = '" + xFilial("SZH") + "' " + _cEnter
	_cQry += "                          AND SZH.ZH_CART    = 'R' " + _cEnter
	_cQry += "                          AND SZH.ZH_CLIENT  = SE1.E1_CLIENTE " + _cEnter
	_cQry += "                          AND SZH.ZH_LOJA    = SE1.E1_LOJA " + _cEnter
	_cQry += "                          AND SZH.ZH_PREFIX  = SE1.E1_PREFIXO " + _cEnter
	_cQry += "                          AND SZH.ZH_NUM     = SE1.E1_NUM " + _cEnter
	_cQry += "                          AND SZH.ZH_PARCEL  = SE1.E1_PARCELA " + _cEnter
	_cQry += "                       ),0) AS [E1_VALOR] " + _cEnter
	_cQry += "            , 0 AS [VLRCOMP], 0 AS [SLDCOMP], E1_SALDO AS [TM_VALOR] " + _cEnter
	_cQry += "            , ISNULL((SELECT SUM(ISNULL(ZH_VALOR,0)) " + _cEnter
	_cQry += "               FROM " + RetSqlName("SZH") + " SZH (NOLOCK) " + _cEnter
	_cQry += "               WHERE SZH.D_E_L_E_T_ = '' " + _cEnter
	_cQry += "                 AND SZH.ZH_FILIAL  = '" + xFilial("SZH") + "' " + _cEnter
	_cQry += "                 AND SZH.ZH_CART    = 'R' " + _cEnter
	_cQry += "                 AND SZH.ZH_CLIENT  = SE1.E1_CLIENTE " + _cEnter
	_cQry += "                 AND SZH.ZH_LOJA    = SE1.E1_LOJA " + _cEnter
	_cQry += "                 AND SZH.ZH_PREFIX  = SE1.E1_PREFIXO " + _cEnter
	_cQry += "                 AND SZH.ZH_NUM     = SE1.E1_NUM " + _cEnter
	_cQry += "                 AND SZH.ZH_PARCEL  = SE1.E1_PARCELA " + _cEnter
	_cQry += "               ),0) AS [CMPDIVER] " + _cEnter
	_cQry += "            , '' AS [PEDIDO] " + _cEnter
	_cQry += "       FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) " + _cEnter
	_cQry += "       WHERE SE1.D_E_L_E_T_       = '' " + _cEnter
	if MV_PAR05 == 1 //Considera Filiais
		_cQry += "     AND SE1.E1_FILIAL  BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' " + _cEnter
	else
		_cQry += "     AND SE1.E1_FILIAL        = '" + xFilial("SE1") + "' " + _cEnter
	endif
	if MV_PAR08 == 1 //Considera NCCs
		_cTipos := "('RA','NCC')"
	else
		_cTipos := "('RA')"
	endif
	_cQry += "         AND SE1.E1_TIPO         IN " + _cTipos + " " + _cEnter
	if MV_PAR02 == 1 //Considera Cliente
		_cQry += "     AND SE1.E1_CLIENTE       = '" + SC5->C5_CLIENTE + "' " + _cEnter
	else
		_cQry += "     AND SE1.E1_CLIENTE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + _cEnter
	endif
	if MV_PAR01 == 1 //Considera Loja
		_cQry += "     AND SE1.E1_LOJA          = '" + SC5->C5_LOJACLI + "' " + _cEnter
	endif
	_cQry += "         AND SE1.E1_SALDO         > 0  " + _cEnter
	//Certifico que o título ainda não possui vínculo ao pedido em questão
	_cQry += "         AND (SELECT COUNT(*) " + _cEnter
	_cQry += "		        FROM " + RetSqlName("SZH") + " SZH (nolock)" + _cEnter
	_cQry += "		        WHERE SZH.D_E_L_E_T_ = '' " + _cEnter
	_cQry += "                AND SZH.ZH_FILIAL  = '" + xFilial("SZH") + "' " + _cEnter
	_cQry += "                AND SZH.ZH_CART    = 'R' " + _cEnter
	_cQry += "                AND SZH.ZH_CLIENT  = SE1.E1_CLIENTE " + _cEnter
	_cQry += "                AND SZH.ZH_LOJA    = SE1.E1_LOJA " + _cEnter
	_cQry += "                AND SZH.ZH_PREFIX  = SE1.E1_PREFIXO " + _cEnter
	_cQry += "                AND SZH.ZH_NUM     = SE1.E1_NUM " + _cEnter
	_cQry += "                AND SZH.ZH_PARCEL  = SE1.E1_PARCELA " + _cEnter
	_cQry += "                AND SZH.ZH_PEDIDO  = '" + SC9->C9_PEDIDO + "' " + _cEnter
	_cQry += "              ) = 0 " + _cEnter
	_cQry += "    UNION ALL " + _cEnter
	//É feita a junção dos resultados da SE1 com os títulos já relacionados na tabela SZH
	_cQry += "       SELECT TMP.TM_RECSZH, TMP.TM_RECSE1, TMP.E1_MARK, TMP.E1_PREFIXO, TMP.E1_NUM, TMP.E1_PARCELA, TMP.E1_TIPO " + _cEnter
	//_cQry += "            , TMP.E1_CLIENTE, TMP.E1_LOJA, TMP.E1_NOMERAZ, TMP.TM_VALOR-CMPDIVER AS [E1_VALOR] " + _cEnter
	_cQry += "            , TMP.E1_CLIENTE, TMP.E1_LOJA, TMP.E1_NOMERAZ, TMP.TM_VALOR-CMPDIVER AS [E1_VALOR] " + _cEnter
	_cQry += "            , TMP.VLRCOMP, TMP.SLDCOMP, TMP.TM_VALOR, TMP.CMPDIVER, TMP.PEDIDO " + _cEnter
	_cQry += "       FROM ( SELECT SZH.R_E_C_N_O_ AS [TM_RECSZH], SE1.R_E_C_N_O_ AS [TM_RECSE1]" + _cEnter
	_cQry += "                   , (CASE WHEN SZH.ZH_PEDIDO = '" + SC9->C9_PEDIDO + "' THEN '" + cMark + "' ELSE '' END) AS [E1_MARK] " + _cEnter
	_cQry += "                   , ZH_PREFIX AS [E1_PREFIXO], SZH.ZH_NUM AS [E1_NUM], SZH.ZH_PARCEL AS [E1_PARCELA] " + _cEnter
	_cQry += "                   , SZH.ZH_TIPO AS [E1_TIPO], SZH.ZH_CLIENT AS [E1_CLIENTE], SZH.ZH_LOJA AS [E1_LOJA] " + _cEnter
	_cQry += "                   , SE1.E1_NOMERAZ AS [E1_NOMERAZ], SE1.E1_SALDO-ZH_VALOR AS [E1_VALOR] " + _cEnter
	_cQry += "                   , SZH.ZH_VALOR-ISNULL(SZH.ZH_SALDO,0) AS [VLRCOMP]" + _cEnter
	_cQry += "                   , (CASE WHEN SZH.ZH_PEDIDO = '" + SC9->C9_PEDIDO + "' THEN SZH.ZH_SALDO ELSE 0 END) AS [SLDCOMP] " + _cEnter
	_cQry += "                   , E1_SALDO AS [TM_VALOR] " + _cEnter
	_cQry += "                   , (SELECT ISNULL(SUM(AUX.ZH_VALOR),0) " + _cEnter
	_cQry += "                      FROM " + RetSqlName("SZH") + " AUX (nolock)" + _cEnter
	_cQry += "                      WHERE AUX.D_E_L_E_T_ = '' " + _cEnter
	_cQry += "                        AND AUX.ZH_FILIAL  = '" + xFilial("SZH") + "' " + _cEnter
	_cQry += "                        AND AUX.ZH_CLIENT  = SZH.ZH_CLIENT " + _cEnter
	_cQry += "                        AND AUX.ZH_LOJA    = SZH.ZH_LOJA " + _cEnter
	_cQry += "                        AND AUX.ZH_PREFIX  = SZH.ZH_PREFIX " + _cEnter
	_cQry += "                        AND AUX.ZH_NUM     = SZH.ZH_NUM " + _cEnter
	_cQry += "                        AND AUX.ZH_PARCEL  = SZH.ZH_PARCEL " + _cEnter
	_cQry += "                      ) AS [CMPDIVER], SZH.ZH_PEDIDO AS [PEDIDO] " + _cEnter
	_cQry += "              FROM " + RetSqlName("SZH") + " SZH (nolock)" + _cEnter
	_cQry += "                     INNER JOIN " + RetSqlName("SE1") + " SE1 (nolock) ON SE1.D_E_L_E_T_ = '' " + _cEnter
	if MV_PAR05 == 1 //Considera Filiais
		_cQry += "                                      AND SE1.E1_FILIAL  BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' " + _cEnter
	else
		_cQry += "                                      AND SE1.E1_FILIAL        = '" + xFilial("SE1") + "' " + _cEnter
	endif
	if MV_PAR08 == 1 //Considera NCCs
		_cTipos := "('RA','NCC')"
	else
		_cTipos := "('RA')"
	endif
	_cQry += "                                          AND SE1.E1_TIPO         IN " + _cTipos + " " + _cEnter
	if MV_PAR02 == 1 //Considera Cliente
		_cQry += "                                      AND SE1.E1_CLIENTE       = '" + SC5->C5_CLIENTE + "' " + _cEnter
	else
		_cQry += "                                      AND SE1.E1_CLIENTE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'" + _cEnter
	endif
	if MV_PAR01 == 1 //Considera Loja
		_cQry += "                                      AND SE1.E1_LOJA          = '" + SC5->C5_LOJACLI + "' " + _cEnter
	endif
	_cQry += "                                          AND SE1.E1_SALDO         > 0 " + _cEnter
	_cQry += "                                          AND SE1.E1_PREFIXO       = SZH.ZH_PREFIX " + _cEnter
	_cQry += "                                          AND SE1.E1_NUM           = SZH.ZH_NUM " + _cEnter
	_cQry += "                                          AND SE1.E1_CLIENTE       = SZH.ZH_CLIENT " + _cEnter
	_cQry += "                                          AND SE1.E1_LOJA          = SZH.ZH_LOJA " + _cEnter
	_cQry += "                                          AND SE1.E1_PARCELA       = SZH.ZH_PARCEL " + _cEnter
	_cQry += "              WHERE SZH.D_E_L_E_T_ = '' " + _cEnter
	_cQry += "                AND SZH.ZH_FILIAL  = '" + xFilial("SZH") + "' " + _cEnter
	_cQry += "            ) TMP " + _cEnter
	_cQry += "       WHERE TMP.E1_MARK <> '' OR (TMP.SLDCOMP = 0 AND TMP.PEDIDO = '" + SC9->C9_PEDIDO + "') " + _cEnter
	_cQry += "      ) COMP " + _cEnter
	//Query auxiliar para avaliar se existem títulos a serem compensados de acordo com os parâmetros do F12 na tela de análise de crédito do pedido
	_cQryAux := StrTran(_cQry," * "," COUNT(*) AS [QTD]")
	_cQry += "ORDER BY COMP.E1_CLIENTE, COMP.E1_LOJA, COMP.E1_PREFIXO, COMP.E1_NUM, COMP.E1_PARCELA	" + _cEnter
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQryAux)
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryAux),_cTMPCNT,.F.,.T.)
	dbSelectArea(_cTMPCNT)
	if (_cTMPCNT)->QTD > 0
		_lCont := .T.
	endif
	//Fecho a tabela temporária
	if Select(_cTMPCNT)
		(_cTMPCNT)->(dbCloseArea())
	endif
	if !_lVldObr .And. !_lCont .And. !_lOpen
		return .T.
	endif
	if _lVldObr
		MsgInfo("Esse pedido possui recebimento antecipado! O vínculo com título RA e/ou NCC é obrigatório!",_cRotina+"_001")
	endif

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Vincular Adiantamento ao Pedido" FROM aSizFrm[1], aSizFrm[1]  TO aSizFrm[6], aSizFrm[5] COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
		oDlg:lEscClose 		:= .F.
		private _aSize		:= MsAdvSize()
		private _nMargem	:= 3
		private _nTamBut	:= 47
		private _nAltBut	:= 12
		_nLimite            := TotPedido() //Total do pedido (liberado)
		SetModulo("SIGAFIN",'FIN')
		SetFunName("FINA040")
		//Labels
		@ 009, 013 SAY lblPedido 		PROMPT "Pedido:" 										SIZE aSizFrm[1]+025, 007 OF oDlg 				COLORS 0		, 16777215 PIXEL
		@ 008, 033 SAY lblNumPedi 		PROMPT cNumPedi 										SIZE aSizFrm[1]+037, 010 OF oDlg FONT oFont1 	COLORS 16711680	, 16777215 PIXEL
		@ 009, 144 SAY lblVlrLimit 		PROMPT "Valor Limite:" 									SIZE aSizFrm[1]+037, 007 OF oDlg 				COLORS 0		, 16777215 PIXEL
		@ 008, 182 SAY lblLimite 		PROMPT Transform(_nLimite,PesqPict("SC9","C9_PRCVEN")) 	SIZE aSizFrm[1]+047, 010 OF oDlg FONT oFont1 	COLORS 16711680	, 16777215 PIXEL
		@ 009, 262 SAY lblVlrSelec 		PROMPT "Valor Selecionado:" 							SIZE aSizFrm[1]+054, 007 OF oDlg 				COLORS 0		, 16777215 PIXEL
		@ 008, 317 SAY lblSelecionado 	PROMPT Transform(_nValSel,PesqPict("SC9","C9_PRCVEN")) 	SIZE aSizFrm[1]+047, 010 OF oDlg FONT oFont1 	COLORS 16711680	, 16777215 PIXEL
		@ 009, 372 SAY lblCondPg 		PROMPT "Cond. Pagto: " + AllTrim(_cDescPg) 				SIZE aSizFrm[1]+162, 007 OF oDlg FONT oFont2 	COLORS 0		, 16777215 PIXEL
		//MarkBrowse
		Selecao()
		//Botões
		@ (_aSize[6]*0.5)-015, aSizFrm[3]-(_nTamBtn*3)-(_nEspPad*3) 	BUTTON btnIncluir 	PROMPT "&Incluir" 	SIZE _nTamBtn, 012 OF oDlg ACTION FinA040() 	PIXEL
		@ (_aSize[6]*0.5)-015, aSizFrm[3]-(_nTamBtn*2)-(_nEspPad*2) 	BUTTON btnConfirmar PROMPT "&Confirmar" SIZE _nTamBtn, 012 OF oDlg ACTION Confirmar() 	PIXEL
		@ (_aSize[6]*0.5)-015, aSizFrm[3]-_nTamBtn-_nEspPad 			BUTTON btnFechar 	PROMPT "&Fechar" 	SIZE _nTamBtn, 012 OF oDlg ACTION Fechar() 		PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
	//Verifico se a compensação é obrigatória
	If !_lVldObr
		_lRetCmp := .T.
	EndIf
	RestArea(_aSavSC5)
	RestArea(_aSavSC6)
	RestArea(_aSavSC9)
	RestArea(_aSavArea)
return _lRetCmp
/*/{Protheus.doc} Fechar (RFINE021)
@description Função responsável por fechar a tela principal.
@author Adriano L. de Souza
@since 14/07/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Fechar()
	//Avalio se existe algum título selecionado para compensação
	if _nValSel > 0
		_lRetCmp := .T.
	else
		_lRetCmp := .F.
	endif
	//Fecho a tabela temporária
	if Select(_cTabTmp) > 0
		(_cTabTmp)->(dbCloseArea())
	endif
	//Fecho a tela de diálogo
	Close(oDlg)
return
/*/{Protheus.doc} Selecao (RFINE021)
@description Função responsável por montar markbrowse para seleção dos títulos à compensar.
@author Adriano L. de Souza
@since 14/07/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Selecao()
	local _lMostra      := .T.
	private bFiltraBrw 	:= {|| Nil}
	_cInd1		        := CriaTrab(Nil,.F.)	
	_aCpos		        := {}
	_aStruct	        := {}
	_aCampos	        := {}
	//Monto estrutura para tabela temporária que será utilizada no markbrowse
	AADD(_aCpos,{"TM_OK"  		,"C",_nTamMark					,0						})
	AADD(_aCpos,{"TM_PREFIXO" 	,"C",TamSx3("E1_PREFIXO")[01]	,0						})
	AADD(_aCpos,{"TM_NUM"		,"C",TamSx3("E1_NUM"	)[01]	,0						})
	AADD(_aCpos,{"TM_PARCELA"	,"C",TamSx3("E1_PARCELA")[01]	,0						})
	AADD(_aCpos,{"TM_TIPO"		,"C",TamSx3("E1_TIPO"	)[01]	,0						})
	AADD(_aCpos,{"TM_CLIFOR"	,"C",TamSx3("E1_CLIENTE")[01]	,0						})
	AADD(_aCpos,{"TM_LOJA"		,"C",TamSx3("E1_LOJA"	)[01]	,0						})
	AADD(_aCpos,{"TM_NOME"		,"C",TamSx3("E1_NOMERAZ")[01]	,0						})
	AADD(_aCpos,{"TM_SALDO"		,"N",TamSx3("FR3_VALOR"	)[01]	,TamSx3("FR3_VALOR")[02]})
	AADD(_aCpos,{"TM_VLRCOMP"	,"N",TamSx3("FR3_VALOR"	)[01]	,TamSx3("FR3_VALOR")[02]})
	AADD(_aCpos,{"TM_SLDCOMP"	,"N",TamSx3("FR3_VALOR"	)[01]	,TamSx3("FR3_VALOR")[02]})
	AADD(_aCpos,{"TM_RECSZH"	,"N",TamSx3("FR3_VALOR"	)[01]	,TamSx3("FR3_VALOR")[02]})
	AADD(_aCpos,{"TM_RECSE1"	,"N",TamSx3("FR3_VALOR"	)[01]	,TamSx3("FR3_VALOR")[02]})
	AADD(_aCpos,{"TM_VALOR"		,"N",TamSx3("E1_VALOR"	)[01]	,TamSx3("E1_VALOR" )[02]})
	AADD(_aCpos,{"TM_CMPDIV"	,"N",TamSx3("E1_VALOR"	)[01]	,TamSx3("E1_VALOR" )[02]})
	AADD(_aCpos,{"TM_PEDIDO"	,"C",TamSx3("C5_NUM"	)[01]	,0						})
	/* FB - RELEASE 12.1.23
	_cInd1 := CriaTrab(_aCpos,.T.)
	//Crio tabela temporária para uso com markbrowse
	dbUseArea(.T.,,_cInd1,_cTabTmp,.T.,.F.)
	IndRegua(_cTabTmp,_cInd1,"TM_NUM",,,"Criando índice temporario...")
	*/
	//-------------------
	//Criacao do objeto
	//-------------------
	_cTabTmp := GetNextAlias()
	oTempTable := FWTemporaryTable():New( _cTabTmp )
	oTemptable:SetFields( _aCpos )
	oTempTable:AddIndex("indice1", {"TM_NUM"} )
	//------------------
	//Criacao da tabela
	//------------------
	oTempTable:Create()
	if !empty(_cQry)
		//Crio tabela temporária com títulos passíveis de compensação com o pedido posicionado
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cQTmp,.F.,.T.)
	endif
	//Gravo a tabela temporária com base no resultado da query acima
	dbSelectArea(_cQTmp) //Tabela temporária com resultado da query
	(_cQTmp)->(dbGoTop())
	while !(_cQTmp)->(EOF())
		_lMostra := (_cQTmp)->E1_VALOR >= 0
		if _lMostra
			while !RecLock(_cTabTmp,.T.) ; enddo
				(_cTabTmp)->TM_OK     	:= (_cQTmp)->E1_MARK
				(_cTabTmp)->TM_PREFIXO	:= (_cQTmp)->E1_PREFIXO
				(_cTabTmp)->TM_NUM		:= (_cQTmp)->E1_NUM
				(_cTabTmp)->TM_PARCELA	:= (_cQTmp)->E1_PARCELA
				(_cTabTmp)->TM_TIPO		:= (_cQTmp)->E1_TIPO
				(_cTabTmp)->TM_CLIFOR	:= (_cQTmp)->E1_CLIENTE
				(_cTabTmp)->TM_LOJA		:= (_cQTmp)->E1_LOJA
				(_cTabTmp)->TM_NOME		:= (_cQTmp)->E1_NOMERAZ
				(_cTabTmp)->TM_SALDO	:= (_cQTmp)->E1_VALOR
				(_cTabTmp)->TM_VLRCOMP	:= (_cQTmp)->CMPDIVER-(_cQTmp)->SLDCOMP
				(_cTabTmp)->TM_SLDCOMP	:= (_cQTmp)->SLDCOMP
				(_cTabTmp)->TM_RECSZH	:= (_cQTmp)->TM_RECSZH
				(_cTabTmp)->TM_RECSE1	:= (_cQTmp)->TM_RECSE1
				(_cTabTmp)->TM_VALOR	:= (_cQTmp)->TM_VALOR-(_cQTmp)->CMPDIVER
				(_cTabTmp)->TM_CMPDIV	:= (_cQTmp)->CMPDIVER
				(_cTabTmp)->TM_PEDIDO	:= (_cQTmp)->PEDIDO
			(_cTabTmp)->(MsUnLock())
			_nValSel += (_cQTmp)->SLDCOMP
		endif
		dbSelectArea(_cQTmp)
		(_cQTmp)->(dbSkip())
	enddo
	if Select(_cQTmp) > 0 
		(_cQTmp)->(dbCloseArea()) //Fecho a tabela temporária com base no resultado da query
	endif
	//Campos que serão apresentados no markbrowse
	AADD(_aCampos,{"TM_OK"  		,"" ,Space(_nTamMark)		,"" })
	AADD(_aCampos,{"TM_PREFIXO" 	,"" ,"Prefixo"   			,"" })
	AADD(_aCampos,{"TM_NUM" 		,"" ,"Numero"   			,"" })
	AADD(_aCampos,{"TM_PARCELA"		,"" ,"Parcela"   			,"" })
	AADD(_aCampos,{"TM_TIPO"		,"" ,"Tipo"   				,"" })
	AADD(_aCampos,{"TM_CLIFOR"		,"" ,"Cli/For"   			,"" })
	AADD(_aCampos,{"TM_NOME"		,"" ,"Nome"   				,"" })
	AADD(_aCampos,{"TM_SALDO"		,"" ,"Saldo do Titulo"		,"" })
	AADD(_aCampos,{"TM_VLRCOMP"		,"" ,"Valor Relacionado"	,"" })
	AADD(_aCampos,{"TM_SLDCOMP"		,"" ,"Valor a Relacionar"	,"" })
	dbSelectArea(_cTabTmp)
	(_cTabTmp)->(dbGoTop())
	//Faço a instancia do markbrowse
	oMark := MsSelect():New(_cTabTmp,"TM_OK",,_aCampos,lInverte,@cMark,{aSizFrm[1]+028, aSizFrm[1]+008, (_aSize[6]*0.50)-((_nMargem+_nAltBut)*2), _aSize[3]-_nMargem})
	oMark:oBrowse:lHasMARK    := .T.
	oMark:oBrowse:lCanAllMARK := .T.
	oMark:bAval               := {|| ChkMarca(oMark,cMark)}
	AddColMARK(oMark,"TM_OK")
return _lRetm
/*/{Protheus.doc} ChkMarca (RFINE021)
@description Função responsável por marcar/desmarcar o título a ser compensado e o valor a ser compensado.
@author Adriano L. de Souza
@since 14/07/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ChkMarca(oMark,cMark)
//	local _nReg := Recno()
	dbSelectArea(_cTabTmp)
	if !Empty((_cTabTmp)->(TM_OK))
		while !RecLock(_cTabTmp,.F.) ; enddo
			(_cTabTmp)->(TM_OK)		:= Space(_nTamMark)
			_nValSel -= (_cTabTmp)->(TM_SLDCOMP)
			_nSldAnt := (_cTabTmp)->(TM_SLDCOMP)
			(_cTabTmp)->(TM_SLDCOMP):= 0
			(_cTabTmp)->(TM_SALDO  )+= _nSldAnt
		(_cTabTmp)->(MsUnLock())
	else
		while !RecLock(_cTabTmp,.F.) ; enddo
			ValorComp() //Abre getDados para informe do valor a ser compensado
			_nValSel += IIF(Type("_nVlrComp")<>"N",0,_nVlrComp)
	        //Certifico que algum valor foi selecionado para compensação
			if _nVlrComp>0
				(_cTabTmp)->(TM_OK)	:= cMark
			else
				(_cTabTmp)->(TM_OK)	:= Space(_nTamMark)
			endif
			(_cTabTmp)->(TM_SLDCOMP) := _nVlrComp
			(_cTabTmp)->(TM_SALDO  ) -= (_cTabTmp)->(TM_SLDCOMP)
		(_cTabTmp)->(MsUnLock())
	endif
	oMark:oBrowse:Refresh()
	lblSelecionado:SetText(Transform(_nValSel,PesqPict("SC9","C9_PRCVEN")))
return
/*/{Protheus.doc} TotPedido (RFINE021)
@description Função responsável por retornar o total do pedido (liberado) para estabelecer o valor limite a ser compensado.
@author Adriano L. de Souza
@since 15/07/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function TotPedido()
	local _nTotal := 0
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	if SC5->(MsSeek(xFilial("SC5")+SC9->C9_PEDIDO,.T.,.F.))
		//Inicio o processamento do MaFis() para contabilização dos impostos
		MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C",SC5->C5_TIPO,SC5->C5_TIPOCLI,MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR730")
		dbSelectArea("SC6")
		SC6->(dbSetOrder(1)) //Filial + Numero do pedido + Item
		if SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM,.T.,.F.))
			while !SC6->(EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == SC5->C5_NUM
				if (SC6->C6_QTDVEN-SC6->C6_QTDENT) > 0 //Certifico que existe saldo a faturar para o item corrente
					nPrcTot := (SC6->C6_QTDEMP*SC6->C6_PRCVEN) //Considero o valor da quantidade liberada apenas
					nPrcUni := SC6->C6_PRCVEN
					MaFisAdd(SC6->C6_PRODUTO,SC6->C6_TES,SC6->C6_QTDVEN,nPrcUni,0,"","",0,0,0,0,0,nPrcTot,0,0,0)
				endif
				dbSelectArea("SC6")
				SC6->(dbSetOrder(1)) //Filial + Numero do pedido
				SC6->(dbSkip())
			enddo
			_nTotal	:= MaFisRet(1,"NF_TOTAL") //Recupero o valor total do pedido (considerando parte liberada apenas)
		endif
		//Encerro o MaFis()
		MaFisEnd()
	endif
return _nTotal
/*/{Protheus.doc} ValorComp (RFINE021)
@description Função responsável por montar tela para informe do valor a ser compensado.
@author Adriano L. de Souza
@since 15/07/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValorComp()
	local oGetb
	local oGroupb
	local oSayb
	local oSButtonb
	_nHandle        := GetFocus()
	_nVlrComp       := 0
	if _nLimite > 0 .AND. _nValSel < _nLimite
		if (_cTabTmp)->(TM_SALDO) <= _nLimite .AND. (_cTabTmp)->(TM_SALDO) <= (_nLimite - _nValSel)
			_nVlrComp := (_cTabTmp)->(TM_SALDO)
		else
			_nVlrComp := _nLimite - _nValSel
		endif
	endif
	//Verifico se a tela já está aberta
	if oDlgb <> nil
		return
	endif
	static oDlgb
	DEFINE MSDIALOG oDlgb TITLE "Adiantamento" FROM 000, 000 TO 130, 240 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
		oDlgb:lEscClose := .F.
		@ 007, 003 GROUP oGroupb TO 058, 116 	PROMPT " Informe o valor a ser compensado " OF oDlgb COLOR  0, 16777215 PIXEL
		@ 021, 010   SAY   oSayb 				PROMPT "Valor:" SIZE 037, 007 				OF oDlgb COLORS 0, 16777215 PIXEL
		@ 019, 045 MSGET   oGetb VAR _nVlrComp SIZE 060, 010 OF oDlgb PICTURE PesqPict("SC9","C9_PRCVEN") VALID Positivo() .And. (_nVlrComp<=_nLimite) .And. (_nVlrComp<=(_cTabTmp)->(TM_SALDO)) .And. (_nValSel+_nVlrComp)<=_nLimite COLORS 0, 16777215 PIXEL
		DEFINE SBUTTON oSButtonb FROM 039, 048 TYPE 01 OF oDlgb ENABLE ACTION (Close(oDlgb))
	ACTIVATE MSDIALOG oDlgb CENTERED
	oDlg:SetFocus(_nHandle)
return
/*/{Protheus.doc} Confirmar (RFINE021)
@description Função responsável por gravar o vínculo entre o pedido e os títulos de crédito (RAs/NCCs).
@author Adriano L. de Souza
@since 15/07/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Confirmar()
	_lRetCmp := .F.
	dbSelectArea(_cTabTmp)
	(_cTabTmp)->(dbSetOrder(1))
	(_cTabTmp)->(dbGoTop())
	while !(_cTabTmp)->(EOF()) //Varro a tabela temporária do markbrowse
		if ((_cTabTmp)->TM_RECSZH)>0 .And. ((_cTabTmp)->TM_PEDIDO)==SC9->C9_PEDIDO //Verifico se o título já existe na SZH
			dbSelectArea("SZH")
			dbGoTo((_cTabTmp)->TM_RECSZH)
			if (_cTabTmp)->TM_SLDCOMP>0 //Certifico que o valor a ser compensado é maior que zero
				_lRetCmp := .T.
				while !RecLock("SZH",.F.) ; enddo
					SZH->ZH_VALOR := (_cTabTmp)->TM_SLDCOMP
					SZH->ZH_SALDO := (_cTabTmp)->TM_SLDCOMP
				SZH->(MsUnlock())
				//Gravo o número do pedido no título que estão sendo compensado (no caso do título ser vínculado a mais de um pedido, será preservado o último)
				if ((_cTabTmp)->TM_RECSE1)>0
					dbSelectArea("SE1")
					dbGoTo((_cTabTmp)->TM_RECSE1)
					while !RecLock("SE1",.F.) ; enddo
						SE1->E1_PEDIDO := SC9->C9_PEDIDO
					SE1->(MsUnlock())
				endif
			else //Caso o valor compensado seja menor que zero, deleto o vínculo do título com o pedido
				while !RecLock("SZH",.F.) ; enddo
					SZH->(dbDelete())
				SZH->(MsUnlock())
				//Limpo o número do pedido do título
				if ((_cTabTmp)->TM_RECSE1)>0
					dbSelectArea("SE1")
					dbGoTo((_cTabTmp)->TM_RECSE1)
					while !RecLock("SE1",.F.) ; enddo
						SE1->E1_PEDIDO := ""
					SE1->(MsUnlock())
				endif
			endif
		elseif ((_cTabTmp)->TM_SLDCOMP)>0 //Caso o título esteja marcado, mas ainda não existe na SZH, faço a inclusão
			_lRetCmp := .T.
			dbSelectArea("SZH")
			while !RecLock("SZH",.T.) ; enddo
				SZH->ZH_FILIAL	:= xFilial("SZH")
				SZH->ZH_CART	:= "R" //Recebimento
				SZH->ZH_PEDIDO	:= SC9->C9_PEDIDO
				SZH->ZH_PREFIX	:= (_cTabTmp)->TM_PREFIXO
				SZH->ZH_NUM		:= (_cTabTmp)->TM_NUM
				SZH->ZH_PARCEL	:= (_cTabTmp)->TM_PARCELA
				SZH->ZH_TIPO	:= (_cTabTmp)->TM_TIPO
				SZH->ZH_CLIENT	:= (_cTabTmp)->TM_CLIFOR
				SZH->ZH_FORNEC	:= ""
				SZH->ZH_LOJA	:= (_cTabTmp)->TM_LOJA
				SZH->ZH_VALOR 	:= (_cTabTmp)->TM_SLDCOMP
				SZH->ZH_SALDO 	:= (_cTabTmp)->TM_SLDCOMP
			SZH->(MsUnLock())
			//Gravo o número do pedido no título que está sendo compensado (no caso do título ser vínculado a mais de um pedido, será preservado o último pedido vinculado)
			if ((_cTabTmp)->TM_RECSE1)>0
				dbSelectArea("SE1")
				dbGoTo((_cTabTmp)->TM_RECSE1)
				while !RecLock("SE1",.F.) ; enddo
					SE1->E1_PEDIDO := SC9->C9_PEDIDO
				SE1->(MsUnlock())
			endif
		endif
		dbSelectArea(_cTabTmp)
		(_cTabTmp)->(dbSetOrder(1))
		(_cTabTmp)->(dbSkip())
	enddo
	//Fecho a tabela temporária
	dbSelectArea(_cTabTmp)
	(_cTabTmp)->(dbCloseArea())
	//Fecho a tela de diálogo
	Close(oDlg)
return