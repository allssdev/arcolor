#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATR043 ºAutor  ³ Arthur Silva		    º Data ³ 12/12/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de representantes com a relação de clientes	  º±±
±±º          ³ Ativos.													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
///////////////////////////ATENÇÃO!!!/////////////////////////////////////////
//O NOME DA EMPRESA 'ARCOLOR' ESTÁ CHUMABO NESTE FONTE, POIS NÃO ESTÁ NA SM0//
//////////////////////////////////////////////////////////////////////////////
User Function RFATR043()

Private oReport, oSection
Private cTitulo  := OemToAnsi("Relatório de Clientes Ativos do(a) Representante ")
Private _cRotina := "RFATR043"
Private cPerg    := _cRotina

If FindFunction("TRepInUse") .And. TRepInUse()
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Arthur Silva		    ³ Data ³ 12/12/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportDef()

Local _aOrd    := {"Representante + Cliente"}		//{"Solicitação + Produto","Nome + ..."}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Estamos lhe enviando a relação de seus clientes."+CHR(13)+CHR(10)+"Bons Negócios!"+CHR(13)+CHR(10)+"ARCOLOR")
oReport:SetLandscape()			//Paisagem
oReport:SetTotalInLine(.F.)
Pergunte(oReport:uParam,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : //X3TITULO()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao dos itens do Pedido de Vendas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection := TRSection():New(oReport,"Informações",{"SA1","SA3"},_aOrd/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:SetTotalInLine(.F.)

//Definição das colunas do relatório
//TRCell():New(oSection,"A3_NOME"    		,"SA3TMP","Representante"         ,PesqPict  ("SA3","A3_NOME" ),TamSx3("A3_NOME"  )[1]	 ,/*lPixel*/,{|| SA3TMP->A3_NOME        })	// NOME REPRESENTANTE
TRCell():New(oSection,"A1_NOME"    		,"SA3TMP","Cliente" 	          ,PesqPict  ("SA1","A1_NOME" ),TamSx3("A1_NOME"  )[1]	 ,/*lPixel*/,{|| SA3TMP->A1_NOME        })	// NOME CLIENTE
TRCell():New(oSection,"A1_END"    		,"SA3TMP",RetTitle("A1_END"	)	  ,PesqPict  ("SA1","A1_END"  ),TamSx3("A1_END"   )[1]-5 ,/*lPixel*/,{|| SA3TMP->A1_END       	})	// ENDEREÇO
TRCell():New(oSection,"A1_CGC"    		,"SA3TMP",RetTitle("A1_CGC"	)	  ,"@R 99.999.999/9999-99"	   ,TamSx3("A1_CGC"   )[1]+21,/*lPixel*/,{|| SA3TMP->A1_CGC       	})	// CGC
TRCell():New(oSection,"A1_EMAIL"    	,"SA3TMP",RetTitle("A1_EMAIL")	  ,PesqPict  ("SA1","A1_EMAIL"),TamSx3("A1_EMAIL" )[1]-10,/*lPixel*/,{|| SA3TMP->A1_EMAIL		})	// EMAIL
TRCell():New(oSection,"A1_DDD"  		,"SA3TMP",RetTitle("A1_DDD"	)	  ,PesqPict  ("SA1","A1_DDD"  ),TamSx3("A1_DDD"   )[1]	 ,/*lPixel*/,{|| SA3TMP->A1_DDD  	  	})	// DDD
TRCell():New(oSection,"A1_TEL"  		,"SA3TMP",RetTitle("A1_TEL"	)	  ,PesqPict  ("SA1","A1_TEL"  ),TamSx3("A1_TEL"	  )[1]	 ,/*lPixel*/,{|| SA3TMP->A1_TEL     	})	// TELEFONE

/*
oSection:SetEdit(.T.)
oSection:SetUseQuery(.T.)
oSection:SetEditCell(.T.)
//oSection:DelUserCell(.F.)
*/

//oBreak := TRBreak():New(oSection,oSection:Cell("A3_NOME"),"Representante...")

//TRFunction():New(oSection:Cell("CAMPO"),NIL,"COUNT",oBreak) // Totalizador

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Troca descricao do total dos itens                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//oReport:Section(1):SetTotalText("Descrição Totalizador")

//oReport:Section(1):SetEdit(.T.) 
//oReport:Section(1):SetUseQuery(.T.) // Novo componente tReport para adcionar campos de usuario no relatorio qdo utiliza query

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alinhamento a direita as colunas de valor                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oSection:Cell("CAMPO"):SetHeaderAlign("RIGHT")

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor ³Arthur Silva		   º Data ³  12/12/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento das informações para impressão (Print).       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrintReport(oReport)

Local _cOrder  := ""
Local _cField  := ""
Local _cFilSA3 := oSection:GetSqlExp("SA3")
Local _cFilSA1 := oSection:GetSqlExp("SA1")


If Empty(MV_PAR01) .OR. MV_PAR02 > MV_PAR04 .OR. MV_PAR03 > MV_PAR05
	MsgStop("Parâmetros informados incorretamente!",_cRotina+"_002")
	Return
EndIf

//Definição da ordem de apresentação das informações
If oReport:Section(1):GetOrder() == 1			//Ordem por Nome
	_cOrder := "A3_NOME, A1_NOME"
//ElseIf oReport:Section(1):GetOrder() == 2		//Ordem por Nome + ...
//	_cOrder := "Definir aqui a segunda ordem almejada..."
EndIf

_cField  := "%" + _cField  + "%"
_cOrder  := "%" + _cOrder  + "%"
/*
oSection:SetEdit(.T.)
oSection:SetUseQuery(.T.)
oSection:SetEditCell(.T.)
//oSection:DelUserCell(.F.)
*/
//Elimino os filtros do usuário para evitar duplicidades na query, uma vez que já estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
For _x := 1 To Len(oSection:aUserFilter)
	oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
Next
oSection:CSQLEXP := ""
//PROCESSAMENTO DAS INFORMAÇÕES PARA IMPRESSÃO
//Transforma parâmetros do tipo Range em expressao SQL para ser utilizada na query 

MakeSqlExpr(oReport:uParam)
MakeSqlExpr(cPerg)

oSection:BeginQuery()
		BeginSql Alias "SA3TMP"
			SELECT *
			FROM %table:SA3% SA3
				INNER JOIN %table:SA1% SA1 ON SA1.A1_FILIAL     = %xFilial:SA1%
							  AND SA1.A1_COD  BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR04%
							  AND SA1.A1_LOJA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05%
							  AND SA1.A1_MSBLQL    <> '1'
							  AND SA1.A1_CGC       <> ''
							  AND SA1.A1_EST       <> 'EX'
							  AND SA1.A1_VEND       = SA3.A3_COD
							  AND SA1.%NotDel%
			WHERE SA3.A3_FILIAL     = %xFilial:SA3%
			  AND SA3.A3_COD        = %Exp:MV_PAR01%
			  AND LEN(SA3.A3_EMAIL) > 3
			  AND SA3.A3_MSBLQL    <> '1'
			  AND SA3.%NotDel%
			ORDER BY A3_FILIAL, A3_COD, A1_FILIAL, A1_NOME, A1_END, A1_CGC
		EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
oSection:EndQuery()

//MemoWrite("\"+_cRotina+"_QRY_001",oSection:CQUERY)

oSection:Print()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Arthur Silva			 Data ³  12/12/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se as perguntas existem na SX1. Caso não existam,  º±±
±±º          ³as cria.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg()

Local _aArea := GetArea()
Local aRegs  := {}
Local _aTam  := {}
Local i      := 0

cPerg := PADR(cPerg,10)

_aTam  := TamSx3("A3_COD" )
// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
//AADD(aRegs,{cPerg,"01","Do Vendedor           ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
AADD(aRegs,{cPerg,"01","Do Representante        ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"02","Do Cliente            ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"03","Da Loja               ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := TamSx3("A1_COD" )
AADD(aRegs,{cPerg,"04","Até o Cliente         ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SA1","",""})
_aTam  := TamSx3("A1_LOJA")
AADD(aRegs,{cPerg,"05","Até a Loja            ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par05",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next


RestArea(_aArea)

Return
