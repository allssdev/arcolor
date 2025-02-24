#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA120G2  �Autor  �Adriano Leonardo    � Data � 16/04/13    ���
�������������������������������������������������������������������������͹��
���Desc. � Ponto de entrada utilizado para gravar o conteudo dos campos   ���
���      � customizados no rodap� do pedido de compras.                   ���
���      � Esse ponto de entrada � utilizado juntamente com os PEs:       ���  
���      � MT120TEL                                                       ���
���      � MT120FOL                                                       ���
�������������������������������������������������������������������������͹��                  
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor 			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTA120G2()

Local _aSavArea := GetArea()
Local _aSavSC7  := SC7->(GetArea()) 
Local _cAlias	:= "SC7"

dbSelectArea(_cAlias)
//If INCLUI .OR. ALTERA
	RecLock("SC7",.F.)
		If FieldPos("C7_OBSERVE")<>0 .AND. Type("_cAux"    )<>"U"               //Confirmo a exist�ncia do campo
			(_cAlias)->C7_OBSERVE := _cAux        //Vari�vel private declarada no ponto de entrada MT120TEL
		EndIf
		If FieldPos("C7_DEPART" )<>0 .AND. Type("_cDepart" )<>"U"               //Confirmo a exist�ncia do campo
			(_cAlias)->C7_DEPART  := _cDepart      //Vari�vel private declarada no ponto de entrada MT120FOL
		EndIf
		If FieldPos("C7_ESPECIF")<>0 .AND. Type("_cEspecif")<>"U"               //Confirmo a exist�ncia do campo
			(_cAlias)->C7_ESPECIF := _cEspecif      //Vari�vel private declarada no ponto de entrada MT120FOL
		EndIf
		If FieldPos("C7_USERINC")<>0 .AND. INCLUI //Confirmo a exist�ncia do campo e se a opera��o � inclus�o
			(_cAlias)->C7_USERINC := __cUserId    //Vari�vel private declarada no ponto de entrada MT120FOL
		EndIf
	(_cAlias)->(MsUnLock())
//EndIf

RestArea(_aSavSC7)
RestArea(_aSavArea)

Return()