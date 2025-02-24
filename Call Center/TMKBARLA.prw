#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออษฑฑ
ฑฑบPrograma  ณTMKBARLA	บAutor  ณAdriano Leonardo      บ Data ณ  02/01/13 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDescri็ใo ณ Ponto de entrada para colocar bot๕es na tela de atendimentoบฑฑ
ฑฑบ			 ณ do CALL CENTER. Inclusใo de botใo para valida็ใo do atendi-บฑฑ
ฑฑบ			 ณ mento.        	  										  บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออษฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออษฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function TMKBARLA()
	//Salvo a แrea ativa no momento
	Local _aSavAr  := GetArea()
	Local _aBotoes := {}
	//Adiciona botใo na barra lateral do atendimento
	If ExistBlock("RFATE002")
		aAdd(_aBotoes,{"POSCLI"     , {|| U_RFATE002(.T.,"")} ,"Valida็ใo"   })
	EndIf
	If ExistBlock("RTMKR008")
		aAdd(_aBotoes,{"EMAIL", {|| U_RTMKR008(.T.,"")} ,"Envio de E-mail"})
	EndIf
	If ExistBlock("RFINE011")
		SetKey( K_CTRL_F11, { || })
		SetKey( K_CTRL_F11, { || U_RFINE011("F11")})
		aAdd(_aBotoes,{"BUDGETY"    , {|| U_RFINE011("F11")} ,"Ficha Financeira"  })
	EndIf
	//Restauro as แreas originais
	RestArea(_aSavAr)
return(_aBotoes)