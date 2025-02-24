#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RTMKE016 �Autor  �Adriano Leonardo    � Data �  18/12/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina respons�vel por replicar o valor do desconto do item���
���          � do atendimento (Call Center) em campo auxiliar.            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RTMKE016(_lGatil)

Local _aSavArea := GetArea()
Local _cRotina	:= "RTMKE016"
Local _lRet		:= .T.
Default _lGatil	:= .F. //Vari�vel auxiliar para determinar se a chamada da rotina est� sendo feita por gatilho, por conta do retorno

//Resgato as posi��es das colunas no aCols
_nPValDesc := aScan(aHeader,{|x|AllTrim(x[02])==AllTrim("UB_VALDESC")})
_nPPValDAu := aScan(aHeader,{|x|AllTrim(x[02])==AllTrim("UB_VALDAUX")})

//Verifico se houve mudan�a
If aCols[n,_nPPValDAu] <> aCols[n,_nPValDesc]
	aCols[n,_nPPValDAu] := aCols[n,_nPValDesc]
EndIf

If _lGatil
	_lRet := aCols[n,_nPValDesc]
EndIf

RestArea(_aSavArea)

Return(_lRet)