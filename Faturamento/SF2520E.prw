#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _lEnt CHR(13) + CHR(10)
/*/{Protheus.doc} SF2520E
//TODO Este Ponto de Entrada, localizado no TMSXFUNA (Funções utilizadas pelo TMS), executa procedimentos antes do estorno do documento de saída, na rotina de cálculo do frete.
@description Ponto de Entrada executado apos a validacao da exclusao do documento de saida (while na SF2), porem antes da exclusao, utilizado para, quando o corte (controle CD) for no valor, estornar a quantidade ja entregue (C6_QTDENT) da parcela nao migravel, para evitar duplicidade de informacao (CD Control).
@obs Estorno do tratamento dado na rotina RFATA002.
@author Anderson C. P. Coelho
@since 23/02/2013
@history 11/12/2013, Adriano Leonardo, Ajustes
@history 24/03/2014, Júlio Soares, Ajustes
@history 08/06/2016, Júlio Soares, Ajustes
@version 1.0
@type function
@see https://allss.com.br
@history 27/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revisão para adequação de chamadas de tabela em querys sem NOLOCK.
/*/
user function SF2520E()
	local   _aSavArea   := GetArea()
	local   _aSvSUA     := SUA->(GetArea())
	local   _aSvSD2     := SD2->(GetArea())
	local   _aSvSF2     := SF2->(GetArea())
	local   _cRotina    := "SF2520E"
	local   _cAliasSX1  := "SX1"		//"SX1_"+GetNextAlias()
	local   _cLogx      := ""
	local   _aPedido    := {}

	private lCarteira   := MV_PAR04==1 //1=Os pedidos voltam a ficar em carteira (aberto); 2=Os pedidos voltam liberados
	private _cLog       := ""
	private _lRFATL001  := ExistBlock("RFATL001")

	if AllTrim(SF2->F2_TIPO) == "N"
		if !lCarteira
			_cMsg := ">>> ATENÇÃO!!! <<< "
			_cMsg += " Não é permitido estornar o pedido diretamente para 'Apto a faturar'. "
			_cMsg += " O mesmo deve voltar para a opção 'Carteira' por questões de integridade do processo"
			_cMsg += " Por gentileza, informe imediatamente o administrador do sistema "
			Msgbox(_cMsg,_cRotina+"_002","ALERT")
			MV_PAR04   := 1
			lCarteira  := MV_PAR04==1
			if Select(_cAliasSX1) > 0
				(_cAliasSX1)->(dbCloseArea())
			endif
			OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
			dbSelectArea(_cAliasSX1)
			(_cAliasSX1)->(dbSetOrder(1))
			if (_cAliasSX1)->(MsSeek("MTA521    04",.T.,.F.))
				while !RecLock(_cAliasSX1,.F.) ; enddo
					(_cAliasSX1)->X1_PRESEL := 1
				(_cAliasSX1)->(MSUNLOCK())
			endif
			if Select(_cAliasSX1) > 0
				(_cAliasSX1)->(dbCloseArea())
			endif
			if ExistBlock("RCFGASX1")
				U_RCFGASX1("MTA521    ","04", 1)
			endif
		endif
		
		/*
		_cQry   := " UPDATE SB2 " + _lEnt
		_cQry   += " SET B2_QPEDVEN = SB2.B2_QPEDVEN - SD2.D2_QUANT " + _lEnt
		_cQry   += " FROM " + RetSqlName("SB2") + " SB2 " + _lEnt
		_cQry   += "      INNER JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D_E_L_E_T_ = '' " + _lEnt
		_cQry   += "                                             AND  SD2.D2_FILIAL  = '" + xFilial("SD2")  + "' " + _lEnt
		_cQry   += "                                             AND  SD2.D2_TIPO    = 'N' " + _lEnt
		_cQry   += "                                             AND  SD2.D2_DOC     = '" + SF2->F2_DOC     + "' " + _lEnt
		_cQry   += "                                             AND  SD2.D2_SERIE   = '" + SF2->F2_SERIE   + "' " + _lEnt
		_cQry   += "                                             AND  SD2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "' " + _lEnt
		_cQry   += "                                             AND  SD2.D2_LOJA    = '" + SF2->F2_LOJA    + "' " + _lEnt
		_cQry   += "                                             AND  SD2.D2_COD     = SB2.B2_COD "   + _lEnt
		_cQry   += "                                             AND  SD2.D2_LOCAL   = SB2.B2_LOCAL " + _lEnt
		_cQry   += "      INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = '' " + _lEnt
		_cQry   += "                                             AND  SB1.B1_FILIAL  = '" + xFilial("SB1") + "' " + _lEnt
		_cQry   += "                                             AND  SB1.B1_COD     = SD2.D2_COD     " + _lEnt
		_cQry   += "      INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' " + _lEnt
		_cQry   += "                                             AND  SA1.A1_FILIAL  = '" + xFilial("SA1") + "' " + _lEnt
		_cQry   += "                                             AND  SA1.A1_COD     = SD2.D2_CLIENTE " + _lEnt
		_cQry   += "                                             AND  SA1.A1_LOJA    = SD2.D2_LOJA    " + _lEnt
		_cQry   += "      INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = '' " + _lEnt
		_cQry   += "                                             AND  SC6.C6_FILIAL  = '" + xFilial("SC6") + "' " + _lEnt
		_cQry   += "                                             AND (SC6.C6_TPCALC  = 'V' OR (SC6.C6_TPCALC = '' AND SB1.B1_TPCALC = 'V')) " + _lEnt
		_cQry   += "                                             AND  SC6.C6_NUM     = SD2.D2_PEDIDO  " + _lEnt
		_cQry   += "                                             AND  SC6.C6_ITEM    = SD2.D2_ITEMPV  " + _lEnt
		_cQry   += "                                             AND  SC6.C6_PRODUTO = SD2.D2_COD     " + _lEnt
		_cQry   += "      INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.D_E_L_E_T_ = '' " + _lEnt
		_cQry   += "                                             AND  SC5.C5_FILIAL  = '" + xFilial("SC5") + "' " + _lEnt
		_cQry   += "                                             AND  SC5.C5_TIPO    = 'N'  " + _lEnt
		_cQry   += "                                             AND ((SC5.C5_TPDIV <> '0' AND SC5.C5_TPDIV <> '4' AND SC5.C5_TPDIV <> '5') OR (SC5.C5_TPDIV = '' AND SA1.A1_TPDIV <> '0' AND SA1.A1_TPDIV <> '4' AND SA1.A1_TPDIV <> '5'))" + _lEnt
		_cQry   += "                                             AND  SC5.C5_NUM     = SC6.C6_NUM     " + _lEnt
		_cQry   += "      INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' " + _lEnt
		_cQry   += "                                             AND  SF4.F4_FILIAL  = '" + xFilial("SF4") + "' " + _lEnt
		_cQry   += "                                             AND  SF4.F4_MIGRA   = 'N' " + _lEnt
		_cQry   += "                                             AND  SF4.F4_ESTOQUE = 'N' " + _lEnt
		_cQry   += "                                             AND  SF4.F4_CODIGO  = SD2.D2_TES     " + _lEnt
		_cQry   += " WHERE  SB2.D_E_L_E_T_ = '' " + _lEnt
		_cQry   += "   AND  SB2.B2_FILIAL  = '" + xFilial("SB2") + "' " + _lEnt
		//if __cUserId == "000000"
		//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
		//endif
		if TCSQLExec(_cQry) < 0
			TCSQLError()
			_cMsg := "      ATENÇÃO      " + _lEnt
			_cMsg += " Foram encontrados problemas na quantidade já entregue para o pedido referente ao documento "+AllTrim(SF2->F2_DOC)+"/"+AllTrim(SF2->F2_SERIE)+"." + _lEnt
			_cMsg += " Por gentileza, informe imediatamente o administrador do sistema "+ _lEnt
			MsgBox(_cMsg,_cRotina+"_001","STOP")
		endif
		dbSelectArea("SB2")
		_aSvB2Upd := SB2->(GetArea())
		TcRefresh("SB2")
		RestArea(_aSvB2Upd)

		_cQry := " UPDATE " + RetSqlName("SC6") + _lEnt
		_cQry += " SET  C6_QTDEMP  = ISNULL(	(SELECT SUM(CASE WHEN C9_BLEST = '10' THEN 0 else C9_QTDLIB  END)" + _lEnt
		_cQry += " 								 FROM " + RetSqlName("SC9") + " SC9X " + _lEnt
		_cQry += " 								 WHERE SC9X.D_E_L_E_T_ = '' " + _lEnt
		_cQry += " 								   AND SC9X.C9_FILIAL  = '" + xFilial("SC9") + "' " + _lEnt
		_cQry += " 								   AND SC9X.C9_PEDIDO  = C6_NUM " + _lEnt
		_cQry += " 								   AND SC9X.C9_ITEM    = C6_ITEM " + _lEnt
		_cQry += " 								   AND SC9X.C9_PRODUTO = C6_PRODUTO " + _lEnt
		_cQry += " 								 GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO " + _lEnt
		_cQry += " 								),0) " + _lEnt
		_cQry += " 		 ,C6_QTDEMP2 = ISNULL(	(SELECT SUM(CASE WHEN C9_BLEST = '10' THEN 0 else C9_QTDLIB2 END)"+ _lEnt
		_cQry += " 								 FROM " + RetSqlName("SC9") + " SC9X " + _lEnt
		_cQry += " 								 WHERE SC9X.D_E_L_E_T_ = ''  " + _lEnt
		_cQry += " 								   AND SC9X.C9_FILIAL  = '" + xFilial("SC9") + "' " + _lEnt
		_cQry += " 								   AND SC9X.C9_PEDIDO  = C6_NUM  " + _lEnt
		_cQry += " 								   AND SC9X.C9_ITEM    = C6_ITEM  " + _lEnt
		_cQry += " 								   AND SC9X.C9_PRODUTO = C6_PRODUTO  " + _lEnt
		_cQry += " 								 GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO  " + _lEnt
		_cQry += " 								),0) " + _lEnt
		_cQry += " 		 ,C6_QTDENT  = ISNULL((SELECT CASE WHEN COUNT(D2_PEDIDO)>1 AND C6_TPCALC = 'V' AND C5_TPDIV <> '5' " + _lEnt
		_cQry += "     										   THEN SUM(D2_QUANT)/2  " + _lEnt
		_cQry += "     										   else SUM(D2_QUANT)  " + _lEnt
		_cQry += "     								  END  " + _lEnt
		_cQry += "     						   FROM " + RetSqlName("SD2") + " SD2 " + _lEnt
		_cQry += "     						   WHERE SD2.D_E_L_E_T_= ''  " + _lEnt
		_cQry += "     							 AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' " + _lEnt
		_cQry += "     							 AND SD2.D2_PEDIDO = C6_NUM   " + _lEnt
		_cQry += "     							 AND SD2.D2_ITEMPV = C6_ITEM  " + _lEnt
		_cQry += "     							 AND SD2.D2_COD    = C6_PRODUTO " + _lEnt
		_cQry += "     						   GROUP BY D2_PEDIDO, D2_ITEMPV, D2_COD " + _lEnt
		_cQry += "     						  ),0)  " + _lEnt
		_cQry += " 		 ,C6_QTDENT2 = ISNULL((SELECT CASE WHEN COUNT(D2_PEDIDO)>1 AND C6_TPCALC = 'V' AND C5_TPDIV <> '5' " + _lEnt
		_cQry += "     										   THEN SUM(D2_QTSEGUM)/2  " + _lEnt
		_cQry += "     										   else SUM(D2_QTSEGUM)    " + _lEnt
		_cQry += "     								  END  " + _lEnt
		_cQry += "     						   FROM " + RetSqlName("SD2") + " SD2 " + _lEnt
		_cQry += "     						   WHERE SD2.D_E_L_E_T_= ''  " + _lEnt
		_cQry += "     							 AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' " + _lEnt
		_cQry += "     							 AND SD2.D2_PEDIDO = C6_NUM   " + _lEnt
		_cQry += "     							 AND SD2.D2_ITEMPV = C6_ITEM  " + _lEnt
		_cQry += "     							 AND SD2.D2_COD    = C6_PRODUTO " + _lEnt
		_cQry += "     							 AND SD2.D2_CLIENTE= C6_CLI   " + _lEnt
		_cQry += "     							 AND SD2.D2_LOJA   = C6_LOJA  " + _lEnt
		_cQry += "     						   GROUP BY D2_PEDIDO, D2_ITEMPV, D2_COD " + _lEnt
		_cQry += "     						  ),0)  " + _lEnt
		_cQry += " 	 FROM " + RetSqlName("SC6") + " SC6 " + _lEnt
		_cQry += " 	 INNER JOIN " + RetSqlName("SD2") + " SD2X ON SD2X.D_E_L_E_T_ = '' " + _lEnt
		_cQry += " 						 AND SD2X.D2_FILIAL   = '" + xFilial("SD2")  + "' " + _lEnt
		_cQry += " 						 AND SD2X.D2_DOC      = '" + SF2->F2_DOC     + "' " + _lEnt
		_cQry += " 						 AND SD2X.D2_SERIE    = '" + SF2->F2_SERIE   + "' " + _lEnt
		_cQry += " 						 AND SD2X.D2_CLIENTE  = '" + SF2->F2_CLIENTE + "' " + _lEnt
		_cQry += " 						 AND SD2X.D2_LOJA     = '" + SF2->F2_LOJA    + "' " + _lEnt
		_cQry += "     					 AND SD2X.D2_PEDIDO   = SC6.C6_NUM   " + _lEnt
		_cQry += "     					 AND SD2X.D2_ITEMPV   = SC6.C6_ITEM  " + _lEnt
		_cQry += "     					 AND SD2X.D2_COD      = SC6.C6_PRODUTO " + _lEnt
		_cQry += " 	 INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.D_E_L_E_T_ = '' " + _lEnt
		_cQry += " 						 AND SC5.C5_FILIAL   = '" + xFilial("SC5") + "' " + _lEnt
		_cQry += " 						 AND SC5.C5_NUM      = SC6.C6_NUM  " + _lEnt
		_cQry += " 	 WHERE SC6.D_E_L_E_T_ = ''  " + _lEnt
		_cQry += "     AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "' " + _lEnt
		if TCSQLExec(_cQry) < 0
			TCSQLError()
			_cMsg := "      ATENÇÃO      " + _lEnt
			_cMsg += " Foram encontrados problemas no ajuste das quantidades do pedido referente ao documento "+AllTrim(SF2->F2_DOC)+"/"+AllTrim(SF2->F2_SERIE)+"." + _lEnt
			_cMsg += " Por gentileza, informe imediatamente o administrador do sistema."
			MsgBox(_cMsg,_cRotina+"_003","STOP")
		endif
		dbSelectArea("SC6")
		_aSvC6Upd := SC6->(GetArea())
		TcRefresh("SC6")
		RestArea(_aSvC6Upd)*/
	endif
	if !AllTrim(SF2->F2_TIPO)$"D/B"
		dbSelectArea("SD2")
		SD2->(dbSetOrder(1))
		if SD2->(dbSeek(xFilial("SD2") + SF2->(F2_DOC) + SF2->(F2_SERIE) + SF2->(F2_CLIENTE) + SF2->(F2_LOJA) ))
			while !SD2->(EOF()) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == (xFilial("SD2") + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
				if aScan(_aPedido,SD2->D2_PEDIDO) == 0
					_cLogx := "Documento de Saída '" + SF2->F2_DOC + " / " + SF2->F2_SERIE + "' cancelado."
					AADD(_aPedido,SD2->D2_PEDIDO)
					// - Trecho inserido para gravar log de processo no atendimento
					dbSelectArea('SUA')
					SUA->(dbOrderNickName("UA_NUMSC5"))
					if SUA->(MsSeek(xFilial("SUA") + SD2->D2_PEDIDO,.T.,.F.))
						while !RecLock("SUA", .F.) ; enddo
							SUA->UA_STATSC9 := ""
							if SUA->(FieldPos("UA_LOGSTAT"))>0
								_cLog           := Alltrim(SUA->UA_LOGSTAT)
								SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
													UsrRetName(__cUserId) +	_lEnt + _cLogx
							endif
						SUA->(MsUnLock())
					endif
					// - Inserido em 24/03/2014 por Júlio Soares para gravar status também no quadro de vendas.
					dbSelectArea("SC5")
					SC5->(dbSetOrder(1))
					If SC5->(MsSeek(xFilial("SC5")+SD2->D2_PEDIDO,.T.,.F.))
						while !RecLock("SUA", .F.) ; enddo
							If SC5->(FieldPos("C5_LOGSTAT"))>0
								_cLog           := Alltrim(SC5->C5_LOGSTAT)
								SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
													UsrRetName(__cUserId) +	_lEnt + _cLogx
							endif
						SC5->(MsUnlock())
					endif
					//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
					If _lRFATL001
						U_RFATL001(	SC5->C5_NUM  ,;
									SUA->UA_NUM,;
									_cLogx     ,;
									_cRotina    )
					endif
				endif
				dbSelectArea("SD2")
				SD2->(dbSetOrder(1))
				SD2->(dbSKip())
			enddo
		endif
	endif
	// - Trecho inserido por Júlio Soares para que no momento da exclusão da nota, se a mesma foi denegada, 
	// - essa informação deve atualizar a observação doa livros fiscais.³
	_cQryS   := "  SELECT (F2_SERIE + F2_DOC) [F2_SDOC] ,NFE_ID ,F2_SERIE, F2_DOC, " + _lEnt
	_cQryS   += "  ISNULL(CONVERT(VARCHAR(2024), CONVERT(VARBINARY(2024),XMOT_SEFR)),'') AS XMOT_SEFR " + _lEnt
	_cQryS   += "  FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) " 					+ _lEnt
	_cQryS   += "     INNER JOIN SPED054 S54 (NOLOCK) ON S54.D_E_L_E_T_    = '' " 	+ _lEnt
	_cQryS   += "                           AND S54.XMOT_SEFR    <> '' " 			+ _lEnt
	_cQryS   += "                           AND (S54.XMOT_SEFR LIKE '%Deneg%' OR S54.XMOT_SEFR LIKE '%DENEG%') " + _lEnt
	_cQryS   += "                           AND S54.NFE_ID        = (SF2.F2_SERIE + SF2.F2_DOC) " + _lEnt
	_cQryS   += "  WHERE SF2.F2_FILIAL   = ' " + xFilial("SF2") + " ' " + _lEnt
	_cQryS   += "    AND SF2.F2_SERIE    = ' " + SF2->F2_SERIE  + " ' " + _lEnt
	_cQryS   += "    AND SF2.F2_DOC      = ' " + SF2->F2_DOC    + " ' " + _lEnt
	_cQryS   += "  ORDER BY SF2.F2_DOC, F2_EMISSAO " + _lEnt
	If TCSQLExec(_cQryS) < 0
		_cObserv := SF3->F3_OBSERV
		If !Empty (_cObserv)
			while !RecLock("SF3",.F.) ; enddo
				_cObserv := Alltrim(_cObserv) + " - NF DENEGADA "
			SF3->(MsUnLock())
		else
			while !RecLock("SF3",.F.) ; enddo
				_cObserv := ((Alltrim(_cObserv)) + ("NF DENEGADA "))
			SF3->(MsUnLock())
		endif
	endif
	// Trecho inserido por Júlio Soares para apresentar a tela a ser preenchida com o motivo da exclusão da Nota fiscal.
	if Existblock("RFATE027")
		Execblock("RFATE027")
	else
		MsgBox("Função não encontrada on U_RFATE027. Informe o Administrador do sistema",_cRotina+"_004","ALERT")
	endif
	// Linha adicionada por Adriano Leonardo em 11/12/2013 - chamada da função para atualizar histório de consumo do produto                
	HistConsum()
	RestArea(_aSvSUA)
	RestArea(_aSvSF2)
	RestArea(_aSvSD2)
	RestArea(_aSavArea)
return

static function HistConsum()
	//Salvo a área de trabalho atual
local _aSavArea  := GetArea()
local _aSavSF2   := SF2->(GetArea())
local _aSavSD2   := SD2->(GetArea())
local _aSavSB3   := SB3->(GetArea())
local _aSavSZG   := SZG->(GetArea())
local _cAnoMes   := SUBSTR(DtoS(dDataBase),1,6) 	     //AnoMes no formato (AAAAMM)
local _cCampo    := "B3_Q" + STRZERO(MONTH(dDataBase),2) //Variável para utilização de macro
local _cRotina := "SF2529E"
local lGrvSzg    := SuperGetMv("MV_GRVSZG" ,,.F.) 
local _QtdCons   := 0

if lGrvSzg //Determina se a gravação do histórico do consumo mensal está ativa na SZG (consumo médio - específico)		
	dbSelectArea("SD2")
	SD2->(dbSetOrder(3)) //Filial + Documento + Serie
	SD2->(dbGoTop())
	if SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
		while !SD2->(EOF()) .AND. SD2->D2_FILIAL==xFilial("SD2") .AND. SD2->D2_DOC==SF2->F2_DOC .AND. SD2->D2_SERIE==SF2->F2_SERIE
		_QtdCons:= Iif(SD2->D2_TIPO $ ("D") , (SB3->&_cCampo) - SD2->D2_QUANT, (SB3->&_cCampo) + SD2->D2_QUANT )
		u_reste009(SB3->B3_COD , _QtdCons ,_cRotina)			
			dbSelectArea("SD2")
	    	SD2->(dbSetOrder(3)) //Filial + Documento + Serie
	    	SD2->(dbSkip())
		enddo
	endif
endif
	//Restauro as áreas armazenadas originalmente
	RestArea(_aSavSZG)
	RestArea(_aSavSB3)
	RestArea(_aSavSD2)
	RestArea(_aSavSF2)
	RestArea(_aSavArea)
return
