#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT107LIB  �Autor  �J�lio Soares        � Data �  10/04/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada criado para informar os usu�rios          ���
���          � autorizados a liberar as solicita��es ao armaz�m           ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Especifico para a emprsa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User function MT107LIB()

// Verificado que a valida��o � por item, verificar a possibilidade de avaliar o par�metro antes se por item ou SA.
Local _lRet    := .T.
Local _cRotina := " MT107LIB "

If __cUserId $ SuperGetMV("MV_USLIBSA",,"000000")
	_lRet := .T.
Else
	MSGBOX('Usu�rio sem permiss�o para realizar a libera��o de requisi��es ao armaz�m. Informe o Administrador do sistema. ',_cRotina,'ALERT')
	_lRet := .F.
EndIf

Return(_lRet)