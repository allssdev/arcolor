#include "totvs.ch"
#include "FWPrintSetup.ch"
#include "rptdef.ch"

/*/{Protheus.doc} RESTR007
@description Ficha Controle Produto Intermediario em modo Paisagem.
@description Utilizado ponto de entrada A250ITOK E SD3250I
@author Diego Rodrigues Pereira (ALLSS Soluções em Sistemas)
@since 23/06/2021
@type function
@version 1.00
@see https://allss.com.br
@history 10/02/2025, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação para a impressão a partir da rotina MATA681(roteiro de operações)
/*/

User Function RESTR007()
	private _cRotina := "RESTR007"
	private _cPerg   := _cRotina
	private _cAlias  := GetNextAlias()
	Private clog := ""
	
	If AllTrim(FunName())=="MATA250"  
		
		MV_PAR01 := M->D3_COD
		MV_PAR02 := M->D3_COD
		MV_PAR03 := M->D3_OP
		MV_PAR04 := M->D3_OP
		MV_PAR05 := SC2->C2_EMISSAO
		MV_PAR06 := M->D3_EMISSAO
		MV_PAR07 := ""
		MV_PAR08 := "ZZ"
		MV_PAR09 := M->D3_DOC
		MV_PAR10 := M->D3_DOC

		//Carrega os dados para fins de impressão
		ChrFicha()
		//Imprime a ficha de controle produto intermediario
		PrtFicha()
	ElseIf AllTrim(FunName())=="MATA681" 
		
		MV_PAR01 := SC2->C2_PRODUTO
		MV_PAR02 := SC2->C2_PRODUTO
		MV_PAR03 := SD3->D3_OP
		MV_PAR04 := SD3->D3_OP
		MV_PAR05 := SC2->C2_EMISSAO
		MV_PAR06 := SD3->D3_EMISSAO
		MV_PAR08 := ""
		MV_PAR09 := "ZZ"
		MV_PAR10 := SD3->D3_DOC
		MV_PAR11 := SD3->D3_DOC
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
@since 22/06/2021
@type function
@version 1.00
@see https://allss.com.br
/*/
static function ChrFicha()
	BeginSql alias _cAlias
		%noparser%
		SELECT RTRIM(B1_COD)  PRODUTO
			 , RTRIM(B1_DESC) DESCRICAO
			 , RTRIM(ISNULL(D3_QUANT,0)) QUANTIDADE
			 , RTRIM(B1_CONV) FATOR
			 , RTRIM(B1_SEGUM) EMB
			 , RTRIM(B1_PESO) PESOL
			 , RTRIM(B1_PESBRU) PESOB
		     , RTRIM(D3_CF) CF
			 , RTRIM(D3_TM) TM
			 , RTRIM(D3_ITEM) ITEM
			 , RTRIM(ISNULL(B1_CC,ISNULL(C2_CC,ISNULL(D3_CC,'')))) SETOR
			 , RTRIM(ISNULL(C2_NUM+C2_ITEM+C2_SEQUEN,'')) OP
			 , RTRIM(ISNULL(D3_DOC,ISNULL(C2_NUM+C2_ITEM+C2_SEQUEN,''))) DOCUMENTO
			 , RTRIM(ISNULL(D3_LOCAL,ISNULL(C2_LOCAL,ISNULL(B1_LOCPAD,'')))) ARMAZEM
			 , RTRIM(ISNULL(C2_NUM+C2_ITEM+C2_SEQUEN,'')) LOTE
			 , RTRIM(ISNULL(D3_NUMLOTE,''))  SUBLOTE
			 , RTRIM(B1_PRVALID) VAL_DIAS
			 , RTRIM(REPLACE(CAST(DATEADD(MONTH,(B1_PRVALID/30),C2_DATPRF) AS DATE),'-','')) VALIDADE
			 , RTRIM(D3_EMISSAO) AS ENTRADA
			 , RTRIM((CASE 
					WHEN ISNULL(D3_LOCALIZ,'') = '' 
						THEN SUBSTRING(ISNULL((
												SELECT MAX(CBJ_ITEM+CBJ_ENDERE) 
												FROM %table:CBJ% CBJ (NOLOCK) 
												WHERE CBJ_FILIAL = %xFilial:CBJ% 
												  AND CBJ_CODPRO = B1_COD 
												  AND CBJ_ARMAZ  = ISNULL(D3_LOCAL,ISNULL(C2_LOCAL,ISNULL(B1_LOCPAD,''))) 
												  AND CBJ.%NotDel%
											),''),%Exp:TamSx3("D3_LOCAL")[1]%+1,%Exp:TamSx3("D3_LOCALIZ")[1]%)
						ELSE ISNULL(D3_LOCALIZ,'')
				END)) ENDERECO
			, (	SELECT REG
				FROM (
						SELECT R_E_C_N_O_ RECSD3, (ROW_NUMBER() OVER (ORDER BY D3_FILIAL, D3_OP, D3_DOC, D3_NUMSEQ, R_E_C_N_O_)) REG
						FROM %table:SD3% SD3ORD (NOLOCK)
						WHERE SD3ORD.D3_FILIAL  = SD3.D3_FILIAL
						AND SD3ORD.D3_OP      = SD3.D3_OP
						AND SD3ORD.D3_CF      = SD3.D3_CF
						AND SD3ORD.D3_ESTORNO = SD3.D3_ESTORNO
						//AND SD3ORD.D3_EMISSAO = SD3.D3_EMISSAO
						AND SD3ORD.%notdel%
				) XXX
				WHERE XXX.RECSD3 = SD3.R_E_C_N_O_
			  ) PAG
		FROM %table:SB1% SB1 (NOLOCK)
			INNER JOIN      %table:SC2% SC2 (NOLOCK) ON C2_FILIAL = %xFilial:SC2% 
												AND C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
												AND C2_EMISSAO  BETWEEN %Exp:DTOS(MV_PAR05)% AND %Exp:DTOS(MV_PAR06)%
												AND C2_PRODUTO   = B1_COD
												AND SC2.%NotDel%
			LEFT OUTER JOIN %table:SD3% SD3 (NOLOCK) ON D3_FILIAL  = C2_FILIAL
												AND D3_OP          = C2_NUM + C2_ITEM + C2_SEQUEN
												AND	D3_COD         = C2_PRODUTO
												AND D3_ESTORNO     = ''
												AND D3_CF          = 'PR0'
												AND D3_EMISSAO BETWEEN %Exp:DTOS(MV_PAR05)% AND %Exp:DTOS(MV_PAR06)%
												AND (CASE WHEN D3_DOC BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10% THEN 1 ELSE 0 END) = 1
												/*AND (CASE WHEN %Exp:Alltrim(Funname())% = 'MATA250' 
														THEN (CASE WHEN D3_NUMSEQ = %Exp:SD3->D3_NUMSEQ% THEN 1 ELSE 0 END)
														ELSE (CASE WHEN D3_DOC BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10% THEN 1 ELSE 0 END )
														END ) = 1 
												*/
												AND SD3.%NotDel%
		WHERE B1_FILIAL    = %xFilial:SB1%
		  AND B1_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		  AND B1_TIPO BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
		  AND SB1.%NotDel%
		ORDER BY B1_COD, C2_NUM + C2_ITEM + C2_SEQUEN, D3_EMISSAO, D3_LOTECTL
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
		cPDF := cName +StrZero(nINc,4,0)
		if !File(cSpool+cPDF+".PDF")
			exit
		endif
	next
	
	If AllTrim(FunName())=="MATA250"  
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
		Private 	cData  := DTOC(STOD((_cAlias)->ENTRADA)) //DTOS(DDATABASE+VAL((_cAlias)->VAL_DIAS))
		Private 	cPag	:= (_cAlias)->PAG
			

		For nFic := 1 to nNum

						
		oPrinter:StartPage()

			nRegs++

            oPrinter:SayBitmap(5,10,cBTM,50,35)        // logo
            //Titulo
            oPrinter:Say(15,70, "IDENTIFICAÇÃO DO PRODUTO", oFont16AT)

			//Box Margem
			//oPrinter:Box(45, 5, 400, 420)
		
		
			//Box Identificação
			oPrinter:Box(50,10, 125, 420)
			oPrinter:Say(55,10, "OP Nº:", oFont16AT)
			oPrinter:Say(55,70, ALLTRIM((_cAlias)->OP), oFont16)

			oPrinter:Say(55,185, "DATA PROD:", oFont16AT)
			oPrinter:Say(55,300, cData, oFont15)

			oPrinter:Say(75,10, "PRODUTO:", oFont16AT)
			oPrinter:Say(75,90, ALLTRIM((_cAlias)->PRODUTO), oFont16)

			oPrinter:Say(75,170, "", oFont16AT)
			oPrinter:Say(75,170, ALLTRIM((_cAlias)->DESCRICAO), oFont14)

			oPrinter:Say(95,10, "LOTE Nº:", oFont16AT)
			oPrinter:Say(95,90, ALLTRIM((_cAlias)->LOTE),   oFont16)

			//Box rastreabilidade
            oPrinter:Box(125,10, 150, 420)
			oPrinter:Say(125,60, "RASTREABILIDADE DO PROCESSO", oFont16AT)
						
			//Box Manipulação
			oPrinter:Box(150,10, 275, 420)
            oPrinter:Say(148,60, "MANIPULAÇÃO", oFont16AT)
			oPrinter:Say(165,10, "OP BASE Nº", oFont16)
			oPrinter:Say(165,115, ALLTRIM((_cAlias)->OP), oFont16 )
			
			oPrinter:Say(185,10,"COD BASE:", oFont16)
			oPrinter:Say(185,100, ALLTRIM((_cAlias)->PRODUTO), oFont16)
			
	    	oPrinter:Say(205,10,"DATA INICIO:", oFont16)
			oPrinter:Say(205,135, DTOC(STOD((_cAlias)->ENTRADA)), oFont16)

            oPrinter:Say(225,10,"DATA TERMINO:", oFont16)
			oPrinter:Say(225,145, DTOC(STOD((_cAlias)->ENTRADA)), oFont16)

           	oPrinter:Say(245,10,"RESPONSAVEL:", oFont16)
			oPrinter:Say(245,130,"        ", oFont16)

            oPrinter:Say(160,285,"AMOSTRA RECOLHIDA?", oFont14)
            oPrinter:Box(185,285, 205, 335)
			oPrinter:Say(180,287, "SIM", oFont14)
            oPrinter:Box(185,335, 205, 385)
            oPrinter:Say(180,337,"NAO", oFont14)
			
            oPrinter:Say(205,310,"QTDE KG", oFont14)
            oPrinter:Box(230,285, 255, 410)
			oPrinter:Say(232,295, (_cAlias)->QUANTIDADE, oFont14)

                     
            //Box Qualidade
			oPrinter:Box(275,10, 370, 420)
            oPrinter:Say(272,60,"QUALIDADE", oFont16AT)
			oPrinter:Say(290,10,"DATA INICIO:", oFont16)
			oPrinter:Say(290,135,  "    /     /     ", oFont16)

            oPrinter:Say(310,10,"DATA TERMINO:", oFont16)
			oPrinter:Say(310,145,  "    /     /     ", oFont16)

			oPrinter:Say(330,10,"RESPONSAVEL:", oFont16)
			oPrinter:Say(330,130,"        ", oFont16)
            
            //Box Controle da Qualidade
            oPrinter:Box(275,300, 365, 410) 
			oPrinter:Say(270,305,"CONTROLE DE", oFont14)
            oPrinter:Say(279,315,"QUALIDADE:", oFont14)
			oPrinter:Box(303,305, 318, 315)               
			oPrinter:Say(293,325,"APROVADO:", oFont14)
			
            oPrinter:Box(323,305, 338, 315) 
			oPrinter:Say(310,325,"REPROVADO", oFont14)
			
            oPrinter:Box(343,305, 358, 315) 
			oPrinter:Say(330,325,"RETRABALHO", oFont14)

             //Box Envase
			oPrinter:Box(370,10, 455, 420)
            oPrinter:Say(368,60,"ENVASE", oFont16AT)
			oPrinter:Say(385,10,"DATA INICIO:", oFont16)
			oPrinter:Say(385,135,  "    /     /     ", oFont16)

            oPrinter:Say(405,10,"DATA TERMINO:", oFont16)
			oPrinter:Say(405,145,  "    /     /     ", oFont16)

			oPrinter:Say(425,10,"RESPONSAVEL:", oFont16)
			oPrinter:Say(425,130,"        ", oFont16)

            oPrinter:Say(368,330,"QTDE UNIT", oFont14)
            oPrinter:Box(390,300, 407, 410)
			oPrinter:Say(385,305, " ", oFont14)

            oPrinter:Say(408,330,"QTDE CXS", oFont14)
            oPrinter:Box(430,300, 450, 410)
			oPrinter:Say(425,305, " ", oFont14)

            

            
            //IMPRESSAO PAGINA 2

            oPrinter:SayBitmap(5,435,cBTM,50,35)        // logo
            //Titulo
            oPrinter:Say(15,495, "IDENTIFICAÇÃO DO PRODUTO", oFont16AT)

					
			//Box Identificação
			oPrinter:Box(50,430, 125, 840)
			oPrinter:Say(55,430, "OP Nº:", oFont16AT)
			oPrinter:Say(55,500, ALLTRIM((_cAlias)->OP), oFont16)

			oPrinter:Say(55,615, "DATA PROD:", oFont16AT)
			oPrinter:Say(55,735, cData, oFont15)

			oPrinter:Say(75,430, "PRODUTO:", oFont16AT)
			oPrinter:Say(75,520, ALLTRIM((_cAlias)->PRODUTO), oFont16)

			oPrinter:Say(75,605, "", oFont16AT)
			oPrinter:Say(75,610, ALLTRIM((_cAlias)->DESCRICAO), oFont14)
			oPrinter:Say(95,430, "LOTE Nº:", oFont16AT)
			oPrinter:Say(95,520, ALLTRIM((_cAlias)->LOTE),   oFont16)

			//Box rastreabilidade
            oPrinter:Box(125,430, 150, 840)
			oPrinter:Say(125,490, "RASTREABILIDADE DO PROCESSO", oFont16AT)
						
			//Box Manipulação
			oPrinter:Box(150,430, 275, 840)
            oPrinter:Say(148,490, "MANIPULAÇÃO", oFont16AT)
			oPrinter:Say(165,430, "OP BASE Nº", oFont16)
			oPrinter:Say(165,545, ALLTRIM((_cAlias)->OP), oFont16 )
			
			oPrinter:Say(185,430,"COD BASE:", oFont16)
			oPrinter:Say(185,530, ALLTRIM((_cAlias)->PRODUTO), oFont16)
			
	    	oPrinter:Say(205,430,"DATA INICIO:", oFont16)
			oPrinter:Say(205,560, DTOC(STOD((_cAlias)->ENTRADA)), oFont16)

            oPrinter:Say(225,430,"DATA TERMINO:", oFont16)
			oPrinter:Say(225,570, DTOC(STOD((_cAlias)->ENTRADA)), oFont16)

           	oPrinter:Say(245,430,"RESPONSAVEL:", oFont16)
			oPrinter:Say(245,560,"        ", oFont16)

            oPrinter:Say(160,710,"AMOSTRA RECOLHIDA?", oFont14)
            oPrinter:Box(185,710, 205, 765)
			oPrinter:Say(180,712, "SIM", oFont14)
            oPrinter:Box(185,760, 205, 815)
            oPrinter:Say(180,762,"NAO", oFont14)
			
            oPrinter:Say(205,760,"QTDE KG", oFont14)
            oPrinter:Box(230,730, 255, 840)
			oPrinter:Say(232,735, (_cAlias)->QUANTIDADE, oFont14)

                     
            //Box Qualidade
			oPrinter:Box(275,430, 370, 840)
            oPrinter:Say(272,490,"QUALIDADE", oFont16AT)
			oPrinter:Say(290,430,"DATA INICIO:", oFont16)
			oPrinter:Say(290,560,  "    /     /     ", oFont16)

            oPrinter:Say(310,430,"DATA TERMINO:", oFont16)
			oPrinter:Say(310,570,  "    /     /     ", oFont16)

			oPrinter:Say(330,430,"RESPONSAVEL:", oFont16)
			oPrinter:Say(330,560,"        ", oFont16)
            
            //Box Controle da Qualidade
            oPrinter:Box(275,730, 365, 840) 
			oPrinter:Say(270,735,"CONTROLE DE", oFont14)
            oPrinter:Say(279,745,"QUALIDADE:", oFont14)
			oPrinter:Box(303,735, 318, 745)               
			oPrinter:Say(293,755,"APROVADO:", oFont14)
			
            oPrinter:Box(323,735, 338, 745) 
			oPrinter:Say(310,755,"REPROVADO", oFont14)
			
            oPrinter:Box(343,735, 358, 745) 
			oPrinter:Say(330,755,"RETRABALHO", oFont14)

             //Box Envase
			oPrinter:Box(370,430, 455, 840)
            oPrinter:Say(368,490,"ENVASE", oFont16AT)
			oPrinter:Say(385,430,"DATA INICIO:", oFont16)
			oPrinter:Say(385,560,  "    /     /     ", oFont16)

            oPrinter:Say(405,430,"DATA TERMINO:", oFont16)
			oPrinter:Say(405,570,  "    /     /     ", oFont16)

			oPrinter:Say(425,430,"RESPONSAVEL:", oFont16)
			oPrinter:Say(425,560,"        ", oFont16)

            oPrinter:Say(368,760,"QTDE UNIT", oFont14)
            oPrinter:Box(390,730, 407, 840)
			oPrinter:Say(385,735, " ", oFont14)

            oPrinter:Say(408,760,"QTDE CXS", oFont14)
            oPrinter:Box(430,730, 450, 840)
			oPrinter:Say(425,735, " ", oFont14)
			
			
			
			oPrinter:EndPage()
		
		next

		
			If AllTrim(FunName())=="MATA250"

				 clog := DTOC(Date()) + " - " + Time() + " - " + __cUserId + " - " + Substr(cUsuario,7,10) + " AUT"
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
				
			(_cAlias)->(dbSkip())
	
	enddo

	 If AllTrim(FunName())=="MATA250" 
	    //oPrinter:Preview()
		oPrinter:Print()
	 Else
	//	oPrinter:Preview()
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
	AADD(_aRegs,{_cPerg,"01","Do Produto?"        ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SB1"   ,"",""})
	AADD(_aRegs,{_cPerg,"02","Ao Produto?"        ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SB1"   ,"",""})
	_aTam  := TamSX3("D3_OP"     )
	AADD(_aRegs,{_cPerg,"03","Da Ordem de Prod. ?","","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par03",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SC2"   ,"",""})
	AADD(_aRegs,{_cPerg,"04","Até a Ordem Prod. ?","","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SC2"   ,"",""})
	_aTam  := TamSX3("D3_EMISSAO")
	AADD(_aRegs,{_cPerg,"05","Da Data Produção  ?","","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par05",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	AADD(_aRegs,{_cPerg,"06","Até Data Produção ?","","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par06",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSX3("B1_TIPO")
	AADD(_aRegs,{_cPerg,"08","Do Tipo?"        ,"","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par07",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"09","Ao Tipo?"        ,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	_aTam  := TamSX3("D3_DOC")
	AADD(_aRegs,{_cPerg,"10","Do Documento?"        ,"","","mv_ch9",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par09",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"11","Ao Documento?"        ,"","","mv_ch10",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par10",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	
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
