#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _lEnt CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  OS200ASS   ºAutor  ³Arthur Silva        º Data ³  24/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Ponto de Entrada executado para gravar informações nas  	  º±±
±±º			 ³ tabelas envolvidas,após a associação do veículo na carga.  º±±
±±º			   															  º±±
±±º          ³ EM QUE PONTO: Permite executar rotinas especificas após    º±±
±±º          ³associar veiculo na montagem de cargas    	 			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - SIGAOMS - Específico para a emrpesa Arcolor.  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function OS200ASS()
	Local _cRotina := "OS200ASS"
	Local _aSvArea := GetArea()
	Local _aSvADAK := DAK->(GetArea())
	Local _aSvADA3 := DA3->(GetArea())
	Local _cCarga  := DAK->DAK_COD
	Local _cSqCar  := DAK->DAK_SEQCAR
	Local _dCarga  := DAK->DAK_DATA
	Local _lRet    := .T.

	//ATUALIZAÇÃO DA DAK
	_cQUpd1  := " UPDATE " + RetSqlName("DAK")             														+_lEnt
	_cQUpd1  += " SET DAK_VLFRET = DA3_VLFRET																 "	+_lEnt
	_cQUpd1  += " FROM " + RetSqlName("DAK") + " DAK (NOLOCK) 												 "  +_lEnt
	_cQUpd1  += "      INNER JOIN " + RetSqlName("DA3") + " DA3 (NOLOCK) ON DA3.DA3_FILIAL = '" + xFilial("DA3") + "' " +_lEnt
	_cQUpd1  += "                 AND DA3.DA3_COD     = DAK.DAK_CAMINH										 " 	+_lEnt
	_cQUpd1  += "                 AND DA3.DA3_MOTORI  = DAK.DAK_MOTORI    									 "	+_lEnt
	_cQUpd1  += "                 AND DA3.D_E_L_E_T_  = ''		    										 "  +_lEnt
	_cQUpd1  += "   WHERE 	DAK.DAK_FILIAL 	   = '" + xFilial("DAK") + "' 									 "  +_lEnt
	_cQUpd1  += " 			AND DAK.DAK_COD    = '" + _cCarga  + "' 										 "  +_lEnt
	_cQUpd1  += " 			AND DAK.DAK_SEQCAR = '" + _cSqCar + "' 											 "	+_lEnt
	_cQUpd1  += " 			AND DAK.DAK_DATA   = '" + DTOS(_dCarga) + "'									 "  +_lEnt
	_cQUpd1  += " 			AND DAK.D_E_L_E_T_ = '' 														 "  +_lEnt
//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_Frete_Carga_" + _cCarga + ".txt",_cQUpd1)
	If TCSQLExec(_cQUpd1) < 0
		MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_001",'STOP')
	EndIf
	TcRefresh(RetSqlName("DAK"))
	RestArea( _aSvADA3)
	RestArea( _aSvADAK)
	RestArea( _aSvArea)
return _lRet