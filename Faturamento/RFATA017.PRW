#INCLUDE "RWMAKE.CH"

#DEFINE _clrf CHR(13) + CHR(10)

/*/{Protheus.doc} RFATA017
@description Rotina utilizada dar um ALTERAR e OK nos pedidos de vendas, de forma que suas liberacoes caiam.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 27/01/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFATA017()
	Local _lInc      := IIF(Type("INCLUI" )<>"U",INCLUI,.F.)
	Local _lAlt      := IIF(Type("ALTERA" )<>"U",ALTERA,.F.)
	Local _aSavAr    := GetArea()
	Local _cFunName  := FunName()

	Private _cRotina := 'RFATA017'
	Private	cPerg	 := _cRotina
	//+-------------------------------------------------------------------------+
	//¦ Verifica as perguntas selecionadas.    								      ¦
	//+-------------------------------------------------------------------------+
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		return
	EndIf
	If MsgYesNo("Deseja estornar a liberacao de todos os pedidos de vendas, neste momento?",_cRotina+"_001")
		Processa({ |lEnd| IMPARQ(@lEnd) }, "["+_cRotina + "] Estorna liberacoes dos pedidos de venda.","Processando...",.T.)
		MsgInfo("Rotina concluida com sucesso.",_cRotina+"_003")
	Else
		MsgAlert("Rotina abortada!",_cRotina+"_004")
	EndIf
	INCLUI := _lInc
	ALTERA := _lAlt
	SetFunName(_cFunName)
	RestArea(_aSavAr)
return
/*/{Protheus.doc} IMPARQ (RFATA017)
@description Processamento da rotina...
@author Anderson C. P. Coelho (ALL System Solutions)
@since 27/01/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function IMPARQ(lEnd)
	Local   _aPv          := {}
	Local   _x            := 0
	Local   _cOK          := "Pedidos alterados."     + _clrf
	Local   _cErro        := "Pedidos não alterados." + _clrf
	Local   _cTRATMP      := GetNextAlias()

	Private lMsErroAuto   := .F.

	if Select(_cTRATMP) > 0
		(_cTRATMP)->(dbCloseArea())
	endif
	BeginSql Alias _cTRATMP
		SELECT SC5.R_E_C_N_O_ RECSC5, MIN(C9_ITEM) C6_ITEM
		FROM %table:SC9% SC9 (NOLOCK)
				INNER JOIN %table:SC5% SC5 (NOLOCK) ON SC5.C5_FILIAL = %xFilial:SC5% AND SC5.C5_NUM = SC9.C9_PEDIDO AND SC5.%NotDel%
		WHERE SC9.C9_FILIAL        = %xFilial:SC9%
		  AND SC9.C9_NFISCAL       = %Exp:''%
		  AND SC9.C9_PEDIDO  BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
		  AND SC9.C9_DATALIB BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
		  AND (CASE WHEN %Exp:MV_PAR05% = 2 OR C9_BLEST = '' THEN 1 ELSE 0 END) = 1
		  AND SC9.%NotDel%
		GROUP BY SC5.R_E_C_N_O_
		ORDER BY SC5.R_E_C_N_O_
	EndSql
	dbSelectArea(_cTRATMP)
	ProcRegua((_cTRATMP)->(RecCount()))
	(_cTRATMP)->(dbGoTop())
	If !(_cTRATMP)->(EOF()) .AND. !lEnd
		SetFunName("MATA410")
		While !(_cTRATMP)->(EOF()) .AND. !lEnd
			_nRecSC5 := (_cTRATMP)->RECSC5
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			SC5->(dbGoTo(_nRecSC5))
			IncProc("Processando Pedido '" + SC5->C5_NUM + "'...")
			_cPV     := SC5->C5_NUM
			_aItens  := {}
			_aCab    := {	{"C5_FILIAL"    ,SC5->C5_FILIAL ,Nil},;
							{"C5_NUM" 		,SC5->C5_NUM    ,Nil} }
			dbSelectArea(_cTRATMP)
		//	While !(_cTRATMP)->(EOF()) .AND. !lEnd .AND. _nRecSC5 == (_cTRATMP)->RECSC5
				If lEnd
					Exit
				EndIf
		//		If !Empty((_cTRATMP)->C6_ITEM)
		  			AADD(_aItens,{"LINPOS" , "C6_ITEM" ,(_cTRATMP)->C6_ITEM})
		//		EndIf
		//		dbSelectArea(_cTRATMP)
		//		(_cTRATMP)->(dbSkip())
		//	EndDo
			If Len(_aItens) > 0
				INCLUI      := .F.
				ALTERA      := .T.
				lMsErroAuto := .F.
				dbSelectArea("SC5")
				MSExecAuto({|x,y,z| mata410(x,y,z)},_aCab,{_aItens},4)
				If lMsErroAuto
		//			MostraErro()
					AADD(_aPv,{_cPV,.F.})
				Else
					AADD(_aPv,{_cPV,.T.})
				EndIf
			EndIf
			(_cTRATMP)->(dbSkip())
		EndDo
		for _x := 1 to len(_aPv)
			If _aPv[_x][02]
				_cOK   += _aPv[_x][01] + CHR(13) + CHR(10)
			Else
				_cErro += _aPv[_x][01] + CHR(13) + CHR(10)
			EndIf
		next
		if ExistDir("\2.MemoWrite\")
			MemoWrite("\2.MemoWrite\"+_cRotina+"_OK.csv"  ,_cOK  )
			MemoWrite("\2.MemoWrite\"+_cRotina+"_ERRO.csv",_cErro)
		endif
	EndIf
	if Select(_cTRATMP) > 0
		(_cTRATMP)->(dbCloseArea())
	endif
return
/*/{Protheus.doc} ValidPerg
@description Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 27/01/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _sArea     := GetArea()
	local aRegs      := {}
	local _aTam      := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg  := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam  := TamSx3("C5_EMISSAO")
	AADD(aRegs,{cPerg,"01","De Data?"               ,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""			,"mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""      ,"",""})
	AADD(aRegs,{cPerg,"02","Até Data?"              ,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""      ,"",""})
	_aTam  := TamSx3("C5_NUM"    )
	AADD(aRegs,{cPerg,"03","Do Pedido?"             ,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SC5"   ,"",""})
	AADD(aRegs,{cPerg,"04","Ao Pedido?"             ,"","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SC5"   ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"05","Somente PV s/bloqueio?" ,"","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"C","NaoVazio()","mv_par05","Sim"  ,"","","","","Nao"  ,"","","","",""     ,"","","","","","","","","","","","","",""      ,"",""})
	for i := 1 to len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_sArea)
return