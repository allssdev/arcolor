#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CENT CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³RFATR040ºAlterado por ³Marcelo Evangelistaº Data ³  20/02/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Rotina de impressao de etiquetas termicas, especifico para º±±
±±ºDescrição ³ a impressora Datamax OS214TT.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function RFATR040()
	local   aArea       := GetArea() 
	local   aAreaSC5    := SC5->(GetArea())
	local   aAreaSC6    := SC6->(GetArea())
	local   aAreaSC9    := SC9->(GetArea())
	local   aAreaSF2	:= SF2->(GetArea())
	local   aAreaSD2    := SD2->(GetArea())
	local   aAreaSE1    := SE1->(GetArea())
	local   aAreaSB1    := SB1->(GetArea())
	local   aAreaSA1    := SA1->(GetArea()) 
	local   aAreaSA2    := SA2->(GetArea()) 
//	Private aPerg       := {}
	Private Titulo		:= "Etiqueta Datamax - NF" 
	Private _cRotina    := "RFATR040"
	Private cPerg       := _cRotina

	if AllTrim(FunName()) <> "ACDV166" .AND. AllTrim(FunName())<> "RACDV166" .AND. AllTrim(FunName()) <> "U_RACDV166"
		ValidPerg()
		if AllTrim(FunName()) == "RFATA002"
			MV_PAR01 := SF2->F2_DOC
			MV_PAR02 := SF2->F2_DOC           
			MV_PAR03 := SF2->F2_SERIE
			MV_PAR04 := 1
			MV_PAR05 := SF2->F2_VOLUME1
		else
			if !Pergunte(cPerg,.T.)
				return nil
			endif	
			if MV_PAR04 == 0
				MV_PAR04 := 1
			endif
		endif
		//U_RACDR001()
		if !Empty(MV_PAR02) .AND. !Empty(MV_PAR03)
		//U_RACDR001()
			aAreaSF2    := SF2->(GetArea())
			Proces(@lEnd)
		//	Processa( { |lEnd| Proces(@lEnd) }, "["+_cRotina+"] "+Titulo,"Aguarde... Processando a impressão...",.T.)
		else
			MsgStop("Parâmetros preenchidos incorretamente. Operação não permitida!",_cRotina+"_003")
		endif
	elseif ExistBlock("RACDR001")
		U_RACDR001()
	endif
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaSC9)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaSE1)
	RestArea(aAreaSB1)
	RestArea(aAreaSA1) 
	RestArea(aAreaSA2) 
	RestArea(aArea)
return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcesºAlterado por  ³Marcelo Evangelistaº Data ³  20/03/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Processamento da rotina.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function Proces(lEnd)
	Local _cNota    := ""
	Local _cSerie   := ""
	Local _cCodbar  := ""
	Local _cFName   := AllTrim(FunName())
	Local _cAliasF2 := GetNextAlias()
	Local _cAliasD2 := GetNextAlias()
	Local _nVolume  := 0
	Local _nAux     := 1

	#DEFINE DMPAPER_ENV_10 20

	Private oFont1	:= TFont():New("Verdana",,15,,.F.,,,,,.F. )
	Private oFont2	:= TFont():New("Verdana",,15,,.T.,,,,,.F. )
//	Private oFont3	:= TFont():New("Verdana",,15,,.F.,,,,,.F. )
	Private oPrn	:= TMSPrinter():New("DATAMAX")
	Private _aIdEti := {}
	Private aEti    := {}
	Private aEtds   := {}
	Private _nXi    := 0
	Private cEti    := ""

	// - Inserido em 01/01/2016 por Júlio Soares para previnir erro na rotina
	If (Select(_cAliasF2) > 0 )
		(_cAliasF2)->(dbCloseArea())
	EndIf
	// - Fim
	BeginSql Alias _cAliasF2
		SELECT F2_FILIAL, F2_SERIE, F2_DOC, F2_EMISSAO, F2_VOLUME1, F2_CLIENTE, F2_LOJA, F2_TIPO
		FROM %table:SF2% SF2X (NOLOCK)
		WHERE SF2X.F2_FILIAL      = %xFilial:SF2%
		  AND SF2X.F2_DOC   BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		  AND SF2X.F2_SERIE       = %Exp:MV_PAR03%
		  AND SF2X.%NotDel%
		ORDER BY F2_FILIAL, F2_SERIE, F2_DOC
	EndSql
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.txt",cQuery1)
	dbSelectArea(_cAliasF2)
	if !(_cAliasF2)->(EOF()) .AND. !lEnd
	//	oPrn:ResetPrinter()
	//	oPrn:Setup()
		oPrn:SetPaperSize(DMPAPER_ENV_10)																	// Tamanho/Tipo do Papel
		if _cFName=="RFATA002" .OR. _cFName=="ACDV166"
	//		oPrn:Setup()                     																//Abre a tela para configuração da impressora
			oPrn:SetLandscape()																				// Impressão em formato "paisagem"
		else
	  		oPrn:Setup()                     																//Abre a tela para configuração da impressora
			oPrn:SetLandscape()																				// Impressão em formato "paisagem"	
		endif
		while !(_cAliasF2)->(EOF()) .AND. !lEnd
			If AllTrim((_cAliasF2)->F2_SERIE) == "ZZZ"
				BeginSql Alias _cAliasD2
					SELECT SD2X.D2_PEDIDO D2_PEDIDO, COUNT(*) REG
					FROM %table:SD2% SD2X (NOLOCK)
					WHERE SD2X.D2_FILIAL  = %xFilial:SD2%
					  AND SD2X.D2_EMISSAO = %Exp:(_cAliasF2)->F2_EMISSAO%
					  AND SD2X.D2_SERIE  <> %Exp:'ZZZ'%
					  AND SD2X.D2_PEDIDO IN (
												SELECT DISTINCT D2_PEDIDO
												FROM %table:SD2% SD2 (NOLOCK)
												WHERE 
												  AND SD2.D2_FILIAL  = %xFilial:SD2%
												  AND SD2.D2_DOC     = %Exp:(_cAliasF2)->F2_DOC%
												  AND SD2.D2_SERIE   = %Exp:(_cAliasF2)->F2_SERIE%
												  AND SD2.D2_EMISSAO = %Exp:(_cAliasF2)->F2_EMISSAO%
												  AND SD2.%NotDel%
											)
					  AND SD2X.%NotDel%
					GROUP BY SD2X.D2_PEDIDO
				EndSql
			//	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.txt",cQuery1)
				dbSelectArea(_cAliasD2)
				if (_cAliasD2)->REG > 0
					(_cAliasD2)->(dbCloseArea())
					dbSelectArea(_cAliasF2)
					(_cAliasF2)->(dbSkip())
					Loop
				else
					(_cAliasD2)->(dbCloseArea())
				endif
				_cPedido := (_cAliasD2)->D2_PEDIDO
			endif
			_cNota   := (_cAliasF2)->F2_DOC
			_cSerie	 := (_cAliasF2)->F2_SERIE
			_nVolume := (_cAliasF2)->F2_VOLUME1 
			_cCodbar := ""
			if AllTrim((_cAliasF2)->F2_TIPO) $ "D/B"
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				if SA2->(MsSeek(xFilial("SA2") + (_cAliasF2)->F2_CLIENTE + (_cAliasF2)->F2_LOJA,.T.,.F.))
					_cRazao := SA2->A2_NOME
				endif
			else
				dbSelectarea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA1") + (_cAliasF2)->F2_CLIENTE + (_cAliasF2)->F2_LOJA,.T.,.F.))
					_cRazao := SA1->A1_NOME
				EndIf
			EndIf
			If MV_PAR04 <= (_cAliasF2)->F2_VOLUME1
				If MV_PAR05 >= (_cAliasF2)->F2_VOLUME1
					_nVolume := (_cAliasF2)->F2_VOLUME1
				Else
					_nVolume :=	MV_PAR05
				EndIf
			Else
				_nVolume      := 0
			EndIf
			if _nVolume > 0
				aEti := {}
				for _nAux := MV_PAR04 to _nVolume
				   	aEti  := {}	    
				    _cEti := ""
					_cCodBar := _cNota + _cSerie + cValToChar(_nAux)
					oPrn:Say(085 ,0200, Alltrim(_cNota) ,oFont2,100,,,3)
					_cEti += _cNota
					oPrn:Say(130 ,0065, "VOLUME(S): " + Alltrim(cValToChar(_nAux)+"/"+cValToChar((_cAliasF2)->F2_VOLUME1))  ,oFont2,100,,,3)
					_cEti += CENT +  "VOLUME(S): " + Alltrim(cValToChar(_nAux)+"/"+cValToChar((_cAliasF2)->F2_VOLUME1)) 
					oPrn:Say(0180,010, SubStr(AllTrim(_cRazao),01,26),oFont1,100,,,3)
					_cEti += CENT + SubStr(AllTrim(_cRazao),01,26)  
					oPrn:Say(0240,010, SubStr(AllTrim(_cRazao),27,26),oFont1,100,,,3)
					_cEti += CENT +   SubStr(AllTrim(_cRazao),27,26)
					oPrn:Say(0300,010, SubStr(AllTrim(_cRazao),53,26),oFont1,100,,,3)
					_cEti += CENT + SubStr(AllTrim(_cRazao),53,26)			
					oPrn:EndPage() 
					oPrn:StartPage()
					aadd(aEti, _cEti)	
					aadd(aEtds, aEti)			
				next 
			else
				MsgAlert("Atencao!!! Sem etiquetas a imprimir!",_cRotina+"_001")
				return
			endif
			//IncProc()
			dbSelectArea(_cAliasF2)
			(_cAliasF2)->(dbSkip())
		enddo
		oPrn:EndPage()
		SET DEVICE TO SCREEN
		MS_FLUSH()
	else
		MsgAlert("Atencao!!! Sem etiquetas a imprimir!",_cRotina+"_002")
	endif
	/*if ExistBlock("RFATL001") 
	 	_aIdEti  := logGetPedAt(_cNota ,_cSerie )
	 	For _nXi := 1  to len(aEtds)
	 		cEti := aEtds[_nXi][1]
	 		U_RFATL001(_aIdEti[2], _aIdEti[1] ,"Etiqueta "+ cValtoChar(_nXi) +" de " + cValToChar(_nVolume) + " / Conteudo Impresso: "+ cEti  +".",_cRotina)
	 	next _nXi++
	endif*/
	oPrn:Print()
	// - Trecho inserido por Júlio Soares para corrigir erro apresentado na expedição.
		if (Select(_cAliasF2) > 0 )
			(_cAliasF2)->(dbCloseArea())
		endif
	// - Fim
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Marcelo Ecangelista³ Data ³ 20/02/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento das perguntas na SX1.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Programa Principal                                          º±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/       
static function ValidPerg()
	Local _sAlias := GetArea()
	Local aRegs   := {}
	Local i       := 0
	Local j       := 0

	cPerg         := PADR(cPerg,10)
	AADD(aRegs,{cPerg,"01","De Nota     ?","","","mv_ch1","C",09,0,0,"G","NAOVAZIO()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SF2","",""})
	AADD(aRegs,{cPerg,"02","Ate Nota    ?","","","mv_ch2","C",09,0,0,"G","NAOVAZIO()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SF2","",""})
	AADD(aRegs,{cPerg,"03","Serie       ?","","","mv_ch3","C",03,0,0,"G","NAOVAZIO()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","De Volume   ?","","","mv_ch4","N",06,0,0,"G","NAOVAZIO()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Ate Volume  ?","","","mv_ch5","N",06,0,0,"G","NAOVAZIO()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	for i := 1 to len(aRegs)
		dbSelectArea("SX1")
		SX1->(dbSetOrder(1))
	    If !SX1->(dbSeek(cPerg+aRegs[i,2]))
	        while !RecLock("SX1",.T.) ; enddo
		        For j := 1 To FCount()
		            If j <= Len(aRegs[i])
		                FieldPut(j,aRegs[i,j])
		            Else
		               Exit
		            EndIf
		        Next
	        SX1->(MsUnLock())
	    EndIf
	next
	RestArea(_sAlias)
return
static function logGetPedAt(_cNotaEmi, _cSerieEmi)
	local _aIdEti   := {}
	Private _cAliasUA := ""
	if Select(_cAliasUA) > 0
		(_cAliasUA)->(dbCloseArea())
	endif
	BeginSql Alias _cAliasUA
		SELECT UA_NUM, UA_NUMSC5
		FROM %table:SUA% SUA (NOLOCK)
		WHERE SUA.UA_FILIAL  = %xFilial:SUA%
		  AND SUA.UA_DOC     = %Exp:_cNotaEmi%
		  AND SUA.UA_SERIE   = %Exp:_cSerieEmi%
		  AND SUA.%NotDel%
	EndSql
	dbSelectArea(_cAliasUA)
	if Select(_cAliasUA) > 0
		aAdd(_aIdEti, (_cAliasUA)->UA_NUM    )
		aAdd(_aIdEti, (_cAliasUA)->UA_NUMSC5 )
		(_cAliasUA)->(dbCloseArea())
	endif
return _aIdEti