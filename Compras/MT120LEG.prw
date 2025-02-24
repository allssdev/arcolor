#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT120LEG �Autor  �Adriano Leonardo    � Data � 21/03/2014  ���
�������������������������������������������������������������������������͹��
���Desc. � Ponto de entrada utilizado para manipula��o das legendas do    ���
���      � browse de pedido de compra (cores x descri��o).                ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MT120LEG()

Local _aSavArea	:= GetArea()
Local aCores	:= aClone(PARAMIXB[1]) //Array contendo as legendas padr�es dos pedidos de compra

//Verifico a exist�ncia do campo utilizado como flag para as legendas customizadas
If FieldPos("C7_DEPART")<>0
	_nCont := 0
	For _nPos := 1 To Len(aCores)
		//Altero a descri��o das legendas de cor verde (pendente) e azul (bloqueado)
		If AllTrim(aCores[_nPos,1]) == "ENABLE" .Or. AllTrim(aCores[_nPos,1]) == "BR_AZUL"
			aCores[_nPos][2] += " (Departamento Compras)"
			_nCont++
		EndIf
		//Otimiza o processamento, para que o la�o de repeti��o seja encerrado assim que as condi��es esperadas sejam atendidas
		If _nCont==2
			Exit
		EndIf
	Next
EndIf

//Adiciono novas legendas
aAdd(aCores, {'BR_MARRON','Pedido Pendente (Outros Departamentos)'  })
aAdd(aCores, {'BR_PINK'  ,'Pedido Bloqueado (Outros Departamentos)' })
If FunName() == "MATA121"
	aAdd(aCores, {'BR_AZUL_CLARO'  ,'Contrato Parceria' })
EndIf	

RestArea(_aSavArea)

Return(aCores)