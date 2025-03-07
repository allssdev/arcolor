/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKC002  �Autor  �Adriano Leonardo    � Data �  28/05/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de cadastro de hist�rico (tabela SZD) utilizada para  ���
���          � observa��es do telemarketing.                              ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arc�lor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                          
//ANTIGO RTMKC002
User Function RTMKC004()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local _aSavArea  := GetArea()
Local _aSavSA1   := {}
Local _aBkpRot   := IIF(Type("aRotina")<>"U",aClone(aRotina),{})
Local _cFNamBk   := FunName()
Local _cRotina   := "RTMKC002"
Local cVldAlt    := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc    := ".F." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private _cString := "SZD"

dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())

dbSelectArea(_cString)
(_cString)->(dbSetOrder(1))
If AllTrim(FunName())=="MATA030"
	If MsgYesNo("Filtra o cliente posicionado (" + SA1->A1_NOME + ")?",_cRotina+"_001")
		SetFunName(_cRotina)
		dbClearFilter()
		Set Filter To SZD->ZD_CODCLI == SA1->A1_COD .AND. SZD->ZD_LOJA == SA1->A1_LOJA
		dbFilter()
	EndIf
EndIf

AxCadastro(_cString,"Hist�rico de Cliente - TeleVendas",cVldExc,cVldAlt)

Set Filter To 
dbFilter()
dbClearFilter()

SetFunName(_cFNamBk)
aRotina := aClone(_aBkpRot)
RestArea(_aSavSA1)
RestArea(_aSavArea)

Return()
