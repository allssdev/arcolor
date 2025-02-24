#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'olecont.ch'
#include 'rwmake.ch'
#define STR_PULA CHR(13) + CHR(10)
Static cDirTmp 		:= GetTempPath()
/*/{Protheus.doc} VALTRANSP
Fun��o para gera��o do arquivo de compra do vale transporte da SPTrans.
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 22/08/2019
@version 1.00 (P12.1.17)
@type Function	
@param nulo, Nil, nenhum 
@return nulo, Nil 
@obs Sem observa��es at� o momento. 
@see https://allss.com.br/
@history 22/08/2019, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Disponibiliza��o da rotina para uso.
/*/
User Function VALTRANSP()
Private cPerg       := FunName()
Private cTitulo		:= 'Gera��o de arquivo ".dat" para SPTrans'
Private cRotina		:= AllTrim(FunName())
Private oLeTxt
ValidPerg()
@ 200,001 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi(cTitulo)
@ 002,002 TO 090,190
@ 010,003 Say '   Este programa tem por objetivo gerar o arquivo para compra do VT da '
@ 018,003 Say '   SPTrans de acordo com as parametriza��es realizadas pelo usu�rio.   '
@ 070,088 BMPBUTTON TYPE 01 ACTION Processa({|| ProcRel()}, cTitulo, 'Processando, aguarde...', .F.)
@ 070,118 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
@ 070,148 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
Activate Dialog oLeTxt Centered
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ProcRel    �Autor  � Rodrigo Telecio 	 � Data �  22/08/2019 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o de processamento do relat�rio					      ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ProcRel()
Local lRet		:= .T.
Local cQuery 	:= ""
Local cTmp		:= ""
Local nHandle 	:= ""
Local cExtensao	:= ".dat"
Local lGerou	:= .F.
Local cSep		:= "|"
Local lGerExc	:= .T.
Local cAba		:= 'Parametros'
Local cAba2		:= 'VT SPTrans'
Local cTitulo	:= 'Parametros utilizados'
Local cTitulo2	:= "Rela��o de funcion�rios - VT SPTrans - Per�odo " + AllTrim(mv_par03) + " - " + IIf(mv_par01 == 1, "Reprocessamento", "Procesamento")
Local aSavArea	:= ""
Local aPar		:= {}
Local cArquivo	:= cDirTmp + cRotina + ".xml"
Local cObserva	:= ""
Local cTxt		:= ""
Local nNroPed	:= ""
Local aRet 		:= TamSX3("R0_VLRVALE")
Local nPosPar	:= 0
Local oFWMsExcel
Local oExcel
If !(SubStr(cAcesso, 160, 1) == "S" .AND. SubStr(cAcesso, 168, 1) == "S" .AND. SubStr(cAcesso, 170, 1) == "S")
	Aviso('TOTVS', 'Usu�rio sem permiss�o para gerar relat�rios em Excel. Informe essa mensagem ao administrador.', {'OK'}, 3, 'Cancelamento de opera��o por falta de permiss�es')
	lGerExc := .F.
EndIf
/*If !ApOleClient('MsExcel')
	Aviso('TOTVS', 'Excel n�o est� instalado nessa esta��o.', {'OK'}, 3, 'Cancelamento de opera��o por ausencia de aplicativo')
	lGerExc := .F.
EndIf*/
If lRet
	If Empty(AllTrim(mv_par15))
		Aviso('TOTVS', 'N�o foi informado diret�rio para gera��o do arquivo.', {'OK'}, 3, 'Cancelamento de opera��o pela regra de neg�cio')
		lRet := .F.	
	EndIf
EndIf
If lRet
	If Empty(AllTrim(mv_par16))
		Aviso('TOTVS', 'Conforme layout SPTrans, � necess�rio informar o nome de usu�rio de acesso � loja virtual.', {'OK'}, 3, 'Cancelamento de opera��o pela regra de neg�cio')
		lRet := .F.
	EndIf
EndIf
If lRet
	cTxt		:= AllTrim(mv_par15) + AllTrim(mv_par16) + DtoS(Date()) + cExtensao
	nHandle 	:= FCreate(cTxt)
	If nHandle < 0
		Aviso('TOTVS', 'Ocorreu um erro na gera��o do arquivo.', {'OK'}, 3, 'Cancelamento de opera��o')
	Else
		lGerou	:= .T.
		If lGerExc
			If mv_par11 == 1
				//ABA PAR�METROS
				oFWMsExcel 	:= FWMSExcel():New()
				oFWMsExcel:AddWorkSheet(cAba)
				oFWMsExcel:AddTable(cAba, cTitulo)
				oFWMsExcel:AddColumn(cAba, cTitulo, 'Descri��o'					, 1, 1) //1 = Modo Texto
				oFWMsExcel:AddColumn(cAba, cTitulo, 'Conte�do'					, 1, 1) //1 = Modo Texto
				cAliasSX1 	:= "SX1_" + GetNextAlias()
				aSavArea	:= GetArea()
				OpenSXS(,,,, FWCodEmp(), cAliasSX1, "SX1",, .F.)
				dbSelectArea(cAliasSX1)
				(cAliasSX1)->(dbSetOrder(1))
				(cAliasSX1)->(dbGoTop())
				cPerg 		:= PADR(cPerg, 10)
				If (cAliasSX1)->(dbSeek(cPerg))
					While !(cAliasSX1)->(EOF()) .AND. (cAliasSX1)->X1_GRUPO == cPerg
						If AllTrim((cAliasSX1)->X1_GSC) == "C"
							AAdd(aPar,{(cAliasSX1)->X1_PERGUNT, &("(cAliasSX1)->X1_DEF" + StrZero(&((cAliasSX1)->X1_VAR01),2))})
						Else
							AAdd(aPar,{(cAliasSX1)->X1_PERGUNT, &((cAliasSX1)->X1_VAR01)})
						EndIf
						dbSelectArea(cAliasSX1)
						(cAliasSX1)->(dbSetOrder(1))    
						(cAliasSX1)->(dbSkip())
					EndDo
				EndIf
				If Len(aPar) > 0
					For nPosPar := 1 To Len(aPar)
						oFWMsExcel:AddRow(cAba, cTitulo, aPar[nPosPar])
					Next
				EndIf
				RestArea(aSavArea)
				//ABA VT SPTRANS
				oFWMsExcel:AddworkSheet(cAba2)
				oFWMsExcel:AddTable(cAba2, cTitulo2)
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Filial"					, 1, 1) //1 = Modo Texto
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Cart�o SPTrans"			, 1, 1) //1 = Modo Texto
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Matricula"				, 1, 1) //1 = Modo Texto
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Nome"					, 1, 1) //1 = Modo Texto
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Situa��o Folha"			, 1, 1) //1 = Modo Texto
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Codigo VT"				, 1, 1) //1 = Modo Texto
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Descri��o VT"			, 1, 1) //1 = Modo Texto
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "C. Custo"				, 1, 1) //1 = Modo Texto
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Qtd. Dias"				, 2, 2) //2 = Valor sem R$
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Qtd. por dia"			, 2, 2) //2 = Valor sem R$
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Vlr. Unit�rio"			, 3, 3) //3 = Valor com R$
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Vlr. Total VT"			, 3, 3) //3 = Valor com R$
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Parte funcion�rio"		, 3, 3) //3 = Valor com R$
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Parte empresa"			, 3, 3) //3 = Valor com R$
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Sal�rio base"			, 3, 3) //3 = Valor com R$
				oFWMsExcel:AddColumn(cAba2, cTitulo2, "Observa��o"				, 1, 1) //1 = Modo Texto								
			EndIf
		EndIf
		//LEVANTA NUMERA��O DO PEDIDO (PROCESSAMENTO)
		If mv_par01 == 2 //PROCESSAMENTO
			cQuery := "SELECT																				" 
			cQuery += "		ISNULL(MAX(R0_NROPED),'') AS NROPED												"
			cQuery += "FROM																					"
			cQuery += 		RetSqlName("SR0") + " AS SR0													"
			cQuery += "WHERE																				"
			cQuery += "		SR0.R0_FILIAL = '" + xFilial("SR0") + "'										"
			cQuery += "		AND SR0.D_E_L_E_T_ = ''															"		
			cTmp 	:= GetNextAlias()
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmp, .T., .F.)
			MemoWrite(cDirTmp + cRotina + "_1.txt", cQuery)
			dbSelectArea(cTmp)
			While (cTmp)->(!EOF())
				nNroPed := (cTmp)->NROPED
				(cTmp)->(dbSkip())
			EndDo
			If Empty(AllTrim(nNroPed))
				nNroPed := StrZero(1, TamSX3("R0_NROPED")[1]) 
			Else
				nNroPed := StrZero(Val(nNroPed) + 1, TamSX3("R0_NROPED")[1])
			EndIf
			(cTmp)->(dbCloseArea())
			//PROCESSA REGISTROS
			cQuery := "SELECT																				"
			cQuery += "		SRA.RA_FILIAL AS FILIAL, 														"
			cQuery += "		SRA.RA_SPTRANS AS SPTRANS,														"
			cQuery += "		SRA.RA_MAT AS MATRICULA, 														"
			cQuery += "		SRA.RA_NOME AS NOME,															"
			cQuery += "		CASE 																			"
			cQuery += "			WHEN SRA.RA_SITFOLH = '' THEN 'ATIVO'										"
			cQuery += "			WHEN SRA.RA_SITFOLH = 'F' THEN 'FERIAS'										"
			cQuery += "			WHEN SRA.RA_SITFOLH = 'D' THEN 'DEMITIDO'									"
			cQuery += "			WHEN SRA.RA_SITFOLH = 'A' THEN 'AFASTADO'									"
			cQuery += "			WHEN SRA.RA_SITFOLH = 'T' THEN 'TRANSFERIDO'								"
			cQuery += "		END AS SITUACAO, 															    "
			cQuery += "		SR0.R0_PEDIDO AS PEDIDO, 														"
			cQuery += "		SR0.R0_NROPED AS NROPED,														"
			cQuery += "		SR0.R0_CODIGO AS CODIGO, 														"
			cQuery += "		SRN.RN_DESC AS DESC_VT, 														"
			cQuery += "		SR0.R0_CC AS C_CUSTO, 															"
			cQuery += "		SR0.R0_DIASPRO AS QTDDIAS, 														"
			cQuery += "		SR0.R0_QDIAINF AS QTD_DIA, 														"
			cQuery += "		SR0.R0_VLRVALE AS VLR_FACE, 													"
			cQuery += "		SR0.R0_VALCAL AS VALOR, 														"
			cQuery += "		SR0.R0_VLRFUNC AS VAL_FUNC, 													"
			cQuery += "		SR0.R0_VLREMP AS VAL_EMP, 														"
			cQuery += "		SR0.R0_SALBASE AS SAL_BASE,														"
			cQuery += "		SR0.R_E_C_N_O_ AS RECNO 														"
			cQuery += "FROM 																				"
			cQuery += 		RetSqlName("SR0") + " AS SR0													"
			cQuery += "		INNER JOIN																		"
			cQuery += 			RetSqlName("SRA") + " AS SRA												"
			cQuery += "		ON																				"
			cQuery += "			SRA.RA_MAT = SR0.R0_MAT														"
			cQuery += "			AND SRA.RA_FILIAL = SR0.R0_FILIAL											"
			cQuery += "			AND SRA.RA_PROCES = '" 			+ mv_par02 + "' 							"
			cQuery += "			AND SRA.RA_FILIAL BETWEEN '" 	+ mv_par05 + "' AND '" + mv_par06 + "'		"
			cQuery += "			AND SRA.RA_CC BETWEEN '" 		+ mv_par07 + "' AND '" + mv_par08 + "'		"
			cQuery += "			AND SRA.RA_MAT BETWEEN '" 		+ mv_par09 + "' AND '" + mv_par10 + "'		"
			cQuery += "			AND SRA.D_E_L_E_T_ = ''														"
			cQuery += "		INNER JOIN																		"
			cQuery += 			RetSqlName("SRN") + " AS SRN												"
			cQuery += "		ON																				"
			cQuery += "			SRN.RN_COD = SR0.R0_CODIGO													"
			cQuery += "			AND SRN.D_E_L_E_T_ = ''														"
			cQuery += "WHERE																				"
			cQuery += "		SR0.R0_TPVALE = '0'																"
			cQuery += "		AND SR0.R0_NROPED BETWEEN '" 		+ mv_par13 + "' AND '" + mv_par14 + "'		"
			cQuery += "		AND SR0.D_E_L_E_T_ = ''															"
			cQuery += "ORDER BY																				"
			If mv_par12 == 1
				cQuery += "		SRA.RA_FILIAL, SRA.RA_MAT													"		
			ElseIf mv_par12 == 2
				cQuery += "		SRA.RA_FILIAL, SR0.R0_CC, SRA.RA_MAT										"		
			ElseIf mv_par12 == 3
				cQuery += "		SRA.RA_FILIAL, SRA.RA_NOME													"
			Else
				cQuery += "		SRA.RA_FILIAL, SRA.RA_MAT													"
			EndIf
		Else
			cQuery := "SELECT																				" 
			cQuery += "		ISNULL(MAX(RG2_NROPED),'') AS NROPED											"
			cQuery += "FROM																					"
			cQuery += 		RetSqlName("RG2") + " AS RG2													"
			cQuery += "WHERE																				"
			cQuery += "		RG2.RG2_FILIAL = '" + xFilial("RG2") + "'										"
			cQuery += "		AND RG2.D_E_L_E_T_ = ''															"		
			cTmp 	:= GetNextAlias()
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmp, .T., .F.)
			MemoWrite(cDirTmp + cRotina + "_1.txt", cQuery)
			dbSelectArea(cTmp)
			While (cTmp)->(!EOF())
				nNroPed := (cTmp)->NROPED
				(cTmp)->(dbSkip())
			EndDo
			If Empty(AllTrim(nNroPed))
				nNroPed := StrZero(1, TamSX3("RG2_NROPED")[1]) 
			Else
				nNroPed := StrZero(Val(nNroPed) + 1, TamSX3("RG2_NROPED")[1])
			EndIf
			(cTmp)->(dbCloseArea())
			//PROCESSA REGISTROS
			cQuery := "SELECT																				"
			cQuery += "		SRA.RA_FILIAL AS FILIAL, 														"
			cQuery += "		SRA.RA_SPTRANS AS SPTRANS,														"
			cQuery += "		SRA.RA_MAT AS MATRICULA, 														"
			cQuery += "		SRA.RA_NOME AS NOME,															"
			cQuery += "		CASE 																			"
			cQuery += "			WHEN SRA.RA_SITFOLH = '' THEN 'ATIVO'										"
			cQuery += "			WHEN SRA.RA_SITFOLH = 'F' THEN 'FERIAS'										"
			cQuery += "			WHEN SRA.RA_SITFOLH = 'D' THEN 'DEMITIDO'									"
			cQuery += "			WHEN SRA.RA_SITFOLH = 'A' THEN 'AFASTADO'									"
			cQuery += "			WHEN SRA.RA_SITFOLH = 'T' THEN 'TRANSFERIDO'								"
			cQuery += "		END AS SITUACAO, 															    "
			cQuery += "		RG2.RG2_PEDIDO AS PEDIDO,														"
			cQuery += "		RG2.RG2_NROPED AS NROPED,														"
			cQuery += "		RG2.RG2_CODIGO AS CODIGO,														"
			cQuery += "		SRN.RN_DESC AS DESC_VT,															"
			cQuery += "		RG2.RG2_CC AS C_CUSTO,															"
			cQuery += "		RG2.RG2_DIAPRO AS QTDDIAS,														"
			cQuery += "		RG2.RG2_VTDUTE AS QTD_DIA,														"
			cQuery += "		RG2.RG2_CUSUNI AS VLR_FACE,														"
			cQuery += "		RG2.RG2_VALCAL AS VALOR,														"
			cQuery += "		RG2.RG2_CUSFUN AS VAL_FUNC,														"
			cQuery += "		RG2.RG2_CUSEMP AS VAL_EMP,														"
			cQuery += "		RG2.RG2_SALBSE AS SAL_BASE,														"
			cQuery += "		RG2.R_E_C_N_O_ AS RECNO															"
			cQuery += "FROM																					"
			cQuery += 		RetSqlName("RG2") + " AS RG2													"
			cQuery += "		INNER JOIN																		"
			cQuery += 			RetSqlName("SRA") + " AS SRA												"
			cQuery += "		ON																				"
			cQuery += "			SRA.RA_MAT = RG2.RG2_MAT													"
			cQuery += "			AND SRA.RA_FILIAL = RG2.RG2_FILIAL											"
			cQuery += "			AND SRA.RA_PROCES = '" 			+ mv_par02 + "' 							"
			cQuery += "			AND SRA.RA_FILIAL BETWEEN '" 	+ mv_par05 + "' AND '" + mv_par06 + "'		"
			cQuery += "			AND SRA.RA_CC BETWEEN '" 		+ mv_par07 + "' AND '" + mv_par08 + "'		"
			cQuery += "			AND SRA.RA_MAT BETWEEN '" 		+ mv_par09 + "' AND '" + mv_par10 + "'		"
			cQuery += "			AND SRA.D_E_L_E_T_ = ''														"
			cQuery += "		INNER JOIN																		"
			cQuery += 			RetSqlName("SRN") + " AS SRN												"
			cQuery += "		ON																				"
			cQuery += "			SRN.RN_COD = RG2.RG2_CODIGO													"
			cQuery += "			AND SRN.D_E_L_E_T_ = ''														"
			cQuery += "WHERE																				"
			cQuery += "		RG2.RG2_TPVALE = '0'															"
			cQuery += "		AND RG2.RG2_PERIOD = '" 			+ mv_par03 + "'								"
			cQuery += "		AND RG2.RG2_NROPGT = '" 			+ mv_par04 + "'								"
			cQuery += "		AND RG2.RG2_NROPED BETWEEN '" 		+ mv_par13 + "' AND '" + mv_par14 + "'		"
			cQuery += "		AND RG2.RG2_ROTEIR = 'VTR'														"
			cQuery += " 	AND RG2.D_E_L_E_T_ = ''															"
			cQuery += "ORDER BY																				"
			If mv_par12 == 1
				cQuery += "		SRA.RA_FILIAL, SRA.RA_MAT													"		
			ElseIf mv_par12 == 2
				cQuery += "		SRA.RA_FILIAL, RG2.RG2_CC, SRA.RA_MAT										"		
			ElseIf mv_par12 == 3
				cQuery += "		SRA.RA_FILIAL, SRA.RA_NOME													"
			Else
				cQuery += "		SRA.RA_FILIAL, SRA.RA_MAT													"
			EndIf
		EndIf
		cTmp 	:= GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmp, .T., .F.)
		MemoWrite(cDirTmp + cRotina + "_2.txt", cQuery)
		dbSelectArea(cTmp)
		ProcRegua(RecCount())
		While (cTmp)->(!EOF())
			IncProc("Gravando registro do '" + AllTrim((cTmp)->NOME) + "', aguarde...")
			cObserva := ""
			If !Empty(AllTrim((cTmp)->SPTRANS))
				FWrite(nHandle, AllTrim((cTmp)->SPTRANS) 			 									+ cSep + ;
				  				AllTrim(Str((cTmp)->QTDDIAS))		 									+ cSep + ;
				  				AllTrim(Str((cTmp)->VLR_FACE * (cTmp)->QTD_DIA, aRet[1], aRet[2]))		+ cSep + ;
				  				AllTrim(SubStr((cTmp)->NOME, 1, 40)) 									+ STR_PULA)
			Else
				cObserva := "Cart�o SPTrans n�o preenchido no cadastro do funcion�rio. Tal registro n�o foi considerado no arquivo de compra de VT da SPTrans."
			EndIf
			If lGerExc
				If mv_par11 == 1
					//ABA VT SPTRANS
					oFWMsExcel:AddRow(cAba2, cTitulo2,	{	AllTrim((cTmp)->FILIAL)				,;
															AllTrim((cTmp)->SPTRANS)			,;
															AllTrim((cTmp)->MATRICULA)			,;
															AllTrim((cTmp)->NOME)				,;
															AllTrim((cTmp)->SITUACAO)			,;
															AllTrim((cTmp)->CODIGO)				,;
															AllTrim((cTmp)->DESC_VT)			,;
															AllTrim((cTmp)->C_CUSTO)			,;
															(cTmp)->QTDDIAS						,;
															(cTmp)->QTD_DIA						,;
															(cTmp)->VLR_FACE					,;
															(cTmp)->VALOR						,;
															(cTmp)->VAL_FUNC					,;
															(cTmp)->VAL_EMP						,;
															(cTmp)->SAL_BASE					,;
															AllTrim(cObserva)					})
				EndIf
			EndIf
			If mv_par01 == 2
				dbSelectArea("SR0")
				SR0->(dbGoTo((cTmp)->RECNO))
			    RecLock("SR0", .F.)
			    SR0->R0_PEDIDO 		:= '2'
			    SR0->R0_NROPED 		:= nNroPed 
			    SR0->(MsUnlock())
		    Else
		    	dbSelectArea("RG2")
				RG2->(dbGoTo((cTmp)->RECNO))
			    RecLock("RG2", .F.)
			    RG2->RG2_PEDIDO 	:= 2
			    RG2->RG2_NROPED 	:= nNroPed 
			    RG2->(MsUnlock())
		    EndIf
			(cTmp)->(dbSkip())
		EndDo
		(cTmp)->(dbCloseArea())
		FClose(nHandle)
		If lGerExc
			If mv_par11 == 1
				oFWMsExcel:Activate()
				oFWMsExcel:GetXMLFile(cArquivo)
				oExcel := MsExcel():New()
				oExcel:WorkBooks:Open(cArquivo)
				oExcel:SetVisible(.T.)
				oExcel:Destroy()
			EndIf
		EndIf
	EndIf
EndIf
If lGerou
	Aviso('TOTVS', "Arquivo '" + cTxt + "' gerado com sucesso. Realize a importa��o dos dados na loja virtual da SPTrans.", {'OK'}, 3, 'Notifica��o de conclus�o do processo')
EndIf
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg  �Autor  � Rodrigo Telecio 	 � Data �  22/08/2019 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o responsavel por criar as perguntas utilizadas no    ���
���          � relat�rio                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValidPerg()
Local aAlias 	:= GetArea()
Local aRegs   	:= {}
Local aRet		:= {}
Local i,j
AAdd(aRegs,{cPerg,"01","Reprocessamento?"      		,"","","mv_ch1","N"    ,1	   ,0      ,0,"C",'naovazio()'	                       					,"mv_par01","Sim"      ,"","","","","N�o"      ,"","","","",""		,"","","","","","","","","","","","","",""	    	,"","",""})
aRet := TamSX3("RGB_PROCES")
AAdd(aRegs,{cPerg,"02","Processo?"      			,"","","mv_ch2",aRet[3],aRet[1],aRet[2],0,"G",'naovazio() .AND. ExistCpo("RCJ")'   					,"mv_par02",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","RCJ"		,"","",""})
aRet := TamSX3("RGB_PERIOD")
AAdd(aRegs,{cPerg,"03","Periodo?"      				,"","","mv_ch3",aRet[3],aRet[1],aRet[2],0,"G",'naovazio() .AND. Gpm015Per(1, mv_par02, mv_par03)'   ,"mv_par03",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","RCHAQB"	,"","",""})
aRet := TamSX3("RGB_SEMANA")
AAdd(aRegs,{cPerg,"04","Nro.Pagamento?"   			,"","","mv_ch4",aRet[3],aRet[1],aRet[2],0,"G",''   													,"mv_par04",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
aRet := TamSX3("RGB_FILIAL")
AAdd(aRegs,{cPerg,"05","Da Filial?"    				,"","","mv_ch5",aRet[3],aRet[1],aRet[2],0,"G",''													,"mv_par05",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","XM0"		,"","",""})
AAdd(aRegs,{cPerg,"06","At� a Filial?" 				,"","","mv_ch6",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'											,"mv_par06",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","XM0"		,"","",""})
aRet := TamSX3("RGB_CC")
AAdd(aRegs,{cPerg,"07","Do Centro de Custo?"    	,"","","mv_ch7",aRet[3],aRet[1],aRet[2],0,"G",''													,"mv_par07",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","CTT"		,"","",""})
AAdd(aRegs,{cPerg,"08","At� o Centro de Custo?"		,"","","mv_ch8",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'											,"mv_par08",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","CTT"		,"","",""})
aRet := TamSX3("RGB_MAT")
AAdd(aRegs,{cPerg,"09","Da Matricula?"    			,"","","mv_ch9",aRet[3],aRet[1],aRet[2],0,"G",''													,"mv_par09",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","SRA"		,"","",""})
AAdd(aRegs,{cPerg,"10","At� a Matricula?"			,"","","mv_cha",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'											,"mv_par10",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","","SRA"		,"","",""})
AAdd(aRegs,{cPerg,"11","Gera listagem?"     		,"","","mv_chb","N"    ,1	   ,0      ,0,"C",'naovazio()'	                       					,"mv_par11","Sim"      ,"","","","","N�o"      ,"","","","",""		,"","","","","","","","","","","","","",""	    	,"","",""})
AAdd(aRegs,{cPerg,"12","Ordem do relat�rio?"     	,"","","mv_chc","N"    ,1	   ,0      ,0,"C",'naovazio()'	                       					,"mv_par12","Matricula","","","","","C.Custo"  ,"","","","","Nome"	,"","","","","","","","","","","","","",""	    	,"","",""})
aRet := TamSX3("R0_NROPED")
AAdd(aRegs,{cPerg,"13","Do Nro.Pedido?"   			,"","","mv_chd",aRet[3],aRet[1],aRet[2],0,"G",''													,"mv_par13",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
AAdd(aRegs,{cPerg,"14","At� o Nro.Pedido?"			,"","","mv_che",aRet[3],aRet[1],aRet[2],0,"G",'naovazio()'											,"mv_par14",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
AAdd(aRegs,{cPerg,"15","Diretorio p/Salvar Arq.?"   ,"","","mv_chf","C"    ,90     ,0      ,0,"G",'U_GETLOCARQ()'										,"mv_par15",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
AAdd(aRegs,{cPerg,"16","Usuario SPTrans?"   		,"","","mv_chg","C"    ,10     ,0      ,0,"G",'naovazio()'											,"mv_par16",""         ,"","","","",""         ,"","","","",""		,"","","","","","","","","","","","","",""			,"","",""})
cAliasSX1 		:= "SX1_" + GetNextAlias()
OpenSXS(,,,, FWCodEmp(), cAliasSX1, "SX1", , .F.)
dbSelectArea(cAliasSX1)
(cAliasSX1)->(dbSetOrder(1))
For i := 1 to Len(aRegs)
	If !(cAliasSX1)->(dbSeek(cPerg + Space(Len((cAliasSX1)->X1_GRUPO) - Len(cPerg)) + aRegs[i,2]))
		RecLock(cAliasSX1,.T.)
		for j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j, aRegs[i,j])
			EndIf
		Next
		MsUnlock()
	EndIf
Next
RestArea(aAlias)
Return


/*/{Protheus.doc} GETLOCARQ
Fun��o para coleta do diret�rio para salvar arquivo.
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 22/08/2019
@version 1.00 (P12.1.17)
@type Function	
@param nulo, Nil, nenhum 
@return nulo, Nil 
@obs Sem observa��es at� o momento. 
@see https://allss.com.br/
@history 22/08/2019, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Disponibiliza��o da rotina para uso.
/*/
User Function GETLOCARQ()
Local cTitulo 	:= "Escolha o diret�rio para salvar o arquivo"
Local cDirTmp 	:= GetTempPath()
mv_par15 		:= cGetFile('*.dat|*.dat' , cTitulo, 1, cDirTmp, .F., nOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY), .F., .T.)
Return .T.
