#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE065  �Autor  �Anderson C. P. Coelho � Data �  07/04/17 ���
�������������������������������������������������������������������������͹��
���Desc.     � ExecBlock utiliza para carregar o inicializador padr�o de  ���
���          �alguns campos da SF2 no browse.                             ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

user function RFATE065(_cCpoSE1)

Local   _aSavArea := GetArea()
Local   _aSavSF2  := SF2->(GetArea())
Local   _aSavSE1  := SE1->(GetArea())
Local   _cRet     := ""

Default _cCpoSE1  := ""

dbSelectArea("SE1")
SE1->(dbSetOrder(2))
If !Empty(_cCpoSE1) .AND. SE1->(MsSeek(xFilial("SE1") + SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DUPL),.T.,.F.))
	_cRet := &("SE1->"+_cCpoSE1)
EndIf

RestArea(_aSavSF2)
RestArea(_aSavSE1)
RestArea(_aSavArea)

return(_cRet)