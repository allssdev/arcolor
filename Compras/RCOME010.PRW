#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RCOME010  ºAutor  ³Júlio Soares       º Data ³  10/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock criado para alterar o fornecedor do pedido       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para empresa Arcolor               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCOME010()

Private _aSavArea := GetArea()
Private _cRotina   := "RCOME010"
Private _cNum      := SC7->C7_NUM
Private _cCod
Private _cFornDesc
Private _gCodForn
Private cgCodForn  := SC7->C7_FORNECE		//Space("SC7->C7_FORNECE")
Private _cLoja
Private _gCodLoja
Private cgCodLoja  := SC7->C7_LOJA			//Space("SC7->C7_LOJA")
Private _gForn
Private FornDescri
Private cornDescri := SC7->C7_NOMEFOR		//Space("SC7->C7_NOMEFOR")
Private _cCancela
Private _Confirm
Private _cContato := SC7->C7_CONTATO

/*
_cQuery:= " SELECT COUNT(TMP.C7_NUM) [PEDIDO] "
_cQuery+= " FROM ( SELECT DISTINCT C7_NUM,C7_QUJE,C7_QTDACLA,C7_RESIDUO "
_cQuery+= "        FROM " + RetSqlName("SC7") + " SC7 "
_cQuery+= "        WHERE SC7.C7_FILIAL  = '" + xFilial("SC7") + "' "
_cQuery+= "          AND SC7.C7_NUM     = '" + _cNum + "' "
_cQuery+= "          AND SC7.C7_QUJE    = 0 "
_cQuery+= "          AND SC7.C7_QTDACLA = 0 "
_cQuery+= "          AND SC7.C7_RESIDUO = '' "
_cQuery+= "          AND SC7.D_E_L_E_T_ = '' "
_cQuery+= "      ) TMP "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TMPSC7",.T.,.F.)
*/

BeginSql Alias "TMPSC7"
	SELECT COUNT(TMP.C7_NUM) [PEDIDO]
	FROM ( SELECT DISTINCT C7_NUM,C7_QUJE,C7_QTDACLA,C7_RESIDUO
	       FROM %table:SC7% SC7                  
	       WHERE SC7.C7_FILIAL  = %xFilial:SC7%
	         AND SC7.C7_NUM     = %Exp:_cNum%
	         AND SC7.C7_QUJE    = 0
	         AND SC7.C7_QTDACLA = 0
	         AND SC7.C7_RESIDUO = ''
	         AND SC7.%NotDel%
	     ) TMP 
EndSql

dbSelectArea("TMPSC7")
If (TMPSC7->(PEDIDO)) == 1
	_lRet := .T.
	Altera()
	TMPSC7->(dbCloseArea())	
Else
	_lRet:= .F.
	MSGBOX('Não é possível alterar as informações do pedido pois o mesmo não se encontra em aberto.',_cRotina+'_000','STOP')
	TMPSC7->(dbCloseArea())
EndIf

RestArea(_aSavArea)

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Altera    ºAutor  ³Júlio Soares       º Data ³  10/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock criado para alterar o fornecedor do pedido       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Altera()

Static oDlg

If MSGBOX('DESEJA ALTERAR AS INFORMAÇÕES DO PEDIDO: '+ Alltrim(_cNum) +' ?',_cRotina + '_001','YESNO')
	dbSelectArea("SC7")
	SC7->(dbsetOrder(3))
	If SC7->(MsSeek(xFilial("SC7")+cgCodForn+cgCodLoja+_cNum,.T.,.F.))
		DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 215, 350 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME// Inibe o botao "X" da tela
		oDlg:lEscClose := .F.//Não permite fechar a tela com o "Esc"
	    @ 005, 007 GROUP _gForn TO 085, 165 PROMPT "Altera dados do fornecedor" OF oDlg COLOR 8404992, 16777215                      PIXEL
	    @ 015, 012 SAY _cCod                PROMPT "Codigo"       SIZE 027, 010 OF oDlg COLORS 0, 16777215                           PIXEL
	    @ 015, 075 SAY _cLoja               PROMPT "Loja"         SIZE 025, 012 OF oDlg COLORS 0, 16777215                           PIXEL
	    @ 027, 012 MSGET _gCodForn          VAR cgCodForn         SIZE 050, 012 OF oDlg COLORS 0, 16777215 F3 "SA2" VALID VALIDSA2() PIXEL
	    @ 027, 075 MSGET _gCodLoja          VAR cgCodLoja         SIZE 025, 012 OF oDlg COLORS 0, 16777215 VALID VALIDSA2()          PIXEL
	    @ 045, 012 SAY _cFornDesc           PROMPT "Fornecedor"   SIZE 050, 010 OF oDlg COLORS 0, 16777215                           PIXEL
	    @ 060, 012 MSGET FornDescri         VAR cornDescri        SIZE 147, 010 OF oDlg COLORS 0, 16777215 READONLY WHEN .F.         PIXEL
	    @ 090, 050 BUTTON _cCancela         PROMPT "Cancela"      SIZE 050, 012 OF oDlg ACTION Cancela()                             PIXEL
	    @ 090, 112 BUTTON _Confirm          PROMPT "Confirma"     SIZE 050, 012 OF oDlg ACTION Confirma()                            PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Cancela   ºAutor  ³Júlio Soares       º Data ³  10/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sub rotina para cancelar a rotina em operação              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Cancela()

MSGBOX("Dados não alterados.",_cRotina+"_02","INFO")
Close(oDlg)

Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Confirma  ºAutor  ³Júlio Soares       º Data ³  10/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Subrotina de confirmação.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Confirma()

Local _aSavSE1 := GetArea()
//Local _indOrd  := IndexOrd()

dbSelectArea("SC7")
SC7->(dbSetOrder(1))
If SC7->(MsSeek(xFilial("SC7") + _cNum,.T.,.F.))
dbSelectArea("SA2")
SA2->(dbSetOrder(1))
If SA2->(MsSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,.T.,.F.))
  _cContato := Alltrim(SA2->A2_CONTATO)
EndIf
	While !SC7->(EOF()) .AND. SC7->C7_FILIAL == xFilial("SC7") .AND. SC7->C7_NUM == _cNum
		RecLock("SC7",.F.)
			SC7->C7_FORNECE := cgCodForn
			SC7->C7_LOJA    := cgCodLoja
			SC7->C7_NOMEFOR := cornDescri
			SC7->C7_CONTATO := _cContato
		SC7->(MsUnLock())
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
		SC7->(dbSkip())
	EndDo
	MSGBOX("Observações gravadas",_cRotina + "003","INFO")
	_lRet := .T.
Else
	MSGBOX("Não exite registro para o fornecedor informado, verifique.",_cRotina + "004","ALERT")
	_lRet := .F.
EndIf

Close(oDlg)
RestArea(_aSavSE1)

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VALIDSA2  ºAutor  ³Júlio Soares       º Data ³  10/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Subrotina de validação das informações imputadas via F3    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VALIDSA2()

If !Empty(cgCodForn)
	dbSelectArea("SA2")
	If cgCodForn == SA2->A2_COD
		cgCodLoja := SA2->A2_LOJA
	EndIf
	SA2->(dbSetOrder(1)) // - A2_FILIAL+A2_COD+A2_LOJA
	If SA2->(MsSeek(xFilial("SA2") + cgCodForn + cgCodLoja,.T.,.F.))
		cornDescri := SA2->A2_NOME
		_lRet := .T.
	Else
		MSGBOX('NÃO EXISTE REGISTRO PARA O FORNECEDOR INFORMADO, VERIFIQUE.',_cRotina+'_005','ALERT')
		_lRet := .F.
	EndIf
Else
	MSGBOX('NÃO EXISTE REGISTRO PARA O FORNECEDOR INFORMADO, VERIFIQUE.',_cRotina+'_006','ALERT')
	_lRet := .F.
EndIf

Return(_lRet)
