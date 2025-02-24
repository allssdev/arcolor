#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFINE012  บAutor  ณ J๚lio Soares       บ Data ณ  01/14/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Execblock criado para impedir a altera็ใo do parโmetro que บฑฑ
ฑฑบ          ณ considera ou nao os juros na baixa manual (F12)            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico - ARCOLOR                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFINE012()

Local _cRotina := 'RFINE012'
Local _lRet    := .T.

If !Pergunte("FIN070",.T.)
	// - A pergunta 3 "Abate Desc. Comiss. ?" deve estar como SIM para que os descontos nใo componham a base da comissใo.
	If MV_PAR03 == 2
		MV_PAR03 := 1
		_lRet:= .T.
	EndIf
	// - A pergunta 5 "Cons.Juros Comissao ?" deve estar como NรO para que os juros recebidos nใo componham a base da comissใo.
	If MV_PAR05 == 1
		MV_PAR05 := 2
		_lRet:= .T.
	EndIf
	Return(_lRet)
EndIf


If MV_PAR03 <> 1
	_lRet      := .F.
	MV_PAR03   := 1

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	If (_cAliasSX1)->(MsSeek("FIN070    03",.T.,.F.))
		RecLock(_cAliasSX1,.F.)
		(_cAliasSX1)->X1_PRESEL := MV_PAR03
		(_cAliasSX1)->(MSUNLOCK())
		If ExistBlock("RCFGASX1")
			U_RCFGASX1("FIN070    ","03", MV_PAR03)
		EndIf
		MSGBOX("Por questoes de integridade, a pergunta 'Abate Desc. Comiss. ?' foi fixada para NรO permitir que os descontos sejam considerados na base da comissใo.",_cRotina+"_01",'ALERT')
	EndIf
EndIf

If MV_PAR05 <> 2
	_lRet      := .F.
	MV_PAR05   := 2

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	If (_cAliasSX1)->(MsSeek("FIN070    05",.T.,.F.))
		RecLock(_cAliasSX1,.F.)
		(_cAliasSX1)->X1_PRESEL := MV_PAR05
		(_cAliasSX1)->(MSUNLOCK())
		If ExistBlock("RCFGASX1")
			U_RCFGASX1("FIN070    ","05", MV_PAR05)
		EndIf
		MSGBOX("Por questoes de integridade, a pergunta 'Cons.Juros Comissao ?' foi fixada para NใO permitir que os juros sejam considerados na baixa do tํtulo!",_cRotina+"_02",'ALERT')
	EndIf
EndIf

Return(_lRet)