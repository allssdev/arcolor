#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOME007  ºAutor  ³Júlio Soares        º Data ³  09/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Execblock criado para utilização em gatilho onde atualiza   º±±
±±º          ³o preço de compra na segunda unidade de medida para realiza-º±±
±±º          ³ção de inclusão de pedidos de compras.                      º±±
±±º          ³C7_PRECO2 => C7_PRECO                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Especifico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCOME007()

Local _aSavArea := GetArea()
Local _aSavSB1  := SB1->(GetArea())
Local _aSavSD1  := SC7->(GetArea())
Local _cRotina  := "RCOME007"
Local _cValid   := ""
Local cProd     := aScan(aHeader,{|x| AllTrim(Upper(x[02]))=="C7_PRODUTO"})
Local nPreco    := aScan(aHeader,{|x| AllTrim(Upper(x[02]))=="C7_PRECO"  })
Local nPreco2   := aScan(aHeader,{|x| AllTrim(Upper(x[02]))=="C7_PRECO2" })
Local _cProd    := aCols[n][cProd  ]
Local _nPreco   := aCols[n][nPreco ]
Local _nPreco2  := aCols[n][nPreco2]
Local _nTotal   := 0
Local _cAliasSX3    := GetNextAlias()

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+_cProd,.T.,.F.))
	If !Empty(SB1->B1_SEGUM)
		If !Empty(SB1->B1_TIPCONV)
			If SB1->B1_CONV > 0
				If SB1->B1_TIPCONV == 'M' // MULTIPLICADOR
					_nTotal := (_nPreco2 * SB1->B1_CONV)
				ElseIf SB1->B1_TIPCONV == 'D' // DIVISOR
					_nTotal := (_nPreco2 / SB1->B1_CONV)
				EndIf
			Else
				MSGBOX("O produto " + Alltrim(_cProd) + " não tem o campo ''FATOR DE CONVERÇÃO'' com valor válido, VERIFIQUE!",_cRotina+"_001","ALERT")
				_nTotal := 0
			EndIf
		Else
			MSGBOX("O produto " + Alltrim(_cProd) + " não tem o campo ''TIPO DE CONVERSÃO'' de unidades preenchido, VERIFIQUE!",_cRotina+"_002","ALERT")
			_nTotal := 0
		EndIf
	Else
		//MSGBOX("O produto " + Alltrim(_cProd) + " não tem o campo ''SEGUNDA UNIDADE'' de medida cadastrado, VERIFIQUE ",_cRotina+"_003","ALERT") //Linha comentada por Adriano Leonardo em 11/09/2013 - a pedido do Sr. Marco
		_nTotal := 0
	EndIf
Else
	MSGBOX("Produto " + Alltrim(_cProd) + " não encontrado, informe o administrador do sistema!",_cRotina+"_004","STOP")
	_nTotal := 0
EndIf
M->C7_PRECO := aCols[n][nPreco ] := _nTotal
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(2))
If (_cAliasSX3)->(MsSeek("C7_PRECO",.T.,.F.))
	_cValid := AllTrim((_cAliasSX3)->X3_VALID + IIF(!Empty((_cAliasSX3)->X3_VALID).AND.!Empty((_cAliasSX3)->X3_VLDUSER),".AND."," ") + (_cAliasSX3)->X3_VLDUSER)
	If !Empty(_cValid)
		&_cValid
	EndIf
EndIf


If ExistTrigger("C7_PRECO")
	RunTrigger(2,n)
	EvalTrigger()
EndIf

RestArea(_aSavSB1)
RestArea(_aSavSD1)
RestArea(_aSavArea)

Return(_nTotal)