#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCOME001  �Autor  �Alessandro Villar     � Data �  09/02/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina criada para um gatilho para o preenchimento do Centro���
���           de Custo nas Solicita��es de Compras de acordo com o Centro ���
���           de Custo do usu�rio logado no sistema, conforme o cadastro  ���
���           de funcion�rios.                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
                                                                                     
User Function RCOME001() 

Local _aSavArea := GetArea()
Local _aSavSRA  := SRA->(GetArea())
Local _aUser := {}
Local _cRet  := ""

PswOrder(1)			//Ordem: por c�digo de usu�rio
If PswSeek(__cUserId, .T.)	//Retorna o c�digo do usu�rio logado.
	_aUser := PswRet()      //Retorna informa��es do usu�rio.
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))  //Ordem por matr�cula de funcion�rio.
	If SRA->(MsSeek(xFilial("SRA") + SubStr(_aUser[01][22],5,TamSx3("RA_CC")[01]),.T.,.F.))	//[1][22] C Empresa, filial e matricula.
		_cRet := SRA->RA_CC
	EndIf
EndIf

RestArea(_aSavSRA)
RestArea(_aSavArea)

Return(_cRet)