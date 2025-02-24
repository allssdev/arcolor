#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _CRLF CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RESTE006  ºAutor  ³Anderson C. P. Coelho º Data ³  03/02/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de leitura do código de barras de produtos (B1_COD) º±±
±±º          ³nos movimentos internos.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcólor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RESTE006()

Local oGroup1
Local _aSavArea  := GetArea()
Local _aSavSB1   := SB1->(GetArea())

Private oGet1
Private oGet2
Private _cRotina := "RESTE006"
Private cGet1    := Space(TamSx3("B1_COD")[01])
Private cGet2    := " "
Private _cLogPrd := ""
Private _nCPrd   := aScan(aHeader,{|x| AllTrim(x[02]) == "D3_COD"  })
Private _nCQtd   := aScan(aHeader,{|x| AllTrim(x[02]) == "D3_QUANT"})
Private _lVldCpo := .F.			//ATIVA/DESATIVA A VALIDAÇÃO PADRÃO DOS CAMPOS DA SD3 DURANTE A LEITURA

If AllTrim(FunName())<>"MATA241"
	Return
EndIf

Static oDlg

  DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] Leitura de Código de Barras de Produto" FROM 000, 000  TO 100, 300 COLORS 0, 16777215 PIXEL

    @ 004, 002 GROUP oGroup1 TO 044, 147 PROMPT " Informe o Código de Barras do Produto " OF oDlg COLOR 0, 16777215 PIXEL
    @ 021, 009 MSGET oGet2 VAR cGet2                                                     SIZE 000, 000 OF oDlg COLORS 0, 16777215 PIXEL
    @ 021, 009 MSGET oGet1 VAR cGet1 Valid VALCODBAR()  Picture PesqPict("SB1","B1_COD") SIZE 127, 010 OF oDlg COLORS 0, 16777215 PIXEL
	oGet1:SetFocus()
  ACTIVATE MSDIALOG oDlg CENTERED

If !Empty(_cLogPrd)
	MsgAlert("Atenção! Os seguintes códigos de barras foram lidos mas não encontrados no cadastro de produtos do sistema:" + _CRLF + _cLogPrd,_cRotina+"_001")
EndIf

RestArea(_aSavSB1)
RestArea(_aSavArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VALCODBAR ºAutor  ³Anderson C. P. Coelho º Data ³  03/02/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-Rotina de validação da leitura do código de barras.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VALCODBAR()

Local _lRet   := .T.
Local _lValid := .T.
Local _aTmp   := {}
Local _cValid := ""
Local _nBkp   := n
Local _cRVBkp := ReadVar()
Local _cAliasSX3 := "SX3_"+GetNextAlias()

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1") + Padr(cGet1,TamSx3("B1_COD")[01]),.T.,.F.))
	n := aScan(aCols,{|x| x[_nCPrd] == SB1->B1_COD })
	If n > 0
		nX               := _nCQtd
		cCampo           := "D3_QUANT"
		__ReadVar        := "M->D3_QUANT"
		
		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		dbSelectArea(_cAliasSX3)
		(_cAliasSX3)->(dbSetOrder(2))
		If (_cAliasSX3)->(MsSeek(cCampo,.T.,.F.)) .AND. !aCols[n][Len(aHeader)+1]
			aCols[n][nx] := &(__ReadVar) := aCols[n][_nCQtd] + 1
			If !Empty(aCols[n][nx])
				_lValid := .T.
				_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
				If !Empty(_cValid) .AND. _lVldCpo
					_lValid := &_cValid
				EndIf
				If _lValid
					If ExistTrigger(cCampo)
						RunTrigger(2,n,,cCampo)
						EvalTrigger()
					EndIf
				Else
					aCols[n][Len(aHeader)+1] := .T.
					aCols[n][_nCQtd        ] := 0
				EndIf
			EndIf
		EndIf
		
	Else
		If !(Len(aCols) == 1 .AND. Empty(aCols[01][_nCPrd]))
			_aTmp  := {}
			// Adiciona item no acols
			AADD(aCols,Array(Len(aHeader)+1))
		EndIf
		n := Len(aCols)
		dbSelectArea("SD3")
		SD3->(dbSetOrder(1))
		RegToMemory("SD3",.T.,.T.,.T.)
		// Preenche conteudo do acols
		aCols[n][Len(aHeader)+1] := .F.
		For nx:=1 To Len(aHeader)
			cCampo := Alltrim(aHeader[nx,2])
			If IsHeadRec(cCampo)
				aCols[n][nx] := 0
			ElseIf IsHeadAlias(cCampo)
				aCols[n][nx] := "SD3"
			ElseIf AllTrim(cCampo) == "D3_COD"
				__ReadVar    := "M->"+AllTrim(cCampo)
				aCols[n][nx] := &(__ReadVar) := SB1->B1_COD
			ElseIf AllTrim(cCampo) == "D3_DESCRI"
				__ReadVar    := "M->"+AllTrim(cCampo)
				aCols[n][nx] := &(__ReadVar) := SB1->B1_DESC
			ElseIf AllTrim(cCampo) == "D3_UM"
				__ReadVar    := "M->"+AllTrim(cCampo)
				aCols[n][nx] := &(__ReadVar) := SB1->B1_UM
			ElseIf AllTrim(cCampo) == "D3_LOCAL"
				__ReadVar    := "M->"+AllTrim(cCampo)
				aCols[n][nx] := &(__ReadVar) := SB1->B1_LOCPAD
			ElseIf AllTrim(cCampo) == "D3_QUANT"
				__ReadVar    := "M->"+AllTrim(cCampo)
				aCols[n][nx] := &(__ReadVar) := 1
			Else
				__ReadVar    := "M->"+AllTrim(cCampo)
				aCols[n][nx] := &(__ReadVar) := CriaVar(cCampo,.F.)
			EndIf
	
			OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))
			If (_cAliasSX3)->(MsSeek(cCampo,.T.,.F.)) .AND. !Empty(aCols[n][nx]) .AND. !aCols[n][Len(aHeader)+1]
				_lValid := .T.
				_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
				If !Empty(_cValid) .AND. _lVldCpo
					_lValid := &_cValid
				EndIf
				If _lValid
					If ExistTrigger(cCampo)
						RunTrigger(2,n,,cCampo)
						EvalTrigger()
					EndIf
				Else
					aCols[n][Len(aHeader)+1] := .T.
					aCols[n][_nCQtd        ] := 0
				EndIf
			EndIf
						
		Next nx
	EndIf
Else
	_cLogPrd += cGet1 + _CRLF
EndIf

cGet1 := Space(TamSx3("B1_COD")[01])
oGet1:SetFocus()

n         := _nBkp
__ReadVar := _cRVBkp

oGet:oBrowse:Refresh()
oGet:Refresh()

Return(_lRet)