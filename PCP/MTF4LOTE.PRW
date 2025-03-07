#include 'rwmake.ch'
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'shell.ch'

/*/{Protheus.doc} RFATE064
Rotina desenvolvida para bvalidar o acesso a consulta de lote atrav�s do F4 na tela de empenhos.
@author Diego Rodrigues
@since 17/01/2024
@version P12.1.2310
@type Function
@obs Sem observa��es
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

//Login usu�rio e Senha
If _cProg =="A381" .and. Upper(AllTrim(__cUserId)) $ _aUsrPcp
	ShowHelpDlg("[MTF4LOTE_001]", {"N�o � permitido a consulta da Tela de Lotes. Por gentileza digite o Lote!",""},5,;
                                   {"Caso o lote digitado n�o exista, por gentileza procurar o departamento do PCP ou um responsavel autorizado para consulta",""},5)
            Login()
        If !Empty(_cLogin) .and.  !Upper(AllTrim(_cCodUser)) $ _aUsrPcp
          _lRet := .T.
        Else  
            ShowHelpDlg("[MTF4LOTE_001]", {"Usu�rio n�o autorizado!",""},5,;
                        {"Procure os departamento do PCP ou responsaveis",""},5)
          _lRet   := .F.
        EndIf
EndIf

Return _lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Login   	�Autor  �Diego Rodrigues	   � Data �  17/01/2024 ���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza��o de Login no in�cio do processo consulta F4 EMPENHOS ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Login()

Local _aSavArea  := GetArea()
Local _aSavCB7   := CB7->(GetArea())
Local _cCadastro := "* * *  PRODU��O * * *"
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

    @ 004, 005  GROUP oGroupLog TO 045, 181 PROMPT " Digite o Usu�rio e Senha" OF oDlgLog COLOR 0, 16777215 	PIXEL
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidLog �Autor  �Diego Rodrigues		   � Data �  17/01/2024 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de valida��o da senha digitada na rotina Login      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal (Login) 	                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		MsgAlert("Usu�rio n�o encontrado!",_cRotina+"_059")
		_cLogin   := Space(30)
		_cSenha   := Space(100)
	EndIf
Else
	_cLogin   := Space(30)
	_cSenha   := Space(100)
	MsgAlert("Preencha as informa��es corretamente!",_cRotina+"_057")
EndIf

Return(_lValidlg)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EndLogin 	�Autor  �Diego Rodrigues		 � Data �  20/03/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Sair da tela de login.			                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa - ARCOLOR                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Static Function EndLogin()

_cLogin		:= ""

Close(oDlgLog)

Return(.F.)
