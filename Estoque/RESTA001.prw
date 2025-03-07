#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?270Autom ?Autor ?icardo Berti          ?Data ?20/05/08 ??
??un?o    ?ESTA001  ?Autor ?nderson C. P. Coelho  ?Data ?27/08/13 ??
???????????????????????????????????????
??escri?o ?Selecao automatica para contagens do inventario            ??
??         ?Altera?es processadas para a sele?o autom?ica de conta- ??
??         ?em.                                                        ??
???????????????????????????????????????
??intaxe   ?A270Autom(ExpC1)                                           ??
???????????????????????????????????????
??arametros?ExpC1 = Alias do arquivo                                   ??
???????????????????????????????????????
??etorno   ?Nenhum                                                     ??
???????????????????????????????????????
??Uso      ?Protheus 11 - Espec?ico para a empresa Arcolor            ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/

//Function A270Autom(cAlias)
User Function RESTA001(cAlias)

Local oDlg
Local bBlNewProc := {|oCenterPanel|a270ProSel(oCenterPanel)}
Local cCadastro  := OemtoAnsi("Sele��o Autom�tica do Invent�rio")
Local cPerg	     := "MTA270A"
Local nOpca  	 := 0
Local lUsaNewPrc := If(FindFunction('UsaNewPrc'),UsaNewPrc(),.F.)

If l270Auto
	a270ProSel()
ElseIf GetRPORelease() >= "R1.1" .And. lUsaNewPrc
	tNewProcess():New("MATA270",cCadastro,bBlNewProc,"Rotina de Sele��oo de Contagem de Invent�rio Espec�fica",cPerg)
Else
	DEFINE MSDIALOG oDlg FROM  96,4 TO 355,625 TITLE cCadastro PIXEL
	@ 18, 9 TO 99, 300 LABEL "" OF oDlg  PIXEL
	@ 29, 15 Say OemToAnsi("Este programa ir� selecionar e gravar contagens como OK, quando houverem m?tiplas contagens ") SIZE 275, 10 OF oDlg PIXEL
	@ 38, 15 Say OemToAnsi("e dados de quantidade, lote e endere? estiverem iguais em contagens do mesmo produto na data. ") SIZE 275, 10 OF oDlg PIXEL
	@ 58, 15 Say OemToAnsi("Nota: Ser?considerado apenas o estoque inventariado na data p/ sele?o autom?ica (par?etros). ") SIZE 255, 10 OF oDlg PIXEL
	@ 78, 35 Say OemToAnsi("Verifique em par�metros a data p/ sele��o autom�tica. ") SIZE 275, 10 OF oDlg PIXEL

	DEFINE SBUTTON FROM 108,209 TYPE 5 ACTION Pergunte(cPerg,.T.) ENABLE OF oDlg
	DEFINE SBUTTON FROM 108,238 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 108,267 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg
EndIf

If nOpca == 1 .And. !(GetRPORelease() >= "R1.1" .And. lUsaNewPrc)
	a270ProSel()
EndIf

Return Nil

/*
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?270ProSel?Autor ?icardo Berti          ?Data ?24/05/08 ??
??un?o    ?270ProSel?Autor ?nderson C. P. Coelho  ?Data ?27/08/13 ??
???????????????????????????????????????
??escri?o ?Processamento da Selecao automat.p/ contagens do Inventario??
???????????????????????????????????????
??intaxe   ?A270ProSel(ExpO1)                                          ??
???????????????????????????????????????
??arametros?ExpO1: nome do obj da regua de processamento               ??
???????????????????????????????????????
??etorno   ?Nenhum                                                     ??
???????????????????????????????????????
??Uso      ?MATA270                                                    ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/

Static Function a270ProSel(oCenterPanel)

Local oObj 
#IFDEF TOP
	TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top
#ENDIF

If oCenterPanel <> NIL
	oObj := oCenterPanel
EndIf

If l270Auto
	A270ProAut()
Else
	If !(oObj <> NIL)
		oObj := MsNewProcess():New({|lEnd| A270ProAut(oObj)},"","",.F.)
		oObj:Activate()
	Else
		A270ProAut(oObj)
	EndIf
EndIf

Return Nil

/*
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?270ProAut?Autor ?icardo Berti          ?Data ?24/05/08 ??
??un?o    ?270ProAut?Autor ?nderson C. P. Coelho  ?Data ?27/08/13 ??
???????????????????????????????????????
??escri?o ?Processamento da Selecao automat.p/ contagens do Inventario??
???????????????????????????????????????
??intaxe   ?A270ProAut(ExpO1)                                          ??
???????????????????????????????????????
??arametros?ExpO1: nome do obj da regua de processamento               ??
???????????????????????????????????????
??etorno   ?Nenhum                                                     ??
???????????????????????????????????????
??Uso      ?MATA270                                                    ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/

Static Function A270ProAut(oObj)

//Local lOk
//Local cChaveB7
Local aArea 	:= GetArea()
//Local aContagens:= {}
Local cAliasSB7 := "SB7"
Local lQuery	:= .F.
Local nAchou	:= 0
Local nX		:= 0                   
Local lUsaNewPrc := If(FindFunction('UsaNewPrc'),UsaNewPrc(),.F.)
Local _cDocinv	:= Alltrim(mv_par07 )

//Local cContage := ""
//Local nContValid := 0
//Local nQtdAnt := 0

#IFDEF TOP
	Local aStru		:= {}
	Local cQuery	:= ""
#ENDIF

dbSelectArea("SB7")
SB7->(dbSetOrder(1))

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		aStru     := SB7->(dbStruct())
		lQuery	  := .T.
		cAliasSB7 := GetNextAlias()
		/*
		cQuery := "SELECT B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE,"
		cQuery += "B7_QUANT,B7_CONTAGE,B7_ESCOLHA,SB7.R_E_C_N_O_ RECNOSB7 "
		cQuery += "FROM " + RetSqlName("SB7") + " SB7 "
		cQuery += "WHERE SB7.B7_FILIAL='" + xFilial("SB7") + "' "
		cQuery += "AND B7_DATA = '" + DTOS(mv_par03) + "' " 
		cQuery += "AND SB7.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE,B7_QUANT,B7_CONTAGE "
		*/
		
		cQuery := "SELECT B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE,"
		cQuery += "B7_QUANT, MAX(SB7.R_E_C_N_O_) RECNOSB7 "
		cQuery += "FROM " + RetSqlName("SB7") + " SB7 (NOLOCK)"
		cQuery += "WHERE SB7.B7_FILIAL = '" + xFilial("SB7") + "' "
		cQuery += "  AND SB7.B7_DATA   = '" + DTOS(mv_par03) + "' " 
		If !Empty(Alltrim(_cDocinv))
		cQuery += "  AND SB7.B7_DOC ='" + _cDocinv + "' " 
		EndIf
		cQuery += "  AND SB7.D_E_L_E_T_= '' "
		cQuery += "GROUP BY B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE,B7_QUANT "
		cQuery += "HAVING COUNT(*) > 1 "
		
		
		cQuery += "UNION ALL "
		cQuery += "SELECT B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE,"
		cQuery += "MAX(B7_QUANT) B7_QUANT, MAX(SB7.R_E_C_N_O_) RECNOSB7 "
		cQuery += "FROM " + RetSqlName("SB7") + " SB7 "
		cQuery += "WHERE SB7.B7_FILIAL = '" + xFilial("SB7") + "' "
		cQuery += "  AND SB7.B7_DATA   = '" + DTOS(mv_par03) + "' " 
		If !Empty(Alltrim(_cDocinv))
		cQuery += "  AND SB7.B7_DOC ='" + _cDocinv + "' " 
		EndIf
		cQuery += "  AND SB7.D_E_L_E_T_=' ' "
		cQuery += "GROUP BY B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE "
		cQuery += "HAVING COUNT(*) = 1 "
		/*
		cQuery += "UNION ALL "
		cQuery += "SELECT B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE,"
		cQuery += "MAX(B7_QUANT) B7_QUANT, MAX(SB7.R_E_C_N_O_) RECNOSB7 "
		cQuery += "FROM " + RetSqlName("SB7") + " SB7 (NOLOCK)"
		cQuery += "WHERE SB7.B7_FILIAL = '" + xFilial("SB7") + "' "
		cQuery += "  AND SB7.B7_DATA   = '" + DTOS(mv_par03) + "' " 
		If substr(_cDocinv,1,3) = "IPA"
			cQuery += "  AND SB7.B7_DOC ='" + _cDocinv + "' " 
			//cQuery += "  AND SB7.B7_QUANT  > 0 "
		
		Else
			cQuery += "  AND SB7.B7_QUANT  = 0 " 
			cQuery += "   AND  EXISTS ( "
			cQuery += "                    SELECT TOP 1 1 "
			cQuery += "                    FROM " + RetSqlName("SB7") + " SB7X (NOLOCK) "
			cQuery += "                    WHERE SB7X.B7_FILIAL      = '" + xFilial("SB7")  + "' "
			cQuery += "                      AND SB7X.B7_DATA        = '" + DTOS(dDataBase) + "' "
			cQuery += "                      AND SB7X.B7_COD         = SB7.B7_COD  "
			cQuery += "                      AND SB7X.B7_LOCAL       = SB7.B7_LOCAL "
			cQuery += "                      AND SB7X.B7_LOTECTL      = SB7.B7_LOTECTL"
			cQuery += "                      AND SB7X.B7_ESCOLHA     = '' "
			cQuery += "                      AND SB7X.B7_QUANT    	 > 0 "
			cQuery += "                      AND SB7.D_E_L_E_T_ = '' " 
			cQuery += "                    ) " 
		Endif
		cQuery += "  AND SB7.D_E_L_E_T_= '' "
		cQuery += "GROUP BY B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE "
		cQuery += "HAVING COUNT(*) = 1 "
		*/
		cQuery += "ORDER BY B7_FILIAL,B7_DATA,B7_COD,B7_LOCAL,B7_LOCALIZ,B7_NUMSERI,B7_LOTECTL,B7_NUMLOTE,B7_QUANT "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB7,.T.,.T.)
		dbSelectArea(cAliasSB7)
		For nX := 1 To Len(aStru)
			If ( aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0 )
				TcSetField(cAliasSB7,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next
	Else
#ELSE
	SB7->(MsSeek(xFilial("SB7")+DToS(mv_par03),.T.,.F.)) // B7_FILIAL + B7_DATA
#ENDIF                         

#IFDEF TOP
	EndIf
#ENDIF

If !l270Auto
	oObj:SetRegua1(SB7->(LastRec()))
EndIf

If oObj <> NIL .And. (GetRPORelease() >= "R1.1" .And. lUsaNewPrc)
	If !EOF() .And. If(lQuery,.T.,(cAliasSB7)->B7_DATA == mv_par03)
		oObj:SaveLog(OemToAnsi("Inicio do Processamento"))
	EndIf       
EndIf
nAchou := 0
While !(cAliasSB7)->(EOF()) .And. If(lQuery,.T.,(cAliasSB7)->B7_DATA == mv_par03)
	If !l270Auto
		oObj:IncRegua1("Processando")
	EndIf
	/*
	cChaveB7 := B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	cContage := B7_CONTAGE
	nQuant   := B7_QUANT
	nRecno   := If(lQuery,RECNOSB7,RecNo())
	nAchou	 := 0
	lOk		 := .T.
	While !Eof() .And. cChaveB7 == B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
		//?????????????????????????????????????????????????????
		//?Validacoes: - Deve haver mais de uma contagem (e nenhuma selec.) p/ ser considerada multipla contagem ?
		//?            - Todas devem ter a mesma qtde.         												  ?
		//?????????????????????????????????????????????????????
		If lOk .And. (nQuant <> B7_QUANT .Or. Empty(B7_CONTAGE) .Or. B7_ESCOLHA <> " ")
			lOk := .F.
		ElseIf lOk
			nAchou++
		EndIf		
		dbSkip()
	EndDo
	If lOk .And. nAchou > 1  // Multiplas contagens
		AADD(aContagens,{cContage,nQuant,nRecno})
	EndIf
	*/
	dbSelectArea("SB7")
	dbGoTo(IIf(lQuery,(cAliasSB7)->RECNOSB7,RecNo()))
	If !SB7->(EOF()) .and. SB7->B7_QUANT = 0 .and. SB7->B7_ESCOLHA = "S"
		Reclock('SB7',.F.)
		SB7->B7_ESCOLHA := ""
		SB7->(MsUnlock())
		nAchou++
	Else
		Reclock('SB7',.F.)
		SB7->B7_ESCOLHA := "S"
		SB7->(MsUnlock())
		nAchou++
	EndIf
	dbSelectArea(cAliasSB7)
	(cAliasSB7)->(dbSkip())
EndDo	

If nAchou == 0
	If !l270Auto
		Help(" ",1,"MA270NSAUT") // N? h?contagens m?tiplas que podem ser selecionadas automaticamente na data.
	EndIf
/*Else
	If oObj <> NIL .and. lUsaNewPrc
		oObj:SaveLog(OemToAnsi("Fim do Processamento"))
	EndIf*/
EndIf
/*
If Len(aContagens) == 0
	If !l270Auto
		Help(" ",1,"MA270NSAUT") // N? h?contagens m?tiplas que podem ser selecionadas automaticamente na data.
	EndIf
Else
	//??????????????????????????????????????????????
	//?Grava a 1a. contagem como selecionada (oficial), dentre as contagens c/qtdes. iguais    ?
	//??????????????????????????????????????????????
	dbSelectArea("SB7")
	SB7->(dbSetOrder(1))
	If !l270Auto
		oObj:SetRegua2(Len(aContagens))
	EndIf

	For nX := 1 To Len(aContagens)
		dbgoto(aContagens[nX,3])
		If !l270Auto
			oObj:IncRegua2("?????")
		EndIf
		Reclock('SB7',.F.)
		Replace B7_ESCOLHA With "S"
		MsUnlock()
	Next
	If oObj <> NIL .and. lUsaNewPrc
		oObj:SaveLog(OemToAnsi("Fim do Processamento"))
	EndIf
EndIf	
*/
RestArea(aArea)

Return Nil
