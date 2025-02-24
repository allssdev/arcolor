#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFINE013 º Autor ³Adriano Leonardo      º Data ³  28/01/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Execblock utilizado para criar automaticamente o cadastro  º±±
±±º          ³ de fornecedor com base no cadastro de vendedor, quando a   º±±
±±º          ³ forma de pagamento das comissões for o contas a pagar.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
user function RFINE013(_cCpo)
	Local   _aSavArea   := GetArea()
	Local   _aSavSA2    := SA2->(GetArea())
	Local   _aSavCC2    := CC2->(GetArea())
	Local   _cRotina    := "RFINE013"
	Local   _cRet       := ""
	Local   _cForn      := CriaVar("A3_FORNECE")
	Local   _cLoja      := CriaVar("A3_LOJA"   )
	Local   _cCodMun    := ""
	Local   _lAchou     := .T.
	Default _cCpo       := "A3_FORNECE"
	_cRet               := CriaVar(_cCpo)
	//Verifica a forma de pagamento das comissões
	If M->A3_GERASE2<>"S".AND.M->A3_GERASE2<>"P"
		return(_cRet)
	EndIf
	//Verifica se o fornecedor já não está cadastrado
	SA2->(dbOrderNickName("A2_CODSA3")) //Filial + Código do vendedor
	If SA2->(FieldPos("A2_CODSA3")) <> 0 .AND. SA2->(MsSeek(xFilial("SA2") + M->A3_COD))
		If AllTrim(_cCpo) == "A3_FORNECE"
			_cRet := M->A3_FORNECE := SA2->A2_COD
		Else
			_cRet := M->A3_LOJA    := SA2->A2_LOJA
		EndIf
	Else
		// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
		//If MsgYesNo("Não foi encontrado nenhum fornecedor vinculado a este vendedor, deseja que o sistema crie o cadastro do fornecedor com base neste cadastro?",_cRotina + "_001")
		If MsgYesNo("Não foi encontrado nenhum fornecedor vinculado a este representante, deseja que o sistema crie o cadastro do fornecedor com base neste cadastro?",_cRotina + "_001")
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022

			//Só gera o cadastro de fornecedor na alteração do cadastro do vendedor, para garantir que os campos obrigatórios estão preenchidos.
			If !ALTERA
				MsgInfo("Operação só permitida na alteração do cadastro, primeiro salve este cadastro e após isso repita a operação!",_cRotina + "_002")
				return(_cRet)
			EndIf
			dbSelectArea("CC2") //Municípios
			CC2->(dbOrderNickName("CC2_ESTMUN"))		//dbSetOrder(3)  //Filial + Estado + Municipio
			If CC2->(MsSeek(xFilial("CC2") + M->A3_EST + M->A3_MUN))
				_cCodMun := CC2->CC2_CODMUN
			EndIf
			_cForn    := GetSx8Num("SA2","A2_COD")
			_cLoja    := StrZero(1,TamSx3("A3_LOJA")[01])
			If AllTrim(_cCpo) == "A3_FORNECE"
				_cRet := _cForn
			Else
				_cRet := _cLoja
			EndIf
			//Foi utilizada a gravação vi reclock por conta de validações de campos obrigatórios ausentes no cadastro de vendedor
			while !RecLock("SA2",.T.);enddo
				SA2->A2_COD    	:= M->A3_FORNECE := _cForn
				SA2->A2_LOJA	:= M->A3_LOJA    := _cLoja
	            SA2->A2_NOME	:= M->A3_NOME
	            SA2->A2_NREDUZ	:= IIF(Empty(M->A3_NREDUZ),M->A3_NOME,M->A3_NREDUZ)
	            SA2->A2_END		:= M->A3_END
	            SA2->A2_EST		:= M->A3_EST
	            SA2->A2_COD_MUN := _cCodMun
	            SA2->A2_MUN		:= M->A3_MUN
	            SA2->A2_BAIRRO	:= M->A3_BAIRRO
	            SA2->A2_CEP		:= M->A3_CEP
	            SA2->A2_TIPO	:= "F"
	            SA2->A2_CGC		:= M->A3_CGC
	            SA2->A2_EMAIL	:= M->A3_EMAIL
	            SA2->A2_CODSA3	:= M->A3_COD
	            SA2->A2_NATUREZ := SuperGetMv("MV_NATCOM",,"COMISSOES")		//202080
			SA2->(MsUnLock())
			If ExistBlock("M020INC")
				ExecBlock("M020INC",.F.,.F.)
			EndIf
			ConfirmSX8()   // Confirma se a numeração do cadastro (SX8)
	        //MsgInfo("Fornecedor cadastrado com sucesso!",_cRotina + "_003")
		EndIf
	EndIf
	RestArea(_aSavCC2)
	RestArea(_aSavSA2)
	RestArea(_aSavArea)
return(_cRet)
