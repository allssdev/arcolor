#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA100.CH"

#DEFINE MAXGETDAD 4096
#DEFINE STR0001  "Pesquisar"
#DEFINE STR0002  "Visualizar"
#DEFINE STR0003  "Incluir"
#DEFINE STR0004  "Alterar"
#DEFINE STR0005  "Excluir"
#DEFINE STR0006  "Copiar"
#DEFINE STR0007  "Manutencao das Regras de Negocio"
#DEFINE STR0008  "Negociacao"
#DEFINE STR0009  "Comercializacao"
#DEFINE STR0010  "Descontos"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ RFATA014 ºAutor  ³ Adriano L. de Souza º Data ³  18/02/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Execblock responsável pela inclusão de regras padrões por gru-º±±
±±ºDesc.   ³ po de produtos.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Protheus 11 - Específico para a empresa Arcolor.             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RFATA014()

Local _cRotina	:= "RFATA014"
Local cAlias 	:= Alias()
Local nReg	 	:= (cAlias)->(Recno())
Local nOpc	 	:= 6 //Cópia (os dados serão manipulados a seguir)
Local aArea     := GetArea()
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aTitles   := {}
Local aHeadNeg  := {}
Local aHeadCom  := {}
Local aHeadDes  := {}
Local aColsNeg  := {}
Local aColsCom  := {}
Local aColsDes  := {}
Local nUsado    := 0
Local nX        := 0
Local nOpcA     := 0
Local _nCont    := 0
Local nSaveSx8  := GetSx8Len()
Local cCadastro := "Manutenção da tabela de preços"	//"Manutenção da tabela de preços"
Local cCodReg   := ""
Local _cCampo   := ""
Local lContinua := .T.
Local lCopia    := nOpc==6

Local oDlg
Local oGetd1
Local oGetd2
Local oGetd3
Local oFolder 

Private aTELA[0][0],aGETS[0]

DEFAULT INCLUI := .F.                 

aTitles := {STR0008,STR0009,STR0010}

dbSelectArea("SBM")
If SBM->(FieldPos("BM_SUGERE"))==0
	MsgAlert("Favor informar o Administrador que o campo BM_SUGERE precisa ser criado!",_cRotina+"_001")
	Return()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa as variaveis da Enchoice                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If INCLUI .AND. !lCopia
	RegToMemory( "ACS", .T., .F. )
EndIf
If !INCLUI .OR. lCopia
	If lCopia .OR. SoftLock("ACS")
		RegToMemory( "ACS", .F., .F. )
		If lCopia
			M->ACS_CODREG := GETSX8NUM("ACS","ACS_CODREG")
			M->ACS_DESCRI := CriaVar("ACS_DESCRI" ,.F.)
			M->ACS_CODCLI := CriaVar("ACS_CODCLI" ,.F.)
			M->ACS_LOJA   := CriaVar("ACS_LOJA"   ,.F.)
			M->ACS_NOME   := CriaVar("ACS_NOME"   ,.F.)
			M->ACS_GRPVEN := CriaVar("ACS_GRPVEN" ,.F.)
			M->ACS_DESGRP := CriaVar("ACS_DESGRP" ,.F.)
			M->ACS_TPHORA := "1"
			M->ACS_DATDE  := dDataBase
			M->ACS_DATATE := STOD(SuperGetMv("MV_FIMVIGP" ,,"20491231")) //Parâmetro com data final padrão para a regra de negócio (final de vigência da regra)
		EndIf
	Else
		lContinua := .F.
	EndIf
EndIf

If lContinua

	cCodReg := IIf (lCopia, ACS->ACS_CODREG, M->ACS_CODREG)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader do ACT                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cSeek  := xFilial("ACT")+cCodReg
	cWhile :=	"ACT->ACT_FILIAL + ACT->ACT_CODREG"
	
	FillGetDados(	nOpc 		, "ACT", 1	, cSeek,;
					{||&(cWhile)}, /*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,;
			   		/*aYesFields*/, /*lOnlyYes*/,/* cQuery*/, /*bMontAcols*/, IIf(nOpc<>3,.F.,.T.),;
					aHeadNeg/*aHeaderAux*/, aColsNeg/*aColsAux*/,{||Fat100Item("ACT")}, /*bBeforeCols*/,;
					/*bAfterHeader*/, /*cAliasQry*/)
 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader do ACX                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cSeek  := xFilial("ACX")+cCodReg
	cWhile := "ACX->ACX_FILIAL + ACX->ACX_CODREG"
	aheader :={}
	aCols 	:={}
	FillGetDados(	nOpc 		, "ACX", 1	, cSeek,;
					{||&(cWhile)}, /*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,;
			   		/*aYesFields*/, /*lOnlyYes*/,/* cQuery*/, /*bMontAcols*/, IIf(nOpc<>3,.F.,.T.),;
					aHeadCom/*aHeaderAux*/, aColsCom/*aColsAux*/,{||Fat100Item("ACX")}, /*bBeforeCols*/,;
					/*bAfterHeader*/, /*cAliasQry*/)
	
	dbSelectArea("ACX")
	If lCopia
		M->ACS_CODREG := CriaVar("ACS_CODREG",.T.)
    EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader do ACN caso a tabela esteja criada     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                 
	//Query responsável por retornar os dados que deverão ser inclusos no aColsNeg para montagem do browse
	_cQuery := "SELECT REPLICATE('0'," + AllTrim(Str(TamSx3("ACN_ITEM")[01])) + "-(LEN(ROW_NUMBER() OVER(ORDER BY SBM.BM_GRUPO))))+CAST(ROW_NUMBER() OVER(ORDER BY SBM.BM_GRUPO) AS CHAR(" + AllTrim(Str(TamSx3("ACN_ITEM")[01])) + ")) AS [ACN_ITEM],"
	_cQuery += "SBM.BM_GRUPO AS [ACN_GRPPRO], "
	_cQuery += "SBM.BM_DESC AS [ACN_DESGRU], "
	_cQuery += "'' AS [ACN_CODPRO], "
	_cQuery += "'' AS [ACN_DESPRO], "
	_cQuery += "'' AS [ACN_CODFAT], "
	_cQuery += "SBM.BM_DESCPAD AS [ACN_DESCV1], "
	_cQuery += "0 AS [ACN_DESCV2], "
	_cQuery += "0 AS [ACN_DESCV3], "
	_cQuery += "0 AS [ACN_DESCV4], "
	_cQuery += "SBM.BM_DESCPAD AS [ACN_FATOR], "
	_cQuery += "SBM.BM_DESCPAD AS [ACN_DESCON], "
	_cQuery += "'' AS [ACN_ITEMGR], "
	_cQuery += "999999.99 AS [ACN_QUANTI], "
	_cQuery += "'' AS [ACN_USERIN], "
	_cQuery += "'" + DtoS(dDataBase) + "' AS [ACN_DTINCL], "
	_cQuery += "'' AS [ACN_USRALT], "
	_cQuery += "'" + DtoS(Stod("")) + "' AS [ACN_DTALTR], "
	_cQuery += "'" + SubStr(Alltrim(UsrRetName(__cUserId)),1,TamSX3("ACN_USRINC")[01]) + "' AS [ACN_USRINC], "
	_cQuery += "'2' AS [ACN_PROMOC], " //Inicia a flag de promoção como 2=Não
	_cQuery += "'" + DtoS(dDataBase) + "' AS [ACN_DATINI], "
	_cQuery += "'" + DtoS(Stod(SuperGetMv("MV_FIMVIGP" ,,"20491231" ))) + "' AS [ACN_DATFIM], "
	_cQuery += "'' AS [ACN_ALI_WT], "
	_cQuery += "0 AS [ACN_REC_WT], "
	_cQuery += "'" + xFilial("ACN") + "' AS [ACN_FILIAL], "
	_cQuery += "'" + cCodReg + "' AS [ACN_CODREG] "
	_cQuery += "FROM " + RetSqlName("SBM") + " SBM "
	_cQuery += "WHERE SBM.D_E_L_E_T_='' "
	_cQuery += "AND SBM.BM_SUGERE='1' " //Sugere grupo como 1=Sim
	_cQuery += "AND SBM.BM_FILIAL='" + xFilial("SBM") + "' "

	dbUseArea( .T., "TOPCONN", TcGenQry( , , _cQuery ), "ACNTMP", .F., .T. )
	
	cSeek  := xFilial("ACN")+cCodReg
	cWhile := "ACN->ACN_FILIAL + ACN->ACN_CODREG"
	aheader :={}
	aCols 	:={}
	FillGetDados(	nOpc 		, "ACN", 1	, cSeek,;
					{||&(cWhile)}, /*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,;
			   		/*aYesFields*/, /*lOnlyYes*/, /*cQuery*/, /*bMontAcols*/, IIf(nOpc<>3,.F.,.T.),;
					aHeadDes/*aHeaderAux*/, aColsDes/*aColsAux*/,{||Fat100Item("ACN")}, /*bBeforeCols*/,;
					/*bAfterHeader*/, /*cAliasQry*/)
	                 	
	aColsDes := {} //Zero o array gerado pela função padrão FillGetDados()
	_aCampos := {} //Array auxiliar para manipulação do conteúdo do aColsDes
	
	_bCpo    := "Type('aCols(_nCont,2)')"
	
	dbSelectArea("ACNTMP")
	ACNTMP->(dbSetOrder(0))
	While !ACNTMP->(EOF()) //Tabela temporária com os descontos padrões por grupo de produtos
		For _nCont := 1 To Len(aHeadDes)
			_cCampo := "ACNTMP->" + AllTrim(aHeadDes[_nCont,2])
			If StrTran(_cCampo,"ACNTMP->","") $ "ACN_DTINCL/ACN_DTALTR/ACN_DATINI/ACN_DATFIM"
				AAdd(_aCampos,StoD(&_cCampo))
			ElseIf StrTran(_cCampo,"ACNTMP->","") $ "ACN_ITEM" //Formata o tamanho do campo
				AAdd(_aCampos,SubStr((&_cCampo),1,TamSx3("ACN_ITEM")[01]))
			Else
			
				If &_cCampo <> Nil
					AAdd(_aCampos,&_cCampo)
				Else //Prevenção de erro em caso de criação de novas colunas no aCols que não foram adicionadas na query
					//If Type("aCols(_nCont,2)")=="N"
					If &(_bCpo) == "N"
						AAdd(_aCampos,0)
					//ElseIf Type("aCols(_nCont,2)")=="C"
					ElseiF &(_bCpo) == "C"
						AAdd(_aCampos,"")
					//ElseIf Type("aCols(_nCont,2)")=="D"
					ElseIf &(_bCpo) == "D"
						AAdd(_aCampos,StoD(""))
					//ElseIf Type("aCols(_nCont,2)")=="L"
					ElseIf &(_bCpo) == "L"
						AAdd(_aCampos,.T.)
					//ElseIf Type("aCols(_nCont,2)")=="A"
					ElseIF &(_bCpo) == "A"
						AAdd(_aCampos,{})
					EndIf
				EndIf
			EndIf
		Next

 		If ACNTMP->ACN_DESCON>0
			AAdd(_aCampos,.F.) //Se desconto padrão maior que zero, linha ativa
		Else 
			AAdd(_aCampos,.T.) //Se desconto padrão maior que zero, linha deletada (cinza)
		EndIf
		
		AAdd(aColsDes,_aCampos)
		
		_aCampos := {}
		dbSelectArea("ACNTMP")
		ACNTMP->(dbSetOrder(0))
		ACNTMP->(dbSkip())
	EndDo
	
	dbSelectArea("ACNTMP")
	dbCloseArea()
	
	aCols := aColsDes
	
	////////////////
	
	If lCopia
		Inclui := .T.
	EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 200, 200, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( "ACS", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.F. )
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{"",""},oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	oFolder:bSetOption:={|nAtu| Ft100Fld(nAtu,oFolder:nOption,oFolder,{oGetD1,oGetD2,oGetD3})}

	oGetD1 := MsNewGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-15,aPosObj[2,4]-aPosObj[2,2]-5,IIf(Altera .Or. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0),"Ft100LOk1()","Ft100TOk1()","+ACT_ITEM",,,MAXGETDAD,,,,oFolder:aDialogs[1],aHeadNeg,aColsNeg)
	oGetD2 := MsNewGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-15,aPosObj[2,4]-aPosObj[2,2]-5,IIf(Altera .Or. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0),"Ft100LOk2()","Ft100TOk2()","+ACX_ITEM",,,MAXGETDAD,,,,oFolder:aDialogs[2],aHeadCom,aColsCom)
	oGetD3 := MsNewGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-15,aPosObj[2,4]-aPosObj[2,2]-5,IIf(Altera .Or. Inclui,GD_INSERT+GD_DELETE+GD_UPDATE,0),"Ft100LOk3()","AllwaysTrue()","+ACN_ITEM",,,MAXGETDAD,,,,oFolder:aDialogs[3],aHeadDes,aColsDes)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,If(Ft100Ok(oGetD1,oGetD2,oGetD3,aColsNeg,aColsCom,aColsDes,oFolder),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rotina de Gravacao da Tabela de preco                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1 .And. nOpc >= 2
		Begin Transaction
		Ft100Grv(nOpc-2,aHeadCom,aColsCom,aHeadNeg,aColsNeg,aHeadDes,aColsDes)
		While (GetSx8Len() > nSaveSx8)
			ConfirmSx8()
		EndDo
		EvalTrigger()
		End Transaction
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a entrada da Rotina                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (GetSx8Len() > nSaveSx8)
	RollBackSx8()
EndDo
MsUnLockAll()
FreeUsedCode()
RestArea(aArea)
Return(nOpcA)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |Ft100afcol  ºAutor ³Fernando Amorim      º Data ³ 22/02/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Faz o tratamento do aCols                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³												              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Regras de Negocio                                     	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Fat100Item(cAlias) 

Local nX := 0
If Len(aCols) == 1
	For nX := 1 To Len(aHeader)
			If AllTrim(aHeader[nX,2]) == "ACT_ITEM" .Or. AllTrim(aHeader[nX,2])== "ACX_ITEM" .Or. AllTrim(aHeader[nX,2])== "ACN_ITEM"
				Acols[Len(Acols),nX] := "001"
			EndIf
 	Next nX
EndIf

If cAlias =="ACX"
	For nX := 1 To Len(aHeader)
			Do Case
						Case Alltrim(aHeader[nX,2]) == "ACX_DESPRO"
							If !Empty(ACX->ACX_CODPRO)
								SB1->(dbSetOrder(1))
								If SB1->(MsSeek(xFilial("SB1")+ACX->ACX_CODPRO))
									aCols[Len(aCols)][nX] := SB1->B1_DESC
								EndIf
							EndIf
						
						Case Alltrim(aHeader[nX,2]) == "ACX_DESGRU"
							If !Empty(ACX->ACX_GRUPO)
								SBM->(dbSetOrder(1))
								If SBM->(MsSeek(xFilial("SBM")+ACX->ACX_GRUPO))
									aCols[Len(aCols)][nX] := SBM->BM_DESC
								EndIf
							EndIf								
		EndCase
	Next nX 
EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft100Grv  ³ Autor ³Eduardo Riera          ³ Data ³ 08/05/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Gravacao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ft100Grv                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opcao da Gravacao sendo:                               ³±±
±±³          ³       [1] Inclusao                                           ³±±
±±³          ³       [2] Alteracao                                          ³±±
±±³          ³       [3] Exclusao                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ft100Grv(nOpcao,aHeadCom,aColsCom,aHeadNeg,aColsNeg,aHeadDes,aColsDes)

Local aArea     := GetArea()
Local aRegNo    := {}
Local lGravou   := .F.
Local lTravou   := .T.
Local nX        := 0
Local nY        := 0
Local nUsado1   := Len(aHeadNeg)
Local nUsado2   := Len(aHeadCom)
Local nUsado3   := Len(aHeadDes)
Local bCampo 	:= {|nCPO| Field(nCPO) }
Local cItem     := Repl("0",Len(ACT->ACT_ITEM))

Do Case
	Case nOpcao <> 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o Cabecalho                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("ACS")
		ACS->(dbOrderNickName("ACS_CODREG"))		//dbSetOrder(1)
		If ACS->(dbSeek(xFilial("ACS")+M->ACS_CODREG))
			while !RecLock("ACS",.F.) ; enddo
		Else
			while !RecLock("ACS",.T.) ; enddo
		EndIf
		For nX := 1 TO FCount()
			FieldPut(nX,M->&(EVAL(bCampo,nX)))
		Next nX
		ACS->ACS_FILIAL := xFilial("ACS")
		MsUnLock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda os registros para reaproveita-los                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("ACT")
		ACT->(dbOrderNickName("ACT_CODRE1"))		//dbSetOrder(1)
		ACT->(dbSeek(xFilial("ACT")+M->ACS_CODREG))
		While !ACT->(EOF()) .AND. xFilial("ACT") == ACT->ACT_FILIAL .AND. M->ACS_CODREG == ACT->ACT_CODREG
			aadd(aRegNo,RecNo())
			dbSelectArea("ACT")
			ACT->(dbOrderNickName("ACT_CODRE1"))
			ACT->(dbSkip())
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os itens                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cItem     := Repl("0",Len(ACT->ACT_ITEM))		
		
		For nX := 1 To Len(aColsNeg)
			lTravou := .F.
			If nX <= Len(aRegNo)
				dbSelectArea("ACT")
				dbGoto(aRegNo[nX])
				while !RecLock("ACT") ; enddo
				lTravou := .T.
			EndIf
			If ( !aColsNeg[nX][nUsado1+1] )
				If !lTravou
					while !RecLock("ACT",.T.) ; enddo
				EndIf
				For nY := 1 to Len(aHeadNeg)
					If aHeadNeg[nY][10] <> "V"
						ACT->(FieldPut(FieldPos(aHeadNeg[nY][2]),aColsNeg[nX][nY]))
					EndIf
				Next nY
				cItem := Soma1(cItem)
				ACT->ACT_FILIAL := xFilial("ACT")
				ACT->ACT_CODREG := M->ACS_CODREG
				ACT->ACT_ITEM   := cItem
				MsUnLock()
				lGravou := .T.
			Else
				If lTravou
					ACT->(dbDelete()) 
				EndIf
			EndIf
			MsUnLock()
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda os registro para reaproveita-los - ACX                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aRegNo := {}
		cItem  := Repl("0",Len(ACX->ACX_ITEM))				
		
		dbSelectArea("ACX")
		ACX->(dbOrderNickName("ACX_CODRE1"))		//dbSetOrder(1)
		ACX->(dbSeek(xFilial("ACX")+M->ACS_CODREG))
		While !ACX->(EOF()) .AND. xFilial("ACX") == ACX->ACX_FILIAL .AND. M->ACS_CODREG == ACX->ACX_CODREG
			aadd(aRegNo,RecNo())
			dbSelectArea("ACX")
			ACX->(dbOrderNickName("ACX_CODRE1"))
			ACX->(dbSkip())
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os itens                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aColsCom)
			lTravou := .F.
			If nX <= Len(aRegNo)
				dbSelectArea("ACX")
				dbGoto(aRegNo[nX])
				while !RecLock("ACX") ; enddo
				lTravou := .T.
			EndIf
			If ( !aColsCom[nX][nUsado2+1] )
				If !lTravou
					while !RecLock("ACX",.T.) ; enddo
				EndIf
				For nY := 1 to Len(aHeadCom)
					If aHeadCom[nY][10] <> "V"
						ACX->(FieldPut(FieldPos(aHeadCom[nY][2]),aColsCom[nX][nY]))
					EndIf
				Next nY
				cItem := Soma1(cItem)
				ACX->ACX_FILIAL := xFilial("ACX")
				ACX->ACX_CODREG := M->ACS_CODREG
				ACX->ACX_ITEM   := cItem
				MsUnLock()
				lGravou := .T.
			Else        
				If lTravou
					ACX->(dbDelete())
				EndIf
			EndIf
			MsUnLock()
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda os registros para reaproveita-los                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aRegNo := {}
		cItem  := Repl("0",Len(ACN->ACN_ITEM))				
		
		dbSelectArea("ACN")
		ACN->(dbOrderNickName("ACN_CODRE1"))		//dbSetOrder(1)
		ACN->(dbSeek(xFilial("ACN")+M->ACS_CODREG))
		While !ACN->(EOF()) .AND. xFilial("ACN") == ACN->ACN_FILIAL .AND. M->ACS_CODREG == ACN->ACN_CODREG
			aadd(aRegNo,RecNo())
			dbSelectArea("ACN")
			ACN->(dbOrderNickName("ACN_CODRE1"))
			ACN->(dbSkip())
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os itens                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aColsDes)
			lTravou := .F.
			If nX <= Len(aRegNo)
				dbSelectArea("ACN")
				ACN->(dbOrderNickName("ACN_CODRE1"))
				dbGoto(aRegNo[nX])
				while !RecLock("ACN") ; enddo
				lTravou := .T.
			EndIf
			If ( !aColsDes[nX][nUsado3+1] )
				If !lTravou
					while !RecLock("ACN",.T.) ; enddo
				EndIf
				For nY := 1 to Len(aHeadDes)
					If aHeadDes[nY][10] <> "V"
						ACN->(FieldPut(FieldPos(aHeadDes[nY][2]),aColsDes[nX][nY]))
					EndIf
				Next nY
				cItem := Soma1(cItem)
				ACN->ACN_FILIAL := xFilial("ACN")
				ACN->ACN_CODREG := M->ACS_CODREG
				ACN->ACN_ITEM   := cItem
				MsUnLock()
				lGravou := .T.
			Else
				If lTravou
					ACN->(dbDelete()) 
				EndIf
			EndIf
			MsUnLock()
		Next nX
	Case nOpcao == 3
		dbSelectArea("ACT")
		ACT->(dbOrderNickName("ACT_CODRE1"))		//dbSetOrder(1)
		ACT->(dbSeek(xFilial("ACT")+M->ACS_CODREG))
		While !ACT->(EOF()) .AND. xFilial("ACT") == ACT->ACT_FILIAL .AND. M->ACS_CODREG == ACT->ACT_CODREG
			while !RecLock("ACT") ; enddo
			dbDelete()
			MsUnLock()
			dbSelectArea("ACT")
			ACT->(dbOrderNickName("ACT_CODRE1"))
			ACT->(dbSkip())
		EndDo
		dbSelectArea("ACX")
		ACX->(dbOrderNickName("ACX_CODRE1"))		//dbSetOrder(1)
		ACX->(dbSeek(xFilial("ACX")+M->ACS_CODREG))
		While !ACX->(EOF()) .AND. xFilial("ACX") == ACX->ACX_FILIAL .AND. M->ACS_CODREG == ACX->ACX_CODREG
			while !RecLock("ACX") ; enddo
			dbDelete()
			MsUnLock()
			dbSelectArea("ACX")
			ACX->(dbOrderNickName("ACX_CODRE1"))
			ACX->(dbSkip())
		EndDo

		dbSelectArea("ACN")
		ACN->(dbOrderNickName("ACN_CODRE1"))		//dbSetOrder(1)
		ACN->(dbSeek(xFilial("ACN")+M->ACS_CODREG))
		While !ACN->(EOF()) .AND. xFilial("ACN") == ACN->ACN_FILIAL .AND. M->ACS_CODREG == ACN->ACN_CODREG
			while !RecLock("ACN") ; enddo
			dbDelete()
			ACN->(MsUnLock())
			dbSelectArea("ACN")
			ACN->(dbOrderNickName("ACN_CODRE1"))
			ACN->(dbSkip())
		EndDo
		dbSelectArea("ACS")
		ACS->(dbOrderNickName("ACS_CODREG"))		//dbSetOrder(1)
		If ACS->(dbSeek(xFilial("ACS")+M->ACS_CODREG))
			while !RecLock("ACS") ; enddo
			dbDelete()
			MsUnLock()
		EndIf
EndCase

Return(lGravou)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft100LOk1 ³ Autor ³Eduardo Riera          ³ Data ³ 09/05/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da linha Ok                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ft100Lok1()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ft100Lok1()

Local aArea     := GetArea()
Local lRetorno  := .T.
Local nPCodTab  := aScan(aHeader,{|x| AllTrim(x[2])=="ACT_CODTAB"})
Local nPCondPg  := aScan(aHeader,{|x| AllTrim(x[2])=="ACT_CONDPG"})
Local nPFormPg  := aScan(aHeader,{|x| AllTrim(x[2])=="ACT_FORMPG"})
Local nPTpNeg   := aScan(aHeader,{|x| AllTrim(x[2])=="ACT_TPRGNG"})
Local nUsado    := Len(aHeader)
Local nX        := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica os campos obrigatorios                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][nUsado+1]
	Do Case
		Case nPCodTab == 0 .OR. nPCondPg  == 0 .OR. nPFormPg == 0
			lRetorno := .F.
			Help(" ",1,"OBRIGAT",,RetTitle("ACT_CODTAB")+","+RetTitle("ACT_CONDPG")+","+RetTitle("ACT_FORMPG"),4)
		Case Empty(aCols[n][nPCodTab]) .AND. Empty(aCols[n][nPCondPg]) .AND. Empty(aCols[n][nPFormPg])  .AND. n<>1
			lRetorno := .F.
			Help(" ",1,"OBRIGAT",,RetTitle("ACT_CODTAB")+","+RetTitle("ACT_CONDPG")+","+RetTitle("ACT_FORMPG"),4)
	EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VerIfica se nao ha valores duplicados                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		For nX := 1 To Len(aCols)
			If nX <> N .AND. !aCols[nX][nUsado+1]
				If ( aCols[nX][nPCodTab]+aCols[nX][nPCondPg]+aCols[nX][nPFormPg] == aCols[N][nPCodTab]+aCols[N][nPCondPg]+aCols[N][nPFormPg] )
					lRetorno := .F.
					Help(" ",1,"JAGRAVADO")
				EndIf
			EndIf
		Next nX
	EndIf
EndIf
RestArea(aArea)
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft100TOk1 ³ Autor ³Eduardo Riera          ³ Data ³ 10/05/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da TudoOk                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ft100Tok1()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ft100Tok1()

Local lRetorno := .T.

If ExistBlock("RFATA015")
	//Chamada da rotina responsável por fazer a amarração produtos x clientes com base nas regras de negócios (descontos)
	MsgRun("Aguarde... Atualizando amarração Produto x Cliente...","RFATA014",{ || lRetorno :=	ExecBlock("RFATA015")})
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft100LOk2 ³ Autor ³Eduardo Riera          ³ Data ³ 09/05/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da linha Ok                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ft100Lok2()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ft100Lok2()

Local aArea     := GetArea()
Local lRetorno  := .T.
Local nPCodPro  := aScan(aHeader,{|x| AllTrim(x[2])=="ACX_CODPRO"})
Local nPGrupo   := aScan(aHeader,{|x| AllTrim(x[2])=="ACX_GRUPO"})
Local nUsado    := Len(aHeader)
Local nX        := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica os campos obrigatorios                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][nUsado+1]
	Do Case
		Case nPCodPro == 0 .OR. nPGrupo  == 0
			lRetorno := .F.
			Help(" ",1,"OBRIGAT",,RetTitle("ACX_CODPRO")+","+RetTitle("ACT_GRUPO"),4)
		Case Empty(aCols[n][nPCodPro]) .AND. Empty(aCols[n][nPGrupo]) .AND. n<>1
			lRetorno := .F.
			Help(" ",1,"OBRIGAT",,RetTitle("ACX_CODPRO")+","+RetTitle("ACT_GRUPO"),4)
	EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VerIfica se nao ha valores duplicados                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		For nX := 1 To Len(aCols)
			If nX <> N .AND. !aCols[nX][nUsado+1]
				If ( aCols[nX][nPCodPro]+aCols[nX][nPGrupo] == aCols[N,nPCodPro]+aCols[N][nPGrupo] )
					lRetorno := .F.
					Help(" ",1,"JAGRAVADO")
				EndIf
			EndIf
		Next nX
	EndIf
EndIf
RestArea(aArea)
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft100LOk3 ³ Autor ³Eduardo Riera          ³ Data ³ 09/05/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da linha Ok                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ft100Lok2()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ft100Lok3()

Local aArea     := GetArea()
Local lRetorno  := .T.
Local nPCodPro  := aScan(aHeader,{|x| AllTrim(x[2])=="ACN_CODPRO"})
Local nPGrupo   := aScan(aHeader,{|x| AllTrim(x[2])=="ACN_GRPPRO"})
Local nPDesc    := aScan(aHeader,{|x| AllTrim(x[2])=="ACN_DESCON"})
Local nUsado    := Len(aHeader)
Local nX        := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica os campos obrigatorios                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][nUsado+1]
	If !Empty(aCols[n][nPCodPro]) .AND. !Empty(aCols[n][nPGrupo]) 
		Help(" ",1,"FT100DESC")
		lRetorno := .F.
	EndIf
EndIf  
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se nao ha valores duplicados                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	For nX := 1 To Len(aCols)
		If nX <> N .AND. !aCols[nX][nUsado+1]
			If ( aCols[nX][nPCodPro]+aCols[nX][nPGrupo] == aCols[N,nPCodPro]+aCols[N][nPGrupo] )
				lRetorno := .F.
				Help(" ",1,"JAGRAVADO")
			EndIf
		EndIf
	Next nX
EndIf

RestArea(aArea)
Return(lRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft100TOk  ³ Autor ³Eduardo Riera          ³ Data ³ 10/05/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da TudoOk                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ft100Tok2()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ft100Tok2()

Local lRetorno := .T.

Return(lRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FtRegraNeg³ Autor ³Eduardo Riera          ³ Data ³15.05.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de avaliacao da regra de Negocio                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Cliente                                    ³±±
±±³          ³ExpC2: Loja do Cliente                                      ³±±
±±³          ³ExpC3: Tabela de Preco                                      ³±±
±±³          ³ExpC4: Condicao de Pagamento                                ³±±
±±³          ³ExpC5: Forma de Pagamento                                   ³±±
±±³          ³ExpA6: Array unidimensional contendo os codigos de produtos ³±±
±±³          ³       [1]-Codigo do Produto                                ³±±
±±³          ³       [2]-Item do pedido de venda                          ³±±
±±³          ³       [3]-Desconto do pedido                               ³±±
±±³          ³       [4]-Desconto permitido por regra                     ³±±
±±³          ³       [5]-Status "01" Blq. Regra "02" Blq.Verba            ³±±
±±³          ³ExpL7: Exibe Help                                           ³±±
±±³          ³ExpL8: Analisa Verba                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Negociacao valida                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo avaliar a regra de Negocio    ³±±
±±³          ³conforme os parametros da rotina                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FtRegraNeg(cCliente,cLoja,cTabPreco,cCondPg,cFormPg,aProdDesc,lHelp)

Local aArea      := GetArea()
Local aAreaACS   := ACS->(GetArea())
Local aParam     := Nil
Local aGrupos    := {}    
Local aProdutos  := {}

Local bCondic    := { || .T. } 

Local cHoraAtual := Left( Time(), 5 )  
Local cDtHrAtual := DToS( dDataBase ) + cHoraAtual 
Local cDataAtual := DToS( dDataBase )

Local cDataVazia := Space( Len( DToS( ACS->ACS_DATATE ) ) ) 
Local cAliasACS  := ""
Local cGrpVen    := ""

Local dDataVazia := CToD( "" )    

Local lContinua  := .T.
Local lRetorno   := .T.
Local lContVerba := .T.

Local nX         := 0
Local nLoop      := 0 
Local nScan      := 0

Default cCliente  := Space( Len( SA1->A1_COD  ) )
Default cLoja     := Space( Len( SA1->A1_LOJA ) )
Default cTabPreco := Space( Len( DA0->DA0_CODTAB ) )
Default cCondPg   := Space( Len( DA0->DA0_CONDPG ) )
Default cFormPg   := Space( Len( ACO->ACO_FORMPG ) )
Default aProdutos := {} 
Default aProdDesc := {} 
Default lHelp     := .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a forma de pagamnto estiver vazia pega a partir da condição.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCondPg) .AND. Empty(cFormPg)
	cFormPg := Posicione( "SE4", 1, xFilial("SE4") + cCondPg, "E4_FORMA" ) 
EndIf

If Len(aProdDesc) > 0           
	Aeval(aProdDesc, {|x| If(x[9] .AND. Empty(Ascan(aProdutos, x[1]) ),Aadd(aProdutos,x[1]),)})
EndIf	

#IfDEF TOP
	bCondic := { || .T. }
#ELSE	
	bCondic := { || ( ACS->ACS_TPHORA == "1" .AND. cDtHrAtual >= DToS( ACS->ACS_DATDE ) + ACS->ACS_HORDE .AND. ;
				( ACS->ACS_DATATE == dDataVazia .OR. cDtHrAtual <= DToS( ACS->ACS_DATATE ) + ACS->ACS_HORATE	) ) .OR. ;	
				( ACS->ACS_TPHORA == "2" .AND. ddatabase >= ACS->ACS_DATDE .AND. ;
				( ACS->ACS_DATATE == dDataVazia .OR. dDataBase <= ACS->ACS_DATATE ) .AND. ;
					cHoraAtual >= ACS->ACS_HORDE .AND. cHoraAtual <= ACS->ACS_HORATE ) }  
#ENDIf 					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa a regra para o cliente                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IfDEF TOP
	cAliasACS := "_QRYACS1" 
	
	cQuery := ""
	cQuery += "SELECT * FROM "  + RetSqlName( "ACS" ) + " " 
	cQuery += "WHERE "	
	cQuery += "ACS_FILIAL='"    + xFilial( "ACS" )    + "' AND " 
	cQuery += "ACS_CODCLI='"    + cCliente            + "' AND " 
	cQuery += "ACS_LOJA='"      + cLoja               + "' AND "

	cQuery += "( ( ACS_TPHORA='1' AND ('" + cDataAtual + "'>ACS_DATDE OR ('" + cDataAtual + "'=ACS_DATDE AND '" + cHoraAtual + "'>=ACS_HORDE ) ) AND " 
	cQuery += " ( ACS_DATATE='" + cDataVazia +"' OR ('" + cDataAtual + "'<ACS_DATATE OR ('" + cDataAtual + "'=ACS_DATATE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) ) ) OR " 
	cQuery += "( ACS_TPHORA='2' AND '" + DToS( dDatabase ) + "'>=ACS_DATDE AND ( ACS_DATATE='" + cDataVazia +"' OR "
	cQuery += "'" + DToS( dDataBase ) + "'<=ACS_DATATE ) AND '" + cHoraAtual + "'>=ACS_HORDE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) AND "   
	
	cQuery += "D_E_L_E_T_=' '"  
	
	cQuery := ChangeQuery( cQuery )        
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACS, .F., .T. ) 
       
#ELSE           
	
	cAliasACS := "ACS" 

	(cAliasACS)->(dbOrderNickName("ACS_CODCLI"))		//ACS->( dbSetOrder( 2 ) ) 
	(cAliasACS)->(dbSeek(xFilial("ACS") + cCliente + cLoja))

#ENDIf 

While !( cAliasACS )->( Eof() ) .AND. xFilial("ACS") == ( cAliasACS )->ACS_FILIAL .AND.;
			cCliente == ( cAliasACS )->ACS_CODCLI .AND.;
			cLoja    == ( cAliasACS )->ACS_LOJA 
	
	If Eval( bCondic ) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia a regra para o item                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                           
		lRetorno   := .F. 		
		FtRegNegIt( ( cAliasACS )->ACS_CODREG, cTabPreco, cCondPg, cFormPg, aProdutos, @aProdDesc, @lContinua, @lRetorno, @lContVerba  )
	EndIf 	
		
	If !lContinua
		Exit 
	EndIf 								
					
	( cAliasACS )->( dbSkip() ) 			
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha a area de trabalho da query                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
( cAliasACS )->( dbCloseArea() )  


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa a regra para o grupo de clientes                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua                                   

	SA1->( dbSetOrder( 1 ) ) 
	SA1->( DbSeek( xFilial( "SA1" ) + cCliente + cLoja ) ) 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se o cliente esta inserido em um grupo de clientes            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cGrpVen := SA1->A1_GRPVEN
	If !Empty( cGrpVen ) 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem a estrutura acima do grupo do cliente                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aGrupos := {} 
		MaCliStrUp( cGrpVen, @aGrupos )  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Percorre todos os grupos para localizar uma regra                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   	For nLoop := 1 To Len( aGrupos )   

			#IfDEF TOP 
			
				cAliasACS := "_QRYACS3" 
				
				cQuery := ""
				cQuery += "SELECT * FROM "  + RetSqlName( "ACS" ) + " " 
				cQuery += "WHERE "					
				cQuery += "ACS_FILIAL='"    + xFilial( "ACS" )    + "' AND " 
				cQuery += "ACS_GRPVEN='"    + aGrupos[ nLoop, 1 ] + "' AND " 
				
				cQuery += "( ( ACS_TPHORA='1' AND ('" + cDataAtual + "'>ACS_DATDE OR ('" + cDataAtual + "'=ACS_DATDE AND '" + cHoraAtual + "'>=ACS_HORDE))  AND " 
				cQuery += " ( ACS_DATATE='" + cDataVazia +"' OR ('" + cDataAtual + "'<ACS_DATATE OR ('" + cDataAtual + "'=ACS_DATATE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) ) ) OR " 
				
				cQuery += "( ACS_TPHORA='2' AND '" + DToS( dDatabase ) + "'>=ACS_DATDE AND ( ACS_DATATE='" + cDataVazia +"' OR "
				cQuery += "'" + DToS( dDataBase ) + "'<=ACS_DATATE ) AND '" + cHoraAtual + "'>=ACS_HORDE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) AND "   
										
				cQuery += "D_E_L_E_T_=' '" 
				
				cQuery := ChangeQuery( cQuery ) 
				
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACS, .F., .T. ) 
			       
			#ELSE           
				
				cAliasACS := "ACS" 
			
				(cAliasACS)->(dbOrderNickName("ACS_GRPVEN"))		//ACS->( dbSetOrder( 3 ) ) 
				(cAliasACS)->(dbSeek(xFilial("ACS") + aGrupos[ nLoop, 1 ]))

			#ENDIf 

			While !( cAliasACS )->( Eof() ) .AND. xFilial("ACS") == ( cAliasACS )->ACS_FILIAL .AND.;
						aGrupos[ nLoop, 1 ] == ( cAliasACS )->ACS_GRPVEN
						
				If Eval( bCondic ) 							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Avalia a regra para o item                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRetorno   := .F. 
					FtRegNegIt( ( cAliasACS )->ACS_CODREG, cTabPreco, cCondPg, cFormPg, aProdutos, @aProdDesc, @lContinua, @lRetorno, @lContVerba  )
				EndIf 
					
				If !lContinua                      
					Exit 
				EndIf 								

				( cAliasACS )->( dbSkip() )	
			  
			EndDo	         

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fecha a area de trabalho da query                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			( cAliasACS )->( dbCloseArea() ) 
			
			If !lContinua 
				Exit
			EndIf 	

		Next nLoop 

	EndIf 
	
EndIf 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa a regra para o codigo de clientes e grupo em branco           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua 

	#IfDEF TOP 
	
		cAliasACS := "_QRYACS2" 
		
		cQuery := ""
		cQuery += "SELECT * FROM "  + RetSqlName( "ACS" )              + " " 
		cQuery += "WHERE "			
		cQuery += "ACS_FILIAL='"    + xFilial( "ACS" )                 + "' AND " 
		cQuery += "ACS_CODCLI='"    + Space( Len( ACS->ACS_CODCLI ) ) + "' AND " 
		cQuery += "ACS_LOJA='"      + Space( Len( ACS->ACS_LOJA   ) ) + "' AND "
		cQuery += "ACS_GRPVEN='"    + Space( Len( ACS->ACS_GRPVEN ) ) + "' AND "
		
		cQuery += "( ( ACS_TPHORA='1' AND ('"+cDataAtual+"'>ACS_DATDE OR ('"+cDataAtual+"'=ACS_DATDE AND '"+cHoraAtual+"'>=ACS_HORDE ) ) AND " 
		cQuery += " ( ACS_DATATE='"+cDataVazia+"' OR ('"+cDataAtual+"'<ACS_DATATE OR ('"+cDataAtual+"'=ACS_DATATE AND '"+cHoraAtual+"'<=ACS_HORATE ) ) ) ) OR " 
		
		cQuery += "( ACS_TPHORA='2' AND '" + DToS( dDatabase ) + "'>=ACS_DATDE AND ( ACS_DATATE='" + cDataVazia +"' OR "
		cQuery += "'" + DToS( dDataBase ) + "'<=ACS_DATATE ) AND '" + cHoraAtual + "'>=ACS_HORDE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) AND "   
				
		cQuery += "D_E_L_E_T_=' '" 
		
		cQuery := ChangeQuery( cQuery ) 
		
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACS, .F., .T. ) 
		
		bWhile := { || !( cAliasACS )->( Eof() ) } 
	       
	#ELSE           
   	                                    
	   cSeekACS := xFilial( "ACS" ) + Space( Len( ACS->ACS_GRPVEN + ACS->ACS_CODCLI + ACS->ACS_LOJA ) )  	
	   	
		ACS->( dbSetOrder( 3 ) ) 
		ACS->( DbSeek( cSeekACS )	) 
		
		bWhile := { || !ACS->( Eof() ) .AND. cSeekACS == ACS->ACS_FILIAL + ACS->ACS_GRPVEN + ACS->ACS_CODCLI + ACS->ACS_LOJA }
		     
	#ENDIf 	
		
	While Eval( bWhile ) 
	              
		If Eval( bCondic ) 									              
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Avalia a regra para o item                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRetorno   := .F. 
			FtRegNegIt( ( cAliasACS )->ACS_CODREG, cTabPreco, cCondPg, cFormPg, aProdutos, @aProdDesc, @lContinua, @lRetorno, @lContVerba  )
		EndIf 	
			
		If !lContinua
			Exit 
		EndIf 								

		( cAliasACS )->( dbSkip() )	
	  
	EndDo	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha a area de trabalho da query                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	( cAliasACS )->( dbCloseArea() ) 
	
EndIf
	                 	
If !lRetorno .AND. lHelp 
	Help(" ",1,"FTREGRANEG")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso achou bloqueio de regra marca todos os registros dos pedidos como ³
//³ bloqueado                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRetorno     
	For nLoop := 1 to Len(aProdDesc)
		aProdDesc[nLoop,7] := "01"
	Next
EndIf		
	
RestArea(aAreaACS)
RestArea(aArea)

Return(lRetorno .AND. lContVerba)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FtRegNegIt³ Autor ³ Sergio Silveira       ³ Data ³14/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Avaliacao dos itens da regra de negocios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FtRegNegIt(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpL1,ExpL2)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da regra                                      ³±±
±±³          ³ExpC2: Tabela de Preco                                      ³±±
±±³          ³ExpC3: Condicao de Pagamento                                ³±±
±±³          ³ExpC4: Forma de Pagamento                                   ³±±
±±³          ³ExpC5: Codigo do produto                                    ³±±
±±³          ³ExpL1: Indica se continua pesquisa ( pass. por referencia ) ³±±
±±³          ³ExpL2: Indica se regra ou excessao ( pass. por referencia ) ³±±
±±³          ³ExpL2: Indica se continua verba    ( pass. por referencia ) ³±±
±±³          ³ExpL2: Indica se verIfica verba                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo avaliar os itens da regra     ³±±
±±³          ³de negocio especIficada conforme os parametros              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conrado Q.    ³27/03/07³120361³Corrigido algoritimo de verIficação de  ³±±
±±³              ³        ³      ³bloqueio de regra na tab. de negociação.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FtRegNegIt(cCodReg,cTabPreco,cCondPg,cFormPg,aProdutos, aProdDesc,lContinua,lRetorno,lContVerba)
                                                      
Local aSearch   := {} 											// Array com variantes de busca no DbSeek para caso utilizado um grupo de produtos na regra, ou somente um produto
Local cGrupo    := ""											// Grupo de produtos da regra
Local cCodPro   := ""											// Código do produto da regra
Local lContItem := .T.											// Se encontrar algum grupo ou produto na regra sai do loop
Local nX        := 0											// Contador
Local nLoop     := 0 											// Contador
Local nLoop2    := 0											// Contador
Local lSomaVer  := (SuperGetMv("MV_SOMAVER",.F.,"S") == "S")	// Indica se caso o vendedor realize uma venda com preco maior que o de tabela, a dIferenca sera adicionada a verba correspondente.
Local aRegras	:= {}											// Regras e excecões encontradas para essa regra de negociação

#IfDEF TOP 
	Local cQuery    := ""	// Query utilizada no select
	Local cAliasQry := ""	// Alias da query
	Local lContDesc := .T.	// Utilizado para procurar algum bloqueio por regra
	Local nCntFor   := 0 	// Contador
	Local aStruACN  := {}	// Estrutura utilizado no loop para correção dos campos retornados pelo TOP
#ENDIf 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona regras a uma array para posterior análise.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACT->( DbSetOrder( 1 ) )
If ACT->(DbSeek( xFilial("ACT") + cCodReg ))
	Do While (	ACT->ACT_FILIAL		== xFilial("ACT") .AND.	;
				ACT->ACT_CODREG		== cCodReg )
		aAdd( aRegras, { ACT->ACT_TPRGNG, ACT->ACT_CODTAB, ACT->ACT_CONDPG, ACT->ACT_FORMPG } )
		ACT->(DbSkip())	
	EndDo
EndIf

If Len( aRegras ) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se só houver excecão, parte do princípio que está aprovado³
	//³até que alguma excecão bloqueie.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aScan( aRegras, { |x| x[1] == "2" } ) > 0 .AND. aScan( aRegras, { |x| x[1] == "1" } ) == 0
		lRetorno := .T.
		For nX := 1 To Len( aRegras )
			If(	If(Empty(aRegras[nX,2]), .T., AllTrim(aRegras[nX,2]) == Alltrim(cTabPreco) )	.AND.;
				If(Empty(aRegras[nX,3]), .T., AllTrim(aRegras[nX,3]) == Alltrim(cCondPg) )	.AND.;
				If(Empty(aRegras[nX,4]), .T., AllTrim(aRegras[nX,4]) == Alltrim(cFormPg) )	)
				lRetorno := .F.
				lContinua := .F.
			EndIf
		Next		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se não, VerIfica a liberação item a item das regras e excecões.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		For nX := 1 To Len( aRegras )
			If(	If(Empty(aRegras[nX,2]), .T., AllTrim(aRegras[nX,2]) == Alltrim(cTabPreco) )	.AND.;
				If(Empty(aRegras[nX,3]), .T., AllTrim(aRegras[nX,3]) == Alltrim(cCondPg) )	.AND.;
				If(Empty(aRegras[nX,4]), .T., AllTrim(aRegras[nX,4]) == Alltrim(cFormPg) )	)
				lRetorno := ( aRegras[nX,1] == "1" )
				lContinua := .F.
			EndIf
		Next
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa os itens de comercializacao, mesmo que tenha encontrado       ³
//³ um item negociacao valido, para localizar uma possivel excessao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .OR. lContinua 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Percorre todos os produtos                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoop2 := 1 To Len( aProdutos )  
	
		cCodPro := aProdutos[ nLoop2 ] 

		SB1->( dbSetOrder( 1 ) ) 
	   If SB1->( DbSeek( xFilial( "SB1" ) + cCodPro ) ) 
	
			cGrupo := SB1->B1_GRUPO 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alimenta as opcoes de pesquisa                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty( cGrupo ) 
				aSearch := { { SB1->B1_COD, Space( Len( SB1->B1_GRUPO ) ) } }
			Else			
			   aSearch := { { SB1->B1_COD, Space( Len( SB1->B1_GRUPO ) ) },;
			   				{ Space( Len( SB1->B1_COD ) ), cGrupo } } 	
			EndIf 
	
			ACX->( dbSetOrder( 2 ) )
			
			For nLoop := 1 To Len( aSearch ) 
	
				If ACX->( dbSeek( xFilial( "ACX" ) + cCodReg + aSearch[ nLoop, 1 ] + aSearch[ nLoop, 2 ] ) ) 
					lRetorno  := ACX->ACX_TPRGNG == "1"
					lContinua := .F.
					lContItem := .F. 
					Exit
	         EndIf 
	   
			Next nLoop    
	
		EndIf    
		
		If !lContItem
			Exit 
		EndIf 	
		
	Next nLoop2 	
	
EndIf 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se existe regras de desconto de verba.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRetorno .AND. lContVerba

	aStruACN:= ACN->(dbStruct())
       
	For nLoop := 1 to Len(aProdDesc)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VerIfica se o item deve ser analisado          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    
		If aProdDesc[ nLoop, 9 ]
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o preco de lista for dIferente do de venda  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			Do Case
			
			Case aProdDesc[nLoop,3] < aProdDesc[nLoop,4]
	
				#IfDEF TOP

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busca regra por Produto Preenchido + Grupo em branco      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					aStructACN := ACN->(dbStruct())
			
					cAliasQry := "QRYACN"
					
					cQuery := "SELECT ACN_DESCON FROM "
					cQuery += RetSqlName("ACN")+ " ACN " 
					cQuery += " WHERE "
					cQuery += "ACN_FILIAL = '"+xFilial("ACN")+ "' AND "
					cQuery += "ACN_CODREG = '"+cCodReg+"' AND "
					cQuery += "ACN_CODPRO = '"+aProdDesc[nLoop,1]+"' AND "
					cQuery += "ACN_GRPPRO = '"+Space(Len(ACN->ACN_GRPPRO))+"' AND "
					cQuery += "ACN.D_E_L_E_T_ = ' '"
					
					cQuery := ChangeQuery( cQuery )        

					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQRY, .F., .T. ) 

					For nCntFor := 1 To Len(aStruACN)
						If ( aStruACN[nCntFor,2]<>"C" )
							TcSetField(cAliasQry,aStruACN[nCntFor,1],aStruACN[nCntFor,2],aStruACN[nCntFor,3],aStruACN[nCntFor,4])
						EndIf
					Next nCntFor
    	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Marca flag para verIficacao da verba           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
					If (cAliasQRY)->(!Eof())
						lContDesc := .F.
						If aProdDesc[nLoop,5] > (cAliasQry)->ACN_DESCON 
							aProdDesc[nLoop,6] := (cAliasQry)->ACN_DESCON                  					
							aProdDesc[nLoop,7] := "02"                  
							lContVerba:= .F.
						EndIf
					EndIf

					dbSelectArea(cAliasQry)
					dbCloseArea()
        	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se nao encontrou ,busca por Produto em Branco + Grupo Preenchido³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
					If lContDesc

						SB1->(dbSetOrder(1))
						If SB1->(DbSeek(xFilial("SB1")+aProdDesc[nLoop,1]))
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se nao existe grupo cadastrado nao traz regra  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty(SB1->B1_GRUPO)
								
								cAliasQry := "QRYACN"
								
								cQuery := "SELECT ACN_DESCON FROM "
								cQuery += RetSqlName("ACN")+ " ACN "
								cQuery += " WHERE "
								cQuery += "ACN_FILIAL = '"+xFilial("ACN")+ "' AND "
								cQuery += "ACN_CODREG = '"+cCodReg+"' AND "
								cQuery += "ACN_CODPRO = '"+Space(Len(ACN->ACN_CODPRO))+"' AND "
								cQuery += "ACN_GRPPRO = '"+SB1->B1_GRUPO+"' AND "
								cQuery += "ACN.D_E_L_E_T_ = ' '"
								
								cQuery := ChangeQuery( cQuery )
								
								dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
		
								For nCntFor := 1 To Len(aStruACN)
									If ( aStruACN[nCntFor,2]<>"C" )
										TcSetField(cAliasQry,aStruACN[nCntFor,1],aStruACN[nCntFor,2],aStruACN[nCntFor,3],aStruACN[nCntFor,4])
									EndIf
								Next nCntFor
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Marca flag para verIficacao da verba           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If (cAliasQRY)->(!Eof())
									lContDesc := .F.
									If aProdDesc[nLoop,5] > (cAliasQry)->ACN_DESCON
										aProdDesc[nLoop,6] := (cAliasQry)->ACN_DESCON
										aProdDesc[nLoop,7] := "02"
										lContVerba:= .F.
									EndIf
								EndIf
	
								dbSelectArea(cAliasQry)
								dbCloseArea()
							EndIf
							
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se nao encontrou ,busca por Produto em Branco + Grupo em Branco ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lContDesc

							cAliasQry := "QRYACN"
							
							cQuery := "SELECT ACN_DESCON FROM "
							cQuery += RetSqlName("ACN")+ " ACN "
							cQuery += " WHERE "
							cQuery += "ACN_FILIAL = '"+xFilial("ACN")+ "' AND "
							cQuery += "ACN_CODREG = '"+cCodReg+"' AND "
							cQuery += "ACN_CODPRO = '"+Space(Len(ACN->ACN_CODPRO))+"' AND "
							cQuery += "ACN_GRPPRO = '"+Space(Len(ACN->ACN_GRPPRO))+"' AND "
							cQuery += "ACN.D_E_L_E_T_ = ' '"
					
							cQuery := ChangeQuery( cQuery )
		
							dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
	  
							For nCntFor := 1 To Len(aStruACN)
								If ( aStruACN[nCntFor,2]<>"C" )
									TcSetField(cAliasQry,aStruACN[nCntFor,1],aStruACN[nCntFor,2],aStruACN[nCntFor,3],aStruACN[nCntFor,4])
								EndIf
							Next nCntFor
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Marca flag para verIficacao da verba           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasQRY)->(!Eof())
								lContDesc := .F.
								If aProdDesc[nLoop,5] > (cAliasQry)->ACN_DESCON
									aProdDesc[nLoop,6] := (cAliasQry)->ACN_DESCON
									aProdDesc[nLoop,7] := "02"
									lContVerba:= .F.
								EndIf
							Else
								aProdDesc[nLoop,6] := 0
								aProdDesc[nLoop,7] := "02"
								lContVerba:= .F.
							EndIf
							dbSelectArea(cAliasQry)
							dbCloseArea()
						EndIf
					EndIf
				
				#ELSE
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o parametro estiver para somar na verba do cliente caso venda com preco     ³
					//³maior que a tabela nao precisa verIficar desconto da regra                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					ACN->(dbSetOrder(2))
					If ACN->(DbSeek(xFilial("ACN")+Space(Len(SB1->B1_GRUPO))+aProdDesc[nLoop,1]+cCodReg))
						If aProdDesc[nLoop,5] > ACN->ACN_DESCON
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Grava desconto permitido na verba e status para verIficacao de saldo³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aProdDesc[nLoop,6] := ACN->ACN_DESCON
							aProdDesc[nLoop,7] := "02"
							lContVerba:= .F.
						EndIf
					Else
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busca por grupo de produtos caso nao exista com o produto           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SB1->(dbSetOrder(1))
						If SB1->(DbSeek(xFilial("SB1")+aProdDesc[nLoop,1]))
							ACN->(dbSetOrder(2))
							If ACN->(DbSeek(xFilial("ACN")+SB1->B1_GRUPO+Space(Len(SB1->B1_COD))+cCodReg))
							
								If aProdDesc[nLoop,5] > ACN->ACN_DESCON 
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Grava desconto permitido na verba e status para verIficacao de saldo³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									aProdDesc[nLoop,6] := ACN->ACN_DESCON
									aProdDesc[nLoop,7] := "02"
									lContVerba:= .F.
								EndIf
							Else
								aProdDesc[nLoop,6] := ACN->ACN_DESCON
								aProdDesc[nLoop,7] := "02"
								lContVerba:= .F.
							EndIf
						EndIf
					EndIf
				#ENDIf
				
			Case aProdDesc[nLoop,3] > aProdDesc[nLoop,4] .AND. lSomaVer
				aProdDesc[nLoop,6] := 0
				aProdDesc[nLoop,7] := "02"
				lContVerba:= .F.

			EndCase
		EndIf
	Next
	
EndIf

Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ft100Fld  ³ Autor ³Eduardo Riera          ³ Data ³13.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento dos Folders                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Folder de Destino                                    ³±±
±±³          ³ExpN2: Folder Atual                                         ³±±
±±³          ³ExpO3: Objeto do Folder                                     ³±±
±±³          ³ExpA4: Array com as getdados.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ft100Fld(nFldDst,nFldAtu,oFolder,aGetDad)


Local lRetorno:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Validacao da GetDados                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( aGetDad[nFldAtu]:TudoOk() )

	lRetorno := .T.
	aGetDad[nFldAtu]:oBrowse:lDisablePaint := .T.
	N := Max(aGetDad[nFldDst]:oBrowse:nAt,1)
	
	aGetDad[nFldDst]:oBrowse:nColPos := 1
	aGetDad[nFldDst]:oBrowse:lDisablePaint := .F.
	aGetDad[nFldDst]:oBrowse:Refresh(.T.)
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ft100Ok   ³ Autor ³Eduardo Riera          ³ Data ³09.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da Enchoicebar                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Getdados 1                                           ³±±
±±³          ³ExpO2: GetDados 2                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ft100Ok(oGetd1,oGetd2,oGetD3,aColsNeg,aColsCom,aColsDes,oFolder)

Local lRetorno := .T.

lRetorno := Eval(oFolder:bSetOption,1)

If lRetorno 
	oFolder:nOption := 1
	If !oGetd1:TudoOk()
		lRetorno := .F.
	EndIf
EndIf

If lRetorno
	lRetorno := Eval(oFolder:bSetOption,2)
	If lRetorno
		oFolder:nOption := 1
		If !oGetd2:TudoOk()
			lRetorno := .F.
		EndIf
	EndIf
EndIf

If lRetorno
	lRetorno := Eval(oFolder:bSetOption,3)
	If lRetorno
		oFolder:nOption := 3
		If !oGetd3:TudoOk()
			lRetorno := .F.
		EndIf
	EndIf
EndIf

If lRetorno
	aColsNeg := aClone(oGetD1:aCols)
	aColsCom := aClone(oGetD2:aCols)
	aColsDes := aClone(oGetD3:aCols)
EndIf

Return(lRetorno)