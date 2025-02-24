#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � MA450COR  �Autor  � Adriano Leonardo   � Data �  27/02/14   ���
���������������������������������������������������������������������������ͱ�
���Desc.     �Ponto de entrada para edi��o das descri��es das legendas na  ���
���          �tela de acompanhamento de pedidos.                           ���
��������������������������������������������������������������������������͹��
���Uso       � Protheus 11 -  Especifico para a empresa Arcolor.           ���
���������������������������������������������������������������������������ͱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/

User Function MA450COR()

Local _aSavArea := GetArea()
Local _aRet		:= PARAMIXB  //Array contendo as legendas do MATA450

AAdd(_aRet, {'BR_BRANCO' ,'Alta Prioridade'})

RestArea(_aSavArea)

Return(_aRet)