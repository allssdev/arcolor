#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RWMAKE.CH'
/*/{Protheus.doc} RESTE009
@description Rotina de gravação do cálculo do consumo mensal
@author Lívia Della Corte (ALL System Solutions)
@since 08/10/2019
@version 1.0
@param _cProdCons, caracter, Código do Produto a ser gravado
@param _cQtd, numérico, Quantidade consumida a ser gravada
@param _cRotina, caracter, Rotina original
@param _DtMov, data, Data do consumo mensal
@param _cAnoMes, caracter, Ano e Mês do consumo mensal
@type function
@history 08/10/2019, Anderson C. P. Coelho (ALL System Solutions), Correção na gravação das datas da rotina.
@see https://allss.com.br
/*/
user function RESTE009(_cProdCons,_cQtd,_cRotina,_DtMov,_cAnoMes)
	local _aSavArea  := GetArea()
//	local   _dSvDataB  := dDataBase
	local   _cDelete := ""
	local   cUser    := ""

	private _cCampo  := ""							 //Campo a ser utilizado como macro

	default _cRotina := "RESTE009"
	default _DtMov   := dDataBase
	default _cAnoMes := StrZero(Year(_DtMov),4) + StrZero(Month(_DtMov),2)

	PswOrder(1)
	if PswSeek( __cUserId, .T. )   
		cUser:= __cUserId + " - " + PswRet()[1][4]
	endif
	_cDelete := " UPDATE " + RetSqlName("SZG") + " SET ZG_STATUS = 'N' "
	_cDelete += " WHERE D_E_L_E_T_ = '' "
	_cDelete += "   AND ZG_FILIAL  = '" + xFilial("SZG") + "' "
	_cDelete += "   AND ZG_MESANO  = '" + _cAnoMes + "' "
	_cDelete += "   AND ZG_PRODUTO	= '" + _cProdCons + "' "
	If TCSQLExec(_cDelete) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_002")
	EndIf
	dbSelectArea("SZG") //Consumo mensal (específico)
	while !RecLock("SZG",.T.) ; enddo
		SZG->ZG_FILIAL  := xFilial("SZG")
		SZG->ZG_SEQUENC	:= GetSx8Num("SZG","ZG_SEQUENC")
		SZG->ZG_PRODUTO	:= _cProdCons
		SZG->ZG_MESANO	:= _cAnoMes
		SZG->ZG_QUANTID	:= _cQtd
		SZG->ZG_EMISSAO	:= Date()						//_DtMov
		SZG->ZG_USUARIO := __cUserId + " - " + cUserName
		SZG->ZG_ROTINA  := _cRotina
		SZG->ZG_STATUS := "S"
	SZG->(MsUnLock())
	RestArea(_aSavArea)
return .T.