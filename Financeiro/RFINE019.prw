#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RFINE019 �Autor  � Adriano L. de Souza � Data �  02/05/2014  ���
��������������������������������������������������������������������������͹��
���Desc.   � Rec�lculo do prazo m�dio da condi��o de pagamento, para atuali-��
���Desc.   � za��o em massa do cadastro.                                   ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

User Function RFINE019()

Local _aSavArea := GetArea()
Local _aSavSE4	:= SE4->(GetArea())
Local _nPrazoMd := 0 
Private _cRotina:= "RFINE019"

If !MsgYesNo("Essa rotina ir� recalcular o prazo m�dio de todas as condi��es de pagamento, deseja continuar?")
	Return()
EndIf

Processa({||Atualiza()},"Aguarde...")

MsgInfo("Finalizado!", _cRotina+"_019")

RestArea(_aSavSE4)
RestArea(_aSavArea)

Return()

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RFINE019 �Autor  � Adriano L. de Souza � Data �  02/05/2014  ���
��������������������������������������������������������������������������͹��
���Desc.   � Fun��o desenvolvida para atualiza��o em massa do prazo m�dio   ��
���Desc.   � das condi��es de pagamentos.                                  ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/
Static Function Atualiza()
Local _lRFINE018 := ExistBlock("RFINE018")

	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))
	SE4->(dbGoTop())
	ProcRegua(RecCount())
	While SE4->(!EOF())
		IncProc()
		If SE4->(FieldPos("E4_PRAZOMD"))<>0 .And. xFilial("SE4")==SE4->E4_FILIAL // Certifico se o campo foi criado
			/* FB - 12.1.23
			If ExistBlock("RFINE018")
			*/
			If _lRFINE018
				while !RecLock("SE4",.F.) ; enddo
					SE4->E4_PRAZOMD := U_RFINE018(SE4->E4_CODIGO) //Chamada da rotina para calcular o prazo m�dio da condi��o
				SE4->(MsUnlock())
			EndIf
		
		EndIf
		dbSelectArea("SE4")
		SE4->(dbSetOrder(1))
		SE4->(dbSkip())
	EndDo	
return