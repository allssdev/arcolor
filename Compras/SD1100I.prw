#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} SD1100I
@description Ponto de entrada utilizado para preencher o campo C7_QUJE (quantidade já entregue) com o valor real e não limitando no pedido de compra como o padrão trata (vide P.E. MT100AG).
@author Adriano L. de Souza / Eduardo M Antunes (ALL System Solutions)
@since 02/09/2014
@version 1.0
@return nil, Sem retorno esperado
@type function
@obs 11/10/2018 - Eduardo M Antunes (ALL System Solutions) - Rotina utiliza para a geração automática de Ordens de Produção por item, para o projeto de industrialização da BCólor pela Arcólor.
@obs 16/09/2024 - Diego Rodrigues (ALL System Solutions) - Ajuste na rotina para adequação devido aos lotes, essa rotina foi desativada em Janeiro de 2024 e reativada em 12/09/2024.
@see https://allss.com.br
/*/
user function SD1100I()
	Local   _aSavArea   := GetArea()
	Local   _aSavSC7    := SC7->(GetArea())
	Local   _aSavSF1    := SF1->(GetArea())
	Local   _aSavSD1    := SD1->(GetArea())
	Local   _aSavSB1    := SB1->(GetArea())
	Local   _cTpPrd     := "SV"
	If SD1->D1_TIPO $ "N" //.AND. SC7->(FieldPos("C7_BKQUJE"))<> 0 .And. .F. //Rotina desativa para prevenir compilação acidental
		If !Empty(SD1->D1_PEDIDO) //Certifico que o item está vinculado a algum pedido de compra
			dbSelectArea("SC7")
			SC7->(dbSetOrder(1)) //Filial + Pedido + Item do pedido
			If SC7->(MsSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC,.T.,.F.))
				//If SC7->C7_BKQUJE > 0 .OR. SC7->C7_QUJE == 0 //Certifico que o campo de backup esteja preenchido ou a quantidade entregue seja zero
					while !RecLock("SC7",.F.) ; enddo
						SC7->C7_QUJE := SC7->C7_BKQUJE + SD1->D1_QUANT
						SC7->C7_BKQUJE := SC7->C7_BKQUJE + SD1->D1_QUANT
					SC7->(MSUNLOCK())
					If SC7->C7_QUJE >= SC7->C7_QUANT
						while !RecLock("SC7",.F.) ; enddo
							SC7->C7_ENCER := "E"
						SC7->(MSUNLOCK())
					EndIf
				//EndIf 
			EndIf
		EndIf
	EndIf
	RestArea(_aSavSB1)
	RestArea(_aSavSF1)
	RestArea(_aSavSD1)
	RestArea(_aSavSC7)
	RestArea(_aSavArea)
	
	If ExistBlock("RPCPA002") .AND. cNumEmp == "0102"		//BCólor
		If SubStr(SD1->D1_COD,1,2) == _cTpPrd .AND. AllTrim(SD1->D1_TP) == _cTpPrd
			U_RPCPA002(SubStr(SD1->D1_COD,3), SD1->D1_QUANT)
		EndIf
	EndIf
	RestArea(_aSavSB1)
	RestArea(_aSavSF1)
	RestArea(_aSavSD1)
	RestArea(_aSavSC7)
	RestArea(_aSavArea)
return
