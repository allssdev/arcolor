#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _lEnt CHR(13) + CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณOM200CAR  บAutor  ณAnderson C. P. Coelho บ Data ณ  17/10/13 บฑฑ
ฑฑบ          ณOM200CAR  บAutor  ณJ๚lio Soares          บ Data ณ  17/10/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.TOTVSณ Ponto de entrada depois das condi็๕es principais de filtro บฑฑ
ฑฑบ          ณ dos pedidos na montagem de carga utilizando Top Connect    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณ Este ponto estแ sendo utilizado para remontar a query para บฑฑ
ฑฑบ          ณ confronto com o que foi marcado na rotina de Montagem de   บฑฑ
ฑฑบ          ณ Cargas.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especifico para a empresa Arcolor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//Conte๚do do PARAMIXB
//ParamIXB[1] - Expressใo da query a ser executada no banco.
user function OM200CAR()
	Local _aSavArea := GetArea()
	Local _cRotina  := "OM200CAR"
	Local nTipoOper := OsVlEntCom()
	Local _cQuery   := PARAMIXB[1] 
	//Elimino os espa็os da query, para depois filtrar melhor o n๚mero do pedido de vendas.
	//Local _cAT      := StrTran(_cQuery," ","")				//	Local _cAT      := AllTrim(SubStr(UPPER(_cQuery),AT("C9_PEDIDO =",UPPER(_cQuery)),AT("AND C9_BLCRED",UPPER(_cQuery))-AT("C9_PEDIDO =",UPPER(_cQuery))))
	MemoWrite("\2.MemoWrite\oms\"+_cRotina+"_QRY_ORIGINAL_001.TXT",_cQuery)
	//Colho o n๚mero do pedido de vendas que serแ filtrado na query
	/* _aparamx
	if "C5_NUM="$_cAT
		//_cAT  :=  SubStr(_cAT,AT("C5_NUM='"   ,_cAT)+07,TamSx3("C9_PEDIDO")[01]) 
		_cAT  :=  SubStr(_cAT,AT("C5_NUM="   ,_cAT)+07,14) 
	elseIf "C9_PEDIDO='"$_cAT
		//_cAT  :=  SubStr(_cAT,AT("C9_PEDIDO=",_cAT)+10,TamSx3("C9_PEDIDO")[01]) 
		_cAT  :=  SubStr(_cAT,AT("C9_PEDIDO=",_cAT)+10,14) 
	else
		MsgStop("Aten็ใo! Houveram mudan็as estruturais que culminam em problemas com esta rotina. Informe imediatamente o administrador do sistema para anแlise e atua็ใo!",_cRotina+"_001")
		_cAT  := ""
	endif
	*/
	//Monto a query
	_cQry := " SELECT SC9.*,SC9.R_E_C_N_O_ RECSC9 , SC5.R_E_C_N_O_ RECSC5 , SC5.C5_NUM"  +_lEnt
	_cQry += ",TMP.PED_SEQROT, TMP.PED_ROTA, TMP.PED_FILORI, TMP.PED_PEDIDO, TMP.PED_CODCLI, TMP.PED_LOJA"  +_lEnt
	_cQry += " FROM "+RetSqlName('SC9')+" SC9 (NOLOCK) "  +_lEnt
	_cQry += " 	INNER JOIN "+ ALLTRIM(substr(_cquery,at('##',_cquery),at(' TMP ',_cquery)-at('##',_cquery))) +" TMP ON TMP.PED_MARCA <> '' AND TMP.D_E_L_E_T_ = '' AND TMP.PED_PEDIDO = SC9.C9_PEDIDO	" +_lEnt
	_cQry += " 	INNER JOIN (SELECT C9SEQ.C9_FILIAL, C9SEQ.C9_PEDIDO, C9SEQ.C9_DTEMISS, MIN(C9_SEQUEN) [C9_SEQUEN], C9SEQ.C9_ORDSEP " +_lEnt
	_cQry += " 				FROM (SELECT DISTINCT C9_FILIAL, C9_PEDIDO, C9_SEQUEN, C9_DTEMISS, C9_ORDSEP " +_lEnt
	_cQry += " 					  FROM "+RetSqlName('SC9')+" SC9X (NOLOCK) " +_lEnt
	_cQry += " 					  WHERE SC9X.D_E_L_E_T_ = '' " +_lEnt
	_cQry += " 					  AND SC9X.C9_FILIAL    = '" + xFilial("SC9") + "' " +_lEnt
	_cQry += " 					  AND Exists (SELECT TOP 1 1 FROM "+ ALLTRIM(substr(_cquery,at('##',_cquery),at(' TMP ',_cquery)-at('##',_cquery))) +" XXX WHERE XXX.PED_MARCA <> '' AND XXX.PED_PEDIDO = SC9X.C9_PEDIDO AND XXX.D_E_L_E_T_ = '') " +_lEnt
	//_cQry += " 					  AND SC9X.C9_PEDIDO    = '" + TRBPED->PED_PEDIDO + "' " +_lEnt
	/*
	if !empty(_cAT)
		//_cQry += "                    AND SC9X.C9_PEDIDO ='363501'" + _lEnt
		_cQry += "                    AND SC9X.C9_PEDIDO = '"+  _cAT + "'" + _lEnt
	EndIf
	*/
	_cQry += " 					  AND SC9X.C9_DTEMISS   > '"+DTOS(dDataBase-365)+"' " + _lEnt
	_cQry += " 					  GROUP BY C9_FILIAL, C9_PEDIDO, C9_SEQUEN, C9_DTEMISS, C9_ORDSEP " +_lEnt
	_cQry += " 					  ) C9SEQ " +_lEnt
	_cQry += " 				GROUP BY C9SEQ.C9_FILIAL, C9SEQ.C9_DTEMISS, C9SEQ.C9_PEDIDO, C9SEQ.C9_ORDSEP) C9AUX " +_lEnt
	_cQry += " 	ON SC9.C9_PEDIDO   = C9AUX.C9_PEDIDO  " +_lEnt
	_cQry += " 	AND SC9.C9_SEQUEN  = C9AUX.C9_SEQUEN  " +_lEnt
	_cQry += " 	AND SC9.C9_ORDSEP  = C9AUX.C9_ORDSEP  " +_lEnt
	_cQry += " 	AND SC9.C9_DTEMISS = C9AUX.C9_DTEMISS " +_lEnt
	_cQry += " 	INNER JOIN " + RetSqlName('SC5') + " SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' " +_lEnt
	_cQry += " 		AND SC5.C5_FILIAL  = SC9.C9_FILIAL  " +_lEnt
	_cQry += " 		AND SC5.C5_NUM     = SC9.C9_PEDIDO  " +_lEnt
	_cQry += " WHERE SC9.D_E_L_E_T_              = '' " +_lEnt
	If	nTipoOper == 1
		_cQry += "  AND SC9.C9_FILIAL            = '" + xFilial("SC9")                              + "' " +_lEnt
	Else
		_cQry += "  AND SC9.C9_FILIAL      BETWEEN '" + mv_par09       + "' AND '" + mv_par10       + "' " +_lEnt
	EndIf
	_cQry += "      AND SC9.C9_CARGA             = '" + Space(Len(SC9->C9_CARGA ))                  + "' " +_lEnt
	_cQry += "      AND SC9.C9_SEQCAR            = '" + Space(Len(SC9->C9_SEQCAR))                  + "' " +_lEnt
	/*
	if !empty(_cAT)
		//_cQry += "      AND SC9.C9_PEDIDO = '363501'" + _lEnt
		_cQry += "      AND SC9.C9_PEDIDO =  '"+ _cAT + "'" + _lEnt
	EndIf
	*/
	//_cQry += "      AND SC9.C9_PEDIDO    = '" + TRBPED->PED_PEDIDO      + "' " +_lEnt
	_cQry += "      AND SC9.C9_PEDIDO      BETWEEN '" + mv_par01      + "' AND '" + mv_par02       + "' " +_lEnt
	_cQry += "      AND SC9.C9_ENDPAD      BETWEEN '" + mv_par07       + "' AND '" + mv_par08       + "' " +_lEnt
	_cQry += "      AND SC9.C9_DATALIB     BETWEEN '" + Dtos(mv_par11) + "' AND '" + Dtos(mv_par12) + "' " +_lEnt
	If SC9->(FieldPos("C9_DTEMISS"))<>0 // Valida se o campo existe para evitar error.log
		_cQry += "      AND SC9.C9_DTEMISS BETWEEN '" + DTOS(mv_par23) + "' AND '" + DTOS(mv_par24) + "' " +_lEnt
	EndIf
//	_cQry += "      AND SC9.C9_BLCRED            = '10' " +_lEnt
	_cQry += "      AND SC9.C9_BLEST             = '10' " +_lEnt
	_cQry += "      AND (SC9.C9_TPCARGA          = '1' OR SC9.C9_TPCARGA = '3') " +_lEnt
//	_cQry += "      AND SC9.C9_NFISCAL          <> '' "   +_lEnt
	If cPaisLoc <> "BRA"
		_cQry += "  AND SC9.C9_REMITO            = '" + Space(Len(SC9->C9_REMITO)) + "' " +_lEnt
	EndIf
	_cQry += "ORDER BY   TMP.PED_SEQROT,TMP.PED_ROTA,TMP.PED_FILORI,TMP.PED_PEDIDO,SC9.C9_ITEM"
	MemoWrite("\2.MemoWrite\oms\"+_cRotina+"_QRY_002.TXT",_cQry)
	RestArea(_aSavArea)
return _cQry
