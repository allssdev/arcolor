#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RESTE002  ºAutor  ³Anderson C. P. Coelho º Data ³  27/08/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para preencher automaticamente o numeroº±±
±±º          ³da contagem na tela de inventario, de forma automatica.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RESTE002()

Local _aSavArea := GetArea()
Local _cCont    := StrZero(0,TamSx3("B7_CONTAGE")[01])
Local _cChave   := (xFilial("SB7") + DTOS(M->B7_DATA)+M->B7_COD+M->B7_LOCAL+POSICIONE("CBJ",1,xFilial("CBJ")+M->B7_COD+M->B7_LOCAL,"CBJ_ENDERE")/*M->B7_LOCALIZ*/+M->B7_NUMSERI+M->B7_LOTECTL+M->B7_NUMLOTE)
//Local _cQry     := ""

dbSelectArea("SB7")
SB7->(dbSetOrder(1))			//B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
If SB7->(MsSeek(_cChave,.T.,.F.))
	While !SB7->(EOF()) .AND. _cChave   == (xFilial("SB7") + DTOS(SB7->B7_DATA)+SB7->B7_COD+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE)
		_cCont := SB7->B7_CONTAGE
		dbSelectArea("SB7")
		SB7->(dbSetOrder(1))
		SB7->(dbSkip())
	EndDo
EndIf
/*
_cQry := " SELECT MAX(B7_CONTAGE) CONTAGEM "
_cQry += " FROM " + RetSqlName("SB7") + " SB7 "
_cQry += " WHERE SB7.D_E_L_E_T_ = '' "
_cQry += "   AND SB7.B7_FILIAL  = '" + xFilial("SB7") + "' "
_cQry += "   AND SB7.B7_DATA    = '" + M->B7_DATA     + "' "
_cQry += "   AND SB7.B7_COD     = '" + M->B7_COD      + "' "
_cQry += "   AND SB7.B7_LOCAL   = '" + M->B7_LOCAL    + "' "
_cQry += "   AND SB7.B7_LOCALIZ = '" + M->B7_LOCALIZ  + "' "
_cQry += "   AND SB7.B7_NUMSERI = '" + M->B7_NUMSERI  + "' "
_cQry += "   AND SB7.B7_LOTECTL = '" + M->B7_LOTECTL  + "' "
_cQry += "   AND SB7.B7_NUMLOTE = '" + M->B7_NUMLOTE  + "' "
_cQry := ChangeQuery(_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SB7TMP",.T.,.T.)

dbSelectArea("SB7TMP")
If !SB7TMP->(EOF()) .AND. !Empty(SB7TMP->B7_CONTAGE)
	_cCont := SB7TMP->B7_CONTAGE
EndIf
SB7TMP->(dbCloseArea())
*/

_cCont := Soma1(_cCont)

RestArea(_aSavArea)

Return(_cCont)