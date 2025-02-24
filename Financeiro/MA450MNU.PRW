#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MA450MNU  บAutor  ณJ๚lio Soares        บ Data ณ  17/10/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada utilizado para apresentar a op็ใo de teclaบฑฑ
ฑฑบ          ณ de atalho "F10/F11" para execu็๕es de rotinas              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ F7       ณ Abre tela customizada para altera็ใo de informa็๕es especํ-บฑฑ
ฑฑบ          ณ ficas na anแlise de cr้dito do pedido.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ F8       ณ Abre o cadastro do cliente posicionado para altera็ใo.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ F9       ณ Abre a consulta da posi็ใo de pedidos do cliente           บฑฑ
ฑฑบ          ณ posicionado.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ F10      ณ Abre a consulta da posi็ใo de faturamento do cliente       บฑฑ
ฑฑบ          ณ posicionado.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ F11      ณ Abre a ficha financeira conforme cliente posicionado       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para empresa Arcolor               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// - Analise de Cr้dito do pedido.
// ATENวรO: ESTE P.E. TAMBษM ษ CHAMADO NO P.E. MA410MNU. PORTANTO, EM CASO DE MUDANวAS, AVALIAR.
User Function MA450MNU()

//Local _oBrwBkp := IIF(Type("oBrowse")<>"U",oBrowse,NIL)

If !Empty(FunName())
	ProcPE()
EndIf
//oBrowse := _oBrwBkp
If Type("oBrowse") == "O"
	oBrowse:Refresh()
EndIf

Return

Static Function ProcPE()

Local _oObj     := GetObjBrow()
Local _aSavArea := GetArea()
Local _aSavSA1  := {}
Local _aSavSA2  := {}
Local _aSavSUS  := {}
Local _aSavSUA  := {}
Local _aSavSUB  := {}
Local _aSavSC5  := {}
Local _aSavSC6  := {}
Local _aSavSC9  := {}
Local _aSavSF2  := {}
Local _aSavSD2  := {}
Local _aSavSE1  := {}
Local _aSavSF1  := {}
Local _aSavSD1  := {}
Local _aSavSE2  := {}

Public _cRotina := 'MA450MNU'
Public cPerg	:= _cRotina

If Type("aTmpFil")=="U"
	Public aTmpFil := {}
EndIf
If Type("aSelFil")=="U"
	Public aSelFil := {}
EndIf
dbSelectArea("SA1")
_aSavSA1  := SA1->(GetArea())
dbSelectArea("SA2")
_aSavSA2  := SA2->(GetArea())
dbSelectArea("SUS")
_aSavSUS  := SUS->(GetArea())
dbSelectArea("SUA")
_aSavSUA  := SUA->(GetArea())
dbSelectArea("SUB")
_aSavSUB  := SUB->(GetArea())
dbSelectArea("SC5")
_aSavSC5  := SC5->(GetArea())
dbSelectArea("SC6")
_aSavSC6  := SC6->(GetArea())
dbSelectArea("SC9")
_aSavSC9  := SC9->(GetArea())
dbSelectArea("SF2")
_aSavSF2  := SF2->(GetArea())
dbSelectArea("SD2")
_aSavSD2  := SD2->(GetArea())
dbSelectArea("SE1")
_aSavSE1  := SE1->(GetArea())
dbSelectArea("SF1")
_aSavSF1  := SF1->(GetArea())
dbSelectArea("SD1")
_aSavSD1  := SD1->(GetArea())
dbSelectArea("SE2")
_aSavSE2  := SE2->(GetArea())

//Tecla F2 para abertura do Banco de Conhecimento do cliente posicionado, inserido por Arthur Silva em 01/08/2016 conforme solicita็ใo da Sra. Alecssandra
If ExistBlock("RFINE030") //Rotina chama tela de Banco de conhecimento
	SetKey(VK_F2, { ||                })
	SetKey(VK_F2, { || U_RFINE030()   })
	RestArea(_aSavSA1)
	RestArea(_aSavSA2)
	RestArea(_aSavSUS)
	RestArea(_aSavSUA)
	RestArea(_aSavSUB)
	RestArea(_aSavSC5)
	RestArea(_aSavSC6)
	RestArea(_aSavSC9)
	RestArea(_aSavSF2)
	RestArea(_aSavSD2)
	RestArea(_aSavSE1)
	RestArea(_aSavSF1)
	RestArea(_aSavSD1)
	RestArea(_aSavSE2)
	RestArea(_aSavArea)
EndIf

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F7 , { ||               })
SetKey(VK_F7 , { || _ALTERPED()   }) // - Tecla de atalho para abrir o cadastro para altera็๕es
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F7,{|| MsgAlert( "Tecla [ F7 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
//SetKey( K_CTRL_F7, { || })
//SetKey( K_CTRL_F7, { || _ALTERPED()})
RestArea(_aSavSA1)
RestArea(_aSavSA2)
RestArea(_aSavSUS)
RestArea(_aSavSUA)
RestArea(_aSavSUB)
RestArea(_aSavSC5)
RestArea(_aSavSC6)
RestArea(_aSavSC9)
RestArea(_aSavSF2)
RestArea(_aSavSD2)
RestArea(_aSavSE1)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavSE2)
RestArea(_aSavArea)

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F8 , { ||               }) // - Tecla de atalho para abrir o cadastro para altera็๕es
SetKey(VK_F8 , { || _ALTER()      }) // - Tecla de atalho para abrir o cadastro para altera็๕es
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F8,{|| MsgAlert( "Tecla [ F8 ] foi alterada para [ Ctrl + F8 ]" , "Protheus11" )})
//SetKey( K_CTRL_F8, { || })
//SetKey( K_CTRL_F8, { || _ALTER()})
RestArea(_aSavSA1)
RestArea(_aSavSA2)
RestArea(_aSavSUS)
RestArea(_aSavSUA)
RestArea(_aSavSUB)
RestArea(_aSavSC5)
RestArea(_aSavSC6)
RestArea(_aSavSC9)
RestArea(_aSavSF2)
RestArea(_aSavSD2)
RestArea(_aSavSE1)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavSE2)
RestArea(_aSavArea)

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F9 , { ||                }) // - Tecla de atalho para abrir os pedidos da consulta do cliente
SetKey(VK_F9 , { || FICHCON("PED") }) // - Tecla de atalho para abrir os pedidos da consulta do cliente
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F9,{|| MsgAlert( "Tecla [ F9 ] foi alterada para [ Ctrl + F9 ]" , "Protheus11" )})
//SetKey( K_CTRL_F9, { || })
//SetKey( K_CTRL_F9, { || FICHCON("PED")})
RestArea(_aSavSA1)
RestArea(_aSavSA2)
RestArea(_aSavSUS)
RestArea(_aSavSUA)
RestArea(_aSavSUB)
RestArea(_aSavSC5)
RestArea(_aSavSC6)
RestArea(_aSavSC9)
RestArea(_aSavSF2)
RestArea(_aSavSD2)
RestArea(_aSavSE1)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavSE2)
RestArea(_aSavArea)

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F10, { ||                }) // - Tecla de atalho para abrir os faturamentos da consulta do cliente
SetKey(VK_F10, { || FICHCON("FAT") }) // - Tecla de atalho para abrir os faturamentos da consulta do cliente
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F10,{|| MsgAlert( "Tecla [ F10 ] foi alterada para [ Ctrl + F10 ]" , "Protheus11" )})
//SetKey( K_CTRL_F10, { || })
//SetKey( K_CTRL_F10, { || FICHCON("FAT")})
RestArea(_aSavSA1)
RestArea(_aSavSA2)
RestArea(_aSavSUS)
RestArea(_aSavSUA)
RestArea(_aSavSUB)
RestArea(_aSavSC5)
RestArea(_aSavSC6)
RestArea(_aSavSC9)
RestArea(_aSavSF2)
RestArea(_aSavSD2)
RestArea(_aSavSE1)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavSE2)
RestArea(_aSavArea)

// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F11, { ||             })
SetKey(VK_F11, { || FICHFINAN() }) // - Tecla de atalho para abrir a ficha financeira (customizada) do cliente
// Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
//SetKey( VK_F11,{|| MsgAlert( "Tecla [ F11 ] foi alterada para [ Ctrl + F11 ]" , "Protheus11" )})
//SetKey( K_CTRL_F11, { || })
//SetKey( K_CTRL_F11, { || FICHFINAN()})
RestArea(_aSavSA1)
RestArea(_aSavSA2)
RestArea(_aSavSUS)
RestArea(_aSavSUA)
RestArea(_aSavSUB)
RestArea(_aSavSC5)
RestArea(_aSavSC6)
RestArea(_aSavSC9)
RestArea(_aSavSF2)
RestArea(_aSavSD2)
RestArea(_aSavSE1)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavSE2)
RestArea(_aSavArea)
//SetKey(VK_F10, { || AltCli()})
//SetKey(VK_F11, { || MA030BRWA()})
//Inํcio - Trecho adicionado por Adriano Leonardo em 18/03/2014 para inclusใo de botใo de busca avan็ada
If ExistBlock("RTMKE022") .And. FunName()=="MATA410"
	AAdd(aRotina,{ "Busca Avan็ada","U_RTMKE022",0,1,0 ,NIL} )
	//Seta atalho para tecla F5 para chamar a tela de busca avan็ada
	//SetKey(VK_F5,{|| })
	//SetKey(VK_F5,{|| U_RTMKE022() })
    // Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
	//SetKey(VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
	SetKey( K_CTRL_F5, { || })
	SetKey( K_CTRL_F5, { || U_RTMKE022()})
EndIf
//Final  - Trecho adicionado por Adriano Leonardo em 18/03/2014 para inclusใo de botใo de busca avan็ada
RestArea(_aSavSA1)
RestArea(_aSavSA2)
RestArea(_aSavSUS)
RestArea(_aSavSUA)
RestArea(_aSavSUB)
RestArea(_aSavSC5)
RestArea(_aSavSC6)
RestArea(_aSavSC9)
RestArea(_aSavSF2)
RestArea(_aSavSD2)
RestArea(_aSavSE1)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavSE2)
RestArea(_aSavArea)
//Inํcio - Trecho adicionado por Adriano Leonardo 16/07/2014
If ExistBlock("RFINE021") //Rotina de Adiantamentos (Pedido de venda)
	//SetKey(VK_F6, { || U_RFINE021(.T.)})
    // Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
	SetKey( K_CTRL_F6, { || })
	SetKey( K_CTRL_F6, { || U_RFINE021(.T.)})	
	RestArea(_aSavSA1)
	RestArea(_aSavSA2)
	RestArea(_aSavSUS)
	RestArea(_aSavSUA)
	RestArea(_aSavSUB)
	RestArea(_aSavSC5)
	RestArea(_aSavSC6)
	RestArea(_aSavSC9)
	RestArea(_aSavSF2)
	RestArea(_aSavSD2)
	RestArea(_aSavSE1)
	RestArea(_aSavSF1)
	RestArea(_aSavSD1)
	RestArea(_aSavSE2)
	RestArea(_aSavArea)
	ValidPerg() //Chama fun็ใo de parโmetros da rotina de adintamentos (customizada)

	//SetKey(VK_F12,{ || Pergunte(cPerg,.T.)})
    // Teclas alterada em 19/08/15 por J๚lio Soares para nใo conflitar com as teclas de atalho padrใo.
	SetKey( K_CTRL_F12, { || })
	SetKey( K_CTRL_F12, { || Pergunte(cPerg,.T.)})
	RestArea(_aSavSA1)
	RestArea(_aSavSA2)
	RestArea(_aSavSUS)
	RestArea(_aSavSUA)
	RestArea(_aSavSUB)
	RestArea(_aSavSC5)
	RestArea(_aSavSC6)
	RestArea(_aSavSC9)
	RestArea(_aSavSF2)
	RestArea(_aSavSD2)
	RestArea(_aSavSE1)
	RestArea(_aSavSF1)
	RestArea(_aSavSD1)
	RestArea(_aSavSE2)
	RestArea(_aSavArea)
EndIf
//Final  - Trecho adicionado por Adriano Leonardo 16/07/2014
//Chamada da tela de apresenta็ใo dos logs dos pedidos
If ExistBlock("RFATL001")
	SetKey( K_CTRL_F9, { || })
	SetKey( K_CTRL_F9, { || U_RFATL001(SC5->C5_NUM,POSICIONE('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_NUM'),'',_cRotina,)})
	AAdd(aRotina,{"Logs do Pedido","U_RFATL001(SC5->C5_NUM,POSICIONE('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_NUM'),'','"+_cRotina+"',)" ,0,6,0 ,NIL})
EndIf

If Type("_oObj")=="O"
	_oObj:Default()
	_oObj:Refresh()
EndIf

RestArea(_aSavSA1)
RestArea(_aSavSA2)
RestArea(_aSavSUS)
RestArea(_aSavSUA)
RestArea(_aSavSUB)
RestArea(_aSavSC5)
RestArea(_aSavSC6)
RestArea(_aSavSC9)
RestArea(_aSavSF2)
RestArea(_aSavSD2)
RestArea(_aSavSE1)
RestArea(_aSavSF1)
RestArea(_aSavSD1)
RestArea(_aSavSE2)
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_ALTERPED บAutor  ณJ๚lio Soares        บ Data ณ  29/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _ALTERPED()

If ExistBlock("RFATE035")
	Execblock("RFATE035")
Else
	MSGBOX('Fun็ใo nใo encontrada, informe o Administrador do sistema',_cRotina+'_001','ALERT')
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ _Alter  บAutor  ณJ๚lio Soares         บ Data ณ  23/12/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tecla de atalho para realizar a altera็ใo do cadastro      บฑฑ
ฑฑบ          ณ posicionado.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function _ALTER()

If MSGBOX('Deseja alterar o cadastro do cliente '+(SA1->A1_NOME)+'?',_cRotina + '_01','YESNO')
	A030Altera('SA1',(Recno()),3)
Endif

Return()
*/
Static Function _ALTER()

Local _aSavArea  := GetArea()
Local _aSavSA1X  := SA1->(GetArea())
Local _aSavSC5X  := SC5->(GetArea())
Local _lIncui    := INCLUI
Local _lAltera   := ALTERA

Private _cCli    := SC5->C5_CLIENTE
Private _cLoja   := SC5->C5_LOJACLI
Private _cNome   := SC5->C5_NOMCLI
Private aRotAuto := Nil

dbSelectArea("SC5")
If UPPER(AllTrim(FunName())) == "MATA450"
	SC5->(dbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		_cCli    := SC5->C5_CLIENTE
		_cLoja   := SC5->C5_LOJACLI
		_cNome   := SC5->C5_NOMCLI
	EndIf
EndIf
dbSelectArea("SA1")
SA1->(dbSetOrder(1))
If MSGBOX('Deseja alterar o cadastro do cliente '+ Alltrim(_cNome) +'?',_cRotina + '_002','YESNO')
	If SA1->(MsSeek(xFilial("SA1")+_cCli+_cLoja,.T.,.F.))
		nReg   := SA1->(Recno())
		INCLUI := .F.
		ALTERA := .T.
	//	A030Altera("SA1",nReg,4)
		AxAltera("SA1",nReg,4)
	Else
		MSGBOX('Cliente' + _cCli +' - ' + Alltrim(_cNome) + ' Nใo encontrado, INFORME O ADMINISTRADOR DO SISTEMA.',_cRotina + '_003','ALERT')
	EndIf
	INCLUI := _lIncui
	ALTERA := _lAltera
EndIf

RestArea(_aSavSC5X)
RestArea(_aSavSA1X)
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FICHCON  บAutor  ณJ๚lio Soares        บ Data ณ  23/12/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abri a consulta da posicao do cliente.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// - F10/F11
Static Function FICHCON(_Tp)

Local   _aSavArea := GetArea()
Local _aSavSA1X   := SA1->(GetArea())
Local _aSavSC5X   := SC5->(GetArea())

Private _cCli     := SC5->C5_CLIENTE
Private _cLoja    := SC5->C5_LOJACLI
Private _cNome    := SC5->C5_NOMCLI

DEFAULT _Tp := "PED"

lPergunte := Pergunte("FIC010",FunName()=="FINC010")		
nBrowse   := 0
aAlias    := {}
aGet      := {"","","",""}
aParam    := {}
lExibe    := .T. // - Informa se a pesquisa deve ser exibida.
lRelat    := .F. 
nCasas    := SuperGetMv("MV_CENT",,"2")

If lPergunte .Or. FunName()<>"FINC010"
	aadd(aParam,MV_PAR01)
	aadd(aParam,MV_PAR02)
	aadd(aParam,MV_PAR03)
	aadd(aParam,MV_PAR04)
	aadd(aParam,MV_PAR05)
	aadd(aParam,MV_PAR06)
	aadd(aParam,MV_PAR07)
	aadd(aParam,MV_PAR08)
	aadd(aParam,MV_PAR09)
	aadd(aParam,MV_PAR10)
	aadd(aParam,MV_PAR11)
	aadd(aParam,MV_PAR12)
	aadd(aParam,MV_PAR13)
	aadd(aParam,MV_PAR14)
	aadd(aParam,MV_PAR15)
EndIf
dbSelectArea("SC5")
If UPPER(AllTrim(FunName())) == "MATA450"
	SC5->(dbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		_cCli    := SC5->C5_CLIENTE
		_cLoja   := SC5->C5_LOJACLI
		_cNome   := SC5->C5_NOMCLI
	EndIf
EndIf
dbSelectArea("SA1")
SA1->(dbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1")+_cCli+_cLoja,.T.,.F.))
	If _Tp == "PED"
		nBrowse := 3
		aAlias  := {}
	//	Fc010Con(cAlias,nRecno,nOpcx) // - Apresenta a tela da posi็ใo do cliente
		Fc010Brow(nBrowse,@aAlias,aParam,.T.,aGet)
		For _x := 1 To Len(aAlias)
			dbSelectArea(aAlias[_x][01])
			(aAlias[_x][01])->(dbCloseArea())
			If File(aAlias[_x][02]+OrdBagExt())
				FErase(aAlias[_x][02]+OrdBagExt())
			EndIf
		Next
		nBrowse := 0
		aAlias  := {}
		aParam  := {}	
	ElseIf _Tp == "FAT"
		nBrowse := 4
		aAlias  := {}
	//	Fc010Con() // - Apresenta a tela da posi็ใo do cliente
		Fc010Brow(nBrowse,@aAlias,aParam,.T.,aGet)
		For _x := 1 To Len(aAlias)
			dbSelectArea(aAlias[_x][01])
			(aAlias[_x][01])->(dbCloseArea())
			If File(aAlias[_x][02]+OrdBagExt())
				FErase(aAlias[_x][02]+OrdBagExt())
			EndIf
		Next
		nBrowse := 0
		aAlias  := {}
		aParam  := {}
	EndIf
EndIf	

RestArea(_aSavSC5X)
RestArea(_aSavSA1X)
RestArea(_aSavArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FICHFINAN บAutor  ณJ๚lio Soares       บ Data ณ  17/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Execblock utilizado para montar a ficha financeira do      บฑฑ
ฑฑบ          ณ cliente.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FICHFINAN()

Local _aSavArea := GetArea()
Local _aSavSA1X := SA1->(GetArea())
Local _aSavSC5X := SC5->(GetArea())

Public _cClir   := SC5->C5_CLIENTE
Public _cLojr   := SC5->C5_LOJACLI
Public _cNomr   := SC5->C5_NOMCLI
Public _cCGCr   := SC5->C5_CGCCENT

dbSelectArea("SC5")
If UPPER(AllTrim(FunName())) == "MATA450"
	SC5->(dbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		_cClir   := SC5->C5_CLIENTE
		_cLojr   := SC5->C5_LOJACLI
		_cNomr   := SC5->C5_NOMCLI
		_cCGCr   := SC5->C5_CGCCENT
	EndIf
EndIf
dbSelectArea("SA1")
SA1->(dbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1")+_cClir+_cLojr,.T.,.F.))
	If ExistBlock("RFINE011")
		ExecBlock("RFINE011")
	Else
		MSGBOX('FUNวรO NรO ENCONTRADA. INFORME O ADMINISTRADOR DO SISTEMA!',_cRotina + '_004','ALERT')
	EndIf
Else
	MSGBOX('CLIENTE NAO ENCONTRADO!',_cRotina + '_005','ALERT')
EndIf
_cClir := ''
_cLojr := ''
_cNomr := ''
_cCGCr := ''

RestArea(_aSavSC5X)
RestArea(_aSavSA1X)
RestArea(_aSavArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidaCredบAutor  ณAdriano Leonardo    บ Data ณ  10/07/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel pela avalia็ใo dos tํtulos de cr้dito   บฑฑ
ฑฑบ          ณ (RAs e NCCs) para vํnculo com pedido de vendas.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ValidaCred()
	
//Trecho em desenvolvimento
//Todo: Incluir campo de saldo a compensar e ajustar na query

ValidPerg()
cPerg := _cRotina
Pergunte(cPerg,.F.)

//Monto a consulta para retornar os tํtulos que poderใo ser vinculados ao pedido em questใo
_cQry := "SELECT * FROM " + RetSqlName("SE1") + " SE1 "
_cQry += "WHERE SE1.D_E_L_E_T_='' "
If MV_PAR05 == "1" //Considera Filiais
	_cQry += "AND SE1.E1_FILIAL BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
Else
	_cQry += "AND SE1.E1_FILIAL='" + xFilial("SE1") + "' "
EndIf
If MV_PAR08=="1" //Considera NCCs
	_cTipos := "('RA'|'NCC')"
Else
	_cTipos := "('RA')"
EndIf
_cQry += "AND SE1.E1_TIPO IN '" + _cTipos + "' "
If MV_PAR02 == "1" //Considera Cliente
	_cQry += "AND SE1.E1_CLIENTE = '" + SC5->C5_CLIENTE + "' "
EndIf
If MV_PAR01 == "1" //Considera Loja
	_cQry += "AND SE1.E1_LOJA = '" + SC5->C5_LOJACLI + "' "
EndIf
_cQry += "AND SE1.E1_PEDIDO = '' "
_cQry += "ORDER BY E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_PREFIXO, E1_NUM, E1_PARCELA "

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณAdriano Leonardo    บ Data ณ  10/07/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria็ใo de parโmetros de usuแrio, para definir os crit้riosบฑฑ
ฑฑบ          ณ de sele็ใo dos RAs.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}

cPerg         := PADR(cPerg,10)
                                                             
AADD(aRegs,{cPerg,"01","Considera Loja?"  			,"","","mv_ch1","C",01,0,0,"C","","MV_PAR01","Sim"	,"","",""		,"","Nใo"	,"","","","","","","","","","","","","","","","","","",""	,""})
AADD(aRegs,{cPerg,"02","Considera Cliente?"			,"","","mv_ch2","C",01,0,0,"C","","MV_PAR02","Sim"	,"","",""		,"","Nใo"	,"","","","","","","","","","","","","","","","","","",""	,""})
AADD(aRegs,{cPerg,"03","Do Cliente?" 				,"","","mv_ch3","C",06,0,0,"G","","MV_PAR03",""		,"","",""		,"",""		,"","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"04","At้ Cliente?"				,"","","mv_ch4","C",06,0,0,"G","","MV_PAR04",""		,"","","ZZZZZZ"	,"",""		,"","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"05","Considera Filiais Abaixo?"  ,"","","mv_ch5","C",02,0,0,"C","","MV_PAR05","Sim"	,"","",""		,"","Nใo"	,"","","","","","","","","","","","","","","","","","",""	,""})
AADD(aRegs,{cPerg,"06","De Filial?" 	   			,"","","mv_ch6","C",02,0,0,"G","","MV_PAR06",""		,"","",""		,"",""		,"","","","","","","","","","","","","","","","","","",""	,""})
AADD(aRegs,{cPerg,"07","At้ Filial?"				,"","","mv_ch7","C",02,0,0,"G","","MV_PAR07",""		,"","","ZZ"		,"",""		,"","","","","","","","","","","","","","","","","","",""	,""})
AADD(aRegs,{cPerg,"08","Considera NCC?"  			,"","","mv_ch8","C",01,0,0,"C","","MV_PAR08","Sim"	,"","",""		,"","Nใo"	,"","","","","","","","","","","","","","","","","","",""	,""})

For i:=1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(cPerg+aRegs[i,2]))
		while !RecLock("SX1",.T.) ; enddo
			For j:=1 To FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Else
					Exit
				EndIf
			Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_sAlias)

Return()