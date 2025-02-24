#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} ufDatFer
@description Função de usuário chamada na validação padrão dos campos RH_DATAINI, RH_DIALRE1 e RH_DIALREM, para realizar a regra da licenþa remunerada de acordo com o tipo de férias que está sendo calculado. Conforme a regra levantada nessa data (05/11/2019) com a colaboradora Dominique, se for férias coletivas, aplica a regra da licença remunerada. Se for férias normais, não aplica a regra da licenþa remunerada.
@obs Observar que alteramos a chamada das validações padrão dos referidos campos: RH_DATAINI, RH_DIALRE1 e RH_DIALREM. Logo, em atualizações posteriores, necessitará de revisão de tal ponto até que a funcionalidade seja implementada pelo padrão do Protheus.
@author Rodrigo Telecio (ALLSS - rodrigo.telecio@allss.com.br)
@since 05/11/2019
@version 1.00 (P12.1.25)
@type function
@return .T., lógico, sempre ".T."
@history 05/11/2019, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Disponibilização da rotina para uso.
@history 21/11/2019, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Aplicação de ajustes funcionais.
@see https://allss.com.br
/*/
user function ufDatFer()
	Local aArea		 := GetArea()
	Local aPerAberto := {}
	Local cTipoDia 	 := "2"
	Local cCampo	 := ReadVar()
	Local cRotFOL	 := fGetRotOrdinar() //carrega roteiro da FOLHA
	Local cRotFER	 := fGetCalcRot('3') //carrega roteiro de FERIAS
	Local DATAINI	 := CtoD("")
	Local DATAFIM	 := CtoD("")
	Local DTAVISOF	 := CtoD("")
	Local DTRECIBO	 := CtoD("")
	Local dDtRetAf 	 := CtoD("")
	Local dDataIni 	 := CtoD("")
	Local dDatafim 	 := CtoD("")
	Local lHabiles	 := .T.
	Local lSabNUtil  := .F.
	Local lParSab    := .F.
	Local nDMes12  	 := nDMes01 := 0
	Local nDLicQ1  	 := nDLicQ2 := 0
	Local nRCMOrder  := 0
	Local nAvisFer	 := GetNewPar("MV_AVISFER",0)
	Local oModel	 := FwModelActive()
	Local nBkpFalt	 := 0
	Local lJaDescFal := Type("nDescFal") <> "U" .And. nDescFal > 0
	Local aPerFERBkp := AClone(aPerFerias)
	Local nPosFerBkp := 0
	Local lPerQuit   := .F.
	//INICIO - 05/11/2019 - VARI-VEIS CRIADAS DESDE A IMPLEMENTAÇÃO DESSA ROTINA PARA CORRETO FUNCIONAMENTO
	Local cFerColet	 := If(Empty(M->RH_XCOLET), "N", M->RH_XCOLET)
	Local cAboAnt	 := If(GetMvRH("MV_ABOPEC") == "S", "1", "2")
	Local cDia2501	 := GetMvRH("MV_DIA2501")
	Local nDiasAux   := aTabFer[3]
	Local cPerFeAc	 := ""
	Local nBkpDFer	 := aTabFer[3]
	Local nDiasProg	 := 0
	Local nDAntPer	 := 0
	//FIM - 05/11/2019 - VARI-VEIS CRIADAS DESDE A IMPLEMENTAÇÃO DESSA ROTINA PARA CORRETO FUNCIONAMENTO
	Private cCpo	 := ""
	//--Verifica se nao tem Afastamento no Inicio das Ferias
	fChkAfas(SRA->RA_FILIAL,SRA->RA_MAT,M->RH_DATAINI,@dDataIni,@dDtRetAf)
	If dDtRetAf >= M->RH_DATAINI
		Help(,, "TOTVS - " + AllTrim(FunName()),, "Na data informada existe afastamento com término em " + DtoC(dDtRetAf) + ".", 1, 0)
		Return .F.
	EndIf
	//--Verifica se o Afastamento possui data final
	If !empty(dDataIni) .and. empty(dDtRetAf)
		Help(,, "TOTVS - " + AllTrim(FunName()),, "Na data informada existe afastamento sem data de término definida.", 1, 0)
		Return .F.
	EndIf
	If cPaisLoc == "PAR" .And. !LocChecData(M->RH_DATAINI)
		Aviso("Aviso", "Las vacaciones deben comezar en LUNES o en el proximo dia util en el caso de ser feriado",{"Redigita"})
		Return .F.
	EndIf
	If cPaisLoc $ "PTG|COL|VEN|PER|ANG"
		nRCMOrder := RetOrder( "RCM", "RCM_FILIAL+RCM_PD" )
		cTipoDia := gp240RetCont(;
						"RCM", 									; 			// cAlias
	  					nRCMOrder, 								; 			// nIndex
						xFilial("RCM") + fGetCodFol( "0072"),	; 			// cKey
						"RCM_TIPODI")
	EndIf
	If cPaisLoc == "BRA"
		cAboPec  := If(!Empty(M->RH_ABOPEC), M->RH_ABOPEC, cAboAnt)
	EndIf
	DATAINI  := M->RH_DATAINI
	//Faz o recálculo dos dias de direito a férias e atualiza o cabeþalho das férias com os dias de direito
	aPerFerias := {}
	If !(cPaisLoc $ "PER|PTG|ANG") .Or. StrZero(Year(SRA->RA_ADMISSA),4) == StrZero(Year(dDataAte),4)
		Calc_Fer(@aPerFerias,DATAINI,,,,,,.F.,If(cPaisLoc=="BRA",M->RH_DATABAS,CtoD('')))
	ElseIf cPaisLoc == "ANG"
		Calc_Fer(@aPerFerias,LastDate(CtoD("01/"+Substr(cMesAnoRef,5,2)+"/"+Substr(cMesAnoRef,1,4))),@n2Dferven,,,,,.F.)
	ElseIf cPaisLoc == "PER"
		Calc_Fer(@aPerFerias,DATAINI,,,,,,.F.)
	Else
		Calc_Fer(@aPerFerias,Ctod("31/12/"+StrZero(Year(DATAINI),4)),,,,,,.F.)
	EndIf
	//Posicionar no periodo aberto atual
	nPosFer	   := aScan(aPerFerias,{ |X| X[8] == "1" })
	nPosFerBkp := aScan(aPerFERBkp,{ |X| X[8] == "1" })
	If nPosFer == 0
		Help(,, "TOTVS - " + AllTrim(FunName()),, "Não existe período de cálculo aberto para a competência", 1, 0)
		Return .F.
	EndIf
	If Len(aPerFerias) > 0 .And. Len(aPerFERBkp) > 0 .And. nPosFerBkp > 0 .And. Len(aPerFerias) == Len(aPerFERBkp) .And. aPerFerias[nPosFer,1] < aPerFERBkp[nPosFerBkp,1]
		aPerFerias := AClone(aPerFERBkp)
		lPerQuit   := .T.
	EndIf
	If !lPerQuit
		n2Dferven  := aPerFerias[nPosFer][3]
		//INICIO - 12/11/2019 - VALIDAÇÃO ESPECIFICA CRIADA DESDE A IMPLEMENTAÇÃO DESSA ROTINA PARA CORRETO FUNCIONAMENTO	
		//n2Dferave  := aPerFerias[nPosFer][4]
		if Month(M->RH_DATAINI) == Month(aPerFerias[nPosFer][2])
			n2Dferave  := aPerFERBkp[nPosFer][3]
		else
			n2Dferave  := aPerFerias[nPosFer][4]
		endif
		//FIM - 12/11/2019 - VALIDAÇÃO ESPECIFICA CRIADA DESDE A IMPLEMENTAÇÃO DESSA ROTINA PARA CORRETO FUNCIONAMENTO
		n2Dferven  := If(n2DferVen <= 0, n2Dferave, n2Dferven)
		If cPaisLoc = "BRA"
			n2Dferven := If (n2DferVen>nDiasAux,nDiasAux,n2Dferven)
		EndIf
		nBkpFalt := oModel:GetValue("GPEM030_MSRH","RH_DFALTAS")
		// Verifica as Faltas e Calcula as Medias do Periodo
		Ver_med(@nfaltas)
		If nFaltas == 0
			//--Quando as Ferias for a Vencer deve proporcionalizar as Ferias
			If n2Dferven < aTabFer[3]
				If cPaisLoc=="BRA" .and. cPerFeAc=='S' .and. n2Dferven > 0
					nFaltas  := SRF->RF_DFALVAT
				Else
					nFaltas  := SRF->RF_DFALAAT
				EndIf
			Else
				nFaltas  := SRF->RF_DFALVAT
			Endif
		Endif
		If nFaltas == 0 .And. nBkpFalt > 0
			nFaltas	:= nBkpFalt
		EndIf
		M->RH_DFALTAS 	:= nFaltas
		n2Dferven 		:= If(!Empty(dFVenPen),nDVenPen,n2Dferven)  // - Ajusta os dias de ferias vencidas quando existirem dias pendentes do periodo
		If ValType(oModel) == "O"
			oModel:LoadValue("GPEM030_MSRH","RH_DFERVEN",n2Dferven)
		EndIf
		If cPaisLoc == "PER"
			dRch_DtIni	:= dDataDe
			dRch_DtFim	:= DDataAte
			nValAux	:= 0
			dPerCad 	:= CtoD( Substr( DtoS(dRch_DtFim) ,7,2) + "/" + Substr( DtoS(dRch_DtFim) ,5,2) + "/" + AllTrim(Str( Year(dRch_DtFim) - 2 )) )
			aEval( aPerFerias , { |x| iif( x[1] < dRch_Dtini .and. x[2] >= dPerCad , nValAux += (x[3] - x[14]) , ) } )
			If ValType(oModel) == "O"
				oModel:LoadValue("GPEM030_MSRH","RH_DFERVEN",nValAux)
			EndIf
		EndIf
		M->RH_DFERVEN := oModel:GetValue("GPEM030_MSRH","RH_DFERVEN")
		//Atualiza o cabeþalho das férias com os dias de férias que serão gozados
		If nBkpDFer == M->RH_DFERIAS
			If cPaisLoc $ "ANG*VEN*COL"
				oModel:LoadValue("GPEM030_MSRH","RH_DFERIAS",n2DFerVen)
			ElseIf cPaisLoc == "PER"
				nValAux := 0
				aEval( aPerFerias , { |x| iif( x[1] < dRch_Dtini .and. x[2] >= dPerCad , nValAux += (x[3] - x[14]) , ) } )
				oModel:LoadValue("GPEM030_MSRH","RH_DFERIAS",nValAux)
			Else
				nDescFal := nFaltas
				TabFaltas(@nDescFal)
				//--Quando as Ferias for a Vencer deve proporcionalizar as Ferias
				If n2DferVen < nDiasAux .And. !lMetadeFal .And. !lTempoParc
					nDescFal := ((nDescFal / 30) * n2DferVen)
				EndIf
				//--A prioridade sera sempre para os dias de vencidas pendentes
				If nDVenPen > 0 .And. !Empty(dIVenPen)
					If nDiasProg > 0
						oModel:LoadValue("GPEM030_MSRH","RH_DFERIAS",Min((nDVenPen - nDescFal),nDiasProg))
					Else
						oModel:LoadValue("GPEM030_MSRH","RH_DFERIAS",(nDVenPen - nDescFal))
					EndIf
					If Type("nDFalt") != "U"
						nDFalt := nDescFal
					EndIf
				ElseIf !lMetadeFal .And. !lTempoParc
					If nDiasProg > 0
						If ( oModel:GetValue("GPEM030_MSRH","RH_DFERVEN") - nDescFal ) > 0 .And. !lJaDescFal
							nDiasProg := Min(nDiasProg  - nDescFal , oModel:GetValue("GPEM030_MSRH","RH_DFERVEN") - nDescFal )
							If nDiasProg + nDAntPer <= aTabFer[3]
								oModel:LoadValue("GPEM030_MSRH","RH_DFERIAS",Max(nDiasProg,0))
							EndIf
						EndIf
					ElseIf nDAntPer > 0 .And. If(cPaisLoc == "ARG", dDtBasFer <= aPerFerias[nPosFer][1], dDtBasFer == aPerFerias[nPosFer][1])
						oModel:LoadValue("GPEM030_MSRH","RH_DFERIAS",Max(oModel:GetValue("GPEM030_MSRH","RH_DFERVEN") - nDescFal - nDAntPer,0))
					ElseIf M->RH_DFERIAS > M->RH_DFERVEN
						//INICIO - 12/11/2019 - VALIDAÇÃO ESPECIFICA CRIADA DESDE A IMPLEMENTAÇÃO DESSA ROTINA PARA CORRETO FUNCIONAMENTO
						//não faz nada
						//FIM - 12/11/2019 - VALIDAÇÃO ESPECIFICA CRIADA DESDE A IMPLEMENTAÇÃO DESSA ROTINA PARA CORRETO FUNCIONAMENTO
					Else
						oModel:LoadValue("GPEM030_MSRH","RH_DFERIAS",Max(oModel:GetValue("GPEM030_MSRH","RH_DFERVEN") - nDescFal,0))
					EndIf
				EndIf
			EndIf
			M->RH_DFERIAS := oModel:GetValue("GPEM030_MSRH","RH_DFERIAS")
			If !(cCampo $ "M->RH_DIALREM*M->RH_DIALRE1")
				M->RH_DIALREM := 0
				M->RH_DIALRE1 := 0
			EndIf
			nBkpDFer := M->RH_DFERIAS
		EndIf
		If cPaisLoc $ "PTG|COL|VEN|PER|ANG"
			If cTipoDia == "2"
				DATAFIM  :=(M->RH_DATAINI + Round(M->RH_DFERIAS,0)) - 1
			Else
				GpeCalend(,,,,,DATAINI,@dDataFim,M->RH_DFERIAS,"F",cCampo,.F.)
				DATAFIM  := dDataFim
			EndIf
		Else
			DATAFIM  := If(cPaisLoc == "BRA".Or.!lHabiles,(M->RH_DATAINI + Round(M->RH_DFERIAS+M->RH_DIALREM+M->RH_DIALRE1,0)) - 1,LocFimFer(M->RH_DATAINI, Round(M->RH_DFERIAS,0),'1',.T.,.T.,.T.)-1)
		EndIf
		If cPaisloc <> "BRA"
			If cPaisLoc == "PAR"
				lParSab := If(SRA->RA_SABUTIL == "1",.T.,.F.)
			EndIf
			If cPaisLoc == "CHI"
				lSabNUtil := .T.
			ElseIf cPaisLoc == "PAR" .And. !lParSab
				lSabNUtil := .T.
			EndIf
		EndIf
	Else
		DATAFIM  := If(cPaisLoc == "BRA".Or.!lHabiles,(M->RH_DATAINI + Round(M->RH_DFERIAS+M->RH_DIALREM+M->RH_DIALRE1,0)) - 1,LocFimFer(M->RH_DATAINI, Round(M->RH_DFERIAS,0),'1',.T.,.T.,.T.)-1)
	EndIf
	DATAFIM  := If (DATAFIM < DATAINI,DATAINI,DATAFIM)
	DTAVISOF := fVerData(M->RH_DATAINI - (If (nAvisFer > 0, nAvisFer, Max(aTabFer[3],30))))
	If !(cPaisLoc == "PER") .And. cAboPec =="1" .and.  M->RH_DABONPE > 0  //--  Considera Abono Pecuniario antes da Dt Inicial de Ferias para o caluclo da data de pagamento
		DTRECIBO := DataValida(DataValida((M->RH_DATAINI-M->RH_DABONPE)-1,.F.)-1,.F.)
	ElseIf cPaisLoc == "COL"
		DTRECIBO := DataValida(M->RH_DATAINI-0,.F.)
	Else
		DTRECIBO := DataValida(DataValida(M->RH_DATAINI-1,.F.)-1,.F.)
	EndIf
	If cPaisLoc == "ANG"
		If Type("lDUtilFer") # "U"
			lDUtilFer := cTipoDia == "1"
		EndIf
	EndIf
	//+--------------------------------------------------------------+
	//¦ Verifica se Deve Considerar dias 24/12, 25/12, 31/12 e 01/01 ¦
	//| como licenca remunerada.                                     |
	//+--------------------------------------------------------------+
	//INICIO - 05/11/2019 - VALIDAÇÃO ESPECIFICA CRIADA DESDE A IMPLEMENTAÇÃO DESSA ROTINA PARA CORRETO FUNCIONAMENTO
	If cFerColet == "S"
		fChkLicRem(DATAINI,DATAFIM,@nDMes12,@nDMes01,cDia2501)
	EndIf
	//FIM - 05/11/2019 - VALIDAÇÃO ESPECIFICA CRIADA DESDE A IMPLEMENTAÇÃO DESSA ROTINA PARA CORRETO FUNCIONAMENTO
	If nDMes12 + nDMes01 > 0
		DATAFIM += nDMes12 + nDMes01
	EndIf
	//+--------------------------------------------------------------+
	//¦ Se houver dias de ferias = 0.5, lancar 0.5 em Lic. Remunerda ¦
	//+--------------------------------------------------------------+
	fChkFQueb(DATAINI,DATAFIM,@nDLicQ1,@nDLicQ2)
	//Procura periodo de calculo aberto para o fim das ferias
	If AnoMes(DATAINI) <> AnoMes(DATAFIM)
		fRetPerComp(SubStr(Dtos(DATAFIM),5,2), SubStr(Dtos(DATAFIM),1,4),, SRA->RA_PROCES,fGetCalcRot("3"),@aPerAberto )
		If Empty(aPerAberto)
			Help(,, "TOTVS - " + AllTrim(FunName()),, "Não existe período de cálculo aberto para a competência", 1, 0)
			Return .F.
		EndIf
	EndIf
	//Procura periodo de calculo de acordo com a data digitada
	aPerAberto := {}
	fRetPerComp(SubStr(Dtos(DATAINI),5,2), SubStr(Dtos(DATAINI),1,4),, SRA->RA_PROCES,fGetCalcRot("3"),@aPerAberto )
	If Empty(aPerAberto)
		Help(,, "TOTVS - " + AllTrim(FunName()),, "Não existe período de cálculo aberto para a competência", 1, 0)
		Return .F.
	EndIf
	If !Empty(aPerAberto[1,11])
		Help(,, "TOTVS - " + AllTrim(FunName()),,"Periodo de férias já foi integrado",1,0)
		Return .F.
	EndIf
	M->RH_DIALREM := If( Empty(M->RH_DIALREM), nDMes12 + nDLicQ1, M->RH_DIALREM )
	M->RH_DIALRE1 := If( Empty(M->RH_DIALRE1), nDMes01 + nDLicQ2, M->RH_DIALRE1 )
	M->RH_DATAFIM := DATAFIM
	M->RH_DTAVISO := DTAVISOF
	M->RH_DTRECIB := DTRECIBO
	M->RH_SALARIO := SRA->RA_SALARIO
	M->RH_PERIODO := aPerAberto[1,1]
	M->RH_ROTEIR  := aPerAberto[1,8]
	M->RH_NPAGTO  := aPerAberto[1,2]
	If ValType(oModel) == "O"
		oModel:LoadValue("GPEM030_MSRH","RH_DIALREM", If( Empty(M->RH_DIALREM), nDMes12 + nDLicQ1, M->RH_DIALREM ) )
		oModel:LoadValue("GPEM030_MSRH","RH_DIALRE1", If( Empty(M->RH_DIALRE1), nDMes01 + nDLicQ2, M->RH_DIALRE1 ) )
		oModel:LoadValue("GPEM030_MSRH","RH_DATAFIM",DATAFIM)
		oModel:LoadValue("GPEM030_MSRH","RH_DTAVISO",DTAVISOF)
		oModel:LoadValue("GPEM030_MSRH","RH_DTRECIB",DTRECIBO)
		oModel:LoadValue("GPEM030_MSRH","RH_SALARIO",SRA->RA_SALARIO)
		oModel:LoadValue("GPEM030_MSRH","RH_PERIODO",aPerAberto[1,1])
		oModel:LoadValue("GPEM030_MSRH","RH_ROTEIR",aPerAberto[1,8])
		oModel:LoadValue("GPEM030_MSRH","RH_NPAGTO",aPerAberto[1,2])
	EndIf
	RestArea(aArea)
Return .T.