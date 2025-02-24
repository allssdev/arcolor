//COLOCAR xFilial na Query
//Alterar a documenta็ใo para o PDoc (atalho: CTRL+D)
//Colocar as variแveis com um underline antes
//No pergunte, colocแ-lo no If .not., para no retorno negativo, dar um return
//Alterar o alias da query de "QRYRUM" para algo mais especํfico para esta rotina, para nใo concorrer com outros Alias.
//Usar o include "RWMAKE.CH"
//Para as perguntas, colher os 03 parโmetros do TAMSX3 (tamanho, decimais e tipo) - Jม TRATADO!!!!
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"

/*/{Protheus.doc} RESTR005
//TODO Relat๓rio da ฺltima Movimenta็ใo de Mat้rias Primas e Produtos Acabados 
@author Djalma Mathias da Silva
@since 13/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

User Function RESTR005()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Private oReport  := Nil 
Private oSecCab	 := Nil

/* FB - RELEASE 12.1.23
Private cPerg 	 := PadR ("RESTR005", Len (SX1->X1_GRUPO))
*/
_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))
Private cPerg 	 := PadR ("RESTR005", Len ((_cAliasSX1)->X1_GRUPO))
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ 
//ณCriacao e apresentacao das perguntas      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/* FB - RELEASE 12.1.23
PutSx1(cPerg,"01","Emissao De ?"  		,'','',"mv_ch1",TamSx3 ("D3_EMISSAO")[3],TamSx3 ("D3_EMISSAO")[1] 	,TamSx3 ("D3_EMISSAO")[2]	,0,"D","","","","","mv_par01",""			 ,"","","","",""		  ,"","","","","","","","","","")
PutSx1(cPerg,"02","Emissao At้?" 		,'','',"mv_ch2",TamSx3 ("D3_EMISSAO")[3],TamSx3 ("D3_EMISSAO")[1] 	,TamSx3 ("D3_EMISSAO")[2]	,0,"D","","","","","mv_par02",""			 ,"","","","",""		  ,"","","","","","","","","","")
PutSx1(cPerg,"03","Local Moviment.?" 	,'','',"mv_ch3",'N'						,1							,0 							,2,"C","","","","","mv_par03","Ord. Producao","","","","","NFs Saํdas","","","","","","","","","","")
*/
_cPerg    := cPerg
_cValid   := ""
_cF3      := ""
_cPicture := ""
_cDef01   := ""
_cDef02   := ""
_cDef03   := ""
_cDef04   := ""
_cDef05   := ""
_cHelp    := ""
U_RGENA001(_cPerg, "01" ,"Emissao De ?"    , "MV_PAR01", "mv_ch1", TamSx3 ("D3_EMISSAO")[3],TamSx3 ("D3_EMISSAO")[1], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
U_RGENA001(_cPerg, "02" ,"Emissao At้? ?"  , "MV_PAR02", "mv_ch2", TamSx3 ("D3_EMISSAO")[3],TamSx3 ("D3_EMISSAO")[1], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

_cDef01   := "Ord. Producao"
_cDef02   := "NFs Saํdas"
U_RGENA001(_cPerg, "03" ,"Local Moviment.?", "MV_PAR03", "mv_ch3", "N", 01, 0, _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicoes/preparacao para impressao      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Pergunte(cPerg, .T.)
	return
EndIf
ReportDef() 
oReport	:PrintDialog()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณ Djalma Mathias da Silvaบ Dataณ13/06/2018บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Defini็ใo da estrutura do relat๓rio.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()

//Local oSection1	:= nil
//Local oSection2 := nil

oReport := TReport():New("RESTR005","Movimen. de Produtos",cPerg,{|oReport| PrintReport(oReport)},"Relat๓rio de Mat้rias Primas e Produtos com a ๚ltima Data de Movimenta็ใo")
oReport:SetLandscape(.T.)
oReport:oPage:setPaperSize(10) 
oReport:nfontbody:=10
oReport:cfontbody:="Arial"
oReport:SetLineHeight(40) 
oReport:lHeaderVisible := .T. 
oReport:lFooterVisible := .F. 
//oReport:SetHeaderBreak(.F.) 

oSecCab := TRSection():New( oReport , "CODIGO", {"QRYRUM"} ) 

TRCell():New( oSecCab, "LOCAL"  				, "QRYRUM"	,	"LOCAL"         					,"@!"	,02) 
TRCell():New( oSecCab, "TIPO" 					, "QRYRUM"	,	"TIPO"    							,"@!"	,02)
TRCell():New( oSecCab, "GRUPO" 					, "QRYRUM"	,	"GRUPO"					    		,"@!"	,02)
TRCell():New( oSecCab, "CODIGO" 				, "QRYRUM"	,	"CODIGO"  							,"@!"	,15) 
TRCell():New( oSecCab, "DESCRICAO" 				, "QRYRUM"	,	"DESCRICAO" 						,"@!"	,40)
TRCell():New( oSecCab, "EMISSAO"				, "QRYRUM"	,	"EMISSAO"  							,"@!"	,10,,{|| SUBSTR(QRYRUM->EMISSAO,01,10) }) 
TRCell():New( oSecCab, "DOCUMENTO"				, "QRYRUM"	,  IF(MV_PAR03=1,"DOCUMENTO","NF SAIDA"),"@!"	,09,,{|| SUBSTR(QRYRUM->DOCUMENTO,01,09) })
 
//TRCell():New( oSecCab, "B1_TIPO"    , "QRYRUM")
//TRCell():New( oSecCab, "B1_UM"      , "QRYRUM")

//TRFunction():New(/*Cell*/             ,/*cId*/,/*Function*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,/*Section*/)
//TRFunction():New(oSecCab:Cell("SD3RES.D3_COD"),/*cId*/,"COUNT"     ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)
 
Return Nil 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutorณ Djalma Mathias da SilvaบDataณ 13/06/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport)

Local _cQuery     := ""

//Pergunte(cPerg,.T.)

If MV_PAR03=1			

/*	_cQuery += "SELECT		SD3RES.D3_LOCAL LOCAL,"							+ CRLF	
	_cQuery += "			SD3RES.D3_TIPO TIPO, "							+ CRLF
	_cQuery += "			SB1.B1_GRUPO GRUPO, "							+ CRLF	
	_cQuery += "			SD3RES.D3_COD CODIGO,"							+ CRLF
	_cQuery += "			SB1.B1_DESC DESCRICAO,"							+ CRLF
	_cQuery += " 			MAX(SUBSTRING(D3_EMISSAO,7,2)+'/'+"				+ CRLF
	_cQuery += " 				SUBSTRING(D3_EMISSAO,5,2)+'/'+"				+ CRLF
	_cQuery += "				SUBSTRING(D3_EMISSAO,1,4) + " 				+ CRLF
	_cQuery += "				SD3RES.D3_DOC ) DOCUMENTO "					+ CRLF		
	_cQuery += "FROM " + RetSqlName("SD3") + " SD3RES " 					+ CRLF 
	_cQuery += "INNER JOIN " + RetSqlName("SB1") + " "						+ CRLF  
	_cQuery += "			SB1 ON	SB1.B1_FILIAL='"+xFilial('SB1')+"'	AND " + CRLF 
	_cQuery += "			SB1.B1_COD=SD3RES.D3_COD			AND	"  		+ CRLF 
	_cQuery += "			SB1.B1_TIPO IN ('MP','EM','PI')		AND	"  		+ CRLF 
	_cQuery += "			SB1.B1_MSBLQL='2'					AND	"  		+ CRLF 
	_cQuery += "			SB1.D_E_L_E_T_ = ' '	"  						+ CRLF  
	_cQuery += "WHERE 		SD3RES.D3_FILIAL='"+xFilial('SD3')+"' AND "		+ CRLF
	_cQuery += "			SD3RES.D3_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "  + CRLF
	_cQuery += "			SD3RES.D3_OP<>'' 			AND "  				+ CRLF
	_cQuery += "			SD3RES.D3_TM>'500' 			AND "  				+ CRLF
	_cQuery += "			SD3RES.D_E_L_E_T_ = ' ' "  						+ CRLF
	_cQuery += "GROUP BY	SD3RES.D3_COD, SD3RES.D3_LOCAL, SD3RES.D3_TIPO, SB1.B1_GRUPO, SB1.B1_DESC  "									+ CRLF
	_cQuery += "ORDER BY 	SD3RES.D3_COD "
*/	
	
	_cQuery += "SELECT	SD3T.D3_LOCAL LOCAL, "											+ CRLF	
	_cQuery += "		SD3T.D3_TIPO TIPO, "											+ CRLF	
	_cQuery += "		SD3T.D3_GRUPO GRUPO, "											+ CRLF	
	_cQuery += "		SD3T.D3_COD CODIGO, "											+ CRLF	
	_cQuery += "		SB1T.B1_DESC DESCRICAO,"										+ CRLF	
	_cQuery += "		SUBSTRING(SD3T.D3_EMISSAO,7,2)+'/'+ "							+ CRLF	
	_cQuery += "		SUBSTRING(SD3T.D3_EMISSAO,5,2)+'/'+ "							+ CRLF	
	_cQuery += "		SUBSTRING(SD3T.D3_EMISSAO,1,4) EMISSAO, "						+ CRLF			
	_cQuery += "		SD3T.D3_OP DOCUMENTO " 											+ CRLF	
	_cQuery += "FROM	" + RetSqlName("SD3") + " SD3T (NOLOCK)"						+ CRLF	
	_cQuery += "INNER	JOIN " + RetSqlName("SB1") + " SB1T (NOLOCK) ON "				+ CRLF	
	_cQuery += "		SB1T.B1_FILIAL = SD3T.D3_FILIAL		AND "						+ CRLF	
	_cQuery += "		SB1T.B1_COD=SD3T.D3_COD				AND "						+ CRLF	
	_cQuery += "		SB1T.B1_MSBLQL='2'					AND "						+ CRLF	
	_cQuery += "		SB1T.D_E_L_E_T_ = ' ' "											+ CRLF	
	_cQuery += "WHERE	(SD3T.D3_EMISSAO+SD3T.D3_LOCAL+SD3T.D3_TIPO+SD3T.D3_OP) IN "	+ CRLF	
	_cQuery += "	(	SELECT	MAX(D3_EMISSAO+D3_LOCAL+D3_TIPO+D3_OP) "				+ CRLF	
	_cQuery += "		FROM	" + RetSqlName("SD3") + " SD3 (NOLOCK) "				+ CRLF		
	_cQuery += "		INNER	JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON "			+ CRLF	
	_cQuery += "				SB1.B1_FILIAL=SD3.D3_FILIAL			AND "				+ CRLF	
	_cQuery += "				SB1.B1_COD=SD3.D3_COD				AND "				+ CRLF	
	_cQuery += "				SB1.B1_MSBLQL='2'					AND "				+ CRLF	
	_cQuery += "				SB1.B1_TIPO IN ('MP','EM','PI')		AND "				+ CRLF	
	_cQuery += "				SB1.D_E_L_E_T_ = ' ' "									+ CRLF	
	_cQuery += "		WHERE	SD3.D3_FILIAL='01'					AND "				+ CRLF	
	_cQuery += "				SD3.D3_COD=SD3T.D3_COD				AND "				+ CRLF	
	_cQuery += "				SD3.D3_OP<>'' 						AND "				+ CRLF	
	_cQuery += "				SD3.D3_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "	+ CRLF	
	_cQuery += "				SD3.D3_TM>'500' 					AND "				+ CRLF	
	_cQuery += "				SD3.D_E_L_E_T_ = ' ' )"									+ CRLF						
	_cQuery += "ORDER BY SD3T.D3_COD	"
	
Else
/*
	_cQuery += "SELECT	SD2.D2_LOCAL LOCAL, "								+ CRLF
	_cQuery += "		SB1.B1_TIPO TIPO, "									+ CRLF
	_cQuery += "		SB1.B1_GRUPO GRUPO, "								+ CRLF	
	_cQuery += "		SD2.D2_COD CODIGO, "								+ CRLF
	_cQuery += "		SB1.B1_DESC DESCRICAO, "							+ CRLF
	_cQuery += "		MAX(SUBSTRING(SD2.D2_EMISSAO,7,2)+'/'+ "			+ CRLF
	_cQuery += "			SUBSTRING(SD2.D2_EMISSAO,5,2)+'/'+ "			+ CRLF
	_cQuery += "			SUBSTRING(SD2.D2_EMISSAO,1,4)+ "				+ CRLF
	_cQuery += "			SD2.D2_DOC) DOCUMENTO "							+ CRLF
	_cQuery += "FROM "+ RetSqlName("SD2") +" SD2 "							+ CRLF
	_cQuery += "INNER JOIN	"+ RetSqlName("SF2") +" SF2 ON "				+ CRLF
	_cQuery += "			SF2.F2_FILIAL='"+xFilial('SF2')+"'		AND "	+ CRLF
	_cQuery += "			SF2.F2_CLIENTE=SD2.D2_CLIENTE	AND "			+ CRLF
	_cQuery += "			SF2.F2_LOJA=SD2.D2_LOJA			AND "			+ CRLF 
	_cQuery += "			SF2.F2_EMISSAO=SD2.D2_EMISSAO	AND "			+ CRLF 
	_cQuery += "			SF2.F2_TIPO='N'					AND "			+ CRLF
	_cQuery += "			SF2.D_E_L_E_T_ = ' ' "							+ CRLF
	_cQuery += "INNER JOIN "+ RetSqlName("SF4") + " SF4 ON "				+ CRLF
	_cQuery += "			SF4.F4_FILIAL='"+xFilial('SF4')+"'		AND "	+ CRLF
	_cQuery += "			SF4.F4_CODIGO=SD2.D2_TES		AND "			+ CRLF
	_cQuery += "			SF4.F4_ESTOQUE='S'				AND "			+ CRLF
	_cQuery += "			SF4.D_E_L_E_T_ = ' ' "							+ CRLF
	_cQuery += "INNER JOIN "+ RetSqlName("SB1") + " SB1 ON "				+ CRLF
	_cQuery += "			SB1.B1_FILIAL='"+xFilial('SB1')+"'		AND "	+ CRLF
	_cQuery += "			SB1.B1_COD=SD2.D2_COD			AND "			+ CRLF  
	_cQuery += "			SB1.B1_TIPO='PA'				AND "			+ CRLF
	_cQuery += "			SB1.B1_MSBLQL<>'1'				AND "			+ CRLF
	_cQuery += "			SB1.D_E_L_E_T_ = ' ' "							+ CRLF
	_cQuery += "WHERE		SD2.D2_FILIAL='"+xFilial('SD2')+"' AND "		+ CRLF
	_cQuery += "			SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND " + CRLF
	_cQuery += "			SD2.D_E_L_E_T_ = ' ' "							+ CRLF
	_cQuery += "GROUP BY	SD2.D2_COD, SD2.D2_LOCAL, SB1.B1_TIPO, SB1.B1_GRUPO, SB1.B1_DESC "	+ CRLF
	_cQuery += "ORDER BY	SD2.D2_COD "
 */
	_cQuery += " SELECT	SD2T.D2_LOCAL LOCAL, "														+ CRLF
	_cQuery += "		SB1T.B1_TIPO TIPO, "														+ CRLF
	_cQuery += "		SB1T.B1_GRUPO GRUPO, "														+ CRLF
	_cQuery += "		SD2T.D2_COD CODIGO, "														+ CRLF
	_cQuery += "		SB1T.B1_DESC DESCRICAO, " 													+ CRLF
	_cQuery += "		SUBSTRING(SD2T.D2_EMISSAO,7,2)+'/'+ "										+ CRLF
	_cQuery += "		SUBSTRING(SD2T.D2_EMISSAO,5,2)+'/'+ "										+ CRLF
	_cQuery += "		SUBSTRING(SD2T.D2_EMISSAO,1,4) EMISSAO, "									+ CRLF
	_cQuery += "		SD2T.D2_DOC DOCUMENTO  "													+ CRLF
	_cQuery += "FROM	"+ RetSqlName("SD2") +" SD2T (NOLOCK) "										+ CRLF
	_cQuery += "INNER	JOIN "+ RetSqlName("SB1") +" SB1T ON "										+ CRLF
	_cQuery += "		SB1T.B1_FILIAL = SD2T.D2_FILIAL		AND "									+ CRLF
	_cQuery += "		SB1T.B1_COD=SD2T.D2_COD				AND "									+ CRLF
	_cQuery += "		SB1T.B1_MSBLQL='2'					AND "									+ CRLF
	_cQuery += "		SB1T.D_E_L_E_T_ = ' ' "														+ CRLF
	_cQuery += "WHERE	(SD2T.D2_EMISSAO+SD2T.D2_COD+SD2T.D2_LOCAL+SD2T.D2_TIPO+SD2T.D2_DOC) IN "	+ CRLF
	_cQuery += "	(	SELECT	MAX(SD2.D2_EMISSAO+SD2.D2_COD+SD2.D2_LOCAL+SD2.D2_TIPO+SD2.D2_DOC) "+ CRLF
	_cQuery += "		FROM	"+ RetSqlName("SD2") +" SD2 (NOLOCK) "								+ CRLF
	_cQuery += "		INNER JOIN	"+ RetSqlName("SF2") +" SF2 ON "								+ CRLF
	_cQuery += "					SF2.F2_FILIAL='"+xFilial('SF2')+"'				AND "			+ CRLF
	_cQuery += "					SF2.F2_CLIENTE=SD2.D2_CLIENTE	AND "							+ CRLF
	_cQuery += "					SF2.F2_LOJA=SD2.D2_LOJA			AND " 							+ CRLF
	_cQuery += "					SF2.F2_EMISSAO=SD2.D2_EMISSAO	AND "							+ CRLF
	_cQuery += "					SF2.F2_TIPO='N'					AND "							+ CRLF
	_cQuery += "					SF2.D_E_L_E_T_ = ' ' "											+ CRLF
	_cQuery += "		INNER JOIN	"+ RetSqlName("SF4") +" SF4 ON "								+ CRLF
	_cQuery += "					SF4.F4_FILIAL='"+xFilial('SF4')+"'				AND "			+ CRLF
	_cQuery += "					SF4.F4_CODIGO=SD2.D2_TES		AND "							+ CRLF
	_cQuery += "					SF4.F4_ESTOQUE='S'				AND " 							+ CRLF 
	_cQuery += "					SF4.D_E_L_E_T_ = ' ' "											+ CRLF
	_cQuery += "		INNER JOIN	"+ RetSqlName("SB1") +" SB1 ON "								+ CRLF
	_cQuery += "					SB1.B1_FILIAL='"+xFilial('SB1')+"'				AND "			+ CRLF
	_cQuery += "					SB1.B1_COD=SD2.D2_COD			AND "							+ CRLF
	_cQuery += "					SB1.B1_TIPO='PA'				AND "							+ CRLF
	_cQuery += "					SB1.B1_MSBLQL<>'1'				AND "							+ CRLF
	_cQuery += "					SB1.D_E_L_E_T_ = ' ' "											+ CRLF
	_cQuery += "		WHERE		SD2.D2_FILIAL='"+xFilial('SD2')+"' AND "						+ CRLF
	_cQuery += "					SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "+ CRLF
	_cQuery += "					SD2.D2_COD=SD2T.D2_COD			AND "							+ CRLF
	_cQuery += "					SD2.D_E_L_E_T_ = ' ' ) "										+ CRLF
	_cQuery += "ORDER BY SD2T.D2_COD "
 
 
 
EndIf  
  
If Select("QRYRUM") > 0 
	Dbselectarea("QRYRUM")
	QRYRUM->(DbClosearea())
EndIf  

TcQuery _cQuery New Alias "QRYRUM" 
 
oSecCab:BeginQuery()
oSecCab:EndQuery({{"QRYRUM"},_cQuery})    
oSecCab:Print()

Return Nil
