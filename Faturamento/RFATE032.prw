#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE032  ºAutor  ³Adriano Leonardo    º Data ³  14/11/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina responsável por atualizar o NCM do cadastro de pro- º±±
±±º          ³ duto com base no informado no pedido de vendas.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
user function RFATE032()
	Local _aSavArea := GetArea()
	Local _cRotina	:= "RFATE032"
	Local _aSavSB1	:= SB1->(GetArea())
	Local _lRet		:= .F.
	Local _nPosCod	:= aScan(aHeader,{|x|AllTrim(x[02])=="C6_PRODUTO"})
	Local _nPosNcm	:= aScanAda(aHeader,{|x|AllTrim(x[02])=="C6_NCM"	 })
	
	dbSelectArea("SB1")
	sb1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+aCols[n,_nPosCod]))
		If	SB1->B1_POSIPI<>aCols[n,_nPosNcm]
			If MsgYesNo("O NCM do cadastro do produto será alterado de " + Transform(AllTrim(SB1->B1_POSIPI),PesqPict("SB1","B1_POSIPI")) + " para " + Transform(AllTrim(aCols[n,_nPosNcm]),PesqPict("SB1","B1_POSIPI")) + ", deseja continuar?",_cRotina+"_001")
			
				dbSelectArea("SB1")
				while !RecLock("SB1",.F.) ; enddo
					SB1->B1_POSIPI := aCols[n][_nPosNcm]
				SB1->(MsUnlock())
				_lRet := .T.
			Else
				_lRet := .F.
			EndIf
		Else 	
			_lRet := .T.
		EndIf
	EndIf
	RestArea(_aSavArea)
return(_lRet)