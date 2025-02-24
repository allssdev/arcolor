#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOME004  ºAutor  ³Júlio Soares        º Data ³  09/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Execblock criado para utilização em gatilho onde atualiza   º±±
±±º          ³o preço de compra na segunda unidade de medida para realiza-º±±
±±º          ³ção de documentos de entrada. D1_VUNIT  => D1_PRECO2        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico - ARCOLOR                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCOME005()

Local _aSavArea := GetArea()
Local _aSavSB1  := SB1->(GetArea())
Local _aSavSD1  := SD1->(GetArea())
Local _cRotina  := " RCOME005 "

Local cProd     := aScan(aHeader,{|x|AllTrim(Upper(x[02]))=="D1_COD"})
Local nPreco    := aScan(aHeader,{|x|AllTrim(Upper(x[02]))=="D1_VUNIT"})
Local nPreco2   := aScan(aHeader,{|x|AllTrim(Upper(x[02]))=="D1_PRECO2"})

Local _cProd    := (aCols[n][cProd])
Local _nPreco   := (aCols[n][nPreco])
Local _nPreco2  := (aCols[n][nPreco2])

IF Empty(_cProd)

	_nTotal := 0

Else

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+_cProd,.T.,.F.))
		If !Empty (SB1->B1_SEGUM)
			If !Empty (SB1->(B1_TIPCONV))
				If (SB1->(B1_CONV)) > 0
					If SB1->(B1_TIPCONV) == 'M' // MULTIPLICADOR
						_nTotal := (_nPreco / SB1->B1_CONV)
					ElseIf SB1->(B1_TIPCONV) == 'D' // DIVISOR
						_nTotal := (_nPreco * SB1->B1_CONV)
					EndIf
				Else
					MSGBOX("O produto " + (Alltrim(_cProd)) + " não tem o campo ''FATOR DE CONVERÇÃO'' com valor válido, VERIFIQUE ",(_cRotina) + "_01","ALERT")
					_nTotal := 0
				EndIf
			Else
				MSGBOX("O produto " + (Alltrim(_cProd)) + " não tem o campo ''TIPO DE CONVERSÃO'' de unidades preenchido, VERIFIQUE ",(_cRotina) + "_02","ALERT")
				_nTotal := 0
			EndIf
		Else
			//MSGBOX("O produto " + (Alltrim(_cProd)) + " não tem o campo ''SEGUNDA UNIDADE'' de medida cadastrado, VERIFIQUE ",(_cRotina) + "_03","ALERT") //Linha comentada por Adriano Leonardo em 11/09/2013 - a pedido do Sr. Marco
			_nTotal := 0
		EndIf
	Else
		MSGBOX("Produto " + (Alltrim(_cProd)) + " não encontrado, informe o administrador do sistema ",(_cRotina) + "_04","STOP")
		_nTotal := 0
	EndIf
EndIf

RestArea(_aSavSB1)
RestArea(_aSavSD1)
RestArea(_aSavArea)

Return(_nTotal)
