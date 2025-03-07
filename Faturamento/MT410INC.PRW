#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

#DEFINE CENT CHR(13) + CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT410INC  �Autor  �J�lio Soares       � Data �  02/07/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Este ponto de entrada pertence � rotina de pedidos de venda���
���          � MATA410(). Est� localizado na rotina de altera��o do       ���
���          � pedido, A410INCLUI(). � executado ap�s a grava��o das      ���
���          � informa��es.                                               ���
�������������������������������������������������������������������������͹��
���          � Ponto de entrada utilizado para que, ao final da inclus�o  ���
���          � do pedido de vendas, caso o tipo de divis�o esteja         ���
���          � divergente do cadastro do cliente, o risco do cliente �    ���
���          � alterado automaticamente para 'E'. Dessa forma torna-se    ���
���          � obrigat�rio a verifica��o do mesmo na rotina de an�lise de ���
���          � cr�dito do pedido. � inserido tamb�m um texto no campo de  ���
���          � observa��o.                                                ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa ARCOLOR.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
					If AllTrim(SE4->E4_PRIORI) == "1" .OR. AllTrim(SE4->E4_CTRADT) == "1" //.OR. Vinculos() //Se a condi��o de pagamento for priorit�ria ou adiantamento ou se o cliente possui algum t�tulo de cr�dito em aberto, bloqueia o pedido por cr�dito
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
						SC5->C5_OBS := DTOC(Date()) + ' - ' + Time() + ' - Usu�rio: ' + __cUserId + CENT +;
						 "O TIPO DE DIVIS�O DO PEDIDO N�O � COMPAT�VEL COM O TIPO DE DIVIS�O DO CLIENTE."
					Else
						SC5->C5_OBS := Alltrim(SC5->C5_OBS) + CENT + DTOC(Date()) + ' - ' + Time() + ' - Usu�rio: ' + __cUserId + CENT +;
						 "O TIPO DE DIVIS�O DO PEDIDO N�O � COMPAT�VEL COM O TIPO DE DIVIS�O DO CLIENTE."
					EndIf
				SC5->(MsUnLock())
			EndIf
		EndIf
	Else
		MSGBOX('Cliente n�o encontrado, informe o administrador do sistema!',_cRotina+'_001','ALERT')
	EndIf
EndIf
/*
If ExistBlock
	StartJob("U_RFATA050",GetEnvServer(),.F.,,,,,.T.)
EndIf
*/
If INCLUI .AND. ExistBlock("RFATL001")
	_cLogx += "Pedido Inclu�do diretamente pela rotina de Pedidos de Venda."
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