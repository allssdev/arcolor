#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SE5FI70E  ºAutor  ³Júlio Soares        º Data ³  19/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada após a atualização da tabela SE5 utilizadaº±±
±±º          ³ para gravar a última data encontrada, conforme parâmetros, º±±
±±º          ³ da movimentação bancária na data de emissão da comissão.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Inserido trecho para compor a data de baixa de acordo com aº±±
±±º          ³ última baixa realizada antes da data da exclusão da baixa. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SE5FI70E()

Local  _cRotina  := 'SE5FI70E'
Local  _nValor   := 0
Local  _aSavArea := GetArea()
Local  _aSavSE1  := SE1->(GetArea())
Local  _aSavSE3  := SE3->(GetArea())
Local  _aSavSE5  := SE5->(GetArea())                                           
Local  _cNum     := (xFilial("SE3")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
// - Alteração inserida em 20/01/2014 por Júlio Soares para que a comissão seja gerada com a data do crédito e não da baixa.
// - AGUARDANDO DEFINIÇÃO DE DATA DE CORTE
//Local   _cBaixa  := (ddtcredito) //SE1->E1_DTACRED
Private nValor   := SE1->E1_VALOR

// - Verificar se nesse momento o título de vendas tem vendedor.
_cQuery := " SELECT E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_SEQ,MAX(E5_DATA)[E5_DATA] "
_cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
_cQuery += " WHERE SE5.D_E_L_E_T_ = '' "
_cQuery += "   AND SE5.E5_FILIAL  = '" + xFilial("SE5")   + "' "
_cQuery += "   AND SE5.E5_CLIENTE = '" + SE1->E1_CLIENTE  + "' "
_cQuery += "   AND SE5.E5_LOJA    = '" + SE1->E1_LOJA     + "' "
_cQuery += "   AND SE5.E5_PREFIXO = '" + SE1->E1_PREFIXO  + "' "
_cQuery += "   AND SE5.E5_NUMERO  = '" + SE1->E1_NUM      + "' "
_cQuery += "   AND SE5.E5_PARCELA = '" + SE1->E1_PARCELA  + "' "
_cQuery += " GROUP BY E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_SEQ "
_cQuery += " HAVING COUNT(E5_RECPAG) = 1 "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"SE5TMP",.T.,.F.)
//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQuery)

If TCSQLExec(_cQuery) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_01")
Else
	dbSelectArea("SE5TMP")
	SE5TMP->(dbGoTop())
	dbSelectArea("SE3")
	SE3->(dbSetOrder(1))                       
	If SE3->(dbSeek(_cNum)) //xFilial("SE3"))+ SE3->E3_PREFIXO + SE3->E3_NUM //+ SE1->E1_PARCELA +SE3->E3_CODCLI+SE3->E3_LOJA
		While !SE3->(EOF()) .AND. (xFilial("SE3")+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA) == _cNum
			If Empty(SE3->E3_DATA)
				while !RecLock("SE3",.F.) ; enddo
					SE3->E3_EMISSAO := SToD(SE5TMP->E5_DATA)
				SE3->(MsUnlock())
			EndIf
			dbSelectArea("SE3")
			SE3->(dbSetOrder(1))
			SE3->(dbSkip())
		EndDo			
	Else
		MSGBOX("TITULO DE COMISSÃO N°- " + _cNum + " NÃO ENCONTRADO! Verifique se o mesmo já foi estornado completamente!",_cRotina+"_001","ALERT")
	EndIf
EndIf
dbSelectArea("SE5TMP")
SE5TMP->(dbCloseArea())

_cQuery := " SELECT TOP 1 E5_SEQ,MAX(E5_DATA)[E5_DATA] "
_cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
_cQuery += " WHERE SE5.D_E_L_E_T_ = '' "
_cQuery += "   AND SE5.E5_FILIAL  = '" + xFilial("SE5")   + "' "
_cQuery += "   AND SE5.E5_CLIENTE = '" + SE1->E1_CLIENTE  + "' "
_cQuery += "   AND SE5.E5_LOJA    = '" + SE1->E1_LOJA     + "' "
_cQuery += "   AND SE5.E5_PREFIXO = '" + SE1->E1_PREFIXO  + "' "
_cQuery += "   AND SE5.E5_NUMERO  = '" + SE1->E1_NUM      + "' "
_cQuery += "   AND SE5.E5_PARCELA = '" + SE1->E1_PARCELA  + "' " 
_cQuery += "   AND SE5.E5_SEQ    <> '" + SE5->E5_SEQ      + "' "
_cQuery += " GROUP BY E5_SEQ "
_cQuery += " HAVING COUNT(E5_RECPAG) = 1 "
_cQuery += " ORDER BY E5_SEQ DESC "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"SE5TMP",.T.,.F.)
//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.TXT",_cQuery)

If TCSQLExec(_cQuery) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_01")
Else
	dbSelectArea("SE5TMP")
	If !Empty(SE5TMP->(E5_DATA))
		_dDtBaixa := SE5TMP->(E5_DATA)
	Else
		_dDtBaixa := ""
	EndIf
	while !RecLock("SE1",.F.) ; enddo
		SE1->E1_BAIXA := STOD(_dDtBaixa)
	SE1->(MsUnlock())
	dbSelectArea("SE5TMP")
	SE5TMP->(dbCloseArea())
EndIf

RestArea(_aSavSE1)
RestArea(_aSavSE3)
RestArea(_aSavSE5)
RestArea(_aSavArea)

Return()