#INCLUDE "MATR540.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ?MATR540  ?Autor ?Marco Bianchi            ?Data ?23/05/06 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ?Relatorio de Comissoes.                                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ?MATR540(void)                                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?Generico                                                      ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RMATR540()

Local oReport
Private cAliasQry := GetNextAlias()
#IFDEF TOP
   Private cAlias    := cAliasQry
#ELSE
   Private cAlias    := "SE3"
#ENDIF
If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()  
Else
	Matr540R3()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Programa  ³ReportDef ?Autor ?Marco Bianchi         ?Data ?3/05/2006³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±?
±±?         ³relatorios que poderao ser agendados pelo usuario.          ³±?
±±?         ?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros³Nenhum                                                      ³±?
±±?         ?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?  DATA   ?Programador   ³Manutencao efetuada                         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?         ?              ?                                           ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function ReportDef()

Local oReport
Local oComissaoA
Local oComissaoS
Local oDetalhe
Local oTotal
Local cVend  		:= ""
Local dVencto   	:= CTOD( "" ) 
Local dBaixa    	:= CTOD( "" ) 
Local nVlrTitulo	:= 0
Local nBasePrt  	:= 0
Local nComPrt   	:= 0
Local cTipo     	:= ""
Local cLiquid 
Local aValLiq   	:= {}
Local nI2       	:= 0
Local aLiqProp  	:= {}
Local nValIR    	:= 0
Local nTotSemIR 	:= 0
Local nAc1      	:= 0
Local nAc2      	:= 0
Local nAc3      	:= 0
Local nDecPorc		:= TamSX3("E3_PORC")[2]
Local nTamData  	:= Len(DTOC(MsDate()))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ?
//?                                                                       ?
//³TReport():New                                                           ?
//³ExpC1 : Nome do relatorio                                               ?
//³ExpC2 : Titulo                                                          ?
//³ExpC3 : Pergunte                                                        ?
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ?
//³ExpC5 : Descricao                                                       ?
//?                                                                       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//STR0025 := (STR0025 + " De " + (mv_par02) + " At?" + (mv_par03))
//oReport := TReport():New("RMATR540",STR0025,"MTR540", {|oReport| ReportPrint(oReport,cAliasQry,oComissaoA,oComissaoS,oDetalhe,oTotal)},STR0026)
oReport := TReport():New("RMATR540",STR0025,"RMATR540", {|oReport| ReportPrint(oReport,cAliasQry,oComissaoA,oComissaoS,oDetalhe,oTotal)},STR0026)
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

AjustaSX1()
Pergunte("RMATR540",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ?
//?                                                                       ?
//³TRSection():New                                                         ?
//³ExpO1 : Objeto TReport que a secao pertence                             ?
//³ExpC2 : Descricao da seçao                                              ?
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ?
//?       sera considerada como principal para a seção.                   ?
//³ExpA4 : Array com as Ordens do relatório                                ?
//³ExpL5 : Carrega campos do SX3 como celulas                              ?
//?       Default : False                                                 ?
//³ExpL6 : Carrega ordens do Sindex                                        ?
//?       Default : False                                                 ?
//?                                                                       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ?
//?                                                                       ?
//³TRCell():New                                                            ?
//³ExpO1 : Objeto TSection que a secao pertence                            ?
//³ExpC2 : Nome da celula do relatório. O SX3 ser?consultado              ?
//³ExpC3 : Nome da tabela de referencia da celula                          ?
//³ExpC4 : Titulo da celula                                                ?
//?       Default : //X3TITULO()                                            ?
//³ExpC5 : Picture                                                         ?
//?       Default : X3_PICTURE                                            ?
//³ExpC6 : Tamanho                                                         ?
//?       Default : X3_TAMANHO                                            ?
//³ExpL7 : Informe se o tamanho esta em pixel                              ?
//?       Default : False                                                 ?
//³ExpB8 : Bloco de código para impressao.                                 ?
//?       Default : ExpC2                                                 ?
//?                                                                       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oComissaoA := TRSection():New(oReport,STR0050,{"SE3","SA3"},{STR0046,STR0047},/*Campos do SX3*/,/*Campos do SIX*/)
oComissaoA:SetTotalInLine(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Analitico                                                              ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oComissaoA,"E3_VEND" ,"SE3",/*Titulo*/,/*Picture*/                ,/*Tamanho*/         ,/*lPixel*/  ,{|| cVend })
TRCell():New(oComissaoA,"A3_NOME" ,"SA3",/*Titulo*/,/*Picture*/                ,/*Tamanho*/         ,/*lPixel*/  ,{|| SA3->A3_NOME })

// Titulos da Comissao
oDetalhe := TRSection():New(oComissaoA,STR0048,{"SE3","SA3","SA1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oDetalhe:SetTotalInLine(.F.)
oDetalhe:SetHeaderBreak(.T.)
TRCell():New(oDetalhe,"E3_PREFIXO" 	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_NUM"		,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,{|| E3_NUM })
TRCell():New(oDetalhe,"E3_PARCELA" 	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_CODCLI"	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"A1_NREDUZ"	,cAlias,/*Titulo*/,/*Picture*/               ,30			,/*lPixel*/,{|| Substr(SA1->A1_NREDUZ,1,30) })
TRCell():New(oDetalhe,"A1_NOME"		,cAlias,/*Titulo*/,/*Picture*/               ,30			,/*lPixel*/,{|| Substr(SA1->A1_NOME,1,30)  })
TRCell():New(oDetalhe,"E3_EMISSAO"	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"DVENCTO"		,"    ",STR0033   ,/*Picture*/               ,nTamData  ,/*lPixel*/,{|| dVencto })
TRCell():New(oDetalhe,"DBAIXA"		,"    ",STR0034   ,/*Picture*/               ,nTamData  ,/*lPixel*/,{|| dBaixa })
TRCell():New(oDetalhe,"E3_DATA"		,cAlias,/*Titulo*/,/*Picture*/               ,nTamData  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_PEDIDO"	,cAlias,STR0039   ,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"NVLRTITULO"	,"    ",STR0035   ,PesqPict('SE3','E3_COMIS'),TamSx3("E3_COMIS"	)[1],/*lPixel*/,{|| 5,5 }) //nVlrTitulo })
TRCell():New(oDetalhe,"NBASEPRT"		,"    ",STR0036   ,PesqPict('SE3','E3_BASE') ,TamSx3("E3_BASE"	)[1],/*lPixel*/,{|| nBasePrt })
If cPaisLoc<>"BRA"
	TRCell():New(oDetalhe,"E3_PORC"	,cAlias,STR0032,tm(SE3->E3_PORC,6,nDecPorc)  ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
Else
	TRCell():New(oDetalhe,"E3_PORC"	,cAlias,STR0032,tm(SE3->E3_PORC,6)           ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
Endif
TRCell():New(oDetalhe,"NCOMPRT"		,"   ",STR0038,PesqPict('SE3','E3_COMIS')   ,TamSx3("E3_COMIS")[1]	,/*lPixel*/,{|| nComPrt })
TRCell():New(oDetalhe,"E3_BAIEMI"	,cAlias,STR0040,/*Picture*/                   ,/*Tamanho*/  ,/*lPixel*/,{|| Substr(cTipo,1,1) })
TRCell():New(oDetalhe,"AJUSTE"		,"   ",STR0037,/*Picture*/                   ,/*Tamanho*/  ,/*lPixel*/,{|| ""})



// Titulos de Liquidacao
oLiquida := TRSection():New(oDetalhe,STR0051,{"SE1","SA1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oLiquida:SetTotalInLine(.F.)
TRCell():New(oLiquida,"E1_NUMLIQ" 	,"   ",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,{|| cLiquid })
TRCell():New(oLiquida,"E1_PREFIXO"	,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_NUM"	    ,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_PARCELA" 	,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_TIPO"   	,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_CLIENTE"	,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_LOJA"		,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oLiquida,"A1_NREDUZ"	,"SA1",/*Titulo*/ ,/*Picture*/                ,TamSX3("A1_NREDUZ")[1],/*lPixel*/,{|| Substr(SA1->A1_NREDUZ,1,30) })
TRCell():New(oLiquida,"A1_NOME"		,"SA1",/*Titulo*/ ,/*Picture*/                ,TamSX3("A1_NOME")[1],/*lPixel*/,{|| Substr(SA1->A1_NOME,1,30) })

TRCell():New(oLiquida,"E1_VALOR"		,"SE1",/*Titulo*/ ,Tm(SE1->E1_VALOR,15,2)    ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"NVALLIQ1"		,"   ",STR0043    ,/*Picture*/                ,nTamData	     		,/*lPixel*/,{|| aValLiq[nI2,1] })
TRCell():New(oLiquida,"NVALLIQ2"		,"   ",STR0044    ,Tm(SE1->E1_VALOR,15,2)    ,/*Tamanho*/  		,/*lPixel*/,{|| aValLiq[nI2,2] })
TRCell():New(oLiquida,"NLIQPROP"		,"   ",STR0045    ,Tm(SE1->E1_VALOR,15,2)    ,/*Tamanho*/  		,/*lPixel*/,{|| aLiqProp[nI2] })

//-- Secao Totalizadora do Valor do IR e Total (-) IR
oTotal := TRSection():New(oReport,"",{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oTotal,"TOTALIR"     ,"   ",STR0028,"@E 99,999,999.99",12         ,/*lPixel*/,{|| nValIR })
TRCell():New(oTotal,"TOTSEMIR"    ,"   ",STR0029,"@E 99,999,999.99",12         ,/*lPixel*/,{|| nTotSemIR })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Sintetico                                                              ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oComissaoS := TRSection():New(oReport,STR0049,{"SE3","SA3"},{STR0046,STR0047},/*Campos do SX3*/,/*Campos do SIX*/)
oComissaoS:SetTotalInLine(.F.)

TRCell():New(oComissaoS,"E3_VEND" ,"SE3",/*Titulo*/,/*Picture*/                	,/*Tamanho*/          	,/*lPixel*/	,{|| cVend })
TRCell():New(oComissaoS,"A3_NOME" ,"SA3",/*Titulo*/,/*Picture*/					,/*Tamanho*/          	,/*lPixel*/	,{|| SA3->A3_NOME })
TRCell():New(oComissaoS,"TOTALTIT",""		,STR0027   ,PesqPict('SE3','E3_BASE') 	,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{|| nAc3 })
TRCell():New(oComissaoS,"E3_BASE" ,cAlias,STR0030   ,PesqPict('SE3','E3_BASE') 	,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{|| nAc1 })
TRCell():New(oComissaoS,"E3_PORC" ,cAlias,STR0032   ,PesqPict('SE3','E3_PORC') 	,TamSx3("E3_PORC")[1] 	,/*lPixel*/	,{||NoRound((nAc2*100) / nAc1),2})
TRCell():New(oComissaoS,"E3_COMIS",cAlias,STR0031   ,PesqPict('SE3','E3_COMIS')	,TamSx3("E3_COMIS")[1]	,/*lPixel*/	,{|| nAc2 })
TRCell():New(oComissaoS,"VALIR"   ,""   	,STR0028   ,PesqPict('SE3','E3_COMIS')	,TamSx3("E3_COMIS")[1]	,/*lPixel*/	,{||nValIR })
TRCell():New(oComissaoS,"TOTSEMIR",""   	,STR0029   ,PesqPict('SE3','E3_COMIS')	,TamSx3("E3_COMIS")[1]	,/*lPixel*/	,{||nTotSemIR})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Impressao do Cabecalho no topo da pagina                               ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):SetHeaderPage()
oReport:Section(3):SetHeaderPage() 
oReport:Section(1):Setedit(.T.)
oReport:Section(1):Section(1):Setedit(.T.)
oReport:Section(1):Section(1):Section(1):Setedit(.T.)
oReport:Section(2):Setedit(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Alinhamento a direita dos campos de valores                            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Analitico
oDetalhe:Cell("NVLRTITULO"):SetHeaderAlign("RIGHT")
oDetalhe:Cell("NBASEPRT")  :SetHeaderAlign("RIGHT")
oDetalhe:Cell("NCOMPRT")   :SetHeaderAlign("RIGHT")
//Sintetico
oComissaoS:Cell("TOTALTIT"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("E3_BASE" ):SetHeaderAlign("RIGHT")
oComissaoS:Cell("E3_COMIS"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("VALIR"   ):SetHeaderAlign("RIGHT")
oComissaoS:Cell("TOTSEMIR"):SetHeaderAlign("RIGHT")

//IR
oTotal:Cell("TOTALIR")     :SetHeaderAlign("RIGHT")
oTotal:Cell("TOTSEMIR")    :SetHeaderAlign("RIGHT")

Return(oReport)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Programa  ³ReportPrin?Autor ³Eduardo Riera          ?Data ?4.05.2006³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±?
±±?         ³relatorios que poderao ser agendados pelo usuario.          ³±?
±±?         ?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Retorno   ³Nenhum                                                      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±?
±±?         ?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?  DATA   ?Programador   ³Manutencao efetuada                         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?         ?              ?                                           ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function ReportPrint(oReport,cAliasQry,oComissaoA,oComissaoS,oDetalhe,oTotal)

Local lQuery   := .F.
Local dEmissao := CTOD( "" ) 
Local nTotLiq  := 0
Local aLiquid  := {}
Local ny 
Local cWhere   := ""
Local cNomArq, cFilialSE1, cFilialSE3
Local nI       := 0
Local cOrder   := ""
Local nDecs
Local nTotPorc := 0
Local nTotPerVen := 0

#IFNDEF TOP
	Local cCondicao := ""
#ENDIF

Local cDocLiq   := ""
Local cTitulo   := ""                                     
Local cAjuste   := ""
Local nTotBase	:= 0
Local nTotComis	:= 0
Local nSection	:= 0
Local nOrdem	:= 0
Local nTGerBas  := 0
Local nTGerCom  := 0
Local cFilSE1	:= "" 
Local cFilSE3   := "" 
Local cFilSA1   := "" 
Local lVend	    := .F.
Local lFirst    := .F.

// Declarado a variável oReport a fim de utilizar os parâmetros de data at?data para utilização no cabeçalho das páginas.
// Incluido por Júlio Soares em 24/09/2013
oReport:CTITLE := ("Relatório de comissões De " + (DTOC(mv_par02)) + " At?" + (DTOC(mv_par03)))

If oReport:Section(1):GetOrder() == 1		// Ordem: por Titulo
	nOrdem := 1
Else										// Ordem: por Cliente
	nOrdem := 2
EndIf	

If mv_par12 == 1	// Analitico
	oReport:Section(3):Disable()
	nSection := 1   
	If mv_par14 == 1
		oReport:Section(1):section(1):Cell("A1_NOME"):Disable()
		oReport:Section(1):section(1):Section(1):Cell("A1_NOME"):Disable()
	Else
		oReport:Section(1):section(1):Cell("A1_NREDUZ"):Disable()
		oReport:Section(1):section(1):Section(1):Cell("A1_NREDUZ"):Disable()
	EndIf
	oReport:Section(1)                      :Cell("E3_VEND"    ):SetBlock({|| cVend })	
	oReport:Section(1):Section(1)           :Cell("DVENCTO"    ):SetBlock({|| dVencto })	
	oReport:Section(1):Section(1)           :Cell("DBAIXA"     ):SetBlock({|| dBaixa })	
	oReport:Section(1):Section(1)           :Cell("NVLRTITULO" ):SetBlock({|| nVlrTitulo })	
	oReport:Section(1):Section(1)           :Cell("NBASEPRT"   ):SetBlock({|| nBasePrt })	
	oReport:Section(1):Section(1)           :Cell("NCOMPRT"    ):SetBlock({|| nComPrt })	
	oReport:Section(1):Section(1)           :Cell("E3_BAIEMI"  ):SetBlock({|| Substr(cTipo,1,1) })	
	oReport:Section(1):Section(1)           :Cell("AJUSTE"     ):SetBlock({|| IIf( (cAjuste == "S" .And. MV_PAR07 == 1),"AJUSTE","" ) })	
	oReport:Section(1):Section(1):Section(1):Cell("E1_NUMLIQ"  ):SetBlock({|| cLiquid  })	
	oReport:Section(1):Section(1):Section(1):Cell("NVALLIQ1"   ):SetBlock({|| aValLiq[nI2,1] })	
	oReport:Section(1):Section(1):Section(1):Cell("NVALLIQ2"   ):SetBlock({|| aValLiq[nI2,2] })	
	oReport:Section(1):Section(1):Section(1):Cell("NLIQPROP"   ):SetBlock({|| aLiqProp[nI2] })	
	oReport:Section(2)                      :Cell("TOTALIR"    ):SetBlock({|| nValIR })	
	oReport:Section(2)                      :Cell("TOTSEMIR"   ):SetBlock({|| nTotSemIR })	
    bVOrig := { || cDocLiq := SE1->E1_NUMLIQ, nVlrTitulo := Iif(cTitulo <> (cAlias)->E3_PREFIXO+(cAlias)->E3_NUM+(cAlias)->E3_PARCELA+(cAlias)->E3_TIPO+(cAlias)->E3_VEND+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA, nVlrTitulo, 0 ) }
	TRFunction():New(oDetalhe:Cell("NVLRTITULO"),/* cID */,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,bVOrig,.T./*lEndSection*/,IIf(mv_par11 == 2,.T.,.F.)/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oDetalhe:Cell("NBASEPRT"  ),/* cID */,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,IIf(mv_par11 == 2,.T.,.F.)/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oDetalhe:Cell("NCOMPRT"   ),/* cID */,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,IIf(mv_par11 == 2,.T.,.F.)/*lEndReport*/,/*lEndPage*/)
  //TRFunction():New(oDetalhe:Cell("E3_PORC"   ),/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| nTotPorc},.T./*lEndSection*/,IIf(mv_par13 == 2,.T.,.F.)/*lEndReport*/,.F.)	
	TRFunction():New(oDetalhe:Cell("E3_PORC"   ),/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| nTotPerVen },.T./*lEndSection*/,IIf(mv_par13 == 2,.T.,.F.)/*lEndReport*/,.F.)
	
	If mv_par10 > 0
		TRFunction():New(oTotal:Cell("TOTALIR" ),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,IIf(mv_par11 == 2,.T.,.F.)/*lEndReport*/,/*lEndPage*/)
		TRFunction():New(oTotal:Cell("TOTSEMIR"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,IIf(mv_par11 == 2,.T.,.F.)/*lEndReport*/,/*lEndPage*/)
	EndIf	

	cVend		:= ""
	dVencto 	:= ctod("  /  /  ")
	dBaixa 		:= ctod("  /  /  ")
	nVlrTitulo 	:= 0
	nBasePrt 	:= 0
	nComPrt 	:= 0
	cTipo 		:= ""
	cLiquid  	:= ""
	nValIR		:= 0
	nTotSemIR 	:= 0

Else				// Sintetico

	TRFunction():New(oComissaoS:Cell("TOTALTIT"),/* cID */,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("E3_BASE" ),/* cID */,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("E3_PORC" ),/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,{||nTotPorc},.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("E3_COMIS"),/* cID */,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("VALIR"   ),/* cID */,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("TOTSEMIR"),/* cID */,"SUM"    ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
              
	oReport:Section(1):Disable()
	oReport:Section(1):Section(1):Disable()
	oReport:Section(1):Section(1):Section(1):Disable()
	nSection := 3
	
	oReport:Section(3):Cell("E3_VEND"  ):SetBlock({|| cVend })		
	oReport:Section(3):Cell("TOTALTIT" ):SetBlock({|| nAc3 })		
	oReport:Section(3):Cell("E3_BASE"  ):SetBlock({|| nAc1 })		
	oReport:Section(3):Cell("E3_PORC"  ):SetBlock({||NoRound((nAc2*100) / nAc1,2) })		
	oReport:Section(3):Cell("E3_COMIS" ):SetBlock({||nAc2 })		
	oReport:Section(3):Cell("VALIR"    ):SetBlock({|| nValIR })	
	oReport:Section(3):Cell("TOTSEMIR" ):SetBlock({|| nTotSemIR })	

	cVend		:= ""
	nAc1		:= 0
	nAc2		:= 0
	nAc3		:= 0
	nValIR		:= 0
	nTotSemIR	:= 0
	
EndIf
If len(oReport:Section(1):GetAdvplExp("SE1")) > 0
   cFilSE1 := oReport:Section(1):GetAdvplExp("SE1")
EndIf
If len(oReport:Section(3):GetAdvplExp("SE3")) > 0
   cFilSE3 := oReport:Section(3):GetAdvplExp("SE3")
EndIf
If len(oReport:Section(1):GetAdvplExp("SA1")) > 0
   cFilSA1 := oReport:Section(1):GetAdvplExp("SA1")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF TOP

	// Indexa de acordo com ordem escolhida pelo cliente
	dbSelectArea("SE3")
	If nOrdem == 1		// Ordem: por Titulo
		SE3->(dbSetOrder(2))
		cOrder := "%E3_FILIAL,E3_VEND,E3_PREFIXO,E3_NUM,E3_PARCELA%"
	Else						// Ordem: por Cliente
		SE3->(dbSetOrder(3))
		cOrder := "%E3_FILIAL,E3_VEND,E3_CODCLI,E3_LOJA,E3_PREFIXO,E3_NUM,E3_PARCELA%"
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lQuery := .T.                 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)	
	
	oReport:Section(nSection):BeginQuery()
	cWhere :="%"             
	If mv_par01 == 1
		cWhere += "AND E3_BAIEMI <> 'B'"  //Baseado pela emissao da NF
	Elseif mv_par01 == 2
		cWhere += "AND E3_BAIEMI =  'B'"  //Baseado pela baixa do titulo
	EndIf
	If mv_par06 == 1 		//Comissoes a pagar
		cWhere += "AND E3_DATA = '" + Dtos(Ctod("")) + "'"
	ElseIf mv_par06 == 2 //Comissoes pagas
		cWhere += "AND E3_DATA <> '" + Dtos(Ctod("")) + "'"
	Endif
	cWhere +="%"
	BeginSql Alias cAliasQry
	SELECT E3_FILIAL,E3_BASE, E3_COMIS, E3_VEND, E3_PORC, A3_NOME, E3_PREFIXO,E3_NUM, E3_PARCELA,E3_TIPO,E3_CODCLI,E3_LOJA,E3_AJUSTE,E3_BAIEMI,E3_EMISSAO,E3_DATA, E3_PEDIDO
		FROM %table:SE3% SE3
		LEFT JOIN %table:SA3% SA3
	        ON A3_COD = E3_VEND
		WHERE A3_FILIAL = %xFilial:SA3%
			AND E3_FILIAL = %xFilial:SE3%
			AND	E3_EMISSAO >= %Exp:Dtos(mv_par02)%
			AND E3_EMISSAO <= %Exp:Dtos(mv_par03)%
			AND SE3.E3_VEND BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
			AND SA3.%NotDel%
			AND SE3.%notdel%
			%Exp:cWhere%
	ORDER BY %Exp:cOrder%
	EndSql
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ?
	//?                                                                       ?
	//³Prepara o relatório para executar o Embedded SQL.                       ?
	//?                                                                       ?
	//³ExpA1 : Array com os parametros do tipo Range                           ?
	//?                                                                       ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(nSection):EndQuery()

#ELSE
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros para ambiente CDX ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeAdvplExpr("RMATR540") 
	// Indexa de acordo com ordem escolhida oelo cliente
	dbSelectArea("SE3")
	If nOrdem == 1		// Ordem: por Titulo
		SE3->(dbSetOrder(2))
		cOrder := "E3_FILIAL+E3_VEND+E3_PREFIXO+E3_NUM+E3_PARCELA"
	Else										// Ordem: por Cliente
		SE3->(dbSetOrder(3))
		cOrder := "E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA"
	EndIf	
	DbSelectArea("SE3")	// Posiciona no arquivo de comissoes
	SE3->(dbSetOrder(3))			// Por Vendedor, Cliente, Loja, Prefixo, Numero
	cFilialSE3 := xFilial()
	cNomArq    := CriaTrab("",.F.)
	cCondicao := "SE3->E3_FILIAL=='" + cFilialSE3 + "'"
	If !Empty(mv_par04)
		cCondicao +=  " .AND. "+MV_PAR04
	EndIf
	cCondicao += " .AND. DtoS(SE3->E3_EMISSAO)>='" + DtoS(mv_par02) + "'"
	cCondicao += " .AND. DtoS(SE3->E3_EMISSAO)<='" + DtoS(mv_par03) + "'"	
	If mv_par01 == 1
		cCondicao += " .AND. SE3->E3_BAIEMI!='B'"  // Baseado pela emissao da NF
	Elseif mv_par01 == 2
		cCondicao += " .AND. SE3->E3_BAIEMI=='B'"  // Baseado pela baixa do titulo
	Endif	
		
	If mv_par06 == 1 		// Comissoes a pagar
		cCondicao += " .AND. Dtos(SE3->E3_DATA)== '"+Dtos(Ctod(""))+"'"
	ElseIf mv_par06 == 2 // Comissoes pagas
		cCondicao += " .AND. Dtos(SE3->E3_DATA)!= '"+Dtos(Ctod(""))+"'"
	Endif
	
	oReport:Section(nSection):SetFilter(cCondicao,cOrder)      // abre tela de imprimindo...
	
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo TrPosition()                                                     ?
//?                                                                       ?
//³Posiciona em um registro de uma outra tabela. O posicionamento ser?    ?
//³realizado antes da impressao de cada linha do relatório.                ?
//?                                                                       ?
//?                                                                       ?
//³ExpO1 : Objeto Report da Secao                                          ?
//³ExpC2 : Alias da Tabela                                                 ?
//³ExpX3 : Ordem ou NickName de pesquisa                                   ?
//³ExpX4 : String ou Bloco de código para pesquisa. A string ser?macroexe-?
//?       cutada.                                                         ?
//?                                                                       ?			
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oReport:Section(nSection),"SA3",1,{|| xFilial("SA3")+cVend })
//TRPosition():New(oReport:Section(nSection),"SE3",2,{|| xFilial("SE3")+cVend+(cAlias)->E3_PREFIXO+(cAlias)->E3_NUM+(cAlias)->E3_PARCELA+(cAlias)->E3_SEQ})
If mv_par12 == 1
   TRPosition():New(oReport:Section(1):Section(1),"SA1",1,{|| xFilial("SA1")+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA })
   TRPosition():New(oReport:Section(1):Section(1):Section(1),"SA1",1,{|| xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA })
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par12 == 2 .Or. mv_par12 == 1 
	nTotBase	:= 0
	nTotComis	:= 0
EndIf

dbSelectArea(cAlias)
dbGoTop()
nDecs     := GetMv("MV_CENT"+(IIF(mv_par08 > 1 , STR(mv_par08,1),"")))

_nVLRETIR := GetMV("MV_VLRETIR")

oReport:SetMeter(SE3->(LastRec()))
dbSelectArea(cAlias)
While !oReport:Cancel() .And. !&(cAlias)->(Eof())
	cVend := &(cAlias)->(E3_VEND)
	nAc1 := 0
	nAc2 := 0
	nAc3 := 0
	nTotPerVen := 0
	oReport:Section(nSection):Init()
	If mv_par12 == 1 .And. Empty(cFilSE1) .And. Empty(cFilSE3) .And. Empty(cFilSA1)
		oReport:Section(nSection):PrintLine()
	EndIf	
	lVend  := .T. 
	lFirst := .T. 

	While !Eof() .And. xFilial("SE3") == (cAlias)->E3_FILIAL .And. (cAlias)->E3_VEND == cVend 
		nBasePrt   := 0
		nComPrt    := 0
		nVlrTitulo := 0
		If mv_par12 == 1 
			nTotBase	:= 0
			nTotComis	:= 0
		EndIf
		dbSelectArea("SE3")
		SE3->(dbSetOrder(2))
		SE3->(MsSeek(xFilial("SE3")+cVend+&(cAlias)->(E3_PREFIXO)+&(cAlias)->(E3_NUM)+&(cAlias)->(E3_PARCELA),.T.,.F.))
				
		dbSelectArea("SE1")
//		SE1->(dbSetOrder(1))
//		MsSeek(xFilial("SE1")+&(cAlias)->(E3_PREFIXO)+&(cAlias)->(E3_NUM)+&(cAlias)->(E3_PARCELA)+&(cAlias)->(E3_TIPO),.T.,.F.)
		SE1->(dbOrderNickName("E1_CLIENTE"))		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		MsSeek(xFilial("SE1")+&(cAlias)->(E3_CODCLI)+&(cAlias)->(E3_LOJA)+&(cAlias)->(E3_PREFIXO)+&(cAlias)->(E3_NUM)+&(cAlias)->(E3_PARCELA)+&(cAlias)->(E3_TIPO),.T.,.F.)

		// Alterado por Júlio Soares em 12/11/2013 para tratamento para que não seja apresentado no relatório as comissões de títulos não finalizados
//		If ((Alltrim(SE1->E1_TIPO) == 'NF') .And. (SE1->E1_SALDO <> 0)) .Or. (Alltrim(SE1->E1_TIPO) == 'NCC')
//		If (((Alltrim(SE1->E1_TIPO) == 'NF') .And. (SE1->E1_SALDO <> 0)) .Or. ((Alltrim(SE1->E1_TIPO) == 'NCC') .And. (SE1->E1_SALDO == 0)))
//			(cAlias)->(dbSkip())
//			Loop
//       EndIf

		// Se nao imprime detalhes da origem, desconsidera titulos faturados
		If mv_par13 <> 1 .And. !Empty(SE1->E1_FATURA) .And. SE1->E1_FATURA <> "NOTFAT"
			(cAliasQry)->( dbSkip() )
			Loop
		EndIf

	   // Verifica filtro do usuario
	   	If !Empty(cFilSE1) .And. !(&cFilSE1)
		   dbSelectArea(cAliasQry)	
	       dbSkip()
		   Loop
		ElseIf !Empty(cFilSE1) .And. (&cFilSE1) .And. lFirst
			oReport:Section(nSection):PrintLine()
			lFirst := .F.    
		EndIf 
		If!Empty(cFilSE3) .And. !(cAliasQry)->(&cFilSE3)
		   dbSelectArea(cAliasQry)	
	       dbSkip()
		   Loop
		ElseIf !Empty(cFilSE3) .And. (cAliasQry)->(&cFilSE3) .And. lVend 
			If mv_par12 == 1
				oReport:Section(nSection):PrintLine()       
				lVend:= .F.
			EndIf   
		EndIf
		If!Empty(cFilSA1) 
		   	SA1->(dbSetOrder(1))               
			If SA1->(MsSeek(xFilial()+&(cAlias)->(E3_CODCLI)+&(cAlias)->(E3_LOJA),.T.,.F.))
				If !( SA1->&cFilSa1)	
		  			dbSelectArea(cAliasQry)	
				   	dbSkip()
					Loop
				ElseIf (SA1->&cFilSA1) .And. lVend
					oReport:Section(nSection):PrintLine()
					lVend := .F.	
				EndIf	
		   	EndIf 
		EndIf 		   	
		If nModulo == 12 
			nVlrTitulo:= Round(xMoeda((cAlias)->E3_BASE,SE1->E1_MOEDA,MV_PAR08,(cAlias)->E3_EMISSAO,nDecs+1),nDecs)
		Else
			nVlrTitulo:= Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
		EndIf	
		dEmissao  := SE1->E1_EMISSAO
		cLiquid   := ""
		cDocLiq   := SE1->E1_NUMLIQ
		If mv_par12 == 1
			dVencto   := SE1->E1_VENCTO
			aLiquid	  := {}
			aValLiq	  := {}
			aLiqProp  := {}
			nTotLiq	  := 0
			If mv_par13 == 1 .And. !Empty(SE1->E1_NUMLIQ) .And. FindFunction("FA440LIQSE1")
				cLiquid := SE1->E1_NUMLIQ
				cDocLiq := SE1->E1_NUMLIQ
				// Obtem os registros que deram origem ao titulo gerado pela liquidacao
				Fa440LiqSe1(SE1->E1_NUMLIQ,@aLiquid,@aValLiq)
				For ny := 1 to Len(aValLiq)
					nTotLiq += aValLiq[ny,2]
				Next
				For ny := 1 to Len(aValLiq)
					aAdd(aLiqProp,(nVlrTitulo/nTotLiq)*aValLiq[ny,2])
				Next
			Endif
			
			If (cAlias)->E3_BAIEMI == "B"
				dBaixa     := (cAlias)->E3_EMISSAO
			Else
				dBaixa     := SE1->E1_BAIXA
			Endif
		EndIf
		If Eof()
			dbSelectArea("SF1")
			SF1->(dbSetOrder(1))

			dbSelectArea("SF2")
			SF2->(dbSetorder(1))
			
			If AllTrim((cAlias)->E3_TIPO) == "NCC"
				SF1->(MsSeek(xFilial("SF1")+(cAlias)->E3_NUM+(cAlias)->E3_PREFIXO+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA,.T.,.F.))
			    nVlrTitulo := Round(xMoeda(SF1->F1_VALMERC,SF1->F1_MOEDA,mv_par08,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA),nDecs)
			    dEmissao   := SF1->F1_DTDIGIT
			Else
		   		SF2->(MsSeek(xFilial("SF2")+(cAlias)->E3_NUM+(cAlias)->E3_PREFIXO,.T.,.F.))
				nVlrTitulo := Round(xMoeda(F2_VALFAT,SF2->F2_MOEDA,mv_par08,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA),nDecs)
		 		dEmissao   := SF2->F2_EMISSAO
			EndIf
			If mv_par12 == 1
				dVencto    := CTOD( "" )
				dBaixa     := CTOD( "" )  	
			EndIf
			If Eof()
				nVlrTitulo := 0
				dbSelectArea("SE1")
				SF1->(dbSetOrder(1))
				cFilialSE1 := xFilial()
				SF1->(MsSeek(cFilialSE1+&(cAlias)->(E3_PREFIXO)+&(cAlias)->(E3_NUM),.T.,.F.))
				While ( !Eof() .And. (cAlias)->E3_PREFIXO == SE1->E1_PREFIXO .And.;
					(cAlias)->E3_NUM     == SE1->E1_NUM .And.;
					(cAlias)->E3_FILIAL  == cFilialSE1 )
					If (SE1->E1_TIPO    == SE3->E3_TIPO  .And. ;
						SE1->E1_CLIENTE == SE3->E3_CODCLI .And. ;
						SE1->E1_LOJA    == SE3->E3_LOJA )
						nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
						If mv_par12 == 1
							dVencto    := CTOD( "" )
							dBaixa     := CTOD( "" )
						EndIf
						If Empty(dEmissao)
							dEmissao := SE1->E1_EMISSAO
						EndIf
					EndIf
					dbSelectArea("SE1")
					SE1->(dbOrderNickName("E1_CLIENTE"))		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					SE1->(dbSkip())
				EndDo
			EndIf
		Endif
		If Empty(dEmissao)
			dEmissao := NIL
		EndIf
		nBasePrt:=	Round(xMoeda((cAlias)->E3_BASE ,1,MV_PAR08,dEmissao,nDecs+1),nDecs)
		nComPrt :=	Round(xMoeda((cAlias)->E3_COMIS,1,MV_PAR08,dEmissao,nDecs+1),nDecs)
		If nBasePrt < 0 .And. nComPrt < 0
			nVlrTitulo := nVlrTitulo * -1
		Endif
		If mv_par12 == 1
			cAjuste := (cAlias)->E3_AJUSTE
			cTipo   := (cAlias)->E3_BAIEMI
			dbSelectArea(cAlias)
			oReport:Section(1):Section(1):Init()
 			oReport:Section(1):Section(1):PrintLine()
  			oReport:IncMeter()
			If mv_par13 == 1
				For nI := 1 To Len(aLiquid)
					nI2 := nI
					SE1->(MsGoto(aLiquid[nI]))
				    oReport:Section(1):SetHeaderBreak(.T.)
					oReport:Section(1):Section(1):Section(1):Init()
					oReport:Section(1):Section(1):Section(1):PrintLine()
				Next
				If Len(aLiquid) > 0
					oReport:Section(1):Section(1):Section(1):Finish()
				EndIf
			Endif			
			
		EndIf
		
		nAc1 += nBasePrt
		nAc2 += nComPrt
		nTotPerVen += (nBasePrt*(cAlias)->E3_PORC)/100
		If cTitulo <> (cAlias)->E3_PREFIXO+(cAlias)->E3_NUM+(cAlias)->E3_PARCELA+(cAlias)->E3_TIPO+(cAlias)->E3_VEND+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA 
			nAc3   += nVlrTitulo
			cTitulo:= (cAlias)->E3_PREFIXO+(cAlias)->E3_NUM+(cAlias)->E3_PARCELA+(cAlias)->E3_TIPO+(cAlias)->E3_VEND+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA
			cDocLiq:= ""
		EndIf
		
		dbSelectArea(cAlias)
		dbSkip()
	EndDo
	
	If mv_par12 == 1
		nTotBase 	+= nAc1
		nTotComis 	+= nAc2
		nTotPorc	:= NoRound((nTotComis / nTotBase)*100,2)
		nTotPerVen  := NoRound((nTotPerVen/nAc1)*100,2)
		// Incluido a função "Posicione" por Júlio Soares para apresentar o nome do vendedor no totalizador do fim de página

		// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
		//oReport:Section(1):Section(1):SetTotalText("Total do Vendedor: " + cVend + "  -  " +(POSICIONE("SA3",1,xFilial("SA3")+cVend,"A3_NOME")))
		oReport:Section(1):Section(1):SetTotalText("Total do Representante: " + cVend + "  -  " +(POSICIONE("SA3",1,xFilial("SA3")+cVend,"A3_NOME")))
		// Fim - Fernando Bombardi - ALLSS - 03/03/2022

		oReport:Section(1):Section(1):Finish()
	EndIf

	nValIR    := 0
	nTotSemIR := 0
	If mv_par10 > 0 .And. (nAc2 * mv_par10 / 100) > _nVLRETIR //IR
		nValIR    := nAc2 * (MV_PAR10/100)
		nTotSemIR := nAc2 - (nAc2 * (MV_PAR10/100))
	Else
		nTotSemIR := nAc2
	EndIf
	
	If mv_par12 == 2
		nTotBase 	+= nAc1
		nTotComis 	+= nAc2
		nTotPorc	:= NoRound((nTotComis / nTotBase)*100,2)
		nTotPerVen  := NoRound((nTotPerVen/nAc1)*100,2)
		oReport:Section(nSection):Init()				
		oReport:Section(nSection):PrintLine()
	EndIf	
	oReport:Section(nSection):Finish()
	
	If mv_par12 == 1 .And. mv_par10 > 0
		oReport:Section(2):Init()
		oReport:Section(2):PrintLine()
		oReport:Section(2):Finish()
	EndIf
	
	If mv_par11 == 1
	   oReport:Section(nSection):SetPageBreak(.T.)
	EndIf
	If mv_par12 == 2
		oReport:IncMeter()
	EndIf
	nTGerBas    += nAc1
    nTGerCom    += nAc2
EndDo
nTotPorc := ((nTGerCom*100)/nTGerBas)	     
oReport:Section(nSection):SetPageBreak(.T.)

#IFNDEF TOP
   RetIndex("SE3")
#ENDIF
   
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ?MATR540R3?Autor ?Claudinei M. Benzi       ?Data ?13.04.92 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ?Relatorio de Comissoes.                                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ?MATR540(void)                                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?Generico                                                      ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?DATA   ?BOPS ³Programad.³ALTERACAO                                      ³±?
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?5.02.03³XXXXXX³Eduardo Ju³Inclusao de Queries para filtros em TOPCONNECT.³±?
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Matr540R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Define Variaveis                                             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local STR0001 := (STR0001 + " De - " + (DTOS(mv_par02)) + " At?- " + (DTOS(mv_par03)))//"Relatorio de Comissoes"
Local wnrel
Local titulo    := "" //STR0001//"Relatorio de Comissoes"
Local cDesc1    := STR0002  //"Emissao do relatorio de Comissoes."
Local tamanho   := "G"
Local limite    := 220
Local cString   := "SE3"
Local cAliasAnt := Alias()
Local cOrdemAnt := IndexOrd()
Local nRegAnt   := Recno()
Local cDescVend := " "

Private aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private nomeprog:= "RMATR540"
Private aLinha  := { },nLastKey := 0
Private cPerg   := "RMATR540"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Verifica as perguntas selecionadas                           ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()
Pergunte("RMATR540",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Variaveis utilizadas para parametros                          ?
//?mv_par01        	// Pela <E>missao,<B>aixa ou <A>mbos      ?
//?mv_par02        	// A partir da data                       ?
//?mv_par03        	// Ate a Data                             ?
//?mv_par04 	    	// Do Vendedor                            ?
//?mv_par05	     	// Ao Vendedor                            ?
//?mv_par06	     	// Quais (a Pagar/Pagas/Ambas)            ?
//?mv_par07	     	// Incluir Devolucao ?                    ?
//?mv_par08	     	// Qual moeda                             ?
//?mv_par09	     	// Comissao Zerada ?                      ?
//?mv_par10	     	// Abate IR Comiss                        ?
//?mv_par11	     	// Quebra pag.p/Vendedor                  ?
//?mv_par12	     	// Tipo de Relatorio (Analitico/Sintetico)?
//?mv_par13	     	// Imprime detalhes origem                ?
//?mv_par14         // Nome cliente							  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Envia controle para a funcao SETPRINT                        ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "RMATR540"
wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,"","",.F.,"",.F.,Tamanho)

If nLastKey==27
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey ==27
	dbClearFilter()
	Return
Endif
// Declarado a fim de apresentar as datas de emissão de/at?no cabeçalho do relatório.
// Incluído por Júlio Soares a fim de implementar a data dos paramêtros..
Titulo := ("Relatório de comissões De - " + (DTOC(mv_par02)) + " At?- " + (DTOC(mv_par03)))

RptStatus({|lEnd| C540Imp(@lEnd,wnRel,cString)},Titulo) ///Titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Retorna para area anterior, indice anterior e registro ant.  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(caliasAnt)
DbSetOrder(cOrdemAnt)
DbGoto(nRegAnt)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?C540IMP  ?Autor ?Rosane Luciane Chene  ?Data ?09.11.95 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Chamada do Relatorio                                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATR540			                                          ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?/
*/
Static Function C540Imp(lEnd,WnRel,cString)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Define Variaveis                                             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local CbCont,cabec1,cabec2
Local tamanho  := "G"
Local limite   := 220
Local nomeprog := "RMATR540"
Local imprime  := .T.
Local cPict    := ""
Local cTexto,j :=0,nTipo:=0
Local cCodAnt,nCol:=0
Local nAc1:=0,nAc2:=0,nAg1:=0,nAg2:=0,nAc3:=0,nAg3:=0,nAc4:=0,nAg4:=0,lFirstV:=.T.
Local nTregs,nMult,nAnt,nAtu,nCnt,cSav20,cSav7
Local lContinua:= .T.
Local cNFiscal :=""
Local aCampos  :={}
Local lImpDev  := .F.
Local cBase    := ""
Local cNomArq, cCondicao, cFilialSE1, cFilialSE3, cChave, cFiltroUsu
Local nDecs    := GetMv("MV_CENT"+(IIF(mv_par08 > 1 , STR(mv_par08,1),"")))
Local nBasePrt :=0, nComPrt:=0 
Local aStru    := SE3->(dbStruct()), ni
Local nDecPorc := TamSX3("E3_PORC")[2]
Local nVlrTitulo := 0
Local nTotPerVen := 0
Local nTotPerGer := 0

Local cDocLiq   := ""
Local cTitulo  := "" 
Local dEmissao := CTOD( "" ) 
Local nTotLiq  := 0
Local aLiquid  := {}
Local aValLiq  := {}
Local aLiqProp := {}
Local ny
Local aColuna := IIF(cPaisLoc <> "MEX",{15,19,42,46,83,95,107,119,130,137,153,169,176,195,203},{28,35,58,62,99,111,123,135,146,153,169,185,192,211,219})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Variaveis utilizadas para Impressao do Cabecalho e Rodape    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := Space(10)
cbcont   := 00
li       := 80
m_pag    := 01
imprime  := .T.

nTipo := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Definicao dos cabecalhos                                     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
STR0005 := (STR0005 + " De " + (DTOS(mv_par02)) + " At?" + (DTOS(mv_par03)))//"Relatorio de Comissoes"

If mv_par12 == 1
	If mv_par01 == 1
		titulo := OemToAnsi(STR0005)+OemToAnsi(STR0006)+" ("+OemToAnsi(STR0019)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1)) //"RELATORIO DE COMISSOES "###"(PGTO PELA EMISSAO)"
	Elseif mv_par01 == 2
		titulo := OemToAnsi(STR0005)+OemToAnsi(STR0007)+" ("+OemToAnsi(STR0019)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES "###"(PGTO PELA BAIXA)"
	Else
		titulo := OemToAnsi(STR0008)+" ("+OemToAnsi(STR0019)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES"
	Endif

	cabec1:=OemToAnsi(STR0009)	//"PRF NUMERO   PARC. CODIGO DO              LJ  NOME                                 DT.BASE     DATA        DATA        DATA       NUMERO          VALOR           VALOR      %           VALOR    TIPO"
	cabec2:=OemToAnsi(STR0010)	//"    TITULO         CLIENTE                                                         COMISSAO    VENCTO      BAIXA       PAGTO      PEDIDO         TITULO            BASE               COMISSAO   COMISSAO"
									// XXX XXXXXXxxxxxx X XXXXXXxxxxxxxxxxxxxx   XX  012345678901234567890123456789012345 XX/XX/XXxx  XX/XX/XXxx  XX/XX/XXxx  XX/XX/XXxx XXXXXX 12345678901,23  12345678901,23  99.99  12345678901,23     X       AJUSTE
									// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
									// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	If cPaisLoc == "MEX"
		Cabec1 := Substr(Cabec1,1,10) + Space(16) + Substr(Cabec1,11)
		Cabec2 := Substr(Cabec2,1,10) + Space(16) + Substr(Cabec2,11)
	EndIf								
Else
	If mv_par01 == 1
		titulo := OemToAnsi(STR0005)+OemToAnsi(STR0006)+" ("+OemToAnsi(STR0020)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1)) //"RELATORIO DE COMISSOES "###"(PGTO PELA EMISSAO)"
	Elseif mv_par01 == 2
		titulo := OemToAnsi(STR0005)+OemToAnsi(STR0007)+" ("+OemToAnsi(STR0020)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES "###"(PGTO PELA BAIXA)"
	Else
		titulo := OemToAnsi(STR0008)+" ("+OemToAnsi(STR0020)+") "+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES"
	Endif

	// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
	//cabec1:=OemToAnsi(STR0021) //"CODIGO VENDEDOR                                           TOTAL            TOTAL      %            TOTAL           TOTAL           TOTAL"
	cabec1:=OemToAnsi("CODIGO REPRESENTANTE                                      TOTAL            TOTAL      %            TOTAL           TOTAL           TOTAL") //"CODIGO VENDEDOR                                           TOTAL            TOTAL      %            TOTAL           TOTAL           TOTAL"
	// Fim - Fernando Bombardi - ALLSS - 03/03/2022
	
	cabec2:=OemToAnsi(STR0022) //"                                                         TITULO             BASE                COMISSAO              IR          (-) IR"
                                //"XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 123456789012,23  123456789012,23  99.99  123456789012,23 123456789012,23 123456789012,23
                                //"0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                                //"0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Monta condicao para filtro do arquivo de trabalho            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SE3")	// Posiciona no arquivo de comissoes
SE3->(DbSetOrder(2))			// Por Vendedor
cFilialSE3 := xFilial()
cNomArq    :=CriaTrab("",.F.)

cCondicao := "SE3->E3_FILIAL=='" + cFilialSE3 + "'"
cCondicao += ".And.SE3->E3_VEND>='" + mv_par04 + "'"
cCondicao += ".And.SE3->E3_VEND<='" + mv_par05 + "'"
cCondicao += ".And.DtoS(SE3->E3_EMISSAO)>='" + DtoS(mv_par02) + "'"
cCondicao += ".And.DtoS(SE3->E3_EMISSAO)<='" + DtoS(mv_par03) + "'" 

If mv_par01 == 1
	cCondicao += ".And.SE3->E3_BAIEMI!='B'"  // Baseado pela emissao da NF
Elseif mv_par01 == 2
	cCondicao += " .And.SE3->E3_BAIEMI=='B'"  // Baseado pela baixa do titulo
Endif 

If mv_par06 == 1 		// Comissoes a pagar
	cCondicao += ".And.Dtos(SE3->E3_DATA)=='"+Dtos(Ctod(""))+"'"
ElseIf mv_par06 == 2 // Comissoes pagas
	cCondicao += ".And.Dtos(SE3->E3_DATA)!='"+Dtos(Ctod(""))+"'"
Endif

If mv_par09 == 1 		// Nao Inclui Comissoes Zeradas
   cCondicao += ".And.SE3->E3_COMIS<>0"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Cria expressao de filtro do usuario                          ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ! Empty(aReturn[7]) )
	cFiltroUsu := &("{ || " + aReturn[7] +  " }")
Else
	cFiltroUsu := { || .t. }
Endif

nAg1 := nAg2 := nAg3 := nAg4 := 0

#IFDEF TOP
	If TcSrvType() != "AS/400"
		cOrder := SqlOrder(SE3->(IndexKey()))
		/*
		cQuery := " SELECT * "
		cQuery += " FROM "+	RetSqlName("SE3")
		cQuery += " WHERE E3_FILIAL = '" + xFilial("SE3") + "' AND "
	  	cQuery += "	E3_VEND >= '"  + mv_par04 + "' AND E3_VEND <= '"  + mv_par05 + "' AND " 
		cQuery += "	E3_EMISSAO >= '" + Dtos(mv_par02) + "' AND E3_EMISSAO <= '"  + Dtos(mv_par03) + "' AND " 
		*/

		cQuery := " SELECT * "
		cQuery += " FROM "+	RetSqlName("SE3")
		cQuery += " WHERE E3_FILIAL = '" + xFilial("SE3") + "' AND "
	  	cQuery += "	E3_VEND >= '"  + mv_par04 + "' AND E3_VEND <= '"  + mv_par05 + "' AND " 
		cQuery += "	E3_EMISSAO >= '" + Dtos(mv_par02) + "' AND E3_EMISSAO <= '"  + Dtos(mv_par03) + "' AND " 
	
		If mv_par01 == 1
			cQuery += "E3_BAIEMI <> 'B' AND "  //Baseado pela emissao da NF
		Elseif mv_par01 == 2
			cQuery += "E3_BAIEMI =  'B' AND "  //Baseado pela baixa do titulo  
		EndIf	
		
		If mv_par06 == 1 		//Comissoes a pagar
			cQuery += "E3_DATA = '" + Dtos(Ctod("")) + "' AND "
		ElseIf mv_par06 == 2 //Comissoes pagas
  			cQuery += "E3_DATA <> '" + Dtos(Ctod("")) + "' AND "
		Endif 
		
		If mv_par09 == 1 		//Nao Inclui Comissoes Zeradas
   		cQuery+= "E3_COMIS <> 0 AND "
		EndIf  
		
		cQuery += "D_E_L_E_T_ = '' "   

		cQuery += " ORDER BY "+ cOrder

		cQuery := ChangeQuery(cQuery)
											
		dbSelectArea("SE3")
		dbCloseArea()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE3', .F., .T.)
			
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE3', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next 
	Else
	
#ENDIF	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Cria arquivo de trabalho                                     ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave := IndexKey()
		cNomArq :=CriaTrab("",.F.)
		IndRegua("SE3",cNomArq,cChave,,cCondicao, OemToAnsi(STR0016)) //"Selecionando Registros..."
		nIndex := RetIndex("SE3")
		DbSelectArea("SE3") 
		#IFNDEF TOP
			DbSetIndex(cNomArq+OrdBagExT())
		#ENDIF
		DbSetOrder(nIndex+1)

#IFDEF TOP
	EndIf
#ENDIF	

SetRegua(RecCount())		// Total de Elementos da regua 
DbGotop()
While !Eof()
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0011)  //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIF
	IncRegua()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Processa condicao do filtro do usuario                       ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Eval(cFiltroUsu)
		Dbskip()
		Loop
	Endif

	nAc1 := nAc2 := nAc3 := nAc4 := 0 
	nTotPerVen := 0
	lFirstV:= .T.
	cVend  := SE3->E3_VEND
	
	While !Eof() .AND. SE3->E3_VEND == cVend
		IncRegua()
		cDocLiq:= ""
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Processa condicao do filtro do usuario                       ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! Eval(cFiltroUsu)
			Dbskip()
			Loop
		Endif  
		
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Seleciona o Codigo do Vendedor e Imprime o seu Nome          ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lFirstV
			dbSelectArea("SA3")
			MsSeek(xFilial()+SE3->E3_VEND,.T.,.F.)
			If mv_par12 == 1
				cDescVend := SE3->E3_VEND + " - " + A3_NOME 
			
				// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
				//@li, 00 PSAY OemToAnsi(STR0012) + " - " + cDescVend //"Vendedor : "
				@li, 00 PSAY OemToAnsi("REPRESENTANTE: ") + " - " + cDescVend //"Vendedor : "
				// Fim - Fernando Bombardi - ALLSS - 03/03/2022

				li+=2
			Else
				@li, 00 PSAY SE3->E3_VEND + " - "
				@li, 07 PSAY A3_NOME 
			EndIf
			dbSelectArea("SE3")
//			lFirstV := .F.
			lFirstV := .F.
		EndIF
		
		dbSelectArea("SE1")
//		dbSetOrder(1)
//		MsSeek(xFilial()+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO,.T.,.F.)
		SE1->(dbOrderNickName("E1_CLIENTE"))		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		MsSeek(xFilial("SE1")+SE3->E3_CODCLI+SE3->E3_LOJA+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO,.T.,.F.)
		                                                           
		// Se nao imprime detalhes da origem, desconsidera titulos faturados
		If mv_par13 <> 1 .And. !Empty(SE1->E1_FATURA) .And. SE1->E1_FATURA <> "NOTFAT"
			SE3->( dbSkip() )
			Loop
		EndIf

		If mv_par12 == 1
			@li, 00 PSAY SE3->E3_PREFIXO
			@li, 04 PSAY SE3->E3_NUM
			@li, aColuna[1] PSAY SE3->E3_PARCELA
			@li, aColuna[2] PSAY SE3->E3_CODCLI
			@li, aColuna[3] PSAY SE3->E3_LOJA
		
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(MsSeek(xFilial()+SE3->E3_CODCLI+SE3->E3_LOJA,.T.,.F.))
			@li, aColuna[4] PSAY IF(mv_par14 == 1,Substr(SA1->A1_NREDUZ,1,35),Substr(SA1->A1_NOME,1,35))
		
			dbSelectArea("SE3")
			@li, aColuna[5] PSAY SE3->E3_EMISSAO
		EndIf
		
		dbSelectArea("SE1")
//		SE1->(dbSetOrder(1))
//		SE1->(MsSeek(xFilial()+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO,.T.,.F.))
		SE1->(dbOrderNickName("E1_CLIENTE"))		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		MsSeek(xFilial("SE1")+SE3->E3_CODCLI+SE3->E3_LOJA+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO,.T.,.F.)
		nVlrTitulo := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
		dVencto    := SE1->E1_VENCTO  
		dEmissao   := SE1->E1_EMISSAO 
		aLiquid	   := {}
		aValLiq	   := {}
		aLiqProp   := {}
		nTotLiq	   := 0
		If mv_par13 == 1 .And. !Empty(SE1->E1_NUMLIQ) .And. FindFunction("FA440LIQSE1")
			cLiquid := SE1->E1_NUMLIQ			
			cDocLiq := SE1->E1_NUMLIQ
			// Obtem os registros que deram origem ao titulo gerado pela liquidacao
			Fa440LiqSe1(SE1->E1_NUMLIQ,@aLiquid,@aValLiq)
			For ny := 1 to Len(aValLiq)
				nTotLiq += aValLiq[ny,2]
			Next
			For ny := 1 to Len(aValLiq)
				aAdd(aLiqProp,(nVlrTitulo/nTotLiq)*aValLiq[ny,2])
			Next
		Endif
		/*
		Nas comissoes geradas por baixa pego a data da emissao da comissao que eh igual a data da baixa do titulo.
		Isto somente dara diferenca nas baixas parciais
		*/	 
		
		If SE3->E3_BAIEMI == "B"
			dBaixa     := SE3->E3_EMISSAO
    	Else
			dBaixa     := SE1->E1_BAIXA
		Endif
		
		If Eof()

			dbSelectArea("SF1")
			dbSetOrder(1)

			dbSelectArea("SF2")
			dbSetorder(1)
			
			If AllTrim(SE3->E3_TIPO) == "NCC"
				SF1->(MsSeek(xFilial("SF1")+SE3->E3_NUM+SE3->E3_PREFIXO+SE3->E3_CODCLI+SE3->E3_LOJA,.T.,.F.))
			    nVlrTitulo := Round(xMoeda(SF1->F1_VALMERC,SF1->F1_MOEDA,mv_par07,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA),nDecs)
			    dEmissao   := SF1->F1_DTDIGIT
			Else
				MsSeek(xFilial()+SE3->E3_NUM+SE3->E3_PREFIXO,.T.,.F.)
			    nVlrTitulo := Round(xMoeda(F2_VALFAT,SF2->F2_MOEDA,mv_par07,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA),nDecs)
			    dEmissao   := SF2->F2_EMISSAO
			EndIf
			
			dVencto    := " "
			dBaixa     := " "
			
			dEmissao   := SF2->F2_EMISSAO 
			
			If Eof()
				nVlrTitulo := 0
				dbSelectArea("SE1")
//				dbSetOrder(1)
				SE1->(dbOrderNickName("E1_CLIENTE"))		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				cFilialSE1 := xFilial()
				MsSeek(cFilialSE1+SE3->E3_PREFIXO+SE3->E3_NUM,.T.,.F.)
				While ( !Eof() .And. ;
						SE3->E3_PREFIXO  == SE1->E1_PREFIXO .And.;
						SE3->E3_NUM      == SE1->E1_NUM     .And.;
						SE3->E3_FILIAL   == cFilialSE1 )
					If ( SE1->E1_TIPO    == SE3->E3_TIPO  .And. ;
						SE1->E1_CLIENTE == SE3->E3_CODCLI .And. ;
						SE1->E1_LOJA    == SE3->E3_LOJA )
						nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
						dVencto    := " "
						dBaixa     := " "
						If Empty(dEmissao)
							dEmissao := SE1->E1_EMISSAO
						EndIf
					EndIf
					dbSelectArea("SE1")
					SE1->(dbOrderNickName("E1_CLIENTE"))		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					dbSkip()
				EndDo
			EndIf
		Endif

		If Empty(dEmissao)
			dEmissao := NIL
		EndIf
		
		//Preciso destes valores para pasar como parametro na funcao TM(), e como 
		//usando a xmoeda direto na impressao afetaria a performance (deveria executar
		//duas vezes, uma para imprimir e outra para pasar para a picture), elas devem]
		//ser inicializadas aqui. Bruno.

		nBasePrt:=	Round(xMoeda(SE3->E3_BASE ,1,MV_PAR08,dEmissao,nDecs+1),nDecs)
		nComPrt :=	Round(xMoeda(SE3->E3_COMIS,1,MV_PAR08,dEmissao,nDecs+1),nDecs)

		If nBasePrt < 0 .And. nComPrt < 0
			nVlrTitulo := nVlrTitulo * -1
		Endif	
		
		dbSelectArea("SE3")
		
		If mv_par12 == 1
			@ li,aColuna[6]  PSAY dVencto
			@ li,aColuna[7]  PSAY dBaixa
			@ li,aColuna[8]  PSAY SE3->E3_DATA
			@ li,aColuna[9]  PSAY SE3->E3_PEDIDO	Picture "@!"
			@ li,aColuna[10] PSAY nVlrTitulo		Picture tm(nVlrTitulo,14,nDecs)
			@ li,aColuna[11] PSAY nBasePrt 			Picture tm(nBasePrt,14,nDecs)
			If cPaisLoc<>"BRA"
				@ li,aColuna[12] PSAY SE3->E3_PORC		Picture tm(SE3->E3_PORC,6,nDecPorc)
			Else
				@ li,aColuna[12] PSAY SE3->E3_PORC		Picture tm(SE3->E3_PORC,6)
			Endif
			@ li,aColuna[13] PSAY nComPrt			Picture tm(nComPrt,14,nDecs)
			@ li,aColuna[14] PSAY SE3->E3_BAIEMI

			If ( SE3->E3_AJUSTE == "S" .And. MV_PAR07==1)
				@ li,aColuna[15] PSAY STR0018 //"AJUSTE "
			EndIf
			li++
			// Imprime titulos que deram origem ao titulo gerado por liquidacao
			If mv_par13 == 1
				For nI := 1 To Len(aLiquid)
					If li > 55
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
					EndIF
					If nI == 1
						@ ++li, 0 PSAY __PrtThinLine()
						@ ++li, 0 PSAY STR0023 +SE1->E1_NUMLIQ // "Detalhes : Titulos de origem da liquidação "
						@ ++li,10 PSAY STR0024 // "Prefixo    Numero          Parc    Tipo    Cliente   Loja    Nome                                       Valor Titulo      Data Liq.         Valor Liquidação      Valor Base Liq."
//         Prefixo    Numero          Parc    Tipo    Cliente   Loja    Nome                                       Valor Titulo      Data Liq.         Valor Liquidação      Valor Base Liq.
//         XXX        XXXXXXXXXXXX    XXX     XXXX    XXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999999999999     99/99/9999          999999999999999      999999999999999 
   					@ ++li, 0 PSAY __PrtThinLine()
						li++
					Endif
					cDocLiq  := SE1->E1_NUMLIQ
					SE1->(MsGoto(aLiquid[nI]))
					SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.,.F.))
					@li,  10 PSAY SE1->E1_PREFIXO
					@li,  21 PSAY SE1->E1_NUM
					@li,  37 PSAY SE1->E1_PARCELA
					@li,  45 PSAY SE1->E1_TIPO
					@li,  53 PSAY SE1->E1_CLIENTE
					@li,  64 PSAY SE1->E1_LOJA
					@li,  71 PSAY IF(mv_par14 == 1,Substr(SA1->A1_NREDUZ,1,35),Substr(SA1->A1_NOME,1,35))
					@li, 111 PSAY SE1->E1_VALOR PICTURE Tm(SE1->E1_VALOR,15,nDecs)
					@li, 132 PSAY aValLiq[nI,1] 
					@li, 151 PSAY aValLiq[nI,2] PICTURE Tm(SE1->E1_VALOR,15,nDecs)
					@li, 172 PSAY aLiqProp[nI] PICTURE Tm(SE1->E1_VALOR,15,nDecs)
					li++
				Next
				// Imprime o separador da ultima linha
				If Len(aLiquid) >= 1
					@ li++, 0 PSAY __PrtThinLine()
				Endif
			Endif	
		EndIf
		nAc1 += nBasePrt
		nAc2 += nComPrt
		nTotPerVen += (nBasePrt*SE3->E3_PORC)/100
		If cTitulo <> SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO+SE3->E3_VEND+SE3->E3_CODCLI+SE3->E3_LOJA  .And. Empty(cDocLiq)
			nAc3   += nVlrTitulo
			cTitulo:= SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO+SE3->E3_VEND+SE3->E3_CODCLI+SE3->E3_LOJA
			cDocLiq:= ""
		EndIf
		
		dbSelectArea("SE3")
		dbSkip()
	EndDo
	
	If mv_par12 == 1
		li++
	
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF

		// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
		//@ li, 00  PSAY OemToAnsi(STR0013)+ " - " +cDescVend  //"TOTAL DO VENDEDOR --> "
		@ li, 00  PSAY OemToAnsi("TOTAL DO REPRESENTANTE --> ")+ " - " +cDescVend  //"TOTAL DO VENDEDOR --> "
		// Fim - Fernando Bombardi - ALLSS - 03/03/2022

		@ li,aColuna[10]-1  PSAY nAc3 	PicTure tm(nAc3,15,nDecs)
		@ li,aColuna[11]-1  PSAY nAc1 	PicTure tm(nAc1,15,nDecs)
	
		If nAc1 != 0
			If cPaisLoc=="BRA"
				//@ li, aColuna[12] PSAY NoRound((nAc2/nAc1)*100,2)   PicTure "999.99"
				@ li, aColuna[12] PSAY NoRound((nTotPerVen/nAc1)*100,2)   PicTure "999.99"
			Else
				@ li, aColuna[12] PSAY NoRound((nAc2/nAc1)*100)   PicTure "999.99"
			Endif
		Endif
	
		@ li, aColuna[13]-1  PSAY nAc2 PicTure tm(nAc2,15,nDecs)
		li++
	
		If mv_par10 > 0 .And. (nAc2 * mv_par10 / 100) > _nVLRETIR //IR
			@ li, 00  PSAY OemToAnsi(STR0015)  //"TOTAL DO IR       --> "
			nAc4 += (nAc2 * mv_par10 / 100)				
			@ li, aColuna[13]-1  PSAY nAc4 PicTure tm(nAc2 * mv_par10 / 100,15,nDecs)
			li ++
			@ li, 00  PSAY OemToAnsi(STR0017)  //"TOTAL (-) IR      --> "
			@ li, aColuna[13]-1 PSAY nAc2 - nAc4 PicTure tm(nAc2,15,nDecs)
			li ++
		EndIf
	
		@ li, 00  PSAY __PrtThinLine()

		If mv_par11 == 1  // Quebra pagina por vendedor (padrao)
			li := 60  
		Else
		   li+= 2
		Endif
	Else
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF
		@ li,048  PSAY nAc3 	PicTure tm(nAc3,15,nDecs)
		@ li,065  PSAY nAc1 	PicTure tm(nAc1,15,nDecs)
		If nAc1 != 0
			If cPaisLoc=="BRA"
				@ li, 081 PSAY NoRound((nAc2/nAc1)*100,2)  PicTure "999.99"
			Else
				@ li, 081 PSAY NoRound((nAc2/nAc1)*100)   PicTure "999.99"
			Endif
		Endif
		@ li, 089  PSAY nAc2 PicTure tm(nAc2,15,nDecs)
		If mv_par10 > 0 .And. (nAc2 * mv_par10 / 100) > _nVLRETIR //IR
			nAc4 += (nAc2 * mv_par10 / 100)
			@ li, 105  PSAY nAc4 PicTure tm(nAc2 * mv_par10 / 100,15,nDecs)
			@ li, 121 PSAY nAc2 - nAc4 PicTure tm(nAc2,15,nDecs)
		EndIf
		li ++
	EndIf
	
	dbSelectArea("SE3")
	nAg1 += nAc1
	nAg2 += nAc2
 	nAg3 += nAc3
 	nAg4 += nAc4
 	nTotPerGer += nTotPerVen
EndDo

If (nAg1+nAg2+nAg3+nAg4) != 0
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif

	If mv_par12 == 1
		@li,  00 PSAY OemToAnsi(STR0014)  //"TOTAL  GERAL      --> "
		@li, aColuna[10]-1 PSAY nAg3	Picture tm(nAg3,15,nDecs)
		@li, aColuna[11]-1 PSAY nAg1	Picture tm(nAg1,15,nDecs)
		If cPaisLoc=="BRA"
			//@li, aColuna[12] PSAY NoRound((nAg2/nAg1)*100,2) Picture "999.99"
			@li, aColuna[12] PSAY NoRound((nTotPerGer/nAg1)*100,2) Picture "999.99"
		Else
			@li, aColuna[12] PSAY NoRound((nAg2/nAg1)*100) Picture "999.99"
		Endif
		@li, aColuna[13]-1 PSAY nAg2 Picture tm(nAg2,15,nDecs)
		If mv_par10 > 0 .And. (nAg2 * mv_par10 / 100) > GetMV("MV_VLRETIR")//IR
			li ++
			@ li, 00  PSAY OemToAnsi(STR0015)  //"TOTAL DO IR       --> "
			@ li, 175  PSAY nAg4 PicTure tm((nAg2 * mv_par10 / 100),15,nDecs)
			li ++
			@ li, 00  PSAY OemToAnsi(STR0017)  //"TOTAL (-) IR       --> "
			@ li, 175  PSAY nAg2 - nAg4 Picture tm(nAg2,15,nDecs)
		EndIf
	Else
		@li,000  PSAY __PrtThinLine()
		li ++
		@li,000 PSAY OemToAnsi(STR0014)  //"TOTAL  GERAL      --> "
		@li,048 PSAY nAg3	Picture tm(nAg3,15,nDecs)
		@li,065 PSAY nAg1	Picture tm(nAg1,15,nDecs)
		If cPaisLoc=="BRA"
			@li,081 PSAY NoRound((nAg2/nAg1)*100,2) Picture "999.99"
		Else
			@li,081 PSAY NoRound((nAg2/nAg1)*100) Picture "999.99"
		Endif
		@li,089 PSAY nAg2 Picture tm(nAg2,15,nDecs)
		If mv_par10 > 0 .And. (nAg2 * mv_par10 / 100) > GetMV("MV_VLRETIR")//IR
			@ li,105  PSAY nAg4 PicTure tm((nAg2 * mv_par10 / 100),15,nDecs)
			@ li,121  PSAY nAg2 - nAg4 Picture tm(nAg2,15,nDecs)
		EndIf
	EndIf
	roda(cbcont,cbtxt,"G")
EndIF
    
#IFDEF TOP
	If TcSrvType() != "AS/400"
  		dbSelectArea("SE3")
		DbCloseArea()
		chkfile("SE3")
	Else	
#ENDIF
		fErase(cNomArq+OrdBagExt())
#IFDEF TOP
	Endif
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Restaura a integridade dos dados                             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE3")
RetIndex("SE3")
DbSetOrder(2)
dbClearFilter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Se em disco, desvia para Spool                               ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³AjustaSX1 ºAutor  ³Ana Paula N. Silva  ?Data ? 20/09/07   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?                                                           º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?MATR540                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function AjustaSX1()
/* FB - RELEASE 12.1.23
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local aAreaSX1 := GetArea()

DbSelectArea("SX1")
DbSetOrder(1)

MsSeek(PadR("RMATR540",Len(SX1->X1_GRUPO)) + "09",.T.,.F.)
RecLock("SX1",.F.)
Replace X1_PRESEL With 1
Replace X1_DEF01 With "Não"
Replace X1_DEFSPA1 With "No"
Replace X1_DEFENG1 With "No" 

Replace X1_DEF02 With "Sim"
Replace X1_DEFSPA2 With "Si"
Replace X1_DEFENG2 With "Yes" 

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}
AADD(aHelpPor,'Indica que não ser?impresso')
AADD(aHelpPor,'comissões zeradas.')
AADD(aHelpSpa,'Indica que no se imprimirán') 
AADD(aHelpSpa,'comisiones en cero.')
AADD(aHelpEng,'Indicates the system will not')
AADD(aHelpEng,'print commissions zeroed.')
                                                             

PutSX1Help("P.MTR54009.",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}
AADD(aHelpPor,'Informe os códigos dos vendedores dos ')
AADD(aHelpPor,'quais se deseja emitir a relação de ')
AADD(aHelpPor,'comissões.')
AADD(aHelpPor,'Tecla [F3] disponível para consultar ')
AADD(aHelpPor,'o Cadastro de Vendedores.')
AADD(aHelpEng,'Informe os códigos dos vendedores dos ')
AADD(aHelpPor,'quais se deseja emitir a relação de ')
AADD(aHelpPor,'comissões.')
AADD(aHelpEng,'Tecla [F3] disponível para consultar ')
AADD(aHelpEng,'o Cadastro de Vendedores.')
AADD(aHelpSpa,'Informe os códigos dos vendedores dos ')
AADD(aHelpPor,'quais se deseja emitir a relação de ')
AADD(aHelpPor,'comissões.')
AADD(aHelpSpa,'Tecla [F3] disponível para consultar ')
AADD(aHelpSpa,'o Cadastro de Vendedores.')
PutSX1Help("P.MTR540P9R104.",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}
AADD(aHelpPor,'Informe se saltar?por vendedor.')
AADD(aHelpSpa,'Informe se saltar?por vendedor.') 
AADD(aHelpEng,'Informe se saltar?por vendedor.')
PutSX1Help("P.MTR540P9R109.",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}
AADD(aHelpPor,'Informe o código final do intervalo de ')
AADD(aHelpPor,'códigos dos vendedores,os quais se ')
AADD(aHelpPor,'deseja emitir a relação de comissões.')
AADD(aHelpPor,'Tecla [F3] disponível para consultar o ')
AADD(aHelpPor,'Cadastro de Vendedores.')
AADD(aHelpSpa,'') 
AADD(aHelpSpa,'')
AADD(aHelpEng,'')
AADD(aHelpEng,'')                                                   

PutSX1Help("P.MTR54005.",aHelpPor,aHelpEng,aHelpSpa)

SX1->(MsUnLock())
RestArea(aAreaSX1)
*/
Local aAreaSX1 := GetArea()

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))

IF (_cAliasSX1)->(MsSeek(PadR("RMATR540",Len(SX1->X1_GRUPO)) + "09",.T.,.F.))
	RecLock(_cAliasSX1,.F.)
	(_cAliasSX1)->X1_PRESEL  := 1
	(_cAliasSX1)->X1_DEF01   := "Não"
	(_cAliasSX1)->X1_DEFSPA1 := "No"
	(_cAliasSX1)->X1_DEFENG1 := "No" 
	(_cAliasSX1)->X1_DEF02   := "Sim"
	(_cAliasSX1)->X1_DEFSPA2 := "Si"
	(_cAliasSX1)->X1_DEFENG2 := "Yes" 
	(_cAliasSX1)->(MsUnLock())
ENDIF
RestArea(aAreaSX1)

Return
