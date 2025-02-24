#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MVIEWSALDOºAutor  ³Adriano L. de Souza º Data ³  17/01/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Ponto de entrada que permite manipular as informações apresen_º±±
±±ºDesc.   ³ tadas na tela de consulta de estoques, acessada via F4 no ca_ º±±
±±ºDesc.   ³ dastro de produtos.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11  ³ Uso específico Arcolor                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MVIEWSALDO()

Local _aSavArea := GetArea()
Local _cProd    := PARAMIXB[1]
Local _cLocal   := PARAMIXB[2]
Local _aSaldo   := PARAMIXB[3]
Local _cAlias	:= "TMPSB2"
//Local _aRet     := {}

/*
_cQry := " SELECT SUM(C1_QUANT-C1_QUJE) AS [QTD_SOL] "
_cQry += " FROM " + RetSqlName("SC1") + " SC1 (NOLOCK)"
_cQry += " WHERE SC1.D_E_L_E_T_ = '' "
_cQry += "   AND SC1.C1_FILIAL  = '" + xFilial("SC1") + "' "
_cQry += "   AND SC1.C1_PRODUTO = '" + _cProd         + "' "
*/

_cQry := " SELECT C7_LOCAL, SUM(C7_QUANT-C7_QUJE) AS [QTD_SOL] "
_cQry += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK)"
_cQry += " WHERE SC7.D_E_L_E_T_ = '' "
_cQry += "   AND SC7.C7_FILIAL  = '" + xFilial("SC7") + "' "
_cQry += "   AND SC7.C7_PRODUTO = '" + _cProd         + "' "
_cQry += "   AND SC7.C7_LOCAL = '" + _cLocal        + "' "
_cQry += "   AND (CASE WHEN SC7.C7_RESIDUO = 'S' THEN 1 ELSE 0 END) = 0 "
_cQry += " GROUP BY C7_LOCAL
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.F.)
dbSelectArea(_cAlias)
_nQtdSol := (_cAlias)->QTD_SOL //Quantidade em solicitação de compras	
If Len(_aSaldo) > 0 .and.  Alltrim((_cAlias)->C7_LOCAL) == Alltrim(_cLocal)
	_aSaldo[1,5] := _nQtdSol
EndIf
dbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())

_cQry := " SELECT D4_LOCAL, SUM(D4_QUANT) AS [QTD_EMP] "
_cQry += " FROM " + RetSqlName("SD4") + " SD4 (NOLOCK)"
_cQry += " WHERE SD4.D_E_L_E_T_ = '' "
_cQry += "   AND SD4.D4_FILIAL  = '" + xFilial("SD4") + "' "
_cQry += "   AND SD4.D4_COD = '" + _cProd         + "' "
_cQry += "   AND SD4.D4_LOCAL = '" + _cLocal        + "' "
_cQry += "   AND SD4.D4_QUANT > 0 "
_cQry += "   AND (CASE WHEN SUBSTRING(SD4.D4_OP,1,1) = 'Z' THEN 1 ELSE 0 END) = 0 "
_cQry += " GROUP BY D4_LOCAL
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.F.)
dbSelectArea(_cAlias)
_nQtdEmp := (_cAlias)->QTD_EMP //Quantidade em empenho
If _nQtdEmp > 0 .and.  Alltrim((_cAlias)->D4_LOCAL) == Alltrim(_cLocal)
	_aSaldo[1,4] := _nQtdEmp
EndIf
dbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())


_cQry := " SELECT C2_LOCAL, SUM(C2_QUANT-C2_QUJE-C2_PERDA) AS [QTD_ENT] "
_cQry += " FROM " + RetSqlName("SC2") + " SC2 (NOLOCK)"
_cQry += " WHERE SC2.D_E_L_E_T_ = '' "
_cQry += "   AND SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
_cQry += "   AND SC2.C2_PRODUTO = '" + _cProd         + "' "
_cQry += "   AND SC2.C2_LOCAL = '" + _cLocal        + "' "
_cQry += "   AND (C2_QUANT-C2_QUJE-C2_PERDA) > 0 "
_cQry += "   AND C2_DATRF = '' "
_cQry += "   AND (CASE WHEN SUBSTRING(SC2.C2_NUM,1,1) = 'Z' THEN 1 ELSE 0 END) = 0 "
_cQry += " GROUP BY C2_LOCAL
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.F.)
dbSelectArea(_cAlias)
_nQtdEnt := (_cAlias)->QTD_ENT //Quantidade em empenho
If _nQtdEnt > 0 .and.  Alltrim((_cAlias)->C2_LOCAL) == Alltrim(_cLocal) .and. (_cAlias)->(!EOF()) 
	_aSaldo[1,5] := _nQtdEnt
EndIf
dbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())
RestArea(_aSavArea)
	
Return(_aSaldo)
