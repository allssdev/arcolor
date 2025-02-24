#include "totvs.ch"
/*/{Protheus.doc} MT681AIN
@description Rotina responsável por fazer o ajuste de empenho automático das embalagens caso seja apontado perda na produção, uma vez que a quantidade apontada como perda, não deve consumir esse tipo de produto, lembrando há uma flag no apontamento da produção para inibir esse ajuste automático.
@author  Adriano Leonardo
@since   01/10/2013
@version P12.1.25 - 1.00
@see https://allss.com.br
@history 26/01/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação do fonte devido a rotina se comportar diferente na release 12.1.2210
@history 11/05/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Ajuste para posicionamento da ordem de produção no momento da validação das quantidades
@history 09/10/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Ajuste na rotina visando a implantação da rastreabilidade para MP/EM
@history 09/10/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Inclusão de melhoria para apontamentos do tipo ganho de produção, consumir de forma automatica as embalagens
/*/

User Function MT681AIN()
	Local	_cAliasSD4	:= GetNextAlias()
	local   _aSavArea := GetArea()
	local   _aSavSD4  := SD4->(GetArea())
	local   _aSavSB1  := SB1->(GetArea())
	local   _aSavSD3  := SD3->(GetArea())
    local   _aSavSH6  := SH6->(GetArea())
	local   _aSavSC2  := SC2->(GetArea())
	//local   _cTipo	:= ""
	local   _cRotina  := "MT681AIN"
	//Local   _aUsrPcp	:= SuperGetMv("MV_XUSRPCP" ,,"000000" )
	//Local	_cProd := ""
	//Local _cQtdGanho    := 0
	//Local _cQtdConsum   := 0

//Trecho para ajuste das embalagens quando houver apontamento de perda
		if Select(_cAliasSD4) > 0
			(_cAliasSD4)->(dbCloseArea())
		endif
		BEGINSQL ALIAS _cAliasSD4
			%noparser%
			SELECT D4_FILIAL,D4_OP,D4_COD,D4_QTDEORI,D4_QUANT,B1_TIPO,D4_AUTOAJU, D4_TRT, D4_LOTECTL
			FROM %table:SD4% D4 (NOLOCK)
			INNER JOIN SB1010 B1 ON B1_COD = D4_COD AND B1.%notDel%
			WHERE D4.%notDel%
			AND D4_OP = %exp:SH6->H6_OP%
			AND B1_TIPO = 'EM'
            AND D4_OPERAC = %exp:SH6->H6_OPERAC%
			ORDER BY B1_TIPO DESC
		ENDSQL


		if !Empty(SH6->H6_OP) .AND. !Empty(SH6->H6_PRODUTO) .AND. SH6->H6_QTDPERD > 0 .AND. Select(_cAliasSD4) > 0
			MsgAlert("Atenção, como foi apontado perda, será realizado um ajuste automático no empenho das embalagens!",_cRotina+"_001")
			dbSelectArea(_cAliasSD4)
			DbGoTop()
			while !(_cAliasSD4)->(EOF()).AND. (_cAliasSD4)->D4_FILIAL == xFilial("SD4") .AND. (_cAliasSD4)->D4_OP==SH6->H6_OP
				dbSelectArea("SD4")
				//Adequação para rastreabilidade, inserir indice que contenha lote.
				SD4->(dbSetOrder(1)) //D4_FILIAL+D4_COD+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE
				if SD4->(MsSeek(xFilial("SD4")+(_cAliasSD4)->D4_COD+(_cAliasSD4)->D4_OP+(_cAliasSD4)->D4_TRT+(_cAliasSD4)->D4_LOTECTL,.T.,.F.))
					//Valida caso o empenho esteja zerado, para não fazer nenhuma alteração
					If (_cAliasSD4)->D4_QUANT==0 
						//dbSelectArea("SD4")
						//SD4->(dbSetOrder(2))
						SD4->(dbSkip())
						(_cAliasSD4)->(dbSkip())
						loop
					endif

					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					if !SB1->(MsSeek(xFilial("SB1")+(_cAliasSD4)->D4_COD,.T.,.F.))
						MsgAlert("Houve uma falha no ajuste de empenhos. O item '" + AllTrim((_cAliasSD4)->D4_COD) + "' não foi localizado no cadastro de produtos!",_cRotina+"_003")
						SD4->(dbSkip())
						(_cAliasSD4)->(dbSkip())
						loop
					endif
	
						dbSelectArea("SC2")
						SC2->(dbSetOrder(1))
						if SC2->(MsSeek(xFilial("SC2")+SH6->H6_OP,.T.,.F.))
							_nAjuste  := If((SD4->D4_QTDEORI/SC2->C2_QUANT)*SH6->H6_QTDPERD > SD4->D4_QUANT,SD4->D4_QUANT,(SD4->D4_QTDEORI/SC2->C2_QUANT)*SH6->H6_QTDPERD)
							_nQtdAnte := SD4->D4_QTDEORI
							_nEmpAnte := SD4->D4_QUANT
							//Gravo o empenho original, para fins de histórico
							while !RecLock("SD4",.F.) ; enddo
							SD4->D4_EMPANTE    	:= _nEmpAnte
							SD4->D4_QTDANTE 	:= _nQtdAnte
							SD4->(MsUnlock())
							aVetor      := {}
							nOpc        := 4 // Alteração
							lMsErroAuto := .F.
							//Calculo a quantidade do empenho a ser considerado
							_nEmpenho   := SD4->D4_QTDEORI - _nAjuste //SD4->D4_QTDEORI - (SD4->D4_QTDEORI - _nAjuste)
							_nSldEmpe   := SD4->D4_QUANT - _nAjuste
							//Verifico se o ajuste automático já foi realizado, para eliminar a possibilidade de duplicidade
							if AllTrim(Upper(SD4->D4_AUTOAJU))<>"S"
								if _nSldEmpe == 0
									Reclock("SD4",.F.)
										SD4->D4_QUANT 	:= _nSldEmpe
										SD4->D4_AUTOAJU := "S"
									SD4->(MsUnlock())

									dbSelectArea("SB2")
									SB2->(dbSetOrder(1))
									if SB2->(MsSeek(xFilial("SB2")+(_cAliasSD4)->D4_COD,.T.,.F.))
										Reclock("SB2",.F.)
										//SB2->B2_QATU	:= SB2->B2_QATU+_nSldEmpe
										SB2->B2_QEMP  	:= SB2->B2_QEMP-_nAjuste
										SB2->(MsUnlock())
									EndIf

									dbSelectArea("SB8")
									SB8->(dbSetOrder(3))
									if SB8->(MsSeek(xFilial("SB8")+(_cAliasSD4)->D4_COD+"01"+(_cAliasSD4)->D4_LOTECTL,.T.,.F.))
										Reclock("SB8",.F.)
										//SB2->B2_QATU	:= SB2->B2_QATU+_nSldEmpe
										SB8->B8_EMPENHO  	:= SB8->B8_EMPENHO-_nAjuste
										SB8->(MsUnlock())
									EndIf
								else
									aVetor:=  {	{"D4_COD" 		,SD4->D4_COD		  		,Nil},;
												{"D4_LOCAL" 	,SD4->D4_LOCAL        		,Nil},;
												{"D4_OP" 		,SD4->D4_OP     	  		,Nil},;
												{"D4_DATA" 		,SD4->D4_DATA     	  		,Nil},;
												{"D4_QUANT" 	,_nSldEmpe					,Nil},;
												{"D4_QTDEORI"	,_nEmpenho				 	,Nil},;
												{"D4_LOTECTL"	,SD4->D4_LOTECTL		 	,Nil},;
												{"D4_QTSEGUM"	,SD4->D4_QTSEGUM      		,Nil},;
												{"D4_AUTOAJU"	,"S"		    	  		,Nil},;
												{"D4_TRT"		,SD4->D4_TRT    	  		,Nil},;
												{"ZERAEMP"      ,"N"                        ,Nil} }
									   
								endif
								//Verifica se há ajuste a ser feito
								lMsErroAuto := .F.
								if _nAjuste<>0 .and. _nSldEmpe <> 0
									Reclock("SD4",.F.)
									SD4->D4_AUTOAJU   	:= "S"
									SD4->(MsUnlock())
									//MATA380 - Ajuste de empenhos
									MSExecAuto({|x,y| mata380(x,y)},aVetor,nOpc) //Alteração
									
								endif
								if lMsErroAuto
									RecLock("SD4",.F.)
									SD4->D4_AUTOAJU := "F"
									SD4->(MSUNLOCK())
									MsgAlert("Houve uma falha no ajuste de empenhos, anote o erro que será apresentado a seguir e informe ao Administrador do sistema!",_cRotina+"_002")
									MostraErro()
								endif
							endif
						//endif
					endif
				dbSelectArea("SD4")
				SD4->(dbSetOrder(1))
				endif
			(_cAliasSD4)->(dbSkip())	
			enddo
		/* TRECHO COMENTADO PARA SER ATIVADO APÓS A IMPLANTAÇÃO DA RASTREABILIDADE
		ElseIf !Empty(SH6->H6_OP) .AND. !Empty(SH6->H6_PRODUTO) .AND. SH6->H6_PT == 'T' .AND. (SH6->H6_QTDPROD > SC2->C2_QUANT .OR. (SH6->H6_QTDPROD + SC2->C2_QUJE + SC2->C2_PERDA) > SC2->C2_QUANT) .AND. !Upper(AllTrim(__cUserId))$_aUsrPcp

			If (SC2->C2_QUJE == 0 .AND. SC2->C2_PERDA == 0)
				_cQtdGanho := SH6->H6_QTDPROD - SC2->C2_QUANT
			Else
				_cQtdGanho := (SH6->H6_QTDPROD+C2_QUJE+C2_PERDA) - SC2->C2_QUANT
			EndIf

			MsgAlert("Atenção, como foi apontado ganho de produção, será realizado um ajuste automático no empenho das embalagens!",_cRotina+"_001")
			dbSelectArea(_cAliasSD4)
			DbGoTop()
			while !(_cAliasSD4)->(EOF()).AND. (_cAliasSD4)->D4_FILIAL == xFilial("SD4") .AND. (_cAliasSD4)->D4_OP==SH6->H6_OP .and. _cQtdGanho > 0
				dbSelectArea("SD4")
				SD4->(dbSetOrder(1)) //D4_FILIAL+D4_COD+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE
				if SD4->(MsSeek(xFilial("SD4")+(_cAliasSD4)->D4_COD+(_cAliasSD4)->D4_OP+(_cAliasSD4)->D4_TRT+(_cAliasSD4)->D4_LOTECTL,.T.,.F.))
					//Valida caso o empenho esteja zerado, para não fazer nenhuma alteração
					If (_cAliasSD4)->D4_QUANT==0 
						SD4->(dbSkip())
						(_cAliasSD4)->(dbSkip())
						loop
					endif

					dbSelectArea("SB5")
					SB5->(dbSetOrder(1))
					if !SB5->(MsSeek(xFilial("SB5")+(_cAliasSD4)->D4_COD,.T.,.F.))
						MsgAlert("Houve uma falha no ajuste de empenhos. O item '" + AllTrim((_cAliasSD4)->D4_COD) + "' não foi localizado no complemento de produtos!",_cRotina+"_005")
						SD4->(dbSkip())
						(_cAliasSD4)->(dbSkip())
						loop
					ElseIf SB5->B5_XGNHOEM == "1"
						dbSelectArea("SC2")
						SC2->(dbSetOrder(1))
						if SC2->(MsSeek(xFilial("SC2")+SH6->H6_OP,.T.,.F.))
							_nAjuste  := (SD4->D4_QTDEORI/SC2->C2_QUANT)*_cQtdGanho
							_nQtdAnte := SD4->D4_QUANT
							_nEmpAnte := SD4->D4_QTDEORI
							//Gravo o empenho original, para fins de histórico
							while !RecLock("SD4",.F.) ; enddo
							SD4->D4_EMPANTE    	:= _nEmpAnte
							SD4->D4_QTDANTE 	:= _nQtdAnte
							SD4->(MsUnlock())
							aVetor      := {}
							nOpc        := 4 // Alteração
							lMsErroAuto := .F.
							//Calculo a quantidade do empenho a ser considerado
							_nEmpenho   := SD4->D4_QTDEORI + _nAjuste //SD4->D4_QTDEORI - (SD4->D4_QTDEORI - _nAjuste)
							_nSldEmpe   := SD4->D4_QUANT + _nAjuste
							//Verifico se o ajuste automático já foi realizado, para eliminar a possibilidade de duplicidade
							if AllTrim(Upper(SD4->D4_AUTOAJU))<>"S"
								if _nSldEmpe == 0
									Reclock("SD4",.F.)
										SD4->D4_QUANT 	:= _nSldEmpe
										SD4->D4_AUTOAJU := "S"
									SD4->(MsUnlock())

									dbSelectArea("SB2")
									SB2->(dbSetOrder(1))
									if SB2->(MsSeek(xFilial("SB2")+(_cAliasSD4)->D4_COD,.T.,.F.))
										Reclock("SB2",.F.)
										SB2->B2_QEMP  	:= SB2->B2_QEMP+_nAjuste
										SB2->(MsUnlock())
									EndIf
								else
									aVetor:=  {	{"D4_COD" 		,SD4->D4_COD		  		,Nil},;
												{"D4_LOCAL" 	,SD4->D4_LOCAL        		,Nil},;
												{"D4_OP" 		,SD4->D4_OP     	  		,Nil},;
												{"D4_DATA" 		,SD4->D4_DATA     	  		,Nil},;
												{"D4_QUANT" 	,_nSldEmpe					,Nil},;
												{"D4_QTDEORI"	,_nEmpenho				 	,Nil},;
												{"D4_LOTECTL"	,SD4->D4_LOTECTL		 	,Nil},;
												{"D4_QTSEGUM"	,SD4->D4_QTSEGUM      		,Nil},;
												{"D4_AUTOAJU"	,"S"		    	  		,Nil},;
												{"D4_TRT"		,SD4->D4_TRT    	  		,Nil},;
												{"ZERAEMP"      ,"N"                        ,Nil} }
									   
								endif
								//Verifica se há ajuste a ser feito
								lMsErroAuto := .F.
								if _nAjuste<>0 .and. _nSldEmpe <> 0
									Reclock("SD4",.F.)
									SD4->D4_AUTOAJU   	:= "S"
									SD4->(MsUnlock())
									//MATA380 - Ajuste de empenhos
									MSExecAuto({|x,y| mata380(x,y)},aVetor,nOpc) //Alteração
									
								endif
								if lMsErroAuto
									RecLock("SD4",.F.)
									SD4->D4_AUTOAJU := "F"
									SD4->(MSUNLOCK())
									MsgAlert("Houve uma falha no ajuste de empenhos, anote o erro que será apresentado a seguir e informe ao Administrador do sistema!",_cRotina+"_002")
									MostraErro()
								endif
							endif
						EndIf
					endif
				dbSelectArea("SD4")
				SD4->(dbSetOrder(1))
				endif
			(_cAliasSD4)->(dbSkip())	
			EndDo
		*/
		(_cAliasSD4)->(dbCloseArea())
		endif
	//endif

	
	RestArea(_aSavSC2)
	RestArea(_aSavSD3)
    RestArea(_aSavSH6)
	RestArea(_aSavSB1)
	RestArea(_aSavSD4)
	RestArea(_aSavArea)
Return Nil
