#include "totvs.ch"
#include "FWPrintSetup.ch"
#include "rptdef.ch"

/*/{Protheus.doc} RESTR009
@description Ficha Controle Apontamento intermediario
@description Utilizado ponto de entrada MT681INC
@author Diego Rodrigues Pereira (ALLSS Soluções em Sistemas)
@since 11/02/2025
@type function
@version 1.00
@see https://allss.com.br
@history 11/02/2025, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação para a impressão a partir da rotina MATA681(roteiro de operações)
/*/

User Function RESTR009()
	private _cRotina := "RESTR009"
	private _cPerg   := _cRotina
	private _cAlias  := GetNextAlias()
	Private clog := ""
	
	If AllTrim(FunName())=="MATA681" 
		
		MV_PAR01 := SC2->C2_PRODUTO
		MV_PAR02 := SC2->C2_PRODUTO
		MV_PAR03 := SH6->H6_OP
		MV_PAR04 := SH6->H6_OP
		MV_PAR05 := SH6->H6_DATAINI
		MV_PAR06 := SH6->H6_DTAPONT
		MV_PAR07 := ""
		MV_PAR08 := "ZZ"
		MV_PAR09 := ""
		MV_PAR10 := "ZZZZZZZZZ"
		//Carrega os dados para fins de impressão
		ChrFicha()
		//Imprime a ficha pallet
		PrtFicha()	
	Else
		ValidPerg()
		if Pergunte(_cPerg)
			if Select(_cAlias) > 0
			(_cAlias)->(dbCloseArea())
			endif
		//Carrega os dados para fins de impressão
		ChrFicha()
		//Imprime a ficha de controle produto intermediario
		PrtFicha()
		endif
	EndIf
	
 return
/*/{Protheus.doc} ChrFicha
@description Carrega os dados a serem impressos.
@author Diego Rodrigues Pereira (ALLSS Soluções em Sistemas)
@since 11/02/2025
@type function
@version 1.00
@see https://allss.com.br
/*/
static function ChrFicha()
	BeginSql alias _cAlias
		%noparser%
        SELECT
            RTRIM(H6_PRODUTO) PRODUTO
            ,RTRIM(B1_DESC) DESCRICAO
            ,RTRIM(ISNULL(H6_QTDPROD,0)) QUANTIDADE
            ,RTRIM(H6_OP) OP
            ,RTRIM(H6_OP) LOTE
            ,RTRIM(H6_OPERAC) OPERACAO
            ,RTRIM(VI_DESCRI) DESC_OPER
            ,RTRIM(H6_DATAINI) DATA_INI
            ,RTRIM(H6_DATAFIN) DATA_FIM
            ,RTRIM(H6_DTAPONT) DATA_APO
        FROM SH6010 SH6 (NOLOCK)
        INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = H6_PRODUTO
        INNER JOIN SVI010 SVI (NOLOCK) ON SVI.D_E_L_E_T_ = '' AND VI_CODIGO = H6_OPERAC
        WHERE SH6.D_E_L_E_T_ = ''
            AND H6_PRODUTO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
            AND H6_OP      BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
            AND H6_DTAPONT BETWEEN %Exp:DTOS(MV_PAR05)% AND %Exp:DTOS(MV_PAR06)%
            AND B1_TIPO    BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
	EndSql
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",GetLastQuery()[02])
return
/*/{Protheus.doc} PrtFicha
@description Imprime a Ficha Pallet.
@author Diego Rodrigues Pereira (ALLSS Soluções em Sistemas)
@since 22/06/2021
@type function
@version 1.00
@see https://allss.com.br
/*/
static function PrtFicha()
	Local   nInc
	Local 	nFic
	Local   nNum := 0
	Local   lAdjustToLegacy := .F.
	Local   lDisableSetup   := .T.
	Local   nRegs           := 0
	Local   cBTM            := FisxLogo("1")
	Local   cName           := _cRotina
	
	Private cSpool          := GetTempPath()
	Private cPdf            := ""
	Private oFont10         := TFont():New("Arial" ,,10,,.F.,,,,,.F.)
	Private oFont16         := TFont():New("Areal" ,,16,,.F.,,,,,.F.)
    Private oFont16AT        := TFont():New("Areal" ,,16,,.T.,,,,,.F.)
	Private oFont22         := TFont():New("Areal" ,,22,,.F.,,,,,.F.)
	Private oFont15	        := TFont():New("Areal" ,,15,,.F.,,,,,.F.)
	Private oFont14         := TFont():New("Arial" ,,14,,.F.,,,,,.F.)
    

	for nInc := 1 to 1000
		cPDF := cName+"_"+ALLTRIM((_cAlias)->OP)
		if !File(cSpool+cPDF+".PDF")
			exit
		endif
	next
	
	If AllTrim(FunName())=="MATA681"  
		oPrinter := FWMSPrinter():New(cPdf, IMP_SPOOL, lAdjustToLegacy,, lDisableSetup,.t. , , , , , .F., )
		oPrinter:Setup()
	Else
		oPrinter := FWMSPrinter():New(cPdf, IMP_SPOOL, lAdjustToLegacy,, lDisableSetup,.t. , , , , , .F., )
		oPrinter:Setup()
	EndIF
	//oPrinter:SetParm( "-RFS")
	oPrinter:SetResolution(72)
	oPrinter:SetLandsCape()
	oPrinter:SetPaperSize(DMPAPER_A4)
	//oPrinter:SetMargin(20,20,20,20) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:cPathPDF := cSpool // Caso seja utilizada impressão em IMP_PDF
	//oPrinter:Box( 30, 10, 500, 700, "-4")
	(_cAlias)->(dbGoTop())
	while !(_cAlias)->(EOF())

		nNum := 1
		Private 	cLote  := ALLTRIM((_cAlias)->LOTE)
		Private 	cData  := DTOC(STOD((_cAlias)->DATA_APO)) 
		//Private 	cPag	:= (_cAlias)->PAG

		For nFic := 1 to nNum
    
		    oPrinter:StartPage()
			nRegs++

            oPrinter:SayBitmap(5,10,cBTM,50,35)        // logo
            //Titulo
            oPrinter:Say(15,70, "IDENTIFICAÇÃO DO PRODUTO", oFont16AT)

			//Box Margem
			//oPrinter:Box(45, 5, 400, 420)
		
			//Box Identificação
			oPrinter:Box(50,10, 145, 420)
			oPrinter:Say(55,10, "OP Nº:", oFont16AT)
			oPrinter:Say(55,70, ALLTRIM((_cAlias)->OP), oFont16)

			//Qrcode
			oPrinter:QrCode(105,345,ALLTRIM((_cAlias)->OP),0075)
			//primeira linha
			oPrinter:Say(80,10, "DATA PROD:", oFont16AT)
			oPrinter:Say(80,85, cData, oFont15)

			oPrinter:Say(105,10, "PRODUTO:", oFont16AT)
			oPrinter:Say(105,90, ALLTRIM((_cAlias)->PRODUTO), oFont16)

			oPrinter:Say(105,150, Substr(ALLTRIM((_cAlias)->DESCRICAO),1,33), oFont14)

			oPrinter:Say(120,10, "LOTE Nº:", oFont16AT)
			oPrinter:Say(120,90, ALLTRIM((_cAlias)->LOTE),   oFont16)

            oPrinter:Say(120,225, "OPERACAO:", oFont16AT)
			oPrinter:Say(120,300, ALLTRIM((_cAlias)->OPERACAO), oFont15)

			//Box rastreabilidade
            oPrinter:Box(145,10, 170, 420)
			oPrinter:Say(145,60, "RASTREABILIDADE DO PROCESSO", oFont16AT)
						
			//Box Manipulação
			oPrinter:Box(170,10, 300, 420)
            oPrinter:Say(168,60, "MANIPULAÇÃO", oFont16AT)
			oPrinter:Say(185,10, "OP BASE Nº", oFont16)
			oPrinter:Say(185,115, ALLTRIM((_cAlias)->OP), oFont16 )
			
			oPrinter:Say(205,10,"COD BASE:", oFont16)
			oPrinter:Say(205,100, ALLTRIM((_cAlias)->PRODUTO), oFont16)
			
	    	oPrinter:Say(225,10,"DATA INICIO:", oFont16)
			oPrinter:Say(225,135, DTOC(STOD((_cAlias)->DATA_INI)), oFont16)

            oPrinter:Say(245,10,"DATA TERMINO:", oFont16)
			oPrinter:Say(245,145, DTOC(STOD((_cAlias)->DATA_FIM)), oFont16)

           	oPrinter:Say(265,10,"RESPONSAVEL:", oFont16)
			oPrinter:Say(265,130,"        ", oFont16)

            oPrinter:Say(180,285,"AMOSTRA RECOLHIDA?", oFont14)
            oPrinter:Box(205,285, 225, 335)
			oPrinter:Say(200,287, "SIM", oFont14)
            oPrinter:Box(205,335, 225, 385)
            oPrinter:Say(200,337,"NAO", oFont14)
			
            oPrinter:Say(225,310,"QTDE KG", oFont14)
            oPrinter:Box(250,285, 275, 410)
			oPrinter:Say(252,295, (_cAlias)->QUANTIDADE, oFont14)

                     
            //Box Qualidade
			oPrinter:Box(300,10, 395, 420)
            oPrinter:Say(297,60,"QUALIDADE", oFont16AT)
			oPrinter:Say(315,10,"DATA INICIO:", oFont16)
			oPrinter:Say(315,135,  "    /     /     ", oFont16)

            oPrinter:Say(335,10,"DATA TERMINO:", oFont16)
			oPrinter:Say(335,145,  "    /     /     ", oFont16)

			oPrinter:Say(355,10,"RESPONSAVEL:", oFont16)
			oPrinter:Say(355,130,"        ", oFont16)
            
            //Box Controle da Qualidade
            oPrinter:Box(300,300, 390, 410) 
			oPrinter:Say(295,305,"CONTROLE DE", oFont14)
            oPrinter:Say(304,315,"QUALIDADE:", oFont14)
			oPrinter:Box(328,305, 343, 315)               
			oPrinter:Say(318,325,"APROVADO:", oFont14)
			
            oPrinter:Box(348,305, 363, 315) 
			oPrinter:Say(335,325,"REPROVADO", oFont14)
			
            oPrinter:Box(368,305, 383, 315) 
			oPrinter:Say(355,325,"RETRABALHO", oFont14)

             //Box Envase
			oPrinter:Box(395,10, 480, 420)
            oPrinter:Say(393,60,"ENVASE", oFont16AT)
			oPrinter:Say(410,10,"DATA INICIO:", oFont16)
			oPrinter:Say(410,135,  "    /     /     ", oFont16)

            oPrinter:Say(430,10,"DATA TERMINO:", oFont16)
			oPrinter:Say(430,145,  "    /     /     ", oFont16)

			oPrinter:Say(450,10,"RESPONSAVEL:", oFont16)
			oPrinter:Say(450,130,"        ", oFont16)

            oPrinter:Say(393,330,"QTDE UNIT", oFont14)
            oPrinter:Box(415,300, 432, 410)
			oPrinter:Say(410,305, " ", oFont14)

            oPrinter:Say(433,330,"QTDE CXS", oFont14)
            oPrinter:Box(455,300, 475, 410)
			oPrinter:Say(450,305, " ", oFont14)

            //IMPRESSAO PAGINA 2 ////////////////////////////////////////////////////////////////

            oPrinter:SayBitmap(5,435,cBTM,50,35)        // logo
            //Titulo
            oPrinter:Say(15,495, "IDENTIFICAÇÃO DO PRODUTO", oFont16AT)

			//Box Identificação
			oPrinter:Box(50,430, 145, 840)
			oPrinter:Say(55,430, "OP Nº:", oFont16AT)
			oPrinter:Say(55,500, ALLTRIM((_cAlias)->OP), oFont16)

			//Qrcode
			oPrinter:QrCode(105,765,ALLTRIM((_cAlias)->OP),0075)
			//primeira linha
			oPrinter:Say(80,430, "DATA PROD:", oFont16AT)
			oPrinter:Say(80,505, cData, oFont15)

			oPrinter:Say(105,430, "PRODUTO:", oFont16AT)
			oPrinter:Say(105,515, ALLTRIM((_cAlias)->PRODUTO), oFont16)

			oPrinter:Say(105,570, Substr(ALLTRIM((_cAlias)->DESCRICAO),1,33), oFont14)

			oPrinter:Say(120,430, "LOTE Nº:", oFont16AT)
			oPrinter:Say(120,510, ALLTRIM((_cAlias)->LOTE),   oFont16)

        	oPrinter:Say(120,645, "OPERACAO:", oFont16AT)
			oPrinter:Say(120,710, ALLTRIM((_cAlias)->OPERACAO), oFont15)

			//Box rastreabilidade
            oPrinter:Box(145,430, 170, 840)
			oPrinter:Say(145,490, "RASTREABILIDADE DO PROCESSO", oFont16AT)
						
			//Box Manipulação
			oPrinter:Box(170,430, 300, 840)
            oPrinter:Say(168,490, "MANIPULAÇÃO", oFont16AT)
			oPrinter:Say(185,430, "OP BASE Nº", oFont16)
			oPrinter:Say(185,545, ALLTRIM((_cAlias)->OP), oFont16 )
			
			oPrinter:Say(205,430,"COD BASE:", oFont16)
			oPrinter:Say(205,530, ALLTRIM((_cAlias)->PRODUTO), oFont16)
			
	    	oPrinter:Say(225,430,"DATA INICIO:", oFont16)
			oPrinter:Say(225,560, DTOC(STOD((_cAlias)->DATA_INI)), oFont16)

            oPrinter:Say(245,430,"DATA TERMINO:", oFont16)
			oPrinter:Say(245,570, DTOC(STOD((_cAlias)->DATA_FIM)), oFont16)

           	oPrinter:Say(265,430,"RESPONSAVEL:", oFont16)
			oPrinter:Say(265,560,"        ", oFont16)

            oPrinter:Say(180,710,"AMOSTRA RECOLHIDA?", oFont14)
            oPrinter:Box(205,710, 225, 765)
			oPrinter:Say(200,712, "SIM", oFont14)
            oPrinter:Box(205,760, 225, 815)
            oPrinter:Say(200,762,"NAO", oFont14)
			
            oPrinter:Say(225,760,"QTDE KG", oFont14)
            oPrinter:Box(250,730, 275, 840)
			oPrinter:Say(252,735, (_cAlias)->QUANTIDADE, oFont14)

                     
            //Box Qualidade
			oPrinter:Box(300,430, 395, 840)
            oPrinter:Say(297,490,"QUALIDADE", oFont16AT)
			oPrinter:Say(315,430,"DATA INICIO:", oFont16)
			oPrinter:Say(315,560,  "    /     /     ", oFont16)

            oPrinter:Say(335,430,"DATA TERMINO:", oFont16)
			oPrinter:Say(335,570,  "    /     /     ", oFont16)

			oPrinter:Say(355,430,"RESPONSAVEL:", oFont16)
			oPrinter:Say(355,560,"        ", oFont16)
            
            //Box Controle da Qualidade
            oPrinter:Box(300,730, 390, 840) 
			oPrinter:Say(295,735,"CONTROLE DE", oFont14)
            oPrinter:Say(304,745,"QUALIDADE:", oFont14)
			oPrinter:Box(328,735, 343, 745)               
			oPrinter:Say(318,755,"APROVADO:", oFont14)
			
            oPrinter:Box(348,735, 363, 745) 
			oPrinter:Say(335,755,"REPROVADO", oFont14)
			
            oPrinter:Box(368,735, 383, 745) 
			oPrinter:Say(355,755,"RETRABALHO", oFont14)

             //Box Envase
			oPrinter:Box(395,430, 480, 840)
            oPrinter:Say(393,490,"ENVASE", oFont16AT)
			oPrinter:Say(410,430,"DATA INICIO:", oFont16)
			oPrinter:Say(410,560,  "    /     /     ", oFont16)

            oPrinter:Say(430,430,"DATA TERMINO:", oFont16)
			oPrinter:Say(430,570,  "    /     /     ", oFont16)

			oPrinter:Say(450,430,"RESPONSAVEL:", oFont16)
			oPrinter:Say(450,560,"        ", oFont16)

            oPrinter:Say(393,760,"QTDE UNIT", oFont14)
            oPrinter:Box(415,730, 432, 840)
			oPrinter:Say(410,735, " ", oFont14)

            oPrinter:Say(433,760,"QTDE CXS", oFont14)
            oPrinter:Box(455,730, 475, 840)
			oPrinter:Say(450,735, " ", oFont14)

			oPrinter:EndPage()
		next
            /*
			If AllTrim(FunName())=="MATA681"

				 clog := DTOC(Date()) + " - " + Time() + " - " + __cUserId + " - " + Substr(cUsuario,7,10) + " AUT"
                	cQry := ""
					cQry += " UPDATE "+RetSQLName("SD3")
					cQry += " SET D3_LOGIMP = '" + clog + "' "
					cQry += " WHERE D_E_L_E_T_ = '' "
					cQry +=		 " AND D3_FILIAL = '"+xFilial("SD3")+"' "
					cQry +=		 " AND D3_CF = 'PR0' "
					cQry +=		 " AND RTrim(Ltrim(D3_OP)) = '"+(_cAlias)->OP+"' "
					//cQry +=		 " AND RTrim(Ltrim(D3_DOC)) = '"+(_cAlias)->DOCUMENTO+"' "

					if TCSQLExec(cQry) < 0
						MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_001")
					endif
			Else

				 clog := DTOC(Date()) + " - " + Time() + " - " + __cUserId + " - " + Substr(cUsuario,7,10) + " MAN"
					cQry := ""
					cQry += " UPDATE "+RetSQLName("SD3")
					cQry += " SET D3_LOGIMP = '" + clog + "' "
					cQry += " WHERE D_E_L_E_T_ = '' "
					cQry +=		 " AND D3_FILIAL = '"+xFilial("SD3")+"' "
					cQry +=		 " AND D3_CF = 'PR0' "
					cQry +=		 " AND RTrim(Ltrim(D3_OP)) = '"+(_cAlias)->OP+"' "
					cQry +=		 " AND RTrim(Ltrim(D3_DOC)) = '"+(_cAlias)->DOCUMENTO+"' "

					if TCSQLExec(cQry) < 0
						MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_001")
					endif

			End
            */
	(_cAlias)->(dbSkip())
	enddo

	If AllTrim(FunName())=="MATA681" 
	    //oPrinter:Preview()
		oPrinter:Print()
	Else
        //oPrinter:Preview()
        oPrinter:Print()
	Endif

	//MsgInfo("Foram processados "+cValToChar(nRegs)+" produtos.", _cRotina+"_001")

	if Select(_cAlias) > 0
		(_cAlias)->(DbCloseArea())
	endif
return
/*/{Protheus.doc} ValidPerg
@description Verifica as perguntas no dicionário SX1, as criando, caso não existam.
@author Diego Rodrigues Pereira (ALLSS Soluções em Sistemas)
@since 22/06/2021
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
	_aTam  := TamSX3("C2_PRODUTO")
	AADD(_aRegs,{_cPerg,"01","Do Produto?"          ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SB1"   ,"",""})
	AADD(_aRegs,{_cPerg,"02","Ao Produto?"          ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SB1"   ,"",""})
	_aTam  := TamSX3("D3_OP"     )
	AADD(_aRegs,{_cPerg,"03","Da Ordem de Prod. ?"  ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par03",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SC2"   ,"",""})
	AADD(_aRegs,{_cPerg,"04","Até a Ordem Prod. ?"  ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SC2"   ,"",""})
	_aTam  := TamSX3("D3_EMISSAO")
	AADD(_aRegs,{_cPerg,"05","Da Data Produção  ?"  ,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par05",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	AADD(_aRegs,{_cPerg,"06","Até Data Produção ?"  ,"","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par06",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSX3("B1_TIPO")
	AADD(_aRegs,{_cPerg,"07","Do Tipo?"             ,"","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par07",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"08","Ao Tipo?"             ,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	_aTam  := TamSX3("D3_DOC")
	AADD(_aRegs,{_cPerg,"09","Do Documento?"        ,"","","mv_ch9",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par09",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"10","Ao Documento?"        ,"","","mv_ch10",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par10",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	
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
