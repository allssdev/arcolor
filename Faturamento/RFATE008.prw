#Include "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE008  ºAutor  ³Adriano Leonardo    º Data ³  14/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de regras de comissões - Opção de Visualização    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11   ³ Uso específico Arcolor                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE008(_cCod)

Local btnConfirmar
Local btnFechar
Local lblRepres
Local txtDescRep
Local txtRepres
Static cxtRepres 	:= "      "
Static cxtDescRep 	:= "                                        "
Static oDlg
Private _cCodigo := _cCod := SZ6->Z6_REPRES
Private _aArea 	 := GetArea()

  DEFINE MSDIALOG oDlg TITLE "Regras de Comissões - Visualização" FROM 000, 000  TO 540, 970 COLORS 0, 16777215 PIXEL

    @ 015, 009 SAY lblRepres PROMPT "Representante:" SIZE 039, 007 OF oDlg COLORS 0, 16777215 PIXEL        
    @ 023, 009 MSGET txtRepres VAR cxtRepres F3 "SA3" VALID ValidSA3()  SIZE 059, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 023, 084 MSGET txtDescRep VAR cxtDescRep SIZE 175, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    frvRegras()
    @ 245, 396 BUTTON btnConfirmar PROMPT "&Confirmar" SIZE 037, 012 OF oDlg Action Close(oDlg) PIXEL
    @ 245, 438 BUTTON btnFechar PROMPT "&Fechar" SIZE 037, 012 OF oDlg Action Close(oDlg) PIXEL                     
      	
  ACTIVATE MSDIALOG oDlg CENTERED

Return
                                                                      
Static Function ValidSA3()
 
	dbSelectArea("SA3")
	dbSetOrder(1)
	If dbSeek(xFilial("SA3") + cxtRepres)
		cxtDescRep := SA3->A3_NOME
		lRet := .T.                   
	ElseIf Empty(cxtRepres)
		lRet := .T.                 
		cxtDescRep := ""
	Else
		lRet := .F.
	EndIf
	RestArea(_aArea)	
Return(lRet)                                                                             

//------------------------------------------------
Static Function frvRegras()
//------------------------------------------------
Local nX
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aAlterFields 	:= {}
Local aFields 		:= {"NOUSER"}
Static grvRegras

  // Get fields from SZ6
  aEval(ApBuildHeader("SZ6", Nil), {|x| Aadd(aFields, x[2])})
  aAlterFields := aClone(aFields)

  // Define field properties
 
  _cAliasSX3 := "SX3_"+GetNextAlias()
  OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
  dbSelectArea(_cAliasSX3)
  (_cAliasSX3)->(dbSetOrder(2))
 
  For nX := 1 to Len(aFields)
    If (_cAliasSX3)->(DbSeek(aFields[nX]))
      Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
                       (_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
    EndIf
  Next nX

  // Define field values
  For nX := 1 to Len(aFields)
    If DbSeek(aFields[nX])
      Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
    EndIf
  Next nX
  Aadd(aFieldFill, .F.)
  Aadd(aColsEx, aFieldFill)

  grvRegras := MsNewGetDados():New( 048, 009, 237, 476, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
                      
  //Chama a função para carregar os itens
  Visualizar(_cCodigo)
Return

Static Function Visualizar(_cCodRep) //Visualização

	_cCodigo 	:= _cCodRep                   
	cxtRepres 	:= _cCodigo
			
	dbSelectArea("SZ6")		
	dbSetOrder(1)
	If dbSeek(xFilial("SZ6") + cxtRepres)
		cxtDescRep := SZ6->Z6_NOMERE
	EndIf
	                     
	linha := 1
	While !EOF() .And. xFilial("SZ6")==SZ6->Z6_FILIAL

 		If cxtRepres <> SZ6->Z6_REPRES
			Exit
 		EndIf
 		
		//Inclui nova linha no aCols                            
		If linha>1
			grvRegras:AddLine()
		EndIf                  

		SZ6->Z6_FILIAL := xFilial("SZ6")
		grvRegras:aCols[linha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_GRPPRO"})]:=	SZ6->Z6_GRPPRO
		grvRegras:aCols[linha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DESCGR"})]:=	SZ6->Z6_DESCGR
		grvRegras:aCols[linha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_PRODUT"})]:=	SZ6->Z6_PRODUT
		grvRegras:aCols[linha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DESCPR"})]:=	SZ6->Z6_DESCPR
		grvRegras:aCols[linha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_PERC"})]  :=	SZ6->Z6_PERC
		grvRegras:aCols[linha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DTINI"})] :=	SZ6->Z6_DTINI
		grvRegras:aCols[linha,aScan(grvRegras:aHeader,{|x|Alltrim(x[2])=="Z6_DTFIM"})] :=	SZ6->Z6_DTFIM              
		linha++
		dbSelectArea("SZ6")	       
		dbSkip()
	EndDo	

	//Inclui nova linha no aCols
	grvRegras:AddLine()
Return()