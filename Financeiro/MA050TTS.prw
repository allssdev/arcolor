#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MA050TTS º Autor ³Adriano Leonardo      º Data ³  04/02/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada após a gravação da transportadora, utili- º±±
±±º          ³ zado para permitir replicar o cadastro de transportadora   º±±
±±º          ³ para o cadastro de fornecedor, uma vez que serão inclusos  º±±
±±º          ³ títulos a pagar para essa trasportadora.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MA050TTS()

Local _aSavArea 	:= GetArea()
Local _aSavSA2  	:= SA2->(GetArea())
Local _aSavSA4  	:= SA4->(GetArea())
Local _cRotina		:= "MA050TTS"
Local _cCodFor  	:= ""
Local _cLojFor		:= ""
Local _lContin		:= .T.

dbSelectArea("SA2")
SA2->(dbOrderNickName("A2_CODSA4")) //Filial + Código da transportadora + loja
//Verifica se o fornecedor já não está cadastrado
If SA2->(MsSeek(xFilial("SA2") + SA4->A4_COD,.T.,.F.))
	_cCodFor := SA4->A4_COD
Else
	//Faz a busca também por CNPJ
	If !Empty(SA4->A4_CGC)
		dbSelectArea("SA2")
		SA2->(dbSetOrder(3)) //Filial + CNPJ
		If SA2->(MsSeek(xFilial("SA2") + SA4->A4_CGC))
	  		_lContin := .F.
		EndIf
	EndIf
	_cMensagem := ""
	If Inclui
		_cMensagem := "Deseja replicar este cadastro para o cadastro de fornecedor?"
	ElseIf Altera
		_cMensagem := "Não foi encontrado nenhum fornecedor vinculado a esta transportadora, deseja que o sistema crie o cadastro do fornecedor com base neste cadastro?"
	EndIf
	If _lContin .And. (Inclui.or. Altera)
		If MsgYesNo(_cMensagem,_cRotina + "_001")
			_cCodFor := GetSx8Num("SA2","A2_COD")
			_cLojFor := "01"
			//Foi utilizada a gravação via reclock por conta de divergências de obrigatoriedade de campos entre os cadastros de transportadora x fornecedor
			If !Empty(SA4->A4_CGC) .And. !Empty(SA4->A4_CEP) .And. !Empty(SA4->A4_EST) .And. !Empty(SA4->A4_CGC) .And. !empty(SA4->A4_NOME)
				while !RecLock("SA2",.T.) ; enddo
					SA2->A2_COD    	:= _cCodFor
					SA2->A2_LOJA	:= _cLojFor
		            SA2->A2_NOME	:= SA4->A4_NOME
		            SA2->A2_NREDUZ	:= IIF(Empty(SA4->A4_NREDUZ),SA4->A4_NOME,SA4->A4_NREDUZ)
		            SA2->A2_END		:= SA4->A4_END
		            SA2->A2_COMPLEM	:= SA4->A4_COMPLEM
		            SA2->A2_EST		:= SA4->A4_EST
		            SA2->A2_COD_MUN := SA4->A4_COD_MUN
		            SA2->A2_MUN		:= SA4->A4_MUN
		            SA2->A2_BAIRRO	:= SA4->A4_BAIRRO
		            SA2->A2_CEP		:= SA4->A4_CEP
		            SA2->A2_TIPO	:= "J"
		            SA2->A2_CGC		:= SA4->A4_CGC
		            SA2->A2_EMAIL	:= SA4->A4_EMAIL
		            SA2->A2_DDI		:= SA4->A4_DDI
		            SA2->A2_DDD		:= SA4->A4_DDD
					SA2->A2_TEL		:= SA4->A4_TEL
					SA2->A2_INSCR	:= SA4->A4_INSEST
					SA2->A2_FAX		:= SA4->A4_FAX
					SA2->A2_CONTATO	:= SA4->A4_CONTATO
		            SA2->A2_CODSA4	:= SA4->A4_COD
		            SA2->A2_NATUREZ := &(SuperGetMv('MV_NATCCFO',,'{"210010","210201003"}'))[01]
		            SA2->A2_CONTA   := &(SuperGetMv('MV_NATCCFO',,'{"210010","210201003"}'))[02]
				SA2->(MsUnlock())
				If ExistBlock("M020INC")
					ExecBlock("M020Inc",.F.,.F.)
				EndIf			
				ConfirmSX8()   // Confirma se a numeração do cadastro (SX8)
		        MsgInfo("Este cadastro foi replicado para o fornecedor: " + SA2->A2_COD + "-" + SA2->A2_LOJA + "!",_cRotina + "_003")
		    Else
		    	MsgAlert("Preencha todos os dados cadastrais!")
		    	return()
		    EndIf 
		EndIf
	EndIf
EndIf

RestArea(_aSavSA4)
RestArea(_aSavSA2)
RestArea(_aSavArea)

Return(_cCodFor)