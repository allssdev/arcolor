#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA120G2  ºAutor  ³Adriano Leonardo    º Data ³ 16/04/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ Ponto de entrada utilizado para gravar o conteudo dos campos   º±±
±±º      ³ customizados no rodapé do pedido de compras.                   º±±
±±º      ³ Esse ponto de entrada é utilizado juntamente com os PEs:       º±±  
±±º      ³ MT120TEL                                                       º±±
±±º      ³ MT120FOL                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±                  
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor 			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA120G2()

Local _aSavArea := GetArea()
Local _aSavSC7  := SC7->(GetArea()) 
Local _cAlias	:= "SC7"

dbSelectArea(_cAlias)
//If INCLUI .OR. ALTERA
	RecLock("SC7",.F.)
		If FieldPos("C7_OBSERVE")<>0 .AND. Type("_cAux"    )<>"U"               //Confirmo a existência do campo
			(_cAlias)->C7_OBSERVE := _cAux        //Variável private declarada no ponto de entrada MT120TEL
		EndIf
		If FieldPos("C7_DEPART" )<>0 .AND. Type("_cDepart" )<>"U"               //Confirmo a existência do campo
			(_cAlias)->C7_DEPART  := _cDepart      //Variável private declarada no ponto de entrada MT120FOL
		EndIf
		If FieldPos("C7_ESPECIF")<>0 .AND. Type("_cEspecif")<>"U"               //Confirmo a existência do campo
			(_cAlias)->C7_ESPECIF := _cEspecif      //Variável private declarada no ponto de entrada MT120FOL
		EndIf
		If FieldPos("C7_USERINC")<>0 .AND. INCLUI //Confirmo a existência do campo e se a operação é inclusão
			(_cAlias)->C7_USERINC := __cUserId    //Variável private declarada no ponto de entrada MT120FOL
		EndIf
	(_cAlias)->(MsUnLock())
//EndIf

RestArea(_aSavSC7)
RestArea(_aSavArea)

Return()