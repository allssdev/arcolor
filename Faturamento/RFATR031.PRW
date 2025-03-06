#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥RFATR031  ∫ Autor ≥ J˙lio Soares         ∫ Data ≥  25/04/14 ∫±±
±±∫          ≥Arrays    ∫ Autor ≥ Anderson Coelho      ∫ Data ≥  29/06/14 ∫±±
±±∫          ≥ReediÁ„o  ∫ Autor ≥ J˙lio Soares         ∫ Data ≥  17/07/14 ∫±±
±±∫          ≥Moeda     ∫ Autor ≥ J˙lio Soares         ∫ Data ≥  27/06/16 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ RelatÛrio de relaÁ„o de faturamento totalizado por produto,∫±±
±±∫          ≥ por cliente, por vendedor, por estado e por emiss„o        ∫±±
±±∫          ≥ conforme informaÁıes dos par‚metros solicitados.           ∫±±
±±∫          ≥ RelatÛrio chamado pelo cliente de MASTER-DATA.             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫          ≥ Master-Data                                                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Protheus 11 - EspecÌfico para empresa ARCOLOR              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function RFATR031()

Local   _aSavArea  := GetArea()
Private _cRotina   := "RFATR031"
Private _cPerg     := _cRotina
Private _cTitulo   := ""
Private _cTitulo2  := ""
Private _cQuery    := ""
Private _tAlias	   := "TMPRFT31"
Private _aColuns   := {}		//Campos a serem atualizados
Private _lEnt      := + CHR(13) + CHR(10)
Private nListBox1  := 1
Private nListBox2  := 2
Private nListBox3  := 3
Private nListBox4  := 4
Private nListBox5  := 5
Private nListBox6  := 6
Private nListBox7  := 7
Private nListBox8  := 8
Private _cQryCheck := ""
Private _aTtt      := {}	//PosiÁıes: 1=N∫ Coluna  /  2=Valores Somados
Private _aSbTtt    := {}	//PosiÁıes: 1=Tipo (Estado,Vendedor,CNPJ,Cliente)  /  2=Sub-Estrutura contendo: [1=N∫ Coluna  |  2=Valores Somados | 3=Sub-Total de que?]  /  3=Nome do campo relativo  /  4=TÌtulo do Sub_Total  /  5=Nome que ser· exibino no sub-total / 6=Ordem Escolhida
Private _aSize   := MsAdvSize()
Private _cMoeda   := iif(len(MV_PAR17)>0, MV_PAR17, '1')
Public  _lRetm     := .T.
Public  _lRetView  := .T.

// - INFORMA SE ESSE RELAT”RIO CONT…M INFORMA«’ES ESPECÕFICA DO CLIENTE.
Public _lEspecific := .T.

// - PERGUNTA DE SEGURAN«A, CASO O PAR¬METRO COM INFORMA«’ES ESPECÕFICAS ESTEJA COMO 'FALSE'
If !_lEspecific
	If MsgYesNo("O relatÛrio n„o est· configurado para atender campos especÌficos do cliente, Deseja configurar automaticamente?",_cRotina+"_001A")
		_lEspecific := .T.
	Else
		Return()
	EndIf
EndIf

/* - VALIDA A EXIST NCIA DAS TABELAS DE VIEW
//If FindFunction("CView")
//	CView()
//EndIf

If !_lRetView
	MSGBOX('FORAM EXECUTADOS OS PROCESSOS DE CRIA«√O DA ESTRUTURA PARA QUE O RELAT”RIO POSSA SER GERADO COM INTEGRIDADE.' + _lEnt +;
	 'SER¡ NECESS¡RIO AGUARDAR ALGUNS MINUTOS ANTES DE EMITIR NOVAMENTE O RELAT”RIO',_cRotina+'999','ALERT')
	Return()
EndIf*/

// - VALIDA AS PERGUNTAS PARA O PAR¬METRO
//If FindFunction ("ValidPerg")
	ValidPerg()
//Else
//	MSGBOX('FunÁ„o de validaÁ„o de perguntas n„o encontrado. Informe o administrador do sistema',_cRotina+'_','ALERT')
//EndIf

// - CHAMA AS PERGUNTAS DOS PAR¬METROS
/* FB - RELEASE 12.1.23
While !Pergunte(_cPerg,.T.)
	If MsgYesNo("Deseja cancelar a emiss„o do relatÛrio?",_cRotina+"_001B")
		Return()
	EndIf
EndDo
*/
IF !Pergunte(_cPerg,.T.)
	MSGBOX("FunÁ„o cancelada pelo usu·rio!",'CANCELADO','STOP')
	Return()
ENDIF

// - VERIFICA SE USU¡RIO TEM PERMISS√O PARA GERAR DADOS EM EXCEL
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usu·rio sem permiss„o para gerar relatÛrio em Excel. Informe o Administrador.',_cRotina+"_002",'STOP')
   Return(Nil)
EndIf

// - VERIFICA SE H¡ O EXCEL INSTALADO NA M¡QUINA EM USO, PERMITE QUE USU¡RIO 'ADMINISTRADOR' REALIZE TESTES
If !(__cUserID) $ '000000|000154|000155|000156'
	If !ApOleClient('MsExcel')
		Msgbox('Para emitir o relatÛrio È necess·rio ter o aplicativo [Excel] instalado.',_cRotina+"_003",'ALERT')
	   Return(Nil)
	EndIf
EndIf

_cTitulo  := ("RelaÁ„o de Faturamento de " + (DTOC(mv_par01)) + " atÈ " + (DTOC(mv_par02)) + " - " + _cRotina)
_cTitulo2 := ("PAR¬METROS")

// - SELECIONA A ORDEM DO FATURAMENTO
//If FindFunction ("SelOrd")
	SelOrd()
//Else
//	MSGBOX('FunÁ„o de ordenaÁ„o dos sub-totais n„o encontrado. Informe o administrador do sistema!',_cRotina+'_012','ALERT')
//EndIf

// - DEFINE A ORDEM DOS ARRAYS DA SUB-TOTALIZA«√O
	//Estrutura do array "_aSbTtt"
	//PosiÁıes: 1=Tipo (1=Estado,2=Vendedor,3=CNPJ,4=Cliente,5=Documento,6=Tipo,7=Familia,8=Produto)
	//          2=Sub-Estrutura contendo: 
	//						1=N∫ Coluna
	//						2=Valores Somados
	//						3=Sub-Total de que?
	//			3=Nome do campo relativo
	//			4=TÌtulo do Sub_Total
	//			5=Nome que ser· exibino no sub-total
	//			6=Ordem na Query
	//			7=Ordem Escolhida
	//			8=Indica se haver· sub-totalizaÁ„o

AADD( _aSbTtt, { 1, {}, (_tAlias)+"->ESTADO"                                                                  , "SUB-TOTAL DO ESTADO "            , (_tAlias)+"->ESTADO"   , "ESTADO"           , nListBox1, MV_PAR06==2} )		//ESTADO

// AlteraÁ„o - Fernando Bombardi - ALLSS - 02/03/2022
//AADD( _aSbTtt, { 2, {}, (_tAlias)+"->VEND     + ' ' + " + (_tAlias)+"->NOMEVEND"                              , "SUB-TOTAL DO VENDEDOR "          , (_tAlias)+"->NOMEVEND" , "VEND,NOMEVEND"    , nListBox2, MV_PAR07==2} )		//VENDEDOR
AADD( _aSbTtt, { 2, {}, (_tAlias)+"->VEND     + ' ' + " + (_tAlias)+"->NOMEVEND"                              , "SUB-TOTAL DO REPRESENTANTE "          , (_tAlias)+"->NOMEVEND" , "VEND,NOMEVEND"    , nListBox2, MV_PAR07==2} )		//VENDEDOR
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

If _lEspecific
	AADD( _aSbTtt, { 3, {}, (_tAlias)+"->CNPJCENT + ' ' + " + (_tAlias)+"->NOMECNPJ"                              , "SUB-TOTAL DO CNPJ CENTRALIZADOR ", (_tAlias)+"->NOMECNPJ" , "CNPJCENT,NOMECNPJ", nListBox3, MV_PAR04==1} )		//CNPJ CENTRAL
EndIf
AADD( _aSbTtt, { 4, {}, (_tAlias)+"->CLIENTE  + ' ' + " + (_tAlias)+"->LOJA     + ' ' + " + (_tAlias)+"->NOME", "SUB-TOTAL DO CLIENTE "           , (_tAlias)+"->NOME"     , "CLIENTE,LOJA,NOME", nListBox4, MV_PAR05==2} )		//CLIENTE
AADD( _aSbTtt, { 5, {}, (_tAlias)+"->DOC      + ' ' + " + (_tAlias)+"->SERIE"                                 , "SUB-TOTAL DO DOCUMENTO "         , (_tAlias)+"->DOC"      , "DOC,SERIE"        , nListBox5, MV_PAR08==2} )		//DOCUMENTO
AADD( _aSbTtt, { 6, {}, (_tAlias)+"->TIPO "                                                                   , "SUB-TOTAL DO TIPO "              , (_tAlias)+"->TIPO"     , "TIPO "            , nListBox6, MV_PAR13==2} )		//TIPO
AADD( _aSbTtt, { 7, {}, (_tAlias)+"->FAMILIA "                                                                , "SUB-TOTAL DA FAMILIA DE PRODUTOS", (_tAlias)+"->FAMILIA"  , "FAMILIA "         , nListBox7, MV_PAR14==2} )		//GRUPO 
AADD( _aSbTtt, { 8, {}, (_tAlias)+"->PRODUTO "                                                                , "SUB-TOTAL DO PRODUTO "           , (_tAlias)+"->PRODUTO"  , "PRODUTO "         , nListBox8, MV_PAR15==2} )		//PRODUTO

// - REALIZA A REORDENA«√O DOS ARRAYS COM AS SUB-TOTALIZA«’ES
_aSbTtt := aSort(_aSbTtt,,, { |x,y| x[07] < y[07] } )
If _lRetm
	// - CHAMA CONSULTA DO CLIENTE CONFORME SELE«√O DEFINIDO PELO USU¡RIO
	If ExistBlock("RFATE050")
		MSGRUN("Selecionando as informaÁıes de clientes... Por favor AGUARDE. ","["+_cRotina+"_013] "+_cTitulo,{|| U_RFATE050()})
	Else
		MSGBOX('N„o foi possÌvel continuar o processo, informe o administrador do sistema',_cRotina+'_COMP','STOP')
	EndIf
Else
	Return()
EndIf
If _lRetm
	// - CHAMA CONSULTA DO PRODUTO CONFORME SELE«√O DEFINIDO PELO USU¡RIO
	If ExistBlock("RFATE051")
		MsgRun("Selecionando as informaÁıes de produtos... Por favor AGUARDE. ",_cTitulo,{|| U_RFATE051()})
	Else
		MSGBOX('N„o foi possÌvel continuar o processo, informe o administrador do sistema',_cRotina+'_COMP','STOP')
	EndIf
Else
	Return()
EndIf
// Verifica a moeda selecionada
/*If MV_PAR17 <> '1'
	dbSelectArea("SM2")
	dbSetOrder(1) // M2_DATA
	If MsSeek(MV_PAR18,.T.,.F.)
		If Empty(&("M2_MOEDA"+MV_PAR17))
			MSGBOX("N„o existe cotaÁ„o cadastrada para a moeda "+GetMV("MV_MOEDA"+MV_PAR17+"")+" em "+DtoC(MV_PAR18)+". Verifique o cadastro de moedas.",_cRotina+"_000","STOP")
			Return()
		EndIf
	EndIf
EndIf*/
If _lRetm
// - CHAMA FUN«√O DE CONSULTA CONFORME PAR¬METROS DEFINIDO PELO USU¡RIO
//	MsgRun("Selecionando dados... Por favor AGUARDE. ",_cTitulo,{ || SelectQry() })
	Processa({ |lEnd| SelectQry()   },_cRotina,'Selecionando dados... Por favor AGUARDE. ',.T.)
	// - CHAMA A FUN«√O PARA EMITIR OS DADOS EM PLANILHA
	Processa({ |lEnd| Geraxls(@lEnd)},_cRotina,' Gerando relatÛrio em Excel...   Por favor aguarde.',.T.)
Else
    MSGBOX('N„o foram selecionados itens completos para a geraÁ„o do relatÛrio.',_cRotina+'_004','ALERT')
	Return()
EndIf

// - SE A TABELA APRESENTAR DADOS FECHA A MESMA AP”S O USO
If Select (_tAlias) > 0
   (_tAlias)->(dbCloseArea())
EndIf
dbCloseArea(_tAlias)

// - FAZ A LIMPEZA DAS MARCA«’ES DA TABELA DOS VENDEDORES
_cQryUpd1 := "UPDATE " + RetSqlName("SA3") + " "
_cQryUpd1 += "SET   A3_MARK   = '' "
If SA3->(FieldPos("A3_RELFAT"))<>0
	_cQryUpd1 += ", A3_RELFAT = REPLACE(A3_RELFAT,'" + ALLTRIM(__cUserId) + "|" + "','')"
	_cQryUpd1 += "WHERE A3_RELFAT LIKE '%" + ALLTRIM(__cUserId) + "|" +"%'"
	_cQryUpd1 += "AND D_E_L_E_T_ = '' "
Else
	_cQryUpd1 += "WHERE D_E_L_E_T_ = '' "
EndIf
_cQryUpd1 += "AND A3_FILIAL  = '" + xFilial("SA3") + "' "
If TCSQLExec(_cQryUpd1) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_005A")
EndIf

// - FAZ A LIMPEZA DAS MARCA«’ES DA TABELA DOS CLIENTES
_cQryUpd2 := "UPDATE " + RetSqlName("SA1") + " "
_cQryUpd2 += "SET A1_MARK    = '' "
If SA1->(FieldPos("A1_RELFAT"))<>0
	_cQryUpd2 += "  , A1_RELFAT  = REPLACE(A1_RELFAT,'" + ALLTRIM(__cUserId) + "|" + "','')"
	_cQryUpd2 += "WHERE A1_RELFAT LIKE '%" + ALLTRIM(__cUserId) + "|" +"%'"
	_cQryUpd2 += "AND D_E_L_E_T_ = '' "
Else
	_cQryUpd2 += "WHERE D_E_L_E_T_ = '' "
EndIf
_cQryUpd2 += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
If TCSQLExec(_cQryUpd2) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_005B")
EndIf

// - FAZ A LIMPEZA DAS MARCA«’ES DA TABELA DOS GRUPOS DE PRODUTOS
_cQryUpd3 := "UPDATE " + RetSqlName("SBM") + " "
_cQryUpd3 += "SET   BM_MARK   = '' "
If SBM->(FieldPos("BM_RELFAT"))<>0
	_cQryUpd3 += ", BM_RELFAT = REPLACE(BM_RELFAT,'" + ALLTRIM(__cUserId) + "|" + "','')"
	_cQryUpd3 += "WHERE BM_RELFAT LIKE '%" + ALLTRIM(__cUserId) + "|" +"%'"
	_cQryUpd3 += "AND D_E_L_E_T_ = '' "
Else
	_cQryUpd3 += "WHERE D_E_L_E_T_ = '' "
EndIf
_cQryUpd3 += "AND BM_FILIAL  = '" + xFilial("SBM") + "' "
If TCSQLExec(_cQryUpd3) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_005C")
EndIf

// - FAZ A LIMPEZA DAS MARCA«’ES DA TABELA DOS PRODUTOS
_cQryUpd4 := "UPDATE " + RetSqlName("SB1") + " "
_cQryUpd4 += "SET   B1_MARK    = '' "
If SB1->(FieldPos("B1_RELFAT"))<>0
	_cQryUpd4 += ", B1_RELFAT  = REPLACE(B1_RELFAT,'" + (Alltrim(__cUserId)) + "|" + "','') "
	_cQryUpd4 += "WHERE B1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "|" +"%' "
	_cQryUpd4 += "AND D_E_L_E_T_ = '' "
Else
	_cQryUpd4 += "WHERE D_E_L_E_T_ = '' "
EndIf
_cQryUpd4 += "AND B1_FILIAL  = '" + xFilial("SB1") + "' "
If TCSQLExec(_cQryUpd4) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_005D")
EndIf
If MsgYesNo("Deseja processar o relatÛrio novamente?",_cRotina+"_005E")
	ExecBlock("RFATR031")
EndIf
             
RestArea(_aSavArea)

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥SelectQry ∫ Autor ≥J˙lio Soares         ∫ Data ≥  25/04/14 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ FunÁ„o respons·vel pela seleÁ„o dos dados a partir da      ∫±±
±±∫          ≥ consulta .                                                 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫          ≥ Implementado ajustes na consulta.                          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function SelectQry()

Local _cSelFat  := ""  // Select Faturamento
Local _cQryFat  := ""  // Query  Faturamento
Local _cGrpFat  := ""  // Group  Faturamento

Local _cSelDev  := ""  // Select DevolÁ„o
Local _cQryDev  := ""  // Query  DevolÁ„o
Local _cGrpDev  := ""  // Group  DevolÁ„o
Local _cOrdDev  := ""  // Order  DevolÁ„o

Local _SelCpos  := ""  // SeleÁ„o do Union All
Local _SumCpos  := ""  // Soma dos campos do Union All

Local _cGroup   := ""  // Group Geral
Local _cOrder   := ""  // Order Geral
Local _cOrd     := ""  // Order 

Local _cQuery   := ""  // Query final

// - INICIO DA CONSTRU«√O DAS COLUNAS PARA O EXCEL

// VERIFICA PARAMETRO PARA APRESENTAR COLUNA DA DATA DE EMISS√O: 1 - N√O, 2 - SIM
If (MV_PAR03) == 2
	AADD(_aColuns,{"EMISSAO"       ,"(_tAlias)->EMISSAO"  ,2,4,.F.})
EndIf

// TRATAMENTO PARA O PAR¬METRO "AT… ESTADO": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR06) <> 1
	AADD(_aColuns,{"ESTADO"        ,"(_tAlias)->ESTADO"   ,2,1,.F.})
EndIf

// TRATAMENTO PARA O PAR¬METRO "VENDEDOR": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR07) <> 1

	// AlteraÁ„o - Fernando Bombardi - ALLSS - 02/03/2022
	AADD(_aColuns,{"REPRESENTANTE" ,"(_tAlias)->VEND"     ,2,1,.F.})
	AADD(_aColuns,{"NOME REP."     ,"(_tAlias)->NOMEVEND" ,1,1,.F.})

	//AADD(_aColuns,{"VENDEDOR"      ,"(_tAlias)->VEND"     ,2,1,.F.})
	//AADD(_aColuns,{"NOME VEND."    ,"(_tAlias)->NOMEVEND" ,1,1,.F.})
	// AlteraÁ„o - Fernando Bombardi - ALLSS - 02/03/2022


EndIf

// TRATAMENTO PARA O PAR¬METRO "CNPJ CENTRAL": 1 - TOTALIZA, 2 - APRESENTA, 3 - N√O
If _lEspecific
	If (MV_PAR04) <> 3
		AADD(_aColuns,{"CNPJ_CENT"     ,"(_tAlias)->CNPJCENT" ,2,1,.F.})
		AADD(_aColuns,{"NOME_CENTRAL"  ,"(_tAlias)->NOMECNPJ" ,1,1,.F.})
	EndIf
EndIf

// TRATAMENTO PARA O PAR¬METRO "CLIENTE/LOJA": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR05) <> 1
	AADD(_aColuns,{"CNPJ"          ,"(_tAlias)->CNPJ"     ,2,1,.F.})
	AADD(_aColuns,{"CLIENTE"       ,"(_tAlias)->CLIENTE"  ,2,1,.F.})
	AADD(_aColuns,{"LOJA"          ,"(_tAlias)->LOJA"     ,2,1,.F.})
	AADD(_aColuns,{"NOME"          ,"(_tAlias)->NOME"     ,1,1,.F.})
EndIf

// TRATAMENTO PARA O PAR¬METRO "DOCUMENTO/SERIE": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR08) <> 1
	AADD(_aColuns,{"DOCUMENTO"     ,"(_tAlias)->DOC"      ,1,1,.F.})
	AADD(_aColuns,{"S…RIE"         ,"(_tAlias)->SERIE"    ,1,1,.F.})
EndIf

// TRATAMENTO PARA O PAR¬METRO "TIPO": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR13) <> 1
	AADD(_aColuns,{"TIPO"          ,"(_tAlias)->TIPO"     ,1,1,.F.})
EndIf

// TRATAMENTO PARA O PAR¬METRO "FAMÕLIA": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR14) <> 1
	AADD(_aColuns,{"FAMILIA"       ,"(_tAlias)->FAMILIA"  ,2,1,.F.})
EndIf

// TRATAMENTO PARA O PAR¬METRO "PRODUTO": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR15) <> 1
	AADD(_aColuns,{"PRODUTO"       ,"(_tAlias)->CODIGO"   ,2,1,.F.})
	AADD(_aColuns,{"DESCRI«√O"     ,"(_tAlias)->PRODUTO"  ,1,1,.F.})
	AADD(_aColuns,{"1∞UM"          ,"(_tAlias)->UM"       ,2,1,.F.})
	If _lEspecific
		AADD(_aColuns,{"UM.COM"        ,"(_tAlias)->UMCOM"    ,2,1,.F.})
	EndIf
EndIf

// - TOTAIS
AADD(_aColuns,{"QTD.FAT.(1∞UM)" ,"(_tAlias)->QTDFAT"  ,3,2,.F.})
If _lEspecific
	AADD(_aColuns,{"PESO COM. FAT." ,"(_tAlias)->PCOM"    ,3,2,.F.})
EndIf
AADD(_aColuns,{"QTD.DEV.(1∞UM)" ,"(_tAlias)->QTDDEV"  ,3,2,.F.})
If _lEspecific
	AADD(_aColuns,{"PESO COM.DEV."  ,"(_tAlias)->PCOMDEV" ,3,2,.F.})
EndIf
AADD(_aColuns,{"TOTALFAT"       ,"(_tAlias)->TOTALFAT",3,2,.F.})
AADD(_aColuns,{"TOTALDEV"       ,"(_tAlias)->TOTALDEV",3,2,.F.})
AADD(_aColuns,{"ICMS FAT."      ,"(_tAlias)->ICMFAT"  ,3,2,.F.})
AADD(_aColuns,{"ICMS DEV."      ,"(_tAlias)->ICMDEV"  ,3,2,.F.})
AADD(_aColuns,{"IPI FAT."       ,"(_tAlias)->IPIFAT"  ,3,2,.F.})
AADD(_aColuns,{"IPI DEV."       ,"(_tAlias)->IPIDEV"  ,3,2,.F.})

// - INICIO DA CONSTRU«√O DA CONSULTA NO BANCO

_cSelFat += " SELECT " +_lEnt 
_cSelDev += " SELECT " +_lEnt

// VERIFICA PARAMETRO PARA APRESENTAR COLUNA DA DATA DE EMISS√O: 1 - N√O, 2 - SIM
If (MV_PAR03) == 2
	_cSelFat += " (SUBSTRING(SFD.EMISSAO,7,2) + '/' + SUBSTRING(SFD.EMISSAO,5,2) + '/' + SUBSTRING(SFD.EMISSAO,1,4))[EMISSAO], "          +_lEnt
	_cSelDev += " (SUBSTRING(SD1A.DIGITACAO,7,2) + '/' + SUBSTRING(SD1A.DIGITACAO,5,2) + '/' + SUBSTRING(SD1A.DIGITACAO,1,4))[EMISSAO], " +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " EMISSAO" +_lEnt	
Else
	_cSelFat += " '' [EMISSAO], " +_lEnt
	_cSelDev += " '' [EMISSAO], " +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " EMISSAO" +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "ESTADO": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR06) <> 1
	_cSelFat += " SFD.ESTADO [ESTADO], "                 +_lEnt
	_cSelDev += " SD1A.ESTADOD [ESTADO], "               +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " ESTADO" +_lEnt
Else
	_cSelFat += " '' [ESTADO], "                         +_lEnt
	_cSelDev += " '' [ESTADO], "                         +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " ESTADO" +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "VENDEDOR": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR07) <> 1
	_cSelFat += " SFD.VEND[VEND], SFD.NOMEVEND[NOMEVEND], "      +_lEnt
	_cSelDev += " SD1A.VENDD[VEND], SD1A.NOMEVENDD [NOMEVEND], " +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " VEND, NOMEVEND" +_lEnt
Else
	_cSelFat += " '' [VEND], '' [NOMEVEND], "                    +_lEnt
	_cSelDev += " '' [VEND], '' [NOMEVEND], "                    +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " VEND, NOMEVEND" +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "CNPJ CENTRAL": 1 - TOTALIZA, 2 - APRESENTA, 3 - N√O
If _lEspecific
	If MV_PAR04 <> 3
		_cSelFat += " SFD.CGCCENT[CNPJCENT], SFD.NOMECNPJ[NOMECNPJ], "      +_lEnt
		_cSelDev += " SD1A.CGCCENTD[CNPJCENT], SD1A.NOMECNPJD [NOMECNPJ], " +_lEnt
		_SelCpos += IIf(Empty(_SelCpos),"",",") + " CNPJCENT, NOMECNPJ "    +_lEnt
	Else
		_cSelFat += " '' [CNPJCENT], '' [NOMECNPJ], "                       +_lEnt
		_cSelDev += " '' [CNPJCENT], '' [NOMECNPJ], "                       +_lEnt
		_SelCpos += IIf(Empty(_SelCpos),"",",") + " CNPJCENT, NOMECNPJ"     +_lEnt
	EndIf
EndIf

// TRATAMENTO PARA O PAR¬METRO "CLIENTE/LOJA": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR05) <> 1
	_cSelFat += " SFD.CGC[CNPJ], SFD.CLIENTE[CLIENTE], SFD.LOJA[LOJA], SFD.NOME[NOME], "       +_lEnt
	_cSelDev += " SD1A.CGCD [CNPJ],SD1A.CLIENTED[CLIENTE],SD1A.LOJAD[LOJA],SD1A.NOMED[NOME], " +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " CNPJ, CLIENTE, LOJA, NOME"                    +_lEnt
Else
	_cSelFat += " '' [CNPJ], '' [CLIENTE], '' [LOJA], '' [NOME], "          +_lEnt
	_cSelDev += " '' [CNPJ], '' [CLIENTE], '' [LOJA], '' [NOME], "          +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " CNPJ, CLIENTE, LOJA, NOME" +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "DOCUMENTO/SERIE": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR08) <> 1
	_cSelFat += " SFD.DOC[DOC], SFD.SERIE[SERIE], "          +_lEnt
	_cSelDev += " '' [DOC], '' [SERIE], "                    +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " DOC, SERIE" +_lEnt
Else
	_cSelFat += " '' [DOC], '' [SERIE], "                    +_lEnt
	_cSelDev += " '' [DOC], '' [SERIE], "                    +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " DOC, SERIE" +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "TIPO": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR13) <> 1
	_cSelFat += " SFD.TIPO[TIPO], "                    +_lEnt
	_cSelDev += " SD1A.TIPOD [TIPO], "                 +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " TIPO" +_lEnt
Else
	_cSelFat += " '' [TIPO], "                         +_lEnt
	_cSelDev += " '' [TIPO], "                         +_lEnt		
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " TIPO" +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "FAMÕLIA": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR14) <> 1
	_cSelFat += " SFD.FAMILIA[FAMILIA], "                 +_lEnt
	_cSelDev += " SD1A.FAMILIAD [FAMILIA], "              +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " FAMILIA" +_lEnt
Else
	_cSelFat += " '' [FAMILIA], "                         +_lEnt
	_cSelDev += " '' [FAMILIA], "                         +_lEnt
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " FAMILIA" +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "PRODUTO": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR15) <> 1
	_cSelFat += " SFD.CODIGO [CODIGO], SFD.DESCRI [PRODUTO], SFD.UM[UM],"     +_lEnt
	If _lEspecific
		_cSelFat += " SFD.UMCOM[UMCOM],"                                      +_lEnt
	EndIf
	_cSelDev += " SD1A.CODIGOD[CODIGO], SD1A.DESCRID[PRODUTO], SD1A.UMD[UM]," +_lEnt
	If _lEspecific
		_cSelDev += " SD1A.UMCOMERD[UMCOM],"                                  +_lEnt
	EndIf
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " CODIGO, PRODUTO, UM"         +_lEnt
	If _lEspecific
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " UMCOM"                   +_lEnt
	EndIf
Else
	_cSelFat += " '' [CODIGO], '' [PRODUTO], '' [UM], "                +_lEnt
	If _lEspecific
		_cSelFat += " '' [UMCOM],"                                     +_lEnt
	EndIf
	_cSelDev += " '' [CODIGO], '' [PRODUTO], '' [UM], "                +_lEnt
	If _lEspecific
		_cSelDev += " '' [UMCOM],"                                     +_lEnt
	EndIf	
	_SelCpos += IIf (Empty(_SelCpos),"",",") + " CODIGO, PRODUTO, UM" +_lEnt
	If _lEspecific
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " UMCOM"            +_lEnt
	EndIf
EndIf

// TRATAMENTO PARA O TIPO DE SELE«√O QUANTO AO TIPO DE APROPRIA«√O DAS DEVOLU«’ES
If (MV_PAR16) == 1
// - DATA DA DEVOLU«√O
	// - FATURAMENTO
	_cSelFat += " SUM(SFD.QTDFAT)[QTDFAT],        0 [QTDDEV], "              +_lEnt
	If _lEspecific
		_cSelFat += " SUM(SFD.QTDFAT*SFD.PCOM)[PCOM], 0 [PCOMDEV], "         +_lEnt
	EndIf
    // moeda
	If _cMoeda == '1'
		_cSelFat += " SUM(SFD.TOTALFAT)[TOTALFAT],0 [TOTALDEV], " +_lEnt
		_cSelFat += " SUM(SFD.ICMFAT)[ICMFAT], 0 [ICMDEV], " +_lEnt
		_cSelFat += " SUM(SFD.IPIFAT)[IPIFAT], 0 [IPIDEV] " +_lEnt
	Else	
		_cSelFat += " SUM(SFD.TOTALFAT * SM2.M2_MOEDA"+_cMoeda+")[TOTALFAT], 0 [TOTALDEV], " +_lEnt
		_cSelFat += " SUM(SFD.ICMFAT   * SM2.M2_MOEDA"+_cMoeda+")[ICMFAT]  , 0 [ICMDEV], " +_lEnt
		_cSelFat += " SUM(SFD.IPIFAT   * SM2.M2_MOEDA"+_cMoeda+")[IPIFAT]  , 0 [IPIDEV] " +_lEnt
	EndIf
	
	// - DEVOLU«’ES
	_cSelDev += " 0 [QTDFAT],   SUM(SD1A.QUANTD)[QTDDEV], "                  +_lEnt
	If _lEspecific
		_cSelDev += " 0 [PCOM],     SUM (SD1A.QUANTD * SD1A.PCOMERCD)[PCOMDEV]," +_lEnt
	EndIf
    // moeda
	If _cMoeda == '1'
		_cSelDev += " 0 [TOTALFAT], SUM(SD1A.TOTDEV)[TOTALDEV]," +_lEnt
		_cSelDev += " 0 [ICMFAT],   SUM(SD1A.ICMDEV)[ICMDEV]," +_lEnt
		_cSelDev += " 0 [IPIFAT],   SUM(SD1A.IPIDEV)[IPIDEV]" +_lEnt
	Else
		_cSelDev += " 0 [TOTALFAT], SUM(SD1A.TOTDEV * SM2.M2_MOEDA"+_cMoeda+")[TOTALDEV]," +_lEnt
		_cSelDev += " 0 [ICMFAT],   SUM(SD1A.ICMDEV * SM2.M2_MOEDA"+_cMoeda+")[ICMDEV]," +_lEnt
		_cSelDev += " 0 [IPIFAT],   SUM(SD1A.IPIDEV * SM2.M2_MOEDA"+_cMoeda+")[IPIDEV]" +_lEnt
	EndIf
	// - TOTAIS
	_SumCpos += +_lEnt + " ,"
	_SumCpos +=	" SUM(QTDFAT)[QTDFAT],     SUM(QTDDEV)[QTDDEV], " +_lEnt

	If _lEspecific
		_SumCpos += " SUM(PCOM)[PCOM],         SUM(PCOMDEV)[PCOMDEV], " +_lEnt
	EndIf
    // moeda
	If _cMoeda == '1'
		_SumCpos += " SUM(TOTALFAT)[TOTALFAT], SUM(TOTALDEV)[TOTALDEV], " +_lEnt
		_SumCpos += " SUM(ICMFAT)[ICMFAT],     SUM(ICMDEV)[ICMDEV], " +_lEnt
		_SumCpos += " SUM(IPIFAT)[IPIFAT],     SUM(IPIDEV)[IPIDEV] " +_lEnt
	Else
		_SumCpos += " SUM(TOTALFAT)[TOTALFAT], SUM(TOTALDEV)[TOTALDEV], " +_lEnt
		_SumCpos += " SUM(ICMFAT)[ICMFAT],     SUM(ICMDEV)[ICMDEV], " +_lEnt
		_SumCpos += " SUM(IPIFAT)[IPIFAT],     SUM(IPIDEV)[IPIDEV] " +_lEnt
	EndIf
Else
// - DATA DO FATURAMENTO
	_cSelFat += " SUM(SFD.QTDFAT)[QTDFAT], SUM(SFD.QTDDEV)[QTDDEV], "                      +_lEnt

	If _lEspecific
		_cSelFat += " SUM(SFD.QTDFAT*SFD.PCOM)[PCOM], SUM(SFD.QTDDEV*SFD.PCOMDEV)[PCOMDEV], "  +_lEnt
	EndIf
    // moeda
	If _cMoeda == '1'
		_cSelFat += " SUM(SFD.TOTALFAT)[TOTALFAT], SUM(SFD.TOTALDEV)[TOTALDEV], "              +_lEnt
		_cSelFat += " SUM(SFD.ICMFAT)[ICMFAT], SUM(SFD.ICMDEV)[ICMDEV], "                      +_lEnt
		_cSelFat += " SUM(SFD.IPIFAT)[IPIFAT], SUM(SFD.IPIDEV)[IPIDEV]  "                      +_lEnt
	Else
		_cSelFat += " SUM(SFD.TOTALFAT * SM2.M2_MOEDA"+_cMoeda+")[TOTALFAT], SUM(SFD.TOTALDEV * SM2.M2_MOEDA"+_cMoeda+")[TOTALDEV], " +_lEnt
		_cSelFat += " SUM(SFD.ICMFAT * SM2.M2_MOEDA"+_cMoeda+")[ICMFAT], SUM(SFD.ICMDEV * SM2.M2_MOEDA"+_cMoeda+")[ICMDEV], " +_lEnt
		_cSelFat += " SUM(SFD.IPIFAT * SM2.M2_MOEDA"+_cMoeda+")[IPIFAT], SUM(SFD.IPIDEV * SM2.M2_MOEDA"+_cMoeda+")[IPIDEV]  " +_lEnt
	EndIf
EndIf

// - SELE«√O DA ORIGEM
_cQryFat += " FROM SFD_"+cNumEmp+"_001 SFD "                                  +_lEnt
_cQryFat += "    INNER JOIN " + RetSqlName("SA1") + " SA1 "                   +_lEnt
_cQryFat += " 	    ON SA1.D_E_L_E_T_ = '' "                                  +_lEnt
_cQryFat += " 	    AND SA1.A1_MARK <> '' "                                   +_lEnt
_cQryFat += "	    AND SA1.A1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "%' " +_lEnt
_cQryFat += "    INNER JOIN " + RetSqlName("SB1") + " SB1 "                   +_lEnt
_cQryFat += " 	    ON SB1.D_E_L_E_T_ = '' "                                  +_lEnt
_cQryFat += " 	    AND SB1.B1_MARK <> '' "                                   +_lEnt
_cQryFat += "	    AND SB1.B1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "%' " +_lEnt
//Moeda
If _cMoeda <> '1'
	_cQryFat += "    INNER JOIN " + RetSqlName("SM2") + " SM2 " +_lEnt
	_cQryFat += "    ON SM2.M2_DATA = '"+DTOS(MV_PAR18)+"' "    +_lEnt
	_cQryFat += "    AND SM2.D_E_L_E_T_ = '' "
EndIf

_cQryDev += " FROM SD1_"+cNumEmp+"_002 SD1A "                                 +_lEnt
_cQryDev += "    INNER JOIN " + RetSqlName("SA1") + " SA1 "                   +_lEnt
_cQryDev += " 	    ON SA1.D_E_L_E_T_ = '' "                                  +_lEnt
_cQryDev += " 	    AND SA1.A1_MARK <> '' "                                   +_lEnt
_cQryDev += "	    AND SA1.A1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "%' " +_lEnt
_cQryDev += "    INNER JOIN " + RetSqlName("SB1") + " SB1 "                   +_lEnt
_cQryDev += " 	    ON SB1.D_E_L_E_T_ = '' "                                  +_lEnt
_cQryDev += " 	    AND SB1.B1_MARK  <> '' "                                  +_lEnt
_cQryDev += "	    AND SB1.B1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "%' " +_lEnt
// Moeda
If _cMoeda <> '1'
	_cQryDev += "    INNER JOIN " + RetSqlName("SM2") + " SM2 " +_lEnt
	_cQryDev += "    ON SM2.M2_DATA = '"+DTOS(MV_PAR18)+"' "    +_lEnt
	_cQryDev += "    AND SM2.D_E_L_E_T_ = '' "
EndIf

// - WHERE
_cQryFat += " WHERE " +_lEnt
_cQryDev += " WHERE " +_lEnt

// - EMISSAO
_cQryFat += " SFD.EMISSAO    BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " +_lEnt
_cQryDev += " SD1A.DIGITACAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " +_lEnt

// - FAZ A AMARRA«√O DOS CLIENTES MARCADOS E A TABELA DA VIEW
// - DOCUMENTOS DE SAÕDA
_cQryFat += " AND SFD.CGCCENT = SA1.A1_CGCCENT " +_lEnt
_cQryFat += " AND SFD.CLIENTE = SA1.A1_COD "     +_lEnt
_cQryFat += " AND SFD.LOJA    = SA1.A1_LOJA "    +_lEnt
_cQryFat += " AND SFD.CODIGO  = SB1.B1_COD "     +_lEnt

// - SELECIONA DOCUMENTO E SERIE
If MV_PAR08 <> 1
	If !Empty (MV_PAR11)
		_cQryFat += " AND SFD.DOC BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR11 + "' "            +_lEnt
	Else
		_cQryFat += " AND SFD.DOC BETWEEN '' AND '" + Replicate("Z",TamSx3("F2_DOC")[01]) + "' " +_lEnt
	EndIf
	If !Empty (MV_PAR12)
		_cQryFat += " AND SFD.SERIE BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR12 + "' "              +_lEnt
	Else
		_cQryFat += " AND SFD.SERIE BETWEEN '' AND '" + Replicate("Z",TamSx3("F2_SERIE")[01]) + "' " +_lEnt
	EndIf
EndIf

// - DOCUMENTOS DE ENTRADA
_cQryDev += " AND SD1A.CGCCENTD = SA1.A1_CGCCENT " +_lEnt
_cQryDev += " AND SD1A.CLIENTED = SA1.A1_COD "     +_lEnt
_cQryDev += " AND SD1A.LOJAD    = SA1.A1_LOJA "    +_lEnt
_cQryDev += " AND SD1A.CODIGOD  = SB1.B1_COD "     +_lEnt

// - AGRUPAMENTO DAS INFORMA«’ES

_cGroup  += " GROUP BY " +_lEnt

// VERIFICA PARAMETRO PARA APRESENTAR COLUNA DA DATA DE EMISS√O: 1 - N√O, 2 - SIM
If (MV_PAR03) == 2
	_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " EMISSAO "   +_lEnt
	_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " DIGITACAO " +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "VENDEDOR": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR07) <> 1
	_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " VEND, NOMEVEND "   +_lEnt
	_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " VENDD, NOMEVENDD " +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "CGC CENTRAL": 1 - TOTALIZA, 2 - APRESENTA, 3 - N√O
If _lEspecific
	If (MV_PAR04) <> 3
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " CGCCENT, NOMECNPJ "   +_lEnt
		_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " CGCCENTD, NOMECNPJD " +_lEnt
	EndIf
EndIf

// TRATAMENTO PARA O PAR¬METRO "CLIENTE/LOJA": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR05) <> 1
	_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " CGC, CLIENTE, LOJA, NOME "     +_lEnt
	_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " CGCD, CLIENTED, LOJAD, NOMED " +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "ESTADO": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR06) <> 1
	_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " ESTADO "  +_lEnt
	_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " ESTADOD " +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "DOCUMENTO/SERIE": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR08) <> 1
	_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " DOC, SERIE " +_lEnt
//	_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " " +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "TIPO": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR13) <> 1
	_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " TIPO "  +_lEnt
	_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " TIPOD " +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "FAMILIA": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR14) <> 1
	_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " FAMILIA "  +_lEnt
	_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " FAMILIAD " +_lEnt
EndIf

// TRATAMENTO PARA O PAR¬METRO "PRODUTO": 1 - N√O, 2 - TOTALIZA, 3 - APRESENTA
If (MV_PAR15) <> 1
	_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " CODIGO,DESCRI,UM"    +_lEnt
	If _lEspecific
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " UMCOM"           +_lEnt
	EndIf
	_cGrpDev += IIf (Empty(_cGrpdev),"",",") + " CODIGOD,DESCRID,UMD" +_lEnt
	If _lEspecific
		_cGrpDev += IIf (Empty(_cGrpdev),"",",") + " UMCOMERD"        +_lEnt
	EndIf
EndIf      
IIf (Empty(_cGrpFat),_cGroup := "",_cGroup)
IIf (Empty(_cGrpDev),_cGroup := "",_cGroup)

// - ORDENA«√O DAS INFORMA«’ES
_cOrd := " ORDER BY "

If (MV_PAR03) == 2
	_cOrder := " EMISSAO " +_lEnt
EndIf

//CRIA«√O DA ORDEM DEFINIDA PELO USU¡RIO ATRAV…S DE PAR¬METROS
For _k := 1 To Len(_aSbTtt)
	_cOrder += IIf (Empty(_cOrder),"",",") + _aSbTtt[_k][06] +_lEnt
Next

// - AGRUPA AS QUERYS FORMADAS DE ACORDO COM O TIPO DE APROPRIA«√O DAS DEVOLU«’ES
If (MV_PAR16) == 1
	_cQuery  := " SELECT " +_lEnt

	// - QUERY DOS CAMPOS A SEREM APRESENTADOS
	_cQuery  += _SelCpos + _SumCpos

	// - MONTAGEM DA QUERY PRINCIPAL
	_cQuery  += " FROM ( " +_lEnt

	// - QUERY DA TABELA DE FATURAMENTO
	_cQuery  += _cSelFat + _cQryFat + _cGroup + _cGrpFat

	// - UNION ALL
	_cQuery  += _lEnt + " UNION ALL " +_lEnt +_lEnt

	// - QUERY DA TABELA DE DEVOLU«’ES
	_cQuery  += _cSelDev + _cQryDev + _cGroup + _cGrpDev + _cOrdDev
	_cQuery  += "       ) AMBOS " +_lEnt

	// - AGRUPAMENTO
	_cQuery  +=	" GROUP BY " + _SelCpos

	// - ORDENA«√O
	_cQuery  +=	" ORDER BY " + _cOrder
Else
	_cQuery  := _cSelFat + _cQryFat + _cGroup + _cGrpFat + _cOrd +_cOrder
EndIf

// - GRAVA A QUERY EM UMA ARQUIVO TEXTO PARA AN¡LISE.
//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.TXT",_cQuery)

// - SE FOR ADMINISTRADOR VERIFICA SE CONTINUA O RELAT”RIO
If __cUserID == '000000|000154|000155|000156'
	If MsgYesNo("Deseja cancelar a emiss„o do relatÛrio?",_cRotina+"_001C")
		Return()
	EndIf
EndIf

// - VERIFICA SE FOI GERADA ALGUMA QUERY PARA PROSSEGUIR
If (Len(_cQuery) ) >0
	_cQuery := ChangeQuery(_cQuery)
Else
	MSGBOX('N√O FOI POSSÕVEL GERAR A CONSULTA. INFORME O ADMINISTRADOR DO SISTEMA','','STOP')
	Return()	
EndIf

// - GERA A QUERY FORMADA
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_tAlias,.T.,.F.)

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ Geraxls  ∫Autor  ≥ J˙lio Soares       ∫ Data ≥  15/01/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o respons„vel por gerar a planilha conforme dados     ∫±±
±±∫          ≥ obtidos da consulta formada de acordo com par‚metros       ∫±±
±±∫          ≥ inseridos pelo usu·rio.                                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function Geraxls(lEnd)

Local oExcel
Local _cTmpFile := ""
Local _cSheet1  := (DTOC(mv_par01)) + " ~ " + (DTOC(mv_par02))
Local _cSheet2  := 'PAR¬METROS'

//Local _cFileTMP  := cGetFile ('Arquivo Arquivo XML|*.xml','Salvar arquivo',0,'C:\Dir\',.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.) //Define o local onde o arquivo ser· gerado
Local _cFileTMP  := cGetFile ('Arquivo XML|*.xml','Salvar Arquivo',0,'C:\',.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.,.F.)
	// - cMascara     - Caracter Indica o nome do arquivo ou m·scara.   
	// - cTitulo      - Caracter Indica o tÌtulo da janela. Caso o par‚metro n„o seja especificado, o tÌtulo padr„o ser· apresentado.   
	// - nMascpadrao  - NumÈrico Indica o n˙mero da m·scara.   
	// - cDirinicial  - Caracter Indica o diretÛrio inicial.   
	// - lSalvar      - LÛgico Indica se È um "save dialog" ou um "open dialog".   
	// - nOpcoes      - NumÈrico Indica a opÁ„o de funcionamento. Para mais informaÁıes das funcionalidades disponÌveis, consulte a ·rea ObservaÁıes.   
	// - lArvore      - LÛgico Indica se, verdadeiro (.T.), apresenta o ·rvore do servidor; caso contr·rio, falso (.F.).   
	// - lKeepCase    - LÛgico Indica se, verdadeiro (.T.), mantÈm o case original; caso contr·rio, falso (.F.). 

Local _cFile    := ""
Private _aPar   := {}
Private _cAliasSX1 := ""

Private _bPAR := "Type(_aSbTtt[_nTpST][03])"

If __cUserID == '000000|000154|000155|000156'
	If MsgYesNo("Deseja cancelar a geraÁ„o em excel?",_cRotina+"_001D")
		Return()
	EndIf
EndIf

dbSelectArea(_tAlias)
ProcRegua(((_tAlias)->(RecCount())*2)+1)
(_tAlias)->(dbGoTop())
If !(_tAlias)->(EOF())
	oExcel := FWMSEXCEL():New()
	oExcel:AddWorkSheet(_cSheet1)
	oExcel:AddTable(_cSheet1,_cTitulo)
	For _x := 1 To Len(_aColuns)
		oExcel:AddColumn(_cSheet1,_cTitulo,_aColuns[_x][01],_aColuns[_x][03],_aColuns[_x][04],_aColuns[_x][05])
	Next

	// - EXECUTA A REORDENA«√O DA SUB-TOTALIZA«√O PARA APRESENTAR NO EXCEL A ORDEM SELECIONADA PELO CLIENTE
	_aSbTtt := aSort(_aSbTtt,,, { |x,y| x[07] > y[07] } )

	// - ACRESCENTA AS LINHAS COM INFORMA«’ES WHILE ! TEMP ->(EOF())
	While !(_tAlias)->(EOF()) .AND. !lEnd

		If (MV_PAR15) <> 1
			IncProc('PROCESSANDO RELATORIO: '     +_lEnt + AllTrim((_tAlias)->NOME)     + '.')
		ElseIf (MV_PAR07) <> 1
			IncProc('PROCESSANDO REPRESENTANTE: ' +_lEnt + AllTrim((_tAlias)->NOMEVEND) + '.')
		ElseIf (MV_PAR04) <> 3
			IncProc('PROCESSANDO CNPJ CENTRAL: '  +_lEnt + AllTrim((_tAlias)->CNPJCENT) + '.')
		ElseIf (MV_PAR05) <> 1
			IncProc('PROCESSANDO CLIENTE: '       +_lEnt + AllTrim((_tAlias)->NOME)     + '.')
		ElseIf (MV_PAR15) <> 1
			IncProc('PROCESSANDO PRODUTO: '       +_lEnt + AllTrim((_tAlias)->PRODUTO)  + '.')
		EndIf

		// TRECHO PARA IMPRESS√O DOS SUB-TOTAIS
		For _sT := 1 To Len(_aSbTtt)
			If _aSbTtt[_sT][08]
				_nReg  := 0
				_aAux  := ARRAY(Len(_aColuns))
				For _k := 1 To Len(_aSbTtt[_sT][02])
					If AllTrim(&(_aSbTtt[_sT][03])) <> AllTrim(_aSbTtt[_sT][02][_k][03])
						_nReg++
						_aAux[01]                       := _aSbTtt[_sT][04] + AllTrim(_aSbTtt[_sT][02][_k][04])
						_aAux[_aSbTtt[_sT][02][_k][01]] := _aSbTtt[_sT][02][_k][02]
						_aSbTtt[_sT][02][_k][02]        := 0
						_aSbTtt[_sT][02][_k][03]        := ""
						_aSbTtt[_sT][02][_k][04]        := ""
					EndIf
				Next
				If _nReg > 0
					oExcel:AddRow(_cSheet1, _cTitulo, _aAux )
				EndIf
			EndIf
		Next

		// - TRECHO PARA IMPRESS√O DAS LINHAS
		_aAux := {}

		// - GERA AS COLUNAS DE ACORDO COM A QUERY MONTADA
		For _x := 1 To Len(_aColuns)

			// - COLETA AS INFORMA«’ES ANALÕTICAS PARA GERAR AS SOMAS
			AADD(_aAux, &(_aColuns[_x][02]))

			// - ¡REA DOS TOTAIS E SUB-TOTAIS
			If ValType(&(_aColuns[_x][02]))=="N"

				// - VALOR DOS TOTAIS CONFORME PAR¬METROS
				_nPColN := aScan(_aTtt, {|k| k[01] == _x})
				If _nPColN == 0
					AADD(_aTtt,{_x,&(_aColuns[_x][02])})
				Else
					_aTtt[_nPColN][02] += &(_aColuns[_x][02])
				EndIf

				// - VALOR DOS SUB-TOTAIS CONFORME PAR¬METROS
				For _nTpST := 1 To Len(_aSbTtt)
					If _aSbTtt[_nTpST][08] .AND. &(_bPAR) <> "U"
						_nPColN := aScan(_aSbTtt[_nTpST][02], {|k| k[01] == _x})
						If _nPColN == 0
							AADD(_aSbTtt[_nTpST][02],{_x,&(_aColuns[_x][02]),&(_aSbTtt[_nTpST][03]),&(_aSbTtt[_nTpST][05])})
						Else
							_aSbTtt[_nTpST][02][_nPColN][02] += &(_aColuns[_x][02])
							_aSbTtt[_nTpST][02][_nPColN][03] := &(_aSbTtt[_nTpST][03])
							_aSbTtt[_nTpST][02][_nPColN][04] := &(_aSbTtt[_nTpST][05])
						EndIf
					EndIf
				Next
			EndIf
		Next
		oExcel:AddRow(_cSheet1, _cTitulo, _aAux )

		(_tAlias)->(dbSkip())
	EndDo

	If lEnd
		Alert("Abortado!")
		FreeObj(oExcel)
		oExcel := NIL
		Return
	EndIf

	// - TRECHO RESPONS¡VEL PELA IMPRESS√O DOS SUB-TOTAIS
	For _sT := 1 To Len(_aSbTtt)
		_nReg  := 0
		_aAux  := ARRAY(Len(_aColuns))
		For _k := 1 To Len(_aSbTtt[_sT][02])
			If AllTrim(&(_aSbTtt[_sT][03])) <> AllTrim(_aSbTtt[_sT][02][_k][03])
				_nReg++
				_aAux[01]                       := _aSbTtt[_sT][04] + AllTrim(_aSbTtt[_sT][02][_k][04])
				_aAux[_aSbTtt[_sT][02][_k][01]] := _aSbTtt[_sT][02][_k][02]
				_aSbTtt[_sT][02][_k][02]        := 0
				_aSbTtt[_sT][02][_k][03]        := ""
				_aSbTtt[_sT][02][_k][04]        := ""
			EndIf
		Next
		If _nReg > 0
			oExcel:AddRow(_cSheet1, _cTitulo, _aAux )
		EndIf
	Next

	// - TRECHO RESPONS¡VEL PELA IMPRESS√O DOS TOTAIS
	_aAux    := ARRAY(Len(_aColuns))
	_aAux[1] := "TOTAL GERAL "
	For _k := 1 To Len(_aTtt)
		_aAux[_aTtt[_k][01]] := _aTtt[_k][02]
	Next
	oExcel:AddRow(_cSheet1, _cTitulo, _aAux )

	// - TRECHO RESPONS¡VEL PELA INSER«√O DE UMA ABA COM AS INFORMA«’ES DOS PARAMETROS
	oExcel:AddWorkSheet(_cSheet2)
	oExcel:AddTable(_cSheet2,_cTitulo2)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRI«√O" ,1,1,.F.)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTE⁄DO"  ,1,1,.F.)

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	(_cAliasSX1)->(dbGoTop())

	_cPerg := PADR(_cPerg,10)

	If (_cAliasSX1)->(dbSeek(_cPerg))
		While !EOF() .And. (_cAliasSX1)->X1_GRUPO == _cPerg
			IncProc('PROCESSANDO PARAMETROS...')
			If AllTrim((_cAliasSX1)->X1_GSC)=="C"
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&("(_cAliasSX1)->X1_DEF"+StrZero(&((_cAliasSX1)->X1_VAR01),2)) })
			Else
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
			EndIf
			dbSelectArea((_cAliasSX1))
			dbSetOrder(1)
			dbSkip()
		EndDo
	EndIf
	If Len(_aPar) > 0
		For _nPosPar := 1 To Len(_aPar)
			oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
		Next
	EndIf

	// - IMPRIME O RELAT”RIO NO EXCEL
	IncProc("GERANDO ARQUIVO.")
		If !Empty(_cFileTMP)
			If !(".XML" $ Upper(_cFileTMP))
				_cFileTmp := StrTran(_cFileTmp,'.','')
				_cFileTmp += ".xml"
			EndIf
		EndIf
		oExcel:Activate()
		_cFile := (CriaTrab(NIL, .F.) + ".xml")
				
		While File(_cFile)
			_cFile := (CriaTrab(NIL, .F.) + ".xml")
		EndDo
		oExcel:GetXMLFile(_cFile)
		oExcel:DeActivate()
		If !(File(_cFile))
			_cFile := ""
			Break
		EndIf
		
		// - TRATAMENTO PARA QUE O RELAT”RIO SEJA SALVO NA PASTA "TEMP" NO COMPUTADOR QUANDO UM LOCAL N√O … DEFINIDO
		If Empty(_cFileTMP)
			_cFileTMP := (GetTempPath() + _cFile)
		EndIf
		
		If !(__CopyFile(_cFile , _cFileTMP))
			MsgStop("AtenÁ„o! N„o foi possÌvel salvar o arquivo no caminho " + _cFileTMP + ". Portanto, a rotina tentar· salvar o arquivo no seguinte caminho: " + (GetTempPath() + _cFile),_cRotina+"_011A")
			_cFileTMP := (GetTempPath() + _cFile)
			If !(__CopyFile(_cFile , _cFileTMP))
				fErase( _cFile )
				_cFile := ""
				Break
			EndIf
		EndIf

		fErase(_cFile)
		_cFile := _cFileTMP

		If !(File(_cFile))
			_cFile := ""
			Break
		EndIf

		IncProc('ABRINDO ARQUIVO.' + _cFile)
		oMsExcel:= MsExcel():New()
		oMsExcel:WorkBooks:Open(_cFile)
		oMsExcel:SetVisible(.T.)
		
		IncProc('RELAT”RIO GERADO COM SUCESSO!')
		MsgBox('O arquivo foi salvo no local '+ _cFile +'.',_cRotina+"_010",'INFO')
		oMsExcel:= oMsExcel:Destroy()
Else
	MSGBOX('N„o h· dados a serem apresentados. Verifique os par‚metros informados. ',_cRotina+'_011B','ALERT')
	Return()
EndIf

FreeObj(oExcel)
oExcel := NIL

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ SelOrd   ∫Autor  ≥ J˙lio Soares      ∫ Data ≥  10/06/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Monta uma tela para a seleÁ„o da ordem das sub-totalizaÁıes∫±±
±±∫          ≥ a serem apresentadas no relatÛrio.                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function SelOrd()

Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oGroup1
Local oButton1
Local oListBox1
Local oListBox2
Local oListBox3
Local oListBox4
Local oListBox5
Local oListBox6
Local oListBox7
Local oListBox8

// AlteraÁ„o - Fernando Bombardi - ALLSS - 03/03/2022
//Local _aOpc     := {"ESTADO","VENDEDOR","CNPJ CENTRALIZADOR","CLIENTE","DOCUMENTO","TIPO","FAMILIA","PRODUTO"}
Local _aOpc     := {"ESTADO","REPRESENTANTE","CNPJ CENTRALIZADOR","CLIENTE","DOCUMENTO","TIPO","FAMILIA","PRODUTO"}
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

nListBox1       := "ESTADO"

// AlteraÁ„o - Fernando Bombardi - ALLSS - 03/03/2022
//nListBox2       := "VENDEDOR"
nListBox2       := "REPRESENTANTE"
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

nListBox3       := "CNPJ CENTRALIZADOR"
nListBox4       := "CLIENTE"
nListBox5       := "DOCUMENTO"
nListBox6       := "TIPO"
nListBox7       := "FAMILIA"
nListBox8       := "PRODUTO"

Static oDlg

  DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] ORDEM" FROM 000, 000  TO 450, 330 COLORS 0, 16777215 PIXEL

	@ 005, 005 GROUP oGroup1 TO 190, 160 PROMPT " Selecione a Ordem para os Registros no RelatÛrio " OF oDlg COLOR 0, 16777215 PIXEL

	@ 025, 015 SAY oSay1 PROMPT "Ordem 1:"                    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 025, 045 MSCOMBOBOX oListBox1 VAR nListBox1 ITEMS _aOpc SIZE 095, 015 OF oDlg COLORS 0, 16777215 PIXEL

	@ 045, 015 SAY oSay2 PROMPT "Ordem 2:"                    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045, 045 MSCOMBOBOX oListBox2 VAR nListBox2 ITEMS _aOpc SIZE 095, 015 OF oDlg COLORS 0, 16777215 PIXEL

	@ 065, 015 SAY oSay3 PROMPT "Ordem 3:"                    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 065, 045 MSCOMBOBOX oListBox3 VAR nListBox3 ITEMS _aOpc SIZE 095, 015 OF oDlg COLORS 0, 16777215 PIXEL

	@ 085, 015 SAY oSay4 PROMPT "Ordem 4:"                    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 085, 045 MSCOMBOBOX oListBox4 VAR nListBox4 ITEMS _aOpc SIZE 095, 015 OF oDlg COLORS 0, 16777215 PIXEL
    
	@ 105, 015 SAY oSay5 PROMPT "Ordem 5:"                    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 105, 045 MSCOMBOBOX oListBox5 VAR nListBox5 ITEMS _aOpc SIZE 095, 015 OF oDlg COLORS 0, 16777215 PIXEL
    
	@ 125, 015 SAY oSay6 PROMPT "Ordem 6:"                    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 125, 045 MSCOMBOBOX oListBox6 VAR nListBox6 ITEMS _aOpc SIZE 095, 015 OF oDlg COLORS 0, 16777215 PIXEL

	@ 145, 015 SAY oSay7 PROMPT "Ordem 7:"                    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 145, 045 MSCOMBOBOX oListBox7 VAR nListBox7 ITEMS _aOpc SIZE 095, 015 OF oDlg COLORS 0, 16777215 PIXEL

	@ 165, 015 SAY oSay8 PROMPT "Ordem 8:"                    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 165, 045 MSCOMBOBOX oListBox8 VAR nListBox8 ITEMS _aOpc SIZE 095, 015 OF oDlg COLORS 0, 16777215 PIXEL

    @ 200, 120 BUTTON oButton1 PROMPT "&Confirma"             SIZE 035, 015 OF oDlg PIXEL ACTION Close(oDlg)

  ACTIVATE MSDIALOG oDlg CENTERED

	nListBox1 := aScan(_aOpc,nListBox1)
	nListBox2 := aScan(_aOpc,nListBox2)
	nListBox3 := aScan(_aOpc,nListBox3)
	nListBox4 := aScan(_aOpc,nListBox4)
	nListBox5 := aScan(_aOpc,nListBox5)
	nListBox6 := aScan(_aOpc,nListBox6)
	nListBox7 := aScan(_aOpc,nListBox7)
	nListBox8 := aScan(_aOpc,nListBox8)

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ ValidPerg ∫ Autor ≥J˙lio Soares         ∫ Data ≥  14/07/14 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ FunÁ„o respons·vel pela inclus„o de par‚metros na rotina.  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function ValidPerg()

Local _aSArea  := GetArea()
Local aHelpPor := {}
//Local aHelpSpa := {}
//Local aHelpEng := {}

_cPerg := PADR(_cPerg,10)

// - 01
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Insira a data inicial da emiss„o dos "   )
AAdd(aHelpPor,"documentos."                             )
PutSx1(_cPerg,"01","Data inicial?"             ,"" ,"" ,"mv_ch1","D" ,08                      ,0 ,0 ,"G" ,"NAOVAZIO()",""    ,"" ,"S" ,"mv_par01" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Insira a data inicial da emiss„o dos documentos."
U_RGENA001(_cPerg, "01" ,"Data inicial?" , "MV_PAR01", "MV_CH1", "D", 08, 00, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 02
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Insira a data final da emiss„o dos "     )
AAdd(aHelpPor,"documentos."                             )
PutSx1(_cPerg,"02","Data final?"               ,"" ,"" ,"mv_ch2","D" ,08                      ,0 ,0 ,"G" ,"NAOVAZIO()",""    ,"" ,"S" ,"mv_par02" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Insira a data final da emiss„o dos documentos."
U_RGENA001(_cPerg, "02" ,"Data final?" , "MV_PAR02", "MV_CH2", "D", 08, 00, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


// - 03
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Selecione SIM ou NAO para que a coluna " )
AAdd(aHelpPor,"das datas seja apresentada no relatÛrio.")
PutSx1(_cPerg,"03","Imprime data emiss„o?"     ,"" ,"" ,"mv_ch3","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par03" ,"Nao"         ,"" ,"" ,"" ,"Sim"            ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Nao"
_cDef02   := "Sim"
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione SIM ou NAO para que a coluna das datas seja apresentada no relatÛrio."
U_RGENA001(_cPerg, "03" ,"Imprime data emiss„o?" , "MV_PAR03", "MV_CH3", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


// - 04
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Selecione NAO para que a coluna n„o seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"04","CNPJ-Central?"             ,"" ,"" ,"mv_ch4","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par04" ,"Totaliza"    ,"" ,"" ,"" ,"Apresenta"      ,"" ,"" ,"Nao"       ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Totaliza"
_cDef02   := "Apresenta"
_cDef03   := "Nao"
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione NAO para que a coluna n„o seja"
_cHelp    += "apresentada, APRESENTA para que seja "   
_cHelp    += "apresentada e TOTALIZA para que seja "   
_cHelp    += "apresentada com os subtotais referentes."
U_RGENA001(_cPerg, "04" ,"CNPJ-Central?" , "MV_PAR04", "MV_CH4", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 05
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Selecione NAO para que a coluna n„o seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"05","Cliente + Loja?"           ,"" ,"" ,"mv_ch5","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par05" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Nao"
_cDef02   := "Totaliza"
_cDef03   := "Apresenta"
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione NAO para que a coluna n„o seja"
_cHelp    += "apresentada, APRESENTA para que seja "   
_cHelp    += "apresentada e TOTALIZA para que seja "   
_cHelp    += "apresentada com os subtotais referentes."
U_RGENA001(_cPerg, "05" ,"Cliente + Loja?"  , "MV_PAR05", "MV_CH5", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 06
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Selecione NAO para que a coluna n„o seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"06","Estado?"                   ,"" ,"" ,"mv_ch6","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par06" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Nao"
_cDef02   := "Totaliza"
_cDef03   := "Apresenta"
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione NAO para que a coluna n„o seja"
_cHelp    += "apresentada, APRESENTA para que seja "   
_cHelp    += "apresentada e TOTALIZA para que seja "   
_cHelp    += "apresentada com os subtotais referentes."
U_RGENA001(_cPerg, "06" ,"Estado?"  , "MV_PAR06", "MV_CH6", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 07
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Selecione NAO para que a coluna n„o seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"07","Vendedor?"                 ,"" ,"" ,"mv_ch7","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par07" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Nao"
_cDef02   := "Totaliza"
_cDef03   := "Apresenta"
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione NAO para que a coluna n„o seja"
_cHelp    += "apresentada, APRESENTA para que seja "   
_cHelp    += "apresentada e TOTALIZA para que seja "   
_cHelp    += "apresentada com os subtotais referentes."

// AlteraÁ„o - Fernando Bombardi - ALLSS - 03/03/2022
//U_RGENA001(_cPerg, "07" ,"Vendedor?" , "MV_PAR07", "MV_CH7", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
U_RGENA001(_cPerg, "07" ,"Representante?" , "MV_PAR07", "MV_CH7", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

// - 08
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Selecione NAO para que a coluna n„o seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"08","Documento de saÌda?"       ,"" ,"" ,"mv_ch8","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par08" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Nao"
_cDef02   := "Totaliza"
_cDef03   := "Apresenta"
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione NAO para que a coluna n„o seja"
_cHelp    += "apresentada, APRESENTA para que seja "   
_cHelp    += "apresentada e TOTALIZA para que seja "   
_cHelp    += "apresentada com os subtotais referentes."
U_RGENA001(_cPerg, "08" ,"Documento de saÌda?" , "MV_PAR08", "MV_CH8", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 09
/* FB - REELASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Informe o numero do documento inicial "  )
AAdd(aHelpPor,"para que o documento seja apresentado "  )
AAdd(aHelpPor,"no relatÛrio."                           )
PutSx1(_cPerg,"09","De Documento ?"            ,"" ,"" ,"mv_ch9","C" ,(TamSx3("F2_DOC")[01])  ,0 ,0 ,"G" ,""          ,"SF2" ,"" ,"S" ,"mv_par09" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := "SF2"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe o numero do documento inicial "  
_cHelp    += "para que o documento seja apresentado " 
_cHelp    += "no relatÛrio."
U_RGENA001(_cPerg, "09" ,"De Documento ?"  , "MV_PAR09", "MV_CH9", "C", TamSx3("F2_DOC")[01], 00, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 10
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Informe o numero da sÈrie inicial para " )
AAdd(aHelpPor,"que a sÈrie seja apresentada no "        )
AAdd(aHelpPor," relatÛrio. "                            )
AAdd(aHelpPor," - ESSA INFORMA«√O DEVE SER PREENCHIDA " )
AAdd(aHelpPor,"EM CONJUNTO COM O PREENCHIMENTO DO "     )
AAdd(aHelpPor,"DOCUMENTO INICIAL."                      )
PutSx1(_cPerg,"10","De SÈrie?"                 ,"" ,"" ,"mv_cha","C" ,(TamSx3("F2_SERIE")[01]),0 ,0 ,"G" ,""          ,""    ,"" ,"S" ,"mv_par10" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe o numero da sÈrie inicial para " 
_cHelp    += "que a sÈrie seja apresentada no "        
_cHelp    += " relatÛrio. "                            
_cHelp    += " - ESSA INFORMA«√O DEVE SER PREENCHIDA " 
_cHelp    += "EM CONJUNTO COM O PREENCHIMENTO DO "     
_cHelp    += "DOCUMENTO INICIAL."
U_RGENA001(_cPerg, "10" ,"De SÈrie?"  , "MV_PAR10", "MV_CHa", "C", TamSx3("F2_SERIE")[01], 00, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 11
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Informe o numero do documento final para")
AAdd(aHelpPor,"que o documento seja apresentado "       )
AAdd(aHelpPor,"no relatÛrio. "                          )
PutSx1(_cPerg,"11","AtÈ Documento ?"           ,"" ,"" ,"mv_chb","C" ,(TamSx3("F2_DOC")[01])  ,0 ,0 ,"G" ,""          ,"SF2" ,"" ,"S" ,"mv_par11" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := "SF2"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe o numero do documento final para "
_cHelp    += "que o documento seja apresentado "       
_cHelp    += "no relatÛrio. "
U_RGENA001(_cPerg, "11" ,"AtÈ Documento ?" , "MV_PAR11", "mv_chb", "C", TamSx3("F2_DOC")[01], 00, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 12
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Informe o numero da sÈrie final para "   )
AAdd(aHelpPor,"que a sÈrie seja apresentada no "        )
AAdd(aHelpPor," relatÛrio. "                            )
AAdd(aHelpPor," - ESSA INFORMA«√O DEVE SER PREENCHIDA " )
AAdd(aHelpPor,"APENAS PARA O RELAT”RIO ANALÕTICO E "    )
AAdd(aHelpPor,"EM CONJUNTO COM O PREENCHIMENTO DO "     )
AAdd(aHelpPor,"DOCUMENTO FINAL."                        )
PutSx1(_cPerg,"12","AtÈ SÈrie?"                ,"" ,"" ,"mv_chc","C" ,(TamSx3("F2_SERIE")[01]),0 ,0 ,"G" ,""          ,""    ,"" ,"S" ,"mv_par12" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe o numero da sÈrie final para " 
_cHelp    += "que a sÈrie seja apresentada no "        
_cHelp    += " relatÛrio. "                            
_cHelp    += " - ESSA INFORMA«√O DEVE SER PREENCHIDA " 
_cHelp    += "APENAS PARA O RELAT”RIO ANALÕTICO E "    
_cHelp    += "EM CONJUNTO COM O PREENCHIMENTO DO "    
_cHelp    += "DOCUMENTO FINAL."
U_RGENA001(_cPerg, "12" ,"De SÈrie?"  , "MV_PAR12", "mv_chc", "C", TamSx3("F2_SERIE")[01], 00, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 13
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Selecione NAO para que a coluna n„o seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"13","Tipo do produto?"          ,"" ,"" ,"mv_chd","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par13" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Nao"
_cDef02   := "Totaliza"
_cDef03   := "Apresenta"
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione NAO para que a coluna n„o seja"
_cHelp    += "apresentada, APRESENTA para que seja "   
_cHelp    += "apresentada e TOTALIZA para que seja "   
_cHelp    += "apresentada com os subtotais referentes."
U_RGENA001(_cPerg, "13" ,"Tipo do produto?" , "MV_PAR13", "mv_chd", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 14
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Selecione NAO para que a coluna n„o seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"14","Grupo do produto?"         ,"" ,"" ,"mv_che","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par14" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Nao"
_cDef02   := "Totaliza"
_cDef03   := "Apresenta"
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione NAO para que a coluna n„o seja"
_cHelp    += "apresentada, APRESENTA para que seja "   
_cHelp    += "apresentada e TOTALIZA para que seja "   
_cHelp    += "apresentada com os subtotais referentes."
U_RGENA001(_cPerg, "14" ,"Grupo do produto?"  , "MV_PAR14", "mv_che", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 15
/*
aHelpPor := {}
AAdd(aHelpPor,"Selecione o produto final da pesquisa "  )
AAdd(aHelpPor,"caso queira que essa coluna seja "       )
AAdd(aHelpPor,"apresentada no relatÛrio."               )
PutSx1(_cPerg,"15","Produto?"                  ,"" ,"" ,"mv_chf","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par15" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Nao"
_cDef02   := "Totaliza"
_cDef03   := "Apresenta"
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione o produto final da pesquisa "  
_cHelp    += "caso queira que essa coluna seja "       
_cHelp    += "apresentada no relatÛrio."
U_RGENA001(_cPerg, "15" ,"Produto?"  , "MV_PAR15", "mv_chf", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 16
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"DEVOLU«√O - Base na Nota fiscal de "     )
AAdd(aHelpPor,"devoluÁ„o "                              )
AAdd(aHelpPor,""                                        )
AAdd(aHelpPor,"VENDA (Orig) - Base na Nota fiscal de "  )
AAdd(aHelpPor,"venda (documento original) "             )
PutSx1(_cPerg,"16","ApropriaÁ„o da devoluÁ„o?" ,"" ,"" ,"mv_chg","N" ,01                      ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par16" ,"NF DevoluÁ„o" ,"" ,"" ,"" ,"NF Venda(Orig)" ,"" ,"" ,""         ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "NF DevoluÁ„o"
_cDef02   := "NF Venda(Orig)"
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "DEVOLU«√O - Base na Nota fiscal de "     
_cHelp    += "devoluÁ„o "                              
_cHelp    += ""                                        
_cHelp    += "VENDA (Orig) - Base na Nota fiscal de "  
_cHelp    += "venda (documento original) "
U_RGENA001(_cPerg, "16" ,"ApropriaÁ„o da devoluÁ„o?"  , "MV_PAR16", "mv_chg", "N", 01, 00, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// 17
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Informe em qual moeda o relatÛrio deve"  )
AAdd(aHelpPor,"ser impresso.                         "  )
PutSx1(_cPerg,"17","Moeda para convers„o?"     ,"" ,"" ,"mv_chh","C" ,01                      ,0 ,0 ,"G" ,""          ,""    ,"" ,"S" ,"mv_par17" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Informe em qual moeda o relatÛrio deve" 
_cHelp    += "ser impresso. "
U_RGENA001(_cPerg, "17" ,"Moeda para convers„o?"  , "MV_PAR17", "mv_chh", "C", 01, 00, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// 18
/* FB - RELEASE 12.1.23
aHelpPor := {}
AAdd(aHelpPor,"Insira a data da cotaÁ„o da moeda para"  )
AAdd(aHelpPor,"realizaÁ„o do c·lculo de convers„o."     )
PutSx1(_cPerg,"18","Data da CotaÁ„o"           ,"" ,"" ,"mv_chi","D" ,08                      ,0 ,0 ,"G" ,""           ,""    ,"" ,"S" ,"mv_par18" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Insira a data da cotaÁ„o da moeda para"  
_cHelp    += "realizaÁ„o do c·lculo de convers„o."
U_RGENA001(_cPerg, "18" ,"Data da CotaÁ„o" , "MV_PAR18", "mv_chi", "D", 08, 00, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


RestArea(_aSArea)

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CView    ∫Autor  ≥ J˙lio Soares       ∫ Data ≥  29/04/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Por seguranÁa foi criado a verificaÁ„o da existÍncia das   ∫±±
±±∫          ≥ Views                                                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function CView()
/*
_createSD1A()
CriaSD1B()
_createSD2()
_createSF2()
_createSFD()
*/
// - VERIFICA VIEW SD11 DEVOLU«’ES COM AMARRA«√O AO DOCUMENTO ORIGINAL

// - PESQUISAR FUN«√O DE EXIST NCIA VIEW
_cQryCheck := " SELECT TOP 1 SD1A.CLIENTE " +_lEnt
_cQryCheck += " FROM SD1_"+cNumEmp+"_001 SD1A "
If TCSQLExec(_cQryCheck) < 0

// - VERIFICAR OUTRA FORMA DE TRATAR A VERIFICA«√O

	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_006A")
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA',_cRotina+"_006D",'STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o das estruturas necess·rias para a emiss„o do relatÛrio?",_cRotina+"_006E")
		_createSD1A()
	Else
		Return(Nil)
	EndIf
EndIf
TCQUERY _cQryCheck NEW ALIAS "TMPSD1A"
If Empty(TMPSD1A->(CLIENTE))
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA','V_SD1','STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o da estrutura necess·ria para a emiss„o do relatÛrio?",_cRotina+"_001E")
		_createSD1A()
		_lRetView := .F.
	EndIf
EndIf
TMPSD1A->(dbCloseArea())

// - VERIFICA VIEW SD12 DEVOLU«’ES SEM AMARRA«√O COM O DOCUMENTO ORIGINAL
_cQryCheck := " SELECT TOP 1 SD1B.CLIENTED " +_lEnt
_cQryCheck += " FROM SD1_"+cNumEmp+"_002 SD1B "
If TCSQLExec(_cQryCheck) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_006B")
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA',_cRotina+"_006F",'STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o das estruturas necess·rias para a emiss„o do relatÛrio?",_cRotina+"_006G")
		CriaSD1B()
	Else
		Return(Nil)
	EndIf
EndIf
TCQUERY _cQryCheck NEW ALIAS "TMPSD1B"
If Empty(TMPSD1B->(CLIENTED))
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA','V_SD1','STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o da estrutura necess·ria para a emiss„o do relatÛrio?",_cRotina+"_001F")
		CriaSD1B()
		_lRetView := .F.
	EndIf
EndIf
TMPSD1B->(dbCloseArea())

// - VERIFICA VIEW SD2
_cQryCheck := " SELECT TOP 1 SD2.CLIENTE " +_lEnt
_cQryCheck += " FROM SD2_"+cNumEmp+"_001 SD2 "
If TCSQLExec(_cQryCheck) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_007")
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA',_cRotina+"_006H",'STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o das estruturas necess·rias para a emiss„o do relatÛrio?",_cRotina+"_006I")
		_createSD2()
		_createSF2()
		_createSFD()
	Else
		Return(Nil)
	EndIf
EndIf
TCQUERY _cQryCheck NEW ALIAS "TMPSD2"
If Empty(TMPSD2->CLIENTE)
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA','V_SD2','STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o da estrutura necess·ria para a emiss„o do relatÛrio?",_cRotina+"_001G")
		_createSD2()
		_lRetView := .F.
	EndIf
EndIf
TMPSD2->(dbCloseArea())

// - VERIFICA VIEW SF2
_cQryCheck := " SELECT TOP 1 SF2.CLIENTE " +_lEnt
_cQryCheck += " FROM SF2_"+cNumEmp+"_001 SF2 "
If TCSQLExec(_cQryCheck) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_008")
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA',_cRotina+"_006J",'STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o das estruturas necess·rias para a emiss„o do relatÛrio?",_cRotina+"_006K")
		_createSF2()
	Else
		Return(Nil)
	EndIf
EndIf
TCQUERY _cQryCheck NEW ALIAS "TMPSF2"
If Empty(TMPSF2->(CLIENTE))
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA','V_SF2','STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o da estrutura necess·ria para a emiss„o do relatÛrio?",_cRotina+"_001H")
		_createSF2()
		_lRetView := .F.
	EndIf
EndIf
TMPSF2->(dbCloseArea())

// - VERIFICA VIEW SFD
_cQryCheck := " SELECT TOP 1 SFD.CLIENTE " +_lEnt
_cQryCheck += " FROM SFD_"+cNumEmp+"_001 SFD "
If TCSQLExec(_cQryCheck) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_009")
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA',_cRotina+"_006L",'STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o das estruturas necess·rias para a emiss„o do relatÛrio?",_cRotina+"_006M")
		_createSFD()
	Else
		Return(Nil)
	EndIf
EndIf
TCQUERY _cQryCheck NEW ALIAS "TMPSFD"
If Empty(TMPSFD->(CLIENTE))
	MSGBOX('N√O FOI POSSÕVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECU«√O DO RELAT”RIO. INFORME O ADMINISTRADOR DO SISTEMA','V_SFD','STOP')
	If MsgYesNo("Deseja iniciar o processo de criaÁ„o da estrutura necess·ria para a emiss„o do relatÛrio?",_cRotina+"_001")
		_createSFD()
		_lRetView := .F.
	EndIf
EndIf
TMPSFD->(dbCloseArea())

Return(_lRetView)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ _createSD1A ∫Autor  ≥ J˙lio Soares    ∫ Data ≥  17/07/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Rotina criada para checar a existÍncia da estrutura da view∫±±
±±∫          ≥ com base na tabela SD1, caso n„o exista a rotina cria.     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function _createSD1A()

_cCriaView1 := ""
//_cCriaView1 += "IF object_id('SD1_"+cNumEmp+"_001') IS NULL "                           +_lEnt
//_cCriaView1 += "BEGIN "                                                                 +_lEnt
// - alterar tratamento da criaÁ„o da view empresa+filial + Sequencia
_cCriaView1 += " CREATE VIEW SD1_"+cNumEmp+"_001 AS "                                   +_lEnt
_cCriaView1 += " SELECT "                                                               +_lEnt
_cCriaView1 += " 	SD1.D1_FILIAL           AS 'FILIAL', "                              +_lEnt
_cCriaView1 += " 	SD1.D1_FORNECE          AS 'CLIENTE', "                             +_lEnt
_cCriaView1 += " 	SD1.D1_LOJA             AS 'LOJA', "                                +_lEnt
_cCriaView1 += " 	SA1.A1_NOME             AS 'NOME', "                                +_lEnt
If _lEspecific
	_cCriaView1 += "SA1.A1_CGCCENT          AS 'CGCCENT', "                             +_lEnt
	_cCriaView1 += "SB1.B1_UMCOMER          AS 'UMCOMER', "                             +_lEnt
	_cCriaView1 += "SB1.B1_PCOMERC          AS 'PCOMERC', "                             +_lEnt
EndIf
_cCriaView1 += " 	SD1.D1_NFORI            AS 'NFORI', "                               +_lEnt
_cCriaView1 += " 	SD1.D1_SERIORI          AS 'SERIORI', "                             +_lEnt
_cCriaView1 += " 	SD1.D1_ITEMORI          AS 'ITEMORI', "                             +_lEnt
_cCriaView1 += " 	SD1.D1_COD              AS 'CODIGO', "                              +_lEnt
_cCriaView1 += " 	SB1.B1_DESC             AS 'DESCRI', "                              +_lEnt
_cCriaView1 += " 	SD1.D1_GRUPO            AS 'FAMILIA', "                             +_lEnt
_cCriaView1 += " 	SB1.B1_TIPO             AS 'TIPO', "                                +_lEnt
_cCriaView1 += " 	SUM(SD1.D1_QUANT )*(-1) AS 'QUANT', "                               +_lEnt
_cCriaView1 += " 	SD1.D1_UM               AS 'UM', "                                  +_lEnt
_cCriaView1 += " 	SUM(SD1.D1_TOTAL )*(-1) AS 'TOTAL', "                               +_lEnt
_cCriaView1 += " 	SUM(SD1.D1_VALICM)*(-1) AS 'ICM', "                                 +_lEnt
_cCriaView1 += " 	SUM(SD1.D1_VALIPI)*(-1) AS 'IPI' "                                  +_lEnt
_cCriaView1 += " FROM " + RetSqlName("SD1") + " SD1 "                                   +_lEnt
_cCriaView1 += "  	INNER JOIN " + RetSqlName("SA1") + " SA1 "                          +_lEnt
_cCriaView1 += " 		ON SA1.D_E_L_E_T_ = '' "                                        +_lEnt
_cCriaView1 += "  		AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "                  +_lEnt
_cCriaView1 += "  		AND SA1.A1_COD    = SD1.D1_FORNECE "                            +_lEnt
_cCriaView1 += "  		AND SA1.A1_LOJA   = SD1.D1_LOJA "                               +_lEnt
_cCriaView1 += " 	INNER JOIN " + RetSqlName("SB1") + " SB1 "                          +_lEnt
_cCriaView1 += " 		ON SB1.D_E_L_E_T_ = '' "                                        +_lEnt
_cCriaView1 += " 		AND SB1.B1_FILIAL = '"+xFilial("SB1") + "' "                    +_lEnt
_cCriaView1 += " 		AND SB1.B1_COD    = SD1.D1_COD "                                +_lEnt
_cCriaView1 += " 		AND SB1.B1_TIPO   = SD1.D1_TP "                                 +_lEnt
_cCriaView1 += " WHERE SD1.D_E_L_E_T_ = '' "                                            +_lEnt
_cCriaView1 += " AND SD1.D1_FILIAL  = '"+ xFilial("SD1") +"' "                          +_lEnt
_cCriaView1 += " AND SD1.D1_TIPO    = 'D' "                                             +_lEnt
If _lEspecific
	_cCriaView1 += " AND SD1.D1_EMISSAO > '20090101' "                                  +_lEnt
EndIf
_cCriaView1 += " GROUP BY "                                                             +_lEnt
_cCriaView1 += " SD1.D1_FILIAL,SD1.D1_FORNECE,SD1.D1_LOJA,SA1.A1_NOME, "                +_lEnt
If _lEspecific
	_cCriaView1 += " SA1.A1_CGCCENT, SB1.B1_UMCOMER,SB1.B1_PCOMERC, "                   +_lEnt
EndIf
_cCriaView1 += " SD1.D1_NFORI,SD1.D1_SERIORI,SD1.D1_ITEMORI,SD1.D1_COD,SB1.B1_DESC, "   +_lEnt
_cCriaView1 += " SD1.D1_GRUPO,SB1.B1_TIPO,SD1.D1_UM "                                   +_lEnt
//_cCriaView1 += "END "
//MemoWrite("\2.Memowrite\"+_cRotina+"_VIEW-1.TXT",_cCriaView1)
If TCSQLExec(_cCriaView1) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_009A")
EndIf

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CriaSD1B ∫Autor  ≥ J˙lio Soares       ∫ Data ≥  17/07/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Rotina criada para checar a existÍncia da estrutura da view∫±±
±±∫          ≥ com base na tabela SD1, caso n„o exista a rotina cria.     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function CriaSD1B()

_cCriaView2 := ""
//_cCriaView2 += "IF object_id('SD1_"+cNumEmp+"_002') IS NULL "                    +_lEnt
//_cCriaView2 += "BEGIN "                                                          +_lEnt
_cCriaView2 += " CREATE VIEW SD1_"+cNumEmp+"_002 AS "                            +_lEnt
_cCriaView2 += " SELECT "                                                        +_lEnt
_cCriaView2 += " 	SD1.D1_FILIAL           AS 'FILIALD', "                      +_lEnt
_cCriaView2 += " 	SD1.D1_DTDIGIT			AS 'DIGITACAO', "                    +_lEnt
_cCriaView2 += " 	SD1.D1_FORNECE          AS 'CLIENTED', "                     +_lEnt
_cCriaView2 += " 	SD1.D1_LOJA             AS 'LOJAD', "                        +_lEnt
_cCriaView2 += " 	SA1.A1_NOME             AS 'NOMED', "                        +_lEnt
_cCriaView2 += " 	SA1.A1_CGC              AS 'CGCD', "                         +_lEnt
_cCriaView2 += " 	SA1.A1_EST              AS 'ESTADOD', "                      +_lEnt
If _lEspecific
	If SA1->(FieldPos("A1_CGCCENT"))<>0
		_cCriaView2 += "SA1.A1_CGCCENT      AS 'CGCCENTD', "                     +_lEnt
	Else
		_cCriaView2 += " ''                 AS 'CGCCENTD', "                     +_lEnt
	EndIf
	If SA1->(FieldPos("A1_NOMECGC"))<>0
		_cCriaView2 += "SA1.A1_NOMECGC      AS 'NOMECNPJD', "                    +_lEnt
	Else
		_cCriaView2 += " ''                 AS 'NOMECNPJD', "                    +_lEnt
	EndIf
	If SB1->(FieldPos("B1_UMCOMER"))<>0
		_cCriaView2 += "SB1.B1_UMCOMER      AS 'UMCOMERD', "                     +_lEnt
	Else
		_cCriaView2 += " ''                 AS 'UMCOMERD', "                     +_lEnt
	EndIf
	If SB1->(FieldPos("B1_PCOMERC"))<>0
		_cCriaView2 += "SB1.B1_PCOMERC      AS 'PCOMERCD', "                     +_lEnt
	Else
		_cCriaView2 += " ''                 AS 'PCOMERCD', "                     +_lEnt
	EndIf
EndIf
_cCriaView2 += " 	SA1.A1_VEND             AS 'VENDD', "                        +_lEnt
_cCriaView2 += " 	SA3.A3_NOME             AS 'NOMEVENDD', "                    +_lEnt
_cCriaView2 += " 	SD1.D1_COD              AS 'CODIGOD', "                      +_lEnt
_cCriaView2 += " 	SB1.B1_DESC             AS 'DESCRID', "                      +_lEnt
_cCriaView2 += " 	SD1.D1_GRUPO            AS 'FAMILIAD', "                     +_lEnt
_cCriaView2 += " 	SD1.D1_TP               AS 'TIPOD', "                        +_lEnt
_cCriaView2 += " 	SUM(SD1.D1_QUANT )*(-1) AS 'QUANTD', "                       +_lEnt
_cCriaView2 += " 	SD1.D1_UM               AS 'UMD', "                          +_lEnt
_cCriaView2 += " 	SUM(SD1.D1_TOTAL )*(-1) AS 'TOTDEV', "                       +_lEnt
_cCriaView2 += " 	SUM(SD1.D1_VALICM)*(-1) AS 'ICMDEV', "                       +_lEnt
_cCriaView2 += " 	SUM(SD1.D1_VALIPI)*(-1) AS 'IPIDEV' "                        +_lEnt
_cCriaView2 += " FROM "+ RetSqlName("SD1") +" SD1 "                              +_lEnt
_cCriaView2 += "  	INNER JOIN "+ RetSqlName("SA1") +" SA1 "                     +_lEnt
_cCriaView2 += "  		ON SA1.D_E_L_E_T_ = '' "                                 +_lEnt
_cCriaView2 += "  		AND SA1.A1_FILIAL = '"+ xFilial("SA1") +"' "             +_lEnt
_cCriaView2 += "  		AND SA1.A1_COD    = SD1.D1_FORNECE "                     +_lEnt
_cCriaView2 += "  		AND SA1.A1_LOJA   = SD1.D1_LOJA "                        +_lEnt
_cCriaView2 += " INNER JOIN "+ RetSqlName("SB1") +" SB1 "                        +_lEnt
_cCriaView2 += " 		ON SB1.D_E_L_E_T_ = '' "                                 +_lEnt
_cCriaView2 += " 		AND SB1.B1_FILIAL = '"+xFilial("SB1") + "'"              +_lEnt
_cCriaView2 += " 		AND SB1.B1_COD    = SD1.D1_COD "                         +_lEnt
_cCriaView2 += " 		AND SB1.B1_TIPO   = SD1.D1_TP "                          +_lEnt
_cCriaView2 += " INNER JOIN "+ RetSqlName("SA3") +" SA3 "                        +_lEnt
_cCriaView2 += " 		ON SA3.A3_FILIAL = '" + xFilial("SA3") + "' "            +_lEnt
_cCriaView2 += " 		AND SA3.A3_COD   = SA1.A1_VEND "                         +_lEnt
_cCriaView2 += " WHERE SD1.D_E_L_E_T_ = '' "                                     +_lEnt
_cCriaView2 += " AND SD1.D1_FILIAL    = '"+xFilial("SD1") + "' "                 +_lEnt
_cCriaView2 += " AND SD1.D1_TIPO	  = 'D' "                                    +_lEnt
If _lEspecific
	_cCriaView2 += " AND SD1.D1_EMISSAO > '20090101' "                           +_lEnt
EndIf
_cCriaView2 += " GROUP BY  "                                                     +_lEnt
_cCriaView2 += " SD1.D1_FILIAL, SD1.D1_DTDIGIT,SA1.A1_CGC,SD1.D1_FORNECE, "      +_lEnt
_cCriaView2 += " SD1.D1_LOJA, SA1.A1_NOME, A1_EST, "                             +_lEnt
If _lEspecific
	If SA1->(FieldPos("A1_CGCCENT"))<>0
		_cCriaView2 += " SA1.A1_CGCCENT,"  +_lEnt
	EndIf
	If SA1->(FieldPos("A1_NOMECGC"))<>0
		_cCriaView2 += " SA1.A1_NOMECGC,"  +_lEnt
	EndIf
	If SB1->(FieldPos("B1_UMCOMER"))<>0
		_cCriaView2 += " SB1.B1_UMCOMER,"  +_lEnt
	EndIf
	If SB1->(FieldPos("B1_PCOMERC"))<>0
		_cCriaView2 += " SB1.B1_PCOMERC,"  +_lEnt
	EndIf
EndIf
_cCriaView2 += " A1_VEND,A3_NOME, SD1.D1_COD, SB1.B1_DESC, "                     +_lEnt
_cCriaView2 += " SD1.D1_GRUPO,SD1.D1_TP,SD1.D1_UM "                              +_lEnt
//_cCriaView2 += "END "
//MemoWrite("\2.Memowrite\"+_cRotina+"_VIEW-2.TXT",_cCriaView2)
If TCSQLExec(_cCriaView2) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_009B")
EndIf

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ _createSD2 ∫Autor  ≥ J˙lio Soares     ∫ Data ≥  17/07/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Rotina criada para checar a existÍncia da estrutura da view∫±±
±±∫          ≥ com base na tabela SD2, caso n„o exista a rotina cria.     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function _createSD2()

Local _aTpOper := Separa(SuperGetMv("MV_FATOPER",,"01|ZZ|9"),"|",.F.)

_cCriaView3 := ""
//_cCriaView3 += "IF object_id('SD2_"+cNumEmp+"_001') IS NULL "            +_lEnt
//_cCriaView3 += "BEGIN "                                                  +_lEnt
_cCriaView3 += " CREATE VIEW SD2_"+cNumEmp+"_001 AS "                    +_lEnt
_cCriaView3 += " SELECT "                                                +_lEnt
_cCriaView3 += " 	SD2.D2_FILIAL		AS 'FILIAL', "                   +_lEnt
_cCriaView3 += " 	SD2.D2_EMISSAO      AS 'EMISSAO', "                  +_lEnt
_cCriaView3 += " 	SD2.D2_CLIENTE      AS 'CLIENTE', "                  +_lEnt
_cCriaView3 += " 	SD2.D2_LOJA         AS 'LOJA', "                     +_lEnt
_cCriaView3 += " 	SD2.D2_EST          AS 'ESTADO', "                   +_lEnt
_cCriaView3 += " 	SD2.D2_SERIE        AS 'SERIE', "                    +_lEnt
_cCriaView3 += " 	SD2.D2_DOC          AS 'DOC', "                      +_lEnt
_cCriaView3 += " 	SD2.D2_ITEM         AS 'ITEM', "                     +_lEnt
_cCriaView3 += " 	SD2.D2_COD          AS 'CODIGO', "                   +_lEnt
_cCriaView3 += " 	SB1.B1_DESC         AS 'DESCRI', "                   +_lEnt
_cCriaView3 += " 	SD2.D2_GRUPO        AS 'FAMILIA', "                  +_lEnt
If _lEspecific
	_cCriaView3 += "SB1.B1_UMCOMER      AS 'UMCOMER', "                  +_lEnt
	_cCriaView3 += "SB1.B1_PCOMERC      AS 'PCOMERC', "                  +_lEnt
EndIf
_cCriaView3 += " 	SB1.B1_TIPO         AS 'TIPO', "                     +_lEnt
_cCriaView3 += " 	SUM(CASE WHEN SF4.F4_ESTOQUE = 'S' "                 +_lEnt
If _lEspecific
	_cCriaView3 += " 	OR (SD2.D2_TES = '601' AND SD2.D2_SCOA <> '') "  +_lEnt
EndIf
_cCriaView3 += " 			THEN SD2.D2_QUANT "                          +_lEnt
_cCriaView3 += " 			ELSE 0 "                                     +_lEnt
_cCriaView3 += " 		END) AS 'QUANT', "                               +_lEnt
_cCriaView3 += " 	SD2.D2_UM           AS 'UM', "                       +_lEnt
_cCriaView3 += " 	SUM(SD2.D2_QTSEGUM) AS 'QTD2UM', "                   +_lEnt
_cCriaView3 += " 	SD2.D2_SEGUM        AS 'UM2', "                      +_lEnt
_cCriaView3 += " 	SUM(SD2.D2_TOTAL)   AS 'TOTAL', "                    +_lEnt
_cCriaView3 += " 	SUM(SD2.D2_VALICM)  AS 'ICM', "                      +_lEnt
_cCriaView3 += " 	SUM(SD2.D2_VALIPI)  AS 'IPI' "                       +_lEnt
_cCriaView3 += " FROM " + RetSqlName("SD2") + " SD2 "                    +_lEnt
_cCriaView3 += "  	INNER JOIN "+ RetSqlName("SF4") +" SF4 "             +_lEnt
_cCriaView3 += "  		ON SF4.D_E_L_E_T_ = '' "                         +_lEnt
_cCriaView3 += "  		AND SF4.F4_FILIAL = '" +xFilial("SF4") + "' "    +_lEnt
_cCriaView3 += "  		AND SF4.F4_DUPLIC = 'S' "                        +_lEnt
_cCriaView3 += " 		AND SF4.F4_CODIGO = SD2.D2_TES "                 +_lEnt
_cCriaView3 += " 	INNER JOIN " + RetSqlName("SB1") + " SB1 "           +_lEnt
_cCriaView3 += "  		ON SB1.D_E_L_E_T_ = '' "                         +_lEnt
_cCriaView3 += " 		AND SB1.B1_FILIAL = '"+xFilial("SB1") + "' "     +_lEnt
_cCriaView3 += " 		AND SB1.B1_COD    = SD2.D2_COD "                 +_lEnt
_cCriaView3 += " 		AND SB1.B1_TIPO   = SD2.D2_TP "                  +_lEnt
_cCriaView3 += " WHERE SD2.D_E_L_E_T_  = '' "                            +_lEnt
_cCriaView3 += "   AND SD2.D2_FILIAL   = '" + xFilial("SD2") + "' "      +_lEnt
_cCriaView3 += "   AND SD2.D2_TIPO	   = 'N' "                           +_lEnt
If _lEspecific
	If Len(_aTpOper) > 0
		_cCriaView3 += "   AND ("
		For _x := 1 To Len(_aTpOper)
			If _x > 1
				_cCriaView3 += " OR "
			EndIf
			_cCriaView3 += "SD2.D2_TIPOPER = '"+_aTpOper[_x]+"' "
		Next
		_cCriaView3 += "       )"                                        +_lEnt
	EndIf
	_cCriaView3 += "   AND SD2.D2_EMISSAO > '20090101' "                 +_lEnt
EndIf
_cCriaView3 += " GROUP BY "                                              +_lEnt 
_cCriaView3 += " SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_CLIENTE, "          +_lEnt
_cCriaView3 += " SD2.D2_LOJA,SD2.D2_EST,SD2.D2_SERIE,SD2.D2_DOC, "       +_lEnt
_cCriaView3 += " SD2.D2_ITEM,SD2.D2_COD,SB1.B1_DESC,SD2.D2_GRUPO, "      +_lEnt
If _lEspecific
	_cCriaView3 += " SB1.B1_UMCOMER,SB1.B1_PCOMERC, "  +_lEnt
EndIf
_cCriaView3 += " SB1.B1_TIPO,SD2.D2_UM, SD2.D2_SEGUM "                   +_lEnt
//_cCriaView3 += "END "
//MemoWrite("\2.Memowrite\"+_cRotina+"_VIEW-3.TXT",_cCriaView3)
If TCSQLExec(_cCriaView3) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_009C")
EndIf

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ _createSF2  ∫Autor  ≥ J˙lio Soares    ∫ Data ≥  17/07/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Rotina criada para checar a existÍncia da estrutura da view∫±±
±±∫          ≥ com base na tabela SF2, caso n„o exista a rotina cria.     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function _createSF2()

_cCriaView4 := ""
//_cCriaView4 += "IF object_id('SF2_"+cNumEmp+"_001') IS NULL "          +_lEnt
//_cCriaView4 += "BEGIN "                                                +_lEnt
_cCriaView4 += " CREATE VIEW SF2_"+cNumEmp+"_001 AS "                  +_lEnt
_cCriaView4 += " SELECT "                                              +_lEnt
_cCriaView4 += " 	SF2.F2_FILIAL  AS 'FILIAL', "                      +_lEnt
_cCriaView4 += " 	SF2.F2_EMISSAO AS 'EMISSAO', "                     +_lEnt
_cCriaView4 += " 	SF2.F2_CLIENTE AS 'CLIENTE', "                     +_lEnt
_cCriaView4 += " 	SF2.F2_LOJA    AS 'LOJA', "                        +_lEnt
_cCriaView4 += " 	SA1.A1_NOME    AS 'NOME', "                        +_lEnt
If _lEspecific
	If SA1->(FieldPos("A1_CGCCENT"))<>0
		_cCriaView4 += "SA1.A1_CGCCENT AS 'CGCCENT', "                 +_lEnt
	Else
		_cCriaView4 += " ''            AS 'CGCCENT', "                 +_lEnt
	EndIf
	If SA1->(FieldPos("A1_NOMECGC"))<>0
		_cCriaView4 += "SA1.A1_NOMECGC AS 'NOMECNPJ', "                +_lEnt
	Else
		_cCriaView4 += " ''            AS 'NOMECNPJ', "                +_lEnt
	EndIf
EndIf
_cCriaView4 += " 	SA1.A1_CGC     AS 'CGC', "                         +_lEnt
_cCriaView4 += " 	SA1.A1_EST     AS 'EST', "                         +_lEnt
_cCriaView4 += " 	SF2.F2_VEND1   AS 'VEND', "                        +_lEnt
_cCriaView4 += "  	SA3.A3_NOME    AS 'NOMEVEND', "                    +_lEnt
_cCriaView4 += "  	SF2.F2_DOC     AS 'DOC', "                         +_lEnt
_cCriaView4 += "  	SF2.F2_SERIE   AS 'SERIE' "                        +_lEnt
_cCriaView4 += " FROM "+ RetSqlName("SF2") + " SF2 "                   +_lEnt
_cCriaView4 += " 	INNER JOIN " + RetSqlName("SA3") + " SA3 "         +_lEnt
_cCriaView4 += " 		ON SA3.D_E_L_E_T_ = '' "                       +_lEnt
_cCriaView4 += "  		AND SA3.A3_FILIAL = '" +xFilial("SA3") + "' "  +_lEnt
_cCriaView4 += "  		AND SA3.A3_COD    = SF2.F2_VEND1 "             +_lEnt
_cCriaView4 += "  	INNER JOIN "+ RetSqlName("SA1") +" SA1 "           +_lEnt
_cCriaView4 += "  		ON SA1.D_E_L_E_T_ = '' "                       +_lEnt
_cCriaView4 += "  		AND SA1.A1_FILIAL = '"+ xFilial("SA1") + "' "  +_lEnt
_cCriaView4 += "  		AND SA1.A1_COD    = SF2.F2_CLIENTE "           +_lEnt
_cCriaView4 += "  		AND SA1.A1_LOJA   = SF2.F2_LOJA "              +_lEnt
_cCriaView4 += " WHERE SF2.D_E_L_E_T_ = '' "                           +_lEnt
_cCriaView4 += " AND SF2.F2_FILIAL    = '"+ xFilial("SF2") +"' "       +_lEnt
_cCriaView4 += " AND SF2.F2_TIPO      = 'N' "                          +_lEnt
If _lEspecific
	_cCriaView4 += "AND SF2.F2_EMISSAO> '20090101' "                   +_lEnt
EndIf
//_cCriaView4 += "END "
//MemoWrite("\2.Memowrite\"+_cRotina+"_VIEW-4.TXT",_cCriaView4)
If TCSQLExec(_cCriaView4) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_009D")
EndIf

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ _createSFD  ∫Autor  ≥ J˙lio Soares    ∫ Data ≥  17/07/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Rotina criada para checar a existÍncia da estrutura da view∫±±
±±∫          ≥ com base na tabela SF2, caso n„o exista a rotina cria.     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function _createSFD()

_cCriaView5 := ""
//_cCriaView5 += "IF object_id('SFD_"+cNumEmp+"_001') IS NULL"+_lEnt
//_cCriaView5 += "BEGIN "                                     +_lEnt
_cCriaView5 += " CREATE VIEW SFD_"+cNumEmp+"_001 AS "       +_lEnt
_cCriaView5 += " SELECT "                                   +_lEnt
_cCriaView5 += " 	SD2.EMISSAO            AS 'EMISSAO', "  +_lEnt
_cCriaView5 += " 	SD2.CLIENTE            AS 'CLIENTE', "  +_lEnt
_cCriaView5 += " 	SD2.LOJA               AS 'LOJA', "     +_lEnt
_cCriaView5 += " 	SF2.NOME               AS 'NOME', "     +_lEnt
If _lEspecific
	_cCriaView5 += " 	SF2.CGCCENT            AS 'CGCCENT', "  +_lEnt
	_cCriaView5 += " 	SF2.NOMECNPJ           AS 'NOMECNPJ', " +_lEnt
EndIf
_cCriaView5 += " 	SF2.CGC                AS 'CGC', "      +_lEnt
_cCriaView5 += " 	SF2.EST                AS 'ESTADO', "   +_lEnt
_cCriaView5 += " 	SF2.VEND               AS 'VEND', "     +_lEnt
_cCriaView5 += "  	SF2.NOMEVEND           AS 'NOMEVEND', " +_lEnt
_cCriaView5 += " 	SD2.CODIGO             AS 'CODIGO', "   +_lEnt
_cCriaView5 += " 	SD2.DESCRI             AS 'DESCRI', "   +_lEnt
If _lEspecific
	_cCriaView5 += "SD2.FAMILIA            AS 'FAMILIA', "  +_lEnt
	_cCriaView5 += "SD2.UMCOMER            AS 'UMCOM', "    +_lEnt
	_cCriaView5 += "SD2.PCOMERC            AS 'PCOM', "     +_lEnt
EndIf
_cCriaView5 += " 	SD2.TIPO               AS 'TIPO', "     +_lEnt
_cCriaView5 += " 	SD2.QUANT              AS 'QTDFAT', "   +_lEnt
_cCriaView5 += " 	SD2.UM                 AS 'UM', "       +_lEnt
_cCriaView5 += " 	SD2.QTD2UM             AS 'QTD2FAT', "  +_lEnt
_cCriaView5 += " 	SD2.UM2                AS 'UM2', "      +_lEnt
_cCriaView5 += " 	SD2.SERIE              AS 'SERIE', "    +_lEnt
_cCriaView5 += " 	SD2.DOC                AS 'DOC', "      +_lEnt
_cCriaView5 += " 	SD2.ITEM               AS 'ITEMFAT', "  +_lEnt
_cCriaView5 += " 	SD2.TOTAL              AS 'TOTALFAT', " +_lEnt
_cCriaView5 += " 	SD2.ICM                AS 'ICMFAT', "   +_lEnt
_cCriaView5 += " 	SD2.IPI         	   AS 'IPIFAT', "   +_lEnt
_cCriaView5 += " 	ISNULL(SD1.SERIORI,'') AS 'SERIORI', "  +_lEnt
_cCriaView5 += " 	ISNULL(SD1.NFORI  ,'') AS 'NFORI', "    +_lEnt
_cCriaView5 += " 	ISNULL(SD1.ITEMORI,'') AS 'ITEMORI', "  +_lEnt
_cCriaView5 += " 	ISNULL(SD1.TOTAL  ,'') AS 'TOTALDEV', " +_lEnt
_cCriaView5 += " 	ISNULL(SD1.QUANT  ,'') AS 'QTDDEV', "   +_lEnt
_cCriaView5 += " 	ISNULL(SD1.ICM    ,'') AS 'ICMDEV', "   +_lEnt
_cCriaView5 += " 	ISNULL(SD1.IPI    ,'') AS 'IPIDEV', "   +_lEnt
If _lEspecific
	_cCriaView5 += "ISNULL(SD1.PCOMERC,'') AS 'PCOMDEV' "   +_lEnt
EndIf
_cCriaView5 += " FROM SD2_"+cNumEmp+"_001 SD2 "             +_lEnt
_cCriaView5 += " 	INNER JOIN SF2_"+cNumEmp+"_001 SF2 "    +_lEnt
_cCriaView5 += " 		ON  SF2.FILIAL  = SD2.FILIAL "      +_lEnt
_cCriaView5 += " 		AND SF2.CLIENTE = SD2.CLIENTE "     +_lEnt
_cCriaView5 += " 		AND SF2.LOJA    = SD2.LOJA "        +_lEnt
_cCriaView5 += " 		AND SF2.SERIE   = SD2.SERIE "       +_lEnt
_cCriaView5 += " 		AND SF2.DOC     = SD2.DOC "         +_lEnt
_cCriaView5 += " 	LEFT JOIN SD1_"+cNumEmp+"_001 SD1 "     +_lEnt
_cCriaView5 += " 		ON SD1.FILIAL   = SD2.FILIAL "      +_lEnt
_cCriaView5 += " 		AND SD1.CLIENTE = SD2.CLIENTE "     +_lEnt
_cCriaView5 += " 		AND SD1.LOJA    = SD2.LOJA "        +_lEnt
_cCriaView5 += " 		AND SD1.SERIORI = SD2.SERIE "       +_lEnt
_cCriaView5 += " 		AND SD1.NFORI   = SD2.DOC "         +_lEnt
_cCriaView5 += " 		AND SD1.ITEMORI = SD2.ITEM "        +_lEnt
_cCriaView5 += " 		AND SD1.CODIGO  = SD2.CODIGO "      +_lEnt
//_cCriaView5 += "END "
//MemoWrite("\2.Memowrite\"+_cRotina+"_VIEW-5.TXT",_cCriaView5)
If TCSQLExec(_cCriaView5) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_009E")
EndIf

Return()
