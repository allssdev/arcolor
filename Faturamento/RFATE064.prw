#include 'rwmake.ch'
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'shell.ch'
/*/{Protheus.doc} RFATE064
Rotina desenvolvida para informar a data de in�cio e encerramento das confer�ncias das Ordens de Separa��o.
@author Arthur Silva
@since 20/03/2017
@version P12.1.2310
@type Function
@obs Sem observa��es
@see https://allss.com.br/
@history 12/01/2024, Rodrigo Telecio (rodrigo.telecio@allss.com.br), #7110 - Adequa��es no processo de faturamento de consignado.
/*/
user function RFATE064()

Private _dData	 	:= Date()
Private _cNumOs    	:= Space(TamSx3("CB7_ORDSEP")[01])
Private _cRotina    := "RFATE064"
Private _cNomUsr   	:= ""
Private _cCodUser  	:= ""
Private _cLogin		:= ""
Private _cSenha 	:= ""
Private _lRetSai    := .F.

//Login usu�rio e Senha
Login()

//Tela de apontamento in�cio/encerramento separa��o.
If !Empty(_cLogin)
	TelaApon()
EndIf	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TelaApon  �Autor  �Arthur Silva 		� Data �  20/03/17	  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina desenvolvida para informar a data de in�cio e 	  ���
���          � encerramento das conferencias das Ordens de separa��es.    ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function TelaApon()


Local oFont1 	 	:= TFont():New("Arial Narrow",,022,,.T.,,,,,.F.,.F.)
Local oFont2 	 	:= TFont():New("Arial Narrow",,020,,.T.,,,,,.F.,.F.)
Local oFont3 	 	:= TFont():New("Arial Narrow",,018,,.F.,,,,,.F.,.F.)
Local _aSavArea  	:= GetArea()
Local _aSavCB7		:= CB7->(GetArea())
Local oButton1
Local oButton2
Local oButton3
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oGet1

_cNumOs := Space(TamSx3("CB7_ORDSEP")[01])

Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Separa��o e Confer�ncia de O.S" FROM 000, 000  TO 200, 700 COLORS 0, 16777215 PIXEL
	
	@ 003, 000 SAY 		oSay1 		PROMPT 	"     Indicador de in�cio e encerramento das Ordens de Separa��es." SIZE 620, 019 						OF oDlg FONT oFont1 COLORS 0, 8404992  	PIXEL
	@ 024, 003 SAY 		oSay2 		PROMPT 	"Usu�rio/C�d.Usu�rio:"												SIZE 200, 090 						OF oDlg FONT oFont2	COLORS 0, 16777215 	PIXEL
	@ 024, 105 SAY 		oSay3 		VAR 	_cNomUsr+ " / " +_cLogin											SIZE 300, 010 						OF oDlg FONT oFont3	COLORS 0, 16777215 	PIXEL
	@ 024, 245 SAY 		oSay4 		PROMPT 	"Data:" 															SIZE 030, 013 						OF oDlg FONT oFont2	COLORS 0, 16777215 	PIXEL
	@ 024, 270 SAY 		oSay5 		PROMPT 	_dData 																SIZE 136, 010 						OF oDlg FONT oFont3	COLORS 0, 16777215 	PIXEL
	@ 045, 003 SAY 		oSay6 		PROMPT 	"Informe o n�mero da O.S:" 											SIZE 140, 020 						OF oDlg FONT oFont2	COLORS 0, 16777215 	PIXEL
	@ 044, 125 MSGET 	oGet1 		VAR 	_cNumOs 	WHEN !EMPTY(_cNomUsr)									SIZE 090, 011 						OF oDlg 			COLORS 0, 16777215 	PIXEL
	@ 075, 030 BUTTON 	oButton1 	PROMPT 	"Iniciar Sep." 														SIZE 070, 017 Action Iniciar()   	OF oDlg 								PIXEL
	@ 075, 115 BUTTON 	oButton2 	PROMPT 	"Encerrar Sep." 													SIZE 070, 017 Action Encerrar()   	OF oDlg 								PIXEL
	@ 075, 200 BUTTON 	oButton3 	PROMPT 	"Sair"	 															SIZE 040, 017 Action Sair()   		OF oDlg 								PIXEL
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
RestArea(_aSavCB7)
RestArea(_aSavArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Iniciar   �Autor  �Arthur Silva		 � Data �  20/03/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Iniciar Processo de Separa��o                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa - ARCOLOR                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Iniciar()

Local _cNomeCb1 := ""
Local _cCodSep  := ""
Local _dDtIni   := ""
Local _cNomeOs  := ""
Local _aSavArea := GetArea()
Local _aSavCB7	:= CB7->(GetArea())
Local _aSavCB1	:= CB1->(GetArea())

dbSelectArea("CB1")
CB1->(dbSetOrder(2))
If CB1->(MsSeek(xFilial("CB1") + _cCodUser,.T.,.F.))
	_cNomeCb1 := CB1->CB1_NOME
	_cCodSep  := CB1->CB1_CODOPE
Else
	MsgStop("Separador n�o encontrado, verifique o cadastro de Operadores!",_cRotina+"_001")
EndIf
dbSelectArea("CB7")
CB7->(dbSetOrder(1))
If CB7->(MsSeek(xFilial("CB7") + _cNumOs,.T.,.F.))
	_dDtIni  	:= CB7->CB7_DTISEP
	_cNomeOs 	:= CB7->CB7_NOMOP1
	If Empty(_dDtIni) //.AND. Empty(_dDtFim)
		while !RecLock("CB7",.F.) ; enddo
			CB7->CB7_CODOPE 	:= _cCodSep
			CB7->CB7_NOMOP1 	:= _cNomeCb1
			CB7->CB7_DTISEP 	:= Date()
			CB7->CB7_HRISOS 	:= Time()
		CB7->(MsUnLock())
		MsgInfo("Processo de Separa��o iniciado com sucesso para a O.S:'" + _cNumOs + "'!", _cRotina+"_002")
		Close(oDlg)
		//Login()
		If !Empty(_cLogin)
			TelaApon()
		EndIf
	Else
		MsgStop("Processo de Separa��o j� iniciado pelo Operador '" + _cNomeOs + "' na O.S:'" + _cNumOs + "' , verifique!", _cRotina+"_003")
	EndIf
ElseIf !Empty(_cNumOs)
	MsgStop("Ordem de Separa��o '" + _cNumOs + "' n�o encontrada, verifique!", _cRotina+"_004")
ElseIf Empty(_cNumOs)
	MsgStop("Ordem de Separa��o n�o informada, verifique!", _cRotina+"_005")
EndIf
	
RestArea(_aSavCB1)
RestArea(_aSavCB7)
RestArea(_aSavArea)


Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Encerrar   �Autor  �Arthur Silva		 � Data �  20/03/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Encerrar Processo de Separa��o                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa - ARCOLOR                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Encerrar()

Local _cCodOp 	:= ""
Local _cCodCb7  := ""
Local _cNomeCb7 := ""
Local _dDtICb7	:= ""
Local _dDtFCb7  := ""
Local _aSavArea := GetArea()
Local _aSavCB7	:= CB7->(GetArea())
Local _aSavCB1	:= CB1->(GetArea())


dbSelectArea("CB1")
CB1->(dbSetOrder(2))
If CB1->(MsSeek(xFilial("CB1") + _cCodUser,.T.,.F.))
	_cCodOp := CB1->CB1_CODOPE
Else
	MsgStop("Separador n�o encontrado, verifique o cadastro de Operadores!",_cRotina+"_006")
EndIf
dbSelectArea("CB7")
CB7->(dbSetOrder(1))
If	CB7->(MsSeek(xFilial("CB7") + _cNumOs,.T.,.F.))
	_cCodCb7  	:= CB7->CB7_CODOPE
	_cNomeCb7 	:= CB7->CB7_NOMOP1
	_dDtICb7  	:= CB7->CB7_DTISEP
	_dDtFCb7  	:= CB7->CB7_DTFSEP
	If !Empty(_dDtICb7) .AND. Empty(_dDtFCb7)
		If _cCodCb7 ==  _cCodOp
			while !RecLock("CB7",.F.) ; enddo
				CB7->CB7_DTFSEP 	:= Date()
				CB7->CB7_HRFSOS 	:= Time()
			CB7->(MsUnLock())
				MsgInfo("Processo de Separa��o encerrado com sucesso para a O.S:'" + _cNumOs + "'!",_cRotina+"_007")
			Close(oDlg)
			//Login()
			If !Empty(_cLogin)
				TelaApon()
			EndIf
		Else
			MsgStop("O Processo de Separa��o n�o foi iniciado por voc�, somente o usu�rio '" + Alltrim(_cNomeCb7) + "',poder� encerrar esta O.S!",_cRotina+"_008")
		EndIf
	ElseIf !Empty(_dDtFCb7)
		MsgStop("O.S: '" + _cNumOs + "' j� foi encerrada anteriormente!",_cRotina+"_009")
	Else
		MsgStop("N�o foi INICIADO a separa��o da O.S: '" + _cNumOs + "'. Inicie o processo de separa��o,para depois encerra-la!",_cRotina+"_009A")
	EndIf
ElseIf !Empty(_cNumOs)
	MsgStop("O.S: '" + _cNumOs + "' N�o encontrada , verifique!",_cRotina+"_010")
ElseIf Empty(_cNumOs)
	MsgStop("Ordem de Separa��o n�o informada, verifique!",_cRotina+"_011")
EndIf
	
RestArea(_aSavCB1)
RestArea(_aSavCB7)
RestArea(_aSavArea)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Sair   	�Autor  �Arthur Silva		 � Data �  20/03/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Sa� da tela.						                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa - ARCOLOR                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Static Function Sair()

MsgInfo("Dados n�o alterados.",_cRotina+"_012","INFO")

Close(oDlg)

Return(.F.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Login   	�Autor  �Arthur Silva		   � Data �  03/04/17 ���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza��o de Login no in�cio do processo de separa��o.	  ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Login()

Local _aSavArea  := GetArea()
Local _aSavCB7   := CB7->(GetArea())
Local _cCadastro := "* * *  E X P E D I � � O  * * *"
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
    @ 017, 010    SAY oSaylg1    PROMPT "Login:"                                       	SIZE 025, 007 OF oDlgLog COLORS 0, 16777215          			PIXEL
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
���Programa  �ValidLog �Autor  �Arthur Silva		   � Data �  03/04/17 ���
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
���Programa  �EndLogin 	�Autor  �Arthur Silva		 � Data �  20/03/17   ���
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
