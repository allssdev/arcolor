#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRFATR027  บ Autor ณJ๚lio Soares          บ Data ณ  25/04/14 บฑฑ
ฑฑบ          ณArrays    บ Autor ณAnderson Coelho       บ Data ณ  29/06/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de rela็ใo de faturamento totalizado por produto,บฑฑ
ฑฑบ          ณ por cliente, por vendedor, por estado e por emissใo        บฑฑ
ฑฑบ          ณ conforme informa็๕es dos parโmetros solicitados.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFATR027()

Local   _aSavArea  := GetArea()
Private _cRotina   := "RFATR027"
Private _cPerg     := _cRotina
Private _cTitulo   := ""
Private _cTitulo2  := ""
Private _cQuery    := ""
Private _tAlias	   := "TMPRFT27"
Private _aCpos     := {}		//Campos a serem atualizados
Private _lEnt      := + CHR(13) + CHR(10)
Private nListBox1  := 1
Private nListBox2  := 2
Private nListBox3  := 3
Private nListBox4  := 4

Private _cQryCheck := ""

Private _aTtt   := {}	//Posi็๕es: 1=Nบ Coluna  /  2=Valores Somados
Private _aSbTtt := {}	//Posi็๕es: 1=Tipo (Estado,Vendedor,CNPJ,Cliente)  /  2=Sub-Estrutura contendo: [1=Nบ Coluna  |  2=Valores Somados | 3=Sub-Total de que?]  /  3=Nome do campo relativo  /  4=Tํtulo do Sub_Total  /  5=Nome que serแ exibino no sub-total / 6=Ordem Escolhida

Public  _lRetm     := .T.

// - VALIDA AS PERGUNTAS PARA O PARยMETRO
ValidPerg()

// - CHAMA AS PERGUNTAS DOS PARยMETROS
/* FB - RELEASE 12.1.23
While !Pergunte(_cPerg,.T.)
	If MsgYesNo("Deseja cancelar a emissใo do relat๓rio?",_cRotina+"_01")
		Return()
	EndIf
EndDo
*/
IF  !Pergunte(_cPerg,.T.)
	MSGBOX("Fun็ใo cancelada pelo usuแrio!",'CANCELADO','STOP')
	Return()
ENDIF


// - VERIFICA SE USUมRIO TEM PERMISSรO PARA GERAR DADOS EM EXCEL
If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
	MSGBOX('Usuแrio sem permissใo para gerar relat๓rio em Excel. Informe o Administrador.',_cRotina +"02",'STOP')
   Return(Nil)
EndIf

/*// - VERIFICA SE Hม O EXCEL INSTALADO NA MมQUINA EM USO
If __cUserID <> '000000'
	If !ApOleClient('MsExcel')
		Msgbox('Excel nใo instalado.',_cRotina +"03",'ALERT')
	   Return(Nil)
	EndIf
EndIf
*/
_cTitulo  := ("Rela็ใo de Faturamento " +(IIf (MV_PAR14 == 1,'Sint้tico','Analํtico')) + " - de " + (DTOC(mv_par01)) + " at้ " + (DTOC(mv_par02)) + " - " + _cRotina)
_cTitulo2 := ("PARยMETROS")

// - SELECIONA A ORDEM DO FATURAMENTO
SelOrdem()

// - DEFINE A ORDEM DOS ARRAYS DA SUB-TOTALIZAวรO
	//Estrutura do array "_aSbTtt"
	//Posi็๕es: 1=Tipo (1=Estado,2=Vendedor,3=CNPJ,4=Cliente)
	//          2=Sub-Estrutura contendo: 
	//						1=Nบ Coluna
	//						2=Valores Somados
	//						3=Sub-Total de que?
	//			3=Nome do campo relativo
	//			4=Tํtulo do Sub_Total
	//			5=Nome que serแ exibino no sub-total
	//			6=Ordem na Query
	//			7=Ordem Escolhida
	//			8=Indica se haverแ sub-totaliza็ใo

AADD( _aSbTtt, { 1, {}, (_tAlias)+"->ESTADO"                                                                  , "SUB-TOTAL DO ESTADO "            , (_tAlias)+"->ESTADO"   , "ESTADO"           , nListBox1, MV_PAR06==2} )		//Estado

// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
//AADD( _aSbTtt, { 2, {}, (_tAlias)+"->VEND     + ' ' + " + (_tAlias)+"->NOMEVEND"                              , "SUB-TOTAL DO VENDEDOR "          , (_tAlias)+"->NOMEVEND" , "VEND,NOMEVEND"    , nListBox2, MV_PAR07==2} )		//Vendedor
AADD( _aSbTtt, { 2, {}, (_tAlias)+"->VEND     + ' ' + " + (_tAlias)+"->NOMEVEND"                              , "SUB-TOTAL DO REPRESENTANTE "          , (_tAlias)+"->NOMEVEND" , "VEND,NOMEVEND"    , nListBox2, MV_PAR07==2} )		//Vendedor
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

AADD( _aSbTtt, { 3, {}, (_tAlias)+"->CNPJCENT + ' ' + " + (_tAlias)+"->NOMECNPJ"                              , "SUB-TOTAL DO CNPJ CENTRALIZADOR ", (_tAlias)+"->NOMECNPJ" , "CNPJCENT,NOMECNPJ", nListBox3, MV_PAR04==1} )		//CNPJ Centralizador
AADD( _aSbTtt, { 4, {}, (_tAlias)+"->CLIENTE  + ' ' + " + (_tAlias)+"->LOJA     + ' ' + " + (_tAlias)+"->NOME", "SUB-TOTAL DO CLIENTE "           , (_tAlias)+"->NOME"     , "CLIENTE,LOJA,NOME", nListBox4, MV_PAR05==2} )		//Cliente

// - REALIZA A REORDENAวรO DAS SUB-TOTALIZAวีES
_aSbTtt := aSort(_aSbTtt,,, { |x,y| x[07] < y[07] } )

// - CHAMA CONSULTA DO CLIENTE CONFORME SELEวรO DEFINIDO PELO USUมRIO
If ExistBlock("RFATE046")
	MsgRun("Selecionando cadastro de clientes... Por favor AGUARDE. ",_cTitulo,{|| U_RFATE046()})
Else
	MSGBOX('Nใo foi possํvel continuar o processo, informe o administrador do sistema',_cRotina,'STOP')
EndIf

If _lRetm
	// - CHAMA FUNวรO DE CONSULTA CONFORME PARยMETROS DEFINIDO PELO USUมRIO
	MsgRun("Selecionando dados... Por favor AGUARDE. ",_cTitulo,{ || SelectQry() })
	// - CHAMA A FUNวรO PARA EMITIR OS DADOS EM PLANILHA
	Processa({ |lEnd| Geraxls(@lEnd) },_cRotina,' Gerando relat๓rio em Excel...   Por favor aguarde.',.T.)
Else
    MSGBOX('Nใo foi selecionado nenhum cliente para gera็ใo do relat๓rio.',_cRotina+'_04','ALERT')
	Return()
EndIf

// - SE A TABELA APRESENTAR DADOS FECHA A MESMA APำS O USO
If Select (_tAlias) > 0
   (_tAlias)->(dbCloseArea())
EndIf
dbCloseArea(_tAlias)

// - FAZ A LIMPEZA DAS MARCAวีES DA TABELA DOS CLIENTES
_cQryUpd := "UPDATE " + RetSqlName("SA1") + " "
_cQryUpd += "SET A1_MARK = '', A1_RELFAT  = REPLACE(A1_RELFAT,'" + ALLTRIM(__cUserId) + "|" + "','')"
_cQryUpd += "WHERE A1_RELFAT LIKE '%" + ALLTRIM(__cUserId) + "|" +"%'"
_cQryUpd += "AND D_E_L_E_T_ = ''"
_cQryUpd += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
If TCSQLExec(_cQryUpd) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+ "_05")
EndIf
             
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ RFATR027  บ Autor ณJ๚lio Soares         บ Data ณ  25/04/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel pela sele็ใo dos dados a partir da      บฑฑ
ฑฑบ          ณ consulta .                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Implementado ajustes na consulta.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelectQry()

Local _cQryFat  := ""  // Query  Faturamento
Local _cSelFat  := ""  // Select Faturamento
Local _cGrpFat  := ""  // Group  Faturamento
Local _cQryDev  := ""  // Query  Devol็ใo
Local _cSelDev  := ""  // Select Devol็ใo
Local _cGrpDev  := ""  // Group  Devol็ใo
Local _cOrdDev  := ""  // Order  Devol็ใo
Local _SelCpos  := ""  // Sele็ใo do Union All
Local _SumCpos  := ""  // Soma dos campos do Union All
Local _cOrder   := ""  // Order  Geral
Local _cOrd     := ""  // Order 
Local _cQuery   := ""  // Query final

// - INICIO DA CONSTRUวรO DAS COLUNAS PARA O EXCEL
If (MV_PAR14) == 2 .OR. (MV_PAR03) == 2
	AADD(_aCpos,{"EMISSAO"       ,"(_tAlias)->EMISSAO" ,2,4,.F.})
EndIf
If (MV_PAR14) == 2 .OR. (MV_PAR06) <> 1
	AADD(_aCpos,{"ESTADO"        ,"(_tAlias)->ESTADO"  ,2,1,.F.})
EndIf
If (MV_PAR14) == 2 .OR. (MV_PAR07) <> 1

	// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
	AADD(_aCpos,{"REPRESENTANTE"      ,"(_tAlias)->VEND",2,1,.F.})
	AADD(_aCpos,{"NOME REP."    ,"(_tAlias)->NOMEVEND",1,1,.F.})

	//AADD(_aCpos,{"VENDEDOR"      ,"(_tAlias)->VEND",2,1,.F.})
	//AADD(_aCpos,{"NOME VEND."    ,"(_tAlias)->NOMEVEND",1,1,.F.})
	// Fim - Fernando Bombardi - ALLSS - 02/03/2022

EndIf
If (MV_PAR14) == 2 .OR. (MV_PAR04) <> 3
	AADD(_aCpos,{"CNPJ_CENT"     ,"(_tAlias)->CNPJCENT",2,1,.F.})
	AADD(_aCpos,{"NOME_CENTRAL"  ,"(_tAlias)->NOMECNPJ",1,1,.F.})
EndIf
If (MV_PAR14) == 2 .OR. (MV_PAR05) <> 1
	AADD(_aCpos,{"CNPJ"          ,"(_tAlias)->CNPJ"     ,2,1,.F.})
	AADD(_aCpos,{"CLIENTE"       ,"(_tAlias)->CLIENTE"  ,2,1,.F.})
	AADD(_aCpos,{"LOJA"          ,"(_tAlias)->LOJA"     ,2,1,.F.})
	AADD(_aCpos,{"NOME"          ,"(_tAlias)->NOME"     ,1,1,.F.})
EndIf
If !(Empty (MV_PAR09)) .OR. (MV_PAR14) == 2
	AADD(_aCpos,{"FAMILIA"       ,"(_tAlias)->FAMILIA" ,2,1,.F.})
EndIf
	// - PARAMETRO "DOCUMENTO E SERIE" VALIDOS APENAS PARA O MODELO DA FORMA ANALITICA
	If (MV_PAR14) == 2
		AADD(_aCpos,{"DOCUMENTO"     ,"(_tAlias)->DOC"     ,1,1,.F.})
		AADD(_aCpos,{"SษRIE"         ,"(_tAlias)->SERIE"   ,1,1,.F.})
	EndIf
	// - -----------------------------------------------------------------------------
If !(Empty (MV_PAR11)) .OR. (MV_PAR14) == 2
	AADD(_aCpos,{"PRODUTO"       ,"(_tAlias)->CODIGO"  ,2,1,.F.})
	AADD(_aCpos,{"DESCRIวรO"     ,"(_tAlias)->PRODUTO" ,1,1,.F.})
	AADD(_aCpos,{"1ฐUM"          ,"(_tAlias)->UM"      ,2,1,.F.})
	AADD(_aCpos,{"UM.COM"        ,"(_tAlias)->UMCOM"   ,2,1,.F.})
EndIf
AADD(_aCpos,{"QTD.FAT.(1ฐUM)" ,"(_tAlias)->QTDFAT"   ,3,2,.F.})
AADD(_aCpos,{"PESO COM. FAT." ,"(_tAlias)->PCOM"     ,3,2,.F.})
AADD(_aCpos,{"QTD.DEV.(1ฐUM)" ,"(_tAlias)->QTDDEV"   ,3,2,.F.})
AADD(_aCpos,{"PESO COM.DEV."  ,"(_tAlias)->PCOMDEV"  ,3,2,.F.})
AADD(_aCpos,{"TOTALFAT"       ,"(_tAlias)->TOTALFAT" ,3,2,.F.})
AADD(_aCpos,{"TOTALDEV"       ,"(_tAlias)->TOTALDEV" ,3,2,.F.})
AADD(_aCpos,{"ICMS FAT."      ,"(_tAlias)->ICMFAT"   ,3,2,.F.})
AADD(_aCpos,{"ICMS DEV."      ,"(_tAlias)->ICMDEV"   ,3,2,.F.})
AADD(_aCpos,{"IPI FAT."       ,"(_tAlias)->IPIFAT"   ,3,2,.F.})
AADD(_aCpos,{"IPI DEV."       ,"(_tAlias)->IPIDEV"   ,3,2,.F.})

If !(Empty(MV_PAR13)) .OR. (MV_PAR14) == 2
	AADD(_aCpos,{"TIPO"          ,"(_tAlias)->TIPO"    ,1,1,.F.})
EndIf

//SINTETICO - VERIFICA OS PROXIMOS PARAMETROS
If (MV_PAR14) == 1 
	_cSelFat := " SELECT " +_lEnt
	_cSelDev := " SELECT " +_lEnt

	// VERIFICA PARAMETRO PARA EXPORTAR COLUNA DA DATA DE EMISSรO.
	If (MV_PAR03) == 2
		_cSelFat += " (SUBSTRING(SFD.EMISSAO,7,2) + '/' + SUBSTRING(SFD.EMISSAO,5,2) + '/' + SUBSTRING(SFD.EMISSAO,1,4))[EMISSAO], " +_lEnt
		_cSelDev += " '' [EMISSAO], " +_lEnt
	Else
		_cSelFat += " '' [EMISSAO], " +_lEnt
		_cSelDev += " '' [EMISSAO], " +_lEnt
	EndIf

	// SE PARยMETRO "ATษ ESTADO" ESTIVER PREENCHIDO
	If (MV_PAR06) <> 1
		_cSelFat += " SFD.ESTADO [ESTADO], " +_lEnt
		_cSelDev += " SD1A.ESTADOD [ESTADO], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " ESTADO" +_lEnt
	Else
		_cSelFat += " '' [ESTADO], " +_lEnt
		_cSelDev += " '' [ESTADO], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " ESTADO" +_lEnt
	EndIf

	// SE PARยMETRO "ATษ VENDEDOR" ESTIVER PREENCHIDO
	If (MV_PAR07) <> 1
		_cSelFat += " SFD.VEND[VEND], SFD.NOMEVEND[NOMEVEND], " +_lEnt
		_cSelDev += " SD1A.VENDD[VEND], SD1A.NOMEVENDD [NOMEVEND], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " VEND, NOMEVEND" +_lEnt
	Else
		_cSelFat += " '' [VEND], '' [NOMEVEND], " +_lEnt
		_cSelDev += " '' [VEND], '' [NOMEVEND], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " VEND, NOMEVEND" +_lEnt
	EndIf

	// SE PARยMETRO "CNPJ CENTRAL" ESTIVER PREENCHIDO
	If (MV_PAR04) <> 3
		_cSelFat += " SFD.CGCCENT[CNPJCENT], SFD.NOMECNPJ[NOMECNPJ], " +_lEnt
		_cSelDev += " SD1A.CGCCENTD[CNPJCENT], SD1A.NOMECNPJD [NOMECNPJ], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " CNPJCENT, NOMECNPJ" +_lEnt
	Else
		_cSelFat += " '' [CNPJCENT], '' [NOMECNPJ], " +_lEnt
		_cSelDev += " '' [CNPJCENT], '' [NOMECNPJ], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " CNPJCENT, NOMECNPJ" +_lEnt
	EndIf

	// SE PARยMETRO "ATษ CLIENTE/LOJA" ESTIVER PREENCHIDO
	If (MV_PAR05) <> 1
		_cSelFat += " SFD.CGC[CNPJ], SFD.CLIENTE[CLIENTE], SFD.LOJA[LOJA], SFD.NOME[NOME], " +_lEnt
		_cSelDev += " SD1A.CGCD [CNPJ],SD1A.CLIENTED[CLIENTE],SD1A.LOJAD[LOJA],SD1A.NOMED[NOME], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " CNPJ, CLIENTE, LOJA, NOME" +_lEnt
	Else
		_cSelFat += " '' [CNPJ], '' [CLIENTE], '' [LOJA], '' [NOME], " +_lEnt
		_cSelDev += " '' [CNPJ], '' [CLIENTE], '' [LOJA], '' [NOME], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " CNPJ, CLIENTE, LOJA, NOME" +_lEnt
	EndIf

	// SE PARยMETRO "ATษ FAMILIA" ESTIVER PREENCHIDO
	If !Empty (MV_PAR09)
		_cSelFat += " SFD.FAMILIA[FAMILIA], " +_lEnt
		_cSelDev += " SD1A.FAMILIAD [FAMILIA], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " FAMILIA" +_lEnt
	Else
		_cSelFat += " '' [FAMILIA], " +_lEnt
		_cSelDev += " '' [FAMILIA], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " FAMILIA" +_lEnt
	EndIf

	// SE PARยMETRO "ATษ PRODUTO" ESTIVER PREENCHIDO
	If !Empty (MV_PAR11)
		_cSelFat += " SFD.CODIGO [CODIGO], SFD.DESCRI [PRODUTO], SFD.UM[UM], SFD.UMCOM[UMCOM], " +_lEnt
		_cSelDev += " SD1A.CODIGOD[CODIGO], SD1A.DESCRID[PRODUTO], SD1A.UMD[UM], SD1A.UMCOMERD[UMCOM], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " CODIGO, PRODUTO, UM, UMCOM" +_lEnt
	Else
		_cSelFat += " '' [CODIGO], '' [PRODUTO], '' [UM], '' [UMCOM], " +_lEnt
		_cSelDev += " '' [CODIGO], '' [PRODUTO], '' [UM], '' [UMCOM], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " CODIGO, PRODUTO, UM, UMCOM" +_lEnt
	EndIf

	// SE PARยMETRO "ATษ TIPO" ESTIVER PREENCHIDO
	If !Empty (MV_PAR13)
		_cSelFat += " SFD.TIPO[TIPO], " +_lEnt
		_cSelDev += " SD1A.TIPOD [TIPO], " +_lEnt
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " TIPO" +_lEnt
	Else
		_cSelFat += " '' [TIPO], " +_lEnt
		_cSelDev += " '' [TIPO], " +_lEnt		
		_SelCpos += IIf (Empty(_SelCpos),"",",") + " TIPO" +_lEnt
	EndIf

	If (MV_PAR19) == 1
		// - Sele็ใo dos faturamentos
		_cSelFat += " SUM(SFD.QTDFAT)[QTDFAT],        0 [QTDDEV], "              +_lEnt
		_cSelFat += " SUM(SFD.QTDFAT*SFD.PCOM)[PCOM], 0 [PCOMDEV], "             +_lEnt
		_cSelFat += " SUM(SFD.TOTALFAT)[TOTALFAT],    0 [TOTALDEV], "            +_lEnt
		_cSelFat += " SUM(SFD.ICMFAT)[ICMFAT],        0 [ICMDEV], "              +_lEnt   
		_cSelFat += " SUM(SFD.IPIFAT)[IPIFAT],        0 [IPIDEV] "               +_lEnt
		// - Sele็ใo das devolu็๕es
		_cSelDev += " 0 [QTDFAT],   SUM(SD1A.QUANTD) [QTDDEV], "                  +_lEnt
		_cSelDev += " 0 [PCOM],     SUM (SD1A.QUANTD * SD1A.PCOMERCD) [PCOMDEV]," +_lEnt
		_cSelDev += " 0 [TOTALFAT], SUM(SD1A.TOTDEV) [TOTALDEV],"                 +_lEnt
		_cSelDev += " 0 [ICMFAT],   SUM(SD1A.ICMDEV) [ICMDEV],"                   +_lEnt
		_cSelDev += " 0 [IPIFAT],   SUM(SD1A.IPIDEV) [IPIDEV]"                    +_lEnt
		// - Sele็ใo do Union All
		_SumCpos += +_lEnt + " ,"
		_SumCpos +=	" SUM(QTDFAT)[QTDFAT],     SUM(QTDDEV)[QTDDEV], "            +_lEnt
		_SumCpos += " SUM(PCOM)[PCOM],         SUM(PCOMDEV)[PCOMDEV], "          +_lEnt
		_SumCpos += " SUM(TOTALFAT)[TOTALFAT], SUM(TOTALDEV)[TOTALDEV], "        +_lEnt
		_SumCpos += " SUM(ICMFAT)[ICMFAT],     SUM(ICMDEV)[ICMDEV], "            +_lEnt
		_SumCpos += " SUM(IPIFAT)[IPIFAT],     SUM(IPIDEV)[IPIDEV] "             +_lEnt
	Else
		// - Seleciona com base na View
		_cSelFat += " SUM(SFD.QTDFAT)[QTDFAT], SUM(SFD.QTDDEV)[QTDDEV], "                      +_lEnt
		_cSelFat += " SUM(SFD.QTDFAT*SFD.PCOM)[PCOM], SUM(SFD.QTDDEV*SFD.PCOMDEV)[PCOMDEV], "  +_lEnt
		_cSelFat += " SUM(SFD.TOTALFAT)[TOTALFAT], SUM(SFD.TOTALDEV)[TOTALDEV], "              +_lEnt
		_cSelFat += " SUM(SFD.ICMFAT)[ICMFAT], SUM(SFD.ICMDEV)[ICMDEV], "                      +_lEnt
		_cSelFat += " SUM(SFD.IPIFAT)[IPIFAT], SUM(SFD.IPIDEV)[IPIDEV]  "                      +_lEnt
	EndIf

//ANALITICO - ORIGINAL SEM SOMA POR PRODUTOS IMPRIME RELATORIO POR ITEM
ElseIf (MV_PAR14) == 2 // ANALอTICO
	_cSelFat := " SELECT "                                                                                                       +_lEnt
	_cSelFat += " (SUBSTRING(SFD.EMISSAO,7,2) + '/' + SUBSTRING(SFD.EMISSAO,5,2) + '/' + SUBSTRING(SFD.EMISSAO,1,4))[EMISSAO], " +_lEnt
	_cSelFat += " SFD.ESTADO[ESTADO], "                                                                                          +_lEnt
	_cSelFat += " SFD.VEND[VEND], SFD.NOMEVEND[NOMEVEND], "                                                                      +_lEnt
	_cSelFat += " SFD.CGCCENT[CNPJCENT], SFD.NOMECNPJ[NOMECNPJ], "                                                               +_lEnt
	_cSelFat += " SFD.CGC[CNPJ], SFD.CLIENTE[CLIENTE], SFD.LOJA[LOJA], SFD.NOME[NOME], "                                         +_lEnt
	_cSelFat += " SFD.FAMILIA[FAMILIA], "                                                                                        +_lEnt
	_cSelFat += " SFD.[DOC], SFD.SERIE[SERIE], "                                                                                 +_lEnt
	_cSelFat += " SFD.CODIGO[CODIGO], SFD.DESCRI[PRODUTO], SFD.TIPO[TIPO], "                                                     +_lEnt
	_cSelFat += " SFD.UM[UM], SFD.QTDFAT[QTDFAT], SFD.QTDDEV[QTDDEV], "                                                         +_lEnt
	// - comentado linha para apresenta็ใo da segunda unidade de medida por hora inativa no cliente.
	//_cSelFat += " SFD.UM2[UM2],SFD.QTD2FAT[QTD2FAT], 0 [QTD2DEV] "                                                               +_lEnt
	_cSelFat += " SFD.UMCOM[UMCOM], "                                                                                            +_lEnt
	_cSelFat += " (SFD.QTDFAT * SFD.PCOM)[PCOM], (SFD.QTDDEV * SFD.PCOM)[PCOMDEV], "                                             +_lEnt
	_cSelFat += " SFD.TOTALFAT[TOTALFAT], SFD.TOTALDEV[TOTALDEV], "                                                              +_lEnt
	_cSelFat += " SFD.ICMFAT[ICMFAT], SFD.ICMDEV[ICMDEV], "                                                                      +_lEnt
	_cSelFat += " SFD.IPIFAT[IPIFAT], SFD.IPIDEV[IPIDEV]  "                                                                      +_lEnt
EndIf

// - Sele็ใo da origem
_cQryFat := " FROM SFD_"+cNumEmp+"_001 SFD "                                  +_lEnt
_cQryFat += "     INNER JOIN " + RetSqlName("SA1") + " SA1 "                  +_lEnt
_cQryFat += " 	    ON SA1.D_E_L_E_T_ = '' "                                  +_lEnt
_cQryFat += " 	    AND SA1.A1_MARK <> '' "                                   +_lEnt
_cQryFat += "	    AND SA1.A1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "%' " +_lEnt

_cQryDev := " FROM SD1_"+cNumEmp+"_002 SD1A "                                                       +_lEnt
_cQryDev += "     INNER JOIN " + RetSqlName("SA1") + " SA1 "                                        +_lEnt
_cQryDev += " 	    ON SA1.D_E_L_E_T_ = '' "                                                        +_lEnt
_cQryDev += " 	    AND SA1.A1_MARK <> '' "                                                         +_lEnt
_cQryDev += "	    AND SA1.A1_RELFAT LIKE '%" + (Alltrim(__cUserId)) + "%' "                       +_lEnt

// - WHERE
_cQryFat += " WHERE " +_lEnt
_cQryDev += " WHERE " +_lEnt

// - EMISSAO
_cQryFat += " SFD.EMISSAO    BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " +_lEnt
_cQryDev += " SD1A.DIGITACAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "  +_lEnt

// - FAZ A AMARRAวรO DOS CLIENTES MARCADOS E A TABELA DA VIEW
_cQryFat += " AND SFD.CGCCENT = SA1.A1_CGCCENT " +_lEnt
_cQryFat += " AND SFD.CLIENTE = SA1.A1_COD "     +_lEnt
_cQryFat += " AND SFD.LOJA    = SA1.A1_LOJA "    +_lEnt

_cQryDev += " AND SD1A.CGCCENTD = SA1.A1_CGCCENT " +_lEnt
_cQryDev += " AND SD1A.CLIENTED = SA1.A1_COD "     +_lEnt
_cQryDev += " AND SD1A.LOJAD    = SA1.A1_LOJA "    +_lEnt

// - ATษ FAMILIA
If !Empty (MV_PAR09)
	_cQryFat += " AND SFD.FAMILIA BETWEEN '"+(MV_PAR08)+"' AND '"+(MV_PAR09)+"' " +_lEnt
	_cQryDev += " AND SD1A.FAMILIAD BETWEEN '"+(MV_PAR08)+"' AND '"+(MV_PAR09)+"' " +_lEnt
EndIf

// - SELECIONA DOCUMENTO E SERIE APENAS PARA MODELO ANALITICO
If (MV_PAR14) = 2
	If !Empty (MV_PAR17)
		_cQryFat += " AND SFD.DOC BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR17 + "' "  +_lEnt
	EndIf
	If !Empty (MV_PAR18)
		_cQryFat += " AND SFD.SERIE BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR18 + "' " +_lEnt
	EndIf
EndIf

// - ATษ CODIGO
If !Empty (MV_PAR11)
	_cQryFat += " AND SFD.CODIGO BETWEEN '" +(MV_PAR10)+ "' AND '" +(MV_PAR11)+ "' " +_lEnt
	_cQryDev += " AND SD1A.CODIGOD BETWEEN '" +(MV_PAR10)+ "' AND '" +(MV_PAR11)+ "' " +_lEnt
EndIf

// - ATษ TIPO
If !Empty (MV_PAR13)
	_cQryFat += " AND SFD.TIPO BETWEEN '" +(MV_PAR12)+ "' AND '" +(MV_PAR13)+ "' " +_lEnt
	_cQryDev += " AND SD1A.TIPOD  BETWEEN '" +(MV_PAR12)+ "' AND '" +(MV_PAR13)+ "' " +_lEnt
EndIf

// - AGRUPAMENTO DO MODELO SINTETICO
If (MV_PAR14) == 1
	_cGroup := " GROUP BY " +_lEnt
	// CONSIDERA A DATA DE EMISSรO PARA GERAวAO DO RELATำRIO
	_cGrpFat := ""
	_cGrpDev := ""
	If (MV_PAR03) == 2
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " EMISSAO " +_lEnt
		_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " EMISSAOD " +_lEnt
	EndIf
	// NรO TRAZ A COLUNA DE VENDEDOR SE O PARยMETRO ESTIVER EM BRANCO
	If (MV_PAR07) <> 1
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " VEND, NOMEVEND " +_lEnt
		_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " VENDD, NOMEVENDD " +_lEnt
	EndIf

	// NรO TRAZ COLUNA DE CNPJ CENTRAL SE PARยMETRO ESTIVER EM BRANCO
	If (MV_PAR04) <> 3
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " CGCCENT, NOMECNPJ " +_lEnt
		_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " CGCCENTD, NOMECNPJD " +_lEnt
	EndIf
	
	// NรO TRAZ COLUNA DE CLIENTE/LOJA SE PARยMETRO ESTIVER EM BRANCO
	If (MV_PAR05) <> 1
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " CGC, CLIENTE, LOJA, NOME " +_lEnt
		_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " CGCD, CLIENTED, LOJAD, NOMED " +_lEnt
	EndIf

	// NรO TRAZ COLUNA ESTADO SE O PARยMETRO ESTIVER PREENCHIDO
	If (MV_PAR06) <> 1
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " ESTADO " +_lEnt
		_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " ESTADOD " +_lEnt
	EndIf
	// NรO TRAZ COLUNA FAMILIA SE O PARยMETRO ESTIVER PREENCHIDO
	If  !(Empty(MV_PAR09))
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " FAMILIA " +_lEnt
		_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " FAMILIAD " +_lEnt
	EndIf
	// NรO TRAZ COLUNA PRODUTO SE O PARยMETRO ESTIVER PREENCHIDO
	If !(Empty(MV_PAR11))
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " CODIGO,DESCRI,UM,UMCOM " +_lEnt
		_cGrpDev += IIf (Empty(_cGrpdev),"",",") + " CODIGOD,DESCRID,UMD,UMCOMERD " +_lEnt
	EndIf      
	// NรO TRAZ COLUNA TIPO SE O PARยMETRO ESTIVER PREENCHIDO
	If !Empty(MV_PAR13)
		_cGrpFat += IIf (Empty(_cGrpFat),"",",") + " TIPO " +_lEnt
		_cGrpDev += IIf (Empty(_cGrpDev),"",",") + " TIPOD " +_lEnt
	EndIf

	IIf (Empty(_cGrpFat),_cGroup := "",_cGroup)
	IIf (Empty(_cGrpDev),_cGroup := "",_cGroup)
	
EndIf
_cOrd := " ORDER BY "

If (MV_PAR03) == 2
	_cOrder := " EMISSAO " +_lEnt
EndIf

//DEFINIวรO DA ORDEM PELO USUมRIO
For _k := 1 To Len(_aSbTtt)
	_cOrder += IIf (Empty(_cOrder),"",",") + _aSbTtt[_k][06] +_lEnt
Next

// CONSIDERA FAMILIA SE O PARยMETRO ESTIVER PREENCHIDO
If  !(Empty(MV_PAR09))
	_cOrder += ",FAMILIA"
EndIf                                               

// CONSIDERA PRODUTO SE O PARยMETRO ESTIVER PREENCHIDO
If !(Empty(MV_PAR11))
	_cOrder += ",CODIGO" +_lEnt
EndIf
// - AGRUPA AS QUERYS FORMADAS
If (MV_PAR14) == 1
	If (MV_PAR19) == 1
		_cQuery  := " SELECT " +_lEnt
		_cQuery  += _SelCpos + _SumCpos
		_cQuery  += " FROM ( " +_lEnt
		_cQuery  += _cSelFat + _cQryFat + _cGroup + _cGrpFat
		_cQuery  += _lEnt + " UNION ALL " +_lEnt +_lEnt
		_cQuery  += _cSelDev + _cQryDev + _cGroup + _cGrpDev + _cOrdDev
		_cQuery  += "       ) AMBOS " +_lEnt
		_cQuery  +=	" GROUP BY " + _SelCpos
		_cQuery  +=	" ORDER BY " + _cOrder
	Else
		_cQuery  := _cSelFat + _cQryFat + _cGroup + _cGrpFat + _cOrd +_cOrder
	EndIf
Else
	_cQuery  := _cSelFat + _cQryFat + _cOrd + _cOrder
EndIf

//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_01.TXT",_cQuery)

If (Len(_cQuery) ) >0
	_cQuery := ChangeQuery(_cQuery) // incluido para tratamento no novo processo.
Else
	MSGBOX('NรO FOI POSSอVEL GERAR A CONSULTA. INFORME O ADMINISTRADOR DO SISTEMA','','STOP')
	Return()	
EndIf

// - GERA A QUERY FORMADA
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_tAlias,.T.,.F.)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Geraxls  บAutor  ณ J๚lio Soares       บ Data ณ  15/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsใvel por gerar a planilha conforme dados     บฑฑ
ฑฑบ          ณ obtidos da consulta formada de acordo com parโmetros       บฑฑ
ฑฑบ          ณ inseridos pelo usuแrio.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Geraxls(lEnd)

Local oExcel
Local _cTmpFile := ""
Local _cSheet1  := (DTOC(mv_par01)) + " ~ " + (DTOC(mv_par02))
Local _cSheet2  := 'PARยMETROS'

//Local _cFileTMP  := cGetFile ('Arquivo Arquivo XML|*.xml','Salvar arquivo',0,'C:\Dir\',.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.) //Define o local onde o arquivo serแ gerado
Local _cFileTMP  := cGetFile ('Arquivo XML|*.xml','Salvar Arquivo',0,'C:\',.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.,.F.)
//cMascara Caracter Indica o nome do arquivo ou mแscara.   
//cTitulo Caracter Indica o tํtulo da janela. Caso o parโmetro nใo seja especificado, o tํtulo padrใo serแ apresentado.   
//nMascpadrao Num้rico Indica o n๚mero da mแscara.   
//cDirinicial Caracter Indica o diret๓rio inicial.   
//lSalvar L๓gico Indica se ้ um "save dialog" ou um "open dialog".   
//nOpcoes Num้rico Indica a op็ใo de funcionamento. Para mais informa็๕es das funcionalidades disponํveis, consulte a แrea Observa็๕es.   
//lArvore L๓gico Indica se, verdadeiro (.T.), apresenta o แrvore do servidor; caso contrแrio, falso (.F.).   
//lKeepCase L๓gico Indica se, verdadeiro (.T.), mant้m o case original; caso contrแrio, falso (.F.). 


//Local _cFileTMP := ""
Local _cFile    := ""
Private _aPar   := {}

Private _xTYPE := "Type(_aSbTtt[_nTpST][03])"

dbSelectArea(_tAlias)
ProcRegua(((_tAlias)->(RecCount())*2)+1)
(_tAlias)->(dbGoTop())
If !(_tAlias)->(EOF())
	oExcel := FWMSEXCEL():New()
	oExcel:AddWorkSheet(_cSheet1)
	oExcel:AddTable(_cSheet1,_cTitulo)
	For _x := 1 To Len(_aCpos)
		oExcel:AddColumn(_cSheet1,_cTitulo,_aCpos[_x][01],_aCpos[_x][03],_aCpos[_x][04],_aCpos[_x][05])
	Next

	//Reordeno a sub-totaliza็ใo para apresentar no Excel a ordem Cliente - CNPJ Central - Vendedor - Estado 
	_aSbTtt := aSort(_aSbTtt,,, { |x,y| x[07] > y[07] } )

	// - ACRESCENTA AS LINHAS COM INFORMAวีES WHILE ! TEMP ->(EOF())
	While !(_tAlias)->(EOF()) .AND. !lEnd
		If (MV_PAR14) == 2
			IncProc('PROCESSANDO RELATORIO: '     +_lEnt + AllTrim((_tAlias)->NOME)     + '.')
		ElseIf (MV_PAR07) <> 1
			IncProc('PROCESSANDO REPRESENTANTE: ' +_lEnt + AllTrim((_tAlias)->NOMEVEND) + '.')
		ElseIf (MV_PAR04) <> 3
			IncProc('PROCESSANDO CNPJ CENTRAL: '  +_lEnt + AllTrim((_tAlias)->CNPJCENT) + '.')
		ElseIf (MV_PAR05) <> 1
			IncProc('PROCESSANDO CLIENTE: '       +_lEnt + AllTrim((_tAlias)->NOME)     + '.')
		ElseIf ! Empty (MV_PAR11)
			IncProc('PROCESSANDO PRODUTO: '       +_lEnt + AllTrim((_tAlias)->PRODUTO)  + '.')
		EndIf

		//Trecho para impressใo dos sub-totais
		For _sT := 1 To Len(_aSbTtt)
			If _aSbTtt[_sT][08]
				_nReg  := 0
				_aAux  := ARRAY(Len(_aCpos))
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

		//Trecho para impressใo das linhas (detalhes)
		_aAux := {}

		// - CRIO AS COLUNAS DE ACORDO COM A QUERY MONTADA
		For _x := 1 To Len(_aCpos)

			//Coleta as informa็๕es campo a campo para o analํtico
			AADD(_aAux, &(_aCpos[_x][02]))

			//มrea dos totais e sub-totais
			If ValType(&(_aCpos[_x][02]))=="N"

				//C๔mputo dos totais
				_nPColN := aScan(_aTtt, {|k| k[01] == _x})
				If _nPColN == 0
					AADD(_aTtt,{_x,&(_aCpos[_x][02])})
				Else
					_aTtt[_nPColN][02] += &(_aCpos[_x][02])
				EndIf

				//C๔mputo dos sub-totais
				
				For _nTpST := 1 To Len(_aSbTtt)
					If _aSbTtt[_nTpST][08] .AND. &(_xTYPE) <>"U"
						_nPColN := aScan(_aSbTtt[_nTpST][02], {|k| k[01] == _x})
						If _nPColN == 0
							AADD(_aSbTtt[_nTpST][02],{_x,&(_aCpos[_x][02]),&(_aSbTtt[_nTpST][03]),&(_aSbTtt[_nTpST][05])})
						Else
							_aSbTtt[_nTpST][02][_nPColN][02] += &(_aCpos[_x][02])
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

	//oExcel:AddRow(_cSheet1, _cTitulo, _aAux5)	
	If lEnd
		Alert("Abortado!")
		FreeObj(oExcel)
		oExcel := NIL
		Return
	EndIf

	//Trecho para impressใo dos sub-totais
	For _sT := 1 To Len(_aSbTtt)
		_nReg  := 0
		_aAux  := ARRAY(Len(_aCpos))
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

	//Impressใo do TOTAL GERAL
	_aAux    := ARRAY(Len(_aCpos))
	_aAux[1] := "TOTAL GERAL "
	For _k := 1 To Len(_aTtt)
		_aAux[_aTtt[_k][01]] := _aTtt[_k][02]
	Next
	oExcel:AddRow(_cSheet1, _cTitulo, _aAux )

	// - INCLUI UMA ABA COM AS INFORMAวีES DOS PARAMETROS
	oExcel:AddWorkSheet(_cSheet2)
	oExcel:AddTable(_cSheet2,_cTitulo2)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"DESCRIวรO" ,1,1,.F.)
	oExcel:AddColumn(_cSheet2,_cTitulo2,"CONTEฺDO"  ,1,1,.F.)

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	_cPerg := PADR(_cPerg,10)

	If (_cAliasSX1)->(dbSeek(_cPerg))
		While !EOF() .And. (_cAliasSX1)->X1_GRUPO == _cPerg
			IncProc('PROCESSANDO PARAMETROS...')
			If AllTrim((_cAliasSX1)->X1_GSC)=="C"
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&("(_cAliasSX1)->X1_DEF"+StrZero(&((_cAliasSX1)->X1_VAR01),2)) })
			Else
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
			EndIf
			dbSelectArea(_cAliasSX1)
			(_cAliasSX1)->(dbSkip())
		EndDo
	EndIf
	If Len(_aPar) > 0
		For _nPosPar := 1 To Len(_aPar)
			oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
		Next
	EndIf

	// - IMPRIME O RELATำRIO NO EXCEL
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
		
		//Caso nใo tenha sido definido um local, o arquivo serแ gerado na pasta TEMP
		If Empty(_cFileTMP)
			_cFileTMP := (GetTempPath() + _cFile)
		EndIf
		
		If !(__CopyFile(_cFile , _cFileTMP))
			MsgStop("Aten็ใo! Nใo foi possํvel salvar o arquivo no caminho " + _cFileTMP + ". Portanto, a rotina tentarแ salvar o arquivo no seguinte caminho: " + (GetTempPath() + _cFile),_cRotina+"_11")
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
		
		IncProc('RELATำRIO GERADO COM SUCESSO!')
		MsgBox('O arquivo foi salvo no local '+ _cFile +'.',_cRotina+"_10",'INFO')
		oMsExcel:= oMsExcel:Destroy()

	// - TRECHO ANTIGO.
	/*
	oExcel:Activate()
	_cFile := (CriaTrab(NIL, .F.) + ".xml")
	IncProc("VERIFICANDO ARQUIVO GERADO.")
	oExcel:GetXMLFile(_cFile)
	oExcel:DeActivate()
	If !(File(_cFile))
		IncProc('ARQUIVO NAO ENCONTRADO.')
		_cFile := ""
		Break
	EndIf
	_cFileTMP := (GetTempPath() + _cFile)
	If !(__CopyFile(_cFile , _cFileTMP))
		IncProc('VERIFICANDO ARQUIVO NO SERVIDOR.')
		fErase( _cFile )
		_cFile := ""
		Break
	EndIf
	fErase(_cFile)
	_cFile := _cFileTMP
	If !(File(_cFile))
		IncProc('ARQUIVO AINDA NรO GERADO.')
		_cFile := ""
		Break
	EndIf
	IncProc('ABRINDO ARQUIVO.')
	Sleep(5000)
	oMsExcel:= MsExcel():New()
	oMsExcel:WorkBooks:Open(_cFile)
	oMsExcel:SetVisible(.T.)
	IncProc('RELATำRIO GERADO COM SUCESSO!')
	*/
Else
	MSGBOX('Nใo hแ dados a serem apresentados. Verifique os parโmetros informados. ',_cRotina+'_11','ALERT')
	Return()
EndIf

FreeObj(oExcel)
oExcel := NIL

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SelOrdem บAutor  ณ J๚lio Soares       บ Data ณ  06/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta uma tela para a sele็ใo da ordem das sub-totaliza็๕esบฑฑ
ฑฑบ          ณ a serem apresentadas no relat๓rio.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelOrdem()

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
// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
//Local _aOpc       := {"ESTADO","VENDEDOR","CNPJ CENTRALIZADOR","CLIENTE"}
Local _aOpc       := {"ESTADO","REPRESENTANTE","CNPJ CENTRALIZADOR","CLIENTE"}
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

nListBox1 := "ESTADO"
// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
//nListBox2 := "VENDEDOR"
nListBox2 := "REPRESENTANTE"
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

nListBox3 := "CNPJ CENTRALIZADOR"
nListBox4 := "CLIENTE"

Static oDlg

  DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] ORDEM" FROM 000, 000  TO 300, 350 COLORS 0, 16777215 PIXEL

    @ 004, 006 GROUP oGroup1 TO 145, 168 PROMPT " Selecione a Ordem para os Registros no Relat๓rio " OF oDlg COLOR 0, 16777215 PIXEL

    @ 029, 013 SAY oSay1 PROMPT "Ordem 1:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 029, 046 MSCOMBOBOX oListBox1 VAR nListBox1 ITEMS _aOpc SIZE 093, 011 OF oDlg COLORS 0, 16777215 PIXEL

    @ 049, 013 SAY oSay2 PROMPT "Ordem 2:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 049, 046 MSCOMBOBOX oListBox2 VAR nListBox2 ITEMS _aOpc SIZE 093, 011 OF oDlg COLORS 0, 16777215 PIXEL

    @ 069, 013 SAY oSay3 PROMPT "Ordem 3:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 069, 046 MSCOMBOBOX oListBox3 VAR nListBox3 ITEMS _aOpc SIZE 093, 011 OF oDlg COLORS 0, 16777215 PIXEL

    @ 089, 013 SAY oSay4 PROMPT "Ordem 4:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 089, 046 MSCOMBOBOX oListBox4 VAR nListBox4 ITEMS _aOpc SIZE 093, 011 OF oDlg COLORS 0, 16777215 PIXEL

    @ 120, 120 BUTTON oButton1 PROMPT "&Confirma" SIZE 037, 012 OF oDlg PIXEL ACTION Close(oDlg)

  ACTIVATE MSDIALOG oDlg CENTERED

nListBox1 := aScan(_aOpc,nListBox1)
nListBox2 := aScan(_aOpc,nListBox2)
nListBox3 := aScan(_aOpc,nListBox3)
nListBox4 := aScan(_aOpc,nListBox4)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ ValidPerg บ Autor ณJ๚lio Soares         บ Data ณ  04/10/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo responsแvel pela inclusใo de parโmetros na rotina.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Local _aSArea  := GetArea()
Local aHelpPor := {}
//Local aHelpSpa := {}
//Local aHelpEng := {}

_cPerg := PADR(_cPerg,10)

// - 01
/* FB -  RELEASE 12.1.23
AAdd(aHelpPor,"Insira a data inicial da emissใo dos "   )
AAdd(aHelpPor,"documentos."                             )
PutSx1(_cPerg,"01","De Data?"                  ,"" ,"" ,"mv_ch1","D" ,08 ,0 ,0 ,"G" ,"NAOVAZIO()",""    ,"" ,"S" ,"mv_par01" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Insira a data inicial da emissใo dos documentos."
U_RGENA001(_cPerg, "01", "De Data?" , "MV_PAR01", "MV_CH1", "D", 08, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 02
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Insira a data final da emissใo dos "     )
AAdd(aHelpPor,"documentos."                             )
PutSx1(_cPerg,"02","At้ Data?"                 ,"" ,"" ,"mv_ch2","D" ,08 ,0 ,0 ,"G" ,"NAOVAZIO()",""    ,"" ,"S" ,"mv_par02" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Insira a data final da emissใo dos documentos."
U_RGENA001(_cPerg, "02" ,"At้ Data?" , "MV_PAR02", "MV_CH2", "D", 08, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 03
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione SIM ou NAO para que a coluna " )
AAdd(aHelpPor,"das datas seja apresentada no relat๓rio.")
PutSx1(_cPerg,"03","Imprime Data Emissใo?"     ,"" ,"" ,"mv_ch3","N" ,01 ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par03" ,"Nao"         ,"" ,"" ,"" ,"Sim"            ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Selecione SIM ou NAO para que a coluna das datas seja apresentada no relat๓rio."
U_RGENA001(_cPerg, "03" ,"Imprime Data Emissใo?"  , "MV_PAR03", "MV_CH2", "N", 01, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


// - 04
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione NAO para que a coluna nใo seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"04","CNPJ-Central?"             ,"" ,"" ,"mv_ch4","N" ,01 ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par04" ,"Totaliza"    ,"" ,"" ,"" ,"Apresenta"      ,"" ,"" ,"Nao"       ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Selecione NAO para que a coluna nใo seja apresentada, APRESENTA para que seja apresentada e TOTALIZA para que seja apresentada com os subtotais referentes."
U_RGENA001(_cPerg, "04" ,"CNPJ-Central?"  , "MV_PAR04", "MV_CH4", "N", 01, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


// - 05
/* FB -  RELEASE 12.1.23
AAdd(aHelpPor,"Selecione NAO para que a coluna nใo seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"05","Cliente + Loja?"           ,"" ,"" ,"mv_ch5","N" ,01 ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par05" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Selecione NAO para que a coluna nใo seja apresentada, APRESENTA para que seja apresentada e TOTALIZA para que seja apresentada com os subtotais referentes."
U_RGENA001(_cPerg, "05" ,"Cliente + Loja?"  , "MV_PAR05", "MV_CH5", "N", 01, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 06
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione NAO para que a coluna nใo seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"06","Estado?"                   ,"" ,"" ,"mv_ch6","N" ,01 ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par06" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Selecione NAO para que a coluna nใo seja apresentada, APRESENTA para que seja apresentada e TOTALIZA para que seja apresentada com os subtotais referentes."
U_RGENA001(_cPerg, "06" ,"Estado?"  , "MV_PAR06", "MV_CH6", "N", 01, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 07
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione NAO para que a coluna nใo seja")
AAdd(aHelpPor,"apresentada, APRESENTA para que seja "   )
AAdd(aHelpPor,"apresentada e TOTALIZA para que seja "   )
AAdd(aHelpPor,"apresentada com os subtotais referentes.")
PutSx1(_cPerg,"07","Vendedor?"                 ,"" ,"" ,"mv_ch7","N" ,01 ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par07" ,"Nao"         ,"" ,"" ,"" ,"Totaliza"       ,"" ,"" ,"Apresenta" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Selecione NAO para que a coluna nใo seja apresentada, APRESENTA para que seja apresentada e TOTALIZA para que seja apresentada com os subtotais referentes."

// Altera็ใo - Fernando Bombardi - ALLSS - 02/03/2022
//U_RGENA001(_cPerg, "07" ,"Vendedor?" , "MV_PAR07", "MV_CH7", "N", 01, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
U_RGENA001(_cPerg, "07" ,"Representante?" , "MV_PAR07", "MV_CH7", "N", 01, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
// Fim - Fernando Bombardi - ALLSS - 02/03/2022

// - 08
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione a familia inicial da pesquisa ")
AAdd(aHelpPor,"caso queira que essa coluna seja "       )
AAdd(aHelpPor,"apresentada no relat๓rio."               )
PutSx1(_cPerg,"08","De Famํlia?"               ,"" ,"" ,"mv_ch8","C" ,02 ,0 ,0 ,"G" ,""          ,"SBM" ,"" ,"S" ,"mv_par08" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := "SBM"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione a familia inicial da pesquisa caso queira que essa coluna seja apresentada no relat๓rio."
U_RGENA001(_cPerg, "08" ,"De Famํlia?" , "MV_PAR08", "MV_CH8", "C", 02, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 09
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione a familia final da pesquisa "  )
AAdd(aHelpPor,"caso queira que essa coluna seja "       )
AAdd(aHelpPor,"apresentada no relat๓rio."               )
PutSx1(_cPerg,"09","At้ Famํlia?"              ,"" ,"" ,"mv_ch9","C" ,02 ,0 ,0 ,"G" ,""          ,"SBM" ,"" ,"S" ,"mv_par09" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := "SBM"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione a familia inicial da pesquisa caso queira que essa coluna seja apresentada no relat๓rio."
U_RGENA001(_cPerg, "09" ,"At้ Famํlia?" , "MV_PAR09", "MV_CH9", "C", 02, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 10
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione o produto inicial da pesquisa ")
AAdd(aHelpPor,"caso queira que essa coluna seja "       )
AAdd(aHelpPor,"apresentada no relat๓rio."               )
PutSx1(_cPerg,"10","De Produto?"               ,"" ,"" ,"mv_cha","C" ,15 ,0 ,0 ,"G" ,""          ,"SB1" ,"" ,"S" ,"mv_par10" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := "SB1"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione o produto inicial da pesquisa caso queira que essa coluna seja apresentada no relat๓rio."
U_RGENA001(_cPerg, "10" ,"De Produto?"  , "MV_PAR10", "MV_CHA", "C", 15, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 11
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione o produto final da pesquisa "  )
AAdd(aHelpPor,"caso queira que essa coluna seja "       )
AAdd(aHelpPor,"apresentada no relat๓rio."               )
PutSx1(_cPerg,"11","At้ Produto?"              ,"" ,"" ,"mv_chb","C" ,15 ,0 ,0 ,"G" ,""          ,"SB1" ,"" ,"S" ,"mv_par11" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := "SB1"
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione o produto final da pesquisa caso queira que essa coluna seja apresentada no relat๓rio."
U_RGENA001(_cPerg, "11" ,"At้ Produto?"  , "MV_PAR11", "MV_CHB", "C", 15, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 12
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione o tipo do produto inicial da " )
AAdd(aHelpPor,"pesquisa caso queira que essa coluna "   )
AAdd(aHelpPor,"seja apresentada no relat๓rio."          )
PutSx1(_cPerg,"12","De Tipo?"                  ,"" ,"" ,"mv_chc","C" ,02 ,0 ,0 ,"G" ,""          ,"02"  ,"" ,"S" ,"mv_par12" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Selecione o tipo do produto inicial da pesquisa caso queira que essa coluna seja apresentada no relat๓rio."
U_RGENA001(_cPerg, "12" ,"De Tipo?" , "MV_PAR12", "MV_CHC", "C", 02, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 13
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione o tipo do produto final da "   )
AAdd(aHelpPor,"pesquisa caso queira que essa coluna "   ) 
AAdd(aHelpPor,"seja apresentada no relat๓rio."          )
PutSx1(_cPerg,"13","At้ Tipo?"                 ,"" ,"" ,"mv_chd","C" ,02 ,0 ,0 ,"G" ,""          ,"02"  ,"" ,"S" ,"mv_par13" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Selecione o tipo do produto final da pesquisa caso queira que essa coluna seja apresentada no relat๓rio."
U_RGENA001(_cPerg, "13" ,"At้ Tipo?"  , "MV_PAR13", "MV_CHD", "C", 02, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 14
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Selecione o tipo do relat๓rio: "         )
AAdd(aHelpPor,"  1. Sint้tico apresenta as informa็๕es ")
AAdd(aHelpPor,"  resumidas."                            )
AAdd(aHelpPor,"  2. Anแlitico apresenta as informa็๕es ")
AAdd(aHelpPor,"  detalhadas."                           )
PutSx1(_cPerg,"14","Tipo do relat๓rio?"        ,"" ,"" ,"mv_che","N" ,01 ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par14" ,"Sint้tico"   ,"" ,"" ,"" ,"Analํtico"      ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "Sint้tico"
_cDef02   := "Analํtico"
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "Selecione o tipo do relat๓rio: 1. Sint้tico apresenta as informa็๕es resumidas. 2. Anแlitico apresenta as informa็๕es detalhadas."
U_RGENA001(_cPerg, "14" ,"Tipo do relat๓rio?"  , "MV_PAR14", "MV_CHE", "N", 01, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 15
/* FB - RELEASE 12.1.13
AAdd(aHelpPor,"Informe o numero do documento inicial "  )
AAdd(aHelpPor,"caso queira que essa coluna seja "       )
AAdd(aHelpPor,"apresentada no relat๓rio. "              )
AAdd(aHelpPor," - ESSA INFORMAวรO DEVE SER PREENCHIDA " )
AAdd(aHelpPor," APENAS PARA O RELATำRIO ANALอTICO."     )
PutSx1(_cPerg,"15","De Documento ?"            ,"" ,"" ,"mv_chf","C" ,09 ,0 ,0 ,"G" ,""          ,"SF2" ,"" ,"S" ,"mv_par15" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Informe o numero do documento inicial caso queira que essa coluna seja apresentada no relat๓rio.  - ESSA INFORMAวรO DEVE SER PREENCHIDA  APENAS PARA O RELATำRIO ANALอTICO."
U_RGENA001(_cPerg, "15" ,"De Documento ?" , "MV_PAR15", "MV_CHF", "C", 09, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 16
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Informe o numero da s้rie inicial caso " )
AAdd(aHelpPor,"queira que essa coluna seja apresentada" )
AAdd(aHelpPor,"no relat๓rio. "                          )
AAdd(aHelpPor," - ESSA INFORMAวรO DEVE SER PREENCHIDA " )
AAdd(aHelpPor,"APENAS PARA O RELATำRIO ANALอTICO E "    )
AAdd(aHelpPor,"JUNTO COM O PREENCHIMENTO DO DOCUMENTO " )
AAdd(aHelpPor," INICIAL."                               )
PutSx1(_cPerg,"16","De S้rie?"                 ,"" ,"" ,"mv_chg","C" ,03 ,0 ,0 ,"G" ,""          ,""    ,"" ,"S" ,"mv_par16" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Informe o numero da s้rie inicial caso queira que essa coluna seja apresentada no relat๓rio.  - ESSA INFORMAวรO DEVE SER PREENCHIDA APENAS PARA O RELATำRIO ANALอTICO E JUNTO COM O PREENCHIMENTO DO DOCUMENTO INICIAL."
U_RGENA001(_cPerg, "16" ,"De S้rie?" , "MV_PAR16", "MV_CHG", "C", 03, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 17
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Informe o numero do documento final "    )
AAdd(aHelpPor,"caso queira que essa coluna seja "       )
AAdd(aHelpPor,"apresentada no relat๓rio. "              )
AAdd(aHelpPor," - ESSA INFORMAวรO DEVE SER PREENCHIDA " )
AAdd(aHelpPor," APENAS PARA O RELATำRIO ANALอTICO."     )
PutSx1(_cPerg,"17","At้ Documento ?"           ,"" ,"" ,"mv_chh","C" ,09 ,0 ,0 ,"G" ,""          ,"SF2" ,"" ,"S" ,"mv_par17" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Informe o numero do documento final caso queira que essa coluna seja apresentada no relat๓rio. - ESSA INFORMAวรO DEVE SER PREENCHIDA APENAS PARA O RELATำRIO ANALอTICO."
U_RGENA001(_cPerg, "17" ,"At้ Documento ?" , "MV_PAR17", "MV_CHH", "C", 09, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 18
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"Informe o numero da s้rie final caso "   )
AAdd(aHelpPor,"queira que essa coluna seja apresentada ")
AAdd(aHelpPor,"no relat๓rio. "                          )
AAdd(aHelpPor," - ESSA INFORMAวรO DEVE SER PREENCHIDA " )
AAdd(aHelpPor,"APENAS PARA O RELATำRIO ANALอTICO E "    )
AAdd(aHelpPor,"JUNTO COM O PREENCHIMENTO DO DOCUMENTO " )
AAdd(aHelpPor," FINAL."                                 )
PutSx1(_cPerg,"18","At้ S้rie?"                ,"" ,"" ,"mv_chi","C" ,03 ,0 ,0 ,"G" ,""          ,""    ,"" ,"S" ,"mv_par18" ,""            ,"" ,"" ,"" ,""               ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
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
_cHelp    := "Informe o numero da s้rie final caso queira que essa coluna seja apresentada no relat๓rio.  - ESSA INFORMAวรO DEVE SER PREENCHIDA APENAS PARA O RELATำRIO ANALอTICO E JUNTO COM O PREENCHIMENTO DO DOCUMENTO FINAL."
U_RGENA001(_cPerg, "18" ,"At้ S้rie?"  , "MV_PAR18", "MV_CHI", "C", 03, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

// - 19
/* FB - RELEASE 12.1.23
AAdd(aHelpPor,"DEVOLUวรO - Base na Nota fiscal de "     )
AAdd(aHelpPor,"devolu็ใo "                              )
AAdd(aHelpPor,""                                        )
AAdd(aHelpPor,"VENDA (Orig) - Base na Nota fiscal de "  )
AAdd(aHelpPor,"venda (documento original) "             )
PutSx1(_cPerg,"19","Apropria็ใo da devolu็ใo?" ,"" ,"" ,"mv_chJ","N" ,01 ,0 ,1 ,"C" ,""          ,""    ,"" ,"S" ,"mv_par19" ,"NF Devolu็ใo" ,"" ,"" ,"" ,"NF Venda(Orig)" ,"" ,"" ,""          ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,aHelpPor,,,)
aHelpPor := {}
*/
_cPerg    := _cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := "NF Devolu็ใo"
_cDef02   := "NF Venda(Orig)"
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := "DEVOLUวรO - Base na Nota fiscal de devolu็ใo VENDA (Orig) - Base na Nota fiscal de venda (documento original) venda (documento original)"
U_RGENA001(_cPerg, "19" ,"Apropria็ใo da devolu็ใo?" , "MV_PAR19", "MV_CHJ", "N", 01, 0, "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

RestArea(_aSArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ChekView บAutor  ณ J๚lio Soares       บ Data ณ  04/29/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Por seguran็a foi criado a verifica็ใo da exist๊ncia das   บฑฑ
ฑฑบ          ณ Views                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para empresa ARCOLOR              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

// - (FWCompany("SE1") + FWUnitBusiness("SE1") + FWFilial("SE1"))

// - VERIFICA VIEW SD1
_cQryCheck := " SELECT TOP 1 SD1.CLIENTE " +_lEnt
_cQryCheck += " FROM SD1_"+cNumEmp+"_001 SD1 "
If TCSQLExec(_cQryCheck) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_06")
	Return(Nil)
EndIf
TCQUERY _cQryCheck NEW ALIAS "TMPSD1"
/*
If Empty(TMPSD1->(CLIENTE))
	MSGBOX('NรO FOI POSSอVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECUวรO DO RELATำRIO. INFORME O ADMINISTRADOR DO SISTEMA','V_SD1','STOP')
//	_createSD1()
Else
	Return(Nil)
EndIf
*/

// - VERIFICA VIEW SD2
_cQryCheck := " SELECT TOP 1 SD2.CLIENTE " +_lEnt
_cQryCheck += " FROM SD2_"+cNumEmp+"_001 SD2 "
If TCSQLExec(_cQryCheck) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_07")
	Return(Nil)
EndIf
TCQUERY _cQryCheck NEW ALIAS "TMPSD2"
/*
If Empty(TMPSD2->(CLIENTE))
	MSGBOX('NรO FOI POSSอVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECUวรO DO RELATำRIO. INFORME O ADMINISTRADOR DO SISTEMA','V_SD2','STOP')
//	_createSD2()
Else
	Return(Nil)
EndIf
*/

// - VERIFICA VIEW SF2
_cQryCheck := " SELECT TOP 1 SF2.CLIENTE " +_lEnt
_cQryCheck += " FROM SF2_"+cNumEmp+"_001 SF2 "
If TCSQLExec(_cQryCheck) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_08")
	Return(Nil)
EndIf
TCQUERY _cQryCheck NEW ALIAS "TMPSF2"
/*
If Empty(TMPSF2->(CLIENTE))
	MSGBOX('NรO FOI POSSอVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECUวรO DO RELATำRIO. INFORME O ADMINISTRADOR DO SISTEMA','V_SF2','STOP')
//	_createSF2()
Else
	Return(Nil)
EndIf
*/

// - VERIFICA VIEW SFD
_cQryCheck := " SELECT TOP 1 SFD.CLIENTE " +_lEnt
_cQryCheck += " FROM SFD_"+cNumEmp+"_001 SFD "
If TCSQLExec(_cQryCheck) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_09")
	Return(Nil)
EndIf
TCQUERY _cQryCheck NEW ALIAS "TMPSFD"
/*
If Empty(TMPSFD->(CLIENTE))
	MSGBOX('NรO FOI POSSอVEL ENCONTRAR A ESTRUTURA INTEGRA PARA A EXECUวรO DO RELATำRIO. INFORME O ADMINISTRADOR DO SISTEMA','V_SFD','STOP')
//	_createSFD()
Else
	Return(Nil)
EndIf
*/

