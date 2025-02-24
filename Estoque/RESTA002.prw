#INCLUDE "RWMAKE.CH"
//#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RESTA002  ºAutor  ³Anderson C. P. Coelho º Data ³  27/08/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina utilizada para o lancamento automatico de inventarioº±±
±±º          ³com quantidade igual a zero para itens em estoque que nao   º±±
±±º          ³foram inventariados por database.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Especifico para a Empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RESTA002()

Local cPerg	     := "RESTA002"
Private _cRotina    := "RESTA002"
Private lMsErroAuto := .F.
Private _nProc      := 0

Static oDlg01
@ 132,92 To 275,523 Dialog oDlg01 Title "Rotina de lancamento de inventario Zero"
@ 04,011 To 70,205
@ 13,020 Say "Por meio desta rotina, sera possivel gerar inventario com quantidade " Size 173,8
@ 21,020 Say "zerada para todos os itens que ainda nao foram inventariados na      " Size 173,8
@ 29,020 Say "database " + DTOC(dDataBase) + ".                                    " Size 173,8
@ 50,100 BmpButton Type 1 Action Close(oDlg01)
@ 50,130 BmpButton Type 5 Action Pergunte(cPerg,.T.)
Activate Dialog oDlg01 CENTERED

If MsgYesNo("Deseja iniciar o lancamento destes inventarios, neste momento?",_cRotina+"_001")
	Processa({ || ProcInv() }, "["+_cRotina+"] - Rotina de zeramento de custos","Coletando informacoes...",.F.)
	MsgInfo("Processo concluido. Foram processados " + cValToChar(_nProc) + " registros!",_cRotina+"_002")
Else
	MsgAlert("Rotina abortada!",_cRotina+"_003")
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcInv   ºAutor  ³Anderson C. P. Coelho º Data ³  27/08/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processamento...                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ProcInv()

Local _x
dbSelectArea("SB7")
SB7->(dbSetOrder(1))
If !SB7->(MsSeek(xFilial("SB7") + DTOS(dDataBase),.T.,.F.))
	MsgAlert("Nenhum inventario já digitado em " + DTOC(dDataBase) + ". Processo abortado!",_cRotina+"_004")
	Return
EndIf
If Empty(MV_PAR01)
	MV_PAR01 := "5"
EndIf
For _x := 1 To 3
	If _x == 1		//Saldos por endereço
		_cQry := " SELECT	BF_PRODUTO [B7_COD] "
		_cQry += "  	   ,BF_LOCAL   [B7_LOCAL] "
		_cQry += "  	   ,B1_TIPO    [B7_TIPO] "
		_cQry += "  	   ,'" + "I"+DTOS(dDataBase) + "' [B7_DOC] "
		_cQry += "  	   ,0          [B7_QUANT] "
		_cQry += "  	   ,0          [B7_QTSEGUM] "
		_cQry += "  	   ,'" + DTOS(dDataBase)     + "' [B7_DATA] "
		_cQry += "  	   ,BF_LOTECTL [B7_LOTECTL] "
		_cQry += "  	   ,BF_NUMLOTE [B7_NUMLOTE] "
//		_cQry += "  	   ,BF_DTVALID [B7_DTVALID] "
		_cQry += "  	   ,BF_LOCALIZ [B7_LOCALIZ] "
		_cQry += "  	   ,BF_NUMSERI [B7_NUMSERI] "
		_cQry += "  	   ,''         [B7_TPESTR] "
		_cQry += "  	   ,''         [B7_OK] "
		_cQry += "  	   ,'S'        [B7_ESCOLHA] "
		_cQry += "  	   ,'001'      [B7_CONTAGE] "
		_cQry += "  	   ,''         [B7_NUMDOC] "
		_cQry += "  	   ,''         [B7_SERIE] "
		_cQry += "  	   ,''         [B7_FORNECE] "
		_cQry += "  	   ,''         [B7_LOJA] "
		_cQry += "  	   ,'1'        [B7_STATUS] "
		_cQry += " FROM " + RetSqlName("SBF") + " SBF (NOLOCK) "
		_cQry += "      INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
//		_cQry += "                           AND SB1.B1_TIPO   IN (" + SuperGetMv("MV_TPPRDINV",,"'PA','PI','MP','EM'") + ") "
		If MV_PAR01 = 1
			_cQry += "                           AND SB1.B1_TIPO   = 'PA' "
		elseif MV_PAR01 = 2
			_cQry += "                           AND SB1.B1_TIPO   = 'PI' "
		elseif MV_PAR01 = 3
			_cQry += "                           AND SB1.B1_TIPO   = 'MP' "
		elseif MV_PAR01 = 4
			_cQry += "                           AND SB1.B1_TIPO  IN ('EM','MC') "
		EndIf
		
		_cQry += "                           AND SB1.B1_LOCALIZ = 'S' "
		_cQry += "                           AND SB1.B1_COD     = SBF.BF_PRODUTO "
		_cQry += "                           AND SB1.D_E_L_E_T_ = '' "
		_cQry += " WHERE SBF.BF_FILIAL  = '"  + xFilial("SBF")  + "' " 
		_cQry += "   AND NOT EXISTS ( "
		_cQry += "                    SELECT TOP 1 1 "
		_cQry += "                    FROM " + RetSqlName("SB7") + " SB7 (NOLOCK) "
		_cQry += "                    WHERE B7_FILIAL      = '"+xFilial("SB7")    + "' "
		_cQry += "                      AND B7_DATA        = '" + DTOS(dDataBase) + "' "
		_cQry += "                      AND B7_COD         = BF_PRODUTO "
		_cQry += "                      AND B7_LOCAL       = BF_LOCAL "
		_cQry += "                      AND B7_LOTECTL     = BF_LOTECTL "
		_cQry += "                      AND B7_NUMLOTE     = BF_NUMLOTE "
		_cQry += "                      AND B7_LOCALIZ     = BF_LOCALIZ "
		_cQry += "                      AND SB7.D_E_L_E_T_ = '' " 
		_cQry += "                    ) "
		_cQry += "   AND SBF.D_E_L_E_T_ = '' "
		_cQry += "   AND SBF.BF_LOCAL = '01' "
		_cQry += " ORDER BY BF_PRODUTO, BF_LOCAL,  BF_LOTECTL, BF_NUMLOTE, BF_LOCALIZ "	 // BF_DTVALID, NÃO TEM NO SBF
	ElseIf _x == 2		//Processa primeiramente por lote
		_cQry := " SELECT	B8_PRODUTO [B7_COD] "
		_cQry += "  	   ,B8_LOCAL   [B7_LOCAL] "
		_cQry += "  	   ,B1_TIPO    [B7_TIPO] "
		_cQry += "  	   ,'" + "I"+DTOS(dDataBase) + "' [B7_DOC] "
		_cQry += "  	   ,0          [B7_QUANT] "
		_cQry += "  	   ,0          [B7_QTSEGUM] "
		_cQry += "  	   ,'" + DTOS(dDataBase)     + "' [B7_DATA] "
		_cQry += "  	   ,B8_LOTECTL [B7_LOTECTL] "
		_cQry += "  	   ,B8_NUMLOTE [B7_NUMLOTE] "
//		_cQry += "  	   ,B8_DTVALID [B7_DTVALID] "
		_cQry += "  	   ,''         [B7_LOCALIZ] "
		_cQry += "  	   ,''         [B7_NUMSERI] "
		_cQry += "  	   ,''         [B7_TPESTR] "
		_cQry += "  	   ,''         [B7_OK] "
		_cQry += "  	   ,'S'        [B7_ESCOLHA] "
		_cQry += "  	   ,'001'      [B7_CONTAGE] "
		_cQry += "  	   ,''         [B7_NUMDOC] "
		_cQry += "  	   ,''         [B7_SERIE] "
		_cQry += "  	   ,''         [B7_FORNECE] "
		_cQry += "  	   ,''         [B7_LOJA] "
		_cQry += "  	   ,'1'        [B7_STATUS] "
		_cQry += " FROM " + RetSqlName("SB8") + " SB8 (NOLOCK) "
		_cQry += "      INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
//		_cQry += "                           AND SB1.B1_TIPO    IN (" + SuperGetMv("MV_TPPRDINV",,"'PA','PI','MP','EM'") + ") "
		If MV_PAR01 = 1
			_cQry += "                           AND SB1.B1_TIPO   = 'PA' "
		elseif MV_PAR01 = 2
			_cQry += "                           AND SB1.B1_TIPO   = 'PI' "
		elseif MV_PAR01 = 3
			_cQry += "                           AND SB1.B1_TIPO   = 'MP' "
		elseif MV_PAR01 = 4
			_cQry += "                           AND SB1.B1_TIPO   = 'EM' "
		EndIf
		
		_cQry += "                           AND SB1.B1_LOCALIZ <> 'S' "
		_cQry += "                           AND SB1.B1_RASTRO  <> 'N' "
		_cQry += "                           AND SB1.B1_COD      = SB8.B8_PRODUTO "
		_cQry += "                           AND SB1.D_E_L_E_T_  = '' "
		_cQry += " WHERE SB8.B8_FILIAL  = '"  + xFilial("SB8")  + "' "
		_cQry += "   AND NOT EXISTS ( "
		_cQry += "                    SELECT TOP 1 1 "
		_cQry += "                    FROM " + RetSqlName("SB7") + " SB7 (NOLOCK) "
		_cQry += "                    WHERE B7_FILIAL      = '" + xFilial("SB7")  + "' "
		_cQry += "                      AND B7_DATA        = '" + DTOS(dDataBase) + "' "
		_cQry += "                      AND B7_COD         = B8_PRODUTO "
		_cQry += "                      AND B7_LOCAL       = B8_LOCAL "
		_cQry += "                      AND B7_LOTECTL     = B8_LOTECTL "
		_cQry += "                      AND B7_NUMLOTE     = B8_NUMLOTE "
		_cQry += "                      AND SB7.D_E_L_E_T_ = '' " 
		_cQry += "                    ) "
		_cQry += "   AND SB8.D_E_L_E_T_ = '' "
		_cQry += "   AND SB8.B8_LOCAL = '01' "
		_cQry += " ORDER BY B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_LOTECTL, B8_NUMLOTE "
	Else		
		_cQry := " SELECT	B2_COD     [B7_COD] "
		_cQry += "  	   ,B2_LOCAL   [B7_LOCAL] "
		_cQry += "  	   ,B1_TIPO    [B7_TIPO] "
		_cQry += "  	   ,'" + "I"+DTOS(dDataBase) + "' [B7_DOC] "
		_cQry += "  	   ,0          [B7_QUANT] "
		_cQry += "  	   ,0          [B7_QTSEGUM] "
		_cQry += "  	   ,'" + DTOS(dDataBase)     + "' [B7_DATA] "
		_cQry += "  	   ,''         [B7_LOTECTL] "
		_cQry += "  	   ,''         [B7_NUMLOTE] "
//		_cQry += "  	   ,''         [B7_DTVALID] "
		_cQry += "  	   ,''         [B7_LOCALIZ] "
		_cQry += "  	   ,''         [B7_NUMSERI] "
		_cQry += "  	   ,''         [B7_TPESTR] "
		_cQry += "  	   ,''         [B7_OK] "
		_cQry += "  	   ,'S'        [B7_ESCOLHA] "
		_cQry += "  	   ,'001'      [B7_CONTAGE] "
		_cQry += "  	   ,''         [B7_NUMDOC] "
		_cQry += "  	   ,''         [B7_SERIE] "
		_cQry += "  	   ,''         [B7_FORNECE] "
		_cQry += "  	   ,''         [B7_LOJA] "
		_cQry += "  	   ,'1'        [B7_STATUS] "
		_cQry += " FROM " + RetSqlName("SB2") + " SB2 (NOLOCK) "
		_cQry += "      INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
//		_cQry += "                           AND SB1.B1_TIPO    IN (" + SuperGetMv("MV_TPPRDINV",,"'PA','PI','MP','EM'") + ") "
		If MV_PAR01 = 1
			_cQry += "                           AND SB1.B1_TIPO   = 'PA' "
		elseif MV_PAR01 = 2
			_cQry += "                           AND SB1.B1_TIPO   = 'PI' "
		elseif MV_PAR01 = 3
			_cQry += "                           AND SB1.B1_TIPO   = 'MP' "
		elseif MV_PAR01 = 4
			_cQry += "                           AND SB1.B1_TIPO   = 'EM' "
		EndIf
		
		_cQry += "                           AND SB1.B1_LOCALIZ <> 'S' "
		_cQry += "                           AND SB1.B1_RASTRO   = 'N' "
		_cQry += "                           AND SB1.B1_COD      = SB2.B2_COD "
		_cQry += "                           AND SB1.D_E_L_E_T_  = '' "
		_cQry += " WHERE SB2.B2_FILIAL  = '"  + xFilial("SB2")  + "' "
		/*
		_cQry += "   AND NOT EXISTS (SELECT TOP 1 1 "
		_cQry += "                   FROM "+RetSqlName("SB8")+" SB8 (NOLOCK) "
		_cQry += "                   WHERE SB8.B8_FILIAL  = '"+xFilial("SB8")+"' "
		_cQry += "                     AND SB8.B8_PRODUTO = SB2.B2_COD "
		_cQry += "                     AND SB8.B8_LOCAL   = SB2.B2_LOCAL "
		_cQry += "                     AND SB8.D_E_L_E_T_ = '' "
		_cQry += "                  )"
		*/
		_cQry += "   AND NOT EXISTS ( "
		_cQry += "                    SELECT TOP 1 1 "
		_cQry += "                    FROM " + RetSqlName("SB7") + " SB7 (NOLOCK) "
		_cQry += "                    WHERE B7_FILIAL      = '" + xFilial("SB7")  + "' "
		_cQry += "                      AND B7_DATA        = '" + DTOS(dDataBase) + "' "
		_cQry += "                      AND B7_COD         = B2_COD "
		_cQry += "                      AND B7_LOCAL       = B2_LOCAL "
		_cQry += "                      AND SB7.D_E_L_E_T_ = '' " 
		_cQry += "                    ) "
		_cQry += "   AND SB2.D_E_L_E_T_ = '' "
		_cQry += "   AND SB2.B2_LOCAL  = '01' "
		_cQry += " ORDER BY B2_COD, B2_LOCAL "
	EndIf
	_cPonto := "|"
	_cQry   := ChangeQuery(_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SB7TMP",.T.,.F.)
	dbSelectArea("SB7TMP")
	ProcRegua(RecCount())
	SB7TMP->(dbGoTop())
	While !SB7TMP->(EOF())
		If _cPonto == "|"
			_cPonto := "/"
		ElseIf _cPonto == "/"
			_cPonto := "-"
		ElseIf _cPonto == "-"
			_cPonto := "\"
		Else
			_cPonto := "|"
		EndIf
		If _x == 1
			IncProc("Processando SB8 "+_cPonto)
		Else
			IncProc("Processando SB2 "+_cPonto)
		EndIf
		dbSelectArea("SB7")
		SB7->(dbSetOrder(1))
		while !RecLock("SB7",.T.) ; enddo
			SB7->B7_FILIAL  := xFilial("SB7")
			SB7->B7_COD     := SB7TMP->B7_COD
			SB7->B7_LOCAL   := SB7TMP->B7_LOCAL
			SB7->B7_TIPO    := SB7TMP->B7_TIPO
			SB7->B7_DOC     := SB7TMP->B7_DOC
			SB7->B7_QUANT   := SB7TMP->B7_QUANT
			SB7->B7_QTSEGUM := SB7TMP->B7_QTSEGUM
			SB7->B7_DATA    := STOD(SB7TMP->B7_DATA)
			SB7->B7_LOTECTL := SB7TMP->B7_LOTECTL
			SB7->B7_NUMLOTE := SB7TMP->B7_NUMLOTE
		//	SB7->B7_DTVALID := STOD(SB7TMP->B7_DTVALID)
			SB7->B7_LOCALIZ := SB7TMP->B7_LOCALIZ					//POSICIONE("CBJ",1,xFilial("CBJ")+SB7TMP->B7_COD+SB7TMP->B7_LOCAL,"CBJ_ENDERE")
			SB7->B7_NUMSERI := SB7TMP->B7_NUMSERI
			SB7->B7_TPESTR  := SB7TMP->B7_TPESTR
			SB7->B7_OK      := SB7TMP->B7_OK
			SB7->B7_ESCOLHA := SB7TMP->B7_ESCOLHA
			SB7->B7_CONTAGE := SB7TMP->B7_CONTAGE
			SB7->B7_NUMDOC  := SB7TMP->B7_NUMDOC
			SB7->B7_SERIE   := SB7TMP->B7_SERIE
			SB7->B7_FORNECE := SB7TMP->B7_FORNECE
			SB7->B7_LOJA    := SB7TMP->B7_LOJA
			SB7->B7_STATUS  := SB7TMP->B7_STATUS
			SB7->B7_ORIGEM  := _cRotina
		SB7->(MSUNLOCK())
		_nProc++
		dbSelectArea("SB7TMP")
		SB7TMP->(dbSkip())
	EndDo
	dbSelectArea("SB7TMP")
	SB7TMP->(dbCloseArea())
next

return
