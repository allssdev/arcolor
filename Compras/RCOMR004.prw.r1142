#include "protheus.ch"
#include "parmtype.ch"

/*Relatório resumo de compras por data de entrega*/

User Function RCOMR004()

Private oReport, oSection
Private cTitulo  := OemToAnsi("Relatório Resumo de Compras por Data de Entrega")
Private _cRotina := "RCOMR004"
Private cPerg    := _cRotina

If FindFunction("TRepInUse") .And. TRepInUse()
//	ValidPerg()
	If !Pergunte(cPerg,.T.)
	   Return
	EndIf
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return


Static Function ReportDef()

Local _aOrd    := {"Pedido + Fonecedor"}		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)}," Relatório resumo de compras por data de entrega!")
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
//³        Default : X3Titulo()                                            ³
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

oSection := TRSection():New(oReport,"Informações",{"SC7"},_aOrd/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:SetTotalInLine(.F.)

TRCell():new(osection,"C7_NUM" ,"SC7TEMP",rettitle("C7_NUM" )   ,pesqpict ("SC7","C7_NUM"  ),tamsx3("C7_NUM")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_NUM     })  
TRCell():new(osection,"C7_EMISSAO" ,"SC7TEMP",rettitle("C7_EMISSAO" )   ,pesqpict ("SC7","C7_EMISSAO"  ),tamsx3("C7_EMISSAO")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_EMISSAO     })  
TRCell():new(osection,"C7_DATPRF" ,"SC7TEMP",rettitle("C7_DATPRF" )   ,pesqpict ("SC7","C7_DATPRF"  ),tamsx3("C7_DATPRF")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_DATPRF    })  
TRCell():new(osection,"C7_ANTEPRO" ,"SC7TEMP",rettitle("C7_ANTEPRO" )   ,pesqpict ("SC7","C7_ANTEPRO"  ),tamsx3("C7_ANTEPRO")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_ANTEPRO   })  
TRCell():new(osection,"C7_FORNECE" ,"SC7TEMP",rettitle("C7_FORNECE" )   ,pesqpict ("SC7","C7_FORNECE"  ),tamsx3("C7_FORNECE")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_FORNECE     })  
TRCell():new(osection,"C7_LOJA" ,"SC7TEMP",rettitle("C7_LOJA" )   ,pesqpict ("SC7","C7_LOJA"  ),tamsx3("C7_LOJA")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_LOJA     })  
TRCell():new(osection,"A2_NOME" ,"SC7TEMP",rettitle("A2_NOME" )   ,pesqpict ("SC7","A2_NOME"  ),tamsx3("A2_NOME")[1]  ,/*lpixel*/,{|| SC7TEMP->A2_NOME     })  
TRCell():new(osection,"C7_COND" ,"SC7TEMP",rettitle("C7_COND" )   ,pesqpict ("SC7","C7_COND"  ),tamsx3("C7_COND")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_COND     })  
TRCell():new(osection,"C7_VALICM" ,"SC7TEMP",rettitle("C7_VALICM" )   ,pesqpict ("SC7","C7_VALICM"  ),tamsx3("C7_VALICM")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_VALICM     })  
TRCell():new(osection,"C7_VALIPI" ,"SC7TEMP",rettitle("C7_VALIPI" )   ,pesqpict ("SC7","C7_VALIPI"  ),tamsx3("C7_VALIPI")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_VALIPI     })  
TRCell():new(osection,"C7_TOTAL" ,"SC7TEMP",rettitle("C7_TOTAL" )   ,pesqpict ("SC7","C7_TOTAL"  ),tamsx3("C7_TOTAL")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_TOTAL     })  
TRCell():new(osection,"C7_VALIPI" ,"SC7TEMP",rettitle("C7_VALIPI" )   ,pesqpict ("SC7","C7_VALIPI"  ),tamsx3("C7_VALIPI")[1]  ,/*lpixel*/,{|| SC7TEMP->TTLCIMP})  
TRCell():new(osection,"C7_MOEDA" ,"SC7TEMP",rettitle("C7_MOEDA" )   ,pesqpict ("SC7","C7_MOEDA"  ),tamsx3("C7_MOEDA")[1]  ,/*lpixel*/,{|| SC7TEMP->C7_MOEDA})  


Return(oReport)

/*Processamento das informações para impressão (Print)*/

Static Function PrintReport(oReport)

Local _x
Local _cOrder  := ""
Local _cField  := ""
//Local _cFilSC7 := oSection:GetSqlExp("SC7")


If oReport:Section(1):GetOrder() == 1			//Ordem por Nome
	_cOrder := "C7_NUM, C7_FORNECE"

EndIf

_cField  := "%" + _cField  + "%"
_cOrder  := "%" + _cOrder  + "%"

For _x := 1 To Len(oSection:aUserFilter)
	oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
Next
oSection:CSQLEXP := ""


MakeSqlExpr(oReport:uParam)
//MakeSqlExpr(cPerg)

oSection:BeginQuery()
BeginSql Alias "SC7TEMP"
   SELECT  
      SC7.C7_NUM    
   , SC7.C7_EMISSAO    
   , SC7.C7_DATPRF  
   , SC7.C7_ANTEPRO  
   , SC7.C7_FORNECE  
   , SC7.C7_LOJA  
   , SA2.A2_NOME  
   , SC7.C7_COND  
   , SUM(SC7.C7_VALICM)   C7_VALICM
   , SUM(SC7.C7_VALIPI)   C7_VALIPI
   , SUM(SC7.C7_TOTAL)   C7_TOTAL
   , ROUND(CASE WHEN C7_MOEDA = "1" THEN (SUM(SC7.C7_VALIPI) + SUM(SC7.C7_TOTAL)) ELSE (SUM(SC7.C7_VALIPI) + SUM(SC7.C7_TOTAL)) * (SELECT M2_MOEDA2 FROM SM2010 SM2 WHERE SM2.D_E_L_E_T_ = "" AND M2_DATA = C7_EMISSAO) END,2)   TTLCIMP 
   , C7_MOEDA  C7_MOEDA 
         FROM %table:SC7% SC7 
            INNER JOIN %table:SB1%  SB1 ON      SB1.B1_COD    = SC7.C7_PRODUTO   
                            					   AND SB1.D_E_L_E_T_ = ""   
            INNER JOIN %table:SA2%  SA2 (NOLOCK) ON      SA2.A2_COD    = SC7.C7_FORNECE   
                              					   AND SA2.A2_LOJA   = SC7.C7_LOJA   
                             					    AND SA2.D_E_L_E_T_ = ""   
            WHERE    
                SC7.C7_FORNECE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%  
               AND ((SC7.C7_DATPRF BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% OR
               		 SC7.C7_ANTEPRO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% ) OR
               		(SC7.C7_DATPRF BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%  AND SC7.C7_ANTEPRO=""))   
               AND SC7.C7_PRODUTO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%   
               AND SB1.B1_TIPO BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%  
               AND SC7.%NotDel% 
         GROUP BY SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_DATPRF, SC7.C7_ANTEPRO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NOME, SC7.C7_COND, SC7.C7_MOEDA   
         ORDER BY C7_NUM, C7_FORNECE   

	EndSql

oSection:EndQuery()

MemoWrite("\"+_cRotina+"_QRY_001",oSection:CQUERY)

oSection:Print()

Return
