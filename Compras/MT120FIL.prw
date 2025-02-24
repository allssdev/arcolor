#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT120FIL � Autor � Adriano Leonardo   � Data � 21/03/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para filtrar o browse do pedido ���
���          � de compra.                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MT120FIL()
                            
Local _aSavArea := GetArea()
Local _aSavSY1  := SY1->(GetArea())
Local _cRotina  := "MT120FIL"
Local _cRet 	:= ""

dbSelectArea("SY1")			//Compradores
SY1->(dbSetOrder(3)) 		//Filial + Usu�rio
If SY1->(MsSeek(xFilial("SY1")+__cUserId,.T.,.F.))
	If SY1->Y1_DEPART == "C"
		_cRet := ""
	Else
		_cRet := "AllTrim(C7_USERINC)=='" + AllTrim(__cUserId) + "'"
	EndIf
EndIf

RestArea(_aSavSY1)
RestArea(_aSavArea)

Return(_cRet)