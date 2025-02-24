#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "VKEY.CH"

#define _clrf CHR(13) + CHR(10)

/*/{Protheus.doc} RFATA021
    Rotina para realizar consulta do Status das Ordens de Separação
    @type  Function
    @author Diego Rodrigues
    @since 16/07/2024
    @version 1.0
    /*/
user function RFATA021()
	Local _aSavArea := GetArea()
    Local aSizeAut  := MsAdvSize(,.F.,400)
	Local _cNumPed  := CriaVar("C5_NUM",.F.)
	Private aAux1     := {}
	Private aAux2     := {}
	Private aFields1  := {"C5_NUM","C5_NOMCLI","C9_ORDSEP"}
	Private oFont2    := TFont():New('Calibri',,-15,.T.)

	Private aFields2  := {	"CB9_ORDSEP",; 
							"CB9_PROD",;
							"CB9_QTESEP",;
							"CB9_LOTECT",;
							"B8_LOTECTL",;
							"B8_SALDO",;
							"B8_EMPENHO" }

    aObjects := {}
    AAdd( aObjects, { 0,    41, .T., .F. } )
    AAdd( aObjects, { 100, 100, .T., .T. } )
    aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
        {{10,40,105,140,200,234,275,200,225,260,285,265},;
        If(cPaisLoc<>"PTG",{10,40,105,140,200,234,63},{10,40,101,120,175,205,63,250,270}),;
        Iif(cPaisLoc<>"PTG",{5,70,160,205,295},{5,50,120,145,205,245,293}),;
        {6,34,200,215},;
        {6,34,80,113,160,185},;
        {6,34,245,268,260},;
        {10,50,150,190},;
        {273,130,190},;
        {8,45,80,103,139,173,200,235,270},;
        {133,190,144,190,289,293},;
        {142,293,140},;
        {9,47,188,148,9,146} } )

    oDlg := TDialog():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],"",,,,,CLR_BLACK,CLR_WHITE,,,.T.) 

        otMultiBtn := tMultiBtn():New( 10,20,'Saldos Por Pedido',oDlg,,300,150, 'ACDIMG32.PNG',0,'Mensagem',3 ) //FWBY_LM_INTERACAO.PNG 
        otMultiBtn:SetFonts('Tahoma',16,'Tahoma',10)
        otMultiBtn:AddButton('Sai&r')
        otMultiBtn:bAction := {|x,y| RPCPA05M(y) }
  
		oGetPrd := TGet():Create(oDlg,{|u| If(Pcount()>0,_cNumPed:=u,_cNumPed)},020, aPosObj[2,4]-200,150,011,,{|x| .T. },,,,,,.T.,,,,,,,,,,"_cNumPed",,,,,,,"Pesquisar Pedido: ",1 )
		oGetPrd:cF3 := "SC5" 

		cEstilo1 := "QPushButton {"  
		cEstilo1 += " background-image: url(rpo:FILTRO1_MDI.PNG);background-repeat: none; margin: 2px;" 
		cEstilo1 += " border-style: outset;"
		cEstilo1 += " border-width: 2px;"
		cEstilo1 += " border: 1px solid #C0C0C0;"
		cEstilo1 += " border-radius: 5px;"
		cEstilo1 += " border-color: #C0C0C0;"
		cEstilo1 += " font: bold 12px Arial;"
		cEstilo1 += " padding: 6px;"
		cEstilo1 += "}"

		oBtnImprimir := TButton():New(023, aPosObj[2,4]-50,"      "	,oDlg,;
		{|| RFATA20P(_cNumPed) },;
		17,17,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtnImprimir:SetCss(cEstilo1) 

		oSayPrd  := TSay():New(aPosObj[1][3]-20,aPosObj[2,2],{||'Pedidos:'},oDlg,,oFont2,,,,.T.,CLR_BLACK ,CLR_WHITE,200,20)

	    GridPrd()

		oSayOrd  := TSay():New(aPosObj[1][3]+110,aPosObj[2,2],{||'Produtos com divergencia:'},oDlg,,oFont2,,,,.T.,CLR_BLACK ,CLR_WHITE,200,20)

	    GridSep()

		AtuGe1()

	oDlg:Activate(,,,.T.,{||/*saindo*/,.T.},,{||/*iniciando*/} )

	RestArea(_aSavArea)
return

/*/{Protheus.doc} GridPrd
Rotina de Montagem da GetDados 1 da rotina RFATA021.
@author Fernando Bombardi
@since 06/07/2023
@version 1.0
@type function

/*/
static function GridPrd()
	local   nX
	local   aColsEx      := {}
	local   aHeaderEx    := {}
	local   aFieldFill   := {}
	local   aAlterFields := {}
	local   _cAliasSX3   := "SX3_"+GetNextAlias()

	static oGridPrd

		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		if Select(_cAliasSX3) > 0
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))
			for nX := 1 to len(aFields1)
				if (_cAliasSX3)->(MsSeek(aFields1[nX],.T.,.F.))
					Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
										(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
					if AllTrim((_cAliasSX3)->X3_CAMPO) == "C5_NUM"
						Aadd(aFieldFill, Space(06)             )
					else
						Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
					endif
				endif
			next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aAux1     := aClone(aColsEx)
			oGridPrd := MsNewGetDados():New( aPosObj[1][3]-10,aPosObj[2,2]-3,aPosObj[2,3]-160,aPosObj[2,4]+5, /*GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 9999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
			oGridPrd:bChange := {|| AtuGe2() }
		endif
		(_cAliasSX3)->(dbCloseArea())

return

/*/{Protheus.doc} GridSep
Rotina de Montagem da GetDados 2 da rotina RFATA021.
@author Fernando Bombardi
@since 06/07/2023
@version 1.0
@type function

/*/
static function GridSep()
	local   nX
	local   aColsEx      := {}
	local   aHeaderEx    := {}
	local   aFieldFill   := {}
	local   aAlterFields := {}
	local   _cAliasSX3   := "SX3_"+GetNextAlias()

	static oGridSep

		OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
		if Select(_cAliasSX3) > 0
			dbSelectArea(_cAliasSX3)
			(_cAliasSX3)->(dbSetOrder(2))
			For nX := 1 To Len(aFields2)
				if (_cAliasSX3)->(MsSeek(aFields2[nX],.T.,.F.))
					Aadd(aHeaderEx, {AllTrim((_cAliasSX3)->X3_TITULO),(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_PICTURE,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL,(_cAliasSX3)->X3_VALID,;
										(_cAliasSX3)->X3_USADO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_F3,(_cAliasSX3)->X3_CONTEXT,(_cAliasSX3)->X3_CBOX,(_cAliasSX3)->X3_RELACAO})
					Aadd(aFieldFill, CriaVar((_cAliasSX3)->X3_CAMPO))
				endif
			next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aAux2     := aClone(aColsEx)
			oGridSep := MsNewGetDados():New( aPosObj[1][3]+120,aPosObj[2,2]-3,aPosObj[2,3],aPosObj[2,4]+5, /*GD_INSERT+GD_DELETE+GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+ZA_ITEM", aAlterFields,, 9999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
		endif
		(_cAliasSX3)->(dbCloseArea())

return

/*/{Protheus.doc} AtuGe1
Rotina responsavel por atualizar o GetDados 1.
@author Fernando Bombardi
@since 06/07/2023
@version 1.0
@type function

/*/
static function AtuGe1()

	AtuGet1()
	AtuGet2()

return
/*/{Protheus.doc} AtuGet1
Rotina de atualiza??o do Get Dados 1.
@author Fernando Bombardi
@since 06/07/2023
@version 1.0
@type function

/*/
static function AtuGet1()
	local   _x        := 0
	local   _cTR1TMP  := GetNextAlias()
	local   cQry      := ""
	oGridPrd:aCols   := {}

	cQry := " SELECT "
	for _x := 1 to len(aFields1)
		if _x > 1
			cQry += ", "
		endif
		cQry += aFields1[_x]
	next
	cQry += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) " + _clrf
    cQry += " INNER JOIN " + RetSqlName("SC9") + " SC9 (NOLOCK) ON C9_PEDIDO = C5_NUM "              + _clrf
	cQry += "                                                      AND C9_NFISCAL = '' "             + _clrf
    cQry += "                                                      AND C9_ORDSEP <> '' "             + _clrf
	cQry += "                                                      AND SC9.D_E_L_E_T_ = '' "         + _clrf
	cQry += " WHERE SC5.C5_FILIAL  = '" + xFilial("SC5") + "' " + _clrf
	cQry += "   AND SC5.C5_NOTA = '' "                          + _clrf
	cQry += "   AND SC5.D_E_L_E_T_ = '' "                       + _clrf
    cQry += " GROUP BY C5_NUM,C5_NOMCLI, C9_ORDSEP "            + _clrf
	cQry += " ORDER BY C5_NUM "                                 + _clrf
	if Select(_cTR1TMP) > 0
		(_cTR1TMP)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cTR1TMP,.T.,.F.)

	dbSelectArea(_cTR1TMP)
	(_cTR1TMP)->(dbGoTop())
	While !(_cTR1TMP)->(EOF())
		_aCpos1 := {}
		for _x  := 1 To Len(aFields1)
			AADD(_aCpos1,&(_cTR1TMP+"->"+aFields1[_x]))
		next
		AADD(_aCpos1,.F.)
		AADD(oGridPrd:aCols,_aCpos1)
		(_cTR1TMP)->(dbSkip())
	enddo
	if Select(_cTR1TMP) > 0
		(_cTR1TMP)->(dbCloseArea())
	endif
	if empty(oGridPrd:aCols)
		oGridPrd:aCols := aClone(aAux1)
	endif
	oGridPrd:Refresh()
return .T.

/*/{Protheus.doc} AtuGe2
Rotina responsavel por atualizar o GetDados 2.
@author Fernando Bombardi
@since 06/07/2023
@version 1.0
@type function

/*/
static function AtuGe2()
	AtuGet2()
return .T.

/*/{Protheus.doc} AtuGet2
Rotina de atualiza??o do Get Dados 2.
@author Fernando Bombardi
@since 06/07/2023
@version 1.0
@type function

/*/
static function AtuGet2()
	local   _x        := 0
	local   _cTR2TMP  := GetNextAlias()
	local   cQry      := ""
	oGridSep:aCols   := {}

	cQry := " SELECT "
	for _x := 1 To Len(aFields2)
		if _x > 1
			cQry += ", "
		endif
		cQry += aFields2[_x]
	next
	cQry += " FROM " + RetSqlName("CB9") + " CB9 (NOLOCK) "                                                              + _clrf
	cQry += "     LEFT OUTER JOIN " + RetSqlName("SB8") + " SB8 (NOLOCK) ON SB8.B8_PRODUTO = CB9.CB9_PROD "              + _clrf
	cQry += "                                                           AND B8_LOTECTL = CB9_LOTECT "                    + _clrf
    cQry += "                                                           AND B8_LOCAL = CB9_LOCAL "                       + _clrf
	cQry += "                                                           AND SB8.D_E_L_E_T_ = '' "                        + _clrf
	cQry += " WHERE CB9.CB9_FILIAL  = '" + xFilial("CB9") + "' "                                                         + _clrf
	cQry += "   AND CB9.CB9_PEDIDO    = '" + oGridPrd:aCols[oGridPrd:nAT,aScan(aFields1,{|x|AllTrim(x)=="C5_NUM"})] + "' " + _clrf
	cQry += "   AND (B8_SALDO-B8_EMPENHO) < CB9_QTESEP "            + _clrf
	cQry += "   AND CB9.D_E_L_E_T_ = '' "                           + _clrf
	cQry += "   ORDER BY CB9_PROD"                                  + _clrf
	if Select(_cTR2TMP) > 0
		(_cTR2TMP)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cTR2TMP,.T.,.F.)

	dbSelectArea(_cTR2TMP)
	(_cTR2TMP)->(dbGoTop())
	if !(_cTR2TMP)->(EOF())
		while !(_cTR2TMP)->(EOF())
			_aCpos2 := {}
			for _x := 1 to len(aFields2)
				AADD(_aCpos2,&(_cTR2TMP+"->"+aFields2[_x]))
			next
			AADD(_aCpos2,.F.)
			AADD(oGridSep:aCols,_aCpos2)
			(_cTR2TMP)->(dbSkip())
		enddo
	else
		oGridSep:aCols := aClone(aAux2)
	endif

	oGridSep:oBrowse:Refresh()
return .T.

/*/{Protheus.doc} RPCPA05M
//TODO Função para definição de menu.
@author Fernando Bombardi
@since 06/07/2023
@version 1.0

@type function
/*/
Static Function RPCPA05M(_nBtSel)

    DO CASE
        CASE _nBtSel == 1
            oDlg:End()
    END CASE

Return

/*/{Protheus.doc} RFATA20P
	Rotina para pesquisar produto no grid
	@type  Static Function
	@author Fernando Bombardi
	@since 06/07/2023
	@version 1.0
/*/
Static Function RFATA20P(_cNumPed)
Local _nItPrd  := 0
Local _nPosNum := aScan(aFields1,{|x|AllTrim(x)=="C5_NUM"})
Local _lLocPrd := .F.
Local _cLimpa  := CriaVar("B1_COD",.F.) 

For _nItPrd := 1 to len(oGridPrd:aCols)
	if Alltrim(oGridPrd:aCols[_nItPrd,_nPosNum]) == Alltrim(_cNumPed)
		oGridPrd:oBrowse:nAT := _nItPrd
		oGridPrd:oBrowse:Refresh()
		AtuGet2()
		oDlg:Refresh()
		oGetPrd:cText := _cLimpa
		_lLocPrd := .T.
	endif
Next

if !_lLocPrd
	MsgALert("O pedido não foi localizado! Verifique o código informado no campo de pesquisa.","[RFATA021_001] - Atenção")
	oGetPrd:cText := _cLimpa
	oGetPrd:SetFocus()
endif

Return
