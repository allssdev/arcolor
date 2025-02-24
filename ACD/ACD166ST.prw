#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#Include 'TOTVS.ch'
#Include 'topconn.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACD166ST  �Autor  �Arthur Silva� 			 Data  �  21/08/17���
�������������������������������������������������������������������������͹��
���Desc.     �LOCALIZA��O : Function VldCodSep() - Valida��o da Ordem de  ���
���			  Separa��o. � executado antes da fun��o MSCBFSem()           ���
���           DESCRI��O : � utilizado para validar a Ordem de Separa��o   ���
���           informada pelo coletor RF, permitindo ou n�o que o operador ���
���           continue no processo de Separa��o.       					  ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function ACD166ST()
	local _lRet     := .T. 	// Customiza��o de usu�rio. Caso o retorno seja falso, n�o finaliza a separa��o. 
	local _cOrdSep  := PARAMIXB[1] 
	Local _dDtIni   := ""
	Local _cNomeCb1 := ""
	Local _cCodUser := __cUserId
	Local _cUser	:= ""			

	dbSelectArea("CB1")
	CB1->(dbSetOrder(2))
	If CB1->(MsSeek(xFilial("CB1") + _cCodUser,.T.,.F.))
		_cNomeCb1 := CB1->CB1_NOME
		_cCodSep  := CB1->CB1_CODOPE
		_cUser	  := CB1->CB1_CODUSR
	EndIf
	dbSelectArea("CB7")
	CB7->(dbSetOrder(1))
	If CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
		_dDtIni  := CB7->CB7_DTISEP
		_cNomeOs := CB7->CB7_NOMOP1
		If Empty(_dDtIni)
			while !RecLock("CB7",.F.) ; enddo
				CB7->CB7_CODOPE := _cCodSep
				CB7->CB7_NOMOP1 := _cNomeCb1
				CB7->CB7_DTISEP := Date()
				CB7->CB7_HRISOS := Time()
			CB7->(MsUnLock())
		ElseIf _cCodUser <> _cUser
			VtAlert("Processo de Separa��o/Confer�ncia j� iniciado pelo Operador '" + _cNomeOs + "' na O.S:'" + _cOrdSep + "' , verifique!","AVISO", .T.)
			_lRet := .F.
		EndIf
	EndIf
return _lRet
