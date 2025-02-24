#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} RFATA018
@description Rotina e eliminacao de residuo.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 04/12/2014
@version 1.0
@type function
@history 27/08/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Ajustes anteriores não haviam sido aqui documentados. Nesta oportunidade, promovemos melhorias e correções gerais de funcionalidade e apresentação.
@see https://allss.com.br
/*/
user function RFATA018()
	local aArea       := GetArea()
	Local i         := 0

	private cCadastro := "Eliminação de Resíduo dos Pedidos de Vendas"
	private _cRotina  := "RFATA018"
	private cPerg     := _cRotina
	private _cPar     := ""
	private _cEnt     := CHR(13)+CHR(10)
	
	private aRegs     := {}

	If MsgYesNo("Deseja Eliminar o resíduo dos pedidos de vendas neste momento?"+ _cEnt +"ATENÇÃO! este processo É IRREVERSÍVEL. Deseja Continuar?",_cRotina+"_001")
		ValidPerg()
		If Pergunte(cPerg,.T.)
			for i := 1 to len(aRegs)
				If !Empty(_cPar)
					_cPar += "+"
				EndIf
				_cPar += "'Parâmetro " + cValToChar(i) + ": " + aRegs[i][3] + "  =  ' + "
				if aRegs[i][11] == "C"
					_cPar += "'"+aRegs[i][14+(&(aRegs[i][13])*5)-5]+"' + _cEnt"
				else
					if aRegs[i][7] == "D"
						_cPar += "AllTrim(DTOC("+aRegs[i][13]+")) + _cEnt"
					elseif aRegs[i][7] == "N"
						_cPar += "AllTrim(Str(" +aRegs[i][13]+")) + _cEnt"
					else
						_cPar += "AllTrim("     +aRegs[i][13]+")  + _cEnt"
					endif
				endif
			next
			_cPar := &_cPar
			If MsgYesNo("Confirma os parâmetros abaixo?"+ _cEnt +_cPar,_cRotina+"_002")
				Processa( {|lEnd| ProcElRes(@lEnd)}, "["+_cRotina+"] "+cCadastro, "Eliminando resíduos conforme parâmetros...",.T.)
			Else
				MsgStop("Atenção! Processo abortado pelo usuário",_cRotina+"_003")
			EndIf
		Else
			MsgStop("Atenção! Processo abortado pelo usuário",_cRotina+"_004")
		EndIf
	Else
		MsgStop("Atenção! Processo abortado pelo usuário",_cRotina+"_005")
	EndIf
	RestArea(aArea)
return
/*/{Protheus.doc} ProcElRes (RFATA018)
@description Processamento da rotina...
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 04/12/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ProcElRes(lEnd)
	local lValido    := .F.
	local cAlias     := "SC5"
	local _cSC5TMP   := GetNextAlias()
	local _cQry      := ""
	local _cFunNBkp  := FunName()
	Local _lEnt     := CHR(13)+CHR(10)

	_cQry := " SELECT DISTINCT SC5.R_E_C_N_O_ RECSC5 " + _cEnt
	_cQry += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) " + _cEnt
	_cQry += " 	INNER JOIN " + RetSqlName("SC6") + " SC6 (NOLOCK) ON SC6.D_E_L_E_T_ = '' " + _cEnt
	_cQry += "                                          AND SC6.C6_FILIAL        = '" + xFilial("SC6") + "' " + _cEnt
	_cQry += "                                          AND SC6.C6_BLQ          <> 'R' " + _cEnt
	_cQry += "                                          AND (SC6.C6_QTDVEN-SC6.C6_QTDENT) <> 0 " + _cEnt
	_cQry += "                                          AND SC6.C6_NUM           = SC5.C5_NUM "  + _cEnt
	_cQry += " WHERE SC5.D_E_L_E_T_       = '' " + _cEnt
	_cQry += "   AND SC5.C5_FILIAL        = '" + xFilial("SC5") + "' " + _cEnt
	//_cQry += "   AND (SC5.C5_NOTA         = '' OR SC5.C5_BLQ = '1') " + _cEnt
	_cQry += "   AND SC5.C5_NUM     BETWEEN '" + MV_PAR01        + "' AND '" + MV_PAR02       + "' " + _cEnt
	_cQry += "   AND SC5.C5_EMISSAO BETWEEN '" + DTOS(MV_PAR03)  + "' AND '" + DTOS(MV_PAR04) + "' " + _cEnt
	_cQry += "   AND SC5.C5_VEND1   BETWEEN '" + MV_PAR05        + "' AND '" + MV_PAR06       + "' " + _cEnt
	_cQry += "   AND SC5.C5_TPOPER  BETWEEN '" + MV_PAR07        + "' AND '" + MV_PAR08       + "' " + _cEnt
	If MV_PAR10 == 1
		_cQry += "   AND SC5.C5_CARGA  <> '' " + _cEnt //Nao pode ser eliminado residuo de pedido sem carga.
	Endif
	If MV_PAR09 <> 3
		_cQry += "   AND (SELECT SUM(C6_QTDENT) "  + _cEnt
		_cQry += "        FROM " + RetSqlName("SC6") + " SC6ENT (NOLOCK) "  + _cEnt
		_cQry += "        WHERE SC6ENT.D_E_L_E_T_ = '' "  + _cEnt
		_cQry += "          AND SC6ENT.C6_FILIAL  = '" + xFilial("SC6") + "' "  + _cEnt
		_cQry += "          AND SC6ENT.C6_NUM     = SC5.C5_NUM "  + _cEnt
		If MV_PAR09 == 2
			_cQry += "   ) = 0 " + _cEnt
		Else
			_cQry += "   ) > 0 " + _cEnt
		EndIf
	EndIf
	_cQry += " ORDER BY SC5.R_E_C_N_O_ "
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",_cQry)
	_cQry := ChangeQuery(_cQry)
	if Select(_cSC5TMP) > 0
		(_cSC5TMP)->(dbCloseArea())
	endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cSC5TMP,.T.,.F.)
	dbSelectArea(_cSC5TMP)
	ProcRegua((_cSC5TMP)->(RecCount()))
	(_cSC5TMP)->(dbGoTop())
	If !(_cSC5TMP)->(EOF()) .AND. !lEnd
		SetFunName("MATA410")
		_lEECFAT := SuperGetMv("MV_EECFAT")
		While !(_cSC5TMP)->(EOF()) .AND. !lEnd
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			SC5->(dbGoTo((_cSC5TMP)->RECSC5))
			If !SC5->(EOF()) .AND. !lEnd
				IncProc("Processando pedido " + AllTrim(SC5->C5_NUM) + "...")
				MaAvalSC5("SC5",4)
				MaAvalSC5("SC5",9)
				If SoftLock(cAlias)
					Begin Transaction
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Eliminacao de residuo                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lValido  := .T.
						If lValido .AND. !Empty(SC5->C5_PEDEXP) .AND. _lEECFAT // Integracao SIGAEEC
							If FindFunction("EECZERASALDO")
								lValido := EECZeraSaldo(,SC5->C5_PEDEXP,,.T.,SC5->C5_NUM)
							Else
								lValido := EECCancelPed(,SC5->C5_PEDEXP,,.T.,SC5->C5_NUM)
							EndIf
						EndIf
						If lValido
							DbSelectArea("SC9")
							SC9->(DbSetOrder(1))
							SC9->(MsSeek(xFilial("SC5") + SC5->C5_NUM, .T., .F.))
							While SC9->(!Eof()) .AND. SC9->C9_FILIAL == xFilial("SC5") .AND. SC9->C9_PEDIDO == SC5->C5_NUM .AND. Empty(SC9->C9_NFISCAL)
					    		SC9->(A460Estorna(.T.,.T.))
					    		SC9->(DbSkip())
					    	EndDo
							dbSelectArea("SC6")
							SC6->(dbSetOrder(1))
							SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
							While !SC6->(EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == SC5->C5_NUM
						    	If (SC6->C6_QTDVEN - SC6->C6_QTDENT) <> 0
					    		    MaResDoFat(,.T.,.F.)
					    		EndIf
								dbSelectArea("SC6")
								SC6->(dbSetOrder(1))
								SC6->(dbSkip())
							EndDo
							SC6->(MaLiberOk({SC5->C5_NUM},.T.))
						EndIf
					End Transaction
				EndIf
			Else
				IncProc()
			EndIf
			// Inclusão de Log nos pedidos após eliminação de residuo - Diego Rodrigues 15/02/2024
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				SC5->(MsSeek(xFilial("SC5") + SC5->C5_NUM,.T.,.F.))

					_cLogx := "Pedido Eliminado por Saldos"
					SUA->(dbOrderNickName("UA_NUMSC5"))
					If SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
						_cLog  := Alltrim(SUA->UA_LOGSTAT)
						If SUA->(FieldPos("UA_LOGSTAT"))>0
							RecLock("SUA", .F.)
								SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
								UsrRetName(__cUserId) + _lEnt + _cLogx
							SUA->(MsUnLock())
						EndIf
					EndIf
					dbSelectArea("SC5")
					SC5->(dbSetOrder(1))
					If SC5->(MsSeek(xFilial("SC5") +SC5->C5_NUM,.T.,.F.))
						_cLog := Alltrim(SC5->C5_LOGSTAT)
						If SC5->(FieldPos("C5_LOGSTAT"))>0
							RecLock("SC5",.F.)
								SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
								UsrRetName(__cUserId) + _lEnt + _cLogx
							SC5->(MsUnLock())
						EndIf
					EndIf
				// Customizações do cliente
				//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
				If ExistBlock("RFATL001")
					U_RFATL001(	SC5->C5_NUM,;
								SUA->UA_NUM,;
								_cLogx     ,;
								_cRotina    )
				EndIf
			//Fim do Log
			(_cSC5TMP)->(dbSkip())
		EndDo
		if Select(_cSC5TMP) > 0
			(_cSC5TMP)->(dbCloseArea())
		endif
		SetFunName(_cFunNBkp)
	Else
		MsgInfo("Nada a processar!",_cRotina+"_005")
	EndIf
return
/*/{Protheus.doc} ValidPerg
@description Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 04/02/2014
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _sArea     := GetArea()
	local _aTam      := {}
	local j          := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	Local i     := 0
	aRegs := {}
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam := TamSx3("C5_NUM"    )
	AADD(aRegs,{cPerg,"01","Do Pedido de Vendas   ?"      ,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR01",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","","SC5","",""})
	AADD(aRegs,{cPerg,"02","Ao Pedido de Vendas   ?"      ,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR02",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","","SC5","",""})
	_aTam := TamSx3("C5_EMISSAO")
	AADD(aRegs,{cPerg,"03","Da Emissão            ?"      ,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR03",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	AADD(aRegs,{cPerg,"04","Até a Emissão         ?"      ,"","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR04",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	_aTam := TamSx3("C5_VEND1"  )

	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	AADD(aRegs,{cPerg,"05","Do Representante 1         ?"      ,"","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR05",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
	AADD(aRegs,{cPerg,"06","Ao Representante 1         ?"      ,"","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR06",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})

	//AADD(aRegs,{cPerg,"05","Do Vendedor 1         ?"      ,"","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR05",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
	//AADD(aRegs,{cPerg,"06","Ao Vendedor 1         ?"      ,"","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR06",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","","SA3","",""})
	// Fim - Fernando Bombardi - ALLSS - 02/03/2022

	_aTam := TamSx3("C5_TPOPER" )
	AADD(aRegs,{cPerg,"07","Da Operação           ?"      ,"","","mv_ch7",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"MV_PAR07",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","","DJ" ,"",""})
	AADD(aRegs,{cPerg,"08","Até a Operação        ?"      ,"","","mv_ch8",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","MV_PAR08",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","","DJ" ,"",""})
	_aTam := {01,00,"N"}
	AADD(aRegs,{cPerg,"09","Considerar Somente    ?"      ,"","","mv_ch9",_aTam[03],_aTam[01],_aTam[02],0,"C","NAOVAZIO()","MV_PAR09","Saldos"        ,"","","","","Pendentes"   ,"","","","","Ambos","","","","","","","","","","","","","",""   ,"",""})
	_aTam := {01,00,"N"}
	AADD(aRegs,{cPerg,"10","Somente Ped. c/Carga Montada?","","","mv_cha",_aTam[03],_aTam[01],_aTam[02],0,"C","NAOVAZIO()","MV_PAR10","Sim"           ,"","","","","Não"         ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
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
