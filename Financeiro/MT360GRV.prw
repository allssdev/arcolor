#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � MT360GRV �Autor  � Adriano L. de Souza � Data �  24/04/2014  ���
��������������������������������������������������������������������������͹��
���Desc.   � Ponto de entrada ap�s a grava��o da condi��o de pagamento,     ��
���Desc.   � utilizado para gravar o prazo m�dio da condi��o.              ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

User Function MT360GRV()

Local _aSavArea := GetArea()
Local _aSavSE4	:= SE4->(GetArea())
Local _nPrazoMd := 0

dbSelectArea("SE4")

If SE4->(FieldPos("E4_PRAZOMD"))<>0 // Certifico se o campo foi criado
	If ExistBlock("RFINE018")
		while !RecLock("SE4",.F.) ; enddo
			SE4->E4_PRAZOMD := U_RFINE018(SE4->E4_CODIGO) //Chamada da rotina para calcular o prazo m�dio da condi��o
		SE4->(MsUnlock())
	EndIf
EndIf

RestArea(_aSavSE4)
RestArea(_aSavArea)

Return()