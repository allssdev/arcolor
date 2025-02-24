#include 'protheus.ch'
#include 'parmtype.ch'
Static cDirTmp := GetTempPath()
/*/{Protheus.doc} RGPER002
Calculo Premio Absenteismo
@author Ronaldo Silva (ALL System Solutions)
@since 01/2016
@version P12
@type Function
@param nulo, Nil, nenhum 
@return nulo, Nil 
@obs Sem observacoes ate o momento 
@see https://allss.com.br/
@history 16/07/2019, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adequacoes referentes a captura do salario-base
@history 23/07/2019, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adequacoes referentes a leitura do periodo, adequacao XML e validacoes diversas
@history 30/07/2019, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Disponibilizacao em ambiente oficial para validacao
@history 23/01/2020, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Diversas alterações - vide SVN.
/*/
User Function RGPER002()
Private cPerg 	:= "RGPER002"
Private lRet	:= .T. 
ValidPerg(cPerg)
If !Pergunte(cPerg, .T.)
	Return
EndIf
Processa({|| MyRel()})
Return lRet
/*
******************************************************************************
******************************************************************************
******************************************************************************
***Programa  'MyRel		*Autor  'Ronaldo Silva   		*Data '01/2016     ***
******************************************************************************
***Descricao 'Funcao responsavel pelo levantamento de dados e impressao	   ***
***          'do relatorio                                                 ***
******************************************************************************
***Uso		 'Programa Principal										   ***
******************************************************************************
******************************************************************************
******************************************************************************
*/
Static Function MyRel()
Local cIniPer   	:= mv_par08
Local cFimPer   	:= mv_par09
Local cRotina		:= AllTrim(FunName())
Local cAba			:= 'Premio ABS'
Local cAba2			:= 'Parametros'
Local cTitulo		:= 'Premio ABS - Periodo de avaliacao - de ' + AllTrim(DtoC(cIniPer)) + ' a ' + AllTrim(DtoC(cFimPer)) + ' - ordenado por centro de custo + matricula'
Local cTitulo2		:= 'Parametros utilizados'
Local cArquivo    	:= Lower(AllTrim(mv_par07))
Local _nABSSAL 		:= mv_par10
Local _nABSHRS 		:= mv_par11
Local _nABSPERC 	:= mv_par12
Local nValPer		:= 0
Local aPonMes		:= StrTokArr(AllTrim(GetMv("MV_PONMES")),"/")
Local cArea      	:= GetArea()
Local lOpen			:= .F.
Local cMotAus		:= GetMv("MV_XMOTAUS")
Local cQuery		:= ""
Local cTmp			:= ""
Local nQtdDias 		:= 0
Local nDiasProp		:= 0
Local cFerias		:= "NAO"
Local oFWMsExcel
Local oExcel
cIniPer				:= DtoS(cIniPer)
cFimPer				:= DtoS(cFimPer)
//----------------------------------------------------------------------------------------
//Inserida validacao com relacao as datas informadas no arquivo. Basicamente, teremos:
// nValPer == 1 -> Quando a data inicial e final informada nos parametros corresponder
// 					a uma "parte" do periodo atualmente aberto no Ponto Eletronico
//					(de acordo com conteudo encontrado no MV_PONMES)
// nValPer == 2 -> Quando a data inicial e final informada nos parametros se encaixa
//					totalmente no periodo atualmente aberto no Ponto Eletronico
//					(de acordo com conteudo encontrado no MV_PONMES)
// nValPer == 3 -> Quando a data inicial e final informada nos parametros NAO se encaixa
//					totalmente no periodo atualmente aberto do Ponto Eletronico
//					(de acordo com conteudo encontrado no MV_PONMES)
//----------------------------------------------------------------------------------------
If AllTrim(SubStr(cIniPer, 1, 6)) <> AllTrim(SubStr(cFimPer, 1, 6))
	If DateDiffMonth(StoD(cIniPer), StoD(cFimPer)) > 1
		Aviso('TOTVS', 'Intervalo informado nos parametros excede 2(dois) meses. Por gentileza, revisar os parametros e tentar novamente.', {'OK'}, 3, 'Cancelamento de operacao pela regra de negocio')
		nValPer := 0
	Else
		If (StoD(cIniPer) < StoD(AllTrim(aPonMes[1])) .AND. StoD(cFimPer) < StoD(AllTrim(aPonMes[1]))) .OR. (StoD(cIniPer) > StoD(AllTrim(aPonMes[2])) .AND. StoD(cFimPer) > StoD(AllTrim(aPonMes[2])))   
			nValPer := 3
			//Alert(AllTrim(Str(nValPer)))
		Else
			nValPer	:= 1
			//Alert(AllTrim(Str(nValPer)))
		EndIf
	EndIf
Else
	If StoD(cIniPer) >= StoD(AllTrim(aPonMes[1])) .AND. StoD(cFimPer) <= StoD(AllTrim(aPonMes[2]))
		nValPer := 2
		//Alert(AllTrim(Str(nValPer)))
	Else
		nValPer := 3
		//Alert(AllTrim(Str(nValPer)))		
	EndIf
EndIf
//----------------------------------------------------------------------------------------
//Inserida validacao com relacao ao preenchimento do nome do arquivo.
//----------------------------------------------------------------------------------------
If Empty(RetFileName(cArquivo)) 
	cArquivo := Lower(AllTrim(cArquivo)) + cRotina + '.xml'
EndIf
//----------------------------------------------------------------------------------------
//Inserida validacao com relacao as permissoes do usuario.
//----------------------------------------------------------------------------------------
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	Aviso('TOTVS', 'Usuario sem permissao para gerar relatorios em Excel. Informe o Administrador.', {'OK'}, 3, 'Cancelamento de operacao por falta de permissoes')
	nValPer := 0
EndIf
//----------------------------------------------------------------------------------------
//Inserida validacao quanto a existencia do MsExcel no computador que esta executando a 
//o "smartclient.exe"
//----------------------------------------------------------------------------------------
/*If !ApOleClient('MsExcel')
	Aviso('TOTVS', 'Excel nao esta instalado nessa estacao.', {'OK'}, 3, 'Cancelamento de operacao por ausencia de aplicativo')
	nValPer := 0
EndIf*/
If nValPer <> 0
	//Criando o objeto que ira gerar o conteudo do Excel
	oFWMsExcel := FWMSExcel():New()
	//----------------------------------------------------------------------------------------
	//Melhoria inserida, de maneira a tornar o arquivo gerado exportavel no formato ".xml"
	// - aba referente aos parametros do relatorio
	//----------------------------------------------------------------------------------------
	//Criando uma aba dentro do arquivo
	oFWMsExcel:AddWorkSheet(cAba2)
	//Criando a Tabela
	oFWMsExcel:AddTable(cAba2, cTitulo2)
	//Criando Colunas
	oFWMsExcel:AddColumn(cAba2, cTitulo2, 'Descricao'			, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba2, cTitulo2, 'Conteudo'			, 1, 1) //1 = Modo Texto
	_aSavArea	:= GetArea()
	_cAliasSX1 	:= "SX1"
	OpenSXS(Nil,Nil,Nil,Nil,FWCodEmp(),_cAliasSX1,"SX1",Nil,.F.)
	lOpen		:= Select(_cAliasSX1) > 0
	If lOpen
		dbSelectArea(_cAliasSX1)
		(_cAliasSX1)->(dbSetOrder(1))
		(_cAliasSX1)->(dbGoTop())
		cPerg 		:= PADR(cPerg, 10)
		_aPar		:= {}
		If (_cAliasSX1)->(dbSeek(cPerg))
			While !(_cAliasSX1)->(EOF()) .AND. (_cAliasSX1)->X1_GRUPO == cPerg
				If AllTrim((_cAliasSX1)->X1_GSC) == "C"
					AAdd(_aPar,{(_cAliasSX1)->X1_PERGUNT, &("(_cAliasSX1)->X1_DEF" + StrZero(&((_cAliasSX1)->X1_VAR01),2))})
				Else
					AAdd(_aPar,{(_cAliasSX1)->X1_PERGUNT, &((_cAliasSX1)->X1_VAR01)})
				EndIf
				dbSelectArea(_cAliasSX1)
				(_cAliasSX1)->(dbSetOrder(1))    
				(_cAliasSX1)->(dbSkip())
			EndDo
		EndIf
		If Len(_aPar) > 0
			For _nPosPar := 1 To Len(_aPar)
				oFWMsExcel:AddRow(cAba2, cTitulo2, _aPar[_nPosPar])
			Next
		EndIf
	EndIf
	RestArea(_aSavArea)
	//----------------------------------------------------------------------------------------
	//Melhoria inserida, de maneira a tornar o arquivo gerado exportavel no formato ".xml"
	// - aba referente aos dados do relatorio
	//----------------------------------------------------------------------------------------
	//Criando uma aba dentro do arquivo
	oFWMsExcel:AddworkSheet(cAba)
	//Criando a Tabela
	oFWMsExcel:AddTable(cAba, cTitulo)
	//Criando Colunas
	oFWMsExcel:AddColumn(cAba, cTitulo, "Centro de Custo"					, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba, cTitulo, "Matricula"							, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba, cTitulo, "Nome"								, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba, cTitulo, "Salario"							, 3, 3) //3 = Valor com R$
	oFWMsExcel:AddColumn(cAba, cTitulo, "Funcionario elegivel?"				, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba, cTitulo, "Perdeu por salario acima teto?"	, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba, cTitulo, "Perdeu por admissao?"				, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba, cTitulo, "Perdeu por afast.?"				, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba, cTitulo, "Perdeu por ausencia?"				, 1, 1) //1 = Modo Texto
	oFWMsExcel:AddColumn(cAba, cTitulo, "Férias no período?"				, 1, 1) //1 = Modo Texto	
	oFWMsExcel:AddColumn(cAba, cTitulo, "Horas ausencias"					, 2, 2) //2 = Valor sem R$
	oFWMsExcel:AddColumn(cAba, cTitulo, "Base de calculo"					, 3, 3) //3 = Valor com R$
	oFWMsExcel:AddColumn(cAba, cTitulo, "Valor premio"						, 3, 3) //3 = Valor com R$
	If Select("QRY1") <> 0
		dbSelectArea("QRY1")
		dbCloseArea()
	EndIf
	BEGINSQL Alias "QRY1"
		SELECT 
			RA_FILIAL FILIAL, RA_CC CC, RA_MAT MAT, RA_NOME NOME, 
			RA_SALARIO SALARIO, RA_ADMISSA ADMISSA, RA_XABS XABS  
		FROM 
			%table:SRA% AS SRA 
		WHERE 
			RA_FILIAL BETWEEN 	%Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND RA_MAT BETWEEN 	%Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND RA_CC BETWEEN 	%Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND (RA_DEMISSA = '' OR RA_DEMISSA >= %Exp:DtoS(FirstDay(StoD(cIniPer)))%)
			AND SRA.%NotDel% 
		ORDER BY 
			FILIAL, CC, MAT 
	ENDSQL
	dbSelectArea("QRY1")
	ProcRegua(RecCount())
	QRY1->(dbGoTop())
	While !QRY1->(EOF())
		cCC       	:= QRY1->CC
		cMatr     	:= QRY1->MAT
		cDirABS		:= QRY1->XABS
		cNomeFun  	:= AllTrim(QRY1->NOME)
		cAnMeAdm  	:= SubString(QRY1->ADMISSA, 1, 6)
		cABS      	:= "NAO"
		cSalario 	:= "NAO"
		cAdmissa 	:= "NAO"
		cFunDir 	:= "NAO"
		cAfast 		:= "NAO"
		cAusenc 	:= "NAO"
		nHrPrev   	:= 0.00
		nHrTrab 	:= 0.00
		nHrAuse 	:= 0.00
		nSalABS 	:= 0.00
		nValorABS 	:= 0.00
		dDataRef  	:= CtoD("01/" + SubStr(cFimPer, 5, 2) + "/" + SubStr(cFimPer, 1, 4))
		nSalAtu	 	:= fBusSal(dDataRef, dDataRef)
		cSalario  	:= IIf(nSalAtu < _nABSSAL					, "NAO", "SIM")
		cAdmissa  	:= IIf(cAnMeAdm < cIniPer                   , "NAO", "SIM")
		cFunDir		:= IIf(cDirABS == "1"                   	, "SIM", "NAO")
		cQuery		:= ""
		cTmp		:= ""
		nQtdDias	:= 0
		nDiasProp	:= 0
		cFerias		:= "NAO"		
		If cSalario == "NAO" .and. cAdmissa == "NAO" .and. cFunDir == "SIM"
			//---------------------------------------------
			// PERDEU POR AFASTAMENTO NO PERIODO SOLICITADO
			//---------------------------------------------
			cQuery := "SELECT 																																				"
			cQuery += "		TT.MATRIC AS MATRIC,																															"
			cQuery += "		TT.DT_FERIAS AS DT_FER,																															"
			cQuery += "		TT.TP_AFAST AS TP_AFT,																															"
			cQuery += "		TT.DT_INI AS DT_INI,																															"
			cQuery += "		TT.DT_FIM AS DT_FIM,																															"
			cQuery += "		TT.PROCESS AS PROCES,																															"
			cQuery += "		TT.PERIODO AS PER,																																"
			cQuery += "		ISNULL(TT.COLETIVA,'') AS FER_CLT,																												"
			cQuery += "		TT.FER_PAD AS QTD_FER,																															"
			cQuery += "		CASE																																			"
			cQuery += "			WHEN ISNULL(TT.COLETIVA,'') = 'S' THEN DATEDIFF(DAY, TT.DTINI, TT.DTFIM) + TT.FER_PAD 														"
			cQuery += "			WHEN ISNULL(TT.COLETIVA,'') = 'N' THEN DATEDIFF(DAY, TT.DTINI, TT.DTFIM)																	"
			cQuery += "			WHEN ISNULL(TT.COLETIVA,'') = '' THEN 0																										"
			cQuery += "		END AS QTD_DIAS,																																"
			cQuery += "		ISNULL(TT.DIAS_MES,0) AS DIAS_MES																												"
			cQuery += "FROM																																					"
			cQuery += "		(SELECT																																			"
			cQuery += "			SR8.R8_MAT AS MATRIC, 																														"
			cQuery += "			SR8.R8_DATA AS DT_FERIAS, 																													"
			cQuery += "			SR8.R8_TIPOAFA AS TP_AFAST, 																												"
			cQuery += "			SR8.R8_DATAINI AS DT_INI,																													"
			cQuery += "			SR8.R8_DATAFIM AS DT_FIM,																													"
			cQuery += "			SR8.R8_NUMID AS CHAVE, 																														"
			cQuery += "			SR8.R8_PROCES AS PROCESS, 																													"
			cQuery += "			SR8.R8_PER AS PERIODO,																														"
			cQuery += "			SRH.RH_XCOLET AS COLETIVA,																													"
			cQuery += "			RCF.RCF_DCALCM AS DIAS_MES,																													"			
			cQuery += "			T.FER_PAD AS FER_PAD,																														"
			cQuery += "			CONVERT(DATE, SUBSTRING(SR8.R8_DATAFIM,5,2) + '-' + SUBSTRING(SR8.R8_DATAFIM,7,2) + '-' + SUBSTRING(SR8.R8_DATAFIM,1,4)) AS DTINI,			"
			cQuery += "			EOMONTH(CONVERT(DATE, SUBSTRING(SR8.R8_DATAFIM,5,2) + '-' + SUBSTRING(SR8.R8_DATAFIM,7,2) + '-' + SUBSTRING(SR8.R8_DATAFIM,1,4))) AS DTFIM	"
			cQuery += "		FROM																																			"
			cQuery += "			(SELECT 																																	"
			cQuery += "				COUNT(X5_DESCRI) AS FER_PAD																												"
			cQuery += "			FROM 																																		"
			cQuery += 				RetSqlName("SX5") + " AS SX5 																											"
			cQuery += "			WHERE 																																		"
			cQuery += "				SX5.X5_FILIAL = '" 						+ xFilial("SX5") 		+ "'  																	"
			cQuery += "				AND SUBSTRING(SX5.X5_DESCRI,4,2) = '" 	+ SubStr(cFimPer,5,2) 	+ "' 																	"
			cQuery += "				AND SX5.X5_TABELA = '63'																												"			
			cQuery += "				AND SX5.D_E_L_E_T_ = ''																													"
			cQuery += "			) AS T,		 																																"
			cQuery += 			RetSqlName("SR8") + " AS SR8																												"
			cQuery += "			LEFT OUTER JOIN																																"
			cQuery += 				RetSqlName("SRH") + " AS SRH																											"
			cQuery += "			ON																																			"
			cQuery += "				SRH.RH_FILIAL = SR8.R8_FILIAL																											"
			cQuery += "				AND SRH.RH_MAT = SR8.R8_MAT																												"
			cQuery += "				AND SRH.RH_DATAINI = SR8.R8_DATAINI																										"
			cQuery += "				AND SRH.RH_DATAFIM = SR8.R8_DATAFIM																										"
			cQuery += "				AND SRH.D_E_L_E_T_ = ''																													"
			cQuery += "			LEFT OUTER JOIN																																"
			cQuery += 				RetSqlName("RCF") + " AS RCF																											"
			cQuery += "			ON																																			"
			cQuery += "				RCF.RCF_FILIAL = SR8.R8_FILIAL																											"
			cQuery += "				AND RCF.RCF_PROCES = SR8.R8_PROCES																										"
			cQuery += "				AND RCF.RCF_PER = SR8.R8_PER																											"
			cQuery += "				AND RCF.D_E_L_E_T_ = ''																													"
			cQuery += "		WHERE																																			"
			cQuery += "			SR8.R8_FILIAL = '" 				+ QRY1->FILIAL 		+ "' 																					"
			cQuery += "			AND SR8.R8_MAT = '" 			+ QRY1->MAT 		+ "' 																					"
			cQuery += "			AND (SR8.R8_DATAINI BETWEEN '" 	+ cIniPer 			+ "' AND '" + cFimPer + "' OR SR8.R8_DATAFIM BETWEEN '" + cIniPer + "' AND '" + cFimPer + "' OR SR8.R8_DATAFIM = '') "
			cQuery += "			AND SR8.D_E_L_E_T_ = '') AS TT																												"
			cQuery += "ORDER BY																																				"
			cQuery += "		TT.MATRIC, TT.DT_INI																															"
			cTmp   := GetNextAlias()
			if Select(cTmp) <> 0
				dbSelectArea(cTmp)
				(cTmp)->(dbCloseArea())
			endif
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmp, .T., .F.)
			MemoWrite(cDirTmp + cRotina + "_4.txt", cQuery)
			while (cTmp)->(!EOF())
				if !(cTmp)->TP_AFT $ cMotAus 
					cAfast 		:= "SIM"
					exit
				else 
					cAfast 		:= "NAO"
					cFerias		:= "SIM"
					nQtdDias	:= (cTmp)->DIAS_MES
					nDiasProp 	:= (cTmp)->QTD_DIAS
				endif
				(cTmp)->(dbSkip())
			enddo
			(cTmp)->(dbCloseArea())
			//------------------------------------------
			// PERDEU POR AUSENCIA NO PERIODO SOLICITADO
			//------------------------------------------
			If cAfast == "NAO"
				If Select("QRY2") <> 0
					dbSelectArea("QRY2")
					dbCloseArea()
				EndIf
				//Geracao de informacoes em meses "quebrados"
				If nValPer == 1
					BEGINSQL Alias "QRY2"
						SELECT 
							PC_FILIAL FILIAL, PC_MAT MAT, PC_DATA DATA, 
							P9_IDPON IDPON, PC_PD CEVENTO, P9_DESC DEVENTO, P9_BHORAS BHORAS, P9_CODFOL CODFOL, P9_TIPOCOD TIPO, P9_CLASEV CLASSE, PC_QUANTC QEVENTO, 
							PC_PDI PDI, PC_QUANTC QEVENTOI, 
							P6__ABS ABSENT, PC_ABONO CABONO, P6_DESC DABONO, P6_EVENTO DESCFOL, PC_QTABONO QABONO 
						FROM 
							%table:SPC% AS SPC 
							LEFT JOIN 
								%table:SP9% AS SP9 
							ON 
								P9_FILIAL = %xFilial:SP9% 
								AND P9_IDPON <> '' 
								AND PC_PD = P9_CODIGO 
								AND SP9.%NotDel%
							LEFT JOIN
								%table:SP6% AS SP6 
							ON 
								P6_FILIAL = %xFilial:SP6%
								AND ((PC_ABONO = P6_CODIGO ) 
								OR P6_CODIGO IS NULL) 
								AND SP6.%NotDel%
						WHERE 
							PC_FILIAL = %Exp:QRY1->FILIAL%
							AND PC_MAT = %Exp:QRY1->MAT% 
							AND PC_DATA BETWEEN %Exp:DtoS(FirstDay(StoD(cFimPer)))% AND %Exp:cFimPer%
							AND (P9_IDPON IN ('005A','006A') OR  P6__ABS = 'S')
							AND SPC.%NotDel%
						UNION ALL
						SELECT 
							PH_FILIAL FILIAL, PH_MAT MAT, PH_DATA DATA, 
							P9_IDPON IDPON, PH_PD CEVENTO, P9_DESC DEVENTO, P9_BHORAS BHORAS, P9_CODFOL CODFOL, P9_TIPOCOD TIPO, P9_CLASEV CLASSE, PH_QUANTC QEVENTO, 
							PH_PDI PDI, PH_QUANTI QEVENTOI, 
							P6__ABS ABSENT, PH_ABONO CABONO, P6_DESC DABONO, P6_EVENTO DESCFOL, PH_QTABONO QABONO 
						FROM 
							%table:SPH% AS SPH 
							LEFT JOIN 
								%table:SP9% AS SP9 
							ON 
								P9_FILIAL = %xFilial:SP9% 
								AND P9_IDPON <> '' 
								AND PH_PD = P9_CODIGO 
								AND SP9.%NotDel% 
							LEFT JOIN 
								%table:SP6% AS SP6 
							ON 
								P6_FILIAL = %xFilial:SP6% 
								AND (PH_ABONO = P6_CODIGO 
								OR P6_CODIGO IS NULL) 
								AND SP6.%NotDel% 
						WHERE 
							PH_FILIAL = %Exp:QRY1->FILIAL%
							AND PH_MAT    = %Exp:QRY1->MAT% 
							AND PH_DATA BETWEEN %Exp:cIniPer% AND %Exp:DtoS(LastDay(StoD(cIniPer)))%
							AND (P9_IDPON IN ('005A','006A') OR  P6__ABS = 'S')
							AND SPH.%NotDel%
						ORDER BY 
							FILIAL, MAT, DATA, CEVENTO 
					ENDSQL
					MemoWrite(cDirTmp + cRotina + "_1.txt", GetLastQuery()[2])
				ElseIf nValPer == 2
					BEGINSQL Alias "QRY2"
						SELECT 
							PC_FILIAL FILIAL, PC_MAT MAT, PC_DATA DATA, 
							P9_IDPON IDPON, PC_PD CEVENTO, P9_DESC DEVENTO, P9_BHORAS BHORAS, P9_CODFOL CODFOL, P9_TIPOCOD TIPO, P9_CLASEV CLASSE, PC_QUANTC QEVENTO, 
							PC_PDI PDI, PC_QUANTC QEVENTOI, 
							P6__ABS ABSENT, PC_ABONO CABONO, P6_DESC DABONO, P6_EVENTO DESCFOL, PC_QTABONO QABONO 
						FROM 
							%table:SPC% AS SPC 
							LEFT JOIN 
								%table:SP9% AS SP9 
							ON 
								P9_FILIAL = %xFilial:SP9% 
								AND P9_IDPON <> '' 
								AND PC_PD = P9_CODIGO 
								AND SP9.%NotDel%
							LEFT JOIN
								%table:SP6% AS SP6 
							ON 
								P6_FILIAL = %xFilial:SP6%
								AND ((PC_ABONO = P6_CODIGO ) 
								OR P6_CODIGO IS NULL) 
								AND SP6.%NotDel%
						WHERE 
							PC_FILIAL = %Exp:QRY1->FILIAL%
							AND PC_MAT = %Exp:QRY1->MAT% 
							AND PC_DATA BETWEEN %Exp:DtoS(FirstDay(StoD(cIniPer)))% AND %Exp:DtoS(LastDay(StoD(cFimPer)))%
							AND (P9_IDPON IN ('005A','006A') OR  P6__ABS = 'S')
							AND SPC.%NotDel%
						ORDER BY 
							FILIAL, MAT, DATA, CEVENTO
					ENDSQL
					MemoWrite(cDirTmp + cRotina + "_2.txt", GetLastQuery()[2])
				ElseIf nValPer == 3
					BEGINSQL Alias "QRY2"
						SELECT 
							PH_FILIAL FILIAL, PH_MAT MAT, PH_DATA DATA, 
							P9_IDPON IDPON, PH_PD CEVENTO, P9_DESC DEVENTO, P9_BHORAS BHORAS, P9_CODFOL CODFOL, P9_TIPOCOD TIPO, P9_CLASEV CLASSE, PH_QUANTC QEVENTO, 
							PH_PDI PDI, PH_QUANTI QEVENTOI, 
							P6__ABS ABSENT, PH_ABONO CABONO, P6_DESC DABONO, P6_EVENTO DESCFOL, PH_QTABONO QABONO 
						FROM 
							%table:SPH% AS SPH 
							LEFT JOIN 
								%table:SP9% AS SP9 
							ON 
								P9_FILIAL = %xFilial:SP9% 
								AND P9_IDPON <> '' 
								AND PH_PD = P9_CODIGO 
								AND SP9.%NotDel% 
							LEFT JOIN 
								%table:SP6% AS SP6 
							ON 
								P6_FILIAL = %xFilial:SP6% 
								AND (PH_ABONO = P6_CODIGO 
								OR P6_CODIGO IS NULL) 
								AND SP6.%NotDel% 
						WHERE 
							PH_FILIAL = %Exp:QRY1->FILIAL%
							AND PH_MAT    = %Exp:QRY1->MAT% 
							AND PH_DATA BETWEEN %Exp:DtoS(FirstDay(StoD(cIniPer)))% AND %Exp:DtoS(LastDay(StoD(cFimPer)))%
							AND (P9_IDPON IN ('005A','006A') OR  P6__ABS = 'S')
							AND SPH.%NotDel%
						ORDER BY 
							FILIAL, MAT, DATA, CEVENTO
					ENDSQL
					MemoWrite(cDirTmp + cRotina + "_3.txt", GetLastQuery()[2])
				EndIf
				While !QRY2->(EOF()) .AND. cMatr == QRY2->MAT
					If QRY2->IDPON $ ("001A, 026A")
						nHrTrab := SomaHoras(QRY2->QEVENTO, nHrTrab)
					ElseIf QRY2->IDPON $ ("005A, 006A")
						nHrAuse := SomaHoras(QRY2->QEVENTO, nHrAuse)
					ElseIf QRY2->ABSENT == "S"
						nHrAuse := SubHoras(nHrAuse, QRY2->QABONO)
					EndIf
					QRY2->(dbSkip())
				EndDo
				nHrPrev := SomaHoras(nHrTrab, nHrAuse)
				dbSelectArea("QRY2")
				QRY2->(dbCloseArea())
			EndIf
		EndIf
		//------------------------------------------------------------------------------------------------------------------------------------------------------
		// GERA VERBA E IMPRIME FUNCIONARIO
		//------------------------------------------------------------------------------------------------------------------------------------------------------
		cAusenc 	:= IIf(nHrAuse <= _nABSHRS 					, "NAO", "SIM")
		If cSalario == "NAO" .AND. cAdmissa == "NAO" .AND. cFunDir == "SIM" .AND. cAfast == "NAO" .AND. cAusenc == "NAO"
			if cFerias = "SIM"
				cABS      	:= "SIM"
				nSalABS   	:= iif(nQtdDias > 0, ((nSalAtu / nQtdDias) * nDiasProp), nSalAtu)  
				nValorABS 	:= nSalABS * (_nABSPERC / 100)				
			else
				cABS      	:= "SIM"
				nSalABS   	:= nSalAtu
				nValorABS 	:= nSalABS * (_nABSPERC / 100)
			endif
		EndIf
		oFWMsExcel:AddRow(cAba, cTitulo,	{cCC			,;
											cMatr			,;
											cNomeFun		,;
											nSalAtu			,;
											cFunDir			,;
											cSalario		,;
											cAdmissa		,;
											cAfast			,;
											cAusenc			,;
											cFerias			,;											
											nHrAuse			,;
											nSalABS			,;
											nValorABS		})
		IncProc("Gravando informacoes, aguarde...")
		QRY1->(dbSkip())	
	EndDo
	dbSelectArea("QRY1")
	QRY1->(dbCloseArea())
	RestArea(cArea)
	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)
	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             	//Abre uma nova conexao com Excel
	oExcel:WorkBooks:Open(cArquivo)     	//Abre uma planilha
	oExcel:SetVisible(.T.)                 	//Visualiza a planilha
	oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
	Aviso('TOTVS', 'Arquivo gerado com sucesso! O arquivo esta gravado em ' + AllTrim(cArquivo) + '.', {'OK'}, 3, 'Arquivo processado')
EndIf
Return .T.
/*
******************************************************************************
******************************************************************************
******************************************************************************
***Programa  'ValidPerg	*Autor  'Ronaldo Silva   		*Data '01/2016     ***
******************************************************************************
***Descricao 'Funcao responsavel por criar as perguntas utilizadas no      ***
***          'relatorio													   ***
******************************************************************************
***Uso		 'Programa Principal										   ***
******************************************************************************
******************************************************************************
******************************************************************************
*/
Static Function ValidPerg(cPerg)
Local _sAlias 	:= GetArea()
Local aRegs   	:= {}
Local aRet		:= {}
Local i,j
Local _cAliasSX1:= "SX1"
Local lOpen		:= .F.
aRet := TamSX3("RA_FILIAL")
AAdd(aRegs,{cPerg,"01","Da Filial?"    				,"","","mv_ch1",aRet[3],aRet[1],aRet[2],0,"G",""			,"mv_par01",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","","SM0"	,"","",""})
AAdd(aRegs,{cPerg,"02","Ate a Filial?" 				,"","","mv_ch2",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par02",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","","SM0"	,"","",""})
aRet := TamSX3("CTT_CUSTO")
AAdd(aRegs,{cPerg,"03","Do C.Custo?"   				,"","","mv_ch3",aRet[3],aRet[1],aRet[2],0,"G",""			,"mv_par03",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","","CTT"	,"","",""})
AAdd(aRegs,{cPerg,"04","Ate C.Custo?"				,"","","mv_ch4",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par04",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","","CTT"	,"","",""})
aRet := TamSX3("RA_MAT")
AAdd(aRegs,{cPerg,"05","Da Matricula?" 				,"","","mv_ch5",aRet[3],aRet[1],aRet[2],0,"G",""			,"mv_par05",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","","SRA"	,"","",""})
AAdd(aRegs,{cPerg,"06","Ate a Matricula?"			,"","","mv_ch6",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par06",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","","SRA"	,"","",""})
AAdd(aRegs,{cPerg,"07","Diretorio p/Salvar Arq.?"   ,"","","mv_ch7","C"    ,90     ,0      ,0,"G",""			,"mv_par07",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","","DIR"	,"","",""})
aRet := TamSX3("PO_DATAINI")
AAdd(aRegs,{cPerg,"08","Do periodo?"      			,"","","mv_ch8",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par08",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","",""	,"","",""})
AAdd(aRegs,{cPerg,"09","Ate o periodo?"      		,"","","mv_ch9",aRet[3],aRet[1],aRet[2],0,"G","naovazio()"	,"mv_par09",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","",""	,"","",""})
aRet := TamSX3("RA_SALARIO")
AAdd(aRegs,{cPerg,"10","Salario teto para ABS?"   	,"","","mv_chA",aRet[3],aRet[1],aRet[2],0,"G","positivo()"	,"mv_par10",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","",""	,"","",""})
aRet := TamSX3("PC_QUANTC")
AAdd(aRegs,{cPerg,"11","Tol.Hrs?"   				,"","","mv_chB",aRet[3],aRet[1],aRet[2],0,"G","positivo()"	,"mv_par11",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","",""	,"","",""})
aRet := TamSX3("PC_QUANTC")
AAdd(aRegs,{cPerg,"12","Perc.ABS sobre salario?"	,"","","mv_chC",aRet[3],aRet[1],aRet[2],0,"G","positivo()"	,"mv_par12",""         ,"","","","",""         ,"","","","","","","","","","","","","","","","","","",""	,"","",""})
OpenSXS(Nil,Nil,Nil,Nil,FWCodEmp(),_cAliasSX1,"SX1",Nil,.F.)
lOpen			:= Select(_cAliasSX1) > 0
If lOpen 
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	For i := 1 to Len(aRegs)
		If !(_cAliasSX1)->(dbSeek(cPerg + Space(Len((_cAliasSX1)->X1_GRUPO) - Len(cPerg)) + aRegs[i,2]))
			RecLock(_cAliasSX1,.T.)
			for j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j, aRegs[i,j])
				EndIf
			Next
			MsUnlock()
		EndIf
	Next
EndIf
RestArea(_sAlias)
Return
/*
******************************************************************************
******************************************************************************
******************************************************************************
***Programa  'fBusSal 	*Autor  'Rodrigo Telecio   		*Data '16/07/2019  ***
******************************************************************************
***Descricao 'Funcao para busca do salario-base com base no historico de   ***
***          'alteracoes de salario 									   ***
******************************************************************************
***Uso		 'Programa Principal										   ***
******************************************************************************
******************************************************************************
******************************************************************************
*/
Static Function fBusSal(dDataDe,dDataAte,aSalario,lIncorpora) 
Local cTipo     := ""
Local nSalario 	:= 0.00
Local dDtAum	:= CTOD("")
Local dtHistSal	:= CTOD("")
Local lRetTotal	:= .T.
Local cUltAtu	:= "!!"
Local nP
//--Variaveis para Query SRD             
Local lQuery    := .F. 		// Indica se a query foi executada
Local cAliasSR3 := "SR3" 	// Alias da Query
Local aStruSR3  := {}       // Estrutura da Query
Local cQuery    := "" 		// Expressao da Query
Local nX
aSalario 		:= {}
//--Variavel para salario incorporado ou base .F.  Base  , .T. Total com Verbas que incorporam
lincorpora  := If (lIncorpora = Nil, .T. , lIncorpora)
If dDataAte == NIL .Or. dDataAte < dDataDe  // Caso a Data Ate nao seja definida
   dDataAte := dDataDe                      // a funcao retornara somente o ultimo 
   lRetTotal:= .F.                          // aumento Salarial.
EndIf	
dDataAtu 	:= dDataDe
lQuery 		:= .T.
cAliasSR3 	:= "QSR3"
aStruSR3  	:= If(Empty(aStruSR3), SR3->(dbStruct()), aStruSR3)
cQuery 		:= "SELECT													" 
cQuery 		+= "	* 													"
cQuery 		+= "FROM 													" 
cQuery 		+= 		RetSqlName("SR3") + " SR3 							"
cQuery 		+= "WHERE 													"
cQuery 		+= "	SR3.R3_FILIAL = '" 	+ QRY1->FILIAL 		+ "' AND 	"
cQuery 		+= "	SR3.R3_MAT = '" 	+ QRY1->MAT 		+ "' AND 	"
cQuery 		+= "	SR3.D_E_L_E_T_ = ' ' 								"
cQuery 		+= "ORDER BY 												"
cQuery 		+= 		SqlOrder(SR3->(IndexKey()))
cQuery 		:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSR3,.T.,.T.)	
For nX := 1 To Len(aStruSR3)
	If ( aStruSR3[nX][2] <> "C" )
		TcSetField(cAliasSR3, aStruSR3[nX][1], aStruSR3[nX][2], aStruSR3[nX][3], aStruSR3[nX][4])
	EndIf
Next nX
//--Monta array com a quantidade de meses do periodo solicitado
// Quando houver alteracoes salariais
If !EOF() .AND. (cAliasSR3)->R3_FILIAL + (cAliasSR3)->R3_MAT == QRY1->FILIAL + QRY1->MAT 
	While dDataAtu <= dDataAte
		Aadd(aSalario, {"", 0.00, MesAno(dDataAtu)})
		dDataAtu := CTOD( 	"01/" + If(Month(dDataAtu) + 1 > 12 								,;
					  		"01/" + StrZero(Year(dDataAtu) + 1, 4)								,;
					  		StrZero(Month(dDataAtu) + 1, 2) + "/" + StrZero(Year(dDataAtu), 4))	,;
					  		"DDMMYY")
	EndDo
	//-- Somar Salario da mesma data de aumento.
	While !EOF() .AND. (cAliasSR3)->R3_FILIAL + (cAliasSR3)->R3_MAT == QRY1->FILIAL + QRY1->MAT 
		cTipo		:= (cAliasSR3)->R3_TIPO
		dDtAum		:= If(!Empty((cAliasSR3)->R3_DTCDISS), (cAliasSR3)->R3_DTCDISS, (cAliasSR3)->R3_DATA)
		dtHistSal	:= (cAliasSR3)->R3_DATA
		nSalario	:= 0.00
		//--Somar salario da mesma data e tipo de aumento.
		While !EOF() .AND. (cAliasSR3)->R3_FILIAL + (cAliasSR3)->R3_MAT == QRY1->FILIAL + QRY1->MAT .AND. 	;
			dtHistSal == (cAliasSR3)->R3_DATA .AND. 														;
			dDtAum == If(!Empty((cAliasSR3)->R3_DTCDISS), (cAliasSR3)->R3_DTCDISS, (cAliasSR3)->R3_DATA) .AND. cTipo == (cAliasSR3)->R3_TIPO
			//--Verifica se Salario Incorporado ou Base
			If (!lIncorpora  .AND. (cAliasSR3)->R3_PD = "000") .OR. lIncorpora
				nSalario += (cAliasSr3)->R3_VALOR
			EndIf	
			dbSelectArea(cAliasSR3)	
			dbSkip()         
		EndDo
		nAtu 	:= 0		
		//--Atualizar Array de retorno
		If MesAno(dDtAum) <= aSalario[1,3] 
			If cUltAtu # MesAno(dDtAum) .OR. (cUltAtu == MesAno(dDtAum) .AND. nSalario > aSalario[1,2])
				aSalario[1,2] 	:= nSalario
				aSalario[1,1] 	:= cTipo
				nATu 		 	:= 1
				cUltAtu		 	:= MesAno(dDtAum)
		    EndIf
	    ElseIf (nPos := aScan(aSalario, {|x| x[3] == MesAno(dDtAum)})) > 0
			nAtu 	:= nPos
			If nPos > 0
				If nSalario > aSalario[nPos,2] 
			       aSalario[nPos,2] := nSalario
			       aSalario[nPos,1] := cTipo
			    EndIf   
			EndIf
		EndIf
		If nAtu # 0    
			For nP := nAtu To Len(aSalario)   
				aSalario[nP,2] := nSalario
			Next nP	
		EndIf
	EndDo	
EndIf
If (lQuery)
	dbSelectARea(cAliasSR3)
	dbCloseArea()
	dbSelectArea("SR3")
EndIf
If (nPos := aScan(aSalario, {|x| x[3] = AllTrim(MesAno(dDataDe))})) > 0
	Return(aSalario[nPos,2])
Else
	Return(QRY1->SALARIO)
EndIf
Return
