#INCLUDE "RWMAKE.CH"                            
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#DEFINE DMPAPER_A4 9 // A4 210 x 297 mm
#DEFINE ENT CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFINR017  ºAutor  ³Anderson C. P. Coelho º Data ³  20/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Impressão de Boleto Gráfico, previamente         º±±
±±º          ³preparado para o Banco do Brasil.                           º±±
±±º          ³ O nosso número aqui é gravado sem o código do Convênio e   º±±
±±º          ³sem o dígito verificador,que é sempre calculado nesta rotinaº±±
±±º          ³ A Faixa Atual do Nosso Número é considerada na tabela SEE  º±±
±±º          ³como sendo a que já foi impressa.                           º±±
±±º          ³ As seguintes áreas podem ser localizadas neste fonte da    º±±
±±º          ³seguinte maneira:                                           º±±
±±º          ³### REG.001 - Composição do Nosso Número                    º±±
±±º          ³### REG.002 - Composição dos valores e mensagens            º±±
±±º          ³### REG.003 - Composição do Código de Barras                º±±
±±º          ³### REG.004 - Composição da Linha Digitável                 º±±
±±º          ³### REG.005 - Processamento da Impressão                    º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus 11                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
ATENÇÃO
-------
	>>>>>> É necessário criar a pasta "BOLETOS" na Protheus_Data <<<<<<
*/
user function RFINR017(cParSerie, cParNumero, lImprime, lEnvBol , lEnvRom , lOpcoes, cAnexo, cRomaneio, dDtInic, dDtFinal, cDanfe, cEndEmail)
	Local   _aSavA17    := GetArea()
	Local   _aSavSA117  := SA1->(GetArea())
	Local   _aSavSE117  := SE1->(GetArea())
	Local   _aSavSEE17  := SEE->(GetArea())
	Local   _aSavSZI17  := SZI->(GetArea())
	Local   _aSavTmp    := SE1->(GetArea())
	Local   _aRotObr    := {"RFINEBBD",;
							"RFINEBBE",;
							"RFINEBBI",;
							"RFINEBBJ",;
							"RFINEBBL",;
							"RFINEBBN",;
							"RFINEBBO",;
							"RFINEBBT",;
							"RFINEBBV",;
							"RFINEBBS" }
	Private oPrn
	Private cTitulo     := "Impressão de Boleto"
	Private _cRotina    := "RFINR017"
	Private cPerg       := "RFINR017"
	Private _cLogoEmp   := FisxLogo("1")
	Private _cLogoBco   := ""
	Private _cNomBco    := ""
	Private _cCliente   := ""
	Private _cLojaCli   := ""
	Private _cPedido    := ""
	Private _cInstru1   := ""
	Private _cInstru2   := ""
	Private NOSSONUM    := ""
	Private _cDVNN      := ""
	Private CLINHA      := ""
	Private CBARRA      := ""
	Private MsgInstr01  := ""
	Private MsgInstr02  := ""
	Private MsgInstr03  := ""
	Private _cMensJur   := ""
	Private _cMensDesc  := ""
	//Início - Trecho adicionado por Adriano Leonardo em 28/02/2014 - Inclusão de envio por e-mail
	Private _aAnexo     := {}
	Private _aArquivo   := {}
	Private _nQtdBole   := 0
	Default lImprime    := .T.
	Private _lImprime   := lImprime
	Default lOpcoes	    := .T.
	Private _lOpcoes    := lOpcoes
	Default lEnvBol	    := .F.
	Private _lEnvBol    := lEnvBol
	Default lEnvRom	    := .F.
	Private _lEnvRom    := lEnvRom
	Default cAnexo	    := ""
	Private _cAnexoAux  := cAnexo
	Default cRomaneio   := ""
	Private _cRomaneio  := cRomaneio
	Default cDanfe	    := ""
	Private _cDanfe	    := cDanfe
	Default cEndEmail   := ""
	Default dDtInic	    := Stod("20130101")
	Private	_cDtInici   := dDtInic
	Default dDtFinal    := Stod("20491231")
	Private	_cDtFinal   := dDtFinal
	Private _cEmissao   := STOD("")
	Private _cEndEmail  := cEndEmail
	Private _cPrefixo   := cParSerie
	Private _cNumTitu   := cParNumero
	Private _lAlerta    := .T.
	Private _lCancBole  := .F.
	Private _cNumAux    := ""
	Private _lCancela   := .F.
	Private _lCancRoma  := .F.
	Private	_dData      := ""
	Private _lValidMail := .T.
	Private _dExcPDe   := SuperGetMv("MV_PROVDE" ,,STOD("20171213"))
	Private _dExcPAte  := SuperGetMv("MV_PROVATE",,STOD("20180105"))
	
	// FB - RELEASE 12.1.23
	Private _bROTINA := "ExistBlock(_aRotObr[_x])"
	// FIM FB
	Private _aRotObr := ""
	//Verifica se o boleto será enviado por e-mail
	If _lEnvBol
		Private _cCaminho  := IIF(ExistDir("\boletos\"),"\boletos\",lower(GetTempPath()))
		Private _cArqBol   := _cCaminho+"BOL_"+AllTrim(_cNumTitu)+"_"+AllTrim(_cPrefixo)
	EndIf
	//Final  - Trecho adicionado por Adriano Leonardo em 28/02/2014 - Inclusão de envio por e-mail
	for _x := 1 to Len(_aRotObr)
		/* FB - RELASE 12.1.23
		If !ExistBlock(_aRotObr[_x])
		*/
		If !&(_bROTINA)
			MsgAlert("Problemas! Solicite ao administrador que compile a seguinte rotina: " + _aRotObr[_x],_cRotina+"_000")
	//		return
		EndIf
	next
	ValidPerg()
	// - Trecho chamado pela impressão da Danfe
	If _lImprime .And. _lOpcoes
		If Pergunte(cPerg,.T.)
			If !Empty(MV_PAR04) .AND. !Empty(MV_PAR13) .AND. !Empty(MV_PAR14) .AND. !Empty(MV_PAR15) .AND. !Empty(MV_PAR16)
				Processa( { |lEnd| ImpBolBB(lEnd) }, cTitulo, "Processando informações...",.T.)			
			Else
				MsgAlert("Atenção! Parâmetros preenchidos incorretamente. Operação abortada!",_cRotina+"_003")
			EndIf
		EndIf
		//Início - Trecho adicionado por Adriano Leonardo em 28/02/2014 - Inclusão de envio por e-mail	
	// - Trecho chamado na rotina manual de impressão.
	Else
		Pergunte(cPerg,.F.)
		If !Empty(_cNumTitu)
			_aSavTmp  := SE1->(GetArea())
			_cEmissao := STOD("")
			_cPedido  := ""
			_cCliente := ""
			_cLojaCli := ""
			_cInstru1 := ""
			_cInstru2 := ""
			BeginSql Alias "TRATMP"
				SELECT DISTINCT E1_CLIENTE,E1_LOJA,E1_PEDIDO,E1_EMISSAO,E1_INSTR1,E1_INSTR2
				FROM %table:SE1% SE1 (NOLOCK)
				WHERE SE1.E1_FILIAL  = %xFilial:SE1%
				  AND SE1.E1_PREFIXO = %Exp:_cPrefixo%
				  AND SE1.E1_NUM     = %Exp:_cNumTitu%
				  AND SE1.E1_TIPO    = %Exp:'NF'%
				  AND SE1.%NotDel%
			EndSql
			dbSelectArea("TRATMP")
				If !TRATMP->(EOF())
					_cCliente := TRATMP->E1_CLIENTE
					_cLojaCli := TRATMP->E1_LOJA
					_cEmissao := TRATMP->E1_EMISSAO
					_cPedido  := TRATMP->E1_PEDIDO
					_cInstru1 := TRATMP->E1_INSTR1
					_cInstru2 := TRATMP->E1_INSTR2
				EndIf
			TRATMP->(dbCloseArea())
			/*
			dbSelectArea("SE1")
			SE1->(dbSetOrder(1))
			If SE1->(dbSeek(xFilial("SE1") + _cPrefixo + _cNumTitu))
				If !EMPTY(SE1->(E1_CARTEIR))
					_cEmissao := SE1->E1_EMISSAO
					_cPedido  := SE1->E1_PEDIDO
					_cCliente := SE1->E1_CLIENTE
					_cLojaCli := SE1->E1_LOJA
					_cInstru1 := SE1->E1_INSTR1
					_cInstru2 := SE1->E1_INSTR2
			 	Else
			 		MSGBOX("Carteira do Título está em branco, Verifique!", _cRotina + "_017","ALERT")	
			 		return
			 	EndIf 		
			EndIf
			*/
			RestArea(_aSavTmp)
			MV_PAR01 := Space(TamSx3("E1_PREFIXO")[01])						//"01","Prefixo de         ?
			MV_PAR02 := Replicate('Z',TamSx3("E1_PREFIXO")[01])				//"02","Prefixo ate        ?
			MV_PAR03 := Space(TamSx3("E1_NUM")[01])							//"03","Numero de          ?
			MV_PAR04 := Replicate('Z',TamSx3("E1_NUM")[01])					//"04","Numero ate         ?
			MV_PAR05 := Space(TamSx3("E1_NUMBOR")[01])						//"05","Bordero de         ?
			MV_PAR06 := Replicate('Z',TamSx3("E1_NUMBOR")[01])				//"06","Bordero ate        ?
			MV_PAR07 := _cEmissao											//"07","Emissao de         ?
			MV_PAR08 := _cEmissao											//"08","Emissao ate        ?
			MV_PAR11 := _cPedido											//"11","De pedido          ?
			MV_PAR12 := _cPedido											//"12","Até pedido         ?
		Else
			MV_PAR01 := _cPrefixo											//"01","Prefixo de         ?
			MV_PAR02 := _cPrefixo											//"02","Prefixo ate        ?
			MV_PAR03 := _cNumTitu											//"03","Numero de          ?
			MV_PAR04 := _cNumTitu											//"04","Numero ate         ?
			MV_PAR05 := Space(TamSx3("E1_NUMBOR")[01])						//"05","Bordero de         ?
			MV_PAR06 := Replicate('Z',TamSx3("E1_NUMBOR")[01])				//"06","Bordero ate        ?
			MV_PAR07 := "20170101"											//"07","Emissao de         ?
			MV_PAR08 := "20491231"											//"08","Emissao ate        ?
			MV_PAR11 := Space(TamSx3("E1_PEDIDO")[01])						//"11","De pedido          ?
			MV_PAR12 := Replicate('Z',TamSx3("E1_PEDIDO")[01])				//"12","Até pedido         ?
		EndIf
		MV_PAR09 := _cDtInici											//"09","Vencimento de      ?
		MV_PAR10 := _cDtFinal											//"10","Vencimento Ate     ?
		MV_PAR13 := Padr(SuperGetMv("MV_BCOB17" ,,"001"		),TamSx3("EE_CODIGO" )[01])		//"13","Banco              ?
		MV_PAR14 := Padr(SuperGetMv("MV_AGEB17" ,,"3333 "	),TamSx3("EE_AGENCIA")[01])		//"14","Agencia            ?
		MV_PAR15 := Padr(SuperGetMv("MV_CONB17" ,,"150346"	),TamSx3("EE_CONTA"  )[01])		//"15","Conta              ?
		MV_PAR16 := Padr(SuperGetMv("MV_SUBCB17",,"006"		),TamSx3("EE_SUBCTA" )[01])		//"16","Sub-Conta          ?
		MV_PAR17 := ""													//"17","Msg 01 só p/ boleto?
		MV_PAR18 := ""													//"18","Msg 02 só p/ boleto?
		If !Empty(MV_PAR04) .AND. !Empty(MV_PAR13) .AND. !Empty(MV_PAR14) .AND. !Empty(MV_PAR15) .AND. !Empty(MV_PAR16)
			Processa( { |lEnd| ImpBolBB(lEnd) }, cTitulo, "Processando informações...",.T.)		
		EndIf
	//Final  - Trecho adicionado por Adriano Leonardo em 28/02/2014 - Inclusão de envio por e-mail
	EndIf
	If _lValidMail
		// Inicio - Trecho adicionado por Adriano Leonardo em 06/03/2014 para envio por e-mail
		If (_lEnvBol .And. !_lCancBole) .And. (_lEnvRom .And. !_lCancRoma) 
			MsAguarde({|lEnd|SendMail()  },"Aguarde...","Enviando romaneio e boleto(s) para o cliente...",.T.)
		ElseIf _lEnvRom  .And. !_lCancRoma
			MsAguarde({|lEnd|SendMail()  },"Aguarde...","Enviando romaneio para o cliente...",.T.)
		ElseIf _lEnvBol  .And. !_lCancBole
			MsAguarde({|lEnd|SendMail()  },"Aguarde...","Enviando boleto(s) para o cliente...",.T.)
		ElseIf _lEnvBol
			MsgBox("Nenhum e-mail a ser enviado para o cliente!" ,_cRotina + "_004","ALERT")
		EndIf
		// Final  - Trecho adicionado por Adriano Leonardo em 06/03/2014 para envio por e-mail
	EndIf
	RestArea(_aSavSA117)
	RestArea(_aSavSE117)
	RestArea(_aSavSEE17)
	RestArea(_aSavSZI17)
	RestArea(_aSavA17)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpBolBB  ºAutor  ³Anderson C. P. Coelho º Data ³  20/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processamento de impressão da rotina.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpBolBB(lEnd)

// FB - RELEASE 12.1.23
Local _lRFINEBBV  := EXISTBLOCK('RFINEBBV')
Local _lRFINEBBJ  := EXISTBLOCK('RFINEBBJ')
Local _lRFINEBBD  := EXISTBLOCK('RFINEBBD')
Local _lRFINEBBL  := EXISTBLOCK('RFINEBBL')
Local _lRFINEBBI  := EXISTBLOCK('RFINEBBI') 
Local _bEENOMECOM := "Type('SEE->EE_NOMECOM')"
Local _lRFATL001  := ExistBlock("RFATL001")
// FIM FB

	If MV_PAR13 <> '001'
		MsgAlert("Este banco não pode ser utilizado para a impressão deste boleto. Por favor corrija!" ,_cRotina+"_005")
		return
	Else
		dbSelectArea("SEE")
		SEE->(dbSetOrder(1))
		If !SEE->(MsSeek(xFilial("SEE") + MV_PAR13 + MV_PAR14 + MV_PAR15 + MV_PAR16,.T.,.F.))
			MsgAlert("Arquivo de parâmetros banco/cnab incorreto. Verifique banco/agência/conta/sub-conta.",_cRotina+"_006")
			return
		ElseIf UPPER(AllTrim(SEE->EE_EXTEN)) <> "REM"
			MsgAlert("Dados não se referem a configuração de remessa! Verifique os parâmetros!",_cRotina+"_007")
			return
		ElseIf Empty(SEE->EE_CODEMP) .OR. Len(Alltrim(SEE->EE_CODEMP))<4 .OR. Len(Alltrim(SEE->EE_CODEMP))>7
			MsgAlert("Código do Convênio incorreto!",_cRotina+"_008")
			return
		ElseIf Empty(SEE->EE_CODCART)
			MsgAlert("Carteira não preenchida nos parâmetros bancos!",_cRotina+"_009")
			return
		EndIf
		// - Trecho inserido por Júlio Soares em 21/03/2014 para validação das carteiras preenchidas
			dbSelectArea("SE1")
			SE1->(dbSetOrder(1))
			If SE1->(dbSeek(xFilial("SE1") + MV_PAR01 + MV_PAR03)) .AND. SE1->E1_TIPO <> "NCC" // - Implementado tratamento para NCC
				If Empty (SE1->E1_INSTR1)
					MsgAlert("A instrução primária de cobrança do título não está preenchida, Verifique...",_cRotina+"_0")
					Return
				ElseIf Empty (SE1->(E1_INSTR2))
					MsgAlert("A instrução secundária de cobrança do título não está preenchida, Verifique...",_cRotina+"_0")
					return
		        EndIf	
			EndIf
		// - FIM
	EndIf
	If Len(AllTrim(SEE->EE_AGENCIA))>4
		If "-"$AllTrim(SEE->EE_AGENCIA)
			_cAg := AllTrim(SEE->EE_AGENCIA)
		Else
			_cAg := SubStr(SEE->EE_AGENCIA,1,4) + "-" + SubStr(SEE->EE_AGENCIA,5,1)
		EndIf
	Else
		_cAg := AllTrim(SEE->EE_AGENCIA) + "-" + AllTrim(SEE->EE_DVAGE)
	EndIf
	If "-"$AllTrim(SEE->EE_CONTA)
		_cCC := AllTrim(SEE->EE_CONTA)
	ElseIf Empty(SEE->EE_DVCTA)
		_cCC := SubStr(AllTrim(SEE->EE_CONTA),1,Len(AllTrim(SEE->EE_CONTA))-1)+"-"+SubStr(AllTrim(SEE->EE_CONTA),Len(AllTrim(SEE->EE_CONTA))-1,1)
	Else
		_cCC := AllTrim(SEE->EE_CONTA) + "-" + AllTrim(SEE->EE_DVCTA)
	EndIf
	dbSelectArea("SE1")
	_cQry := "SELECT R_E_C_N_O_ RECSE1 "
	_cQry += "FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "
	_cQry += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1")  + "' "
	_cQry += "  AND SE1.E1_PREFIXO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	_cQry += "  AND SE1.E1_NUM     BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	_cQry += "  AND SE1.E1_NUMBOR  BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	If _lImprime .And. _lOpcoes
		_cQry += "  AND SE1.E1_EMISSAO BETWEEN '" + DTOS(MV_PAR07)  + "' AND '" + DTOS(MV_PAR08) + "' "
	Else
		If Empty(MV_PAR07)
			_cQry += "  AND SE1.E1_EMISSAO BETWEEN '19000101' AND '19000101' " // - Inserido para bloquear error log quando MV_PAR07 está nulo
		Else
			_cQry += "  AND SE1.E1_EMISSAO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		EndIf	
	EndIf
	_cQry += "  AND SE1.E1_VENCTO  BETWEEN '" + DTOS(MV_PAR09)  + "' AND '" + DTOS(MV_PAR10) + "' "
	_cQry += "  AND SE1.E1_PEDIDO  BETWEEN '" + MV_PAR11  		+ "' AND '" + MV_PAR12 		 + "' "
	_cQry += "  AND SE1.E1_CARTEIR       = '" + SEE->EE_CODCART + "' "
	_cQry += "  AND SE1.E1_SALDO         > 0 "
	_cQry += "  AND SE1.E1_TIPO         <> 'CH'  "
	_cQry += "  AND SE1.E1_TIPO         <> 'NCC' "
	_cQry += "  AND (SE1.E1_PORTADO      = '' OR SE1.E1_PORTADO = '" + MV_PAR13        + "' )"
	_cQry += "  AND (SE1.E1_AGEDEP       = '' OR SE1.E1_AGEDEP  = '" + MV_PAR14        + "' )"
	_cQry += "  AND (SE1.E1_CONTA        = '' OR SE1.E1_CONTA   = '" + MV_PAR15        + "' )"
	_cQry += "  AND SE1.D_E_L_E_T_       = '' "
	_cQry += "ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA "
	/*
	If __cUserId $ "000000|000155"
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY1.TXT",_cQry)
	EndIf
	*/
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SE1TMP",.T.,.F.)
	dbSelectArea("SE1TMP")
	If SE1TMP->(EOF())
		SE1TMP->(dbCloseArea())
		MsgAlert("Nada a imprimir!",_cRotina+"_010")
		_lValidMail := .F.
		return
	EndIf
	ProcRegua(SE1TMP->(RecCount()))
	_cNomBco   := AllTrim(SEE->EE_DESCBCO)		//Descrição do Banco a ser impresso no boleto
	_cLogoBco  := AllTrim(SEE->EE_LOGO)			//Caminho do logotipo BMP do banco
	oFont08    := TFont():New( "Arial"       ,,08,,.F.,,,,,.F. )
	oFont08B   := TFont():New( "Arial"       ,,08,,.T.,,,,,.F. )
	oFont12    := TFont():New( "Courier New" ,,09,,.t.,,,,,.f. )
	oFont13    := TFont():New( "Arial"       ,,06,,.f.,,,,,.f. )
	oFont14    := TFont():New( "Arial"       ,,08,,.F.,,,,,.f. )
	oFont14B   := TFont():New( "Arial"       ,,14,,.T.,,,,,.F. )
	oFont15    := TFont():New( "Arial"       ,,10,,.t.,,,,,.f. )
	oFont17    := TFont():New( "Arial"       ,,14,,.T.,,,,,.f. )
	oFont18    := TFont():New( "Arial"       ,,09,,.T.,,,,,.f. )
	oFont20    := TFont():New( "Arial Black" ,,16,,.T.,,,,,.f. )
	oFont21    := TFont():New( "Arial"       ,,18,,.T.,,,,,.f. )
	oFont22B   := TFont():New( "Arial"       ,,22,,.T.,,,,,.F. )
	oFont24    := TFont():New( "Arial"       ,,07,,.T.,,,,,.f. )
	oPrn       := TMSPrinter():New()	// Declara o objeto a ser impresso
	oPrn:SetPaperSize(DMPAPER_A4)		// Tamanho/Tipo do Papel
	oPrn:SetPortRait()					// Impressão em formato "retrato"
	If _lImprime .And. _lOpcoes .And. _nQtdBole>0
		oPrn:Setup() //para configurar impressora, quando impressão normal (sem ser em arquivo jpeg)
	EndIf
	oPrn:SetPaperSize(DMPAPER_A4)		// Tamanho/Tipo do Papel
	oPrn:SetPortRait()					// Impressão em formato "retrato"
	dbSelectArea("SE1TMP")
	While !SE1TMP->(EOF())
		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		SE1->(dbGoTo(SE1TMP->RECSE1))
		IncProc("Processando " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + "...")
		//Início - Trecho adicionado por Adriano Leonardo em 06/03/2014
			If !Empty(SE1->E1_ENVMAIL) .And. (_lEnvBol .Or. _lEnvRom) .And. _lAlerta
				If !MsgYesNo("Atenção! O(s) boleto(s) já foram enviados ao cliente anteriormente, deseja envia-lo(s) novamente?",_cRotina+"_016")
					_lCancela := .T.
					return
				Else
					_lAlerta :=	.F.
				EndIf
			EndIf
		//Final  - Trecho adicionado por Adriano Leonardo em 06/03/2014
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If !SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.,.F.))
			MsgAlert("Problemas na localização do cliente " + SE1->E1_CLIENTE+SE1->E1_LOJA + " do título " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Portanto, este não será impresso!",_cRotina+"_011")
			dbSelectArea("SE1TMP")
			SE1TMP->(dbSkip())
			Loop
		EndIf
	
		//### REG.001 - Composição do Nosso Número
			NOSSONUM := ""
			_cDVNN   := ""
			_lContin := .T.
			//Cálculo do Nosso Número e do Dígito Verificador, quando for o caso
				U_RFINEBBS(@NOSSONUM,@_cDVNN,@_lContin,_cRotina)
				If !_lContin
					dbSelectArea("SE1TMP")
					SE1TMP->(dbSkip())
					Loop
				EndIf
			//Fim do Cálculo do Nosso Número
	
		//### REG.002 - Composição dos valores e mensagens
			//Início do cômputo dos valores
				/* FB - RELEASE 12.1.23
				_nSaldo     := IIF(EXISTBLOCK("RFINEBBV"),U_RFINEBBV()   ,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))
				_nJuros     := IIF(EXISTBLOCK("RFINEBBJ"),U_RFINEBBJ()   ,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES)*(SE1->E1_PORCJUR/100))
				_nDescon    := IIF(EXISTBLOCK("RFINEBBD"),U_RFINEBBD('V'),IIF(EXISTBLOCK("RFINEBBV"),U_RFINEBBV(),SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))*(SE1->E1_DESCFIN/100))
			//Fim do cômputo dos valores
			//Coleta das informações do cliente
				//Dados relativos a endereço na rotina RFINEBBL:
				//2=Endereço com número;E=Endereço;N=Número;C=Complemento;B=Bairro;M=Município;U=Estado;P=CEP
				_cCEPc   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("P"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_CEPC   ,SA1->A1_CEP    )))
				_cEndc   := AllTrim(IIf(!Empty(SA1->A1_ENDCOB),AllTrim(FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[1]) + ", " + AllTrim(IIF(!Empty(FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[3]),FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[3],"S/N")),AllTrim(FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[1]) + ", " + AllTrim(IIF(!Empty(FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[3]),FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[3],"S/N")) ) )
				_cEndc   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("2"),_cEndc))
				_cBair   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("B"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_BAIRROC,SA1->A1_BAIRRO )))
				_cMunc   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("M"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_MUNC   ,SA1->A1_MUN    )))
				_cEstc   := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("U"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_ESTC   ,SA1->A1_EST    )))
				_cCompl  := AllTrim(IIF(EXISTBLOCK("RFINEBBL"),U_RFINEBBL("C"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_COMPLC ,SA1->A1_COMPLEM)))
			 	*/
				_nSaldo     := IIF(_lRFINEBBV,U_RFINEBBV()   ,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))
				_nJuros     := IIF(_lRFINEBBJ,U_RFINEBBJ()   ,SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES)*(SE1->E1_PORCJUR/100))
				_nDescon    := IIF(_lRFINEBBD,U_RFINEBBD('V'),IIF(_lRFINEBBV,U_RFINEBBV(),SE1->(E1_SALDO-E1_SDDECRE+E1_SDACRES))*(SE1->E1_DESCFIN/100))
				//Fim do cômputo dos valores
				//Coleta das informações do cliente
				//Dados relativos a endereço na rotina RFINEBBL:
				//2=Endereço com número;E=Endereço;N=Número;C=Complemento;B=Bairro;M=Município;U=Estado;P=CEP
				_cCEPc   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("P"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_CEPC   ,SA1->A1_CEP    )))
				_cEndc   := AllTrim(IIf(!Empty(SA1->A1_ENDCOB),AllTrim(FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[1]) + ", " + AllTrim(IIF(!Empty(FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[3]),FisGetEnd(SA1->A1_ENDCOB,SA1->A1_ESTC)[3],"S/N")),AllTrim(FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[1]) + ", " + AllTrim(IIF(!Empty(FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[3]),FisGetEnd(SA1->A1_END   ,SA1->A1_EST )[3],"S/N")) ) )
				_cEndc   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("2"),_cEndc))
				_cBair   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("B"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_BAIRROC,SA1->A1_BAIRRO )))
				_cMunc   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("M"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_MUNC   ,SA1->A1_MUN    )))
				_cEstc   := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("U"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_ESTC   ,SA1->A1_EST    )))
				_cCompl  := AllTrim(IIF(_lRFINEBBL,U_RFINEBBL("C"),IIF(!Empty(SA1->A1_CEPC).AND.!Empty(SA1->A1_ESTC).AND.!Empty(SA1->A1_ENDCOB).AND.!Empty(SA1->A1_BAIRROC),SA1->A1_COMPLC ,SA1->A1_COMPLEM)))
			 	
			 	If Len(AllTrim(SA1->A1_CGC)) == 14
					_cCnpj := "CNPJ: " + SubStr(SA1->A1_CGC,1,2)+"."+SubStr(SA1->A1_CGC,3,3)+"."+SubStr(SA1->A1_CGC,6,3)+"/"+SubStr(SA1->A1_CGC,9,4)+"-"+SubStr(SA1->A1_CGC,13,2)
				ElseIf Len(AllTrim(SM0->M0_CGC)) == 11
					_cCnpj := "CPF: "  + SubStr(SA1->A1_CGC,1,3)+"."+SubStr(SA1->A1_CGC,4,3)+"."+SubStr(SA1->A1_CGC,7,3)+"-"+SubStr(SA1->A1_CGC,10,2)
				Else
					_cCnpj := "CPF/CNPJ: " + AllTrim(SA1->A1_CGC)
				EndIf
			//Término das informações do cliente
			//Início da área de mensagens para o boleto
				//Mensagem relativa a juros
					_cMensJur   := ""
					If _nJuros<>0
						_cMensJur := "Após o vcto., cobrar R$ "+AllTrim(Transform(_nJuros,"@E 999,999.99"))+" por dia de atraso."
					EndIf
				//Fim da mensagem relativa a juros
				//Mensagem relativa a desconto
					_cMensDesc  := ""
					If _nDescon > 0
						_cMensDesc := "Desconto/Abatimento até " + DTOC(SE1->(E1_VENCTO-E1_DIADESC)) + ": R$ " + AllTrim(Transform(_nDescon,"@E 999,999.99")) + " fixo."
					EndIf
				//Fim da mensagem relativa a desconto
				//Instrução bancária 01
					MsgInstr01 := ""
					_cOcorr    := IIF(!EMPTY(SE1->E1_OCORREN),SE1->E1_OCORREN,SEE->EE_OCORREN)
					/* FB - RELEASE 12.1.23
					_cInstr01  := IIF(EXISTBLOCK("RFINEBBI"),U_RFINEBBI("1"),IIF(Empty(SE1->E1_INSTR1),SEE->EE_INSTPRI,SE1->E1_INSTR1))
					*/
					_cInstr01  := IIF(_lRFINEBBI,U_RFINEBBI("1"),IIF(Empty(SE1->E1_INSTR1),SEE->EE_INSTPRI,SE1->E1_INSTR1))
					If !Empty(_cInstr01)
						dbSelectArea("SZI")
						If !Empty(_cOcorr)
							//SZI->(dbSetOrder(5))		//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_OCORREN+ZI_CODINST
							SZI->(dbOrderNickName("ZI_BANCO2"))
							_lAchou := SZI->(MsSeek(xFilial("SZI")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA)+_cOcorr+_cInstr01))
						Else
							//SZI->(dbSetOrder(1))		//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_CODINST+ZI_OCORREN
							SZI->(dbOrderNickName("ZI_BANCO" ))
							_lAchou := SZI->(MsSeek(xFilial("SZI")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA)+_cInstr01        ))
						EndIf
						If _lAchou .AND. AllTrim(SZI->ZI_MSBLQL)<>"1" .AND. AllTrim(SZI->ZI_IMPBOL)=="S"
						// - TRECHO INSERIDO EM 18/03/2014 POR Júlio Soares PARA IMPLEMENTAÇÃO DE TEXTOS EXPECÍFICOS NO BOLETO BB 17
						//	MsgInstr01 := AllTrim(_cInstr01) + " - " + AllTrim(SZI->ZI_DESINST) // - TRECHO COMENTADO POR Júlio Soares
							If SZI->(ZI_DIASPRO) <> 0
						//		MsgInstr01 := AllTrim(_cInstr01) + " - PROTESTO: " + (DTOC(SE1->(E1_VENCTO) + SZI->(ZI_DIASPRO))) + " - " + "APÓS ESSA DATA CONSULTAR O BANCO DO BRASIL P/ PAGTO"// - Linha comentada por Júlio Soares em 21/03/2014 após solicitação do Sr. Mario para que não fosse impresso o código da instução
								If SZI->(ZI_OCORREN) == '01' .And. SZI->(Z1_DIACONT) == '2'
									// - TRECHO COMENTADO POR Diego Rodrigues
									//If DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) >= DTOC(_dExcPDe) .AND. DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) <= DTOC(_dExcPAte)
									//	MsgInstr01 := " SUJEITO A PROTESTO APÓS O VENCIMENTO. " - 
									//Else
										MsgInstr01 := "PROTESTO: " + DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.))// + " - " + "Após essa data consultar o Banco do Brasil p/ Pgto."
									//EndIf
								Else 
								//	MsgInstr01 := "PROTESTO: " + DTOC(DataValida(SE1->(E1_VENCTO) + IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) + " - " + "APÓS ESSA DATA CONSULTAR O BANCO DO BRASIL P/ PAGTO"				
									//If DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) >= DTOC(_dExcPDe) .AND. DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) <= DTOC(_dExcPAte)
									//	MsgInstr01 := " SUJEITO A PROTESTO APÓS O VENCIMENTO. "
									//Else
										MsgInstr01 := "PROTESTO: " + DTOC(DataValida(Dias(),.T.)) //+ " - " + "Após essa data consultar o "+_cNomBco+" p/ Pgto."
									//EndIf	
								EndIf
							Else
						//		MsgInstr01 := AllTrim(_cInstr01) + " - " + AllTrim(SZI->ZI_DESINST)// - Linha comentada por Júlio Soares em 21/03/2014 após solicitação do Sr. MArio para que não fosse impresso o código da instução
								MsgInstr01 := AllTrim(SZI->ZI_DESINST)
							EndIf
						//----------------------------------------------------------------------------------------------------------------------------------------
				
						EndIf
					EndIf
				//Fim da Instrução bancária 01
				//Instrução bancária 02
					MsgInstr02 := ""
					_cOcorr    := IIF(!EMPTY(SE1->E1_OCORREN),SE1->E1_OCORREN,SEE->EE_OCORREN)

					/* FB - RELEASE 12.1.23
					_cInstr02  := IIF(EXISTBLOCK("RFINEBBI"),U_RFINEBBI("2"),IIF(Empty(SE1->E1_INSTR2),SEE->EE_INSTSEC,SE1->E1_INSTR2))
					*/
					_cInstr02  := IIF(_lRFINEBBI,U_RFINEBBI("2"),IIF(Empty(SE1->E1_INSTR2),SEE->EE_INSTSEC,SE1->E1_INSTR2))

					If !Empty(_cInstr02)
						dbSelectArea("SZI")
						If !Empty(_cOcorr)
							//SZI->(dbSetOrder(5))		//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_OCORREN+ZI_CODINST
							SZI->(dbOrderNickName("ZI_BANCO2"))
							_lAchou := SZI->(MsSeek(xFilial("SZI")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA)+_cOcorr+_cInstr02))
						Else
							//SZI->(dbSetOrder(1))		//ZI_FILIAL+ZI_BANCO+ZI_AGENCIA+ZI_CONTA+ZI_CODINST+ZI_OCORREN
							SZI->(dbOrderNickName("ZI_BANCO" ))
							_lAchou := SZI->(MsSeek(xFilial("SZI")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA)+_cInstr02        ))
						EndIf
						If _lAchou .AND. AllTrim(SZI->ZI_MSBLQL)<>"1" .AND. AllTrim(SZI->ZI_IMPBOL)=="S"
				
						// - TRECHO INSERIDO EM 18/03/2014 POR Júlio Soares PARA IMPLEMENTAÇÃO DE TEXTOS EXPECÍFICOS NO BOLETO BB 17
						// MsgInstr02 := AllTrim(_cInstr02) + " - " + AllTrim(SZI->ZI_DESINST)
							If SZI->(ZI_DIASPRO) <> 0
						//		MsgInstr02 := AllTrim(_cInstr02) + " - PROTESTO: " + (DTOC(SE1->(E1_VENCTO) + IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO))) + " - " + "APÓS ESSA DATA CONSULTAR O BANCO DO BRASIL P/ PAGTO"  // - Linha comentada por Júlio Soares em 21/03/2014 após solicitação do Sr. MArio para que não fosse impresso o código da instução
								If SZI->(ZI_OCORREN) == '01' .And. SZI->(ZI_DIACONT) == '2'
									// - TRECHO COMENTADO POR Diego Rodrigues
									//If DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) >= DTOC(_dExcPDe) .AND. DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) <= DTOC(_dExcPAte)
									//	MsgInstr01 := " SUJEITO A PROTESTO APÓS O VENCIMENTO. "
									//Else
										MsgInstr02 := "PROTESTO: " + DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) //+ " - " + "Após essa data consultar o "+_cNomBco+" p/ Pgto."
									//EndIf
								Else 
									//MsgInstr02 := "PROTESTO: " + (DTOC(SE1->(E1_VENCTO) + IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO))) + " - " + "APÓS ESSA DATA CONSULTAR O BANCO DO BRASIL P/ PAGTO"
									//If DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) >= DTOC(_dExcPDe) .AND. DTOC(DataValida(SE1->E1_VENCTO+IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO),.T.)) <= DTOC(_dExcPAte)
									//	MsgInstr01 := " SUJEITO A PROTESTO APÓS O VENCIMENTO. "
									//Else
										MsgInstr02 := "PROTESTO: " + DTOC(DataValida(Dias(),.T.)) //+ " - " + "Após essa data consultar o "+_cNomBco+" p/ Pgto."
									//EndIf
								EndIf
							Else 
						//		MsgInstr02 := AllTrim(_cInstr02) + " - " + AllTrim(SZI->ZI_DESINST) // - Linha comentada por Júlio Soares em 21/03/2014 após solicitação do Sr. Mario para que não fosse impresso o código da instução
								MsgInstr02 := AllTrim(SZI->ZI_DESINST)
							EndIf
						//--------------------------------------------------------------------------------------------------------------------------------------------
						EndIf
					EndIf
				//Fim da Instrução bancária 02
				//Mensagens adicionais só para o boleto
					MsgInstr03 := ''//AllTrim(Formula(SE1->E1_FORMEN1)) // Comentado por Júlio Soares em 07/01/2014 após verificar que o campo E1_FORMEN1 ainda não existe no banco de dados.
					If !Empty(MV_PAR17)
						If !Empty(MsgInstr03)
							MsgInstr03 += CHR(13) + CHR(10)
						EndIf
						MsgInstr03 += AllTrim(MV_PAR17)
					EndIf
					If !Empty(MV_PAR18)
						If !Empty(MsgInstr03)
							MsgInstr03 += " "
						EndIf
						MsgInstr03 += AllTrim(MV_PAR18)
					EndIf
				//Fim das mensagens adicionais só para o boleto
			//Fim da Área de Mensagens para o boleto
	
		//### REG.003 - Composição do Código de Barras
			//Início da montagem do Código de Barras
				cFatVen     := SE1->E1_VENCTO - STOD("19971007")
				cBarra      := SubStr(SEE->EE_CODIGO,1,3)				//001 a 003 - Código do Banco
				cBarra      += IIF(SE1->E1_MOEDA==1,'9','0')			//004 a 004 - Moeda
				cBarra      += "#"										//005 a 005 - DV Código de Barras
				cBarra      += StrZero(cFatVen             ,04)			//006 a 009 - Fator de Vencimento
			//	cBarra      += StrZero(INT(_nSaldo*100    ),10)			//010 a 019 - Valor (arredondado com 02 decimais) //Linha comentada por Adriano Leonardo em 05/06/2014 por conta de instabilidade com a função INT()
			// - Alterado por Júlio Soares em 17/06/2014 após constatar problemas de impressão para decimais com 0
			//	cBarra      += StrZero(Round(_nSaldo*&("1"+StrZero(0,Len(cValToChar(_nSaldo-INT(_nSaldo)))-2)) ,0),10)			//010 a 019 - Valor (arredondado com 02 decimais)
			// - Alterado por Júlio Soares em 18/06/2014 após constatar problemas de impressão para numeros com decimais igual a 0 foi adicionado manualmente dois Zeros para as decimais.
			//	cBarra      += StrZero(Round(_nSaldo*&("1"+IIF((_nSaldo-INT(_nSaldo))==0,"",StrZero(0,Len(cValToChar(_nSaldo-INT(_nSaldo)))-2))) ,0),10)	//010 a 019 - Valor (arredondado com 02 decimais)
				cBarra      += StrZero(Round(((Round(_nSaldo,2))*100),0),10) //010 a 019 - Valor (arredondado com 02 decimais)
				If Len(SubStr(NOSSONUM,Len(Alltrim(SEE->EE_CODEMP))+1)) > 11	//020 a 042 - Campo Livre (Nosso Número [c/ convênio e sem DV] + Agência e Conta [quando o nosso número for menor ou igual a 11 caracteres]
					cBarra  += StrZero(VAL(NOSSONUM       ),23)
					cBarra  += "21"										//043 a 044 - Tipo de Carteira/Modalidade de Cobrança
				ElseIf Len(Alltrim(SEE->EE_CODEMP)) == 6 .AND. Len(AllTrim(SubStr(NOSSONUM,Len(Alltrim(SEE->EE_CODEMP))+1))) <= 11
					cBarra  += Alltrim(SEE->EE_CODEMP)					//020 a 025 - Número do Convênio de Seis Posições
					cBarra  += StrZero(VAL(NOSSONUM),23-Len(Alltrim(SEE->EE_CODEMP)))	//026 a 042 - Nosso-Número - Livre do cliente.
					cBarra  += StrZero(VAL(SEE->EE_CODCART),02)			//043 a 044 - Tipo de Carteira/Modalidade de Cobrança
				ElseIf Len(Alltrim(SEE->EE_CODEMP)) == 7 .AND. Len(AllTrim(NOSSONUM)) == 17
					cBarra  += StrZero(0,6)								//020 a 025 - Número do Convênio de Seis Posições
					cBarra  += AllTrim(NOSSONUM)						//026 a 042 - Nosso-Número - Livre do cliente.
					cBarra  += StrZero(VAL(SEE->EE_CODCART),02)			//043 a 044 - Tipo de Carteira/Modalidade de Cobrança
				Else
					cBarra  += StrZero(VAL(NOSSONUM       ),11)
					cBarra  += StrZero(VAL(SubStr(_cAg,1,AT("-",_cAg)-1)),04)
					cBarra  += StrZero(VAL(SubStr(_cCC,1,AT("-",_cCC)-1)),08)
					cBarra  += StrZero(VAL(SEE->EE_CODCART),02)			//043 a 044 - Tipo de Carteira/Modalidade de Cobrança
				EndIF
				//Cálculo do Dígito Verificador do Código de Barras (posição 005 a 005)
				CDigCodBar()
			//Fim da composição do código de barras
		
		//### REG.004 - Composição da Linha Digitável
			//Início da composição da Linha Digitável
				cLinha := CalcLinDig()
			//Término da composição da Linha Digitável
		
		//### REG.005 - Processamento da Impressão
			//INÍCIO DA IMPRESSÃO
				oPrn:StartPage()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
				//³Impressao do canhoto (comprovante de entrega)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
				_nPosHor := 01
				_nLinha  := 02
				_nEspLin := 84
		
				// Posicionamento Vertical
					_nPosVer := 10
			
				// Posicionamento do Texto Dentro do Box
					_nTxtBox := 05
		
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25,_nTxtBox+0005,_cNomBco+"   |" + SubStr(cBarra,01,03) + "-" + SubStr(cBarra,04,01) + "|",ofont14B,100)
			//	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25,_nTxtBox+0005,_cNomBco,ofont14B,100)
			//	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin),_nTxtBox+0390,"|" + SubStr(cBarra,01,03) + "-" + SubStr(cBarra,04,01) + "|",ofont22B,100)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+10,_nPosVer+1630,"Comprovante de Entrega",ofont14B,100)
				_nLinha++
				oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0830)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Beneficiário",ofont08,100)

//				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0300,"CPF/CNPJ Beneficiário",ofont08,100)

				/* FB - RELEASE 12.1.23
				If Type("SEE->EE_NOMECOM")<>"U" .AND. !Empty(SEE->EE_NOMECOM)
				*/
				If &(_bEENOMECOM) <> "U" .AND. !Empty(SEE->EE_NOMECOM)
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0010,AllTrim(SEE->EE_NOMECOM),ofont08,100)
				Else
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0010,AllTrim(SM0->M0_NOMECOM),ofont08,100)
				EndIf
		
				// Box Agencia/Codigo Cedente
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0830,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0840,"Agência/Cód. Beneficiário",ofont08,100)
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0850,_cAg + "/" + _cCC,ofont08B,100)
		    	
		    	// BOX CNPJ BENEFICIARIO - Livia 24/04/2018		 	
		 		oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin)+(2*_nEspLin),_nPosVer+2230)	
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1200,"CPF/CNPJ Beneficiário",ofont08,100)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+1200,_cCnpj,ofont08B,100)
		
		
				// Box Motivos nao entrega
			 	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin+0067),_nPosVer+1180,_nPosHor+(_nLinha*_nEspLin)+(2*_nEspLin),_nPosVer+2230)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0067)+_nTxtBox,_nPosVer+1290,"Motivos de não entrega(para uso da empresa entregadora)",ofont08,100)
	
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0105)+_nTxtBox,_nPosVer+1210,"( ) Mudou-se",ofont08,100)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0105)+_nTxtBox,_nPosVer+1490,"( ) Ausente",ofont08,100)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0105)+_nTxtBox,_nPosVer+1820,"( ) Não existe n. indicado",ofont08,100)
	
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0136)+_nTxtBox+0025,_nPosVer+1210,"( ) Recusado",ofont08,100)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0136)+_nTxtBox+0025,_nPosVer+1490,"( ) Não Procurado",ofont08,100)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0136)+_nTxtBox+0025,_nPosVer+1820,"( ) Falecido",ofont08,100)
	
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0167)+_nTxtBox+0050,_nPosVer+1210,"( ) Desconhecido",ofont08,100)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0167)+_nTxtBox+0050,_nPosVer+1490,"( ) Endereço Insuficiente",ofont08,100)
				oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0167)+_nTxtBox+0050,_nPosVer+1820,"( ) Outros (anotar no verso)",ofont08,100)
	
			 
		 
				// Box Sacado
					_nLinha++
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0830)
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Pagador",ofont08,100)
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0010,SubStr(SA1->A1_NOME,1,45),ofont08,100)
		
				// Box Nosso Numero
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0830,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0840,"Nosso Número",ofont08,100)
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0845,NOSSONUM+IIF(!Empty(_cDVNN),"-"+_cDVNN,""),ofont08B,100)
		
				// Box Vencimento
					_nLinha++
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0200)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Vencimento",ofont08,100)
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0030,DTOC(SE1->E1_VENCTO),ofont08B,100)
		
				// Box Numero do Documento
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0200,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0520)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0210,"N. do Documento",ofont08,100)
				//	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0250,AllTrim(SE1->E1_PREFIXO)+"  "+AllTrim(SE1->E1_NUM)+"  "+AllTrim(SE1->E1_PARCELA),ofont08,100)
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0250,AllTrim(SE1->E1_NUM)+"  "+AllTrim(SE1->E1_PARCELA),ofont08,100)
		
				// Box Especie Moeda
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0520,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0830)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0530,"Espécie Moeda",ofont08,100)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0650,"R$",ofont08,100)
		
				// Box Valor do Documento
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0830,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0840,"Valor do Documento",ofont08,100)
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0940,Transform(_nSaldo,"@E 999,999.99"),ofont08B,100)
		
				// Box Recebimento bloqueto
					_nLinha++
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0340)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Recebi(emos) o bloqueto",ofont08,100)
		
				// Box Data
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0340,_nPosHor+(_nLinha*_nEspLin),_nPosVer+560)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0350,"Data",ofont08,100)
		
				// Box Assinatura
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0560,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0570,"Assinatura",ofont08,100)
		
				// Box Data
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1180,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1520)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1190,"Data",ofont08,100)
		
				// Box Entregador
					oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1520,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
					oprn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1530,"Entregador",ofont08,100)
		
				// Box Local de Pagamento
					_nLinha++
					oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+20,_nPosVer+0010,"__  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  __  ",ofont08,100)
	
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAIXAÄÄÄÄAIXAÄÄÄÄAIXAAIXA³
			//³                                                 ³
			//³       MONTA O RECIBO DO SACADO                  ³
			//³                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAIXAÄÄÄÄAIXAÄÄÄÄAIXAÄÄÄÄAI
			*/
				oPrn:Say ( 650, 1770, "RECIBO DO PAGADOR",oFont15,100)
				oPrn:Box ( 690, 0200, 1900, 2180)
		
				oPrn:SayBitmap( 700, 210,_cLogoBco,340,190 )

				/* FB - 12.1.23
				If Type("SEE->EE_NOMECOM")<>"U" .AND. !Empty(SEE->EE_NOMECOM)
				*/
				If &(_bEENOMECOM) <> "U" .AND. !Empty(SEE->EE_NOMECOM)
					oPrn:Say ( 790, 560, AllTrim(SEE->EE_NOMECOM),oFont14B,100)
				Else
					oPrn:Say ( 790, 560, AllTrim(SM0->M0_NOMECOM),oFont14B,100)
				EndIf
				If Len(AllTrim(SM0->M0_CGC)) == 14
			//		_cCnpj := "CNPJ: " + SubStr(SM0->M0_CGC,1,2)+"."+SubStr(SM0->M0_CGC,3,3)+"."+SubStr(SM0->M0_CGC,6,3)+"/"+SubStr(SM0->M0_CGC,9,4)+"-"+SubStr(SM0->M0_CGC,13,2)
					_cCnpj := "CNPJ: " + AllTrim(SM0->M0_CGC)
				ElseIf Len(AllTrim(SM0->M0_CGC)) == 11
					_cCnpj := "CPF: " + SubStr(SM0->M0_CGC,1,3)+"."+SubStr(SM0->M0_CGC,4,3)+"."+SubStr(SM0->M0_CGC,7,3)+"-"+SubStr(SM0->M0_CGC,10,2)
				Else
					_cCnpj := "CPF/CNPJ: " + AllTrim(SM0->M0_CGC)
				EndIf
				oPrn:Say ( 860, 560,AllTrim(FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[1]) + ", " + ;
									AllTrim(IIF(!Empty(FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[3]),FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[3],"S/N")) + " - " + ;
									AllTrim(SM0->M0_BAIRCOB) + " - " + AllTrim(SM0->M0_CIDCOB) + "/" + SM0->M0_ESTCOB + " CEP " + Transform(SM0->M0_CEPCOB,"99999-999") + ;
									"  Tel: " + AllTrim(SM0->M0_TEL) + " " + _cCnpj ,oFont13,100)
			
				oPrn:line( 900, 200, 0901, 2180)
				oPrn:line(1100, 200, 1101, 2180)
				oPrn:line( 900, 1800,1100, 1801)
			
				oPrn:Say ( 955, 1870,"VENCIMENTO",oFont15,100)
					oPrn:Say( 0950, 0240, AllTrim(SE1->E1_CLIENTE)+AllTrim(SE1->E1_LOJA) + " - " + ALLTRIM(SA1->A1_NOME), oFont12,100  )
				If !Empty(_cCompl)
					oPrn:Say( 0990, 0240, ALLTRIM(_cEndc) + " - " + Alltrim(_cCompl), oFont12,100  )
				Else
					oPrn:Say( 0990, 0240, ALLTRIM(_cEndc)      ,oFont12,100  )
				Endif
				oPrn:Say( 1020, 1900, DTOC(SE1->E1_VENCTO)    ,oFont15,100  )   //Vencimento do Titulo
				oPrn:Say( 1030, 0240, SubStr(_cCEPc,1,5)+"-"+SubStr(_cCEPc,6,3)+"  "+RTrim(_cBair)+" - "+ALLTRIM(_cMunc)+"   "+_cEstc, oFont12,100  )
		
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAIXAÄÄÄÄAIXAÄÄÄÄAIXAAIXA³
			//³                                                 ³
			//³       MONTA PARTE INFERIOR DO RECIBO / CAIXA    ³
			//³                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAIXAÄÄÄÄAIXAÄÄÄÄAIXAÄÄÄÄAI
			*/
				// Monta box do boleto
					//        lin   col   lin   col
					//	oPrn:Box (1380, 0200, 1900, 2180)
				
				// Monta linhas horizontais
					//        lin   col   lin   col
					oPrn:Line(1230, 1720, 1230, 2180)
					oPrn:Line(1300, 1720, 1300, 2180)
					oPrn:Line(1380, 1720, 1380, 2180)
					oPrn:Line(1450, 1720, 1450, 2180)
					oPrn:Line(1520, 0200, 1520, 2180)
					oPrn:Line(1590, 1720, 1590, 2180)
					oPrn:Line(1660, 1720, 1660, 2180)
					oPrn:Line(1730, 1720, 1730, 2180)
					oPrn:Line(1800, 0200, 1800, 2180)
				// Monta linha verticais
					//        lin   col   lin   col
					oPrn:SayBitmap( 1110, 0900,_cLogoEmp,400,400 )
					oPrn:Line(1230, 1720, 1900, 1720)
		
				oPrn:Say( 1235, 1730, "Codigo Beneficiário "        ,oFont13,100  )
				oPrn:Say( 1310, 1730, "Nº. Documento "         ,oFont13,100  )
				oPrn:Say( 1385, 1730, "Nosso Numero "          ,oFont13,100  )
				oPrn:Say( 1455, 1730, "Valor do Documento "    ,oFont13,100  )
				oPrn:Say( 1265, 1740, _cAg + "/" + _cCC        ,oFont12,100  )   //Codigo do Cedente
			//	oPrn:Say( 1340, 1830, AllTrim(SE1->E1_PREFIXO)+"  "+AllTrim(SE1->E1_NUM)+"  "+AllTrim(SE1->E1_PARCELA),oFont12,100)
				oPrn:Say( 1340, 1830, AllTrim(SE1->E1_NUM)+"  "+AllTrim(SE1->E1_PARCELA),oFont12,100)
				oPrn:Say( 1410, 1755, NOSSONUM+IIF(!Empty(_cDVNN),"-"+_cDVNN,""),oFont12,100  )
				oPrn:Say( 1480, 1970, Transform(_nSaldo,"@E 999,999.99") , oFont12,100  )
				oPrn:Say( 1525, 1730, "(-) Desconto/Abatimento",oFont13,100  )
				oPrn:Say( 1525, 0220, "Instruções "            ,oFont13,100  )
				oPrn:Say( 1595, 1730, "(-) Outras deduções "   ,oFont13,100  )
		
				_nLinMsg := 1545
				oPrn:Say( _nLinMsg, 0220, "Desconto/Abatimento só com instrução do beneficiário.",oFont18,100  )
				_nLinMsg += 30
				If !Empty(MsgInstr01)
					oPrn:Say( _nLinMsg, 0220, SubStr(MsgInstr01,1,77) ,oFont18,100  )
					_nLinMsg += 30
				EndIf
				If !Empty(MsgInstr02)
					oPrn:Say( _nLinMsg, 0220, SubStr(MsgInstr02,1,77) ,oFont18,100  )
					_nLinMsg += 30
				EndIf
				If !Empty(_cMensJur)
					oPrn:Say( _nLinMsg, 0220, SubStr(_cMensJur ,1,77) ,oFont18,100  )
					_nLinMsg += 30
				EndIf
				If !Empty(_cMensDesc)
					oPrn:Say( _nLinMsg, 0220, SubStr(_cMensDesc,1,77) ,oFont18,100  )
					_nLinMsg += 30
				EndIf
				If !Empty(MsgInstr03)
					_cTxt   := AllTrim(MsgInstr03)
					_nLnTot := MlCount(_cTxt ,100)
					While !Empty(_cTxt)
						_cTexto := IIF(CHR(10)$_cTxt,SubStr(_cTxt,1,AT(CHR(10),_cTxt)-1),AllTrim(_cTxt))
						_cTxt   := IIF(CHR(10)$_cTxt,SubStr(_cTxt,AT(CHR(10),_cTxt)+1),"")
						If !Empty(_cTexto)
							_nMem1 := MlCount(_cTexto,100)
							For _nLoop := 1 To _nMem1
								oPrn:Say(_nLinMsg,0220,MemoLine(StrTran(_cTexto,CHR(13),""),100,_nLoop),oFont18,100  )
								_nLinMsg += 30
						  	Next
						EndIf
					EndDo
				EndIf
		
				oPrn:Say( 1665, 1730, "(+) Mora/Multa/Juros "  ,oFont13,100  )
				oPrn:Say( 1735, 1730, "(+) Outros Acrecimos "  ,oFont13,100  )
				oPrn:Say( 1805, 1730, "(=) Valor Cobrado "     ,oFont13,100  )
		
				oPrn:Say( 1815, 0220, _cNomBco,oFont20,100)
				oPrn:Say( 1815, 1100, SubStr(cBarra,01,03) + "-" + SubStr(cBarra,04,01),oFont21,100)
		
			//******************************************
			//  MONTA FICHA COMPENSAÇÃO
			//******************************************
				// Monta box do boleto
					oPrn:Box (2080, 0200, 3000, 2180)
		
				// Monta linhas horizontais
					oPrn:Line(2190, 0200, 2190, 2180)
					oPrn:Line(2260, 0200, 2260, 2180)
					oPrn:Line(2330, 0200, 2330, 2180)
					oPrn:Line(2400, 0200, 2400, 2180)
					oPrn:Line(2745, 0200, 2745, 2180)
		
				// Monta linha verticais
					oPrn:Line(2000, 0550, 2080, 0550)
					oPrn:Line(2000, 0551, 2080, 0551)
					oPrn:Line(2000, 0553, 2080, 0553)
					oPrn:Line(2000, 0730, 2080, 0730)
					oPrn:Line(2000, 0731, 2080, 0731)
					oPrn:Line(2000, 0733, 2080, 0733)
					oPrn:Line(2080, 1720, 2745, 1720)
					oPrn:Line(2470, 1720, 2470, 2180)
					oPrn:Line(2540, 1720, 2540, 2180)
					oPrn:Line(2610, 1720, 2610, 2180)
					oPrn:Line(2680, 1720, 2680, 2180)
					oPrn:Line(2260, 0500, 2401, 0500)
					oPrn:Line(2260, 0900, 2401, 0900)
					oPrn:Line(2260, 1100, 2331, 1100)
					oPrn:Line(2260, 1400, 2401, 1400)
					oPrn:Line(2330, 0700, 2401, 0700)
					oPrn:Line(2330, 0400, 2401, 0400)
		
				oPrn:SayBitmap(1955, 0222,_cLogoBco,255,120 )
				oPrn:Say( 2005, 0560, SubStr(cBarra,01,03) + "-" + SubStr(cBarra,04,01) ,oFont21,100)
				oPrn:Say( 2005, 0745, cLinha                   ,oFont17,150)
		
				oPrn:Say( 2085, 0220, "Local de Pagamento "    ,oFont13,100  )
				oPrn:Say( 2085, 1730, "Vencimento "            ,oFont13,100  )
				oPrn:Say( 2135, 0240, "Pagável em qualquer banco até o vencimento",oFont12,100 )
				oPrn:Say( 2135, 1900, DTOC(SE1->E1_VENCTO)     ,oFont15,100  )   //Vencimento do Titulo
		
				oPrn:Say( 2195, 0220, "Beneficiário "          ,oFont13,100  )
				oPrn:Say( 2195, 1320, "CNPJ Beneficiário " ,oFont13,100  )
				oPrn:Say( 2195, 1730, "Codigo Beneficiário "   ,oFont13,100  )
				/* FB - RELEASE 12.1.23
				If Type("SEE->EE_NOMECOM")<>"U" .AND. !Empty(SEE->EE_NOMECOM)
				*/
				If &(_bEENOMECOM) <> "U" .AND. !Empty(SEE->EE_NOMECOM)				
					oPrn:Say( 2220, 0240, AllTrim(SEE->EE_NOMECOM) ,oFont12,100  )   //Cedente
					oPrn:Say( 2220, 1345, Transform(AllTrim(SM0->M0_CGC),"@R 99.999.999/9999-99"),oFont12,100  )   //Cedente
				Else
					oPrn:Say( 2220, 0240, AllTrim(SM0->M0_NOMECOM) ,oFont12,100  )   //Cedente
					oPrn:Say( 2220, 1345, Transform(AllTrim(SM0->M0_CGC),"@R 99.999.999/9999-99"),oFont12,100  )   //Cedente
				EndIf
			oPrn:Say( 2220, 1740, _cAg + "/" + _cCC        ,oFont12,100  )   //Codigo do Cedente
		
				oPrn:Say( 2265, 0220, "Data Documento "        ,oFont13,100  )
				oPrn:Say( 2265, 0510, "Nº. Documento "         ,oFont13,100  )
				oPrn:Say( 2265, 0910, "Especie Doc. "          ,oFont13,100  )
				oPrn:Say( 2265, 1110, "Aceite "                ,oFont13,100  )
				oPrn:Say( 2265, 1410, "Data do Processamento " ,oFont13,100  )
				oPrn:Say( 2265, 1730, "Nosso Numero "          ,oFont13,100  )
		
				oPrn:Say( 2290, 0240, DTOC(SE1->E1_EMISSAO)    ,oFont12,100  )
			//	oPrn:Say( 2290, 0530, SE1->E1_PREFIXO+" "+SE1->E1_NUM+" "+SE1->E1_PARCELA , oFont12,100  )
				oPrn:Say( 2290, 0530, SE1->E1_NUM+" "+SE1->E1_PARCELA , oFont12,100  )	
				oPrn:Say( 2290, 0970, "DM"                     ,oFont12,100  )
				oPrn:Say( 2290, 1230, IIF(!Empty(SEE->EE_ACEITE),SEE->EE_ACEITE,"N"),oFont12,100  )
				oPrn:Say( 2290, 1440, DTOC(DDATABASE)          ,oFont12,100  )
				oPrn:Say( 2290, 1755, NOSSONUM+IIF(!Empty(_cDVNN),"-"+_cDVNN,""),oFont12,100  )
				oPrn:Say( 2335, 0220, "Uso do Banco "          ,oFont13,100  )
				oPrn:Say( 2335, 0510, "Carteira "			   ,oFont13,100  )
				oPrn:Say( 2335, 0710, "Especie "               ,oFont13,100  )
				oPrn:Say( 2335, 0910, "Quantidade "            ,oFont13,100  )
				oPrn:Say( 2335, 1410, "Valor "                 ,oFont13,100  )
				oPrn:Say( 2335, 1730, "Valor do Documento "    ,oFont13,100  )
				//oPrn:Say( 2360, 0560, StrZero(VAL(SEE->EE_CODCART),02),oFont12,100  )
				oPrn:Say( 2360, 0560, StrZero(VAL(SEE->EE_CODCART),03),oFont12,100  )
				oPrn:Say( 2360, 0770, "R$"                     ,oFont12,100  )
				oPrn:Say( 2360, 1975, Transform(_nSaldo,"@E 999,999.99") , oFont12,100  )
		
				oPrn:Say( 2405, 0220, "Instruções "            ,oFont13,100  )
				oPrn:Say( 2405, 1730, "(-) Desconto/Abatimento",oFont13,100  )
		
				_nLinMsg := 2430
				oPrn:Say( _nLinMsg, 0220, "Desconto/Abatimento só com instrução do beneficiário.",oFont18,100  )
				_nLinMsg += 40
				If !Empty(MsgInstr01)
					oPrn:Say( _nLinMsg, 0220, SubStr(MsgInstr01,1,77) ,oFont18,100  )
					_nLinMsg += 40
				EndIf
				If !Empty(MsgInstr02)
					oPrn:Say( _nLinMsg, 0220, SubStr(MsgInstr02,1,77) ,oFont18,100  )
					_nLinMsg += 40
				EndIf
				If !Empty(_cMensJur)
					oPrn:Say( _nLinMsg, 0220, SubStr(_cMensJur ,1,77) ,oFont18,100  )
					_nLinMsg += 40
				EndIf
				If !Empty(_cMensDesc)
					oPrn:Say( _nLinMsg, 0220, SubStr(_cMensDesc,1,77) ,oFont18,100  )
					_nLinMsg += 40
				EndIf
				If !Empty(MsgInstr03)
					_cTxt   := AllTrim(MsgInstr03)
					_nLnTot := MlCount(_cTxt ,100)
					While !Empty(_cTxt)
						_cTexto := IIF(CHR(10)$_cTxt,SubStr(_cTxt,1,AT(CHR(10),_cTxt)-1),AllTrim(_cTxt))
						_cTxt   := IIF(CHR(10)$_cTxt,SubStr(_cTxt,AT(CHR(10),_cTxt)+1),"")
						If !Empty(_cTexto)
							_nMem1 := MlCount(_cTexto,100)
							For _nLoop := 1 To _nMem1
								oPrn:Say(_nLinMsg,0220,MemoLine(StrTran(_cTexto,CHR(13),""),100,_nLoop),oFont18,100  )
								_nLinMsg += 40
						  	Next
						EndIf
					EndDo
				EndIf
		
				oPrn:Say( 2475, 1730, "(-) Outras deduções "   ,oFont13,100  )
				oPrn:Say( 2545, 1730, "(+) Mora/Multa/Juros "  ,oFont13,100  )
				oPrn:Say( 2615, 1730, "(+) Outros Acrecimos "  ,oFont13,100  )
				oPrn:Say( 2685, 1730, "(=) Valor do Documento ",oFont13,100  )
		
				oPrn:Say( 2745, 0220, "Pagador"                 ,oFont13,100  )
				oPrn:Say( 2770, 0240, SE1->E1_CLIENTE+SE1->E1_LOJA + " - " + ALLTRIM(SA1->A1_NOME) , oFont12,100  )
				If !Empty(_cCompl)
					oPrn:Say( 2810, 0240, ALLTRIM(_cEndc) + " - " + Alltrim(_cCompl), oFont12,100  )
				Else
					oPrn:Say( 2810, 0240, ALLTRIM(_cEndc), oFont12,100  )
				EndIf
				oPrn:Say( 2850, 0240, Substr(_cCEPc,1,5)+"-"+Substr(_cCEPc,6,3)+"  "+ALLTRIM(_cBair)+" - "+ALLTRIM(_cMunc)+"   "+_cEstc, oFont12,100  )
			//	oPrn:Say( 2890, 0240, _cCnpj        , oFont12,100  ) //Linha comentada por Adriano Leonardo em 16/07/2014 para correção do CNPJ, estava saindo o da SMO e não da SA1
		
				//Início - Trecho adicionado por Adriano Leonardo em 16/07/2014 para correção na rotina
					_cCGCCli := IIF(SA1->A1_PESSOA=="J", Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99"))
					oPrn:Say( 2890, 0240, _cCGCCli, oFont12,100  )
				//Final  - Trecho adicionado por Adriano Leonardo em 16/07/2014 para correção na rotina
	
				oPrn:Say( 3010, 1450, "FICHA DE COMPENSAÇÃO - AUTENTICAÇÃO MECÂNICA",oFont24,100  )
			//	If _lImprPDF <> 1
			//		MSBAR("INT25",26.0,2.2,Alltrim(cBarra),oPrn,.F.,,.T.,0.025,1.3,NIL,NIL,NIL,.F.)		//impressão normal
			//	Else
				// - ALTERADO EM 19/03/2014 POR Júlio Soares PARA AJUSTAR ALTURA DA IMPRESSÃO.
				//	MSBAR("INT25",25.5,1.8,Alltrim(cBarra),oPrn,.F.,,.T.,0.025,1.3,NIL,NIL,NIL,.F.)		//altura para impressoras PDF
					MSBAR("INT25",26,1.8,Alltrim(cBarra),oPrn,.F.,,.T.,0.025,1.3,NIL,NIL,NIL,.F.)		//altura para impressoras PDF
			//	EndIf
	
		//-----------------------------------------------------------------------------------------------------------------------
			//Gravação do nosso número na SE1
				/* FB - RELEASE 12.1.23
				If ExistBlock("RFATL001") //.AND. !Empty(SE1->E1_NUMBCO)
				*/
				If _lRFATL001 				
					U_RFATL001(	SE1->E1_PEDIDO,;
								"",;
								"SE1 - Tit.: "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+" / N.N. Ant.: "+SE1->E1_NUMBCO+" / N.N. Novo: "+SubStr(NOSSONUM,Len(AllTrim(SEE->EE_CODEMP))+1),;
								_cRotina,;
								"Houve alteração no Nosso Número, de '"+SE1->E1_NUMBCO+"' para '"+SubStr(NOSSONUM,Len(AllTrim(SEE->EE_CODEMP))+1)+"', para o título de chave '"+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+"', carteira '"+SE1->E1_CARTEIR+"'. Verifique! Seguem os Índices/RECNOs atuais: SEE (índice "+cValToChar(SEE->(IndexOrd()))+" / recno "+cValToChar(SEE->(Recno()))+") / SE1 (índice "+cValToChar(SE1->(IndexOrd()))+" / recno "+cValToChar(SE1->(Recno()))+")" )
				EndIf
				dbSelectArea("SE1")
				while !RecLock("SE1",.F.) ; enddo
					SE1->E1_PORTADO := SEE->EE_CODIGO
					SE1->E1_AGEDEP  := SEE->EE_AGENCIA
					SE1->E1_CONTA   := SEE->EE_CONTA
					SE1->E1_CONVEN  := SEE->EE_CODEMP										//Guardo o código do convênio separadamente
					SE1->E1_NUMBCO  := SubStr(NOSSONUM,Len(AllTrim(SEE->EE_CODEMP))+1)		//Guardo o nosso número sem o Código do Convênio e sem o Dígito Verificador
				SE1->(MsUnLock())
			//Fim da Gravação do nosso número na SE1
		//-----------------------------------------------------------------------------------------------------------------------
		//Finalização da página de impressão e while
			oPrn:EndPage()
			_nQtdBole++	 //Incrementa a variável de controle da quantidade de boletos gerados
			dbSelectArea("SE1TMP")
			SE1TMP->(dbSkip())
		//Fim da Finalização da página de impressão e while
	EndDo
	dbSelectArea("SE1TMP")
	SE1TMP->(dbCloseArea())
	//Inicio - Trecho adicionado por Adriano Leonardo em 28/02/14 - Inclusão de envio por e-mail
		If _lEnvBol .And. _nQtdBole>0
			If oPrn:SaveAllAsJpeg(_cArqBol,0798,1129,130)
				_aAnexo   := aSort(_aAnexo,,,{|x,y| x[03] < y[03]})
				_aArquivo := {}
				_nVarIni  := 1
				For _nF := 1 To Len(_aAnexo)
					While _nF <= Len(_aAnexo) .AND. (_nF == _nVarIni .OR. _aAnexo[_nF][03] == _aAnexo[_nF-1][03])
						If !(_aAnexo[_nF][Len(_aAnexo[_nF])] := File(_aAnexo[_nF][01]))
							Alert("Atenção!!! Problemas na geração do arquivo " + _aAnexo[_nF][01] + ". Portanto, este arquivo não será enviado por e-mail ao cliente " + _aAnexo[_nF][03] + ", no e-mail " + _aAnexo[_nF][02] + "!")
						Else
							AADD(_aArquivo,_aAnexo[_nF])
						EndIf				
						_nF++
					EndDo
					_nVarIni  := _nF
					_aArquivo := {}
					_nF--
				Next
			Else
				MsgAlert("Atenção! Não foi possível gerar os arquivos de boleto para envio por e-mail!", _cRotina+"_012")
			EndIf
		EndIf
		If _lImprime .And. _nQtdBole>0
			oPrn:Preview()
		EndIf
	//Final  - Trecho adicionado por Adriano Leonardo em 28/02/14 - Inclusão de envio por e-mail
return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcLinDigºAutor  ³Anderson C. P. Coelho º Data ³  23/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-Rotina utilizada para formar/calcular a Linha Digitávelº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function CalcLinDig()
	Local _aSeq      := {2,1}
	Local _nSeq      := 0
	Local _nRegCont  := 0
	Local _nSomaDg   := 0
	Local _x         := 0
	for _nLnClcD := 1 to 3		//composição dos 03 campos da linha digitável com os seus dígitos verificadores
		_nSeq      := 0
		_nRegCont  := 0
		_nSomaDg   := 0
		If _nLnClcD == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cálculo do Primeiro Campo.                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLinha    := SubStr(cBarra,01,04)									//Posição 001 a 004 do Cód. Barras (Banco e Moeda)
			cLinha    += SubStr(cBarra,20,01) + "." + SubStr(cBarra,21,04)		//Posição de 020 a 024 do Cód. Barras
			_nSeq     := 0
			_nRegCont := Len(AllTrim(cLinha))
		ElseIf _nLnClcD == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cálculo do Segundo Campo.                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLinha    := SubStr(cBarra,25,05) + "." + SubStr(cBarra,30,05)		//Posição de 025 a 034 do Cód. Barras
			_nSeq     := 0
			_nRegCont := Len(AllTrim(cLinha))
		ElseIf _nLnClcD == 3
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cálculo do Terceiro Campo.                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLinha    := SubStr(cBarra,35,05) + "." + SubStr(cBarra,40,05)		//Posição de 035 a 044 do Cód. Barras
			_nSeq     := 0
			_nRegCont := Len(AllTrim(cLinha))
		EndIf
		for _x := 1 to _nRegCont
			If SubStr(cLinha,((_nRegCont-_x)+1),1) == "."
				Loop
			EndIf
			If _nSeq==Len(_aSeq)
				_nSeq := 0
			EndIf
			_nSeq++
			_cVal  := cValToChar(VAL(SubStr(AllTrim(cLinha),((_nRegCont-_x)+1),1))*_aSeq[_nSeq])
			for _s := 1 To Len(AllTrim(_cVal))
				_nSomaDg += VAL(SubStr(AllTrim(_cVal),_s,1))
			next
		next
		_nCont1                          := INT(_nSomaDg/10)
		_nCont2                          := _nCont1 * 10
		_nResto                          := _nSomaDg - _nCont2
		_cDv                             := StrZero(IIF(_nResto>0,10-_nResto,0),1)
		&("cLinha"+cValToChar(_nLnClcD)) := cLinha+_cDv+Space(01)
	next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Composição Final da Linha Digitável                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("cLinha1")<>"U".AND.Type("cLinha2")<>"U".AND.Type("cLinha3")<>"U"
		cLinha := cLinha1+cLinha2+cLinha3+SubStr(cBarra,05,01)+Space(01)+SubStr(cBarra,06,14)		//Campos 1, 2 e 3, mais o Dígito Verificador do Código de Barras [01], mais o Fator de Vencimento [04], mais o valor [10]
	Else
		MsgStop("Atenção! Problemas na composição da linha digitável. Contate o administrador!",_cRotina+"_013")
	EndIf
return cLinha
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CDigCodBarºAutor  ³Anderson C. P. Coelho º Data ³  23/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-Rotina de cálculo do dígito verificador do Código de   º±±
±±º          ³Barras.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function CDigCodBar()
	Local _nRegCont  := Len(AllTrim(cBarra))		//A posição do Dígito Verificador foi reservada com o caracter "#"
	Local _aSeq      := {9,8,7,6,5,4,3,2}
	Local _nSeq      := 0
	Local _nSomaDg   := 0
	Local _x         := 0
	for _x := 1 to _nRegCont
		If SubStr(cBarra,((_nRegCont-_x)+1),1) == "#"
			Loop
		EndIf
		If _nSeq==Len(_aSeq)
			_nSeq := 0
		EndIf
		_nSeq++
		_nSomaDg += VAL(SubStr(AllTrim(cBarra),((_nRegCont-_x)+1),1))*_aSeq[_nSeq]
	next
	_nCont1      := INT(_nSomaDg/11)
	_nCont2      := _nCont1 * 11
	_nResto      := _nSomaDg - _nCont2
	If _nResto == 0 .OR. _nResto >= 10
		_nResto := "1"
	Else
		_nResto := StrZero(_nResto,1)
	EndIf
	cBarra := StrTran(cBarra,"#",_nResto)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Anderson C. P. Coelho º Data ³  20/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-rotina utilizada para verificar se as perguntas ja     º±±
±±º          ³estao cadastradas na SX1, as criando, caso nao existam.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ValidPerg()
	Local _aSArea  := GetArea()
	Local aRegs    := {}
	cPerg          := PADR(cPerg,10)
	_aTam := TamSx3("E1_PREFIXO")
	AAdd(aRegs,{cPerg,"01","Prefixo de         ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	AAdd(aRegs,{cPerg,"02","Prefixo ate        ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := TamSx3("E1_NUM"    )
	AAdd(aRegs,{cPerg,"03","Numero de          ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR03",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	AAdd(aRegs,{cPerg,"04","Numero ate         ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR04",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := TamSx3("E1_NUMBOR" )
	AAdd(aRegs,{cPerg,"05","Bordero de         ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR05",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	AAdd(aRegs,{cPerg,"06","Bordero ate        ?","","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR06",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := TamSx3("E1_EMISSAO")
	AAdd(aRegs,{cPerg,"07","Emissao de         ?","","","mv_ch7",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR07",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	AAdd(aRegs,{cPerg,"08","Emissao ate        ?","","","mv_ch8",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR08",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := TamSx3("E1_VENCTO" )
	AAdd(aRegs,{cPerg,"09","Vencimento de      ?","","","mv_ch9",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR09",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	AAdd(aRegs,{cPerg,"10","Vencimento Ate     ?","","","mv_cha",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR10",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := TamSx3("C5_NUM"    )
	AAdd(aRegs,{cPerg,"11","Do Pedido de Vendas?","","","mv_chb",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR11",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SC5","",""})
	AAdd(aRegs,{cPerg,"12","Ao Pedido de Vendas?","","","mv_chc",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR12",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SC5","",""})
	_aTam := TamSx3("EE_CODIGO" )
	AADD(aRegs,{cPerg,"13","Banco              ?","","","mv_chd",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR13",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SA6","",""})
	_aTam := TamSx3("EE_AGENCIA")
	AADD(aRegs,{cPerg,"14","Agencia            ?","","","mv_che",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR14",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := TamSx3("EE_CONTA"  )
	AADD(aRegs,{cPerg,"15","Conta              ?","","","mv_chf",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR15",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	_aTam := TamSx3("EE_SUBCTA" )
	AADD(aRegs,{cPerg,"16","Sub-Conta          ?","","","mv_chg",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR16",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	AADD(aRegs,{cPerg,"17","Msg 01 só p/ boleto?","","","mv_chh","C"      ,60       ,0        ,0,"G",""          ,"MV_PAR17",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	AADD(aRegs,{cPerg,"18","Msg 02 só p/ boleto?","","","mv_chi","C"      ,60       ,0        ,0,"G",""          ,"MV_PAR18",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	for i := 1 to Len(aRegs)
		dbSelectArea("SX1")
		SX1->(dbSetOrder(1))
		If !SX1->(dbSeek(cPerg+aRegs[i,2]))
	        while !RecLock("SX1",.T.) ; enddo
				for J:= 1 to FCount()
					If J <= Len(aRegs[i])
						FieldPut(J,aRegs[i,j])
					Else
						Exit
					EndIf
				next
			SX1->(MsUnlock())
		EndIf
	next
	RestArea(_aSArea)
return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ SendMail  ºAutor ³ Adriano Leonardo de Souza Data ³22/08/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±± ºDesc.   ³ Função responsável pelo envio automático dos boletos por    ¹±±
±±  		³ e-mail.                                                     ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso  P11  ³ Uso específico - Arcolor - Programa principal              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
static function SendMail()
	//Resgata parâmetros para envio de e-mail
	Local _aSavx    := GetArea()
	Local _aSavSA1x := SA1->(GetArea())
	Local _aSavSE1x := SE1->(GetArea())
	_cClient 	:= ""
	_cLoja 		:= ""
	_cNumPed	:= ""
	dbSelectArea("SE1")
	//dbSetOrder(23)
	SE1->(dbOrderNickName("E1_NUM"))
	If SE1->(MsSeek(xFilial("SE1") + _cNumTitu,.T.,.F.))
		_cClient    := SE1->E1_CLIENTE
		_cLoja 	    := SE1->E1_LOJA
		_cNumPed	:= SE1->E1_PEDIDO
	EndIf
	//Monta conteúdo do e-mail
	_cHTML      := "<HTML><HEAD><TITLE></TITLE>"
	_cHTML      += "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
	_cHTML      += "<META content='MSHTML 6.00.6000.16735' name=GENERATOR></HEAD>"
	_cHTML      += "<BODY>"   		 //Inicia conteudo do e-mail
	_cHTML      += "<H4><B><Font Face = 'Arial' Size = '2'><P>Prezado Cliente: </P>"
	_cHTML      += "<P>Você esta recebendo uma cópia do(s) boleto(s) referente(s) à compra efetuada na Arcolor. "
	_cHTML      += "Essa cópia poderá ser utilizada para pagamento, até o vencimento, caso não tenha recebido o original via correio.</P>"
	_cHTML      += "<P>Qualquer dúvida entrar em contato com Alecssandra, pelo telefone (011) 2191-2444 Ramal 410.</P>"
	_cHTML      += "</B><P><I>Este e-mail foi enviado automaticamente pelo sistema Protheus. (Não responder)</I></P></H4><BR>"
	_cHTML      += "<P>&nbsp;</P>"
	_cHTML      += "</A></P></BODY>" //Finaliza conteudo do e-mail
	_cHTML      += "</HTML>"
	//cTitulo 	:= "Arcolor - Boleto de Cobrança referente a NF: " + AllTrim(_cNumTitu) + "-" + AllTrim(_cPrefixo)
	cTitulo 	:= "Boleto de Cobrança referente a NF: " + AllTrim(_cNumTitu) + "-" + AllTrim(_cPrefixo)
	_cNumerAux	:=	AllTrim(_cNumTitu)	//Armazena o número da nota
	_cSerieAux	:=	AllTrim(_cPrefixo)	//Armazena a série da nota
	_cMensagem 	:= _cHTML
	lOk 	 	:= .T.
	If !_lEnvBol
		_nTtlParc := TtlParc(_cNumTitu,_cPrefixo)
	Else
		If _lImprime .And. _lOpcoes
			_nTtlParc := TtlParc("","",_cPedido, DtoS(_cEmissao))
		Else
			_nTtlParc := TtlParc("","",_cPedido, _cEmissao)
		EndIf
	EndIf
	_cAnexo := ""
	If _lEnvBol //.And. !(_cTransp $ SuperGetMv("MV_AIBTRAN" ,,"INDEFINIDO" )) //Trecho comentado em 19/09/2013 por Adriano Leonardo a pedido do Sr. Marco
		_nQtdAnexo := 0
		For nCont  := 1 To _nTtlParc
			_cAux  := "\Boletos\BOL_" + AllTrim(_cNumTitu) + "_" + AllTrim(_cPrefixo) + "_pag" + Alltrim(Str(nCont)) + ".JPG"
		 	//Verifica a existência do arquivo, para que o mesmo seja anexado
			If File (_cAux)
				If nCont==1
					_cAnexo  := _cAux
					_nQtdAnexo++
				Else
					_cAnexo  += ";" + _cAux
					_nQtdAnexo++
				EndIf 
			EndIf
		Next nCont
		_cMensag := ""
	EndIf
	If !Empty(_cRomaneio) .And. _lEnvRom
	 	//Verifica a existência do arquivo, para que o mesmo seja anexado
		If File (_cRomaneio)
			_cAnexo += _cRomaneio
		EndIf		
	EndIf
	cIndice := _cAnexoAux + OrdBagExt()
	//Verifica a existência do arquivo, para que o mesmo seja anexado
	If File (_cAnexoAux)
		If Empty(_cAnexo) .And. _lEnvRom
			_cAnexo += _cAnexoAux
		ElseIf !Empty(_cAnexoAux)
			_cAnexo += ";" + _cAnexoAux
		EndIf
	EndIf
	If !Empty(_cDanfe)
		If !Empty(_cAnexo)
			_cAnexo += ";" + _cDanfe
		Else
		    _cAnexo += _cDanfe
		EndIf
	EndIf
	If Empty(_cAnexo)
		MSGBOX("Não existe nenhum arquivo para envio por e-mail!" ,_cRotina + "_014","ALERT")
		Return(.F.)
	EndIf
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(XFILIAL("SA1") + _cCliente +_cLojaCli,.T.,.F.))
		If !Empty(SA1->A1_EMAIL2)
			_cMail := AllTrim(SA1->A1_EMAIL2) + IIF(Empty(SA1->A1_EMAIL2),"",";") + SuperGetMv("MV_FATCCO",,"") //"; ale.primilla@arcolor.com.br; vanessa.silva@arcolor.com.br
		Else
			_cMail := IIF(!Empty(_cEndEmail),_cEndEmail + "; ","") + SuperGetMv("MV_FATCCO",,"") //"ale.primilla@arcolor.com.br; vanessa.silva@arcolor.com.br
		EndIf
	EndIf
	_cCco := SuperGetMv("MV_FATCCO",,"") //vanessa.silva@arcolor.com.br; ale.primilla@arcolor.com.br"
	If !("BOL_" $ Upper(_cAnexo)) .And. ("DANFE" $ Upper(_cAnexo)) .And. SuperGetMv("MV_ENVSBOL",,.F.)
		//Monta conteúdo do e-mail para os casos em que não há boletos e no anexo vai somente a Danfe
		_cHTML2 := "<HTML><HEAD><TITLE></TITLE>"
		_cHTML2 += "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
		_cHTML2 += "<META content='MSHTML 6.00.6000.16735' name=GENERATOR></HEAD>"
		_cHTML2 += "<BODY>"   		 //Inicia conteudo do e-mail
		_cHTML2 += "<H4><B><Font Face = 'Arial' Size = '2'><P>Prezado Cliente: </P>"
		_cHTML2 += "<P>Esta mensagem refere-se a Nota Fiscal Eletrônica Nacional de serie/número [" + _cSerieAux + "/" + _cNumerAux + "] emitida para: "
		_cHTML2 += "Razão Social: [ARCO IRIS BRASIL IND. COM. PROD. ALIM. LTDA] CNPJ: [52.072.238/0001-26]</P>"
		_cHTML2 += "<P>Qualquer dúvida entrar em contato com Alecssandra, pelo telefone (011) 2191-2444 Ramal 410.</P>"
		_cHTML2 += "</B><P><I>Este e-mail foi enviado automaticamente pelo sistema Protheus. (Não responder)</I></P></H4><BR>"
		_cHTML2 += "<P>&nbsp;</P>"
		_cHTML2 += "</A></P></BODY>" //Finaliza conteudo do e-mail
		_cHTML2 += "</HTML>"
		_cMensagem := _cHTML2
	EndIf
	If !("BOL_" $ Upper(_cAnexo)) .And. !("DANFE" $ Upper(_cAnexo)) .And. ("ROMANEIO" $ Upper(_cAnexo))
		//Monta conteúdo do e-mail para os casos em que não há boletos e no anexo vai somente a Danfe
		_cHTML3    := "<HTML><HEAD><TITLE></TITLE>"
		_cHTML3    += "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
		_cHTML3    += "<META content='MSHTML 6.00.6000.16735' name=GENERATOR></HEAD>"
		_cHTML3    += "<BODY>"   		 //Inicia conteudo do e-mail
		_cHTML3    += "<H4><B><Font Face = 'Arial' Size = '2'><P>Prezado Cliente: </P>"
		_cHTML3    += "<P>Pedimos que confira a sua solicitação em anexo.</P> "
		_cHTML3    += "<P>Qualquer dúvida entrar em contato com Alecssandra, pelo telefone (011) 2191-2444 Ramal 410.</P>"
		_cHTML3    += "</B><P><I>Este e-mail foi enviado automaticamente pelo sistema Protheus. (Não responder)</I></P></H4><BR>"
		_cHTML3    += "<P>&nbsp;</P>"
		_cHTML3    += "</A></P></BODY>" //Finaliza conteudo do e-mail
		_cHTML3    += "</HTML>"
		_cMensagem := _cHTML3
	EndIf                                                                                         
	If !_lCancela .And. ("BOL_" $ Upper(_cAnexo)) .Or. SuperGetMv("MV_ENVSBOL",,.F.) .Or. ("ROMANEIO_" $ Upper(_cAnexo)) //Parâmetro utilizado para definir se haverá o envio do e-mail quando não houver boleto
		//Verifica se a rotina irá esperar o envio do e-mail ou deixará que este seja realizado em segundo plano
		If SuperGetMv("MV_ENVBOLT",,.F.)
			If ExistBlock("RFINE015")
				StartJob("U_RFINE015",GetEnvServer(),.F.,cTitulo,_cMensagem,_cMail,_cAnexo,,_cCco) // Inicia o Job
			Else
				MsgAlert("Favor informar ao Administrador que a rotina RFINE015 precisa ser compilada!", _cRotina + "_015")
		    EndIf
		Else
			U_RCFGM001(cTitulo,_cMensagem,_cMail,_cAnexo,,_cCco) //Chamada da rotina responsável pelo envio de e-mails
		EndIf
	Else
		MsAguarde({|lEnd|DeletTmp()},"Aguarde...","Finalizando processo...",.T.) //Chamada da rotina de deleção dos arquivos temporários
	EndIf
	If !(SuperGetMv("MV_ENVBOLT",,.F.)) .Or. _lCancela
		MsAguarde({|lEnd|DeletTmp()},"Aguarde...","Finalizando processo...",.T.) //Chamada da rotina de deleção dos arquivos temporários
	EndIf
	RestArea(_aSavSE1x)
	RestArea(_aSavSA1x)
	RestArea(_aSavx)
return .T.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ DeletTmp  ºAutor ³ Adriano Leonardo de Souza Data ³22/08/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±± ºDesc.   ³ Função responsável deletar os arquivos temporários.         ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso  P11  ³ Uso específico - Arcolor - Programa principal              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
static function DeletTmp()
	If !Empty(_cAnexo) .And. ";" $ _cAnexo
		_aAnexo := StrTokArr(_cAnexo,";")
		For nCont2 := 1 To Len(_aAnexo)
			fErase(_aAnexo[nCont2])
		Next
	Else 
		fErase(_cAnexo)
	EndIf	
return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ TtlParc   ºAutor ³ Adriano Leonardo de Souza Data ³22/08/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±± ºDesc.   ³ Função responsável por retornar o número de parcelas a ser  ¹±±
±±  		³ processadas para envio como anexo.                          ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso  P11  ³ Uso específico - Arcolor - Programa principal              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
static function TtlParc(_cNumNf, _cSerie, _cPNumPed, _cPEmissao)
Local cAlias := "TRBPRC"
	_cQuery := " SELECT COUNT(SE1.E1_NUM) AS [NUM_PARC] "
	_cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	_cQuery += " WHERE SE1.E1_FILIAL  = '" + xFilial("SE1")+ "' "
	If Empty(_cPNumPed)
		_cQuery += "   AND SE1.E1_NUM      = '" + _cNumNF + "' "
		_cQuery += "   AND SE1.E1_SERIE    = '" + _cSerie + "' "
	Else
		_cQuery += "   AND SE1.E1_PEDIDO   = '" + _cPNumPed + "' "
		_cQuery += "   AND SE1.E1_EMISSAO  = '" + _cPEmissao + "' "
	EndIf
	_cQuery += "  AND SE1.D_E_L_E_T_ = '' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TRBPRC",.T.,.F.)
	dbSelectArea("TRBPRC")
	TRBPRC->(dbGoTop())
		_nTotal := TRBPRC->NUM_PARC
	TRBPRC->(dbCloseArea())
return(_nTotal)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Dias()   ºAutor  ³ Júlio Soares        º Data ³  21/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cálculo de dias úteis para validação de data do vencimento.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa Arcolor                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function Dias()
	_nCont := 1
	_dData := SE1->E1_VENCTO
	while  _nCont <= IIF(SE1->E1_DIASPRO > 0, SE1->E1_DIASPRO, SZI->ZI_DIASPRO)
		_dData := _dData + 1 //(incrementar 1 dia no vencimento)
		If _dData == DataValida(_dData,.T.)
			_nCont++
		EndIf
	enddo
return _dData
