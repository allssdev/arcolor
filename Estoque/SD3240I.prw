#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
/*/{Protheus.doc} SD3240I
@description Ponto de entrada responsável por inibir a atualização do consumo médio do produto no momento da inclusão do movimento interno com base na SF5 (Tipo de movimentos).
@author Adriano Leonardo
@since 15/10/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
user function SD3240I()
	local _aSavArea  := GetArea()
	local _aSavSB3	 := SB3->(GetArea())
	local _aSavSF5	 := SF5->(GetArea())
	local _aSavSZG	 := SZG->(GetArea())
	local _cRotina	 := "SD3240I"
	local _lRotAtiva :=	.T. //AllTrim(__cUserId)=='000000' //Rotina ativa?
	local _lCongCon  := .T. //Define se o consumo será congelado nesse movimento ou se será alterado (padrão do sistema)
	local _cEntSaid  := ""                          
	local _cCampo	 := "B3_Q" + STRZERO(MONTH(DDATABASE),2) //Campo a ser utilizado como macro
	local cUser      := ""
	PswOrder(1)
	if PswSeek( __cUserId, .T. )   
		cUser:= __cUserId + " - " + PswRet()[1][4]
	endif
	//Verifica se a rotina está ativa
	if !_lRotAtiva
		return
	endif
	//Avalia o cadastro do tipo de movimentação SF5
	dbSelectArea("SF5")
	SF5->(dbSetOrder(1))
	if SF5->(MsSeek(xFilial("SF5")+SD3->D3_TM,.T.,.F.))
		if SF5->F5_CONSUMO<>'N'
			_lCongCon := .F.
		endif
		if SF5->F5_CODIGO <= "500"
			_cEntSaid  := "E"
		else
			_cEntSaid  := "S"
		endif
	endif
	if Inclui .And. _lCongCon
		dbSelectArea("SB3")
		SB3->(dbSelectArea(1))
		if SB3->(MsSeek(xFilial("SB3")+SD3->D3_COD))		
			//Estorna a quantidade movimentada, considerando se o movimento foi de entrada ou saída
			while !RecLock("SB3",.F.) ; enddo
				//Se o movimento foi de entrada, soma a quantidade subtraída
				if _cEntSaid=="E"
					SB3->(&_cCampo) := (SB3->&_cCampo) + (SD3->D3_QUANT)
				//Senão subtrai a quantidade somada
				else
					SB3->(&_cCampo) := (SB3->&_cCampo) - (SD3->D3_QUANT)
				endif
			SB3->(MsUnLock())
		endif		
	endif
	if SuperGetMv("MV_GRVSZG" ,,.F. ) //Determina se a gravação do histórico do consumo mensal está ativa na SZG (consumo médio - específico)
		if SB3->(dbSeek(xFilial("SB3")+SD3->D3_COD))
			_cDelete := " UPDATE " + RetSqlName("SZG") + " SET ZG_STATUS = 'N' "
			_cDelete += " WHERE ZG_FILIAL  = '" + xFilial("SZG") + "' "
			_cDelete += "   AND ZG_MESANO  = '" + SUBSTR(DtoS(SD3->D3_EMISSAO),1,6) + "' "
			_cDelete += "   AND ZG_PRODUTO = '" +  SD3->D3_COD + "' "
			if TCSQLExec(_cDelete) < 0
				MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_002")
			endif
			//Insere novo registro
			while !RecLock("SZG",.T.) ; enddo
				SZG->ZG_FILIAL  := xFilial("SZG")
				SZG->ZG_SEQUENC	:= GetSx8Num("SZG","ZG_SEQUENC")
				SZG->ZG_PRODUTO	:= SB3->B3_COD
				SZG->ZG_MESANO	:= SUBSTR(DtoS(dDataBase),1,6)
				SZG->ZG_QUANTID	:= (SB3->&_cCampo)
				SZG->ZG_STATUS  := "S"
				SZG->ZG_EMISSAO := DDATABASE
				SZG->ZG_USUARIO:= cUser
				SZG->ZG_ROTINA:= _cRotina	
			SZG->(MsUnLock())
		endif	
	endif
	//Restauro as áreas armazenadas originalmente
	RestArea(_aSavSZG)
	RestArea(_aSavSF5)
	RestArea(_aSavSB3)
	RestArea(_aSavArea)	
return