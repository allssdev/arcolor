#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE cENT CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFISE001  ºAutor  ³Anderson C. P. Coelho º Data ³  19/11/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock chamado no Ponto de Entrada MA900MNU, utilizado  º±±
±±º          ³para chamar a rotina "A900Altera" padrão e, depois, alterar º±±
±±º          ³a data de digitação do documento de entrada para a data de  º±±
±±º          ³recebimento do referido documento de entrada.               º±±
±±º          ³OBS.: Os riscos inerentes a este processo de alteração já   º±±
±±º          ³foram passados aos Srs. André e Marco nesta data (19/11/14).º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Especifico para a empresa Arcolor.            º±±
±±º          ³ Execblock utilizado no Ponto de Entrada MA900MNU.          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFISE001()

Local _aSvAr   := GetArea()
Local _aSvArD1 := {}
Local _aSvArF1 := {}
Local _cRotina := "RFISE001"
Local _cQry    := ""
Local cAlias   := Alias()
Local nReg     := Recno()
Local nOpc     := 4

//Chamada da rotina padrão
A900Altera(cAlias,nReg,nOpc)

If VAL(SubStr(AllTrim(SF3->F3_CFO),1,1)) < 5
	dbSelectArea("SD1")
	_aSvArD1 := SD1->(GetArea())
	_cQry := " UPDATE " + RetSqlName("SD1")            + cENT
	_cQry += " SET D1_DTDIGIT = SF1.F1_RECBMTO "       + cENT
	_cQry += " FROM " + RetSqlName("SD1") + " SD1 "    + cENT
	_cQry += "      INNER JOIN " + RetSqlName("SF1")   + " SF1 ON SF1.D_E_L_E_T_ = '' " + cENT
	_cQry += "                AND SF1.F1_FILIAL   = '" + xFilial("SF1") + "' "          + cENT
	_cQry += "                AND SF1.F1_DOC      = '" + Padr(SF3->F3_NFISCAL,Len(SF1->F1_DOC    )) + "' " + cENT
	_cQry += "                AND SF1.F1_SERIE    = '" + Padr(SF3->F3_SERIE  ,Len(SF1->F1_SERIE  )) + "' " + cENT
	_cQry += "                AND SF1.F1_FORNECE  = '" + Padr(SF3->F3_CLIEFOR,Len(SF1->F1_FORNECE)) + "' " + cENT
	_cQry += "                AND SF1.F1_LOJA     = '" + Padr(SF3->F3_LOJA   ,Len(SF1->F1_LOJA   )) + "' " + cENT
	_cQry += "                AND SF1.F1_DTDIGIT <> SF1.F1_RECBMTO " + cENT
	_cQry += "                AND SF1.F1_DOC      = SD1.D1_DOC     " + cENT
	_cQry += "                AND SF1.F1_SERIE    = SD1.D1_SERIE   " + cENT
	_cQry += "                AND SF1.F1_FORNECE  = SD1.D1_FORNECE " + cENT
	_cQry += "                AND SF1.F1_LOJA     = SD1.D1_LOJA    " + cENT
	_cQry += " WHERE SD1.D_E_L_E_T_  = '' " + cENT
	_cQry += "   AND SD1.D1_FILIAL   = '"   + xFilial("SD1") + "' "  + cENT
    /*
	If __cUserId == "000000"
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
	EndIf
	*/
	If TCSQLExec(_cQry) < 0
		TcRefresh("SD1")
		MsgStop("Atenção! Houve um problema na tentativa de manipulação da data de digitação dos itens do documento de entrada posicionado. Por favor, verifique o Kardex dos produtos a este vinculados, bem como as demais informações de data do documento e contate o administrador do sistema!" + cENT + "[TCSQLError] " + TCSQLError(),_cRotina+"_001")
	Else
		TcRefresh("SD1")
		RestArea(_aSvArD1)

		dbSelectArea("SF1")
		_aSvArF1 := SF1->(GetArea())
		_cQry := " UPDATE " + RetSqlName("SF1")            + cENT
		_cQry += " SET F1_DTDIGIT = SF1.F1_RECBMTO "       + cENT
		_cQry += " FROM " + RetSqlName("SF1") + " SF1 "    + cENT
		_cQry += " WHERE SF1.D_E_L_E_T_  = '' " + cENT
		_cQry += "   AND SF1.F1_FILIAL   = '"   + xFilial("SF1") + "' "  + cENT
		_cQry += "   AND SF1.F1_DOC      = '" + Padr(SF3->F3_NFISCAL,Len(SF1->F1_DOC    )) + "' " + cENT
		_cQry += "   AND SF1.F1_SERIE    = '" + Padr(SF3->F3_SERIE  ,Len(SF1->F1_SERIE  )) + "' " + cENT
		_cQry += "   AND SF1.F1_FORNECE  = '" + Padr(SF3->F3_CLIEFOR,Len(SF1->F1_FORNECE)) + "' " + cENT
		_cQry += "   AND SF1.F1_LOJA     = '" + Padr(SF3->F3_LOJA   ,Len(SF1->F1_LOJA   )) + "' " + cENT
		_cQry += "   AND SF1.F1_DTDIGIT <> SF1.F1_RECBMTO " + cENT
		If __cUserId == "000000"
			MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cQry)
		EndIf
		If TCSQLExec(_cQry) < 0
			MsgStop("Atenção! Houve um problema na tentativa de manipulação da data de digitação do documento de entrada posicionado. Por favor, verifique o Kardex dos produtos a este vinculados, bem como as demais informações de data do documento e contate o administrador do sistema!" + cENT + "[TCSQLError] " + TCSQLError(),_cRotina+"_002")
		EndIf
		TcRefresh("SF1")
		RestArea(_aSvArF1)
	EndIf
EndIf

RestArea(_aSvAr)

Return NIL