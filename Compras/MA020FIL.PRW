#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MA020FIL  บAutor  ณ J๚lio Soares       บ Data ณ  24/07/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada utilizado para criar uma tecla de atalho. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ LOCALIZAวรO : Function MATA020 - Fun็ใo principal do       บฑฑ
ฑฑบ          ณ programa de inclusใo, altera็ใo e exclusใo de Fornecedores บฑฑ.
ฑฑบ          ณ EM QUE PONTO: No inํcio da Fun็ใo, antes de montar a tela dบฑฑ
ฑฑบ          ณ browse dos fornecedores, deve ser usado para adicionar um  บฑฑ
ฑฑบ          ณ FILTRO para os registros do cadastro de fornecedores       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MA020FIL()

Local _aSavArea  := GetArea()
Local _aSavSC5   := SC5->(GetArea())
Local _aSavSA1   := SA1->(GetArea())

Private _cRotina := "MA020FIL"
// DESATIVADO ALTERAวรO EM 21/08/15 POR JฺLIO SOARES APำS SOLICITAวรO DO SR. MARIO
SetKey(VK_F11, { || FICHFINAN() }) // - Tecla de atalho para abrir a ficha financeira (customizada) do cliente

RestArea(_aSavSC5 )
RestArea(_aSavSA1 )
RestArea(_aSavArea)

Return()
/*
/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ/ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ/ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ/ฑฑบPrograma  ณ FICHFINAN บAutor  ณJ๚lio Soares       บ Data ณ  17/10/13   บฑฑ/ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ/ฑฑบDesc.     ณ Execblock utilizado para montar a ficha financeira do      บฑฑ/ฑฑบ          ณ cliente.                                                   บฑฑ/ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ/ฑฑบUso       ณ Programa Principal.                                        บฑฑ/ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ/ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ/฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FICHFINAN()
// - F11
If ExistBlock("RFINE016")
	U_RFINE016("F11")
Else
	MSGBOX('FUNวรO NรO ENCONTRADA. INFORME O ADMINISTRADOR DO SISTEMA!',_cRotina + '_001','ALERT')
EndIf
Return()