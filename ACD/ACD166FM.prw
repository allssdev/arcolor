#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#Include 'TOTVS.ch'
#Include 'topconn.ch'
/*/{Protheus.doc} ACD166FM
@description Localização: Está localizado na função FimProcesso com o Objetivo de finalizar o processo de separação (para itens separa).Finalidade: Este Ponto de Entrada permite executar rotinas complementares no momento de finalizar o processo de separação, se os itens forem separados.
@obs Só Entra nesse ponto de Entrada, quando eu realmente finalizo o Processo de Separação. Se existir produtos pendentes de separação, ele não entra nesse ponto!
@author Arthur Silva (ALL System Solutions)
@since 07/04/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
user function ACD166FM()
	Local _aArea      := GetArea()
	Local _aAreaCB7   := CB7->(GetArea())
	Private _cCb7Ped  := CB7->CB7_PEDIDO
	Private _cOrdSep  := CB7->CB7_ORDSEP
	Private _nGetVol  := 0
	Private _nTipDiv  := 0
	Private _nOpcFat  := 2
	Private _cEspec   := Padr("VOLUME(S)",TamSx3("C5_ESPECI1")[01])
	Private _cNomProg := FunName()
	Private _cNotaAux := ""
	Private _cCodCb7  := ""
	Private _cNomeCb7 := ""
	Private _dDtICb7  := ""
	Private _dDtFCb7  := ""
	Private _lOkVol	  := .T.
	Private _lOk	  := .T.
	Private _lSolicVol:= .F.

	Volume()

	RestArea(_aAreaCB7)
	RestArea(_aArea)
return
/*/{Protheus.doc} Volume
@description Apontamento de Quantidade de Volume na Separção.
@author Arthur Silva (ALL System Solutions)
@since 08/08/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function Volume()
	Local _cNomConf := "" // "OPER - " + CB1->CB1_NOME
	dbSelectArea("CB1")
	//CB1->(dbSetOrder(2))
	CB1->(dbOrderNickName("CB1_CODUSR"))
	If CB1->(MsSeek(xFilial("CB1") + __cUserId,.T.,.F.))
		_cCodConf := CB1->CB1_CODOPE
		_cNomConf := "OPER - " + CB1->CB1_NOME
	EndIf
	VtBeep(1)
	If VTYesNo("Confirma a geração da Nota Fiscal neste momento?","Aviso",.T.)
		While _lOkVol
			VTCLEAR()
			@ 0,00 VTSAY "Informe Quant. Volumes"
			@ 1,00 VTSAY "--------------------"
			@ 3,00 VTSAY "Volumes:" VTGET _nGetVol             Pict "99999"		VALID ValidVol(_nGetVol)
			VTREAD()
			If VTLastKey() == 27 .AND. _nGetVol == 0 .AND. _lOkVol
				VTAlert("Quantidade de Volumes não pode ser '0', Informe a Quantidade!","Aviso",.T.)
			EndIf
		EndDo
		//VTMSG(cMSG,nTipMen) cMSG:= Mensagem a ser apresentada na tela / nTipMen := (1 =Centro / 2=Rodape)
		VTMSG("Processando...",1)
		if ExistBlock("RFATA02F")
			U_RFATA02F(_nOpcFat,_cOrdSep,_cNomProg,_nGetVol,_cEspec,_cCb7Ped) //Faturamento do pedido
			// Grava a a data e hora da finalização do processo de Separação/Conferência
			dbSelectArea("CB7")
			//CB7->(dbSetOrder(1))
			CB7->(dbOrderNickName("CB7_ORDSEP"))
			if CB7->(MsSeek(xFilial("CB7") + _cOrdSep,.T.,.F.))
				_cCodCb7  := CB7->CB7_CODOPE
				_cNomeCb7 := CB7->CB7_NOMOP1
				_dDtICb7  := CB7->CB7_DTISEP
				_dDtFCb7  := CB7->CB7_DTFSEP
				if !empty(_dDtICb7) .AND. Empty(_dDtFCb7)
					while !RecLock("CB7",.F.) ; enddo
						CB7->CB7_DTFSEP := Date()
						CB7->CB7_HRFSOS := Time()
						//CB7->CB7_DTINIS := Date()
						//CB7->CB7_HRINIS := StrTran(Time(),":","")
						CB7->CB7_CODOP2 := _cCodConf
						CB7->CB7_NOMOP2 := _cNomConf
						CB7->CB7_DTFIN  := Date()
		//				CB7->CB7_HRFIN  := Left(Time(),5)
						CB7->CB7_HRFIMS := StrTran(Time(),":","")
					CB7->(MsUnLock())
				endif
			endif
		else
			VTALERT("PROBLEMA! Programa 'RFATA02F' não compilado. Informe o administrador!","Aviso",.T.)
		endif
	EndIf
return
/*/{Protheus.doc} ValidVol
@description Sub-Rotina de validação do Volume informado na conferência.
@author Arthur Silva (ALL System Solutions)
@since 08/08/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidVol(_nGetVol)
	Local _lRet	:= .F.		//!(VTYesNo("Confirma a quantidade digitada: ("+AllTrim(Transform(_nGetVol,"99999"))+") ?","Aviso",.T.))
	If _nGetVol == 0
		VTAlert("Quantidade de Volumes não pode ser '0', Informe a Quantidade!","Aviso",.T.)
		If VTLastKey() == 27 .AND. _nGetVol == 0
			VTAlert("Quantidade de Volumes não pode ser '0', Informe a Quantidade!","Aviso",.T.)
			_lOkVol := .T.
	    EndIf
	ElseIf VTYesNo("Confirma a quantidade digitada: ("+AllTrim(Transform(_nGetVol,"99999"))+") ?","Aviso",.T.)
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		If SC5->(MsSeek(xFilial("SC5") + _cCb7Ped,.T.,.F.))
			while !RecLock("SC5",.F.) ; enddo
				SC5->C5_VOLUME1  := _nGetVol
				If Empty(SC5->C5_ESPECI1)
					SC5->C5_ESPECI1 := _cEspec
				EndIf
			SC5->(MSUNLOCK())
			_lOkVol := .F.
			_lRet 	:= .T.
		EndIf
	EndIf
return _lRet
