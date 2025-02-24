#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RESTR003
@description Relatório de confronto dos custos de entrada dos produtos em determinado período (D1_TOTAL - D1_VALICM).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RESTR003()
	local Titulo         := "Confronto dos preços de compra em certo período"
	local nOpca  	     := 0

	private _cRotina     := "RESTR003"
	private cPerg        := _cRotina

	static oDlg

	ValidPerg()
	If Pergunte(cPerg,.T.)
		DEFINE MSDIALOG oDlg FROM  96,4 to 355,625 TITLE Titulo PIXEL
			@ 18, 9 to 99, 300 LABEL "" OF oDlg  PIXEL
			@ 29, 15 Say OemToAnsi("Este programa ira gerar o relatorio de confronto dos custos de compra em determinado período.    ") SIZE 275, 10 OF oDlg PIXEL
			@ 38, 15 Say OemToAnsi("As informações serão geradas no Excel. Para tanto, é importante que este esteja instalado.       ") SIZE 275, 10 OF oDlg PIXEL
			@ 58, 15 Say OemToAnsi("                                                                                                 ") SIZE 255, 10 OF oDlg PIXEL
			@ 78, 35 Say OemToAnsi("***** Atenção: Verifique os parâmetros da rotina. *****                                          ") SIZE 275, 10 OF oDlg PIXEL
			DEFINE SBUTTON FROM 108,209 TYPE 5 ACTION Pergunte(cPerg,.T.)   ENABLE OF oDlg
			DEFINE SBUTTON FROM 108,238 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 108,267 TYPE 2 ACTION oDlg:End()            ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg
	
		If nOpca == 1
			Processa( {|lEnd| RunReport() }, Titulo, "Processando..",.T.)
		endif
	endif
return
/*/{Protheus.doc} RUNREPORT (RESTR003)
@description Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function RunReport()
	local oFWMsExcel
	local _aROW    := {}
	local _aTam    := {}
	local _aStru   := {}
	local _nTVUn   := TamSX3("D1_VUNIT")[02]
	local _bARRAY  := ""
	local _cQry    := ""
	local cArquivo := ""
	local _nCol    := ""
	local _cTRBTMP := GetnextAlias()
	local _cSD1TMP := GetnextAlias()
	//-----------------------------------------------------
	// Criação da Tabela Temporária Temporária (_cTRBTMP)
	//-----------------------------------------------------
	/*-----------------------------------------------------
	|              Definições Importantes:                |
	-------------------------------------------------------
	|      _aTam[3]       |    _aTam[1]		  | _aTam[2]   |
	-------------------------------------------------------
	| "C", "D", "N", etc. | Tamanho do Campo  | Decimais  |
	-------------------------------------------------------*/
	AADD(_aStru,{ "ANO_MES"     ,"C"     ,06      ,00       } )
	_aTam  := TamSX3("B1_COD"    )
	AADD(_aStru,{ "PRODUTO"     ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B1_DESC"   )
	AADD(_aStru,{ "DESCRICAO"   ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B1_UM"     )
	AADD(_aStru,{ "UM"          ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("D1_VUNIT"  )
	AADD(_aStru,{ "CUSTO_UNIT"  ,_aTam[3],_aTam[1],_aTam[2] } )
	AADD(_aStru,{ "VARIACAO"    ,"N"     ,08      ,04       } )
	if Select(_cTRBTMP) > 0
		(_cTRBTMP)->(dbCloseArea())
	endif
	//-------------------
	//Criacao do objeto
	//-------------------
	oTempTable := FWTemporaryTable():New(_cTRBTMP)
	oTemptable:SetFields( _aStru )
	oTempTable:AddIndex("indice1", {"ANO_MES","PRODUTO"} )
	//------------------
	//Criacao da tabela
	//------------------
	oTempTable:Create()
	dbSelectArea(_cTRBTMP)
	(_cTRBTMP)->(dbGoTop())
	_cQry := " SELECT MESDIGIT ANO_MES, D1_COD PRODUTO, B1_DESC DESCRICAO, B1_UM UM, (SUM(D1_VUNIT)/COUNT(*)) CUSTO_UNIT "
	_cQry += " FROM ( "
	_cQry += " 		SELECT DISTINCT SUBSTRING(D1_DTDIGIT,1,6) MESDIGIT, D1_COD, B1_DESC, B1_UM, ((D1_TOTAL-D1_VALICM)/D1_QUANT) D1_VUNIT "
	_cQry += " 		FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
	//Início - Trecho adicionado por Adriano Leonardo em 17/12/2013 para adicionar filtragens pela TES e pelo CFOP
	_cQry += " 			  INNER JOIN  " + RetSqlName("SF4") + " SF4 (NOLOCK) ON SF4.D_E_L_E_T_ = '' "
	_cQry += " 								   AND SF4.F4_FILIAL  = '" + xFilial("SF4") + "' "
	_cQry += " 								   AND SF4.F4_CODIGO  = SD1.D1_TES "
	_cQry += " 								   AND (SF4.F4_UPRC<>'N' OR SF4.F4_CODIGO='" + SuperGetMv("MV_TESIMPE" ,,"451" ) + "' OR SD1.D1_CF LIKE " + SuperGetMv("MV_TESIMPE" ,,"1911/2911/3911" ) + ") "
	//Fim - Trecho adicionado por Adriano Leonardo em 17/12/2013 para adicionar filtragens pela TES e pelo CFOP
	_cQry += " 			  INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' "
	_cQry += " 								   AND SB1.B1_FILIAL     = '" + xFilial("SB1") + "' "
	_cQry += " 								   AND SB1.B1_COD  BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	_cQry += " 								   AND SB1.B1_TIPO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	_cQry += " 								   AND SB1.B1_COD        = SD1.D1_COD "
	_cQry += " 		WHERE SD1.D_E_L_E_T_ = '' "
	_cQry += " 		  AND SD1.D1_FILIAL  = '" + xFilial("SD1") + "' "
	_cQry += " 		  AND SD1.D1_TIPO    = 'N' "
	if valtype(MV_PAR01) == "D"
		_cQry += " 		  AND SD1.D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	else
		_cQry += " 		  AND SD1.D1_DTDIGIT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	endif
	_cQry += " 	) TABTMP "
	_cQry += " GROUP BY D1_COD, B1_DESC, B1_UM, MESDIGIT "
	_cQry += " ORDER BY D1_COD, B1_DESC, B1_UM, MESDIGIT "
	_cQry := ChangeQuery(_cQry)
	if Select(_cSD1TMP) > 0
		(_cSD1TMP)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cSD1TMP,.T.,.T.)
	dbSelectArea(_cSD1TMP)
	(_cSD1TMP)->(dbGoTop())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua(RecCount())
	(_cSD1TMP)->(dbGoTop())
	if !(_cSD1TMP)->(EOF())
		_cProd  := ""
		_cCusto := 0
		while !(_cSD1TMP)->(EOF())
			IncProc()
			if _cProd <> (_cSD1TMP)->PRODUTO
				_nVaria := 0
			else
				_nVaria := ((Round((_cSD1TMP)->CUSTO_UNIT,_nTVUn) / _cCusto) - 1)
			endif
			dbSelectArea(_cTRBTMP)
			while !RecLock(_cTRBTMP,.T.) ; enddo
				(_cTRBTMP)->ANO_MES    := (_cSD1TMP)->ANO_MES
				(_cTRBTMP)->PRODUTO    := (_cSD1TMP)->PRODUTO
				(_cTRBTMP)->DESCRICAO  := (_cSD1TMP)->DESCRICAO
				(_cTRBTMP)->UM         := (_cSD1TMP)->UM
				(_cTRBTMP)->CUSTO_UNIT := Round((_cSD1TMP)->CUSTO_UNIT,_nTVUn)
				(_cTRBTMP)->VARIACAO   := _nVaria
			(_cTRBTMP)->(MSUNLOCK())
			_cProd  := (_cSD1TMP)->PRODUTO
			_cCusto := Round((_cSD1TMP)->CUSTO_UNIT,_nTVUn)
			dbSelectArea(_cSD1TMP)
			(_cSD1TMP)->(dbSkip())
		enddo
		dbSelectArea(_cTRBTMP)
		cArquivo    := GetTempPath()  + "RESTR003_" + AllTrim(DTOS(dDataBase))+"_"+StrTran(Time(),":","")+".xml" //Linha comentada por Adriano Leonardo em 26/01/2014 para correção da rotina, para os casos em que o usuário não tem permissão de gravação na unidade C:
		//Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel  := FWMSExcel():New()
		//Aba 01
		oFWMsExcel:AddworkSheet("VARIACAO CUSTO DE ENTRADA")
	    //Criando a Tabela
	    oFWMsExcel:AddTable("VARIACAO CUSTO DE ENTRADA","CUSTO ENTRADA")
	    for _nCol :=  1 to len(_aStru)
	    	oFWMsExcel:AddColumn("VARIACAO CUSTO DE ENTRADA","CUSTO ENTRADA",_aStru[_nCol][1],1)
	    next
	    //Criando as Linhas... Enquanto não for fim da query
	    while !(_cTRBTMP)->(EOF())
	        _bARRAY := "{"
	        for _nCol :=  1 to len(_aStru)
	         	IF _nCol < len(_aStru)
	         		_bARRAY += _cTRBTMP+"->"+ALLTRIM(_aStru[_nCol][1])+","
	         	else 
	         		_bARRAY += _cTRBTMP+"->"+ALLTRIM(_aStru[_nCol][1])             	
	         	endif          
	        next
	        _bARRAY += "}"
	        _aROW   := &(_bARRAY)            
	        oFWMsExcel:AddRow("VARIACAO CUSTO DE ENTRADA","CUSTO ENTRADA",_aROW)
	        (_cTRBTMP)->(dbSkip())
	    enddo
	 	//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)
	     
		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)              //Visualiza a planilha
		oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
		(_cTRBTMP)->(dbCloseArea())
	else
		MsgAlert("Nada a processar!",_cRotina+"_002")
	endif
return
/*/{Protheus.doc} ValidPerg
@description Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _sArea     := GetArea()
	local aRegs      := {}
	local _aTam      := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))

	_aTam := {08,00,"D"}
	AAdd(aRegs,{cPerg,"01","Da Data             ?","","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
	AAdd(aRegs,{cPerg,"02","Até a Data          ?","","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam := TamSx3("B1_COD"   )
	AAdd(aRegs,{cPerg,"03","Do Produto          ?","","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par03",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SB1",""})
	AAdd(aRegs,{cPerg,"04","Ao Produto          ?","","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par04",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SB1",""})
	_aTam := TamSx3("B1_TIPO"  )
	AAdd(aRegs,{cPerg,"05","Do Tipo             ?","","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par05",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","02" ,""})
	AAdd(aRegs,{cPerg,"06","Ao Tipo             ?","","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par06",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","02" ,""})
	for i := 1 to len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
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