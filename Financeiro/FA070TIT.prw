#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA070TIT  �Autor  �J�lio Soares        � Data �  05/15/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada chamado ap�s a confirma��o do t�tulo      ���
���          � Chama execblock RFINE009 que apresenta tela onde � possivel���
���          � inserir ou alterar a carteira e/ou observa��es do t�tulo   ���
�������������������������������������������������������������������������͹��
���          � Alterado o ponto de entrada retirando o execblock RFINE009 ���
���          � e implementado diretamente no fonte.                       ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico empresa - ARCOLOR                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA070TIT()

Local    _aSavArea := GetArea()

Private  _lRet     := .T.
Private  _cRotina  := "FA070TIT"

// - TRECHO INSERIDO EM 23/07/2014 POR J�LIO SOARES PARA TRATAR UMA FALHA ENCONTRADA NA ROTINA ONDE AO ALTERAR O TIPO DE BAIXA O JUROS ZERADO � RETORNADO POR REFRESH DENTRO DA ROTINA
// - DESSA FORMA O PERCENTUAL DE JUROS � GRAVADO COM 0.2 AP�S A ALTERA��O EXECUTADA NO PONTO DE ENTRADA "FA070POS".
/*
while !RecLock("SE1",.F.) ; enddo
	SE1->E1_PORCJUR := 0.2
SE1->(MsUnlock())
*/
// - Trecho inserido por J�lio Soares em 20/01/2014 para validar se o usu�rio deseja baixar o t�tulo mesmo com a agrega��o dos valores de juros e/ou multas
	If nJuros > 0 .OR. nMulta > 0
		_lRet := MSGBOX ('CONFIRMAR BAIXA DO T�TULO COM A AGREGA��O DOS VALORES DE JUROS E/OU MULTA ? ',_cRotina+'_001','YESNO')
	EndIf
// - Fim inser��o.
//����������������������������������������������������������������������������������������������Ŀ
//�Implementado tela para a altera��o da carteira e/ou observa�oes do titulo ap�s baixar o mesmo.�
//������������������������������������������������������������������������������������������������
If _lRet .AND. Upper(AllTrim(FunName()))=="FINA740"
	Static oSay1
	Static oSay2
	Static grpCart
	Static oCart
	Static grpObs
	Static oObstit
	Static oCancela
	Static oConfirma
	Static oDlg

	Private _cPrfx     := SE1->E1_PREFIXO
	Private _cNum      := SE1->E1_NUM
	Private _cPar      := SE1->E1_PARCELA
	dbselectArea("SE1")
	SE1->(dbsetOrder(1))          // Indice por numero do t�tulo
	If SE1->(MsSeek(xFilial("SE1")+ _cPrfx +_cNum + _cPar,.T.,.F.))
		_cCart   := SE1->E1_CARTEIR
		_cObstit := SE1->E1_OBSTIT
		  DEFINE MSDIALOG oDlg TITLE "Altera��o de T�tulos" FROM 000, 000  TO 235, 450 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME// Inibe o botao "X" da tela
			oDlg:lEscClose := .F.//N�o permite fechar a tela com o "Esc"
		    @ 004, 007 GROUP  grpCart   TO 025, 220 PROMPT "Carteira"                                OF oDlg COLOR  0, 16777215 PIXEL
		    @ 010, 050 MSGET  oCart     VAR _cCart                                     SIZE 020, 010 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 030, 007 GROUP  grpObs    TO 095, 220 PROMPT "Observa��es do T�tulo"                   OF oDlg COLOR  0, 16777215 PIXEL
		    @ 038, 010 GET    oObstit   VAR _cObstit                                                 OF oDlg MULTILINE SIZE 207, 054 COLORS 0, 16777215 HSCROLL PIXEL
		    @ 100, 090 BUTTON oCancela  PROMPT "Cancela"                               SIZE 062, 015 OF oDlg ACTION Cancelar()  PIXEL
		    @ 100, 157 BUTTON oConfirma PROMPT "Confirma"                              SIZE 060, 015 OF oDlg ACTION Confirmar() PIXEL
		
		  ACTIVATE MSDIALOG oDlg CENTERED
	Else
		_cCart   := ""
		_cObstit := ""
	EndIf
EndIf

RestArea(_aSavArea)

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

MSGBOX("Observa��es n�o gravadas",_cRotina+"_001","INFO")
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
MSGBOX("Observa��es gravadas com sucesso!",_cRotina + "_002","INFO")
Close(oDlg)
	
RestArea(_aSavSE1)

Return(_lRet)

/*
If ExistBlock("RFINE009")
	Execblock ("RFINE009")
Else
	MsgAlert("Rotina RFINE009 n�o encontrada, informe o Administrador do sistema",_cRotina+"_001")
EndIf
*/
RestArea(_aSavArea)

Return()