#INCLUDE "RWMAKE.CH"                                                               
#INCLUDE "PROTHEUS.CH"                                                                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRTMKC001  บAutor  ณAdriano Leonardo    บ Data ณ  01/04/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de hist๓rico de clientes  (tabela SZC) utilizada para บฑฑ
ฑฑบ          ณ cadastro de observa็๕es de cobran็a.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11 - Especํfico para a empresa Arc๓lor.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                          

User Function RTMKC001()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

AxCadastro(_cString,"Hist๓rico de Clientes - Cobran็a",cVldExc,cVldAlt)

Set Filter To 
dbFilter()
dbClearFilter()

SetFunName(_cFNamBk)
aRotina := aClone(_aBkpRot)
RestArea(_aSavSA1)
RestArea(_aSavArea)

Return()