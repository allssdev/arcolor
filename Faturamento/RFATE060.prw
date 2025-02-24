#INCLUDE 'Protheus.ch'
#INCLUDE 'RwMake.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFATE060 �Autor  � J�lio Soares       � Data �  22/12/2015 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock criado para validar a vig�ncia da tabela de pre�o���
���          � amarrada ao cliente na sele��o do mesmo no pedido de vendas���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE060()

Local _aArea	:= GetArea()
Local _cRotina	:= 'RFATE060'
Local _cCodTab	:= ''

dbSelectArea("SA1")
_aSA1 := SA1->(GetArea())
SA1->(dbSetOrder(1))

If !AllTrim(M->C5_TIPO) $ "D/B"
	If SA1->(MsSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.T.,.F.))
		_cCodTab := SA1->A1_TABELA
		dbSelectArea("DA0")
		DA0->(dbSetOrder(1))
		_aDA0 := DA0->(GetArea())
		If DA0->(MsSeek(xFilial("DA0")+_cCodTab,.T.,.F.))
			If !(dDataBase <= DA0->DA0_DATATE .AND. Time() <= DA0->(DA0_HORATE))
				MSGBOX('A tabela de pre�os "'+ _cCodTab +'" cadastrada no cliente n�o pode ser utilizada pois a mesma est� fora do prazo de vig�ncia. Selecione outra tabela ativa!',_cRotina+'_001','ALERT')
				_cCodTab := ''
			EndIf
		Else
			MSGBOX('Tabela n�o encontrada. Informe o Administrador!',_cRotina+'_002','ALERT')
			_cCodTab := ''
		EndIf
		RestArea(_aDA0)
	EndIf
EndIf

RestArea(_aSA1)
RestArea(_aArea)

Return(_cCodTab)