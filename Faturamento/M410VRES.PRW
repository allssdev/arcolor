#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M410VRES  �Autor  �J�lio Soares       � Data �  21/10/13   ���
�������������������������������������������������������������������������͹��
���Desc.TOTVS� Este ponto de entrada � executado ap�s a confirma��o da    ���
���          � elimina��o de residuos no pedido de venda e antes do inicio���
���          � da transa��o do mesmo.                                     ���
�������������������������������������������������������������������������͹��
���Desc.     � Essa rotina est� sendo utilizado para a atualiza��o das    ���
���          � legendas tanto para os pedidos de vendas (SC5) quanto para ���
���          � o atendimento (SUA) referente.                             ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M410VRES()

Local    _aSavArea := GetArea()
Local    _aSavSC5  := SC5->(GetArea())
Local    _aSavSUA  := SUA->(GetArea())
Local    _cRotina  := "M410VRES"
Local    _cLogx    := "Res�duo Eliminado"
Local    _cCli     := SC5->C5_CLIENTE
Local    _cLoja    := SC5->C5_LOJACLI
Local    _cNum     := SC5->C5_NUM

Private  _lRet     := .T.
Private  _lEnt     := CHR(13) + CHR (10)
Private  _cLog     := ""

// Precisa verificar se est� liberado para elimina��o
If Upper(AllTrim(FunName()))=="MATA410" .OR. Upper(AllTrim(FunName()))=="MATA500"
	while !RecLock('SC5',.F.) ; enddo
		SC5->C5_SALDO := 'R'
		// - Inserido em 24/03/2014 por J�lio Soares para gravar status tamb�m no quadro de vendas.
		If SC5->(FieldPos("C5_LOGSTAT"))>0
			_cLog           := Alltrim(SC5->C5_LOGSTAT)
			SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
								UsrRetName(__cUserId)+ _lEnt + _cLogx
		EndIf
		// - --------------------------------------------------------------------------------------
	SC5->(MsUnlock())
	dbSelectArea('SUA')
	SUA->(dbOrderNickName("UA_NUMSC5"))
	If SUA->(MsSeek(xFilial('SUA')+_cNum,.T.,.F.))
		while !RecLock('SUA',.F.) ; enddo
			SUA->UA_CODCANC := '*'
			If SUA->(FieldPos("UA_LOGSTAT")) > 0
				_cLog           := Alltrim(SUA->UA_LOGSTAT) + _lEnt
				SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
									UsrRetName(__cUserId) + _lEnt + _cLogx
			EndIf
			// Implementado por J�lio Soares em 11/12/2013 ap�s realizar atualiza��es na legenda.
			If SUA->(FieldPos("UA_STATSC9")) > 0
				SUA->UA_STATSC9 := ''
			EndIf
		SUA->(MsUnlock())
	Else
		MSGBOX('Numero do atendimento n�o encontrado, informe o Administrador do sistema com o n� do pedido => '+ _cNum,_cRotina+'_01','ALERT')
	EndIf
EndIf
//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
If ExistBlock("RFATL001")
	U_RFATL001(	SC5->C5_NUM,;
				SUA->UA_NUM,;
				_cLogx     ,;
				_cRotina    )
EndIf
RestArea(_aSavSUA )
RestArea(_aSavSC5 )
RestArea(_aSavArea)

Return(_lRet)