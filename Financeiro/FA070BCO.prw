#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA070BCO 	�Autor  �Thiago S. de Almeida �Data �  21/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada executado na confirma��o da tela de baixa ���
���			 � dos titulos a receber.                         			  ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 -  Espec�fico para a empresa Arcolor.          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/   

User Function FA070BCO()

Local _aSavArea := GetArea()
Local _cRotina  := "FA070BCO"
Local _lRet     := .T.
      
If Funname() == "FINA070"
	dbSelectArea("SZ3")
	dbSetOrder(1)
	If MsSeek(xFilial("SZ3") + __cUserId,.T.,.F.)
		If __cUserId $ SZ3->Z3_USERREC 
			IF cBancolt <> SZ3->Z3_CODBCRE .AND. cAgencialt <> SZ3->Z3_AGENREC .AND. cContalt <> SZ3->Z3_CONTREC
  				MsgAlert("Banco, Agencia e Conta Invalido!",_cRotina+"_001")
				_lRet := .F.
   			EndIf
   		EndIf
	EndIf
EndIf

RestArea(_aSavArea)

Return(_lRet)