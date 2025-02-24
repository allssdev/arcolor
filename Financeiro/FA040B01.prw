#INCLUDE 'Protheus.ch'
#INCLUDE 'Rwmake.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FA040B01 �Autor  � J�lio Soares       � Data �  03/02/2016 ���
�������������������������������������������������������������������������͹��
���Desc.TOTVS� O ponto de entrada FA040B01 sera executado apos confirmar  ���
���          � a exclusao e antes da grava��o dos dados complementares.   ���
���          � Se o retorno for .F., n�o se prosseguir� a dele��o do      ���
���          � t�tulo.                                                    ���
�������������������������������������������������������������������������͹��
���Desc.     � Este ponto de entrada est� sendo utilizado para filtrar os ���
���          � usu�rios que tem autoriza��o para realizar a exclus�o de   ���
���          � t�tulos do contas a receber.                               ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR.                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA040B01()

Local _aSE1 	:= SE1->(GetArea())
Local _cRotina 	:= "FA040B01"
Local _lRet 	:= .T.
Local cTipo		:= SuperGetMV("MV_XTIPFIN",,"RA/PA")

If !__cUserId $ SuperGetMV("MV_USRFINL",,"000000")
	MSGBOX("Somente usu�rios autorizados podem realizar a exclus�o de t�tulos a receber.",_cRotina + "_001","STOP")
	_lRet := .F.
EndIf

If SE1->E1_EMISSAO <> ddatabase .and. ALLTRIM(SE1->E1_TIPO) $ cTipo
	MSGBOX("Data de emiss�o do titulo diferente da data atual do sistema",_cRotina + "_002","STOP")
	_lRet := .F.
Endif

RestArea(_aSE1)

Return(_lRet)
