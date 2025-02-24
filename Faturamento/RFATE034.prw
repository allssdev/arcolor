#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ RFATE034 ºAutor  ³ Adriano Leonardo     º  Data  ³ 13/01/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Execblock utilizado no inicializador padrão do campo         º±±
±±º         ³ C5_DESCFIN, para apresentar o desconto financeiro do cliente º±±
±±º         ³ Quando for inicializador padrão do browser passar .T. como   º±±
±±º         ³ parâmetro.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÜßßßß*/

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