#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F450SE5	ºAutor  ³Arthur F. da Silva	 º Data ³  11/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para atualização da data de emissão de	  º±±
±±º          ³ Todos os títulos de comissões emitidos, conforme parâmetrosº±±
±±º          ³ Informados na compensação entre carteiras.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F450SE5()

Local _aSavArea := GetArea()
Local _aSavSE1  := SE1->(GetArea())
Local _aSavSE2  := SE2->(GetArea())
Local _aSavSE3  := SE3->(GetArea())
Local _aSavSE5  := SE5->(GetArea())
Local _cRotina  := "F450SE5"
Local _cNum     := (SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA))  // padrao -> cPrefixo + cNum + cParcela

//***************************************************************************************************
//11/07/2016 - ARTHUR, AVALIAR A QUESTÃO DO POSIIONAMENTO INICIAL DA SE1.
//VERIFICAR SE NÃO TEREMOS PROBLEMAS, UMA VEZ QUE A DOCUMENTAÇÃO DO P.E. PREVÊ
//O POSICIONAMENTO INICIAL DA SE5 (E NÃO DA SE1).
//UMA IDÉIA SERIA DE COLOCAR A CHAVE DA SE5. CONTUDO, AVALIAR OS IMPACTOS, POIS PODE SER QUE
//A SE5 APRESENTADA SEJA DO TÍTULO A PAGAR. AVALIAR BEM ESTE PONTO. PODE ATÉ SER QUE A CHAVE PELA
//SE1 ESTEJA CORRETA, MAS AVALIAR MELHOR, PARA NÃO TERMOS IMPACTOS FUTUROS. 
//
//                                         ATT, ANDERSON COELHO - 11/07/2016
//***************************************************************************************************

Local _cTipo    := SE1->(E1_TIPO)
Local _dBaixa   := dBaixa          // Transforma o conteúdo do parâmetro padrão em variável

If Upper(AllTrim(FunName())) == "FINA450" 
	If !_cTipo $ "RA|NCC"
		dbSelectArea("SE3")
		SE3->(dbSetOrder(1))
		If SE3->(MsSeek(xFilial("SE3")+_cNum,.T.,.F.))
			While !SE3->(EOF()) .AND. SE3->E3_FILIAL == xFilial("SE3") .AND. (SE3->(E3_PREFIXO+E3_NUM+E3_PARCELA)) == _cNum
				while !RecLock("SE3",.F.) ; enddo
	          		SE3->E3_EMISSAO := _dBaixa
				SE3->(MSUNLOCK())
				dbSelectArea("SE3")
				SE3->(dbSetOrder(1))				
				SE3->(dbSkip())
			EndDo			
		EndIf
	EndIf
EndIf
                  
RestArea(_aSavSE5)
RestArea(_aSavSE3)
RestArea(_aSavSE2)
RestArea(_aSavSE1)
RestArea(_aSavArea)

Return()