#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M461SB3  ºAutor  ³Adriano Leonardo      º Data ³  09/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada utilizado para validar se o consumo mensalº±±
±±º          ³ do produto será atualizado com base na nota fiscal de saídaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus 11 - Específico para empresa Arcolor.              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function M461SB3()
	                         
//Salvo a área de trabalho atual
Local _aSavArea  := GetArea()
Local _aSavSB3	 := SB3->(GetArea())
Local _aSavSZG	 := SZG->(GetArea())
Local _lRet		 := .T.	//O retorno sempre será .T. - ponto de entrada não está validando o movimento
Local _cAnoMes	 := SUBSTR(DtoS(SD2->D2_EMISSAO),1,6) 	       //AnoMes no formato (AAAAMM)
Local _cCampo	 := "B3_Q" + STRZERO(MONTH(SD2->D2_EMISSAO),2) //Variável para utilização de macro
Local lGrvSzg    := SuperGetMv("MV_GRVSZG" ,,.F.) 
local _QtdCons   := 0
private _cRotina := "M461SB3"

_QtdCons:= Iif(SD2->D2_TIPO $ ("D") , (SB3->&_cCampo) - SD2->D2_QUANT,  iif(SD2->D2_TIPO $ ("N"),(SB3->&_cCampo) + SD2->D2_QUANT,(SB3->&_cCampo) ))

If lGrvSzg //Determina se a gravação do histórico do consumo mensal está ativa na SZG (consumo médio - específico)
	u_reste009(SB3->B3_COD , _QtdCons ,_cRotina,SD2->D2_EMISSAO)			
EndIf		

//Restauro as áreas armazenadas originalmente
RestArea(_aSavSZG)
RestArea(_aSavSB3)
RestArea(_aSavArea)

Return(_lRet)