#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH
#INCLUDE "SHELL.CH

#DEFINE _CRLF CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATE058 ºAutor  ³ Júlio Soares       º Data ³  21/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina utilizada para a atualizacao dos campos de Média de º±±
±±º          ³ Compras (A1_MEDCOMP) e Média de Faturamento (A1_MEDFATR) noº±±
±±º          ³ cadastro de clientes.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico empresa Arcolor.                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE067(_cLog)
Local _aSavArea := GetArea()
Local _cRotina  := "RFATE067"
Local _aSavArea := {}
Local _dData    := STOD("")//dDataBase
Local _cTpOp    := ""//SuperGetMv("MV_FATOPER",,"") // Informa os tipos de operacao validos para constar no relatorio de faturamento.
Local _lCnt     := .F.
Local _lAuth    := .F.
Local _cQry5 := ""
Local _cQry6 := ""
Local _cQry7 := ""
Local _cQry8 := ""

_lAuth := Type("CFILANT")=="U"
If _lAuth
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME _cRotina
EndIf

_aSavArea := GetArea()
_dData    := dDataBase
_cTpOp    := SuperGetMv("MV_FATOPER",,"") // Informa os tipos de operacao validos para constar no relatorio de faturamento.

	_cDtDeVd := (cValToChar(Val(SubStr(DTOS(_dData),1,4))-1)+SubStr(DTOS(_dData),5,2))
	_cDtAtVd := SubStr(DTOS(_dData),1,4)+StrZero((Val(SubStr(DTOS(_dData),5,2))-1),2)

	_cQry5 := ""
	_cQry5 += " UPDATE "+RetSqlName("SA1")																			+_CRLF
	_cQry5 += " SET A1_MEDCCEN = SC6X.VALOR "																		+_CRLF
	_cQry5 += " FROM " + RetSqlName("SA1") + " SA1 "																+_CRLF
	_cQry5 += " 	INNER JOIN (SELECT A1_CGCCENT,ROUND((SUM(C6_VALOR)/12),2)[VALOR] "								+_CRLF
	_cQry5 += " 				FROM " + (RetSqlName("SC6")) + " SC6 "												+_CRLF
	_cQry5 += " 					INNER JOIN " + RetSqlName("SC5") + " SC5 "										+_CRLF
	_cQry5 += " 						ON  SC5.C5_FILIAL  = '"+xFilial("SC5")+"' "									+_CRLF	
	_cQry5 += " 						AND SC5.C5_CLIENT  = SC6.C6_CLI "											+_CRLF
	_cQry5 += " 						AND SC5.C5_LOJACLI = SC6.C6_LOJA "											+_CRLF
	_cQry5 += " 						AND SC5.C5_NUM     = SC6.C6_NUM "											+_CRLF
	_cQry5 += " 						AND SC5.C5_TPOPER IN "+FormatIn(_cTpOp,"|")									+_CRLF
	_cQry5 += " 						AND SC5.D_E_L_E_T_ = '' "													+_CRLF
	_cQry5 += " 					INNER JOIN " + RetSqlName("SA1") + " XSA1 "										+_CRLF
	_cQry5 += " 						ON  XSA1.A1_FILIAL  = '"+xFilial("SA1")+"' "								+_CRLF	
    _cQry5 += " 						AND XSA1.A1_COD    = SC6.C6_CLI "											+_CRLF
	_cQry5 += " 						AND XSA1.A1_LOJA   = SC6.C6_LOJA "											+_CRLF								+_CRLF
	_cQry5 += "  				WHERE SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "									+_CRLF
 	_cQry5 += "  				  AND SUBSTRING(SC5.C5_EMISSAO,1,6) BETWEEN '"+(_cDtDeVd)+"' AND '"+(_cDtAtVd)+"'"	+_CRLF
	_cQry5 += "  				  AND SC6.D_E_L_E_T_ = '' "															+_CRLF
	_cQry5 += "  				GROUP BY XSA1.A1_CGCCENT "															+_CRLF
	_cQry5 += "  				) SC6X ON SA1.A1_CGCCENT    = SC6X.A1_CGCCENT "										+_CRLF
	_cQry5 += " WHERE SA1.A1_FILIAL  = '"+ xFilial("SA1")+"' "														+_CRLF
	_cQry5 += "   AND SA1.D_E_L_E_T_ = '' "																			 +_CRLF
 
	If TCSQLExec(_cQry5) ==0
		_cLog:= "_cQry5" +_CRLF
		_cLog+= _cQry5  +_CRLF
	EndIf

	_cDtDeFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-1)+SubStr(DTOS(_dData),5,2)
	_cDtAtFt := SubStr(DtoS(_dData),1,4)+StrZero((Val(SubStr(DTOS(_dData),5,2))-1),2)
 
    _cQry6 := ""
    _cQry6 += " UPDATE "+RetSqlName("SA1")																			+_CRLF
    _cQry6 += " SET A1_MEDFCEN = SC6X.VALOR "																		+_CRLF
    _cQry6 += " FROM "+RetSqlName("SA1")+" SA1 "																	+_CRLF
    _cQry6 += "		INNER JOIN (SELECT A1_CGCCENT,ROUND((SUM(D2_TOTAL)/12),2)[VALOR] "						+_CRLF
    _cQry6 += "					FROM "+RetSqlName("SD2")+" SD2 "													+_CRLF
    _cQry6 += "					     INNER JOIN "+RetSqlName("SF4")+" SF4 "											+_CRLF
	_cQry6 += "					     ON SF4.F4_FILIAL  = '"+xFilial("SF4")+"' "										+_CRLF
    _cQry6 += "					     AND SF4.F4_DUPLIC  = 'S' "														+_CRLF
    _cQry6 += "					     AND SF4.F4_CODIGO  = SD2.D2_TES "												+_CRLF
    _cQry6 += "					     AND SF4.D_E_L_E_T_ = '' "														+_CRLF
    _cQry6 += "	  			 INNER JOIN SA1010 XSA1 ON SD2.D2_CLIENTE = XSA1.A1_COD AND SD2.D2_LOJA = XSA1.A1_LOJA	 and XSA1.D_E_L_E_T_ = '' " +_CRLF									
    _cQry6 += "					WHERE SD2.D2_FILIAL   = '" + xFilial("SD2") + "' "									+_CRLF
    _cQry6 += "					  AND SUBSTRING(SD2.D2_EMISSAO,1,6)  BETWEEN '"+(_cDtDeFt)+"' AND '"+(_cDtAtFt)+"' "+_CRLF
    _cQry6 += "					  AND SD2.D2_TIPO     = 'N' "														+_CRLF
    _cQry6 += "					  AND SD2.D2_TIPOPER IN "+FormatIn(_cTpOp,"|")										+_CRLF
    _cQry6 += "					  AND SD2.D_E_L_E_T_  = '' "														+_CRLF
    _cQry6 += "					GROUP BY A1_CGCCENT "														+_CRLF
    _cQry6 += "					)SC6X  ON SA1.A1_CGCCENT    = SC6X.A1_CGCCENT"											+_CRLF
    _cQry6 += "	WHERE SA1.A1_FILIAL  = '"+xFilial("SA1")+"' "														+_CRLF
    _cQry6 += "	  AND SA1.D_E_L_E_T_ = '' "																			+_CRLF
	If TCSQLExec(_cQry6) ==0
		_cLog+= "_cQry6" +	_CRLF
		_cLog+= _cQry6   +	_CRLF
	EndIf

	If SA1->(FieldPos("A1_MEDFCEA")) > 0
		_cDtDeFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-2)+SubStr(DTOS(_dData),5,2)
		_cDtAtFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-1)+StrZero((Val(SubStr(DTOS(_dData),5,2))-1),2)
	    _cQry7 := " UPDATE SA1 "																						+_CRLF
	    _cQry7 += " SET A1_MEDFCEA = SC6X.VALOR "																		+_CRLF
	    _cQry7+= " FROM "+RetSqlName("SA1")+" SA1 "																	+_CRLF
	    _cQry7 += "		INNER JOIN (SELECT A1_CGCCENT,ROUND((SUM(D2_TOTAL)/12),2)[VALOR] "						+_CRLF
	    _cQry7 += "					FROM "+RetSqlName("SD2")+" SD2 "													+_CRLF
	    _cQry7 += "					     INNER JOIN "+RetSqlName("SF4")+" SF4 "											+_CRLF
		_cQry7 += "					     ON SF4.F4_FILIAL  = '"+xFilial("SF4")+"' "										+_CRLF
	    _cQry7 += "					     AND SF4.F4_DUPLIC  = 'S' "														+_CRLF
	    _cQry7 += "					     AND SF4.F4_CODIGO  = SD2.D2_TES "												+_CRLF
	    _cQry7 += "					     AND SF4.D_E_L_E_T_ = '' "														+_CRLF
	    _cQry7 += "	  			 INNER JOIN SA1010 XSA1 ON SD2.D2_CLIENTE = XSA1.A1_COD AND SD2.D2_LOJA = XSA1.A1_LOJA	 and XSA1.D_E_L_E_T_ = '' " +_CRLF										
	    _cQry7 += "					WHERE SD2.D2_FILIAL   = '" + xFilial("SD2") + "' "									+_CRLF
	    _cQry7 += "					  AND SUBSTRING(SD2.D2_EMISSAO,1,6)  BETWEEN '"+(_cDtDeFt)+"' AND '"+(_cDtAtFt)+"' "+_CRLF
	    _cQry7 += "					  AND SD2.D2_TIPO     = 'N' "														+_CRLF
	    _cQry7 += "					  AND SD2.D2_TIPOPER IN "+FormatIn(_cTpOp,"|")										+_CRLF
	    _cQry7 += "					  AND SD2.D_E_L_E_T_  = '' "														+_CRLF
	    _cQry7 += "					GROUP BY A1_CGCCENT "														+_CRLF
	    _cQry7 += "					)SC6X  ON SA1.A1_CGCCENT    = SC6X.A1_CGCCENT"											+_CRLF
	    _cQry7 += "	WHERE SA1.A1_FILIAL  = '"+xFilial("SA1")+"' "														+_CRLF
	    _cQry7 += "	  AND SA1.D_E_L_E_T_ = '' "																			+_CRLF
		If TCSQLExec(_cQry7)==0
			_cLog+= "_cQry7: " +_CRLF
			_cLog+= _cQry7   +_CRLF
		EndIf
	EndIf
	If SA1->(FieldPos("A1_VARCEN")) > 0
		_cDtDeFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-2)+SubStr(DTOS(_dData),5,2)
		_cDtAtFt := cValToChar(Val(SubStr(DTOS(_dData),1,4))-1)+StrZero((Val(SubStr(DTOS(_dData),5,2))-1),2)
	   
	    _cQry8 := " UPDATE "+RetSqlName("SA1")																		+_CRLF
	    _cQry8 += " SET A1_VARCEN = (CASE WHEN A1_MEDFCEN <> 0 and A1_MEDFCEA <> 0 THEN ROUND(((A1_MEDFCEN/A1_MEDFCEA)-1)*100,"+cValToChar(TamSx3("A1_VARCEN")[02])+") ELSE 0 END) "+_CRLF
	    _cQry8 += "	WHERE A1_FILIAL  = '"+xFilial("SA1")+"' "														+_CRLF
	    _cQry8 += "	  AND D_E_L_E_T_ = '' "																			+_CRLF
		
		If TCSQLExec(_cQry8)==0
			_cLog+= "_cQry8: " +_CRLF
			_cLog+= _cQry8   +_CRLF
		EndIf
	EndIf

If _lAuth
	RESET ENVIRONMENT
EndIf
RestArea(_aSavArea)
Return(_cLog)
