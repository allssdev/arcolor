#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFT100MRN  บAutor  ณAnderson C. P. Coelho บ Data ณ  27/12/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada para a inclusใo de bot๕es na tela de regraบฑฑ
ฑฑบ          ณneg๓cios.                                                   บฑฑ
ฑฑบ          ณ Neste caso, este Ponto de Entrada foi escolhido por ser    บฑฑ
ฑฑบ          ณchamado logo ap๓s a montagem dos GetDados da rotina e, com  บฑฑ
ฑฑบ          ณisso, ้ utilizada para manipular o objeto oGetD3:BLINHAOK,  บฑฑ
ฑฑบ          ณque cont้m a valida็ใo das linhas da terceira aba das regrasบฑฑ
ฑฑบ          ณde neg๓cios, para substitui็ใo da rotina padrใo Ft100LOk3   บฑฑ
ฑฑบ          ณpela rotina RFATE010.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FT100MRN()

Local _aSavArea := GetArea()

If Type("oGetD3:BLINHAOK")=="B"
	oGetD3:BLINHAOK := {|x| IIF(ExistBlock("RFATE010"),ExecBlock("RFATE010"),Ft100LOk3())}
EndIf

RestArea(_aSavArea)

Return NIL