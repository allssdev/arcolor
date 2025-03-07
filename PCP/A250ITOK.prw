#include "totvs.ch"
/*/{Protheus.doc} A250ITOK
@description Rotina respons�vel por fazer o ajuste de empenho autom�tico das embalagens caso seja apontado perda na produ��o, uma vez que a quantidade apontada como perda, n�o deve consumir esse tipo de produto, lembrando h� uma flag no apontamento da produ��o para inibir esse ajuste autom�tico.
@author  Adriano Leonardo
@since   01/10/2013
@version P12.1.25 - 1.00
@see https://allss.com.br
@history 26/01/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequa��o do fonte devido a rotina se comportar diferente na release 12.1.2210
@history 11/05/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Ajuste para posicionamento da ordem de produ��o no momento da valida��o das quantidades
@history 09/10/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Ajuste na rotina visando a implanta��o da rastreabilidade para MP/EM
@history 09/10/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Inclus�o de melhoria para apontamentos do tipo ganho de produ��o, consumir de forma automatica as embalagens
/*/
//ACD025GR
user function A250ITOK()
	Local	_cAliasSD4	:= GetNextAlias()
	local   _aSavArea := GetArea()
	local   _aSavSD4  := SD4->(GetArea())
	local   _aSavSB1  := SB1->(GetArea())
	local   _aSavSD3  := SD3->(GetArea())
	local   _aSavSC2  := SC2->(GetArea())
	//local   _cTipo	:= ""
	local   _cRotina  := "A250ITOK"
	//Local   _aUsrPcp	:= SuperGetMv("MV_XUSRPCP" ,,"000000" )
	//Local	_cProd := ""
	//Local _cQtdGanho    := 0
	//Local _cQtdConsum   := 0
	/*
	dbSelectArea("SC2") 
	SC2->(dbSetOrder(1))
	If SC2->(dbSeek(xFilial("SC2")+substr(M->D3_OP,1,11)))
		//Diego - 18/02/2020 Valida��o para n�o ter o apontamento maior que a ordem de produa��o pelos operadores
		If M->D3_QUANT > (SC2->C2_QUANT-(SC2->C2_QUJE+SC2->C2_PERDA)) .and. Upper(AllTrim(__cUserId)) $ _aUsrPcp
			MSGSTOP('O apontamento est� com quantidade maior que a quantidade da OP. Favor encaminhar esse apontamento ao Departamento do PCP','ATEN��O')
		EndIf
	Endif
	*/
	//Verifico se o usu�rio definiu que haver� ajuste autom�tico dos empenhos
	if AllTrim(Upper(M->D3_AJUSTA))=="S" //.And. AllTrim(__cUserId)=="000000"

		if Select(_cAliasSD4) > 0
			(_cAliasSD4)->(dbCloseArea())
		endif
		BEGINSQL ALIAS _cAliasSD4
			%noparser%

			SELECT D4_FILIAL,D4_OP,D4_COD,D4_QTDEORI,D4_QUANT,B1_TIPO,D4_AUTOAJU, D4_TRT, D4_LOTECTL
			FROM %table:SD4% D4 (NOLOCK)
			INNER JOIN SB1010 B1 ON B1_COD = D4_COD AND B1.%notDel%
			WHERE D4.%notDel%
			AND D4_OP = %exp:M->D3_OP%
			AND B1_TIPO = 'EM'
			ORDER BY B1_TIPO DESC

		ENDSQL


		if !Empty(M->D3_OP) .AND. !Empty(M->D3_COD) .AND. M->D3_PERDA > 0
			MsgAlert("Aten��o, como foi apontado perda, ser� realizado um ajuste autom�tico no empenho das embalagens!",_cRotina+"_001")
			dbSelectArea(_cAliasSD4)
			DbGoTop()
			while !(_cAliasSD4)->(EOF()).AND. (_cAliasSD4)->D4_FILIAL == xFilial("SD4") .AND. (_cAliasSD4)->D4_OP==M->D3_OP 
				dbSelectArea("SD4")
				//Adequa��o para rastreabilidade, inserir indice que contenha lote.
				//SD4->(dbSetOrder(2)) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL 
				//if SD4->(MsSeek(xFilial("SD4")+(_cAliasSD4)->D4_OP+(_cAliasSD4)->D4_COD,.T.,.F.))
				SD4->(dbSetOrder(1)) //D4_FILIAL+D4_COD+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE
				if SD4->(MsSeek(xFilial("SD4")+(_cAliasSD4)->D4_COD+(_cAliasSD4)->D4_OP+(_cAliasSD4)->D4_TRT+(_cAliasSD4)->D4_LOTECTL,.T.,.F.))
					//Valida caso o empenho esteja zerado, para n�o fazer nenhuma altera��o
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
					//	_cTipo := SB1->B1_TIPO
					//	_cProd := SB1->B1_COD
					//else
						MsgAlert("Houve uma falha no ajuste de empenhos. O item '" + AllTrim((_cAliasSD4)->D4_COD) + "' n�o foi localizado no cadastro de produtos!",_cRotina+"_003")
						//dbSelectArea("SD4")
						//->(dbSetOrder(2))
						SD4->(dbSkip())
						(_cAliasSD4)->(dbSkip())
						loop
					endif
	
					//Verifico se o tipo do produto � embalagem
					//if AllTrim(Upper(_cTipo))=="EM" 
						dbSelectArea("SC2")
						SC2->(dbSetOrder(1))
						if SC2->(MsSeek(xFilial("SC2")+M->D3_OP,.T.,.F.))
							/*
							If M->D3_PARCTOT == "T"
								_nAjuste  := (SD4->D4_QTDEORI/SC2->C2_QUANT)*((M->D3_QUANT-aSC2Sld())-M->D3_PERDA)
							EndIf
							*/
							//_nAjuste  := SD4->D4_QTDEORI/SC2->C2_QUANT)*M->D3_PERDA
							_nAjuste  := If((SD4->D4_QTDEORI/SC2->C2_QUANT)*M->D3_PERDA > SD4->D4_QUANT,SD4->D4_QUANT,(SD4->D4_QTDEORI/SC2->C2_QUANT)*M->D3_PERDA)
							_nQtdAnte := SD4->D4_QTDEORI
							_nEmpAnte := SD4->D4_QUANT
							//Gravo o empenho original, para fins de hist�rico
							while !RecLock("SD4",.F.) ; enddo
							SD4->D4_EMPANTE    	:= _nEmpAnte
							SD4->D4_QTDANTE 	:= _nQtdAnte
							SD4->(MsUnlock())
							aVetor      := {}
							nOpc        := 4 // Altera��o
							lMsErroAuto := .F.
							//Calculo a quantidade do empenho a ser considerado
							_nEmpenho   := SD4->D4_QTDEORI - _nAjuste //SD4->D4_QTDEORI - (SD4->D4_QTDEORI - _nAjuste)
							_nSldEmpe   := SD4->D4_QUANT - _nAjuste
							//Verifico se o ajuste autom�tico j� foi realizado, para eliminar a possibilidade de duplicidade
							if AllTrim(Upper(SD4->D4_AUTOAJU))<>"S"
								if _nSldEmpe == 0
									//TRECHO COMENTADO DEVIDO A MUDAN�A NO TRATAMENTO DO ZERAEMP, AT� A RELEASE 12.1.33 zerava somente o produto posicionado, 
									//a partir da migra��o zera todos os empenhos
									/*aVetor:=  {	{"D4_COD" 		,SD4->D4_COD		  		,Nil},;
												{"D4_LOCAL" 	,SD4->D4_LOCAL        		,Nil},;
												{"D4_OP" 		,SD4->D4_OP     	  		,Nil},;
												{"D4_DATA" 		,SD4->D4_DATA     	  		,Nil},;
												{"D4_QUANT" 	,SD4->D4_QUANT				,Nil},;
												{"D4_QTDEORI"	,SD4->D4_QTDEORI		 	,Nil},;
												{"D4_QTSEGUM"	,SD4->D4_QTSEGUM      		,Nil},;
												{"D4_AUTOAJU"	,"S"		    	  		,Nil},;
												{"D4_TRT"		,SD4->D4_TRT    	  		,Nil},;
												{"ZERAEMP"      ,"S"                        ,Nil} }
									*/
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
								//Verifica se h� ajuste a ser feito
								lMsErroAuto := .F.
								if _nAjuste<>0 .and. _nSldEmpe <> 0
									Reclock("SD4",.F.)
									SD4->D4_AUTOAJU   	:= "S"
									SD4->(MsUnlock())
									//MATA380 - Ajuste de empenhos
									MSExecAuto({|x,y| mata380(x,y)},aVetor,nOpc) //Altera��o
									
								endif
								if lMsErroAuto
									RecLock("SD4",.F.)
									SD4->D4_AUTOAJU := "F"
									SD4->(MSUNLOCK())
									MsgAlert("Houve uma falha no ajuste de empenhos, anote o erro que ser� apresentado a seguir e informe ao Administrador do sistema!",_cRotina+"_002")
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
		/* TRECHO COMENTADO PARA SER ATIVADO AP�S A IMPLANTA��O DA RASTREABILIDADE
		ElseIf !Empty(M->D3_OP) .AND. !Empty(M->D3_COD) .AND. M->D3_PARCTOT == 'T' .AND. (M->D3_QUANT > SC2->C2_QUANT .OR. (M->D3_QUANT + SC2->C2_QUJE + SC2->C2_PERDA) > SC2->C2_QUANT) .AND. !Upper(AllTrim(__cUserId))$_aUsrPcp

			If (SC2->C2_QUJE == 0 .AND. SC2->C2_PERDA == 0)
				_cQtdGanho := M->D3_QUANT - SC2->C2_QUANT
			Else
				_cQtdGanho := (M->D3_QUANT+C2_QUJE+C2_PERDA) - SC2->C2_QUANT
			EndIf

			MsgAlert("Aten��o, como foi apontado ganho de produ��o, ser� realizado um ajuste autom�tico no empenho das embalagens!",_cRotina+"_001")
			dbSelectArea(_cAliasSD4)
			DbGoTop()
			while !(_cAliasSD4)->(EOF()).AND. (_cAliasSD4)->D4_FILIAL == xFilial("SD4") .AND. (_cAliasSD4)->D4_OP==M->D3_OP .and. _cQtdGanho > 0
				dbSelectArea("SD4")
				SD4->(dbSetOrder(1)) //D4_FILIAL+D4_COD+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE
				if SD4->(MsSeek(xFilial("SD4")+(_cAliasSD4)->D4_COD+(_cAliasSD4)->D4_OP+(_cAliasSD4)->D4_TRT+(_cAliasSD4)->D4_LOTECTL,.T.,.F.))
					//Valida caso o empenho esteja zerado, para n�o fazer nenhuma altera��o
					If (_cAliasSD4)->D4_QUANT==0 
						SD4->(dbSkip())
						(_cAliasSD4)->(dbSkip())
						loop
					endif

					dbSelectArea("SB5")
					SB5->(dbSetOrder(1))
					if !SB5->(MsSeek(xFilial("SB5")+(_cAliasSD4)->D4_COD,.T.,.F.))
						MsgAlert("Houve uma falha no ajuste de empenhos. O item '" + AllTrim((_cAliasSD4)->D4_COD) + "' n�o foi localizado no complemento de produtos!",_cRotina+"_005")
						SD4->(dbSkip())
						(_cAliasSD4)->(dbSkip())
						loop
					ElseIf SB5->B5_XGNHOEM == "1"
						dbSelectArea("SC2")
						SC2->(dbSetOrder(1))
						if SC2->(MsSeek(xFilial("SC2")+M->D3_OP,.T.,.F.))
							_nAjuste  := (SD4->D4_QTDEORI/SC2->C2_QUANT)*_cQtdGanho
							_nQtdAnte := SD4->D4_QUANT
							_nEmpAnte := SD4->D4_QTDEORI
							//Gravo o empenho original, para fins de hist�rico
							while !RecLock("SD4",.F.) ; enddo
							SD4->D4_EMPANTE    	:= _nEmpAnte
							SD4->D4_QTDANTE 	:= _nQtdAnte
							SD4->(MsUnlock())
							aVetor      := {}
							nOpc        := 4 // Altera��o
							lMsErroAuto := .F.
							//Calculo a quantidade do empenho a ser considerado
							_nEmpenho   := SD4->D4_QTDEORI + _nAjuste //SD4->D4_QTDEORI - (SD4->D4_QTDEORI - _nAjuste)
							_nSldEmpe   := SD4->D4_QUANT + _nAjuste
							//Verifico se o ajuste autom�tico j� foi realizado, para eliminar a possibilidade de duplicidade
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
								//Verifica se h� ajuste a ser feito
								lMsErroAuto := .F.
								if _nAjuste<>0 .and. _nSldEmpe <> 0
									Reclock("SD4",.F.)
									SD4->D4_AUTOAJU   	:= "S"
									SD4->(MsUnlock())
									//MATA380 - Ajuste de empenhos
									MSExecAuto({|x,y| mata380(x,y)},aVetor,nOpc) //Altera��o
									
								endif
								if lMsErroAuto
									RecLock("SD4",.F.)
									SD4->D4_AUTOAJU := "F"
									SD4->(MSUNLOCK())
									MsgAlert("Houve uma falha no ajuste de empenhos, anote o erro que ser� apresentado a seguir e informe ao Administrador do sistema!",_cRotina+"_002")
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
	endif

	
	RestArea(_aSavSC2)
	RestArea(_aSavSD3)
	RestArea(_aSavSB1)
	RestArea(_aSavSD4)
	RestArea(_aSavArea)
return
