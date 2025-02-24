#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _CRFL CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOMR007  ºAutor  ³ Anderson C. P. Coelhoº Data ³  13/06/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de itens dos Documentos de Entrada por período. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Especifico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCOMR007()

Local  oReport

Private oSection
Private _cRotina := "RCOMR007"
Private _cPerg   := _cRotina

If FindFunction("TRepInUse") .And. TRepInUse()
	AjPergCM()
	If !Pergunte(_cPerg,.T.)
		Return
	EndIf
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Anderson C. P. Coelho  ³ Data ³ 13/06/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportDef()

Local oReport
//Local oSection
//Local oBreak
Local cTitulo  := "Relatório de Itens dos Documentos de Entrada - COMPRAS"
Local _aOrd    := {"Dt. Entrada, Fornecedor, Loja, Docto., Série, Tipo"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(_cRotina,cTitulo,_cPerg,{|oReport| PrintReport(oReport)},"Emissao do relatório, de acordo com o intervalo informado na opção de Parâmetros.")
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

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
oSection := TRSection():New(oReport,"ITENS DOC. ENTRADA",{"SD1","SF1","SB1","SA1","SA2","SF4"},_aOrd/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:SetTotalInLine(.F.)

//Definição das colunas do relatório
//TRCell():New(oSection,"D1_DTDIGIT"  ,"SD1"/*Tabela*/,RetTitle("D1_DTDIGIT"),PesqPict  ("SD1","D1_DTDIGIT"),TamSx3("D1_DTDIGIT")[1],/*lPixel*/,{|| STOD(SD1TMP->D1_DTDIGIT) })
TRCell():New(oSection,"D1_TIPO"     ,"SD1"/*Tabela*/,RetTitle("D1_TIPO"   ),PesqPict  ("SD1","D1_TIPO"   ),TamSx3("D1_TIPO"   )[1],/*lPixel*/,{|| SD1TMP->D1_TIPO          })
TRCell():New(oSection,"D1_DOC"      ,"SD1"/*Tabela*/,RetTitle("D1_DOC"    ),PesqPict  ("SD1","D1_DOC"    ),TamSx3("D1_DOC"    )[1],/*lPixel*/,{|| SD1TMP->D1_DOC           })
TRCell():New(oSection,"D1_SERIE"    ,"SD1"/*Tabela*/,RetTitle("D1_SERIE"  ),PesqPict  ("SD1","D1_SERIE"  ),TamSx3("D1_SERIE"  )[1],/*lPixel*/,{|| SD1TMP->D1_SERIE         })
TRCell():New(oSection,"D1_FORNECE"  ,"SD1"/*Tabela*/,RetTitle("D1_FORNECE"),PesqPict  ("SD1","D1_FORNECE"),TamSx3("D1_FORNECE")[1],/*lPixel*/,{|| SD1TMP->D1_FORNECE       })
TRCell():New(oSection,"D1_LOJA"     ,"SD1"/*Tabela*/,RetTitle("D1_LOJA"   ),PesqPict  ("SD1","D1_LOJA"   ),TamSx3("D1_LOJA"   )[1],/*lPixel*/,{|| SD1TMP->D1_LOJA          })
TRCell():New(oSection,"NOME"        ,""   /*Tabela*/,RetTitle("A2_NOME"   ),PesqPict  ("SA2","A2_NOME"   ),TamSx3("A2_NOME"   )[1],/*lPixel*/,{|| SD1TMP->NOME             })
TRCell():New(oSection,"B1_COD"      ,"SB1"/*Tabela*/,RetTitle("B1_COD"    ),PesqPict  ("SB1","B1_COD"    ),TamSx3("B1_COD"    )[1],/*lPixel*/,{|| SD1TMP->B1_COD           })
TRCell():New(oSection,"B1_DESC"     ,"SB1"/*Tabela*/,RetTitle("B1_DESC"   ),PesqPict  ("SB1","B1_DESC"   ),TamSx3("B1_DESC"   )[1],/*lPixel*/,{|| SD1TMP->B1_DESC          })
TRCell():New(oSection,"B1_GRUPO"    ,"SB1"/*Tabela*/,RetTitle("B1_GRUPO"  ),PesqPict  ("SB1","B1_GRUPO"  ),TamSx3("B1_GRUPO"  )[1],/*lPixel*/,{|| SD1TMP->B1_GRUPO         })
TRCell():New(oSection,"B1_TIPO"     ,"SB1"/*Tabela*/,RetTitle("B1_TIPO"	  ),PesqPict  ("SB1","B1_TIPO"   ),TamSx3("B1_TIPO"   )[1],/*lPixel*/,{|| SD1TMP->B1_TIPO          })
TRCell():New(oSection,"B1_CONTA"    ,"SB1"/*Tabela*/,RetTitle("B1_CONTA"  ),PesqPict  ("SB1","B1_CONTA"  ),TamSx3("B1_CONTA"  )[1],/*lPixel*/,{|| SD1TMP->B1_CONTA         })
TRCell():New(oSection,"B1_UM"       ,"SB1"/*Tabela*/,RetTitle("B1_UM"	  ),PesqPict  ("SB1","B1_UM"     ),TamSx3("B1_UM"     )[1],/*lPixel*/,{|| SD1TMP->B1_UM            })
TRCell():New(oSection,"D1_QUANT"    ,"SD1"/*Tabela*/,RetTitle("D1_QUANT"  ),PesqPictQt("D1_QUANT"	     ),TamSx3("D1_QUANT"  )[1],/*lPixel*/,{|| SD1TMP->D1_QUANT         })
TRCell():New(oSection,"D1_TES"      ,"SD1"/*Tabela*/,RetTitle("D1_TES"    ),PesqPict  ("SD1","D1_TES"    ),TamSx3("D1_TES"    )[1],/*lPixel*/,{|| SD1TMP->D1_TES           })
TRCell():New(oSection,"D1_CF"       ,"SD1"/*Tabela*/,RetTitle("D1_CF"     ),PesqPict  ("SD1","D1_CF"     ),TamSx3("D1_CF"     )[1],/*lPixel*/,{|| SD1TMP->D1_CF            })
TRCell():New(oSection,"F4_DUPLIC"   ,"SD1"/*Tabela*/,RetTitle("F4_DUPLIC" ),PesqPict  ("SD1","F4_DUPLIC" ),TamSx3("F4_DUPLIC" )[1],/*lPixel*/,{|| SD1TMP->F4_DUPLIC        })
TRCell():New(oSection,"F4_ESTOQUE"  ,"SD1"/*Tabela*/,RetTitle("F4_ESTOQUE"),PesqPict  ("SD1","F4_ESTOQUE"),TamSx3("F4_ESTOQUE")[1],/*lPixel*/,{|| SD1TMP->F4_ESTOQUE       })
TRCell():New(oSection,"D1_TOTAL"    ,"SD1"/*Tabela*/,RetTitle("D1_TOTAL"  ),PesqPict  ("SD1","D1_TOTAL"  ),TamSx3("D1_TOTAL"  )[1],/*lPixel*/,{|| SD1TMP->D1_TOTAL         })
TRCell():New(oSection,"D1_VALIMP6"  ,"SD1"/*Tabela*/,"Val. PIS"            ,PesqPict  ("SD1","D1_VALIMP6"),TamSx3("D1_VALIMP6")[1],/*lPixel*/,{|| SD1TMP->D1_VALIMP6       })
TRCell():New(oSection,"D1_VALIMP5"  ,"SD1"/*Tabela*/,"Val. COFINS"         ,PesqPict  ("SD1","D1_VALIMP5"),TamSx3("D1_VALIMP5")[1],/*lPixel*/,{|| SD1TMP->D1_VALIMP5       })
TRCell():New(oSection,"D1_VALICM"   ,"SD1"/*Tabela*/,RetTitle("D1_VALICM" ),PesqPict  ("SD1","D1_VALICM" ),TamSx3("D1_VALICM" )[1],/*lPixel*/,{|| SD1TMP->D1_VALICM        })
TRCell():New(oSection,"D1_VALIPI"   ,"SD1"/*Tabela*/,RetTitle("D1_VALIPI" ),PesqPict  ("SD1","D1_VALIPI" ),TamSx3("D1_VALIPI" )[1],/*lPixel*/,{|| SD1TMP->D1_VALIPI        })
TRCell():New(oSection,"D1_ICMSRET"  ,"SD1"/*Tabela*/,RetTitle("D1_ICMSRET"),PesqPict  ("SD1","D1_ICMSRET"),TamSx3("D1_ICMSRET")[1],/*lPixel*/,{|| SD1TMP->D1_ICMSRET       })
TRCell():New(oSection,"D1_DESPESA"  ,"SD1"/*Tabela*/,RetTitle("D1_DESPESA"),PesqPict  ("SD1","D1_DESPESA"),TamSx3("D1_DESPESA")[1],/*lPixel*/,{|| SD1TMP->D1_DESPESA       })
TRCell():New(oSection,"D1_SEGURO"   ,"SD1"/*Tabela*/,RetTitle("D1_SEGURO" ),PesqPict  ("SD1","D1_SEGURO" ),TamSx3("D1_SEGURO" )[1],/*lPixel*/,{|| SD1TMP->D1_SEGURO        })
TRCell():New(oSection,"D1_VALFRE"   ,"SD1"/*Tabela*/,RetTitle("D1_VALFRE" ),PesqPict  ("SD1","D1_VALFRE" ),TamSx3("D1_VALFRE" )[1],/*lPixel*/,{|| SD1TMP->D1_VALFRE        })
TRCell():New(oSection,"TOTAL"       ,""   /*Tabela*/,RetTitle("F1_VALBRUT"),PesqPict  ("SF1","F1_VALBRUT"),TamSx3("F1_VALBRUT")[1],/*lPixel*/,{|| SD1TMP->TOTAL            })
TRCell():New(oSection,"D1_CUSTO"    ,"SD1"/*Tabela*/,RetTitle("D1_CUSTO"  ),PesqPict  ("SD1","D1_CUSTO"  ),TamSx3("D1_CUSTO"  )[1],/*lPixel*/,{|| SD1TMP->D1_CUSTO         })

/*oSection:SetEdit(.T.)
oSection:SetUseQuery(.T.)
oSection:SetEditCell(.T.)
//oSection:DelUserCell(.F.)*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Troca descricao do total dos itens                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oReport:Section(1):SetTotalText("T O T A I S ")
//oReport:Section(2):SetEdit(.F.) 
//oReport:Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alinhamento a direita as colunas de valor                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection:Cell("D1_QUANT"  ):SetHeaderAlign("RIGHT")
oSection:Cell("D1_TOTAL"  ):SetHeaderAlign("RIGHT")
oSection:Cell("D1_VALIMP6"):SetHeaderAlign("RIGHT")
oSection:Cell("D1_VALIMP5"):SetHeaderAlign("RIGHT")
oSection:Cell("D1_VALICM" ):SetHeaderAlign("RIGHT")
oSection:Cell("D1_VALIPI" ):SetHeaderAlign("RIGHT")
oSection:Cell("D1_ICMSRET"):SetHeaderAlign("RIGHT")
oSection:Cell("D1_DESPESA"):SetHeaderAlign("RIGHT")
oSection:Cell("D1_SEGURO" ):SetHeaderAlign("RIGHT")
oSection:Cell("D1_VALFRE" ):SetHeaderAlign("RIGHT")
oSection:Cell("TOTAL"     ):SetHeaderAlign("RIGHT")
oSection:Cell("D1_CUSTO"  ):SetHeaderAlign("RIGHT")

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor ³Anderson C. P. Coelho º Data ³  13/06/16 º±±
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

Local _cFilSF1 := oSection:GetSqlExp("SF1")
Local _cFilSD1 := oSection:GetSqlExp("SD1")
Local _cFilSB1 := oSection:GetSqlExp("SB1")
Local _cFilSA1 := oSection:GetSqlExp("SA1")
Local _cFilSA2 := oSection:GetSqlExp("SA2")
Local _cFilSF4 := oSection:GetSqlExp("SF4")

If MV_PAR01 > MV_PAR02
	MsgStop("Parâmetros informados incorretamente!",_cRotina+"_002")
	Return
EndIf
If Empty(_cFilSF1)
	_cFilSF1 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSD1)
	_cFilSD1 := "%AND "+_cFilSD1+"%"
EndIf
If Empty(_cFilSD1)
	_cFilSD1 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSB1)
	_cFilSB1 := "%AND "+_cFilSB1+"%"
EndIf
If Empty(_cFilSB1)
	_cFilSB1 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSA1)
	_cFilSA1 := "%AND "+_cFilSA1+"%"
EndIf
If Empty(_cFilSA1)
	_cFilSA1 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSA2)
	_cFilSA2 := "%AND "+_cFilSA2+"%"
EndIf
If Empty(_cFilSA2)
	_cFilSA2 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSF4)
	_cFilSF4 := "%AND "+_cFilSF4+"%"
EndIf
If Empty(_cFilSF4)
	_cFilSF4 := "%AND 0 = 0%"
EndIf 
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Troca descricao do total dos itens                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):SetTotalText("T O T A I S ")
//PROCESSAMENTO DAS INFORMAÇÕES PARA IMPRESSÃO
//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
MakeSqlExpr(oReport:uParam)
//MakeSqlExpr(_cPerg)
oSection:BeginQuery()
	BeginSql Alias "SD1TMP"
		SELECT *
			 , (CASE WHEN D1_TIPO IN ('D','B')
							THEN (SELECT A1_NOME FROM %table:SA1% SA1 WHERE SA1.A1_FILIAL = %xFilial:SA1% AND SA1.A1_COD = SD1.D1_FORNECE AND SA1.A1_LOJA = SD1.D1_LOJA AND SA1.%NotDel%  %Exp:_cFilSA1%)
							ELSE (SELECT A2_NOME FROM %table:SA2% SA2 WHERE SA2.A2_FILIAL = %xFilial:SA2% AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA AND SA2.%NotDel%  %Exp:_cFilSA2%)
				END) NOME
			 , ROUND((F1_VALBRUT/F1_VALMERC*D1_TOTAL),2) TOTAL
		FROM %table:SD1% SD1
			INNER JOIN %table:SF1% SF1 ON SF1.F1_FILIAL = %xFilial:SF1% AND SF1.F1_DOC    = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.F1_TIPO = SD1.D1_TIPO AND SF1.%NotDel%  %Exp:_cFilSF1%
			INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD    = SD1.D1_COD AND SB1.%NotDel% %Exp:_cFilSB1%
			INNER JOIN %table:SF4% SF4 ON SF4.F4_FILIAL = %xFilial:SF4% AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.%NotDel% %Exp:_cFilSF4%
		WHERE SD1.D1_FILIAL  = %xFilial:SD1%
		  AND SD1.D1_DTDIGIT BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
		  AND ((%Exp:MV_PAR03% = 1 AND SD1.D1_TIPO NOT IN ('D','B')) OR (%Exp:MV_PAR03% = 2 AND 1=1))
		  AND SD1.%NotDel%
		   %Exp:_cFilSD1%
		ORDER BY D1_DTDIGIT, D1_FORNECE, D1_LOJA, D1_DOC, D1_SERIE, D1_TIPO 
	EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
oSection:EndQuery()
//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001",GetLastQuery()[02])

oSection:Print()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjPergCM  ºAutor  ³Anderson C. P. Coelho º Data ³  13/06/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se as perguntas existem na SX1. Caso não existam,  º±±
±±º          ³as cria.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjPergCM()

Local _aArea   := GetArea()
Local aRegs    := {}
Local _aTam    := {}
Local _aHlpPor := {}
Local _aHlpEng := {}
Local _aHlpSpa := {}

/* FB - RELEASE 12.1.23
_cPerg         := PADR(_cPerg,Len(SX1->X1_GRUPO))
*/
_cPerg         := PADR(_cPerg,10)

//PutSX1(< cGrupo>, < cOrdem>, < cPergunt>, < cPergSpa>, < cPergEng>, < cVar>, < cTipo>, < nTamanho>, [ nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ _aHlpPor], [ _aHlpEng], [ _aHlpSpa], [ cHelp] )
_aTam    := TamSx3("D1_DTDIGIT"    )
/* FB - RELEASE 12.1.23
_aHlpPor := _aHlpEng := _aHlpSpa := {}
Aadd( _aHlpPor, "Informe a data inicial de entrada       " )
PutSx1(_cPerg,"01","De Data               ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,""   ,""   ,"","mv_par01",""              ,"","","","",""            ,"","","","",""     ,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
PutSX1Help("P."+AllTrim(_cPerg)+"01.",_aHlpPor,_aHlpEng,_aHlpSpa)
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
_cHelp    := "Informe a data inicial de entrada." 
U_RGENA001(_cPerg, "01" ,"De Data               ?", "MV_PAR01", "mv_cha", _aTam[03],_aTam[01],_aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

/* FB - RELEASE 12.1.23
_aHlpPor := _aHlpEng := _aHlpSpa := {}
Aadd( _aHlpPor, "Informe a data final de entrada         " )
PutSx1(_cPerg,"02","Até Data              ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()",""   ,""   ,"","mv_par02",""              ,"","","","",""            ,"","","","",""     ,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
PutSX1Help("P."+AllTrim(_cPerg)+"02.",_aHlpPor,_aHlpEng,_aHlpSpa)
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
_cHelp    := "Informe a data final de entrada." 
U_RGENA001(_cPerg, "02" ,"Até Data              ?", "MV_PAR02", "mv_chb", _aTam[03],_aTam[01],_aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


_aTam    := {01,00,"N"}
/* FB - RELEASE 12.1.23
_aHlpPor := _aHlpEng := _aHlpSpa := {}
Aadd( _aHlpPor, "Considera Devolução/Beneficiamento      " ) 
Aadd( _aHlpPor, "(cliente)?                              " )
PutSx1(_cPerg,"03","Considera Dev./Benef. ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()",""   ,""   ,"","mv_par03","Não"           ,"","","","","Sim"         ,"","","","",""     ,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
PutSX1Help("P."+AllTrim(_cPerg)+"03.",_aHlpPor,_aHlpEng,_aHlpSpa)
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
_cHelp    := "Considera Devolução/Beneficiamento (cliente)?"
U_RGENA001(_cPerg, "03" ,"Considera Dev./Benef. ?", "MV_PAR03", "mv_chC", _aTam[03],_aTam[01],_aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


RestArea(_aArea)

Return