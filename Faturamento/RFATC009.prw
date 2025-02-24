#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATC009  บAutor  ณAdriano Leonardo    บ Data ณ  29/03/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de cadastro de cadastro de s๓cios (SZB).              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso P11   ณ Uso especํfico Arcolor                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RFATC009()
	
	Local cVldAlt  	:= ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock
	Local cVldExc  	:= ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock
	Local aRotAdic 	:= {}
	Private cString := "SZB"
	
	dbSelectArea(cString)
	dbSetOrder(1)
	
	aAdd(aRotAdic,{ "Busca Avan็ada","U_RTMKE022", 0 , 1 }) //Chamada da tela de busca avan็ada (customizada)
	
	//Adiciono tecla de atalho para chamada da rotina de busca avan็ada
	SetKey(VK_F5,{|| })
	SetKey(VK_F5,{|| U_RTMKE022() })
	
	AxCadastro(cString, "Cadastro de S๓cios", cVldExc, cVldAlt, aRotAdic, , , , , , , , , )
	
Return()