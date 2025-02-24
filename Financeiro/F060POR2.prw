#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � F060POR2  �Autor  � Arthur Silva		  � Data �  30/11/16   ���
���������������������������������������������������������������������������ͱ�
���Desc.TOTVS� O ponto de entrada F060POR2 valida o portador na 		   ���
���          � transfer�ncia de situa��o cobran�a quando a situa��o atual  ���
���          � 	do t�tulo utiliza portador (diferente de 0= Carteira, 	   ���
���          � 	F= Carteira Protesto, G= Carteira Acordo, 				   ���
���          � 	H=Cobran�a cart�rio) para uma situa��o em que n�o 		   ���
���          � 	� utilizado portador.									   ���
���������������������������������������������������������������������������ͱ�
���Desc.     � Esse ponto de entrada � chamado apenas na op��o TRANSFERIR  ���
���          � da rotina FINA060, n�o se aplica a gera��o de border�.	   ���
��������������������������������������������������������������������������͹��
���Uso       � Protheus 11 -  Espec�fico para a empresa Arcolor.           ���
���������������������������������������������������������������������������ͱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

User function F060POR2()

Local _aSavArea	:= GetArea()
Local _cRotina	:= "F060POR2"


// Este ponto de Entrada esta sendo utilizado somente para manter o "NOSSO N�MERO(E1_NUMBCO)" ao tranferir os t�tulos entre carteiras.
// Ap�s esse P.E ser somente compilado, ao realizar qualquer transfer�ncia entre carteiras o "NOSSO N�MERO(E1_NUMBCO)" foi mantido no devido campo.

RestArea(_aSavArea)
Return