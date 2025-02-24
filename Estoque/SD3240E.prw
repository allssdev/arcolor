#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SD3240E  ºAutor  ³Adriano Leonardo      º Data ³  11/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada após o estorno do movimento interno, uti- º±±
±±º          ³ lizado para atualizar o consumo mensal do produto na tabelaº±±
±±º          ³ SZG (histórico do consumo mensal - específico).            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus 11 - Específico para empresa Arcolor.              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function SD3240E()


//Salvo a área de trabalho atual
Local _aSavArea  := GetArea()
Local _aSavSB3	 := SB3->(GetArea())
Local _aSavSF5	 := SF5->(GetArea())
Local _aSavSZG	 := SZG->(GetArea())

//Variáveis auxiliares                aA
local _cRotina	 := "SD3240E"
local _lRotAtiva :=	.T. //AllTrim(__cUserId)=='000000' //Rotina ativa?
local _lCongCon  := .T. //Define se o consumo será congelado nesse movimento ou se será alterado (padrão do sistema)
local _cEntSaid  := ""                          
local _cCampo	 := "B3_Q" + STRZERO(MONTH(DDATABASE),2) //Campo a ser utilizado como macro
local lGrvSzg    := SuperGetMv("MV_GRVSZG" ,,.F.) 

//Verifica se a rotina está ativa
If !_lRotAtiva
	Return()
EndIf
//Avalia o cadastro do tipo de movimentação SF5
dbSelectArea("SF5")
SF5->(dbSetOrder(1))
If SF5->(MsSeek(xFilial("SF5")+M->D3_TM,.T.,.F.))  //No estorno deve se considerar a variável de memória (M->)
	If SF5->F5_CONSUMO<>'N'
		_lCongCon := .F.
	EndIf
	If SF5->F5_CODIGO <= "500"
		_cEntSaid  := "S" //Por ser estorno considera sempre o movimento inverso
	Else
		_cEntSaid  := "E"
	EndIf
EndIf
If _lCongCon
	dbSelectArea("SB3")
	SB3->(dbSelectArea(1))
	If SB3->(dbSeek(xFilial("SB3")+SD3->D3_COD))
		//Estorna a quantidade movimentada, considerando se o movimento foi de entrada ou saída //pOSSIVEL ERRO AQUI
		RecLock("SB3",.F.)
			//Se o movimento foi de entrada, soma a quantidade subtraída
			If _cEntSaid=="E"
				SB3->(&_cCampo) := (SB3->&_cCampo) + (SD3->D3_QUANT)
			//Senão subtrai a quantidade somada
			Else
				SB3->(&_cCampo) := (SB3->&_cCampo) - (SD3->D3_QUANT)
			EndIf
		SB3->(MsUnlock())
	EndIf		
	
If lGrvSzg //Determina se a gravação do histórico do consumo mensal está ativa na SZG (consumo médio - específico)
	If SB3->(dbSeek(xFilial("SB3")+SD3->D3_COD)) 
		u_reste009(SB3->B3_COD , SB3->(&_cCampo),_cRotina)		
	EndIf	
EndIf	
	
EndIf


//Restauro as áreas armazenadas originalmente
RestArea(_aSavSZG)
RestArea(_aSavSF5)
RestArea(_aSavSB3)
RestArea(_aSavArea)

Return()