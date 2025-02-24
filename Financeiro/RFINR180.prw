#INCLUDE "FINR180.CH"
#Include "PROTHEUS.Ch"
#INCLUDE "RWMAKE.CH"

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR180  ³ Autor ³ Adrianne Furtado      ³ Data ³ 02.09.06 ³±±
±±³Alterado  ³ RFINR180 ³ Autor ³ Thiago S. de Almeida  ³ Data ³ 27.12.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rela‡„o das baixas por lote                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alterado: ³ Validação para filtragem dos dados conforme a tabela SZ3   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINR180(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RFINR180()

Local oReport

If .F.//FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FinR180R3()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Adrianne Furtado       ³ Data ³14.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport 
Local oSection 
Local oCell         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("RFINR180",OemToAnsi(STR0011),"RFIN180", {|oReport| ReportPrint(oReport)},STR0001+" "+STR0002) //"Relacao de Baixas por Lote"##"Este programa ira emitir a relacao dos titulos baixados"##"por Lote."
Pergunte("FIN180",.F.)

oBaixas := TRSection():New(oReport,"Baixas",{"SE5"},{})
oBaixas:SetHeaderPage()    
oBaixas:SetTotalInLine(.F.)

TRCell():New(oBaixas,"E5_LOTE"		,, STR0012,,         9,         .F.)	//"Lote"
TRCell():New(oBaixas,"E5_PREFIXO"	,, STR0013,,         4,         .F.)	//"Prf"
TRCell():New(oBaixas,"E5_NUMERO" 	,, STR0014,,         9,         .F.)	//"Numero"  
TRCell():New(oBaixas,"E5_PARCELA"	,, STR0015,,         2,         .F.)	//"PC"
TRCell():New(oBaixas,"CLIENTE/FORN"	,, STR0016,,        20,         .F.)	//"Cliente/Forn"
TRCell():New(oBaixas,"E5_VALOR"		,, STR0017,, /*nSize*/,/*[lPixel]*/)	//"Valor Original"
TRCell():New(oBaixas,"E5_DATA"		,, STR0018,,         9,         .F.)	//"Data Baixa"
TRCell():New(oBaixas,"DESCONTO"		,, STR0019,, /*nSize*/,/*[lPixel]*/)	//"Descontos"
TRCell():New(oBaixas,"JUROS"		,, STR0020,, /*nSize*/,/*[lPixel]*/)	//"Juros"
TRCell():New(oBaixas,"MULTA"		,, STR0021,, /*nSize*/,/*[lPixel]*/)	//"Multas"
TRCell():New(oBaixas,"CORRECAO"		,, STR0022,, /*nSize*/,/*[lPixel]*/)	//"Corr Monet"
TRCell():New(oBaixas,"ABATIMENTO"	,, STR0023,, /*nSize*/,/*[lPixel]*/)	//"Abatimentos"
TRCell():New(oBaixas,"VL_PG/VL_RCB"	,, ""	  ,, /*nSize*/,/*[lPixel]*/)	//"Valor Recebido"

oReport:NoUserFilter()

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Nereu Humberto Junior  ³ Data ³16.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/           
//PALAVRA CHAVE PARA CUSTOMIZAÇÕES - CUSTOMIZAÇÃO

Static Function ReportPrint(oReport)
Local oBaixas	:= oReport:Section(1)
//Local cAliasSE5	:= "SE5"
Local cTitulo 	:= "" 
Local cChave 	:= ""
Local bFirst
Local oBreak1
Local aRelat	:={}	   
Local nI            
Local nTotBaixado := 0                 
Private cFilterUser := oBaixas:GetAdvplExp("SE5")


//CUSTOMIZAÇÃO
//FIXAÇÃO DOS PARÂMETROS, PARA ATENDIMENTO A ROTINA PADRÃO - ALTERADO - Thiago Silva de Almeida - 27/12/12
MV_PAR02 := MV_PAR01
MV_PAR03 := 1
MV_PAR04 := 1
MV_PAR05 := 2
//FIM DA CUSTOMIZAÇÃO


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF mv_par03==1
	cTitulo:=OemToAnsi(STR0005)+ mv_par01+OemToAnsi(STR0006)+mv_par02  //"Relacao dos Titulos Recebidos do Lote "### " a "
	oBaixas:Cell("VL_PG/VL_RCB"):SetTitle(STR0024)
Else
	cTitulo:=OemToAnsi(STR0007)+mv_par01+OemToAnsi(STR0006)+mv_par02  //"Relacao dos Titulos Pagos do Lote "###" a "
	oBaixas:Cell("VL_PG/VL_RCB"):SetTitle(STR0025)
EndIF

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aRelat[x][01]: "Lote"			³
//³         [02]: "Prf" 			³
//³         [03]: "Numero"			³
//³         [04]: "PC"				³
//³         [05]: "Cliente/Forn"	³
//³         [06]: "Valor Original"	³
//³         [07]: "Data Baixa"      ³
//³         [08]: "Descontos"       ³
//³         [09]: "Juros"       	³
//³         [10]: "Multas"    		³
//³         [11]: "Corr Monet"   	³
//³         [12]: "Abatimentos"    	³
//³         [13]: "Valor Recebido" 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aRelat := FA180ImpR4()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBaixas:Cell("E5_LOTE")		:SetBlock( { || aRelat[nI,01] } )
oBaixas:Cell("E5_PREFIXO")	:SetBlock( { || aRelat[nI,02] } )
oBaixas:Cell("E5_NUMERO")	:SetBlock( { || aRelat[nI,03] } )
oBaixas:Cell("E5_PARCELA")	:SetBlock( { || aRelat[nI,04] } )
oBaixas:Cell("CLIENTE/FORN"):SetBlock( { || aRelat[nI,05] } )
oBaixas:Cell("E5_VALOR")	:SetBlock( { || aRelat[nI,06] } )
oBaixas:Cell("E5_DATA")		:SetBlock( { || aRelat[nI,07] } )
oBaixas:Cell("DESCONTO")	:SetBlock( { || aRelat[nI,08] } )
oBaixas:Cell("JUROS")		:SetBlock( { || aRelat[nI,09] } )
oBaixas:Cell("MULTA")		:SetBlock( { || aRelat[nI,10] } )
oBaixas:Cell("CORRECAO")	:SetBlock( { || aRelat[nI,11] } )
oBaixas:Cell("ABATIMENTO")	:SetBlock( { || aRelat[nI,12] } )
oBaixas:Cell("VL_PG/VL_RCB"):SetBlock( { || aRelat[nI,13] } )

oBreak1 := TRBreak():New( oBaixas, oBaixas:Cell("E5_LOTE"), "")         
TRFunction():New(oBaixas:Cell("DESCONTO")	 	,/*[cID*/, "SUM", oBreak1  , "", PesqPict("SE5","E5_VALOR",15,MV_PAR04), /*[ uFormula ]*/ , .T., .F.) 
TRFunction():New(oBaixas:Cell("JUROS")			,/*[cID*/, "SUM", oBreak1  , "", PesqPict("SE5","E5_VALOR",15,MV_PAR04), /*[ uFormula ]*/ , .T., .F.) 
TRFunction():New(oBaixas:Cell("MULTA")	 		,/*[cID*/, "SUM", oBreak1  , "", PesqPict("SE5","E5_VALOR",15,MV_PAR04), /*[ uFormula ]*/ , .T., .F.) 
TRFunction():New(oBaixas:Cell("CORRECAO")	 	,/*[cID*/, "SUM", oBreak1  , "", PesqPict("SE5","E5_VALOR",15,MV_PAR04), /*[ uFormula ]*/ , .T., .F.) 
TRFunction():New(oBaixas:Cell("ABATIMENTO") 	,/*[cID*/, "SUM", oBreak1  , "", PesqPict("SE5","E5_VALOR",15,MV_PAR04), /*[ uFormula ]*/ , .T., .F.) 
TRFunction():New(oBaixas:Cell("VL_PG/VL_RCB")	,/*[cID*/, "SUM", oBreak1  , "", PesqPict("SE5","E5_VALOR",16,MV_PAR04), /*[ uFormula ]*/ , .T., .F.) 

oBaixas:Cell("E5_VALOR")	:SetPicture(PesqPict("SE5","E5_VALOR",16,MV_PAR04))
oBaixas:Cell("DESCONTO")	:SetPicture(PesqPict("SE5","E5_VALOR",15,MV_PAR04))
oBaixas:Cell("JUROS")		:SetPicture(PesqPict("SE5","E5_VALOR",15,MV_PAR04))
oBaixas:Cell("MULTA")		:SetPicture(PesqPict("SE5","E5_VALOR",15,MV_PAR04))
oBaixas:Cell("CORRECAO")	:SetPicture(PesqPict("SE5","E5_VALOR",15,MV_PAR04))
oBaixas:Cell("ABATIMENTO")	:SetPicture(PesqPict("SE5","E5_VALOR",15,MV_PAR04))
oBaixas:Cell("VL_PG/VL_RCB"):SetPicture(PesqPict("SE5","E5_VALOR",16,MV_PAR04))

oReport:SetTitle(cTitulo)
oReport:SetMeter(Len(aRelat))  

oBaixas:Init()                  	
nI := 1
While nI <= Len(aRelat)
	If oReport:Cancel()
		Exit
	EndIf
	oReport:IncMeter()
	oBaixas:PrintLine()    
	nI++
EndDo
oBaixas:Finish()

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR180R3³ Autor ³ Wagner Xavier         ³ Data ³ 05.10.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao dos titulos baixados por lote                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR180(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Program   ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Mauricio ³28/06/98³xxxxxx³ Nro do titulo com 12 posicoes              ³±±
±±³ Wagner   ³17/08/98³14629A³ Totalizar por lote                         ³±±
±±³ Andreia  ³14/10/98³xxxxxx³ Alteracao no lay-out p/ ativar set Century ³±±
±±³ Mauricio ³07/12/98³18694B³ Corrigida impressao p/ totais de lote      ³±±
±±³ Andreia  ³16.12.98³xxxxxx³ Verificao de baixas estornadas(TEMBXCANC())³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinR180R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel
LOCAL cDesc1 :=OemToAnsi(STR0001)  //"Este programa ira emitir a relacao dos titulos baixados"
LOCAL cDesc2 :=OemToAnsi(STR0002)  //"por Lote."
LOCAL cDesc3 :=""
LOCAL cString:="SE5"
LOCAL tamanho := "G"

PRIVATE titulo := OemToAnsi(STR0011) //"Relacao de Baixas por Lote"
PRIVATE cabec1
PRIVATE cabec2
PRIVATE aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog:="RFINR180"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="FIN180"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("FIN180",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        ³
//³ mv_par01        	// do Lote	                            ³
//³ mv_par02        	// ate o lote	                        ³
//³ mv_par03       	    // Carteira (R/P)                       ³
//³ mv_par04        	// moeda     	                        ³
//³ mv_par05       	    // imprime outras moedas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "RFINR180"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
            
//INICIO - CUSTOMIZAÇÃO - ALTERADO - Thiago Silva de Almeida - 27/12/12
DbSelectArea("SZ3")
DbSetOrder(1)
If MsSeek(xFilial("SZ3") + __cUserId,.T.,.F.)
	_cBco := SZ3->Z3_CODBCRE
	_cAge := SZ3->Z3_AGENREC
	_cCon := SZ3->Z3_CONTREC
	
	aReturn[7] := "SE5->E5_BANCO = '" + _cBco + "' .And. SE5->E5_AGENCIA = '" + _cAge + "'  .And. SE5->E5_CONTA = '" + _cCon + "' "
EndIf
	
//FIM - CUSTOMIZAÇÃO - ALTERADO - Thiago Silva de Almeida - 27/12/12

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| Fa180Imp(@lEnd,wnRel,cString)},Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR180  ³ Autor ³ Wagner Xavier         ³ Data ³ 05.10.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao dos titulos baixados por lote                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR180(lEnd,wnRel,cString)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Parametro 1 - lEnd    - Action no CodeBlock                ³±±
±±³          ³ Parametro 2 - WnRel   - Titulo do relat¢rio                ³±±
±±³          ³ Parametro 3 - cString - Mensagem                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA180Imp(lEnd,wnRel,cString)

LOCAL CbCont,CbTxt
LOCAL tamanho:="G"
LOCAL nTipo,nValor:=0,nDesc:=0,nJuros:=0,nMulta:=0,nCM:=0
LOCAL nTotValor:=0,nTotDesc:=0,nTotJuros:=0,nTotMulta:=0,nTotCM:=0
LOCAL cNumero,cPrefixo,cParcela,dBaixa,cLote:="",cLoteQuebra
Local nAbat := nTotAbat := 0
Local cTipo := cCliFor  := cLoja := ""
LOCAL nLotValor:=0,nLotDesc:=0,nLotJuros:=0,nLotMulta:=0,nLotCM:=0,nLotAbat:=0
Local ndecs:=Msdecimais(mv_par04)

//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
Local lPccBxCr	:= If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)
Local nPccBxCr := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF mv_par03==1
	titulo:=OemToAnsi(STR0005)+ mv_par01+OemToAnsi(STR0006)+mv_par02  //"Relacao dos Titulos Recebidos do Lote "### " a "
	cabec1:=OemToAnsi(STR0008)  //"Lote Prf Numero       PC Cliente              Valor Original Data Baixa        Descontos           Juros           Multas      Corr Monet      Abatimentos   Valor Recebido"
Else
	titulo:=OemToAnsi(STR0007)+mv_par01+OemToAnsi(STR0006)+mv_par02  //"Relacao dos Titulos Pagos do Lote "###" a "
	cabec1:=OemToAnsi(STR0009)  //"Lote Prf Numero       PC Fornecedor           Valor Original Data Baixa        Descontos           Juros           Multas      Corr Monet      Abatimentos       Valor Pago"
EndIF
cabec2 := ""
nTipo:=15

cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

dbSelectArea("SE5")
SE5->(dbSetOrder(5))
SE5->(MsSeek(cFilial+mv_par01,.F.,.F.))
SetRegua(RecCount())
While !SE5->(Eof()) .And. SE5->E5_FILIAL==cFilial .And. SE5->E5_LOTE >= mv_par01 .And. SE5->E5_LOTE <= mv_par02
	IF Empty(SE5->E5_LOTE) .or. SE5->E5_SITUACA == "C"
		SE5->(dbSkip())
		Loop
	EndIF
	cLoteQuebra := SE5->E5_LOTE
	While !SE5->(Eof()) .and. E5_LOTE == cLoteQuebra .and. E5_FILIAL == xFilial()
		IF lEnd
			@PROW()+1,001 PSAY OemToAnsi(STR0010)  //"CANCELADO PELO OPERADOR"
			Exit
		EndIF
		IncRegua()
		IF Empty(SE5->E5_LOTE) .or. SE5->E5_SITUACA == "C"
			Skip
			Loop
		EndIF
		If cPaisLoc <> "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se deve imprimir outras moedas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par05 == 2 // nao imprime
				If Val(SE5->E5_MOEDA) != mv_par04 //verifica moeda do campo=moeda parametro
					dbSkip()
					Loop
				Endif
			Endif
		Endif
		
		IF mv_par03 == 1 .and. SE5->E5_RECPAG = "P"    //N„o ‚ recebimento
			DbSkip()
			Loop
		EndIF
		
		IF mv_par03 == 2 .and. SE5->E5_RECPAG = "R"    //Nao ‚ pagamento
			DbSkip()
			Loop
		EndIF
		
		cNumero  := SE5->E5_NUMERO
		cPrefixo := SE5->E5_PREFIXO
		cParcela := SE5->E5_PARCELA
		dBaixa   := SE5->E5_DATA
		cLote    := SE5->E5_LOTE
		cTipo    := SE5->E5_TIPO
		cCliFor  := SE5->E5_CLIFOR
		cLoja    := SE5->E5_LOJA
		
		Store 0 To nDesc,nCM,nJuros,nValor,nMulta
		
		While !EOF() .and. SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA==cPrefixo+cNumero+cParcela+cTipo+cCliFor+cLoja
			
			IF lEnd
				@PROW()+1,001 PSAY OemToAnsi(STR0010)  //"CANCELADO PELO OPERADOR"
				Go Bottom
				Exit
			EndIF
			
			IncRegua()
			
			IF Empty(SE5->E5_DATA) .or. Empty(SE5->E5_NUMERO) .or. SE5->E5_SITUACA == "C" .or. Empty(SE5->E5_LOTE)
				DbSkip()
				Loop
			EndIF
			
			IF mv_par03 == 1 .and. SE5->E5_RECPAG = "P"    //Nao ‚ recebimento
				DbSkip()
				Loop
			EndIF
			
			IF mv_par03 == 2 .and. SE5->E5_RECPAG = "R"    //Nao ‚ pagamento
				DbSkip()
				Loop
			EndIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe baixas estornadas           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
				dbskip()
				loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Quebra por lote: quando um t¡tulo possuia baixas parciais em dois  ³
			//³ lotes diferentes causavam problemas de recupera‡„o de dados, por   ³
			//³ isso foi instalado esta quebra por lote. Bops 04990-A              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cLote # SE5->E5_LOTE
				Exit
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega a moeda do Banco para utiliza-la no segundo parametro da      ³
			//³ fun‡„o Xmoeda quando o Pa¡s <> de Brasil ou controla saldos        ³
			//³ bancarios em multiplas moedas                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc <> "BRA" .OR. ( FindFunction( "FXMultSld" ) .AND. FXMultSld() )
				dbSelectArea("SA6")
				dbSetOrder(1)
				MsSeek(cFilial+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA,.T.,.F.)
				nMoedabco := max(SA6->A6_MOEDA,1)
				dbSelectArea("SE5")
				SE5->(dbSetOrder(5))
			Else
				nMoedabco := 1
			Endif
			
			Do Case

				Case SE5->E5_TIPODOC $ "DC/D2"
					nTotDesc += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nLotDesc += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nDesc += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
				Case SE5->E5_TIPODOC $ "JR/J2/TL"
					nTotJuros += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nLotJuros += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nJuros += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
				Case SE5->E5_TIPODOC $ "MT/M2"
					nTotMulta += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nLotMulta += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nMulta += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
				Case SE5->E5_TIPODOC $ "CM/C2"
					nTotCm += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nLotCm += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nCM += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
				Case SE5->E5_TIPODOC $ "VL/V2/BA"
					nLotValor += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nValor += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nTotValor += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))

					//Pcc Baixa CR
					If mv_par03 == 1 .and. lPccBxCr .and. cPaisLoc == "BRA"
						If Empty(SE5->E5_PRETPIS) 
							nPccBxCr += xMoeda(SE5->E5_VRETPIS,nMoedabco,mv_par04,,ndecs+1,,SE5->E5_TXMOEDA)
						Endif						
						If Empty(SE5->E5_PRETCOF) 
							nPccBxCr += xMoeda(SE5->E5_VRETCOF,nMoedabco,mv_par04,,ndecs+1,,SE5->E5_TXMOEDA)
						Endif						
						If Empty(SE5->E5_PRETCSL) 
							nPccBxCr += xMoeda(SE5->E5_VRETCSL,nMoedabco,mv_par04,,ndecs+1,,SE5->E5_TXMOEDA)
						Endif											
					Endif
					
			Endcase
			
			dbSkip()
		EndDO
		
		IF (nDesc+nValor+nJuros+nMulta) > 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo do Abatimento						                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par03 == 1
				dbSelectArea("SE1")
				nRecno := Recno()
				nAbat  := SomaAbat(cPrefixo,cNumero,cParcela,"R",mv_par04)
				nAbat  += nPccBxCr	
				dbSelectArea("SE1")
				dbGoTo(nRecno)
			Else
				dbSelectArea("SE2")
				nRecno := Recno()
				nAbat  := SomaAbat(cPrefixo,cNumero,cParcela,"P",mv_par04)
				dbSelectArea("SE2")
				dbGoTo(nRecno)
			EndIf
			
			IF li > 58
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			EndIF
			
			@li, 0 PSAY cLote
			@li,10 PSAY cPrefixo
			@li,14 PSAY cNumero
			@li,27 PSAY cParcela
			
			IF mv_par03==1
				DbSelectArea("SE1")
			Else
				DbSelectArea("SE2")
			EndIF
			MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo+cCliFor+cLoja,.F.,.F.)
			
			IF mv_par03==1
				DbSelectArea("SA1")
				DbSetOrder(1)
				MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.,.F.)
				DbSelectArea("SE1")
				@li, 31 PSAY Left(SA1->A1_NREDUZ,19)
				@li, 51 PSAY xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par04,,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)) Picture PesqPict("SE1","E1_VALOR",15,MV_PAR04)	//E1_VLCRUZ
			Else
				DbSelectArea("SA2")
				DbSetOrder(1)
				MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,.T.,.F.)
				DbSelectArea("SE2")
				@li, 31 PSAY Left(SA2->A2_NREDUZ,19)
				@li, 51 PSAY xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par04,,ndecs+1,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0)) Picture PesqPict("SE2","E2_VALOR",15,MV_PAR04)	//E2_VLCRUZ
			EndIF
			
			@li, 68 PSAY dBaixa
			@li, 80 PSAY nDesc		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
			@li, 97 PSAY nJuros		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
			@li,114 PSAY nMulta		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
			@li,131 PSAY nCM		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
			@li,148 PSAY nAbat		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
			@li,165 PSAY nValor		Picture PesqPict("SE5","E5_VALOR",16,MV_PAR04)
			li++
			nTotAbat +=nAbat
			nLotAbat +=nAbat
			nAbat := 0
		EndIF
		dbSelectArea("SE5")
	Enddo
	if nLotDesc !=0 .or. nLotJuros !=0 .or. nLotMulta !=0 .or. ;
		nLotCM   !=0 .or. nLotAbat  !=0 .or. nLotValor !=0
		li++
		@li, 80 PSAY nLotDesc		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li, 97 PSAY nLotJuros		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li,114 PSAY nLotMulta		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li,131 PSAY nLotCM			Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li,148 PSAY nLotAbat		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li,165 PSAY nLotValor		Picture PesqPict("SE5","E5_VALOR",16,MV_PAR04)
		li+=2
	Endif
	nLotDesc:=0
	nLotJuros:=0
	nLotMulta:=0
	nLotCm:=0
	nLotAbat:=0
	nLotValor:=0
	dbSelectArea("SE5")
EndDO
IF li != 80
	If nTotDesc !=0 .or. nTotJuros !=0 .or. nTotMulta !=0 .or.;
		nTotCM   !=0 .or. nTotAbat  !=0 .or. nTotValor !=0
		li++
		@li, 75 PSAY nTotDesc		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li, 92 PSAY nTotJuros		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li,109 PSAY nTotMulta		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li,126 PSAY nTotCM			Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li,143 PSAY nTotAbat		Picture PesqPict("SE5","E5_VALOR",15,MV_PAR04)
		@li,160 PSAY nTotValor		Picture PesqPict("SE5","E5_VALOR",16,MV_PAR04)
		roda(cbcont,cbtxt,tamanho)
	Endif
EndIF

Set Device To Screen
dbSelectArea("SE5")
dbSetOrder(1)
Set Filter To

If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)
EndIF

MS_FLUSH()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR180R4³ Autor ³ Adrianne Furtado      ³ Data ³ 14.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao dos titulos baixados por lote                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR180()				             		                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA180ImpR4()

LOCAL nValor:=0,nDesc:=0,nJuros:=0,nMulta:=0,nCM:=0
LOCAL nTotValor:=0,nTotDesc:=0,nTotJuros:=0,nTotMulta:=0,nTotCM:=0
LOCAL cNumero,cPrefixo,cParcela,dBaixa,cLote:="",cLoteQuebra
Local nAbat := nTotAbat := 0
Local cTipo := cCliFor  := cLoja := ""
LOCAL nLotValor:=0,nLotDesc:=0,nLotJuros:=0,nLotMulta:=0,nLotCM:=0,nLotAbat:=0
Local ndecs:=Msdecimais(mv_par04)  
Local aRet := {}

//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
Local lPccBxCr	:= If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)
Local nPccBxCr := 0

li       := 1
m_pag    := 1
cFilterUser := "SE5->E5_BANCO ='CX1'"
dbSelectArea("SE5")
SE5->(dbSetOrder(5))
SE5->(MsSeek(cFilial+mv_par01,.F.,.F.))
While !SE5->(Eof()) .And. SE5->E5_FILIAL==cFilial .And. SE5->E5_LOTE >= mv_par01 .And. SE5->E5_LOTE <= mv_par02
	IF Empty(SE5->E5_LOTE) .or. SE5->E5_SITUACA == "C"
		SE5->(dbSkip())
		Loop
	EndIF
	//Considera Filtro de usuario
	If !empty(cFilterUser) .AND. !(&cFilterUser)
		SE5->(dbSkip())
		Loop
	EndIf
	cLoteQuebra := SE5->E5_LOTE
	While !SE5->(Eof()) .and. E5_LOTE == cLoteQuebra .and. E5_FILIAL == xFilial()
		IF Empty(SE5->E5_LOTE) .or. SE5->E5_SITUACA == "C"
			Skip
			Loop
		EndIF
		If cPaisLoc <> "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se deve imprimir outras moedas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par05 == 2 // nao imprime
				If Val(SE5->E5_MOEDA) != mv_par04 //verifica moeda do campo=moeda parametro
					dbSkip()
					Loop
				Endif
			Endif
		Endif
		
		IF mv_par03 == 1 .and. SE5->E5_RECPAG = "P"    //N„o ‚ recebimento
			DbSkip()
			Loop
		EndIF
		
		IF mv_par03 == 2 .and. SE5->E5_RECPAG = "R"    //Nao ‚ pagamento
			DbSkip()
			Loop
		EndIF
		
		cNumero  := SE5->E5_NUMERO
		cPrefixo := SE5->E5_PREFIXO
		cParcela := SE5->E5_PARCELA
		dBaixa   := SE5->E5_DATA
		cLote    := SE5->E5_LOTE
		cTipo    := SE5->E5_TIPO
		cCliFor  := SE5->E5_CLIFOR
		cLoja    := SE5->E5_LOJA
		
		Store 0 To nDesc,nCM,nJuros,nValor,nMulta
		
		While !EOF() .and. SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA==cPrefixo+cNumero+cParcela+cTipo+cCliFor+cLoja
			
			IF Empty(SE5->E5_DATA) .or. Empty(SE5->E5_NUMERO) .or. SE5->E5_SITUACA == "C" .or. Empty(SE5->E5_LOTE)
				DbSkip()
				Loop
			EndIF
			
			IF mv_par03 == 1 .and. SE5->E5_RECPAG = "P"    //Nao ‚ recebimento
				DbSkip()
				Loop
			EndIF
			
			IF mv_par03 == 2 .and. SE5->E5_RECPAG = "R"    //Nao ‚ pagamento
				DbSkip()
				Loop
			EndIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe baixas estornadas           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
				dbskip()
				loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Quebra por lote: quando um t¡tulo possuia baixas parciais em dois  ³
			//³ lotes diferentes causavam problemas de recupera‡„o de dados, por   ³
			//³ isso foi instalado esta quebra por lote. Bops 04990-A              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cLote # SE5->E5_LOTE
				Exit
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega a moeda do Banco para utiliza-la no segundo parametro da      ³
			//³ fun‡„o Xmoeda quando o Pa¡s <> de Brasil ou controla saldos        ³
			//³ bancarios em multiplas moedas                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc <> "BRA" .OR. ( FindFunction( "FXMultSld" ) .AND. FXMultSld() )
				dbSelectArea("SA6")
				dbSetOrder(1)
				MsSeek(cFilial+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA,.T.,.F.)
				nMoedabco := max(SA6->A6_MOEDA,1)
				dbSelectArea("SE5")
				SE5->(dbSetOrder(5))
			Else
				nMoedabco := 1
			Endif
			
			Do Case
				
				Case SE5->E5_TIPODOC $ "DC/D2"
					nTotDesc += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nLotDesc += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nDesc += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
				Case SE5->E5_TIPODOC $ "JR/J2/TL"
					nTotJuros += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nLotJuros += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nJuros += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
				Case SE5->E5_TIPODOC $ "MT/M2"
					nTotMulta += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nLotMulta += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nMulta += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
				Case SE5->E5_TIPODOC $ "CM/C2"
					nTotCm += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nLotCm += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nCM += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
				Case SE5->E5_TIPODOC $ "VL/V2/BA"
					nLotValor += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nValor += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))
					nTotValor += xMoeda(SE5->E5_VALOR,nMoedabco,mv_par04,,ndecs+1,,If(cPaisLoc=="BRA",SE5->E5_TXMOEDA,0))

					//Pcc Baixa CR
					If mv_par03 == 1 .and. lPccBxCr .and. cPaisLoc == "BRA"
						If Empty(SE5->E5_PRETPIS) 
							nPccBxCr += xMoeda(SE5->E5_VRETPIS,nMoedabco,mv_par04,,ndecs+1,,SE5->E5_TXMOEDA)
						Endif						
						If Empty(SE5->E5_PRETCOF) 
							nPccBxCr += xMoeda(SE5->E5_VRETCOF,nMoedabco,mv_par04,,ndecs+1,,SE5->E5_TXMOEDA)
						Endif						
						If Empty(SE5->E5_PRETCSL) 
							nPccBxCr += xMoeda(SE5->E5_VRETCSL,nMoedabco,mv_par04,,ndecs+1,,SE5->E5_TXMOEDA)
						Endif											
					Endif

			Endcase
			
			dbSkip()
		EndDO
		
		IF (nDesc+nValor+nJuros+nMulta) > 0
			AAdd(aRet, Array(13)) 			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo do Abatimento						                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par03 == 1
				dbSelectArea("SE1")
				nRecno := Recno()
				nAbat  := SomaAbat(cPrefixo,cNumero,cParcela,"R",mv_par04)
				nAbat  += nPccBxCr	
				dbSelectArea("SE1")
				dbGoTo(nRecno)
			Else
				dbSelectArea("SE2")
				nRecno := Recno()
				nAbat  := SomaAbat(cPrefixo,cNumero,cParcela,"P",mv_par04)
				dbSelectArea("SE2")
				dbGoTo(nRecno)
			EndIf
			
			aRet[li][01] := cLote
			aRet[li][02] := cPrefixo
			aRet[li][03] := cNumero
			aRet[li][04] := cParcela
			
			IF mv_par03==1
				DbSelectArea("SE1")
			Else
				DbSelectArea("SE2")
			EndIF
			MsSeek(cFilial+cPrefixo+cNumero+cParcela+cTipo+cCliFor+cLoja,.F.,.F.)
			
			IF mv_par03==1
				DbSelectArea("SA1")
				DbSetOrder(1)
				MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.,.F.)
				DbSelectArea("SE1")
				aRet[li][05] := Left(SA1->A1_NREDUZ,19)
				aRet[li][06] := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par04,,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)) 
			Else
				DbSelectArea("SA2")
				DbSetOrder(1)
				MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,.T.,.F.)
				DbSelectArea("SE2")
				aRet[li][05] := Left(SA2->A2_NREDUZ,19)
				aRet[li][06] := xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par04,,ndecs+1,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0)) 
			EndIF
			
			aRet[li][07] := dBaixa
			aRet[li][08] := nDesc		
			aRet[li][09] := nJuros		
			aRet[li][10] := nMulta		
			aRet[li][11] := nCM		
			aRet[li][12] := nAbat	
			aRet[li][13] := nValor	
			li++
			nTotAbat +=nAbat
			nLotAbat +=nAbat
			nAbat := 0
			nPccBxCr := 0		
		EndIF
		dbSelectArea("SE5")
	Enddo
	nLotDesc:=0
	nLotJuros:=0
	nLotMulta:=0
	nLotCm:=0
	nLotAbat:=0
	nLotValor:=0
	dbSelectArea("SE5")
EndDO

dbSelectArea("SE5")
dbSetOrder(1)
Set Filter To            

Return aRet
