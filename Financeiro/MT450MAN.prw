#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma ณ MT450MAN บAutor  ณ Adriano L. de Souza บ Data ณ  16/07/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบ Desc.  ณ Ponto de entrada para validar a libera็ใo de cr้dito manual doบฑฑ
ฑฑบ        ณ pedido de venda, utilizado para avaliar o vํnculo do pedido   บฑฑ
ฑฑบ        ณ com possํveis tํtulos RAs/NCCs.                               บฑฑ
ฑฑบ        ณ Rotina validada em 19/08/2014                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Protheus11 - Especํfico para a empresa Arcolor.               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑอฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT450MAN()

Local _cRotina 	:= "MT450MAN"
Local _aSavArea	:= GetArea()
Local _lRet		:= .T.

//If __cUserId=="000000"
	//Chamada da rotina de vํnculo de adiantamento com pedido de venda
	If ExistBlock("RFINE021")
		_lRet := U_RFINE021()
		//Verifica็ใo de seguran็a para garantir retorno l๓gico para o ponto de entrada
		If _lRet == Nil
			_lRet := .T.
		EndIf
	EndIf
//EndIf

RestArea(_aSavArea)

Return(_lRet)