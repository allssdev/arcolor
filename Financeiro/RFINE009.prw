#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Tbiconn.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFINE009  �Autor  �J�lio Soares        � Data �  05/15/13  ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock criado para apresentar tela com op��o de inser��o���
���          � ou altera��o do c�digo da carteira e observa��es quando    ���
���          � necess�rio                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico empresa - ARCOLOR                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINE009()

Local   oSay1
Local   oSay2
Local   oCart
Local   oObstit
Local   oCancela
Local   oConfirma
Local   _aSavArea := GetArea()

Private _lRet     := .T.
Private _cRotina  := "RFINE009"

Static  oDlg
Static  _cCart    := SE1->E1_CARTEIR
Static  _cObstit  := SE1->E1_OBSTIT

  DEFINE MSDIALOG oDlg TITLE "Altera��o de T�tulos" FROM 000, 000  TO 235, 450 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME// Inibe o botao "X" da tela
	oDlg:lEscClose := .F.//N�o permite fechar a tela com o "Esc"

    @ 005, 007 SAY    oSay1     PROMPT "Carteira"               SIZE 036, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 005, 050 MSGET  oCart     VAR _cCart                      SIZE 025, 012 OF oDlg COLORS 0, 16777215 PIXEL
    @ 019, 007 SAY    oSay2     PROMPT "Observa��es do T�tulo"  SIZE 200, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 007 GET    oObstit   VAR _cObstit OF oDlg MULTILINE  SIZE 210, 069 COLORS 0, 16777215 HSCROLL PIXEL
    @ 100, 090 BUTTON oCancela  PROMPT "Cancela"                SIZE 062, 015 OF oDlg ACTION Cancelar()  PIXEL
    @ 100, 157 BUTTON oConfirma PROMPT "Confirma"               SIZE 060, 015 OF oDlg ACTION Confirmar() PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return(_lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Cancelar  �Autor  �J�lio Soares        � Data �  05/15/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Sub rotina de cancelamento                                 ���
���          � N�O GRAVA AS INFORMA��ES INSERIDAS OU ALTERADAS            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Cancelar()

MSGBOX("Dados n�o alterados!!!",_cRotina+"_001","INFO")
Close(oDlg)

Return(.F.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Confirmar �Autor  �J�lio Soares        � Data �  05/15/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Sub rotina de Grava��o                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Confirmar()

Local _aSavSE1 := GetArea()

dbSelectArea("SE1")
while !RecLock("SE1",.F.) ; enddo
	SE1->E1_CARTEIR  := _cCart
	SE1->E1_OBSTIT   := _cObstit
SE1->(MsUnLock())
MSGBOX("Observa��es gravadas",_cRotina + "002","INFO")
_lRet := .T.
Close(oDlg)
	
RestArea(_aSavSE1)

Return(_lRet)