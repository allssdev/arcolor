#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SD3250E  ºAutor  ³Adriano Leonardo      º Data ³  11/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada após a gravação do consumo na SB3, após o º±±
±±º          ³ estorno da produção, utilizado para atualizar a tabela SZG º±±
±±º          ³ (histório do consumo mensal - específico).                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus 11 - Específico para empresa Arcolor.              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function SD3250E()

//Salvo a área de trabalho atual
Local _aSavArea  := GetArea()
Local _aSavSD3	 := SD3->(GetArea())
Local _aSavSB3	 := SB3->(GetArea())
Local _aSavSZG	 := SZG->(GetArea())
local lGrvSzg    := SuperGetMv("MV_GRVSZG" ,,.F.) 

//Variáveis auxiliares
local _cRotina	 := "SD3250E"
local _cCampo	 := ""//"B3_Q" + STRZERO(MONTH(dDataBase),2) //Campo a ser utilizado como macro - Alterado por Renan em 08/09/2016 para utilizar a Data de emissao da tabela SD3 para os casos de apontamento parcial que ocorrem em meses diferentes.
If lGrvSzg //Determina se a gravação do histórico do consumo mensal está ativa na SZG (consumo médio - específico)
	dbSelectArea("SD3") //Movimentos internos
	SD3->(dbSetOrder(1))
	_cNumOP	:= SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD
	If SD3->(dbSeek(xFilial("SD3")+_cNumOP))
		While !SD3->(EOF()) .And. SD3->D3_OP == _cNumOP .And. SD3->D3_FILIAL == xFilial("SD3")
			_cCampo	 := "B3_Q" + SUBSTR(DtoS(SD3->D3_EMISSAO),5,2)//Alterado por Renan em 08/09/2016 - para que seja utilizado o mês conforme o campo da SD3 devido às divergencias na tabela SZG quando efetuado apontamento parcial. 
			dbSelectArea("SB3") // Demandas
			SB3->(dbSetOrder(1))
			SB3->(dbGoTop())
			If SB3->(dbSeek(xFilial("SB3")+SD3->D3_COD))
				u_reste009(SB3->B3_COD , (SB3->&_cCampo) ,_cRotina)				
			EndIf
			dbSelectArea("SD3")
			SD3->(dbSetOrder(1))
			SD3->(dbSkip())
		EndDo
	EndIf
EndIf
/* AGUARDANDO DEFINIÇÃO DO CLIENTE PARA IMPLANTAÇÃO DO INSPEÇÃO DE PROCESSO.
DbSelectArea("QPK")
QPK->(dbSetOrder(3)) //QPK_FILIAL+QPK_XNUMSE
If QPK->(MsSeek(xFilial("QPK")+SD3->D3_NUMSEQ,.T.))
	RecLock("QPK",.F.)
		QPK->(dbDelete())
	QPK->(MsUnlock())
EndiF
*/
//Restauro as áreas armazenadas originalmente
RestArea(_aSavSZG)
RestArea(_aSavSB3)
RestArea(_aSavSD3)
RestArea(_aSavArea)

Return()                                                          
