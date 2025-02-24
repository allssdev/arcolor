#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _CLRF CHR(13)+CHR(10)
/*/{Protheus.doc} RESTA003
Rotina executada ao tÈrmino do processamento da rotina padr„o do Refaz Acumulados, utilizada para refazer a coluna
de quantidade j· entregue dos pedidos de vendas, para os pedidos com o tipo de divis„o em "Valor" com o percentual
maior do que zero e menor do que 100, conforme a tabela SD2, que seja vinculada a um TES que gere movimentaÁ„o de estoque.
@author Anderson C. P. Coelho
@since 03/10/2013
@version P12.1.33
@type Function
@obs Sem observaÁıes
@see https://allss.com.br
@history 27/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revis„o para adequaÁ„o de chamadas de tabela em querys sem NOLOCK.
/*/
//Base: 102. OK - Delecao dos itens duplicados na SC9 (acerto final) e acerto do C6_QTDEMP.sql
User Function RESTA003(_cPV)

Local _aSavArea  := GetArea()

Private _cRotina := "RESTA003"

Default _cPV     := ""

If MsgYesNo("Deseja processar o acerto nos pedidos do CD neste momento?",_cRotina+"_001")
	MsgInfo("ATEN«√O!!! Certifique-se de ter executado o backup antes.",_cRotina+"_002")
	If !MsgYesNo("Deseja abortar este processo?",_cRotina+"_003")
		Processa( { |lEnd| Atualiza(@lEnd,_cPV) }, "Ajuste dos pedidos do CD", "Processando...",.F.)
	Else
		MsgInfo("Processo abortado pelo usu·rio!",_cRotina+"_004")
	EndIf
EndIf

RestArea(_aSavArea)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Atualiza  ∫Autor  ≥Anderson C. P. Coelho ∫ Data ≥  03/10/13 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Processamento da rotina.                                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa Principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function Atualiza(lEnd,_cPV)

Local _nCont := 0

ProcRegua(7)

//Duplicidades na SC9
/*
_cQry   := " SELECT COUNT(*) CONTAGEM " + _CLRF
_cQry   += " FROM " + RetSqlName("SC9") + " SC9X " + _CLRF
_cQry   += " WHERE (SC9X.C9_PEDIDO+SC9X.C9_ITEM+SC9X.C9_PRODUTO+SC9X.C9_DATALIB+SC9X.C9_LOTECTL) IN (SELECT (C9_PEDIDO+C9_ITEM+C9_PRODUTO+C9_DATALIB+C9_LOTECTL) " + _CLRF
_cQry   += " 														FROM " + RetSqlName("SC9") + " SC9 " + _CLRF
_cQry   += " 														WHERE SC9.C9_FILIAL  = '" + xFilial("SC9") + "' " + _CLRF
If !Empty(_cPV)
	_cQry   += " 													  AND SC9.C9_PEDIDO  = '" + _cPV           + "' " + _CLRF
EndIf
_cQry   += " 														  AND SC9.C9_BLEST  <> '10' " + _CLRF
_cQry   += " 														  AND SC9.D_E_L_E_T_ = '' " + _CLRF
_cQry   += " 														GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_DATALIB, C9_LOTECTL " + _CLRF
_cQry   += " 														HAVING COUNT(*) > 1 " + _CLRF
_cQry   += " 														) " + _CLRF
_cQry   += "  AND SC9X.D_E_L_E_T_ = '' " + _CLRF
//_cQry   += " ORDER BY C9_DATALIB, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_LOTECTL " + _CLRF
//If __cUserId == "000000"
//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_000.TXT",_cQry)
//EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SC9TMP",.T.,.F.)
*/
If !Empty(_cPV)
	_cQry   := "%AND SC9.C9_PEDIDO = '" + _cPV + "'%"
Else
	_cQry   := "%%"
EndIf
BeginSql Alias "SC9TMP"
	SELECT COUNT(*) CONTAGEM
	FROM %table:SC9% SC9X (NOLOCK)
	WHERE (	SELECT COUNT(*)
			FROM %table:SC9% SC9 (NOLOCK)
			WHERE SC9.C9_FILIAL  = %xFilial:SC9%
			  AND SC9.C9_BLEST  <> '10'
			  AND SC9.C9_PEDIDO  = SC9X.C9_PEDIDO
			  AND SC9.C9_ITEM    = SC9X.C9_ITEM
			  AND SC9.C9_PRODUTO = SC9X.C9_PRODUTO
			  AND SC9.C9_DATALIB = SC9X.C9_DATALIB
			  AND SC9.C9_LOTECTL = SC9X.C9_LOTECTL
			  AND SC9.%NotDel%
			  %Exp:_cQry%
			GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_DATALIB, C9_LOTECTL 
			HAVING COUNT(*) > 1 
			) > 0
	  AND SC9X.%NotDel%
EndSql
//If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_000.TXT",GetLastQuery()[02])
//EndIf
IncProc()
dbSelectArea("SC9TMP")
_nCont := SC9TMP->CONTAGEM
SC9TMP->(dbCloseArea())
If _nCont > 0 .AND. MsgYesNo("AtenÁ„o!!! Duplicidades foram encontradas na tabela SC9 (LiberaÁ„o de Pedidos). Deseja corrigir esta duplicidade neste momento? (CERTIFIQUE-SE DE QUE O BACKUP ANTERIOR A ESTA OPERA«√O EST¡ PRESERVADO. N√O SE ESQUE«A DE COMUNICAR ESTE PROBLEMA AO ADMINISTRADOR DO SISTEMA)",_cRotina+"_005")
	_cQry   := " UPDATE " + RetSqlName("SC9") + _CLRF
	_cQry   += " SET R_E_C_D_E_L_ = R_E_C_N_O_, " + _CLRF
	_cQry   += "     D_E_L_E_T_   = '*', " + _CLRF
	_cQry   += "     C9_NFISCAL   = '#'" + DTOS(Date()) + ", " + _CLRF
	//_cQry   += "     C9_NFISCAL   = '#'" + SubStr(DTOS(Date()),3,2) + StrTran(Time(),":","") + ", " + _CLRF
	_cQry   += "     C9_SERIENF   = '###' " + _CLRF
	_cQry   += " FROM " + RetSqlName("SC9") + " SC9OFI " + _CLRF
	_cQry   += "      INNER JOIN (SELECT C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_DATALIB, C9_LOTECTL, MAX(SC9X.R_E_C_N_O_) RECSC9 " + _CLRF
	_cQry   += "                  FROM " + RetSqlName("SC9") + " SC9X " + _CLRF
	_cQry   += "                  WHERE SC9X.C9_FILIAL  = '" + xFilial("SC9") + "' " + _CLRF
	If !Empty(_cPV)
		_cQry   += " 				AND SC9X.C9_PEDIDO  = '" + _cPV           + "' " + _CLRF
	EndIf
	_cQry   += "                    AND (SELECT COUNT(*) " + _CLRF
	_cQry   += "                         FROM " + RetSqlName("SC9") + " SC9 " + _CLRF
	_cQry   += "                         WHERE SC9.C9_FILIAL  = '" + xFilial("SC9") + "' " + _CLRF
	_cQry   += "                           AND SC9.C9_BLEST  <> '10' " + _CLRF
	_cQry   += "                           AND SC9.C9_PEDIDO  = SC9X.C9_PEDIDO
	_cQry   += "                           AND SC9.C9_ITEM    = SC9X.C9_ITEM
	_cQry   += "                           AND SC9.C9_PRODUTO = SC9X.C9_PRODUTO
	_cQry   += "                           AND SC9.C9_DATALIB = SC9X.C9_DATALIB
	_cQry   += "                           AND SC9.C9_LOTECTL = SC9X.C9_LOTECTL
	_cQry   += "                           AND SC9.D_E_L_E_T_ = '' " + _CLRF
	_cQry   += "                           GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_DATALIB, C9_LOTECTL " + _CLRF
	_cQry   += "                           HAVING COUNT(*) > 1 " + _CLRF
	_cQry   += "                         ) > 0" + _CLRF
	_cQry   += "                    AND SC9X.D_E_L_E_T_ = '' " + _CLRF
	_cQry   += "                  GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_DATALIB, C9_LOTECTL " + _CLRF
	_cQry   += "                  ) XXX ON XXX.RECSC9 = SC9OFI.R_E_C_N_O_ " + _CLRF
	//If __cUserId == "000000"
	//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
	//EndIf
	If TCSQLExec(_cQry) < 0
		IncProc()
		MsgStop("AtenÁ„o!!! Problemas na deleÁ„o dos registros duplicados na tabela SC9, baseado neste registro: " + CHR(13) + CHR(10) + _cQry  + ". Por favor, contate imediatamente o administrador, passe a ele a mensagem que ser· apresentada a seguir e solicite o acerto!",_cRotina+"_006")
		TCSQLError()
	Else
		IncProc()
	EndIf
	dbSelectArea("SC9")
	_aSvC9Upd := SC9->(GetArea())
	TcRefresh("SC9")
	SC9->(dbGoBottom())
	SC9->(dbGoTop())
	RestArea(_aSvC9Upd)
EndIf
/*
//Corrige o campo a quantidade empenhada dos pedidos de vendas
_cQry   := " UPDATE " + RetSqlName("SC6")
_cQry   += " SET C6_QTDEMP  = ISNULL(C9_QTDLIB ,0), "
_cQry   += "     C6_QTDEMP2 = ISNULL(C9_QTDLIB2,0)  "
_cQry   += " FROM " + RetSqlName("SC6") + " SC6 "
_cQry   += " 		LEFT OUTER JOIN  ( "
_cQry   += " 						SELECT C9_PEDIDO, C9_ITEM, C9_PRODUTO, SUM(C9_QTDLIB) C9_QTDLIB, SUM(C9_QTDLIB2) C9_QTDLIB2 "
_cQry   += " 						FROM " + RetSqlName("SC9") + " SC9 "
_cQry   += " 						WHERE SC9.D_E_L_E_T_ = '' "
_cQry   += "                          AND SC9.C9_FILIAL  = '" + xFilial("SC9") + "' "
_cQry   += " 						  AND SC9.C9_BLEST  <> '10' "
_cQry   += " 						GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO "
_cQry   += " 					) SC9FIL ON SC9FIL.C9_PEDIDO   = SC6.C6_NUM "
_cQry   += " 					        AND SC9FIL.C9_ITEM     = SC6.C6_ITEM "
_cQry   += " 					        AND SC9FIL.C9_PRODUTO  = SC6.C6_PRODUTO "
//_cQry   += " 					        AND (SC9FIL.C9_QTDLIB <> SC6.C6_QTDEMP OR SC9FIL.C9_QTDLIB2<> SC6.C6_QTDEMP2) "
_cQry   += " WHERE SC6.D_E_L_E_T_ = '' "
_cQry   += "   AND  SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cQry)
EndIf
If TCSQLExec(_cQry) < 0
	IncProc()
	MsgStop("AtenÁ„o!!! Problemas no ajuste do campo C6_QTDEMP, baseado neste registro: " + CHR(13) + CHR(10) + _cQry  + ". Por favor, contate imediatamente o administrador, passe a ele a mensagem que ser· apresentada a seguir e solicite o acerto!",_cRotina+"_007")
	TCSQLError()
Else
	IncProc()
EndIf
dbSelectArea("SC6")
_aSvC6Upd := SC6->(GetArea())
SC6->(dbGoBottom())
SC6->(dbGoTop())
RestArea(_aSvC6Upd)


//Corrige o campo a quantidade j· entregue dos pedidos de vendas
_cQry   := " UPDATE " + RetSqlName("SC6")
_cQry   += " SET   C6_QTDENT  = ISNULL(SD2.D2_QUANT  ,0) "
_cQry   += "     , C6_QTDENT2 = ISNULL(SD2.D2_QTSEGUM,0) "
_cQry   += " FROM " + RetSqlName("SC6") + " SC6 "
_cQry   += "       INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.D_E_L_E_T_ = '' "
_cQry   += "              AND  SC5.C5_FILIAL  = '" + xFilial("SC5") + "' "
//_cQry   += "              AND  SC5.C5_TIPO    = 'N'  "
//_cQry   += "              AND  SC5.C5_EMISSAO > '" + DTOS(SuperGetMv("MV_ULMES",,"20130330")) + "' "
//_cQry   += "              AND (SC5.C5_TPDIV   = '1' OR SC5.C5_TPDIV = '2' OR SC5.C5_TPDIV = '3') "
_cQry   += "              AND  SC5.C5_NUM     = SC6.C6_NUM     "
_cQry   += "       LEFT OUTER JOIN ( SELECT D2_PEDIDO, D2_ITEMPV, D2_COD, SUM(D2_QUANT) D2_QUANT, SUM(D2_QTSEGUM) D2_QTSEGUM "
_cQry   += "                         FROM " + RetSqlName("SD2") + " SD2INT "
_cQry   += "                                INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' "
_cQry   += "                                AND  SF4.F4_FILIAL  = '" + xFilial("SF4") + "' "
//_cQry   += "                                AND  SF4.F4_MIGRA   = 'S' "
_cQry   += "                                AND  SF4.F4_ESTOQUE = 'S' "
//_cQry   += "                                AND  SF4.F4_TESALTV<> ''  "
_cQry   += "                                AND  SF4.F4_CODIGO  = SD2INT.D2_TES "
_cQry   += "                         WHERE SD2INT.D_E_L_E_T_  = '' "
_cQry   += "                           AND  SD2INT.D2_FILIAL  = '" + xFilial("SD2") + "' "
//_cQry   += "                         AND  SD2INT.D2_TIPO    = 'N' "
//_cQry   += "                         AND  SD2INT.D2_EMISSAO > '" + DTOS(SuperGetMv("MV_ULMES",,"20130330")) + "' "
_cQry   += "                         GROUP BY D2_PEDIDO, D2_ITEMPV, D2_COD "
_cQry   += "                       ) SD2 ON SD2.D2_PEDIDO  = SC6.C6_NUM "
_cQry   += "                            AND  SD2.D2_ITEMPV  = SC6.C6_ITEM    "
_cQry   += "                            AND  SD2.D2_COD     = SC6.C6_PRODUTO "
//_cQry   += "                            AND  (SD2.D2_QUANT <> SC6.C6_QTDENT OR SD2.D2_QTSEGUM <> SC6.C6_QTDENT2) "
_cQry   += "       INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = '' "
_cQry   += "              AND  SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
_cQry   += "              AND  SB1.B1_COD     = SC6.C6_PRODUTO "
_cQry   += "       INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' "
_cQry   += "              AND  SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
_cQry   += "              AND  SA1.A1_COD     = SC5.C5_CLIENTE "
_cQry   += "              AND  SA1.A1_LOJA    = SC5.C5_LOJACLI "
_cQry   += " WHERE  SC6.D_E_L_E_T_ = '' "
_cQry   += "   AND  SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "
_cQry   += "   AND  SC6.C6_TPCALC  = 'V' "
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_003.TXT",_cQry)
EndIf
If TCSQLExec(_cQry) < 0
	IncProc()
	MsgStop("AtenÁ„o!!! Problemas no ajuste do campo C6_QTDENT, baseado neste registro: " + CHR(13) + CHR(10) + _cQry  + ". Por favor, contate imediatamente o administrador, passe a ele a mensagem que ser· apresentada a seguir e solicite o acerto!",_cRotina+"_008")
	TCSQLError()
Else
	IncProc()
EndIf
dbSelectArea("SC6")
_aSvC6Upd := SC6->(GetArea())
SC6->(dbGoBottom())
SC6->(dbGoTop())
RestArea(_aSvC6Upd)


//Corrige o campo a quantidade j· entregue dos pedidos de vendas
_cQry   := " UPDATE " + RetSqlName("SC6")
_cQry   += " SET   C6_QTDENT  = SD2.D2_QUANT   "
_cQry   += "     , C6_QTDENT2 = SD2.D2_QTSEGUM "
_cQry   += " FROM " + RetSqlName("SC6") + " SC6 "
_cQry   += "       INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.D_E_L_E_T_ = '' "
_cQry   += "              AND  SC5.C5_FILIAL  = '" + xFilial("SC5") + "' "
//_cQry   += "              AND  SC5.C5_TIPO    = 'N'  "
//_cQry   += "              AND  SC5.C5_EMISSAO > '" + DTOS(SuperGetMv("MV_ULMES",,"20130330")) + "' "
//_cQry   += "              AND (SC5.C5_TPDIV   = '1' OR SC5.C5_TPDIV = '2' OR SC5.C5_TPDIV = '3') "
_cQry   += "              AND  SC5.C5_NUM     = SC6.C6_NUM     "
_cQry   += "       INNER JOIN ( SELECT D2_PEDIDO, D2_ITEMPV, D2_COD, SUM(D2_QUANT) D2_QUANT, SUM(D2_QTSEGUM) D2_QTSEGUM "
_cQry   += "                    FROM " + RetSqlName("SD2") + " SD2INT "
//_cQry   += "                         INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_ = '' "
//_cQry   += "                                AND  SF4.F4_FILIAL  = '" + xFilial("SF4") + "' "
//_cQry   += "                                AND  SF4.F4_MIGRA   = 'S' "
//_cQry   += "                                AND  SF4.F4_ESTOQUE = 'S' "
//_cQry   += "                                AND  SF4.F4_TESALTV<> ''  "
//_cQry   += "                                AND  SF4.F4_CODIGO  = SD2INT.D2_TES "
_cQry   += "                    WHERE SD2INT.D_E_L_E_T_  = '' "
_cQry   += "                      AND  SD2INT.D2_FILIAL  = '" + xFilial("SD2") + "' "
//_cQry   += "                      AND  SD2INT.D2_TIPO    = 'N' "
//_cQry   += "                      AND  SD2INT.D2_EMISSAO > '" + DTOS(SuperGetMv("MV_ULMES",,"20130330")) + "' "
_cQry   += "                    GROUP BY D2_PEDIDO, D2_ITEMPV, D2_COD "
_cQry   += "                  ) SD2 ON SD2.D2_PEDIDO  = SC6.C6_NUM "
_cQry   += "                      AND  SD2.D2_ITEMPV  = SC6.C6_ITEM    "
_cQry   += "                      AND  SD2.D2_COD     = SC6.C6_PRODUTO "
_cQry   += "                      AND  (SD2.D2_QUANT <> SC6.C6_QTDENT OR SD2.D2_QTSEGUM <> SC6.C6_QTDENT2) "
_cQry   += "       INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = '' "
_cQry   += "              AND  SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
_cQry   += "              AND  SB1.B1_COD     = SD2.D2_COD     "
_cQry   += "       INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' "
_cQry   += "              AND  SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
_cQry   += "              AND  SA1.A1_COD     = SC5.C5_CLIENTE "
_cQry   += "              AND  SA1.A1_LOJA    = SC5.C5_LOJACLI "
_cQry   += " WHERE  SC6.D_E_L_E_T_ = '' "
_cQry   += "   AND  SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "
_cQry   += "   AND  SC6.C6_TPCALC <> 'V' "
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_004.TXT",_cQry)
EndIf
If TCSQLExec(_cQry) < 0
	IncProc()
	MsgStop("AtenÁ„o!!! Problemas no ajuste do campo C6_QTDENT, baseado neste registro: " + CHR(13) + CHR(10) + _cQry  + ". Por favor, contate imediatamente o administrador, passe a ele a mensagem que ser· apresentada a seguir e solicite o acerto!",_cRotina+"_009")
	TCSQLError()
Else
	IncProc()
EndIf
dbSelectArea("SC6")
_aSvC6Upd := SC6->(GetArea())
SC6->(dbGoBottom())
SC6->(dbGoTop())
RestArea(_aSvC6Upd)
*/


/*
 SELECT *
 FROM (
			 SELECT C6_NUM, C6_ITEM, C6_PRODUTO
				   ,C6_QTDEMP , ISNULL((SELECT SUM(CASE WHEN C9_BLEST = '10' THEN 0 ELSE C9_QTDLIB  END)
 								 FROM SC9010 SC9X 
 								 WHERE SC9X.D_E_L_E_T_ = '' 
 								   AND SC9X.C9_FILIAL  = '01' 
 								   AND SC9X.C9_PEDIDO  = C6_NUM 
								   AND SC9X.C9_ITEM    = C6_ITEM 
								   AND SC9X.C9_PRODUTO = C6_PRODUTO 
 								 GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO 
 								),0) LIBERADO 
				   ,C6_QTDEMP2, ISNULL((SELECT SUM(CASE WHEN C9_BLEST = '10' THEN 0 ELSE C9_QTDLIB2 END)
 								 FROM SC9010 SC9X 
 								 WHERE SC9X.D_E_L_E_T_ = '' 
 								   AND SC9X.C9_FILIAL  = '01' 
 								   AND SC9X.C9_PEDIDO  = C6_NUM 
								   AND SC9X.C9_ITEM    = C6_ITEM 
								   AND SC9X.C9_PRODUTO = C6_PRODUTO 
 								 GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO 
 								),0) LIBERADO2
				   ,C6_QTDENT , ISNULL((SELECT CASE WHEN COUNT(D2_PEDIDO)>1 AND C6_TPCALC='V' 
                   									   THEN SUM(D2_QUANT)/2 
                   									   ELSE SUM(D2_QUANT) 
                   							  END 
                   						FROM SD2010 SD2 
                   						WHERE SD2.D_E_L_E_T_= '' 
                   						  AND SD2.D2_FILIAL = '01'
                   						  AND SD2.D2_PEDIDO = C6_NUM  
                   						  AND SD2.D2_ITEMPV = C6_ITEM 
               							  AND SD2.D2_COD    = C6_PRODUTO
                   						GROUP BY D2_PEDIDO, D2_ITEMPV, D2_COD 
                   					   ),0) FATURADO
				   ,C6_QTDENT2, ISNULL((SELECT CASE WHEN COUNT(D2_PEDIDO)>1 AND C6_TPCALC = 'V' 
                   									   THEN SUM(D2_QTSEGUM)/2 
                   									   ELSE SUM(D2_QTSEGUM)   
                   							  END 
                   						FROM SD2010 SD2 
                   						WHERE SD2.D_E_L_E_T_= '' 
                   						  AND SD2.D2_FILIAL = '01'
                   						  AND SD2.D2_PEDIDO = C6_NUM  
                   						  AND SD2.D2_ITEMPV = C6_ITEM 
               							  AND SD2.D2_COD    = C6_PRODUTO
                   						GROUP BY D2_PEDIDO, D2_ITEMPV, D2_COD
                   					   ),0) FATURADO2
*/
//Corrige o campo a quantidade empenhada (SC9) e entregue (SD2) dos pedidos de vendas (SC6)
_cQry := " UPDATE " + RetSqlName("SC6") + _CLRF
_cQry += " SET  C6_QTDEMP  = ISNULL(	(SELECT SUM(CASE WHEN C9_BLEST = '10' THEN 0 ELSE C9_QTDLIB  END)" + _CLRF
_cQry += " 								 FROM " + RetSqlName("SC9") + " SC9X " + _CLRF
_cQry += " 								 WHERE SC9X.C9_FILIAL  = '" + xFilial("SC9") + "' " + _CLRF
_cQry += " 								   AND SC9X.C9_PEDIDO  = C6_NUM " + _CLRF
_cQry += " 								   AND SC9X.C9_ITEM    = C6_ITEM " + _CLRF
_cQry += " 								   AND SC9X.C9_PRODUTO = C6_PRODUTO " + _CLRF
_cQry += " 								   AND SC9X.D_E_L_E_T_ = '' " + _CLRF
_cQry += " 								 GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO " + _CLRF
_cQry += " 								),0) " + _CLRF
_cQry += " 		 ,C6_QTDEMP2 = ISNULL(	(SELECT SUM(CASE WHEN C9_BLEST = '10' THEN 0 ELSE C9_QTDLIB2 END)" + _CLRF
_cQry += " 								 FROM " + RetSqlName("SC9") + " SC9X " + _CLRF
_cQry += " 								 WHERE SC9X.C9_FILIAL  = '" + xFilial("SC9") + "' " + _CLRF
_cQry += " 								   AND SC9X.C9_PEDIDO  = C6_NUM  " + _CLRF
_cQry += " 								   AND SC9X.C9_ITEM    = C6_ITEM  " + _CLRF
_cQry += " 								   AND SC9X.C9_PRODUTO = C6_PRODUTO  " + _CLRF
_cQry += " 								   AND SC9X.D_E_L_E_T_ = ''  " + _CLRF
_cQry += " 								 GROUP BY C9_PEDIDO, C9_ITEM, C9_PRODUTO  " + _CLRF
_cQry += " 								),0) " + _CLRF
_cQry += " 		 ,C6_QTDENT  = ISNULL((SELECT CASE WHEN COUNT(D2_PEDIDO)>1 AND C6_TPCALC = 'V' AND C5_TPDIV <> '5' " + _CLRF
_cQry += "     										   THEN SUM(D2_QUANT)/2  " + _CLRF
_cQry += "     										   ELSE SUM(D2_QUANT)  " + _CLRF
_cQry += "     								  END  " + _CLRF
_cQry += "     						   FROM " + RetSqlName("SD2") + " SD2 " + _CLRF
_cQry += "     						   WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' " + _CLRF
_cQry += "     							 AND SD2.D2_PEDIDO = C6_NUM   " + _CLRF
_cQry += "     							 AND SD2.D2_ITEMPV = C6_ITEM  " + _CLRF
_cQry += "     							 AND SD2.D2_COD    = C6_PRODUTO " + _CLRF
_cQry += "     							 AND SD2.D_E_L_E_T_= ''  " + _CLRF
_cQry += "     						   GROUP BY D2_PEDIDO, D2_ITEMPV, D2_COD " + _CLRF
_cQry += "     						  ),0)  " + _CLRF
_cQry += " 		 ,C6_QTDENT2 = ISNULL((SELECT CASE WHEN COUNT(D2_PEDIDO)>1 AND C6_TPCALC = 'V' AND C5_TPDIV <> '5' " + _CLRF
_cQry += "     										   THEN SUM(D2_QTSEGUM)/2  " + _CLRF
_cQry += "     										   ELSE SUM(D2_QTSEGUM)    " + _CLRF
_cQry += "     								  END  " + _CLRF
_cQry += "     						   FROM " + RetSqlName("SD2") + " SD2 " + _CLRF
_cQry += "     						   WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' " + _CLRF
_cQry += "     							 AND SD2.D2_PEDIDO = C6_NUM   " + _CLRF
_cQry += "     							 AND SD2.D2_ITEMPV = C6_ITEM  " + _CLRF
_cQry += "     							 AND SD2.D2_COD    = C6_PRODUTO " + _CLRF
_cQry += "     							 AND SD2.D_E_L_E_T_= ''  " + _CLRF
_cQry += "     						   GROUP BY D2_PEDIDO, D2_ITEMPV, D2_COD " + _CLRF
_cQry += "     						  ),0)  " + _CLRF
_cQry += " 	 FROM " + RetSqlName("SC6") + " SC6 " + _CLRF
_cQry += " 	 INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL   = '" + xFilial("SC5") + "' " + _CLRF
_cQry += " 						 AND SC5.C5_EMISSAO >= '20130401'  " + _CLRF
_cQry += " 						 AND SC5.C5_NUM      = SC6.C6_NUM  " + _CLRF
_cQry += " 						 AND SC5.D_E_L_E_T_  = '' " + _CLRF
_cQry += " 	 WHERE SC6.C6_FILIAL  = '" + xFilial("SC6") + "' " + _CLRF
If !Empty(_cPV)
	_cQry   += "AND SC6.C6_NUM    = '" + _cPV           + "' " + _CLRF
EndIf
_cQry += " 	   AND SC6.D_E_L_E_T_ = '' " + _CLRF
//If __cUserId == "000000"
//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_005.TXT",_cQry)
//EndIf
If TCSQLExec(_cQry) < 0
	IncProc()
	MsgStop("AtenÁ„o!!! Problemas no ajuste do campo C6_QTDEMP e C6_QTDENT, baseado neste registro: " + CHR(13) + CHR(10) + _cQry  + ". Por favor, contate imediatamente o administrador, passe a ele a mensagem que ser· apresentada a seguir e solicite o acerto!",_cRotina+"_010")
	TCSQLError()
Else
	IncProc()
EndIf
dbSelectArea("SC6")
_aSvC6Upd := SC6->(GetArea())
SC6->(dbGoBottom())
SC6->(dbGoTop())
RestArea(_aSvC6Upd)
/*
//Ajusta a quantidade entregue na SC6, quando esta exceder a quantidade do pedido de vendas
_cQry := " UPDATE " + RetSqlName("SC6")
_cQry += " SET C6_QTDENT  = C6_QTDVEN "
_cQry += "    ,C6_QTDENT2 = C6_UNSVEN "
_cQry += "    ,C6_QTDEMP  = 0 "
_cQry += "    ,C6_QTDEMP2 = 0 "
_cQry += " WHERE D_E_L_E_T_ = '' "
_cQry += "   AND C6_QTDVEN < C6_QTDENT "
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_006.TXT",_cQry)
EndIf
If TCSQLExec(_cQry) < 0
	IncProc()
	MsgStop("AtenÁ„o!!! Problemas no ajuste do campo C6_QTDEMP e C6_QTDENT, baseado neste registro: " + CHR(13) + CHR(10) + _cQry  + ". Por favor, contate imediatamente o administrador, passe a ele a mensagem que ser· apresentada a seguir e solicite o acerto!",_cRotina+"_011")
	TCSQLError()
Else
	IncProc()
EndIf
dbSelectArea("SC6")
_aSvC6Upd := SC6->(GetArea())
SC6->(dbGoBottom())
SC6->(dbGoTop())
RestArea(_aSvC6Upd)
*/
//25/09/2014 - O trecho abaixo foi comentado por Anderson C. P. Coelho, uma vez que apÛs os procedimentos acima, a rotina de Saldo Atual deve ser reexecutada para que faÁa o que o trecho abaixo se propıe.
/*
//Atualiza a quantidade em pedido de vendas na SB2
_cQry   := " UPDATE " + RetSqlName("SB2")
_cQry   += " SET B2_QPEDVEN = ISNULL((SELECT SUM(C6_QTDVEN-C6_QTDENT-C6_QTDEMP-C6_QTDRESE) 
_cQry   += "                          FROM " + RetSqlName("SC6") + " SC6 "
_cQry   += "                          WHERE SC6.D_E_L_E_T_='' "
_cQry   += "                            AND SC6.C6_FILIAL ='" + xFilial("SC6") + "' "
_cQry   += "                            AND SC6.C6_PRODUTO=SB2.B2_COD "
_cQry   += "                            AND SC6.C6_LOCAL=SB2.B2_LOCAL "
_cQry   += "                            AND SC6.C6_QTDENT<SC6.C6_QTDVEN "
_cQry   += "                            AND SC6.C6_BLQ<>'R' "
_cQry   += "                            AND SC6.C6_EMISSAO > '" + DTOS(SuperGetMv("MV_ULMES",,"20130330")) + "' "
_cQry   += "                          GROUP BY SC6.C6_PRODUTO),0), "
_cQry   += "    B2_QPEDVE2 = ISNULL((SELECT SUM(C6_UNSVEN-C6_QTDENT2-C6_QTDEMP2) FROM " + RetSqlName("SC6") + " SC6 "
_cQry   += "                         WHERE SC6.D_E_L_E_T_='' "
_cQry   += "                           AND SC6.C6_FILIAL='" + xFilial("SC6") + "' "
_cQry   += "                           AND SC6.C6_PRODUTO=SB2.B2_COD "
_cQry   += "                           AND SC6.C6_LOCAL=SB2.B2_LOCAL "
_cQry   += "                           AND SC6.C6_QTDENT<SC6.C6_QTDVEN "
_cQry   += "                           AND SC6.C6_BLQ<>'R' "
_cQry   += "                           AND SC6.C6_EMISSAO > '" + DTOS(SuperGetMv("MV_ULMES",,"20130330")) + "' "
_cQry   += "                         GROUP BY SC6.C6_PRODUTO),0) "
_cQry   += " FROM " + RetSqlName("SB2") + " SB2 "   
_cQry   += "		INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB2.B2_COD=SB1.B1_COD "
_cQry   += "												AND SB2.B2_LOCAL=SB1.B1_LOCPAD "
_cQry   += "												AND SB1.B1_FILIAL='" + xFilial("SB1") + "' "
_cQry   += "												AND SB1.D_E_L_E_T_='' "
_cQry   += "												AND SB1.B1_TIPO<>'EM' "
_cQry   += "												AND SB1.B1_TIPO<>'MP' "	
_cQry   += " WHERE SB2.D_E_L_E_T_='' "
_cQry   += "   AND SB2.B2_FILIAL='" + xFilial("SB2") + "' "
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_007.TXT",_cQry)
EndIf              
If TCSQLExec(_cQry) < 0
	IncProc()
	MsgStop("AtenÁ„o!!! Problemas no ajuste do campo B2_QPEDVEN, baseado neste registro: " + CHR(13) + CHR(10) + cQryOri + ". Por favor, contate imediatamente o administrador, passe a ele a mensagem que ser· apresentada a seguir e solicite o acerto!",_cRotina+"_012")
	TCSQLError()
Else
	IncProc()	
	//Update complementar para acertar a quantidade em pedido de vendas na SB2
	_cQry   := "UPDATE " + RetSqlName("SB2")
	_cQry   += "SET B2_QPEDVEN=	B2_QPEDVEN + ISNULL((SELECT SUM(C9_QTDLIB-C9_QTDRESE) "
	_cQry   += "		FROM " + RetSqlName("SC9") + " SC9 "
	_cQry   += "			WHERE SC9.D_E_L_E_T_='' "
	_cQry   += "			AND SC9.C9_FILIAL='" + xFilial("SC9") + "' "
	_cQry   += "			AND SC9.C9_PRODUTO=SB2.B2_COD "
	_cQry   += "			AND SC9.C9_LOCAL=SB2.B2_LOCAL "
	_cQry   += "			AND C9_BLCRED<>'10' AND C9_BLEST<>'10' "
	_cQry   += "			AND (C9_BLCRED<>'' OR C9_BLEST<>'') "
	_cQry   += "			AND C9_NFISCAL='' "
	_cQry   += "			AND "
	_cQry   += "				(SELECT COUNT(*) FROM " + RetSqlName("SC6") + " SC6 "
	_cQry   += "					WHERE SC6.D_E_L_E_T_='' "
	_cQry   += "					AND SC6.C6_FILIAL='" + xFilial("SC6") + "' "
	_cQry   += "					AND SC6.C6_NUM=SC9.C9_PEDIDO "
	_cQry   += "					AND SC6.C6_ITEM=SC9.C9_ITEM "
	_cQry   += "					AND SC6.C6_BLQ='')>0 "
	_cQry   += "		GROUP BY SC9.C9_PRODUTO),0), "
	_cQry   += "	B2_QPEDVE2=B2_QPEDVE2+ISNULL((SELECT SUM(C9_QTDLIB2-C9_RESERVA) "
	_cQry   += "		FROM " + RetSqlName("SC9") + " SC9 "
	_cQry   += "			WHERE SC9.D_E_L_E_T_='' "
	_cQry   += "			AND SC9.C9_FILIAL='" + xFilial("SC9") + "' "
	_cQry   += "			AND SC9.C9_PRODUTO=SB2.B2_COD "
	_cQry   += "			AND SC9.C9_LOCAL=SB2.B2_LOCAL "
	_cQry   += "			AND C9_BLCRED<>'10' AND C9_BLEST<>'10' "
	_cQry   += "			AND (C9_BLCRED<>'' OR C9_BLEST<>'') "
	_cQry   += "			AND C9_NFISCAL='' "
	_cQry   += "			AND "
	_cQry   += "				(SELECT COUNT(*) FROM " + RetSqlName("SC6") + " SC6 "
	_cQry   += "					WHERE SC6.D_E_L_E_T_='' "
	_cQry   += "					AND SC6.C6_FILIAL='" + xFilial("SC6") + "' "
	_cQry   += "					AND SC6.C6_NUM=SC9.C9_PEDIDO "
	_cQry   += "					AND SC6.C6_ITEM=SC9.C9_ITEM "
	_cQry   += "					AND SC6.C6_BLQ='')>0 "
	_cQry   += "		GROUP BY SC9.C9_PRODUTO),0) "
	_cQry   += "FROM " + RetSqlName("SB2") + " SB2 "
	_cQry   += "		INNER JOIN " + RetSqlName("SB1") + " SB1 "
	_cQry   += "		ON SB2.B2_COD=SB1.B1_COD "
	_cQry   += "		AND SB2.B2_LOCAL=SB1.B1_LOCPAD "
	_cQry   += "		AND SB1.B1_FILIAL='" + xFilial("SB1") + "' "
	_cQry   += "		AND SB1.D_E_L_E_T_='' "
	_cQry   += "		AND SB1.B1_TIPO<>'EM' "
	_cQry   += "		AND SB1.B1_TIPO<>'MP' "
	_cQry   += "WHERE SB2.D_E_L_E_T_='' "
	_cQry   += "AND SB2.B2_FILIAL='" + xFilial("SB2") + "' "	
	If __cUserId == "000000"
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_008.TXT",_cQry)
	EndIf
	If TCSQLExec(_cQry) < 0
		IncProc()
		MsgStop("AtenÁ„o!!! Problemas no ajuste do campo B2_QPEDVEN, baseado neste registro: " + CHR(13) + CHR(10) + _cQry + ". Por favor, contate imediatamente o administrador, passe a ele a mensagem que ser· apresentada a seguir e solicite o acerto!",_cRotina+"_013")
		TCSQLError()
	Else
		IncProc()
	EndIf
EndIf     
dbSelectArea("SB2")
_aSvB2Upd := SB2->(GetArea())
SB2->(dbGoBottom())
SB2->(dbGoTop())
RestArea(_aSvB2Upd)

//Atualiza a quantidade reservada do produto na SB2           
_cQry   := "UPDATE " + RetSqlName("SB2")
_cQry   += "	SET B2_RESERVA= "
_cQry   += "		ISNULL((SELECT SUM(C9_QTDLIB+C9_QTDRESE) "
_cQry   += "			FROM " + RetSqlName("SC9") + " SC9 "
_cQry   += "			WHERE SC9.D_E_L_E_T_='' "
_cQry   += "			AND SC9.C9_FILIAL='" + xFilial("SC9") + "' "
_cQry   += "			AND SC9.C9_PRODUTO=SB2.B2_COD "
_cQry   += "			AND SC9.C9_LOCAL=SB2.B2_LOCAL "
_cQry   += "			AND C9_BLCRED='' AND C9_BLEST='' "
_cQry   += "		GROUP BY SC9.C9_PRODUTO, SC9.C9_LOCAL),0), "
_cQry   += "	    B2_RESERV2= "
_cQry   += "		ISNULL((SELECT SUM(C9_QTDLIB2+C9_RESERVA) "
_cQry   += "			FROM " + RetSqlName("SC9") + " SC9 "
_cQry   += "			WHERE SC9.D_E_L_E_T_='' "
_cQry   += "			AND SC9.C9_FILIAL='" + xFilial("SC9") + "' "
_cQry   += "			AND SC9.C9_PRODUTO=SB2.B2_COD "
_cQry   += "			AND SC9.C9_LOCAL=SB2.B2_LOCAL "
_cQry   += "			AND C9_BLCRED='' AND C9_BLEST='' "
_cQry   += "		GROUP BY SC9.C9_PRODUTO, SC9.C9_LOCAL),0) "
_cQry   += " FROM " + RetSqlName("SB2") + " SB2 "
_cQry   += "		INNER JOIN " + RetSqlName("SB1") + " SB1 "
_cQry   += "		ON SB2.B2_COD=SB1.B1_COD "
_cQry   += "		AND SB2.B2_LOCAL=SB1.B1_LOCPAD "
_cQry   += "		AND SB1.B1_FILIAL='" + xFilial("SB1") + "' "
_cQry   += "		AND SB1.D_E_L_E_T_='' "
_cQry   += "		AND SB1.B1_TIPO<>'EM' "
_cQry   += "		AND SB1.B1_TIPO<>'MP' "
_cQry   += "		WHERE SB2.D_E_L_E_T_='' "
_cQry   += "			AND SB2.B2_FILIAL='" + xFilial("SB2") + "' "
If __cUserId == "000000"
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_009.TXT",_cQry)
EndIf

If TCSQLExec(_cQry) < 0
	IncProc()
	MsgStop("AtenÁ„o!!! Problemas no ajuste do campo B2_RESERVA, baseado neste registro: " + CHR(13) + CHR(10)  + cQryOri  + ". Por favor, contate imediatamente o administrador, passe a ele a mensagem que ser· apresentada a seguir e solicite o acerto!",_cRotina+"_014")
	TCSQLError()
Else
	IncProc()
EndIf

dbSelectArea("SB2")
_aSvB2Upd := SB2->(GetArea())
SB2->(dbGoBottom())
SB2->(dbGoTop())
RestArea(_aSvB2Upd)
*/
Return
