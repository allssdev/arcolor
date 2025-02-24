#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#DEFINE _lEnt CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OM200FIM  ºAutor  ³ Júlio Soares       º Data ³  06/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc TOTVS³ Ponto de entrada ao término da gravação da carga, utilizadoº±±
±±º          ³para gravar informações personalizadas.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Realiza a atualização de campos específicos após a montagemº±±
±±º          ³ da carga.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Após a atualização das informações específicas é realizada º±±
±±º          ³ a atualização dos status no atendimento (CallCenter) e     º±±
±±º          ³ pedidos de venda. É gravado também nas tabelas SUA, SC5 e  º±±
±±º          ³ SF2 o código da carga gerado e a data da expedição.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Especifico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function OM200FIM()
	Local _aSavArea := GetArea()
	Local _aSavDAK  := {}
	Local _aSavDAI  := {}
	Local _aSavSC5  := {}
	Local _aSavSF2  := {}
	Local _aSavSE1  := {}
	Local _aSavSUA  := {}
	Local _aRecSUA  := {}
	Local _cRotina  := "OM200FIM"
	Local _cLogx    := ""
	Local _cSC9     := RetSqlName("SC9")
	Local _cLog     := ""
	Local _cQUpd   := ""
	Local _cQUpd1   := ""
	Local _cQUpd2   := ""
	Local _cQUpd3   := ""
	Local _cQUpd4   := ""
	Local _cQUpd5   := ""
	Local _cQuery   := ""
	Local cCarga    := DAK->DAK_COD
	Local _cSqCar   := DAK->DAK_SEQCAR
	Local _dCarga   := DAK->DAK_DATA
	Local _cSequen  := ""

    _cQUpd := " UPDATE  " + RetSqlName("SF2") 
	_cQUpd += " SET F2_CARGA = '"    + cCarga		  + "' " + _lEnt		
	_cQUpd += "   , F2_DTCARGA = '" + DTOS(_dCarga) 		  + "' " + _lEnt
	_cQUpd += "   , F2_SEQCAR  = SC9.C9_SEQCAR " + _lEnt
	_cQUpd += " FROM " + RetSqlName("SC9") + " SC9 WITH (NOLOCK) "                                 +_lEnt
	_cQUpd += " 	INNER JOIN " + RetSqlName("SF2") + " SF2 WITH (NOLOCK) ON SF2.D_E_L_E_T_ = '' " +_lEnt
	_cQUpd += "   		AND SF2.F2_FILIAL  = '" + xFilial("SF2")+ "' "                			    +_lEnt
	_cQUpd += "   		AND F2_FILIAL = C9_FILIAL AND F2_DOC = C9_NFISCAL AND F2_SERIE = C9_SERIENF "   +_lEnt	
	_cQUpd += " WHERE SC9.C9_CARGA = '"    + cCarga		  + "' " +_lEnt	
	_cQUpd += " 	AND SC9.D_E_L_E_T_ = '' " +_lEnt
//	MemoWrite("\2.MemoWrite\OMS\"+_cRotina+TRBPED->PED_NOTA +"_QRY_000.TXT",_cQUpd)	
	If TCSQLExec(_cQUpd) < 0
		MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_001",'STOP')
	EndIf
	TcRefresh("SF2")
	_cQUpd1 := " UPDATE  " + RetSqlName("SC5") 
	_cQUpd1 += " SET  C5_CARGA   = '" + cCarga  + "' " +_lEnt
	_cQUpd1 += " 	, C5_DTCARGA = '" + dtos(_dCarga) + "' " +_lEnt			
	_cQUpd1 += " WHERE C5_NUM  = '" + TRBPED->PED_PEDIDO    + "' " + _lEnt
//	MemoWrite("\2.MemoWrite\OMS\"+_cRotina+"_QRY_001.TXT",_cQUpd1)
	If TCSQLExec(_cQUpd1) < 0
		MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_001",'STOP')
	EndIf
	TcRefresh("SC5")
    _cQUpd2 := " UPDATE  " + RetSqlName("SUA") 
	_cQUpd2 += " SET  UA_CARGA   = '" + cCarga  + "' " +  _lEnt
	_cQUpd2 += " 	, UA_DTCARGA = '" + dtos(_dCarga) + "' " +_lEnt
	_cQUpd2 += " WHERE  UA_NUMSC5  = '" + TRBPED->PED_PEDIDO    + "' " + _lEnt
//	MemoWrite("\2.MemoWrite\OMS\"+_cRotina+"_QRY_002.TXT",_cQUpd2)
	If TCSQLExec(_cQUpd2) < 0
		MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_002",'STOP')
	EndIf		
	TcRefresh("SUA")
/*	o padrão já faz a atulização
	_cQUpd3 := " UPDATE " + RetSqlName("SC9") 
	_cQUpd3 += " SET C9_CARGA = '" +  cCarga     + "' " + _lEnt
	_cQUpd3 += " , C9_SEQCAR   = '" + _cSqCar      + "' " + _lEnt
	_cQUpd3 += "  WHERE  C9_NFISCAL      = '" + TRBPED->PED_NOTA       + "' " +_lEnt
	_cQUpd3 += "      AND C9_BLEST        = '10' " +_lEnt
	_cQUpd3 += "      AND (C9_TPCARGA     = '1' OR C9_TPCARGA = '3') " +_lEnt	
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_003.TXT",_cQUpd5)
	If TCSQLExec(_cQUpd3) < 0
		MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_003",'STOP')
	EndIf
*/
	_cQUpd4 := " UPDATE  " + RetSqlName("DAI") 
	_cQUpd4 += " SET DAI_NFISCA = SF2.F2_DOC  " 	+ _lEnt		
	_cQUpd4 += "   , DAI_NFISC2 = SF2.F2_DOC  " 	+ _lEnt
	_cQUpd4 += "   , DAI_PESO2  = SF2.F2_PBRUTO " 	+ _lEnt
	_cQUpd4 += "   , DAI_SERIE2 = SF2.F2_SERIE " 	+ _lEnt
	_cQUpd4 += "   , DAI_VALOR2 = SF2.F2_VALFAT " 	+ _lEnt
	_cQUpd4 += "   , DAI_VOLUM2 = SF2.F2_VOLUME1 " 	+ _lEnt
	_cQUpd4 += "   , DAI_VALFRE = SF2.F2_FRETE " 		+ _lEnt
	_cQUpd4 += "   , DAI_FREAUT = SF2.F2_FRETAUT " 		+ _lEnt
	_cQUpd4 += " FROM " + RetSqlName("DAI") + " DAI WITH (NOLOCK) "                                 +_lEnt
	_cQUpd4 += " 	INNER JOIN " + RetSqlName("SF2") + " SF2 WITH (NOLOCK) ON SF2.D_E_L_E_T_ = '' AND DAI.DAI_COD = SF2.F2_CARGA and DAI.DAI_SEQCAR = SF2.F2_SEQCAR  " +_lEnt
	_cQUpd4 += " 	INNER JOIN " + RetSqlName("SC9") + " SC9 WITH (NOLOCK) ON F2_FILIAL = SC9.C9_FILIAL AND F2_DOC = SC9.C9_NFISCAL AND F2_SERIE = SC9.C9_SERIENF AND F2_CARGA = C9_CARGA AND F2_SEQCAR = SC9.C9_SEQCAR AND DAI.DAI_PEDIDO = SC9.C9_PEDIDO  AND SC9.D_E_L_E_T_ = ''  " +_lEnt
	_cQUpd4 += " WHERE DAI.DAI_COD = '" + cCarga    + "' " + _lEnt
////	MemoWrite("\2.MemoWrite\OMS\"+_cRotina+TRBPED->PED_NOTA +"_QRY_004.TXT",_cQUpd4)	
	If TCSQLExec(_cQUpd4) < 0
		MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_004",'STOP')
	EndIf
    TcRefresh("DAI")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a atualização dos campos DAK_VALOR 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	_cQUpd := " UPDATE " + RetSqlName("DAK")                                         +_lEnt
	_cQUpd += " SET DAK_VALOR = SF2X.VALBRUT  "                                      +_lEnt
	_cQUpd += " FROM " + RetSqlName("DAK") + " DAK WITH (NOLOCK) "                   +_lEnt
	_cQUpd += " 	INNER JOIN (SELECT SF2.F2_CARGA, SF2.F2_SEQCAR,SUM(SF2.F2_VALBRUT)AS VALBRUT" +_lEnt
	_cQUpd += " 	FROM " + RetSqlName("SF2") + " SF2 WITH (NOLOCK) "               				  	+_lEnt
	_cQUpd += " 	WHERE SF2.D_E_L_E_T_ 	= '' "                                      +_lEnt
	_cQUpd += "   		AND SF2.F2_CARGA  	= '" + cCarga           + "' "         		+_lEnt
	_cQUpd += "   		AND SF2.F2_SEQCAR  	= '" + _cSqCar          + "' "         		+_lEnt
	_cQUpd += "   		AND SF2.F2_FILIAL 	= '" + xFilial("SF2")   + "' "              +_lEnt
	_cQUpd += "   	GROUP BY SF2.F2_CARGA, SF2.F2_SEQCAR) SF2X       "                  +_lEnt
	_cQUpd += "   		ON  DAK.DAK_COD 	= SF2X.F2_CARGA "             				+_lEnt
	_cQUpd += "   		AND DAK.DAK_SEQCAR  = SF2X.F2_SEQCAR "         					+_lEnt
	_cQUpd += "   		AND DAK.DAK_FILIAL  = '" + xFilial("DAK")   + "' "    			+_lEnt
	_cQUpd += "        WHERE  DAK.D_E_L_E_T_ = '' "                                    +_lEnt
//	MemoWrite("\2.MemoWrite\OMS\"+_cRotina+"_QRY_000_Carga_" + cCarga + ".txt",_cQUpd)
	If TCSQLExec(_cQUpd) < 0
		MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_000",'STOP')
	EndIf
	TcRefresh("DAK")
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria tabela temporária para atualização das tabelas SC5, SUA e SF2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cQuery := " SELECT DISTINCT ISNULL(SC5.R_E_C_N_O_, 0) RECSC5 "                                              +_lEnt
	_cQuery += "      ,          ISNULL(SUA.R_E_C_N_O_, 0) RECSUA "                                              +_lEnt
	_cQuery += "      ,          ISNULL(SUA.UA_STATSC9,'') UA_STATSC9 "                                          +_lEnt
	_cQuery += " FROM " + RetSqlName("DAI") + " DAI WITH (NOLOCK) "                                              +_lEnt
	_cQuery += "  	INNER JOIN      " + RetSqlName("SC5") + " SC5 WITH (NOLOCK) ON SC5.D_E_L_E_T_ = '' "         +_lEnt
	_cQuery += "  		AND SC5.C5_FILIAL  = '" + xFilial("SC5") + "' "                                          +_lEnt
	_cQuery += "  		AND SC5.C5_NUM     = DAI.DAI_PEDIDO "                                                    +_lEnt
	_cQuery += "  	LEFT OUTER JOIN " + RetSqlName("SUA") + " SUA WITH (NOLOCK) ON SUA.D_E_L_E_T_ = '' "         +_lEnt
	_cQuery += "  		AND SUA.UA_FILIAL  = '"+ xFilial("SUA")+"' "                                             +_lEnt
	_cQuery += "  		AND SUA.UA_NUMSC5  = DAI.DAI_PEDIDO "                                                    +_lEnt
	_cQuery += " WHERE DAI.D_E_L_E_T_ = '' "                                                                     +_lEnt
	_cQuery += "   AND DAI.DAI_FILIAL = '" + xFilial("DAI") + "' "                                               +_lEnt
	_cQuery += "   AND DAI.DAI_COD    = '" + cCarga         + "' "                                               +_lEnt
	_cQuery += "   AND DAI.DAI_SEQCAR = '" + _cSqCar        + "' "                                               +_lEnt
	//MemoWrite("\2.MemoWrite\OMS\"+_cRotina+"_QRY_005_Carga_"+ cCarga +".txt",_cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TRATMP",.T.,.F.)
	// - Abro a tabela temporária para verificar se há registro
	dbSelectArea("TRATMP")
	TRATMP->(dbGoTop())
	While !TRATMP->(EOF())
	// - Se houver significa que há saldo a ser faturado (Faturamento parcial)
	// - - Atualiza SC5
		If TRATMP->RECSC5 > 0
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			SC5->(dbGoTo(TRATMP->RECSC5))
			_cLog := Alltrim(SC5->C5_LOGSTAT) + _lEnt	
			while !RecLock("SC5",.F.) ; enddo	
				if empty(SC5->C5_CARGA)
					SC5->C5_CARGA := cCarga
				endif
				if empty(SC5->C5_DTCARGA)
					SC5->C5_DTCARGA := _dCarga
				endif
				If TRATMP->UA_STATSC9 == '06' // - 06 Faturado Parcial
					_cLogx := "PEDIDO EXPEDIDO PARCIALMENTE NA CARGA "+ cCarga + "."
					SC5->C5_SALDO   := 'S'		//'E'
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + _lEnt + _cLogx
				ElseIf TRATMP->UA_STATSC9 == '07' // - 07 Faturado Total
					_cLogx := "PEDIDO EXPEDIDO TOTALMENTE NA CARGA "+ cCarga + "."
					SC5->C5_SALDO   := 'E'
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + _lEnt + _cLogx
				Else
					_cLogx := "PEDIDO EXPEDIDO NA CARGA "+ cCarga + "."
					SC5->C5_SALDO   := 'E'
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + _lEnt + _cLogx	
				EndIf
			SC5->(MSUNLOCK())
		EndIf
	// - - Atualiza SUA
		If TRATMP->RECSUA > 0
			dbSelectArea("SUA")
			SUA->(dbSetOrder(1))
			SUA->(dbGoTo(TRATMP->RECSUA))
			_cLog := Alltrim(SUA->UA_LOGSTAT) + _lEnt
			while !RecLock("SUA",.F.) ; enddo
				if empty(SUA->UA_CARGA)
					SUA->UA_CARGA := cCarga
				endif
				if empty(SUA->UA_DTCARGA)
					SUA->UA_DTCARGA := _dCarga
				endif
				// - Se não for pedido de resíduo
				If !AllTrim(SC5->C5_SALDO) == 'R'
					SUA->UA_STATSC9 := '05'
				EndIf
				If TRATMP->UA_STATSC9 == '06'
					_cLogx := "PEDIDO EXPEDIDO PARCIALMENTE NA CARGA "+ cCarga + "."
					SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + _lEnt + _cLogx
				ElseIf TRATMP->UA_STATSC9 == '07'
					_cLogx := "PEDIDO EXPEDIDO TOTALMENTE NA CARGA "+ cCarga + "."
					SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + _lEnt + _cLogx
				Else
					_cLogx := "PEDIDO EXPEDIDO NA CARGA "+ cCarga + "."
					SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + _lEnt + _cLogx				
				EndIf		
			SUA->(MSUNLOCK())
		EndIf
		//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
		If ExistBlock("RFATL001")
			U_RFATL001(	SC5->C5_NUM  ,SUA->UA_NUM, _cLogx ,_cRotina    )
		EndIf
		dbSelectArea("TRATMP")
		TRATMP->(dbSkip())
	EndDo
	dbSelectArea("TRATMP")
	TRATMP->(dbCloseArea())
	RestArea(_aSavArea)
return
