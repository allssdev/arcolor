#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} TMKVFIM
Ponto de Entrada para gravar informações específicas na SC6, e SC5, executado apos a gravacao do atendimento e do pedido de vendas, conforme o caso (CD Control).
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 17/12/2012
@version 1.0
@history 11/03/2014, Adriano Leonardo, Nesta rotina foi inclusa a sugestão do desconto no atendimento, com base nas regras de negócios seguindo prioridades específicas da empresa.
@type function
@see https://allss.com.br
@history 09/02/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Tratativa para preenchimento do campo C6_NUMPCOM nos itens do pedido de venda de forma automatizada.
@history 19/04/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Tratativa para orçamentos/pedidos que contenham mais de 99 itens tenham o campo C6_ITEMPC ajustado para sequencia numérica correta.
/*/
user function TMKVFIM(_cAtend, _cPed)
	Local   _aSavArea  := GetArea()
	Local   _aSavSUA   := SUA->(GetArea())
	Local   _aSavSA1   := SA1->(GetArea())
	Local   _aSavSUS   := SUS->(GetArea())
	Local   _aSavSU5   := SU5->(GetArea())
	Local   _aSavSUB   := SUB->(GetArea())
	Local   _aSavSC5   := SC5->(GetArea())
	Local   _aSavSC6   := SC6->(GetArea())   
	Local   _aSavSF4   := SF4->(GetArea())
	Local   _aSavSB1   := SB1->(GetArea())
	Local   _aSavSA4   := SA4->(GetArea())
	Local   _aSavSA3   := SA3->(GetArea())
	Local   _aSavSZ6   := SZ6->(GetArea())
	Local   _lRet      := .T.
	Local   _lAtvReod  := SuperGetMv("AR_ATVREOP",,.T.)			//.T. - Ativa a reordenacao dos itens do pedido de vendas pelo codigo do produto.	/ .F. - Desativa a reordenacao dos itens do pedido de vendas pelo codigo do produto.
	Local   _lAREVERSO := SUA->(FieldPos("UA_REVERSO"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lACOPY    := SUA->(FieldPos("UA_COPY"   ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lAOBS     := SUA->(FieldPos("UA_OBS"    ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5OBS     := SC5->(FieldPos("C5_OBS"    ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lACODOBS  := SUA->(FieldPos("UA_CODOBS" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
//	Local   _l5CODOBS  := SC5->(FieldPos("C5_CODOBS" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lAOBSSEP  := SUA->(FieldPos("UA_OBSSEP" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5OBSSEP  := SC5->(FieldPos("C5_OBSSEP" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lAOBSPLAN := SUA->(FieldPos("UA_OBSPLAN"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5OBSPLAN := SC5->(FieldPos("C5_OBSPLAN"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lAOBSBLQ  := SUA->(FieldPos("UA_OBSBLQ" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5OBSBLQ  := SC5->(FieldPos("C5_OBSBLQ" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lAMENNOTA := SUA->(FieldPos("UA_MENOTA" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lAPEDCLI2 := SUA->(FieldPos("UA_PEDCLI2"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5PEDCLI2 := SC5->(FieldPos("C5_PEDCLI2"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lADTCONFR := SUA->(FieldPos("UA_DTCONFR"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5DTCONFR := SC5->(FieldPos("C5_DTCONFR"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lAHRCONFR := SUA->(FieldPos("UA_HRCONFR"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5HRCONFR := SC5->(FieldPos("C5_HRCONFR"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lAUSRCONF := SUA->(FieldPos("UA_USRCONF"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5USRCONF := SC5->(FieldPos("C5_USRCONF"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5NOMCLI  := SC5->(FieldPos("C5_NOMCLI" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5DESCOND := SC5->(FieldPos("C5_DESCOND"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lATPOPER  := SUA->(FieldPos("UA_TPOPER" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5TPOPER  := SC5->(FieldPos("C5_TPOPER" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lATPDIV   := SUA->(FieldPos("UA_TPDIV"  ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5TPDIV   := SC5->(FieldPos("C5_TPDIV"  ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1TPDIV   := SA1->(FieldPos("A1_TPDIV"  ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l4TESALTQ := SF4->(FieldPos("F4_TESALTQ"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1CGCCENT := SA1->(FieldPos("A1_CGCCENT"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5CGCCENT := SC5->(FieldPos("C5_CGCCENT"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1PRIOR   := SA1->(FieldPos("A1_PRIOR"  ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5NPRIORI := SC5->(FieldPos("C5_NPRIORI"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5ISENIPI := SC5->(FieldPos("C5_ISENIPI"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1ISENIPI := SA1->(FieldPos("A1_ISENIPI"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5ISENICM := SC5->(FieldPos("C5_ISENICM"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1ISENICM := SA1->(FieldPos("A1_ISENICM"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5ISNPCOF := SC5->(FieldPos("C5_ISNPCOF"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1PISCOFI := SA1->(FieldPos("A1_PISCOFI"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5ISENMVA := SC5->(FieldPos("C5_ISENMVA"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1HBLTMVA := SA1->(FieldPos("A1_HBLTMVA"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5INSCRES := SC5->(FieldPos("C5_INSCRES"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1INSCR   := SA1->(FieldPos("A1_INSCR"  ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5VLDSUFR := SC5->(FieldPos("C5_VLDSUFR"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1VLSUFR  := SA1->(FieldPos("A1_VLSUFR" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1VLDSINT := SA1->(FieldPos("A1_VLDSINT"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5EST     := SC5->(FieldPos("C5_EST"    ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5SUFRAMA := SC5->(FieldPos("C5_SUFRAMA"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1SUFRAMA := SA1->(FieldPos("A1_SUFRAMA"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5REDUCAO := SC5->(FieldPos("C5_REDUCAO"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1BASTRI  := SA1->(FieldPos("A1_BASTRI" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l5DTRANSP := SC5->(FieldPos("C5_DTRANSP"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l6ITEMOLD := SC6->(FieldPos("C6_ITEMOLD"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l6TPPROD  := SC6->(FieldPos("C6_TPPROD" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l6COD_E   := SC6->(FieldPos("C6_COD_E"  ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1COD_E   := SB1->(FieldPos("B1_COD_E"  ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l6TPCALC  := SC6->(FieldPos("C6_TPCALC" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l1TPCALC  := SB1->(FieldPos("B1_TPCALC" ))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l6DESCTV1 := SC6->(FieldPos("C6_DESCTV1"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l6DESCTV2 := SC6->(FieldPos("C6_DESCTV2"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l6DESCTV3 := SC6->(FieldPos("C6_DESCTV3"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l6DESCTV4 := SC6->(FieldPos("C6_DESCTV4"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _lBITEMOLD := SUB->(FieldPos("UB_ITEMOLD"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	Local   _l6EMISSAO := SC6->(FieldPos("C6_EMISSAO"))<>0		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o campo existe (várias vezes).
	//INICIO - CUSTOM. ALLSS - 09/02/2022 - Rodrigo Telecio - tratativa para preenchimento do campo C6_NUMPCOM nos itens do pedido de venda de forma automatizada.
	local   _lNumPCom  := SC6->(FieldPos("C6_NUMPCOM")) <> 0 
	local   _lNItPCom  := SC6->(FieldPos("C6_ITEMPC")) <> 0 
	//FIM - CUSTOM. ALLSS - 09/02/2022 - Rodrigo Telecio - tratativa para preenchimento do campo C6_NUMPCOM nos itens do pedido de venda de forma automatizada.
	Local   _nContIt   := 0
	Local   _nTamItC6  := TamSx3("C6_ITEM")[01]					//IIF(AllTrim(GetRPORelease()) < "12.1.023", TamSx3("C6_ITEM")[01], 02)
	Local   _MVMAXSUA  := SuperGetMV("MV_MAXSUA",,10000000)-(SUA->(Recno()))	//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema não tenha de ficar consultando o conteúdo do parâmetro.
	Local   _MVDTFIXAT := SuperGetMv("MV_DTFIXAT",,MsDate())					//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Variável declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema não tenha de ficar consultando o conteúdo do parâmetro.
	Local   _cTabSUB   := RetSqlName("SUB")
	Local   _cFilSUB   := FWFilial("SUB")
	Local   _cTabSC6   := RetSqlName("SC6")
	Local   _cFilSC6   := FWFilial("SC6")
	Local   _cAliasSX3 := "SX3_"+GetNextAlias()
	Local   _cFilSX3   := (_cAliasSX3) + "->" + "X3_ARQUIVO" + " == " + "'SC6'"	//Filtro para a tabela SX3
	Local   _cUpd      := ""
	Private _cRotina   := "TMKVFIM"
	Private _cPar1     := _cAtend
	Private _cPar2     := _cPed
	Private _aCab      := {}
	Private _aItens    := {}
	Private _aItPV     := {}
	//Variáveis auxiliares para armazenar os percentuais de comissões
	Private _nComis1   := 0
	Private _nComis2   := 0
	Private _nComis3   := 0
	Private _nComis4   := 0
	Private _nComis5   := 0
	Private _cLog      := ""
	Private _lEnt      := CHR(13) + CHR(10)
	default _cPed      := SUA->UA_NUMSC5
	default _cAtend    := SUA->UA_NUM
	//Início - Trecho adicionado por Adriano Leonardo em 20/05/2014
	dbSelectArea("SUA")
	while !RecLock("SUA",.F.) ; enddo
		If _lAREVERSO
			SUA->UA_REVERSO := _MVMAXSUA				//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SUA->UA_REVERSO := SuperGetMV("MV_MAXSUA",,10000000)-(SUA->(Recno()))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Trecho utilizado para alterar o campo UA_COPY que indica se o atendimento foi gerado através de uma cópia.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _lACOPY .AND. !Empty(SUA->UA_COPY)
			SUA->UA_COPY  := ""
		EndIf
	SUA->(MsUnLock())
	//Final -  Trecho adicionado por Adriano Leonardo em 20/05/2014
	If AllTrim(SUA->UA_OPER) == "1"
		dbSelectArea("SA4")
		SA4->(dbSetOrder(1))
		SA4->(MsSeek(xFilial("SA4")+SUA->UA_TRANSP,.T.,.F.))
		_lProc     := .F.
		//30.07.2013 - ANDERSON COELHO - INICIO DO TRECHO DE REORDENACAO DOS ITENS DO PEDIDO POR CODIGO DE PRODUTO
		If _lAtvReod .AND. !AllTrim(SUA->UA_STATUS)$'LIB/NF./CAN' .AND. Empty(SUA->UA_DOC+SUA->UA_SERIE)
			_cUpd := ""
			If _lBITEMOLD
				_cUpd  := " UPDATE " + _cTabSUB
				_cUpd  += " SET UB_ITEMOLD   = UB_ITEM "
				_cUpd  += "	WHERE UB_FILIAL  = '"  + _cFilSUB + "' "
				_cUpd  += "	  AND UB_NUM     = '"  + _cPed          + "' "
			EndIf
			If _lBITEMOLD .AND. TCSQLExec(_cUpd)<0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_001")
			Else
				dbSelectArea("SUB")
				TcRefresh(_cTabSUB)
				//SUB->(dbGoBottom())
				//SUB->(dbGoTop())
				_cUpd  := " UPDATE " + _cTabSC6
				_cUpd  += " SET "
				If _l6ITEMOLD			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance.
					_cUpd  += " C6_ITEMOLD   = C6_ITEM "
				EndIf
				If _l6TPPROD			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC6->(FieldPos("C6_TPPROD"))>0
					If _l6ITEMOLD
						_cUpd  += " , "
					EndIf
					_cUpd  += " C6_TPPROD = '1' "
				EndIf
				_cUpd  += "	WHERE C6_FILIAL  = '"  + _cFilSC6 + "' "
				_cUpd  += "	  AND C6_NUM     = '"  + _cPed          + "' "
				If TCSQLExec(_cUpd)<0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_002")
				ElseIf _l6ITEMOLD
					dbSelectArea("SC6")
					TcRefresh(_cTabSC6)
					//SC6->(dbGoBottom())
					//SC6->(dbGoTop())
					_cUpd  := " UPDATE " + _cTabSC6
					_cUpd  += " SET C6_ITEM    = (CASE  "
					_cUpd  += " 							WHEN LEN(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100))) > " + cValToChar(_nTamItC6) + " "			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: _cUpd  += " 							WHEN LEN(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100))) > " + cValToChar(TamSx3("C6_ITEM")[01]) + " "
					_cUpd  += " 								THEN (CASE "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '10' "
					_cUpd  += " 												THEN 'A'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '11' "
					_cUpd  += " 												THEN 'B'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '12' "
					_cUpd  += " 												THEN 'C'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '13' "
					_cUpd  += " 												THEN 'D'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '14' "
					_cUpd  += " 												THEN 'E'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '15' "
					_cUpd  += " 												THEN 'F'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '16' "
					_cUpd  += " 												THEN 'G'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '17' "
					_cUpd  += " 												THEN 'H'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '18' "
					_cUpd  += " 												THEN 'I'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '19' "
					_cUpd  += " 												THEN 'J'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '20' "
					_cUpd  += " 												THEN 'K'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '21' "
					_cUpd  += " 												THEN 'L'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '22' "
					_cUpd  += " 												THEN 'M'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '23' "
					_cUpd  += " 												THEN 'N'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '24' "
					_cUpd  += " 												THEN 'O'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '25' "
					_cUpd  += " 												THEN 'P'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '26' "
					_cUpd  += " 												THEN 'Q'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '27' "
					_cUpd  += " 												THEN 'R'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '28' "
					_cUpd  += " 												THEN 'S'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '29' "
					_cUpd  += " 												THEN 'T'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '30' "
					_cUpd  += " 												THEN 'U'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '31' "
					_cUpd  += " 												THEN 'V'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '32' "
					_cUpd  += " 												THEN 'W'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '33' "
					_cUpd  += " 												THEN 'X'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '34' "
					_cUpd  += " 												THEN 'Y'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 											WHEN SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),1,2) = '35' "
					_cUpd  += " 												THEN 'Z'+SUBSTRING(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100)),3,999) "
					_cUpd  += " 									  END) "
					_cUpd  += " 							ELSE (REPLICATE('0'," + cValToChar(_nTamItC6) + "-LEN(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100))))+CAST(XXX.C6_ITEMNEW AS NVARCHAR(100))) "					//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: _cUpd  += " 							ELSE (REPLICATE('0'," + cValToChar(TamSx3("C6_ITEM")[01]) + "-LEN(CAST(XXX.C6_ITEMNEW AS NVARCHAR(100))))+CAST(XXX.C6_ITEMNEW AS NVARCHAR(100))) "
					_cUpd  += " 					END) "
					_cUpd  += " FROM " + _cTabSc6 + " SC6X, "
					_cUpd  += "		(	SELECT SC6.R_E_C_N_O_ RECSC6, "
					_cUpd  += "			       (RANK() OVER (PARTITION BY SC6.C6_NUM ORDER BY SC6.C6_NUM, SC6.C6_DESCRI, SC6.C6_PRODUTO)) C6_ITEMNEW "
					_cUpd  += "			FROM " + _cTabSc6 + " SC6 "
					_cUpd  += "			WHERE SC6.C6_FILIAL  = '"  + _cFilSC6 + "' "
					_cUpd  += "			  AND SC6.C6_NUM     = '"  + _cPed          + "' "
					_cUpd  += "			  AND SC6.D_E_L_E_T_ = '' "
					_cUpd  += "		 ) XXX "
					_cUpd  += " WHERE SC6X.R_E_C_N_O_ = XXX.RECSC6 "
					If TCSQLExec(_cUpd)<0
						MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_003")
					Else
						_lProc := .T.
					EndIf
				EndIf
			EndIf
			dbSelectArea("SC6")
			TcRefresh(_cTabSC6)
	//		SC6->(dbGoBottom())
	//		SC6->(dbGoTop())
	//		RestArea(_aSavSC6)
			SC6->(dbSeek(_cFilSC6+_cPar2))
			dbSelectArea("SUB")
			TcRefresh(_cTabSUB)
	//		SUB->(dbGoBottom())
	//		SUB->(dbGoTop())
			SUB->(dbSeek(_cFilSUB+_cPar1))
			If _lProc
				_cUpd  := " UPDATE " + RetSqlName("SUB")
				_cUpd  += " SET UB_ITEMPV = SC6.C6_ITEM, "
				_cUpd  += "     UB_ITEM   = SC6.C6_ITEM  "
				_cUpd  += " FROM " + RetSqlName("SUB") + " SUB "
				_cUpd  += "     INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.C6_FILIAL  = '" + _cFilSC6 + "' "
				_cUpd  += "                                             AND SUB.UB_NUMPV   = SC6.C6_NUM "
				_cUpd  += "                                             AND SUB.UB_PRODUTO = SC6.C6_PRODUTO "
				If _l6ITEMOLD
					_cUpd  += "                                             AND SUB.UB_ITEMPV  = SC6.C6_ITEMOLD "
				Else
					_cUpd  += "                                             AND SUB.UB_ITEMPV  = SC6.C6_ITEM "
				EndIf
				_cUpd  += "                                             AND SC6.D_E_L_E_T_ = '' "
				_cUpd  += " WHERE SUB.UB_FILIAL  = '" + _cFilSUB + "' "
				_cUpd  += "   AND SUB.UB_NUMPV   = '" + _cPed + "' "
				_cUpd  += "   AND SUB.D_E_L_E_T_ = '' "
				If TCSQLExec(_cUpd)<0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_004")
				EndIf
			EndIf
		EndIf
		dbSelectArea("SUB")
		TcRefresh(_cTabSUB)
		//SUB->(dbGoBottom())
		//SUB->(dbGoTop())
		SUB->(dbSeek(_cFilSUB+_cPar1))
		//30.07.2013 - ANDERSON COELHO - FIM DO TRECHO DE REORDENACAO DOS ITENS DO PEDIDO POR CODIGO DE PRODUTO
		// - Trecho inserido em 19/12/2013 por Júlio Soares para realizar um Update nos descontos do atendimento para o pedido.
			If _l6DESCTV1 .AND. _l6DESCTV2 .AND. _l6DESCTV3 .AND. _l6DESCTV4
				_cUpd01  := " UPDATE " + RetSqlName("SC6")
				_cUpd01  += " SET C6_DESCTV1 = UB_DESCTV1, C6_DESCTV2 = UB_DESCTV2, C6_DESCTV3 = UB_DESCTV3, C6_DESCTV4 = UB_DESCTV4 "
				_cUpd01  += " FROM " +RetSqlName("SUB")+ " SUB "
				_cUpd01  += " 	INNER JOIN " + RetSqlName("SUA") + " SUA ON SUA.UA_FILIAL  = '"+xFilial("SUA")+"' "
				If Empty(_cPed)
					_cUpd01  += "                                       AND UA_NUMSC5     <> '' "
				EndIf
				_cUpd01  += "                                           AND UA_NUMSC5      = '" + _cPed + "' "
				_cUpd01  += "                                           AND SUA.UA_NUM     = SUB.UB_NUM "
				_cUpd01  += "                                           AND SUA.D_E_L_E_T_ = '' "
				_cUpd01  += " 	INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.C6_FILIAL  = '" + _cFilSC6 + "' "
				_cUpd01  += "                                           AND (SC6.C6_QTDENT+SC6.C6_QTDEMP) = 0 "
				_cUpd01  += "                                           AND SC6.C6_NUM     = SUA.UA_NUMSC5 "
				_cUpd01  += "                                           AND SC6.C6_PRODUTO = SUB.UB_PRODUTO "
				_cUpd01  += "                                           AND SC6.C6_ITEM    = SUB.UB_ITEM "
				_cUpd01  += "                                           AND SC6.D_E_L_E_T_ = '' "
				_cUpd01  += " WHERE SUB.D_E_L_E_T_ = '' "
				If TCSQLExec(_cUpd01)<0
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_005")
				EndIf
				TcRefresh(_cTabSC6)
			EndIf
		// - Fim do trecho inserido para atualizar os descontos dos itens.
		If !SUB->(EOF())
			_aCab    := {}
			_aItPV   := {}
			_nContIt := 0
			nP99	 := 0
			While !SUB->(EOF()) .AND. SUB->UB_FILIAL == _cFilSUB .AND. SUB->UB_NUM == _cAtend
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				If SB1->(MsSeek(xFilial("SB1") + SUB->UB_PRODUTO,.T.,.F.))
					dbSelectArea("SC6")
					SC6->(dbSetOrder(1))
					If SC6->(dbSeek(_cFilSC6 + SUB->UB_NUMPV + SUB->UB_ITEMPV))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Início do trecho de tratamento das regras de comissões        ³
						//³>>>>>> As comissões foram anteriormente zeradas na tabela SC5!³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						_nComis1 := 0
						_nComis2 := 0
						_nComis3 := 0
						_nComis4 := 0
						_nComis5 := 0
						_nNomCli := ""
						if _lATPDIV
							_cTpDiv  := SUA->UA_TPDIV
						else
							_cTpDiv  := "5"
						endif
						dbSelectArea("SF4")
						SF4->(dbSetOrder(1))
						SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES,.T.,.F.))
						dbSelectArea("SC5")
						SC5->(dbSetOrder(1))
						If SC5->(dbSeek(xFilial("SC5") + SUB->UB_NUMPV))
							//Tratamento de informações específicas para cliente.
							If !AllTrim(SC5->C5_TIPO) $ "D/B"
								dbSelectArea("SA1")
								SA1->(dbSetOrder(1))
								If SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
									_nComis1 := SA1->A1_COMIS
									_nComis2 := SA1->A1_COMIS
									_nComis3 := SA1->A1_COMIS
									_nComis4 := SA1->A1_COMIS
									_nComis5 := SA1->A1_COMIS
									_nNomCli := SA1->A1_NOME
									If Empty(_cTpDiv)
										If !_l1TPDIV .OR. Empty(SA1->A1_TPDIV)
											_cTpDiv  := "5"		//100
										Else
											_cTpDiv  := SA1->A1_TPDIV
										EndIf
									EndIf
									If _nContIt == 0
										_nContIt++
										_cPriori := IIF(_l5NPRIORI .AND. !EMPTY(SC5->C5_NPRIORI),SC5->C5_NPRIORI,IIF(_l1PRIOR .AND. !EMPTY(SA1->A1_PRIOR),SA1->A1_PRIOR,'9')) //Linha adicionada por Adriano Leonardo em 18/02/2014 para correção da rotina
										_aCab    :=  {	{"C5_NUM" 		,SC5->C5_NUM                                        ,Nil} ,;
														{"C5_NPRIORI"	,_cPriori                                           ,Nil} ,; //Linha adicionada por Adriano Leonardo em 18/02/2014 para correção da rotina
														{"C5_REDESP"	,SUA->UA_REDESP                                     ,Nil} ,;
														{"C5_TPFRETE"	,SUA->UA_TPFRETE                                    ,Nil} ,;
														{"C5_DTRANSP"	,SA4->A4_NOME                                       ,Nil} ,;
														{"C5_PEDCLI2"	,IIF(_lAPEDCLI2,SUA->UA_PEDCLI2,"")             ,Nil} ,;
														{"C5_TPCARGA"	,"1"                                                ,Nil} ,;
														{"C5_GERAWMS"	,"2"                                                ,Nil} ,;
														{"C5_OBS"		,IIF(_lACODOBS .AND. !Empty(SUA->UA_CODOBS), MSMM(SUA->UA_CODOBS,43), IIF(_lAOBS,SUA->UA_OBS,"")),Nil} ,;		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_OBS"		,IIF(!Empty(SUA->UA_CODOBS),MSMM(SUA->UA_CODOBS,43),IIF(Type("SUA->UA_OBS")<>"U",SUA->UA_OBS,"")),Nil} ,;
														{"C5_OBSSEP"	,IIF(_lAOBSSEP , SUA->UA_OBSSEP , "")           ,Nil} ,;	//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_OBSSEP"	,IIF(Type("SUA->UA_OBSSEP" )<>"U",SUA->UA_OBSSEP ,"") ,Nil} ,;
														{"C5_OBSPLAN"	,IIF(_lAOBSPLAN, SUA->UA_OBSPLAN, "")           ,Nil} ,; //Linha adicionada por Arthur Silva em 13/10/2015 para trazer no pedido de vendas as observações da planilha.		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_OBSPLAN"	,IIF(Type("SUA->UA_OBSPLAN")<>"U",SUA->UA_OBSPLAN,"") ,Nil} ,;
														{"C5_OBSBLQ"	,IIF(_lAOBSBLQ , SUA->UA_OBSBLQ , "")			,Nil} ,;	//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_OBSBLQ"	,SUA->UA_OBSBLQ			,Nil} ,;
														{"C5_NOMCLI"	,_nNomCli			  								,Nil} ,;
														{"C5_COMIS1"	,0       								  			,Nil} ,;
														{"C5_COMIS2"	,0       								  			,Nil} ,;
														{"C5_COMIS3"	,0       								  			,Nil} ,;
														{"C5_COMIS4"	,0       								  			,Nil} ,;
														{"C5_COMIS5"	,0       								  			,Nil} ,;												
														{"C5_DESC1"		,SUA->UA_DESC1							  			,Nil} ,; //Início - Trecho adicionado por Adriano Leonardo em 14/08/2014 para integridade na rotina
														{"C5_DESC2"		,SUA->UA_DESC2  						  			,Nil} ,;
														{"C5_DESC3"		,SUA->UA_DESC3      					  			,Nil} ,;
														{"C5_DESC4"		,SUA->UA_DESC4      					  			,Nil} ,; //Final -  Trecho adicionado por Adriano Leonardo em 14/08/2014 para integridade na rotina
														{"C5_TPOPER"	,IIF(_lATPOPER,IIF(_l5TPDIV .AND. SC5->C5_TPDIV == '0','ZZ',SUA->UA_TPOPER),"01"),Nil} ,;
														{"C5_ISENIPI"	,IIF(_l1ISENIPI .AND. Alltrim(SA1->A1_ISENIPI) == "0", "NAO", "SIM") ,Nil} ,;
														{"C5_ISENICM"	,IIF(_l1ISENICM .AND. Alltrim(SA1->A1_ISENICM) == "0", "NAO", "SIM") ,Nil} ,;
														{"C5_ISNPCOF"	,IIF(_l1PISCOFI .AND. Alltrim(SA1->A1_PISCOFI) == "0", "NAO", "SIM") ,Nil} ,;
														{"C5_ISENMVA"	,IIF(_l1HBLTMVA .AND. Alltrim(SA1->A1_HBLTMVA) == "0", "NAO", "SIM") ,Nil} ,;
														{"C5_INSCRES"	,IIF(_l1INSCR  ,SA1->A1_INSCR  ,"") 			,Nil} ,;
														{"C5_VLDSUFR"	,IIF(_l1VLSUFR ,SA1->A1_VLSUFR ,"")				,Nil} ,;
														{"C5_VLDSINT"	,IIF(_l1VLDSINT,SA1->A1_VLDSINT,"")				,Nil} ,;
														{"C5_EST"		,POSICIONE('SX5',1,xFilial('SX5')+"12"+SA1->A1_EST,"X5DESCRI()"),Nil} ,;
														{"C5_DESCOND"   ,POSICIONE("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")  ,Nil} ,;												
														{"C5_SUFRAMA"	,IIF(_l1SUFRAMA .AND. !Empty(SA1->A1_SUFRAMA),(SA1->A1_SUFRAMA),"Em branco")     ,Nil} ,;
														{"C5_REDUCAO"	,IIF(_l1BASTRI  .AND. Alltrim(SA1->A1_BASTRI ) == "0", "SIM", IIF(Alltrim(SA1->A1_BASTRI) == "1", "NAO", "INDET")),Nil} ,;
														{"C5_MENNOTA"	,IIF(_lAMENNOTA ,SUA->UA_MENNOTA,"")             ,Nil} ,;			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_MENNOTA"	,IIF(SUA->(FieldPos("UA_MENOTA"))<>0,SUA->UA_MENNOTA,"")   ,Nil} ,;
														{"C5_DTCONFR"	,IIF(_lADTCONFR,SUA->UA_DTCONFR,"")		  		,Nil} ,;			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_DTCONFR"	,SUA->UA_DTCONFR							  		,Nil} ,;
														{"C5_HRCONFR"	,IIF(_lAHRCONFR,SUA->UA_HRCONFR,"")				,Nil} ,;			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_HRCONFR"	,SUA->UA_HRCONFR							  		,Nil} ,;
														{"C5_USRCONF"	,IIF(_lAUSRCONF,SUA->UA_USRCONF,"")				,Nil}  }			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_USRCONF"	,SUA->UA_USRCONF							  		,Nil} ,;
									EndIf
								EndIf
							Else
								dbSelectArea("SA2")
								SA2->(dbSetOrder(1))
								If SA2->(MsSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
									_nNomCli := SA2->A2_NOME
									_cTpDiv  := "5"			//100
								EndIf
							EndIf
							If Len(_aCab) == 0 .AND. _nContIt == 0
								_nContIt++
								_cPriori := IIF(!EMPTY(SC5->C5_NPRIORI),SC5->C5_NPRIORI,IIF(!EMPTY(SA1->A1_PRIOR),SA1->A1_PRIOR,'9')) //Linha adicionada por Adriano Leonardo em 18/02/2014 para correção da rotina
								_aCab    :=  {	{"C5_NUM" 		,SC5->C5_NUM                                        ,Nil} ,;
												{"C5_NPRIORI"	,_cPriori                                           ,Nil} ,; //Linha adicionada por Adriano Leonardo em 18/02/2014 para correção da rotina
												{"C5_REDESP"	,SUA->UA_REDESP                                     ,Nil} ,;
												{"C5_TPFRETE"	,SUA->UA_TPFRETE                                    ,Nil} ,;
												{"C5_DTRANSP"	,SA4->A4_NOME                                       ,Nil} ,;
												{"C5_PEDCLI2"	,IIF(_lAPEDCLI2,SUA->UA_PEDCLI2,"")                 ,Nil} ,;
												{"C5_TPCARGA"	,"1"                                                ,Nil} ,;
												{"C5_GERAWMS"	,"2"                                                ,Nil} ,;
												{"C5_OBS"		,IIF(_lACODOBS .AND. !Empty(SUA->UA_CODOBS), MSMM(SUA->UA_CODOBS,43), IIF(_lAOBS,SUA->UA_OBS,"")),Nil} ,;		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_OBS"		,IIF(!Empty(SUA->UA_CODOBS),MSMM(SUA->UA_CODOBS,43),IIF(Type("SUA->UA_OBS")<>"U",SUA->UA_OBS,"")),Nil} ,;
												{"C5_OBSSEP"	,IIF(_lAOBSSEP , SUA->UA_OBSSEP , "")               ,Nil} ,;	//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_OBSSEP"	,IIF(Type("SUA->UA_OBSSEP" )<>"U",SUA->UA_OBSSEP ,"") ,Nil} ,;
												{"C5_OBSPLAN"	,IIF(_lAOBSPLAN, SUA->UA_OBSPLAN, "")               ,Nil} ,; //Linha adicionada por Arthur Silva em 13/10/2015 para trazer no pedido de vendas as observações da planilha.		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_OBSPLAN"	,IIF(Type("SUA->UA_OBSPLAN")<>"U",SUA->UA_OBSPLAN,"") ,Nil} ,;
												{"C5_OBSBLQ"	,IIF(_lAOBSBLQ , SUA->UA_OBSBLQ , "")               ,Nil} ,;	//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_OBSBLQ"	,SUA->UA_OBSBLQ			,Nil} ,;
												{"C5_NOMCLI"	,_nNomCli			  								,Nil} ,;
												{"C5_COMIS1"	,0       								  			,Nil} ,;
												{"C5_COMIS2"	,0       								  			,Nil} ,;
												{"C5_COMIS3"	,0       								  			,Nil} ,;
												{"C5_COMIS4"	,0       								  			,Nil} ,;
												{"C5_COMIS5"	,0       								  			,Nil} ,;												
												{"C5_DESC1"		,SUA->UA_DESC1							  			,Nil} ,; //Início - Trecho adicionado por Adriano Leonardo em 14/08/2014 para integridade na rotina
												{"C5_DESC2"		,SUA->UA_DESC2  						  			,Nil} ,;
												{"C5_DESC3"		,SUA->UA_DESC3      					  			,Nil} ,;
												{"C5_DESC4"		,SUA->UA_DESC4      					  			,Nil} ,; //Final -  Trecho adicionado por Adriano Leonardo em 14/08/2014 para integridade na rotina
												{"C5_TPOPER"	,IIF(_lATPOPER,IIF(_l5TPDIV .AND. SC5->C5_TPDIV == '0','ZZ',SUA->UA_TPOPER),"01"),Nil} ,;
												{"C5_ISENIPI"	,IIF(_l1ISENIPI .AND. Alltrim(SA1->A1_ISENIPI) == "0", "NAO", "SIM") ,Nil} ,;
												{"C5_ISENICM"	,IIF(_l1ISENICM .AND. Alltrim(SA1->A1_ISENICM) == "0", "NAO", "SIM") ,Nil} ,;
												{"C5_ISNPCOF"	,IIF(_l1PISCOFI .AND. Alltrim(SA1->A1_PISCOFI) == "0", "NAO", "SIM") ,Nil} ,;
												{"C5_ISENMVA"	,IIF(_l1HBLTMVA .AND. Alltrim(SA1->A1_HBLTMVA) == "0", "NAO", "SIM") ,Nil} ,;
												{"C5_INSCRES"	,IIF(_l1INSCR  ,SA1->A1_INSCR  ,"") 			,Nil} ,;
												{"C5_VLDSUFR"	,IIF(_l1VLSUFR ,SA1->A1_VLSUFR ,"")				,Nil} ,;
												{"C5_VLDSINT"	,IIF(_l1VLDSINT,SA1->A1_VLDSINT,"")				,Nil} ,;
												{"C5_EST"		,POSICIONE('SX5',1,xFilial('SX5')+"12"+SA1->A1_EST,"X5DESCRI()"),Nil} ,;
												{"C5_DESCOND"   ,POSICIONE("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")  ,Nil} ,;												
												{"C5_SUFRAMA"	,IIF(_l1SUFRAMA .AND. !Empty(SA1->A1_SUFRAMA),(SA1->A1_SUFRAMA),"Em branco")     ,Nil} ,;
												{"C5_REDUCAO"	,IIF(_l1BASTRI  .AND. Alltrim(SA1->A1_BASTRI ) == "0", "SIM", IIF(Alltrim(SA1->A1_BASTRI) == "1", "NAO", "INDET")),Nil} ,;
												{"C5_MENNOTA"	,IIF(_lAMENNOTA ,SUA->UA_MENNOTA,"")             ,Nil} ,;			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_MENNOTA"	,IIF(SUA->(FieldPos("UA_MENOTA"))<>0,SUA->UA_MENNOTA,"")   ,Nil} ,;
												{"C5_DTCONFR"	,IIF(_lADTCONFR,SUA->UA_DTCONFR,"")		  		,Nil} ,;			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_DTCONFR"	,SUA->UA_DTCONFR							  		,Nil} ,;
												{"C5_HRCONFR"	,IIF(_lAHRCONFR,SUA->UA_HRCONFR,"")				,Nil} ,;			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_HRCONFR"	,SUA->UA_HRCONFR							  		,Nil} ,;
												{"C5_USRCONF"	,IIF(_lAUSRCONF,SUA->UA_USRCONF,"")				,Nil}  }			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: {"C5_USRCONF"	,SUA->UA_USRCONF							  		,Nil} ,;
							EndIf
							while !RecLock("SC5",.F.) ; enddo
							If !Empty(_MVDTFIXAT)
								SC5->C5_EMISSAO := _MVDTFIXAT
							EndIf
							If _l5TPDIV
								SC5->C5_TPDIV := _cTpDiv
								If SC5->C5_TPDIV == '0'
									SC5->C5_TPOPER  := 'ZZ'
								Else
									SC5->C5_TPOPER  := SUA->UA_TPOPER
								EndIf
							ElseIf _l5TPOPER
								If _lATPOPER
									SC5->C5_TPOPER  := SUA->UA_TPOPER
								Else
									SC5->C5_TPOPER  := "01"
								EndIf
							Endif
							SC5->C5_TIPLIB  := "2"
							SC5->C5_TPCARGA := "1"             //Alterado por Júlio em 10/05/2013 para utilização de montagem de carga
							SC5->C5_GERAWMS := "2"             //Alterado por Júlio em 10/05/2013 para utilização de montagem de carga
							SC5->C5_REDESP  := SUA->UA_REDESP
							SC5->C5_TPFRETE := SUA->UA_TPFRETE
							SC5->C5_XLININD := SUA->UA_XLININD //Alterado por Diego em 15/08/2024 para definição do pedido industrial
							If _l5DTRANSP
								SC5->C5_DTRANSP := SA4->A4_NOME
							EndIf
							If _l5PEDCLI2 .AND. _lAPEDCLI2		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC5->(FieldPos("SC5->C5_PEDCLI2"))<>0
								SC5->C5_PEDCLI2 := SUA->UA_PEDCLI2 //Incluido por Júlio em 28/05/2013 para tratar solicitação 357 da lista de pendências solicitado pelo Sr. Mario.
							EndIf
							If _l5OBS
								SC5->C5_OBS     := IIF(_lACODOBS .AND. !Empty(SUA->UA_CODOBS),MSMM(SUA->UA_CODOBS,43),IIF(_lAOBS,SUA->UA_OBS,""))
							EndIf
							If _l5OBSSEP .AND. _lAOBSSEP							//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC5->(FieldPos("SC5->C5_OBSSEP"))<>0
								SC5->C5_OBSSEP  := SUA->UA_OBSSEP					//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC5->C5_OBSSEP  := IIF(Type("SUA->UA_OBSSEP")<>"U",SUA->UA_OBSSEP,"")
							EndIf					
							If _l5OBSPLAN .AND. _lAOBSPLAN							//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: 
								SC5->C5_OBSPLAN := SUA->UA_OBSPLAN					//Linha adicionada por Arthur Silva em 13/10/2015 para trazer no pedido de vendas as observações da planilha.		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: 
							EndIf
							If _l5OBSBLQ .AND. _lAOBSBLQ							//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC5->(FieldPos("SC5->C5_OBSBLQ"))<>0
								SC5->C5_OBSBLQ  := SUA->UA_OBSBLQ
							EndIf					
							If _lAMENNOTA											//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC5->(FieldPos("C5_MENOTA"))<>0
								SC5->C5_MENNOTA := SUA->UA_MENNOTA
							EndIf
							If _l5NOMCLI
								SC5->C5_NOMCLI  := _nNomCli
							EndIf
							If _l5DESCOND											//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC5->(FieldPos("C5_DESCOND"))<>0
								SC5->C5_DESCOND := POSICIONE("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")
							EndIf					
							SC5->C5_COMIS1  := 0
							SC5->C5_COMIS2  := 0
							SC5->C5_COMIS3  := 0
							SC5->C5_COMIS4  := 0
							SC5->C5_COMIS5  := 0
							If _lADTCONFR .AND. _l5DTCONFR
								SC5->C5_DTCONFR := SUA->UA_DTCONFR
							EndIf
							If _lAHRCONFR .AND. _l5HRCONFR
								SC5->C5_HRCONFR := SUA->UA_HRCONFR
							EndIf
							If _lAUSRCONF .AND. _l5USRCONF
								SC5->C5_USRCONF := SUA->UA_USRCONF
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Trecho inserido por Júlio Soares em 19/06/2013 para atender as necessidades do faturamento na verificação dos dados do cliente no pedido de vendas.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							dbSelectArea("SA1")
							SA1->(dbSetOrder(1))
							If SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
								If _l5CGCCENT .AND. _l1CGCCENT
									SC5->C5_CGCCENT := SA1->A1_CGCCENT
								EndIf
								If _l5NPRIORI .AND. _l1PRIOR
									SC5->C5_NPRIORI := IIF(!EMPTY(SA1->A1_PRIOR),SA1->A1_PRIOR,'9') // - Incluido por Júlio Soares em 17/02/2014 para implemetação de rotina de validação de prioridade para cortes na separação.
								EndIf
								If _l5ISENIPI .AND. _l1ISENIPI
									SC5->C5_ISENIPI := IIF(Alltrim(SA1->A1_ISENIPI) == "0", "NAO", "SIM")
								EndIf
								If _l5ISENICM .AND. _l1ISENICM
									SC5->C5_ISENICM := IIF(Alltrim(SA1->A1_ISENICM) == "0", "NAO", "SIM")
								EndIf
								If _l5ISNPCOF .AND. _l1PISCOFI
									SC5->C5_ISNPCOF := IIF(Alltrim(SA1->A1_PISCOFI) == "0", "NAO", "SIM")
								EndIf
								If _l5ISENMVA .AND. _l1HBLTMVA
									SC5->C5_ISENMVA := IIF(Alltrim(SA1->A1_HBLTMVA) == "0", "NAO", "SIM")
								EndIf
								If _l5INSCRES .AND. _l1INSCR
									SC5->C5_INSCRES := SA1->A1_INSCR
								EndIf
								If _l5VLDSUFR .AND. _l1VLSUFR
									SC5->C5_VLDSUFR := SA1->A1_VLSUFR
								EndIf
								If _l5EST
									SC5->C5_EST     := POSICIONE('SX5',1,xFilial('SX5')+"12"+SA1->A1_EST,"X5DESCRI()") // - ALTERADO POR JÚLIO SOARES EM 06/03/2014
								EndIf
								If _l5SUFRAMA .AND. _l1SUFRAMA
									SC5->C5_SUFRAMA := IIF(!Empty(SA1->A1_SUFRAMA),(SA1->A1_SUFRAMA),"Em branco")
								EndIf
								If _l5REDUCAO .AND. _l1BASTRI
									SC5->C5_REDUCAO := IIF(Alltrim(SA1->A1_BASTRI) == "0", "SIM", IIF(Alltrim(SA1->A1_BASTRI) == "1", "NAO", "INDET"))
								EndIf
								// - LINHA COMENTADA EM 13/08/2014 POR JÚLIO SOARES APÓS OBSERVAR QUE O CAMPO FOI PASSADO PARA VIRTUAL E RESULTOU EM ERRO NA ROTINA 
								// - APÓS ATUALIZAÇÃO DO CONFIGURADOR.
								// - SC5->C5_VLDSINT := SA1->(A1_VLDSINT) // - INSERIDO POR JÚLIO SOARES EM 06/03/2014
							EndIf
							SC5->(MSUNLOCK())
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Início do trecho de tratamento das regras de comissões        ³
						//³>>>>>> As comissões foram anteriormente zeradas na tabela SC5!³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						/*
						//Trecho comentado por Adriano Leonardo em 12/06/13 - Para correção da hierarquia das regras de comissões
								_nComis1 := 0
								_nComis2 := 0
								_nComis3 := 0
								_nComis4 := 0
								_nComis5 := 0
						*/
						//Linha adicionada por Adriano em 12/06/13 para dar prioridade ao percentual cadastrado no cliente, quando este estiver preenchido
						If _nComis1 == 0 .And. _nComis2 == 0 .And. _nComis3 == 0 .And. _nComis4 == 0 .And. _nComis5 == 0
							dbSelectArea("SZ6")			//Regras de comissões
							//Verifica se, para o vendedor 1, há alguma regra cadastrada
							If !Empty(SC5->C5_VEND1)
								If _nComis1 == 0 .AND. !Empty(SB1->B1_GRUPO)
									SZ6->(dbSetOrder(1))		//Z6_FILIAL+Z6_REPRES+Z6_GRPPRO+Z6_PRODUT+Z6_DTFIM
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND1 + SB1->B1_GRUPO,.T.,.F.))
										While _nComis1 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES == SC5->C5_VEND1  .AND. ;
																	SZ6->Z6_GRPPRO == SB1->B1_GRUPO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis1 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis1 == 0 .AND. !Empty(SC6->C6_PRODUTO)
									SZ6->(dbSetOrder(2))		//Z6_FILIAL+Z6_REPRES+Z6_PRODUT+DTOS(Z6_DTFIM)
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND1 + SC6->C6_PRODUTO,.T.,.F.))
										While _nComis1 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL  == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES  == SC5->C5_VEND1  .AND. ;
																	SZ6->Z6_PRODUT  == SC6->C6_PRODUTO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis1 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis1 == 0
									_nComis1 := SB1->B1_COMIS
								EndIf
								If _nComis1 == 0
									dbSelectArea("SA3")
									SA3->(dbSetOrder(1))
									If SA3->(MsSeek(xFilial("SA3") + SC5->C5_VEND1,.T.,.F.))
										_nComis1 := SA3->A3_COMIS
									EndIf
								EndIf
							EndIf
							//Verifica se, para o vendedor 2, há alguma regra cadastrada
							If !Empty(SC5->C5_VEND2)
								If _nComis2 == 0 .AND. !Empty(SB1->B1_GRUPO)
									SZ6->(dbSetOrder(1))		//Z6_FILIAL+Z6_REPRES+Z6_GRPPRO+Z6_PRODUT+Z6_DTFIM
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND2 + SB1->B1_GRUPO,.T.,.F.))
										While _nComis2 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES == SC5->C5_VEND2  .AND. ;
																	SZ6->Z6_GRPPRO == SB1->B1_GRUPO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis2 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis2 == 0 .AND. !Empty(SC6->C6_PRODUTO)
									SZ6->(dbSetOrder(2))		//Z6_FILIAL+Z6_REPRES+Z6_PRODUT+DTOS(Z6_DTFIM)
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND2 + SC6->C6_PRODUTO,.T.,.F.))
										While _nComis2 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL  == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES  == SC5->C5_VEND2  .AND. ;
																	SZ6->Z6_PRODUT  == SC6->C6_PRODUTO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis2 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis2 == 0
									_nComis2 := SB1->B1_COMIS
								EndIf
								If _nComis2 == 0
									dbSelectArea("SA3")
									SA3->(dbSetOrder(1))
									If SA3->(MsSeek(xFilial("SA3") + SC5->C5_VEND2,.T.,.F.))
										_nComis2 := SA3->A3_COMIS
									EndIf
								EndIf
							EndIf
							//Verifica se, para o vendedor 3, há alguma regra cadastrada
							If !Empty(SC5->C5_VEND3)
								If _nComis3 == 0 .AND. !Empty(SB1->B1_GRUPO)
									SZ6->(dbSetOrder(1))		//Z6_FILIAL+Z6_REPRES+Z6_GRPPRO+Z6_PRODUT+Z6_DTFIM
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND3 + SB1->B1_GRUPO,.T.,.F.))
										While _nComis3 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES == SC5->C5_VEND3  .AND. ;
																	SZ6->Z6_GRPPRO == SB1->B1_GRUPO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis3 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis3 == 0 .AND. !Empty(SC6->C6_PRODUTO)
									SZ6->(dbSetOrder(2))		//Z6_FILIAL+Z6_REPRES+Z6_PRODUT+DTOS(Z6_DTFIM)
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND3 + SC6->C6_PRODUTO,.T.,.F.))
										While _nComis3 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL  == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES  == SC5->C5_VEND3  .AND. ;
																	SZ6->Z6_PRODUT  == SC6->C6_PRODUTO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis3 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis3 == 0
									_nComis3 := SB1->B1_COMIS
								EndIf
								If _nComis3 == 0
									dbSelectArea("SA3")
									SA3->(dbSetOrder(1))
									If SA3->(MsSeek(xFilial("SA3") + SC5->C5_VEND3,.T.,.F.))
										_nComis3 := SA3->A3_COMIS
									EndIf
								EndIf
							EndIf
							//Verifica se, para o vendedor 4, há alguma regra cadastrada
							If !Empty(SC5->C5_VEND4)
								If _nComis4 == 0 .AND. !Empty(SB1->B1_GRUPO)
									SZ6->(dbSetOrder(1))		//Z6_FILIAL+Z6_REPRES+Z6_GRPPRO+Z6_PRODUT+Z6_DTFIM
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND4 + SB1->B1_GRUPO,.T.,.F.))
										While _nComis4 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES == SC5->C5_VEND4  .AND. ;
																	SZ6->Z6_GRPPRO == SB1->B1_GRUPO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis4 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis4 == 0 .AND. !Empty(SC6->C6_PRODUTO)
									SZ6->(dbSetOrder(2))		//Z6_FILIAL+Z6_REPRES+Z6_PRODUT+DTOS(Z6_DTFIM)
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND4 + SC6->C6_PRODUTO,.T.,.F.))
										While _nComis4 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL  == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES  == SC5->C5_VEND4  .AND. ;
																	SZ6->Z6_PRODUT  == SC6->C6_PRODUTO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis4 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis4 == 0
									_nComis4 := SB1->B1_COMIS
								EndIf
								If _nComis4 == 0
									dbSelectArea("SA3")
									SA3->(dbSetOrder(1))
									If SA3->(MsSeek(xFilial("SA3") + SC5->C5_VEND4,.T.,.F.))
										_nComis4 := SA3->A3_COMIS
									EndIf
								EndIf
							EndIf
							//Verifica se, para o vendedor 5, há alguma regra cadastrada
							If !Empty(SC5->C5_VEND5)
								If _nComis5 == 0 .AND. !Empty(SB1->B1_GRUPO)
									SZ6->(dbSetOrder(1))		//Z6_FILIAL+Z6_REPRES+Z6_GRPPRO+Z6_PRODUT+Z6_DTFIM
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND5 + SB1->B1_GRUPO,.T.,.F.))
										While _nComis5 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES == SC5->C5_VEND5  .AND. ;
																	SZ6->Z6_GRPPRO == SB1->B1_GRUPO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis5 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis5 == 0 .AND. !Empty(SC6->C6_PRODUTO)
									SZ6->(dbSetOrder(2))		//Z6_FILIAL+Z6_REPRES+Z6_PRODUT+DTOS(Z6_DTFIM)
									If SZ6->(MsSeek(xFilial("SZ6") + SC5->C5_VEND5 + SC6->C6_PRODUTO,.T.,.F.))
										While _nComis5 == 0 .AND. !SZ6->(EOF()) .AND. ;
																	SZ6->Z6_FILIAL  == xFilial("SZ6") .AND. ;
																	SZ6->Z6_REPRES  == SC5->C5_VEND5  .AND. ;
																	SZ6->Z6_PRODUT  == SC6->C6_PRODUTO
											If SZ6->Z6_DTINI <= dDataBase .AND. SZ6->Z6_DTFIM >= dDataBase
												_nComis5 := SZ6->Z6_PERC
											EndIf
											SZ6->(dbSkip())
										EndDo
									EndIf
								EndIf
								If _nComis5 == 0
									_nComis5 := SB1->B1_COMIS
								EndIf
								If _nComis5 == 0
									dbSelectArea("SA3")
									SA3->(dbSetOrder(1))
									If SA3->(MsSeek(xFilial("SA3") + SC5->C5_VEND5,.T.,.F.))
										_nComis5 := SA3->A3_COMIS
									EndIf
								EndIf
							EndIf      
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Final do trecho de tratamento das regras de comissões, para   ³
						//³posterior gravação nos itens do pedido de vendas.             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SC6")
						while !RecLock("SC6",.F.) ; enddo
							If _l6TPPROD			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC6->(FieldPos("C6_TPPROD"))>0
								SC6->C6_TPPROD := '1'
							EndIf 
							If _l6COD_E
								//Os tres próximos campos abaixo foram atualizados por RecLock
								SC6->C6_COD_E   := IIF(_l6TPCALC .AND. _l5TPDIV .AND. _l1COD_E .AND. AllTrim(SC6->C6_TPCALC)=="V" .AND. AllTrim(SC5->C5_TPDIV)<>"5" .AND. !Empty(SB1->B1_COD_E), SB1->B1_COD_E, "")		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC6->C6_COD_E   := IIF(AllTrim(SC6->C6_TPCALC)=="V" .AND. AllTrim(SC5->C5_TPDIV)<>"5".AND.!Empty(SB1->B1_COD_E), SB1->B1_COD_E, "")
							EndIf
						//	SC6->C6_BLQ     := ""		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Linha comentada pois, se o sistema havia alimentado este campo, pode ser que ele tenha impactado em informações específicas na tabela SB2 (dentre outras). Por questões de integridade, deixaremos este conteúdo a ser tratado pelo padrão do sistema.
						//	SC6->C6_BLOQUEI := ""		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Linha comentada pois, se o sistema havia alimentado este campo, pode ser que ele tenha impactado em informações específicas na tabela SB2 (dentre outras). Por questões de integridade, deixaremos este conteúdo a ser tratado pelo padrão do sistema.
							//Trecho adicionado por Adriano Leonardo em 22/07/2013
							//Este campo está sendo alimentado para permitir filtros por data na personalização de relatórios, onde a SC5 não está disponível
							If _l6EMISSAO			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conteúdo anterior: SC6->(FieldPos("C6_EMISSAO"))<>0
								SC6->C6_EMISSAO := SC5->C5_EMISSAO
							EndIf
							//Final do trecho adicionado por Adriano Leonardo em 22/07/2013
							If _l6TPCALC
								SC6->C6_TPCALC  := IIF(!_l1TPCALC .OR. Empty(SB1->B1_TPCALC),"Q",SB1->B1_TPCALC)
							EndIf
							If _l5TPDIV .AND. _l4TESALTQ .AND. AllTrim(SC5->C5_TPDIV) == "0" .AND. !Empty(SF4->F4_TESALTQ)
								SC6->C6_TES := SF4->F4_TESALTQ
							EndIf
							If _l6COD_E .AND. _l1COD_E .AND. _l6TPCALC .AND. _l5TPDIV .AND. AllTrim(SC6->C6_TPCALC) == "V" .AND. AllTrim(SC5->C5_TPDIV)<>"5" .AND. !Empty(SB1->B1_COD_E)
								SC6->C6_COD_E := SB1->B1_COD_E
							EndIf
					 		SC6->C6_COMIS1 	:= _nComis1
					 		SC6->C6_COMIS2	:= _nComis2
					 		SC6->C6_COMIS3 	:= _nComis3
					 		SC6->C6_COMIS4 	:= _nComis4
					 		SC6->C6_COMIS5 	:= _nComis5
							//INICIO - CUSTOM. ALLSS - 09/02/2022 - Rodrigo Telecio - tratativa para preenchimento do campo C6_NUMPCOM nos itens do pedido de venda de forma automatizada.
							if _lNumPCom .AND. _lNItPCom .AND. _lAPEDCLI2
								SC6->C6_NUMPCOM := SubStr(AllTrim(SUA->UA_PEDCLI2),1,TamSX3("C6_NUMPCOM")[1])
								if SubStr(AllTrim(SC6->C6_ITEM),1,TamSX3("C6_ITEMPC")[1]) = "01"
									nItemPc := "01"
								elseif SubStr(AllTrim(SC6->C6_ITEM),1,TamSX3("C6_ITEMPC")[1]) < "99"
									nItemPc := SubStr(AllTrim(SC6->C6_ITEM),1,TamSX3("C6_ITEMPC")[1])
								elseif SubStr(AllTrim(SC6->C6_ITEM),1,TamSX3("C6_ITEMPC")[1]) == "99"
									nItemPc := SubStr(AllTrim(SC6->C6_ITEM),1,TamSX3("C6_ITEMPC")[1])
									nP99	:= Val(SubStr(AllTrim(SC6->C6_ITEM),1,TamSX3("C6_ITEMPC")[1]))
								else
									if nP99 > 0
										nP99	:= nP99 + 1
										nItemPc := AllTrim(Str(nP99))
									else
										nItemPc := SubStr(AllTrim(SC6->C6_ITEM),1,TamSX3("C6_ITEMPC")[1])
									endif
								endif
								//SC6->C6_ITEMPC  := SubStr(AllTrim(SC6->C6_ITEM),1,TamSX3("C6_ITEMPC")[1])
								SC6->C6_ITEMPC  := nItemPc
							endif
							//FIM - CUSTOM. ALLSS - 09/02/2022 - Rodrigo Telecio - tratativa para preenchimento do campo C6_NUMPCOM nos itens do pedido de venda de forma automatizada.
						SC6->(MSUNLOCK())
						_aItens := {}    
						_cItem  := SC6->C6_ITEM
						//INICIO CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Alteração do método de pesquisa na SX3 para a função OpenSXs, em decorrência da migração de release (12.1.17 para 12.1.23) prevista para 06/2019 em produção.
							//OpenSxs(	<oParam1 >, ;		//Compatibilidade
							//			<oParam2 >, ;		//Compatibilidade
							//			<oParam3 >, ;		//Compatibilidade
							//			<oParam4 >, ;		//Compatibilidade
							//			<cEmpresa >, ;		//Empresa que se deseja abrir o dicionário, se não informado utilizada a empresa atual (cEmpAnt) 
							//			<cAliasSX >, ;		// Alias que será utilizado para abrir a tabela 
							//			<cTypeSX >, ;		// Tabela que será aberta 
							//			<oParam8 >, ;		//Compatibilidade
							//			<lFinal >, ;		// Indica se deve chamar a função FINAL caso a tabela não exista (.T.)
							//			<oParam10 >, ;		//Compatibilidade
							//			<lShared >, ;		// Indica se a tabela deve ser aberta em modo compartilhado ou exclusivo (.T.)
							//			<lCreate >) 		// Indica se deve criar a tabela, caso ela não exista
							OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)		//OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.T.,,.F.,.F.)
							if Select(_cAliasSX3) > 0
								AADD(_aItens,{"LINPOS"  , "C6_ITEM" ,_cItem}) //Linha adicionada por Adriano Leonardo em 02/12/2013 para correção da rotina
								dbSelectArea(_cAliasSX3)
								(_cAliasSX3)->(dbSetOrder(1))
								(_cAliasSX3)->(dbSetFilter({|| &(_cFilSX3)}, _cFilSX3))
								(_cAliasSX3)->(dbGoTop())
								while !(_cAliasSX3)->(EOF()) //.AND. AllTrim((_cAliasSX3)->X3_ARQUIVO) == "SC6"
									if AllTrim((_cAliasSX3)->X3_CONTEXT) <> "V" .AND. X3USO((_cAliasSX3)->X3_USADO) .AND. cNivel >= (_cAliasSX3)->X3_NIVEL ;
	 									.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_PRUNIT"  ;
	 									.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_PRCVEN"  ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_VALOR"   ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_DESCONT" ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_VALDESC" ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_SEGUM"   ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_IPIDEV"  ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_BLQ"     ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_LOCALIZ" ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_CODFAB"  ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_LOJAFA"  ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_TPCONTR" ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_REGWMS"  ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_VDMOST"  ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_CNATREC" ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_COD_E"   ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_QTDVEN"  ;
										.AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "C6_PRODUTO" //Linha adicionada por Adriano Leonardo em 02/12/2013 - Não remover, inibe a validação do produto
										AADD(_aItens,{(_cAliasSX3)->X3_CAMPO,&(AllTrim((_cAliasSX3)->X3_ARQUIVO)+"->"+AllTrim((_cAliasSX3)->X3_CAMPO)),NIL})
									endif
									dbSelectArea(_cAliasSX3)
									(_cAliasSX3)->(dbSetOrder(1))
									(_cAliasSX3)->(dbSkip())
								enddo
								(_cAliasSX3)->(dbCloseArea())
							endif
						//FIM CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Alteração do método de pesquisa na SX3 para a função OpenSXs, em decorrência da migração de release (12.1.17 para 12.1.23) prevista para 06/2019 em produção.
	//					AADD(_aItens,{"C6_BLQ"    ,Space(TamSx3("C6_BLQ")[01]),NIL}) //Linha adicionada por Adriano Leonardo em 16/10/2013 para correção da rotina
						AADD(_aItens,{"C6_QTDVEN" ,SC6->C6_QTDVEN ,NIL})
						AADD(_aItens,{"C6_PRCVEN" ,SC6->C6_PRCVEN ,NIL})
						AADD(_aItens,{"C6_PRUNIT" ,SC6->C6_PRUNIT ,NIL})
						AADD(_aItens,{"C6_VALDESC",SC6->C6_VALDESC,NIL})
						AADD(_aItens,{"C6_DESCONT",SC6->C6_DESCONT,NIL})
						AADD(_aItens,{"C6_VALOR"  ,SC6->C6_VALOR  ,NIL})
						aadd(_aItens,{"AUTDELETA" ,"N"  	      ,Nil}) //Linha adicionada por Adriano Leonardo em 02/12/2013 para correção da rotina
						AADD(_aItPV,_aItens)
					EndIf
				EndIf
				dbSelectArea("SUB")
				SUB->(dbSetOrder(1))
				SUB->(dbSkip())
			EndDo
			//Trecho utilizado para alterar o pedido de vendas, para que as observações do bloqueio de regras sejam gravadas no pedido de vendas
			If ExistBlock("RFATA012") .AND. Len(_aCab) > 0 .AND. Len(_aItPV) > 0
				_cFunName := FunName()
	//			U_RFATA012(_aCab,_aItPV,_cPed,"0101",.F.) // - LINHA COMENTADA POR JÚLIO SOARES APÓS IDENTIFICAR PROBLEMAS NA CONFIRMAÇÃO DO ATENDIMENTO PARA ARCOLOR USA.
				U_RFATA012(_aCab,_aItPV,_cPed,'"'+FWCodEmp()+FWFILIAL()+'"',.F.) // - LINHA INCLUIDA POR JÚLIO SOARES APÓS IDENTIFICAR PROBLEMAS NA CONFIRMAÇÃO DO ATENDIMENTO PARA ARCOLOR USA.
	//			StartJob("U_RFATA012",GetEnvServer(),.F.,_aCab,_aItPV,_cPed,cNumEmp,.T.)
				SetFunName(_cFunName)
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				// - TRECHO COMENTADO POR JÚLIO SOARES EM 24/02/2014 APÓS A VERIFICAÇÃO DE PROBLEMAS NA GRAVAÇÃO DO CAMPO MEMO.
				/*			
				If MsSeek(xFilial("SC5") + _cPed,.T.,.F.) //.AND. !Empty(SC5->C5_OBSBLQ) 
					dbSelectArea("SUA")
					while !RecLock("SUA",.F.) ; enddo
						SUA->UA_OBSBLQ := SC5->C5_OBSBLQ
					SUA->(MSUNLOCK())
				EndIf
				*/
			EndIf
			/*
			_lAltBkp := ALTERA
			_lIncBkp := INCLUI
			ALTERA  := .T.
			INCLUI  := .F.
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			If SC5->(dbSeek(xFilial("SC5") + _cPed))
				A410Altera("SC5", SC5->(Recno()), 4)
			EndIf
			ALTERA := _lAltBkp
			INCLUI := _lIncBkp
			*/
		EndIf
	EndIf
	//RestArea(_aSavSUA ) // - LINHA COMENTADA POR JÚLIO SOARES EM 27/08/2014 DEVIDO O REST AREA ESTAR NO FINAL DA ROTINA PARA A TABELA SUA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Trecho incluido por Adriano para voltar o status do atendimento para "aberto" quando esse é alterado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If INCLUI 
		If M->UA_OPER == "3" // - ATENDIMENTO                
			_cLogx := "Inclusão de Atendimento."
		ElseIf M->UA_OPER == "2" // - PRÉ-PEDIDO
			_cLogx := "Inclusão de Pré-Pedido."
		Else
			_cLogx := ""
		EndIf
		If SUA->(FieldPos("UA_LOGSTAT")) > 0 .AND. SUA->(FieldPos("UA_STATSC9")) > 0
			_cLog := Alltrim(M->UA_LOGSTAT) + _lEnt
			//RecLock("SUA",.F.) // - LINHA COMENTADA POR JÚLIO SOARES EM 27/08/2014 DEVIDO APRESENTAÇÃO DE MENSAGEM " Tentativa de reservar registro no Alias SUA em EOF Stack de chamadas em MSRLOCK.eof Controle de transações desabilitado nesta operação".
			M->UA_STATSC9 := ""
			M->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + ;
							_lEnt + _cLogx
			//SUA->(MsUnLock()) // - LINHA COMENTADA POR JÚLIO SOARES EM 27/08/2014 DEVIDO APRESENTAÇÃO DE MENSAGEM " Tentativa de reservar registro no Alias SUA em EOF Stack de chamadas em MSRLOCK.eof Controle de transações desabilitado nesta operação".
		EndIf
		// - Inserido em 24/03/2014 por Júlio Soares para gravar status também no quadro de vendas.
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		If SC5->(dbSeek(xFilial("SC5") + M->UA_NUMSC5)) .AND. SC5->(FieldPos("C5_LOGSTAT")) > 0
			If SC5->(FieldPos("C5_LOGSTAT"))>0
				_cLog := Alltrim(SC5->C5_LOGSTAT) + _lEnt
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) + ;
										_lEnt + _cLogx
				SC5	->(MsUnLock())
			EndIf
		EndIf
		// - --------------------------------------------------------------------------------------
		//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
		If ExistBlock("RFATL001") .AND. !Empty(_cLogx)
			U_RFATL001(	M->UA_NUMSC5,;          
						M->UA_NUM,;
						_cLogx,;
						_cRotina)
		EndIf
	EndIf
	/*
	If !Empty(SUA->UA_NUMSC5)
		If INCLUI
			_cLogx := "Pedido de Vendas incluído."
		ElseIf ALTERA
			_cLogx := "Pedido de Vendas alterado."
		EndIf
	EndIf
	*/
	If ExistBlock("RTMKE028")
		//Seta atalho para tecla F4 para alterar informações específicas no atendimento Call Center
		//SetKey(VK_F4,{|| })
		//SetKey(VK_F4,{|| U_RTMKE028()})
		//Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F8,{|| MsgAlert( "Tecla [ F8 ] foi alterada para [ Ctrl + F8 ]" , "Protheus11" )})
		SetKey( K_CTRL_F8, { || })
		SetKey( K_CTRL_F8, { || U_RTMKE028()})
	EndIf
	If ExistBlock("RTMKE022")
		//Seta atalho para tecla F5 para chamar a tela de busca avançada
		//SetKey(VK_F5,{|| })
		//SetKey(VK_F5,{|| U_RTMKE022() })
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey(VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
		SetKey( K_CTRL_F5, { || })
		SetKey( K_CTRL_F5, { || U_RTMKE022()})
	EndIf
	If ExistBlock("RTMKE025")
		//Seta atalho para tecla F6 para chamar a conferência dos atendimentos
		//SetKey(VK_F6,{|| })
		//SetKey(VK_F6,{|| U_RTMKE025() })
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F6,{|| MsgAlert( "Tecla [ F6 ] foi alterada para [ Ctrl + F6 ]" , "Protheus11" )})
		SetKey( K_CTRL_F6, { || })
		SetKey( K_CTRL_F6, { || U_RTMKE025()})
	EndIf
	If ExistBlock("RFATC011")
		//Seta atalho para tecla F7 para chamar consulta dos pedidos por cliente
		//SetKey(VK_F7,{|| })
		//SetKey(VK_F7,{|| U_RFATC011() })
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey(VK_F7,{|| MsgAlert( "Tecla [ F7 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
		SetKey( K_CTRL_F7, { || })
		SetKey( K_CTRL_F7, { || U_RFATC011()})
	EndIf
	If ExistBlock("RFATL001")
		SetKey( K_CTRL_9, { || })
		SetKey( K_CTRL_9, { || U_RFATL001(SUA->UA_NUMSC5,POSICIONE('SUA',1,xFilial('SUA')+SUA->UA_NUM,'UA_NUM'),'',_cRotina,)})
		//AAdd(aRotina,{"Logs do Pedido","U_RFATL001(SUA->UA_NUMSC5,POSICIONE('SUA',1,xFilial('SUA')+SUA->UA_NUM,'UA_NUM'),'','"+_cRotina+"',)" ,0,6,0 ,NIL})
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restauro as áreas salvas inicialmente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(_aSavSUA )
	RestArea(_aSavSA1 )
	RestArea(_aSavSUS )
	RestArea(_aSavSU5 )
	RestArea(_aSavSUB )
	RestArea(_aSavSC5 )
	RestArea(_aSavSC6 )
	RestArea(_aSavSF4 )
	RestArea(_aSavSB1 )
	RestArea(_aSavSA4 )
	RestArea(_aSavSA3 )
	RestArea(_aSavSZ6 )
	RestArea(_aSavArea)
return _lRet
