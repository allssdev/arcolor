#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFINEBBL  ºAutor  ³Anderson C. P. Coelho º Data ³  20/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock para o retorno do desconto / dia para o CNAB     º±±
±±º          ³e boleto a receber do Banco do Brasil.                      º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFINEBBL(_cTipo)

Local _aSavArea  := GetArea()
Local _cRet      := ""

Default _cTipo   := ""		//2=Endereço com número;E=Endereço;N=Número;C=Complemento;B=Bairro;M=Município;U=Estado;P=CEP

If _cTipo == "2"		//Endereço com número
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := AllTrim(SA1->A1_ENDCOB )
	Else
		_cRet := AllTrim(SA1->A1_END    )
	EndIf
ElseIf _cTipo == "E"		//Endereço
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := FisGetEnd(AllTrim(SA1->A1_ENDCOB))[01]
	Else
		_cRet := FisGetEnd(AllTrim(SA1->A1_END   ))[01]
	EndIf
ElseIf _cTipo == "N"	//Número
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := FisGetEnd(AllTrim(SA1->A1_ENDCOB))[03]
	Else
		_cRet := FisGetEnd(AllTrim(SA1->A1_END   ))[03]
	EndIf
ElseIf _cTipo == "C"	//Complemento
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := FisGetEnd(AllTrim(SA1->A1_ENDCOB))[04]
		If !Empty(_cRet)
			_cRet += " - "
		EndIf
		_cRet += AllTrim(SA1->A1_COMPLC )
	Else
		_cRet := FisGetEnd(AllTrim(SA1->A1_END   ))[04]
		If !Empty(_cRet)
			_cRet += " - "
		EndIf
		_cRet += AllTrim(SA1->A1_COMPLEM)
	EndIf
ElseIf _cTipo == "B"	//Bairro
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := AllTrim(SA1->A1_BAIRROC)
	Else
		_cRet := AllTrim(SA1->A1_BAIRRO )
	EndIf
ElseIf _cTipo == "M"	//Município
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := AllTrim(SA1->A1_MUNC   )
	Else
		_cRet := AllTrim(SA1->A1_MUN    )
	EndIf
ElseIf _cTipo == "U"	//Estado
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := AllTrim(SA1->A1_ESTC   )
	Else
		_cRet := AllTrim(SA1->A1_EST    )
	EndIf
ElseIf _cTipo == "P"	//CEP
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := AllTrim(SA1->A1_CEPC   )
	Else
		_cRet := AllTrim(SA1->A1_CEP    )
	EndIf
EndIf

RestArea(_aSavArea)

Return(_cRet)