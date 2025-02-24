#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RWMAKE.CH'
/*/{Protheus.doc} RESTE004
@description Rotina respons�vel por replicar o consumo do m�s corrente da tabela SB3 (Demandas) para a tabela espec�fica SZG (Hist�rico do consumo mensal).
@obs Aten��o: O ser� considerado o m�s da data base do sistema.
@author Adriano Leonardo
@since 12/12/2013
@version 1.0
@type function
@history 22/04/2015, Anderson C. P. Coelho (ALL System Solutions), Inserido par�metros de M�s/Ano para que o usu�rio possa selecionar o per�odo desejado p/ o rec�lculo, sem depend�ncia da database do sistema.
@history 08/10/2019, Anderson C. P. Coelho (ALL System Solutions), Corre��o de pontos relacionados a grava��o da data do consumo na tabela SZG
@see https://allss.com.br
/*/
User Function RESTE004()
	//Salvo a �rea de trabalho atual
	Local _aSavArea  := GetArea()
	Local _aSavSZG   := SZG->(GetArea())
	Private _dSvDataB  := dDataBase
	Private _cRotina := "RESTE004"
	Private cPerg    := _cRotina
	Private _cAnoMes := ""
	Private _cCampo  := ""							 //Campo a ser utilizado como macro
	Private _nMes    := Month(dDataBase)
	Private _nAno    := Year(dDataBase)

	//ValidPerg()
	If !Pergunte(cPerg,.T.)
		MsgStop("Processamento abortado pelo usu�rio!",_cRotina+"_005")
		Return
	ElseIf Empty(MV_PAR01) .OR. Empty(MV_PAR02)
		MsgStop("Par�metros preenchidos incorretamente. Processamento abortado!",_cRotina+"_006")
		Return
	EndIf
	_nMes     := MV_PAR01
	_nAno     := MV_PAR02
	_cAnoMes  := StrZero(_nAno,4)+StrZero(_nMes,2) //SUBSTR(DtoS(dDataBase),1,6)
	dDataBase := LastDay(STOD(_cAnoMes+"01"))
	_cCampo   := "B3_Q" + StrZero(_nMes,2)			//STRZERO(MONTH(DDATABASE),2) //Campo a ser utilizado como macro
	If !MsgYesNo("Esta rotina ir� replicar o consumo mensal atual calculado dos produtos da SB3 (Demandas) para SZG (Hist�rico de consumo), � recomendado que voc� fa�a o rec�lculo de lote econ�mico antes de executar esta rotina, deseja continuar?",_cRotina+"_001")
		Return()
	EndIf
	//Garanto que o rec�lculo n�o ser� feito com database retroativa superior a 11 meses
	//If (AllTrim(cValToChar(Year(dDataBase)+1)) + StrZero(Month(dDataBase),2)) <= (AllTrim(cValToChar(Year(Date()) )) + StrZero(Month(Date()),2))
	//	MsgAlert("Aten��o, n�o � poss�vel fazer esse rec�lculo com database retroativa superior a 11 meses, caso seja necess�rio alterar algum valor fora desse intervalo, informe ao Admiministrador do sistema!",_cRotina+"_004")
	If (StrZero(_nAno+1,4)+StrZero(_nMes,2)) <= (AllTrim(cValToChar(Year(Date()))) + StrZero(Month(Date()),2))
		MsgAlert("Aten��o, n�o � poss�vel fazer esse rec�lculo com data retroativa superior a 11 meses. Caso seja necess�rio alterar algum valor fora desse intervalo, informe ao Admiministrador do sistema!",_cRotina+"_004")
		/*
			Aten��o, na tabela de demandas (SB3) o sistema s� mant�m informa��es dos �ltimos 12 meses, por esse motivo n�o � poss�vel extrair
			informa��es superior a 11 meses, nesse caso, se for de extrema necessidade altere diretamente na tabela SZG (Consumo mensal hist�rico),
			ciente das quest�es de integridade das informa��es.
		*/
		Return()
	EndIf

	//Chamo o rec�lculo padr�o do Lote Economico
	SetFunName("MATA290")
	//MATA290()
	MsgRun("Aguarde... Calculando consumo Mensal...","["+_cRotina+"_001] Rec�lculo Consumo",{|| MS290()})
	SetFunName(_cRotina)

	MsgRun("Aguarde... Armazenando os hist�rico dos consumos...","["+_cRotina+"_002] Rec�lculo Consumo",{|| RepliCons()})

	//Retauro a data anteriormente preservada
	dDataBase := _dSvDataB

	RestArea(_aSavSZG)
	RestArea(_aSavArea)
Return()
/*/{Protheus.doc} RepliCons
@description Processamento...
@author Adriano Leonardo
@since 12/12/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
Static Function RepliCons()
	TCRefresh("SZG")
	_cQry	 := " SELECT B3_COD, " + _cCampo + " AS [B3_QUANT] "
	_cQry	 += " FROM " + RetSqlName("SB3") + " WITH (NOLOCK) "
	_cQry	 += " WHERE D_E_L_E_T_ = '' "
	_cQry	 += "   AND B3_FILIAL  = '" + xFilial("SB3") + "' "
//	_cQry	 += "   AND "+_cCampo + " <> 0 "  
	_cAlias	 := getNextAlias()
	if Select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	endif
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.F.)
	dbSelectArea(_cAlias)
	//AVALIAR A PERFORMANCE DESTE TRECHO, POSTERIORMENTE E PROMOVER MUDAN�AS
	if ExistBlock("RESTE009")
		while !(_cAlias)->(EOF())
			U_RESTE009((_cAlias)->B3_COD , (_cAlias)->B3_QUANT, _cRotina, dDataBase,_cAnoMes)
			dbSelectArea(_cAlias)
			(_cAlias)->(dbSkip())
		enddo
		if Select(_cAlias) > 0
			(_cAlias)->(dbCloseArea())
		endif
		MsgInfo("Rotina executada com sucesso!",_cRotina+"_003")
	else
		MsgAlert("Aten��o! Rotina ('RESTE009') de grava��o dos hist�ricos n�o encontrada!",_cRotina+"_007")
	endif
Return()
/*/{Protheus.doc} MS290
@description Execauto da rotina MATA290. Consumo Mes a Mes / Lote Economico.
@author Renan Santos
@since 19/07/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
Static function MS290()
	Local aOpt      := {}
	Local lBat      := .T.
	Local nCalculo := 1     			// C�lculo por Peso ou Tend�ncia
	Local nIncre    := 0    			// Incremento para c�lculo por Peso
	Local nMeses    := 0    			// Meses para c�lculo por Tend�ncia
	PRIVATE lMsErroAuto := .F.
	aadd(aOpt,{"x",,})                	//[1] Atualiza o Consumo do M�s?
	If nCalculo = 1         
	    aadd(aOpt,{"x",nIncre,})  		//[2] Tipo de C�lculo: Peso
	    aadd(aOpt,{" ",0,})           	//[3] Tipo de C�lculo: Peso
	Else
	    aadd(aOpt,{" ",0,})           	//[2] Tipo de C�lculo: Tend�ncia
	    aadd(aOpt,{"x",nMeses,})  		//[3] Tipo de C�lculo: Tend�ncia
	EndIf
	aadd(aOpt,{" "," ",})           	//[4] Calcula Lote Econ�mico?
	aadd(aOpt,{" ",0,})               	//[5] Disponibilidade Financeira
	aadd(aOpt,{1,1,1})              	//[6] Per�odos de Aquisi��o (meses)
	aadd(aOpt,{30,30,40})           	//[7] Distribui��o Percentual (%)
	aadd(aOpt,{"**",,})               	//[8] Tipos de Produto a Processar, "**" processa todos.
	aadd(aOpt,{"**",,})               	//[9] Grupos de Produtos a Processar, "**" processa todos.
	aadd(aOpt,{.F.,,})              	//[10] Ativa ou n�o sele��o de Filiais, se n�o ativar, processa somente filial atual
	aadd(aOpt,{" ",0,.F.})            	//[11] Processa o calculo do estoque de seguran�a
	MSExecAuto({|x,y| MATA290(x,y)},lBat,aOpt)
	If lMsErroAuto
		Mostraerro()
	EndIF
Return
/*/{Protheus.doc} ValidPerg
@description Valida se as perguntas j� existem no arquivo SX1 e caso n�o encontre as cria no arquivo.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 06/02/2015
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
	_aTam := {02,00,"N"}
	AADD(aRegs,{cPerg,"01","M�s para c�lculo      ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par01",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	_aTam := {04,00,"N"}
	AADD(aRegs,{cPerg,"02","Ano para c�lculo      ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par02",""              ,"","","","",""            ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	for _x := 1 To Len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[_x,2],.T.,.F.))
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
