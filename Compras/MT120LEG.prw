#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT120LEG บAutor  ณAdriano Leonardo    บ Data ณ 21/03/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. ณ Ponto de entrada utilizado para manipula็ใo das legendas do    บฑฑ
ฑฑบ      ณ browse de pedido de compra (cores x descri็ใo).                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function MT120LEG()

Local _aSavArea	:= GetArea()
Local aCores	:= aClone(PARAMIXB[1]) //Array contendo as legendas padr๕es dos pedidos de compra

//Verifico a exist๊ncia do campo utilizado como flag para as legendas customizadas
If FieldPos("C7_DEPART")<>0
	_nCont := 0
	For _nPos := 1 To Len(aCores)
		//Altero a descri็ใo das legendas de cor verde (pendente) e azul (bloqueado)
		If AllTrim(aCores[_nPos,1]) == "ENABLE" .Or. AllTrim(aCores[_nPos,1]) == "BR_AZUL"
			aCores[_nPos][2] += " (Departamento Compras)"
			_nCont++
		EndIf
		//Otimiza o processamento, para que o la็o de repeti็ใo seja encerrado assim que as condi็๕es esperadas sejam atendidas
		If _nCont==2
			Exit
		EndIf
	Next
EndIf

//Adiciono novas legendas
aAdd(aCores, {'BR_MARRON','Pedido Pendente (Outros Departamentos)'  })
aAdd(aCores, {'BR_PINK'  ,'Pedido Bloqueado (Outros Departamentos)' })
If FunName() == "MATA121"
	aAdd(aCores, {'BR_AZUL_CLARO'  ,'Contrato Parceria' })
EndIf	

RestArea(_aSavArea)

Return(aCores)