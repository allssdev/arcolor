#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA330VLD  ºAutor  ³Júlio Soares        º Data ³  08/16/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada utilizado para alterar a data de emissão   º±±
±±º          ³de todas as comissões geradas para um determinado título    º±±
±±º          ³quando esse é compensado.                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa ARCOLOR.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA330VLD()

Local _aSavArea := GetArea()
Local _aSavSE1  := SE1->(GetArea())
Local _aSavSE3  := SE3->(GetArea())
Local _cRotina  := "FA330VLD"
Local _cPrfx    := ""
Local _cNtit    := ""
Local _cParc    := ""
Local _cNum     := (xFilial("SE1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA))  // padrao -> cPrefixo + cNum + cParcela
Local _cTipo    := Alltrim(cTipoTit)
Local _dBaixa   := dBaixa          // Transforma o conteúdo do parâmetro padrão em variável
Local _lRet     := .T.
Local nCont     := 0

If Upper(AllTrim(FunName())) == "MATA330" .OR. Upper(AllTrim(FunName())) == "FINA740"
	If !_cTipo $ "RA|NCC"
		dbSelectArea("SE3")
		SE3->(dbSetOrder(1))
		If SE3->(MsSeek(_cNum,.T.,.F.))
			While !SE3->(EOF()) .AND. (xFilial("SE3")+SE3->(E3_PREFIXO+E3_NUM+E3_PARCELA)) == _cNum
				while !RecLock("SE3",.F.) ; enddo
	           		SE3->E3_EMISSAO := _dBaixa
				SE3->(MSUNLOCK())
				dbSelectArea("SE3")
				SE3->(dbSetOrder(1))
				SE3->(dbSkip())
			EndDo			
		// - Alterado em 22/10/2015 por Júlio Soares - Retirado a apresentação da Mensagem nas compensações.
		//Else
			//MSGBOX("TITULO DE COMISSÃO N°- " + (SE1->E1_PREFIXO) + " - " + ( SE1->E1_NUM) + " NÃO ENCONTRADO, Verifique a existência de regras de comissão para esse representante ou crie a comissão pela rotina 'Manutenção de comissão'. ",_cRotina+"_001","ALERT")
			//_lRet := .F.
		EndIf
	Else
		//MSGBOX("O tipo do título não é (RA) ou (NCC), Verifique o título referente a Nota fiscal para realizar a compensação",_cRotina+"_02","ALERT")
		//_lRet := .F.
		For nCont := 1 To Len(aTitulos)
			/*
			If aTitulos[nCont][8] == .T.
				aTitulos[nCont][1]
				aTitulos[nCont][2]
				aTitulos[nCont][3]
		  	EndIf
		  	*/
		  	_cPrfx := aTitulos[nCont][1]
		  	_cNtit := aTitulos[nCont][2]
		  	_cParc := aTitulos[nCont][3]
			dbSelectArea("SE3")
			SE3->(dbSetOrder(1))
			_cNum := (xFilial("SE1") + _cPrfx + _cNtit + _cParc)
			//Tratar para verificar se haverá mais de um título a ser compensado pela mesma NCC ou RA.
			If SE3->(MsSeek(_cNum,.T.,.F.))
				While !SE3->(EOF()) .AND. (xFilial("SE3")+SE3->(E3_PREFIXO+E3_NUM+E3_PARCELA)) == _cNum
					while !RecLock("SE3",.F.) ; enddo
		           		SE3->E3_EMISSAO := _dBaixa
					SE3->(MSUNLOCK())
					SE3->(dbSkip())
				EndDo			
			// - Alterado em 22/10/2015 por Júlio Soares - Retirado a apresentação da Mensagem nas compensações.
			//Else
				//MSGBOX("TITULO DE COMISSÃO N°- " + (_cPrfx) + " - " + (_cNtit) + " NÃO ENCONTRADO, Verifique a existência de regras de comissão para esse representante ou crie a comissão pela rotina 'Manutenção de comissão'. ",_cRotina+"_02","ALERT")
				//_lRet := .F.
			EndIf
		Next
	EndIf
EndIf

RestArea(_aSavSE3)
RestArea(_aSavSE1)
RestArea(_aSavArea)

Return(_lRet)