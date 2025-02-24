#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFINE013 � Autor �Adriano Leonardo      � Data �  28/01/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Execblock utilizado para criar automaticamente o cadastro  ���
���          � de fornecedor com base no cadastro de vendedor, quando a   ���
���          � forma de pagamento das comiss�es for o contas a pagar.     ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	//Verifica a forma de pagamento das comiss�es
	If M->A3_GERASE2<>"S".AND.M->A3_GERASE2<>"P"
		return(_cRet)
	EndIf
	//Verifica se o fornecedor j� n�o est� cadastrado
	SA2->(dbOrderNickName("A2_CODSA3")) //Filial + C�digo do vendedor
	If SA2->(FieldPos("A2_CODSA3")) <> 0 .AND. SA2->(MsSeek(xFilial("SA2") + M->A3_COD))
		If AllTrim(_cCpo) == "A3_FORNECE"
			_cRet := M->A3_FORNECE := SA2->A2_COD
		Else
			_cRet := M->A3_LOJA    := SA2->A2_LOJA
		EndIf
	Else
		// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
		//If MsgYesNo("N�o foi encontrado nenhum fornecedor vinculado a este vendedor, deseja que o sistema crie o cadastro do fornecedor com base neste cadastro?",_cRotina + "_001")
		If MsgYesNo("N�o foi encontrado nenhum fornecedor vinculado a este representante, deseja que o sistema crie o cadastro do fornecedor com base neste cadastro?",_cRotina + "_001")
		// Fim - Fernando Bombardi - ALLSS - 02/03/2022

			//S� gera o cadastro de fornecedor na altera��o do cadastro do vendedor, para garantir que os campos obrigat�rios est�o preenchidos.
			If !ALTERA
				MsgInfo("Opera��o s� permitida na altera��o do cadastro, primeiro salve este cadastro e ap�s isso repita a opera��o!",_cRotina + "_002")
				return(_cRet)
			EndIf
			dbSelectArea("CC2") //Munic�pios
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
			//Foi utilizada a grava��o vi reclock por conta de valida��es de campos obrigat�rios ausentes no cadastro de vendedor
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
			ConfirmSX8()   // Confirma se a numera��o do cadastro (SX8)
	        //MsgInfo("Fornecedor cadastrado com sucesso!",_cRotina + "_003")
		EndIf
	EndIf
	RestArea(_aSavCC2)
	RestArea(_aSavSA2)
	RestArea(_aSavArea)
return(_cRet)
