#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

#DEFINE CENT CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT410INC  ºAutor  ³Júlio Soares       º Data ³  02/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este ponto de entrada pertence à rotina de pedidos de vendaº±±
±±º          ³ MATA410(). Está localizado na rotina de alteração do       º±±
±±º          ³ pedido, A410INCLUI(). É executado após a gravação das      º±±
±±º          ³ informações.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Ponto de entrada utilizado para que, ao final da inclusão  º±±
±±º          ³ do pedido de vendas, caso o tipo de divisão esteja         º±±
±±º          ³ divergente do cadastro do cliente, o risco do cliente é    º±±
±±º          ³ alterado automaticamente para 'E'. Dessa forma torna-se    º±±
±±º          ³ obrigatório a verificação do mesmo na rotina de análise de º±±
±±º          ³ crédito do pedido. É inserido também um texto no campo de  º±±
±±º          ³ observação.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa ARCOLOR.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT410INC()

Local _aSavArea := GetArea()
Local _aSavSA1  := SA1->(GetArea())
Local _aSavSC5  := SC5->(GetArea())
Local _aSavSE4  := SE4->(GetArea())
Local _cRotina  := 'MT410INC'
Local _cLogx	:= ""

_cPed           := SC5->C5_NUM
_cTpDivPed      := SC5->C5_TPDIV

If !AllTrim(SC5->C5_TIPO) $ "/D/B/"
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
		If AllTrim(SA1->A1_RISCO) <> "E"
			_cTpDivcli := SA1->A1_TPDIV
			If _cTpDivPed <> _cTpDivCli
				while !RecLock("SA1",.F.) ; enddo
					SA1->A1_RISCO := "E"
				SA1->(MsUnlock())
			EndIf
			If AllTrim(SA1->A1_RISCO) <> "E"
				dbSelectArea("SE4")
				SE4->(dbSetOrder(1)) // - E4_FILIAL+E4_CODIGO
				If SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG,.T.,.F.))
					If AllTrim(SE4->E4_PRIORI) == "1" .OR. AllTrim(SE4->E4_CTRADT) == "1" //.OR. Vinculos() //Se a condição de pagamento for prioritária ou adiantamento ou se o cliente possui algum título de crédito em aberto, bloqueia o pedido por crédito
						dbSelectArea("SA1")
						SA1->(dbSetOrder(1))
						while !RecLock("SA1",.F.) ; enddo
							SA1->A1_RISCO := "E"
						SA1->(MsUnlock())
					EndIf
				EndIf
			EndIf
			If AllTrim(SA1->A1_RISCO) <> "E" //.AND. AllTrim(SC5->C5_TPOPER)$("|"+AllTrim(SuperGetMv("MV_FATOPER",,"01|ZZ|9"))+"|")
				_cQry := " SELECT COUNT(*) REG " + CENT
				_cQry += " FROM " + RetSqlName("SC6") + " SC6 " + CENT
				_cQry += "      INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' " + CENT
				_cQry += "                AND SF4.F4_FILIAL  = '" + xFilial("SF4") + "' " + CENT
				_cQry += "                AND SF4.F4_DUPLIC <> 'S' " + CENT
				_cQry += "                AND SF4.F4_CODIGO  = SC6.C6_TES " + CENT
				_cQry += " WHERE SC6.D_E_L_E_T_ = '' " + CENT
				_cQry += "   AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "' " + CENT
				_cQry += "   AND SC6.C6_NUM     = '" + SC5->C5_NUM    + "' " + CENT
//				MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.TXT",_cQry)
				_cQry := ChangeQuery(_cQry)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SC6TMP",.T.,.F.)
				dbSelectArea("SC6TMP")
				If SC6TMP->REG > 0
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					while !RecLock("SA1",.F.) ; enddo
						SA1->A1_RISCO := "E"
					SA1->(MsUnlock())
				EndIf
				SC6TMP->(dbCloseArea())
			EndIf
		EndIf
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		If SC5->(MsSeek(xFilial("SC5")+ _cPed,.T.,.F.))
			If SC5->C5_TPDIV <> SA1->A1_TPDIV
				while !RecLock("SC5",.F.) ; enddo
					If Empty(SC5->(C5_OBS))
						SC5->C5_OBS := DTOC(Date()) + ' - ' + Time() + ' - Usuário: ' + __cUserId + CENT +;
						 "O TIPO DE DIVISÃO DO PEDIDO NÃO É COMPATÍVEL COM O TIPO DE DIVISÃO DO CLIENTE."
					Else
						SC5->C5_OBS := Alltrim(SC5->C5_OBS) + CENT + DTOC(Date()) + ' - ' + Time() + ' - Usuário: ' + __cUserId + CENT +;
						 "O TIPO DE DIVISÃO DO PEDIDO NÃO É COMPATÍVEL COM O TIPO DE DIVISÃO DO CLIENTE."
					EndIf
				SC5->(MsUnLock())
			EndIf
		EndIf
	Else
		MSGBOX('Cliente não encontrado, informe o administrador do sistema!',_cRotina+'_001','ALERT')
	EndIf
EndIf
/*
If ExistBlock
	StartJob("U_RFATA050",GetEnvServer(),.F.,,,,,.T.)
EndIf
*/
If INCLUI .AND. ExistBlock("RFATL001")
	_cLogx += "Pedido Incluído diretamente pela rotina de Pedidos de Venda."
	U_RFATL001(	SC5->C5_NUM  ,;
				,;
				_cLogx,;
				_cRotina    )
EndIf


RestArea(_aSavSA1)
RestArea(_aSavSC5)
RestArea(_aSavSE4)
RestArea(_aSavArea)

Return()