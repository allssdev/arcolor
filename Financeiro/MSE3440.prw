#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MSE3440   �Autor  �J�lio Soares        � Data �  18/07/13  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para alterar a data da comiss�o para a    ���
���          � data da ultima movimenta��o realizada no t�tulo ap�s a     ���
���          � gera��o da comiss�o.                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MSE3440()

Local _aSavArea := GetArea()
Local _aSavSE1  := SE1->(GetArea())
Local _aSavSE3  := SE3->(GetArea())
Local _aSavSE5  := SE5->(GetArea())
Local _cRotina  := "MSE3440"
Local _cNum     := (xFilial("SE3")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
Local _cBaixa   := SE1->E1_BAIXA

// - Altera��o inserida em 20/01/2014 por J�lio Soares para que a comiss�o seja gerada com a data do cr�dito e n�o da baixa.
// - AGUARDANDO DEFINI��O DE DATA DE CORTE
//Local   _cBaixa   := (ddtcredito) //SE1->E1_DTACRED

If Upper(AllTrim(FunName()))=="FINA740" .OR. Upper(AllTrim(FunName()))=="FINA070" .OR. Upper(AllTrim(FunName()))=="FINA440" .OR. Upper(AllTrim(FunName()))=="RFINA440"
	//MSGBOX("MSE3440",_cRotina+"_01","ALERT")
	_cQry := " UPDATE " + RetSqlName("SE3")
	_cQry += " SET E3_EMISSAO   = '" + DTOS(_cBaixa) + "' "
	_cQry += " WHERE D_E_L_E_T_ = '' "
	_cQry += "   AND E3_FILIAL  = '" + xFilial("SE3")  + "' "
	_cQry += "   AND E3_PREFIXO = '" + SE1->E1_PREFIXO + "' "
	_cQry += "   AND E3_NUM     = '" + SE1->E1_NUM     + "' "
	_cQry += "   AND E3_PARCELA = '" + SE1->E1_PARCELA + "' "
	_cQry += "   AND E3_TIPO    = '" + SE1->E1_TIPO    + "' "
	//If __cUserId == "000000"
//		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
	//EndIf
	If TCSQLExec(_cQry) < 0
		MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_016")
	Else
		dbSelectArea("SE3")
		TcRefresh("SE3")
		SE3->(dbSetOrder(1))
		If SE3->(dbSeek(_cNum)) //xFilial("SE3"))+ SE3->E3_PREFIXO + SE3->E3_NUM //+ SE1->E1_PARCELA
			While !SE3->(EOF()) .AND. (xFilial("SE3")+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA) == _cNum
				If Empty(SE3->E3_DATA)
					while !RecLock("SE3",.F.) ; enddo
						SE3->E3_EMISSAO := _cBaixa
					dbSelectArea("SE3")
					SE3->(MSUNLOCK())
				EndIf
				dbSelectArea("SE3")
				SE3->(dbSetOrder(1))
				SE3->(dbSkip())
			EndDo
		Else
			If AllTrim(SE1->E1_TIPO) <> 'NCC' // Condi��o incluida em 09/12/2013 por J�lio Soares ap�s a apresenta��o do Alert nos rec�lculos de comiss�o.
				MSGBOX("TITULO DE COMISS�O - " + _cNum + " - N�O ENCONTRADO!",_cRotina+"_002","ALERT")
			EndIf
		EndIf
	EndIf
EndIf

RestArea(_aSavSE1)
RestArea(_aSavSE3)
RestArea(_aSavSE5)
RestArea(_aSavArea)

Return()
//���������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
//�Poss�velmente, ap�s pr�via an�lise nas baixas de t�tulos, foi observado que talvez somente este fonte fosse necess�rio para realizar as altera��es.�
//�Pocesso em an�lise.                                                                                                                                �
//�����������������������������������������������������������������������������������������������������������������������������������������������������