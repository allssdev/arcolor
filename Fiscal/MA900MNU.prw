#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA900MNU  �Autor  �Anderson C. P. Coelho � Data �  19/11/14 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada na rotina de Ajustes Fiscais (MATA900),   ���
���          � utilizado para alterar a rotina "A900Altera" por uma fun��o���
���          �pr�pria que chama a rotina padr�o e depois altera a data de ���
���          �digita��o do documento de entrada para a data de recebimento���
���          �do referido documento de entrada.                           ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Especifico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MA900MNU()
	Local _cRotina  := "MA900MNU"
	Local _aSavArea := GetArea()
	Local _nPosFAlt := aScan(aRotina,{|x| AllTrim(x[02])=="A900Altera"})
	If _nPosFAlt > 0
		aRotina[_nPosFAlt][02] := "U_RFISE001()"
	EndIf
	RestArea(_aSavArea)
Return(aRotina)