#include "totvs.ch"
#include "FWPrintSetup.ch"
#include "rptdef.ch"

#Define COR_PRETO   RGB(000, 000, 000)

/*/{Protheus.doc} RPCPR009
    Relatório de rastreabilidade Anvisa
    @type  Function
    @author Fernando Bombardi
    @since 26/07/2023
    @version 1.0
	@history 04/04/2024, Diego Rodrigues (diego.rodrigues@allss.com.br), Conforme sugestão do Marco Antonio removemos o bloqueio de lista de ordens de produção dos produtos intermediarios e incluimos o saldo do PA no cabeçalho
    /*/
User Function RPCPR009()
	private _cRotina := "RPCPR009"
	private _cPerg   := _cRotina
	private _aTPPRD  := {}
	Private _cUsrId  := Alltrim(RetCodUsr())

	Private _cSpool         := GetTempPath()
	Private _cPdf           := "rel_rast_anvisa_"  + dToS(dDataBase) + "_" + StrTran(Time(), ':', '-') + ".pdf"

	ValidPerg()
	if Pergunte(_cPerg)

		if MV_PAR09 == 1 .AND. !_cUsrId $ Alltrim(SuperGetMv("MV_XIMPRAS",.F.,"000000"))
			MsgAlert("Você não possue permissão para imprimir a descrição dos produto. O relatório será gerado apenas com os códigos.","[RPCPR09_001] - Atenção")
			MV_PAR09 := 2
		endif

		if Select('RASTLOTE') > 0
			RASTLOTE->(dbCloseArea())
		endif

		if !RPCPR09D() 
			Return
		endif

		Aviso("[RPCPR09] - Fim de Processamento","O relatório foi gerado com sucesso!" + Chr(10) + chr(13) +;
		Chr(10) + chr(13) +;
		"Localização do arquivo: " + _cSpool + _cPdf ,{"Ok"},3)

	else

		MsgAlert("Rotina cancelada pelo usuário.","Atenção")

	endif
	
 return

/*/{Protheus.doc} RPCPR09D
Carrega os dados para o relatório
@author Fernando Bombardi
@since 26/07/2023
@type function
@version 1.00
/*/
static function RPCPR09D()
Local _lRet := .T.
Local lAdjustToLegacy := .F.
Local lDisableSetup   := .T.

Private cBTM            := FisxLogo("1")
Private oFont10         := TFont():New("Arial" ,,10,,.F.,,,,,.F.)
Private oFont16         := TFont():New("Areal" ,,16,,.F.,,,,,.F.)
Private oFont16AT       := TFont():New("Areal" ,,16,,.T.,,,,,.F.)
Private oFont22         := TFont():New("Areal" ,,22,,.F.,,,,,.F.)
Private oFont15	        := TFont():New("Areal" ,,15,,.F.,,,,,.F.)
Private oFont14         := TFont():New("Arial" ,,14,,.F.,,,,,.F.)
Private _nLimite        := 570
Private _nSaltoL        := 25
Private _nLin           := 50
Private _aLotesPrd      := {}

	BeginSql alias 'RASTLOTE'
		SELECT 
			MAX(D3_EMISSAO) D3_EMISSAO,D3_OP,D3_COD,SUM(D3_QUANT) D3_QUANT,D3_LOTECTL,D3_TM,D3_CF,B1_TIPO,B1_DESC 
		FROM  
			%table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
			ON B1_COD = D3_COD AND SB1.%NotDel%
		WHERE 
			D3_FILIAL =  %xFilial:SC2%  
			AND D3_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
			AND D3_COD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND D3_OP BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND D3_LOTECTL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
			AND D3_CF NOT IN ('DE0','RE0','DE6','RE6','DE4','RE4')
			AND D3_ESTORNO = ''
			AND SD3.%NotDel%
		GROUP BY D3_OP,D3_COD,D3_LOTECTL,D3_TM,D3_CF,B1_TIPO,B1_DESC
		ORDER BY D3_OP, D3_TM
	EndSql

	if !RASTLOTE->(EOF())

		oPrintAnvisa := FWMSPrinter():New(_cPdf, IMP_PDF, lAdjustToLegacy,, lDisableSetup,.t. , , , , , .F., )
		oPrintAnvisa:SetResolution(72)
		oPrintAnvisa:SetLandScape()		// Orientação do Papel (Retrato)
		oPrintAnvisa:SetPaperSize(9)	// Tamanho da Folha (9 = A4)	
		oPrintAnvisa:cPathPDF := _cSpool // Caso seja utilizada impressão em IMP_PDF

		while !RASTLOTE->(EOF())

			_aLotesPrd := {}
			if Select('INSUMOS') > 0
				INSUMOS->(DbCloseArea())
			endif

			BeginSql alias 'INSUMOS'
				SELECT 
					MAX(D3_EMISSAO) D3_EMISSAO, D3_OP, D3_COD, SUM(D3_QUANT) D3_QUANT,D3_LOTECTL,
					D3_TM,D3_CF,B1_TIPO,B1_DESC,D3_DTVALID 
				FROM  
					%table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
					ON B1_COD = D3_COD AND SB1.%NotDel%
				WHERE 
					D3_FILIAL =  %xFilial:SC2%  
					AND D3_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
					AND D3_OP = %Exp:RASTLOTE->D3_OP%
					AND SD3.%NotDel%
					AND D3_CF NOT IN ('DE0','RE0','DE6','RE6','DE4','RE4')
					AND D3_ESTORNO = ''
				GROUP BY D3_OP, D3_COD,D3_LOTECTL,
						 D3_TM,D3_CF,B1_TIPO,B1_DESC,D3_DTVALID
				ORDER BY D3_OP,D3_COD, D3_TM
			EndSql		
			
			if !INSUMOS->(EOF())
				while !INSUMOS->(EOF())

					if Alltrim(INSUMOS->B1_TIPO ) $ "PI/PA"
						aADD(_aLotesPrd, {INSUMOS->D3_COD, INSUMOS->B1_TIPO, INSUMOS->B1_DESC, INSUMOS->D3_LOTECTL, INSUMOS->D3_OP})
						aADD(_aTPPRD, {INSUMOS->D3_COD, INSUMOS->B1_TIPO, INSUMOS->B1_DESC, INSUMOS->D3_LOTECTL, INSUMOS->D3_OP})
					endif

					INSUMOS->(dbSkip())

				enddo

				RPCPR09P()

			endif

			RASTLOTE->(dbSkip())

		enddo

		oPrintAnvisa:Preview()

		FreeObj(oPrintAnvisa)
		oPrintAnvisa := Nil

		if Select('INSUMOS') > 0
			INSUMOS->(DbCloseArea())
		endif

	else

		MsgAlert("Não foram encontrados dados para inpressão! Verifique os parâmetros informados.","Atenção")
		_lRet := .F.

	endif

return(_lRet)

/*/{Protheus.doc} RPCPR09P
Imprime a rastreabilidade
@author Fernando Bombardi
@since 26/07/2023
@type function
@version 1.00
@see https://allss.com.br
/*/
static function RPCPR09P()
Local _nInter   := 0
Local _aPiDoPi  := {}
Local _cPai     := ""
Local _nTotal	:= 0

	INSUMOS->(dbGoTop())
	while !INSUMOS->(EOF())

		If (_nLin + _nSaltoL) > _nLimite
			oPrintAnvisa:EndPage()
			oPrintAnvisa:StartPage()
			RPCPR09C()
		else
			oPrintAnvisa:StartPage()
			RPCPR09C()
		EndIf

		_nPosPA := aScan(_aTPPRD,{|x|AllTrim(x[02])=="PA"})

		oPrintAnvisa:Say(_nLin,005, "Produto:", oFont16AT)
		oPrintAnvisa:Say(_nLin,080,  ALLTRIM(_aTPPRD[_nPosPA][1]), oFont15)

		if MV_PAR09 == 1
			oPrintAnvisa:Say(_nLin,150,  ALLTRIM(_aTPPRD[_nPosPA][3]), oFont15)
		endif

		oPrintAnvisa:Say(_nLin,550, "Tipo:", oFont16AT)
		oPrintAnvisa:Say(_nLin,600,  ALLTRIM(_aTPPRD[_nPosPA][2]), oFont15)

		oPrintAnvisa:Say(_nLin,700, "Lote:", oFont16AT)
		oPrintAnvisa:Say(_nLin,750,  ALLTRIM(_aTPPRD[_nPosPA][4]), oFont15)
		_nLin     += _nSaltoL

		oPrintAnvisa:Say(_nLin,080, "OP:", oFont16AT)
		oPrintAnvisa:Say(_nLin,150,  ALLTRIM(_aTPPRD[_nPosPA][5]), oFont15)

		BeginSql alias 'SALDOPA'
			SELECT 
				B8_PRODUTO,B8_LOTECTL, B8_SALDO
			FROM  %table:SB8% SB8 (NOLOCK) 
			WHERE B8_FILIAL =  %xFilial:SC2%
				AND B8_LOTECTL = %Exp:ALLTRIM(_aTPPRD[_nPosPA][4])%
				AND SB8.%NotDel%
		EndSql		

		if !SALDOPA->(EOF())
		oPrintAnvisa:Say(_nLin,550, "Saldos", oFont16AT)
		oPrintAnvisa:Say(_nLin,600, Transform(SALDOPA->B8_SALDO,"@e 999,999,999.999999"), oFont15)
		EndIf
		SALDOPA->(dbCloseArea())
		_nLin     += _nSaltoL + 3

		oPrintAnvisa:Say(_nLin,005, "Máterias Primas Consumidas:", oFont16AT)
		_nLin     += _nSaltoL


		oPrintAnvisa:Say(_nLin,030, "CÓDIGO", oFont16)

		if MV_PAR09 == 1
			oPrintAnvisa:Say(_nLin,100, "DESCRIÇÃO", oFont16)
			oPrintAnvisa:Say(_nLin,500, "TIPO", oFont16)
			oPrintAnvisa:Say(_nLin,550, "QTD", oFont16)
			oPrintAnvisa:Say(_nLin,650, "LOTE", oFont16)
			oPrintAnvisa:Say(_nLin,750, "DTVALIDADE", oFont16)
		else
			oPrintAnvisa:Say(_nLin,500-400, "TIPO", oFont16)
			oPrintAnvisa:Say(_nLin,550-400, "QTD", oFont16)
			oPrintAnvisa:Say(_nLin,650-400, "LOTE", oFont16)
			oPrintAnvisa:Say(_nLin,750-400, "DTVALIDADE", oFont16)
		endif
		_nLin     += _nSaltoL

		while !INSUMOS->(EOF())

			if Alltrim(INSUMOS->B1_TIPO) == "PA"
				INSUMOS->(dbSkip())
				Loop
			endif

			If (_nLin + _nSaltoL) > _nLimite
				oPrintAnvisa:EndPage()
				oPrintAnvisa:StartPage()
				RPCPR09C()
			Endif

			oPrintAnvisa:Say(_nLin,030,  INSUMOS->D3_COD    , oFont14)

			if MV_PAR09 == 1
				oPrintAnvisa:Say(_nLin,100,  INSUMOS->B1_DESC   , oFont14)
				oPrintAnvisa:Say(_nLin,500,  INSUMOS->B1_TIPO   , oFont14)
				oPrintAnvisa:Say(_nLin,550,  Transform(INSUMOS->D3_QUANT,"@e 999,999,999.999999")  , oFont14)
				oPrintAnvisa:Say(_nLin,650,  INSUMOS->D3_LOTECTL, oFont14)
				oPrintAnvisa:Say(_nLin,750,  DTOC(STOD(INSUMOS->D3_DTVALID)), oFont14)
			else
				oPrintAnvisa:Say(_nLin,500-400,  INSUMOS->B1_TIPO   , oFont14)
				oPrintAnvisa:Say(_nLin,550-400,  Transform(INSUMOS->D3_QUANT,"@e 999,999,999.999999")  , oFont14)
				oPrintAnvisa:Say(_nLin,650-400,  INSUMOS->D3_LOTECTL, oFont14)
				oPrintAnvisa:Say(_nLin,750-400,  DTOC(STOD(INSUMOS->D3_DTVALID)), oFont14)
			endif
			_nLin     += _nSaltoL

			INSUMOS->(dbSkip())
		enddo
	
	enddo

	if len(_aTPPRD) > 0 

		for _nInter := 1 to len(_aTPPRD)

			if ALLTRIM(_aTPPRD[_nInter][2]) == "PA"
				Loop
			endif

			BeginSql alias 'PRDINTER'
				SELECT 
					D3_EMISSAO,
					D3_OP,
					D3_COD,
					D3_QUANT,
					D3_LOTECTL,
					D3_NUMSEQ,
					D3_TM,
					D3_CF,
					B1_TIPO,
					B1_DESC,
					D3_DTVALID 
				FROM  
					%table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
					ON B1_COD = D3_COD AND SB1.%NotDel%
				WHERE 
					D3_FILIAL =  %xFilial:SC2%
					AND D3_LOTECTL = %Exp:ALLTRIM(_aTPPRD[_nInter][4])%
					AND SD3.%NotDel%
					AND D3_CF = 'PR0'
					AND D3_CF NOT IN ('DE0','RE0','DE6','RE6','DE4','RE4')
					AND D3_ESTORNO = ''
				ORDER BY D3_NUMSEQ, D3_TM
			EndSql		

			if !PRDINTER->(EOF())
				_nLin     += _nSaltoL
				oPrintAnvisa:Line(_nLin, 005, _nLin, 835, COR_PRETO)
				_nLin     += _nSaltoL

				If (_nLin + _nSaltoL) > _nLimite
					oPrintAnvisa:EndPage()
					oPrintAnvisa:StartPage()
					RPCPR09C()
				Endif

				oPrintAnvisa:Say(_nLin,005, "Produto Intermediário:", oFont16AT)
				_nLin     += _nSaltoL
				
				If (_nLin + _nSaltoL) > _nLimite
					oPrintAnvisa:EndPage()
					oPrintAnvisa:StartPage()
					RPCPR09C()
				Endif

				oPrintAnvisa:Say(_nLin,100, "Produto:", oFont16AT)
				oPrintAnvisa:Say(_nLin,165,  ALLTRIM(PRDINTER->D3_COD), oFont15)
				_cPai := PRDINTER->D3_COD

				if MV_PAR09 == 1
					oPrintAnvisa:Say(_nLin,235,  ALLTRIM(PRDINTER->B1_DESC), oFont15)
				endif

				oPrintAnvisa:Say(_nLin,550, "Tipo:", oFont16AT)
				oPrintAnvisa:Say(_nLin,600,  ALLTRIM(PRDINTER->B1_TIPO), oFont15)

				oPrintAnvisa:Say(_nLin,700, "Lote:", oFont16AT)
				oPrintAnvisa:Say(_nLin,750,  ALLTRIM(PRDINTER->D3_LOTECTL), oFont15)
				_nLin     += _nSaltoL

				If (_nLin + _nSaltoL) > _nLimite
					oPrintAnvisa:EndPage()
					oPrintAnvisa:StartPage()
					RPCPR09C()
				Endif

				oPrintAnvisa:Say(_nLin,100, "OP:", oFont16AT)
				oPrintAnvisa:Say(_nLin,165,  ALLTRIM(PRDINTER->D3_OP), oFont15)
				_nLin     += _nSaltoL + 3

				If (_nLin + _nSaltoL) > _nLimite
					oPrintAnvisa:EndPage()
					oPrintAnvisa:StartPage()
					RPCPR09C()
				Endif

				oPrintAnvisa:Say(_nLin,100, "Máterias Primas PI:", oFont16AT)
				_nLin     += _nSaltoL

				If (_nLin + _nSaltoL) > _nLimite
					oPrintAnvisa:EndPage()
					oPrintAnvisa:StartPage()
					RPCPR09C()
				Endif

				oPrintAnvisa:Say(_nLin,100, "CÓDIGO", oFont16)

				if MV_PAR09 == 1
					oPrintAnvisa:Say(_nLin,180, "DESCRIÇÃO", oFont16)
					oPrintAnvisa:Say(_nLin,500, "TIPO", oFont16)
					oPrintAnvisa:Say(_nLin,550, "QTD", oFont16)
					oPrintAnvisa:Say(_nLin,650, "LOTE", oFont16)
					oPrintAnvisa:Say(_nLin,750, "DTVALIDADE", oFont16)
				else
					oPrintAnvisa:Say(_nLin,500-350, "TIPO", oFont16)
					oPrintAnvisa:Say(_nLin,550-350, "QTD", oFont16)
					oPrintAnvisa:Say(_nLin,650-350, "LOTE", oFont16)
					oPrintAnvisa:Say(_nLin,750-350, "DTVALIDADE", oFont16)
				endif
				_nLin     += _nSaltoL

				If (_nLin + _nSaltoL) > _nLimite
					oPrintAnvisa:EndPage()
					oPrintAnvisa:StartPage()
					RPCPR09C()
				Endif

				BeginSql alias 'OPINTER'
					SELECT 
						MAX(D3_EMISSAO) D3_EMISSAO,D3_OP,D3_COD,SUM(D3_QUANT) D3_QUANT,D3_LOTECTL,
						D3_TM,D3_CF,B1_TIPO,B1_DESC,D3_DTVALID 
					FROM  
						%table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
						ON B1_COD = D3_COD AND SB1.%NotDel%
					WHERE 
						D3_FILIAL =  %xFilial:SC2%  
						AND D3_OP = %Exp:ALLTRIM(PRDINTER->D3_OP)%
						AND SD3.%NotDel%
						AND D3_CF NOT IN ('DE0','RE0','DE6','RE6','DE4','RE4')
						AND D3_ESTORNO = ''
					GROUP BY D3_OP,D3_COD,D3_LOTECTL,
							 D3_TM,D3_CF,B1_TIPO,B1_DESC,D3_DTVALID 
					ORDER BY D3_OP, D3_COD, D3_TM
				EndSql	
			
				_cQry := GetLastQuery()[2]			

				while !OPINTER->(EOF())

					if Alltrim(OPINTER->D3_TM) == "010"
						OPINTER->(dbSkip())
						Loop
					endif

					If (_nLin + _nSaltoL) > _nLimite
						oPrintAnvisa:EndPage()
						oPrintAnvisa:StartPage()
						RPCPR09C()
					Endif

					oPrintAnvisa:Say(_nLin,100,  OPINTER->D3_COD    , oFont14)
					if MV_PAR09 == 1
						oPrintAnvisa:Say(_nLin,180,  OPINTER->B1_DESC   , oFont14)
						oPrintAnvisa:Say(_nLin,500,  OPINTER->B1_TIPO   , oFont14)
						oPrintAnvisa:Say(_nLin,550,  Transform(OPINTER->D3_QUANT,"@e 999,999,999.999999")  , oFont14)
						oPrintAnvisa:Say(_nLin,650,  OPINTER->D3_LOTECTL, oFont14)
						oPrintAnvisa:Say(_nLin,750,  DTOC(STOD(OPINTER->D3_DTVALID)), oFont14)
					else
						oPrintAnvisa:Say(_nLin,500-350,  OPINTER->B1_TIPO   , oFont14)
						oPrintAnvisa:Say(_nLin,550-350,  Transform(OPINTER->D3_QUANT,"@e 999,999,999.999999")  , oFont14)
						oPrintAnvisa:Say(_nLin,650-350,  OPINTER->D3_LOTECTL, oFont14)
						oPrintAnvisa:Say(_nLin,750-350,  DTOC(STOD(OPINTER->D3_DTVALID)), oFont14)
					endif
					_nLin     += _nSaltoL

					if Alltrim(OPINTER->B1_TIPO) == "PI"
						aADD(_aLotesPrd, {OPINTER->D3_COD, OPINTER->B1_TIPO, OPINTER->B1_DESC, OPINTER->D3_LOTECTL, OPINTER->D3_OP,_cPai})
						aADD(_aPiDoPi, {OPINTER->D3_COD, OPINTER->B1_TIPO, OPINTER->B1_DESC, OPINTER->D3_LOTECTL, OPINTER->D3_OP,_cPai})
					endif

					OPINTER->(dbSkip())

				enddo
			
				OPINTER->(dbCloseArea())

				
				if len(_aPiDoPi) > 0
					RPCPR09I(_aPiDoPi) //Imprime Intermedio do Intermediario
					_aPiDoPi := {}
				endif
				

			endif
			
			PRDINTER->(dbCloseArea())

		next

	endif

	_nLin     += _nSaltoL
	oPrintAnvisa:Line(_nLin, 005, _nLin, 835, COR_PRETO)

	If (_nLin + _nSaltoL) > _nLimite
		oPrintAnvisa:EndPage()
		oPrintAnvisa:StartPage()
		RPCPR09C()
	Endif
	
	if MV_PAR10 == 1 //Imprime resumo
		/*
		// PI onde foi usado
		if len(_aLotesPrd) > 0
			_cInLote := ""

			_nLin     += _nSaltoL
			If (_nLin + _nSaltoL) > _nLimite
				oPrintAnvisa:EndPage()
				oPrintAnvisa:StartPage()
				RPCPR09C()
			Endif

			for _nInter := 1 to len(_aLotesPrd)

				if ALLTRIM(_aLotesPrd[_nInter][2]) == "PA"
					Loop
				endif

				if _nInter < len(_aLotesPrd)
					_cInLote += _aLotesPrd[_nInter][4] + "|"
				else
					_cInLote += _aLotesPrd[_nInter][4]
				endif

			next

			_cInLote := "%AND D3_LOTECTL IN " + FormatIn(_cInLote,"|") + "%"

			BeginSql alias 'ONDEFOIUSADO'
				SELECT 
					D3_EMISSAO,
					D3_OP,
					D3_COD,
					D3_QUANT,
					D3_LOTECTL,
					D3_NUMSEQ,
					D3_TM,
					D3_CF,
					B1_TIPO,
					B1_DESC,
					D3_DTVALID 
				FROM  
					%table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
					ON B1_COD = D3_COD AND SB1.%NotDel%
				WHERE 
					D3_FILIAL =  %xFilial:SC2% 
					%Exp:_cInLote%
					AND B1_TIPO IN ('PA','PI')
					AND D3_TM <> '010'
					AND SD3.%NotDel%
					AND D3_ESTORNO = ''
				ORDER BY D3_LOTECTL
			EndSql		

			_cQry := GetLastQuery()[2]

			oPrintAnvisa:Say(_nLin,005, "Produtos Intermediários Onde foi usado:", oFont16AT)
			_nLin     += _nSaltoL
					
			If (_nLin + _nSaltoL) > _nLimite
				oPrintAnvisa:EndPage()
				oPrintAnvisa:StartPage()
				RPCPR09C()
			Endif

			oPrintAnvisa:Say(_nLin,050, "OP", oFont16)
			oPrintAnvisa:Say(_nLin,150, "PRODUTO PI", oFont16)
			oPrintAnvisa:Say(_nLin,550, "TIPO", oFont16)
			oPrintAnvisa:Say(_nLin,600, "QTD", oFont16)
			oPrintAnvisa:Say(_nLin,700, "LOTE", oFont16)
			oPrintAnvisa:Say(_nLin,750, "DTVALIDADE", oFont16)
			_nLin     += _nSaltoL + 3

			If (_nLin + _nSaltoL) > _nLimite
				oPrintAnvisa:EndPage()
				oPrintAnvisa:StartPage()
				RPCPR09C()
			Endif

			while !ONDEFOIUSADO->(EOF())

				if !TEM010(ONDEFOIUSADO->D3_OP)
					ONDEFOIUSADO->(dbSkip())
					Loop
				endif

				If (_nLin + _nSaltoL) > _nLimite
					oPrintAnvisa:EndPage()
					oPrintAnvisa:StartPage()
					RPCPR09C()
				Endif

				oPrintAnvisa:Say(_nLin,050,  ONDEFOIUSADO->D3_OP    , oFont14)
				oPrintAnvisa:Say(_nLin,150,  ONDEFOIUSADO->D3_COD   , oFont14)
				oPrintAnvisa:Say(_nLin,550,  ONDEFOIUSADO->B1_TIPO   , oFont14)
				oPrintAnvisa:Say(_nLin,600,  Transform(ONDEFOIUSADO->D3_QUANT,"@e 999,999,999.999999")  , oFont14)
				oPrintAnvisa:Say(_nLin,700,  ONDEFOIUSADO->D3_LOTECTL, oFont14)
				oPrintAnvisa:Say(_nLin,750,  DTOC(STOD(ONDEFOIUSADO->D3_DTVALID)), oFont14)
				_nLin     += _nSaltoL

				ONDEFOIUSADO->(dbSkip())

			enddo

			ONDEFOIUSADO->(dbCloseArea())

		endif
		*/

		oPrintAnvisa:Line(_nLin, 005, _nLin, 835, COR_PRETO)

		// PA/PI onde foram utilizados (Faturados)
		if len(_aTPPRD) > 0
			_cCodPa   := ""
			_cLoteCtl := ""

			_nLin     += _nSaltoL
			If (_nLin + _nSaltoL) > _nLimite
				oPrintAnvisa:EndPage()
				oPrintAnvisa:StartPage()
				RPCPR09C()
			Endif

			oPrintAnvisa:Say(_nLin,005, "Produtos Acabados Onde foi usado:", oFont16AT)
			_nLin     += _nSaltoL
						
			If (_nLin + _nSaltoL) > _nLimite
				oPrintAnvisa:EndPage()
				oPrintAnvisa:StartPage()
				RPCPR09C()
			Endif

			oPrintAnvisa:Say(_nLin,050, "NF", oFont16)
			oPrintAnvisa:Say(_nLin,150, "PRODUTO PA/PI", oFont16)
			oPrintAnvisa:Say(_nLin,550, "TIPO", oFont16)
			oPrintAnvisa:Say(_nLin,600, "QTD", oFont16)
			oPrintAnvisa:Say(_nLin,700, "LOTE", oFont16)
			oPrintAnvisa:Say(_nLin,750, "DTVALIDADE", oFont16)
			_nLin     += _nSaltoL + 3

			If (_nLin + _nSaltoL) > _nLimite
				oPrintAnvisa:EndPage()
				oPrintAnvisa:StartPage()
				RPCPR09C()
			Endif

			for _nInter := 1 to len(_aTPPRD)
				_nTotal := 0
				_cCodPrd  := _aTPPRD[_nInter][1]
				_cLoteCtl := _aTPPRD[_nInter][4]

				BeginSql alias 'FATURADOONDE'
					SELECT 
						D2_DOC,D2_COD,D2_TP,D2_QUANT,D2_LOTECTL,D2_DTVALID 
					FROM  %table:SD2% SD2 (NOLOCK)
					INNER JOIN SF4010 SF4 (NOLOCK) ON SF4.D_E_L_E_T_ = '' AND SF4.F4_CODIGO = SD2.D2_TES AND F4_DUPLIC = 'S'
					WHERE 
						D2_FILIAL =  %xFilial:SD2% 
						AND D2_COD = %Exp:_cCodPrd%
						AND D2_LOTECTL = %Exp:_cLoteCtl%
						AND SD2.%NotDel%
						AND SD2.D2_TIPO = 'N'
				EndSql		

				while !FATURADOONDE->(EOF())

					If (_nLin + _nSaltoL) > _nLimite
						oPrintAnvisa:EndPage()
						oPrintAnvisa:StartPage()
						RPCPR09C()
					Endif

					oPrintAnvisa:Say(_nLin,050,  FATURADOONDE->D2_DOC    , oFont14)
					oPrintAnvisa:Say(_nLin,150,  FATURADOONDE->D2_COD   , oFont14)
					oPrintAnvisa:Say(_nLin,550,  FATURADOONDE->D2_TP   , oFont14)
					oPrintAnvisa:Say(_nLin,600,  Transform(FATURADOONDE->D2_QUANT,"@e 999,999,999.999999")  , oFont14)
					oPrintAnvisa:Say(_nLin,700,  FATURADOONDE->D2_LOTECTL, oFont14)
					oPrintAnvisa:Say(_nLin,750,  DTOC(STOD(FATURADOONDE->D2_DTVALID)), oFont14)
					_nLin     += _nSaltoL
					_nTotal += FATURADOONDE->D2_QUANT
					FATURADOONDE->(dbSkip())
				enddo
				If _nTotal <> 0
					oPrintAnvisa:Line(_nLin, 005, _nLin, 835, COR_PRETO)
					oPrintAnvisa:Say(_nLin,500,  "TOTAL"  , oFont14)
					oPrintAnvisa:Say(_nLin,600,  Transform(_nTotal,"@E 999,999,999.999999")  , oFont14)
					_nLin     += _nSaltoL
				EndIf
				FATURADOONDE->(dbCloseArea())
			next
		endif
	endif

	oPrintAnvisa:EndPage()

return
/*/{Protheus.doc} ValidPerg
Verifica as perguntas no dicionário SX1, as criando, caso não existam.
@author Fernando Bombardi
@since 26/07/2023
@type function
@version 1.00
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aArea     := GetArea()
	local _aTam      := {}
	local _aRegs     := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	_cPerg := PADR(_cPerg,len((_cAliasSX1)->X1_GRUPO))

	_aTam  := TamSX3("D3_EMISSAO")
	AADD(_aRegs,{_cPerg,"01","Da Data Produção  ?","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	AADD(_aRegs,{_cPerg,"02","Até Data Produção ?","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSX3("C2_PRODUTO")
	AADD(_aRegs,{_cPerg,"03","Do Produto?"        ,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par03",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SB1"   ,"",""})
	AADD(_aRegs,{_cPerg,"04","Ao Produto?"        ,"","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SB1"   ,"",""})
	_aTam  := TamSX3("D3_OP"     )
	AADD(_aRegs,{_cPerg,"05","Da Ordem de Prod. ?","","","mv_ch5",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par05",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SC2"   ,"",""})
	AADD(_aRegs,{_cPerg,"06","Até a Ordem Prod. ?","","","mv_ch6",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par06",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SC2"   ,"",""})
	_aTam  := TamSX3("D3_LOTECTL")
	AADD(_aRegs,{_cPerg,"07","Do Lote?"           ,"","","mv_ch7",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par07",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"08","Ao Lote?"           ,"","","mv_ch8",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	_aTam            := {1,0,"N"}
	AADD(_aRegs,{_cPerg,"09","Imprimir descrição?","","","mv_ch9",_aTam[03],_aTam[01],_aTam[02],0,"C","naovazio()","mv_par09","Sim"    ,"","","","","Não"               ,"","","","",""      ,"","","","","","","","","","","","","",""   ,""})
	_aTam            := {1,0,"N"}
	AADD(_aRegs,{_cPerg,"10","Imprimir resumo?","","","mv_chA"   ,_aTam[03],_aTam[01],_aTam[02],0,"C","naovazio()","mv_par10","Sim"    ,"","","","","Não"               ,"","","","",""      ,"","","","","","","","","","","","","",""   ,""})

	for i := 1 to len(_aRegs)
		if !(_cAliasSX1)->(dbSeek(_cPerg+_aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= Len(_aRegs[i])
						FieldPut(j,_aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_aArea)
return


/*/{Protheus.doc} RPCPR09C
	Rotina para imprimir cabeçalho
	@type  Function
	@author Fernando Bombardi
	@since 31/07/2023
	@version 1.0
/*/
Static Function RPCPR09C()

    oPrintAnvisa:SayBitmap(10,10,cBTM,50,35)        // logo
    oPrintAnvisa:Say(15,300, "Relatório de Rastreabilidade - Anvisa", oFont16AT)
	_nLin := 50	

Return


/*/{Protheus.doc} RPCPR09I
	Imprimi Intermedia do Intermediario
	@type function
	@author Fernando Bombardi
	@since 31/07/2023
	@version 1.0
/*/
Static Function RPCPR09I(_aTPPRD)
Local _nInter  := 1

	for _nInter := 1 to len(_aTPPRD)

		if ALLTRIM(_aTPPRD[_nInter][2]) == "PA"
			Loop
		endif
		If !Empty(ALLTRIM(_aTPPRD[_nInter][4]))
			RPCPR09X(ALLTRIM(_aTPPRD[_nInter][4]),ALLTRIM(_aTPPRD[_nInter][6]))
		EndIf

	next

Return 

/*/{Protheus.doc} RPCPR09X
	Função recursiva para impressão do PI do PI
	@type Function
	@author Fernando Bombardi
	@since 31/07/2023
	@version 1.0
/*/
Static Function RPCPR09X(_cLoteCtl,_PrdPai)
Local _aPiDoPi := {}
Local cAliasPI := GetNextAlias()
Local cAliasMP := GetNextAlias()
Local _lPiDoPi := .F.
Local _nItAux  := 1

	BeginSql alias cAliasPI
		SELECT 
			D3_EMISSAO,
			D3_OP,
			D3_COD,
			D3_QUANT,
			D3_LOTECTL,
			D3_NUMSEQ,
			D3_TM,
			D3_CF,
			B1_TIPO,
			B1_DESC,
			D3_DTVALID 
		FROM  
			%table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
			ON B1_COD = D3_COD AND SB1.%NotDel%
		WHERE 
			D3_FILIAL =  %xFilial:SC2%
			AND D3_LOTECTL = %Exp:ALLTRIM(_cLoteCtl)%
			AND B1_TIPO IN ('PA','PI')
			AND D3_TM = '010'
			AND SD3.%NotDel%
			AND D3_ESTORNO = ''
		ORDER BY D3_NUMSEQ, D3_TM
	EndSql		

	_cQry := GetLastQuery()[2]

	if !(cAliasPI)->(EOF())

		_nLin     += _nSaltoL
		oPrintAnvisa:Line(_nLin, 005, _nLin, 835, COR_PRETO)
		_nLin     += _nSaltoL

		If (_nLin + _nSaltoL) > _nLimite
			oPrintAnvisa:EndPage()
			oPrintAnvisa:StartPage()
			RPCPR09C()
		Endif

		oPrintAnvisa:Say(_nLin,005, "Produto Intermediarios Sub-Estrutura "+ Alltrim(_PrdPai) + ":", oFont16AT)
		_nLin     += _nSaltoL

		If (_nLin + _nSaltoL) > _nLimite
			oPrintAnvisa:EndPage()
			oPrintAnvisa:StartPage()
			RPCPR09C()
		Endif

		oPrintAnvisa:Say(_nLin,100, "Produto:", oFont16AT)
		oPrintAnvisa:Say(_nLin,165,  ALLTRIM((cAliasPI)->D3_COD), oFont15)
		_cPaiPI := (cAliasPI)->D3_COD
		if MV_PAR09 == 1
			oPrintAnvisa:Say(_nLin,235,  ALLTRIM((cAliasPI)->B1_DESC), oFont15)
		endif
		oPrintAnvisa:Say(_nLin,550, "Tipo:", oFont16AT)
		oPrintAnvisa:Say(_nLin,600,  ALLTRIM((cAliasPI)->B1_TIPO), oFont15)
		oPrintAnvisa:Say(_nLin,700, "Lote:", oFont16AT)
		oPrintAnvisa:Say(_nLin,750,  ALLTRIM((cAliasPI)->D3_LOTECTL), oFont15)
		_nLin     += _nSaltoL

		If (_nLin + _nSaltoL) > _nLimite
			oPrintAnvisa:EndPage()
			oPrintAnvisa:StartPage()
			RPCPR09C()
		Endif

		oPrintAnvisa:Say(_nLin,100, "OP:", oFont16AT)
		oPrintAnvisa:Say(_nLin,165,  ALLTRIM((cAliasPI)->D3_OP), oFont15)
		_nLin     += _nSaltoL + 3

		If (_nLin + _nSaltoL) > _nLimite
			oPrintAnvisa:EndPage()
			oPrintAnvisa:StartPage()
			RPCPR09C()
		Endif

		oPrintAnvisa:Say(_nLin,100, "Máterias Primas Consumidas PI:", oFont16AT)
		_nLin     += _nSaltoL

		If (_nLin + _nSaltoL) > _nLimite
			oPrintAnvisa:EndPage()
			oPrintAnvisa:StartPage()
			RPCPR09C()
		Endif

		oPrintAnvisa:Say(_nLin,100, "CÓDIGO", oFont16)
		if MV_PAR09 == 1
			oPrintAnvisa:Say(_nLin,200, "DESCRIÇÃO", oFont16)
			oPrintAnvisa:Say(_nLin,550, "TIPO", oFont16)
			oPrintAnvisa:Say(_nLin,600, "QTD", oFont16)
			oPrintAnvisa:Say(_nLin,700, "LOTE", oFont16)
			oPrintAnvisa:Say(_nLin,750, "DTVALIDADE", oFont16)
		else
			oPrintAnvisa:Say(_nLin,550-350, "TIPO", oFont16)
			oPrintAnvisa:Say(_nLin,600-350, "QTD", oFont16)
			oPrintAnvisa:Say(_nLin,700-350, "LOTE", oFont16)
			oPrintAnvisa:Say(_nLin,750-350, "DTVALIDADE", oFont16)
		endif
		_nLin     += _nSaltoL

		If (_nLin + _nSaltoL) > _nLimite
			oPrintAnvisa:EndPage()
			oPrintAnvisa:StartPage()
			RPCPR09C()
		Endif

		BeginSql alias cAliasMP
			SELECT 
				MAX(D3_EMISSAO) D3_EMISSAO,D3_OP,D3_COD,SUM(D3_QUANT) D3_QUANT,D3_LOTECTL,D3_TM,
				D3_CF,B1_TIPO,B1_DESC,D3_DTVALID 
			FROM  
				%table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
				ON B1_COD = D3_COD AND SB1.%NotDel%
			WHERE 
				D3_FILIAL =  %xFilial:SC2%  
				AND D3_OP = %Exp:ALLTRIM((cAliasPI)->D3_OP)%
				AND SD3.%NotDel%
				AND D3_ESTORNO = ''
			GROUP BY D3_OP,D3_COD,D3_LOTECTL,D3_TM,D3_CF,B1_TIPO,B1_DESC,D3_DTVALID 
			ORDER BY D3_OP, D3_COD, D3_TM
		EndSql

		_cQry := GetLastQuery()[2]

		while !(cAliasMP)->(EOF())

			if Alltrim((cAliasMP)->D3_TM) == "010"
				(cAliasMP)->(dbSkip())
				Loop
			endif

			If (_nLin + _nSaltoL) > _nLimite
				oPrintAnvisa:EndPage()
				oPrintAnvisa:StartPage()
				RPCPR09C()
			Endif

			oPrintAnvisa:Say(_nLin,100,  (cAliasMP)->D3_COD    , oFont14)
			if MV_PAR09 == 1
				oPrintAnvisa:Say(_nLin,200,  (cAliasMP)->B1_DESC   , oFont14)
				oPrintAnvisa:Say(_nLin,550,  (cAliasMP)->B1_TIPO   , oFont14)
				oPrintAnvisa:Say(_nLin,600,  Transform((cAliasMP)->D3_QUANT,"@e 999,999,999.999999")  , oFont14)
				oPrintAnvisa:Say(_nLin,700,  (cAliasMP)->D3_LOTECTL, oFont14)
				oPrintAnvisa:Say(_nLin,750,  DTOC(STOD((cAliasMP)->D3_DTVALID)), oFont14)
			else
				oPrintAnvisa:Say(_nLin,550-350,  (cAliasMP)->B1_TIPO   , oFont14)
				oPrintAnvisa:Say(_nLin,600-350,  Transform((cAliasMP)->D3_QUANT,"@e 999,999,999.999999")  , oFont14)
				oPrintAnvisa:Say(_nLin,700-350,  (cAliasMP)->D3_LOTECTL, oFont14)
				oPrintAnvisa:Say(_nLin,750-350,  DTOC(STOD((cAliasMP)->D3_DTVALID)), oFont14)
			endif
			_nLin     += _nSaltoL

			if Alltrim((cAliasMP)->B1_TIPO) == "PI"
				_aAux := {}
				aADD(_aLotesPrd, {(cAliasMP)->D3_COD, (cAliasMP)->B1_TIPO, (cAliasMP)->B1_DESC, (cAliasMP)->D3_LOTECTL, (cAliasMP)->D3_OP,_cPaiPI})
				aADD(_aPiDoPi, {(cAliasMP)->D3_COD, (cAliasMP)->B1_TIPO, (cAliasMP)->B1_DESC, (cAliasMP)->D3_LOTECTL, (cAliasMP)->D3_OP,_cPaiPI})
				_lPiDoPi := .T.
			endif

			(cAliasMP)->(dbSkip())

		enddo

		(cAliasMP)->(dbCloseArea())

		if _lPiDoPi //len(_aPiDoPi) > 0
			_aAux := aClone(_aPiDoPi)
			_lPiDoPi := .F.
			_aPiDoPi := {}
			for _nItAux := 1 to len(_aAux)
				If !Empty(ALLTRIM(_aAux[_nItAux][4]))
					RPCPR09X(_aAux[_nItAux][4],_aAux[_nItAux][6]) //Imprime Intermedio do Intermediario
				EndIf
			next
		endif

	endif

	(cAliasPI)->(dbCloseArea())

Return

/*/{Protheus.doc} TEM010
	Verifica se o lote tem tipo de movimento 010 - Produção se o lote não tive nenhuma produção retorna .F.
	@type  Function
	@author Fernando Bombardi
	@since 02/08/2023
	@version 1.0
/*/
Static Function TEM010(_cOp)
Local _aArea := GetArea()
Local _lTem010 := .F.

	BeginSql alias 'TEM010'
		SELECT 
			D3_EMISSAO,
			D3_OP,
			D3_COD,
			D3_QUANT,
			D3_LOTECTL,
			D3_NUMSEQ,
			D3_TM,
			D3_CF,
			B1_TIPO,
			B1_DESC,
			D3_DTVALID 
		FROM  
			%table:SD3% SD3 (NOLOCK) INNER JOIN  %table:SB1% SB1 (NOLOCK)
			ON B1_COD = D3_COD AND SB1.%NotDel%
		WHERE 
			D3_FILIAL =  %xFilial:SC2%
			AND D3_OP = %Exp:ALLTRIM(_cOp)%
			AND B1_TIPO IN ('PA','PI')
			AND D3_TM = '010'
			AND SD3.%NotDel%
			AND D3_ESTORNO = ''
		ORDER BY D3_NUMSEQ, D3_TM
	EndSql	

	if TEM010->(!EOF())
		_lTem010 := .T.
	endif

	TEM010->(dbCloseArea())

RestArea(_aArea)
Return(_lTem010)
