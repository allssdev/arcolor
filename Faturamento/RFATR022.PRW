#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*/{Protheus.doc} RFATR022
Relatório posição comercial com exportação em Excel
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 31/01/2022
@version P12
@type Function
@obs Sem observações
@see https://allss.com.br
@history 07/07/2014, Júlio Soares, Foi realizado alteração no fonte para ajustar as condições do filtro sendo criado o parâmetro MV_FATR022 para inserir os usuários com permissão para visualizar todas as colunas.
@history 27/06/2016, Júlio Soares, Inserido parâmetros e condições para que o relatório possa ser emitido em outras moedas conforme cadastro de moedas.
@history 02/02/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adição de coluna com a contagem da quantidade de pedidos que representam o valor apresentado no relatório e revisão de declaração de variáveis locais.
/*/
User Function RFATR022()
Local   _aSavArea  := GetArea()
Private _cRotina   := "RFATR022"
Private _cPerg      := _cRotina
Private _cTitulo   := ""
Private _cTitulo2  := ""
Private _cQuery    := ""
Private _tAlias	   := "TMPRFT22"
Private _cCampos   := ""
Private _aColuns   := {}
Private _lRet      := .T.
Private _lValid    := __cUserId $ (SuperGetMv('MV_FATR022',,'000000'))
Private _lEnt      := + CHR(13) + CHR(10)

ValidPerg()

// - PERGUNTA DE CANCELAMENTO
IF !Pergunte(_cPerg,.T.)
	If MsgYesNo("Deseja cancelar a emissão do relatório?",_cRotina+"_001")
		Return()
	EndIf
ENDIF

IF ((MV_PAR03) == 2) .And. (Empty(MV_PAR11))
	MSGBOX('NÃO É POSSÍVEL INSERIR A APRESENTAÇÃO DA COLUNA DE "EMISSAO" SE O PARÂMETRO "Até pedido" NÃO ESTIVER PREENCHIDO',_cRotina + '_02','STOP')
	IF !Pergunte(_cPerg,.T.)
		Return()
	ENDIF	
ENDIF
// - VERIFICA SE USUÁRIO TEM PERMISSÃO PARA GERAR DADOS EM EXCEL
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usuário sem permissão para gerar relatório em Excel. Informe o Administrador.',_cRotina +"03",'STOP')
   Return(Nil)
EndIf
/* - VERIFICA SE HÁ O EXCEL INSTALADO NA MÁQUINA EM USO
If !ApOleClient('MsExcel')
	Msgbox('Excel não instalado.',_cRotina +"04",'ALERT')
   Return(Nil)
EndIf*/

_cTitulo  := (" Posição comercial dos pedidos de " + (DTOC(mv_par01)) + "  até  " + (DTOC(mv_par02)) + IIF(!Empty(MV_PAR13)," em "+GetMV("MV_MOEDA"+MV_PAR13+""),"") + "  -  " + _cRotina)
_cTitulo2 := ("PARÂMETROS")
// Verifica a moeda selecionada
If !Empty(MV_PAR13) .And. MV_PAR13 <> '1'
	dbSelectArea("SM2")
	dbSetOrder(1) // M2_DATA
	If MsSeek(MV_PAR14,.T.,.F.)
		If Empty(&("M2_MOEDA"+MV_PAR13))
			MSGBOX("Não existe cotação cadastrada para a moeda "+GetMV("MV_MOEDA"+MV_PAR13+"")+" em "+DtoC(MV_PAR14)+". Verifique o cadastro de moedas.",_cRotina+"_000","STOP")
			Return()
		EndIf
	EndIf
EndIf
// CHAMA FUNÇÃO DE CONSULTA CONFORME PARÂMETROS DEFINIDO PELO USUÁRIO
//MsgRun("Selecionando dados... Por favor AGUARDE. ",_cTitulo,{ || SelectQry()})
Processa({ || SelectQry() },_cTitulo,"Selecionando dados... Por favor AGUARDE. ",.T.)
// - CHAMA A FUNÇÃO PARA EMITIR OS DADOS EM PLANILHA
If ! Empty(_cQuery)
	Processa({ |lEnd| Geraxls(@lEnd) },_cTitulo," Gerando relatório em Excel...   Por favor aguarde.",.T.)
EndIf

// - SE A TABELA APRESENTAR DADOS FECHA A MESMA APÓS O USO
If Select (_tAlias) > 0
   (_tAlias)->(dbCloseArea())
EndIf

RestArea(_aSavArea)
                                                                              
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SelectQry   º Autor ³Júlio Soares       º Data ³  04/10/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seleção da Query                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para empresa ARCOLOR              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SelectQry()
// - COLUNAS
If (MV_PAR03) == 2 // - IMPRIME OU NAO A COLUNA EMISSAO
	_cCampos := "(_tAlias)->EMISSAO,"
EndIf
If !Empty (MV_PAR06) .And.  !Empty(MV_PAR07)
	_cCampos += "(_tAlias)->CLIENTE,(_tAlias)->LOJA,(_tAlias)->NOME_CLIENTE,"
EndIf
If !Empty (MV_PAR09)
	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	//_cCampos += "(_tAlias)->VENDEDOR,(_tAlias)->NOME_VENDEDOR,"
	_cCampos += "(_tAlias)->REPRESENTANTE,(_tAlias)->NOME_REPRESENTANTE,"
	// Fim - Fernando Bombardi - ALLSS - 02/03/2022
EndIf
//********************************************************************
// INICIO
// ARCOLOR - Inclusão da coluna com a quantidade de pedidos
// RODRIGO TELECIO EM 02/02/2022
//********************************************************************
if !Empty (MV_PAR11)
	_cCampos += "(_tAlias)->PEDIDO,"
	_cCampos += "(_tAlias)->OPERACAO,"
else
	_cCampos += "(_tAlias)->QTD_PED,"
endif
// FIM
//********************************************************************
_cCampos += "(_tAlias)->VENDIDO"
If (_lValid) // Permite impressão das demais colunas apenas para usuários autorizados
	_cCampos += ", (_tAlias)->PENDENTE, (_tAlias)->SALDO, (_tAlias)->FATURADO, (_tAlias)->CANCELADO"
EndIf

// - Início da formação da Query
_cQuery := " SELECT " + _lEnt
// - Inclui a coluna de emissão conforme preenchimento do parâmetro
If (MV_PAR03) == 2
	_cQuery += " SUBSTRING(EMISSAO,7,2) + '/' + SUBSTRING(EMISSAO,5,2) + '/' + SUBSTRING(EMISSAO,1,4) [EMISSAO], " + _lEnt
EndIf
// - Inclui as colunas do cliente conforme preenchimento do parâmetro
If !Empty (MV_PAR06) .And.  !Empty(MV_PAR07)
	_cQuery += " CLIENTE, LOJA, NOME_CLIENTE, "                                                                                                + _lEnt
EndIf
// - Inclui a coluna do vendedor conforme preenchimento do parâmetro
If !Empty (MV_PAR09)
	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	//_cQuery += " VENDEDOR, SA3.A3_NOME[NOME_VENDEDOR],"                                                                                        + _lEnt
	_cQuery += " REPRESENTANTE, SA3.A3_NOME[NOME_REPRESENTANTE],"                                                                                        + _lEnt
	// Fim - Fernando Bombardi - ALLSS - 02/03/2022
EndIf
// Inclui a coluna dos pedidos conforme preenchimento do parâmetro
//********************************************************************
// INICIO
// ARCOLOR - Inclusão da coluna com a quantidade de pedidos
// RODRIGO TELECIO EM 02/02/2022
//********************************************************************
if !Empty (MV_PAR11)
	_cQuery += " PEDIDO, "                                                                                                                     + _lEnt
	_cQuery += " OPERACAO, "                                                                                                                     + _lEnt
else
	_cQuery += " COUNT(DISTINCT PEDIDO) AS QTD_PED, "                                                                                                              + _lEnt
endif
// FIM
//********************************************************************
// Trecho alterado para inserir tratamento de cálculo em outras moedas.
If Empty(MV_PAR13) .Or. MV_PAR13 == '1'
	_cQuery += " ROUND(SUM(VENDIDO),2)[VENDIDO] "                                                                                                  + _lEnt
	If (_lValid)
		_cQuery += " ,"
		_cQuery += " ROUND(SUM(PENDENTE),2)  [PENDENTE], " + _lEnt
		_cQuery += " ROUND(SUM(SALDO),2)     [SALDO],    " + _lEnt
		_cQuery += " ROUND(SUM(FATURADO),2)  [FATURADO], " + _lEnt
		_cQuery += " ROUND(SUM(CANCELADO),2) [CANCELADO] " + _lEnt
	EndIf
ElseIf !Empty(MV_PAR13) .And. MV_PAR13 <> '1'
	_cQuery += " ROUND(SUM(VENDIDO)  * SM2.M2_MOEDA"+MV_PAR13+",2)[VENDIDO] "    + _lEnt
	If (_lValid)
	_cQuery += " ,"
	_cQuery += " ROUND(SUM(PENDENTE) * SM2.M2_MOEDA"+MV_PAR13+",2) [PENDENTE], " + _lEnt
	_cQuery += " ROUND(SUM(SALDO)    * SM2.M2_MOEDA"+MV_PAR13+",2) [SALDO], "    + _lEnt
	_cQuery += " ROUND(SUM(FATURADO) * SM2.M2_MOEDA"+MV_PAR13+",2) [FATURADO], " + _lEnt
	_cQuery += " ROUND(SUM(CANCELADO)* SM2.M2_MOEDA"+MV_PAR13+",2) [CANCELADO] " + _lEnt
	EndIf
EndIf
// Fim trecho alterado.

_cQuery += " FROM "                                                                                                                            + _lEnt

// Trecho dos valores sobre Vendas
_cQuery += " ( "                                                                                                                               + _lEnt
_cQuery += " SELECT SC5.C5_EMISSAO[EMISSAO],SC5.C5_CLIENTE[CLIENTE],C5_LOJACLI[LOJA],C5_NOMCLI[NOME_CLIENTE], "                                + _lEnt
// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
//_cQuery += " C5_VEND1[VENDEDOR],C5_DESCVEN[NOME_VENDEDOR] "                                                                                    + _lEnt
_cQuery += " C5_VEND1[REPRESENTANTE],C5_DESCVEN[NOME_REPRESENTANTE] "                                                                                    + _lEnt
// Fim - Fernando Bombardi - ALLSS - 02/03/2022
_cQuery += " ,C6_NUM[PEDIDO],C5_TIPO[TIPO],C5_TPOPER[OPERACAO],"                                                                               + _lEnt
_cQuery += " (C6_QTDVEN*C6_PRCVEN)[VENDIDO],0[PENDENTE],0[SALDO],0[FATURADO],0[CANCELADO] "                                                    + _lEnt
_cQuery += " FROM " + RetSqlName("SC5") + " SC5 "                                                                                              + _lEnt
_cQuery += " 	INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' "                                                              + _lEnt
_cQuery += " 		AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "                                                                            + _lEnt
_cQuery += " 		AND SC5.C5_CLIENTE = SC6.C6_CLI "                                                                                          + _lEnt
_cQuery += " 		AND SC5.C5_LOJACLI = SC6.C6_LOJA "                                                                                         + _lEnt
_cQuery += " 		AND SC5.C5_NUM     = SC6.C6_NUM "                                                                                          + _lEnt
_cQuery += " 	INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' "                                                              + _lEnt
_cQuery += " 		AND SF4.F4_FILIAL  = '" + xFilial("SF4") + "' "                                                                            + _lEnt
_cQuery += " 		AND SF4.F4_CODIGO  = SC6.C6_TES "                                                                                          + _lEnt
//_cQuery += " 		AND SF4.F4_DUPLIC  = 'S' "                                                                                                 + _lEnt
_cQuery += " WHERE SC5.D_E_L_E_T_ = '' "                                                                                                       + _lEnt

_cQuery += " UNION ALL "                                                                                                                       + _lEnt

// Trecho dos valores Pendentes
_cQuery += " SELECT SC5A.C5_EMISSAO[EMISSAO],SC5A.C5_CLIENTE[CLIENTE],SC5A.C5_LOJACLI[LOJA],SC5A.C5_NOMCLI[NOME_CLIENTE], "                    + _lEnt
// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
//_cQuery += "  SC5A.C5_VEND1[VENDEDOR],SC5A.C5_DESCVEN[NOME_VENDEDOR], SC5A.C5_NUM[PEDIDO],SC5A.C5_TIPO[TIPO],C5_TPOPER[OPERACAO], "            + _lEnt
_cQuery += "  SC5A.C5_VEND1[REPRESENTANTE],SC5A.C5_DESCVEN[NOME_REPRESENTANTE], SC5A.C5_NUM[PEDIDO],SC5A.C5_TIPO[TIPO],C5_TPOPER[OPERACAO], "            + _lEnt
// Fim - Fernando Bombardi - ALLSS - 02/03/2022
_cQuery += "  0[VENDIDO],SC5A.PENDENTE[PENDENTE],0[SALDO],0[FATURADO],0[CANCELADO] "                                                           + _lEnt
_cQuery += "  FROM ( "                                                                                                                         + _lEnt
_cQuery += " 	SELECT SC5.C5_EMISSAO,SC5.C5_NUM,SC5.C5_CLIENTE,C5_LOJACLI,C5_NOMCLI, "                                                        + _lEnt
_cQuery += " 	C5_VEND1,C5_DESCVEN,C5_TIPO,C5_TPOPER, "                                                                                       + _lEnt
_cQuery += " 	SUM(SC6.C6_QTDVEN)[QTDVEN],SUM(SC6.C6_QTDENT)[QTDENT], "                                                                       + _lEnt
_cQuery += " 	SUM((SC6.C6_QTDVEN - SC6.C6_QTDENT )*SC6.C6_PRCVEN)[PENDENTE] "                                                                + _lEnt
_cQuery += " 	FROM " + RetSqlName("SC5") + " SC5 "                                                                                           + _lEnt
_cQuery += " 	 	INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' "                                                          + _lEnt
_cQuery += "  			AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "                                                                        + _lEnt
_cQuery += "  			AND SC5.C5_CLIENTE = SC6.C6_CLI "                                                                                      + _lEnt
_cQuery += "  			AND SC5.C5_LOJACLI = SC6.C6_LOJA "                                                                                     + _lEnt
_cQuery += "  			AND SC5.C5_NUM     = SC6.C6_NUM "                                                                                      + _lEnt
_cQuery += "  		INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' "                                                          + _lEnt
_cQuery += " 	 		AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "                                                                         + _lEnt
_cQuery += "  			AND SF4.F4_CODIGO = SC6.C6_TES "                                                                                       + _lEnt
//_cQuery += "  			AND SF4.F4_DUPLIC = 'S' "                                                                                              + _lEnt
_cQuery += " 	WHERE SC5.D_E_L_E_T_ = '' "                                                                                                    + _lEnt
_cQuery += " 	AND (SC6.C6_BLQ <> 'R' OR SUBSTRING(C5_NOTA,1,1) <> 'X') "                                                                     + _lEnt
_cQuery += " 	GROUP BY C5_EMISSAO,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_NOMCLI,C5_VEND1,C5_DESCVEN,C5_TIPO,C5_TPOPER "                             + _lEnt
_cQuery += " 	) SC5A "                                                                                                                       + _lEnt
_cQuery += " WHERE SC5A.QTDENT = 0 "                                                                                                           + _lEnt

_cQuery += " UNION ALL "                                                                                                                       + _lEnt

// Trecho dos valores de Saldo
_cQuery += " SELECT SC5B.C5_EMISSAO[EMISSAO],SC5B.C5_CLIENTE[CLIENTE],SC5B.C5_LOJACLI[LOJA],SC5B.C5_NOMCLI[NOME_CLIENTE], "                    + _lEnt

// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
//_cQuery += " SC5B.C5_VEND1[VENDEDOR],SC5B.C5_DESCVEN[NOME_VENDEDOR],SC5B.C5_NUM[PEDIDO],SC5B.C5_TIPO[TIPO],SC5B.C5_TPOPER[OPERACAO], "         + _lEnt
_cQuery += " SC5B.C5_VEND1[REPRESENTANTE],SC5B.C5_DESCVEN[NOME_REPRESENTANTE],SC5B.C5_NUM[PEDIDO],SC5B.C5_TIPO[TIPO],SC5B.C5_TPOPER[OPERACAO], "         + _lEnt
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

_cQuery += " 0[VENDIDO],0[PENDENTE],SC5B.SALDO[SALDO],0[FATURADO],0[CANCELADO] "                                                               + _lEnt
_cQuery += " FROM ( "                                                                                                                          + _lEnt
_cQuery += " 	SELECT SC5.C5_EMISSAO,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_NOMCLI,SC5.C5_VEND1,SC5.C5_DESCVEN, "                               + _lEnt
_cQuery += " 	SC5.C5_NUM,SC5.C5_TIPO,SC5.C5_TPOPER, "                                                                                        + _lEnt
_cQuery += " 	SUM(SC6.C6_QTDVEN)[VEND],SUM(SC6.C6_QTDENT)[QTDENT], SUM((SC6.C6_QTDVEN - SC6.C6_QTDENT )*SC6.C6_PRCVEN)[SALDO] "              + _lEnt
_cQuery += " 	FROM " + RetSqlName("SC5") + " SC5 "                                                                                           + _lEnt
_cQuery += " 	INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' "                                                              + _lEnt
_cQuery += " 			AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "                                                                        + _lEnt
_cQuery += "  			AND SC5.C5_CLIENTE = SC6.C6_CLI "                                                                                      + _lEnt
_cQuery += "  			AND SC5.C5_LOJACLI = SC6.C6_LOJA "                                                                                     + _lEnt
_cQuery += "  			AND SC5.C5_NUM     = SC6.C6_NUM "                                                                                      + _lEnt
_cQuery += " 	INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' "                                                              + _lEnt
_cQuery += " 			AND SF4.F4_FILIAL  = '" + xFilial("SF4") + "' "                                                                        + _lEnt
_cQuery += "  			AND SF4.F4_CODIGO = SC6.C6_TES "                                                                                       + _lEnt
//_cQuery += "  			AND SF4.F4_DUPLIC = 'S' "                                                                                              + _lEnt
_cQuery += " 	WHERE SC5.D_E_L_E_T_ = '' "                                                                                                    + _lEnt
_cQuery += " 	AND (SC6.C6_BLQ <> 'R' OR SUBSTRING(C5_NOTA,1,1) <> 'X') "                                                                     + _lEnt
_cQuery += " 	GROUP BY C5_EMISSAO,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_NOMCLI,C5_VEND1,C5_DESCVEN,C5_TIPO,C5_TPOPER "                             + _lEnt
_cQuery += " 	)SC5B "                                                                                                                        + _lEnt
_cQuery += " WHERE SC5B.QTDENT > 0 "                                                                                                           + _lEnt

_cQuery += " UNION ALL "                                                                                                                       + _lEnt

// Trecho dos valores Faturados

// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
//_cQuery += " SELECT SC5.C5_EMISSAO[EMISSAO],SC5.C5_CLIENTE[CLIENTE],C5_LOJACLI[LOJA],C5_NOMCLI[NOME_CLIENTE],C5_VEND1[VENDEDOR],"              + _lEnt
//_cQuery += " C5_DESCVEN[NOME_VENDEDOR] "                                                                                                       + _lEnt
_cQuery += " SELECT SC5.C5_EMISSAO[EMISSAO],SC5.C5_CLIENTE[CLIENTE],C5_LOJACLI[LOJA],C5_NOMCLI[NOME_CLIENTE],C5_VEND1[REPRESENTANTE],"              + _lEnt
_cQuery += " C5_DESCVEN[NOME_REPRESENTANTE] "                                                                                                       + _lEnt
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

_cQuery += " ,C6_NUM[PEDIDO],C5_TIPO[TIPO],C5_TPOPER[OPERACAO], "                                                                              + _lEnt
_cQuery += " 0[VENDIDO],0[PENDENTE],0[SALDO],(C6_QTDENT*C6_PRCVEN)[FATURADO],0[CANCELADO] "                                                    + _lEnt
_cQuery += " FROM " + RetSqlName("SC5") + " SC5 "                                                                                              + _lEnt
_cQuery += " 	INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' "                                                              + _lEnt
_cQuery += " 		AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "                                                                            + _lEnt
_cQuery += " 		AND SC5.C5_CLIENTE = SC6.C6_CLI "                                                                                          + _lEnt
_cQuery += " 		AND SC5.C5_LOJACLI = SC6.C6_LOJA "                                                                                         + _lEnt
_cQuery += " 		AND SC5.C5_NUM = SC6.C6_NUM "                                                                                              + _lEnt
_cQuery += " 	INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' "                                                              + _lEnt
_cQuery += " 		AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "                                                                             + _lEnt
_cQuery += " 		AND SF4.F4_CODIGO = SC6.C6_TES "                                                                                           + _lEnt
//_cQuery += " 		AND SF4.F4_DUPLIC = 'S' "                                                                                                  + _lEnt
_cQuery += " WHERE SC5.D_E_L_E_T_ = '' "                                                                                                       + _lEnt
_cQuery += " AND SC5.C5_TIPO = 'N' "                                                                                                           + _lEnt
_cQuery += " UNION ALL "                                                                                                                       + _lEnt

// Trecho dos valores dos Cancelados
// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
//_cQuery += " SELECT SC5.C5_EMISSAO[EMISSAO],SC5.C5_CLIENTE[CLIENTE],C5_LOJACLI[LOJA],C5_NOMCLI[NOME_CLIENTE],C5_VEND1[VENDEDOR],"              + _lEnt
//_cQuery += " C5_DESCVEN[NOME_VENDEDOR] "                                                                                                       + _lEnt
_cQuery += " SELECT SC5.C5_EMISSAO[EMISSAO],SC5.C5_CLIENTE[CLIENTE],C5_LOJACLI[LOJA],C5_NOMCLI[NOME_CLIENTE],C5_VEND1[REPRESENTANTE],"              + _lEnt
_cQuery += " C5_DESCVEN[NOME_REPRESENTANTE] "                                                                                                       + _lEnt
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

_cQuery += " ,C6_NUM[PEDIDO],C5_TIPO[TIPO],C5_TPOPER[OPERACAO], "                                                                              + _lEnt
_cQuery += " 0[VENDIDO],0[PENDENTE],0[SALDO],0[FATURADO],(((C6_QTDVEN-C6_QTDENT)*C6_PRCVEN))[CANCELADO] "                                      + _lEnt
_cQuery += " FROM " + RetSqlName("SC5") + " SC5 "                                                                                              + _lEnt
_cQuery += " 	INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' "                                                              + _lEnt
_cQuery += " 		AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "                                                                            + _lEnt
_cQuery += " 		AND SC5.C5_CLIENTE = SC6.C6_CLI "                                                                                          + _lEnt
_cQuery += " 		AND SC5.C5_LOJACLI = SC6.C6_LOJA "                                                                                         + _lEnt
_cQuery += " 		AND SC5.C5_NUM = SC6.C6_NUM "                                                                                              + _lEnt
_cQuery += " 	INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' "                                                              + _lEnt
_cQuery += " 		AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "                                                                             + _lEnt
_cQuery += " 		AND SF4.F4_CODIGO = SC6.C6_TES "                                                                                           + _lEnt
//_cQuery += " 		AND SF4.F4_DUPLIC = 'S' "                                                                                                  + _lEnt
_cQuery += " WHERE SC5.D_E_L_E_T_ = '' "                                                                                                       + _lEnt
_cQuery += " AND SC5.C5_TIPO = 'N' "                                                                                                           + _lEnt
_cQuery += " AND (SC6.C6_BLQ = 'R') "                                                                                                          + _lEnt
_cQuery += " ) PED "                                                                                                                           + _lEnt
_cQuery += " 	INNER JOIN SA3010 SA3 ON SA3.D_E_L_E_T_ = '' "                                                                                 + _lEnt
_cQuery += " 		AND SA3.A3_FILIAL = '" + xFilial("SA3") + "' "                                                                             + _lEnt

// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
//_cQuery += " 		AND PED.VENDEDOR  = SA3.A3_COD "                                                                                           + _lEnt
_cQuery += " 		AND PED.REPRESENTANTE  = SA3.A3_COD "                                                                                           + _lEnt
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

// - Alterado em 27/06/2016 por Júlio Soares
If !Empty(MV_PAR13) .And. MV_PAR13 <> '1' // Se moeda for diferente de 1 (Real)
	_cQuery += " INNER JOIN "+RetSqlName("SM2")+" SM2 "                                                                                        + _lEnt
	_cQuery += " ON SM2.M2_DATA  = '"+DTOS(MV_PAR14)+"' "
	_cQuery += " AND SM2.D_E_L_E_T_ = '' "
EndIf
// Fim alteração
_cQuery += " WHERE PED.EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "                                                 + _lEnt

// - ATÉ CLIENTE + LOJA	
If !Empty (MV_PAR06) .And. !Empty (MV_PAR07)
	_cQuery += " AND PED.CLIENTE  BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "' "                                                          + _lEnt
	_cQuery += " AND PED.LOJA     BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' "                                                          + _lEnt
Else
	_cQuery += " AND PED.CLIENTE  BETWEEN '' AND 'ZZZZZZ' "                                                                                    + _lEnt
	_cQuery += " AND PED.LOJA     BETWEEN '' AND 'ZZ' "                                                                                        + _lEnt
EndIf

// - ATÉ VENDEDOR
// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
/*
If !Empty (MV_PAR09)
	_cQuery += " AND PED.VENDEDOR BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "                                                          + _lEnt
Else
	_cQuery += " AND PED.VENDEDOR BETWEEN '' AND 'ZZZZZZ' "                                                                                    + _lEnt
EndIf
*/
If !Empty (MV_PAR09)
	_cQuery += " AND PED.REPRESENTANTE BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "                                                          + _lEnt
Else
	_cQuery += " AND PED.REPRESENTANTE BETWEEN '' AND 'ZZZZZZ' "                                                                                    + _lEnt
EndIf
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

// - ATÉ PEDIDO
If !Empty (MV_PAR11)
	_cQuery += " AND PED.PEDIDO BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "' "                                                            + _lEnt
Else
	_cQuery += " AND PED.PEDIDO BETWEEN '' AND 'ZZZZZZ' "                                                                                      + _lEnt
EndIf

// - SOMENTE VENDAS
If (MV_PAR12) == 1
	_cQuery += " AND (PED.OPERACAO = '01' OR PED.OPERACAO = 'ZZ' OR PED.OPERACAO = '06' ) "                                                                            + _lEnt
	//_cQuery += " AND (PED.OPERACAO IN '"+FormatIn(SuperGetMv("MV_FATOPER",,"01|ZZ|9"),"|")+"') "                                               + _lEnt
EndIf         

 // - GROUP BY
_cQuery += " GROUP BY "                                                                                                                        + _lEnt
If (MV_PAR03) = 2
	_cQuery += " PED.EMISSAO, "                                                                                                                + _lEnt
EndIf
If !Empty (MV_PAR06) .And.  !Empty (MV_PAR07)
	_cQuery += " PED.CLIENTE, PED.LOJA, PED.NOME_CLIENTE, "                                                                                    + _lEnt
EndIf

// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
/*
If !Empty (MV_PAR09)
	_cQuery += " PED.VENDEDOR, SA3.A3_NOME "                                                                                                   + _lEnt
EndIf
*/
If !Empty (MV_PAR09)
	_cQuery += " PED.REPRESENTANTE, SA3.A3_NOME "                                                                                                   + _lEnt
EndIf
// Fim - Fernando Bombardi - ALLSS - 02/03/2022


If !Empty (MV_PAR11)
	_cQuery += " ,PED.PEDIDO "                                                                                                                 + _lEnt
	_cQuery += " ,PED.OPERACAO"                                                                                                                 + _lEnt
EndIf
If !Empty(MV_PAR13) .And. MV_PAR13 <> '1'
	_cQuery += " ,	SM2.M2_MOEDA"+MV_PAR13+"" + _lEnt
EndIf

// - ORDER BY
_cQuery += " ORDER BY "                                                                                                                        + _lEnt
If (MV_PAR03) = 2
	_cQuery += " PED.EMISSAO, "                                                                                                                + _lEnt
EndIf
If !Empty (MV_PAR06) .And.  !Empty (MV_PAR07)
	_cQuery += " PED.CLIENTE, PED.LOJA, PED.NOME_CLIENTE, "                                                                                    + _lEnt
EndIf

// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
/*
If !Empty (MV_PAR09)
	_cQuery += " PED.VENDEDOR "                                                                                                                + _lEnt
EndIf
*/
If !Empty (MV_PAR09)
	_cQuery += " PED.REPRESENTANTE "                                                                                                                + _lEnt
EndIf
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

If !Empty (MV_PAR11)
	_cQuery += " ,PED.PEDIDO "                                                                                                                 + _lEnt
EndIf	
//********************************************************************
// INICIO
// ARCOLOR - Inclusão da coluna com a quantidade de pedidos
// RODRIGO TELECIO EM 02/02/2022
//********************************************************************
MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.TXT",_cQuery)
// FIM
//********************************************************************
If  (Len(_cQuery) ) >0
	_cQuery := ChangeQuery(_cQuery)
Else
	MSGBOX('CONSULTA NÃO GERADA ','*** ***','STOP')
	Return()	
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_tAlias,.T.,.F.)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GeraXLS   º Autor ³Júlio Soares         º Data ³  04/10/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa criado para gerar em Excel a planilha conforme    º±±
±±º          ³ dados obtidos na consulta do banco                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para empresa ARCOLOR              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// - EXCEL OS DADOS DA TABELA TEMPORÁRIA PARA UMA PLANILHA
Static Function Geraxls(lEnd)
Local oExcel    := FWMSEXCEL():New()
Local _cSheet1  := (DTOC(MV_PAR01)) + " ~ " + (DTOC(MV_PAR02))
Local _cSheet2  := 'PARÂMETROS'
Local _cFileTMP := ""
Local _cFile    := ""
local _nCtn2	:= 0
local _nPosPar	:= 0
Private _aPar   := {}

oExcel:AddWorkSheet(_cSheet1)
oExcel:AddTable(_cSheet1,_cTitulo)

// - COLUNAS DO EXCEL
If (MV_PAR03) = 2
	oExcel:AddColumn(_cSheet1,_cTitulo,'EMISSAO'          	,2,4,.F.)
EndIf
If !Empty (MV_PAR06) .And.  !Empty (MV_PAR07)
	oExcel:AddColumn(_cSheet1,_cTitulo,'CLIENTE'      		,1,1,.F.)
	oExcel:AddColumn(_cSheet1,_cTitulo,'LOJA'         		,1,1,.F.)
	oExcel:AddColumn(_cSheet1,_cTitulo,'NOME_CLIENTE' 		,1,1,.F.)
EndIf
If !Empty (MV_PAR09)
	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	//oExcel:AddColumn(_cSheet1,_cTitulo,'VENDEDOR'     		,1,1,.F.)
	//oExcel:AddColumn(_cSheet1,_cTitulo,'NOME_VENDEDOR'		,1,1,.F.)

	oExcel:AddColumn(_cSheet1,_cTitulo,'REPRESENTANTE'     		,1,1,.F.)
	oExcel:AddColumn(_cSheet1,_cTitulo,'NOME_REPRESENTANTE'		,1,1,.F.)
	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
EndIf
//********************************************************************
// INICIO
// ARCOLOR - Inclusão da coluna com a quantidade de pedidos
// RODRIGO TELECIO EM 02/02/2022
//********************************************************************
if !Empty (MV_PAR11)
	oExcel:AddColumn(_cSheet1,_cTitulo,'PEDIDO'       		,1,1,.F.)
	oExcel:AddColumn(_cSheet1,_cTitulo,'TP_OPER'       		,1,1,.F.)
else
	oExcel:AddColumn(_cSheet1,_cTitulo,'QTD PEDIDOS'  		,2,2,.F.)
endif
// FIM
//********************************************************************
oExcel:AddColumn(_cSheet1,_cTitulo,'VENDIDO'    			,3,3,.T.)
// - PARAMETRO INCLUIDO PARA INFOMRAR OS USUÁRIOS AUTORIZADOS A VISUALIZAR AS COLUNAS ESPECÍFICAS.
If (_lValid)
	oExcel:AddColumn(_cSheet1,_cTitulo,'PENDENTE'   		,3,3,.T.)
	oExcel:AddColumn(_cSheet1,_cTitulo,'SALDO'      		,3,3,.T.)
	oExcel:AddColumn(_cSheet1,_cTitulo,'FATURADO'   		,3,3,.T.)
	oExcel:AddColumn(_cSheet1,_cTitulo,'CANCELADO'  		,3,3,.T.)
EndIf
// - SELECIONA A TABELA TEMPORÁRIA
dbSelectArea(_tAlias)
ProcRegua(((_tAlias)->(RecCount())*2)+1)
(_tAlias)->(dbGoTop())
// - ACRESCENTA AS LINHAS COM INFORMAÇÕES WHILE ! TEMP ->(EOF())
While !(_tAlias)->(EOF()) .AND. !lEnd
	If !Empty (MV_PAR11)
		IncProc('PROCESSANDO PEDIDO: '+AllTrim((_tAlias)->PEDIDO)+'.')
	Else

		// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
		//IncProc('PROCESSANDO VENDEDOR: '+AllTrim((_tAlias)->NOME_VENDEDOR)+'.')
		IncProc('PROCESSANDO REPRESENTANTE: '+AllTrim((_tAlias)->NOME_REPRESENTANTE)+'.')
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022
		
	EndIf
	_aAux := StrTokArr(_cCampos,',')
	For _nCtn2 := 1 To Len(_aAux)
	    _aAux[_nCtn2] := &(_aAux[_nCtn2])
	Next
	oExcel:AddRow(_cSheet1, _cTitulo, _aAux )
	(_tAlias)->(dbSkip())
EndDo
If lEnd
	Alert("Abortado!")
	FreeObj(oExcel)
	oExcel := NIL
	Return
EndIf
// - INCLUI UMA ABA COM AS INFORMAÇÕES DOS PARAMETROS
oExcel:AddWorkSheet(_cSheet2)
oExcel:AddTable(_cSheet2,_cTitulo2)
oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRIÇÃO" ,1,1,.F.)
oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTEÚDO"  ,1,1,.F.)

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))

_cPerg := PADR(_cPerg,10)
If (_cAliasSX1)->(dbSeek(_cPerg))
	While (_cAliasSX1)->(!EOF()) .And. (_cAliasSX1)->X1_GRUPO==_cPerg
		IncProc('PROCESSANDO PARÂMETROS.')
		AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
		dbSelectArea(_cAliasSX1)
		(_cAliasSX1)->(dbSkip())
	EndDo
EndIf
If Len(_aPar) > 0
	For _nPosPar := 1 To Len(_aPar)
		oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
	Next
EndIf
// - VALIDA A EMISSÃO DO RELATÓRIO E IMPRIME
If _lRet == .T.
IncProc("ABRINDO ARQUIVO...")
	oExcel:Activate()
	_cFile := (CriaTrab(NIL, .F.) + ".xml")
	While File(_cFile)
		_cFile := (CriaTrab(NIL, .F.) + ".xml")
	EndDo
	oExcel:GetXMLFile(_cFile)
	oExcel:DeActivate()
	If !(File(_cFile))
		_cFile := ""
		Break
	EndIf
	_cFileTMP := (GetTempPath() + _cFile)
	If !(__CopyFile(_cFile , _cFileTMP))
		fErase( _cFile )
		_cFile := ""
		Break
	EndIf
	fErase(_cFile)
	_cFile := _cFileTMP
	If !(File(_cFile))
		_cFile := ""
		Break
	EndIf
	oMsExcel:= MsExcel():New()
	oMsExcel:WorkBooks:Open(_cFile)
	oMsExcel:SetVisible(.T.)
	IncProc('RELATÓRIO GERADO COM SUCESSO.')
	MSGBOX('Relatório gerado, VERIFIQUE!!!',_cRotina+'_05','ALERT')
	oMsExcel:= oMsExcel:Destroy()
Else
	MSGBOX("Não há dados a serem apresentados. Informe o Administrador do sistema.",_cRotina+"_06",'ALERT')
EndIf

FreeObj(oExcel)
oExcel := NIL

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidPerg º Autor ³Júlio Soares         º Data ³  04/10/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsável pela inclusão de parâmetros na rotina.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para empresa ARCOLOR              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg()
Local _sAlias 	:= GetArea()
Local aRegs   	:= {}
local _x		:= 0
local _y		:= 0
_cPerg         	:= PADR(_cPerg,10)
AADD(aRegs,{_cPerg,"01","De Emissão?"           ,"","","mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{_cPerg,"02","Até Emissão?"          ,"","","mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{_cPerg,"03","Imprime Data emissão?" ,"","","mv_ch3","N",01,0,0,"C",""          ,"mv_par03","Não"           ,"","","","","Sim"      ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{_cPerg,"04","De Cliente?"           ,"","","mv_ch4","C",06,0,0,"G",""          ,"mv_par04",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA1","","","",""})
AADD(aRegs,{_cPerg,"05","De Loja?"              ,"","","mv_ch5","C",02,0,0,"G",""          ,"mv_par05",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{_cPerg,"06","Até Cliente?"          ,"","","mv_ch6","C",06,0,0,"G",""          ,"mv_par06",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA1","","","",""})
AADD(aRegs,{_cPerg,"07","Até Loja?"             ,"","","mv_ch7","C",02,0,0,"G",""          ,"mv_par07",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})

// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
//AADD(aRegs,{_cPerg,"08","De Vendedor?"          ,"","","mv_ch8","C",06,0,0,"G",""          ,"mv_par08",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA3","","","",""})
//AADD(aRegs,{_cPerg,"09","Até Vendedor?"         ,"","","mv_ch9","C",06,0,0,"G","NaoVazio()","mv_par09",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA3","","","",""})

AADD(aRegs,{_cPerg,"08","De Representante?"          ,"","","mv_ch8","C",06,0,0,"G",""          ,"mv_par08",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA3","","","",""})
AADD(aRegs,{_cPerg,"09","Até Representante?"         ,"","","mv_ch9","C",06,0,0,"G","NaoVazio()","mv_par09",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SA3","","","",""})
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

AADD(aRegs,{_cPerg,"10","De Pedido?"            ,"","","mv_cha","C",06,0,0,"G",""          ,"mv_par10",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SC5","","","",""})
AADD(aRegs,{_cPerg,"11","Até Pedido?"           ,"","","mv_chb","C",06,0,0,"G",""          ,"mv_par11",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","","SC5","","","",""})
AADD(aRegs,{_cPerg,"12","Tipo de pedidos?"      ,"","","mv_chc","N",01,0,0,"C",""          ,"mv_par12","Somente Vendas","","","","","Todos"    ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{_cPerg,"13","Qual Moeda?"           ,"","","mv_chd","C",01,0,1,"G","NaoVazio"  ,"mv_par13",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})
AADD(aRegs,{_cPerg,"14","Data para conversão?"  ,"","","mv_che","D",08,0,0,"G",""          ,"mv_par14",""              ,"","","","",""         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"","","",""})

For _x := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(MsSeek(_cPerg+aRegs[_x,2],.T.,.F.))
		RecLock("SX1",.T.)
		For _y := 1 To FCount()
			If _y <= Len(aRegs[_x])
				FieldPut(_y,aRegs[_x,_y])
			Else              
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_sAlias)

Return()
