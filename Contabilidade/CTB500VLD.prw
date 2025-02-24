#INCLUDE 'protheus.ch'
#INCLUDE 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CTB500VLD บAutor  ณJ๚lio Soares       บ Data ณ  29/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CTB500VLD()

Local aSavArea := GetArea()

If FunName() == 'RCTB001A'
	SetFunName:= 'CTBA500'
	MV_PAR03 := (StrTran(Substring(cArq,1,Len(cArq)-4) + '_a'+Substring(cArq,Len(cArq)-3,4) ,".csv",".txt"))
	MV_PAR06 := 241
ElseIf FunName() == 'RCTB001B'
	SetFunName:= 'CTBA500'
	MV_PAR03 := (StrTran(Substring(cArq,1,Len(cArq)-4) + '_c'+Substring(cArq,Len(cArq)-3,4) ,".csv",".txt"))
	MV_PAR06 := 241
ElseIf FunName() == 'RCTB001C'
	SetFunName:= 'CTBA500'
	MV_PAR03 := (StrTran(Substring(cArq,1,Len(cArq)-4) + '_d'+Substring(cArq,Len(cArq)-3,4) ,".csv",".txt"))
	MV_PAR06 := 241
	SetFunName:= 'RCTBI002'
EndIf

RestArea(aSavArea)

Return(.T.)