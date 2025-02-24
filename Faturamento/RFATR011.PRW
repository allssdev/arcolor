#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE _CLRF CHR(13) + CHR(10)
/*/{Protheus.doc} RFATR011
@description Impressão do Romaneio de Entrega em PDF, com envio por e-mail.
@author Anderson C. P. Coelho
@since 16/05/2013
@version 1.0
@history 26/08/2013, Adriano Leonardo, Melhorias tratadas. 
@type function
@see https://allss.com.br
@history 23/04/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), adequação do titulo do e-mail removendo as palavras maiscuslas devido a restrições da localweb
/*/
user function RFATR011(_cPv,_dEmisNF,_lImprime, _lEnvMail, cDanfe, _cHora,_cRomn)
	Local _aSvArea         := GetArea()
	Local _aSvSF2          := SF2->(GetArea())
	Local _aSvSD2          := SD2->(GetArea())


	
	Private _cRomn := ""
	Private _nNumPag       := 0
	Private _nLin          := 0
	Private _nLimite       := 2900
	Private _nSaltoL       := 35
	Private _nValMerc      := 0
	Private _nTotalNf      := 0
	Private _nValIPI       := 0
	Private _nValST        := 0
	Private _cRotina       := "RFATR011"
	Private Titulo         := _cRotina+"_Romaneio de Entrega"
	Private cPerg          := _cRotina
	Private _cFromOri      := ""
	Private _cMail         := ""
	Private _cMsg          := ""
	Private _cAnexo        := ""
	Private _cPesVol       := ""
	Private _cMenInfo      := ""
	Private _cObsCond	   := ""
	Private _cNumTit       := ""
	Private _cPrefix	   := ""
	Private _cCarteir	   := ""
	Private _cDescPag      := ""
	Private _lAuto		   := _lImprime
	Private _lEnvBol       := _lEnvMail
	Private _cDanfe		   := cDanfe
	//Início - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
	Private _cHoraAux	   := _cHora
	Private _cTimeMin	   := ""
	Private _cTimeMax	   := ""
	//Fim - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
	Private _cCartPar      := SuperGetMv("MV_CARTPAR",,"17/109")



	default _cPv           := ""
	default _dEmisNF       := STOD("")
	default _lImprime	   := .F.
	default _lEnvMail	   := .F.
	default cDanfe		   := ""
	default _cHora		   := ""
	default _cRomn 		   := ""

	dbSelectArea("SF2")
	dbSelectArea("SD2")
	//Início - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
	If !Empty(_cHoraAux)
		_nVariac := SuperGetMv("MV_VARIAMI",,5) //Parâmetro com delay máximo entre faturamento da nota e geração do romaneio
		cHora 	 := SUBSTR(_cHoraAux, 1, 2)
		cMinutos := SUBSTR(_cHoraAux, 4, 2)
		If (Val(cMinutos)+_nVariac)>59
			cHoraMax 	:= StrZero(Val(cHora)+1,2)
			cMinuMax	:= StrZero((Val(cMinutos)-60)+_nVariac,2)
		Else
			cHoraMax 	:= StrZero(Val(cHora),2)
			cMinuMax	:= StrZero(Val(cMinutos)+_nVariac,2)
		EndIf
		If (Val(cMinutos)-_nVariac)<0
			cHoraMin 	:= StrZero(Val(cHora)-1,2)
			cMinuMin	:= StrZero((Val(cMinutos)-60)-_nVariac,2)
		Else
			cHoraMin 	:= StrZero(Val(cHora),2)
			cMinuMin	:= StrZero(Val(cMinutos)-_nVariac,2)
		EndIf
		_cTimeMin := AllTrim(cHoraMin) + ":" + AllTrim(cMinuMin)
		_cTimeMax := AllTrim(cHoraMax) + ":" + AllTrim(cMinuMax)
	EndIf
	//Fim - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
	
	If MsgYesNo("Imprime Romaneio N° '"+ SF2->F2_DOC +"' posicionado ?",_cRotina+"_011")
	
		dbSelectArea("SF2")
		dbSelectArea("SD2")
		SD2->(dbSetOrder(3))
		If SD2->(MsSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.T.,.F.))
			_cPv     := SD2->D2_PEDIDO
			_dEmisNF := SD2->D2_EMISSAO
		EndIf
	
		MV_PAR01 := _cPv
		MV_PAR02 :=_dEmisNF
		MV_PAR03 := 1
		Processa({|lEnd| Imprime(@lEnd,_cRomn)},Titulo,"Processando a impressão...",.T.)	
	Else
		ValidPerg()
		If FunName() == "RFATR011"
			If !Pergunte(cPerg,.T.)
				RestArea(_aSvSD2)
				RestArea(_aSvSF2)
				RestArea(_aSvArea)
				return
			Else
				_cFromOri := AllTrim(UsrRetMail(__cUserId))
			EndIf
		Else
			Pergunte(cPerg,.F.)
			If Empty(_cPv)
				dbSelectArea("SF2")
				dbSelectArea("SD2")
				SD2->(dbSetOrder(3))
				If SD2->(MsSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.T.,.F.))
					_cPv     := SD2->D2_PEDIDO
					_dEmisNF := SD2->D2_EMISSAO
				EndIf
			EndIf
			If !Empty(_cPv)
				MV_PAR01 := _cPv
				MV_PAR02 := _dEmisNF
				MV_PAR03 := 1
				/*
				MV_PAR04 := "CASO O AVISO DE COBRANCA NAO CHEGUE EM ATE 48 HORAS ANTES DO VENCIMENTO, LIGUE PARA (11) 2191-2444."
				MV_PAR05 := "NAO ACEITAMOS DEVOLUCAO OU TROCA DE MISTURA P/PANETONE E CREME TIPO CHANTILLY."
				MV_PAR06 := "NAO ACEITAMOS DEV./TROCA DOS DEMAIS PRODUTOS APOS SUA VALIDADE."
				MV_PAR07 := ""
				MV_PAR08 := ""
				MV_PAR09 := ""
				MV_PAR10 := ""
				MV_PAR11 := ""
				MV_PAR12 := ""
				MV_PAR13 := ""
				*/
			Else
				If !Pergunte(cPerg,.T.)
					RestArea(_aSvSD2)
					RestArea(_aSvSF2)
					RestArea(_aSvArea)
					return
				EndIf
			EndIf
		EndIf
		// Exibe tela de carregamento da rotina
		If FunName() == "RFATR011"
			_cDivid := POSICIONE("SC5",1,xFilial("SC5")+MV_PAR01,"C5_TPDIV")
		Else
			_cDivid := POSICIONE("SC5",1,xFilial("SC5")+_cPv,"C5_TPDIV")
		EndIf
		
		
		If _cDivid $ "1|2|3" 
			_cQry := ""
			_cQry += " SELECT COUNT(*)[CONT]
			_cQry += " FROM
			_cQry += " 	(	SELECT D2_EMISSAO,D2_PEDIDO,D2_SERIE
			_cQry += " 		FROM "  + RetSqlName("SD2") + " SD2  (NOLOCK) "
			_cQry += " 		WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
			If AllTrim(FunName()) == "RFATR011"
				_cQry += " 		AND SD2.D2_PEDIDO   = '"+MV_PAR01+"'"
				_cQry += " 		AND SD2.D2_EMISSAO  = '"+DTOS(MV_PAR02)+"'"
		    Else
				_cQry += " 		AND SD2.D2_PEDIDO   = '"+_cPv+"'"
				_cQry += " 		AND SD2.D2_EMISSAO  = '"+DTOS(_dEmisNF)+"'"
			EndIf
			_cQry += " 		AND SD2.D_E_L_E_T_  = '' "
			_cQry += " 		GROUP BY D2_EMISSAO,D2_PEDIDO,D2_SERIE
			_cQry += " 	) TX
			If Select("SD2TMP") > 0
				SD2TMP->(dbCloseArea())
			EndIf
			_cQry  := ChangeQuery(_cQry)
			dbUseArea(.T., 'TOPCONN', TCGenQry(,,_cQry),'SD2TMP', .F., .T.)
		
			dbSelectArea("SD2TMP")
			If SD2TMP->CONT == 2
				Processa({|lEnd| Imprime(@lEnd), _cRomn},Titulo,"Processando a impressão...",.T.)
			Else
				MSGBOX('ATENÇÃO!!! '+_CLRF+'Houve problemas no faturamento desse pedido e não foi gerado um dos documentos'+;
				' necessários. '+_CLRF+'Informe imediatamente o administrador do sistema.',_cRotina+'_001','')
			EndIf
		Else
			Processa({|lEnd| Imprime(@lEnd,_cRomn)},Titulo,"Processando a impressão...",.T.)
		EndIf
	EndIf	
	RestArea(_aSvSD2)
	RestArea(_aSvSF2)
	RestArea(_aSvArea)
return
/*/{Protheus.doc} Imprime
@description Processamento e impressão do relatório.
@author Anderson C. P. Coelho
@since 16/05/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Imprime(lEnd, _cRomn)
	Local cDrive, cDir, cNome, cExt
	Local _cArq            := ""
	Local cQuery1		   := ""
	Local _cTamFil         := "%"+cValToChar(TamSx3("F2_FILIAL")[01])+"%"
	Local _cTamDoc         := "%"+cValToChar(TamSx3("F2_DOC"   )[01])+"%"
	Local _cTamSer         := "%"+cValToChar(TamSx3("F2_SERIE" )[01])+"%"
	Local nUsaPDF          := IMP_PDF	//IMP_SPOOL
	Local lFormaTMSPrinter := .T.

	//Incluido por Fernando Bombardi - 10/02/2020 - Implementacao contorle de valores futuros para desconto em folha de pagamento
	Local _cCLIENTE        := ""
	Local _cLOJA           := ""
	Private oRFATR011      := RFATR011():NEW()
	// Fim FB

	BeginSql Alias "TRETMP"
		SELECT DISTINCT D2_CLIENTE,D2_LOJA,D2_TIPO,D2_PEDIDO,D2_ITEMPV,D2_COD,D2_UM,
		       D2_SERIE + ' ' + D2_DOC DOCTO,
		       SUM(CASE WHEN F4_ESTOQUE  = 'S' THEN D2_QUANT ELSE 0 END) QUANT,
		       (SUM(D2_TOTAL )/(CASE WHEN SUM(CASE WHEN F4_ESTOQUE = 'S' THEN D2_QUANT ELSE 0 END) = 0 THEN 1 ELSE SUM(CASE WHEN F4_ESTOQUE = 'S' THEN D2_QUANT ELSE 0 END) END) ) PRECO,
		       SUM(D2_TOTAL  ) VALMERC,
		       SUM(D2_VALBRUT) TOTALNF,
		       SUM(D2_VALIPI ) IPI,    
		       SUM(D2_ICMSRET) ST,     
		       MIN(F2_ESPECIE) ESPECIE,
		       CAST(F2_FILIAL AS CHAR(%Exp:_cTamFil%)) + CAST(F2_DOC   AS CHAR(%Exp:_cTamDoc%)) + CAST(F2_SERIE AS CHAR(%Exp:_cTamSer%)) NOTA,
		       CAST(F2_FILIAL AS CHAR(%Exp:_cTamFil%)) + CAST(F2_SERIE AS CHAR(%Exp:_cTamSer%)) + CAST(F2_DOC   AS CHAR(%Exp:_cTamDoc%)) NTIT,
		       MIN(F2_EMISSAO) EMISSAO,
		       MAX(F2_PBRUTO ) PBRUTO, 
		       MAX(F2_VOLUME1) VOLUME, 
		       MAX(F2_ENDEXP ) ENDEXP  
		FROM %table:SF2% SF2 (NOLOCK)
			INNER JOIN %table:SD2% SD2 (NOLOCK) ON SD2.D2_FILIAL = %xFilial:SD2%
	                                AND SD2.D2_PEDIDO   = %Exp:MV_PAR01%
	                                AND SD2.D2_EMISSAO  = %Exp:DTOS(MV_PAR02)%
	                                AND SD2.D2_EMISSAO  = SF2.F2_EMISSAO
	                                AND SD2.D2_DOC      = SF2.F2_DOC
	                                AND SD2.D2_SERIE    = SF2.F2_SERIE
	                                AND SD2.D2_CLIENTE  = SF2.F2_CLIENTE
	                                AND SD2.D2_LOJA     = SF2.F2_LOJA
	                                AND SD2.%NotDel%
			INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
	                                AND SF4.F4_CODIGO   = SD2.D2_TES
	                                AND SF4.%NotDel%
		WHERE SF2.F2_FILIAL      = %xFilial:SF2%
		  AND SF2.F2_EMISSAO     = %Exp:DTOS(MV_PAR02)%
		//  AND SF2.F2_HORA  BETWEEN (CASE WHEN %Exp:IIF(!Empty(_cHoraAux),'1','')% = '1'  THEN %Exp:_cTimeMin% ELSE SF2.F2_HORA END) AND (CASE WHEN %Exp:IIF(!Empty(_cHoraAux),'1','')% = '1'  THEN %Exp:_cTimeMax% ELSE SF2.F2_HORA END)
		  AND SF2.%NotDel%
		GROUP BY D2_CLIENTE,D2_LOJA,D2_TIPO,D2_PEDIDO,D2_ITEMPV,D2_COD,D2_UM ,D2_DOC, F2_DOC , D2_SERIE, F2_SERIE, F2_FILIAL 
		ORDER BY D2_CLIENTE,D2_LOJA,D2_TIPO,D2_PEDIDO,D2_ITEMPV,D2_COD,D2_UM,DOCTO
	EndSql
	dbSelectArea("TRETMP")
	ProcRegua(TRETMP->(RecCount()))
	TRETMP->(dbGoTop())
	If !TRETMP->(EOF())

		//Incluido por Fernando Bombardi - 10/02/2020 - Implementacao contorle de valores futuros para desconto em folha de pagamento
		_cCLIENTE := TRETMP->D2_CLIENTE
		_cLOJA    := TRETMP->D2_LOJA
		// Fim FB

		_cArq := StrTran(Titulo," ","_")+"_"+DTOS(dDataBase)+StrTran(Time(),":","")+".rel"
		Private oPrn           := FWMSPrinter():New(_cArq,nUsaPDF,lFormaTMSPrinter,,.T.,.F.,,"",.F.,.T.,.F.,.T.)
		Private oFont06        := TFont():New( "Arial",,06,,.F.,,,,.F.,.F. )
		Private oFont07        := TFont():New( "Arial",,07,,.F.,,,,.F.,.F. )
		Private oFont08        := TFont():New( "Arial",,08,,.F.,,,,.F.,.F. )
		Private oFont09        := TFont():New( "Arial",,09,,.F.,,,,.F.,.F. )
		Private oFont10        := TFont():New( "Arial",,10,,.F.,,,,.F.,.F. )
		Private oFont11        := TFont():New( "Arial",,11,,.F.,,,,.F.,.F. )
		Private oFont12        := TFont():New( "Arial",,12,,.F.,,,,.F.,.F. )
		Private oFont13        := TFont():New( "Arial",,13,,.F.,,,,.F.,.F. )
		Private oFont14        := TFont():New( "Arial",,14,,.F.,,,,.F.,.F. )
		Private oFont15        := TFont():New( "Arial",,15,,.F.,,,,.F.,.F. )
		Private oFont16        := TFont():New( "Arial",,16,,.F.,,,,.F.,.F. )
		Private oFont17        := TFont():New( "Arial",,17,,.F.,,,,.F.,.F. )
		Private oFont18        := TFont():New( "Arial",,18,,.F.,,,,.F.,.F. )
		Private oFont19        := TFont():New( "Arial",,19,,.F.,,,,.F.,.F. )
		Private oFont20        := TFont():New( "Arial",,20,,.F.,,,,.F.,.F. )
		Private oFont06N       := TFont():New( "Arial",,06,,.T.,,,,.F.,.F. )
		Private oFont07N       := TFont():New( "Arial",,07,,.T.,,,,.F.,.F. )
		Private oFont08N       := TFont():New( "Arial",,08,,.T.,,,,.F.,.F. )
		Private oFont09N       := TFont():New( "Arial",,09,,.T.,,,,.F.,.F. )
		Private oFont10N       := TFont():New( "Arial",,10,,.T.,,,,.F.,.F. )
		Private oFont11N       := TFont():New( "Arial",,11,,.T.,,,,.F.,.F. )
		Private oFont12N       := TFont():New( "Arial",,12,,.T.,,,,.F.,.F. )
		Private oFont13N       := TFont():New( "Arial",,13,,.T.,,,,.F.,.F. )
		Private oFont14N       := TFont():New( "Arial",,14,,.T.,,,,.F.,.F. )
		Private oFont15N       := TFont():New( "Arial",,15,,.T.,,,,.F.,.F. )
		Private oFont16N       := TFont():New( "Arial",,16,,.T.,,,,.F.,.F. )
		Private oFont17N       := TFont():New( "Arial",,17,,.T.,,,,.F.,.F. )
		Private oFont18N       := TFont():New( "Arial",,18,,.T.,,,,.F.,.F. )
		Private oFont19N       := TFont():New( "Arial",,19,,.T.,,,,.F.,.F. )
		Private oFont20N       := TFont():New( "Arial",,20,,.T.,,,,.F.,.F. )
		//oPrn:SetLandScape()	// Orientação do Papel (Paisagem)
		oPrn:SetPortrait()		// Orientação do Papel (Retrato)
		oPrn:SetPaperSize(9)	// Tamanho da Folha (9 = A4)
		//oPrn:Setup()
		//oPrn:SetPortrait()    // Orientação do Papel (Retrato)
		//	oPrn:cPathPDF := "C:\"
		_cPv   := ""
		_nCont := 0
		//CUSTOM. ALL - DATA: 11/06/2013 - AUTOR: Júlio Soares
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Trecho inserido para atualizar o status do campo E1_FLUXO no financeiro para "S".³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cNota := TRETMP->NOTA  // Filial + Numero da Nota + Série -> F2
			//_cDocn := TRETMP->NTIT  // Filial + Série + Numero da Nota -> E1
			//Trecho adicionado por Adriano Leonardo em 18/07/2013 pra implementar melhoria na busca das notas da serie "ZZZ"
			_cNotaAux := SubStr(_cNota,1,TamSx3("F2_FILIAL")[01])
			_cNotaAux += SubStr(_cNota,TamSx3(  "F2_FILIAL")[01] +   TamSx3("F2_DOC")[01] + 1,TamSx3("F2_FILIAL")[01]+TamSx3("F2_DOC")[01])
			_cNotaAux += SubStr(_cNota,TamSx3(  "F2_FILIAL")[01] + 1,TamSx3("F2_DOC")[01])
			//Fim do trecho adicionado por Adriano Leonardo em 18/07/2013
			If !TRETMP->(Alltrim(TRETMP->ESPECIE)) $ "SPED"
				dBSelectArea("SF2")
				SF2->(dbSetOrder(1))
				If SF2->(MsSeek(_cNota,.T.,.F.))
					_dEmis := SF2->F2_EMISSAO
					While !SF2->(EOF()) .AND. SF2->(xFilial("SF2") + F2_DOC + F2_SERIE) == _cNota .AND. F2_FIMP <> "S"
						while !RecLock("SF2",.F.) ; enddo
							//SF2->F2_FIMP 	:= "X" 	//Linha comentada por Adriano Leonardo em 25/09/2013 para implementação da legenda NFe-Sefaz para romaneios serie ZZZ
							SF2->F2_FIMP 	:= "S"  //Linha adicionada por Adriano Leonardo em 25/09/2013 para implementação da legenda NFe-Sefaz para romaneios serie ZZZ
							SF2->F2_USRSND	:= Alltrim(UsrRetName(__cUserId)) //Linha adicionada por Adriano Leonardo em 04/02/2014 para gravação do usuário que imprimiu o romaneio
						SF2->(MsUnLock())
						dBSelectArea("SF2")
						SF2->(dbSetOrder(1))
						SF2->(dbSkip())
					EndDo
				Else
					MSGBOX("A nota " + SF2->F2_SERIE + " - " + SF2->F2_DOC + " NÃO pôde ser atualizada, informe o Administrador do sistema",_cRotina + "_004" ,"ALERT")
					_dEmis := STOD("")
				EndIf
				dbSelectArea("SE1")
				SE1->(dbSetOrder(1))
				If SE1->(MsSeek(_cNotaAux,.T.,.F.))
					_cPed  := SE1->E1_PEDIDO
					dbSelectArea("SE1")
					SE1->(dbOrderNickName("E1_PEDIDO"))
					SE1->(dbGoTop())
					If SE1->(MsSeek(xFilial("SE1") + _cPed,.T.,.F.))
						While !SE1->(EOF()) .AND. SE1->E1_FILIAL == xFilial("SE1") .AND. SE1->E1_PEDIDO == _cPed
							If SE1->E1_FLUXO <> "S" .AND. SE1->E1_PEDIDO == _cPed .AND. SE1->E1_EMISSAO == _dEmis
								while !RecLock("SE1",.F.) ; enddo
									SE1->E1_FLUXO := "S"
								SE1->(MsUnLock())
							EndIf
							dbSelectArea("SE1")
							SE1->(dbOrderNickName("E1_PEDIDO"))
							SE1->(dbSkip())
						EndDo
					EndIf
				Else
					MSGBOX("O título " + SE1->E1_PREFIXO + " - " + SE1->E1_NUM + " NÃO foi atualizado no Financeiro, informe o Administrador do sistema ",_cRotina + "_005" ,"ALERT")
				EndIf
			EndIf



		//FIM - CUSTOM. ALL - DATA: 11/06/2013 - AUTOR: Júlio Soares
		While !TRETMP->(EOF())
			If Empty(TRETMP->ENDEXP)
				MsgAlert("O documento " + TRETMP->DOCTO + " não foi endereçado na expedição. Impressão do Romaneio não autorizada!",_cRotina+"_003")
				TRETMP->(dbSkip())
				Loop
				exit
			EndIf
			_nCont++
			IncProc(cValToChar(_nCont))
			If _cPv <> TRETMP->D2_PEDIDO
				If _nCont > 1
					If (_nLin+(_nSaltoL*4)) > _nLimite
						oPrn:EndPage()
						oPrn:StartPage()
						ImpCab()
						CabDocto(2)
					EndIf
					oPrn:Line(_nLin     , 0001, _nLin     , 2300, ,"-8")
					oPrn:Line(_nLin+0001, 0001, _nLin+0001, 2300, ,"-8")
					_nLin     += _nSaltoL
					oPrn:Say(_nLin, 1500,"MERCADORIAS"                               , oFont12 , 100,,,1)
				//	oPrn:Say(_nLin, 2000,Transform(_nValMerc,"@E 999,999,999,999.99"), oFont12 , 100,,,1)
					oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValMerc,"@E 999,999,999,999.99"), oFont12 , 2000,200,,1,1)
					_nLin     += _nSaltoL
					oPrn:Say(_nLin, 1500,"IPI"                                       , oFont12 , 100,,,1)
				//	oPrn:Say(_nLin, 2000,Transform(_nValIPI ,"@E 999,999,999,999.99"), oFont12 , 100,,,1)
					oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValIPI ,"@E 999,999,999,999.99"), oFont12 , 2000,200,,1,1)
					_nLin     += _nSaltoL
					oPrn:Say(_nLin, 1500,"SUBST.TRIB"                                , oFont12 , 100,,,1)
				//	oPrn:Say(_nLin, 2000,Transform(_nValST  ,"@E 999,999,999,999.99"), oFont12 , 100,,,1)
					oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValST  ,"@E 999,999,999,999.99"), oFont12 , 2000,200,,1,1)
					_nLin     += _nSaltoL
					oPrn:Say(_nLin, 1500,"TOTAL"                                     , oFont12N, 100,,,1)
				//	oPrn:Say(_nLin, 2000,Transform(_nTotalNf,"@E 999,999,999,999.99"), oFont12N, 100,,,1)
					oPrn:SayAlign(_nLin-0025, 0150,Transform(_nTotalNf,"@E 999,999,999,999.99"), oFont12N, 2000,200,,1,1)
					oPrn:EndPage()
					_nValMerc := 0
					_nTotalNf := 0
					_nValIPI  := 0
					_nValST   := 0
				EndIf
				oPrn:StartPage()
				ImpCab()
				CabDocto(1)
			EndIf
			If _nLin > _nLimite
				oPrn:EndPage()
				oPrn:StartPage()
				ImpCab()
				CabDocto(2)
			EndIf
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1") + TRETMP->D2_COD,.T.,.F.))
			oPrn:Say(_nLin, 0030,TRETMP->D2_COD                                       , oFont10 , 100,,,3)
			oPrn:Say(_nLin, 0300,SubStr(SB1->B1_DESC,1,60)                         , oFont10 , 100,,,3)
			oPrn:Say(_nLin, 1330,TRETMP->D2_UM                                        , oFont10 , 100,,,3)
			oPrn:Say(_nLin, 1400,Transform(TRETMP->QUANT     ,"@E 999,999,999,999.99"), oFont10 , 100,,,1)
			oPrn:Say(_nLin, 1700,Transform(TRETMP->PRECO     ,"@E 999,999,999,999.99"), oFont10 , 100,,,1)
			oPrn:Say(_nLin, 2000,Transform(TRETMP->VALMERC   ,"@E 999,999,999,999.99"), oFont10 , 100,,,1)
			_nLin     += _nSaltoL
			_nValMerc += TRETMP->VALMERC
			_nTotalNf += TRETMP->TOTALNF
			_nValIPI  += TRETMP->IPI
			_nValST   += TRETMP->ST
			_cPv      := TRETMP->D2_PEDIDO
			_cNumTit  := SubStr(TRETMP->DOCTO,5,TamSX3("E1_NUM")[01])
			_cPrefix  := SubStr(TRETMP->DOCTO,1,3)
			dbSelectArea("TRETMP")
			TRETMP->(dbSkip())
		EndDo
		If (_nLin+(_nSaltoL*4)) > _nLimite
			oPrn:EndPage()
			oPrn:StartPage()
			ImpCab()
			CabDocto(2)
		EndIf
		oPrn:Line(_nLin     , 0001, _nLin     , 2300, ,"-8")
		oPrn:Line(_nLin+0001, 0001, _nLin+0001, 2300, ,"-8")
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 1500,"MERCADORIAS"                               , oFont12 , 100,,,1)
	//	oPrn:Say(_nLin, 2000,Transform(_nValMerc,"@E 999,999,999,999.99"), oFont12 , 100,,,1)
		oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValMerc,"@E 999,999,999,999.99"), oFont12 , 2000,200,,1,1)
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 0030, _cPesVol                                             , oFont12N, 0100,   ,,3  )
		oPrn:Say(_nLin, 1500,"IPI"                                       , oFont12 , 100,,,1)
	//	oPrn:Say(_nLin, 2000,Transform(_nValIPI ,"@E 999,999,999,999.99"), oFont12 , 100,,,1)
		oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValIPI ,"@E 999,999,999,999.99"), oFont12 , 2000,200,,1,1)
		_nLin     += _nSaltoL
	// - INSERIDO POR JÚLIO SOARES EM 17/03/2014
		oPrn:Say(_nLin, 0030, _cMenInfo												,oFont12N, 0100,   ,,3  )
	
		oPrn:Say(_nLin, 1500,"SUBST.TRIB"                                , oFont12 , 100,,,1)
	//	oPrn:Say(_nLin, 2000,Transform(_nValST  ,"@E 999,999,999,999.99"), oFont12 , 100,,,1)
		oPrn:SayAlign(_nLin-0025, 0150,Transform(_nValST  ,"@E 999,999,999,999.99"), oFont12 , 2000,200,,1,1)
	// - FIM TRECHO INSERIDO POR JÚLIO SOARES EM 17/03/2014
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 0030, _cObsCond												,oFont12N, 0100,   ,,3  )  //Linha adicionada por Adriano Leonardo em 22/04/2014
		oPrn:Say(_nLin, 1500,"TOTAL"                                     , oFont12N, 100,,,1)
	//	oPrn:Say(_nLin, 2000,Transform(_nTotalNf,"@E 999,999,999,999.99"), oFont12N, 100,,,1)
		oPrn:SayAlign(_nLin-0025, 0150,Transform(_nTotalNf,"@E 999,999,999,999.99"), oFont12N, 2000,200,,1,1)

		//Incluido por Fernando Bombardi (ALLSS) - 10/01/2020 -  Implementacao contorle de valores futuros para desconto em folha de pagamento
		oRFATR011:AutorizacaoDescontoFolha(_cCLIENTE,_cLOJA,_nTotalNf)
		// Fim FB

		oPrn:EndPage()
		oPrn:Preview()
		If File(oPrn:cPathPDF+StrTran(_cArq,".rel",".pdf"))
			_cTpDiv   := ""
			_cTransp  := ""
			//Início do trecho adicionado por Adriano Leonardo em 26/08/2013
			//MV_AIBTRAN -- Parâmetro utilizado para definir quais transportadoras são de responsabilidade da Arcolor
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			If SC5->(MsSeek(xFilial("SC5")+_cPv,.T.,.F.))
				_cTpDiv  := SC5->C5_TPDIV
				_cTransp := SC5->C5_TRANSP
				If !SC5->C5_TIPO $ "D/B"
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					If SA1->(MsSeek(xFilial("SA1")+SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
						_cCarteir := SA1->A1_CDCART
					Else
						_cCarteir := ""
					EndIf
				EndIf
			EndIf
			If (ExistBlock("RFINR005") .Or. ExistBlock("RFINR017")) .Or. ExistBlock("RFINR018") .And. !Empty(_cMail) .And. (_cTpDiv == "0" .Or. _lEnvBol) /*.And. (_cTransp $ SuperGetMv("MV_AIBTRAN" ,,"NÃO DEFINIDO" )) */ .And. (SuperGetMv("MV_AUTOBOL",,.T.) .Or. AllTrim(__cUserId)=='000000') //.And. FunName()<>"SPEDNFE"
			//If (ExistBlock("RFINR005") .Or. ExistBlock("RFINR017")) .And. !Empty(_cMail) .And. (_cTpDiv == "0" .Or. _lEnvBol) /*.And. (_cTransp $ SuperGetMv("MV_AIBTRAN" ,,"NÃO DEFINIDO" )) */ .And. (SuperGetMv("MV_AUTOBOL",,.T.) .Or. AllTrim(__cUserId)=='000000') //.And. FunName()<>"SPEDNFE"
				_cNewArq := ""
				_cNewArq := "\workflow\"+StrTran(_cArq,".rel",".pdf")
				_cAnexo  := (oPrn:cPathPDF+StrTran(_cArq,".rel",".pdf"))
				CpyT2S(_cAnexo, "\boletos", .F.)
				//_cDanfe := _cCaminho + _cArquivo
				//Imprime o boleto na sequência e envia o romaneio por e-mail para o cliente
				If ExistBlock("RFINR005") .And. !(AllTrim(_cCarteir)) $ _cCartPar
					U_RFINR005(_cPrefix, _cNumTit, .T., .T. , .T. , .F., StrTran(_cNewArq,"\workflow\","\boletos\"),,,,_cDanfe,_cMail)
				ElseIf ExistBlock("RFINR017") .And. !(AllTrim(_cCarteir)) $ '109|112'
					U_RFINR017(_cPrefix, _cNumTit, .T., .T. , .T. , .F., StrTran(_cNewArq,"\workflow\","\boletos\"),,,,_cDanfe,_cMail)
				ElseIf ExistBlock("RFINR018") .And. (AllTrim(_cCarteir)) $ '109|112'
					U_RFINR018(_cPrefix, _cNumTit, .T., .T. , .T. , .F., StrTran(_cNewArq,"\workflow\","\boletos\"),,,,_cDanfe,_cMail)
				EndIf 
			//Fim do trecho adicionado por Adriano Leonardo em 26/08/2013
			ElseIf (MV_PAR03 == 1 .OR. FunName()=="SPEDNFE") .AND. !_lAuto .AND. ExistBlock("RCFGM001") .AND. !Empty(_cMail) .AND. MsgYesNo("Deseja enviar este documento para o e-mail " + AllTrim(_cMail) + " , neste momento?",_cRotina+"_002")
				_cAnexo  := (oPrn:cPathPDF+StrTran(_cArq,".rel",".pdf"))
				_cMsg    := "Prezado cliente, pedimos que confira a sua solicitação em anexo. " + CHR(13) + CHR(10)
				_cMsg    += "Em caso de dúvidas e/ou problemas, solicitamos que entre em contato conosco." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + CHR(13) + CHR(10)
				_cMsg    += "Atenciosamente, " + CHR(13) + CHR(10) + CHR(13) + CHR(10)
				_cMsg    += "Departamento de Vendas"
				_cNewArq := ""
	//			SplitPath(_cAnexo, @cDrive, @cDir, @cNome, @cExt)
				_cNewArq := "\workflow\"+StrTran(_cArq,".rel",".pdf")
				CpyT2S(_cAnexo, "\workflow", .F.)
				_cAnexo  := _cNewArq
				//U_RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri)
				_cCco := SuperGetMv("MV_FATCCO",,"") //"ale.primilla@arcolor.com.br
				U_RCFGM001(Titulo,_cMsg,_cMail,_cAnexo,_cFromOri,_cCco)
			EndIf
	//		FErase(_cAnexo)
		EndIf
	Else
		MsgAlert("Não há informações a serem impressas.",_cRotina+"_002")
	EndIf
	TRETMP->(dbCloseArea())
return
/*/{Protheus.doc} ImpCab
@description Sub-rotina de impressão do cabeçalho do relatório.
@author Anderson C. P. Coelho
@since 16/05/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ImpCab()
	_nNumpag++
	_nLin := 0010
	oPrn:Line(_nLin, 0001, _nLin, 2300, ,"-8")
	_nLin += _nSaltoL
	oPrn:Say(_nLin, 0015,ALLTRIM(cUserName)          , oFont09N, 100,,,3)
	oPrn:Say(_nLin, 2100,"Pág. "+cValToChar(_nNumpag), oFont09N, 100,,,3)
	_nLin += _nSaltoL
	oPrn:Say(_nLin, 0015,DTOC(dDataBase)+" "+Time()  , oFont09N, 100,,,3)
	oPrn:Say(_nLin, 2100,_cRotina                    , oFont09N, 100,,,3)
	//oPrn:Say(_nLin, 0850,SubStr(Titulo,10)           , oFont18N, 100,,,3)
	_nLin += _nSaltoL-0010
	oPrn:Line(_nLin, 0001, _nLin, 2300, ,"-8")
	_nLin += _nSaltoL+0020
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CabDocto  ºAutor  ³Anderson C. P. Coelho º Data ³  16/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Sub-Rotina utilizada para imprimir as informações de        º±±
±±º          ³cabeçalho do documento.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} CabDocto
@description Sub-Rotina utilizada para imprimir as informações de cabeçalho do documento.
@author Anderson C. P. Coelho
@since 16/05/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function CabDocto(_nOpc)
	Local cQuery1 := ""
	Local _k      := 0

	If _nOpc == 1
		cQuery1 := " SELECT DISTINCT D2_DOC "
		cQuery1 += " FROM " + RetSqlName("SD2") + " SD2 (NOLOCK) "
		//Início - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
		If !Empty(_cHoraAux)
			cQuery1 += " INNER JOIN " + RetSqlName("SF2") + " SF2  (NOLOCK) ON SF2.D_E_L_E_T_ = '' "
			cQuery1 += " AND SF2.F2_FILIAL              = '" + xFilial("SF2") + "' "
			cQuery1 += " AND SF2.F2_HORA  BETWEEN '" + _cTimeMin + "' AND '" + _cTimeMax + "' "	
			cQuery1 += " AND SD2.D2_DOC     = SF2.F2_DOC "
			cQuery1 += " AND SD2.D2_SERIE   = SF2.F2_SERIE "
			cQuery1 += " AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
			cQuery1 += " AND SD2.D2_LOJA    = SF2.F2_LOJA "
		EndIf
		//Fim - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
		cQuery1 += " WHERE SD2.D_E_L_E_T_             = '' "
		cQuery1 += "   AND SD2.D2_FILIAL              = '" + xFilial("SD2") + "' "
		cQuery1 += "   AND SD2.D2_PEDIDO              = '" + TRETMP->D2_PEDIDO + "' "
		cQuery1 += "   AND SD2.D2_EMISSAO             = '" + TRETMP->EMISSAO   + "' "
	//	cQuery1 += "   AND (SD2.D2_SERIE+SD2.D2_DOC) <> '" + TRETMP->DOCTO     + "' "
		cQuery1 += "   AND (SD2.D2_SERIE+' '+SD2.D2_DOC) <> '" + TRETMP->DOCTO     + "' "
		cQuery1 := ChangeQuery(cQuery1)
	//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.txt",cQuery1)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"TRE2TMP",.T.,.F.)
		dbSelectArea("TRE2TMP")
		_cDoc := ""
		If !TRE2TMP->(EOF())
			_cDoc := TRE2TMP->D2_DOC
		EndIf
		TRE2TMP->(dbCloseArea())
		oPrn:Say(_nLin, 0030,"Pedido: "  + TRETMP->D2_PEDIDO          , oFont10 , 100,,,3)
	//	oPrn:Say(_nLin, 0300,"Docto: "   + TRETMP->DOCTO              , oFont10 , 100,,,3) _cTpDiv
		oPrn:Say(_nLin, 0300,"Documentos: " + AllTrim(SubStr(TRETMP->DOCTO,1,3))+" / "+AllTrim(SubStr(TRETMP->DOCTO,4))+IIF(!Empty(_cDoc)," / "+AllTrim(_cDoc),""), oFont10 , 100,,,3)
		oPrn:Say(_nLin, 0900,"Emissão: " + DTOC(STOD(TRETMP->EMISSAO)), oFont10 , 100,,,3)
		_nLin += _nSaltoL
		_cNomCli := ""
		_cEndCli := ""
		_cTelCli := ""
		_cMail   := ""
		_cPesVol := ""
		If TRETMP->D2_TIPO $ "D/B"

			_cCLIENTE := TRETMP->D2_CLIENTE
			_cLOJA    := TRETMP->D2_LOJA

			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			If SA2->(MsSeek(xFilial("SA2")+TRETMP->D2_CLIENTE+TRETMP->D2_LOJA,.T.,.F.))
				_cNomCli := SA2->A2_NOME
				_cEndCli := AllTrim(SA2->A2_END)+" - "+AllTrim(SA2->A2_BAIRRO)+" - "+AllTrim(SA2->A2_MUN)+"/" + SA2->A2_EST+" - "+AllTrim(SA2->A2_CEP)
				_cTelCli := IIF(!Empty(SA2->A2_DDD),"("+AllTrim(SA2->A2_DDD)+") ","")+AllTrim(SA2->A2_TEL)
				_cMail   := AllTrim(LOWER(SA2->A2_EMAIL)) //+ IIF(!Empty(_cMailDvC).AND.!Lower(AllTrim(_cMailDvC))$_cMail,";"+Lower(AllTrim(_cMailDvC)),"")
			EndIf
		Else
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+TRETMP->D2_CLIENTE+TRETMP->D2_LOJA,.T.,.F.))
				_cNomCli := SA1->A1_NOME
				_cEndCli := AllTrim(SA1->A1_END)+" - "+AllTrim(SA1->A1_BAIRRO)+" - "+AllTrim(SA1->A1_MUN)+"/" + SA1->A1_EST+" - "+AllTrim(SA1->A1_CEP)
				_cTelCli := IIF(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+") ","")+AllTrim(SA1->A1_TEL)
				_cMail   := AllTrim(LOWER(SA1->A1_EMAIL2)) //+ IIF(!Empty(_cMailFat).AND.!Lower(AllTrim(_cMailFat))$_cMail,";"+Lower(AllTrim(_cMailFat)),"")
				_cCarteir:= SA1->A1_CDCART
			EndIf
		EndIf
		oPrn:Say(_nLin, 0030,"Cliente|Lj: "+TRETMP->D2_CLIENTE+"|"+TRETMP->D2_LOJA+" - "+_cNomCli, oFont10, 100,,,3)
		_nLin += _nSaltoL
		oPrn:Say(_nLin, 0030,"End.: "      +_cEndCli+IIF(!Empty(_cTelCli),"  Tel.: " + _cTelCli,"")/*+IIF(!Empty(_cMail),"   e-mail: "+_cMail,"")*/, oFont10, 100,,,3)
		_cPesVol  := "End. Exp.: "+TRETMP->ENDEXP + "   Peso Bruto: "+Transform(TRETMP->PBRUTO,"@E 999,999.999")+"   Volume: "+cValToChar(TRETMP->VOLUME)
		_cMenInfo := "#_" + Alltrim(_cCarteir) + "_" + Alltrim(Posicione("SC5",1,xFilial("SC5")+(TRETMP->D2_PEDIDO),"C5_DESCOND")) + "_# "
		//Início - Trecho adicionado por Adriano Leonardo em 17/04/2014 - para adição da observação da condição de pagamento
		dbSelectArea("SE4")
		If SE4->(FieldPos("E4_OBSNOTA"))<>0
			_cCondPag := Posicione("SC5",1,xFilial("SC5")+(TRETMP->D2_PEDIDO)	,"C5_CONDPAG")
			_cObsCond := AllTrim(Posicione("SE4",1,xFilial("SE4")+_cCondPag,"E4_OBSNOTA"))						
		EndIf
		//Final  - Trecho adicionado por Adriano Leonardo em 17/04/2014 - para adição da observação da condição de pagamento
		//Trecho adicionado por Adriano Leonardo
	//	INFORMAÇÃO RETIRADA, PARA IMPRESSÃO AO TÉRMINO DO DOCUMENTO
	//	_nLin += _nSaltoL
	//	oPrn:Say(_nLin, 0030, _cPesVol                                                                                                         , oFont11N, 100,,,3)
		ImpParc()
		/*
		If !Empty(MV_PAR04+MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR08+MV_PAR09+MV_PAR10+MV_PAR11+MV_PAR12+MV_PAR13)
			_nLin += _nSaltoL+0010
			oPrn:Say(_nLin, 0030,"MENSAGENS:"                               , oFont10, 100,,,3)
			If !Empty(MV_PAR04+MV_PAR05) .AND. !(MV_PAR04+" "+MV_PAR05)$AllTrim(FORMULA(SC5->C5_MENPAD))
				_nLin += _nSaltoL
				oPrn:Say(_nLin, 0045,AllTrim(MV_PAR04)+" "+AllTrim(MV_PAR05), oFont10, 100,,,3)
			EndIf
			If !Empty(MV_PAR06+MV_PAR07) .AND. !(MV_PAR06+" "+MV_PAR07)$AllTrim(FORMULA(SC5->C5_MENPAD))
				_nLin += _nSaltoL
				oPrn:Say(_nLin, 0045,AllTrim(MV_PAR06)+" "+AllTrim(MV_PAR07), oFont10, 100,,,3)
			EndIf
			If !Empty(MV_PAR08+MV_PAR09) .AND. !(MV_PAR08+" "+MV_PAR09)$AllTrim(FORMULA(SC5->C5_MENPAD))
				_nLin += _nSaltoL
				oPrn:Say(_nLin, 0045,AllTrim(MV_PAR08)+" "+AllTrim(MV_PAR09), oFont10, 100,,,3)
			EndIf
			If !Empty(MV_PAR10+MV_PAR11) .AND. !(MV_PAR10+" "+MV_PAR11)$AllTrim(FORMULA(SC5->C5_MENPAD))
				_nLin += _nSaltoL
				oPrn:Say(_nLin, 0045,AllTrim(MV_PAR10)+" "+AllTrim(MV_PAR11), oFont10, 100,,,3)
			EndIf
			If !Empty(MV_PAR12+MV_PAR13) .AND. !(MV_PAR12+" "+MV_PAR13)$AllTrim(FORMULA(SC5->C5_MENPAD))
				_nLin += _nSaltoL
				oPrn:Say(_nLin, 0045,AllTrim(MV_PAR12)+" "+AllTrim(MV_PAR13), oFont10, 100,,,3)
			EndIf
		EndIf
		*/
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		If SC5->(MsSeek(xFilial("SC5") + TRETMP->D2_PEDIDO,.T.,.F.))
			If !AllTrim(MV_PAR04)+" "+AllTrim(MV_PAR05)+" "+AllTrim(MV_PAR06)+" "+AllTrim(MV_PAR07)+" "+AllTrim(MV_PAR08)+;
			" "+AllTrim(MV_PAR09)+" "+AllTrim(MV_PAR10)+" "+AllTrim(MV_PAR11)+" "+AllTrim(MV_PAR12)+" "+AllTrim(MV_PAR13) ;
			$ AllTrim(FORMULA(SC5->C5_MENPAD))
				_cMsgPad := AllTrim(FORMULA(SC5->C5_MENPAD))
				_nTamMsg := MlCount(_cMsgPad,120)
				For _k := 1 To _nTamMsg
					_cMens := MemoLine(_cMsgPad,120,_k)
					While !Empty(_cMens)
						If CHR(13) + CHR(10) $ _cMens
							_cMsg := SubStr(_cMens,1,AT(CHR(13)+CHR(10),_cMens))
						Else
							_cMsg := _cMens
						EndIf
						_nLin += _nSaltoL
						oPrn:Say(_nLin, 0045,_cMsg, oFont10, 100,,,3)
						_cMens := SubStr(_cMens,Len(_cMsg)+1)
					EndDo
			  	Next
			EndIf
			/*
			_cMsgPad := AllTrim(SC5->C5_MENNOTA)
			While !Empty(_cMsgPad)
				_nLin += _nSaltoL
				oPrn:Say(_nLin, 0045,SubStr(_cMsgPad,1,100), oFont10, 100,,,3)
				_cMsgPad := SubStr(_cMsgPad,101)
			EndDo
			*/
		EndIf
		_nLin += _nSaltoL*0004
		oPrn:Say(_nLin, 0030,"RECEBEMOS _____________________________________________________________________________________________ - DATA ___________/___________/____________________", oFont10, 100,,,3)
		_nLin += _nSaltoL*0002
	EndIf
	oPrn:Say(_nLin, 0030,"Produto"                             , oFont10N, 100,,,3)
	oPrn:Say(_nLin, 0300,"Descrição"                           , oFont10N, 100,,,3)
	oPrn:Say(_nLin, 1325,"UM"                                  , oFont10N, 100,,,3)
	oPrn:Say(_nLin, 1415,"Quantidade"                          , oFont10N, 100,,,3)
	oPrn:Say(_nLin, 1770,"Preço"                               , oFont10N, 100,,,3)
	oPrn:Say(_nLin, 2050,"Val.Merc."                           , oFont10N, 100,,,3)
	_nLin += _nSaltoL-0010
	oPrn:Line(_nLin, 0001, _nLin, 2300, ,"-8")
	_nLin += _nSaltoL
return
/*/{Protheus.doc} ImpParc
@description Sub-Rotina utilizada para trazer as parcelas a receber.
@author Anderson C. P. Coelho
@since 16/05/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ImpParc()
	Local _aSavArea := GetArea()
	Local _nParc    := 0
	Local _aColPar  := {0030,0700,1370}

	_cQry := " SELECT E1_PARCELA, E1_VENCTO, E1_VALOR "
	_cQry += " FROM " + RetSqlName("SE1") + " SE1  (NOLOCK) "
	//Início - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
	If !Empty(_cHoraAux)
		_cQry += " INNER JOIN " + RetSqlName("SF2") + " SF2 "
		_cQry += "  (NOLOCK) ON SE1.E1_NUM=SF2.F2_DOC "
		_cQry += " AND SE1.E1_PREFIXO=SF2.F2_SERIE "
		_cQry += " AND SE1.E1_CLIENTE=SF2.F2_CLIENTE "
		_cQry += " AND SE1.E1_LOJA=SF2.F2_LOJA "
	EndIf
	//Fim - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
	_cQry += " WHERE SE1.D_E_L_E_T_       = '' "
	_cQry += "   AND SE1.E1_FILIAL        = '" + xFilial("SE1")  + "' "
	_cQry += "   AND SE1.E1_TIPO          = 'NF' "
	_cQry += "   AND SE1.E1_PEDIDO        = '" + TRETMP->D2_PEDIDO  + "' "
	_cQry += "   AND SE1.E1_EMISSAO       = '" + TRETMP->EMISSAO    + "' "
	_cQry += "   AND SE1.E1_CLIENTE       = '" + TRETMP->D2_CLIENTE + "' "
	_cQry += "   AND SE1.E1_LOJA          = '" + TRETMP->D2_LOJA    + "' "
	//Início - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
	If !Empty(_cHoraAux)
		_cQry += " AND SF2.D_E_L_E_T_             = '' "
		_cQry += " AND SF2.F2_FILIAL              = '" + xFilial("SF2") + "' "
		_cQry += " AND SF2.F2_HORA  BETWEEN '" + _cTimeMin + "' AND '" + _cTimeMax + "' "
	EndIf
	//Fim - Trecho adicionado por Adriano Leonardo em 21/01/2014 para melhoria na rotina
	_cQry += "ORDER BY E1_VENCTO, E1_PARCELA, E1_PREFIXO, E1_VALOR "
	_cQry   := ChangeQuery(_cQry)
	//If __cUserId == "000000"
	//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_003.TXT",_cQry)
	//EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SE1TMP",.T.,.F.)
	dbSelectArea("SE1TMP")
	SE1TMP->(dbGoTop())
	If !SE1TMP->(EOF())
		_nLin += 0005
		While !SE1TMP->(EOF())
			_nLin    += _nSaltoL
			_nCntPar := 0
			While !SE1TMP->(EOF()) .AND. _nCntPar < 3
				_nCntPar++
				_nParc++
				oPrn:Say(_nLin, _aColPar[_nCntPar],"Vcto. " + cValToChar(_nParc) + ": " + DTOC(STOD(SE1TMP->E1_VENCTO)) + Space(02) + Transform(SE1TMP->E1_VALOR,"@E 999,999,999,999.99"), oFont10, 100,,CLR_HBLUE,3)
				dbSelectArea("SE1TMP")
				SE1TMP->(dbSkip())
			EndDo
		EndDo
		_nLin += 0005
	EndIf
	dbSelectArea("SE1TMP")
	SE1TMP->(dbCloseArea())
	RestArea(_aSavArea)
return
/*/{Protheus.doc} ValidPerg
@description Verifica se as perguntas existem na SX1. Caso não existam, as cria.
@author Anderson C. P. Coelho
@since 16/05/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	Local _sAlias := GetArea()
	Local aRegs   := {}
	Local i       := 0
	Local j       := 0

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg         := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	AADD(aRegs,{cPerg,"01","Pedido de Vendas      ?","","","mv_ch1" ,"C",06,0,0,"G","","mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SC5","",""})
	AADD(aRegs,{cPerg,"02","Emissão NF            ?","","","mv_ch2" ,"D",08,0,0,"G","","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,"",""})
	AADD(aRegs,{cPerg,"03","Envia E-Mail p/Cliente?","","","mv_ch3" ,"N",01,0,0,"C","","mv_par03","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""   ,"",""})
	For i := 1 To Len(aRegs)
		If !(_cAliasSX1)->(MsSeek(cPerg+aRegs[i,2],.T.,.F.))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				For j := 1 To FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Else
						Exit
					EndIf
				Next
			(_cAliasSX1)->(MsUnLock())
		EndIf
	Next
	RestArea(_sAlias)
return


/*/{Protheus.doc} RFATR011
	Classe para ser utilizada na impressao do romaneio
	@author Fernando Bombardi (ALLSS)
	@since 10/02/2020
	@version 1.0
	/*/
Class RFATR011
	
	Method New() CONSTRUCTOR
	Method AutorizacaoDescontoFolha()

EndClass

/*/{Protheus.doc} NEW
	Metodo constructor
	@author Fernando Bombardi (ALLSS)
	@since 10/02/2020
	@version 1.0
	/*/
Method NEW() class RFATR011
	
Return 

/*/{Protheus.doc} AutorizacaoDescontoFolha()
	(long_description)
	@author Fernando Bombardi
	@since 10/02/2020
	@version 1.0
	/*/
Method AutorizacaoDescontoFolha(_cCLIENTE,_cLOJA,_nVALORT) class RFATR011
Local _cFUNC   := GetNextAlias()
Local _nLINHAS := 0

    BEGINSQL ALIAS _cFUNC
        SELECT RA_NOME,RA_NUMCP,RA_SERCP,RJ_DESC
        FROM %table:SRA% SRA LEFT JOIN %table:SRJ% SRJ
		ON SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
        WHERE RA_FILIAL = %xFilial:SRA% 
        AND RA_CLIENTE = %exp:_cCLIENTE%
        AND RA_LOJACLI = %exp:_cLOJA%
        AND SRA.%notDel%
		AND SRJ.%notDel%
    ENDSQL
	dbSelectArea(_cFUNC)
	IF !(_cFUNC)->(EOF())

		_nLin     += _nSaltoL
		_nLin     += _nSaltoL
		oPrn:Box(_nLin+15,30,_nLin+520,2300)
		_nLin     += _nSaltoL
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 930,"*** Autorização de Desconto em Folha ***"                           , oFont14)
		_nLin     += _nSaltoL
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 0050,"Empregado: "                           , oFont10N)
		oPrn:Say(_nLin, 0220,ALLTRIM((_cFUNC)->RA_NOME)              , oFont10N)		
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 0050,"Função:    "                           , oFont10N)
		oPrn:Say(_nLin, 0220,(_cFUNC)->RJ_DESC                       , oFont10N)
		_nLin     += _nSaltoL
		oPrn:Say(_nLin, 0050,"CTPS:      "                           , oFont10N)
		oPrn:Say(_nLin, 0220,(_cFUNC)->RA_NUMCP + (_cFUNC)->RA_SERCP , oFont10N)
		_nLin     += _nSaltoL
		
		_cTEXTO := "O empregado aqui qualificado AUTORIZA o desconto em seus proventos, conforme prevê a cláusula 10ª da "
		_cTEXTO += "Convenção Coletiva, do valor de R$ " + ALLTRIM(Transform(_nVALORT,"@E 999,999,999,999.99")) + " (" + Extenso(_nVALORT) + "), referente a compra de "
		_cTEXTO += "produtos da empregadora conforme demonstrativo abaixo, conferido e assinado pelo empregado."

		_nLINHAST := MLCount(_cTEXTO,164)
		FOR _nLINHAS := 1 TO _nLINHAST
			_nLin     += _nSaltoL
			oPrn:Say(_nLin, 0050, memoline(_cTEXTO,164,_nLINHAS) , oFont10N, 100,,,3)
		NEXT

		_nLin += _nSaltoL*0004
		oPrn:Say(_nLin, 0050,"Assinatura: _____________________________________________________________________________________________", oFont10, 100,,,3)
		_nLin += _nSaltoL*0002

	ENDIF
    IF Select(_cFUNC) > 0
		(_cFUNC)->(dbCloseArea())
	ENDIF 

Return
