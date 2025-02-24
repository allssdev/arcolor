#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA030TOK �Autor  �Adriano Leonardo    � Data �  12/08/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada chamado no OK do cadastro de clientes,    ���
���          � utilizado para tratar a validade do Sintegra.              ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MA030TOK()
	
	Local _aSavArea  := GetArea()
	Local _lRet		 := .T. //Para este caso o retorno sempre ser� verdadeiro
	Local _dValidade := dDataBase
	Local _nDiasEsta := 30  //Validade do Sintegra dentro do estado
	Local _nDiasFora := 90  //Validade do Sintegra fora do estado
	Local _cAliasSX3 := "SX3_"+GetNextAlias()
	
	OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
	dbSelectArea(_cAliasSX3)
	(_cAliasSX3)->(dbSetOrder(2))
	
	If dbSeek("A1_MASHUP")
		If !Empty(M->A1_MASHUP)
			If M->A1_EST == GETMV("MV_ESTINT")
				_dValidade := DaySum( _dValidade, _nDiasEsta)
			Else
				_dValidade := DaySum( _dValidade, _nDiasFora)
			EndIf
		EndIf
	EndIf
	
	RestArea(_aSavArea)
	
Return(_lRet)