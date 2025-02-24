#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT120BRW บAutor  ณ J๚lio Soares       บ Data ณ  10/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada na inicializa็ใo do browse dos pedidos de บฑฑ
ฑฑบ          ณ compras.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT120BRW()

Local _aSavArea := GetArea()
Local _aRotUser	:= {}

If ExistBlock("RCOME010")
	//SetKey(VK_F6,{ || U_RCOME010()}) // - Tecla de atalho para alterar o fornecedor do pedido de compras.
	// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
	//SetKey( VK_F6,{|| MsgAlert( "Tecla [ F6 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
	SetKey( K_CTRL_F7, { || })
	SetKey( K_CTRL_F7, { || U_RCOME010()})
EndIf
//RestArea(_aSavArea)
//Inicio - Trecho adicionado por Adriano Leonardo em 19/05/2014
If ExistBlock("RTMKE022")
	AAdd(_aRotUser, { "Busca Avan็ada", "U_RTMKE022", 0, 1 })
	//Seta atalho para tecla F5 para chamar a tela de busca avan็ada
	//SetKey(VK_F5,{|| })
	//SetKey(VK_F5,{|| U_RTMKE022() })
    // Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
	//SetKey( VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
	SetKey( K_CTRL_F5, { || })
	SetKey( K_CTRL_F5, { || U_RTMKE022()})
EndIf
//Final  - Trecho adicionado por Adriano Leonardo em 19/05/2014

Return()
