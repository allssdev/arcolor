#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M512AGRV �Autor  �Anderson C. P. Coelho � Data �  18/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.TOTVS� Esse ponto de entrada est� localizado antes da grava��o da ���
���          � manuten��o. � acionado no momento em que o bot�o de        ���
���          � confirma��o for selecionado.                               ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada chamado na grava��o na tabela SF2,relativo���
���          � a rotina de Expedi��o, utilizado para apresentar a tela de ���
���          � manipula��o dos volumes do documento de sa�da, quando a    ���
���          � nota fiscal eletr�nica ainda n�o tiver sido transmitida.   ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function M512AGRV()
	Local _aSavArea  := GetArea()
	Local _lAltVol   := .F.
	Private _cRotina := "M512AGRV"
	Private nGet1    := SF2->F2_VOLUME1
	Private cGet2    := SF2->F2_ESPECI1
	Private cGet3    := SF2->F2_ENDEXP
	Private _nPliq	 := SF2->F2_PLIQUI
	Private _nPBrut  := SF2->F2_PBRUTO
	dbSelectArea("SF2")
	_aSavSF2 := SF2->(GetArea())
	dbSelectArea("SF3")
	_aSavSF3 := SF3->(GetArea())
	SF3->(dbSetOrder(1))
	If SF3->(MsSeek(xFilial("SF3") + DTOS(SF2->F2_EMISSAO) + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA,.T.,.F.))
	//	If (AllTrim(SF2->F2_ESPECIE) == "SPED" /*.OR. (SF2->(F2_BASEIMP5+F2_BASEIMP6+F2_BASEICM)>0*/) .AND. Empty(SF2->F2_CHVNFE)
		If AllTrim(SF2->F2_ESPECIE) == "SPED"
			If Empty(SF2->F2_CHVNFE)  // .AND. !AllTrim(SF2->F2_IMP)$"S/T"
				_lAltVol := .T.
			Else
				_lAltVol := .F.
			EndIf
		Else
			_lAltVol     := .T.
		EndIf
	Else
		_lAltVol         := .T.
	EndIf
	//If _lAltVol
		AtuVol(_lAltVol)
	//EndIf
	If Empty(SF2->F2_USREXP) .AND. AllTrim(SF2->F2_TIPO)$"N" .AND. MsgYesNo("Deseja encerrar o processo de expedi��o?",_cRotina+"_003")
		EncerraExp()
	EndIf
	RestArea(_aSavSF3)
	RestArea(_aSavSF2)
	RestArea(_aSavArea)
return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtuVol    �Autor  �Anderson C. P. Coelho � Data �  18/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Sub-Rotina para atualiza��o manual do volume antes da       ��
���          �transmiss�o da NFE.                                          ��
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function AtuVol(_lAltVol)
	Local oGet1
	Local oGet2
	Local oGet3
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oGroup1
	Local oSButton1
	Local oSButton2
	Local _lGrvVol   := .F.

	Default _lAltVol := .F.

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE _cRotina + " - Altera��o de Volume/Esp�cie - " + cUserName                     FROM 000, 000 TO 350, 600 COLORS 0, 16777215 PIXEL
		@ 013, 011 GROUP oGroup1     TO 157, 287 PROMPT " Altera��o de Volume/Esp�cie e endere�o de expedi��o nos Doctos. Sa�da j� emitidos " OF oDlg     COLOR  0, 16777215 PIXEL
		@ 033, 018   SAY   oSay1 PROMPT "Nota Fiscal / S�rie: " + SF2->F2_DOC + " / " + SF2->F2_SERIE + "."   SIZE 260, 007 OF oDlg     COLORS 0, 16777215 PIXEL
		If _lAltVol
			@ 050, 018   SAY   oSay2 PROMPT "Volume:"                                                   SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 050, 053 MSGET   oGet1    VAR nGet1       Valid Positivo()     Picture "@E 999,999,999"   SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
			@ 050, 143   SAY   oSay3 PROMPT "Esp�cie:"                                                  SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 050, 183 MSGET   oGet2    VAR cGet2       Valid NaoVazio()     Picture "@!"               SIZE 094, 010 OF oDlg COLORS 0, 16777215 PIXEL
		EndIf
		@ 070, 018   SAY   oSay4 PROMPT "End.Exp.:"                                                 SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 070, 053 MSGET   oGet3    VAR cGet3       Valid NaoVazio()     Picture "@!"               SIZE 225, 010 OF oDlg COLORS 0, 16777215 PIXEL
		//02/05/2023 - Diego Rodrigues - Criado novo parametro para valida��o dos usu�rios
		//If _lAltVol .AND. __cUserId $  GetMV("MV_USRFATA")
		If _lAltVol .AND. __cUserId $  GetMV("MV_XUSRPES")
		//02/05/2023 - Diego Rodrigues - FIM
			@ 090, 018   SAY   oSay4 PROMPT "Peso L�q.:"                                            SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 090, 053 MSGET   oGet3    VAR _nPliq  Valid NaoVazio() Picture "@E 999,999,999.9999"  SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL
			@ 110, 018   SAY   oSay4 PROMPT "Peso Bruto.:"                                          SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 110, 053 MSGET   oGet3    VAR _nPBrut Valid NaoVazio() Picture "@E 999,999,999.9999"  SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL
		EndIf
		DEFINE SBUTTON oSButton1   FROM 135, 205 TYPE 01 OF oDlg ENABLE Action EVAL({||_lGrvVol := .T., Close(oDlg)})
		DEFINE SBUTTON oSButton2   FROM 135, 250 TYPE 02 OF oDlg ENABLE Action EVAL({||_lGrvVol := .F., Close(oDlg)})
	ACTIVATE MSDIALOG oDlg CENTERED

	If _lGrvVol .AND. MsgYesNo("Confirma a grava��o do Volume/Esp�cie/End.Exp./Peso?",_cRotina+"_001")
		//Trecho utilizado para o calculo do Peso Bruto no documento de saida, baseado num fator multiplicador sobre o volume informado.
	//	_nFatorVol := SuperGetMv("MV_FATPBRU",,0.20)
		_nFatorVol := SuperGetMv("MV_FATPBRU",,1.00) // - Alterado em 08/10/2014 por Anderson C. P. Coelho
		dbSelectArea("SF2")
		while !RecLock("SF2",.F.) ; enddo
			SF2->F2_ENDEXP  := cGet3
			//In�cio - Trecho adicionado por Adriano Leonardo em 25/02/2014 para desbloqueio da nota para transmiss�o
				If !Empty(SF2->F2_BLQ)
					If MsgYesNo("O processo de confer�ncia de separa��o n�o finalizado e a nota encontra-se bloqueada para transmiss�o, deseja liberar a nota para transmiss�o ao Sefaz?",_cRotina+"_006")
						SF2->F2_BLQ := ""
					EndIf
				EndIf
			//Final  - Trecho adicionado por Adriano Leonardo em 25/02/2014 para desbloqueio da nota para transmiss�o
			If _lAltVol
				SF2->F2_VOLUME1 := nGet1
				SF2->F2_ESPECI1 := cGet2
			//	SF2->F2_PBRUTO  := SF2->F2_PLIQUI + (SF2->F2_VOLUME1 * _nFatorVol) + (SF2->F2_VOLUME2 * _nFatorVol) + (SF2->F2_VOLUME3 * _nFatorVol) + (SF2->F2_VOLUME4 * _nFatorVol) // Alterado por Renan - Trecho comentado conforme solicita��o do Sr. Marcos e autoriza��o do Sr. Anderson para nao recalcular o Peso Bruto
				SF2->F2_PLIQUI  := _nPliq
				SF2->F2_PBRUTO  := _nPBrut
				SF2->F2_USRAVOL := __cUserId
				SF2->F2_DATAVOL := Date()
				SF2->F2_HORAVOL := Time()
			EndIf
		SF2->(MSUNLOCK())
		If _lAltVol
			MsgInfo("Volume " + cValToChar(nGet1) + " e Esp�cie " + AllTrim(cGet2) + " gravados com sucesso!",_cRotina+"_002")
		EndIf
		MsgInfo("Endere�o " + AllTrim(cGet3)  + " gravado com sucesso!",_cRotina+"_005")
	EndIf
return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EncerraExp�Autor  �Anderson C. P. Coelho � Data �  18/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Sub-Rotina para atualiza��o manual do processo de expedi��o���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function EncerraExp()
	Local oGet1
	Local oGet2
	Local oSay1
	Local oSay2
	Local oSay3
	Local oGroup1
	Local oSButton1
	Local _aSvAr     := GetArea()
	Local _aPedido   := {}
	Local _lAtuExp   := .F.
	Local _lRFATL001 := ExistBlock("RFATL001")			//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Vari�vel declarada para uso dentro do While para melhoria de perfomance, evitando assim que, no meio do loop, o sistema fique verificando se o P.E. existe ou n�o (v�rias vezes).
	Private _lEnt    := CHR(13) + CHR (10)
	Private _cLog    := ""

	dbSelectArea("SD2")
	_aSvSD2 := SD2->(GetArea())
	dbSelectArea("SUA")
	_aSvSUA := SUA->(GetArea())
	dbSelectArea("SC5")
	_aSvSC5 := SC5->(GetArea())

	Static oDlg
	DEFINE MSDIALOG oDlg TITLE _cRotina + " - Processo de Encerramento do Processo de Expedi��o - " + cUserName                     FROM 000, 000 TO 350, 600 COLORS 0, 16777215 PIXEL
		@ 013, 011 GROUP oGroup1     TO 157, 287 PROMPT " Altera��o do Status do Processo " OF oDlg     COLOR  0, 16777215 PIXEL
		@ 033, 018   SAY   oSay1 PROMPT "Nota Fiscal / S�rie: " + SF2->F2_DOC + " / " + SF2->F2_SERIE + "."   SIZE 259, 007 OF oDlg     COLORS 0, 16777215 PIXEL
		DEFINE SBUTTON oSButton1   FROM 135, 205 TYPE 01 OF oDlg ENABLE Action EVAL({||_lAtuExp := MsgYesNo("Encerra do processo de expedi��o neste momento?",_cRotina+"_004"), Close(oDlg)})
	ACTIVATE MSDIALOG oDlg CENTERED
	If _lAtuExp
		dbSelectArea("SF2")
		while !RecLock("SF2",.F.) ; enddo
			SF2->F2_USREXP  := __cUserId
			SF2->F2_DATAEXP := Date()
			SF2->F2_HORAEXP := Time()
		SF2->(MSUNLOCK())
		dbSelectArea("SD2")
		//SD2->(dbSetOrder(3))
		SD2->(dbOrderNickName("D2_DOC"))
		If SD2->(MsSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA,.T.,.F.))
			While !SD2->(EOF()) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == (xFilial("SD2") + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
				If aScan(_aPedido,SD2->D2_PEDIDO) == 0
					_cLogx := "Volume alterado para o docto.: " + ALLTRIM(SF2->F2_DOC) + " / " + ALLTRIM(SF2->F2_SERIE) + "."
					AADD(_aPedido,SD2->D2_PEDIDO)
					dbSelectArea('SUA')
					SUA->(dbOrderNickName("UA_NUMSC5"))
					If SUA->(MsSeek(xFilial("SUA") + SD2->D2_PEDIDO,.T.,.F.))
						while !RecLock("SUA", .F.) ; enddo
							SUA->UA_STATSC9 := "05" // - 05 "Pedido expedido"
							If SUA->(FieldPos("UA_LOGSTAT"))>0
								_cLog           := Alltrim(SUA->UA_LOGSTAT)
								SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt  + DTOC(Date()) + " - " + Time() + " - " +;
													UsrRetName(__cUserId) + _lEnt  + _cLogx
							EndIf
						SUA->(MsUnLock())
					EndIf
					// - Inserido em 24/03/2014 por J�lio Soares para gravar status tamb�m no quadro de vendas.
					dbSelectArea("SC5")
					SC5->(dbSetOrder(1))
					If SC5->(MsSeek(xFilial("SC5") + SD2->D2_PEDIDO,.T.,.F.))
						while !RecLock("SC5",.F.) ; enddo
							If SC5->(FieldPos("C5_LOGSTAT"))>0
								_cLog           := Alltrim(SC5->C5_LOGSTAT)
								SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt  + DTOC(Date()) + " - " + Time() + " - " + ;
													UsrRetName(__cUserId) + _lEnt  + _cLogx
							EndIf
						SC5->(MsUnlock())
					EndIf
					//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
					If _lRFATL001		//CUSTOM. ALLSS - 29/04/2019 - Anderson Coelho - Trecho alterado para melhoria de perfomance. Conte�do anterior: ExistBlock("RFATL001")
						U_RFATL001(	SC5->C5_NUM,;
									SUA->UA_NUM,;
									_cLogx     ,;
									_cRotina    )
					EndIf
				EndIf
				dbSelectArea("SD2")
				SD2->(dbSetOrder(3))
				SD2->(dbSKip())
			EndDo
		EndIf
	EndIf
	RestArea(_aSvSUA)
	RestArea(_aSvSC5)
	RestArea(_aSvSD2)
	RestArea(_aSvAr)
return
