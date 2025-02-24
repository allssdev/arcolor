#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _lEnt CHR(13) + CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TMK150EXC �Autor  �Microsiga           � Data �  10/06/15  ���
�������������������������������������������������������������������������͹��
���Desc TOTVS� Ponto de entrada para valida��o da exclus�o de um          ���
���          � atendimento do tipo faturamento no Televendas.             ���
�������������������������������������������������������������������������͹��
���          � Ponto de entrada utilizado para validar a exclus�o do      ���
���          � atendimento se esse est� vinculado a um pedido.            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TMK150EXC()

Local _aSavArea  := GetArea()
Local _aSavSUA   := SUA->(GetArea())
Local _lRet      := .T.
Local _cRotina   := "TMK150EXC"

If !Empty(SUA->UA_NUMSC5)
	//Precisa inserir o numero do pedido para verificar se n�o ir� ter problemas com o posicionamento.
	_cLog := Alltrim(SUA->UA_LOGSTAT)
	If SUA->(FieldPos("UA_LOGSTAT"))>0
		RecLock("SUA",.F.)
			SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) +;
								_lEnt + "CANCELAMENTO DO ATENDIMENTO VINCULADO AO PEDIDO N�"+ALLTRIM(SUA->UA_NUMSC5)+"."
		SUA->(MsUnLock())
	EndIf
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	If ExistBlock("RFATL001")
		U_RFATL001(	SUA->UA_NUMSC5,;
					SUA->UA_NUM,;
					"Cancelamento do Atendimento.",;
					_cRotina)
	EndIf
EndIf
RestArea(_aSavSUA)
RestArea(_aSavArea)

Return(_lRet)