#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณMC050BUT  บAutor  ณAnderson C. P. Coelho บ Data ณ  21/05/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada para adi็ใo de bot๕es na Consulta do      บฑฑ
ฑฑบ          ณKardex acessada na consulta do produto.                     บฑฑ
ฑฑบ          ณ LOCALIZAวรO : Function MC050Con- Fun็ใo que monta a tela daบฑฑ
ฑฑบ          ณconsulta de Produtos. O objetivo deste ponto de entrada ้   บฑฑ
ฑฑบ          ณpermitir a inclusใo de bot๕es de usuแrio na barra de        บฑฑ
ฑฑบ          ณferramentas da consulta de produtos.                        บฑฑ
ฑฑบ          ณ EM QUE PONTO: No inicio da Fun็ใo, antes de montar a       บฑฑ
ฑฑบ          ณToolBar da consulta; Deve ser usado para adicionar bot๕es doบฑฑ
ฑฑบ          ณusuario na toolbar da consulta de produtos, atrav้s do      บฑฑ
ฑฑบ          ณretorno de um Array com a estrutura do botใo a adicionar.   บฑฑ
ฑฑบ          ณ Rotinas Envolvidas:                                        บฑฑ
ฑฑบ          ณ * MC030ARR;                                                บฑฑ
ฑฑบ          ณ * RMATC030;                                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MC050BUT()

Local aButtons

If ExistBlock("Mc030Con")
	aButtons := {{'GRAF3D', {|| U_Mc030Con("PE")}, OemtoAnsi("Kardex/Dia Quant."),"Kardex/Dia Quant."}}
EndIf

Return(aButtons)
