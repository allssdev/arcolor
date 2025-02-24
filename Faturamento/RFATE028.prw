#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATE028  ºAutor  ³Júlio Soares        º Data ³  05/11/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock criado para montagem da tela onde serão imputadosº±±
±±º          ³ os parâmetros para exclusão da nota de saída               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.(CD Control º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºRelação   ³ Essa rotina tem relação com o Execblock RFATE028, RFATE029,º±±
±±º          ³ e os pontos de entrada M520QRY, M520FIL e M520BROW.        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE028(_nOpc)

Local _aSavArea := GetArea()
Local _aSavSF2  := SF2->(GetArea())
Local _aSavSD2  := SD2->(GetArea())
Local _aSavSC5  := SC5->(GetArea())
Local oCancela
Local oConfirma
Local oSay1
Local Pedido
Local oData1
Local oData2
Private _cRotina  := "RFATE028"
Private _lRet     := .F.
Public _cFilSF2   := " F2_FILIAL == '##' "
Public _cNota
Public _cPedido
Public _dData1
Public _dData2
Default _nOpc     := 1

If _nOpc == 1
	_cPedido  := Space(TamSx3("C5_NUM" )[01])
	_dData1   := MV_PAR03
	_dData2   := MV_PAR04
	_cNota    := Space(TamSx3("F2_DOC" )[01])
	Static  oDlg
	DEFINE MSDIALOG oDlg TITLE "Exclusao de N.Fiscais" FROM 000, 000  TO 220, 220 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME // Inibe o botao "X" da tela
		oDlg:lEscClose := .F.//Não permite fechar a tela com o "Esc"
	    @ 005, 005 SAY     oSay1       PROMPT "Informe o numero do pedido referente ao documento a ser excluido"    SIZE 100, 017 OF oDlg COLORS 0, 16777215   PIXEL
	    @ 030, 012 MSGET   Pedido      VAR _cPedido /*F3 "SC5"*/  VALID ExistCpo("SC5",_cPedido) SIZE 080, 012 OF oDlg COLORS 0, 16777215   PIXEL
//	    @ 050, 012 MSGET   oData1      VAR _dData1                                           SIZE 080, 012 OF oDlg COLORS 0, 16777215   PIXEL
//	    @ 070, 012 MSGET   oData2      VAR _dData2                                           SIZE 080, 012 OF oDlg COLORS 0, 16777215   PIXEL
	    @ 090, 065 BUTTON  oConfirma   PROMPT "Confirma"                                     SIZE 037, 015 OF oDlg ACTION Gravar(_nOpc) PIXEL
//	    @ 090, 022 BUTTON  oCancela    PROMPT "Cancela"                                      SIZE 037, 015 OF oDlg ACTION Cancelar()    PIXEL
    
    ACTIVATE MSDIALOG oDlg CENTERED
ElseIf _nOpc == 2
	Gravar(_nOpc)
EndIf

RestArea(_aSavArea)
RestArea(_aSavSF2)
RestArea(_aSavSD2)
RestArea(_aSavSC5)

Return({_cFilSF2,_cNota})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Cancelar  ºAutor  ³Júlio Soares        º Data ³  31/01/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-rotina de cancelamento (SEM USO NESTE PONTO DE ENTRADA)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Cancelar()

If MsgYesNo("Deseja realmente cancelar?",_cRotina+"_001")
	_cNota := "000000000000"
	dbSelectArea("SF2")
	dbSetOrder(1)
	SET FILTER TO (SF2->F2_DOC+SF2->F2_SERIE) == _cNota
	dbFilter()
	If _nOpc==1
		Close(oDlg)
	EndIf
	Return(_lRet)
EndIf

Return() //Colocar EXIT para sair da rotina.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gravar    ºAutor  ³Júlio Soares        º Data ³  31/01/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub-rotina de gravação                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Gravar(_nOpc)

_cFilSF2 := ""
_cNota   := ""

If (_nOpc==2 .OR. MsgBox("Deseja prosseguir com o cancelamento das notas?",_cRotina+"_002","YESNO")) .AND. ;
	Type("_cPedido")=="C" .AND. !Empty(_cPedido)      .AND. ;
	Type("_dData1" )=="D" .AND. !Empty(_dData1 )      .AND. ;
	Type("_dData2" )=="D" .AND. !Empty(_dData2 )
	BeginSql Alias "SD2TMP"
		SELECT DISTINCT (D2_DOC+D2_SERIE) DOCTO
		FROM %table:SD2% SD2
		WHERE SD2.D2_FILIAL  = %xFilial:SD2%
		  AND SD2.D2_PEDIDO  = %Exp:_cPedido%
		  AND SD2.D2_EMISSAO BETWEEN %Exp:DTOS(_dData1)% AND %Exp:DTOS(_dData2)%
		  AND SD2.%NotDel%
	EndSql
	dbSelectArea("SD2TMP")
	If !(SD2TMP->(EOF()))
		While !SD2TMP->(EOF())
			If !SD2TMP->DOCTO$_cNota
				If !Empty(_cNota)
					_cNota += "/"
				EndIf
				_cNota += SD2TMP->DOCTO
			EndIf
			dbSelectArea("SD2TMP")
			SD2TMP->(dbSkip())
		EndDo
		If !Empty(_cNota)
			_cFilSF2 := "      F2_FILIAL        == '"+xFilial("SF2")                +"'"
			_cFilSF2 += ".AND. F2_SCOA          == '"+Padr("",TamSx3("F2_SCOA")[01])+"'"
			_cFilSF2 += ".AND. DTOS(F2_EMISSAO) >= '"+DTOS(_dData1)                 +"'"
			_cFilSF2 += ".AND. DTOS(F2_EMISSAO) <= '"+DTOS(_dData2)                 +"'"
			_cFilSF2 += ".AND. (F2_DOC+F2_SERIE) $ '"+_cNota                        +"'"
		Else
			_cNota   := "000000000000"
			_cFilSF2 := "(F2_DOC+F2_SERIE) == '"+_cNota+"'"
		EndIf
	Else
		_cNota   := "000000000000"
		_cFilSF2 := "(F2_DOC+F2_SERIE) == '"+_cNota+"'"
	EndIf
	dbSelectArea("SD2TMP")
	SD2TMP->(dbCloseArea())
Else
	_cNota   := "000000000000"
	_cFilSF2 := "(F2_DOC+F2_SERIE) == '"+_cNota+"'"
EndIf
//dbSelectArea("SF2")
//SF2->(dbSetOrder(1))
//If _nOpc == 2
//	SF2->(dbClearFilter())
//	SF2->(dbSetFilter({ || &(_cFilSF2) }, _cFilSF2 ))
//	Set Filter To _cFilSF2
//	SF2->(dbFilter())
//EndIf

If _nOpc == 1
	Close(oDlg)
EndIf

Return()

/*
If _nOpc==1
	If Empty(_cNota)
		_cNota := "000000000000"
	Else
		_cNota += "'"
	EndIf
	Close(oDlg)
Else
	If Empty(_cNota)
		_cNota := "000000000000"
	Else
		_cNota := StrTran(_cNota,"','","|")
		_cNota := StrTran(_cNota,"'"  ,"|")
	EndIf
	dbSelectArea("SF2")
	dbSetOrder(1)
	SET FILTER TO	SF2->F2_FILIAL        == xFilial("SF2")                 .AND. ;
					SF2->F2_SCOA          == Padr("",TamSx3("F2_SCOA")[01]) .AND. ;
					DTOS(SF2->F2_EMISSAO) >= DTOS(_dData1)                  .AND. ;
					DTOS(SF2->F2_EMISSAO) <= DTOS(_dData2)                  .AND. ;
					(SF2->F2_DOC+SF2->F2_SERIE) $ _cNota
	dbFilter()
EndIf
*/