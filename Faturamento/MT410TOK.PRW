#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT410TOK  �Autor  �Anderson C. P. Coelho � Data �  19/11/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada na valida��o do bot�o OK do pedido de     ���
���          � vendas, neste caso utilizado para processar:               ���
���          � 1 - Limpeza do campo de observa��es de bloqueio das regras ���
���          �     de neg�cios, para que as rotinas reavaliem posterior-  ���
���          �     mente.                                                 ���
���          � 2 - Bloquear por regra de neg�cios os pedidos de vendas    ���
���          �     que n�o tenham regra cadastrada.                       ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT410TOK()

Local _aSavArea  := GetArea()
Local _aSavSC5   := SC5->(GetArea())
Local _aSavSC6   := SC6->(GetArea())
Local _lRet      := .T.
Local _cLogx     := ""
Local _cRotina   := "MT410TOK"
//If ALTERA
//	M->C5_OBSBLQ := CriaVar("C5_OBSBLQ")
//EndIf
dbSelectArea("ACS")
ACS->(dbOrderNickName("ACS_CODCLI"))
If !MsSeek(xFilial("ACS") + Padr(M->C5_CLIENTE,TamSx3("ACS_CODCLI")[01]) + Padr(M->C5_LOJACLI,TamSx3("ACS_LOJA")[01]),.T.,.F.)
	//M->C5_OBSBLQ := "CLIENTE SEM AMARRA��O A REGRA DE NEG�CIOS!"
	M->C5_BLQ    := "1"
ElseIf ACS->ACS_DATATE < dDataBase
	//M->C5_OBSBLQ := "REGRA DE NEG�CIOS " + AllTrim(ACS->ACS_CODREG) + " EXPIRADA EM " + DTOC(ACS->ACS_DATATE) + "!"
	M->C5_BLQ    := "1"
EndIf
//28/11/2016 - Arthur Silva - Novo Log para os Pedidos Inserido
//If !Empty(_cLogx)
If ExistBlock("RFATL001") .AND. SC5->(FieldPos("C5_FLAGLOG"))>0 .AND. Empty(M->C5_FLAGLOG)
	_cLogx += "Pedido Inclu�do Via Call Center com Sucesso!"
	U_RFATL001(	M->C5_NUM  ,;
				,;
				_cLogx,;
				_cRotina    )
	M->C5_FLAGLOG	:= "S"
ElseIf ALTERA .AND. ExistBlock("RFATL001")
	_cLogx += "Pedido Alterado."
	U_RFATL001(	M->C5_NUM  ,;
				,;
				_cLogx,;
				_cRotina   )
	If SC5->(FieldPos("C5_DTLIBCR"))<>0
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1)) 
		If SC5->(MsSeek(xFilial("SC5")+M->C5_NUM ,.T.,.F.))
			while !RecLock("SC5",.F.); enddo
				M->C5_DTLIBCR:= STOD("")
			SC5->(MsUnLock())
		EndIf
	EndIf							
EndIf


//EndIf

RestArea(_aSavSC5 )
RestArea(_aSavSC6 )
RestArea(_aSavArea)

Return(_lRet)