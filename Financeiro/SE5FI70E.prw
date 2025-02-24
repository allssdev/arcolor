#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SE5FI70E  �Autor  �J�lio Soares        � Data �  19/11/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada ap�s a atualiza��o da tabela SE5 utilizada���
���          � para gravar a �ltima data encontrada, conforme par�metros, ���
���          � da movimenta��o banc�ria na data de emiss�o da comiss�o.   ���
�������������������������������������������������������������������������͹��
���          � Inserido trecho para compor a data de baixa de acordo com a���
���          � �ltima baixa realizada antes da data da exclus�o da baixa. ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function SE5FI70E()

Local  _cRotina  := 'SE5FI70E'
Local  _nValor   := 0
Local  _aSavArea := GetArea()
Local  _aSavSE1  := SE1->(GetArea())
Local  _aSavSE3  := SE3->(GetArea())
Local  _aSavSE5  := SE5->(GetArea())                                           
Local  _cNum     := (xFilial("SE3")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
// - Altera��o inserida em 20/01/2014 por J�lio Soares para que a comiss�o seja gerada com a data do cr�dito e n�o da baixa.
// - AGUARDANDO DEFINI��O DE DATA DE CORTE
//Local   _cBaixa  := (ddtcredito) //SE1->E1_DTACRED
Private nValor   := SE1->E1_VALOR

// - Verificar se nesse momento o t�tulo de vendas tem vendedor.
_cQuery := " SELECT E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_SEQ,MAX(E5_DATA)[E5_DATA] "
_cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
_cQuery += " WHERE SE5.D_E_L_E_T_ = '' "
_cQuery += "   AND SE5.E5_FILIAL  = '" + xFilial("SE5")   + "' "
_cQuery += "   AND SE5.E5_CLIENTE = '" + SE1->E1_CLIENTE  + "' "
_cQuery += "   AND SE5.E5_LOJA    = '" + SE1->E1_LOJA     + "' "
_cQuery += "   AND SE5.E5_PREFIXO = '" + SE1->E1_PREFIXO  + "' "
_cQuery += "   AND SE5.E5_NUMERO  = '" + SE1->E1_NUM      + "' "
_cQuery += "   AND SE5.E5_PARCELA = '" + SE1->E1_PARCELA  + "' "
_cQuery += " GROUP BY E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_SEQ "
_cQuery += " HAVING COUNT(E5_RECPAG) = 1 "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"SE5TMP",.T.,.F.)
//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQuery)

If TCSQLExec(_cQuery) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_01")
Else
	dbSelectArea("SE5TMP")
	SE5TMP->(dbGoTop())
	dbSelectArea("SE3")
	SE3->(dbSetOrder(1))                       
	If SE3->(dbSeek(_cNum)) //xFilial("SE3"))+ SE3->E3_PREFIXO + SE3->E3_NUM //+ SE1->E1_PARCELA +SE3->E3_CODCLI+SE3->E3_LOJA
		While !SE3->(EOF()) .AND. (xFilial("SE3")+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA) == _cNum
			If Empty(SE3->E3_DATA)
				while !RecLock("SE3",.F.) ; enddo
					SE3->E3_EMISSAO := SToD(SE5TMP->E5_DATA)
				SE3->(MsUnlock())
			EndIf
			dbSelectArea("SE3")
			SE3->(dbSetOrder(1))
			SE3->(dbSkip())
		EndDo			
	Else
		MSGBOX("TITULO DE COMISS�O N�- " + _cNum + " N�O ENCONTRADO! Verifique se o mesmo j� foi estornado completamente!",_cRotina+"_001","ALERT")
	EndIf
EndIf
dbSelectArea("SE5TMP")
SE5TMP->(dbCloseArea())

_cQuery := " SELECT TOP 1 E5_SEQ,MAX(E5_DATA)[E5_DATA] "
_cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
_cQuery += " WHERE SE5.D_E_L_E_T_ = '' "
_cQuery += "   AND SE5.E5_FILIAL  = '" + xFilial("SE5")   + "' "
_cQuery += "   AND SE5.E5_CLIENTE = '" + SE1->E1_CLIENTE  + "' "
_cQuery += "   AND SE5.E5_LOJA    = '" + SE1->E1_LOJA     + "' "
_cQuery += "   AND SE5.E5_PREFIXO = '" + SE1->E1_PREFIXO  + "' "
_cQuery += "   AND SE5.E5_NUMERO  = '" + SE1->E1_NUM      + "' "
_cQuery += "   AND SE5.E5_PARCELA = '" + SE1->E1_PARCELA  + "' " 
_cQuery += "   AND SE5.E5_SEQ    <> '" + SE5->E5_SEQ      + "' "
_cQuery += " GROUP BY E5_SEQ "
_cQuery += " HAVING COUNT(E5_RECPAG) = 1 "
_cQuery += " ORDER BY E5_SEQ DESC "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"SE5TMP",.T.,.F.)
//MemoWrite("\2.Memowrite\"+_cRotina+"_QRY_001.TXT",_cQuery)

If TCSQLExec(_cQuery) < 0
	MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_01")
Else
	dbSelectArea("SE5TMP")
	If !Empty(SE5TMP->(E5_DATA))
		_dDtBaixa := SE5TMP->(E5_DATA)
	Else
		_dDtBaixa := ""
	EndIf
	while !RecLock("SE1",.F.) ; enddo
		SE1->E1_BAIXA := STOD(_dDtBaixa)
	SE1->(MsUnlock())
	dbSelectArea("SE5TMP")
	SE5TMP->(dbCloseArea())
EndIf

RestArea(_aSavSE1)
RestArea(_aSavSE3)
RestArea(_aSavSE5)
RestArea(_aSavArea)

Return()