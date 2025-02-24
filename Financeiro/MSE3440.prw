#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MSE3440   ºAutor  ³Júlio Soares        º Data ³  18/07/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para alterar a data da comissão para a    º±±
±±º          ³ data da ultima movimentação realizada no título após a     º±±
±±º          ³ geração da comissão.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MSE3440()

Local _aSavArea := GetArea()
Local _aSavSE1  := SE1->(GetArea())
Local _aSavSE3  := SE3->(GetArea())
Local _aSavSE5  := SE5->(GetArea())
Local _cRotina  := "MSE3440"
Local _cNum     := (xFilial("SE3")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
Local _cBaixa   := SE1->E1_BAIXA

// - Alteração inserida em 20/01/2014 por Júlio Soares para que a comissão seja gerada com a data do crédito e não da baixa.
// - AGUARDANDO DEFINIÇÃO DE DATA DE CORTE
//Local   _cBaixa   := (ddtcredito) //SE1->E1_DTACRED

If Upper(AllTrim(FunName()))=="FINA740" .OR. Upper(AllTrim(FunName()))=="FINA070" .OR. Upper(AllTrim(FunName()))=="FINA440" .OR. Upper(AllTrim(FunName()))=="RFINA440"
	//MSGBOX("MSE3440",_cRotina+"_01","ALERT")
	_cQry := " UPDATE " + RetSqlName("SE3")
	_cQry += " SET E3_EMISSAO   = '" + DTOS(_cBaixa) + "' "
	_cQry += " WHERE D_E_L_E_T_ = '' "
	_cQry += "   AND E3_FILIAL  = '" + xFilial("SE3")  + "' "
	_cQry += "   AND E3_PREFIXO = '" + SE1->E1_PREFIXO + "' "
	_cQry += "   AND E3_NUM     = '" + SE1->E1_NUM     + "' "
	_cQry += "   AND E3_PARCELA = '" + SE1->E1_PARCELA + "' "
	_cQry += "   AND E3_TIPO    = '" + SE1->E1_TIPO    + "' "
	//If __cUserId == "000000"
//		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
	//EndIf
	If TCSQLExec(_cQry) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_016")
	Else
		dbSelectArea("SE3")
		TcRefresh("SE3")
		SE3->(dbSetOrder(1))
		If SE3->(dbSeek(_cNum)) //xFilial("SE3"))+ SE3->E3_PREFIXO + SE3->E3_NUM //+ SE1->E1_PARCELA
			While !SE3->(EOF()) .AND. (xFilial("SE3")+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA) == _cNum
				If Empty(SE3->E3_DATA)
					while !RecLock("SE3",.F.) ; enddo
						SE3->E3_EMISSAO := _cBaixa
					dbSelectArea("SE3")
					SE3->(MSUNLOCK())
				EndIf
				dbSelectArea("SE3")
				SE3->(dbSetOrder(1))
				SE3->(dbSkip())
			EndDo
		Else
			If AllTrim(SE1->E1_TIPO) <> 'NCC' // Condição incluida em 09/12/2013 por Júlio Soares após a apresentação do Alert nos recálculos de comissão.
				MSGBOX("TITULO DE COMISSÃO - " + _cNum + " - NÃO ENCONTRADO!",_cRotina+"_002","ALERT")
			EndIf
		EndIf
	EndIf
EndIf

RestArea(_aSavSE1)
RestArea(_aSavSE3)
RestArea(_aSavSE5)
RestArea(_aSavArea)

Return()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Possívelmente, após prévia análise nas baixas de títulos, foi observado que talvez somente este fonte fosse necessário para realizar as alterações.³
//³Pocesso em análise.                                                                                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ