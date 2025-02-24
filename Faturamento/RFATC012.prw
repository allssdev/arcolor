#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATC012  ºAutor  ³Anderson C. P. Coelho º Data ³  16/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de consulta de Produtos Vendidos por Cliente, dentroº±±
±±º          ³dos ultimos 90 dias.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATC012()

Local oButton1
Local oGroup1
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oSay1
Local oSay2
Local oSay3
Local oSay4

Private _cRotina := "RFATC012"
Private cGet1    := Space(TamSx3("B1_COD"   )[01])
Private cGet2    := Space(TamSx3("B1_DESC"  )[01])
Private cGet3    := Space(TamSx3("A1_EST"   )[01])
Private cGet4    := Space(TamSx3("A1_MUN"   )[01])
Private cGet5    := Space(TamSx3("A1_BAIRRO")[01])
Private cGet6    := Space(TamSx3("A1_COD"   )[01])
Private cGet7    := Space(TamSx3("A1_LOJA")[01])
Private aAux1    := {}
Private aFields1 := {	"D2_COD"    ,;
						"B1_DESC"   ,;
						"D2_QUANT"  ,;
						"D2_EMISSAO",;
						"D2_CLIENTE",;
						"D2_LOJA"   ,;
						"A1_NOME"   ,;
						"A1_END"    ,;
						"A1_BAIRRO" ,;
						"A1_MUN"    ,;
						"A1_EST"    ,;
						"A1_DDD"    ,;
						"A1_TEL"    ,;
						"A1_EMAIL"   }
//Private _nDias   := SuperGetMV('MV_','','90')

dbSelectArea("SA1")
SA1->(dbSetOrder(1))
SA1->(dbGoTop())
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(dbGoTop())

Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Consulta de Produtos por Região"    FROM 000,000 TO 555,0950         COLORS 0, 16777215          PIXEL

//    @ 003, 003 GROUP  oGroup1  TO 272, 472 PROMPT " *** TECLE F5 PARA ATUALIZAR A CONSULTA DOS ÚLTIMOS 90 DIAS *** "  OF oDlg COLOR  0, 16777215          PIXEL
    @ 003, 003 GROUP  oGroup1  TO 272, 472 PROMPT " *** TECLE F5 PARA ATUALIZAR A CONSULTA DOS ÚLTIMOS 12 MESES *** "  OF oDlg COLOR  0, 16777215          PIXEL
    @ 020, 010 SAY    oSay1                PROMPT "Produto:"                          SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
    @ 017, 040 MSGET  oGet1                VAR    cGet1                    F3 "SB1"   SIZE 050, 010 OF oDlg COLORS 0, 16777215          PIXEL
    @ 020, 110 SAY    oSay2                PROMPT "Descrição:"                        SIZE 030, 007 OF oDlg COLORS 0, 16777215          PIXEL
    @ 017, 150 MSGET  oGet2                VAR    cGet2                               SIZE 255, 010 OF oDlg COLORS 0, 16777215          PIXEL

    @ 035, 010 SAY    oSay3                PROMPT "Estado:"                           SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
    @ 032, 040 MSGET  oGet3                VAR    cGet3                    F3 "12"    SIZE 030, 010 OF oDlg COLORS 0, 16777215          PIXEL

    @ 035, 080 SAY    oSay4                PROMPT "Munic.:"                           SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
    @ 032, 105 MSGET  oGet4                VAR    cGet4                               SIZE 130, 010 OF oDlg COLORS 0, 16777215          PIXEL

    @ 035, 250 SAY    oSay5                PROMPT "Bairro:"                           SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
    @ 032, 275 MSGET  oGet5                VAR    cGet5                               SIZE 130, 010 OF oDlg COLORS 0, 16777215          PIXEL

	@ 050, 010 SAY    oSay5                PROMPT "Cliente:"                          SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
    @ 047, 040 MSGET  oGet5                VAR    cGet6        				F3 "SA1"  SIZE 050, 010 OF oDlg COLORS 0, 16777215          PIXEL

	@ 050, 100 SAY    oSay5                PROMPT "Loja:"                             SIZE 020, 007 OF oDlg COLORS 0, 16777215          PIXEL
    @ 047, 125 MSGET  oGet5                VAR    cGet7        					   	  SIZE 030, 010 OF oDlg COLORS 0, 16777215          PIXEL

    @ 017, 430 BUTTON oButton1             PROMPT "Sair"   ACTION Close(oDlg)         SIZE 037, 012 OF oDlg                             PIXEL
    fMSNewGe1()
    SetKey(VK_F5, { || AtuGe1() } )

  ACTIVATE MSDIALOG oDlg CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fMSNewGe1 ºAutor  ³Anderson C. P. Coelho º Data ³  16/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Montagem da GetDados 1                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fMSNewGe1()

Local nX
Local aColsEx      := {}
Local aHeaderEx    := {}
Local aFieldFill   := {}
Local aAlterFields := {}
Local _cAliasSX3 := ""
Static oMSNewGe1

// Define field properties

_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(2))

For nX := 1 To Len(aFields1)
	If (_cAliasSX3)->(dbSeek(aFields1[nX]))
		Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
							(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
		Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
	EndIf
Next nX
Aadd(aFieldFill, .F.)
Aadd(aColsEx, aFieldFill)

aAux1     := aClone(aColsEx)

oMSNewGe1 := MsNewGetDados():New( 060, 007, 274, 467, /*GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AtuGe1     ³ Autores ³ Anderson C. P. Coelho ³ Data ³ 16/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por atualizar o GetDados 1.               ³±±
±±³           ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AtuGe1()

Local _lRet := !Empty(cGet1) .OR. !Empty(cGet2) .OR. !Empty(cGet6)

If _lRet
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If !Empty(cGet1)
		_lRet := ExistCpo("SB1",cGet1,1)
	EndIf
	If _lRet
		MsgRun("Aguarde... localizando informações...",_cRotina,{ || AtuGet1() })
	Else
		cGet1    := Space(TamSx3("B1_COD"   )[01])
		cGet2    := Space(TamSx3("B1_DESC"  )[01])
		cGet3    := Space(TamSx3("A1_EST"   )[01])
		cGet4    := Space(TamSx3("A1_MUN"   )[01])
		cGet5    := Space(TamSx3("A1_BAIRRO")[01])
		cGet6    := Space(TamSx3("A1_COD"   )[01])
		cGet7    := Space(TamSx3("A1_LOJA"	)[01])
	EndIf
Else
	MsgAlert("O produto deve ser informado, antes de mais nada!",_cRotina+"_001")
EndIf

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AtuGet1()  ³ Autores ³ Anderson C. P. Coelho ³ Data ³ 16/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao de atualização do Get Dados 1.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AtuGet1()

Local _x := 0
Local nSA1 := 0
Local nSB1 := 0
Local nSD2 := 0

oMSNewGe1:aCols := {}

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(dbGoTop())
aStruSB1 := SB1->(dbStruct())
dbSelectArea("SA1")
SA1->(dbSetOrder(1))
SA1->(dbGoTop())
aStruSA1 := SA1->(dbStruct())
dbSelectArea("SD2")
SD2->(dbSetOrder(1))
SD2->(dbGoTop())
aStruSD2 := SD2->(dbStruct())

cQry := " SELECT DISTINCT "
For _x := 1 To Len(aFields1)
	If _x > 1
		cQry += ", "
	EndIf
	cQry += aFields1[_x]
Next
cQry +=   CHR(13) + CHR(10)
cQry += " FROM " + RetSqlName("SD2") + " SD2 "                                            + CHR(13) + CHR(10)
cQry += "          INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = '' "      + CHR(13) + CHR(10)
cQry += "                             AND SB1.B1_FILIAL    = '"  + xFilial("SB1") + "' "  + CHR(13) + CHR(10)
If !Empty(cGet1)
	cQry += "                         AND SB1.B1_COD       = '"  + cGet1          + "' "  + CHR(13) + CHR(10)
EndIf
If !Empty(cGet2)
	cQry += "                         AND SB1.B1_DESC   LIKE '%" + AllTrim(cGet2) + "%' " + CHR(13) + CHR(10)
EndIf
cQry += "                             AND SB1.B1_COD       = SD2.D2_COD "                 + CHR(13) + CHR(10)
cQry += "          INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' "      + CHR(13) + CHR(10)
cQry += "                             AND SA1.A1_FILIAL    = '" + xFilial("SA1") + "' "   + CHR(13) + CHR(10)
cQry += "                             AND SA1.A1_MSBLQL   <> '1' "                        + CHR(13) + CHR(10)
If !Empty(cGet3)
	cQry += "                         AND SA1.A1_EST    LIKE '%" + AllTrim(cGet3) + "%' " + CHR(13) + CHR(10)
EndIf
If !Empty(cGet4)
	cQry += "                         AND SA1.A1_MUN    LIKE '%" + Alltrim(cGet4) + "%' " + CHR(13) + CHR(10)
EndIf
If !Empty(cGet5)
	cQry += "                         AND SA1.A1_BAIRRO LIKE '%" + Alltrim(cGet5) + "%' " + CHR(13) + CHR(10)
EndIf
If !Empty(cGet6)
	cQry += "                         AND SA1.A1_COD    = '" + AllTrim(cGet6) + "' " + CHR(13) + CHR(10)
EndIf
If !Empty(cGet7)
	cQry += "                         AND SA1.A1_LOJA   = '" + Alltrim(cGet7) + "' " + CHR(13) + CHR(10)
EndIf
cQry += "                             AND SA1.A1_COD       = SD2.D2_CLIENTE "             + CHR(13) + CHR(10)
cQry += "                             AND SA1.A1_LOJA      = SD2.D2_LOJA    "             + CHR(13) + CHR(10)
cQry += " WHERE SD2.D_E_L_E_T_ = '' "                                                     + CHR(13) + CHR(10)
cQry += "   AND SD2.D2_FILIAL  = '" + xFilial("SD2")     + "' "                           + CHR(13) + CHR(10)
cQry += "   AND SD2.D2_TIPO    = 'N' "                                                    + CHR(13) + CHR(10)
//cQry += "   AND SD2.D2_EMISSAO>= '" + DTOS(dDataBase-(_nDias)) + "' "                     + CHR(13) + CHR(10)
//cQry += "   AND SD2.D2_EMISSAO>= '" + DTOS(dDataBase-90) + "' "                           + CHR(13) + CHR(10)
cQry += "   AND SD2.D2_EMISSAO>= '" + DTOS(dDataBase-365) + "' "                           + CHR(13) + CHR(10)
cQry += "ORDER BY D2_EMISSAO DESC, A1_EST, A1_MUN, A1_BAIRRO, A1_END, A1_NOME "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TR1TMP",.T.,.F.)
For nSB1 := 1 To Len(aStruSB1)
	If aStruSB1[nSB1][2] <> "C" .and.  FieldPos(aStruSB1[nSB1][1]) > 0
		TcSetField("TR1TMP",aStruSB1[nSB1][1],aStruSB1[nSB1][2],aStruSB1[nSB1][3],aStruSB1[nSB1][4])
	EndIf
Next nSB1
For nSA1 := 1 To Len(aStruSA1)
	If aStruSA1[nSA1][2] <> "C" .and.  FieldPos(aStruSA1[nSA1][1]) > 0
		TcSetField("TR1TMP",aStruSA1[nSA1][1],aStruSA1[nSA1][2],aStruSA1[nSA1][3],aStruSA1[nSA1][4])
	EndIf
Next nSA1
For nSD2 := 1 To Len(aStruSD2)
	If aStruSD2[nSD2][2] <> "C" .and.  FieldPos(aStruSD2[nSD2][1]) > 0
		TcSetField("TR1TMP",aStruSD2[nSD2][1],aStruSD2[nSD2][2],aStruSD2[nSD2][3],aStruSD2[nSD2][4])
	EndIf
Next nSD2
dbSelectArea("TR1TMP")
TR1TMP->(dbGotop())
While !TR1TMP->(EOF())
	_aCpos1 := {}
	For _x := 1 To Len(aFields1)
		AADD(_aCpos1,&("TR1TMP->"+aFields1[_x]))
	Next
	AADD(_aCpos1,.F.)
	AADD(oMSNewGe1:aCols,_aCpos1)
	dbSelectArea("TR1TMP")
	TR1TMP->(dbSkip())
EndDo
dbSelectArea("TR1TMP")
TR1TMP->(dbCloseArea())
If Empty(oMSNewGe1:aCols)
//	aadd(oMSNewGe1:aCols,aAux1)
	oMSNewGe1:aCols := aClone(aAux1)
EndIf
oMSNewGe1:Refresh()

Return .T.
