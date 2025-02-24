#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA070CA4 ºAutor  ³ Adriano Leonardo   º Data ³  10/01/2014 º±±
±±º          ³          ºAutor  ³ Júlio Soares       º Data ³  16/03/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na validação do cancelamento da baixa a   º±±
±±º          ³ receber, utilizado para gravar a data da baixa em campo    º±±
±±º          ³ auxiliar para que este seja utilizado no ponto de entrada  º±±
±±º          ³ FA070CAN.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Alterado para realizar a correção da atualização do conteúdo do campo º±±
±±º E1_BAIXA conforme movimentações realizadas.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FA070CA4()
// - PARAMIXB	
Local _nOpc := PARAMIXB
Local _aSavArea := GetArea()
Local _aSavSE1  := {}
Local _lRet		:= .T.
Local _cRotina  := 'FA070CA4'

//dbSelectArea("SE1")
//_aSavSE1 := SE1->(GetArea())
/*
while !RecLock("SE1",.F.) ; enddo
	SE1->E1_DTBXAUX := SE1->E1_BAIXA
SE1->(MsUnlock())
*/
// - Início alteração
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
		while !RecLock("SE1",.F.) ; enddo
			SE1->E1_BAIXA := STOD(_dDtBaixa)
		SE1->(MsUnlock())
	//Else
		//_dDtBaixa := ""
	EndIf
EndIf
dbSelectArea("SE5TMP")
SE5TMP->(dbCloseArea())
// - Fim alteração
//RestArea(_aSavSE1)
RestArea(_aSavArea)


Return(_lRet)