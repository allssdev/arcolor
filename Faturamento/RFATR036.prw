#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATR036  º Autor ³Anderson C. P. Coelho º Data ³  20/10/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de pedidos pendentes                             º±±
±±º          ³ Baseado no RFATR012.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RFATR036()

Local  oReport

Private oSection
Private _cRotina  := "RFATR036"
Private cPerg     := _cRotina
Private cTitulo   := "Relatório de Pedidos"
Private _aTpOper  := {}
Private _cVend    := ""

If FindFunction("TRepInUse") .AND. TRepInUse()
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	If MV_PAR01 == 1		//PENDENTES
		cTitulo := AllTrim(cTitulo) + " - PENDENTES"
	ElseIf MV_PAR01 == 2	//SALDO
		cTitulo := AllTrim(cTitulo) + " - SALDOS"
	ElseIf MV_PAR01 == 3	//AMBOS
		cTitulo := AllTrim(cTitulo) + " - AMBOS"
	ElseIf MV_PAR01 == 4	//FATURADO
		cTitulo := AllTrim(cTitulo) + " - FATURADOS"
	ElseIf MV_PAR01 == 5	//CANCELADOS
		cTitulo := AllTrim(cTitulo) + " - CANCELADOS"
	EndIf
	If Len(_aTpOper := aClone(U_SELMARQ())) > 0
		oReport := ReportDef()
		oReport:PrintDialog()
		_bPERG := "Pergunte(cPerg,.T.)"
		_lSELMARQ := ExistBlock("SELMARQ")
		While MSGBOX("Deseja emitir o relatório novamente?",_cRotina+"_001","YESNO")
			If !&(_bPERG)
				Return
			EndIf
			If _lSELMARQ .AND. Len(_aTpOper := aClone(U_SELMARQ())) > 0
				oReport := ReportDef()
				oReport:PrintDialog()
			EndIf
		EndDo
	EndIf
ElseIf ExistBlock("RFATR012")
	ExecBlock("RFATR012")
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Anderson C. P. Coelho  ³ Data ³ 20/10/15 ³±±
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
Local oSection
Local oBreak
Local _aOrd       := {""}		//{"Grupo + Produto", "Grupo + Descrição de Produto"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Emissao do relatório, de acordo com o intervalo informado na opção de Parâmetros.")
oReport:SetLandscape() 
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
//³ Secao dos pedidos                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection := TRSection():New(oReport,"Pedidos",{"SC5","SC6","SA1","SA3"},_aOrd/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:SetTotalInLine(.F.)
//Definição das colunas do relatório

// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
//TRCell():New(oSection,"VENDEDOR"   ,"SC6TMP",RetTitle("C5_VEND1"  ),PesqPict("SC5","C5_VEND1"  ),TamSx3("C5_VEND1"  )[1],/*lPixel*/,{|| SC6TMP->VENDEDOR      })
TRCell():New(oSection,"REPRESENTANTE"   ,"SC6TMP","REPRESENTANTE",PesqPict("SC5","C5_VEND1"  ),TamSx3("C5_VEND1"  )[1],/*lPixel*/,{|| SC6TMP->REPRESENTANTE      })
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

TRCell():New(oSection,"NOME_VEND"  ,"SC6TMP",RetTitle("A3_NOME"   ),PesqPict("SA3","A3_NOME"   ),TamSx3("A3_NOME"   )[1],/*lPixel*/,{|| SC6TMP->NOME_VEND     })
TRCell():New(oSection,"EMISSAO"    ,"SC6TMP",RetTitle("C5_EMISSAO"),PesqPict("SC5","C5_EMISSAO"),TamSx3("C5_EMISSAO")[1],/*lPixel*/,{|| STOD(SC6TMP->EMISSAO) })
TRCell():New(oSection,"PEDIDO"     ,"SC6TMP",RetTitle("C5_NUM"    ),PesqPict("SC5","C5_NUM"    ),TamSx3("C5_NUM"    )[1],/*lPixel*/,{|| SC6TMP->PEDIDO        })
TRCell():New(oSection,"CLIENTE"    ,"SC6TMP",RetTitle("C5_CLIENTE"),PesqPict("SC5","C5_CLIENTE"),TamSx3("C5_CLIENTE")[1],/*lPixel*/,{|| SC6TMP->CLIENTE       })
TRCell():New(oSection,"LOJA"       ,"SC6TMP",RetTitle("C5_LOJACLI"),PesqPict("SC5","C5_LOJACLI"),TamSx3("C5_LOJACLI")[1],/*lPixel*/,{|| SC6TMP->LOJA          })
TRCell():New(oSection,"NOME"       ,"SC6TMP",RetTitle("A1_NOME"   ),PesqPict("SA1","A1_NOME"   ),TamSx3("A1_NOME"   )[1],/*lPixel*/,{|| SC6TMP->NOME          })
TRCell():New(oSection,"VALOR"      ,"SC6TMP",RetTitle("C6_VALOR"  ),PesqPict("SC6","C6_VALOR"  ),TamSx3("C6_VALOR"  )[1],/*lPixel*/,{|| SC6TMP->VALOR         })

// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
//oSection:Cell("VENDEDOR"):SetHeaderAlign("CENTER")
oSection:Cell("REPRESENTANTE"):SetHeaderAlign("CENTER")
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

oSection:Cell("EMISSAO" ):SetHeaderAlign("CENTER")
oSection:Cell("PEDIDO"  ):SetHeaderAlign("CENTER")
oSection:Cell("CLIENTE" ):SetHeaderAlign("CENTER")
oSection:Cell("LOJA"    ):SetHeaderAlign("CENTER")
oSection:Cell("NOME"    ):SetHeaderAlign("LEFT"  )
oSection:Cell("VALOR"   ):SetHeaderAlign("RIGHT" )

// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
//oBreak := TRBreak():New(oSection, oSection:Cell("VENDEDOR" ), {|| "Sub-Total Vendedor " /*+ SC6TMP->VENDEDOR + " - " + SC6TMP->NOME_VEND*/})
oBreak := TRBreak():New(oSection, oSection:Cell("REPRESENTANTE" ), {|| "Sub-Total Representante " /*+ SC6TMP->REPRESENTANTE + " - " + SC6TMP->NOME_VEND*/})
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

TRFunction():New(oSection:Cell("VALOR"    ),NIL,"SUM",oBreak)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Troca descricao do total dos itens                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oReport:Section(1):SetTotalText("T O T A I S ")

//Efetuo o relacionamento entre as tabelas
//TRPosition():New(oSection,"SF2",1,{|| xFilial("SF2") + SD2->D2_DOC+SD2->D2_SERIE})
//TRPosition():New(oSection,"SA3",1,{|| xFilial("SA3") + SF2->F2_VEND1            })

//oReport:Section(2):SetEdit(.F.)
//oReport:Section(1):SetUseQuery(.T.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor ³Anderson C. P. Coelho º Data ³  06/02/15 º±±
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

Local oSection := oReport:Section(1)
Local _cTpOper := ""
Local _cTotal  := ""
Local _cPend   := ""
Local _cCpoSum := ""
Local _cFlOper := ""
Local _cFilSA1 := oSection:GetSqlExp("SA1")
Local _cFilSA3 := oSection:GetSqlExp("SA3")
Local _cFilSC5 := oSection:GetSqlExp("SC5")
Local _cFilSC6 := oSection:GetSqlExp("SC6")

If MV_PAR02 > MV_PAR03 .OR. MV_PAR04 > MV_PAR05
	MsgStop("Parâmetros informados incorretamente!",_cRotina+"_002")
	Return
EndIf
If MV_PAR01 == 4		//FATURADO
	_cTotal := "%, (SC6.C6_QTDENT * SC6.C6_PRCVEN) TOTAL%" 
Else
	_cTotal := "%, ((SC6.C6_QTDVEN - SC6.C6_QTDENT) * SC6.C6_PRCVEN) TOTAL%" 
EndIf
If MV_PAR01 == 1		//PENDENTES
	_cPend := " 		  	  SC6.C6_QTDENT < SC6.C6_QTDVEN  "
	_cPend += " 		  AND (	SELECT SUM(SC6A.C6_QTDENT)  "
	_cPend += " 	            FROM " + RetSqlName("SC6") + " SC6A " 
	_cPend += " 			       WHERE SC6A.C6_FILIAL  = '" + xFilial("SC6") + "' " 
	_cPend += " 			         AND SC6A.C6_NUM     = SC5.C5_NUM " 
	_cPend += " 			         AND SC6A.D_E_L_E_T_ = ''  "
	_cPend += " 			       ) = 0  "
	_cPend += " 		  AND SC6.C6_BLQ <> 'R' "	
	_cPend += " 		  AND SUBSTRING(C5_NOTA,1,1) <> 'X' "
ElseIf MV_PAR01 == 2	//SALDO
	_cPend := " 		      SC6.C6_QTDENT < SC6.C6_QTDVEN "
	_cPend += " 		  AND (SELECT SUM(SC6A.C6_QTDENT) "
	_cPend += " 		       FROM " + RetSqlName("SC6") + " SC6A "
	_cPend += " 		       WHERE SC6A.C6_FILIAL  = '" + xFilial("SC6") + "' "
	_cPend += " 		         AND SC6A.C6_NUM     = SC5.C5_NUM "
	_cPend += " 		         AND SC6A.D_E_L_E_T_ = '' "
	_cPend += " 		       ) > 0 "
	_cPend += " 		  AND SC6.C6_BLQ <> 'R' "
	_cPend += " 		  AND SUBSTRING(C5_NOTA,1,1) <> 'X' "
ElseIf MV_PAR01 == 3 /*.OR. MV_PAR01 == 5*/	//AMBOS
	_cPend := " 		      SC6.C6_QTDENT < SC6.C6_QTDVEN " 
	_cPend += " 		  AND SC6.C6_BLQ <> 'R' "
	_cPend += " 		  AND SUBSTRING(C5_NOTA,1,1) <> 'X' "
ElseIf MV_PAR01 == 4	//FATURADO
	_cPend := " 		      SC6.C6_QTDENT > 0  "
ElseIf MV_PAR01 == 5 	// RESÍDUOS
	_cPend := " 			 (SC6.C6_BLQ = 'R' OR SUBSTRING(C5_NOTA,1,1)  = 'X') " 
EndIf
If MV_PAR01 <> 4		//FATURADO                                        
	If !Empty(_cPend)
		_cPend += " 		  AND "
	EndIf
	_cPend += " 			 (SC6.C6_BLQ<> 'R' OR SUBSTRING(C5_NOTA,1,1) <> 'X') " 
EndIf
_cTpOper := "%('"
For _x := 1 To Len(_aTpOper)
	If _x > 1
		_cTpOper += "','"
	EndIf
	_cTpOper += _aTpOper[_x]
Next
_cTpOper += "')%"
If !Empty(_cFilSC5)
	_cFilSC5 := "%AND "+_cFilSC5+_cPend+"%"
ElseIf !Empty(_cPend)
	_cFilSC5 := "%AND "+_cPend+"%"
Else
	_cFilSC5 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSC6)
	_cFilSC6 := "%AND "+_cFilSC6+"%"
Else
	_cFilSC6 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSA1)
	_cFilSA1 := "%AND "+_cFilSA1+"%"
Else
	_cFilSA1 := "%AND 0 = 0%"
EndIf
If !Empty(_cFilSA3)
	_cFilSA3 := "%AND "+_cFilSA3+"%"
Else
	_cFilSA3 := "%AND 0 = 0%"
EndIf
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
//MakeSqlExpr(cPerg)
oSection:BeginQuery()
	BeginSql Alias "SC6TMP"
		SELECT 	  C5_FILIAL  FILIAL
			    , C5_VEND1   REPRESENTANTE
				, A3_NOME    NOME_VEND
				, C5_EMISSAO EMISSAO
			    , C5_NUM     PEDIDO
			    , C5_CLIENTE CLIENTE
			    , C5_LOJACLI LOJA
			    , NOME       NOME
			    , SUM(TOTAL) VALOR
		FROM ( 
				SELECT C5_FILIAL, C5_EMISSAO, C5_NUM, C5_VEND1, ISNULL(A3_NOME,'') A3_NOME
					 , C5_CLIENTE, C5_LOJACLI, 
						(CASE  
							WHEN C5_TIPO IN ('D','B')  
								THEN (	SELECT A2_NOME  
										FROM %table:SA2% SA2 
										WHERE SA2.A2_FILIAL  = %xFilial:SA2%
										  AND SA2.A2_COD     = SC5.C5_CLIENTE 
										  AND SA2.A2_LOJA    = SC5.C5_LOJACLI 
										  AND SA2.%NotDel% )
								ELSE (	SELECT A1_NOME 
										FROM %table:SA1% SA1 
										WHERE SA1.A1_FILIAL  = %xFilial:SA1%
										  AND SA1.A1_COD     = SC5.C5_CLIENTE 
										  AND SA1.A1_LOJA    = SC5.C5_LOJACLI
										  AND SA1.%NotDel%
										  %Exp:_cFilSA1% )
						END) NOME
						%Exp:_cTotal% 
				FROM %table:SC5% SC5 
					INNER JOIN      %table:SC6% SC6  ON SC6.C6_FILIAL   = %xFilial:SC6%
													AND SC5.C5_NUM      = SC6.C6_NUM
				 									AND SC6.%NotDel%
				 						 			%Exp:_cFilSC6%
		 			LEFT OUTER JOIN %table:SA3% SA3  ON SA3.A3_FILIAL   = %xFilial:SA3%
		 											AND SA3.A3_COD      = SC5.C5_VEND1
		 											AND SA3.%NotDel%
		 											%Exp:_cFilSA3%
		 		WHERE SC5.C5_FILIAL        = %xFilial:SC5% 
				  AND SC5.C5_EMISSAO BETWEEN %Exp:DTOS(MV_PAR02)% AND %Exp:DTOS(MV_PAR03)% 
				  AND (SC5.C5_TIPO = 'N' OR SC5.C5_TIPO = 'P') 
				  AND SC5.C5_VEND1   BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05% 
				  AND SC5.C5_TPOPER       IN %Exp:_cTpOper%
				  AND SC5.%NotDel%
				  %Exp:_cFilSC5%
			) PV 
		GROUP BY C5_FILIAL, C5_EMISSAO, C5_VEND1, A3_NOME, C5_NUM, C5_CLIENTE, C5_LOJACLI, NOME 
		ORDER BY C5_FILIAL, C5_VEND1, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C5_NUM 
	EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
oSection:EndQuery()

//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001",oSection:CQUERY)

oSection:Print()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VALIDPERG ºAutor  ³Anderson C. P. Coelho º Data ³  20/10/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se as perguntas estão criadas no arquivo SX1 e caso º±±
±±º          ³ não as encontre ele as cria.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Status?"      ,"","","mv_ch1","N",01,0,0,"C","","mv_par01","Pendentes","","","","","Saldo","","","","","Ambos","","","","","Faturados","","","","","Cancelados","","","",""   ,""})
AADD(aRegs,{cPerg,"02","De  Emisssão?","","","mv_ch2","D",08,0,0,"G","","mv_par02",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})
AADD(aRegs,{cPerg,"03","Até Emisssão?","","","mv_ch3","D",08,0,0,"G","","mv_par03",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","",""   ,""})

// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
//AADD(aRegs,{cPerg,"04","De Vendedor?" ,"","","mv_ch4","C",06,0,0,"G","","mv_par04",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
//AADD(aRegs,{cPerg,"05","Até Vendedor?","","","mv_ch5","C",06,0,0,"G","","mv_par05",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})

AADD(aRegs,{cPerg,"04","De Representante?" ,"","","mv_ch4","C",06,0,0,"G","","mv_par04",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
AADD(aRegs,{cPerg,"05","Até Representante?","","","mv_ch5","C",06,0,0,"G","","mv_par05",""         ,"","","","",""     ,"","","","",""     ,"","","","",""         ,"","","","",""          ,"","","","SA3",""})
// Fim - Fernando Bombardi - ALLSS - 03/03/2022

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(MsSeek(cPerg+aRegs[i,2],.T.,.F.))
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

RestArea(_sAlias)

Return
