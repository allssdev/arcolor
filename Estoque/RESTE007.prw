#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RESTE007
@description Rotina chamada nos Movimentos Internos mod.2, utilizada para agilizar o processo de digitação das entradas de produtos originados de Documentos de Entrada que utilizaram TES sem controle de estoque ativado.
@obs Por ser apenas uma rotina facilitadora do processo de digitação, esta rotina não prevê a validação do que já foi ou não lido. A validação de duplicidade fica a cargo do usuário, desta maneira.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 17/04/2017
@version 1.0
@type function
@see https://allss.com.br
@history 11/04/2023,  Diego Rodrigues (diego.rodrigues@allss.com.br) - adequação da query e da rotina para inclusão do lote e data de validade.
@history 16/05/2023, Diego Rodrigues (diego.rodrigues@allss.com.br) - Adequação do fonte para validar produto e lote desta forma não somar quantidades quando houver diversas linhas.
@history 22/08/2023, Diego Rodrigues (diego.rodrigues@allss.com.br) - Adequação do fonte para alteração do armazem para produtos do tipo PA, isolando as devoluções no armazem 90
@history 31/08/2023, Diego Rodrigues (diego.rodrigues@allss.com.br) - Adequação do fonte para alteração do preenchimento da Tela para quando for TM 001 direcionar para o armazem 90, TM 002 para o armazem 002
/*/
user function RESTE007()
	Local   oGet1
	Local   oGet2
	Local   oGet3
	Local   oGet4
	Local   oSay1
	Local   oSay2
	Local   oSay3
	Local   oSay4
	Local   oSay5
	Local   oSay6
	Local   oSay7
	Local   oGroup1
	Local   oSButton1
	Local   oSButton2
	Local   _aSavArea  := GetArea()
	Local   _aSavSB1   := SB1->(GetArea())
	Local   _aSavSF1   := SF1->(GetArea())
	Local   _aSavSD1   := SD1->(GetArea())

	Private _cRotina   := "RESTE007"
	Private cGet1      := replicate(" ",len(SF1->F1_SERIE))
	Private cGet2      := replicate(" ",len(SF1->F1_DOC  ))
	Private cGet3      := replicate(" ",len(SB1->B1_COD  ))
	Private cGet4      := replicate("Z",len(SB1->B1_COD  ))
	Private _nCPrd     := aScan(aHeader,{|x| AllTrim(x[02]) == "D3_COD"  })
	Private _nCQtd     := aScan(aHeader,{|x| AllTrim(x[02]) == "D3_QUANT"})
	Private _nClot	   := aScan(aHeader,{|x| AllTrim(x[02]) == "D3_LOTECTL"})
	Private _lVldCpo   := .F.			//ATIVA/DESATIVA A VALIDAÇÃO PADRÃO DOS CAMPOS DA SD3 DURANTE A LEITURA

	if AllTrim(FunName())<>"MATA241"
		return
	endif

	static oDlg

	DEFINE MSDIALOG oDlg TITLE "Movimentos Internos x Documentos de Entrada" FROM 000, 000  TO 250, 500 COLORS 0, 16777215 PIXEL
		@ 006, 007 GROUP oGroup1 TO 114, 243   PROMPT " Seleção de Documento de Entrada "                                                                  OF oDlg COLOR  0, 16777215 PIXEL
		@ 018, 012 SAY     oSay1               PROMPT "Selecione a seguir a série e número do Documento de Entrada que não tenha gerado"     SIZE 225, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 031, 012 SAY     oSay2               PROMPT "Movimentação de Estoque, para preechimento dos Itens de Movimentos Internos para sua" SIZE 225, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 043, 012 SAY     oSay3               PROMPT "conferência e efetivação."                                                            SIZE 225, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 063, 012 SAY     oSay4               PROMPT "Série:"                                                                               SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 061, 042 MSGET   oGet1               VAR    cGet1                                                                                  SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL
		@ 078, 012 SAY     oSay5               PROMPT "Docto.:"                                                                              SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 076, 042 MSGET   oGet2               VAR    cGet2                   VALID NAOVAZIO()                                               SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
		@ 063, 125 SAY     oSay6               PROMPT "Do Produto:"                                                                          SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 061, 160 MSGET   oGet3               VAR    cGet3         F3 "SB1"                                                                 SIZE 075, 010 OF oDlg COLORS 0, 16777215 PIXEL
		@ 078, 125 SAY     oSay7               PROMPT "Ao Produto:"                                                                          SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 076, 160 MSGET   oGet4               VAR    cGet4         F3 "SB1"  VALID NAOVAZIO()                                               SIZE 075, 010 OF oDlg COLORS 0, 16777215 PIXEL
		DEFINE     SBUTTON oSButton1 FROM 096, 125 TYPE 01 OF oDlg ENABLE ACTION Eval( {|| Processa({|lEnd| AtuGet(@lEnd)}, "["+_cRotina+"] Seleção de Documento de Entrada", "Processando informações...",.T.), Close(oDlg) } )
		DEFINE     SBUTTON oSButton2 FROM 096, 207 TYPE 02 OF oDlg ENABLE ACTION Close(oDlg)
	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea(_aSavSF1)
	RestArea(_aSavSD1)
	RestArea(_aSavSB1)
	RestArea(_aSavArea)
return
/*/{Protheus.doc} AtuGet
@description Sub-Rotina de atualização da getdados com os produtos do documento de entrada selecionado.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 17/04/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AtuGet(lEnd)
	local _lValid    := .T.
	local _aTmp      := {}
	local _cValid    := ""
	local _cGroup    := ""
	local _cSelec    := ""
	local _cAliasSX3 := "SX3_"+GetNextAlias()
	local _cSD1TMP   := GetNextAlias()
	local _cRVBkp    := ReadVar()
	local _nBkp      := n
	local nx         := 0
	local _cAmz 	 := SuperGetMV("MV_XAMZDEV",,"90")
	local _cNotaDv   := cGet2
	
	if Select(_cAliasSX3) > 0
		(_cAliasSX3)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
	dbSelectArea(_cAliasSX3)
	if empty(cGet2)
		MsgAlert("Nenhum documento selecionado. Nada a processar!",_cRotina+"_001")
		return
	endif
	if empty(cGet4) .OR. cGet3 > cGet4
		MsgAlert("Problema no range de produtos solicitado. Nada a processar!",_cRotina+"_002")
		return
	endif
	if MsgYesNo("Aglutina itens iguais?",_cRotina+"_003")
		//_cGroup := " GROUP BY D1_COD, SB1.R_E_C_N_O_ , SD3.D3_DOC, SF4.F4_ESTOQUE, SF4.F4_CODIGO "
		//_cSelec += " D1_COD, SB1.R_E_C_N_O_ RECSB1, SUM(D1_QUANT) D1_QUANT , SD3.D3_DOC, SF4.F4_ESTOQUE , SF4.F4_CODIGO"
		_cGroup := " GROUP BY D1_FORNECE,D1_LOJA,D1_COD, D2_LOTECTL, D2_DTVALID, SB1.R_E_C_N_O_, SD3.D3_DOC, SF4.F4_ESTOQUE, SF4.F4_CODIGO, D1_LOTECTL "
		_cSelec += " D1_FORNECE,D1_LOJA,D1_COD, D2_LOTECTL, D2_DTVALID, SB1.R_E_C_N_O_ RECSB1, SUM(D1_QUANT) D1_QUANT, SD3.D3_DOC, SF4.F4_ESTOQUE, SF4.F4_CODIGO, D1_LOTECTL"
	else
		//_cSelec += " D1_COD, SB1.R_E_C_N_O_ RECSB1, D1_QUANT, SD3.D3_DOC, SF4.F4_ESTOQUE, SF4.F4_CODIGO "
		_cSelec += " D1_FORNECE,D1_LOJA,D1_COD, D2_LOTECTL, D2_DTVALID, SB1.R_E_C_N_O_ RECSB1, D1_QUANT, SD3.D3_DOC, SF4.F4_ESTOQUE, SF4.F4_CODIGO, D1_LOTECTL "
	endif
	_cSelec := "%"+_cSelec+"%"
	_cGroup := "%"+_cGroup+"%"
	if Select(_cSD1TMP) > 0
		(_cSD1TMP)->(dbCloseArea())
	endif
	BeginSql Alias _cSD1TMP
		SELECT %Exp:_cSelec%
		FROM %table:SD1% SD1 (NOLOCK) 
			INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%  AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.%NotDel%
			INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%  AND SB1.B1_MSBLQL  <> '1' AND SB1.B1_COD    = SD1.D1_COD AND SB1.%NotDel%
			INNER JOIN %table:SD2% SD2 (NOLOCK) ON SD2.D2_FILIAL = %xFilial:SD2%  AND SD2.D2_DOC = SD1.D1_NFORI AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_COD = SD1.D1_COD AND SD2.D2_ITEM = SD1.D1_ITEMORI
			LEFT  JOIN %table:SD3% SD3 (NOLOCK) ON SD3.D3_FILIAL = %xFilial:SD3%  AND SD3.D3_DOC = D1_DOC AND SD3.D3_COD = D1_COD 
		WHERE SD1.D1_FILIAL       = %xFilial:SD1%
		  AND SD1.D1_DOC          = %Exp:cGet2%
		  AND SD1.D1_SERIE        = %Exp:cGet1%
		  AND SD1.D1_TIPO         = %Exp:"D"%
		  AND SD1.D1_COD    BETWEEN %Exp:cGet3% AND %Exp:cGet4%
		  AND SD1.%NotDel%
		%Exp:_cGroup%
		ORDER BY D1_COD
	EndSql
	dbSelectArea(_cSD1TMP)
	ProcRegua((_cSD1TMP)->(RecCount()))
	(_cSD1TMP)->(dbGoTop())
	if empty((_cSD1TMP)->D3_DOC) 
		if !(_cSD1TMP)->(EOF())
			while !(_cSD1TMP)->(EOF()) .AND. !lEnd
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				SB1->(dbGoTo((_cSD1TMP)->RECSB1))
				IncProc("Processando Produto '"+AllTrim(SB1->B1_COD)+"'...")
				n := aScan(aCols,{|x| x[_nCPrd] == SB1->B1_COD .AND. x[_nClot] == (_cSD1TMP)->D2_LOTECTL })
				if n > 0
					nX               := _nCQtd
					cCampo           := "D3_QUANT"
					__ReadVar        := "M->"+cCampo
	
					(_cAliasSX3)->(dbSetOrder(2))
					if (_cAliasSX3)->(MsSeek(cCampo,.T.,.F.)) .AND. !aCols[n][len(aHeader)+1]
						aCols[n][nx] := &(__ReadVar) := aCols[n][_nCQtd] + (_cSD1TMP)->D1_QUANT
						if !empty(aCols[n][nx])
							_lValid := .T.
							_cValid := AllTrim((_cAliasSX3)->X3_VALID + iif(!empty((_cAliasSX3)->X3_VALID).AND.!empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
							if !empty(_cValid) .AND. _lVldCpo
								_lValid := &_cValid
							endif
							if _lValid
								if ExistTrigger(cCampo)
									RunTrigger(2,n,,cCampo)
									EvalTrigger()
								endif
							else
								aCols[n][len(aHeader)+1] := .T.
								aCols[n][_nCQtd        ] := 0
							endif
						endif
					endif
				else
					if !(Len(aCols) == 1 .AND. empty(aCols[01][_nCPrd]))
						_aTmp  := {}
						// Adiciona item no acols
						AADD(aCols,Array(Len(aHeader)+1))
					endif
					n := len(aCols)
					dbSelectArea("SD3")
					SD3->(dbSetOrder(1))
					RegToMemory("SD3",.T.,.T.,.T.)
					// Preenche conteudo do acols
					aCols[n][len(aHeader)+1] := .F.
					for nx:=1 to len(aHeader)
						cCampo := Alltrim(aHeader[nx,2])
						if IsHeadRec(cCampo)
							aCols[n][nx] := 0
						elseif IsHeadAlias(cCampo)
							aCols[n][nx] := "SD3"
						elseif AllTrim(cCampo) == "D3_COD"
							__ReadVar    := "M->"+AllTrim(cCampo)
							aCols[n][nx] := &(__ReadVar) := SB1->B1_COD
						elseif AllTrim(cCampo) == "D3_DESCRI"
							__ReadVar    := "M->"+AllTrim(cCampo)
							aCols[n][nx] := &(__ReadVar) := SB1->B1_DESC
						elseif AllTrim(cCampo) == "D3_UM"
							__ReadVar    := "M->"+AllTrim(cCampo)
							aCols[n][nx] := &(__ReadVar) := SB1->B1_UM
						elseif AllTrim(cCampo) == "D3_LOCAL"
							__ReadVar    := "M->"+AllTrim(cCampo)
							If SB1->B1_TIPO == "PA" .and. cTM == "001"
								aCols[n][nx] := &(__ReadVar) := _cAmz
							else
								aCols[n][nx] := &(__ReadVar) := SB1->B1_LOCPAD
							EndIf
						elseif AllTrim(cCampo) == "D3_QUANT"
							__ReadVar    := "M->"+AllTrim(cCampo)
							aCols[n][nx] := &(__ReadVar) := (_cSD1TMP)->D1_QUANT
						elseif AllTrim(cCampo) == "D3_LOTECTL"
							__ReadVar    := "M->"+AllTrim(cCampo)
							aCols[n][nx] := &(__ReadVar) := (_cSD1TMP)->D2_LOTECTL
						elseif AllTrim(cCampo) == "D3_DTVALID"
							__ReadVar    := "M->"+AllTrim(cCampo)
							aCols[n][nx] := &(__ReadVar) := STOD((_cSD1TMP)->D2_DTVALID)
						elseif AllTrim(cCampo) == "D3_OBSERVA"
							__ReadVar    := "M->"+AllTrim(cCampo)
							aCols[n][nx] := &(__ReadVar) := "NF DEV: "+_cNotaDv+ " CODFOR: " + (_cSD1TMP)->D1_FORNECE+" "+(_cSD1TMP)->D1_LOJA
						else
							__ReadVar    := "M->"+AllTrim(cCampo)
							aCols[n][nx] := &(__ReadVar) := CriaVar(cCampo,.F.)
						endif
					
						(_cAliasSX3)->(dbSetOrder(2))
						if (_cAliasSX3)->(MsSeek(cCampo,.T.,.F.)) .AND. !empty(aCols[n][nx]) .AND. !aCols[n][len(aHeader)+1]
							_lValid := .T.
							_cValid := AllTrim((_cAliasSX3)->X3_VALID + iif(!empty((_cAliasSX3)->X3_VALID).AND.!empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
							if !empty(_cValid) .AND. _lVldCpo
								_lValid := &_cValid
							endif
							if _lValid
								if ExistTrigger(cCampo)
									RunTrigger(2,n,,cCampo)
									EvalTrigger()
								endif
							else
								aCols[n][len(aHeader)+1] := .T.
								aCols[n][_nCQtd        ] := 0
							endif
						endif
					next nx
				endif
				dbSelectArea(_cSD1TMP)
				(_cSD1TMP)->(dbSkip())
			enddo
		else
			MsgStop("Documento nao Localizado!",_cRotina+"_004")
		endif
	else
		MsgStop("Ja existe movimento interno para este documento!",_cRotina+"_005")
	endif
	if Select(_cSD1TMP) > 0
		(_cSD1TMP)->(dbCloseArea())
	endif
	if Select(_cAliasSX3) > 0
		(_cAliasSX3)->(dbCloseArea())
	endif
	n         := _nBkp
	__ReadVar := _cRVBkp
	if type("oGet") == "O" .AND. type("oGet:oBrowse") == "O"
		oGet:oBrowse:Refresh()
		oGet:Refresh()
	endif
return nil
