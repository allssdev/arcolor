#INCLUDE 'Protheus.ch'
#INCLUDE 'Rwmake.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATE055  �Autor  � J�lio Soares      � Data �  08/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock criado para apresentar uma tela na rotina de     ���
���          � expedi��o para inclus�o do numero da coleta, contato, data ���
���          � e hora da liga��o.                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE055()

Local _cGrp
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGet5
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5

Private cGet1    := IIF(SF2->(FieldPos("F2_COLETA") )<>0,IIF(!Empty(SF2->(F2_COLETA) ),(SF2->(F2_COLETA) ),Space(TamSx3("F2_COLETA")[01])),Space(010))
Private cGet2    := IIF(SF2->(FieldPos("F2_DTCLTA") )<>0,IIF(!Empty(SF2->(F2_DTCLTA) ),DTOC(SF2->(F2_DTCLTA) ),DTOC(Date())),Space(008))
Private cGet3    := IIF(SF2->(FieldPos("F2_HRCLTA") )<>0,IIF(!Empty(SF2->(F2_HRCLTA) ),(SF2->(F2_HRCLTA) ),Time()),Space(008))
Private cGet4    := IIF(SF2->(FieldPos("F2_CONTATO"))<>0,IIF(!Empty(SF2->(F2_CONTATO)),(SF2->(F2_CONTATO)),Space(TamSx3("F2_CONTATO")[01])),Space(030))
Private cGet5    := IIF(SF2->(FieldPos("F2_OBS"))<>0,IIF(!Empty(SF2->(F2_OBS)),(SF2->(F2_OBS)),Space(TamSx3("F2_OBS")[01])),Space(200))
Private _cRotina := 'RFATE055'
Private Cancela
Private Confirma

Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Coleta" FROM 000, 000  TO 210, 545               COLORS 0, 16777215                         PIXEL

    @ 005, 005 GROUP _cGrp TO 085, 267 PROMPT "I nforma��es da coleta" OF oDlg COLOR 10485760, 16777215                   PIXEL

    @ 017, 010 SAY oSay1       PROMPT "N. Coleta"  SIZE 037, 012 OF oDlg COLORS 0, 16777215                               PIXEL
    @ 017, 050 MSGET oGet1     VAR cGet1           SIZE 050, 012 OF oDlg COLORS 0, 16777215 WHEN Empty(SF2->(F2_COLETA))  PIXEL

    @ 017, 112 SAY oSay2       PROMPT "Data"       SIZE 025, 012 OF oDlg COLORS 0, 16777215                               PIXEL
    @ 017, 137 MSGET oGet2     VAR cGet2           SIZE 037, 012 OF oDlg COLORS 0, 12632256 WHEN .F. READONLY             PIXEL

    @ 017, 187 SAY oSay3       PROMPT "Hora"       SIZE 025, 012 OF oDlg COLORS 0, 16777215                               PIXEL
    @ 017, 212 MSGET oGet3     VAR cGet3           SIZE 037, 012 OF oDlg COLORS 0, 12632256 WHEN .F. READONLY             PIXEL

    @ 040, 010 SAY oSay4       PROMPT "Contato"    SIZE 025, 012 OF oDlg COLORS 0, 16777215                               PIXEL
    @ 040, 040 MSGET oGet4     VAR cGet4           SIZE 212, 012 OF oDlg COLORS 0, 16777215 WHEN Empty(SF2->(F2_CONTATO)) PIXEL

    @ 060, 010 SAY oSay5       PROMPT "Obs."       SIZE 025, 012 OF oDlg COLORS 0, 16777215                               PIXEL
    @ 060, 040 MSGET oGet5     VAR cGet5           SIZE 212, 012 OF oDlg COLORS 0, 16777215                               PIXEL

    @ 090, 150 BUTTON Cancela  PROMPT "Cancela"    SIZE 050, 012 OF oDlg ACTION Cancela()              	                  PIXEL
    @ 090, 207 BUTTON Confirma PROMPT "Confirma"   SIZE 050, 012 OF oDlg ACTION Confirma()                                PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Confirma �Autor  � J�lio Soares       � Data �  08/14/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Confirma()

while !RecLock("SF2",.F.) ; enddo
	If SF2->(FieldPos("F2_COLETA"))<>0
		SF2->(F2_COLETA)  := cGet1
	Else
		MSGBOX('O CAMPO [COLETA] N�O EXISTE E PORTANTO N�O SER� GRAVADO, INFORME O ADMINISTRADOR DO SISTEMA. ',_cRotina+'_01','INFO')
	EndIf
	If SF2->(FieldPos("F2_DTCLTA"))<>0
		SF2->(F2_DTCLTA)  := CTOD(cGet2)
	Else
		MSGBOX('O CAMPO [DATA DA COLETA] N�O EXISTE E PORTANTO N�O SER� GRAVADO, INFORME O ADMINISTRADOR DO SISTEMA. ',_cRotina+'_02','INFO')
	EndIf
	If SF2->(FieldPos("F2_HRCLTA"))<>0
		SF2->(F2_HRCLTA)  := cGet3
	Else
		MSGBOX('O CAMPO [HORA DA COLETA] N�O EXISTE E PORTANTO N�O SER� GRAVADO, INFORME O ADMINISTRADOR DO SISTEMA. ',_cRotina+'_03','INFO')
	EndIf
	If SF2->(FieldPos("F2_CONTATO"))<>0
		SF2->(F2_CONTATO) := cGet4
	Else
		MSGBOX('O CAMPO [CONTATO] N�O EXISTE E PORTANTO N�O SER� GRAVADO, INFORME O ADMINISTRADOR DO SISTEMA. ',_cRotina+'_04','INFO')
	EndIf
	If SF2->(FieldPos("F2_OBS"))<>0
		SF2->(F2_OBS) := cGet5
	Else
		MSGBOX('O CAMPO [OBSERVACAO] N�O EXISTE E PORTANTO N�O SER� GRAVADO, INFORME O ADMINISTRADOR DO SISTEMA. ',_cRotina+'_04','INFO')
	EndIf

SF2->(MsUnlock())
Close(oDlg)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Cancela  �Autor  � J�lio Soares       � Data �  08/14/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Cancela()
	Close(oDlg)
	MSGBOX('AS INFORMA��ES DA COLETA N�O FORAM GRAVADAS',_cRotina+'_05','ALERT')
Return()