#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ RFATE044 ºAutor  ³ Adriano L. de Souza º Data ³ 05/05/2014   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Execblock de validação da condição de pagamento no pedido de  º±±
±±ºDesc.   ³ vendas, esse execblock será chamado na rotina de validação do º±±
±±ºDesc.   ³ via fórmula e retornar se o pedido poderá ou não ser liberado,º±±
±±ºDesc.   ³ dependendo se o valor da menor parcela é maior que o mínimo   º±±
±±ºDesc.   ³ estabelecido para a condição de pagamento utilizada.          º±±
±±ºDesc.   ³ Obs. Essa validação só será processada em pedidos de saldo.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11  ³ Uso específico Arcolor                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RFATE044()

Local _cRotina  := "RFATE044"
Local _aSavArea := GetArea()
Local _aSavSC5	:= SC5->(GetArea())
Local _aSavSC6	:= SC6->(GetArea())
Local _aSavSE4	:= SE4->(GetArea())
Local _aParcelas:= {}
Local _cCondPg	:= IIF(Type("M->C5_CONDPAG")<>"U",M->C5_CONDPAG,SC5->C5_CONDPAG)
Local _nTotIPI	:= 0
Local _nTotST	:= 0	
Local _dData	:= dDataBase
Local _lRet		:= .T.

//Não serão avaliados pedidos do tipo devolução ou beneficiamento e pedidos que não sejam "Saldo"
If (SC5->C5_TIPO $ "B|D") .OR. AllTrim(Upper(SC5->C5_SALDO))<>"S"
	Return(_lRet)
EndIf
//Avalio o mínimo estabelecido para a condição de pagamento
dbSelectArea("SE4")
SE4->(dbSetOrder(1)) //Filial + Código
If SE4->(FieldPos("E4_MINIMO"))==0
	MsgAlert("O campo E4_MINIMO não foi criado, favor informar o Administrador do sistema!",_cRotina + "_001")
	Return(_lRet)
EndIf
If SE4->(MsSeek(xFilial("SE4")+_cCondPg,.T.,.F.))
	_nValMin := SE4->E4_MINIMO
EndIf
If _nValMin > 0
	//Inicio o processamento do MaFis()
	MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C",SC5->C5_TIPO,SC5->C5_TIPOCLI,MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR730")
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1)) //Filial + Numero do pedido
	If SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM,.T.,.F.))
		While SC6->(!EOF()) .And. SC6->C6_NUM==SC5->C5_NUM .AND. SC6->C6_FILIAL==xFilial("SC6")
			If (SC6->C6_QTDVEN-SC6->C6_QTDENT)>0
				nPrcTot := ((SC6->C6_QTDVEN-SC6->C6_QTDENT)*SC6->C6_PRCVEN)
				nPrcUni := SC6->C6_PRCVEN
				//MaFisAdd(SC6->C6_PRODUTO,SC6->C6_TES,SC6->C6_QTDVEN,nPrcUni,0,"","",0,0,0,0,0,nPrcTot,0,0,0)
				MaFisAdd(SC6->C6_PRODUTO,SC6->C6_TES,(SC6->C6_QTDVEN-SC6->C6_QTDENT),nPrcUni,0,"","",0,0,0,0,0,nPrcTot,0,0,0)
			EndIf
			dbSelectArea("SC6")
			SC6->(dbSetOrder(1)) //Filial + Numero do pedido
			SC6->(dbSkip())
		EndDo
		_nTotal		:= MaFisRet(1,"NF_TOTAL"  )
		_nTotIPI	:= MaFisRet(1,"NF_VALIPI" )
		_nTotST		:= MaFisRet(1,"NF_VALSOL" )
		_aParcelas  := Condicao(_nTotal,_cCondPg,_nTotIPI,_dData,_nTotST)
		//Seleciono a parcela mínima
		For _nCont := 1 To Len(_aParcelas)
			If _nCont == 1 .OR. _aParcelas[_nCont,2]<_nParMin
				_nParMin := _aParcelas[_nCont,2]
			EndIf
		Next
		//Verifico se a menor parcela é inferior ao mínimo permitido
		If _nValMin > _nParMin
			_lRet := .F.
			MsgAlert("Condição de pagamento inválida, o valor de uma ou mais parcelas seria inferior a R$" + AllTrim(Transform(_nValMin,PesqPict("SE4","E4_MINIMO"))) + " que é o mínimo estabelecido para ela, altere a condição de pagamento antes de continuar!",_cRotina+"_002")
		EndIf
	EndIf
	//Encerro o MaFis()
	MaFisEnd()
EndIf
//Restauro a área de trabalho original
RestArea(_aSavSE4)
RestArea(_aSavSC5)
RestArea(_aSavSC6)
RestArea(_aSavArea)

Return(_lRet)