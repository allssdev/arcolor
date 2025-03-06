#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "SHELL.CH"
//#INCLUDE "TOTVS.CH"

#DEFINE _CRLF CHR(13) + CHR(10)

/*/{Protheus.doc} RTMKI001
@description Rotina responsável por importar a planilha em XLS (Excel) dos pedidos dos representantes para o Call Center. Para correto funcionamento desta rotina, o terminal do usuário deverá possuir o Excel. Será executada uma Macro do Excel, chamada por esta rotina. A Macro converterá o arquivo XLS em CSV para que possa ser importado. O layout final da planilha foi estabelecido no dia 24/07/14.
@obs
	//	PONTOS ESPECÍFICOS PARA A ROTINA:
	//  PARÂMETROS:
	//       MV_OPERVDA - Identifica o Tipo de Operação padrão para a operação de venda. Conforme o cliente selecionado (ou outra especificidade) esta informação padrão poderá ser alterada. [CARACTER]
	//       MV_PENTVDA - Identifica o caminho default onde os arquivos a serem importados pela rotina automática estarão (arquivos XLS - CAIXA DE ENTRADA). [CARACTER]
	//       MV_PTRAVDA - Identifica o caminho default da pasta de trânsito (em processamento), onde os arquivos serão colocados para processamento, retirados da pasta definida no parâmetro MV_PENTVDA, para importação automática ao sistema (arquivos XLS - CAIXA DE ENTRADA). [CARACTER]
	//       MV_PERRVDA - Identifica o caminho default onde os arquivos, depois de lidos COM ERRO, serão movidos (arquivos XLS - CAIXA DE ERRO). [CARACTER]
	//       MV_PPROVDA - Identifica o caminho default onde os arquivos, depois de lidos COM SUCESSO, serão movidos (arquivos XLS - CAIXA DE OK). [CARACTER]
	
	//  CAMPOS:
	//       UA_ARQXLS  - Utilizado para a informação do nome do arquivo importado para o input do Orçamento [CARACTER, TAMANHO 200, REAL, USADO, BROWSE, VISUAL]
	//       UA_REPRES  - Identificação do Representante na Planílha [CARACTER, TAMANHO 100, REAL, USADO, BROWSE, VISUAL]
	//       UA_EMPLAN  - Data de emissão constante na planilha [CARACTER, TAMANHO 10, REAL, USADO, BROWSE, VISUAL]
	//       UA_PEDCLI2 - Número do pedido/orçamento do cliente [CARACTER, TAMANHO 15, REAL, USADO, BROWSE]
	//       UA_ALTTRAN - A transportadora do cliente foi alterada [CARACTER, TAMANHO 1, REAL, USADO, BROWSE, VISUAL, OPÇÕES: S=Sim;N=Não]
	//       UA_OBSPLAN - Observações da Planilha [MEMO, TAMANHO 10, REAL, USADO]
	//       UB_DESCTV1 - % Desconto 1 [NUMÉRICO, TAMANHO 6, DECIMAIS 2, REAL, USADO, BROWSE]
	//       UB_DESCTV2 - % Desconto 2 [NUMÉRICO, TAMANHO 6, DECIMAIS 2, REAL, USADO, BROWSE]
	//       UB_DESCTV3 - % Desconto 3 [NUMÉRICO, TAMANHO 6, DECIMAIS 2, REAL, USADO, BROWSE]
	//       UB_DESCTV4 - % Desconto 4 [NUMÉRICO, TAMANHO 6, DECIMAIS 2, REAL, USADO, BROWSE]

@author Anderson C. P. Coelho (ALL System Solutions)
@since 24/07/2014
@version 1.0
@param _lExt , lógico  , .T. - Se a rotina está sendo chamada fora do Protheus (via JOB).
@param _cEmpr, caracter, Empresa de processamento da rotina.
@param _cFil , caracter, Filial de processamento da rotina.
@type function
@history 25/11/15, Anderson Coelho, Defido a problemas intermitentes de compatibilidade com o Excel (versão 2013) e dado o processo atual do cliente, a rotina foi alterada para não mais converter os arquivos XLS para CSV, uma vez que foi alinhado que a equipe comercial fará a conversão manual mencionada.
@see https://allss.com.br
/*/
user function RTMKI001(_lExt,_cEmpr,_cFil)
	local oGroup1
	local oSay1
	local oSay2
	local oSay3
	local oSButton1
	local oSButton2
	local oSButton3
	local _cLogTempo     := ""
	local _cPswUsr       := ""
	local _cPswPsd       := ""
	local _aArqEnt       := {}
	local _nXi           := 0
	local _lExcl         := .F.

	private cDrive, cDir, cNome, cExt
	private cDriveE, cDirE, cNomeE, cExtE
	private _cRotina     := "RTMKI001"
	private cTitulo      := "Importação do Pedido de Vendas por arquivo CSV (Excel)"
	private cCadastro    := cTitulo
	private _cDst        := ""			//Lower(GetTempPath())
	private _cPathEnt    := "\xls\entrada\"
	private _cPathTra    := "\xls\transito\"
	private _cPathErr    := "\xls\erro\"
	private _cPathPro    := "\xls\ok\"
	private _cExtDst     := ".csv"
	private _cArqCsv     := ""
	private _cArqOri     := ""
	private _cNomOri     := ""
	private _nOpc        := 0
	private nEntrada     := 0
	private nFinanciado  := 0
	private nNumParcelas := 0
	private nVlJur       := 0
	private nTxDescon    := 0
	private _lProc       := .T.
	private _aSvAr       := GetArea()
	private bOk          := { || _nOpc := 1, oDlg:End()                  }
	private bCancel      := { || oDlg:End()                              }
	private bDir         := { || _cArqOri := Lower(AllTrim(Lower(SelDirArq()))) }

	Private _cEmpr       := IIF(type("__cUserId")=="U",GetPvProfString("PEDIDOS_TMK","EMPRESA"   ,"",GetAdv97()),SubStr(cNumEmp,1,2))
	Private _cFil        := IIF(type("__cUserId")=="U",GetPvProfString("PEDIDOS_TMK","FILIAL"    ,"",GetAdv97()),SubStr(cNumEmp,3,2))
	Private _lExt        := IsBlind()

	//_lExt        := .F.

	if _lExt
		_cPswUsr         := _cRotina
		_cPswPsd         := _cRotina
		PREPARE ENVIRONMENT EMPRESA _cEmpr FILIAL _cFil USER _cPswUsr PASSWORD _cPswPsd  //MODULO 'TMK'  FUNNAME _cRotina
			if type("cFilAnt")<>"U"
				SetModulo("SIGATMK",'TMK')
				SetFunName("TMKA271")
				OpenSxs(,,,,FWCodEmp(),"SX6","SX6",,.F.)
				SX6->(dbSetOrder(1))
				_cPathEnt := SuperGetMv("MV_PENTVDA",,"\xls\entrada\" ) // "\\192.168.1.212\g$\planilhas12\entrada\"  //SuperGetMv("MV_PENTVDA",,"\xls\entrada\" ) 
				_cPathTra := SuperGetMv("MV_PTRAVDA",,"\xls\transito\") //"\\192.168.1.212\g$\planilhas12\transito\" //SuperGetMv("MV_PTRAVDA",,"\xls\transito\")
				_cPathErr := SuperGetMv("MV_PERRVDA",,"\xls\erro\"    ) //"\\192.168.1.212\g$\planilhas12\erro\" //SuperGetMv("MV_PERRVDA",,"\xls\erro\"    ) 
				_cPathPro := SuperGetMv("MV_PPROVDA",,"\xls\ok\"      ) //"\\192.168.1.212\g$\planilhas12\ok\"//SuperGetMv("MV_PPROVDA",,"\xls\ok\"      )
				_aArqEnt  := Directory(_cPathEnt + "*.CSV")
	//			_cPathTra := Directory(_cPathEnt+ "*.CSV" )
				if len(_aArqEnt) > 0
					_nXi := 1
					for _nXi := 1 to len(_aArqEnt)		//27.03.2015 - O QUE HAVIA SIDO DESATIVADO EM 09.02.2015 FOI REATIVADO PARA ACOMPANHAMENTO
						_lProc   := .T.
						_cArqOri := _cPathEnt+LOWER(_aArqEnt[_nXi][01])
						SplitPath(_cArqOri, @cDriveE, @cDirE, @cNomeE, @cExtE)
						if file(_cArqOri) 
							_cQry := " SELECT COUNT(*) REG "
							_cQry += " FROM " + RetSqlName("SUA") + " (NOLOCK) "
							_cQry += " WHERE UA_FILIAL  = '" + xFilial("SUA") + "' "
							_cQry += "   AND UA_ARQXLS  = '" + StrTran(Padr(Lower(_cPathTra+cNomeE+cExtE),TamSx3("UA_ARQXLS")[01]),"'","") + "' "
							_cQry += "   AND D_E_L_E_T_ = '' "
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SUATMPXLS",.F.,.T.)
							dbSelectArea("SUATMPXLS")
							if SUATMPXLS->REG > 0
								SUATMPXLS->(dbCloseArea())
								fRename((cDriveE+cDirE+cNomeE+cExtE), (_cPathErr+cNomeE+cExtE))
								MemoWrite(_cPathErr+cNomeE+".log","Arquivo '"+cNomeE+cExtE+"' ja importado anteriormente, sendo entao desprezado!")
								Loop
								return
							endif
							SUATMPXLS->(dbCloseArea())
							if file(cDriveE+cDirE+cNomeE+cExtE) .AND. fRename((cDriveE+cDirE+cNomeE+cExtE), (_cPathTra+cNomeE+cExtE)) == 0
								if file(_cPathTra+cNomeE+cExtE)
									_lExcl := .T.
		
									if _lExcl
										_cArqOri   := _cPathTra+cNomeE+cExtE
										SplitPath(_cArqOri, @cDriveE, @cDirE, @cNomeE, @cExtE)
										_cLogTempo += "Início: "  + DTOC(Date()) + " - " + Time() + " - Arquivo: " + (cDriveE+cDirE+cNomeE+cExtE) + _CRLF
										_nOpc      := 1
										if ProcRotIni(_lExt)
											fRename((cDriveE+cDirE+cNomeE+cExtE), (_cPathPro+cNomeE+cExtE))
										else
											fRename((cDriveE+cDirE+cNomeE+cExtE), (_cPathErr+cNomeE+cExtE))
										endif
										_cLogTempo += "Término: " + DTOC(Date()) + " - " + Time() + " - Arquivo: " + (cDriveE+cDirE+cNomeE+cExtE) + _CRLF
									 endif
								endif
							endif
						endif
					next
				endif
			else
				MsgStop("Problemas na entrada da rotina automatica " + _cRotina,_cRotina+"_015")
			endif
		RESET ENVIRONMENT
	else
		Static oDlg

		DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] "+cTitulo FROM 000, 000  to 220, 750 COLORS 0, 16777215 PIXEL

		    @ 004, 003 GROUP oGroup1 to 104, 371 PROMPT " IMPORTANTE " OF oDlg COLOR 0, 16777215 PIXEL
		    @ 025, 010 SAY oSay1 PROMPT "Esta rotina é utilizada para a importação do arquivo de pedidos de vendas do Excel para o Call Center do sistema. Selecione o arquivo em " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 038, 010 SAY oSay2 PROMPT "formato CSV para que possa ser processado.                                                                                               " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 050, 010 SAY oSay3 PROMPT "Após selecionar o arquivo, clique em confirmar.                                                                                          " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    DEFINE SBUTTON oSButton1 FROM 087, 237 TYPE 14 OF oDlg ENABLE  ACTION Eval(bDir   )
		    DEFINE SBUTTON oSButton2 FROM 087, 280 TYPE 01 OF oDlg ENABLE  ACTION Eval(bOk    )
		    DEFINE SBUTTON oSButton3 FROM 087, 320 TYPE 02 OF oDlg ENABLE  ACTION Eval(bCancel)

		ACTIVATE MSDIALOG oDlg CENTERED

		_cLogTempo += "Início: "  + DTOC(Date()) + " - " + Time() + " - Arquivo: " + (_cArqOri) + _CRLF
		ProcRotIni(_lExt)
		_cLogTempo += "Término: " + DTOC(Date()) + " - " + Time() + " - Arquivo: " + (_cArqOri) + _CRLF
	endif
	//GravaArred() //Função para correção dos calculos de valores arrendondando para 2 casas decimais.
	if !empty(_cLogTempo)
		if !_lExt
			MsgInfo("Processamento concluído!" + _CRLF + "LOG de Tempo de Processamento: " + _CRLF + _cLogTempo,_cRotina+"_016")
		endif
	endif
return
/*/{Protheus.doc} ProcRotIni
@description Processamento da rotina RTMKI001.
@obs Chamada pela função RTMKI001
@author Anderson C. P. Coelho (ALL System Solutions)
@since 24/07/2014
@version 1.0
@param _lExt , lógico  , .T. - Se a rotina está sendo chamada fora do Protheus (via JOB).
@type function
@see https://allss.com.br
/*/
static function ProcRotIni(_lExt)
	if !_lProc .OR. _nOpc <> 1 //.OR. (!_lExt .AND. !MsgYesNo("Confirma a importação do arquivo '" + _cArqOri + "' selecionado?",_cRotina+"_005"))
		MsgStop("Operação cancelada!",_cRotina+"_006")
		_lProc := .F.
	endif
	SplitPath( _cArqOri, @cDrive, @cDir, @cNome, @cExt)
	_cDst    := (cDrive+cDir)
	_cNomOri := cNome
	_cExtDst := cExt
	if _lProc
		_cFilSA1 := " A1_MSBLQL <> '1' "
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbClearFilter())
		SA1->(dbSetFilter( { || &(_cFilSA1) }, _cFilSA1 ))
		dbSelectArea("SUA")
		SUA->(dbSetOrder(1))
		dbSelectArea("SUB")
		SUB->(dbSetOrder(1))
		if _lProc
			Processa( { |lEnd| _lProc := ProcArq(lEnd, (_cDst+_cNomOri+_cExtDst), _lExt) }, "["+_cRotina+"] "+cTitulo, "Processando arquivo " + (_cDst+_cNomOri+_cExtDst) + "...", .F. )
		endif
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbClearFilter())
	endif
	RestArea(_aSvAr)
return _lProc
/*/{Protheus.doc} SelDirArq
@description Seleçao de arquivo no diretorio, pela rotina RTMKI001.
@obs Chamada pela função RTMKI001
@author Anderson C. P. Coelho (ALL System Solutions)
@since 24/07/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function SelDirArq()
	local _cTipo := "Arquivos Excel do tipo CSV | *.CSV"
	_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo a ser importado ",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
return _cArqOri
/*/{Protheus.doc} ProcArq
@description Processamento do arquivo CSV selecionado para importação ao Televendas do Call Center, por meio de MsExecAuto na rotina padrão "TMKA271".
@obs Chamada pela função RTMKI001
@author Anderson C. P. Coelho (ALL System Solutions)
@since 24/07/2014
@version 1.0
@param lEnd    , lógico  , Indica se a operação foi cancelada pela regua de processamento.
@param _cArqCsv, caracter, Nome do arquivo que será processado.
@param _lExt   , lógico  , .T. - Se a rotina está sendo chamada fora do Protheus (via JOB).
@type function
@see https://allss.com.br
/*/
static function ProcArq(lEnd,_cArqCsv,_lExt) 
	local _cLin        := ""
	local _cTpAt       := "2"	//Tipo de Atendimento: 1=Telemarketing; 2=Televendas            ; 3=Telecobrança; 4=Ambos
	local _cTpPd       := "3"	//Tipo de Atendimento: 1=Faturamento  ; 2=Orçamento (pré-pedido); 3=Atendimento
	local _cTpMk       := "4"	//Tipo de Marketing..: 1=Ativo        ; 2=Receptivo             ; 3=Fax         ; 4=Representante
//	local cRotina      := _cTpAt
	local _cCposIt     := ""
	local _nLin        := 0
	local _k           := 0
	local _kd          := 0
	local nOpc         := 3		//2=Visualização; 3=Inclusão; 4=Alteração; 5=Exclusão

	private _x         := 0
	private _cCdAnt    := SuperGetMv("MV_CNDPGAN",,"166")		//Condição de Pagamento padrão para antecipação
	private _aCabec    := { {"UA_CLIENTE", ""               , NIL},;
		                    {"UA_LOJA"   , ""               , NIL},;
		                    {"UA_TPOPER" , SuperGetMv("MV_OPERVDA",,"01"), NIL},;
		                    {"UA_OPER"   , _cTpPd           , NIL},;
		                    {"UA_ALTTRAN", ""               , NIL},;
		                    {"UA_PEDCLI2", ""               , NIL},;
		                    {"UA_CONDPG" , _cCdAnt          , NIL},;
		                    {"UA_OBSPLAN", ""               , NIL},;
		                    {"UA_DESC1"  , 0                , NIL},;
		                    {"UA_DESC2"  , 0                , NIL},;
		                    {"UA_DESC3"  , 0                , NIL},;
		                    {"UA_DESC4"  , 0                , NIL},;
		                    {"UA_TMK"    , _cTpMk           , NIL},;
		                    {"UA_ARQXLS" , Lower(StrTran(_cArqOri,"'","")), NIL} }
	//	                    {"UA_EMISSAO", dDataBase        , NIL},;
	//	                    {"UA_TPOPER" , SuperGetMv("MV_OPERVDA",,"01"), NIL},;
	//						{"UA_NUM"    , ""               , NIL},;
	private _aItBk     := {	{"UB_ITEM"   , ""                   , NIL},;
		                    {"UB_PRODUTO", Criavar("UB_PRODUTO"), NIL},;
		                    {"UB_QUANT"  , 0                    , NIL},;
		                    {"UB_VRUNIT" , Criavar("UB_VRUNIT" ), NIL},;
		                    {"UB_DESCTV1", Criavar("UB_DESCTV1"), NIL},;
		                    {"UB_DESCTV2", Criavar("UB_DESCTV2"), NIL},;
		                    {"UB_DESCTV3", Criavar("UB_DESCTV3"), NIL},;
		                    {"UB_DESCTV4", Criavar("UB_DESCTV4"), NIL},;
		                    {"UB_CODFATR", Criavar("UB_CODFATR"), NIL},;
		                    {"UB_FATOR"  , Criavar("UB_FATOR"  ), NIL},;
		                    {"UB_DESC"   , Criavar("UB_DESC"   ), NIL} }
	private _aItens    := {}
	private _aItPv     := {}
	private _aLin      := {}
	//Estrutura do Array _aCbPl (utilizado para a configuração dos campos do cabeçalho da planilha importada):
		//01 - Campo na planilha
		//02 - Posição (coluna) na planilha, relativo ao título
		//03 - Posição (coluna) na planilha, relativo ao conteúdo
		//04 - Conteúdo lido
		//05 - Que campo(s) o sistema deverá atualizar (array)
		//06 - Tipo, sendo: 
		//          P=Posicionamento (neste caso, o sistema utilizará o array da próxima coluna desta matriz)
		//          A=Atualização (neste caso o sistema somente passará a informação para o campo mencionada na coluna anterior da matriz)
		//          I=Informativo (o sistema não fará nada com este registro
		//          V=Verificar (o sistema utilizará esta informação para checagem de algo)
		//07 - Array contendo a sequencia para posicionamento, quando for o caso. Este posicionamento deverá convergir com o conteúdo de campos a serem preenchidos na ordem 05.
		//08 - Ordem de Prioridade, sendo:
		//          XX - Dois primeiros dígitos para o grupo da ordem, sendo:
		//                       01 - Cliente
		//                       02 - Condição de Pagamento
		//                       03 - Desconto do cabeçalho
		//                       04 - Transportadora
		//                       05 - Número do Pedido do cliente
		//                       06 - Observações
		//          XX - Dois últimos dígitos para a prioridade da ordem
		//09 - Idetifica se o registro final (da coluna 05) foi atualizado ou não
	//POSIÇÕES DO ARRAY: 	 01                       , 02, 03, 04, 05                      , 06 , 07                                                                                                                                                           , 08    , 09
	private _aCbPl     := {	{"RAZAO SOCIAL"           , 02, 03, "", {"UA_CLIENTE","UA_LOJA"}, "P", {"SA1",2,'xFilial("SA1") + Padr(UPPER(_aCbPl[_x][04]),TamSx3("A1_NOME")[01])',{"A1_COD","A1_LOJA"}                                                          }, "0102", .F.},;
							{"CNPJ"                   , 02, 03, "", {"UA_CLIENTE","UA_LOJA"}, "P", {"SA1",3,'xFilial("SA1") + Padr(StrTran(StrTran(StrTran(StrTran(_aCbPl[_x][04],".",""),"-",""),"/","")," ",""),TamSx3("A1_CGC" )[01])',{"A1_COD","A1_LOJA"} }, "0101", .F.},;
							{"CIDADE"                 , 04, 07, "", {"UA_CLIENTE","UA_LOJA"}, "V", {'Padr(UPPER(_aCbPl[_x][04]),TamSx3("A1_MUN")[01]) == SA1->A1_MUN'                                                                                          }, "0104", .F.},;
							{"ESTADO"                 , 08, 10, "", {"UA_CLIENTE","UA_LOJA"}, "V", {'Padr(UPPER(_aCbPl[_x][04]),TamSx3("A1_EST")[01]) == SA1->A1_EST'                                                                                          }, "0103", .F.},;
							{"PAGAMENTO ANTECIPADO?"  , 02, 06, "", {"UA_CONDPG"           }, "P", {'IIF(!empty(_aCbPl[_x][04]),_cCdAnt,IIF(!empty(SA1->A1_COND),SA1->A1_COND,_cCdAnt))'                                                                       }, "0201", .F.},;
							{"% DESC. COND. DE PAGTO.", 08, 10, 00, {"UA_DESC1"            }, "P", {'IIF(ValType(_aCbPl[_x][04])=="C",VAL(StrTran(StrTran(StrTran(StrTran(_aCbPl[_x][04],"%",""),".","."),"%",""),",",".")),_aCbPl[_x][04])'                   }, "0301", .F.},;
							{"MUDOU TRANSPORTADORA?"  , 04, 06, "", {"UA_ALTTRAN"          }, "P", {'IIF(!empty(_aCbPl[_x][04]),"S","N")'                                                                                                                      }, "0401", .F.},;
							{"REPRESENTANTE"          , 02, 03, "", {"UA_REPRES"           }, "A", {                                                                                                                                                           }, "0501", .F.},;
							{"DATA"                   , 08, 10, "", {"UA_EMPLAN"           }, "P", {'DTOC(CTOD(_aCbPl[_x][04]))'                                                                                                                               }, "0601", .F.},;
							{"PED. CLIENTE"           , 08, 10, "", {"UA_PEDCLI2"          }, "A", {                                                                                                                                                           }, "0701", .F.},;
							{"OBSERVAÃ‡ÃƒO"           , 02, 03, "", {"UA_OBSPLAN"          }, "A", {                                                                                                                                                           }, "0801", .F.} }
	//Estrutura do Array _aItPl (utilizado para a configuração dos campos dos itens da planilha importada):
		//01 - Nome da coluna na planilha
		//02 - Campo relacionado ao sistema
		//03 - 1=Atualizar; 2=Verificar (a rotina irá fazer algum tipo de consistência); 3=Nenhuma ação será data a esta informação
		//04 - Coluna onde a informação se encontra
	private _aItPl     := {	{"CODIGO"        ,"UB_PRODUTO",1,02},;
							{"PRODUTO"       ,"B1_DESC"   ,3,03},;
							{"Q/E"           ,"B1_VOSEC"  ,2,04},;
							{"PRECO DE LISTA","UB_VRUNIT" ,1,05},;
							{"QTDE."         ,"UB_QUANT"  ,1,06},;
							{"MENSAGEM"      ,""          ,2,07},;
							{"DESC.1"        ,"UB_DESCTV1",1,08},;
							{"DESC.2"        ,"UB_DESCTV2",1,09},;
							{"DESC.3"        ,"UB_DESCTV3",1,10},;
							{"TOTAL"         ,"UB_VLRITEM",2,11} }
	private _nColQt     := 06
	private _lIncBk     := IIF(Type("INCLUI")<>"U",INCLUI,INCLUI := .T.)
	private _lAltBk     := IIF(Type("ALTERA")<>"U",ALTERA,ALTERA := .F.)
	private _lObs       := .F.
	private lMsErroAuto := .F.

	FT_FUSE(_cArqCsv)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	if !FT_FEOF()
		for _k := 1 to len(_aItPl)
			if _k > 1
				if _k > 3	//Só me bastam os 03 primeiros campos dos itens.
					Exit
				endif
				_cCposIt += ";"
			endif
			_cCposIt += _aItPl[_k][01]
		next
	//	Begin Transaction
			_aCbPl := aSort(_aCbPl,,, { |x,y| x[08] < y[08] })
			_lObs  := .F.
			//while do Cabeçalho
			while !FT_FEOF() .AND. !_cCposIt$UPPER(_cLin)
				_nLin++
				IncProc("Lendo linha " + cValToChar(_nLin) + " do arquivo " + _cArqCsv + "...")
				_cLin := FT_FREADLN()
				if _cCposIt$UPPER(_cLin)
					Loop
				endif
				_aLin  := Separa(_cLin,";",.T.)		//Estrutura do array gerado: _aLin[_x]
				for _x := 1 to len(_aCbPl)
					If _x = 12 //Tratamento para ajustar a estrutura da planilha devido a conversão automatica através do script Python.
						_x := 11
					EndIf
					if aScan(_aLin, _aCbPl[_x][01]) > 0
						_aCbPl[_x][04] := _aLin[ _aCbPl[_x][03] ]
						if "OBSERVAÃ‡ÃƒO"$AllTrim(_aCbPl[_x][01])//"OBSERVA€ÇO" 
							while !FT_FEOF() .AND. !_cCposIt$UPPER(_cLin)
								FT_FSKIP()
								if _cCposIt$UPPER(_cLin)
									Loop
								endif
								_nLin++
								IncProc("Lendo linha " + cValToChar(_nLin) + " do arquivo " + _cArqCsv + "...")
								_cLin          := FT_FREADLN()
								if !empty(_cLin)
									_aLin      := Separa(_cLin,";",.T.)		//Estrutura do array gerado: _aLin[_x]
									if len(_aLin) > 0
										_aCbPl[_x][04] += _CRLF + _aLin[01]
									endif
								endif
							enddo
							_aCbPl[_x][04] := StrTran(_aCbPl[_x][04],'"','')
						endif
					endif
				next
				if _cCposIt$UPPER(_cLin)
					Loop
				endif
				FT_FSKIP()
			enddo
			for _x := 1 to len(_aCbPl)
				//_lAchou := .F.
				_cGrp   := SubStr(_aCbPl[_x][8],1,2)
				if !_aCbPl[_x][09]
					for _k := 1 to len(_aCbPl[_x][05])
						_nPos := aScan(_aCabec, {|x| AllTrim(x[01]) == AllTrim(_aCbPl[_x][05][_k])})
						if _nPos > 0             	
							//MELHORAR A CONVERSÃO DOS DADOS
							if _aCbPl[_x][06] == "A"
								if ValType(_aCabec[_nPos][02]) == "N" .AND. ValType(_aCbPl[_x][04]) == "C"
									_aCabec[_nPos][02] := VAL(StrTran(StrTran(StrTran(_aCbPl[_x][04],"%",""),".","."),",","."))
								elseif ValType(_aCbPl[_x][04]) == "C"
									_aCabec[_nPos][02] := StrTran(_aCbPl[_x][04],'"','')
								else
									_aCabec[_nPos][02] := _aCbPl[_x][04]
								endif
								_aCbPl[_x][09]     := .T.
							elseif _aCbPl[_x][06] == "P"
								if len(_aCbPl[_x][05]) > 1
									dbSelectArea(_aCbPl[_x][07][01])
									(_aCbPl[_x][07][01])->(dbSetOrder(_aCbPl[_x][07][02]))
									if !empty(&(_aCbPl[_x][07][03])) .AND. dbSeek(&(_aCbPl[_x][07][03]))
										_aCabec[_nPos][02] := &(Alias()+"->"+_aCbPl[_x][07][04][_k])
										_aCbPl[_x][09]     := .T.
									endif
								else
									_aCabec[_nPos][02] := &(_aCbPl[_x][07][_k])
									_aCbPl[_x][09]     := .T.
								endif
							elseif _aCbPl[_x][06] == "V"
								//?????????????????????????????????????????????????????????//
								//???????????????????TRATAR DEPOIS?????????????????????????//
								//?????????????????????????????????????????????????????????//
							endif
						endif
					next
					if _aCbPl[_x][09]
						_nLin := _x
						_x++
						while len(_aCbPl) >= _x .AND. _cGrp == SubStr(_aCbPl[_x][8],1,2)
							_aCbPl[_x][09] := .T.
							_cGrp          := SubStr(_aCbPl[_x][8],1,2)
							_x++
						enddo
						_x := _nLin
					endif
				endif
			next
			if _cCposIt$UPPER(_cLin)
				_cLin   := FT_FREADLN()
				_aCabLn := Separa(_cLin,";",.T.)		//Estrutura do array gerado: _aLin[_x]
				for _x := 1 to len(_aCabLn)
					_aCabLn[_x] := AllTrim(_aCabLn[_x])
				next
				for _x := 1 to len(_aItPl)
					//_aItPl[_x][04] := aScan(_aCabLn, AllTrim(_aItPl[_x][01]))
					if AllTrim(_aItPl[_x][02]) == "UB_QUANT"
						_nColQt := _aItPl[_x][04]
					endif
				next
				_aItPl := aSort(_aItPl,,, { |x,y| x[03] < y[03] })
				FT_FSKIP()
				//while dos Itens
				while !FT_FEOF()
					_nLin++
					IncProc("Lendo linha " + cValToChar(_nLin) + " do arquivo " + _cArqCsv + "...")
					_cLin := FT_FREADLN()
					//if ";TOTAL;;;;"$_cLin
					if ";TOTAL;"$_cLin
						FT_FSKIP()
						Loop
					endif
					_aLin := Separa(_cLin,";",.T.)		//Estrutura do array gerado: _aLin[_x]
					if len(_aLin) > 0
						_nQtd := VAL(StrTran(StrTran(_aLin[_nColQt],".","."),",","."))
						if ValType(_nQtd) == "N" .AND. _nQtd > 0
							_aItens := {}
							_aItens := aClone(_aItBk)
							for _x := 1 to len(_aLin)
								for _k := 1 to len(_aItPl)
									if _aItPl[_k][03] == 1 .AND. _aItPl[_k][04] <> 0		//Atualizar
		//MELHORAR A CONVERSÃO DOS DADOS
										if AllTrim(TamSx3(_aItPl[_k][02])[03]) == "N" .AND. ValType(_aLin[_aItPl[_k][04]]) == "C"
											_aLin[_aItPl[_k][04]] := VAL(StrTran(StrTran(StrTran(_aLin[_aItPl[_k][04]],"%",""),".","."),",","."))
										endif
										if !empty(_aLin[_aItPl[_k][04]]) .AND. aScan(_aItens,{|x|AllTrim(x[01])==AllTrim(_aItPl[_k][02])}) > 0
											_aItens[aScan(_aItens,{|x|AllTrim(x[01])==AllTrim(_aItPl[_k][02])})][02] := _aLin[_aItPl[_k][04]]
										endif
									elseif _aItPl[_k][03] == 2 .AND. _aItPl[_k][04] <> 0	//Verificar
		
									else													//Não fazer nada
										Exit
									endif
								next
							next
							//Início do trecho para a informação do fator de desconto
							_cDDesc := ""
							_nCDesc := 1
							_nPDesc := 0
							while (_nPDesc := aScan(_aItens,{|x| AllTrim(x[01]) == "UB_DESCTV"+cValToChar(_nCDesc)})) > 0 .AND. SUB->(FieldPos("UB_DESCTV"+cValToChar(_nCDesc))) <> 0
								_cDDesc += Str(_aItens[_nPDesc][02],6,2)
								_nCDesc++
							enddo
							if !empty(_cDDesc)
								dbSelectArea("SZA")
								SZA->(dbOrderNickName("ZA_DESC1"))	//ZA_FILIAL+STR(ZA_DESC1,6,2)+STR(ZA_DESC2,6,2)+STR(ZA_DESC3,6,2)+STR(ZA_DESC4,6,2)+ZA_MSBLQL
								if aScan(_aItens,{|x| AllTrim(x[01]) == "UB_CODFATR"}) > 0 .AND. SUB->(FieldPos("UB_CODFATR")) <> 0 .AND. (SZA->(MsSeek(xFilial("SZA") + _cDDesc + "2")) .OR. SZA->(MsSeek(xFilial("SZA") + _cDDesc + " ")))
									_aItens[aScan(_aItens,{|x| AllTrim(x[01]) == "UB_CODFATR"})][02]   := SZA->ZA_CODIGO
									if aScan(_aItens,{|x| AllTrim(x[01]) == "UB_FATOR"}) > 0 .AND. SUB->(FieldPos("UB_FATOR")) <> 0
										_aItens[aScan(_aItens,{|x| AllTrim(x[01]) == "UB_FATOR"})][02] := SZA->ZA_FATOR
										if aScan(_aItens,{|x| AllTrim(x[01]) == "UB_DESC"}) > 0 .AND. SUB->(FieldPos("UB_DESC")) <> 0
											_aItens[aScan(_aItens,{|x| AllTrim(x[01]) == "UB_DESC" })][02] := SZA->ZA_FATOR
										endif
									endif
								else
									_aDesc  := Separa(_cDDesc," ",.F.)
									if len(_aDesc) > 0
										_nFator := 1
										for _kd := 1 to len(_aDesc)
											_nFator := _nFator - (_nFator * (VAL(StrTran(StrTran(StrTran(AllTrim(_aDesc[_kd]),"%",""),".","."),",",".")) / 100))
										next
										_nFator := NoRound((1-_nFator)*100,TamSx3("UB_DESC")[02])
										if _nFator > 0
											if aScan(_aItens,{|x| AllTrim(x[01]) == "UB_DESC"}) > 0 .AND. SUB->(FieldPos("UB_DESC")) <> 0
												_aItens[aScan(_aItens,{|x| AllTrim(x[01]) == "UB_DESC" })][02] := _nFator
											endif
											if aScan(_aItens,{|x| AllTrim(x[01]) == "UB_FATOR"}) > 0 .AND. SUB->(FieldPos("UB_FATOR")) <> 0
												_aItens[aScan(_aItens,{|x| AllTrim(x[01]) == "UB_FATOR"})][02] := _nFator
											endif
										endif
									endif
								endif
							endif
							//FIM do trecho para a informação do fator de desconto
							_nItMax := VAL(Replicate("9",TamSx3("UB_ITEM")[01]))
							if (len(_aItPv)+1) > _nItMax
								_cItem := cValToChar(_nItMax)
								for _x := (_nItMax+1) to (len(_aItPv)+1)
									_cItem := Soma1(_cItem,,,.T.)
								next
								_aItens[aScan(_aItens,{|x| AllTrim(x[01]) == "UB_ITEM"   })][02] := Padr(_cItem          ,TamSx3("UB_ITEM")[01])
							else
								_aItens[aScan(_aItens,{|x| AllTrim(x[01]) == "UB_ITEM"   })][02] := StrZero(len(_aItPv)+1,TamSx3("UB_ITEM")[01])
							endif
							AADD(_aItPv,_aItens)
						endif
					endif
					FT_FSKIP()
				enddo
			endif
		Begin Transaction
			if len(_aCabec) > 0 .AND. len(_aItPv) > 0
				if aScan(_aCabec,{|x| AllTrim(x[01])=="UA_CLIENTE"}) > 0 .AND. aScan(_aCabec,{|x| AllTrim(x[01])=="UA_LOJA"}) > 0
					//Trecho de ajuste do Tipo de Operação para o disparo dos TES Inteligente
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					if SA1->(MsSeek(xFilial("SA1") + Padr(_aCabec[aScan(_aCabec,{|x| AllTrim(x[01])=="UA_CLIENTE"})][02],TamSx3("A1_COD")[01]) + Padr(_aCabec[aScan(_aCabec,{|x| AllTrim(x[01])=="UA_LOJA"})][02],TamSx3("A1_LOJA")[01]),.T.,.F.))
						if AllTrim(SA1->A1_TPDIV) == "0"
							_aCabec[aScan(_aCabec,{|x| AllTrim(x[01])=="UA_TPOPER"})][02] := "ZZ"
						endif
					endif
					//Fim do trecho de ajuste do Tipo de Operação
				endif
				dbSelectArea("SUA")
				SUA->(dbSetOrder(1))
				//Parâmetros do MsExecAuto:
				//  x   1=Array com o Cabeçalho
				//  y   2=Array com os Itens
				//  z   3=nOpc (3 para inclusão; 4 para alteração)
				//  k   4=_cTpAt (Tipo de Atendimento, sendo: 1=Telemarketing; 2=Televendas; 3=Telecobrança; 4=Ambos)
				//_aCabec[aScan(_aCabec,{|x| AllTrim(x[01]) == "UA_NUM"})][02] := TkNumero("SUA","UA_NUM")		//GetSXeNum("SUA","UA_NUM")
				lMsErroAuto := .F.
	//			MSExecAuto( { |x,y,z,w| TMKA271(x,y,z,w) }, _aCabec, _aItPv, nOpc, _cTpAt )
				TMKA271(_aCabec, _aItPv, nOpc, _cTpAt)
				if lMsErroAuto
					_lProc := .F.
					if _lExt
						MostraErro(_cPathErr,cNomeE+".log")
					//else
					//	MostraErro()
					endif
				//else
				//	MsgInfo("Importação realizada com sucesso!",_cRotina+"_013")
				endif
			else
				_lProc := .F.
			endif
		End Transaction
//	else
//		_lProc := .F.
//		MsgStop("Arquivo " + _cArqCsv + " vazio. Nada a importar!",_cRotina+"_014")
	endif
	FT_FUSE()

	INCLUI := _lIncBk
	ALTERA := _lAltBk
return _lProc


Static Function GravaArred()
		cQry := " UPDATE "+RetSQLName("SUB")
		cQry += " SET UB_VRUNIT = ROUND(UB_VRUNIT,2) "
		cQry += " , UB_VLRITEM = ROUND(UB_QUANT * ROUND(UB_VRUNIT,2),2) "
		cQry += " , UB_VALDESC = ROUND(UB_QUANT * ROUND(UB_PRCTAB,2),2) - ROUND(UB_QUANT * ROUND(UB_VRUNIT,2),2) "
		cQry += " FROM SUB010 SUB (NOLOCK) "
		cQry += " INNER JOIN SUA010 SUA (NOLOCK) ON SUA.D_E_L_E_T_ = '' AND UA_NUM = UB_NUM AND UA_NUMSC5 = '' "
		cQry += " WHERE SUB.D_E_L_E_T_ = '' "
		cQry += " AND UB_FILIAL = '"+xFilial("SUB")+"' "
		cQry += " AND UA_EMISSAO >= '20250201' "
		cQry += " AND ROUND((UB_QUANT * ROUND(UB_VRUNIT,2)),2) <> UB_VLRITEM "
	
		TcSQLExec(cQry)
return

