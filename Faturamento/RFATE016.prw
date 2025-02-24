#Include "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE016  ºAutor  ³Adriano Leonardo    º Data ³  15/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de regras de comissões - Opção de Alteração       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11   ³ Uso específico Arcolor                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE016(nOpc)

Local btnConfirmar, btnFechar, lblRepres, txtDescRep, txtRepres
Local _cOpc       := ""

Private _aArea 	  := GetArea()
Private _cRotinaA := "RFATE016"
Private _cCodigo  := SZ6->Z6_REPRES

Default nOpc      := IIF(Type("INCLUI")=="L".AND.INCLUI,3,IIF(Type("ALTERA")=="L".AND.ALTERA,4,2))

Static cxtRepres  := Space(Len(SA3->A3_COD ))
Static cxtDescRep := Space(Len(SA3->A3_NOME))
Static oDlg

If nOpc == 2
	_cOpc  := "VISUALIZAÇÃO"
	INCLUI := .F.
	ALTERA := .F.
ElseIf nOpc == 3
	_cOpc  := "INCLUSÃO"
	INCLUI := .T.
	ALTERA := .F.
ElseIf nOpc == 4
	_cOpc  := "ALTERAÇÃO"
	INCLUI := .F.
	ALTERA := .T.
ElseIf nOpc == 5
	_cOpc  := "EXCLUSÃO"
	INCLUI := .F.
	ALTERA := .T.
EndIf

  DEFINE MSDIALOG oDlg TITLE "Regras de Comissões - "+_cOpc FROM 000, 000  TO 540, 970 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
	oDlg:lEscClose := .F.

    @ 015, 009 SAY lblRepres       PROMPT "Representante:"                     SIZE 039, 007 OF oDlg COLORS 0, 16777215           PIXEL        
    @ 023, 009 MSGET txtRepres        VAR cxtRepres F3 "SA3" VALID ValidSA3()  SIZE 059, 010 OF oDlg COLORS 0, 16777215 READONLY  PIXEL
    @ 023, 084 MSGET txtDescRep       VAR cxtDescRep                           SIZE 175, 010 OF oDlg COLORS 0, 16777215 READONLY  PIXEL
    frvRegras(nOpc)
	If nOpc >= 3 .AND. nOpc <= 5
	    @ 245, 396 BUTTON btnConfirmar PROMPT "Confirmar"                     SIZE 037, 012 OF oDlg Action ATUINF(_cCodigo,nOpc) PIXEL
	EndIf
    @ 245, 438 BUTTON btnFechar    PROMPT "Fechar"                            SIZE 037, 012 OF oDlg Action Close(oDlg)           PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

grvRegras := NIL

Return

//---------------------------------------------------------------
Static Function ValidSA3()
//---------------------------------------------------------------
Local lRet := .T. 

dbSelectArea("SA3")
SA3->(dbSetOrder(1))
If SA3->(MsSeek(xFilial("SA3") + cxtRepres,.T.,.F.))
	cxtDescRep := SA3->A3_NOME
ElseIf Empty(cxtRepres)
	cxtDescRep := Space(Len(SA3->A3_NOME))
Else
	lRet := .F.
EndIf

RestArea(_aArea)

Return(lRet)                                                                         

//------------------------------------------------
Static Function frvRegras(nOpc)
//------------------------------------------------
Local nX
Local aHeaderEx    := {}
Local aColsEx      := {}
Local aFieldFill   := {}
Local aAlterFields := {}
Local _cAliasSX3   := "SX3_"+GetNextAlias()

Static aFields     := {"NOUSER"}
Static grvRegras

if select(_cAliasSX3) > 0
	(_cAliasSX3)->(dbCloseArea())
endif
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(2))

// Get fields from SZ6
aEval(ApBuildHeader("SZ6", Nil), {|x| Aadd(aFields, x[2])})
aAlterFields := aClone(aFields)
// Define field properties
For nX := 1 to Len(aFields)
	If (_cAliasSX3)->(MsSeek(aFields[nX],.T.,.F.))
		// Define field structs
		Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
						(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
		// Define field values
		Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
	EndIf
Next nX
// Define field structs
Aadd(aHeaderEx, {"RECNO","RECNO","",20,0,".T.","€€€€€€€€€€€€€€ ","N","","V","",""})
// Define field values
Aadd(aFieldFill, .F.)
Aadd(aColsEx, aFieldFill)

If nOpc == 3 .OR. nOpc == 4
	grvRegras := MsNewGetDados():New( 048, 009, 237, 476, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", NIL, aAlterFields,, 5000, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
Else
	grvRegras := MsNewGetDados():New( 048, 009, 237, 476,                              , "AllwaysTrue", "AllwaysTrue", NIL, aAlterFields,, 5000, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
EndIf
//Chama a função para carregar os itens
Processa({|lEnd| Visualizar(_cCodigo,nOpc,lEnd)}, "["+_cRotinaA+"] Visualização das Regras de Comissões","Processando informações para exibição...",.F.)

if select(_cAliasSX3) > 0
	(_cAliasSX3)->(dbCloseArea())
endif

Return

//------------------------------------------------
Static Function Visualizar(_cCodRep,nOpc,lEnd) //Visualização
//------------------------------------------------
//Local _nLinha := 0

_cCodigo 	  := _cCodRep
cxtRepres 	  := _cCodigo

ValidSA3()

BeginSql Alias "SZ6TMP"
	SELECT *, R_E_C_N_O_ RECSZ6
	FROM %table:SZ6% SZ6
	WHERE SZ6.Z6_FILIAL = %xFilial:SZ6%
	  AND SZ6.Z6_REPRES = %Exp:cxtRepres%
	  AND SZ6.%NotDel%
	ORDER BY Z6_FILIAL, Z6_REPRES, Z6_PRODUT, Z6_DTINI, Z6_DTFIM
EndSql
dbSelectArea("SZ6TMP")
ProcRegua(SZ6TMP->(RecCount()))
SZ6TMP->(dbGoTop())
If !SZ6TMP->(EOF())
	aCols := {}
	n     := 0
	While !SZ6TMP->(EOF())
		IncProc()
		AADD(aCols, ARRAY(Len(grvRegras:aHeader)+1))
		n := Len(aCols)
		aCols[n,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_GRPPRO"})] := SZ6TMP->Z6_GRPPRO
		aCols[n,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DESCGR"})] := SZ6TMP->Z6_DESCGR
		aCols[n,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_PRODUT"})] := SZ6TMP->Z6_PRODUT
		aCols[n,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DESCPR"})] := SZ6TMP->Z6_DESCPR
		aCols[n,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_PERC"  })] := SZ6TMP->Z6_PERC
		aCols[n,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DTINI" })] := STOD(SZ6TMP->Z6_DTINI)
		aCols[n,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DTFIM" })] := STOD(SZ6TMP->Z6_DTFIM)
		aCols[n,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="RECNO"    })] := SZ6TMP->RECSZ6
		aCols[n,Len(grvRegras:aHeader)+1]                                 := .F.
		dbSelectArea("SZ6TMP")
		SZ6TMP->(dbSkip())
	EndDo
	grvRegras:nAt   := 1
	grvRegras:aCols := aClone(aCols)
EndIf
dbSelectArea("SZ6TMP")
SZ6TMP->(dbCloseArea())

Return()

//------------------------------------------------
Static Function ATUINF(_cCodigo,nOpc)		//Alterar(_cCodRep)
//------------------------------------------------
Local _nLinha := 0

dbSelectArea("SZ6")
For _nLinha := 1 To Len(grvRegras:aCols)	
	If nOpc == 5 .OR. (nOpc == 4 .AND. grvRegras:aCols[_nLinha,Len(grvRegras:aHeader)+1])	//Exclui
		SZ6->(dbGoTo(grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="RECNO"})]))
		RecLock("SZ6",.F.)
			SZ6->(dbDelete())
		SZ6->(MsUnLock())
	ElseIf nOpc == 3 .OR. nOpc == 4			//Inlcui ou Altera
	//Verifica se deletado        
		If (!Empty(grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_GRPPRO"})]) .OR. !Empty(grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_PRODUT"})]))
			//If !grvRegras:aCols[_nLinha,Len(aFields)]
			//Faz a gravação dos dados        
			dbSelectArea("SZ6")
			If grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="RECNO"})] == 0
				RecLock("SZ6",.T.)
				SZ6->Z6_FILIAL := xFilial("SZ6")
				SZ6->Z6_REPRES := _cCodigo
			Else
				SZ6->(dbGoTo(grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="RECNO"})]))
				RecLock("SZ6",.F.)
			EndIf
				SZ6->Z6_NOMERE := cxtDescRep
				SZ6->Z6_GRPPRO := grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_GRPPRO"})]
				SZ6->Z6_DESCGR := grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DESCGR"})]
				SZ6->Z6_PRODUT := grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_PRODUT"})]
				SZ6->Z6_DESCPR := grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DESCPR"})]
				SZ6->Z6_PERC   := grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_PERC"  })]
				SZ6->Z6_DTINI  := grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DTINI" })]
				SZ6->Z6_DTFIM  := grvRegras:aCols[_nLinha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DTFIM" })]
			SZ6->(MsUnLock())
		EndIf
	EndIf
Next

//Fecha a tela de diálogo
Close(oDlg)
	
Return()