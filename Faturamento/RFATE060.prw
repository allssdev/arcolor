#INCLUDE 'Protheus.ch'
#INCLUDE 'RwMake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATE060 ºAutor  ³ Júlio Soares       º Data ³  22/12/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock criado para validar a vigência da tabela de preçoº±±
±±º          ³ amarrada ao cliente na seleção do mesmo no pedido de vendasº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - específico empresa ARCOLOR                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
				MSGBOX('A tabela de preços "'+ _cCodTab +'" cadastrada no cliente não pode ser utilizada pois a mesma está fora do prazo de vigência. Selecione outra tabela ativa!',_cRotina+'_001','ALERT')
				_cCodTab := ''
			EndIf
		Else
			MSGBOX('Tabela não encontrada. Informe o Administrador!',_cRotina+'_002','ALERT')
			_cCodTab := ''
		EndIf
		RestArea(_aDA0)
	EndIf
EndIf

RestArea(_aSA1)
RestArea(_aArea)

Return(_cCodTab)