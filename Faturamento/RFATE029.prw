#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE019  ºAutor  ³Júlio Soares          º Data ³  07/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada criado para fixar os parâmetros da        º±±
±±ºDesc.     ³ exclusão da nota de saída para que essa não seja alterada. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus 11 - Específico para a empresa Arcolor.(CD Control)º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºRelação   ³ Essa rotina tem relação com o Execblock RFATE028, RFATE029,º±±
±±º          ³ e os pontos de entrada M520QRY, M520FIL e M520BROW.        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE029(_cChamada)

Local _cRotina    := "RFATE029"
Local _lRet       := .T.

Default _cChamada := ""

If __cUserId <> '000000'
	If _cChamada<>"VLDSX1"
		If !Pergunte("MT521A",.T.)
			_lRet := .F.
			Return(_lRet)
		EndIf
		aRotina[1][2] := "Ma521MarkB"
	EndIf
	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±º MV_PAR01 := 1           //Marcação/Seleção º±±
	±±º MV_PAR02 := 1           //Seleciona Itens  º±±
	±±º MV_PAR03 := _dData1     //De Emissao       º±±
	±±º MV_PAR04 := _dData2     //Ate Emissao      º±±
	±±º MV_PAR05 := ""          //De Serie         º±±
	±±º MV_PAR06 := "ZZZ"       //Ate Serie        º±±
	±±º MV_PAR07 := ""          //De Documento     º±±
	±±º MV_PAR08 := "ZZZZZZZZZ" //Ate Documento    º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	//MV_PAR01 := 1           //Marcação/Seleção

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	If MV_PAR01<>1
		_lRet    := .F.
		MV_PAR01 := 1 //Marcação/Seleção
		If _cChamada<>"VLDSX1"
			If (_cAliasSX1)->(MsSeek("MT521A    01",.T.,.F.))
				RecLock(_cAliasSX1,.F.)
				(_cAliasSX1)->X1_PRESEL := MV_PAR01
				(_cAliasSX1)->(MSUNLOCK())
			EndIf
			If ExistBlock("RCFGASX1")
				U_RCFGASX1("MT521A    ","01",MV_PAR01)
			EndIf
			MsgBox("Por questoes de integridade, a pergunta '1' foi fixada para permitir que as notas venham sempre marcadas!",_cRotina+"_001","ALERT")
		Else
			MsgBox("Por questoes de integridade, a pergunta '1' nao podera ser configurada com conteudo diferente de (Marcacao)",_cRotina+"_001","STOP")
		EndIf
	EndIf
	// MV_PAR02 := 1           //Seleciona Itens
	If MV_PAR02<>1 //Alterado para não trazer flegado
		_lRet    := .F.
		MV_PAR02 := 1 //Seleciona Itens (1=SIM | 2=NÃO)
		If _cChamada<>"VLDSX1"
			If (_cAliasSX1)->(MsSeek("MT521A    02",.T.,.F.))
				RecLock(_cAliasSX1,.F.)
				(_cAliasSX1)->X1_PRESEL := MV_PAR02
				(_cAliasSX1)->(MSUNLOCK())
			EndIf
			If ExistBlock("RCFGASX1")
				U_RCFGASX1("MT521A    ","01",MV_PAR02)
			EndIf
			MsgBox("Por questoes de integridade, a pergunta '2' foi fixada para permitir que os itens não sejam alterados",_cRotina+"_002","ALERT")
		Else
			MsgBox("Por questoes de integridade, a pergunta '2' nao podera ser configurada com conteudo diferente de (Não)",_cRotina+"_002","STOP")
		EndIf
	EndIf
	//	MV_PAR05 := ""//De Serie
	If MV_PAR05<>"   "
		_lRet    := .F.
		MV_PAR05 := "   " //De Serie
		If _cChamada<>"VLDSX1"
			If (_cAliasSX1)->(MsSeek("MT521A    05",.T.,.F.))
				RecLock(_cAliasSX1,.F.)
				(_cAliasSX1)->X1_PRESEL := MV_PAR05
				(_cAliasSX1)->(MSUNLOCK())
			EndIf
			If ExistBlock("RCFGASX1")
				U_RCFGASX1("MT521A    ","05",MV_PAR05)
			EndIf
			MsgBox("Por questoes de integridade, esse parâmetro não pode ser configurado.",_cRotina+"_005","ALERT")
		Else
			MsgBox("Esse parâmetro não pode ser configurado pois o mesmo já tem conteúdo automático",_cRotina+"_005","STOP")
		EndIf
	EndIf
	//  MV_PAR06 := "ZZZ"//Ate Serie
	If MV_PAR06<>"ZZZ"
		_lRet    := .F.
		MV_PAR06 := "ZZZ" //Ate Serie
		If _cChamada<>"VLDSX1"
			If (_cAliasSX1)->(MsSeek("MT521A    06",.T.,.F.))
				RecLock(_cAliasSX1,.F.)
				(_cAliasSX1)->X1_PRESEL := MV_PAR06
				(_cAliasSX1)->(MSUNLOCK())
			EndIf
			If ExistBlock("RCFGASX1")
				U_RCFGASX1("MT521A    ","06",MV_PAR06)
			EndIf
			MsgBox("Por questoes de integridade, esse parâmetro não pode ser configurado.",_cRotina+"_006","ALERT")
		Else
			MsgBox("Esse parâmetro não pode ser configurado pois o mesmo já tem conteúdo automático",_cRotina+"_006","STOP")
		EndIf
	EndIf
	//  MV_PAR07 := ""//De Documento
	If MV_PAR07<>"         "
		_lRet    := .F.
		MV_PAR07 := "         " //De Documento
		If _cChamada<>"VLDSX1"
			If (_cAliasSX1)->(MsSeek("MT521A    07",.T.,.F.))
				RecLock(_cAliasSX1,.F.)
				(_cAliasSX1)->X1_PRESEL := MV_PAR07
				(_cAliasSX1)->(MSUNLOCK())
			EndIf
			If ExistBlock("RCFGASX1")
				U_RCFGASX1("MT521A    ","07",MV_PAR07)
			EndIf
			MsgBox("Por questoes de integridade, esse parâmetro não pode ser configurado.",_cRotina+"_007","ALERT")
		Else
			MsgBox("Esse parâmetro não pode ser configurado pois o mesmo já tem conteúdo automático",_cRotina+"_007","BOX")
		EndIf
	EndIf
	//	MV_PAR08 := "ZZZZZZZZZ"//Ate Documento
	If MV_PAR08<>"ZZZZZZZZZ"
		_lRet    := .F.
		MV_PAR08 := "ZZZZZZZZZ" //Ate Documento
		If _cChamada<>"VLDSX1"
			If (_cAliasSX1)->(MsSeek("MT521A    08",.T.,.F.))
				RecLock(_cAliasSX1,.F.)
				(_cAliasSX1)->X1_PRESEL := MV_PAR08
				(_cAliasSX1)->(MSUNLOCK())
			EndIf
			If ExistBlock("RCFGASX1")
				U_RCFGASX1("MT521A    ","08",MV_PAR08)
			EndIf
			MsgBox("Por questoes de integridade, esse parâmetro não pode ser configurado.",_cRotina+"_008","ALERT")
		Else
			MsgBox("Esse parâmetro não pode ser configurado pois o mesmo já tem conteúdo automático",_cRotina+"_008","STOP")
		EndIf
	EndIf
EndIf

Return(_lRet)