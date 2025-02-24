#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RESTR002
@description Relatório de conferência dos itens do inventário que não tiveram contagens selecionadas.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 27/08/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RESTR002()
	local Titulo         := "Itens sem Contagem Selecionada"
	local nOpca  	     := 0

	private _cRotina     := "RESTR002"
	private cPerg        := _cRotina

	static oDlg

	ValidPerg()
	if Pergunte(cPerg,.T.)
		DEFINE MSDIALOG oDlg FROM  96,4 to 355,625 TITLE Titulo PIXEL
			@ 18, 9 to 99, 300 LABEL "" OF oDlg  PIXEL
			@ 29, 15 Say OemToAnsi("Este programa ira gerar o relatorio de itens sem contagem selecionada para inventario.           ") SIZE 275, 10 OF oDlg PIXEL
			@ 38, 15 Say OemToAnsi("As informações serão geradas no Excel. Para tanto, é importante que este esteja instalado.       ") SIZE 275, 10 OF oDlg PIXEL
			@ 58, 15 Say OemToAnsi("                                                                                                 ") SIZE 255, 10 OF oDlg PIXEL
			@ 78, 35 Say OemToAnsi("***** Atenção: Verifique os parâmetros da rotina. *****                                          ") SIZE 275, 10 OF oDlg PIXEL

			DEFINE SBUTTON FROM 108,209 TYPE 5 ACTION Pergunte(cPerg,.T.)   ENABLE OF oDlg
			DEFINE SBUTTON FROM 108,238 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 108,267 TYPE 2 ACTION oDlg:End()            ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg
		if nOpca == 1
			Processa( {|lEnd| RunReport() }, Titulo, "Processando..",.T.)
		endif
	endif
return
/*/{Protheus.doc} RUNREPORT (RESTR002)
@description Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 27/08/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function RunReport()
	local oFWMsExcel
	local _aROW    := {}
	local _x       := 0
	local _nCol    := 0
	local _cTRBTMP := GetnextAlias()
	local _cSB7TMP := GetNextAlias()
	local _cMaxCon := GetNextAlias()

	if Select(_cMaxCon) > 0
		(_cMaxCon)->(dbCloseArea())
	endif
	BeginSql Alias _cMaxCon
		SELECT MAX(REG) REG
		FROM (  SELECT B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE, COUNT(*) REG 
				FROM %table:SB7% SB7 (NOLOCK) 
				WHERE SB7.B7_FILIAL        = %xFilial:SB7%
				  AND SB7.B7_DATA          = %Exp:DTOS(MV_PAR01)%
				  AND SB7.B7_COD     BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
				  AND SB7.B7_LOCAL   BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
				  AND NOT EXISTS (	SELECT TOP 1 1
									FROM %table:SB7% SB7E (NOLOCK)
									WHERE SB7E.B7_ESCOLHA = %Exp:'S'%
									  AND SB7E.B7_FILIAL  = SB7.B7_FILIAL
									  AND SB7E.B7_DATA    = SB7.B7_DATA
									  AND SB7E.B7_COD     = SB7.B7_COD
									  AND SB7E.B7_LOCAL   = SB7.B7_LOCAL
									  AND SB7E.B7_LOCALIZ = SB7.B7_LOCALIZ
									  AND SB7E.B7_NUMSERI = SB7.B7_NUMSERI
									  AND SB7E.B7_LOTECTL = SB7.B7_LOTECTL
									  AND SB7E.B7_NUMLOTE = SB7.B7_NUMLOTE
									  AND SB7E.%NotDel%
								 )
				  AND SB7.%NotDel%
				GROUP BY B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE
			) XXX
	EndSql
	if Select(_cMaxCon) > 0
		_nCont := (_cMaxCon)->REG
		(_cMaxCon)->(dbCloseArea())
	endif
	If _nCont == 0
		MsgAlert("Sem contagens para o range selecionado!",_cRotina+"_001")
		return
	endif
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
	_aStru := {}
	_aTam  := TamSX3("B7_DATA"   )
	AADD(_aStru,{ "DATAINV"     ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B7_COD"    )
	AADD(_aStru,{ "PRODUTO"     ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B1_DESC"   )
	AADD(_aStru,{ "DESCRICAO"   ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B1_UM"     )
	AADD(_aStru,{ "UM"          ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B1_TIPO"   )
	AADD(_aStru,{ "TIPO"        ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B7_LOCAL"  )
	AADD(_aStru,{ "ARM"         ,_aTam[3],_aTam[1],_aTam[2] } )
	// - Descomentado o trecho abaixo por Júlio Soares em 07/09/2013 para corrigir erro no IndRégua.
	// - /*
	_aTam  := TamSX3("B7_LOTECTL")
	AADD(_aStru,{ "LOTE"        ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B7_DTVALID")
	AADD(_aStru,{ "VALIDADE"    ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B7_LOCALIZ")
	AADD(_aStru,{ "ENDERECO"    ,_aTam[3],_aTam[1],_aTam[2] } )
	// Trecho descomentado - */
	_aTam  := TamSX3("B2_QATU"   )
	AADD(_aStru,{ "SALDO"       ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B2_CM1"    )
	AADD(_aStru,{ "VALORUN"     ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam  := TamSX3("B7_QUANT"  )
	for _x := 1 to _nCont
		AADD(_aStru,{ "CONT_"+StrZero(_x,IIF(_nCont>3,Len(cValToChar(_nCont)),3)),_aTam[3],_aTam[1],_aTam[2] } )
	next
	if Select(_cTRBTMP) > 0
		(_cTRBTMP)->(dbCloseArea())
	endif
	//-------------------
	//Criacao do objeto
	//-------------------
	oTempTable := FWTemporaryTable():New( _cTRBTMP )
	oTemptable:SetFields( _aStru )
	oTempTable:AddIndex("indice1", {"DATAINV","PRODUTO","LOTE","ARM","ENDERECO"} )
	//------------------
	//Criacao da tabela
	//------------------
	oTempTable:Create()
	dbSelectArea(_cTRBTMP)
	(_cTRBTMP)->(dbGoTop())
	if Select(_cSB7TMP) > 0
		(_cSB7TMP)->(dbCloseArea())
	endif
	BeginSql Alias _cSB7TMP
		SELECT * 
		FROM %table:SB7% SB7 (NOLOCK) 
		WHERE SB7.B7_FILIAL        = %xFilial:SB7%
		  AND SB7.B7_DATA          = %Exp:DTOS(MV_PAR01)%
		  AND SB7.B7_COD     BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
		  AND SB7.B7_LOCAL   BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
		  AND NOT EXISTS (	SELECT TOP 1 1
							FROM %table:SB7% SB7E (NOLOCK)
							WHERE SB7E.B7_ESCOLHA = %Exp:'S'%
							  AND SB7E.B7_FILIAL  = SB7.B7_FILIAL
							  AND SB7E.B7_DATA    = SB7.B7_DATA
							  AND SB7E.B7_COD     = SB7.B7_COD
							  AND SB7E.B7_LOCAL   = SB7.B7_LOCAL
							  AND SB7E.B7_LOCALIZ = SB7.B7_LOCALIZ
							  AND SB7E.B7_NUMSERI = SB7.B7_NUMSERI
							  AND SB7E.B7_LOTECTL = SB7.B7_LOTECTL
							  AND SB7E.B7_NUMLOTE = SB7.B7_NUMLOTE
							  AND SB7E.%NotDel%
						 )
		  AND SB7.%NotDel%
		ORDER BY B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE,B7_CONTAGE,B7_QUANT
	EndSql
	dbSelectArea(_cSB7TMP)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua(RecCount())
	(_cSB7TMP)->(dbGoTop())
	if !(_cSB7TMP)->(EOF())
		while !(_cSB7TMP)->(EOF())
			IncProc()
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			if SB1->(MsSeek(xFilial("SB1") + (_cSB7TMP)->B7_COD,.T.,.F.))
				dbSelectArea("SB2")
				SB2->(dbSetOrder(1))
				if SB2->(MsSeek(xFilial("SB2") + (_cSB7TMP)->B7_COD + (_cSB7TMP)->B7_LOCAL,.T.,.F.))
					dbSelectArea(_cTRBTMP)
					while !RecLock(_cTRBTMP,.T.) ; enddo
						(_cTRBTMP)->DATAINV		:= STOD((_cSB7TMP)->B7_DATA)
						(_cTRBTMP)->PRODUTO		:= (_cSB7TMP)->B7_COD
						(_cTRBTMP)->UM			:= SB1->B1_UM
						(_cTRBTMP)->TIPO		:= SB1->B1_TIPO
						(_cTRBTMP)->DESCRICAO	:= SB1->B1_DESC
						(_cTRBTMP)->ARM			:= (_cSB7TMP)->B7_LOCAL
						(_cTRBTMP)->LOTE		:= (_cSB7TMP)->B7_LOTECTL
						(_cTRBTMP)->VALIDADE	:= STOD((_cSB7TMP)->B7_DTVALID)
						(_cTRBTMP)->ENDERECO	:= (_cSB7TMP)->B7_LOCALIZ
						(_cTRBTMP)->SALDO		:= SB2->B2_QATU
						(_cTRBTMP)->VALORUN		:= SB2->B2_CM1
						_nContag := 0
						_cwhile  := (_cSB7TMP)->B7_FILIAL+(_cSB7TMP)->B7_DATA+(_cSB7TMP)->B7_COD+(_cSB7TMP)->B7_LOCAL+(_cSB7TMP)->B7_LOCALIZ+(_cSB7TMP)->B7_NUMSERI+(_cSB7TMP)->B7_LOTECTL+(_cSB7TMP)->B7_NUMLOTE
						while !(_cSB7TMP)->(EOF()) .AND. _cwhile == (_cSB7TMP)->B7_FILIAL+(_cSB7TMP)->B7_DATA+(_cSB7TMP)->B7_COD+(_cSB7TMP)->B7_LOCAL+(_cSB7TMP)->B7_LOCALIZ+(_cSB7TMP)->B7_NUMSERI+(_cSB7TMP)->B7_LOTECTL+(_cSB7TMP)->B7_NUMLOTE
							_nContag++
							dbSelectArea(_cTRBTMP)
							&(_cTRBTMP+"->CONT_"+StrZero(_nContag,IIF(_nCont>3,Len(cValToChar(_nCont)),3))) := (_cSB7TMP)->B7_QUANT
							dbSelectArea(_cSB7TMP)
							(_cSB7TMP)->(dbSkip())
						enddo
					(_cTRBTMP)->(MSUNLOCK())
				endif
			endif
		enddo
	else
		MsgAlert("Nada a processar!",_cRotina+"_002")
	endif
	(_cTRBTMP)->(dbGoTop())
	if (_cTRBTMP)->(!EOF())
		cArquivo    := GetTempPath()  + "RESTR002_" + AllTrim(DTOS(dDataBase))+"_"+StrTran(Time(),":","")+".xml" //Linha comentada por Adriano Leonardo em 26/01/2014 para correção da rotina, para os casos em que o usuário não tem permissão de gravação na unidade C:
	    //Criando o objeto que irá gerar o conteúdo do Excel
	    oFWMsExcel := FWMSExcel():New()
	    //Aba 01
	    oFWMsExcel:AddworkSheet("CONFERENCIA INVENTARIO")
	        //Criando a Tabela
	        oFWMsExcel:AddTable("CONFERENCIA INVENTARIO","INVENTARIO")
	        for _nCol :=  1 to len(_aStru)
	        	oFWMsExcel:AddColumn("CONFERENCIA INVENTARIO","INVENTARIO",_aStru[_nCol][1],1)
	        next
	        //Criando as Linhas... Enquanto não for fim da query
	        while (_cTRBTMP)->(!EOF())
	            _bARRAY := "{"
	            for _nCol :=  1 to len(_aStru)
	             	if _nCol < len(_aStru)
	             		_bARRAY += _cTRBTMP+"->"+ALLTRIM(_aStru[_nCol][1])+","
	             	else 
	             		_bARRAY += _cTRBTMP+"->"+ALLTRIM(_aStru[_nCol][1])             	
	             	endif          
	            next
	            _bARRAY += "}"
	            _aROW   := &(_bARRAY)            
	            oFWMsExcel:AddRow("CONFERENCIA INVENTARIO","INVENTARIO",_aROW)
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
	endif
	if Select(_cTRBTMP) > 0
		(_cTRBTMP)->(dbCloseArea())
	endif
	if Select(_cSB7TMP) > 0
		(_cSB7TMP)->(dbCloseArea())
	endif
return
/*/{Protheus.doc} ValidPerg
@description Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 26/04/2013
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

	_aTam := {01,00,"C"}
	AAdd(aRegs,{cPerg,"01","Data do Inventário  ?","","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"C",""          ,"mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
	_aTam := TamSx3("B1_COD"   )
	AAdd(aRegs,{cPerg,"02","Do Produto          ?","","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SB1",""})
	AAdd(aRegs,{cPerg,"03","Ao Produto          ?","","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par03",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SB1",""})
	_aTam := TamSx3("B1_LOCPAD")
	AAdd(aRegs,{cPerg,"04","Do Armazém          ?","","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par04",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","NNR",""})
	AAdd(aRegs,{cPerg,"05","Ao Armazém          ?","","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par05",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","NNR",""})
	_aTam := {99,00,"C"}
	AAdd(aRegs,{cPerg,"06","Local do arquivo    ?","","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G","NAOVAZIO()","mv_par06",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
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