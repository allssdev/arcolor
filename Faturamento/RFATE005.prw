#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE005   ºAutor  ³Júlio Soares       º Data ³  29/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ExecBlock criado para atualizar o campo código da região de º±±
±±º          ³vendas a partir do cadastro de regiões.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function RFATE005()

Local _aSavArea	:= GetArea()
Local _cRet 	:= ""
Local _cRotina  := "RFATE005"
Local _cCEPcli	:= M->A3_CEP
Local _nContad  := 0

If FunName() <> "RCFGI002"
	dbselectArea("SZ0")
	SZ0->(dbSetOrder(3))
//	Set SoftSeek ON
	SZ0->(MsSeek(xFilial("SZ0")+_cCEPcli,.F.,.F.))
//	Set SoftSeek OFF
	While !SZ0->(EOF()) .AND.SZ0->Z0_FILIAL == xFilial("SZ0") //.AND. _cBlqcep == "2"
	  	If	_cCEPcli >= SZ0->Z0_CEPINI .and. _cCEPcli <= SZ0->Z0_CEPFIN
  			_cRet := SZ0->Z0_COD
			_nContad++
			Exit
		EndIf
		dbselectArea("SZ0")
		SZ0->(dbSetOrder(3))
		SZ0->(dbSkip())
	EndDo
	If _nContad == 0
		MsgBox("O CEP informado não possue região cadastrada, verifique o cadastro de regiões",_cRotina + " - " +"001", "ALERT")
	ElseIf _nContad > 1
		MsgBox("Foram encontrados mais do que uma região cadastrada para o mesmo CEP informado. Por favor, verifique!",_cRotina + " - " +"001", "ALERT")
	EndIf
EndIf

RestArea(_aSavArea)

Return(_cRet)