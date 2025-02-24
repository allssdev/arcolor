#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE _lEnt CHR(13)+CHR(10)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MTA450R     �Autor  �J�lio Soares     � Data �  14/02/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada na avalia��o do cr�dito do cliente        ���
���          �(MATA450A)para atualizar o campo da tabela SUA com o status.���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function MTA450R()
	Local _aSavArea := GetArea()
	Local _aSavSC9  := SC9->(GetArea())
	Local _aSavSUA  := SUA->(GetArea())
	Local _aSavSC5  := SC5->(GetArea())
	Local _lRet     := .T.
	Local _cLogx    := ""
	Local _cRotina  := "MTA450R"
	Private _cLog   := ""

	dbSelectArea("SUA")
	SUA->(dbOrderNickName("UA_NUMSC5"))
	If SUA->(MsSeek(xFilial("SUA") + SC9->C9_PEDIDO,.T.,.F.))
		_cLog := Alltrim(SUA->UA_LOGSTAT)
		If SC9->C9_BLEST == "02" .AND. Empty(SC9->C9_BLCRED)
			_cLogx := "PEDIDO EM AVALIA��O DE DISPONIBILIDADE DE ESTOQUE."
			while !RecLock("SUA", .F.) ; enddo
				SUA->UA_STATSC9 := "03"
				If SUA->(FieldPos("UA_LOGSTAT"))>0
					SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
										UsrRetName(__cUserId) + _lEnt + _cLogx
				EndIf
			SUA->(MsUnLock())
		Else
			If Empty(SUA->UA_STATSC9)
				_cLogx := "PEDIDO DE VENDA AGUARDANDO LIBERA��O DE CR�DITO."
				while !RecLock("SUA", .F.) ; enddo
					SUA->UA_STATSC9 := "02"
					If SUA->(FieldPos("UA_LOGSTAT"))>0
						SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
											UsrRetName(__cUserId) + _lEnt + _cLogx
					EndIf
				SUA->(MsUnLock())
			EndIf
		EndIf
	EndIf
	// - Inserido em 24/03/2014 por J�lio Soares para gravar status tamb�m no quadro de vendas.
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		_cLog := Alltrim(SC5->C5_LOGSTAT)
		If SC9->C9_BLEST == "02" .AND. Empty(SC9->C9_BLCRED)
			_cLogx := "PEDIDO EM AVALIA��O DE DISPONIBILIDADE DE ESTOQUE"
			If SC5->(FieldPos("C5_LOGSTAT"))>0
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
										UsrRetName(__cUserId) + _lEnt + _cLogx
				SC5->(MsUnLock())
			EndIf
		Else
			_cLogx := "PEDIDO DE VENDA AGUARDANDO LIBERA��O DE CR�DITO."
			If SC5->(FieldPos("C5_LOGSTAT"))>0
				while !RecLock("SC5",.F.) ; enddo
					SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
										UsrRetName(__cUserId) + _lEnt + _cLogx
				SC5->(MsUnLock())
			EndIf
		EndIf
	EndIf
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	If ExistBlock("RFATL001")
		U_RFATL001(	SC5->C5_NUM  ,;
					SUA->UA_NUM,;
					_cLogx     ,;
					_cRotina    )
	EndIf
	// - --------------------------------------------------------------------------------------
	//��������������������������
	//� SUA->UA_STATSC9        �
	//�01 - Bloqueio de Regra  �
	//�02 - Bloqueio de Cr�dito�
	//�03 - Bloqueio de Estoque�
	//�04 - Pedido em Separa��o�
	//�05 - Pedido expedido    �
	//��������������������������
	RestArea(_aSavSUA)
	RestArea(_aSavSC5)
	RestArea(_aSavSC9)
	RestArea(_aSavArea)
return(_lRet)