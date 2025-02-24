#include "totvs.ch"
#include "fileio.ch"
#include "topconn.ch"
/*/{Protheus.doc} RFATA013
@description Rotina de exportação e/ou importação das tabelas de preços.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/10/2013
@version 1.0
@type function
@history 11/09/2020, Anderson C. P. Coelho, Realizado ajuste para a exportação das tabelas de preços, dada a descontinuidade de funções por parte da TOTVS para o novo release.
@history 06/01/2021, Diego Rodrigues Pereira, Alterar o parametro da tabela de preço utilizado no fonte GP010VALPE no momento que fizer a importação
@see https://allss.com.br
/*/
user function RFATA013()
	local   _aTam     := {}

	private cDrive, cDir, cNome, cExt
	private _aStru    := {}
	private cCadastro := "Manipulação das Tabelas de Preços por arquivo CSV"
	private _cRotina  := "RFATA013"
	private cPerg1    := "RFATA0131"
	private _cArqTP   := ""
	private cAliasDA1 := GetNextAlias()		//"DA1TMP"
	//-----------------------------------------------------
	// Criação da Tabela Temporária Temporária (TRBTMP)
	//-----------------------------------------------------
	/*-----------------------------------------------------
	|              Definições Importantes:                |
	-------------------------------------------------------
	|      _aTam[3]       |    _aTam[1]		  | _aTam[2]   |
	-------------------------------------------------------
	| "C", "D", "N", etc. | Tamanho do Campo  | Decimais  |
	-------------------------------------------------------*/
	_aTam  := TamSX3("DA1_CODTAB")
	AADD(_aStru,{ "TABELA"      ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("DA1_ITEM"  )
	AADD(_aStru,{ "ITEM"        ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("DA1_GRUPO" )
	AADD(_aStru,{ "GRUPO"       ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("DA1_CODPRO")
	AADD(_aStru,{ "PRODUTO"     ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B1_DESC"   )
	AADD(_aStru,{ "DESCRICAO"   ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B1_UM"     )
	AADD(_aStru,{ "UM"          ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("DA1_PRCVEN")
	AADD(_aStru,{ "PRECO"       ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("DA1_ESTADO")
	AADD(_aStru,{ "UF"          ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("DA1_QTDLOT")
	AADD(_aStru,{ "QUANTIDADE"  ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("DA1_FILIAL")
	AADD(_aStru,{ "FILIAL"      ,_aTam[3],_aTam[1],_aTam[2] } )
	ValidPerg1()
	static oDlg
	DEFINE MSDIALOG oDlg FROM  096,004 TO 355,625 TITLE cCadastro PIXEL
		@ 018, 009 TO 099, 300 LABEL "" OF oDlg  PIXEL
		@ 028, 015 Say OemToAnsi("Este programa é utilizado para a geração de arquivo CSV das tabelas de preços selecionadas através ") SIZE 275, 10 OF oDlg PIXEL
		@ 038, 015 Say OemToAnsi("dos parâmetros. A rotina também é utilizada para a importar arquivos em formato CSV para a criação ") SIZE 275, 10 OF oDlg PIXEL
		@ 048, 015 Say OemToAnsi("de novas tabelas de preços. O arquivo de importação deverá respeitar o layout definido pela rotina.") SIZE 275, 10 OF oDlg PIXEL
		@ 058, 015 Say OemToAnsi(">>> CLIQUE EM 'EDITAR' P/ EXPORTAR O ARQUIVO EM FORMATO CSV (EXCEL).                               ") SIZE 275, 10 OF oDlg PIXEL
		@ 068, 015 Say OemToAnsi(">>> CLIQUE EM 'SALVAR' P/ IMPORTAR O ARQUIVO MANIPULADO P/ A TABELA DE PREÇOS DO SISTEMA.          ") SIZE 275, 10 OF oDlg PIXEL
		@ 080, 035 Say OemToAnsi("***** ATENÇÃO: Verifique os parâmetros da rotina. *****                                            ") SIZE 275, 10 OF oDlg PIXEL
		DEFINE SBUTTON FROM 108,209 TYPE 11 ACTION (IIF(Pergunte(cPerg1,.T.) .AND. !Empty(MV_PAR01),_cArqTP := AllTrim(Lower(SelDirArq("E"))),_cArqTP := ""), Processa( { || ExpArq(_cArqTP) }, "[" + _cRotina + "] Exportação da tabela de preços CSV", "Processando...", .F.) )  ENABLE OF oDlg			//Exportação
		DEFINE SBUTTON FROM 108,238 TYPE 13 ACTION (_cArqTP := AllTrim(Lower(SelDirArq("I"))), Processa( { || ImpArq(_cArqTP) }, "[" + _cRotina + "] Importação da tabela de preços CSV", "Processando...", .F.) )  ENABLE OF oDlg			//Importação
		DEFINE SBUTTON FROM 108,267 TYPE  2 ACTION (_cArqTP := "",oDlg:End())            ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg
return
/*/{Protheus.doc} ExpArq (RFATA013)
@description Função para a exportação da tabela de preços em formato CSV.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/10/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ExpArq(_cArqTP)
	local _k      := 0
	local nHandle := 0
	local _cArq   := ""
	If Empty(MV_PAR01) .OR. Empty(_cArqTP)
		MsgAlert("Informações faltantes para a exportação da tabela de preços!",_cRotina+"_001")
		oDlg:End()
		return .F.
	EndIf
	SplitPath(lower(_cArqTP), @cDrive, @cDir, @cNome, @cExt)
	If Empty(cDir) .OR. Empty(cNome)
		MsgAlert("Problemas com o nome do arquivo de destino!" + CHR(13) + CHR(10) + _cArqTP,_cRotina+"_007")
		oDlg:End()
		return .F.
	EndIf
	if Select(cAliasDA1) > 0
		(cAliasDA1)->(dbCloseArea())
	endif
	If Empty(cExt)
		cExt := ".csv"
	EndIf
	_cCsv    := AllTrim(cDrive)+AllTrim(cDir)+AllTrim(cNome)+AllTrim(cExt)
    nHandle  := FCREATE(_cCsv,FC_NORMAL)
	if nHandle = -1
		MsgAlert("Erro ao criar arquivo - ferror " + Str(Ferror()),_cRotina+"_019")
		oDlg:End()
		return .F.
	endif
	BeginSql Alias cAliasDA1
		%noparser%
		SELECT DA1_FILIAL FILIAL, DA1_CODTAB TABELA, DA1_ITEM ITEM, DA1_CODPRO PRODUTO, ISNULL(B1_DESC,'') DESCRICAO 
			 , DA1_GRUPO GRUPO, ISNULL(B1_UM,'') UM, DA1_PRCVEN PRECO, DA1_ESTADO UF, DA1_QTDLOT QUANTIDADE 
		FROM %table:DA1% DA1 (NOLOCK) 
			LEFT OUTER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL  = %xFilial:SB1%
													AND SB1.B1_COD     = DA1.DA1_CODPRO 
													AND SB1.%NotDel%
		WHERE DA1.DA1_FILIAL = %xFilial:DA1%
		  AND DA1.DA1_ATIVO  = '1'
		  AND DA1.DA1_CODTAB = %Exp:MV_PAR01%
		  AND DA1.%NotDel%
		ORDER BY DA1_FILIAL, DA1_CODTAB, DA1_ITEM, DA1_GRUPO, DA1_CODPRO 
	EndSql
	for _k := 1 To Len(_aStru)
		If _aStru[_k][2] <> "C" .AND. FieldPos(_aStru[_k][1]) > 0
			TcSetField(cAliasDA1,_aStru[_k][1],_aStru[_k][2],_aStru[_k][3],_aStru[_k][4])
		EndIf
		if _k > 1
			_cArq += ";"
		endif
		_cArq += _aStru[_k][1]
	next
	if !empty(_cArq)
		FWrite(nHandle, _cArq + CRLF)
	endif
	dbSelectArea(cAliasDA1)
	ProcRegua((cAliasDA1)->(RecCount()))
	(cAliasDA1)->(dbGoTop())
	if !(cAliasDA1)->(EOF()) .AND. Len(_aStru) > 0
		while !(cAliasDA1)->(EOF())
			IncProc("Tabela " + (cAliasDA1)->TABELA + ", Produto " + (cAliasDA1)->PRODUTO + "...")
			_cArq := ""
			for _k := 1 to len(_aStru)
				if _k > 1
					_cArq += ";"
				endif
				if valtype(&(cAliasDA1+"->"+AllTrim(_aStru[_k][01]))) == "D"
					_cArq += DTOC(&(cAliasDA1+"->"+AllTrim(_aStru[_k][01])))
				elseif valtype(&(cAliasDA1+"->"+AllTrim(_aStru[_k][01]))) == "N"
					_cArq += StrTran(cValToChar(&(cAliasDA1+"->"+AllTrim(_aStru[_k][01]))),".",",")
				else
					_cArq += &(cAliasDA1+"->"+AllTrim(_aStru[_k][01]))
				endif
			next
			if !empty(_cArq)
				FWrite(nHandle, _cArq + CRLF)
			endif
			dbSelectArea(cAliasDA1)
			(cAliasDA1)->(dbSkip())
		enddo
	else
		MsgAlert("Nada a processar!",_cRotina+"_005")
	endif
	if Select(cAliasDA1) > 0
		(cAliasDA1)->(dbCloseArea())
	endif
	if !FClose(nHandle)
		MsgAlert("Atenção! Problemas ao tentar fechar o arquivo " + _cCsv + " - "+FERROR(),_cRotina+"_020")
	endif
	if File(_cCsv)
		oExcelApp:= MsExcel():New()
		oExcelApp:WorkBooks:Open(_cCsv)
		oExcelApp:SetVisible(.T.)
	else
		MsgAlert("Atenção! Problemas na geração do arquivo " + _cCsv + "!",_cRotina+"_008")
		oDlg:End()
		return .F.
	endif
	oDlg:End()
return .T.
/*/{Protheus.doc} ImpArq (RFATA013)
@description Função para a importação da tabela de preços em formato CSV.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/10/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ImpArq(_cArqTP)
	Local _aTabCab  := {}
	Local _cLog     := ""
	If Empty(_cArqTP)
		MsgAlert("Arquivo não informado para importação da tabela de preços!",_cRotina+"_009")
		oDlg:End()
		return .F.
	EndIf
	SplitPath(_cArqTP, @cDrive, @cDir, @cNome, @cExt)
	If Empty(cDir) .OR. Empty(cNome) .OR. Empty(cExt)
		MsgAlert("Problemas com o nome do arquivo de origem!" + CHR(13) + CHR(10) + _cArqTP,_cRotina+"_010")
		oDlg:End()
		return .F.
	EndIf
	If !File(AllTrim(_cArqTP))
		MsgAlert("Atenção! Arquivo " + _cArqTP + " não localizado para importação!",_cRotina+"_011")
		oDlg:End()
		return .F.
	EndIf
	FT_FUSE(cDrive+cDir+cNome+cExt)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	If !FT_FEOF()
		dbSelectArea("DA1")
		cArqInd   := CriaTrab(, .F.)
		cChaveInd := "DA1_FILIAL+DA1_CODTAB+DA1_GRUPO+DA1_CODPRO+DA1_INDLOT"
		cCondicao := ""
		IndRegua("DA1", cArqInd, cChaveInd, , cCondicao, "Criando indice de trabalho" )
		nIndice := RetIndex("DA1") + 1
		#IFNDEF TOP
			dbSetIndex(cArqInd + OrdBagExt())
		#ENDIF
		_lCab      := .T.
		_lContinua := .T.
		_cNumTP    := ""
		Begin Transaction
			While !FT_FEOF()
				//Preparação do cabeçalho
				cLinha    := FT_FREADLN()
				aLinha    := Separa(cLinha,";",.T.)
				If _lCab		//Lê o cabeçalho principal
					If UPPER(AllTrim(aLinha[01])) == "TABELA"
						_lCab     := .F.
						_cLnCab   := cLinha
						_aTabCab  := aClone(aLinha)
						_nPFil    := aScan(_aTabCab,"FILIAL"    )
						_nPTab    := aScan(_aTabCab,"TABELA"    )
	//					_nPIt     := aScan(_aTabCab,"ITEM"      )
						_nPGrPrd  := aScan(_aTabCab,"GRUPO"     )
						_nPProd   := aScan(_aTabCab,"PRODUTO"   )
	//					_nPDescr  := aScan(_aTabCab,"DESCRICAO" )
	//					_nPUm     := aScan(_aTabCab,"UM"        )
						_nPPreco  := aScan(_aTabCab,"PRECO"     )
						_nPUf     := aScan(_aTabCab,"UF"        )
						_nPQtde   := aScan(_aTabCab,"QUANTIDADE")
						_nItem    := 0
						_cDescrTp := ""
						_cCondPg  := ""
						FT_FSkip()
						If FT_FEOF()
							MsgAlert("Arquivo sem dados!",_cRotina+"_017")
							Loop
						EndIf
						//Preparação do cabeçalho
						cLinha    := FT_FREADLN()
						aLinha    := Separa(cLinha,";",.T.)
						_cTabOld  := aLinha[_nPTab]
						_cNumTP   := GetSX8Num("DA0","DA0_CODTAB")		//GetSXeNum("DA0","DA0_CODTAB")
						dbSelectArea("DA0")
						DA0->(dbSetOrder(1))
						If DA0->(dbSeek(IIF(_nPFil>0,Padr(aLinha[_nPFil],TamSx3("DA0_FILIAL")[01]),xFilial("DA0")) + Padr(_cTabOld,TamSx3("DA0_CODTAB")[01])))
							_cDescrTp := DA0->DA0_DESCRI
							_cCondPg  := DA0->DA0_CONDPG
						Else
							_lAchTP   := .F.
							_cTPOldBk := _cTabOld
							_cTabOld  := "0" + AllTrim(_cTabOld)
							While Len(AllTrim(_cTabOld)) <= TamSx3("DA0_CODTAB")[01] .AND. !_lAchTP
								If DA0->(dbSeek(IIF(_nPFil>0,Padr(aLinha[_nPFil],TamSx3("DA0_FILIAL")[01]),xFilial("DA0")) + Padr(_cTabOld,TamSx3("DA0_CODTAB")[01])))
									_lAchTP  := MsgYesNo("A tabela anterior foi encontrada como sendo a '" + DA0->DA0_CODTAB + "'. Confirma?",_cRotina+"_022")
								EndIf
								If !_lAchTP
									_cTabOld := "0" + AllTrim(_cTabOld)
								EndIf
							EndDo
							If _lAchTP
								_cDescrTp := DA0->DA0_DESCRI
								_cCondPg  := DA0->DA0_CONDPG
							Else
								_cTabOld  := _cTPOldBk
								If !MsgYesNo("A tabela de preços original '" + _cTabOld + "' não foi localizada. Desta maneira, não será possível realizar a alteração da tabela corretamente no cadastro de clientes. Continua mesmo assim?",_cRotina+"_021")
									FT_FUSE()
									_lContinua := .F.
									DisarmTransaction()
									Exit
									//Return
								EndIf
							EndIf
						EndIf
						dbSelectArea("DA0")
						DA0->(dbSetOrder(1))
						While DA0->(dbSeek(xFilial("DA0") + Padr(_cNumTP,TamSx3("DA0_CODTAB")[01])))
							_cNumTP := Soma1(_cNumTP)		//Trecho para evitar duplicidade de código para a nova tabela de preços
						EndDo
						while !RecLock("DA0",.T.) ; enddo
							DA0->DA0_FILIAL := xFilial("DA0")
							DA0->DA0_CODTAB := _cNumTP
							DA0->DA0_DESCRI := _cDescrTp
							DA0->DA0_DATDE  := dDataBase
							DA0->DA0_HORADE := "00:00"
							DA0->DA0_DATATE := Date()+1800		//Validade de 5 anos
							DA0->DA0_HORATE := "23:59"
							DA0->DA0_CONDPG := _cCondPg
							DA0->DA0_TPHORA := "1"
							DA0->DA0_ATIVO  := "1"
							//If Type("DA0->DA0_TABORI")<>"U"
							if DA0->(FieldPos("DA0_TABORI")) > 0
								DA0->DA0_TABORI := _cTabOld
							endif
						DA0->(MSUNLOCK())
						ConfirmSx8()
					else
						MsgAlert("Atenção! A primeira linha e primeira coluna do arquivo CSV deve conter a descrição 'TABELA'. Processo abortado!",_cRotina+"_011")
						FT_FUse()
						_lContinua := .F.
						DisarmTransaction()
						Exit
						//Return(.F.)
					endif
				endif
				IncProc("Processando produto " + AllTrim(aLinha[_nPProd ]) + "...")
				_cQtde := StrZero(Val(StrTran(aLinha[_nPQtde],",",".")),18,2)
				dbSelectArea("DA1")
				DA1->(dbSetOrder(nIndice))
				If !DA1->(dbSeek(	xFilial("DA1") + ;
									Padr(_cNumTP         ,TamSx3("DA1_CODTAB")[01]) + ;
									Padr(aLinha[_nPGrPrd],TamSx3("DA1_GRUPO" )[01]) + ;
									Padr(aLinha[_nPProd ],TamSx3("DA1_CODPRO")[01]) + ;
									Padr(_cQtde          ,TamSx3("DA1_QTDLOT")[01]) ) )
					_nItem++
					_lContin := .T.
					If _lContin .AND. !Empty(aLinha[_nPGrPrd])
						dbSelectArea("SBM")
						SBM->(dbSetOrder(1))
						If !SBM->(dbSeek(xFilial("SBM") + Padr(aLinha[_nPGrPrd],TamSx3("BM_GRUPO")[01])))
							MsgStop("Atenção! O grupo de produto '" + aLinha[_nPGrPrd] + "' informado para o item '" + cValToChar(_nItem) + "' não foi localizado. Este grupo será desprezado!",_cRotina+"_023")
							aLinha[_nPGrPrd] := ""
						EndIf
					EndIf
					If _lContin .AND. !Empty(aLinha[_nPProd ])
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						If !SB1->(dbSeek(xFilial("SB1") + Padr(aLinha[_nPProd ],TamSx3("B1_COD"  )[01])))
							MsgStop("Atenção! O produto '" + aLinha[_nPProd ] + "' informado para o item '" + cValToChar(_nItem) + "' não foi localizado. Este produto será desprezado!",_cRotina+"_024")
							aLinha[_nPProd ] := ""
						EndIf
					EndIf
					If _lContin .AND. Empty(aLinha[_nPGrPrd]+aLinha[_nPProd ])
						MsgStop("Atenção! Nenhum produto ou grupo de produto informado para o item '" + cValToChar(_nItem) + "'. Este item será desprezado!",_cRotina+"_025")
						_lContin := .F.
						FT_FSkip()
						Loop
					EndIf
					If _lContin
						while !RecLock("DA1",.T.) ; enddo
							DA1->DA1_FILIAL := FWFilial("DA1")
							DA1->DA1_ITEM   := StrZero(_nItem,TamSx3("DA1_ITEM")[01])
							DA1->DA1_CODTAB := _cNumTP
							DA1->DA1_GRUPO  := aLinha[_nPGrPrd]
							DA1->DA1_CODPRO := aLinha[_nPProd ]
							DA1->DA1_PRCVEN := Val(StrTran(aLinha[_nPPreco],",","."))
							DA1->DA1_ESTADO := aLinha[_nPUf   ]
							DA1->DA1_QTDLOT := Val(StrTran(aLinha[_nPQtde ],",","."))
							DA1->DA1_INDLOT := _cQtde
							DA1->DA1_ATIVO  := "1"
							DA1->DA1_TPOPER := "4"
							DA1->DA1_MOEDA  := 1
							DA1->DA1_DATVIG := dDatabase
						DA1->(MSUNLOCK())
					EndIf
				Else
					_cLog += cLinha + CHR(13) + CHR(10)	//Produtos duplicados no arquivo CSV
				EndIf
				FT_FSkip()
			EndDo
		End Transaction
		if !_lContinua
			Return _lContinua
		endif
		FErase(cArqInd + OrdBagExt())
		dbSelectArea("DA0")
		DA0->(dbSetOrder(1))
		If DA0->(dbSeek(xFilial("DA0") + Padr(_cNumTP,TamSx3("DA0_CODTAB")[01])))
			dbSelectArea("DA1")
			DA1->(dbSetOrder(1))
			If DA1->(dbSeek(xFilial("DA1") + Padr(_cNumTP,TamSx3("DA1_CODTAB")[01])))
				_cQry := " UPDATE " + RetSqlName("SA1")
				_cQry += " SET A1_TABELA    = '" + Padr(_cNumTP ,TamSx3("A1_TABELA")[01]) + "' "
				_cQry += " WHERE A1_FILIAL  = '" + xFilial("SA1") + "' "
				_cQry += "   AND A1_TABELA  = '" + Padr(_cTabOld,TamSx3("A1_TABELA")[01]) + "' "
				_cQry += "   AND D_E_L_E_T_ = '' "
	//			If __cUserId == "000000"
				//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cQry)
	//			EndIf
	
	 //Alterar o parametro da tabela de preço utilizado no fonte GP010VALPE no momento que fizer a importação			
                PUTMV("MV_FUNTABE", Padr(_cNumTP ,TamSx3("A1_TABELA")[01]))

				IncProc("Finalizando...")
				If TCSQLExec(_cQry) < 0
					MsgAlert("Atenção! Ocorreram problemas na alteração da tabela de preços " + _cTabOld + " para a tabela " + _cNumTP + " no cadastro de clientes! Veja o erro a seguir...",_cRotina+"_016")
					MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_013")
				EndIf
				dbSelectArea("SA1")
				SA1->(dbGoBottom())
				SA1->(dbGoTop())
				dbSelectArea("DA0")
				DA0->(dbSetOrder(1))
				If DA0->(dbSeek(xFilial("DA0") + Padr(_cNumTP,TamSx3("DA0_CODTAB")[01])))
					lConsulta := .T.
					lCopia    := .F.
					_lInclui  := IIF(Type("INCLUI")=="L",INCLUI,.F.)
					_lAltera  := IIF(Type("ALTERA")=="L",ALTERA,.T.)
					INCLUI    := .F.
					ALTERA    := .T.
					_cCadBk   := cCadastro + " - ALTERAR"
					Private aRotina   := {  { OemToAnsi("Pesquisar" ),"AxPesqui"		,0,1,32,.F.},;
											{ OemToAnsi("Visualizar"),"Oms010Tab"		,0,2,32,NIL},;
											{ OemToAnsi("Incluir"   ),"Oms010Tab"		,0,3,32,NIL},;
											{ OemToAnsi("Alterar"   ),"Oms010Tab"		,0,4,32,NIL},;
											{ OemToAnsi("Excluir"   ),"Oms010Tab"		,0,5,32,NIL},;
											{ OemToAnsi("Copiar"    ),"Oms010Cpy"		,0,4,32,NIL},;
											{ OemToAnsi("Gerar"     ),"Oms010PFor"	    ,0,3,32,NIL},;
											{ OemToAnsi("Reajuste"  ),"Oms010Rej"		,0,5,32,NIL},;
											{ OemtoAnsi("Legenda"   ),"Oms010Leg"		,0,2,32,.F.} }
					Oms010Tab("DA0",DA0->(Recno()),4,lConsulta,lCopia)
					INCLUI    := _lInclui
					ALTERA    := _lAltera
					cCadastro := _cCadBk
				EndIf
				If !Empty(_cLog)
					_cLog  := _cLnCab + CHR(13) + CHR(10) + _cLog
					_cFile := Lower(GetTempPath()+_cRotina+"_Log.csv")
					MemoWrite(_cFile,_cLog)
					MsgStop("Atenção! Os seguintes registros não foram processados, pois estavam duplicados: "+GetTempPath()+_cRotina+"_Log.csv",_cRotina+"_020")
					If File(_cFile)
	//					FOpen(GetTempPath()+_cRotina+"_Log.csv")
	//					FErase(GetTempPath()+_cRotina+"_Log.csv")
						//If !ApOleClient('MsExcel')
							MsgStop("Excel não instalado",_cRotina+"_026")
						//Else
							oExcelApp:= MsExcel():New()
							oExcelApp:WorkBooks:Open(_cFile)
							oExcelApp:SetVisible(.T.)
						//EndIf
					EndIf
				EndIf
				MsgInfo("Processo finalizado!",_cRotina+"_014")
			Else
				MsgStop("Problemas na geração da nova tabela de preços!",_cRotina+"_018")
			EndIf
		Else
			MsgStop("Problemas na geração da nova tabela de preços!",_cRotina+"_015")
		EndIf
	Else
		MsgAlert("Nada a processar!"  ,_cRotina+"_012")
	EndIf
	FT_FUSE()
	oDlg:End()
return .T.
/*/{Protheus.doc} ValidPerg1
@description Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/10/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg1()
	local _sArea     := GetArea()
	local aRegs      := {}				//Grupo|Ordem| Pegunt                         | perspa | pereng | VariaVL  | tipo| Tamanho|Decimal| Presel| GSC | Valid         |   var01   | Def01          | DefSPA1 | DefEng1 | CNT01 | var02 | Def02           | DefSPA2 | DefEng2 | CNT02 | var03 | Def03    | DefSPA3 | DefEng3 | CNT03 | var04 | Def04 | DefSPA4 | DefEng4 | CNT04 | var05 | Def05 | DefSPA5 | DefEng5 | CNT05 | F3    | GRPSX5 |
	local _aTam      := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg1 := PADR(cPerg1,len((_cAliasSX1)->X1_GRUPO))
	_aTam  := TamSx3("DA0_CODTAB")
	AADD(aRegs,{cPerg1,"01","Tabela a Exportar ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""                  ,"","","","",""              ,"","","","",""                ,"","","","",""         ,"","","","","","","","","DA0",""})
	for i := 1 to len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg1+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_sArea)
return
/*/{Protheus.doc} SelDirArq (RFATA013)
@description Seleçao de arquivo ou definição de caminho em diretorio.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 15/10/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function SelDirArq(_cOpc)
	local _cTipo  := "Arquivos Excel do tipo CSV | *.CSV"

	default _cOpc := ""

	if _cOpc == "I"
		_cArq  := cGetFile(_cTipo, "Selecione o arquivo a ser carregado"      ,0,GetTempPath(),.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.)
	elseif _cOpc == "E"
		_cArq  := cGetFile(_cTipo, "Selecione local para a geração do arquivo",0,GetTempPath(),.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.)
	endif
return _cArq
