#include 'totvs.ch'
#include 'protheus.ch'
#include 'fwprintsetup.ch'
#include 'rptdef.ch'
#define DMPAPER_A4 9
/*/{Protheus.doc} RESTR006
Ficha Pallet em modo Paisagem.
@author Eduardo Nunes dos Santos (ALLSS Solu��es em Sistemas)
@since 21/12/2020
@type function
@version 1.00
@hystory Diego Rodrigues 01/02/21 - ajustes no fonte para adaptar ao processo de impress�o da ficha pallet
@hystory Diego Rodrigues 16/02/21 - Alinhado com o Paulo em Reuni�o que ir�o utilizar o c�digo de barras ean13(unit�rio)
@history 10/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Adi��o de data/hora de impress�o e melhoria na tela de par�metros para controle das op��es selecionadas.
@history 24/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste do lado esquerdo da impress�o para que n�o haja cortes em impressora f�sica.
@history 24/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste para correta carga e considera��o dos dados informados na tela de parametriza��o do relat�rio para impress�o.
@history 25/08/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajuste do lado inferior direito da impress�o para que n�o haja cortes em impressora f�sica.
@history 05/10/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Impress�o do c�digo de barras do lote considerando apenas os 6 primeiros digitos da Ordem de Produ��o.
@history 01/08/2024, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequa��o para o controle de ficha pallet buscar o numero do apontamento campo (D3_XNRFICH)
@history 10/02/2025, Diego Rodrigues (diego.rodrigues@allss.com.br), Adequa��o para a impress�o a partir da rotina MATA681(roteiro de opera��es)
/*/
user function RESTR006()
Local   _aSavArea := GetArea()
Local   _aSavSD4  := SD4->(GetArea())
Local   _aSavSB1  := SB1->(GetArea())
Local   _aSavSD3  := SD3->(GetArea())
Local   _aSavSH6  := SH6->(GetArea())
Local   _aSavSC2  := SC2->(GetArea())
private _cRotina := "RESTR006"
private _cPerg   := _cRotina
private _cAlias  := GetNextAlias()
	
	If AllTrim(FunName())=="MATA250"  
		
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
		MV_PAR12 := ""
		MV_PAR13 := "ZZ"
		//Carrega os dados para fins de impress�o
		ChrFicha()
		//Imprime a ficha pallet
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
		MV_PAR12 := _cNficha
		MV_PAR13 := _cNficha
		//Carrega os dados para fins de impress�o
		ChrFicha()
		//Imprime a ficha pallet
		PrtFicha()
	Else
		ValidPerg()
		if Pergunte(_cPerg)
			if Select(_cAlias) > 0
			(_cAlias)->(dbCloseArea())
		EndIf
		//Carrega os dados para fins de impress�o
		ChrFicha()
		//Imprime a ficha pallet
		PrtFicha()
		EndIf
	EndIf
RestArea(_aSavSC2)
RestArea(_aSavSD3)
RestArea(_aSavSH6)
RestArea(_aSavSB1)
RestArea(_aSavSD4)
RestArea(_aSavArea)
 return
/*/{Protheus.doc} ChrFicha
Carrega os dados a serem impressos.
@author Eduardo Nunes dos Santos (ALLSS Solu��es em Sistemas)
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
			 , RTRIM(ISNULL(B5_XLINPRO,'')) LINHA_PROD
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
												AND (CASE WHEN D3_XNRFICH BETWEEN %Exp:MV_PAR12% AND %Exp:MV_PAR13% THEN 1 ELSE 0 END) = 1
												
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
@author Eduardo Nunes dos Santos (ALLSS Solu��es em Sistemas)
@since 21/12/2020
@type function
@version 1.00
@see https://allss.com.br
/*/
static function PrtFicha()
local   _nInc
local 	_nFic
local   _nNum := 0
local   lAdjustToLegacy := .F.
local   lDisableSetup   := .T.
local   _nRegs          := 0
local   _cName          := _cRotina
local   _nFlags   	 	:= PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION
local   _cSession	 	:= GetPrinterSession()
local   _cDevice    		:= fwGetProfString(_cSession,"PRINTTYPE"	,"SPOOL"	,.T.)
local   _cDestino	    := fwGetProfString(_cSession,"DEFAULT"	,"c:\temp"	,.T.)
private _cSpool         := GetTempPath()
private _cPdf           := ""
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
private _clog 			:= ''
private oPrintSetup as Object
private oPrinter 	as Object
private _aDevice
for _nInc := 1 to 1000
	_cPdf := _cName +StrZero(_nInc,4,0)
	if !File(_cSpool+_cPdf+".PDF")
		exit
	EndIf
next
if AllTrim(FunName()) == "MATA250"
	_aDevice := {}
	//�������������������������������������Ŀ
	//�Define os Tipos de Impressao validos �
	//���������������������������������������
	AADD(_aDevice,"DISCO")
	AADD(_aDevice,"SPOOL")
	AADD(_aDevice,"EMAIL")
	AADD(_aDevice,"EXCEL")
	AADD(_aDevice,"HTML" )
	AADD(_aDevice,"PDF"  )
	_nPrintType 						:= aScan(_aDevice,{|x| x == _cDevice})
	_nLocal     							:= iif(fWGetProfString(_cSession,"LOCAL","SERVER",.T.) == "SERVER",1,2)		
	oSetup 								:= FWPrintSetup():New(_nFlags,'Impress�o da Ficha Pallet')
	oSetup:SetPropert(PD_PRINTTYPE   , _nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , 2) 
	oSetup:SetPropert(PD_DESTINATION , _nLocal)
	oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	oSetup:SetPropert(PD_PREVIEW	 , .F.)
	if _cDevice == "PDF"
		oSetup:aOptions[PD_VALUETYPE] 	:= _cDestino
	EndIf
	oPrinter 							:= FWMSPrinter():New(_cPdf,IMP_SPOOL,lAdjustToLegacy,,lDisableSetup,.T.,@oSetup,,,,.F.,)
	if !(oSetup:Activate() == PD_OK)
		oPrinter:Deactivate() 
		Aviso('TOTVS','Relat�rio cancelado pelo usu�rio',{'&OK'},3)
		return .F.
	EndIf
	oPrinter:lServer 					:= oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER                      
	oPrinter:SetResolution(75)
	if oSetup:GetProperty(PD_ORIENTATION) == 2
		oPrinter:SetLandsCape()
	else
		oPrinter:SetPortRait()
	EndIf
	oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
	fwWriteProfString(_cSession,"LOCAL"		,iif(oSetup:GetProperty(PD_DESTINATION) == 1,"SERVER","LOCAL"),.T.)
	fwWriteProfString(_cSession,"PRINTTYPE"	,_aDevice[oSetup:GetProperty(PD_PRINTTYPE)],.T.)
	if oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrinter:nDevice 				:= IMP_SPOOL
		fwWriteProfString(_cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)
		oPrinter:cPrinter 				:= oSetup:aOptions[PD_VALUETYPE]
	elseif oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oPrinter:nDevice 				:= IMP_PDF
		fwWriteProfString(_cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)	
		oPrinter:cPathPDF 				:= oSetup:aOptions[PD_VALUETYPE]
	EndIf	
else
	_aDevice := {}
	//�������������������������������������Ŀ
	//�Define os Tipos de Impressao validos �
	//���������������������������������������
	AADD(_aDevice,"DISCO")
	AADD(_aDevice,"SPOOL")
	AADD(_aDevice,"EMAIL")
	AADD(_aDevice,"EXCEL")
	AADD(_aDevice,"HTML" )
	AADD(_aDevice,"PDF"  )
	_nPrintType 							:= aScan(_aDevice,{|x| x == _cDevice})
	_nLocal     							:= iif(fWGetProfString(_cSession,"LOCAL","SERVER",.T.) == "SERVER",1,2)		
	oSetup 								:= FWPrintSetup():New(_nFlags,'Impress�o da Ficha Pallet')
	oSetup:SetPropert(PD_PRINTTYPE   , _nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , 2) 
	oSetup:SetPropert(PD_DESTINATION , _nLocal)
	oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	oSetup:SetPropert(PD_PREVIEW	 , .F.)
	if _cDevice == "PDF"
		oSetup:aOptions[PD_VALUETYPE] 	:= _cDestino
	EndIf
	oPrinter 							:= FWMSPrinter():New(_cPdf,IMP_SPOOL,lAdjustToLegacy,,lDisableSetup,.T.,@oSetup,,,,.F.,)
	if !(oSetup:Activate() == PD_OK)
		oPrinter:Deactivate() 
		Aviso('TOTVS','Relat�rio cancelado pelo usu�rio',{'&OK'},3)
		return .F.
	EndIf
	oPrinter:lServer 					:= oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER                      
	oPrinter:SetResolution(75)
	if oSetup:GetProperty(PD_ORIENTATION) == 2
		oPrinter:SetLandsCape()
	else
		oPrinter:SetPortRait()
	EndIf
	oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
	fwWriteProfString(_cSession,"LOCAL"		,iif(oSetup:GetProperty(PD_DESTINATION) == 1,"SERVER","LOCAL"),.T.)
	fwWriteProfString(_cSession,"PRINTTYPE"	,_aDevice[oSetup:GetProperty(PD_PRINTTYPE)],.T.)
	if oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrinter:nDevice 				:= IMP_SPOOL
		fwWriteProfString(_cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)
		oPrinter:cPrinter 				:= oSetup:aOptions[PD_VALUETYPE]
	elseif oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oPrinter:nDevice 				:= IMP_PDF
		fwWriteProfString(_cSession,"DEFAULT",oSetup:aOptions[PD_VALUETYPE],.T.)	
		oPrinter:cPathPDF 				:= oSetup:aOptions[PD_VALUETYPE]
	EndIf
EndIf
(_cAlias)->(dbGoTop())
	while !(_cAlias)->(EOF())
		_nNum 				:= INT(((_cAlias)->QTEMB))
		Private _cLinProd	:= ALLTRIM((_cAlias)->LINHA_PROD)
		Private _cLote  	:= ALLTRIM((_cAlias)->LOTE)
		Private _cValidade  := (_cAlias)->VALIDADE //DTOS(DDATABASE+VAL((_cAlias)->VAL_DIAS))
		Private _cPag		:= (_cAlias)->PAG
		Private _cEnd  		:= Alltrim((_cAlias)->ENDERECO)
		/*If ALLTRIM((_cAlias)->LINHA_PROD) == '1'
			_nNum 				:= 1
		Else
			_nNum 				:= INT(((_cAlias)->QTEMB))
		EndIf
		*/
		For _nFic := 1 to _nNum
			Private 	_nPesol  := VAL((_cAlias)->PESOL) * VAL((_cAlias)->QUANT_EMB)
			Private 	_nPesob  := VAL((_cAlias)->PESOB) * VAL((_cAlias)->QUANT_EMB)
			oPrinter:StartPage()
			_nRegs++
			//Box Margem
			oPrinter:Box(0002,0005,0800,0840)

			//Box Produto
			oPrinter:Say(0040,0040, ALLTRIM((_cAlias)->PRODUTO)															,oFont72AT)
			oPrinter:Say(0025,0280, ALLTRIM((_cAlias)->DESCRICAO)														,oFont10AT)				

			//Box C�digo de Barras Produto
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
			oPrinter:Say(0250,0040, IIf(ALLTRIM((_cAlias)->LINHA_PROD) == '3',ALLTRIM((_cAlias)->QUANTIDADE),ALLTRIM((_cAlias)->QUANT_EMB))	,oFont180AT)			

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
			oPrinter:Say(0325,0250, ALLTRIM(STR(_nPesob))																,oFont34)			

			//Box Lote e Validade
			oPrinter:Box(0360,0005,0510,0420)
			oPrinter:Say(0370,0030, "LOTE:"																				,oFont22)
			oPrinter:Say(0475,0040, ALLTRIM(SUBSTR((_cAlias)->LOTE,1,6)) /*+ " " + DTOC(STOD((_cAlias)->VALIDADE)) */	,oFont140AT)

			//Box C�digo de barra lote
			oPrinter:Box(0510,0005,0610,0130)
			oPrinter:Say(0510,0030, "LOTE:"																				,oFont22)
			oPrinter:Code128(0515/*nRow*/ ,0040 /*nCol*/,ALLTRIM(SUBSTR((_cAlias)->LOTE,1,6))/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)
			
			//Box endere�o
			oPrinter:Box(0510,0130,0610,0295)			
			oPrinter:Say(0510,0135, "END:"																			,oFont22)
			oPrinter:Say(0510,0185, ALLTRIM((_cAlias)->ARMAZEM) + "-" + ALLTRIM((_cAlias)->ENDERECO)					,oFont22)
			oPrinter:Code128(0515/*nRow*/ ,0150 /*nCol*/,(_cAlias)->ARMAZEM + _cEnd/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)
			
			//Box Pagina
			oPrinter:Box(0450,0420,0610,0840)
			oPrinter:Say(0465,0520, "FICHA N�:"																			,oFont22)
			oPrinter:Say(0570,0650, AllTrim(_cPag)																	,oFont180AT)

			//Box Documento OP
			oPrinter:Box(0510,0295,0610,0450)			
			oPrinter:Say(0510,0305, "DOC:"																			,oFont22)
			oPrinter:Say(0510,0345,ALLTRIM((_cAlias)->DOCUMENTO)															,oFont22)
			oPrinter:Code128(0515/*nRow*/ ,0305 /*nCol*/,(_cAlias)->DOCUMENTO/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)			
			
			//Box validade 
			oPrinter:Say(0065,0440, "VALIDADE:"																			,oFont22)
			oPrinter:Say(0200,0460, SUBSTR((_cAlias)->VALIDADE,1,4)														,oFont180AT)
			oPrinter:Say(0420,0485, SUBSTR((_cAlias)->VALIDADE,5,2)														,oFont300AT)
			oPrinter:Say(0420,0800, 'Data/Hora Emiss�o: ' + AllTrim(DtoC(Date()) + ' - ' + Time())						,oFont12,nil,,0270)
		
			//Box Data de Entrada
			oPrinter:Box(0510,0455,0610,0650)
			//oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,46/*nRow*/, 1/*nCol*/ ,(_cAlias)->ARMAZEM + _cEnd  /*cCode*/,oPrinter/*oPrint*/,.F./*lCheck*/,/*Color*/,/*lHorz*/,0.025 /*nWidth*/,1/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,0.5/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
			oPrinter:Say(0510,0460, "ENTRADA:"																			,oFont22)
			oPrinter:Say(0540,0460, DTOC(STOD((_cAlias)->ENTRADA))														,oFont46)

			oPrinter:EndPage()
		next _nFic

		Private _nComp  := (_nNum * VAL((_cAlias)->QUANT_EMB))
		Private _nTotal := VAL((_cAlias)->QUANTIDADE)

		If  _nTotal > _nComp
				Private _nDif := VAL((_cAlias)->QUANTIDADE) -  (_nNum * VAL((_cAlias)->QUANT_EMB))
				Private _nEmb := ROUND(_nDif / VAL((_cAlias)->FATOR),2)
				Private _nPesold  := VAL((_cAlias)->PESOL) * _nDif
				Private _nPesobd  := VAL((_cAlias)->PESOB) * _nDif
				_cPag := _cPag

				oPrinter:StartPage()
				_nRegs++
                //Box Margem
                oPrinter:Box(0002,0005,0800,0840)
            
                //Box Produto
				oPrinter:Say(0040,0040, ALLTRIM((_cAlias)->PRODUTO)															,oFont72AT)
				oPrinter:Say(0025,0280, ALLTRIM((_cAlias)->DESCRICAO)														,oFont10AT)				

                //Box C�digo de Barras Produto
                oPrinter:Box(0070,0005,0130,0260)
                oPrinter:Code128(60/*nRow*/ ,0040 /*nCol*/,(_cAlias)->BARRAS/*cCode*/,1/*nWidth*/,35/*nHeigth*/,.F./*lSay*/,,)
                oPrinter:Line(0070,0005,0070,0840)
                
                //Box Embalagem
				oPrinter:Box(0070,0260,0130,0420)
				oPrinter:Say(0075,0265, "EMBALAGEM"																			,oFont22)
				oPrinter:Say(0100,0275, ALLTRIM(STR(_nEmb)) + " " + (_cAlias)->EMB											,oFont34)				

                //Box Quantidade
				oPrinter:Box(0130,0005,0290,0420)
				oPrinter:Say(0140,0030, "QUANTIDADE"																		,oFont22)
				oPrinter:Say(0250,0040, ALLTRIM(STR(_nDif))																	,oFont180AT)

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
				oPrinter:Say(0325,0250, ALLTRIM(STR(_nPesobd))																,oFont34)

                //Box Lote e Validade
				oPrinter:Box(0360,0005,0510,0420)
				oPrinter:Say(0370,0030, "LOTE:"																				,oFont22)
				oPrinter:Say(0475,0040, ALLTRIM(SUBSTR((_cAlias)->LOTE,1,6)) /*+ " " + DTOC(STOD((_cAlias)->VALIDADE)) */	,oFont140AT)
                
				//Box C�digo de barra lote
				oPrinter:Box(0510,0005,0610,0130)
				oPrinter:Say(0510,0030, "LOTE:"																				,oFont22)
				oPrinter:Code128(0515/*nRow*/ ,0040 /*nCol*/,ALLTRIM(SUBSTR((_cAlias)->LOTE,1,6))/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)
				
				//Box endere�o
				oPrinter:Box(0510,0130,0610,0295)			
				oPrinter:Say(0510,0135, "END:"																			,oFont22)
				oPrinter:Say(0510,0185, ALLTRIM((_cAlias)->ARMAZEM) + "-" + ALLTRIM((_cAlias)->ENDERECO)					,oFont22)
				oPrinter:Code128(0515/*nRow*/ ,0150 /*nCol*/,(_cAlias)->ARMAZEM + _cEnd/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)
				
				//Box Pagina
				oPrinter:Box(0450,0420,0610,0840)
				oPrinter:Say(0465,0520, "FICHA N�:"																			,oFont22)
				oPrinter:Say(0570,0650, AllTrim(_cPag)																	,oFont180AT)

				//Box Documento OP
				oPrinter:Box(0510,0295,0610,0450)			
				oPrinter:Say(0510,0305, "DOC:"																			,oFont22)
				oPrinter:Say(0510,0345,ALLTRIM((_cAlias)->DOCUMENTO)															,oFont22)
				oPrinter:Code128(0515/*nRow*/ ,0305 /*nCol*/,(_cAlias)->DOCUMENTO/*cCode*/,1/*nWidth*/,50/*nHeigth*/,.F./*lSay*/,,)			
				
				//Box validade 
				oPrinter:Say(0065,0440, "VALIDADE:"																			,oFont22)
				oPrinter:Say(0200,0460, SUBSTR((_cAlias)->VALIDADE,1,4)														,oFont180AT)
				oPrinter:Say(0420,0485, SUBSTR((_cAlias)->VALIDADE,5,2)														,oFont300AT)
				oPrinter:Say(0420,0800, 'Data/Hora Emiss�o: ' + AllTrim(DtoC(Date()) + ' - ' + Time())						,oFont12,nil,,0270)
			
				//Box Data de Entrada
				oPrinter:Box(0510,0455,0610,0650)
				//oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,46/*nRow*/, 1/*nCol*/ ,(_cAlias)->ARMAZEM + _cEnd  /*cCode*/,oPrinter/*oPrint*/,.F./*lCheck*/,/*Color*/,/*lHorz*/,0.025 /*nWidth*/,1/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,0.5/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
				oPrinter:Say(0510,0460, "ENTRADA:"																			,oFont22)
				oPrinter:Say(0540,0460, DTOC(STOD((_cAlias)->ENTRADA))														,oFont46)

                oPrinter:EndPage()
			EndIf
				
			If AllTrim(FunName())=="MATA250"

					_clog := DTOC(Date()) + " - " + Time() + " - " + __cUserId + " - " + Substr(cUsuario,7,10) + " AUT"
					cQry := ""
					cQry += " UPDATE "+RetSQLName("SD3")
					cQry += " SET D3_LOGIMP = '" + _clog + "' "
					cQry += " WHERE D_E_L_E_T_ = '' "
					cQry +=		 " AND D3_FILIAL = '"+xFilial("SD3")+"' "
					cQry +=		 " AND D3_CF = 'PR0' "
					cQry +=		 " AND RTrim(Ltrim(D3_OP)) = '"+(_cAlias)->OP+"' "
					cQry +=		 " AND RTrim(Ltrim(D3_DOC)) = '"+(_cAlias)->DOCUMENTO+"' "
					if TCSQLExec(cQry) < 0
						MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_001")
					EndIf

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
					EndIf
			Else
					_clog := DTOC(Date()) + " - " + Time() + " - " + __cUserId + " - " + Substr(cUsuario,7,10) + " MAN"
					cQry := ""
					cQry += " UPDATE "+RetSQLName("SD3")
					cQry += " SET D3_LOGIMP = '" + _clog + "' "
					cQry += " WHERE D_E_L_E_T_ = '' "
					cQry +=		 " AND D3_FILIAL = '"+xFilial("SD3")+"' "
					cQry +=		 " AND D3_CF = 'PR0' "
					cQry +=		 " AND RTrim(Ltrim(D3_OP)) = '"+(_cAlias)->OP+"' "
					cQry +=		 " AND RTrim(Ltrim(D3_DOC)) = '"+(_cAlias)->DOCUMENTO+"' "
					if TCSQLExec(cQry) < 0
						MsgStop("[TCSQLError] " + TCSQLError(),_cRotina+"_001")
					EndIf

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
					EndIf
			EndIf
			(_cAlias)->(dbSkip())
	enddo

if AllTrim(FunName()) == "MATA250" 
	//oPrinter:Preview()
	oPrinter:Print()
else
	//	oPrinter:Preview()
	oPrinter:Print()
EndIf
//MsgInfo("Foram processados " + cValToChar(_nRegs) + " produtos.",_cRotina + "_001")
if Select(_cAlias) > 0
	(_cAlias)->(dbCloseArea())
EndIf
return
/*/{Protheus.doc} ValidPerg
Verifica as perguntas no dicion�rio SX1, as criando, caso n�o existam.
@author Eduardo Nunes dos Santos (ALLSS Solu��es em Sistemas)
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
	AADD(_aRegs,{_cPerg,"01","Do Produto?"        	,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SB1"   ,"",""})
	AADD(_aRegs,{_cPerg,"02","Ao Produto?"        	,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SB1"   ,"",""})
	_aTam  := TamSX3("D3_OP"     )
	AADD(_aRegs,{_cPerg,"03","Da Ordem de Prod. ?"	,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par03",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SC2"   ,"",""})
	AADD(_aRegs,{_cPerg,"04","At� a Ordem Prod. ?"	,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","","SC2"   ,"",""})
	_aTam  := TamSX3("D3_EMISSAO")
	AADD(_aRegs,{_cPerg,"05","Da Data Produ��o  ?"	,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par05",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	AADD(_aRegs,{_cPerg,"06","At� Data Produ��o ?"	,"","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par06",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	_aTam  := {01,00,"C"}
	AADD(_aRegs,{_cPerg,"07","C�d.Barras (1 a 8)?"	,"","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par07",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSX3("B1_TIPO")
	AADD(_aRegs,{_cPerg,"08","Do Tipo?"        		,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"09","Ao Tipo?"        		,"","","mv_ch9",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par09",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	_aTam  := TamSX3("D3_DOC")
	AADD(_aRegs,{_cPerg,"10","Do Documento?"        ,"","","mv_ch10",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par10",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"11","Ao Documento?"        ,"","","mv_ch11",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par11",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	_aTam  := TamSX3("D3_XNRFICH")
	AADD(_aRegs,{_cPerg,"12","Da Ficha N�?"        	,"","","mv_ch12",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par12",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	AADD(_aRegs,{_cPerg,"13","At� Ficha N�?"       	,"","","mv_ch13",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par13",""                 ,"","","","",""				,"","","","",""					,"","","","",""        ,"","","","","","","","",""   ,"",""})
	for i := 1 to len(_aRegs)
		if !(_cAliasSX1)->(dbSeek(_cPerg+_aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= Len(_aRegs[i])
						FieldPut(j,_aRegs[i,j])
					else
						Exit
					EndIf
				next
			(_cAliasSX1)->(MsUnLock())
		EndIf
	next
	RestArea(_aArea)
return
