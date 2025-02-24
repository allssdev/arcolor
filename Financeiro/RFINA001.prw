#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINA001  �Autor  �Anderson C. P. Coelho � Data �  28/12/12 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina chamada em substitui��o a fun��o padr�o FA070LOT,   ���
���          �por meio do Ponto de Entrada F070BROW, utilizada para       ���
���          �refazer o filtro na tabela SE1, quando da sa�da da rotina de���
���          �Baixas a Receber por Lote.                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINA001()

Local _aSavArea := GetArea()
Local cAlias    := Alias()
Local nReg      := Recno()
Local nOpcx     := 4

Fa070Lot( cAlias,nReg,nOpcx )

If ExistBlock("F070BROW")
	ExecBlock("F070BROW")
EndIf

RestArea(_aSavArea)

Return