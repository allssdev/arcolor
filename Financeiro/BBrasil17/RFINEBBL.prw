#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINEBBL  �Autor  �Anderson C. P. Coelho � Data �  20/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock para o retorno do desconto / dia para o CNAB     ���
���          �e boleto a receber do Banco do Brasil.                      ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINEBBL(_cTipo)

Local _aSavArea  := GetArea()
Local _cRet      := ""

Default _cTipo   := ""		//2=Endere�o com n�mero;E=Endere�o;N=N�mero;C=Complemento;B=Bairro;M=Munic�pio;U=Estado;P=CEP

If _cTipo == "2"		//Endere�o com n�mero
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := AllTrim(SA1->A1_ENDCOB )
	Else
		_cRet := AllTrim(SA1->A1_END    )
	EndIf
ElseIf _cTipo == "E"		//Endere�o
	If !Empty(SA1->A1_CEPC) .AND. !Empty(SA1->A1_ESTC) .AND. !Empty(SA1->A1_ENDCOB) .AND. !Empty(SA1->A1_BAIRROC)
		_cRet := FisGetEnd(AllTrim(SA1->A1_ENDCOB))[01]
	Else
		_cRet := FisGetEnd(AllTrim(SA1->A1_END   ))[01]
	EndIf
ElseIf _cTipo == "N"	//N�mero
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
ElseIf _cTipo == "M"	//Munic�pio
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