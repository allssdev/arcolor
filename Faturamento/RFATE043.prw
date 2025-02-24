#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RFATE043 �Autor  � Adriano L. de Souza � Data � 02/05/2014   ���
��������������������������������������������������������������������������͹��
���Desc.   � Execblock de valida��o da condi��o de pagamento no pedido de  ���
���        � vendas, esse execblock ser� chamado na rotina de valida��o do ���
���        � pedido via f�rmula e retornar se o mesmo poder� ou n�o ser    ���
���        � liberado.                                                     ���
���        � Obs. Essa valida��o s� ser� processada em pedidos de saldo.   ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

User Function RFATE043(_cCondPag,_lAlert)

Local _cRotina		:= "RFATE043"
Local _aSavTmp		:= GetArea()
Local _aSavSA1		:= SA1->(GetArea())
Local _aSavSE4		:= SE4->(GetArea())
Local _lValid  		:= .T.
Default _cCondPag 	:= M->C5_CONDPG2

dbSelectArea("SA1")
dbSetOrder(1)

//Verifico se o campo necess�rio foi criado (customizado) e se o pedido n�o � de devolu��o ou beneficiamento
If	SA1->(FieldPos("A1_PRAZOMD"))<>0 .And. !(M->C5_TIPO $ "B|D") .And. AllTrim(Upper(M->C5_SALDO))=="S"
	
	//Localizo o cliente
	If SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
		
		//Certifico que h� um prazo definido para o cliente
		If SA1->A1_PRAZOMD <> 0
			
			//Localizo a condi��o de pagamento utilizada no atendimento
			dbSelectArea("SE4")
			dbSetOrder(1)
			If	SE4->(FieldPos("E4_PRAZOMD"))<>0
				If SE4->(dbSeek(xFilial("SE4")+_cCondPag))
					If SE4->E4_PRAZOMD > SA1->A1_PRAZOMD
						_cMsg 	:= "O prazo m�dio dessa condi��o de pagamento � superior ao permitido para este cliente!"
						If SA1->A1_COND == SE4->E4_CODIGO
							_cEnt := CHR(13) + CHR(10)
							_cMsg += _cEnt + _cEnt + "Sugest�o: Altere a condi��o de pagamento padr�o definida no cadastro do cliente ou o prazo m�dio permitido para ele, para que essa mensagem n�o se repita nos pr�ximos pedidos desse cliente!"
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