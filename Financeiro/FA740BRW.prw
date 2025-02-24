#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA740BRW  บAutor  ณJ๚lio Soares        บ Data ณ  04/23/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada utilizado para inserir botใo no a็๕es     บฑฑ
ฑฑบ          ณ relacionadas do Fun็๕es Contas a receber no financeiro a   บฑฑ
ฑฑบ          ณ fim de incluir as chamadas para a rotina customizada de    บฑฑ
ฑฑบ          ณ altera็ใo das observa็๕es do tํtulo e a rotina padrใo para บฑฑ
ฑฑบ          ณ a tela de manuten็ใo de comiss๕es.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa ARCOLOR.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function FA740BRW()

Local _aSavArea := GetArea()
Local aBotao 	:= {}
Local _cRotina	:= "FA740BRW"

If ExistBlock("RFINA003")
	AADD(aBotao, {'Altera Obs. Titulo.'	,"U_RFINA003" ,0,3})
EndIf
If ExistBlock("RFINE010")	
	AADD(aBotao, {'Comiss๕es'     		,"U_RFINE010" ,0,3})
EndIf
//Inํcio - Trecho adicionado por Adriano Leonardo em 27/03/2014 para adi็ใo de botใo de busca avan็ada
If ExistBlock("RTMKE022")		//ExistBlock("RFINE017")
	//Defino tecla de atalho para chamada da rotina
	//SetKey(K_CTRL_F5,{|| })
	//SetKey(K_CTRL_F5,{|| U_RTMKE022() })
    // Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
	//SetKey( VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
	SetKey( K_CTRL_F5, { || })
	SetKey( K_CTRL_F5, { || U_RTMKE022()})
	aAdd(aBotao, {"Busca Avan็ada"		,"U_RTMKE022" ,0,1}) //Chamada da tela de busca avan็ada (customizada)
Else
	MsgAlert("A rotina RTMKE022 nใo estแ compilada, favor informar ao Administrador do sistema",_cRotina+"_001")
EndIf
//Final  - Trecho adicionado por Adriano Leonardo em 27/03/2014

RestArea(_aSavArea)

Return(aBotao)