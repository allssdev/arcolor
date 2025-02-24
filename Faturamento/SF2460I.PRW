#include "totvs.ch"
#DEFINE _lEnt CHR(13) + CHR(10)
/*/{Protheus.doc} SF2460I
//TODO Ponto de entrada localizado após a atualização das tabelas referentes à nota fiscal (SF2/SD2), mas antes da contabilização.
ATENÇÃO: Este ponto de entrada está dentro da transação na gravação das tabelas do documento.
@description Ponto de entrada localizado para atualização da forma de pagamento e preenchimento dos campos E1_PORTADO, E1_AGEDEP e E1_CONTA, conforme regra definida na tabela SZ3.
@author Thiago S. de Almeida
@since 18/12/2012
@version 1.0
@history 27/05/2013, Júlio Soares, E1_FLUXO - Incluido tratamento para que os titulos sejam gerados com o campo E1_FLUXO com o conteúdo "NÃO" e o mesmo somente se rá atualizado após a impressão da Danfe e/ou romaneio.
@history   /  /    , Júlio Soares, C5_SALDO - Trecho inserido para validar o saldo do pedido no momento da geração da nota a fim de atulizar o campo C5_SALDO.
@history   /  /    , Júlio Soares, UA_STATSC9 - Trecho inserido para atualizar o campo UA_STATSC9 a fim de atualizar o status da legenda.
@history 21/08/2013, Júlio Soares, CDL - Trecho responsável pelo preenchimento automático da tabela CDL (Complementos de exportação).
@history 07/10/2013, Adriano Leonardo, Mudanças não documentadas.
@history 26/11/2013, Júlio Soares, SC9 - Trecho incluido para realizar a gravação da data de emissão da nota na tabela SC9(Itens liberados) a fim de utilizar essa data na montagem de cargas para dinamizar tempo de processamento.
@history 16/12/2013, Júlio Soares, SD2 - Inserido a gravação dos campos D2_DTEMIS2 e D2_NOMCLI para a apresentação dos mesmos na tela dos documentos de retorno via tecla de atalho F7, uma vez que o campo padrão é fixo para alteração de ordem.
@history 20/01/2014, Júlio Soares, SD2 - D2_TPOPER - Inserido a gravação do campo D2_TPOPER para gravar nos tens do documento o tipo de operação do pedido.
@history 28/01/2014, Júlio Soares, SUA - UA_LOGSTAT - Inserido a gravação do log de status do processo.
@history 12/02/2014, Júlio Soares, SC7 - 
@history 09/05/2014, Adriano Leonardo, SA7 - Inserido trecho para ajustar saldo previsto e qtd entregue.
@history 10/04/2018, Arthur Silva, Trecho adicionado Temporariamente por Arthur Silva, para criação do título de ST no contas a pagar. Devido o Processo padrão não estar funcionando.
@history 16/12/2020, Anderson Coelho, Trecho de chamada da rotina "RFINA006" de criação customizada do título de ST no contas a pagar (devido o Processo padrão não estar funcionando), desativado e ExecBlock descontinuado pois, após a migração para o release 12.1.25, o problema padrão foi resolvido, sendo atestado pela Srta. Dayana Martins.
@history 23/12/2020, Anderson Coelho, Retomado o trecho de chamada da rotina "RFINA006" de criação customizada do título de ST no contas a pagar, uma vez que a Srta. Dayana reportou problemas após descontinuarmos o programa (chamado http://allss.ddns.net:8086/front/ticket.form.php?id=2910).
@type function
@see https://allss.com.br
/*/
user function SF2460I()
	local _aSavArea    := GetArea()
	local _aSavSUA     := SUA->(GetArea())
	local _aSavSC5     := SC5->(GetArea())
	local _aSavSC6     := SC6->(GetArea())
	local _aSavSC9     := SC9->(GetArea())
	local _aSavSF2     := SF2->(GetArea())
	local _aSavSD2     := SD2->(GetArea())
	local _aSavSL4     := SL4->(GetArea())
	local _aSavSA1     := SA1->(GetArea())
	local _aSavSA2     := SA2->(GetArea())
	local _aSavSE1     := SE1->(GetArea())
	local _cRotina     := 'SF2460I'
	local _cLogx       := ""
	local _cTRATMP     := GetNextAlias()
	local _cTRCTMP     := GetNextAlias()
	local _cFilCDL     := FWFilial("CDL")
	local _cFilSA1     := FWFilial("SA1")
	local _cFilSA2     := FWFilial("SA2")
	local _cFilSA7     := FWFilial("SA7")
	local _cFilSC5     := FWFilial("SC5")
	local _cFilSC6     := FWFilial("SC6")
	local _cFilSC9     := FWFilial("SC9")
	local _cFilSD2     := FWFilial("SD2")
	local _cFilSE1     := FWFilial("SE1")
	local _cFilSE4     := FWFilial("SE4")
	local _cFilSUA     := FWFilial("SUA")

	private _cNumPed   := "" //Linha adicionada por Adriano Leonardo em 07/10/2013 para tratamento adicional da carteira no título
	private _cLog      := "" // Linha incluida por Júlio Soares em 28/01/2014 para implementar log de documento emitido
	private _lRFINE032 := ExistBlock("RFINE032")
	private _lOPVENDA  := SuperGetMV("MV_OPVENDA",,"01")
	private _lAUTORSA7 := SuperGetMV("MV_AUTORSA7",,"S")
	
	dbSelectArea("SE1")
	SE1->(dbSetOrder(2))	//FILIAL+CLIENTE+LOJA+PREFIXO+TITULO
	SE1->(dbGoTop())
	//If SE1->(MsSeek(_cFilSE1 + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL,.T.,.F.))
	If SE1->(dbSeek(_cFilSE1 + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL))
		While !SE1->(EOF()) .AND. SE1->E1_FILIAL == _cFilSE1.AND. SF2->F2_CLIENTE == SE1->E1_CLIENTE .AND. ;
				SF2->F2_LOJA == SE1->E1_LOJA .AND. SF2->F2_PREFIXO == SE1->E1_PREFIXO .AND. SF2->F2_DUPL == SE1->E1_NUM
			If _lRFINE032
				U_RFINE032()
			EndIf
			SE1->(dbSetOrder(2))			//FILIAL+CLIENTE+LOJA+PREFIXO+TITULO
			SE1->(dbSkip())
		EndDo
	EndIf
	// Trecho adicionado Temporariamente por Arthur Silva, para criação do título de ST no contas a pagar. Devido o Processo padrão não estar funcionando.
	If ExistBlock("RFINA006")
		U_RFINA006()
	EndIf
	// Fim do trecho adicionado Temporariamente por Arthur Silva, para criação do título de ST no contas a pagar. Devido o Processo padrão não estar funcionando.
	if Select(_cTRATMP) > 0
		(_cTRATMP)->(dbCloseArea())
	endif
	BeginSql Alias _cTRATMP
		%noparser%
		SELECT DISTINCT C6_NUM 
		FROM %table:SD2% D2 (NOLOCK) 
			INNER JOIN %table:SC6% C6 (NOLOCK) ON C6_FILIAL     = %xFilial:SC6%
									 AND C6_BLQ       <> 'R'
									 AND C6_NUM        = D2_PEDIDO
									 AND C6_QTDVEN     > C6_QTDENT
									 AND C6.%NotDel%
		WHERE D2_FILIAL      = %xFilial:SD2%
		  AND D2_DOC         = %Exp:SF2->F2_DOC%
		  AND D2_SERIE       = %Exp:SF2->F2_SERIE%
		  AND D2.%NotDel%
		ORDER BY C6_NUM
	EndSql
	dbSelectArea(_cTRATMP)
	(_cTRATMP)->(dbGoTop())
	If !Empty((_cTRATMP)->C6_NUM) // - Se o resultado da Query não for "Branco" o pedido é faturamento parcial
		_cLogx := "PEDIDO FATURADO PARCIALMENTE PELO DOC. -> " + ALLTRIM(SF2->F2_DOC) + " / " + ALLTRIM(SF2->F2_SERIE) + "."
		dbSelectArea("SUA")
		SUA->(dbOrderNickName("UA_NUMSC5"))		//FILIAL+PEDIDO
		If SUA->(MsSeek(_cFilSUA + (_cTRATMP)->C6_NUM,.T.,.F.))
			// Trecho alterado por Júlio Soares em 18/10/2013 para tratar a alteração da legenda em casos de faturamento parcial.
			If SUA->UA_STATSC9 <> "06" // - "06" = FATURADO PARCIAL
				while !RecLock("SUA",.F.) ; enddo
					SUA->UA_STATSC9 := "06"
					If SUA->(FieldPos("UA_LOGSTAT"))>0
						_cLog           := Alltrim(SUA->UA_LOGSTAT)
						SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt  + DTOC(Date()) + " - " + Time() + " - " +;
											UsrRetName(__cUserId) + _lEnt  + _cLogx
					EndIf
				SUA->(MsUnLock())
			EndIf
		Else
			MSGALERT('Não foi possível encontrar o atendimento vinculado ao pedido ' + Alltrim((_cTRATMP)->C6_NUM) + '!',_cRotina+'_001')
		EndIf
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		If SC5->(MsSeek(_cFilSC5 + (_cTRATMP)->C6_NUM,.T.,.F.))
			If Empty(SC5->C5_SALDO)
				_cLog := Alltrim(SC5->C5_LOGSTAT)
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_SALDO := "S"
					If SC5->(FieldPos("C5_LOGSTAT"))>0
						_cLog           := SC5->C5_LOGSTAT
						SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt  + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) +;
						 					_lEnt  + _cLogx
					EndIf
					// - Linha inserida em 17/02/2016 por Júlio Soares para evitar falha no Schema por falta de placa do veículo
					SC5->C5_VEICULO := ""
				SC5->(MSUNLOCK())
			Else
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_VEICULO := ""
				SC5->(MSUNLOCK())
			EndIf		
		Else
			MSGALERT('Não foi possível encontrar o pedido ' + Alltrim((_cTRATMP)->C6_NUM) + '!',_cRotina+'_002')
		EndIf
	ElseIf Empty((_cTRATMP)->C6_NUM) // - Alterado por Júlio Soares em 09/01/2014 para ajustar o status da legenda.
		_cLogx := "PEDIDO FATURADO TOTALMENTE PELO DOC. -> " + ALLTRIM(SF2->F2_DOC) + " / " + ALLTRIM(SF2->F2_SERIE) + "."
		_cNPed := SC6->C6_NUM
		dbSelectArea("SUA")
		SUA->(dbOrderNickName("UA_NUMSC5"))		//FILIAL+PEDIDO
		If SUA->(MsSeek(_cFilSUA + _cNPed,.T.,.F.))
			while !RecLock("SUA",.F.) ; enddo
				SUA->UA_STATSC9 := "07"
				If SUA->(FieldPos("UA_LOGSTAT"))>0
					_cLog := Alltrim(SUA->UA_LOGSTAT)
					SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt  + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) +;
										_lEnt  + _cLogx
				EndIf
			SUA->(MsUnLock())
		Else
			MSGALERT('Não foi possível encontrar o atendimento do Call Center.  Informe o Administrador do sistema',_cRotina+'_003')
		EndIf
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))		//FILIAL+PEDIDO
		If SC5->(MsSeek(_cFilSC5 + _cNPed,.T.,.F.))
			while !RecLock("SC5",.F.) ; enddo
				SC5->C5_SALDO := "E" //Limpa o campo que contém o Saldo para alterar legenda no padrão. E= EMITIDO
				If SC5->(FieldPos("C5_LOGSTAT"))>0
					_cLog := Alltrim(SC5->C5_LOGSTAT)
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt  + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) +;
										_lEnt  + _cLogx
				EndIf
				// - Linha inserida em 17/02/2016 por Júlio Soares para evitar falha no Schema por falta de placa do veículo
				SC5->C5_VEICULO := ""
			SC5->(MSUNLOCK())
		Else
			MSGALERT('Não foi possível encontrar o pedido: ' + Alltrim((_cTRATMP)->C6_NUM) + ' Informe o Administrador do sistema!',_cRotina+'_004')
		EndIf
	EndIf
	if Select(_cTRATMP) > 0
		(_cTRATMP)->(dbCloseArea())
	endif
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	If ExistBlock("RFATL001")
		U_RFATL001(	SC5->C5_NUM,;
					SUA->UA_NUM,;
					_cLogx     ,;
					_cRotina    )
	EndIf
	// FIM do trecho incluido para validar os saldos do pedido a fim de alterar o status para legenda
	//Inicio do trecho incluído por Júlio Soares responsável pelo preenchimento automático da tabela CDL (Complementos de exportação) quando
	// se tratar de faturamento para cliente do tipo exportação.
	_cNumSer := SF2->F2_SERIE
	_cNumdoc := SF2->F2_DOC
	_dDataem := Date()
	_cCli    := SF2->F2_CLIENTE
	_cLoja   := SF2->F2_LOJA
	_cSpecie := SF2->F2_ESPECIE
	If SC5->(FieldPos("C5_UFEMB")) > 0
		_cUFEmb  := SC5->C5_UFEMB
	Else
		_cUFEmb  := ""
	EndIf
	If SC5->(FieldPos("C5_LOCEMB")) > 0
		_cLocEmb := SC5->C5_LOCEMB
	Else
		_cLocEmb := ""
	EndIf
	If AllTrim(SF2->F2_EST) == 'EX' .AND. AllTrim(SF2->F2_TIPO) == 'N'
		dbSelectArea("SD2")
		SD2->(dbOrderNickName("D2_DOC"))	//FILIAL+NF+SERIE+CLIENTE+LOJA
		If SD2->(MsSeek(_cFilSD2 + _cNumDoc + _cNumSer + _cCli + _cLoja,.T.,.F.))
			While !SD2->(EOF()) .AND. SD2->D2_FILIAL == _cFilSD2 .AND. SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == (_cNumDoc + _cNumSer + _cCli + _cLoja)
				dbSelectArea("CDL")
				CDL->(dbSetOrder(2))		//FILIAL+NF+SERIE+CLIENTE+LOJA+ITEM
				If !CDL->(MsSeek(_cFilCDL + SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_ITEM),.T.,.F.))
					_cItem := SD2->D2_ITEM
					_cProd := SD2->D2_COD
					while !RecLock("CDL",.T.) ; enddo
						CDL->CDL_FILIAL := _cFilSD2
						CDL->CDL_DOC    := _cNumdoc
						CDL->CDL_SERIE  := _cNumSer
						CDL->CDL_ESPEC  := _cSpecie
						CDL->CDL_CLIENT := _cCli
						CDL->CDL_LOJA   := _cLoja
						CDL->CDL_INDDOC := '0'
						CDL->CDL_DTDE   := _dDataem
						CDL->CDL_DTREG  := _dDataem
						CDL->CDL_DTCHC  := _dDataem
						CDL->CDL_DTAVB  := _dDataem
						CDL->CDL_PAIS   := '105'
						CDL->CDL_EMIEXP := _dDataem
						CDL->CDL_QTDEXP := 0
						CDL->CDL_UFEMB  := _cUFEmb
						CDL->CDL_LOCEMB := _cLocEmb
						CDL->CDL_ITEMNF := _cItem
						CDL->CDL_PRODNF := _cProd
					CDL->(MSUNLOCK())
				EndIf
				dbSelectArea("SD2")
				SD2->(dbOrderNickName("D2_DOC"))			//FILIAL+NF+SERIE+CLIENTE+LOJA
				SD2->(dbSkip())
			EndDo
		EndIf
	EndIf
	// - Fim do trecho incluido para o preenchimento automático da tabela CDL
	RestArea(_aSavSA1)
	RestArea(_aSavSA2)
	RestArea(_aSavSUA)
	RestArea(_aSavSC6)
	RestArea(_aSavSC5)
	RestArea(_aSavSD2)                            		
	RestArea(_aSavSF2)
	RestArea(_aSavSL4)
	RestArea(_aSavSE1)
	RestArea(_aSavSC9)
	RestArea(_aSavArea)
	//Trecho utilizado para o calculo do Peso Bruto no documento de saida, baseado num fator multiplicador sobre o volume informado.
	_nFatorVol := SuperGetMv("MV_FATPBRU",,1.00) // - Alterado em 30/06/2014 por Júlio Soares
	dbSelectArea("SD2")
	SD2->(dbSetOrder(3))		//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->(MsSeek(_cFilSD2 + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA,.T.,.F.))
		_cNumPed := SD2->D2_PEDIDO
	Else
		_cNumPed := ""
	EndIf
	RestArea(_aSavSF2)
	while !RecLock("SF2",.F.) ; enddo
		//Condicional adicionado por Adriano Leonardo em 27/06/2013
		//Caso o peso tenha sido informado no pedido, não haverá nenhuma alteração, ou seja, será respeitado o pedido de vendas
		If _nFatorVol > 0 .AND. SF2->F2_PBRUTO == 0 .AND. (SC5->C5_PESOL==0 .Or. SC5->C5_PBRUTO==0)
			SF2->F2_PBRUTO	:= SF2->F2_PLIQUI + (SF2->F2_VOLUME1 * _nFatorVol) + (SF2->F2_VOLUME2 * _nFatorVol) + (SF2->F2_VOLUME3 * _nFatorVol) + (SF2->F2_VOLUME4 * _nFatorVol)
		EndIf
		//Condicional adicionado por Adriano Leonardo em 02/07/2013
		//Caso a espécie tenha sido informada no pedido de vendas, esta será respeitada
		If !Empty(SC5->C5_ESPECI1) .AND. SC5->C5_PESOL>0 .AND. SC5->C5_PBRUTO>0 .AND. SC5->C5_VOLUME1>0
			SF2->F2_ESPECI1	:= SC5->C5_ESPECI1
		EndIf
		// - Incluido por Júlio Soares em 27/05/2013 conforme solicitação do ID 357 para que o numero do pedido do cliente 
		//seja enviado para a SF2.
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))		//FILIAL+PEDIDO
		If SC5->(MsSeek(_cFilSC5 + _cNumPed,.T.,.F.))
			//_cPedCli2 := SC5->(C5_PEDCLI2)
			SF2->F2_PEDCLI2 := SC5->C5_PEDCLI2
			SF2->F2_TPCLASS := SC5->C5_TPDIV
			// - Trecho provisória inserida em 05/01/16 por Júlio Soares para inserir o volume do pedido na nota fiscal.
			// - corrige erro onde não estava sendo impresso a etiqueta de volumes pois o campo era gravado com '0'.
			SF2->F2_VOLUME1 := SC5->C5_VOLUME1
			SF2->F2_ESPECI1 := "VOLUME(S)"
			// - Fim
		EndIf
		//Fim do trecho incluído para gravação da data de emissão da nota na tabela SC9
		// - Trecho inserido em 23/12/15 por Júlio Soares para a gravação da descrição da condição de pagamento na tabela SF2
		If SF2->(FieldPos("F2_CONDESC"))<>0
			dbSelectArea("SE4")
			SE4->(dbSetOrder(1)) // FILIAL + CÓDIGO
			_aSE4 := SE4->(GetArea())
			If SE4->(MsSeek(_cFilSE4+SF2->F2_COND,.T.,.F.))
				SF2->F2_CONDESC := SE4->E4_DESCRI
			EndIf
			RestArea(_aSE4)
		EndIf
		// - Trecho inserido em 17/02/2016 por Júlio Soares para evitar falha no Schema por falta de placa do veículo
		SF2->F2_VEICUL1 := ""
		SF2->F2_VEICUL2 := ""
		SF2->F2_VEICUL3 := ""
		// - Fim trecho
	SF2->(MSUNLOCK())
	// - Trecho incluido por Júlio Soares em 26/11/2013 para contemplar a gravação da data de emissão da nota na tabela 
	// SC9(Itens liberados) a fim de utilizar essa data na montagem de cargas para dinamizar tempo de processamento                                               ³
	_DtEmiss := SF2->F2_EMISSAO
	dbSelectArea("SC9")
	If SC9->(FieldPos("C9_DTEMISS"))<>0 // Faz a validação para verificar se o campo existe no banco de dados para evitar a apresentação de erros.
	//	SC9->(dbSetOrder(6)) //C9_FILIAL + C9_SERIENF + C9_NFISCAL + C9_CARGA + C9_SEQCAR
		SC9->(dbOrderNickName("C9_SERIENF")) //C9_FILIAL + C9_SERIENF + C9_NFISCAL + C9_CARGA + C9_SEQCAR
		SC9->(dbGoTop())
		If SC9->(MsSeek(_cFilSC9 + _cNumSer + _cNumDoc,.T.,.F.))
			While !SC9->(EOF()) .AND. SC9->(C9_FILIAL+C9_SERIENF+C9_NFISCAL) == (_cFilSC9+_cNumSer+_cNumDoc)
				while !RecLock("SC9",.F.) ; enddo
					SC9->C9_DTEMISS := _DtEmiss
				SC9->(MsUnLock())
				dbSelectArea("SC9")
			//	SC9->(dbSetOrder(6)) //C9_FILIAL + C9_SERIENF + C9_NFISCAL + C9_CARGA + C9_SEQCAR
				SC9->(dbOrderNickName("C9_SERIENF")) //C9_FILIAL + C9_SERIENF + C9_NFISCAL + C9_CARGA + C9_SEQCAR
				SC9->(dbSkip())
			EndDo
		Else
			MSGALERT('Não foi possível atualizar a data de emissão para o Documento/Serie '+ Alltrim(_cNumDoc+'-'+_cNumSer) + ;
					'Por favor informe o administrador do sistema',_cRotina+'_05')
		EndIf
	Else
		MSGALERT('NÃO FOI POSSIVEL GRAVAR A DATA DE EMISSÃO DO DOCUMENTO. POR FAVOR INFORME IMEDIATAMENTO O ADMINISTRADOR DO SISTEMA.',_cRotina+'_06')
	EndIf
	// Fim do trecho incluído para gravação da data de emissão da nota na tabela SC9
	dbSelectArea("SD2")
	SD2->(dbSetOrder(3))	//FILIAL+NF+SÉRIE+CLIENTE+LOJA
	If SD2->(dbSeek(_cFilSD2 + _cNumDoc + _cNumSer + _cCli + _cLoja))
		While !SD2->(EOF()) .AND. SD2->D2_FILIAL == _cFilSD2 .AND. SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == (_cNumDoc + _cNumSer + _cCli + _cLoja)
		//Falta validar os itens que estão sendo transmitidos
			_cCliFor := "" //Linha adicionada por Adriano Leonardo de Souza em 18/12/13 para melhoria na rotina
			If !(Alltrim(SF2->(F2_TIPO))) $ ("B/D")
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))		//FILIAL+CLIENTE+LOJA
				If SA1->(MsSeek(_cFilSA1+_cCli+_cLoja,.T.,.F.))
					_cClifor := SA1->A1_NOME
				EndIf
			Else
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))		//FILIAL+FORNECEDOR+LOJA
				If SA2->(MsSeek(_cFilSA2+_cCli+_cLoja,.T.,.F.))
					_cClifor := SA2->A2_NOME
				EndIf
			EndIf
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))		//FILIAL+PEDIDO
			SC5->(MsSeek(_cFilSC5 + SD2->D2_PEDIDO,.T.,.F.))
			while !RecLock("SD2",.F.) ; enddo
				SD2->D2_NOMCLI   := _cClifor
				SD2->D2_DTEMIS2  := _DtEmiss
				// - Trecho inserido por Júlio Soares em 20/01/2014 para gravar nos itens da nota o tipo de operação do pedido.
				If SD2->(FieldPos("D2_TIPOPER"))<>0 .AND. SC5->(FieldPos("C5_TPOPER"))<>0	// Avalia se o campo existe a fim de evitar erros.
					SD2->D2_TIPOPER := SC5->C5_TPOPER
					//Inicio - Trecho adicionado por Adriano Leonardo em 09/05/2014
					If AllTrim(SC5->C5_TPOPER) $ (_lOPVENDA) .AND. SD2->D2_TIPO=="N"
						_aSavSA7  := SA7->(GetArea())
						_aSavSC62 := SC6->(GetArea())
						dbSelectArea("SC6")
						SC6->(dbSetOrder(1)) //Filial + Numero + Item
						If SC6->(MsSeek(_cFilSC6+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.T.,.F.))
							_dDatFat := SD2->D2_EMISSAO
							If SC6->(FieldPos("C6_PRCTAB"))<>0 // - LINHA
								_nPrcTab := SC6->C6_PRCTAB
							Else
								_nPrcTab := 0
							EndIf
							//Verifico se o produto não possui preço de tabela
							If _nPrcTab == 0
								_nPrcTab := SC6->C6_PRCVEN
							EndIf
							_nQuanti     := SC6->C6_QTDVEN
							If SC6->(FieldPos("C6_PERCDES"))<>0 // - LINHA
								_nPDesco := SC6->C6_PERCDES
							Else
								_nPDesco := 0
							EndIf
							dbSelectArea("SA7")
							If SA7->(FieldPos("A7_AUTORIZ"))<>0 .AND. SA7->(FieldPos("A7_ULTFAT"))<>0 .And. SA7->(FieldPos("A7_PRCTAB"))<>0 .And. SA7->(FieldPos("A7_QUANT"))<>0 .And. SA7->(FieldPos("A7_DESCFAT"))<>0 .And. SA7->(FieldPos("A7_ULTPED"))<>0
								dbSelectArea("SA7")
								SA7->(dbSetOrder(1)) //Filial + Cliente + Loja + Produto
								//Verifico se já existe amarração entre produto x cliente
								If SA7->(dbSeek(_cFilSA7+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD))
									dbSelectArea("SA7")
									while !RecLock("SA7",.F.) ; enddo
								Else
									while !RecLock("SA7",.T.) ; enddo
										SA7->A7_FILIAL	:= _cFilSA7
										SA7->A7_CLIENTE	:= SD2->D2_CLIENTE
										SA7->A7_LOJA	:= SD2->D2_LOJA
										SA7->A7_PRODUTO	:= SD2->D2_COD
										SA7->A7_AUTORIZ	:= _lAUTORSA7 //Comercialização do produto autorizada?
								EndIf
									SA7->A7_ULTFAT	:= _dDatFat
									SA7->A7_PRCTAB  := _nPrcTab
									SA7->A7_QUANT	:= _nQuanti
									SA7->A7_DESCFAT := _nPDesco
									SA7->A7_ULTPED	:= SD2->D2_PEDIDO
								SA7->(MsUnLock()) 
							EndIf
						EndIf
						RestArea(_aSavSC62)
						RestArea(_aSavSA7)
					EndIf
					//Final  - Trecho adicionado por Adriano Leonardo em 09/05/2014
				EndIf
				// - Fim trecho
			SD2->(MSUNLOCK())
			dbSelectArea("SD2")
			SD2->(dbSetOrder(3))	//FILIAL+NF+SÉRIE+CLIENTE+LOJA
			SD2->(dbSkip())
		EndDo
	EndIf
	if Select(_cTRCTMP) > 0
		(_cTRCTMP)->(dbCloseArea())
	endif
	BeginSql Alias _cTRCTMP
		%noparser%
		SELECT C9_PEDIDO [PEDIDO], C9_NFISCAL [DOC], C9_SERIENF [SERIE], C9_DTEMISS [EMISSAO]
		FROM %table:SC9% SC9 (NOLOCK)
		WHERE SC9.C9_FILIAL   = %xFilial:SC9%
		  AND SC9.C9_PEDIDO   = %Exp:_cNumPed%
		  AND SC9.C9_NFISCAL <> ''
		  AND SC9.%NotDel%
		GROUP BY C9_PEDIDO,C9_NFISCAL,C9_SERIENF,C9_MARKNF,C9_DTEMISS
		ORDER BY C9_PEDIDO,C9_DTEMISS,C9_SERIENF
	EndSql
	_dData := DtoS(Date())
	dbSelectArea("SUA")
	SUA->(dbOrderNickName("UA_NUMSC5"))		//FILIAL+PEDIDO
	(_cTRCTMP)->(dbGoTop())
	If !Empty((_cTRCTMP)->PEDIDO)
		If SUA->(FieldPos("UA_DOCS"))<>0
			While !(_cTRCTMP)->(EOF())
				while !RecLock("SUA",.F.) ; enddo
					SUA->UA_DOCS := IIF(Empty(SUA->UA_DOCS),;
									DTOC(STOD((_cTRCTMP)->EMISSAO)) + " = " + Alltrim((_cTRCTMP)->SERIE) + "/" + Alltrim((_cTRCTMP)->DOC),;
									Alltrim(SUA->UA_DOCS) + " " + IIF(_dData == (_cTRCTMP)->EMISSAO,;
																			"",;
																			DTOC(STOD((_cTRCTMP)->EMISSAO))) + "" +;
									 " " + Alltrim((_cTRCTMP)->SERIE) + "/" + Alltrim((_cTRCTMP)->DOC))
				SUA->(MsUnlock())
				_dData := (_cTRCTMP)->EMISSAO
				(_cTRCTMP)->(dbSkip())
			EndDo
		Else
			MSGALERT('O campo "UA_DOCS" não existe no banco de dados. INFORME O ADMINISTRADOR DO SISTEMA!',_cRotina + '_009')
		EndIf
	EndIf
	if Select(_cTRCTMP) > 0
		(_cTRCTMP)->(dbCloseArea())
	endif
	RestArea(_aSavSA1)
	RestArea(_aSavSA2)
	RestArea(_aSavSUA)
	RestArea(_aSavSC6)
	RestArea(_aSavSC5)
	RestArea(_aSavSD2)                            		
	RestArea(_aSavSF2)
	RestArea(_aSavSL4)
	RestArea(_aSavSE1)
	RestArea(_aSavSC9)
	RestArea(_aSavArea)
return
