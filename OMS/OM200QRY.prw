#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#define _lEnt  CHR(13) + CHR(10)
/*/{Protheus.doc} OM200QRY
Filtro dos Pedidos na Montagem da Carga.
Ponto de entrada depois das condições principais de filtro dos pedidos na montagem de carga utilizando Top Connect.
Este ponto é utilizado para remontar a query para a apresentação dos pedidos de vendas na tela de montagem de carga.
@author Anderson C. P. Coelho
@since 17/10/2013
@version P11
@type Function
@obs Conteúdo do PARAMIXBTRBSC9
				ParamIXB[1] - Expressão da query a ser executada no banco.
				ParamIXB[2] - Matriz contendo os Tipos de Cargas selecionados pelo usuário.Onde:
						Item 1 - lógico, indicado se está selecionado (.T.)
						Item 2 - caracter, código do tipo da carga.
						Item 3 - caracter, descrição do tipo da carga.
@see https://allss.com.br
@history 05/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revisão de código-fonte em função da migração de release P12.1.33 com a adição dos campos C5_CLIENTE e C5_LOJACLI.
/*/
user function OM200QRY()
Local _aSavArea := GetArea()
Local _cRotina  := "OM200QRY"
Local lLocalEnt := SC5->(FieldPos("C5_CLIENT"))  > 0
Local lFreteEmb := AliasIndic("DAS")
Local lTransp   := SuperGetMv("MV_CGTRANS",.F.,.F.)
Local nTipoOper := OsVlEntCom()
Local _cQuery   := PARAMIXB[1]
Public _aNFCar  := {}
Pergunte("OMS200",.F.)
//_cQuery := " SELECT SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_REDESP,C9_FILIAL,C9_PRODUTO,C9_CLIENTE,C9_LOJA,C9_QTDLIB,C9_PRCVEN," +_lEnt
_cQuery := "SELECT																						" + _lEnt
_cQuery += "	SC5.C5_FILIAL,																			" + _lEnt
_cQuery += "	SC5.C5_NUM,																				" + _lEnt
_cQuery += "	SC5.C5_REDESP,																			" + _lEnt
_cQuery += "	SC5.C5_CLIENTE,																			" + _lEnt
_cQuery += "	SC5.C5_LOJACLI,																			" + _lEnt
_cQuery += "	SC9.C9_FILIAL,																			" + _lEnt
_cQuery += "	SC9.C9_PRODUTO,																			" + _lEnt
_cQuery += "	SC9.C9_CLIENTE,																			" + _lEnt
_cQuery += "	SC9.C9_LOJA,																			" + _lEnt
_cQuery += "	SC9.C9_QTDLIB,																			" + _lEnt
_cQuery += "	SC9.C9_PRCVEN,																			" + _lEnt
_cQuery += "	SC9.C9_PEDIDO,																			" + _lEnt
_cQuery += "	SC9.C9_ITEM,																			" + _lEnt
_cQuery += "	SC9.C9_SEQUEN,																			" + _lEnt
_cQuery += "	SC9.C9_ENDPAD,																			" + _lEnt
_cQuery += "	SC9.R_E_C_N_O_ RECNOSC9,																" + _lEnt
_cQuery += "	SB1.B1_TIPCAR, 																			" + _lEnt
_cQuery += "	SB1.B1_PESBRU,																			" + _lEnt
_cQuery += "	SB1.R_E_C_N_O_ RECSB1,																	" + _lEnt
_cQuery += " 	0 AS B5_CAPARM,																			" + _lEnt
_cQuery += " 	SC5.C5_LOJAENT,																			" + _lEnt
_cQuery += "	SC5.C5_TIPO,																			" + _lEnt
_cQuery += "	SC5.R_E_C_N_O_ RECNOSC5 																" + _lEnt
if lLocalEnt
	_cQuery += " 	, SC5.C5_CLIENT 																	" + _lEnt
endif
if	lFreteEmb
	_cQuery += "	, SC5.C5_TPFRETE 																	" + _lEnt
endif
if SC9->(FieldPos("C9_MARKNF"))<>0
	_cQuery += " 	, SC9.C9_MARKNF 																	" + _lEnt
endif
_cQuery += "FROM "
_cQuery +=		RetSqlName('SC9') + " SC9 (NOLOCK) 														" + _lEnt
_cQuery += " 	INNER JOIN 																				" + _lEnt
_cQuery +=			RetSqlName('SC5') + " SC5 (NOLOCK) 													" + _lEnt
_cQuery += "	ON 																						" + _lEnt
_cQuery += "		SC5.D_E_L_E_T_ = '' 																" + _lEnt
if !lTransp
	_cQuery += " 		AND SC5.C5_TRANSP = '" + Space(Len(SC5->C5_TRANSP)) + "'						" + _lEnt
endif
if cPaisLoc <> "BRA"
	_cQuery += " 		AND SC5.C5_DOCGER <> '3' 														" + _lEnt
endIf
_cQuery += " 		AND SC5.C5_FILIAL  = SC9.C9_FILIAL  												" + _lEnt
_cQuery += " 		AND SC5.C5_NUM     = SC9.C9_PEDIDO  												" + _lEnt
_cQuery += " 	INNER JOIN 																				" + _lEnt	
_cQuery +=			RetSqlName('SC6') + " SC6 (NOLOCK)													" + _lEnt
_cQuery += "	ON																						" + _lEnt
_cQuery += "		SC6.D_E_L_E_T_ = '' 																" + _lEnt
//_cQuery += " 		AND SC6.C6_ENTREG  BETWEEN '" + Dtos(mv_par15) + "' AND '" + Dtos(mv_par16) + "' " +_lEnt
_cQuery += " 		AND SC6.C6_FILIAL  = SC9.C9_FILIAL  												" + _lEnt
_cQuery += " 		AND SC6.C6_NUM     = SC9.C9_PEDIDO 	 												" + _lEnt
_cQuery += " 		AND SC6.C6_ITEM    = SC9.C9_ITEM    												" + _lEnt
_cQuery += " 		AND SC6.C6_PRODUTO = SC9.C9_PRODUTO 												" + _lEnt
_cQuery += " 	INNER JOIN 																				" + _lEnt
_cQuery += 			RetSqlName('SB1') + " SB1 (NOLOCK)													" + _lEnt
_cQuery += "	ON																						" + _lEnt
_cQuery += "		SB1.D_E_L_E_T_ = '' 																" + _lEnt
if nTipoOper == 1
	_cQuery += " 		AND SB1.B1_FILIAL = '" + FwFilial("SB1") + "' 									" + _lEnt
else
	_cQuery += " 		AND SB1.B1_FILIAL =  " + OsFilQry("SB1","SC9.C9_FILIAL") 						  + _lEnt
endif
_cQuery += " 		AND SB1.B1_COD = SC9.C9_PRODUTO 													" + _lEnt
_cQuery += "WHERE
_cQuery += "	SC9.D_E_L_E_T_ = '' 																	" + _lEnt
if nTipoOper == 1
	_cQuery += " 	AND SC9.C9_FILIAL = '" + FwFilial("SC9")       + "' 								" + _lEnt
else
	_cQuery += " 	AND SC9.C9_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' 				" + _lEnt
endif
_cQuery += " 	AND SC9.C9_CARGA = '" 	+ Space(Len(SC9->C9_CARGA )) + "' 								" + _lEnt
_cQuery += " 	AND SC9.C9_SEQCAR = '" 	+ Space(Len(SC9->C9_SEQCAR)) + "' 								" + _lEnt
_cQuery += " 	AND SC9.C9_PEDIDO      BETWEEN '" + mv_par01       + "' AND '" + mv_par02       + "' 	" + _lEnt
_cQuery += " 	AND SC9.C9_CLIENTE     BETWEEN '" + mv_par03       + "' AND '" + mv_par04       + "' 	" + _lEnt
_cQuery += " 	AND SC9.C9_LOJA        BETWEEN '" + mv_par13       + "' AND '" + mv_par14       + "' 	" + _lEnt
_cQuery += " 	AND SC9.C9_ENDPAD      BETWEEN '" + mv_par07       + "' AND '" + mv_par08       + "' 	" + _lEnt
_cQuery += " 	AND SC9.C9_DATALIB     BETWEEN '" + iif(DtoS(mv_par11)> '20181201', DtoS(mv_par11), '20181201') + "' AND '" + DtoS(mv_par12) + "' 	" + _lEnt
if SC9->(FieldPos("C9_DTEMISS")) <> 0 // valida se o campo existe no banco.
	_cQuery += " 	AND SC9.C9_DTEMISS BETWEEN '" + iif(DtoS(mv_par23)> '20181201', DtoS(mv_par23), '20181201') + "' AND '" + DtoS(mv_par24) + "' 	" + _lEnt
endif
_cQuery += " 	AND SC9.C9_BLEST = '10' 																" + _lEnt
_cQuery += "	AND (SC9.C9_TPCARGA = '1' OR SC9.C9_TPCARGA = '3') 										" + _lEnt
If SC9->(FieldPos("C9_MARKNF")) <> 0
	_cQuery += " 	AND SC9.C9_MARKNF = '' 																" + _lEnt
endif
if cPaisLoc <> "BRA"
	_cQuery += " 	AND SC9.C9_REMITO = '" + Space(Len(SC9->C9_REMITO)) + "' 							" + _lEnt
endif
MemoWrite("\2.MemoWrite\OMS\"+_cRotina+"_QRY_001.TXT",_cQuery)
RestArea(_aSavArea)
return _cQuery
