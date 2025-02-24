#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFINE027 บAutor  ณ J๚lio Soares       บ Data ณ  19/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ExecBlock utilizado para validar o tipo de tํtulo que serแ บฑฑ
ฑฑบ          ณ enviado no arquivo Serasa Relato.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Inserir  "IIF(EXISTBLOCK("RFINE027"),U_RFINE027(_Ord),)"   บฑฑ
ฑฑบ          ณ no campo de valida็ใo para as perguntas MV_PAR07 e MV_PAR08บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Ptorheus11 - Especํfico empresa ARCOLOR                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// -  
// - a.

User Function RFINE027(_Ord)

If &("MV_PAR0"+(cValToChar(_Ord))) <> "NF"
	If !MSGBOX("Serใo incluidos no arquivo todos os tipos de tํtulos, deseja posseguir mesmo assim?","RFINE027_001","YESNO")
		If MSGBOX("Deseja alterar o tipo de tํtulo para NF.","RFINE027_002","YESNO")
			&("MV_PAR0"+cValToChar(_ord)) := "NF"
		EndIf
	EndIf
EndIf

Return()