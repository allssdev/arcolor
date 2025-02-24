#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} RGPEA001
    Rotina especifica para tratativas de arredondamento entre roteiros "ADI" e "FOL".
    @type  Function
    @author Fernando Bombardi - ALLSS
    @since 12/04/2022
    @version P12.1.33
    /*/
User Function RGPEA001()
	local _lExeFun := .F.
	local _lPerg   := .F.
	local _cPerg   := "RGPEA001"
	Private _lProc := .T.

	Validperg(_cPerg)

	DEFINE MSDIALOG oDlg FROM  96,4 TO 355,625 TITLE 'Alteração de Verbas' PIXEL
	@ 18, 9 TO 99, 300 LABEL "" OF oDlg  PIXEL
	@ 29, 15 Say "A presente rotina tem por objetivo realizar a alteração das verbas de arredondamento/desconto de um"  SIZE 275, 10 OF oDlg PIXEL
	@ 38, 15 Say "roteiro (FOL) para outro (ADI)." SIZE 275, 10 OF oDlg PIXEL
	DEFINE SBUTTON FROM 108,209 TYPE 5 ACTION (_lPerg:=.T.,Pergunte(_cPerg,.T.))  ENABLE OF oDlg
	DEFINE SBUTTON FROM 108,238 TYPE 1 ACTION (_lExeFun:=.T.,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 108,267 TYPE 2 ACTION (_lExeFun := .F.,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 108,180 TYPE 15 ACTION ProcLogView(cFilAnt,'RGPEA01P') ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg

	if _lExeFun
		if !_lPerg
			if MsgYesNo("Os parâmetros não foram configurados. Deseja gerar a planilha com os parâmetros configurados anteriormente?","[RGPEA001_001] - Atenção")
				Pergunte(_cPerg,.F.)
				MsgRun("Realizando as alterações de verba...","Aguarde um momento, processando sua requisicao",{|| RGPEA01P() })
			else
				return
			endif
		else
			MsgRun("Realizando as alterações de verba...","Aguarde um momento, processando sua requisicao",{|| RGPEA01P() })
			if _lProc
				MsgInfo("Processamento finalizado com sucesso.","[RGPEA001_001] - Aviso")
			endif
		endif
	endif
return .T.

/*/{Protheus.doc} RGPEA01P
    Função para atualizar verbas da tablea RGB
    @type  Function
    @author Fernando Bombardi - ALLSS
    @since 12/04/2022
    @version p12.1.33
/*/
Static Function RGPEA01P()
	Local cWhere     := "% RGB.RGB_PD IN " + FormatIn(Alltrim(MV_PAR06),"\") + "%"
	Local _cDetalhes := ""
	Local cIDCV8MOV	 := MoveId()

	_cDetalhes += "Os seguintes parâmetros foram utilizados neste processamento:" + CHR(13) + CHR(10)
	_cDetalhes += " FILIAL DE " + MV_PAR07 + " ATE " + MV_PAR08 + CHR(13) + CHR(10)
	_cDetalhes += " PROCESSO = " + MV_PAR01 + CHR(13) + CHR(10)
	_cDetalhes += " PERIODO = " + MV_PAR02 + CHR(13) + CHR(10)
	_cDetalhes += " NRO PAGAMENTO = " + MV_PAR03 + CHR(13) + CHR(10)
	_cDetalhes += " ROTEIRO ORIGINAL = " + MV_PAR04 + CHR(13) + CHR(10)
	_cDetalhes += " ROTEIRO NOVO = " + MV_PAR05 + CHR(13) + CHR(10)
	_cDetalhes += " VERBAS ALTERADAS = " + FormatIn(Alltrim(MV_PAR06),"\") + CHR(13) + CHR(10)
	_cDetalhes += " CENTRO DE CUSTO DE " + MV_PAR09 + " ATE " + MV_PAR10 + CHR(13) + CHR(10)
	_cDetalhes += " DEPARTAMENTO DE " + MV_PAR11 + " ATE " + MV_PAR12 + CHR(13) + CHR(10)
	_cDetalhes += " MATRICULA DE " + MV_PAR13 + " ATE " + MV_PAR14 + CHR(13) + CHR(10)

	GravaCV8("1", "RGPEA01P", "Processamento iniciado.", _cDetalhes, "", "", NIL, cIDCV8MOV)

	BeginSQL alias "QRYRGB"
	SELECT R_E_C_N_O_
	FROM %table:RGB% RGB
	WHERE
		RGB.RGB_FILIAL  BETWEEN  %Exp:MV_PAR07% AND  %Exp:MV_PAR08%
        AND RGB.RGB_PROCES = %Exp:MV_PAR01%
        AND RGB.RGB_PERIOD = %Exp:MV_PAR02%
        AND RGB.RGB_SEMANA = %Exp:MV_PAR03%
        AND RGB.RGB_ROTEIR = %Exp:MV_PAR04%
        AND %Exp:cWhere% 
        AND RGB.RGB_CC BETWEEN  %Exp:MV_PAR09% AND  %Exp:MV_PAR10%
        AND RGB.RGB_DEPTO BETWEEN  %Exp:MV_PAR11% AND  %Exp:MV_PAR12%
        AND RGB.RGB_MAT BETWEEN  %Exp:MV_PAR13% AND  %Exp:MV_PAR14%
		AND RGB.%NotDel%
	EndSQL

	dbSelectArea("QRYRGB")

	if QRYRGB->(!EOF())

		while QRYRGB->(!EOF())

			DBSelectArea("RGB")
			RGB->(dbGoto(QRYRGB->R_E_C_N_O_))
			RecLock("RGB",.F.)
			RGB->RGB_ROTEIR := Alltrim(MV_PAR05)
			RGB->(MsUnlock())

			dbSelectArea("QRYRGB")
			QRYRGB->(dbSkip())

		enddo


		GravaCV8("2", "RGPEA01P", "Processamento finalizado com sucesso.", _cDetalhes, "", "", NIL, cIDCV8MOV)

	else

		MsgAlert("Não foram encontrados dados a serem processados. Por favor, verifique os parâmetros informados!","[RGPEA001_002] - Atenção")

		GravaCV8("4", "RGPEA01P", "Não foram encontrados dados a serem processados.", _cDetalhes, "", "", NIL, cIDCV8MOV)

		_lProc := .F.

	endif
	QRYRGB->(dbCloseArea())



Return

/*/{Protheus.doc} Validperg
	Função para criar parametros de filtros para a rotina.
	@type  Function
	@author Fernando Bombardi - ALLSS
	@since 12/04/2022
/*/
Static Function Validperg(cPerg)
	local cAlias := Alias()
	local aRegs  := {}
	local x      := 0
	local y      := 0
	local _cPerg := Padr(cPerg,10)
	local _aTam  := {}

	dbSelectArea("SX1")
	dbSetOrder(1)

	_aTam := TamSx3("RGB_PROCES")
	AADD(aRegs,{_cPerg,"01","Processo                ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","RCJ","","","","",""})

	_aTam := TamSx3("RGB_PERIOD")
	AADD(aRegs,{_cPerg,"02","Período                 ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","RCH","","","","",""})

	_aTam := TamSx3("RGB_SEMANA")
	AADD(aRegs,{_cPerg,"03","Nro. Pagamento          ?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","RCH01","","","","",""})

	_aTam := TamSx3("RGB_ROTEIR")
	AADD(aRegs,{_cPerg,"04","Roteiro atual           ?","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRY","","","","",""})
	AADD(aRegs,{_cPerg,"05","Roteiro novo            ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SRY","","","","",""})

	_aTam := TamSx3("RGB_PD")
	AADD(aRegs,{_cPerg,"06","Verbas a serem alteradas?","","","mv_ch6","C",99,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	AADD(aRegs,{_cPerg,"07","Filial de              ?","","","mv_ch7","C",002,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"08","Filial até             ?","","","mv_ch8","C",002,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	_aTam := TamSx3("RGB_CC")
	AADD(aRegs,{_cPerg,"09","Do centro de custo     ?","","","mv_ch9",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","","","",""})
	AADD(aRegs,{_cPerg,"10","Até centro de custo    ?","","","mv_cha",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","","","",""})

	_aTam := TamSx3("RGB_DEPTO")
	AADD(aRegs,{_cPerg,"11","Do departamento        ?","","","mv_chb",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SQB"   ,"","","","",""})
	AADD(aRegs,{_cPerg,"12","Até departamento       ?","","","mv_chc",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SQB"   ,"","","","",""})

	_aTam := TamSx3("RGB_MAT")
	AADD(aRegs,{_cPerg,"13","De matrícula           ?","","","mv_che",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","SRA04" ,"","","","",""})
	AADD(aRegs,{_cPerg,"14","Até matrícula          ?","","","mv_chf",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","SRA04" ,"","","","",""})

	for x := 1 to len(aRegs)
		dbSelectArea("SX1")
		SX1->(dbSetOrder(1))
		if !SX1->(dbSeek(_cPerg+aRegs[x,2]))
			RecLock("SX1",.T.)
			for y := 1 to FCount()
				if y <= len(aRegs[x])
					FieldPut(y,aRegs[x,y])
				else
					exit
				endif
			next y
			SX1->(MsUnlock())
		endif
	next x

	dbSelectArea(cAlias)
return

/*/{Protheus.doc} MoveId
    Funcao para gerar a identificacao do movimento no CV8.
    @type  Function
    @author Fernando Bombardi - ALLSS
    @since 12/04/2022
    @version P12.1.33
/*/
Static Function MoveId()
	Local _cIdCV8 := ""

	If CV8->(FieldPos("CV8_IDMOV")) > 0 .And. !Empty(CV8->(IndexKey(5)))
		_cIdCV8:= GetSXENum("CV8","CV8_IDMOV",,5)
		ConfirmSX8()
	EndIf

Return(_cIdCV8)
