#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M455FIL   �Autor  �Anderson C. P. Coelho � Data �  25/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para a filtragem espec�fica de registros  ���
���          �na tabela SC9, relativo aos itens para a libera��o de       ���
���          �estoque. A filtragem aqui executada � feita quando a rotina ���
���          �� chamada pela fun��o "RFATA006".                           ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function M455FIL()
	Local _aSavArea := GetArea()
	Local _aSavSC5  := SC5->(GetArea())
	Local _aSavSC9  := SC9->(GetArea())
	Local _cFilSC9  := ""
	If AllTrim(FunName()) == "RFATA026"
	//	_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + SC5->C5_NUM + "' .AND. AllTrim(C9_BLEST) <> '10' "
		_cFilSC9 := " SC9->C9_FILIAL == '" + xFilial("SC9") +"' .AND. SC9->C9_PEDIDO == '" + SC5->C5_NUM + "' .AND. AllTrim(SC9->C9_BLEST) <> '10' "
	EndIf
return(_cFilSC9)