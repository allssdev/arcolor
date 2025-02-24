#include 'rwmake.ch'
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'shell.ch'

/*/{Protheus.doc} RFATE064
Rotina desenvolvida para bvalidar o acesso a consulta de lote atrav้s do F4 na tela de empenhos.
@author Diego Rodrigues
@since 17/01/2024
@version P12.1.2310
@type Function
@obs Sem observa็๕es
@see https://allss.com.br/

/*/

User Function MTF4LOTE  
Local _lRet      :=.T.
Local _cProg     :=PARAMIXB[1]    
Local _aUsrPcp	:= SuperGetMv("MV_XUSRPCP" ,,"000000" )

Private _cRotina	:= "MTF4LOTE"
Private _cNomUsr   	:= ""
Private _cCodUser  	:= ""
Private _cLogin		:= ""
Private _cSenha 	:= ""
Private _lRetSai    := .F.

//Login usuแrio e Senha
If _cProg =="A381" .and. Upper(AllTrim(__cUserId)) $ _aUsrPcp
	ShowHelpDlg("[MTF4LOTE_001]", {"Nใo ้ permitido a consulta da Tela de Lotes. Por gentileza digite o Lote!",""},5,;
                                   {"Caso o lote digitado nใo exista, por gentileza procurar o departamento do PCP ou um responsavel autorizado para consulta",""},5)
            Login()
        If !Empty(_cLogin) .and.  !Upper(AllTrim(_cCodUser)) $ _aUsrPcp
          _lRet := .T.
        Else  
            ShowHelpDlg("[MTF4LOTE_001]", {"Usuแrio nใo autorizado!",""},5,;
                        {"Procure os departamento do PCP ou responsaveis",""},5)
          _lRet   := .F.
        EndIf
EndIf

Return _lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLogin   	บAutor  ณDiego Rodrigues	   บ Data ณ  17/01/2024 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza็ใo de Login no inํcio do processo consulta F4 EMPENHOS บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Login()

Local _aSavArea  := GetArea()
Local _aSavCB7   := CB7->(GetArea())
Local _cCadastro := "* * *  PRODUวรO * * *"
Local oButtonLog
Local oButtonS
Local oGroupLog
Local oSaylg1
Local oSaylg2
Local oGetlg1
Local oGetlg2
Local _lRetlog := .F.

_cLogin	:= Space(30)
_cSenha := Space(100)

Static oDlgLog

  DEFINE MSDIALOG oDlgLog TITLE _cCadastro FROM 000, 000  TO 100, 370 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
	oDlgLog:lEscClose := .F.

    @ 004, 005  GROUP oGroupLog TO 045, 181 PROMPT " Digite o Usuแrio e Senha" OF oDlgLog COLOR 0, 16777215 	PIXEL
    @ 017, 010    SAY oSaylg1    PROMPT "Login:"                                       	SIZE 025, 007 OF oDlgLog COLORS 0, 16777215          	    PIXEL
    @ 015, 037  MSGET oSaylg2       VAR _cLogin  /*VALID NAOVAZIO()*/					SIZE 075, 010 OF oDlgLog COLORS 0, 16777215 /*F3 "USR"*/ 	PIXEL
    @ 030, 010    SAY oGetlg1    PROMPT "Senha:"                                        SIZE 025, 007 OF oDlgLog COLORS 0, 16777215          		PIXEL
    @ 030, 037  MSGET oGetlg2       VAR _cSenha  /*VALID NAOVAZIO()*/                   SIZE 075, 010 OF oDlgLog COLORS 0, 16777215 PASSWORD 		PIXEL
    @ 015, 128 BUTTON oButtonLog PROMPT "Entrar" Action (_lRetlog := ValidLog())        SIZE 037, 012 OF oDlgLog                             		PIXEL
	@ 030, 128 BUTTON oButtonS 	PROMPT 	"Sair"	 Action EndLogin()						SIZE 037, 012 OF oDlgLog									PIXEL

  ACTIVATE MSDIALOG oDlgLog CENTERED

RestArea(_aSavCB7)
RestArea(_aSavArea)

Return(_lRetlog)                                                                             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidLog บAutor  ณDiego Rodrigues		   บ Data ณ  17/01/2024 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de valida็ใo da senha digitada na rotina Login      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal (Login) 	                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidLog()

Local _lValidlg := .F.

_cNomUsr   	:= ""
_cCodUser  	:= ""

If !Empty(_cLogin) .AND. !Empty(_cSenha)
	PswOrder(2)
	If PswSeek(AllTrim(_cLogin),.T.)
		If PswName(AllTrim(_cSenha))
			_lValidlg := .T.
			_cNomUsr  := PswRet(1)[1][4]
			_cCodUser := PswRet(1)[1][1]
			Close(oDlglog)
		Else
			MsgAlert("Senha Incorreta!",_cRotina+"_060")
			_cLogin   := Space(30)
			_cSenha   := Space(100)
		EndIf
	Else
		MsgAlert("Usuแrio nใo encontrado!",_cRotina+"_059")
		_cLogin   := Space(30)
		_cSenha   := Space(100)
	EndIf
Else
	_cLogin   := Space(30)
	_cSenha   := Space(100)
	MsgAlert("Preencha as informa็๕es corretamente!",_cRotina+"_057")
EndIf

Return(_lValidlg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEndLogin 	บAutor  ณDiego Rodrigues		 บ Data ณ  20/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Sair da tela de login.			                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico empresa - ARCOLOR                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function EndLogin()

_cLogin		:= ""

Close(oDlgLog)

Return(.F.)
