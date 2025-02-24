#include "totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE01NFESEFAZºAutor  ³Anderson C. P. Coelho º Data ³ 24/06/15º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para manipulacoes especificas no XML da   º±±
±±º          ³Nota Fiscal Eletronica (NFESEFAZ.PRW).                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Especifico para a empresa Arcolor (CD Control)º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function PE01NFESEFAZ()
	Local _aSavArea := GetArea()
	Local _aSavCD2  := CD2->(GetArea())
	Local _aSavCD5  := CD5->(GetArea())
	Local _aSavSA1  := SA1->(GetArea())
	Local _aSavSA2  := SA2->(GetArea())
	Local _aSavSA4  := SA4->(GetArea())
	Local _aSavSB1  := SB1->(GetArea())
	Local _aSavSC5  := SC5->(GetArea())
	Local _aSavSC6  := SC6->(GetArea())
	Local _aSavSD1  := SD1->(GetArea())
	Local _aSavSD2  := SD2->(GetArea())
	Local _aSavSF1  := SF1->(GetArea())
	Local _aSavSF2  := SF2->(GetArea())
	Local _aSavSFT  := SFT->(GetArea())
	Local _aSavSM4  := SM4->(GetArea())
	Local _aParam   := Paramixb
	Local _cRotina  := "PE01NFESEFAZ"
	Local _cMailFat := lower(AllTrim(SuperGetMV("MV_MAILFAT" ,   ,""   )))	// E-mail para o qual sera enviada a copia do XML e Danfe.
	Local _cMailDvC := lower(AllTrim(SuperGetMV("MV_MAILDVC" ,   ,""   )))	// E-mails que receberao copia da Nfe de Saida, para as 
																			// devolucoes de compras.
	Local _cMailDvF := lower(AllTrim(SuperGetMV("MV_MAILDVF" ,   ,""   )))	// E-mails que receberao copia da Nfe de Entrada, p/ as 
																			// devolucoes de vendas.
	Local _cOPTroca := lower(AllTrim(SuperGetMV("MV_OPERTROC",.F.,"6"  )))	// Informa os tipos de operacao de troca para inserir mensagem 
																			// padrao no documento de saida.
	Local _cForm    := lower(AllTrim(SuperGetMV("MV_FORMDEV" ,.F.,"013")))	// Informa a formula padrao para mensagens a serem apresentadas 
																			// nas mensagens adicionais da nota fiscal de trocas.
	Local _cCodPrd  := ""
	Local _cDescri  := ""
	Local _x        := 0
	/*///////////////////////////////////////////////////////////////////
	//ATUAL ESTRUTURA DOS ARRAYS QUE ESTÃO SENDO UTILIZADOS NA ROTINA: //
	/////////////////////////////////////////////////////////////////////
	aNota:
	------
	aadd(aNota,SF2->F2_SERIE)
	aadd(aNota,IIf(len(SF2->F2_DOC)==6,"000","")+SF2->F2_DOC)
	aadd(aNota,SF2->F2_EMISSAO)
	aadd(aNota,cTipo)
	aadd(aNota,SF2->F2_TIPO)
	aadd(aNota,Iif(lNfCup,cHoraNota,SF2->F2_HORA))
	
	aDest:
	------
	aadd(aDest,AllTrim(SA1->A1_CGC))
	aadd(aDest,SA1->A1_NOME)
	aadd(aDest,MyGetEnd(SA1->A1_END,"SA1")[1])
	aadd(aDest,MyGetEnd(SA1->A1_END,"SA1")[3])
	aadd(aDest,IIF(SA1->(FieldPos("A1_COMPLEM")) > 0 .And. !empty(SA1->A1_COMPLEM),SA1->A1_COMPLEM,MyGetEnd(SA1->A1_END,"SA1")[4]))
	aadd(aDest,SA1->A1_BAIRRO)
	aadd(aDest,SA1->A1_COD_MUN)
	aadd(aDest,SA1->A1_MUN)
	aadd(aDest,Upper(SA1->A1_EST))
	aadd(aDest,SA1->A1_CEP)
	aadd(aDest,IIF(empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
	aadd(aDest,IIF(empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
	aadd(aDest,SA1->A1_DDD+SA1->A1_TEL)
	aadd(aDest,VldIE(SA1->A1_INSCR))
	aadd(aDest,SA1->A1_SUFRAMA)
	aadd(aDest,SA1->A1_EMAIL)
	aAdd(aDest,SA1->A1_CONTRIB) // Posição 17
	aadd(aDest,Iif(SA1->(FieldPos("A1_IENCONT")) > 0 ,SA1->A1_IENCONT,""))
	aadd(aDest,SA1->A1_INSCRM)
	aadd(aDest,SA1->A1_TIPO)
	aadd(aDest,SA1->A1_PFISICA)//21-Identificação estrangeiro
	
	-----------------------------------------------------------------------------
	-OBS.: O array aInfoItem acompanha as inserções no array aProd - VIDE ABAIXO-
	-----------------------------------------------------------------------------
	aInfoItem:
	----------
	aAdd(aInfoItem,{(cAliasSD2)->D2_PEDIDO,(cAliasSD2)->D2_ITEMPV,(cAliasSD2)->D2_TES,(cAliasSD2)->D2_ITEM})
	
	aProd:
	------
	aadd(aProd,	{len(aProd)+1,;
		cCodProd,;
		IIf(Val(SB1->B1_CODBAR)==0,"",StrZero(Val(SB1->B1_CODBAR),len(Alltrim(SB1->B1_CODBAR)),0)),;
		cDescProd,;
		SB1->B1_POSIPI,;//Retirada validação do parametro MV_CAPPROD, de acordo com a NT2014/004 não é mais possível informar o capítulo do NCM
		SB1->B1_EX_NCM,;
		cD2Cfop,;
		SB1->B1_UM,;
		(cAliasSD2)->D2_QUANT,;
		IIF(!(cAliasSD2)->D2_TIPO$"IP",(cAliasSD2)->D2_TOTAL+nDesconto+(cAliasSD2)->D2_DESCZFR,IIF(((cAliasSD2)->D2_TIPO=="I" .And. SF4->F4_AJUSTE == "S" .And. SubStr(SM0->M0_CODMUN,1,2) == "31") .Or. ((cAliasSD2)->D2_TIPO=="I" .And. SF4->F4_AJUSTE == "S" .And. "RESSARCIMENTO" $ Upper(cNatOper) .And. "RESSARCIMENTO" $ Upper(cDescProd)),(cAliasSD2)->D2_TOTAL,0)),;
		IIF(empty(SB5->B5_UMDIPI),SB1->B1_UM,SB5->B5_UMDIPI),;
		IIF(empty(SB5->B5_CONVDIP),(cAliasSD2)->D2_QUANT,SB5->B5_CONVDIP*(cAliasSD2)->D2_QUANT),;
		(cAliasSD2)->D2_VALFRE,;
		(cAliasSD2)->D2_SEGURO,;
		(nDesconto+nDescIcm+nDescRed),;
		RetPrvUnit(cAliasSD2,nDesconto),;
		IIF(SB1->(FieldPos("B1_CODSIMP"))<>0,SB1->B1_CODSIMP,""),; //codigo ANP do combustivel
		IIF(SB1->(FieldPos("B1_CODIF"))<>0,SB1->B1_CODIF,""),; //CODIF
		(cAliasSD2)->D2_LOTECTL,;//Controle de Lote
		(cAliasSD2)->D2_NUMLOTE,;//Numero do Lote
	   	IIF(((cAliasSD2)->D2_TIPO == "D" .And. !lIpiDev) .Or. lConsig .Or. (Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM ) .or. ((cAliasSD2)->D2_TIPO == "B" .and. lIpiBenef) .or. ((cAliasSD2)->D2_TIPO=="P" .And. lComplDev .And. !lIpiDev) ,(cAliasSD2)->D2_DESPESA + (cAliasSD2)->D2_VALPS3 + (cAliasSD2)->D2_VALCF3 + (cAliasSD2)->D2_VALIPI + nIcmsST, (cAliasSD2)->D2_DESPESA + (cAliasSD2)->D2_VALPS3 + (cAliasSD2)->D2_VALCF3 + nIcmsST),;//Outras despesas + PISST + COFINSST  (Inclusão do valor de PIS ST e COFINS ST na tag vOutros - NT 2011/004).E devolução com IPI. (Nota de compl.Ipi de uma devolução de compra(MV_IPIDEV=F) leva o IPI em voutros)
		nRedBC,;//% Redução da Base de Cálculo
		cCST,;//Cód. Situação Tributária
		IIF((SF4->F4_AGREG='N' .And. !AllTrim(SF4->F4_CF) $ cMVCfopTran) .Or. (SF4->F4_ISS='S' .And. SF4->F4_ICM='N'),"0","1"),;// Tipo de agregação de valor ao total do documento
		cInfAdic,;//Informacoes adicionais do produto(B5_DESCNFE)
		nDescZF,;
		(cAliasSD2)->D2_TES,;
		IIF(SB5->(FieldPos("B5_PROTCON"))<>0,SB5->B5_PROTCON,""),; //Campo criado para informar protocolo ou convenio ICMS 
		IIf(SubStr(SM0->M0_CODMUN,1,2) == "35" .And. cTpPessoa == "EP" .And. nDescIcm > 0, nDescIcm,0),;   
		IIF((cAliasSD2)->(FieldPos("D2_TOTIMP"))<>0,(cAliasSD2)->D2_TOTIMP,0),;   //aProd[30] - Total imposto carga tributária. 
		(cAliasSD2)->D2_DESCZFP,;			//aProd[31] - Desconto Zona Franca PIS
		(cAliasSD2)->D2_DESCZFC,;			//aProd[32] - Desconto Zona Franca CONFINS
		(cAliasSD2)->D2_PICM,;		//aProd[33] - Percentual de ICMS
		IIF(SB1->(FieldPos("B1_TRIBMUN"))<>0,RetFldProd(SB1->B1_COD,"B1_TRIBMUN"),""),;  //aProd[34]
		IIF((cAliasSD2)->(FieldPos("D2_TOTFED"))<>0,(cAliasSD2)->D2_TOTFED,0),;   //aProd[35] - Total carga tributária Federal
		IIF((cAliasSD2)->(FieldPos("D2_TOTEST"))<>0,(cAliasSD2)->D2_TOTEST,0),;   //aProd[36] - Total carga tributária Estadual
		IIF((cAliasSD2)->(FieldPos("D2_TOTMUN"))<>0,(cAliasSD2)->D2_TOTMUN,0),;   //aProd[37] - Total carga tributária Municipal
		})
	*/
	///////////////////////////////
	//Estrutura do array aParam: //
	///////////////////////////////
	//_aParam[01] - aProd
	//_aParam[02] - cMensCli
	//_aParam[03] - cMensFis
	//_aParam[04] - aDest
	//_aParam[05] - aNota
	//_aParam[06] - aInfoItem
	//_aParam[07] - aDupl
	//_aParam[08] - aTransp
	//_aParam[09] - aEntrega
	//_aParam[10] - aRetirada
	//_aParam[11] - aVeiculo
	//_aParam[12] - aReboque
	//_aParam[13] - aNfVincRur
	//_aParam[14] - aEspVol
	//_aParam[15] - aNfVinc
	//_aParam[16] - aDetPag
	//_aParam[17] - aObsCont
	//_aParam[18] - aProcRef
	//_aParam[19] - cClieFor
	//_aParam[20] - cLoja
	/////////////////////////////// 
	if len(_aParam) == 20
		if AllTrim(FunName()) <> "SPEDCTE" .AND. AllTrim(FunName()) <> "SPEDNFSE"
			if len(_aParam[05]) >= 4 .AND. valtype(_aParam[05][04])=="C"
				if valtype("_aParam[06]")<>"U" .AND. AllTrim(_aParam[05][04]) == "1" //NF Saida
					//INICIO CUSTOM. ALL - DATA: 17/01/2013 - AUTOR: ANDERSON C. P. COELHO - TRATAMENTO ESPECIFICO PARA O CODIGO ESPELHO
						for _x := 1 to len(_aParam[06])
							dbSelectArea("SC5")
							SC5->(dbSetOrder(1))
							if SC5->(MsSeek(xFilial("SC5") + _aParam[06][_x][01],.T.,.F.))
								dbSelectArea("SF2")
								SF2->(dbSetOrder(1))		//F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_TIPO
								if SF2->(MsSeek(xFilial("SF2") + Padr(_aParam[05][02],len(SF2->F2_DOC)) + Padr(_aParam[05][01],len(SF2->F2_SERIE)) + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
									//INICIO CUSTOM. ALL - DATA: 05/12/2013 - AUTOR: Júlio Soares - Trecho incluido para implementar a apresentação do usuário que transmitiu o documento.
										if empty(SF2->F2_USRSND)
											RecLock("SF2",.F.)
												SF2->F2_USRSND := UsrRetName(__cUserId)
											SF2->(MSUNLOCK())
										endif
									//FIM - CUSTOM. ALL - DATA: 05/12/2013 - AUTOR: Júlio Soares - Trecho incluido para implementar a apresentação do usuário que transmitiu o documento.
									//INICIO CUSTOM. ALL - DATA: 09/04/2013 - AUTOR: ANDERSON C. P. COELHO - INSERIDO O BAIRRO DA TRANSPORTADORA
										dbSelectArea("SA4")
										SA4->(dbSetOrder(1))		//A4_FILIAL + A4_COD
										if !empty(SF2->F2_TRANSP) .AND. SA4->(MsSeek(xFilial("SA4") + SF2->F2_TRANSP,.T.,.F.))
											_aParam[08][04] := AllTrim(SA4->A4_END)+IIF(!empty(SA4->A4_BAIRRO)," - "+AllTrim(SA4->A4_BAIRRO),"")+IIF(!empty(SA4->A4_CEP)," - "+AllTrim(SA4->A4_CEP),"")
										endif
									//FIM CUSTOM. ALL - DATA: 09/04/2013 - AUTOR: ANDERSON C. P. COELHO - INSERIDO O BAIRRO DA TRANSPORTADORA
									//INICIO CUSTOM. ALL - DATA: 19/07/2018 - INÍCIO - AUTOR: ANDERSON C. P. COELHO - ENVIO DO E-MAIL TAMBÉM AOS VENDEDORES/REPRESENTANTES
										dbSelectArea("SA3")
										SA3->(dbSetOrder(1))
										if !empty(SF2->F2_VEND1) .AND. SA3->(MsSeek	(xFilial("SA3") + SF2->F2_VEND1,.T.,.F.)) .AND. !empty(SA3->A3_EMAIL) .AND. !lower(alltrim(SA3->A3_EMAIL))$ lower(AllTrim(_aParam[04][16]))
											_aParam[04][16] := lower(AllTrim(_aParam[04][16])+";"+IIF(!empty(_aParam[04][16]).AND.!empty(SA3->A3_EMAIL),"",";")+AllTrim(SA3->A3_EMAIL))
										endif
									//FIM CUSTOM. ALL - DATA: 19/07/2018 - INÍCIO - AUTOR: ANDERSON C. P. COELHO - ENVIO DO E-MAIL TAMBÉM AOS VENDEDORES/REPRESENTANTES
									dbSelectArea("SC6")
									SC6->(dbSetOrder(1))		//C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
									if SC6->(MsSeek(xFilial("SC6") + Padr(_aParam[06][_x][01],len(SC6->C6_NUM)) + Padr(_aParam[06][_x][02],len(SC6->C6_ITEM)),.T.,.F.))
										//INICIO CUSTOM. ALL - DATA: 30/09/2013 - AUTOR: Júlio Soares - Trecho inserido para que na mensagens adicionais da nota fiscal seja apresentada a mensagem referente a fórmula para notas do tipo de operação igual a 6 (TROCA)
											if AllTrim(SC5->C5_TPDIV) <> '0' .AND. AllTrim(SC5->C5_TPOPER)$_cOPTroca
												dbSelectArea("SM4")
												SM4->(dbSetOrder(1))		//M4_FILIAL + M4_CODIGO
												if SM4->(MsSeek(xFilial("SM4") + Padr(_cForm,len(SM4->M4_CODIGO)),.T.,.F.))
													//if !AllTrim(&(SM4->M4_FORMULA)$AllTrim(_aParam[02]))	//Linha adicionada por Adriano Leonardo em 09/01/2014 para correção da rotina
													if !AllTrim(&(SM4->M4_FORMULA))$AllTrim(_aParam[02])
														if len(_aParam[02]) > 0 .AND. SubStr(_aParam[02], len(_aParam[02]), 1) <> " "
															_aParam[02] += " - " + &(SM4->M4_FORMULA)
														//Início - Trecho adicionado por Adriano Leonardo em 09/01/2014 para correção da rotina
														else 
															_aParam[02] := &(SM4->M4_FORMULA)
														//Fim - Trecho adicionado por Adriano Leonardo em 09/01/2014 para correção da rotina
														endif
													endif //Linha adicionada por Adriano Leonardo em 09/01/2014 para correção da rotina
												endif
											endif
										//FIM CUSTOM. ALL - DATA: 30/09/2013 - AUTOR: Júlio Soares - Trecho inserido para que na mensagens adicionais da nota fiscal seja apresentada a mensagem referente a fórmula para notas do tipo de operação igual a 6 (TROCA)
										//INICIO CUSTOM. ALL - DATA: 28/05/2013 - AUTOR: Júlio Soares - Alterado para trazer o numero do pedido do cliente na SC5, se o mesmo estiver em branco não traz nada.
											//INICIO CUSTOM. ALL - DATA: 17/01/2013 - AUTOR: ANDERSON C. P. COELHO
											if !AllTrim("Nosso Pedido: " + SC5->C5_NUM) $ AllTrim(_aParam[02])
													if len(_aParam[02]) > 0 .AND. SubStr(_aParam[02], len(_aParam[02]), 1) <> " "
														_aParam[02] += " "
													endif
													_aParam[02] += "Nosso Pedido: " + SC5->C5_NUM
												endif
												if "TMK"!=SubStr(SC6->C6_PEDCLI,1,3)
													if !AllTrim("Seu Pedido: " + SC6->C6_PEDCLI) $ AllTrim(_aParam[02])
														if len(_aParam[02]) > 0 .And. SubStr(_aParam[02], len(_aParam[02]), 1) <> " "
															_aParam[02] += " "
														endif
														_aParam[02] += "Seu Pedido: " + SC6->C6_PEDCLI
													endif
												else
													if !AllTrim("AT: " + SC6->C6_PEDCLI) $ AllTrim(_aParam[02])
														if len(_aParam[02]) > 0 .And. SubStr(_aParam[02], len(_aParam[02]), 1) <> " "
															_aParam[02] += " "
														endif
														_aParam[02] += "AT: " + SC6->C6_PEDCLI
													endif
												endif
												if !empty(SF2->F2_PEDCLI2)  //Não tras a mensagem pra nota se o campo customizado estiver em branco.
													if !AllTrim("Seu Pedido: " + SF2->F2_PEDCLI2) $ AllTrim(_aParam[02])
														if len(_aParam[02]) > 0 .And. SubStr(_aParam[02], len(_aParam[02]), 1) <> " "
															_aParam[02] += " "
														endif
														_aParam[02] += "Seu Pedido: " + SF2->F2_PEDCLI2
													endif
												endif
											//FIM CUSTOM. ALL - DATA: 17/01/2013 - AUTOR: ANDERSON C. P. COELHO
										//FIM CUSTOM. ALL - DATA: 28/05/2013 - AUTOR: Júlio Soares - Alterado para trazer o numero do pedido do cliente na SC5, se o mesmo estiver em branco não traz nada.
										_cCodPrd  := ""
										_cDescri  := ""
										_cCod_E   := ""
										if SC6->C6_TPCALC == "V" .AND. SC5->C5_TPDIV <> "5" .AND. SC5->C5_TPDIV <> "0" .AND. SC5->C5_TPDIV <> "4"
											dbSelectArea("SB1")
											SB1->(dbSetOrder(1))
											if !empty(SC6->C6_COD_E) .AND. SB1->(MsSeek(xFilial("SB1") + Padr(SC6->C6_COD_E,TamSx3("B1_COD")[01]),.T.,.F.))
												_cCodPrd  := SB1->B1_COD
												_cDescri  := SB1->B1_DESC
											elseif SB1->(MsSeek(xFilial("SB1") + Padr(SC6->C6_PRODUTO,TamSx3("B1_COD")[01]),.T.,.F.)) .AND. !empty(SB1->B1_COD_E)
												_cCod_E   := Padr(SB1->B1_COD_E,TamSx3("B1_COD")[01])
												if SB1->(MsSeek(xFilial("SB1") + _cCod_E,.T.,.F.))
													_cCodPrd  := SB1->B1_COD
													_cDescri  := SB1->B1_DESC
												endif
											endif
										endif
										if !empty(_cCodPrd)		//Casos de Produto Espelho, conforme lógica acima
											_aParam[01][_x][02] := _cCodPrd
											_aParam[01][_x][04] := _cDescri
											//O trecho abaixo é utilizado para o tratamento do código espelho nos Livros Fiscais
											dbSelectArea("SD2")
											SD2->(dbSetOrder(3))	//D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
											if SD2->(MsSeek(xFilial("SD2")                             + ;
														Padr(_aParam[05][02]    ,len(SD2->D2_DOC    )) + ;
														Padr(_aParam[05][01]    ,len(SD2->D2_SERIE  )) + ;
														Padr(SC5->C5_CLIENTE    ,len(SD2->D2_CLIENTE)) + ;
														Padr(SC5->C5_LOJACLI    ,len(SD2->D2_LOJA   )) + ;
														Padr(SC6->C6_PRODUTO    ,len(SD2->D2_COD    )) + ;
														Padr(_aParam[06][_x][04],len(SD2->D2_ITEM   )) ) )
												dbSelectArea("SFT")
												SFT->(dbSetOrder(1))
												if SFT->(MsSeek(xFilial("SFT")+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+PadR(SD2->D2_ITEM,TamSx3("FT_ITEM")[1])+SD2->D2_COD))
													while !RecLock("SFT",.F.) ; enddo
														SFT->FT_ORGPRD  := SD2->D2_COD
														SFT->FT_PRODUTO := _cCodPrd
													SFT->(MSUNLOCK())
												endif
												dbSelectArea("CD2")
												CD2->(dbSetOrder(1))
												if CD2->(MsSeek(xFilial("CD2")+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+PadR(SD2->D2_ITEM,TamSx3("CD2_ITEM")[01]),.T.,.F.))
													while !CD2->(EOF()) .AND. xFilial("CD2") == CD2->CD2_FILIAL .AND.;
																"S" == CD2->CD2_TPMOV .AND.;
																SD2->D2_SERIE == CD2->CD2_SERIE .AND.;
																SD2->D2_DOC == CD2->CD2_DOC .AND.;
																SD2->D2_CLIENTE == IIF(!SD2->D2_TIPO $ "DB",CD2->CD2_CODCLI,CD2->CD2_CODFOR) .AND.;
																SD2->D2_LOJA == IIF(!SD2->D2_TIPO $ "DB",CD2->CD2_LOJCLI,CD2->CD2_LOJFOR) .AND.;
																SD2->D2_ITEM == SubStr(CD2->CD2_ITEM,1,len(SD2->D2_ITEM))
														while !RecLock("CD2",.F.) ; enddo
												    		CD2->CD2_ORGPRD := SD2->D2_COD
												    		CD2->CD2_CODPRO := _cCodPrd
														CD2->(MSUNLOCK())
														dbSelectArea("CD2")
														CD2->(dbSetOrder(1))
														CD2->(dbSkip())
													enddo
												endif
											endif
										else
											//INICIO CUSTOM. ALL - DATA: 09/04/2015 - AUTOR: Anderson C. P. Coelho - Alterada a forma de buscar a descrição do produto, conforme solicitação do Sr. Marco Antonio. Se a Descrição específica do produto estiver preenchida, esta será impressa na Nota Fiscal, independente de a descrição do item estar preenchida ou não no pedido de vendas.
												_cDescri := IIF(!empty(SB1->B1_ESPECIF),SB1->B1_ESPECIF,IIF(empty(SC6->C6_DESCRI),SB1->B1_DESC,SC6->C6_DESCRI))
											/*//FIM CUSTOM. ALL - DATA: 09/04/2015 - AUTOR: Anderson C. P. Coelho - Alterada a forma de buscar a descrição do produto, conforme solicitação do Sr. Marco Antonio. Se a Descrição específica do produto estiver preenchida, esta será impressa na Nota Fiscal, independente de a descrição do item estar preenchida ou não no pedido de vendas.
											//INICIO CUSTOM. ALL - DATA: 01/10/2014 - AUTOR: Anderson C. P. Coelho - ALTERADO PARA IMPRESSÃO DA DESCRIÇÃO DO COD/NOME DO PRODUTO NA DANFE MESMO QUANDO NÃO É CONTROLADO O PODER DE TERCEIROS.
									         	if !AllTrim(SC5->C5_TIPO) $ "/B/D/"
											         SA7->(dbSetOrder(1)) 	         //--A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_PRODUTO
											         if SA7->(MsSeek(xFilial("SA7")+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD,.T.,.F.)) .AND. !empty(SA7->A7_CODCLI) .AND. !empty(SA7->A7_DESCCLI) 
											         	if SA7->(FieldPos("A7_CODCLI")) > 0
											         		_cCodPrd := SA7->A7_CODCLI
											         	endif
											         	if SA7->(FieldPos("A7_DESCCLI")) > 0
											         		_cDescri := SA7->A7_DESCCLI
											         	endif
											         endif
												else
											         SA5->(dbSetOrder(1)) 	         //--A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO
											         if SA5->(MsSeek(xFilial("SA5")+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD,.T.,.F.)) .AND. !empty(SA5->A5_CODPRF) .AND. !empty(SA5->A5_DESREF )
											         	if SA5->(FieldPos("A5_CODPRF")) > 0
											         		_cCodPrd := SA5->A5_CODPRF
											         	endif
											         	if SA5->(FieldPos("A5_NUMPFR")) > 0
											         		_cDescri := SA5->A5_NUMPFR		//SA5->A5_DESREF
											         	endif
											         endif
										      	endif*/
												if !empty(_cCodPrd)
													_aParam[01][_x][02] := _cCodPrd
												endif
												if !empty(_cDescri)
													_aParam[01][_x][04] := _cDescri
												endif
											//FIM CUSTOM. ALL - DATA: 01/10/2014 - AUTOR: Anderson C. P. Coelho - ALTERADO PARA IMPRESSÃO DA DESCRIÇÃO DO COD/NOME DO PRODUTO NA DANFE MESMO QUANDO NÃO É CONTROLADO O PODER DE TERCEIROS.
										endif
									endif
								endif
							endif
						next
					//FIM - CUSTOM. ALL - DATA: 17/01/2013 - AUTOR: ANDERSON C. P. COELHO - TRATAMENTO ESPECIFICO PARA O CODIGO ESPELHO
					//INICIO CUSTOM. ALL - DATA: 01/11/2013 - AUTOR: ADRIANO LEONARDO DE SOUZA - INSERIDOS OS E-MAILS CONTIDOS NO PARÂMETRO MV_MAILFAT ou MV_MAILDVC (conforme o caso), DE QUEM RECEBERÁ CÓPIA DO ARQUIVO XML E DANFE
						if !AllTrim(_aParam[05][05]) $ "/D/B/" //Outras NFs de Saída
							if !empty(_cMailFat) .AND. !lower(AllTrim(StrTran(_cMailFat,";",""))) $ lower(AllTrim(_aParam[04][16]))
								_aParam[04][16] := lower(AllTrim(_aParam[04][16])+IIF(!empty(_aParam[04][16]).AND.!empty(_cMailFat),";","")+AllTrim(_cMailFat))	//IIF(!empty(_cMailFat),";"+AllTrim(_cMailFat),"")
							endif
						else //Devolução de Compras
							if !empty(_cMailDvC) .AND. !lower(AllTrim(StrTran(_cMailDvC,";",""))) $ lower(AllTrim(_aParam[04][16]))
								_aParam[04][16] := lower(AllTrim(_aParam[04][16])+IIF(!empty(_aParam[04][16]).AND.!empty(_cMailDvC),";","")+AllTrim(_cMailDvC))    //IIF(!empty(_cMailDvC),";"+AllTrim(_cMailDvC),"")
							endif
						endif
					//FIM - CUSTOM. ALL - DATA: 01/11/2013 - AUTOR: ADRIANO LEONARDO DE SOUZA - INSERIDOS OS E-MAILS CONTIDOS NO PARÂMETRO MV_MAILFAT ou MV_MAILDVC (conforme o caso), DE QUEM RECEBERÁ CÓPIA DO ARQUIVO XML E DANFE
				else				//NF Entrada
					//INICIO CUSTOM. ALL - DATA: 01/11/2013 - AUTOR: ADRIANO LEONARDO DE SOUZA - INSERIDOS OS E-MAILS CONTIDOS NO PARÂMETRO MV_MAILFAT ou MV_MAILDVC (conforme o caso), DE QUEM RECEBERÁ CÓPIA DO ARQUIVO XML E DANFE
						if AllTrim(_aParam[05][05]) $ "/D/B/"		//Devolução de Vendas
							if !empty(_cMailDvF) .AND. !AllTrim(StrTran(_cMailDvF,";",""))$AllTrim(_aParam[04][16])
								_aParam[04][16] := AllTrim(_aParam[04][16])+IIF(!empty(_aParam[04][16]).AND.!empty(_cMailDvF),";","")+AllTrim(_cMailDvF)	//IIF(!empty(_cMailDvF),";"+AllTrim(_cMailDvF),"")
							endif
						else									//Outras NFs de Entrada
							if !empty(_cMailFat) .AND. !AllTrim(StrTran(_cMailFat,";",""))$AllTrim(_aParam[04][16])
								_aParam[04][16] := AllTrim(_aParam[04][16])+IIF(!empty(_aParam[04][16]).AND.!empty(_cMailFat),";","")+AllTrim(_cMailFat)	//IIF(!empty(_cMailFat),";"+AllTrim(_cMailFat),"")
							endif
						endif
					//FIM - CUSTOM. ALL - DATA: 01/11/2013 - AUTOR: ADRIANO LEONARDO DE SOUZA - INSERIDOS OS E-MAILS CONTIDOS NO PARÂMETRO MV_MAILFAT ou MV_MAILDVC (conforme o caso), DE QUEM RECEBERÁ CÓPIA DO ARQUIVO XML E DANFE
					//INICIO CUSTOM. ALL - DATA: 30/12/2014 - INÍCIO - AUTOR: ANDERSON C. P. COELHO - Quando o campo F1_HORA não possuir conteúdo, será utilizado o horário da transmissão
						if empty(_aParam[05][06])
							_aParam[05][06] := Time()
						endif
					//FIM CUSTOM. ALL - DATA: 30/12/2014 - INÍCIO - AUTOR: ANDERSON C. P. COELHO - Quando o campo F1_HORA não possuir conteúdo, será utilizado o horário da transmissão
					dbSelectArea("SF1")
					SF1->(dbSetOrder(1))		//F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
					if SF1->(MsSeek(xFilial("SF1") + _aParam[05][02] + _aParam[05][01] + _aParam[19] + _aParam[20] + AllTrim(_aParam[05][05]),.T.,.F.))
						//INICIO CUSTOM. ALL - DATA: 05/12/2013 - AUTOR: Júlio Soares - Trecho incluido para implementar a apresentação do usuário que transmitiu o documento.
							if empty(SF1->F1_USRSND)
								RecLock("SF1",.F.)
									SF1->F1_USRSND := UsrRetName(__cUserId)
								SF1->(MSUNLOCK())
							endif
						//FIM - CUSTOM. ALL - DATA: 05/12/2013 - AUTOR: Júlio Soares - Trecho incluido para implementar a apresentação do usuário que transmitiu o documento.
						//INICIO CUSTOM. ALL - DATA: 09/04/2013 - AUTOR: ANDERSON C. P. COELHO - INSERIDO O BAIRRO DA TRANSPORTADORA
							dbSelectArea("SA4")
							SA4->(dbSetOrder(1))		//A4_FILIAL + A4_COD
							if !empty(SF1->F1_TRANSP) .AND. SA4->(MsSeek(xFilial("SA4") + SF1->F1_TRANSP,.T.,.F.))
								_aParam[08][04] := AllTrim(SA4->A4_END)+IIF(!empty(SA4->A4_BAIRRO)," - "+AllTrim(SA4->A4_BAIRRO),"")+IIF(!empty(SA4->A4_CEP)," - "+AllTrim(SA4->A4_CEP),"")
							endif
						//FIM CUSTOM. ALL - DATA: 09/04/2013 - AUTOR: ANDERSON C. P. COELHO - INSERIDO O BAIRRO DA TRANSPORTADORA
					endif
				endif
			endif
		endif
	else
		MsgAlert("ATENÇÃO! PROBLEMAS ENCONTRADOS. VEJA A SEGUIR OS MOTIVOS!!!",_cRotina+"_001")
		MsgStop("ATENÇÃO! Problemas com o ajuste das informações na NF-e. Contate o administrador e passe a seguinte mensagem: verifique o array 'aParam' no fonte NFESEFAZ.PRW!",_cRotina+"_002")
	endif
	RestArea(_aSavSA1 )
	RestArea(_aSavSA2 )
	RestArea(_aSavSA4 )
	RestArea(_aSavCD2 )
	RestArea(_aSavCD5 )
	RestArea(_aSavSB1 )
	RestArea(_aSavSC5 )
	RestArea(_aSavSC6 )
	RestArea(_aSavSD1 )
	RestArea(_aSavSD2 )
	RestArea(_aSavSF1 )
	RestArea(_aSavSF2 )
	RestArea(_aSavSFT )
	RestArea(_aSavSM4 )
	RestArea(_aSavArea)
return _aParam