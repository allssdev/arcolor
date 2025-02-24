#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RTMKE024 �Autor  � Adriano L. de Souza � Data � 30/04/2014   ���
��������������������������������������������������������������������������͹��
���Desc.   � Fun��o desenvolvida para validar o prazo m�dio de pagamento   ���
���Desc.   � permitido para o cliente.                                     ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

User Function RTMKE024(_cCondPag)

Local _cRotina		:= "RTMKE024"
Local _aSavTmp		:= GetArea()
Local _aSavSA1		:= SA1->(GetArea())
Local _aSavSE4		:= SE4->(GetArea())
Local _lValid  		:= .T.

Default _cCondPag 	:= M->UA_CONDPG

dbSelectArea("SA1")
SA1->(dbSetOrder(1))
//Verifico se o campo necess�rio foi criado (customizado)
If	SA1->(FieldPos("A1_PRAZOMD"))<>0
	//Localizo o cliente
	If SA1->(MsSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,.T.,.F.))
		//Certifico que h� um prazo definido para o cliente
		If SA1->A1_PRAZOMD <> 0
			//Localizo a condi��o de pagamento utilizada no atendimento
			dbSelectArea("SE4")
			SE4->(dbSetOrder(1))
			If	SE4->(FieldPos("E4_PRAZOMD"))<>0
				If SE4->(MsSeek(xFilial("SE4")+_cCondPag,.T.,.F.))
					If SE4->E4_PRAZOMD > SA1->A1_PRAZOMD
						_cMsg 	:= "O prazo m�dio dessa condi��o de pagamento � superior ao permitido para este cliente!"
						If SA1->A1_COND == SE4->E4_CODIGO
							_cEnt := CHR(13) + CHR(10)
							_cMsg += _cEnt + _cEnt + "Sugest�o: Altere a condi��o padr�o definida no cadastro do cliente ou o prazo m�dio permitido para ele, para que essa mensagem n�o se repita nos pr�ximos atendimentos!"
						EndIf
						MsgAlert(_cMsg,_cRotina+"_001")
						_lValid := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

//Restauro a �rea de trabalho inicial
RestArea(_aSavSE4)
RestArea(_aSavSA1)
RestArea(_aSavTmp)

Return(_lValid)