#INCLUDE "RWMAKE.CH"                                                               
#INCLUDE "PROTHEUS.CH"                                                                        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKC001  �Autor  �Adriano Leonardo    � Data �  01/04/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de hist�rico de clientes  (tabela SZC) utilizada para ���
���          � cadastro de observa��es de cobran�a.                       ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arc�lor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                          

User Function RTMKC001()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local _aSavArea   := GetArea()
Local _aSavSA1    := {}
Local _aBkpRot    := IIF(Type("aRotina")<>"U",aClone(aRotina),{})
Local _cFNamBk    := FunName()
Local _cRotina    := "RTMKC001"
Local cVldAlt     := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc     := ".F." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private _cString  := "SZC"

dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())

dbSelectArea(_cString)
(_cString)->(dbSetOrder(2))
If AllTrim(FunName())=="MATA030"
	If MsgYesNo("Filtra o cliente posicionado (" + SA1->A1_NOME + ")?",_cRotina+"_001")
		SetFunName(_cRotina)
		dbClearFilter()
		Set Filter To SZC->ZC_CODCLI == SA1->A1_COD .AND. SZC->ZC_LOJA == SA1->A1_LOJA
		dbFilter()
	EndIf
EndIf

AxCadastro(_cString,"Hist�rico de Clientes - Cobran�a",cVldExc,cVldAlt)

Set Filter To 
dbFilter()
dbClearFilter()

SetFunName(_cFNamBk)
aRotina := aClone(_aBkpRot)
RestArea(_aSavSA1)
RestArea(_aSavArea)

Return()