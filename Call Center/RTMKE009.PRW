#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKE009  �Autor  �Anderson C. P. Coelho � Data �  22/03/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock utilizado para validar se um item j� foi         ���
���          �informado no atendimento ou n�o.                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RTMKE009()

Local _aSavArea := GetArea()
Local _cRotina  := "RTMKE009"
Local _nPItem   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_ITEM"   })
Local _nPProd   := aScan(aHeader,{|x|AllTrim(x[02])=="UB_PRODUTO"})
Local _nPTes    := aScan(aHeader,{|x|AllTrim(x[02])=="UB_TES"    })
Local _cProd    := IIF(__ReadVar=="M->UB_PRODUTO",M->UB_PRODUTO,aCols[n][_nPProd])
Local _nLItem   := aScan(aCols,{|x| x[_nPProd] == _cProd .AND. x[_nPItem] <> aCols[n][_nPItem] .AND. !x[Len(aHeader)+1]})	//Os itens deletados est�o sendo considerados nesta valida��o! Se esta valida��o foi ativada, dever� ser analisado o caso de desdele��o manual do item.
Local _nLTes    := aScan(aCols,{|x| x[_nPProd] == _cProd .AND. x[_nPTes ] <> aCols[n][_nPTes ] .AND. !x[Len(aHeader)+1]})
Local _lRet     := aCols[n][Len(aHeader)+1] .OR. (_nLItem == 0 .And. _nLTes==0)

If !_lRet
	MsgAlert("Aten��o! O produto " + AllTrim(_cProd) + " selecionado j� foi informado neste atendimento no item '" + aCols[_nLItem][_nPItem] + "'. Opera��o n�o permitida!",_cRotina+"_001")
EndIf

RestArea(_aSavArea)

Return(_lRet)