#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _lEnt CHR(13) + CHR(10)
/*/{Protheus.doc} MT103FIM
@description Ponto de entrada utilizado para atualizar o custo da ultima compra do produto baseado nos documentos de entrada.
@author Júlio Soares
@since 08/06/2013
@version 1.0
@type function
@history 22/01/2014, Júlio Soares, DevGrv - Inserido trecho para verificar o codigo do vendedor no documento de origem (saida) a fim de gravar o mesmo no documento de entrada.
@history 10/12/2013, Adriano Leonardo, HistConsum - Criada a função responsável por gravar o histório do consumo mensal dos produtos, com base nas notas de devolução de vendas.
@history 17/11/2023, Diego Rodrigues, RCOME014 - Criada a função responsável por enviar os e-mails de alerta para o departamento da qualidade quando a nota for classificada.
@history 06/04/2024, Diego Rodrigues, Ajuste na linha 35 devido a mudança no processo interno da Arcolor
@see https://allss.com.br
/*/
user function MT103FIM()
	local   _aSavArea  := GetArea()
	local   _aSavSF1   := SF1->(GetArea())
	local   _aSavSF2   := SF2->(GetArea())
	local   _aSavSD2   := SD2->(GetArea())
	local   _aSavSE1   := SE1->(GetArea())
	local   _aSavSD1   := SD1->(GetArea())
	local   _aSavSB1   := SB1->(GetArea())
	Local _cTipo      := Alltrim(SuperGetMv("MV_XTIPME" ,,"/MP/EM/PI"))
	Local _nPosCod     := aScan(aHeader,{|x|AllTrim(x[02])=="D1_COD"   })
	private _cRotina   := "MT103FIM"

	/* Comentado conforme solicitação da Enilda
	If (PARAMIXB[1] == 3 .or. PARAMIXB[1] == 4) .and. PARAMIXB[2] == 1 .and. Posicione("SB1",1,XFILIAL("SB1")+Alltrim(aCols[1][_nPosCod]),"B1_TIPO")$_cTipo //Operação de Inclusão ou Classificação
		//Envio de e-mail para a qualidade informando que a nota foi classificada.
		U_RCOME014(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)

	EndIF
	*/
	//if //INCLUI            .AND. ;
	If	(PARAMIXB[1] == 3 .OR. PARAMIXB[1] == 4) .AND. ;		//Operação de Inclusão ou Classificação
		PARAMIXB[2] == 1				//Usuário confirmou
		if Upper(AllTrim(FunName())) == "MATA103"
			if SF1->(FieldPos("F1_MOTRET")) > 0 .AND. AllTrim(SF1->F1_TIPO) == "D"
				infMotDev()
			endif
			if !AllTrim(SF1->F1_TIPO) $ "D/B" //.AND. MsgYesNo("O Documento incluído foi o " + SF1->F1_DOC + ' - ' + SF1->F1_SERIE,_cRotina+"_temp")
				_cQry1 := " UPDATE SB1 "                                                                                     +_lEnt
				if SF1->F1_TIPO = 'N'
					_cQry1 += " SET B1_UPRC = (CAST((TX.CSTATU/TX.QTDATU) AS DECIMAL(14,"+cValToChar(TamSx3("B1_UPRC")[02])+"))) " +_lEnt
				elseif SF1->F1_TIPO $ 'IPC' // ICMS / IPI / PREÇO
					_cQry1 += " SET B1_UPRC = (CAST(((TX.CSTORI/TX.QTDORI) + (TX.TOTATU/TX.QTDORI)) AS DECIMAL(14,"+cValToChar(TamSx3("B1_UPRC")[02])+"))) " +_lEnt
				endif
				_cQry1 += " FROM "+RetSqlName("SB1")+" SB1 "                                                             +_lEnt
				_cQry1 += " INNER JOIN( SELECT SD1.D1_COD,SD1.D1_CUSTO[CSTATU],SD1.D1_QUANT[QTDATU],SD1.D1_TOTAL[TOTATU]," +_lEnt
				_cQry1 += "             SDA.D1_CUSTO[CSTORI],SDA.D1_QUANT[QTDORI]" +_lEnt
				_cQry1 += " 			FROM SF1010 SF1" +_lEnt
				_cQry1 += " 				INNER JOIN "+RetSqlName("SD1")+" SD1" +_lEnt
				_cQry1 += " 					ON  SD1.D1_FILIAL  = SF1.F1_FILIAL "   +_lEnt
				_cQry1 += " 					AND SD1.D1_DOC     = SF1.F1_DOC "      +_lEnt
				_cQry1 += " 					AND SD1.D1_SERIE   = SF1.F1_SERIE "    +_lEnt
				_cQry1 += " 					AND SD1.D1_FORNECE = SF1.F1_FORNECE "  +_lEnt
				_cQry1 += " 					AND SD1.D1_LOJA    = SF1.F1_LOJA "     +_lEnt
				_cQry1 += " 					AND SD1.D1_TIPO    = SF1.F1_TIPO "     +_lEnt
				_cQry1 += " 					AND SD1.D1_FORMUL  = SF1.F1_FORMUL "   +_lEnt
				_cQry1 += " 					AND SD1.D_E_L_E_T_ = '' "              +_lEnt
				_cQry1 += " 				INNER JOIN "+RetSqlName("SF4")+" SF4 "     +_lEnt
				_cQry1 += " 					ON SF4.F4_FILIAL   = SF1.F1_FILIAL "   +_lEnt
				_cQry1 += " 					AND SF4.F4_UPRC    = 'S' "             +_lEnt
				_cQry1 += " 					AND SF4.F4_CODIGO  = SD1.D1_TES "      +_lEnt
				_cQry1 += " 					AND SF4.D_E_L_E_T_ = '' "              +_lEnt
				_cQry1 += " 				LEFT JOIN "+RetSqlName("SD1")+" SDA "      +_lEnt
				_cQry1 += " 					ON  SDA.D1_FILIAL  = SF1.F1_FILIAL "   +_lEnt
				_cQry1 += " 					AND SDA.D1_DOC     = SD1.D1_NFORI "    +_lEnt
				_cQry1 += " 					AND SDA.D1_SERIE   = SD1.D1_SERIORI "  +_lEnt
				_cQry1 += " 					AND SDA.D1_FORNECE = SF1.F1_FORNECE "  +_lEnt
				_cQry1 += " 					AND SDA.D1_LOJA    = SF1.F1_LOJA "     +_lEnt
				_cQry1 += " 					AND SDA.D1_FORMUL  = SF1.F1_FORMUL "   +_lEnt
				_cQry1 += " 			WHERE SF1.F1_FILIAL = '"+xFilial("SD1") +"' " +_lEnt
				_cQry1 += " 			AND SF1.F1_DOC      = '"+SF1->F1_DOC    +"'" +_lEnt
				_cQry1 += " 			AND SF1.F1_SERIE    = '"+SF1->F1_SERIE  +"'" +_lEnt
				_cQry1 += " 			AND SF1.F1_FORNECE  = '"+SF1->F1_FORNECE+"'" +_lEnt
				_cQry1 += " 			AND SF1.F1_LOJA     = '"+SF1->F1_LOJA   +"'" +_lEnt
				_cQry1 += " 			AND SF1.F1_TIPO     = '"+SF1->F1_TIPO   +"'" +_lEnt
				_cQry1 += " 			AND SF1.F1_FORMUL   = '"+SF1->F1_FORMUL +"'" +_lEnt
				_cQry1 += " 			AND SF1.D_E_L_E_T_  = ''" +_lEnt
				_cQry1 += " )TX
				_cQry1 += " ON B1_COD =  TX.D1_COD
				if TCSQLExec(_cQry1) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_001")
				endif
	//			MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",GetLastQuery()[02])
			elseif AllTrim(SF1->F1_TIPO) $ "D/B"
				// - Trecho inserido por Júlio Soares em 22/01/2014 para chamar função de gravação.
				DevGrv()
				RestArea(_aSavSB1)
				RestArea(_aSavSD1)
				RestArea(_aSavSE1)
				RestArea(_aSavSD2)
				RestArea(_aSavSF2)
				RestArea(_aSavSF1)
				RestArea(_aSavArea)
				//ProcRegua(LASTREC())
				_dtData  := (Date() + SuperGetMV("MV_DVDIAS",,15))         // Pega a data atual + os dias definidos no parâmetro MV_DVDIAS para gerar a nova data
				_ddvDias := DTOS(_dtData                )                  // Transforma a data gerada em STRING
				_dtVenc  := DTOS(DataValida(_dtData,.T.))                  // Transforma a data gerada em data válida já em STRING
				_cQry2   := " UPDATE SE1 "                                                         +_lEnt
				_cQry2   += " SET E1_VENCORI = '" +  _ddvDias  + "' "                              +_lEnt
				_cQry2   += " ,   E1_VENCREA = '" +  _dtVenc   + "' "                              +_lEnt
				_cQry2   += " ,   E1_NOMCLI  = ISNULL(SA1.A1_NREDUZ,E1_NOMCLI ) "                  +_lEnt
				_cQry2   += " ,   E1_NOMERAZ = ISNULL(SA1.A1_NOME  ,E1_NOMERAZ) "                  +_lEnt
				_cQry2   += " FROM " + RetSqlName("SE1")+ " SE1 "                                  +_lEnt
				_cQry2   += "    INNER JOIN " + RetSqlName("SF1") + " SF1 ON SF1.D_E_L_E_T_ = '' " +_lEnt
				_cQry2   += "       AND SF1.R_E_C_N_O_ = " + cValToChar(SF1->(RECNO()))            +_lEnt
				_cQry2   += "       AND SF1.F1_TIPO    = 'D' "                                     +_lEnt
				_cQry2   += "       AND SF1.F1_SERIE   = SE1.E1_PREFIXO "                          +_lEnt
				_cQry2   += "       AND SF1.F1_DOC     = SE1.E1_NUM "                              +_lEnt
				_cQry2   += "       AND SF1.F1_FORNECE = SE1.E1_CLIENTE "                          +_lEnt
				_cQry2   += "       AND SF1.F1_LOJA    = SE1.E1_LOJA    "                          +_lEnt
				_cQry2   += "   LEFT OUTER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' " +_lEnt
				_cQry2   += "       AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "                +_lEnt
				_cQry2   += "       AND SA1.A1_COD     = SE1.E1_CLIENTE "                          +_lEnt
				_cQry2   += "       AND SA1.A1_LOJA    = SE1.E1_LOJA    "                          +_lEnt
				_cQry2   += " WHERE SE1.D_E_L_E_T_ = '' "                                          +_lEnt
				_cQry2   += "   AND SE1.E1_FILIAL  = '" + xFilial("SE1") + "' "                    +_lEnt
				_cQry2   += "   AND SE1.E1_TIPO    = 'NCC' "                                       +_lEnt
				if TCSQLExec(_cQry2) < 0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_002")
				endif
			//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",GetLastQuery()[02])
			endif
		endif
		HistConsum() // Linha adicionada por Adriano Leonardo em 10/12/2013 para chamada da função que grava 

	elseif !INCLUI .AND. !ALTERA .AND. PARAMIXB[2] == 1 .AND.  PARAMIXB[1] == 5
		if Upper(AllTrim(FunName())) == "MATA103" .And. !AllTrim(SF1->F1_TIPO) $ "D/B"
			_cQry1 := " UPDATE "+RetSqlName("SB1")+""                                                                          +_lEnt
			if SF1->F1_TIPO = 'N'
				_cQry1 += " SET B1_UPRC = (CAST((TX.CSTATU/TX.QTDATU) AS DECIMAL(14,"+cValToChar(TamSx3("B1_UPRC")[02])+"))) " +_lEnt
			elseif SF1->F1_TIPO $ 'IPC' // ICMS / IPI / PREÇO
				_cQry1 += " SET B1_UPRC = B1_UPRC - CAST(((TX.TOTATU/TX.QTDORI)) AS DECIMAL(14,"+cValToChar(TamSx3("B1_UPRC")[02])+"))" +_lEnt
			endif
			_cQry1 += " FROM "+RetSqlName("SB1")+" SB1 "                                                             +_lEnt
			_cQry1 += " INNER JOIN( SELECT SD1.D1_COD,SD1.D1_CUSTO[CSTATU],SD1.D1_QUANT[QTDATU],SD1.D1_TOTAL[TOTATU]," +_lEnt
			_cQry1 += "             SDA.D1_CUSTO[CSTORI],SDA.D1_QUANT[QTDORI]" +_lEnt
			_cQry1 += " 			FROM SF1010 SF1" +_lEnt
			_cQry1 += " 				INNER JOIN "+RetSqlName("SD1")+" SD1" +_lEnt
			_cQry1 += " 					ON  SD1.D1_FILIAL  = SF1.F1_FILIAL "   +_lEnt
			_cQry1 += " 					AND SD1.D1_DOC     = SF1.F1_DOC "      +_lEnt
			_cQry1 += " 					AND SD1.D1_SERIE   = SF1.F1_SERIE "    +_lEnt
			_cQry1 += " 					AND SD1.D1_FORNECE = SF1.F1_FORNECE "  +_lEnt
			_cQry1 += " 					AND SD1.D1_LOJA    = SF1.F1_LOJA "     +_lEnt
			_cQry1 += " 					AND SD1.D1_TIPO    = SF1.F1_TIPO "     +_lEnt
			_cQry1 += " 					AND SD1.D1_FORMUL  = SF1.F1_FORMUL "   +_lEnt
			// - Linha comentada pois nesse momento a exclusão já foi realizada.
			//_cQry1 += " 					AND SD1.D_E_L_E_T_ = '' "              +_lEnt
			_cQry1 += " 				INNER JOIN "+RetSqlName("SF4")+" SF4 "     +_lEnt
			_cQry1 += " 					ON SF4.F4_FILIAL   = SF1.F1_FILIAL "   +_lEnt
			_cQry1 += " 					AND SF4.F4_UPRC    = 'S' "             +_lEnt
			_cQry1 += " 					AND SF4.F4_CODIGO  = SD1.D1_TES "      +_lEnt
			_cQry1 += " 					AND SF4.D_E_L_E_T_ = '' "              +_lEnt
			_cQry1 += " 				LEFT JOIN "+RetSqlName("SD1")+" SDA "      +_lEnt
			_cQry1 += " 					ON  SDA.D1_FILIAL  = SF1.F1_FILIAL "   +_lEnt
			_cQry1 += " 					AND SDA.D1_DOC     = SD1.D1_NFORI "    +_lEnt
			_cQry1 += " 					AND SDA.D1_SERIE   = SD1.D1_SERIORI "  +_lEnt
			_cQry1 += " 					AND SDA.D1_FORNECE = SF1.F1_FORNECE "  +_lEnt
			_cQry1 += " 					AND SDA.D1_LOJA    = SF1.F1_LOJA "     +_lEnt
			_cQry1 += " 					AND SDA.D1_FORMUL  = SF1.F1_FORMUL "   +_lEnt
			_cQry1 += " 			WHERE SF1.F1_FILIAL = '"+xFilial("SD1") +"' " +_lEnt
			_cQry1 += " 			AND SF1.F1_DOC      = '"+SF1->F1_DOC    +"'" +_lEnt
			_cQry1 += " 			AND SF1.F1_SERIE    = '"+SF1->F1_SERIE  +"'" +_lEnt
			_cQry1 += " 			AND SF1.F1_FORNECE  = '"+SF1->F1_FORNECE+"'" +_lEnt
			_cQry1 += " 			AND SF1.F1_LOJA     = '"+SF1->F1_LOJA   +"'" +_lEnt
			_cQry1 += " 			AND SF1.F1_TIPO     = '"+SF1->F1_TIPO   +"'" +_lEnt
			_cQry1 += " 			AND SF1.F1_FORMUL   = '"+SF1->F1_FORMUL +"'" +_lEnt
			// - Linha comentada pois nesse momento a exclusão já foi realizada.
			//_cQry1 += " 			AND SF1.D_E_L_E_T_  = ''" +_lEnt
			_cQry1 += " )TX
			_cQry1 += " ON B1_COD =  TX.D1_COD
			if TCSQLExec(_cQry1) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_001")
			endif
		//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",GetLastQuery()[02])
		endif
	endif
	RestArea(_aSavSB1)
	RestArea(_aSavSD1)
	RestArea(_aSavSE1)
	RestArea(_aSavSD2)
	RestArea(_aSavSF2)
	RestArea(_aSavSF1)
	RestArea(_aSavArea)
return
/*/{Protheus.doc} MT103FIM
@description Sub-função responsável por gravar o histório do consumo mensal dos produtos, com base nas notas de devolução de vendas.
@author Adriano Leonardo
@since 10/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function HistConsum()
	local   _cAlias  := GetNextAlias()
	local   lGrvSzg  := SuperGetMv("MV_GRVSZG" ,,.F.) .AND. ExistBlock("RESTE009")

	if !lGrvSzg //Determina se a gravação do histórico do consumo mensal está ativa na SZG (consumo médio - específico)
		return
	endif
	if INCLUI
		if Upper(AllTrim(FunName())) == "MATA103" .AND. SF1->F1_TIPO == "D"
			dbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			SD1->(dbGoTop())
			if SD1->(dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
				While !SD1->(EOF()) .AND. ;
						SD1->D1_FILIAL  == xFilial("SD1")  .AND. ;
						SD1->D1_DOC     == SF1->F1_DOC     .AND. ;
						SD1->D1_SERIE   == SF1->F1_SERIE   .AND. ;
						SD1->D1_FORNECE == SF1->F1_FORNECE .AND. ;
						SD1->D1_LOJA    == SF1->F1_LOJA
					dbSelectArea("SB3")
					SB3->(dbSetOrder(1))
					SB3->(dbGoTop())
					if SB3->(dbSeek(xFilial("SB3")+SD1->D1_COD)) 
						_cCampo	 := "B3_Q" + STRZERO(MONTH(SF1->F1_EMISSAO),2) //Variável para utilização de macro
						U_RESTE009(SB3->B3_COD , (SB3->&_cCampo) ,_cRotina, SF1->F1_EMISSAO)		
					endif
					dbSelectArea("SD1")
					SD1->(dbSetOrder(1))
					SD1->(dbSkip())
				enddo
			endif
		endif    
	elseif Paramixb[1]==5 //Opção 5 - Exclusão (A nota já foi deletada nesse ponto)
		if Select(_cAlias) > 0
			(_cAlias)->(dbCloseArea())
		endif
		BeginSql Alias _cAlias
			SELECT DISTINCT D1_COD
			FROM %table:SD1% SD1
			WHERE SD1.D1_FILIAL = %xFilial:SD1% 	
			  AND SD1.D1_DOC    = %Exp:SF1->F1_DOC% 
			  AND SD1.D1_SERIE  = %Exp:SF1->F1_SERIE%
			  AND %NotDel%
		EndSql
		dbSelectArea(_cAlias)
		(_cAlias)->(dbGoTop())
		while !(_cAlias)->(EOF())
			dbSelectArea("SB3")
			SB3->(dbSetOrder(1))
			SB3->(dbGoTop())
			if SB3->(dbSeek(xFilial("SB3")+SD1->D1_COD))
				_cCampo	 := "B3_Q" + STRZERO(MONTH(dDataBase),2) //Variável para utilização de macro
				U_RESTE009(SB3->B3_COD , (SB3->&_cCampo) ,_cRotina)			
			endif
			dbSelectArea(_cAlias)
			(_cAlias)->(dbSkip())
		enddo
		if Select(_cAlias) > 0
			(_cAlias)->(dbCloseArea())
		endif
	endif
return
/*/{Protheus.doc} DevGrv
@description Função responsável por verificar o vendedor do documento de origem e gravar no documento respectivo de devolução.
@author Júlio Soares
@since 22/01/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function DevGrv()
	local _cSD1Tmp := GetNextAlias()
	if Select(_cSD1Tmp) > 0
		(_cSD1Tmp)->(dbCloseArea())
	endif
	BeginSql Alias _cSD1Tmp
		SELECT DISTINCT D1_NFORI, D1_SERIORI
		FROM %table:SD1% SD1
		WHERE SD1.D1_FILIAL   = %xFilial:SD1% 	
	  	  AND SD1.D1_DOC      = %Exp:SF1->F1_DOC%
	  	  AND SD1.D1_SERIE    = %Exp:SF1->F1_SERIE%
	  	  AND SD1.D1_FORNECE  = %Exp:SF1->F1_FORNECE% 
	  	  AND SD1.D1_LOJA     = %Exp:SF1->F1_LOJA%
	  	  AND SD1.D1_TIPO     = %Exp:SF1->F1_TIPO%
	  	  AND SD1.D1_NFORI   <> '' 
		  AND SD1.%NotDel%
	EndSql
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_004.TXT",GetLastQuery()[02])
	dbSelectArea(_cSD1Tmp)
	if !(_cSD1Tmp)->(EOF())
		while !(_cSD1Tmp)->(EOF())
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1))
			if SF2->(MsSeek(xFilial("SF2")                                        + ;
							Padr((_cSD1Tmp)->D1_NFORI  ,TamSx3("F2_DOC"    )[01]) + ;
							Padr((_cSD1Tmp)->D1_SERIORI,TamSx3("F2_SERIE"  )[01]) + ;
							Padr(SF1->F1_FORNECE       ,TamSx3("F2_CLIENTE")[01]) + ;
							Padr(SF1->F1_LOJA          ,TamSx3("F2_LOJA"   )[01]), .T., .F.) )
				if AllTrim(SF2->F2_TIPO) == "N"
					if !Empty(SF2->F2_VEND1)
						if AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_MSBLQL")) <> "1"
							Reclock("SF1",.F.)
								SF1->F1_VEND1 := SF2->F2_VEND1
							SF1->(MsUnlock())
						else
							// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
							//MSGBOX(	'O vendedor cadastrado no documento original não está mais disponível para uso.'+_lEnt+;
							//		'Verifique se o mesmo ainda está ativo no sistema. ' +_lEnt+;
							//		'O documento de devolução será gerado sem vendedor.',_cRotina+'_005','ALERT')

							MSGBOX(	'O representante cadastrado no documento original não está mais disponível para uso.'+_lEnt+;
									'Verifique se o mesmo ainda está ativo no sistema. ' +_lEnt+;
									'O documento de devolução será gerado sem representante.',_cRotina+'_005','ALERT')
							// fIM - Fernando Bombardi - ALLSS - 02/03/2022
							Reclock("SF1",.F.)
								SF1->F1_VEND1 := ""
							SF1->(MsUnlock())
						endif
					else
						// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
						//MSGBOX(	'Não há vendedor cadastrado no documento original "'+SF2->F2_DOC+'", série "'+SF2->F2_SERIE+'".'+_lEnt+;
						//		'O documento de devolução será gerado sem vendedor.',_cRotina+'_006','ALERT')

						MSGBOX(	'Não há representante cadastrado no documento original "'+SF2->F2_DOC+'", série "'+SF2->F2_SERIE+'".'+_lEnt+;
								'O documento de devolução será gerado sem representante.',_cRotina+'_006','ALERT')
						// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
			
						Reclock("SF1",.F.)
							SF1->F1_VEND1 := ""
						SF1->(MsUnlock())
					endif
				endif
			endif
			dbSelectArea(_cSD1Tmp)
			(_cSD1Tmp)->(dbSkip())
		enddo
	endif
	if Select(_cSD1Tmp) > 0
		(_cSD1Tmp)->(dbCloseArea())
	endif
return
/*/{Protheus.doc} infMotDev
@description Sub-Rotina utilizada para apresentar a tela para a informação do motivo de devolução de vendas, pós inclusão do documento de entrada.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 10/03/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
static function infMotDev()
	local   _aSavAr := GetArea()
	local   oGet1
	local   oGet2
	local   oGroup1
	local   oSay1
	local   oSay2
	local   oSButton1
	if type("cMotRet")<>"C"
		private cMotRet  := SF1->F1_MOTRET
	endif
	if type("cHistRet")<>"C"
		private cHistRet := Space(100)
	endif
	static oDlg
	DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] MOTIVO PARA DEVOLUÇÃO DE VENDAS" FROM 000, 000  TO 180, 500 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
		oDlg:lEscClose := .F.
		@ 004, 004 GROUP oGroup1 TO 076, 245 PROMPT "*** Informe o motivo para a devolução de vendas ***" OF oDlg COLOR 0, 16777215 PIXEL
		@ 020, 008 SAY oSay1 PROMPT "Motivo:"                              SIZE 045, 007 OF oDlg COLORS 0, 16777215           PIXEL
		@ 019, 030 MSGET oGet1 VAR cMotRet  Valid NAOVAZIO().AND.ExistCpo("DHI",cMotRet,1) SIZE 080, 010 OF oDlg COLORS 0, 16777215 F3 "DHI"  PIXEL
		@ 040, 008 SAY oSay2 PROMPT "OBS:"                                 SIZE 045, 007 OF oDlg COLORS 0, 16777215           PIXEL
		@ 039, 030 MSGET oGet2 VAR cHistRet Valid NAOVAZIO()               SIZE 210, 010 OF oDlg COLORS 0, 16777215           PIXEL
		DEFINE SBUTTON oSButton1 FROM 060, 0010 TYPE 01 OF oDlg ENABLE ACTION EVAL({|| IIF(ExistCpo("DHI",cMotRet,1).AND.!empty(cMotRet).AND.!empty(cHistRet),oDlg:End(),MsgStop("Preencha as informações de motivo para devolução!",_cRotina+"_007"))})
	ACTIVATE MSDIALOG oDlg CENTERED
	while !RecLock("SF1",.F.) ; enddo
		SF1->F1_MOTRET  := cMotRet
		if !empty(cHistRet)
			SF1->F1_HISTRET := cHistRet
     	else
     		dbSelectArea("DHI")
     		DHI->(dbSetOrder(1))
     		if DHI->(MsSeek(FWFilial("DHI")+SF1->F1_MOTRET,.T.,.F.))
     			SF1->F1_HISTRET := IIF(SF1->F1_TIPO == "D","Devolvido","Retornado")+" por motivo de "+AllTrim(DHI->DHI_DESCRI)
     		endif
     	endif
     SF1->(MsUnLock())
     RestArea(_aSavAr)
return
