#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFINE014 � Autor �Adriano Leonardo      � Data �  04/02/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada ap�s a grava��o da transportadora, utili- ���
���          � zado para permitir replicar o cadastro de transportadora   ���
���          � para o cadastro de fornecedor, uma vez que ser�o inclusos  ���
���          � t�tulos a pagar para essa trasportadora.                   ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RFINE014()

Local _aSavArea 	:= GetArea()
Local _aSavSA2  	:= SA2->(GetArea())
Local _aSavSA4  	:= SA4->(GetArea())
Local _cRotina		:= "RFINE014"
Local _cCodFor  	:= ""
Local _cLojFor		:= ""
Local _nCont		:= 0
Private _lM020INC :=  ExistBlock("M020INC")

_cMensagem := "Deseja replicar todos os cadastros de transportadoras ativas para o cadastro de fornecedores?"

If !MsgYesNo(_cMensagem,_cRotina + "_001")
    Return()
EndIf

dbSelectArea("SA4")
SA4->(dbSetOrder(0))
SA4->(dbGoTop())
While !SA4->(EOF())
	If SA4->A4_MSBLQL<>"1"
		dbSelectArea("SA2")
		dbOrderNickName("A2_CODSA4") //Filial + C�digo da transportadora + loja
		//Verifica se o fornecedor j� n�o est� cadastrado
		If !SA2->(MsSeek(xFilial("SA2") + SA4->A4_COD))
			_cCodFor := GetSx8Num("SA2","A2_COD")
			_cLojFor := "01"
			//Faz a busca tamb�m por CNPJ
			If !Empty(SA4->A4_CGC)
				dbSelectArea("SA2")
				SA2->(dbSetOrder(3)) //Filial + CNPJ
				If SA2->(MsSeek(xFilial("SA2") + SA4->A4_CGC,.T.,.F.))
					dbSelectArea("SA4")
					SA4->(dbSetOrder(0))
					SA4->(dbSkip())
					Loop
				EndIf
			EndIf
			//Foi utilizada a grava��o via reclock por conta de diverg�ncias de obrigatoriedade de campos entre os cadastros de transportadora x fornecedor
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
			SA2->(MsUnlock())
			/* FB - RELEASE 12.1.23
			If ExistBlock("M020INC")
				ExecBlock("M020Inc",.F.,.F.)
			EndIf
			*/
			If _lM020INC
				ExecBlock("M020Inc",.F.,.F.)
			EndIf			
			ConfirmSX8()   // Confirma se a numera��o do cadastro (SX8)
			_nCont++
		EndIf
	EndIf
	dbSelectArea("SA4")
	SA4->(dbSetOrder(0))
	SA4->(dbSkip())
EndDo
If _nCont == 0
	_cMens := "N�o foi gerado nenhum cadastro de fornecedor, todas as transportadoras ativas j� est�o vinculadas a um fornecedor!"
ElseIf _nCont == 1
	_cMens := "Foi gerado apenas 1 cadastro de fornecedor!"
ElseIf _nCont>1
	_cMens := "Foram gerados " + AllTrim(Str(_nCont)) + " cadastros de fornecedor!"
EndIf

MsgInfo(_cMens,_cRotina + "_001")

RestArea(_aSavSA4)
RestArea(_aSavSA2)
RestArea(_aSavArea)

Return()