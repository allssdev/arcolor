#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ MT100AG  ºAutor  ³ Adriano L. de Souza º Data ³  02/09/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Ponto de entrada na confirmação do documento de entrada em to-º±±
±±º        ³ das as operações (inclusão, exclusão, visualização, etc.)     º±±
±±º        ³ utilizado para preservar o conteúdo do campo C7_QUJE para ser º±±
±±º        ³ restaurado posteriormente no ponto de entrada SD1100I.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso P11  ³ Uso específico Arcolor                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Í±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
user function MT100AG()
	Local _aSavArea	:= GetArea()
	Local _aSavSC7	:= SC7->(GetArea())
	Local _cRotina	:= "MT100AG"
	Local _lRet		:= .F.
	Local _nCont    := 0
	Local _nPosPed	:= aScan(aHeader,{|x|AllTrim(x[02])=="D1_PEDIDO"})
	Local _nPosIte	:= aScan(aHeader,{|x|AllTrim(x[02])=="D1_ITEMPC"})
	Local _nPosQtd	:= aScan(aHeader,{|x|AllTrim(x[02])=="D1_QUANT"})
	If INCLUI .OR. ALTERA
		for _nCont := 1 to len(aCols)
			If !Empty(aCols[_nCont][_nPosPed])
				dbSelectArea("SC7")
				If SC7->(FieldPos("C7_BKQUJE"))<>0 //Certifico que o campo exista
					SC7->(dbSetOrder(1))
					If SC7->(MsSeek(xFilial("SC7")+aCols[_nCont][_nPosPed]+aCols[_nCont][_nPosIte],.T.,.F.))
						RecLock("SC7",.F.)
							SC7->C7_BKQUJE := SC7->C7_QUJE //Preservo a quantidade entregue para utilizá-la no P.E. SD1100I
						SC7->(MsUnlock())
					EndIf
				EndIf
			EndIf
	   	next
	Else
		for _nCont := 1 to len(aCols) ///erro do pedido de compra esta aqui
			If !Empty(aCols[_nCont][_nPosPed])
				dbSelectArea("SC7")
				SC7->(dbSetOrder(1))
				If SC7->(MsSeek(xFilial("SC7")+aCols[_nCont][_nPosPed]+aCols[_nCont][_nPosIte],.T.,.F.))
					If SC7->C7_QUANT < aCols[_nCont][_nPosQtd]
						_nAux := aCols[_nCont][_nPosQtd] - SC7->C7_QUANT
						RecLock("SC7",.F.) 
						SC7->C7_QUJE :=  SC7->C7_QUJE - _nAux 
						SC7->(MsUnlock())
				    EndIf
				EndIf
			EndIf
		next	
	EndIf
	RestArea(_aSavSC7)
	RestArea(_aSavArea)
return(_lRet)
