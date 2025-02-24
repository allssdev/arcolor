#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณ F060POR2  บAutor  ณ Arthur Silva		  บ Data ณ  30/11/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออฑฑ
ฑฑบDesc.TOTVSณ O ponto de entrada F060POR2 valida o portador na 		   บฑฑ
ฑฑบ          ณ transfer๊ncia de situa็ใo cobran็a quando a situa็ใo atual  บฑฑ
ฑฑบ          ณ 	do tํtulo utiliza portador (diferente de 0= Carteira, 	   บฑฑ
ฑฑบ          ณ 	F= Carteira Protesto, G= Carteira Acordo, 				   บฑฑ
ฑฑบ          ณ 	H=Cobran็a cart๓rio) para uma situa็ใo em que nใo 		   บฑฑ
ฑฑบ          ณ 	้ utilizado portador.									   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออฑฑ
ฑฑบDesc.     ณ Esse ponto de entrada ้ chamado apenas na op็ใo TRANSFERIR  บฑฑ
ฑฑบ          ณ da rotina FINA060, nใo se aplica a gera็ใo de border๔.	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 -  Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User function F060POR2()

Local _aSavArea	:= GetArea()
Local _cRotina	:= "F060POR2"


// Este ponto de Entrada esta sendo utilizado somente para manter o "NOSSO NฺMERO(E1_NUMBCO)" ao tranferir os tํtulos entre carteiras.
// Ap๓s esse P.E ser somente compilado, ao realizar qualquer transfer๊ncia entre carteiras o "NOSSO NฺMERO(E1_NUMBCO)" foi mantido no devido campo.

RestArea(_aSavArea)
Return