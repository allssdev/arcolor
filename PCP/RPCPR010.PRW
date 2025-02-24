#include "totvs.ch"
#include "FWPrintSetup.ch"
#include "rptdef.ch"

#Define COR_PRETO   RGB(000, 000, 000)

/*/{Protheus.doc} RPCPR009
    Relatório de rastreabilidade Anvisa para notas faturadas
    @type  Function
    @author Diego Rodrigues
    @since 28/09/2023
    @version 1.0
    /*/
User Function RPCPR010()
	private _cRotina := "RPCPR010"
	private _cPerg   := _cRotina
	private _aTPPRD  := {}
	Private _cUsrId  := Alltrim(RetCodUsr())

	Private _cSpool         := GetTempPath()
	Private _cPdf           := "rel_rast_notas_"  + dToS(dDataBase) + "_" + StrTran(Time(), ':', '-') + ".pdf"

	ValidPerg()
	if Pergunte(_cPerg)

		if MV_PAR03 == 1 .AND. !_cUsrId $ Alltrim(SuperGetMv("MV_XIMPRAS",.F.,"000000"))
			MsgAlert("Você não possue permissão para imprimir a descrição dos produto. O relatório será gerado apenas com os códigos.","[RPCPR10_001] - Atenção")
			MV_PAR03 := 2
		endif

		if Select('RASTLOTE') > 0
			RASTLOTE->(dbCloseArea())
		endif

		if !RPCPR10D() 
			Return
		endif

		Aviso("[RPCPR10] - Fim de Processamento","O relatório foi gerado com sucesso!" + Chr(10) + chr(13) +;
		Chr(10) + chr(13) +;
		"Localização do arquivo: " + _cSpool + _cPdf ,{"Ok"},3)

	else

		MsgAlert("Rotina cancelada pelo usuário.","Atenção")

	endif
	
 return

/*/{Protheus.doc} RPCPR10D
Carrega os dados para o relatório
@author Fernando Bombardi
@since 26/07/2023
@type function
@version 1.00
/*/
static function RPCPR10D()
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
            B8_PRODUTO, B8_LOTECTL, B8_SALDO
        FROM SB8010 SB8 (NOLOCK)
        WHERE SB8.D_E_L_E_T_ = ''
             AND SB8.B8_LOTECTL >= %Exp:MV_PAR01%
             AND SB8.B8_LOTECTL <= %Exp:MV_PAR02%
	EndSql

	if !RASTLOTE->(EOF())

		oPrintAnvisa := FWMSPrinter():New(_cPdf, IMP_PDF, lAdjustToLegacy,, lDisableSetup,.t. , , , , , .F., )
		oPrintAnvisa:SetResolution(72)
		oPrintAnvisa:SetLandScape()		// Orientação do Papel (Retrato)
		oPrintAnvisa:SetPaperSize(9)	// Tamanho da Folha (9 = A4)	
		oPrintAnvisa:cPathPDF := _cSpool // Caso seja utilizada impressão em IMP_PDF

		while !RASTLOTE->(EOF())

			_aLotesPrd := {}

			BeginSql alias 'INSUMOS'
				SELECT 
					D3_OP,D3_COD,
					SUM(D3_QUANT) D3_QUANT,
					D3_LOTECTL,	D3_TM,
					D3_CF,B1_TIPO,
					B1_DESC,D3_DTVALID,
                    B8_SALDO
				FROM  %table:SD3% SD3 (NOLOCK) 
                INNER JOIN  %table:SB1% SB1 (NOLOCK) ON B1_COD = D3_COD AND SB1.%NotDel%
                INNER JOIN SB8010 SB8 (NOLOCK) ON SB8.%NotDel% AND B8_PRODUTO = B1_COD AND B8_LOCAL = D3_LOCAL
				AND B8_LOTECTL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				WHERE D3_FILIAL =  %xFilial:SD3%  
					AND D3_LOTECTL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
					AND SD3.%NotDel%
					AND D3_CF = 'PR0'
					AND D3_ESTORNO = ''
                GROUP BY D3_OP,D3_COD,D3_LOTECTL,D3_TM,D3_CF,B1_TIPO,
					     B1_DESC,D3_DTVALID, B8_SALDO
				ORDER BY D3_COD, D3_TM
			EndSql		
			
			if !INSUMOS->(EOF())
				while !INSUMOS->(EOF())
					if Alltrim(INSUMOS->B1_TIPO ) $ "PI/PA"
						aADD(_aLotesPrd, {INSUMOS->D3_COD, INSUMOS->B1_TIPO, INSUMOS->B1_DESC, INSUMOS->D3_LOTECTL, INSUMOS->D3_OP, INSUMOS->D3_QUANT, INSUMOS->B8_SALDO})
						aADD(_aTPPRD, {INSUMOS->D3_COD, INSUMOS->B1_TIPO, INSUMOS->B1_DESC, INSUMOS->D3_LOTECTL, INSUMOS->D3_OP, INSUMOS->D3_QUANT,INSUMOS->B8_SALDO})
					endif
					INSUMOS->(dbSkip())
				enddo
				RPCPR10P()
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

/*/{Protheus.doc} RPCPR10P
Imprime a rastreabilidade
@author Fernando Bombardi
@since 26/07/2023
@type function
@version 1.00
@see https://allss.com.br
/*/
static function RPCPR10P()
Local _nInter   := 0

	INSUMOS->(dbGoTop())
	while !INSUMOS->(EOF())

		If (_nLin + _nSaltoL) > _nLimite
			oPrintAnvisa:EndPage()
			oPrintAnvisa:StartPage()
			RPCPR10C()
		else
			oPrintAnvisa:StartPage()
			RPCPR10C()
		EndIf

		_nPosPA := aScan(_aTPPRD,{|x|AllTrim(x[02])=="PA"})

		oPrintAnvisa:Say(_nLin,005, "Produto:", oFont16AT)
		oPrintAnvisa:Say(_nLin,080,  ALLTRIM(_aTPPRD[_nPosPA][1]), oFont15)

		if MV_PAR03 == 1
			oPrintAnvisa:Say(_nLin,150,  ALLTRIM(_aTPPRD[_nPosPA][3]), oFont15)
		endif

		oPrintAnvisa:Say(_nLin,550, "Tipo:", oFont16AT)
		oPrintAnvisa:Say(_nLin,600,  ALLTRIM(_aTPPRD[_nPosPA][2]), oFont15)

		oPrintAnvisa:Say(_nLin,700, "Lote:", oFont16AT)
		oPrintAnvisa:Say(_nLin,750,  ALLTRIM(_aTPPRD[_nPosPA][4]), oFont15)
		_nLin     += _nSaltoL

		oPrintAnvisa:Say(_nLin,005, "OP:", oFont16AT)
		oPrintAnvisa:Say(_nLin,080,  ALLTRIM(_aTPPRD[_nPosPA][5]), oFont15)

        oPrintAnvisa:Say(_nLin,250, "QTD Produzida:", oFont16AT)
		oPrintAnvisa:Say(_nLin,400,  cValtoChar(_aTPPRD[_nPosPA][6]), oFont15)

        oPrintAnvisa:Say(_nLin,550, "Saldo:", oFont16AT)
		oPrintAnvisa:Say(_nLin,600,  cValToChar(_aTPPRD[_nPosPA][7]), oFont15)
		_nLin     += _nSaltoL + 3
        INSUMOS->(DbSkip())
	enddo
    
	_nLin     += _nSaltoL
	oPrintAnvisa:Line(_nLin, 005, _nLin, 835, COR_PRETO)

	If (_nLin + _nSaltoL) > _nLimite
		oPrintAnvisa:EndPage()
		oPrintAnvisa:StartPage()
		RPCPR10C()
	Endif

	//if MV_PAR03 == 1 //Imprime resumo

	oPrintAnvisa:Line(_nLin, 005, _nLin, 835, COR_PRETO)

		// PA/PI onde foram utilizados (Faturados)
		if len(_aTPPRD) > 0
			_cCodPa   := ""
			_cLoteCtl := ""

			_nLin     += _nSaltoL
			If (_nLin + _nSaltoL) > _nLimite
				oPrintAnvisa:EndPage()
				oPrintAnvisa:StartPage()
				RPCPR10C()
			Endif

			for _nInter := 1 to len(_aTPPRD)

				_cCodPrd  := _aTPPRD[_nInter][1]
				_cLoteCtl := _aTPPRD[_nInter][4]

				BeginSql alias 'FATURADOONDE'
					SELECT 
						D2_DOC,	D2_COD,	D2_TP,D2_QUANT,	D2_LOTECTL,	D2_DTVALID 
					FROM  
						%table:SD2% SD2 (NOLOCK)
					WHERE D2_FILIAL =  %xFilial:SD2% 
						AND D2_COD = %Exp:_cCodPrd%
						AND D2_LOTECTL = %Exp:_cLoteCtl%
						AND SD2.%NotDel%
				EndSql		

				while !FATURADOONDE->(EOF())

					If (_nLin + _nSaltoL) > _nLimite
						oPrintAnvisa:EndPage()
						oPrintAnvisa:StartPage()
						RPCPR10C()
					Endif

					oPrintAnvisa:Say(_nLin,050,  FATURADOONDE->D2_DOC    , oFont14)
					oPrintAnvisa:Say(_nLin,150,  FATURADOONDE->D2_COD   , oFont14)
					oPrintAnvisa:Say(_nLin,550,  FATURADOONDE->D2_TP   , oFont14)
					oPrintAnvisa:Say(_nLin,600,  Transform(FATURADOONDE->D2_QUANT,"@e 999,999,999.999999")  , oFont14)
					oPrintAnvisa:Say(_nLin,700,  FATURADOONDE->D2_LOTECTL, oFont14)
					oPrintAnvisa:Say(_nLin,750,  DTOC(STOD(FATURADOONDE->D2_DTVALID)), oFont14)
					_nLin     += _nSaltoL

					FATURADOONDE->(dbSkip())
				enddo

				FATURADOONDE->(dbCloseArea())
			next

		endif

        If (_nLin + _nSaltoL) > _nLimite
		oPrintAnvisa:EndPage()
		oPrintAnvisa:StartPage()
		RPCPR10C()
	    Endif

	    oPrintAnvisa:Line(_nLin, 005, _nLin, 835, COR_PRETO)

        BeginSql alias 'FATURADOTOT'
            SELECT 
                D2_COD,	D2_TP,SUM(D2_QUANT) D2_QUANT,D2_LOTECTL
            FROM  
                %table:SD2% SD2 (NOLOCK)
            WHERE D2_FILIAL =  %xFilial:SD2% 
                AND SD2.D2_COD = %Exp:_cCodPrd%
                AND SD2.D2_LOTECTL = %Exp:_cLoteCtl%
                AND SD2.%NotDel%
				AND SD2.D2_LOCAL = '01'
            GROUP BY D2_COD,D2_TP,D2_LOTECTL
		EndSql		

            while !FATURADOTOT->(EOF())

                If (_nLin + _nSaltoL) > _nLimite
                    oPrintAnvisa:EndPage()
                    oPrintAnvisa:StartPage()
                    RPCPR10C()
                Endif

                oPrintAnvisa:Say(_nLin,500,  "TOTAL"  , oFont14)
                oPrintAnvisa:Say(_nLin,600,  Transform(FATURADOTOT->D2_QUANT,"@e 999,999,999.999999")  , oFont14)
                _nLin     += _nSaltoL

                FATURADOTOT->(dbSkip())
            enddo

            FATURADOTOT->(dbCloseArea())

	//endif
    if Select('INSUMOS') > 0
			INSUMOS->(DbCloseArea())
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

    _aTam  := TamSX3("D3_LOTECTL")
	AADD(_aRegs,{_cPerg,"01","Do Lote?"           ,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"02","Ao Lote?"           ,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","NAOVAZIO()","mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	_aTam            := {1,0,"N"}
	AADD(_aRegs,{_cPerg,"03","Imprimir descrição?","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"C","naovazio()","mv_par03","Sim"    ,"","","","","Não"               ,"","","","",""      ,"","","","","","","","","","","","","",""   ,""})
	
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


/*/{Protheus.doc} RPCPR10C
	Rotina para imprimir cabeçalho
	@type  Function
	@author Fernando Bombardi
	@since 31/07/2023
	@version 1.0
/*/
Static Function RPCPR10C()

    oPrintAnvisa:SayBitmap(10,10,cBTM,50,35)        // logo
    oPrintAnvisa:Say(15,300, "Relatório de Rastreabilidade - Anvisa", oFont16AT)
	_nLin := 50	

Return
