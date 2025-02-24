#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH
#INCLUDE "SHELL.CH

#DEFINE _CRLF CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFATE058 บAutor  ณ J๚lio Soares       บ Data ณ  21/09/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina utilizada para a atualizacao dos campos de M้dia de บฑฑ
ฑฑบ          ณ Compras (A1_MEDCOMP) e M้dia de Faturamento (A1_MEDFATR) noบฑฑ
ฑฑบ          ณ cadastro de clientes.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico empresa Arcolor.                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFATE058()
Local _aSavArea := {}
Local _cRotina  := "RFATE058"
Local _dData    := STOD("")//dDataBase
Local _cAtu     := ""//SuperGetMv("MV_MEDCOMP",,"") // Esse parametro grava a data da ultima atualizacao das medias de vendas. NAO ALTERAR MANUALMENTE.
Local _cTpOp    := ""//SuperGetMv("MV_FATOPER",,"") // Informa os tipos de operacao validos para constar no relatorio de faturamento.
Local _lCnt     := .F.
Local _lAuth    := .F.

Local _cQry1 := ""
Local _cQry2 := ""
Local _cQry3 := ""
Local _cQry4 := ""

Private _cLog := "erro"


_lAuth := Type("CFILANT")=="U"
If _lAuth
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina
EndIf

_aSavArea := GetArea()
_dData    := dDataBase
_cAtu     := SuperGetMv("MV_MEDCOMP",,"") // Esse parametro grava a data da ultima atualizacao das medias de vendas. NAO ALTERAR MANUALMENTE.
_cTpOp    := SuperGetMv("MV_FATOPER",,"") // Informa os tipos de operacao validos para constar no relatorio de faturamento.

If !Empty(_cAtu) .AND. _cAtu < (Substring(DtoS(_dData),1,6))
	_cDtDeVd := (cValToChar(Val(SubStr(DTOS(_dData),1,4))-1)+SubStr(DTOS(_dData),5,2))
	_cDtAtVd := SubStr(DTOS(_dData),1,4)+StrZero((Val(SubStr(DTOS(_dData),5,2))-1),2)
	// REALIZA ATUALIZAวรO PARA VENDAS
	_cQry1 := ""
	_cQry1 += " UPDATE SA1 "																						+_CRLF
	_cQry1 += " SET A1_MEDCOMP = SC6X.VALOR "																		+_CRLF
	_cQry1 += " FROM " + RetSqlName("SA1") + " SA1 WITH (NOLOCK) "													+_CRLF
	_cQry1 += " 	INNER JOIN (SELECT C6_CLI,C6_LOJA,ROUND((SUM(C6_VALOR)/12),2)[VALOR] "							+_CRLF
	_cQry1 += " 				FROM " + RetSqlName("SC6") + " SC6 WITH (NOLOCK) "									+_CRLF
	_cQry1 += " 					INNER JOIN " + RetSqlName("SC5") + " SC5 WITH (NOLOCK) "						+_CRLF
	_cQry1 += " 						ON  SC5.C5_FILIAL  = '"+xFilial("SC5")+"' "									+_CRLF	
	_cQry1 += " 						AND SC5.C5_CLIENTE = SC6.C6_CLI "											+_CRLF
	_cQry1 += " 						AND SC5.C5_LOJACLI = SC6.C6_LOJA "											+_CRLF
	_cQry1 += " 						AND SC5.C5_NUM     = SC6.C6_NUM "											+_CRLF
	_cQry1 += " 						AND SC5.C5_TPOPER IN "+FormatIn(_cTpOp,"|")									+_CRLF
	_cQry1 += " 						AND SC5.D_E_L_E_T_ = '' "													+_CRLF
	_cQry1 += "  				WHERE SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "									+_CRLF
 	_cQry1 += "  				  AND SUBSTRING(SC6.C6_EMISSAO,1,6) BETWEEN '"+(_cDtDeVd)+"' AND '"+(_cDtAtVd)+"'"	+_CRLF
	_cQry1 += "  				  AND SC6.D_E_L_E_T_ = '' "															+_CRLF
	_cQry1 += "  				GROUP BY C6_CLI,C6_LOJA "															+_CRLF
	_cQry1 += "  				) SC6X ON SA1.A1_COD    = SC6X.C6_CLI "												+_CRLF
	_cQry1 += "                       AND SA1.A1_LOJA   = SC6X.C6_LOJA "											+_CRLF
	_cQry1 += " WHERE SA1.A1_FILIAL  = '"+xFilial("SA1")+"' "														+_CRLF
	_cQry1 += "   AND SA1.D_E_L_E_T_ = '' "																+_CRLF
	_cLog:=  "_cQry1: " +_CRLF
	_cLog+=  _cQry1 +_CRLF 
	If TCSQLExec(_cQry1) == 0
		_lCnt := .T.
	EndIf
	If SA1->(FieldPos("A1_MEDFATR")) > 0
		_cDtDeFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-1)+SubStr(DTOS(_dData),5,2)
		_cDtAtFt := SubStr(DtoS(_dData),1,4)+StrZero((Val(SubStr(DTOS(_dData),5,2))-1),2)
	    _cQry2 := " UPDATE SA1 "																						+_CRLF
	    _cQry2 += " SET A1_MEDFATR = SC6X.VALOR "																		+_CRLF
	    _cQry2 += " FROM "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) "														+_CRLF
	    _cQry2 += "		INNER JOIN (SELECT D2_CLIENTE,D2_LOJA,ROUND((SUM(D2_TOTAL)/12),2)[VALOR] "						+_CRLF
	    _cQry2 += "					FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "										+_CRLF
	    _cQry2 += "					     INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) "							+_CRLF
		_cQry2 += "					     ON SF4.F4_FILIAL  = '"+xFilial("SF4")+"' "										+_CRLF
	    _cQry2 += "					     AND SF4.F4_DUPLIC  = 'S' "														+_CRLF
	    _cQry2 += "					     AND SF4.F4_CODIGO  = SD2.D2_TES "												+_CRLF
	    _cQry2 += "					     AND SF4.D_E_L_E_T_ = '' "														+_CRLF
	    _cQry2 += "					WHERE SD2.D2_FILIAL   = '" + xFilial("SD2") + "' "									+_CRLF
	    _cQry2 += "					  AND SUBSTRING(SD2.D2_EMISSAO,1,6)  BETWEEN '"+(_cDtDeFt)+"' AND '"+(_cDtAtFt)+"' "+_CRLF
	    _cQry2 += "					  AND SD2.D2_TIPO     = 'N' "														+_CRLF
	    _cQry2 += "					  AND SD2.D2_TIPOPER IN "+FormatIn(_cTpOp,"|")										+_CRLF
	    _cQry2 += "					  AND SD2.D_E_L_E_T_  = '' "														+_CRLF
	    _cQry2 += "					GROUP BY D2_CLIENTE,D2_LOJA "														+_CRLF
	    _cQry2 += "					)SC6X ON SA1.A1_COD     = SC6X.D2_CLIENTE "											+_CRLF
	    _cQry2 += "                      AND SA1.A1_LOJA    = SC6X.D2_LOJA "											+_CRLF
	    _cQry2 += "	WHERE SA1.A1_FILIAL  = '"+xFilial("SA1")+"' "														+_CRLF
	    _cQry2 += "	  AND SA1.D_E_L_E_T_ = '' "																			+_CRLF
		_cLog+=  "_cQry2: " +_CRLF
		_cLog+=  _cQry2 +_CRLF 
		If TCSQLExec(_cQry2) == 0
			_lCnt := .T.
		EndIf
	EndIf
	If SA1->(FieldPos("A1_MEDFATA")) > 0
		_cDtDeFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-2)+SubStr(DTOS(_dData),5,2)
		_cDtAtFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-1)+StrZero((Val(SubStr(DTOS(_dData),5,2))-1),2)
	    _cQry3 := " UPDATE SA1 "																						+_CRLF
	    _cQry3 += " SET A1_MEDFATA = SC6X.VALOR "																		+_CRLF
	    _cQry3 += " FROM "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) "														+_CRLF
	    _cQry3 += "		INNER JOIN (SELECT D2_CLIENTE,D2_LOJA,ROUND((SUM(D2_TOTAL)/12),2)[VALOR] "						+_CRLF
	    _cQry3 += "					FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "										+_CRLF
	    _cQry3 += "					     INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) "							+_CRLF
		_cQry3 += "					     ON SF4.F4_FILIAL  = '"+xFilial("SF4")+"' "										+_CRLF
	    _cQry3 += "					     AND SF4.F4_DUPLIC  = 'S' "														+_CRLF
	    _cQry3 += "					     AND SF4.F4_CODIGO  = SD2.D2_TES "												+_CRLF
	    _cQry3 += "					     AND SF4.D_E_L_E_T_ = '' "														+_CRLF
	    _cQry3 += "					WHERE SD2.D2_FILIAL   = '" + xFilial("SD2") + "' "									+_CRLF
	    _cQry3 += "					  AND SUBSTRING(SD2.D2_EMISSAO,1,6)  BETWEEN '"+(_cDtDeFt)+"' AND '"+(_cDtAtFt)+"' "+_CRLF
	    _cQry3 += "					  AND SD2.D2_TIPO     = 'N' "														+_CRLF
	    _cQry3 += "					  AND SD2.D2_TIPOPER IN "+FormatIn(_cTpOp,"|")										+_CRLF
	    _cQry3 += "					  AND SD2.D_E_L_E_T_  = '' "														+_CRLF
	    _cQry3 += "					GROUP BY D2_CLIENTE,D2_LOJA "														+_CRLF
	    _cQry3 += "					)SC6X ON SA1.A1_COD     = SC6X.D2_CLIENTE "											+_CRLF
	    _cQry3 += "                      AND SA1.A1_LOJA    = SC6X.D2_LOJA "											+_CRLF
	    _cQry3 += "	WHERE SA1.A1_FILIAL  = '"+xFilial("SA1")+"' "														+_CRLF
	    _cQry3 += "	  AND SA1.D_E_L_E_T_ = '' "																			+_CRLF
		_cLog+=  "_cQry3: " +_CRLF
		_cLog+=  _cQry3 +_CRLF 
		If TCSQLExec(_cQry3)== 0
			_lCnt := .T.
		EndIf	
	EndIf
	If SA1->(FieldPos("A1_VARFAT")) > 0
		_cDtDeFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-2)+SubStr(DTOS(_dData),5,2)
		_cDtAtFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-1)+StrZero((Val(SubStr(DTOS(_dData),5,2))-1),2)
	    _cQry4 := " UPDATE "+RetSqlName("SA1")																		+_CRLF
	    _cQry4 += " SET A1_VARFAT = (CASE WHEN A1_MEDFATA <> 0 THEN ROUND(((A1_MEDFATR/A1_MEDFATA)-1)*100,"+cValToChar(TamSx3("A1_VARFAT")[02])+") ELSE 0 END) "+_CRLF
	    _cQry4 += "	WHERE A1_FILIAL  = '"+xFilial("SA1")+"' "														+_CRLF
	    _cQry4 += "	  AND D_E_L_E_T_ = '' "																			+_CRLF
		_cLog+=  "_cQry4: " +_CRLF
		_cLog+=  _cQry4 +_CRLF 
		If TCSQLExec(_cQry4) == 0
				_lCnt := .T.
		EndIf
	EndIf
    // Atualizo o parโmetro que informa a ultima data executada do recalculo.
	If _lCnt
		_cAliasSX6 := "SX6_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX6,"SX6",,.F.)
		dbSelectArea(_cAliasSX6)
		(_cAliasSX6)->(dbSetOrder(1))
		If (_cAliasSX6)->(MsSeek(xFilial(_cAliasSX6)+"MV_MEDCOMP",.T.,.F.))
			while !RecLock(_cAliasSX6,.F.) ; enddo
			(_cAliasSX6)->X6_CONTEUD := SubStr(DTOS(_dData),1,6)
			(_cAliasSX6)->(MsUnlock())
		Else
			_cLog+="O parโmetro 'MV_MEDCOMP' nใo pode ser atualizado. Informe o administrador do sistema!"+_CRLF 
		EndIf
		// M้dias do CNPJ Centralizador 
		_cLog+= U_RFATE067(_cLog)		

	Else
		_cLog+= "Houve um problema na atualiza็ao de algumas informa็๕es para o cadastro de clientes. Informe o administrador do sistema!" +_CRLF 
	EndIf
EndIf


MemoWrite("\2.MemoWrite\MEDIAS\"+ _cRotina + "_"+ dtos(_dData),_cLog)
	
If _lAuth
	RESET ENVIRONMENT
EndIf
RestArea(_aSavArea)
return
