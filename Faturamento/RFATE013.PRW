#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE013  ºAutor  ³Adriano Leonardo    º Data ³  08/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina responsável por definir o nível de acesso dos camposº±±
±±º          ³ conforme cadastro de Bloqueio de Campos (SZ5).             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11   ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE013()

Local   _aSavArea := GetArea()
/*
Private _cCampo   := ""
Private _cValid   := ""

_cQuery := "SELECT SZ5.Z5_TABELA, SZ5.Z5_CAMPO, SZ5.Z5_GRUPO "
_cQuery += "FROM " + RetSqlName("SZ5") + " SZ5 "
_cQuery += "WHERE SZ5.D_E_L_E_T_ = '' "
_cQuery += "  AND SZ5.Z5_FILIAL  = '" + xFilial("SZ5") + "' "
_cQuery += "ORDER BY SZ5.Z5_TABELA, SZ5.Z5_CAMPO, SZ5.Z5_GRUPO "
_cQuery := ChangeQuery(_cQuery)
// Cria tabela temporária com resultado da query
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TRB1",.T.,.F.)
dbSelectArea("TRB1") //Bloqueio campos
While !TRB1->(EOF())
	_cValid := ""
	_cCampo := TRB1->Z5_CAMPO
	While !TRB1->(EOF()) .AND. _cCampo == TRB1->Z5_CAMPO
		//Monta as regras de validação
		_cValid  += "/"+AllTrim(TRB1->Z5_GRUPO)
		dbSelectArea("TRB1")
		TRB1->(dbSkip())
	EndDo
	//Verifica se o campo atual é diferente do anterior
	If !Empty(_cValid) .AND. !Empty(_cCampo)
		_cValid  += "/"
		AtuSx3(_cValid, _cCampo)
	EndIf
	dbSelectArea("TRB1")
EndDo
dbSelectArea("TRB1")
TRB1->(dbCloseArea())
*/
If ExistBlock("RFATE014")
	BeginSql Alias "SZ5TMP"
		SELECT DISTINCT Z5_CAMPO
		FROM %table:SZ5% SZ5
		WHERE SZ5.Z5_FILIAL = %xFilial:SZ5%
		  AND SZ5.%NotDel%
		ORDER BY Z5_CAMPO
	EndSql
	dbSelectArea("SZ5TMP")
	While !SZ5TMP->(EOF())

		_cAliasSX3 := "SX3_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(2))
		If (_cAliasSX3)->(MsSeek(AllTrim(SZ5TMP->Z5_CAMPO),.T.,.F.)) .AND. !"RFATE014"$(_cAliasSX3)->X3_WHEN
			RecLock(_cAliasSX3,.F.)
				If Empty((_cAliasSX3)->X3_WHEN)
					(_cAliasSX3)->X3_WHEN := "U_RFATE014('"+Alltrim((_cAliasSX3)->X3_CAMPO)+"')"
				Else
					(_cAliasSX3)->X3_WHEN := AllTrim((_cAliasSX3)->X3_WHEN)+".AND.U_RFATE014('"+Alltrim((_cAliasSX3)->X3_CAMPO)+"')"
				EndIf
			(_cAliasSX3)->(MSUNLOCK())
		EndIf
		dbSelectArea("SZ5TMP")
		SZ5TMP->(dbSkip())
	EndDo
	SZ5TMP->(dbCloseArea())
EndIf

RestArea(_aSavArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuSX3    ºAutor  ³Adriano Leonardo    º Data ³  08/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função responsável por atualizar validação do campo na SX3.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuSX3(_cAux, _cCpo)

Local _cCompr := ""
Local _nCompr := 0

Default _cAux := ""
Default _cCpo := ""

_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(2))
If (_cAliasSX3)->(MsSeek(_cCpo,.T.,.F.))
	If Compress(@_cCompr,@_nCompr,_cValid,Len(_cValid))
		_cAux := ""
		//Verifica se já existe alguma validação no campo
		If !Empty((_cAliasSX3)->X3_WHEN)
			/*
			_cAux		    := SX3->X3_WHEN
			_cCompara	    := StrTran(_cAux,'U_RFATE014(','@')
			//Verifica se a validação já existe no campo
			If _cCompara <> _cAux
				_aReplace 	:= strTokArr(_cAux,"#")
				_cAux		:= _aReplace[1] + "#" + _cCompr + "#" + _aReplace[3]
			Else
				_cAux		:= AllTrim(_cAux) + ".AND.U_RFATE014('#" + _cCompr + "#')"
			EndIf
			*/
			If !"RFATE014"$(_cAliasSX3)->X3_WHEN
				_cAux		    := AllTrim((_cAliasSX3)->X3_WHEN)+'.AND.ExecBlock("RFATE014")'
			EndIf
		Else
		//	_cAux		    := "U_RFATE014('#" + _cCompr + "#')"
			_cAux		    := 'ExecBlock("RFATE014")'
		EndIf
		//Atualiza campo na SX3
		RecLock(_cAliasSX3,.F.)
		(_cAliasSX3)->X3_WHEN := _cAux
		(_cAliasSX3)->(MsUnLock())
	EndIf
EndIf

Return