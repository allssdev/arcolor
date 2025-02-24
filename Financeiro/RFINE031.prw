#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINE031  � Autor � Arthur Silva       � Data �  03/10/16   ���
�������������������������������������������������������������������������͹��
���Descricao � ExecBlock executado na inclus�o de produto nas regras de   ���
���          �comiss�es, onde n�o permitir� duplicidade de produtos para  ���
���			  o mesmo c�digo de representante.                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - ALL SYSTEM SOLUTIONS                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFINE031()

Local _lRet    := .T.
Local _cRotina := "RFINE031"
Local _aSavArea := GetArea()
Local _aSavSZ6	:= SZ6->(GetArea())

	
dbSelectArea("SZ6")
SZ6->(dbSetOrder(2))
If SZ6->(MsSeek(xFilial("SZ6")+Z6_REPRES+M->Z6_PRODUT,.T.,.F.))
	MsgInfo("Produto " + AllTrim(M->Z6_PRODUT) + " j� cadastrado para o Representante " + AllTrim (Z6_REPRES)+ ",Favor verificar o cadastro que j� foi realizado!",_cRotina+"_001")
	_lRet := .F.
EndIf 

RestArea(_aSavSZ6)
RestArea(_aSavArea)
  
Return (_lRet)