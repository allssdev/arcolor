#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³REST001  ºAutor  ³Júlio Soares         º Data ³  01/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina criada para a criação automática de produtos baseadosº±±
±±º          ³no preenchimento dos campos TIPO, GRUPO                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico Arcolor                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RESTE001()

Local _lRet    := .T.
Local _aArea   := GetArea()
Local _aTipo   := {}
Local _cRVarBk := ReadVar()
Local _cRotina := "RESTE001"
Local _cGrupo  := Alltrim(M->B1_GRUPO)
Local _cTipo   := AllTrim(M->B1_TIPO)
Local _cCod    := ""
Local _cCodt   := ""
Local _cCodu   := ""
Local _nPTipo  := 0
Local _cAliasSX3 := "SX3_"+GetNextAlias()
	
If INCLUI

	If _cTipo	<> "MO"
		cQry := " SELECT MAX(B1_COD) CODMAX "
		cQry += " FROM " + RetSqlName("SB1") + "(NOLOCK)"
		cQry += " WHERE B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQry += "   AND B1_GRUPO   = '" + _cGrupo		 + "' "
		cQry += "   AND B1_TIPO    = '" + _cTipo		 + "' "
		cQry += "   AND D_E_L_E_T_ = '' "
		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SB1X",.T.,.F.)

		dbSelectArea("SB1X")
		_lAtuCod := .F.
		If !SB1X->(EOF()) .AND. !Empty(SB1X->CODMAX)
			_cCod        := Soma1(AllTrim(SB1X->CODMAX))
			_lAtuCod     := .T.
		Else
			_aTipo 	     := &(SuperGetMV("MV_TPPROD",,""))
			_nPTipo      := aScan(_aTipo,{|x|AllTrim(x[01])==_cTipo})
			If _nPTipo > 0
				_cCodt   := _aTipo[_nPTipo][02]
				_cCod	 := Padr(_cCodt,2) + Alltrim(_cGrupo) +  "0001"//Quando trouxer _cCodu tratar para trazer o primeiro código.
				_lAtuCod := .T.
			Else
				MSGBOX("Código do produto não pode ser gerado de acordo com as especificações. ",_cRotina+"_001","STOP")
			EndIf
		EndIf
		If _lAtuCod
			__ReadVar := "M->B1_COD"
			M->B1_COD := _cCod
			OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))
			If (_cAliasSX3)->(MsSeek("B1_COD",.T.,.F.))
				If !Empty((_cAliasSX3)->X3_VALID).OR.!Empty((_cAliasSX3)->X3_VLDUSER)
					_lRet := &((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
				Else
					_lRet := .T.
				EndIf
				If !_lRet
					MSGBOX("Problemas na validação do código de produto gerado: " + _cCod , _cRotina+"_003","ALERT")
				Else
					If ExistTrigger("B1_COD")
						RunTrigger(1)
						EvalTrigger()
					EndIf
				EndIf
			EndIf
			
		EndIf
		dbSelectArea("SB1X")
		SB1X->(dbCloseArea())
	EndIf
EndIf

__ReadVar := _cRVarBk

RestArea(_aArea)

Return(_lRet)
