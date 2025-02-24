#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RFATE034 �Autor  � Adriano Leonardo     �  Data  � 13/01/14  ���
��������������������������������������������������������������������������͹��
���Desc.    � Execblock utilizado no inicializador padr�o do campo         ���
���         � C5_DESCFIN, para apresentar o desconto financeiro do cliente ���
���         � Quando for inicializador padr�o do browser passar .T. como   ���
���         � par�metro.                                                   ���
��������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor             ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/

User Function RFATE034(_lBrowse)

Local _aSavArea  := GetArea()
Local _aSavSA1 	 := SA1->(GetArea())
Local _cRotina   := "RFATE034"
Local _nRet	     := 0
Default _lBrowse := .F.

If _lBrowse
	_cTipo  := "SC5->C5_TIPO"
	_cChave := "SC5->C5_CLIENTE + SC5->C5_LOJACLI"
Else
	_cTipo  := "M->C5_TIPO"
	_cChave := "M->C5_CLIENTE + M->C5_LOJACLI"
EndIf

If !(&_cTipo $ "D/B")
	dbSelectArea("SA1")
	dbSetOrder(1)
	If SA1->(MsSeek(xFilial("SA1")+&_cChave))
		_nRet := SA1->A1_DESCFIN
	EndIf
EndIf

RestArea(_aSavSA1)
RestArea(_aSavArea)

Return(_nRet)