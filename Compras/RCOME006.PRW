#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCOME006  �Autor  �J�lio Soares        � Data �  09/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Execblock criado para utiliza��o em gatilho onde atualiza   ���
���          �o pre�o de compra na segunda unidade de medida para realiza-���
���          ���o de documentos de entrada. D1_PRECO2  => D1_VUNIT        ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico - ARCOLOR                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RCOME006()

Local _aSavArea := GetArea()
Local _aSavSB1  := SB1->(GetArea())
Local _aSavSD1  := SD1->(GetArea())
Local _cRotina  := " RCOME006 "

Local cProd     := aScan(aHeader,{|x|AllTrim(Upper(x[02]))=="D1_COD"})
Local nPreco    := aScan(aHeader,{|x|AllTrim(Upper(x[02]))=="D1_VUNIT"})
Local nPreco2   := aScan(aHeader,{|x|AllTrim(Upper(x[02]))=="D1_PRECO2"})

Local _cProd    := (aCols[n][cProd])
Local _nPreco   := (aCols[n][nPreco])
Local _nPreco2  := (aCols[n][nPreco2])


if FUNNAME()<>"PRENOTACTE"
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+_cProd,.T.,.F.))
		If !Empty (SB1->B1_SEGUM)
			If !Empty (SB1->(B1_TIPCONV))
				If (SB1->(B1_CONV)) > 0
					If SB1->(B1_TIPCONV) == 'M' // MULTIPLICADOR
						_nTotal := (_nPreco2 * SB1->B1_CONV)
					ElseIf SB1->(B1_TIPCONV) == 'D' // DIVISOR
						_nTotal := (_nPreco2 / SB1->B1_CONV)
					EndIf
				Else
					MSGBOX("O produto " + (Alltrim(_cProd)) + " n�o tem o campo ''FATOR DE CONVER��O'' com valor v�lido, VERIFIQUE ",(_cRotina) + "_01","ALERT")
					_nTotal := 0
				EndIf
			Else
				MSGBOX("O produto " + (Alltrim(_cProd)) + " n�o tem o campo ''TIPO DE CONVERS�O'' de unidades preenchido, VERIFIQUE ",(_cRotina) + "_02","ALERT")
				_nTotal := 0
			EndIf
		Else
			//MSGBOX("O produto " + (Alltrim(_cProd)) + " n�o tem o campo ''SEGUNDA UNIDADE'' de medida cadastrado, VERIFIQUE ",(_cRotina) + "_03","ALERT") //Linha comentada por Adriano Leonardo em 11/09/2013 - a pedido do Sr. Marco
			_nTotal := 0
		EndIf
	Else
		MSGBOX("Produto " + (Alltrim(_cProd)) + " n�o encontrado, informe o administrador do sistema ",(_cRotina) + "_04","STOP")
		_nTotal := 0
	EndIf
Endif
/*If ExistTrigger(D1_PRECO2)
	RunTrigger(1)
	EvalTrigger()
EndIf
*/


RestArea(_aSavSB1)
RestArea(_aSavSD1)
RestArea(_aSavArea)

Return(_nTotal)
