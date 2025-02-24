#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ RFATE037 ºAutor  ³ Adriano L. de Souza º Data ³  07/02/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Execblock utilizado na validação do campo A1_VEND, para repli_º±±
±±ºDesc.   ³ car o cadastro de vendedor como grupo de venda (clientes).    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11  ³ Uso específico Arcolor                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RFATE037()

Local _aSavArea := GetArea()
Local _aSavSA1  := SA1->(GetArea()) //Clientes
Local _aSavACY  := ACY->(GetArea()) //Grupo de clientes
Local _aSavSA3	:= SA3->(GetArea())	//Vendedores
Local _cRotina	:= "RFATE037"
Local _lRet 	:= .T.

//Avalio se o campo de vendedor está preenchido
If Empty(M->A1_VEND)

	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	MsgAlert("O código do representante deve ser informado!"+_cRotina+"_001")
	//MsgAlert("O código do vendedor deve ser informado!"+_cRotina+"_001")
	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022

	_lRet := .F.
Else
	dbSelectArea("SA3")
	dbSetOrder(1)
	If SA3->(dbSeek(xFilial("SA3")+M->A1_VEND))
		
		dbSelectArea("ACY")
		dbSetOrder(1)
		If !ACY->(dbSeek(xFilial("ACY")+M->A1_VEND))
			while !RecLock("ACY",.T.)  ; enddo		//Inclusão
				ACY->ACY_GRPVEN := SA3->A3_COD
				ACY->ACY_DESCRI	:= SA3->A3_NOME
			ACY->(MsUnlock())
		EndIf
	EndIf
EndIf

RestArea(_aSavSA3)
RestArea(_aSavACY)
RestArea(_aSavSA1)
RestArea(_aSavArea)

Return(_lRet)
