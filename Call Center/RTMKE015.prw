#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RTMKE015 �Autor  �Adriano Leonardo    � Data �  17/12/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina respons�vel por replicar o percentual ou valor dos  ���
���          � campos de desconto e acr�scimo para que estes sejam preser_���
���          � vados ao se alterar o tipo de opera��o do atendimento.     ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RTMKE015()

Local _aSavArea := GetArea()
Local _cRotina	:= "RTMKE015"
Local _lRet    := .T.      

If AllTrim(ReadVar()) == "M->UB_VALDESC" //Campo padr�o valor do desconto
	If M->UB_VALDESC<>aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDESC"})]
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDAUX"})] := M->UB_VALDESCC //Campo auxiliar valor do desconto
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCAUX"})] := 0              //Campo auxiliar percentual do desconto
	EndIf
ElseIf AllTrim(ReadVar()) == "M->UB_DESC" //Campo padr�o percentual de desconto
	If M->UB_DESC<>aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESC"   })]
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_DESCAUX"})] := M->UB_DESC    //Campo auxiliar percentual do desconto
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALDAUX"})] := 0             //Campo auxiliar valor do desconto
	EndIf
EndIf
If AllTrim(ReadVar()) == "M->UB_VALACRE" //Campo padr�o valor do acr�scimo
	If M->UB_VALACRE<>aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_VALACRE"})]
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREVAL"})] := M->UB_VALACRE //Campo auxiliar valor do acr�scimo
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREPOR"})] := 0             //Campo auxiliar percentual do acr�scimo
	EndIf
ElseIf AllTrim(ReadVar()) == "M->UB_ACRE" //Campo padr�o percentual de acr�scimo
	If M->UB_ACRE<>aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACRE"   })]
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREPOR"})] := M->UB_ACRE    //Campo auxiliar percentual do acr�scimo
		aCols[n][aScan(aHeader,{|x|AllTrim(x[02])=="UB_ACREVAL"})] := 0             //Campo auxiliar valor do acr�scimo
	EndIf
EndIf

RestArea(_aSavArea)

Return(_lRet)