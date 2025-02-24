#include 'totvs.ch'
#include 'protheus.ch'
#include 'fwprintsetup.ch'
#include 'rptdef.ch'
#define DMPAPER_A4 9
/*/{Protheus.doc} RESTR006
Ficha Pallet em modo Paisagem.
@author Eduardo Nunes dos Santos (ALLSS Soluções em Sistemas)
@since 21/12/2020
@type function
@version 1.00
@hystory Diego Rodrigues 01/02/21 - ajustes no fonte para adaptar ao processo de impressão da ficha pallet
@hystory Diego Rodrigues 16/02/21 - Alinhado com o Paulo em Reunião que irão utilizar o código de barras ean13(unitário)
@history 10/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adição de data/hora de impressão e melhoria na tela de parâmetros para controle das opções selecionadas.
@history 24/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste do lado esquerdo da impressão para que não haja cortes em impressora física.
@history 24/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste para correta carga e consideração dos dados informados na tela de parametrização do relatório para impressão.
@history 25/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste do lado inferior direito da impressão para que não haja cortes em impressora física.
@history 05/10/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Impressão do código de barras do lote considerando apenas os 6 primeiros digitos da Ordem de Produção.
@history 01/08/2024, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequação para o controle de ficha pallet buscar o numero do apontamento campo (D3_XNRFICH)
/*/
user function RESTR006()
private _cRotina := "RESTR006"
private _cPerg   := _cRotina
private _cAlias  := GetNextAlias()
	
	If AllTrim(FunName())=="MATA250"  
		
		/*
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
		*/

		MV_PAR01 := M->D3_COD
		MV_PAR02 := M->D3_COD
		MV_PAR03 := M->D3_OP
		MV_PAR04 := M->D3_OP
		MV_PAR05 := SC2->C2_EMISSAO
		MV_PAR06 := M->D3_EMISSAO
		MV_PAR08 := ""
		MV_PAR09 := "ZZ"
		MV_PAR10 := M->D3_DOC
		MV_PAR11 := M->D3_DOC
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
		//Imprime a ficha pallet
		PrtFicha()
		endif
	EndIf
 return
/*/{Protheus.doc} ChrFicha
Carrega os dados a serem impressos.
@author Eduardo Nunes dos Santos (ALLSS Soluções em Sistemas)
@since 21/12/2020
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
			 , RTRIM(B5_LARG) LARGURA
			 , RTRIM(B5_ALTURA) ALTURA
			 , RTRIM(D3_CF) CF
			 , RTRIM(D3_TM) TM
			 , RTRIM(D3_ITEM) ITEM
			 //, (LTRIM(RTRIM(%Exp:MV_PAR07%))+B1_CODBAR) BARRAS
			 //, RTRIM(CASE WHEN B1_CODBAR2 = '' THEN B1_CODBAR ELSE B1_CODBAR2 END) BARRAS
			 , RTRIM(B1_CODBAR) BARRAS
			 , RTRIM(ISNULL(B1_CC,ISNULL(C2_CC,ISNULL(D3_CC,'')))) SETOR
			 , RTRIM(ISNULL(B5_EAN148,0)) QUANT_EMB
			 , (CASE WHEN B5_EAN148 = 0 THEN B5_EAN148 ELSE RTRIM(D3_QUANT / B5_EAN148) END) QTEMB
			 , CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),ISNULL((CASE WHEN B1_CONV = 0 THEN 0 ELSE (B5_EAN148/B1_CONV) END),(CASE WHEN B1_VOSEC = 0 THEN 0 ELSE (B5_EAN148/B1_VOSEC) END)))) + ' ' + B1_SEGUM AS EMBALAGEM
			 , RTRIM(ISNULL(C2_NUM+C2_ITEM+C2_SEQUEN,'')) OP
			 , RTRIM(ISNULL(D3_DOC,ISNULL(C2_NUM+C2_ITEM+C2_SEQUEN,''))) DOCUMENTO
			 //, RTRIM(ISNULL(D3_LOCAL,ISNULL(C2_LOCAL,ISNULL(B1_LOCPAD,'')))) ARMAZEM
			 , RTRIM(ISNULL(B1_LOCPAD,'')) ARMAZEM
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
												  //AND CBJ_ARMAZ  = ISNULL(D3_LOCAL,ISNULL(C2_LOCAL,ISNULL(B1_LOCPAD,''))) 
												  AND CBJ_ARMAZ  = ISNULL(B1_LOCPAD,'') 
												  AND CBJ.%NotDel%
											),''),%Exp:TamSx3("D3_LOCAL")[1]%+1,%Exp:TamSx3("D3_LOCALIZ")[1]%)
						ELSE ISNULL(D3_LOCALIZ,'')
				END)) ENDERECO
			, SD3.D3_XNRFICH AS PAG
			/*(	SELECT REG
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
			  ) PAG*/
			  
		FROM %table:SB1% SB1 (NOLOCK)
			INNER JOIN      %table:SC2% SC2 (NOLOCK) ON C2_FILIAL = %xFilial:SC2% 
												AND C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
												AND C2_DATPRF  BETWEEN %Exp:DTOS(MV_PAR05)% AND %Exp:DTOS(MV_PAR06)%
												AND C2_PRODUTO   = B1_COD
												AND SC2.%NotDel%
			LEFT OUTER JOIN %table:SB5% SB5 (NOLOCK) ON B5_FILIAL = B1_FILIAL
												AND B5_COD        = B1_COD
												AND SB5.%NotDel%
			LEFT OUTER JOIN %table:SD3% SD3 (NOLOCK) ON D3_FILIAL  = C2_FILIAL
												AND D3_OP          = C2_NUM + C2_ITEM + C2_SEQUEN
												AND	D3_COD         = C2_PRODUTO
												AND D3_ESTORNO     = ''
												AND D3_CF          = 'PR0'
												AND D3_EMISSAO BETWEEN %Exp:DTOS(MV_PAR05)% AND %Exp:DTOS(MV_PAR06)%
												AND (CASE WHEN D3_DOC BETWEEN %Exp:MV_PAR10% AND %Exp:MV_PAR11% THEN 1 ELSE 0 END) = 1
												
												/*AND (CASE WHEN %Exp:Alltrim(Funname())% = 'MATA250' 
														THEN (CASE WHEN D3_NUMSEQ = %Exp:M->D3_NUMSEQ% THEN 1 ELSE 0 END)
														ELSE (CASE WHEN D3_DOC BETWEEN %Exp:MV_PAR10% AND %Exp:MV_PAR11% THEN 1 ELSE 0 END )
														END ) = 1 
												*/
												/*AND (CASE WHEN %Exp:Alltrim(Funname())% = 'MATA250' 
														THEN (CASE WHEN D3_LOGIMP = '' THEN 1 ELSE 0 END)
														ELSE (CASE WHEN D3_LOGIMP = '' THEN 0 ELSE 1 END )
														END ) = 1*/
												/*AND SD3.R_E_C_N_O_ IN (
																		SELECT MAX(X.R_E_C_N_O_) 
																		FROM %table:SD3% X (NOLOCK) 
																		WHERE X.D3_FILIAL   = SD3.D3_FILIAL
																		  AND X.D3_CF       = 'PR0'
																		  AND X.D3_ESTORNO  = ''
																		  AND X.D3_OP       = SD3.D3_OP
																		  AND X.D3_COD      = SD3.D3_COD
																		  AND X.D3_EMISSAO >= SD3.D3_EMISSAO
																		  AND X.%NotDel%
																	  ) */
												AND SD3.%NotDel%
		WHERE B1_FILIAL    = %xFilial:SB1%
		  AND B1_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		  AND B1_TIPO BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR09%
		  AND (CASE WHEN B1_CODBAR = '' THEN '0' ELSE '1' END ) = '1' 
		  AND SB1.%NotDel%
		ORDER BY B1_COD, C2_NUM + C2_ITEM + C2_SEQUEN, D3_EMISSAO, D3_LOTECTL
	EndSql
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",GetLastQuery()[02])
return
/*/{Protheus.doc} PrtFicha
Imprime a Ficha Pallet.
@author Eduardo Nunes dos Santos (ALLSS Soluções em Sistemas)
@since 21/12/2020
@type function
@version 1.00
@see https://allss.com.br
/*/
static function PrtFicha()
local   nInc
local 	nFic
local   nNum := 0
local   lAdjustToLegacy := .F.
local   lDisableSetup   := .T.
local   nRegs           := 0
local   cName           := _cRotina
local   nFlags   	 	:= PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION
local   cSession	 	:= GetPrinterSession()
local   cDevice    		:= fwGetProfString(cSession,"PRINTTYPE"	,"SPOOL"	,.T.)
local   cDestino	    := fwGetProfString(cSession,"DEFAULT"	,"c:\temp"	,.T.)
private cSpool          := GetTempPath()
private cPdf            := ""
private oFont12         := TFont():New("Arial" ,,12,,.F.,,,,,.F.)
private oFont10AT       := TFont():New("Arial" ,,28,,.T.,,,,,.F.)
private oFont72AT       := TFont():New("Arial" ,,73,,.T.,,,,,.F.)
private oFont18         := TFont():New("Areal" ,,72,,.F.,,,,,.F.)
private oFont44         := TFont():New("Areal" ,,38,,.F.,,,,,.F.)
private oFont22         := TFont():New("Areal" ,,22,,.F.,,,,,.F.)
private oFont34	        := TFont():New("Areal" ,,34,,.T.,,,,,.F.)
private oFont180AT      := TFont():New("Arial" ,,180,,.T.,,,,,.F.)
private oFont140AT      := TFont():New("Arial" ,,140,,.T.,,,,,.F.)
private oFont300AT      := TFont():New("Arial" ,,300,,.T.,,,,,.F.)
private oFont46         := TFont():New("Arial" ,,46,,.T.,,,,,.F.)  
private oFont78AT       := TFont():New("Areal" ,,78,,.T.,,,,,.F.)
private cLog 			:= ''
private oPrintSetup as Object
private oPrinter 	as Object
private aDevice
for nInc := 1 to 1000
	cPDF := cName +StrZero(nINc,4,0)
	if !File(cSpool+cPDF+".PDF")
		exit
	endif
next
if AllTrim(FunName()) == "MATA250"
	aDevice := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define os Tipos de Impressao validos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aDevice,"DISCO")
	AADD(aDevice,"SPOOL")
	AADD(aDevice,"EMAIL")
	AADD(aDevice,"EXCEL")
	AADD(aDevice,"HTML" )
	AADD(aDevice,"PDF"  )
	nPrintType 							:= aScan(aDevice,{|x| x == cDevice})
	nLocal     							:= iif(fWGetProfString(cSession,"LOCAL","SERVER",.T.) == "SERVER",1,2)		
	oSetup 								:= FWPrintSetup():New(nFlags,'Impressão da Ficha Pallet')
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , 2) 
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	oSetup:SetPropert(PD_PREVIEW	 , .F.)
	if cDevice == "PDF"
		oSetup:aOptions[PD_VALUETYPE] 	:= cDestino
	endif
	oPrinter 							:= FWMSPrinter():New(cPdf,IMP_SPOOL,lAdjustToLegacy,,lDisableSetup,.T.,@oSetup,,,,.F.,)
	if !(oSetup:Activate() == PD_OK)
		oPrinter:Deactivate() 
		Aviso('TOTVS','Relatório cancelado pelo usuário',{'&OK'},3)
		return .F.
	endif
	oPrinter:lServer 					:= oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER                      
	oPrinter:SetResolution(75)
	if oSetup:GetProperty(PD_ORIENTATION) == 2
		oPrinter:SetLandsCape()
	else
		oPrinter:SetPortRait()
	endif
	oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
	fwWriteProfString(cSession,"LOCAL"		,iif(oSetup:GetProperty(PD_DESTINATION) == 1,"SERVER","LOCAL"),.T.)
	fwWriteProfString(cSession,"PRINTTYPE"	,aDevice[oSetup:GetProperty(PD_PRINTTYPE)],.T.)
	if oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrinter:nDevice 				:= IMP_SPOOL
		fwWriteProfString(cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)
		oPrinter:cPrinter 				:= oSetup:aOptions[PD_VALUETYPE]
	elseif oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oPrinter:nDevice 				:= IMP_PDF
		fwWriteProfString(cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)	
		oPrinter:cPathPDF 				:= oSetup:aOptions[PD_VALUETYPE]
	endif	
else
	aDevice := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define os Tipos de Impressao validos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aDevice,"DISCO")
	AADD(aDevice,"SPOOL")
	AADD(aDevice,"EMAIL")
	AADD(aDevice,"EXCEL")
	AADD(aDevice,"HTML" )
	AADD(aDevice,"PDF"  )
	nPrintType 							:= aScan(aDevice,{|x| x == cDevice})
	nLocal     							:= iif(fWGetProfString(cSession,"LOCAL","SERVER",.T.) == "SERVER",1,2)		
	oSetup 								:= FWPrintSetup():New(nFlags,'Impressão da Ficha Pallet')
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , 2) 
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	oSetup:SetPropert(PD_PREVIEW	 , .F.)
	if cDevice == "PDF"
		oSetup:aOptions[PD_VALUETYPE] 	:= cDestino
	endif
	oPrinter 							:= FWMSPrinter():New(cPdf,IMP_SPOOL,lAdjustToLegacy,,lDisableSetup,.T.,@oSetup,,,,.F.,)
	if !(oSetup:Activate() == PD_OK)
		oPrinter:Deactivate() 
		Aviso('TOTVS','Relatório cancelado pelo usuário',{'&OK'},3)
		return .F.
	endif
	oPrinter:lServer 					:= oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER                      
	oPrinter:SetResolution(75)
	if oSetup:GetProperty(PD_ORIENTATION) == 2
		oPrinter:SetLandsCape()
	else
		oPrinter:SetPortRait()
	endif
	oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
	fwWriteProfString(cSession,"LOCAL"		,iif(oSetup:GetProperty(PD_DESTINATION) == 1,"SERVER","LOCAL"),.T.)
	fwWriteProfString(cSession,"PRINTTYPE"	,aDevice[oSetup:GetProperty(PD_PRINTTYPE)],.T.)
	if oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrinter:nDevice 				:= IMP_SPOOL
		fwWriteProfString(cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)
		oPrinter:cPrinter 				:= oSetup:aOptions[PD_VALUETYPE]
	elseif oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oPrinter:nDevice 				:= IMP_PDF
		fwWriteProfString(cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)	
		oPrinter:cPathPDF 				:= oSetup:aOptions[PD_VALUETYPE]
	endif
endif
(_cAlias)->(dbGoTop())
	while !(_cAlias)->(EOF())
		nNum 					:= INT(((_cAlias)->QTEMB))
		Private 	cLote  		:= ALLTRIM((_cAlias)->LOTE)
		Private 	cValidade  	:= (_cAlias)->VALIDADE //DTOS(DDATABASE+VAL((_cAlias)->VAL_DIAS))
		Private 	cPag		:= (_cAlias)->PAG
		Private 	cEnd  		:= Alltrim((_cAlias)->ENDERECO)
		For nFic := 1 to nNum
			Private 	nPesol  := VAL((_cAlias)->PESOL) * VAL((_cAlias)->QUANT_EMB)
			Private 	nPesob  := VAL((_cAlias)->PESOB) * VAL((_cAlias)->QUANT_EMB)
			oPrinter:StartPage()
			nRegs++
			//Box Margem
			oPrinter:Box(0002,0005,0800,0840)

			//Box Produto
			oPrinter:Say(0040,0040, ALLTRIM((_cAlias)->PRODUTO)															,oFont72AT)
			oPrinter:Say(0025,0280, ALLTRIM((_cAlias)->DESCRICAO)														,oFont10AT)				

			//Box Código de Barras Produto
			oPrinter:Box(0070,0005,0130,0260)
			oPrinter:Code128(60/*nRow*/ ,0040 /*nCol*/,(_cAlias)->BARRAS/*cCode*/,1/*nWidth*/,35/*nHeigth*/,.F./*lSay*/,,)
			oPrinter:Line(0070,0005,0070,0840)

			//Box Embalagem
			oPrinter:Box(0070,0260,0130,0420)
			oPrinter:Say(0075,0265, "EMBALAGEM"																			,oFont22)
			oPrinter:Say(0100,0275, ALLTRIM((_cAlias)->EMBALAGEM)														,oFont34)

			//Box Quantidade
			oPrinter:Box(0130,0005,0290,0420)
			oPrinter:Say(0140,0030, "QUANTIDADE"																		,oFont22)
			oPrinter:Say(0250,0040, ALLTRIM((_cAlias)->QUANT_EMB)														,oFont180AT)			

			//Box Lastro 
			oPrinter:Box(0290,0005,0360,0125)
			oPrinter:Say(0295,0030, "LASTRO:"																			,oFont22)
			oPrinter:Say(0325,0040, ALLTRIM((_cAlias)->LARGURA)															,oFont34)

			//Box Altura
			oPrinter:Box(0290,0125,0360,0230)
			oPrinter:Say(0295,0135, "ALTURA:"																			,oFont22)
			oPrinter:Say(0325,0145, ALLTRIM((_cAlias)->ALTURA) 															,oFont34)			

			//Box Peso Bruto
			oPrinter:Box(0290,0230,0360,0420)
			oPrinter:Say(0295,0240, "PESO BRUTO"																		,oFont22)
			oPrinter:Say(0325,0250, ALLTRIM(STR(nPesob))																,oFont34)			

			//Box Lote e Validade
			oPrinter:Box(0360,0005,0510,0420)
			oPrinter:Say(0370,0030, "LOTE:"																				,oFont22)
			oPrinter:Say(0475,0040, ALLTRIM(SUBSTR((_cAlias)->LOTE,1,6)) /*+ " " + DTOC(STOD((_cAlias)->VALIDADE)) */	,oFont140AT)

			//Box Código de barra lote
			oPrinter:Box(0510,0005,0610,0130)
			oPrinter:Say(0510,0030, "LOTE:"																				,oFont22)
			oPrinter:Code128(0515/*nRow*/ ,0040 /*nCol*/,ALLTRIM(SUBSTR((_cAlias)->LOTE,1,6))/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)
			
			//Box endereço
			oPrinter:Box(0510,0130,0610,0295)			
			oPrinter:Say(0510,0135, "END:"																			,oFont22)
			oPrinter:Say(0510,0185, ALLTRIM((_cAlias)->ARMAZEM) + "-" + ALLTRIM((_cAlias)->ENDERECO)					,oFont22)
			oPrinter:Code128(0515/*nRow*/ ,0150 /*nCol*/,(_cAlias)->ARMAZEM + cEnd/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)
			
			//Box Pagina
			oPrinter:Box(0450,0420,0610,0840)
			oPrinter:Say(0465,0520, "FICHA Nº:"																			,oFont22)
			oPrinter:Say(0570,0650, AllTrim(cPag)																	,oFont180AT)

			//Box Documento OP
			oPrinter:Box(0510,0295,0610,0450)			
			oPrinter:Say(0510,0305, "DOC:"																			,oFont22)
			oPrinter:Say(0510,0345,ALLTRIM((_cAlias)->DOCUMENTO)															,oFont22)
			oPrinter:Code128(0515/*nRow*/ ,0305 /*nCol*/,(_cAlias)->DOCUMENTO/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)			
			
			//Box validade 
			oPrinter:Say(0065,0440, "VALIDADE:"																			,oFont22)
			oPrinter:Say(0200,0460, SUBSTR((_cAlias)->VALIDADE,1,4)														,oFont180AT)
			oPrinter:Say(0420,0485, SUBSTR((_cAlias)->VALIDADE,5,2)														,oFont300AT)
			oPrinter:Say(0420,0800, 'Data/Hora Emissão: ' + AllTrim(DtoC(Date()) + ' - ' + Time())						,oFont12,nil,,0270)
		
			//Box Data de Entrada
			oPrinter:Box(0510,0455,0610,0650)
			//oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,46/*nRow*/, 1/*nCol*/ ,(_cAlias)->ARMAZEM + cEnd  /*cCode*/,oPrinter/*oPrint*/,.F./*lCheck*/,/*Color*/,/*lHorz*/,0.025 /*nWidth*/,1/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,0.5/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
			oPrinter:Say(0510,0460, "ENTRADA:"																			,oFont22)
			oPrinter:Say(0540,0460, DTOC(STOD((_cAlias)->ENTRADA))														,oFont46)

			oPrinter:EndPage()
		next nFic

		Private nComp := (nNum * VAL((_cAlias)->QUANT_EMB))
		Private nTotal := VAL((_cAlias)->QUANTIDADE)

		If  nTotal > nComp
				Private nDif := VAL((_cAlias)->QUANTIDADE) -  (nNum * VAL((_cAlias)->QUANT_EMB))
				Private nEmb := ROUND(nDif / VAL((_cAlias)->FATOR),2)
				Private nPesold  := VAL((_cAlias)->PESOL) * nDif
				Private nPesobd  := VAL((_cAlias)->PESOB) * nDif
				cPag := cPag

				oPrinter:StartPage()
				nRegs++
                //Box Margem
                oPrinter:Box(0002,0005,0800,0840)
            
                //Box Produto
				oPrinter:Say(0040,0040, ALLTRIM((_cAlias)->PRODUTO)															,oFont72AT)
				oPrinter:Say(0025,0280, ALLTRIM((_cAlias)->DESCRICAO)														,oFont10AT)				

                //Box Código de Barras Produto
                oPrinter:Box(0070,0005,0130,0260)
                oPrinter:Code128(60/*nRow*/ ,0040 /*nCol*/,(_cAlias)->BARRAS/*cCode*/,1/*nWidth*/,35/*nHeigth*/,.F./*lSay*/,,)
                oPrinter:Line(0070,0005,0070,0840)
                
                //Box Embalagem
				oPrinter:Box(0070,0260,0130,0420)
				oPrinter:Say(0075,0265, "EMBALAGEM"																			,oFont22)
				oPrinter:Say(0100,0275, ALLTRIM(STR(nEmb)) + " " + (_cAlias)->EMB											,oFont34)				

                //Box Quantidade
				oPrinter:Box(0130,0005,0290,0420)
				oPrinter:Say(0140,0030, "QUANTIDADE"																		,oFont22)
				oPrinter:Say(0250,0040, ALLTRIM(STR(nDif))																	,oFont180AT)

				//Box Lastro 
				oPrinter:Box(0290,0005,0360,0125)
				oPrinter:Say(0295,0030, "LASTRO:"																			,oFont22)
				oPrinter:Say(0325,0040, ALLTRIM((_cAlias)->LARGURA)															,oFont34)

				//Box Altura
				oPrinter:Box(0290,0125,0360,0230)
				oPrinter:Say(0295,0135, "ALTURA:"																			,oFont22)
				oPrinter:Say(0325,0145, ALLTRIM((_cAlias)->ALTURA) 															,oFont34)			

				//Box Peso Bruto
				oPrinter:Box(0290,0230,0360,0420)
				oPrinter:Say(0295,0240, "PESO BRUTO"																		,oFont22)
				oPrinter:Say(0325,0250, ALLTRIM(STR(nPesobd))																,oFont34)

                //Box Lote e Validade
				oPrinter:Box(0360,0005,0510,0420)
				oPrinter:Say(0370,0030, "LOTE:"																				,oFont22)
				oPrinter:Say(0475,0040, ALLTRIM(SUBSTR((_cAlias)->LOTE,1,6)) /*+ " " + DTOC(STOD((_cAlias)->VALIDADE)) */	,oFont140AT)
                
				//Box Código de barra lote
				oPrinter:Box(0510,0005,0610,0130)
				oPrinter:Say(0510,0030, "LOTE:"																				,oFont22)
				oPrinter:Code128(0515/*nRow*/ ,0040 /*nCol*/,ALLTRIM(SUBSTR((_cAlias)->LOTE,1,6))/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)
				
				//Box endereço
				oPrinter:Box(0510,0130,0610,0295)			
				oPrinter:Say(0510,0135, "END:"																			,oFont22)
				oPrinter:Say(0510,0185, ALLTRIM((_cAlias)->ARMAZEM) + "-" + ALLTRIM((_cAlias)->ENDERECO)					,oFont22)
				oPrinter:Code128(0515/*nRow*/ ,0150 /*nCol*/,(_cAlias)->ARMAZEM + cEnd/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)
				
				//Box Pagina
				oPrinter:Box(0450,0420,0610,0840)
				oPrinter:Say(0465,0520, "FICHA Nº:"																			,oFont22)
				oPrinter:Say(0570,0650, AllTrim(cPag)																	,oFont180AT)

				//Box Documento OP
				oPrinter:Box(0510,0295,0610,0450)			
				oPrinter:Say(0510,0305, "DOC:"																			,oFont22)
				oPrinter:Say(0510,0345,ALLTRIM((_cAlias)->DOCUMENTO)															,oFont22)
				oPrinter:Code128(0515/*nRow*/ ,0305 /*nCol*/,(_cAlias)->DOCUMENTO/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)			
				
				//Box validade 
				oPrinter:Say(0065,0440, "VALIDADE:"																			,oFont22)
				oPrinter:Say(0200,0460, SUBSTR((_cAlias)->VALIDADE,1,4)														,oFont180AT)
				oPrinter:Say(0420,0485, SUBSTR((_cAlias)->VALIDADE,5,2)														,oFont300AT)
				oPrinter:Say(0420,0800, 'Data/Hora Emissão: ' + AllTrim(DtoC(Date()) + ' - ' + Time())						,oFont12,nil,,0270)
			
				//Box Data de Entrada
				oPrinter:Box(0510,0455,0610,0650)
				//oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,46/*nRow*/, 1/*nCol*/ ,(_cAlias)->ARMAZEM + cEnd  /*cCode*/,oPrinter/*oPrint*/,.F./*lCheck*/,/*Color*/,/*lHorz*/,0.025 /*nWidth*/,1/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,0.5/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
				oPrinter:Say(0510,0460, "ENTRADA:"																			,oFont22)
				oPrinter:Say(0540,0460, DTOC(STOD((_cAlias)->ENTRADA))														,oFont46)

                oPrinter:EndPage()
			endif
				
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

					cQry := ""
					cQry += " UPDATE "+RetSQLName("SDA")
					cQry += " SET DA_XNRFICH = '" +(_cAlias)->PAG+ "' "
					cQry += " WHERE D_E_L_E_T_ = '' "
					cQry +=		 " AND DA_FILIAL = '"+xFilial("SDA")+"' "
					cQry +=		 " AND DA_ORIGEM = 'SD3' "
					cQry +=		 " AND RTrim(Ltrim(DA_LOCAL)) = '"+(_cAlias)->ARMAZEM+"' "
					cQry +=		 " AND RTrim(Ltrim(DA_DOC)) = '"+(_cAlias)->DOCUMENTO+"' "
					if TCSQLExec(cQry) < 0
						MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_003")
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

					cQry := ""
					cQry += " UPDATE "+RetSQLName("SDA")
					cQry += " SET DA_XNRFICH = '" +(_cAlias)->PAG+ "' "
					cQry += " WHERE D_E_L_E_T_ = '' "
					cQry +=		 " AND DA_FILIAL = '"+xFilial("SDA")+"' "
					cQry +=		 " AND DA_ORIGEM = 'SD3' "
					cQry +=		 " AND RTrim(Ltrim(DA_LOCAL)) = '"+(_cAlias)->ARMAZEM+"' "
					cQry +=		 " AND RTrim(Ltrim(DA_DOC)) = '"+(_cAlias)->DOCUMENTO+"' "
					if TCSQLExec(cQry) < 0
						MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_003")
					endif
			Endif
			(_cAlias)->(dbSkip())
	enddo

if AllTrim(FunName()) == "MATA250" 
	//oPrinter:Preview()
	oPrinter:Print()
else
	//	oPrinter:Preview()
	oPrinter:Print()
Endif
//MsgInfo("Foram processados " + cValToChar(nRegs) + " produtos.",_cRotina + "_001")
if Select(_cAlias) > 0
	(_cAlias)->(dbCloseArea())
endif
return
/*/{Protheus.doc} ValidPerg
Verifica as perguntas no dicionário SX1, as criando, caso não existam.
@author Eduardo Nunes dos Santos (ALLSS Soluções em Sistemas)
@since 21/12/2020
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
	_aTam  := {01,00,"C"}
	AADD(_aRegs,{_cPerg,"07","Cód.Barras (1 a 8)?","","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par07",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSX3("B1_TIPO")
	AADD(_aRegs,{_cPerg,"08","Do Tipo?"        ,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"09","Ao Tipo?"        ,"","","mv_ch9",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par09",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	_aTam  := TamSX3("D3_DOC")
	AADD(_aRegs,{_cPerg,"10","Do Documento?"        ,"","","mv_ch10",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par10",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"11","Ao Documento?"        ,"","","mv_ch11",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par11",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	
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
