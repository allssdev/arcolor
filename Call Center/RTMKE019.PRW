#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"

#DEFINE _CRFL CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RTMKE019  �Autor  � J�lio Soares      � Data �  02/13/14   ���
���Programa  �           �Autor  � J�lio Soares      � Data �  06/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock criado para gerar uma tela de inclus�o de        ���
���          � informa��es a serem alteradas atrav�s de um bot�o de atalho���
���          � a fim de que o pedido n�o perca a libera��o dos setores.   ���
�������������������������������������������������������������������������͹��
���          � Altera��es implementadas a inclus�o da prioridade do pedido���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RTMKE019()

Local _aSavArea := GetArea()
Local _aSavSUA  := SUA->(GetArea())
Local _aSavSA1  := SA1->(GetArea())
Local _aSavSA4  := SA4->(GetArea())
Local _aSavSE4  := SE4->(GetArea())
Local cCodCli
Local cLojaCli
Local cNomcli
Local cCodTransp
Local cNomTransp
Local cNum
Local cNumPed
Local cTpFrete
Local cPriori

Local oGroup1
Local oGroup2
Local oGroup3
Local oCancela
Local oConfirma
Local CodCli
Local LojaCli
Local Nomcli
Local CodTransp
Local NomTransp
Local TpFrete
Local mMenNfe
Local mOrdSep
Local mObsPad //12/09/2024 - Diego Rodrigues - Tratativa para atualiza��o do campo UA_OBS/C5_OBS devido a solicita��o da Mayara para n�o perder as libera��es
Local Priori

Private oDlg19
Private _cRotina    := 'RTMKE019'
Private _cCodCli    := SUA->UA_CLIENTE
Private _cLojaCli   := SUA->UA_LOJA
Private _cNomcli    := SUA->UA_NOMECLI
Private _cNum       := SUA->UA_NUM
Private _cNumSC5    := SUA->UA_NUMSC5
Private _cCodTransp := SUA->UA_TRANSP
Private _cNomTransp := SUA->UA_DTRANSP
Private nTpFrete    := SUA->UA_TPFRETE
Private _cPriori    := POSICIONE("SA1",1,xFilial("SA1") + _cCodCli + _cLojaCli,"A1_PRIOR")
Private _cMenNfe    := ""
Private _cOrdSep    := Alltrim(SUA->UA_OBSSEP)
Private _cObsPad    := If(Empty(MSMM(SUA->UA_CODOBS,43)),"",MSMM(SUA->UA_CODOBS,43)) //12/09/2024 - Diego Rodrigues - Tratativa para atualiza��o do campo UA_OBS/C5_OBS devido a solicita��o da Mayara para n�o perder as libera��es

dbSelectArea("SA1")
SA1->(dbSetOrder(1)) // - passar para NickName
If SA1->(MsSeek(xFilial("SA1")+ _cCodCli +_cLojaCli,.T.,.F.))
	_cNomcli := SA1->A1_NOME
EndIf
dbSelectArea("SA4")
SA4->(dbSetOrder(1))
If SA4->(MsSeek(xFilial("SA4")+ _cCodTransp,.T.,.F.))
	_cNomTransp := SA4->A4_NOME
EndIf
dbSelectArea("SC5")
SC5->(dbSetOrder(1))
If SC5->(MsSeek(xFilial("SC5")+ _cNumSC5,.T.,.F.))
	_cMenNfe := Alltrim(SC5->C5_MENNOTA)
	If !Empty(SC5->C5_NPRIORI)
		_cPriori := SC5->C5_NPRIORI
	EndIf
EndIf
Do Case 
	Case nTpFrete = 'C'
		nTpFrete := 'CIF'
	Case nTpFrete = 'F'
		nTpFrete := 'FOB'
	Case nTpFrete = 'T'
		nTpFrete := 'TER'
	Case nTpFrete = 'S'
		nTpFrete := 'SEM'		
End	

//Static oDlg19

  DEFINE MSDIALOG oDlg19 TITLE "Altera Informa��es Espec�ficas" FROM 000, 000  TO 500, 495 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
	oDlg19:lEscClose := .F.
	
    @ 002, 004 GROUP oGroup1 TO 222, 247 PROMPT "Altera��o de informa��es espec�ficas no atendimento." OF oDlg19 COLOR 8404992, 16777215                             PIXEL

    @ 017, 007 SAY   cNumPed             PROMPT "Atendimento:"                         SIZE 042, 010 OF oDlg19 COLORS 0, 16777215                                    PIXEL
    @ 015, 050 MSGET cNum                VAR _cNum                                     SIZE 037, 012 OF oDlg19 COLORS 0, 16777215 READONLY WHEN .F.                  PIXEL

    @ 017, 099 SAY   CodCli              PROMPT "Cliente:"                             SIZE 027, 010 OF oDlg19 COLORS 0, 16777215                                    PIXEL
    @ 015, 126 MSGET cCodCli             VAR _cCodCli                                  SIZE 035, 012 OF oDlg19 COLORS 0, 16777215 READONLY WHEN .F.                  PIXEL

    @ 017, 166 SAY   LojaCli             PROMPT "Loja:"                                SIZE 020, 010 OF oDlg19 COLORS 0, 16777215                                    PIXEL
    @ 015, 189 MSGET cLojaCli            VAR _cLojaCli                                 SIZE 020, 012 OF oDlg19 COLORS 0, 16777215 READONLY WHEN .F.                  PIXEL

    @ 035, 007 SAY   Nomcli              PROMPT "Nome:"                                SIZE 030, 010 OF oDlg19 COLORS 0, 16777215                                    PIXEL
    @ 033, 050 MSGET cNomcli             VAR _cNomcli                                  SIZE 192, 012 OF oDlg19 COLORS 0, 16777215 READONLY WHEN .F.                  PIXEL

    @ 052, 007 SAY   CodTransp           PROMPT "Transportadora:"                      SIZE 057, 010 OF oDlg19 COLORS 0, 16777215                                    PIXEL
    @ 050, 050 MSGET cCodTransp          VAR _cCodTransp                               SIZE 045, 012 OF oDlg19 COLORS 0, 16777215 F3 "SA4" VALID ValidSA4()          PIXEL

	@ 070, 007 SAY   NomTransp           PROMPT "Nome:"                                SIZE 025, 010 OF oDlg19 COLORS 0, 16777215                                    PIXEL
    @ 067, 050 MSGET cNomTransp          VAR _cNomTransp                               SIZE 192, 012 OF oDlg19 COLORS 0, 16777215 READONLY WHEN .F.                  PIXEL

    @ 087, 007 SAY   TpFrete             PROMPT "Tipo de Frete:"                       SIZE 047, 010 OF oDlg19 COLORS 0, 16777215                                    PIXEL
    @ 085, 050 MSCOMBOBOX cTpFrete       VAR nTpFrete ITEMS {"CIF","FOB","TER","SEM"}  SIZE 050, 012 OF oDlg19 COLORS 0, 16777215                                    PIXEL

    @ 087, 105 SAY   Priori              PROMPT "Prioridade do pedido"                 SIZE 060, 010 OF oDlg19 COLORS 0, 16777215                                    PIXEL
    @ 085, 175 MSGET cPriori             VAR _cPriori                                  SIZE 020, 012 OF oDlg19 COLORS 0, 16777215          VALID Naovazio()          PIXEL

    @ 104, 006 GROUP oGroup2 TO 139, 245 PROMPT "Mensagem para a Nota."   OF oDlg19 COLOR 8404992, 16777215                                                          PIXEL
    @ 113, 008 GET   mMenNfe             VAR _cMenNfe OF oDlg19 MULTILINE                SIZE 235, 023 COLORS 0, 16777215 HSCROLL                                    PIXEL

    @ 142, 006 GROUP oGroup3 TO 179, 245 PROMPT "Obs. Ordem de separa��o" OF oDlg19 COLOR 8404992, 16777215                                                          PIXEL
    @ 152, 008 GET   mOrdSep             VAR _cOrdSep OF oDlg19 MULTILINE                SIZE 235, 025 COLORS 0, 16777215 HSCROLL                                    PIXEL

	@ 180, 006 GROUP oGroup3 TO 219, 245 PROMPT "Obs. Padr�o"			  OF oDlg19 COLOR 8404992, 16777215                                                          PIXEL
    @ 192, 008 GET   mObsPad             VAR _cObsPad OF oDlg19 MULTILINE                SIZE 235, 025 COLORS 0, 16777215 HSCROLL                                    PIXEL

    @ 225, 126 BUTTON oCancela           PROMPT "Cancela"                              SIZE 050, 012 OF oDlg19 ACTION Cancelar()                                     PIXEL
    @ 225, 189 BUTTON oConfirma          PROMPT "Confirma"                             SIZE 050, 012 OF oDlg19 ACTION Confirmar()                                    PIXEL

  ACTIVATE MSDIALOG oDlg19 CENTERED

RestArea(_aSavSA1)
RestArea(_aSavSA4)
RestArea(_aSavSE4)
RestArea(_aSavSUA)
RestArea(_aSavArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ValidSA4  �Autor  � J�lio Soares       � Data �  01/09/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina criada para realizar a valida��o do cadastro de     ���
���          � transportadoras.                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidSA4()

dbSelectArea("SA4")
SA4->(dbSetOrder(1))
If SA4->(MsSeek(xFilial("SA4") + _cCodTransp,.T.,.F.))
	_cNomTransp := SA4->A4_NOME
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Cancelar �Autor  �J�lio Soares        � Data �  05/15/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Sub rotina de cancelamento                                 ���
���          � N�O GRAVA AS INFORMA��ES INSERIDAS OU ALTERADAS            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal.                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Cancelar()

Close(oDlg19)
MSGBOX("Altera��o n�o realizada. ",_cRotina+"_001","ALERT")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Confirmar �Autor  � J�lio Soares       � Data �  01/09/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina criada para que na confirma��o das altera��es, essas���
���          � sejam gravadas.                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Confirmar()

If MSGBOX("Deseja confirmar a grava��o das altera��es? ",_cRotina+"_002","YESNO")
	Do Case 
		Case nTpFrete = 'CIF'
			_TpFrete := 'C'
		Case nTpFrete = 'FOB'
			_TpFrete := 'F'
		Case nTpFrete = 'TER'
			_TpFrete := 'T'
		Case nTpFrete = 'SEM'
			_TpFrete := 'S'		
	End
	dbSelectArea("SUA")
	SUA->(dbOrderNickName("UA_NUMSC5"))
	//SUA->(dbSetOrder(8))
	If SUA->(MsSeek(xFilial("SUA")+_cNumSC5,.T.,.F.))
		//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
		If ExistBlock("RFATL001")
			If SUA->UA_TRANSP <> _cCodTransp
				U_RFATL001(	SUA->UA_NUMSC5,;
							SUA->UA_NUM,;
							"Transportadora alterada: "+_cCodTransp + ' - ' + Alltrim(_cNomTransp),;
							_cRotina)
			EndIf
			If SUA->UA_TPFRETE <> _TpFrete
				U_RFATL001(	SUA->UA_NUMSC5,;
							SUA->UA_NUM,;
							"Tipo de frete alterado: " + nTpFrete,;
							_cRotina)
			EndIf
		EndIf
		//12/09/2024 - Diego Rodrigues - Tratativa para atualiza��o do campo UA_OBS
		dbSelectArea("SYP")
		SYP->(dbSetOrder(1))
		If SYP->(MsSeek(xFilial("SYP")+SUA->UA_CODOBS,.T.,.F.))
			RecLock('SYP',.F.) 
				SYP->YP_TEXTO := _cObsPad
			SYP->(MsUnLock())
		EndIF
		//12/09/2024 - Diego Rodrigues - Tratativa para atualiza��o do campo UA_OBS
		while !RecLock('SUA',.F.) ; enddo
			SUA->UA_TRANSP  := _cCodTransp
			SUA->UA_DTRANSP := _cNomTransp
			SUA->UA_TPFRETE := _TpFrete
			SUA->UA_OBSSEP  := _cOrdSep
			// - IMPLEMENTADO PARA GRAVAR NO CAMPO DE LOG AS ALTERA��ES REALIZADAS
			If SUA->(FieldPos("UA_LOGSTAT"))>0
				_cLog           := Alltrim(SUA->UA_LOGSTAT)
				SUA->UA_LOGSTAT := _cLog + _CRFL + Replicate("-",60)                                    + _CRFL +;
									DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId)       + _CRFL +;
									'ALTERA��ES REALIZADAS NO PEDIDO DE VENDAS '                        + _CRFL +;
									'Transportadora:     ' + _cCodTransp + ' - ' + Alltrim(_cNomTransp) + _CRFL +;
									'Tipo de frete:      ' + nTpFrete                                   + _CRFL +;
									'Prioridade:         ' + _cPriori
			EndIf
		SUA->(MsUnLock())
	Else
		MSGBOX('NUMERO DO PEDIDO: '+ _cNumSC5 +' N�O ENCONTRADO, INFORME O ADMINISTRADOR DO SISTEMA',_cRotina+'_003','ALERT')
		Close(oDlg19)
	EndIf
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5")+ _cNumSC5 ,.T.,.F.))
		//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
		If ExistBlock("RFATL001")
			If SC5->C5_TRANSP <> _cCodTransp
				U_RFATL001(	SC5->C5_NUM,;
							SUA->UA_NUM,;
							"Transportadora alterada: "+_cCodTransp + ' - ' + Alltrim(_cNomTransp)                            )
			EndIf
			If SC5->C5_TPFRETE <> _TpFrete
				U_RFATL001(	SUA->UA_NUMSC5,;
							SUA->UA_NUM,;
							"Tipo de frete alterado de '"+SC5->C5_TPFRETE+"' para '" + nTpFrete + "'"                         )
			EndIf
			If SC5->(FieldPos("C5_NPRIORI"))>0 .AND. SC5->C5_NPRIORI <> _cPriori
				U_RFATL001(	SUA->UA_NUMSC5,;
							SUA->UA_NUM,;
							"Prioridade alterada de '"+SC5->C5_NPRIORI+"' para '" + _cPriori + "'"                            )
			EndIf
			If SC5->(FieldPos("C5_MENNOTA"))>0 .AND. SC5->C5_MENNOTA <> _cMenNfe
				U_RFATL001(	SUA->UA_NUMSC5,;
							SUA->UA_NUM,;
							"Mensagem para a NF alterada de '"+AllTrim(SC5->C5_MENNOTA)+"' para '" + AllTrim(_cMenNfe) + "'",;
							"Mensagem para a NF alterada de '"+AllTrim(SC5->C5_MENNOTA)+"' para '" + AllTrim(_cMenNfe) + "'"  )
			EndIf
		EndIf
		while !RecLock('SC5',.F.) ; enddo
			SC5->C5_MENNOTA     := _cMenNfe
			SC5->C5_TPFRETE     := _TpFrete
			SC5->C5_TRANSP      := _cCodTransp
			If SC5->(FieldPos("C5_DTRANSP"))>0
				SC5->C5_DTRANSP := _cNomTransp
			EndIf
			If SC5->(FieldPos("C5_OBSSEP"))>0
				SC5->C5_OBSSEP  := _cOrdSep
			EndIf
			If SC5->(FieldPos("C5_NPRIORI"))>0
				SC5->C5_NPRIORI := _cPriori
			EndIf
			If SC5->(FieldPos("C5_OBS"))>0
				SC5->C5_OBS:= _cObsPad
			EndIf
			// - IMPLEMENTADO PARA GRAVAR NO CAMPO DE LOG AS ALTERA��ES REALIZADAS
			If SC5->(FieldPos("C5_LOGSTAT"))>0
				_cLog           := Alltrim(SC5->C5_LOGSTAT)
				SC5->C5_LOGSTAT := _cLog + _CRFL + Replicate("-",60)                                    + _CRFL +;
									DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId)       + _CRFL +;
									'ALTERA��ES REALIZADAS NO PEDIDO DE VENDAS '                        + _CRFL +;
									'Transportadora:     ' + _cCodTransp + ' - ' + Alltrim(_cNomTransp) + _CRFL +;
									'Tipo de frete:      ' + nTpFrete                                   + _CRFL +;
									'Prioridade:         ' + _cPriori
			EndIf
		SC5->(MSUNLOCK())
	Else
		MSGBOX('NUMERO DO PEDIDO: '+ _cNumSC5 +' N�O ENCONTRADO. INFORME O ADMINISTRADOR DO SISTEMA!!!',_cRotina+'_004','ALERT')
		Close(oDlg19)		
	EndIf
	Close(oDlg19)
EndIf

Return
