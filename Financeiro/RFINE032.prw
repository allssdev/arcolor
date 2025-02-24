#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
/*/{Protheus.doc} RFINE032
@description Rotina chamada pelos fontes 'SF2460I' e 'FA280', utilizado para o complemento de informa��es nos t�tulos a receber.
@author Anderson C. P. Coelho
@since 07/11/2016
@version 1.0
@param _cNumAt, character, N�mero do Atendimento do Call Center
@param _cNumPed, character, N�mero do Pedido de Vendas.
@type function
@see https://allss.com.br
/*/
user function RFINE032(_cNumAt,_cNumPed)
	Local _aSavAreaF := GetArea()
	Local _aSavSE1F  := SE1->(GetArea())
	Local _aSavSA1F  := SA1->(GetArea())
	Local _aSavSC5F  := SC5->(GetArea())
	Local _aSavSC6F  := SC6->(GetArea())
	Local _aSavSC9F  := SC9->(GetArea())
	Local _aSavSF2F  := SF2->(GetArea())
	Local _aSavSD2F  := SD2->(GetArea())
	Local _aSavSF1F  := SF1->(GetArea())
	Local _aSavSD1F  := SD1->(GetArea())
	Local _aSavSE4F  := SE4->(GetArea())
	Local _aSavSL4F  := SL4->(GetArea())
	Local _aSavSUAF  := SUA->(GetArea())
	Local _aSavSUBF  := SUB->(GetArea())
	Local _aSavSZIF  := SZI->(GetArea())
	Local _cRotina   := "RFINE032"
	Local _cDProSZI  := ""
	Local _cSZITMP   := GetNextAlias()
	Local _cOpTroca  := SuperGetMv("MV_OPERACA",,"6"             ) //Default para opera��es de troca
	Local _nValTol   := SuperGetMv("MV_TOLVBOL",,10.00           )
	Local _nDiasTol  := SuperGetMv("MV_TOLDBOL",,1               )
	Local _cIntrucao := SuperGetMv("MV_XINSTRU",,""              )
	Local _dExcData  := STOD("")
	Local _dExcPDe   := SuperGetMv("MV_PROVDE" ,,STOD("20141212"))
	Local _dExcPAte  := SuperGetMv("MV_PROVATE",,STOD("20150107"))
	Local _dExcPDe1  := SuperGetMv("MV_PROVDE1",,STOD("20141212"))
	Local _dExcPAte1 := SuperGetMv("MV_PROVAT1",,STOD("20150107"))

	Default _cNumAt  := ""
	Default _cNumPed := ""          //Linha adicionada por Adriano Leonardo em 07/10/2013 para tratamento adicional

	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	If (Empty(_cNumAt) .OR. Empty(_cNumPed)) .AND. SC6->(MsSeek(xFilial("SC6") + SE1->E1_PEDIDO,.T.,.F.))
		_cNumAt  := SubStr(SC6->C6_PEDCLI,4,7)
		_cNumPed := SC6->C6_NUM //Linha adicionada por Adriano Leonardo em 07/10/2013 para tratamento adicional
	EndIf
	dbSelectArea("SE1")
	while !RecLock("SE1",.F.) ; enddo
		If Empty(_cNumAt) .AND. !Empty(SE1->E1_PEDIDO)
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			If SC5->(MsSeek(xFilial("SC5") + SE1->E1_PEDIDO,.T.,.F.))
				dbSelectArea("SUB")
				SUB->(dbSetOrder(3))
				If SUB->(MsSeek(xFilial("SUB") + SC5->C5_NUM,.T.,.F.))
					_cNumAt := SUB->UB_NUM
					/*
					dbSelectArea("SUA")
					SUA->(dbSetOrder(1))
					If SUA->(MsSeek(xFilial("SUB") + SUB->UB_NUM,.T.,.F.))
						_cNumAt := SUA->UA_NUM
					EndIf
					*/
				EndIf
			EndIf
		EndIf
		dbSelectArea("SL4")
		SL4->(dbSetOrder(1)) // Numero + Origem
		If !Empty(_cNumAt) .AND. SL4->(MsSeek(xFilial("SL4") + _cNumAt,.T.,.F.)) //.AND. _nContE1 == _nContL4
			//_nContL4++
			SE1->E1_FORMPG := AllTrim(SL4->L4_FORMA)
		EndIf
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
		If SubStr(FunName(),1,4)=="FINA" .OR. (AllTrim(SE1->E1_TIPO) == "NF" .AND. SF2->(dbSeek(xFilial("SF2") + SE1->E1_NUM + SE1->E1_PREFIXO + SE1->E1_CLIENTE + SE1->E1_LOJA)))		//SF2->(MsSeek(xFilial("SF2") + SE1->E1_NUM + SE1->E1_PREFIXO + SE1->E1_CLIENTE + SE1->E1_LOJA,.T.,.F.)))
			If SubStr(FunName(),1,4)=="FINA" .OR. !AllTrim(SF2->F2_TIPO)$"D/B"
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA,.T.,.F.))
					SE1->E1_NATUREZ := SA1->A1_NATUREZ
					SE1->E1_NOMERAZ := SA1->A1_NOME
					SE1->E1_NOMCLI  := SA1->A1_NOME
					SE1->E1_CGCCENT := SA1->A1_CGCCENT // - Linha inserida em 10/04/2014 por J�lio Soares para atualiza��o do CNPJ central no t�tulo.
					If SE1->(FieldPos("E1_DESCFIN"))<>0
						SE1->E1_DESCFIN	:= SA1->A1_DESCFIN	//Linha adicionada por Adriano Leonardo em 13/01/2014 para adi��o 
															//de nova funcionalidade (desconto financeiro com base no cadastro
															//de cliente
					EndIf
					//In�cio - Trecho adicionado por Adriano Leonardo em 07/10/2013 para tratamento adicional da carteira do t�tulo
						//----------------------------------------------------------------------------------//
						// Definido junto com a Sra. Alecssandra em  20/12/2016 que os titulos de funion�rio//
						// devem ser preenchido com a Carteira FOLHA conforme cadastro de clientes.         //
						// Os demais titulos, quando houver Vencimento  <= Emiss�o + 1 devem ser preenchidos//
						// com "" Em branco no caso de venda e "CA" nos casos de Troca pois nessas condi��es//
						// n�o s�o gerados boletos - Analista: Renan Santos                                 //
						//----------------------------------------------------------------------------------//  
						dbSelectArea("SC5")
						SC5->(dbSetOrder(1))
						If SC5->(MsSeek(xFilial("SC5")+_cNumPed,.T.,.F.))
							//Verifico pelo tipo de opera��o do pedido se o sistema � de troca
							If AllTrim(SC5->C5_TPOPER) $ _cOpTroca
								SE1->E1_CARTEIR := "CA"
							Else
								/*if SE1->E1_VENCREA <= DataValida(SE1->E1_EMISSAO + _nDiasTol,.T.)
									SE1->E1_CARTEIR := ""// - Em branco para nao gerar boleto. 
							   	Else
							    	SE1->E1_CARTEIR := SA1->A1_CDCART
							    EndIf  
								*/
								//INICIO - TRECHO Adicionado por Diego Rodrigues em 29/09/2021
								if AllTrim(SC5->C5_TPOPER) = "ZZ"
									SE1->E1_CARTEIR := SA1->A1_CDCART
							    ElseIf SE1->E1_VENCREA <= DataValida(SE1->E1_EMISSAO + _nDiasTol,.T.)
									SE1->E1_CARTEIR := ""// - Em branco para nao gerar boleto. 
							   	Else
							    	SE1->E1_CARTEIR := SA1->A1_CDCART
							    EndIf  
								//FIM
							EndIf
						EndIf 
					//Fim - Trecho adicionado por Adriano Leonardo em 07/10/2013 para tratamento adicional da carteira do t�tulo
					SE1->E1_PORTADO := SA1->A1_BCO1
					SE1->E1_AGEDEP	:= SA1->A1_AGENCIA
					SE1->E1_CONTA 	:= SA1->A1_BCCONT
					SE1->E1_OCORREN := "01"
					SE1->E1_INSTR1  := SA1->A1_INSTRU1
					SE1->E1_INSTR2  := SA1->A1_INSTRU2
					If SA1->(FieldPos("A1_PRZPROT"))<>0
						SE1->E1_DIASPRO := SA1->A1_PRZPROT
					EndIf
					If SE1->E1_VENCREA <= DataValida(SE1->E1_EMISSAO + _nDiasTol,.T.) .OR. IIF(EXISTBLOCK("RFINEBBV"),U_RFINEBBV(),SE1->(E1_SALDO - E1_SDDECRE + E1_SDACRES)) <= _nValTol
						//Dados j� atualizados acima
					Else
						//10/10/2014 - Anderson - Tratamento da exce��o das instru��es de cobran�a para quando o 
						//                        t�tulo a receber estiver dentro do range de data definido nos 
						//                        par�metros MV_PROVDE e MV_PROVATE, exceto para o estado do Rio de Janeiro
						//						Estas regras n�o se aplicar�o para as instru��es originais "00", que est�o
						//						marcados na SZI como sendo instru��o de protesto, quando, na realidade, s�o
						//						entendidos como "Sem Protesto" (normalmente, os clientes do estado RJ
						//						abrangem esta regra.
						_dExcData := SuperGetMv("MV_PROPROT",,STOD("20150115"))
						_dExcData := IIF(Empty(_dExcData),SE1->E1_VENCTO,_dExcData)
						_dDiasPro := _dExcData - SE1->E1_VENCTO
						_lExcVct  := .F.
						If AllTrim(SE1->E1_INSTR1) <> "00" .AND. AllTrim(SE1->E1_INSTR2) <> "00" .AND. (SE1->E1_VENCTO >= _dExcPDe .AND. SE1->E1_VENCTO <= _dExcPAte .OR. SE1->E1_VENCTO >= _dExcPDe1 .AND. SE1->E1_VENCTO <= _dExcPAte1 ) .AND.  (_dDiasPro == 0 .OR. (_dDiasPro >= 0 .AND. SE1->E1_VENCTO <= _dExcData))
							if select(_cSZITMP) > 0
								(_cSZITMP)->(dbCloseArea())
							endif
							_cDProSZI := "%AND SZI.ZI_DIASPRO "+IIF(_dDiasPro == 0," = "," > ")+cValToChar(_dDiasPro)+"%"
							BeginSql Alias _cSZITMP
								SELECT SZIX.ZI_DIASPRO, SZIX.ZI_ATUDPRO, MAX(ZI_CODINST) ZI_CODINST
								FROM %table:SZI% SZIX (NOLOCK)
								 	INNER JOIN ( SELECT ZI_FILIAL, ZI_OCORREN, ZI_TPINSTR, MIN(ZI_DIASPRO) ZI_DIASPRO, ZI_BANCO,ZI_AGENCIA, ZI_CONTA, ZI_MSBLQL
								 				 FROM %table:SZI% SZI (NOLOCK)
								 				 WHERE SZI.ZI_FILIAL   = %xFilial:SZI%
								 				   AND SZI.ZI_BANCO    = %Exp:SE1->E1_PORTADO%
								 				   AND SZI.ZI_AGENCIA  = %Exp:SE1->E1_AGEDEP%
								 				   AND SZI.ZI_CONTA    = %Exp:SE1->E1_CONTA%
								 				   AND SZI.ZI_OCORREN  = %Exp:SE1->E1_OCORREN%
								 				   AND SZI.ZI_TPINSTR  = 'P'
								 				   AND SZI.ZI_MSBLQL   = '2'
								 				   AND SZI.%NotDel%
								 				   %Exp:_cDProSZI%
								 				 GROUP BY ZI_FILIAL, ZI_BANCO,ZI_AGENCIA, ZI_CONTA,ZI_OCORREN, ZI_TPINSTR, ZI_MSBLQL
								 				) TMP ON TMP.ZI_FILIAL  = SZIX.ZI_FILIAL
								 				     AND TMP.ZI_BANCO   = SZIX.ZI_BANCO
								 				     AND TMP.ZI_AGENCIA = SZIX.ZI_AGENCIA
								 				     AND TMP.ZI_CONTA   = SZIX.ZI_CONTA
								 				     AND TMP.ZI_OCORREN = SZIX.ZI_OCORREN
								 				     AND TMP.ZI_DIASPRO = SZIX.ZI_DIASPRO
								 				     AND TMP.ZI_TPINSTR = SZIX.ZI_TPINSTR
								 				     AND TMP.ZI_MSBLQL  = SZIX.ZI_MSBLQL
								WHERE SZIX.%NotDel%
								GROUP BY SZIX.ZI_DIASPRO, SZIX.ZI_ATUDPRO
							EndSql
							dbSelectArea(_cSZITMP)
							If !(_cSZITMP)->(EOF())
								dbSelectArea("SZI")
								/*
								//Trecho alterado em 12/10/2016 por J�lio Soares para ajuste na altera��o de instru��o quando 
								//dentro do range de data definida como per�odo de f�rias coletivas da empresa para que os t�tulos 
								//com vencimento nessas datas n�o v�o para protesto
								//SZI->(dbSetOrder(3))		//ZI_FILIAL+ZI_OCORREN+ZI_CODINST+ZI_BANCO+ZI_AGENCIA+ZI_CONTA
								SZI->(dbOrderNickName("ZI_OCORREN"))
								If SZI->(MsSeek(xFilial("SZI") + SE1->E1_OCORREN + SE1->E1_INSTR1,.T.,.F.)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" //.AND. !Empty(SZI->ZI_DIACONT)
									SE1->E1_INSTR1      := (_cSZITMP)->ZI_CODINST
									//If AllTrim((_cSZITMP)->ZI_ATUDPRO) == "S"
										SE1->E1_DIASPRO := (_cSZITMP)->ZI_DIASPRO
									//EndIf
								ElseIf SZI->(MsSeek(xFilial("SZI") + SE1->E1_OCORREN + SE1->E1_INSTR2,.T.,.F.)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" .AND. !Empty(SZI->ZI_DIACONT)
									SE1->E1_INSTR2      := (_cSZITMP)->ZI_CODINST
									//If AllTrim((_cSZITMP)->ZI_ATUDPRO) == "S"
										SE1->E1_DIASPRO := (_cSZITMP)->ZI_DIASPRO
									//EndIf
								EndIf
								*/
								//SZI->(dbSetOrder(5))//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_OCORREN+ZI_CODINST+ZI_DIASPRO
								SZI->(dbOrderNickName("ZI_BANCO2"))
								If SE1->E1_DIASPRO > 0 .AND. SZI->(MsSeek(xFilial("SZI") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + SE1->E1_OCORREN + SE1->E1_INSTR1 + Str(SE1->E1_DIASPRO,3,0),.T.,.F.)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" //.AND. !Empty(SZI->ZI_DIACONT)
									//INICIO - Trecho alterado 07/10/2021 por Diego Rodrigues para atender a necessidade do banco itau estar com a instru��o em branco
									//SE1->E1_INSTR1  := (_cSZITMP)->ZI_CODINST
									SE1->E1_INSTR1  := IIF(SE1->E1_PORTADO = "341",_cIntrucao,(_cSZITMP)->ZI_CODINST)
									//FIM
									SE1->E1_DIASPRO := (_cSZITMP)->ZI_DIASPRO
									_lExcVct        := .T.
								ElseIf SE1->E1_DIASPRO > 0 .AND. SZI->(MsSeek(xFilial("SZI") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + SE1->E1_OCORREN + SE1->E1_INSTR2 + Str(SE1->E1_DIASPRO,3,0),.T.,.F.)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" .AND. !Empty(SZI->ZI_DIACONT)
									//INICIO - Trecho alterado 07/10/2021 por Diego Rodrigues para atender a necessidade do banco itau estar com a instru��o em branco
									//SE1->E1_INSTR2  := (_cSZITMP)->ZI_CODINST
									SE1->E1_INSTR2  := IIF(SE1->E1_PORTADO = "341", _cIntrucao,(_cSZITMP)->ZI_CODINST)
									//FIM
									SE1->E1_DIASPRO := (_cSZITMP)->ZI_DIASPRO
									_lExcVct        := .T.
								ElseIf SZI->(MsSeek(xFilial("SZI") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + SE1->E1_OCORREN + SE1->E1_INSTR1,.T.,.F.)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" //.AND. !Empty(SZI->ZI_DIACONT)
									//INICIO - Trecho alterado 07/10/2021 por Diego Rodrigues para atender a necessidade do banco itau estar com a instru��o em branco
									//SE1->E1_INSTR1  := (_cSZITMP)->ZI_CODINST
									SE1->E1_INSTR1  := IIF(SE1->E1_PORTADO = "341",_cIntrucao,(_cSZITMP)->ZI_CODINST)
									//FIM
									SE1->E1_DIASPRO := (_cSZITMP)->ZI_DIASPRO
									_lExcVct        := .T.
								ElseIf SZI->(MsSeek(xFilial("SZI") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + SE1->E1_OCORREN + SE1->E1_INSTR2,.T.,.F.)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" .AND. !Empty(SZI->ZI_DIACONT)
									//INICIO - Trecho alterado 07/10/2021 por Diego Rodrigues para atender a necessidade do banco itau estar com a instru��o em branco
									//SE1->E1_INSTR2  := (_cSZITMP)->ZI_CODINST
									SE1->E1_INSTR2  := IIF(SE1->E1_PORTADO = "341", _cIntrucao,(_cSZITMP)->ZI_CODINST)
									//FIM
									SE1->E1_DIASPRO := (_cSZITMP)->ZI_DIASPRO
									_lExcVct        := .T.
								EndIf
							EndIf
							if select(_cSZITMP) > 0
								(_cSZITMP)->(dbCloseArea())
							endif
						EndIf
						If !_lExcVct
							//10/10/2014 - Anderson - Alimenta��o dos dias para protesto na SE1, quando for o caso
							dbSelectArea("SZI")
			/*
									//SZI->(dbSetOrder(3))		//ZI_FILIAL+ZI_OCORREN+ZI_CODINST+ZI_BANCO+ZI_AGENCIA+ZI_CONTA
									SZI->(dbOrderNickName("ZI_OCORREN"))
									If SZI->(MsSeek(xFilial("SZI") + SE1->E1_OCORREN + SE1->E1_INSTR1)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" .AND. AllTrim(SZI->ZI_ATUDPRO) == "S"
										SE1->E1_DIASPRO := SZI->ZI_DIASPRO
									ElseIf SZI->(MsSeek(xFilial("SZI") + SE1->E1_OCORREN + SE1->E1_INSTR2)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" .AND. AllTrim(SZI->ZI_ATUDPRO) == "S"
										SE1->E1_DIASPRO := SZI->ZI_DIASPRO
									Else
										SE1->E1_DIASPRO := 0
									EndIf
			*/
								//SZI->(dbSetOrder(5))//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_OCORREN+ZI_CODINST+ZI_DIASPRO
								SZI->(dbOrderNickName("ZI_BANCO2"))
								If SZI->(MsSeek(xFilial("SZI") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + SE1->E1_OCORREN + SE1->E1_INSTR1 + Str(SE1->E1_DIASPRO,3,0),.T.,.F.)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" //.AND. !Empty(SZI->ZI_DIACONT)
									SE1->E1_DIASPRO := SZI->ZI_DIASPRO
								ElseIf SZI->(MsSeek(xFilial("SZI") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + SE1->E1_OCORREN + SE1->E1_INSTR2 + Str(SE1->E1_DIASPRO,3,0),.T.,.F.)) .AND. AllTrim(SZI->ZI_TPINSTR) == "P" .AND. !Empty(SZI->ZI_DIACONT)
									SE1->E1_DIASPRO := SZI->ZI_DIASPRO
								EndIf
							//10/10/2014 - Anderson - Fim da alimenta��o dos dias para protesto na SE1, quando for o caso
						EndIf
						//10/10/2014 - Anderson - Fim do tratamento da exce��o das instru��es de cobran�a
					EndIf
				EndIf
			Else
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				If SA2->(MsSeek(xFilial("SA2") + SE1->E1_CLIENTE + SE1->E1_LOJA,.T.,.F.))
					SE1->E1_NOMERAZ := SA2->A2_NOME
					SE1->E1_NOMCLI  := SA2->A2_NOME
				EndIf
			EndIf
			dbSelectArea("SE1")
			//In�cio - Trecho do IF adicionado por Adriano Leonardo em 08/08/2014 para tratar o caso dos pedidos de funcion�rios
			If SubStr(FunName(),1,4)<>"FINA" .AND. SF2->F2_COND == SuperGetMV("MV_FUNCOND",,"FOL")
				SE1->E1_PORCJUR := 0
				//In�cio - Trecho adicionado por Adriano Leonardo em 22/08/2014 para gravar a matr�cula dos funcion�rios nos casos de pedidos de funcion�rios
				/*_aSavSRA := SRA->(GetArea())
				dbSelectArea("SRA")
				SRA->(dbOrderNickName("RA_CLIENTE"))
				If SRA->(dbSeek(xFilial("SRA")+SE1->E1_CLIENTE+SE1->E1_LOJA))
					SE1->E1_MATRIC	:= SRA->RA_MAT
				EndIf
				RestArea(_aSavArea)*/
				//Final  - Trecho adicionado por Adriano Leonardo em 22/08/2014 para gravar a matr�cula dos funcion�rios nos casos de pedidos de funcion�rios
			Else
				SE1->E1_PORCJUR := SuperGetMv("MV_PORCJUR",,0.20)
			EndIf
			//In�cio - Trecho adicionado por Adriano Leonardo em 22/04/2014 - para gravar a observa��o da condi��o de pagamento no t�tulo a receber
			dbSelectArea("SE4")
			If SubStr(FunName(),1,4)<>"FINA" .AND. SE4->(FieldPos("E4_OBSNOTA"))<>0
				SE4->(dbSetOrder(1))
				If SE4->(MsSeek(xFilial("SE4")+SF2->F2_COND,.T.,.F.))
					//Gravo a observa��o da condi��o de pagamento nos t�tulos a receber
					If !Empty(SE4->E4_OBSNOTA)
						SE1->E1_OBSCOND := SE4->E4_OBSNOTA
					ElseIf AllTrim(Upper(SE1->E1_CARTEIR))=="CH"
						SE1->E1_OBSCOND := "RECEBER CHEQUE"
					EndIf
				EndIf
			EndIf
			//Final  - Trecho adicionado por Adriano Leonardo em 22/04/2014 - para gravar a observa��o da condi��o de pagamento no t�tulo a receber
		EndIf
		//Final  - Trecho do IF adicionado por Adriano Leonardo em 08/08/2014 para tratar o caso dos pedidos de funcion�rios
		// Incluido por J�lio Soares em 27/05/2013 conforme solicita��o ID-352 para que a informa��o do 
		// pedido de vendas que informa se o vendedor � respons�vel pelos t�tulos no financeiro.
		SE1->E1_VENDRES := SC5->C5_VENDRES	// - Incluido por J�lio Soares em 28/05/2013 conforme solicita��o ID-382 para
											// que todos os t�tulos sejam gerados a partir de notas n�o atualizem o fluxo 
				 							// de caixa no financeiro.
		SE1->E1_FLUXO 	:= IIF(SubStr(FunName(),1,4)=="FINA","S","N")
		//SE1->E1_NATUREZ := SuperGetMv("MV_NATPADR" ,,"101010") //Linha adicionada por Adriano Leonardo em 13/01/2014 para adicionar nova funcionalidade � rotina //Comentada em 20/05/2014 para grava��o da natureza com base no cadastro (cliente/fornecedor)
	/* Trecho para habilitar o tratamento do vencimento devido ao feriado do carnaval. 
		If DDATABASE ==  CtoD("23/02/2017")  .or. DDATABASE ==  CtoD("24/02/2017")     
			SE1->E1_VENCREA  := DataValida(SE1->E1_VENCTO + 7, .T.)
			SE1->E1_VENCTO :=  SE1->E1_VENCTO + 7
		EndIf
	*/
	SE1->(MSUNLOCK())
	RestArea(_aSavSZIF )
	RestArea(_aSavSUAF )
	RestArea(_aSavSUBF )
	RestArea(_aSavSL4F )
	RestArea(_aSavSE4F )
	RestArea(_aSavSE1F )
	RestArea(_aSavSA1F )
	RestArea(_aSavSC5F )
	RestArea(_aSavSC6F )
	RestArea(_aSavSC9F )
	RestArea(_aSavSF2F )
	RestArea(_aSavSD2F )
	RestArea(_aSavSF1F )
	RestArea(_aSavSD1F )
	RestArea(_aSavAreaF)
return
