#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMKE012  ºAutor  ³Júlio Soares        º Data ³  09/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Execblock criado para atualizar o tipo de operação no       º±±
±±º          ³CallCenter quando o cliente possuir o tipo de divisão igual º±±
±±º          ³a '0' para que o mesmo seja gravado no pedido de vendas.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico Arcolor                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RTMKE012()

Local _aSavArea := GetArea()
Local _cRotina  := " RTMKE012 "
Local _cCli     := M->(UA_CLIENTE)
Local _cLoja    := M->(UA_LOJA)
Local _cTpdiv   := M->(UA_TPDIV)

dbSelectArea("SUA")
_aSavSUA := SUA->(GetArea())
dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())

If !lProspect
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1") + _cCli + _cLoja,.T.,.F.))
		If SA1->(A1_TPDIV) == '0'
			_cTpDiv := "ZZ"
		Else
			_cTpDiv := "01"
		EndIf
	Else
		_cTpDiv := "01"
		MSGBOX("CLIENTE NÃO ENCONTRADO, informe o Adrministrador do sistema ",_cRotina + "_01","ALERT")
	EndIf
Else
	_cTpDiv := "01"
EndIf
RestArea(_aSavSA1 )
RestArea(_aSavSUA )
RestArea(_aSavArea)

Return(_cTpDiv)