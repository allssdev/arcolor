#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MTA455P   �Autor  �J�lio Soares       � Data �  17/02/14   ���
���          �           �Autor  �J�lio Soares       � Data �  17/06/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada que valida a libera��o de estoque.        ���
���          � Evita o corte de pedidos com prioridade 1.                 ���
�������������������������������������������������������������������������͹��
���          � Inserido trecho para implementar a apresenta��o de log de  ���
���          � processo nesse ponto.                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa Arcolor.                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTA455P()

Local _aSavArea := GetArea()
Local _aSavSC5  := SC5->(GetArea())
Local _aSavSC6  := SC6->(GetArea())
Local _aSavSC9  := SC9->(GetArea())
Local _aSavSUA  := SUA->(GetArea())
Local _cRotina  := 'MTA455P'
Local _cCondpg  := SuperGetMV('MV_MTA455P',,'166')
Local _cLogx    := ""
Local _cLog     := ""
Local _lEnt     := CHR(13)+CHR(10)
Local _lRet     := .T.

//Private aSaldos :={}
Private nOpcx := 0

IF ValType(nQtdNew)="N"
	_nQtdNew:=	nQtdNew
else
	Private nQtdNew := 0
Endif

dbSelectArea("SC5")
SC5->(dbSetOrder(1))
SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
dbSelectArea("SUA")
SUA->(dbOrderNickName("UA_NUMSC5"))
SUA->(MsSeek(xFilial("SUA") + SC9->C9_PEDIDO,.T.,.F.))
If SC5->C5_NPRIORI == '1'
	_cLogx := "N�o � poss�vel alterar a quantidade do produto " + Alltrim(SC6->C6_PRODUTO) + " - " + Alltrim(SC6->C6_DESCRI) + " pois o pedido tem prioridade m�xima e deve ser faturado totalmente."
	MSGBOX(_cLogx,_cRotina+"_001","ALERT")
	_lRet := .F.
ElseIf SC5->C5_CONDPAG $ _cCondpg
	_cLogx := "N�o � poss�vel alterar a quantidade dos produtos para pedidos que j� tiveram o pagamento efetuado."
	MSGBOX(_cLogx,_cRotina+"_002","STOP")
	_lRet := .F.
Else
	If _nQtdNew == 0
	_cLogx := "Qtde. para separa��o do Item n�mero: " + Alltrim(SC6->C6_ITEM) + " / " + Alltrim(SC6->C6_PRODUTO) + " - " + Alltrim(SC6->C6_DESCRI) + " cortada totalmente do pedido."
	Else
	_cLogx := "Qtde. para separa��o do Item n�mero: " + Alltrim(SC6->C6_ITEM) + " / " + Alltrim(SC6->C6_PRODUTO) + " - " + Alltrim(SC6->C6_DESCRI) + " menor que a qtde. solicitada. Liberado " + cValTochar(_nQtdNew) + " Unidades"
	EndIF
	SUA->(dbOrderNickName("UA_NUMSC5"))
	If SUA->(MsSeek(xFilial("SUA") + SC9->C9_PEDIDO,.T.,.F.))
		_cLog  := Alltrim(SUA->UA_LOGSTAT)
		If SUA->(FieldPos("UA_LOGSTAT"))>0
			RecLock("SUA", .F.)
				SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
				UsrRetName(__cUserId) + _lEnt + _cLogx
			SUA->(MsUnLock())
		EndIf
	EndIf
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
		_cLog := Alltrim(SC5->C5_LOGSTAT)
		If SC5->(FieldPos("C5_LOGSTAT"))>0
			RecLock("SC5",.F.)
				SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
				UsrRetName(__cUserId) + _lEnt + _cLogx
			SC5->(MsUnLock())
		EndIf
	EndIf
EndIf
//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
If ExistBlock("RFATL001")
	U_RFATL001(	SC5->C5_NUM,;
				SUA->UA_NUM,;
				_cLogx     ,;
				_cRotina    )
EndIf

RestArea(_aSavSUA)
RestArea(_aSavSC9)
RestArea(_aSavSC6)
RestArea(_aSavSC5) 
RestArea(_aSavArea)

Return(_lRet)
