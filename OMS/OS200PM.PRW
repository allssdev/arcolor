#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OS200PM  ºAutor  ³ Júlio Soares       º Data ³  16/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada executado após a realização da manutenção º±±
±±º          ³ da carga.                                                  º±±
±±º          ³ Está sendo utilizado para permitir que a manutenção        º±±
±±º          ³ da carga seja realizada quantas vezes necessário inibindo  º±±
±±º          ³ o bloqueio da carga.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa ARCOLOR.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function OS200PM()
	Local _aSavArea := GetArea()
	Local _aSavDAK  := DAK->(GetArea())
	Local _aSavDAI  := DAI->(GetArea())
	Local _aSavSF2  := SF2->(GetArea())
	Local _aSavSC9  := SC9->(GetArea())
	Local _cRotina  := 'OS200PM'
	Local _nPosCod  := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_COD"   })
	Local _nPosSr   := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_SERIE2"})
	Local _nPosNf   := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_NFISC2"})
	Local _x        := 0
//	Local _lLinha   := .F.
	If AllTrim(DAK->DAK_FEZNF) == '1'
		RecLock("DAK",.F.)
			DAK->DAK_FEZNF := '2'
		DAK->(MsUnlock())
		// - Trecho inserido para verificar se a limpeza foi realizada na SC9
			for _x := 1 to Len(aCols)
				If aCols[_x][Len(aHeader)+1]
					dbSelectArea("SC9")
					SC9->(dbSetOrder(6))			// - C9_FILIAL+C9_SERIENF+C9_NFISCAL+C9_CARGA+C9_SEQCAR
					If SC9->(MsSeek(xFilial("SC9")+aCols[_x][_nPosSr]+aCols[_x][_nPosNf]+aCols[_x][_nPosCod],.T.,.F.))
						While !SC9->(EOF()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_CARGA == aCols[_x][_nPosCod]
							If !Empty (SC9->C9_CARGA) .AND. !Empty (SC9->C9_SEQCAR)
								Reclock("SC9",.F.)
									SC9->C9_CARGA  := ""
									SC9->C9_SEQCAR := ""
								SC9->(MsUnlock())
							EndIf
							dbSelectArea("SC9")
							SC9->(dbSetOrder(6))			// - C9_FILIAL+C9_SERIENF+C9_NFISCAL+C9_CARGA+C9_SEQCAR
							SC9->(dbSkip())
						EndDo
					EndIf
					dbSelectArea("SF2")
					SF2->(dbSetOrder(1))					// - F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
					If SF2->(MsSeek(xFilial("SF2")+aCols[_x][_nPosNf]+aCols[_x][_nPosSr],.T.,.F.))
						If !Empty (SF2->F2_CARGA) .AND. !Empty (SF2->F2_SEQCAR)
							RecLock("SF2",.F.)
								SF2->F2_CARGA  := ""
								SF2->F2_SEQCAR := ""
							SF2->(MsUnlock())
						EndIf
					EndIf
				EndIf
			next
		// - Fim
		MSGBOX('Manutenção realizada com sucesso!',_cRotina + '_001','INFO')
	EndIf
	RestArea(_aSavSC9)
	RestArea(_aSavSF2)
	RestArea(_aSavDAI)
	RestArea(_aSavDAK)
	RestArea(_aSavArea)
return