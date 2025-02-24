#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE025  �Autor  �Anderson C. P. Coelho � Data �  26/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock utilizado para posicionar o registro da Ordem de ���
���          �Separa��o, proveniente da Administra��o de Pedidos(RFATA006)���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE025()

Local _aSavArea := GetArea()
Local _aSavCB7  := CB7->(GetArea())
Local _cRotina  := "RFATE025"

dbSelectArea("CB7")
CB7->(dbSetOrder(1))
If CB7->(MsSeek(xFilial("CB7") + (_cTbTmp1)->C9_ORDSEP,.T.,.F.))
	ACDA100()
Else
	CB7->(dbGoTop())
	ACDA100()
EndIf
If Type("oBrowse")=="O"
	//oBrowse:ChangeTopBot(.T.)
	oBrowse:Refresh()
EndIf
/*
If Type("_oObj")=="O"
	_oObj:Default()
	_oObj:Refresh()
EndIf
*/
RestArea(_aSavCB7)
RestArea(_aSavArea)

If ExistBlock("RFATA26U")
	ExecBlock("RFATA26U")
EndIf

Return