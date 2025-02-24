#include "rwmake.ch"
#include "protheus.ch"

#DEFINE _CLRF CHR(13)+CHR(10)
/*/{Protheus.doc} RFATL001
@description Rotina de geração e visualização dos logs dos pedidos de vendas.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/11/2016
@version 1.0
@param _cPed   , caracter, Número do Pedido de Vendas relacionado ao Log
@param _cAt    , caracter, Número do Atendimento do Call Center relacionado ao Log
@param _cLog   , caracter, Log a ser gravado ou gerado (tamanho máximo de 250 caracteres)
@param _cRotOri, caracter, Nome da rotina que chamou a função (normalmente obtida pela variável _cRotina)
@param _cObsEsp, caracter, Observações adicionais/extendida a respeito do log a ser gravado (campo MEMO)
@type function
@see https://allss.com.br
/*/
user function RFATL001(_cPed,_cAt,_cLog,_cRotOri,_cObsEsp)
	local _oButton1L, _oGroup1L, _oSayL
	local _oObj        := GetObjBrow()
	local _cCodCli     := ""
	local _cLoja       := ""
	local _cNome       := ""

	Default _cPed      := Space(len(SC5->C5_NUM))
	Default _cAt       := Space(len(SUA->UA_NUM))
	Default _cLog      := ""
	Default _cRotOri   := FunName()
	Default _cObsEsp   := ""

	private _cRotina   := "RFATL001"
	private _cAlias    := "SZL"
	private _aSavLGer  := GetArea()
	private _aSavLSUA  := SUA->(GetArea())
	private _aSavLSUB  := SUB->(GetArea())
	private _aSavLSC5  := SC5->(GetArea())
	private _aSavLSC6  := SC6->(GetArea())
	private _aSavLSC9  := SC9->(GetArea())
	private _aSavLSF2  := SF2->(GetArea())
	private _aSavLSD2  := SD2->(GetArea())
	private _aSavLSE1  := SE1->(GetArea())
	private _aSavLDAI  := DAI->(GetArea())
	private _aSavLDAK  := DAK->(GetArea())
	private _aSavLLOG  := {}
	private _aAux1L    := {}
	private _cPedido   := _cPed
	private _cAtend    := IIF(Empty(_cAt) .AND. !Empty(_cPed), POSICIONE('SUA',8,xFilial('SUA')+SUA->UA_NUMSC5,'UA_NUM'), _cAt)
	private _lAtuSC5   := .F.
	private _lAtuSUA   := .F.

	dbSelectArea(_cAlias)
	_aSavLLOG  := (_cAlias)->(GetArea())
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	_lAtuSC5 := SC5->(dbSeek(xFilial("SC5") + _cPedido))
	dbSelectArea("SUA")
	if _lAtuSC5
		_cCodCli    := SC5->C5_CLIENTE
		_cLoja      := SC5->C5_LOJACLI
		_cNome      := SC5->C5_NOMCLI
		SUA->(dbOrderNickName("UA_NUMSC5"))
		if _lAtuSUA := SUA->(dbSeek(xFilial("SUA") + SC5->C5_NUM))
			_cAtend := SUA->UA_NUM
		else
			_cAtend := ""
		endif
	else
		SUA->(dbSetOrder(1))
		if _lAtuSUA := SUA->(dbSeek(xFilial("SUA") + _cAtend))
			_cCodCli     := SUA->UA_CLIENTE
			_cLoja       := SUA->UA_LOJA
			_cNome       := SUA->UA_NOMECLI
			if !Empty(SUA->UA_NUMSC5)
				_cPedido := SUA->UA_NUMSC5
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				if _lAtuSC5 := SC5->(dbSeek(xFilial("SC5") + _cPedido))
					_cCodCli    := SC5->C5_CLIENTE
					_cLoja      := SC5->C5_LOJACLI
					_cNome      := SC5->C5_NOMCLI
				endif
			else
				_cPedido := ""
			endif
		endif	
	endif
	if (_lAtuSC5 .OR. _lAtuSUA) .AND. !Empty(_cLog)
		if !GravaLogPV(_cLog,_cRotOri,_cObsEsp)
			MsgStop("Atenção! Falha na gravação do Log. Contate o administrador do sistema!",_cRotina+"_001")
		endif
	elseif (_lAtuSC5 .OR. _lAtuSUA) .AND. (!Empty(_cPedido) .OR. !Empty(_cAtend))
		dbSelectArea(_cAlias)
		(_cAlias)->(dbSetOrder(1))
		(_cAlias)->(dbGoTop())

		static _oDlgL
		DEFINE MSDIALOG _oDlgL TITLE "["+_cRotina+"] Log de Interações no Pedido de Vendas"           												FROM 000,000 TO 555,0950         COLORS 0, 16777215          PIXEL
			@ 003, 003 GROUP  _oGroup1L  TO 272, 472 PROMPT " LOGS  "                                                          						OF _oDlgL COLOR  0, 16777215          PIXEL
			@ 020, 010 SAY    _oSayL                 PROMPT "PEDIDO: " + _cPedido + "  -  ATENDIMENTO: " + _cAtend    									SIZE 200, 007 OF _oDlgL COLORS 0, 16777215          PIXEL
			@ 030, 010 SAY    _oSayL                 PROMPT "CÓDIGO: " + _cCodCli + "  -  LOJA: " + _cLoja + "  -  NOME CLIENTE: " + _cNome  			SIZE 200, 007 OF _oDlgL COLORS 0, 16777215          PIXEL
//			@ 017, 430 BUTTON _oButton1L             PROMPT "&Sair"  ACTION EVAL({|| _cOper := "", Close(_oDlgL)}) 										SIZE 037, 012 OF _oDlgL                             PIXEL
			@ 017, 430 BUTTON _oButton1L             PROMPT "&Sair"  ACTION Close(_oDlgL) 																SIZE 037, 012 OF _oDlgL                             PIXEL
			fMSNewGe1()
		ACTIVATE MSDIALOG _oDlgL CENTERED
	else
		MsgStop("Sem log a apresentar!",_cRotina+"_002")
	endif
	RestArea(_aSavLSUA)
	RestArea(_aSavLSUB)
	RestArea(_aSavLSC5)
	RestArea(_aSavLSC6)
	RestArea(_aSavLSC9)
	RestArea(_aSavLSF2)
	RestArea(_aSavLSD2)
	RestArea(_aSavLSE1)
	RestArea(_aSavLDAI)
	RestArea(_aSavLDAK)
	RestArea(_aSavLLOG)
	RestArea(_aSavLGer)
	if Type("_oObj")=="O"
		_oObj:Default()
		_oObj:Refresh()
	endif
return
/*/{Protheus.doc} GravaLogPV
@description Gravação do Log na tabela específica.
@obs Rotina principal: RFATL001
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/11/2016
@version 1.0
@param _cLog   , caracter, Log a ser gravado ou gerado (tamanho máximo de 250 caracteres)
@param _cRotOri, caracter, Nome da rotina que chamou a função (normalmente obtida pela variável _cRotina)
@param _cObsEsp, caracter, Observações adicionais/extendida a respeito do log a ser gravado (campo MEMO)
@type function
@see https://allss.com.br
/*/
static function GravaLogPV(_cLog,_cRotOri,_cObsEsp)
	local   _aCpEsp := {}
	local   _cCpo   := ""
	local   _nPCEsp := 0
	local   _lRet   := .F.

	private _x      := 0
	private _aStru  := (_cAlias)->(dbStruct())

	if valtype(_aStru)=="A" .AND. len(_aStru) > 0
		if Type(_cCpo := _cAlias+"->"+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_NUM"    )<>"U" .AND. _lAtuSC5
			AADD(_aCpEsp, {_cCpo, _cPedido/*SC5->C5_NUM*/})
		endif
		if Type(_cCpo := _cAlias+"->"+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_ATEND"  )<>"U" .AND. _lAtuSUA
			AADD(_aCpEsp, {_cCpo, _cAtend/*SUA->UA_NUM*/})
		endif
		if Type(_cCpo := _cAlias+"->"+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_LOG"    )<>"U" .AND. !Empty(_cLog)
			AADD(_aCpEsp, {_cCpo, _cLog})
		endif
		if Type(_cCpo := _cAlias+"->"+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_ALIAS"  )<>"U" .AND. !Empty(_aSavLGer[01])
			AADD(_aCpEsp, {_cCpo, _aSavLGer[01]})
		endif
		if Type(_cCpo := _cAlias+"->"+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_INDICE" )<>"U"
			AADD(_aCpEsp, {_cCpo, _aSavLGer[02]})
		endif
		if Type(_cCpo := _cAlias+"->"+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_RECNO"  )<>"U"
			AADD(_aCpEsp, {_cCpo, cValToChar(_aSavLGer[03])})
		endif
		if Type(_cCpo := _cAlias+"->"+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_PE"     )<>"U" .AND. !Empty(_cRotOri)
			AADD(_aCpEsp, {_cCpo, _cRotOri})
		endif
		if Type(_cCpo := _cAlias+"->"+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_OBS"    )<>"U" .AND. !Empty(_cObsEsp)
			AADD(_aCpEsp, {_cCpo, _cObsEsp})
		endif
		if Type(_cCpo := _cAlias+"->"+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_NOMEUSR")<>"U" .AND. (_cAlias)->(FieldPos(IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_NOMEUSR")) > 0
			PswOrder(1)
			if PswSeek( __cUserId, .T. )   
				AADD(_aCpEsp, {_cCpo, PswRet()[1][4]})		//Nome completo do usuário
			endif
		endif
		dbSelectArea(_cAlias)
		(_cAlias)->(dbSetOrder(1))
		_xTYPE := "Type(_cAlias+'->'+_aStru[_x][01])"
		if _lRet   := RecLock(_cAlias,.T.)
			for _x := 1 To len(_aStru)
				if "_"$_aStru[_x][01] .AND. &(_xTYPE) <> "U"
					if (_nPCEsp := aScan(_aCpEsp,{|x| AllTrim(x[01]) == AllTrim(_cAlias+"->"+_aStru[_x][01])})) > 0
						&(_aCpEsp[_nPCEsp][01])        := _aCpEsp[_nPCEsp][02]
					else
						&(_cAlias+"->"+_aStru[_x][01]) := CriaVar(_aStru[_x][01])
					endif
				endif
			next
		endif
		(_cAlias)->(MSUNLOCK())
	endif
return _lRet
/*/{Protheus.doc} fMSNewGe1
@description Montagem da GetDados 1.
@obs Rotina principal: RFATL001
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/11/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
static function fMSNewGe1()
Local _aColsExL      := {}
Local _aHeaderExL    := {}
Local _aFieldFillL   := {}
Local _aAlterFieldsL := {}
Local _cAliasSX3     := ""

Static _oMSNewGe1L

_cAliasSX3 := "SX3"

if Select(_cAliasSX3) > 0
	(_cAliasSX3)->(dbCloseArea())
endif

OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)

dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(1))
(_cAliasSX3)->(MsSeek(_cAlias))
while !(_cAliasSX3)->(EOF()) .AND. AllTrim((_cAliasSX3)->X3_ARQUIVO) == _cAlias
	if cNivel >= (_cAliasSX3)->X3_NIVEL //após alguma atulização recente de dicionario (27/08/2019) o campo USADO mudou.
		Aadd(_aHeaderExL, {AllTrim(X3TITULO()),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
							(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
		Aadd(_aFieldFillL, CriaVar((_cAliasSX3)->X3_CAMPO))
	endif
	dbSelectArea(_cAliasSX3)
	(_cAliasSX3)->(dbSetOrder(1))
	(_cAliasSX3)->(dbSkip())
enddo
Aadd(_aFieldFillL, .F.)
Aadd(_aColsExL, _aFieldFillL)


_aAux1L     := aClone(_aColsExL)
_oMSNewGe1L := MsNewGetDados():New( 060, 007, 274, 467, /*GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", _aAlterFieldsL,, 999, "AllwaysTrue", "", "AllwaysTrue", _oDlgL, _aHeaderExL, _aColsExL)


AtuGet1()
if Select(_cAliasSX3) > 0
	(_cAliasSX3)->(dbCloseArea())
endif

return/*/{Protheus.doc} AtuGet1
@description Funcao de atualização do Get Dados 1.
@obs Rotina principal: RFATL001
@author Anderson C. P. Coelho (ALL System Solutions)
@since 16/11/2016
@version 1.0
@type function
@see https://allss.com.br
/*/*/
static function AtuGet1()
	local _x        := 0//
//	local _nPos     := 0
	local _cQry     := ""
	local _cTABLOG  := GetNextAlias()

	_oMSNewGe1L:aCols := {}

	_cQry := " SELECT TABLOG.R_E_C_N_O_ RECLOG " + _CLRF
	_cQry += " FROM " + RetSqlName(_cAlias) + " TABLOG (NOLOCK) " + _CLRF
	_cQry += " WHERE TABLOG."+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_FILIAL = '" + xFilial(_cAlias) + "' " + _CLRF
	_cQry += "  AND ( " + _CLRF
	if !Empty(_cPedido)
		_cQry += " 			TABLOG."+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_NUM = '" + _cPedido + "' " + _CLRF
	endif
	if !Empty(_cPedido) .AND. !Empty(_cAtend)
		_cQry += " 		OR	" + _CLRF
	endif
	if !Empty(_cAtend)
		_cQry += "  		TABLOG."+IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_ATEND = '" + _cAtend + "' " + _CLRF
	endif
	_cQry += "       ) " + _CLRF
	_cQry += "  AND TABLOG.D_E_L_E_T_ = '' " + _CLRF
	_cQry += " ORDER BY " + StrTran(StrTran(SZL->(IndexKey(1)),"+",","),"DTOS(ZL_DATA)","ZL_DATA") + _CLRF
	//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.txt",_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cTABLOG,.F.,.F.)
	TCSETFIELD(_cTABLOG,IIF(Substr(_cAlias,1,1)=="S",SubStr(_cAlias,2,2),_cAlias)+"_DATA","D",08,0)
	dbSelectArea(_cTABLOG)
	if !(_cTABLOG)->(EOF())
		while !(_cTABLOG)->(EOF())
			dbSelectArea(_cAlias)
			(_cAlias)->(dbGoTo((_cTABLOG)->RECLOG))
			_aCpos1 := {}
			for _x := 1 To Len(_oMSNewGe1L:aHeader)
				AADD(_aCpos1,&(_cAlias+"->"+_oMSNewGe1L:aHeader[_x][02]))
			next
			AADD(_aCpos1,.F.)
			AADD(_oMSNewGe1L:aCols,_aCpos1)
			dbSelectArea(_cTABLOG)
			(_cTABLOG)->(dbSkip())
		enddo
	endif
	dbSelectArea(_cTABLOG)
	(_cTABLOG)->(dbCloseArea())
	if Empty(_oMSNewGe1L:aCols)
		_oMSNewGe1L:aCols := aClone(_aAux1L)
	endif
	_oMSNewGe1L:Refresh()
return .T.