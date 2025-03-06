#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
#define _lEnt    CHR(10)+CHR(13)
/*/{Protheus.doc} RTMKA001
@description Rotina responsável por eliminar os atendimentos que não geraram pedidos de venda.
@author Júlio Soares (ALL System Solutions)
@since 22/06/2015
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RTMKA001()
	Private _cRotina := "RTMKA001"
	Private _cPerg   := _cRotina
	ValidPerg()
	If Pergunte(_cPerg,.T.)
		Processa({ |lEnd| _DeletSUA(@lEnd) },_cRotina + "_001",' Verificando os pedidos a serem processados. Aguarde...',.T.)
	EndIf
return
/*/{Protheus.doc} _DeletSUA
@description SubRotina de deleção de registro.
@author Júlio Soares (ALL System Solutions)
@since 06/22/2015
@version 1.0
@param lEnd, logical, Se houve cancelamento ou não desta operação.
@type function
@see https://allss.com.br
/*/
static function _DeletSUA(lEnd)
	local _aSavArea := GetArea()
//	local _aSavSUA	:= SUA->(GetArea())
	local _aSavSUB	:= SUB->(GetArea())
	local _cPed     := ""
	local _cLog     := ""
	local _nVez     := 0
	local _lRet     := .F.
	dbSelectArea("SUA")
	SUA->(dbSetOrder(1))
	ProcRegua(SUA->(RecCount()))
	_cFilSUA := 'UA_FILIAL == "' + xFilial("SUA")+'".AND. UA_NUMSC5== "      "'
	_cFilSUA += '.AND. UA_EMISSAO >= STOD("'+DTOS(MV_PAR01)+'") .AND. UA_EMISSAO <= STOD("'+DTOS(MV_PAR02)+'")'
	_cFilSUA += '.AND. UA_NUM >= "'+(MV_PAR03)+'" .AND. UA_NUM <= "'+(MV_PAR04)+'"'
	_cFilSUA += '.AND. (UA_CLIENTE + UA_LOJA) >= "'+(MV_PAR05 + MV_PAR06)+'" .AND. (UA_CLIENTE + UA_LOJA) <= "'+(MV_PAR07 + MV_PAR08)+'"'
	_cFilSUA += '.AND. UA_CANC <> "S"'
	SUA->(dbClearFilter())
	SUA->(dbSetFilter({ || &(_cFilSUA) }, _cFilSUA ))
	SUA->(dbGoTop())
	While !SUA->(EOF()) .AND. SUA->UA_FILIAL == xFilial("SUA") .AND. !_lRet .AND. !lEnd
		// - Verifico se o pedido está dentro dos parâmetros (Numero + Data)
		If Empty(SUA->UA_NUMSC5) .AND. SUA->UA_EMISSAO >= MV_PAR01 .AND. SUA->UA_EMISSAO <= MV_PAR02
			If SUA->UA_NUM >= MV_PAR03 .AND. SUA->UA_NUM <= MV_PAR04
				If SUA->(UA_CLIENTE+UA_LOJA) >= (MV_PAR05 + MV_PAR06) .AND. SUA->(UA_CLIENTE+UA_LOJA) <= (MV_PAR07 + MV_PAR08)
					_cPed := SUA->UA_NUM
					IncProc("Processando pedido n° "+ AllTrim(SUA->UA_NUM)+"...")
					Begin Transaction
						_cLog += _cPed +';'
						while !RecLock("SUA",.F.) ; enddo
							SUA->UA_STATUS  := "CAN"
							SUA->UA_CANC    := "S"
							SUA->UA_CODCANC := "AUTO"
							SUA->UA_AUTDEL  := (DTOC(dDataBase))+"-"+(TIME())+"-"+(UsrRetName(__cUserId))
							If !Empty(SUA->UA_AUTDEL) .AND. !lEnd
								SUA->(dbDelete())
								_lRet := .T.
							EndIf
						SUA->(MsUnLock())
						_nVez ++
						dbSelectArea("SUA")
						SUA->(dbSetOrder(1))
						dbSelectArea("SUB")
						SUB->(dbSetOrder(1))
						_cFilSUB := 'UB_FILIAL == "' + xFilial("SUA")+'".AND. UB_NUM == "'+(_cPed)+'"'
						SUB->(dbClearFilter())
						SUB->(dbSetFilter({ || &(_cFilSUB) }, _cFilSUB ))
						SUB->(dbGoTop())
						while !SUB->(EOF()) .AND. SUB->UB_FILIAL == xFilial("SUB") .AND. _lRet .AND. !lEnd
							IncProc("Processando pedido n° "+ AllTrim(SUA->UA_NUM)+"...")
							if SUB->UB_NUM == _cPed
								while !RecLock("SUB",.F.) ; enddo
									SUB->(UB_AUTDEL)  := (DTOC(dDataBase))+"-"+(TIME())+"-"+(UsrRetName(__cUserId))
									if !Empty(SUB->UB_AUTDEL) .AND. !lEnd
										SUB->(dbDelete())
									endif
								SUB->(MsUnLock())
								//_cLog += SUB->UB_ITEM + " - " + SUB->UB_PRODUTO + _lEnt
							endif
							dbSelectArea("SUB")
							SUB->(dbSetOrder(1))
							IncProc("Processando pedido n° "+ AllTrim(SUA->UA_NUM)+"...")
							SUB->(dbSkip())
						enddo
		           	End Transaction
					_lRet := .F.
					RestArea(_aSavSUB)
				EndIf
			EndIf
		EndIf
		SUA->(dbSkip())	
	EndDo
	//MemoWrite("\2.MemoWrite\De_"+DTOC(MV_PAR01)+"_Ate_"+DTOC(MV_PAR02)+"-"+_cRotina+"_001.TXT",_cLog)
	If _nVez >= 1
		MSGBOX("Foram eliminados " + cValToChar(_nVez) + " atendimentos sem pedidos de venda." + _lEnt + _cLog,_cRotina+"_002","INFO")
	Else
		MSGBOX("Não há atendimentos a serem eliminados.",_cRotina+"_003","INFO")
	EndIf
	RestArea(_aSavArea)
return
/*/{Protheus.doc} ValidPerg
@description Valida as perguntas no arquivo SX1.
@author Júlio Soares (ALL System Solutions)
@since 22/06/2015
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aAlias    := GetArea()
	local aRegs     := {}
	local _aTam      := {}
	local _x         := 0
	local _y         := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	_cPerg           := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam            := TamSx3("UA_EMISSAO")
	AADD(aRegs,{_cPerg,"01","De Emissão?" ,"","","mv_ch1",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	AADD(aRegs,{_cPerg,"02","Até Emissão?","","","mv_ch2",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	_aTam            := TamSx3("UA_NUM"    )
	AADD(aRegs,{_cPerg,"03","De Número?"  ,"","","mv_ch3",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SUA","","","",""})
	AADD(aRegs,{_cPerg,"04","Até Número?" ,"","","mv_ch4",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SUA","","","",""})
	_aTam            := TamSx3("UA_CLIENTE")
	AADD(aRegs,{_cPerg,"05","De Cliente?" ,"","","mv_ch5",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
	_aTam            := TamSx3("UA_LOJA"   )
	AADD(aRegs,{_cPerg,"06","De Loja?"    ,"","","mv_ch6",_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	_aTam            := TamSx3("UA_CLIENTE")
	AADD(aRegs,{_cPerg,"07","Até Cliente?","","","mv_ch7",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
	_aTam            := TamSx3("UA_LOJA"   )
	AADD(aRegs,{_cPerg,"08","Até Loja?"   ,"","","mv_ch8",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	for _x := 1 To Len(aRegs)
		if !(_cAliasSX1)->(dbSeek(_cPerg+aRegs[_x,2],.T.,.F.))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for _y := 1 to FCount()
					if _y <= len(aRegs[_x])
						FieldPut(_y,aRegs[_x,_y])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	RestArea(_aAlias)
return