#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATE038 � Autor �Adriano Leonardo      � Data �  25/02/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Execblock utilizado para calcular o fator do desconto com  ���
���          � base nos descontos 1, 2, 3 e 4 para regra de neg�cio.      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFATE038()

Local _aSavArea := GetArea()
Local _cRotina 	:= "RFATE038"
Local _nAux	    := 100
Local _nFator	:= 0
Local _aDesc	:= {}
               
//Posi��o dos descontos no aCols
AAdd(_aDesc,aScan(aHeader,{|x|AllTrim(x[02])=="ACN_DESCV1"}))
AAdd(_aDesc,aScan(aHeader,{|x|AllTrim(x[02])=="ACN_DESCV2"}))
AAdd(_aDesc,aScan(aHeader,{|x|AllTrim(x[02])=="ACN_DESCV3"}))
AAdd(_aDesc,aScan(aHeader,{|x|AllTrim(x[02])=="ACN_DESCV4"}))

_nPosFator := aScan(aHeader,{|x|AllTrim(x[02])=="ACN_FATOR"})

//Varre o array com os campos de desconto para calcular o desconto em cascata
For _nCont := 1 To Len(_aDesc)
	If aCols[n,_aDesc[_nCont]] > 0
		_nAux := _nAux - (_nAux * ((aCols[n,_aDesc[_nCont]])/100))
 	EndIf
 	_nFator := (100 - _nAux)
Next

//Gravo o fator calculado
M->ACN_FATOR := aCols[n,_nPosFator] := _nFator

RestArea(_aSavArea)

Return(_nFator)