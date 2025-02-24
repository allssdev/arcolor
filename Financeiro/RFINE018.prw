#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma ณ RFINE018 บAutor  ณ Adriano L. de Souza บ Data ณ  23/04/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.   ณ Fun็ใo desenvolvida para calcular o prazo m้dio da condi็ใo de ฑฑ
ฑฑบDesc.   ณ pagamento.                                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso P11  ณ Uso especํfico Arcolor                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑอฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RFINE018(cCond,nValTot,nVIPI,dData,nVSol)

Local _aSavArea 	:= GetArea()
Local _aParcelas    := {}
Local _nPrzMed		:= 0
Local _dDataAux		:= dDataBase
Local _nSomPrz		:= 0

//Defino os valores default dos parโmetros para os casos em que s๓ serใo considerados os vencimentos, independente de valor
Default nValTot		:= 1000
Default nVIPI		:= 0
Default dData		:= dDataBase
Default nVSol		:= 0

If (nValTot <> Nil .And. cCond <> Nil .And. nVIPI <> Nil .And. nVSol <> Nil)
	
	_aParcelas := Condicao(nValTot,cCond,nVIPI,dData,nVSol) //Fun็ใo padrใo que retorna um array com os vencimentos de acordo com a condi็ใo de pagamento escolhida
	
	For _nCont := 1 To Len(_aParcelas)
		_nSomPrz  += _aParcelas[_nCont,1] - _dDataAux
	Next
	
	_nPrzMed := Round(_nSomPrz/(Len(_aParcelas)),0) //Arredondo o valor para inteiro
	
EndIf

RestArea(_aSavArea)

Return(_nPrzMed)