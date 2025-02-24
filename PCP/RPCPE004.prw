#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RPCPE004  �Autor  �Alex Matos        � Data �  18/12/14     ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina criada para a cria��o autom�tica de armazem  baseados���
���          �no preenchimento dos campos PRODUTO, ARMAZEM  no apontamento���
���          �da Ordem de Producao										  ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico Arcolor                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RPCPE004()

Private _cProd := ""
Private _cLocal:= ""
Private _lRet  := .F.


_cProd := M->D3_COD
_cLocal := M->D3_LOCAL

If !Empty(_cProd) .AND. !Empty(_cLocal) 
	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek(xFilial("SB2")+_cProd+_cLocal)
		_lRet := .T.
	Else
	     _lRet:= ExistCpo("NNR") .AND. MsgYesNo("Armaz�m n�o existe, deseja criar??")
	     If _lRet = .T.
	     	CRIASB2(_cProd,_cLocal)//produto, local
	     Else
	     	MsgInfo("Operac�o cancelada pelo usu�rio - Armaz�m Inv�lido")
	     EndIf
	EndIf
Else
	MsgAlert("Produto ou Armaz�m n�o informado!!!")
    _lRet := .F.
EndIf

RETURN(_lRet)