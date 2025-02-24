#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA120G2  �Autor  �Adriano Leonardo    � Data � 20/03/2014  ���
�������������������������������������������������������������������������͹��
���Desc. � Ponto de entrada utilizado para manipula��o das legendas do    ���
���      � browse do pedido de compra (cores x condi��es).                ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MT120COR()

Local _aSavArea	:= GetArea()
Local aCores	:= aClone(PARAMIXB[1]) //Array com as condi��es padr�es das legendas do browse dos pedidos de compra
Local _aCores	:= {}

// Redesenvolvido Legendas, devido a solicita��o da Sra. Elaine. 
If FunName() == "MATA121"
	_aCores  := {{" C7_TIPO!=nTipoPed  																									    ",'BR_AZUL_CLARO' },;	// Contrato Parceria	- AZUL CLARO
			 	{ " !EMPTY(C7_RESIDUO) 																									    ",'BR_CINZA' 	  },;	// Com Res�duo Eliminado- CINZA
			 	{ " C7_ACCPROC<> '1' .AND.  C7_CONAPRO== 'B' .AND. C7_QUJE < C7_QUANT .AND. (UPPER(C7_DEPART)<>'C' .AND. !EMPTY(C7_DEPART)) ",'BR_PINK'       },;	// Em Aprova��o Outros	- PINK
			 	{ " C7_ACCPROC<> '1' .AND.  C7_CONAPRO== 'B' .AND. C7_QUJE < C7_QUANT   													",'BR_AZUL' 	  },;	// Em Aprova��o			- AZUL
			 	{ "	C7_ACCPROC<>'1'  .AND.  C7_CONAPRO=='R'  .AND. C7_QUJE < C7_QUANT  														",'BR_CANCEL' 	  },;	// Reprovado			- X
			 	{ " !Empty(C7_CONTRA).AND.  Empty(C7_RESIDUO)	 																			",'BR_BRANCO' 	  },;	// Pedido de Contrato	- BRANCO
			 	{ " C7_QUJE==0 		 .AND.  C7_QTDACLA==0 	 .AND. (Upper(C7_DEPART)<>'C' .AND. !Empty(C7_DEPART))							",'BR_MARRON'	  },;	// Pedido Pend. Outros  - MARRON
			 	{ " C7_QUJE==0 		 .AND. C7_QTDACLA==0 																					",'ENABLE' 		  },;	// Pendente				- VERDE
			 	{ " C7_QUJE<>0		 .AND. C7_QUJE<C7_QUANT																					",'BR_AMARELO' 	  },;	// Recebido Parcial		- AMARELO
			 	{ " C7_QUJE>=C7_QUANT 																										",'DISABLE' 	  },;	// Recebido	  			- VERMELHO
			 	{ " C7_QTDACLA >0  																											",'BR_LARANJA'    }}	// Em Recebimento 		- LARANJA
Else
	_aCores := aCores // Rotina MATA122 (Autoriza��o Entrega)
EndIf
/*
//Verifico a exist�ncia do campo a ser utilizado na condi��o da legenda
If FieldPos("C7_DEPART")<>0
	_nCont := 0
	For _nPos := 1 To Len(aCores)
		//Manipulo as condi��es padr�es, adicionando novas condi��es (concatenando) para as legendas de cor verde (pendente) e azul (bloqueado)
		If AllTrim(aCores[_nPos,2]) == "ENABLE" .Or. AllTrim(aCores[_nPos,2]) == "BR_AZUL"
			_cCondicao := aCores[_nPos][1] + IIF(Empty(aCores[_nPos][1])," "," .And. ") + "(Upper(C7_DEPART)<>'C' .And. !Empty(C7_DEPART))"
			If AllTrim(aCores[_nPos,2]) == "ENABLE"
				_cCorLegen := "BR_MARRON"
			Else //BR_AZUL
				_cCorLegen := "BR_PINK"
			EndIf
			AADD(aCores,{_cCondicao,_cCorLegen})
			aCores[_nPos][1] += IIF(Empty(aCores[_nPos][1])," "," .And. ") + "(Upper(C7_DEPART)=='C' .Or. Empty(C7_DEPART))"
			_nCont++
		EndIf
		//Otimiza o processamento, para que o la�o de repeti��o seja encerrado assim que os resultados esperados sejam encontrados
		If _nCont==2
			Exit
		EndIf
	Next
EndIf*/

RestArea(_aSavArea)

Return(_aCores)