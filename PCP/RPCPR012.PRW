#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwprintsetup.ch"
#define DMPAPER_A4 9
#define ENT (CHR(13)+CHR(10))
/*/{Protheus.doc} RPCPR006
Rotina para impressão de Ordem de Rotulos baseado no fonte RPCPR006
@author Diego Rodrigues (diego.rodrigues@allss.com.br)
@since 25/04/2024
@version P12
@type Function
@obs Sem observações
@see https://allss.com.br
/*/
user function RPCPR012(cOPIni, cOPFim,_aOpImp,_nCpAtu,_nCpTot)
local _nOpIn                := 1
default _nCpAtu             := 1
default _nCpTot             := 1
private _nCtrAtu            := _nCpAtu
private _nCtrTot            := _nCpTot
private _cPerg          	:= AllTrim(FunName())
private _cRotina			:= "RPCPR012"
private _cTitulo			:= "Layout Ordem de Produção"
private _cValidUsr          := SuperGetMv("MV_ORDPIMP",,"000000|000270")
private _cOpIn              := ""
private _cQry               := ""
private _cAls				:= GetNextAlias()
private _cMsg               := ""
private _nLinAp             := SuperGetMv("MV_XLINAP",,10)
private _nVias              := 1
//************************************************************************************
//TRATAMENTO PARA IMPRESSÃO QUANDO A CHAMADA VIER DA ROTINA DE GESTÃO DE OPS PREVISTAS
//************************************************************************************
if (AllTrim(FunName()) == "RPCPA003" .OR. AllTrim(FunName()) == "MATA651" ) .AND. !Empty(cOPIni) .AND. !Empty(cOPFim)
	mv_par01 := cOPIni
	mv_par02 := cOPFim
elseif AllTrim(FunName()) <> "RPCPA001"
	ValidPerg()
    if !Pergunte(_cPerg,.T.)
        Aviso('[0001 - ' + AllTrim(_cRotina) + ']','Parâmetros cancelados. Nada será impresso.',{"OK"},3,'Ausência de parâmetros para impressão')
        return
	endif
else
	if type("_aOpImp") <> "U"
		for _nOpIn := 1 to Len(_aOpImp)
			if _nOpIn > 1
				_cOpIn += ",'" + _aOpImp[_nOpIn,1] + _aOpImp[_nOpIn,2] + _aOpImp[_nOpIn,3] + "'"
			else
				_cOpIn += "'" + _aOpImp[_nOpIn,1] + _aOpImp[_nOpIn,2] + _aOpImp[_nOpIn,3] + "'"			
			endif
		next _nOpIn
	endif
endif
//***************************************************************************
//TRATAMENTO PARA BLOQUEIO DE IMPRESSÕES CONFORME REGRA DE NEGOCIO ESPECIFICA
//***************************************************************************
_cQry   := "SELECT                                                                                                                      " + ENT
_cQry   += "    SC2.C2_FILIAL,                                                                                                          " + ENT
_cQry   += "	SC2.C2_NUM,                                                                                                             " + ENT
_cQry   += "	SC2.C2_ITEM,                                                                                                            " + ENT
_cQry   += "	SC2.C2_SEQUEN,                                                                                                          " + ENT
_cQry   += "	SC2.C2_ITEMGRD,                                                                                                         " + ENT
_cQry   += "	SC2.C2_NUMPAGS                                                                                                          " + ENT
_cQry   += "FROM                                                                                                                        " + ENT
_cQry   +=      RetSqlName("SC2") + " SC2 (NOLOCK)                                                                                      " + ENT
_cQry   += "INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = C2_PRODUTO AND B1_TIPO = 'PA'                            " + ENT
_cQry   += "WHERE                                                                                                                       " + ENT
_cQry   += "    SC2.C2_FILIAL = '" + FwFilial("SC2") + "'                                                                               " + ENT
if !empty(_cOpIn)
	_cQry += "	AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN IN ("      + _cOpIn    + ")                                                " + ENT
else
	_cQry += "	AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN BETWEEN '" + mv_par01  + "' AND '" + mv_par02 + "'                         " + ENT
endif
//_cQry   += "    AND SC2.C2_TPOP = 'P'                                                                                                   " + ENT
_cQry   += "	AND SC2.D_E_L_E_T_ = ''                                                                                                 " + ENT
_cQry   += "ORDER BY                                                                                                                    " + ENT
_cQry   += "    SC2.C2_NUM,                                                                                                             " + ENT
_cQry   += "    SC2.C2_ITEM,                                                                                                            " + ENT
_cQry   += "    SC2.C2_SEQUEN                                                                                                           " + ENT
_cQry   := ChangeQuery(_cQry)
if Select(_cAls) > 0
	(_cAls)->(dbCloseArea())
endif
//MemoWrite("\2.MemoWrite\" + _cRotina + "_QRY_000.TXT",_cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),(_cAls),.T.,.F.)
if !(_cAls)->(EOF())
	while !(_cAls)->(EOF()) .AND. (_cAls)->C2_FILIAL == FwFilial("SC2") .AND. (_cAls)->(C2_NUM + C2_ITEM + C2_SEQUEN) <= mv_par02
			if Len(_cMsg) >= 999999
                Aviso('[0002 - ' + AllTrim(_cRotina) + ']','Falha na quantidade de informações a serem apresentadas! Selecione um intervalo menor das Ordens de Produção para impressão.',{"OK"},3,'Inconsistência nos parâmetros para impressão')
                (_cAls)->(dbCloseArea())
				return
			endif
		dbSelectArea(_cAls)
		(_cAls)->(dbSkip())
	enddo
else
    Aviso('[0004 - ' + AllTrim(_cRotina) + ']','Ordem(ns) de Produção não encontrada(s).',{"OK"},3,'Inconsistência nos parâmetros para impressão')
    (_cAls)->(dbCloseArea())	
	return
endif
(_cAls)->(dbCloseArea())
Processa({|_lEnd| ProcRel(_lEnd)},"[" + _cRotina + "] " + _cTitulo)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ProcRel     º Autor ³ Rodrigo Telecio º Data ³  29/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Processamento principal do relatorio						  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ProcRel(_lEnd)
local _nX                   := 0
private _cQuery           	:= ""
private _cQrySD4            := ""
private _cQry               := ""
private _cNomArq			:= ""
private _cOPSC2Ant			:= ""
private _cOPSD4Ant			:= ""
private _cCtrPag            := ""
private _cNroAtu            := ""
private _cNroTot            := ""
private _cTpProd            := ""
private _cModetq            := ""
private _cAlerge            := ""
private _cDtImpres			:= AllTrim(DtoC(DATE()))
private _cHrImpres			:= AllTrim(TIME())
private _lAdjustToLegacy 	:= .F.
private _lDisableSetup   	:= .F.
private _aFields            := {}
private _aTamSX3            := {}
private _aDevice            := {}
private _cDevice
private _nPrtType        	:= 2
_cNomArq          			:= "op_" + Lower(AllTrim(FWGrpName())) + '-' +	Lower(AllTrim(FwFilialName())) + "_" + DtoS(dDataBase) + "-" + SubStr(TIME(),1,2) + SubStr(TIME(),4,2) + SubStr(TIME(),7,2) + ".pdf"
oProfile                    := FWProfile():New()
oProfile:SetTask('PRINTTYPE')
AADD(_aDevice,"DISCO") // 1
AADD(_aDevice,"SPOOL") // 2
AADD(_aDevice,"EMAIL") // 3
AADD(_aDevice,"EXCEL") // 4
AADD(_aDevice,"HTML" ) // 5
AADD(_aDevice,"PDF"  ) // 6
_cDevice                    := oProfile:LoadStrProfile()
_nPrtType                   := aScan(_aDevice,{|x| x == _cDevice})
if _nPrtType == 0
    _nPrtType        	    := 2
endif
oPrn              			:= FWMSPrinter():New(_cNomArq,_nPrtType,_lAdjustToLegacy,,_lDisableSetup,,,,,,.F.,)
if oPrn:nModalResult == 2
    return .F.
endif
/*
if oPrn:Canceled()
    return .F.
endif
*/
oPrn:nQtdCopies             := 1
oPrn:SetParm("-RFS")
oPrn:SetResolution(72)
oPrn:SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)
oPrn:SetMargin(10,10,10,10)
oPrn:SetViewPDF(.T.)
private oCinBrush   		:= TBrush():New(,RGB(220,220,220)) //Cinza (Gainsboro)
private oFontBarra 			:= TFontEx():New(oPrn,'Courier new',,-16,.T.)
private oFont05   			:= TFontEx():New(oPrn,"Arial Black",05,05,.F.,.F.,.F.)
private oFont06N   			:= TFontEx():New(oPrn,"Arial Black",06,06,.T.,.T.,.F.)
private oFont08   			:= TFontEx():New(oPrn,"Arial Black",08,08,.F.,.F.,.F.)
private oFont08N   			:= TFontEx():New(oPrn,"Arial Black",08,08,.T.,.T.,.F.)
private oFont10    			:= TFontEx():New(oPrn,"Arial Black",10,10,.F.,.T.,.F.)
private oFont14    			:= TFontEx():New(oPrn,"Arial Black",14,14,.F.,.F.,.F.)
private oFont12    			:= TFontEx():New(oPrn,"Arial Black",12,12,.F.,.F.,.F.)
private oFont14T            := TFont():New("Arial Black",14,14,,.F.,,,,,.F.,.F.)
private oFont16N   			:= TFontEx():New(oPrn,"Arial Black",16,16,.T.,.T.,.F.)
private oFont16   			:= TFontEx():New(oPrn,"Arial Black",16,16,.F.,.F.,.F.)
private oFont
private oTempTable
private _cTmp               := GetNextAlias()
private _cAlsSD4            := ""
private _cAlias				:= "PROD"
private _nLin 				:= 0010
private _cLogo				:= FisxLogo("1")
private _aItEmp 			:= {{0035,"Codigo"			,3},; //1
		  						{0075,"Descrição" 	 	,3},; //2
		  						{0250,"Local"   	    ,3},; //3  
		  						{0270,"Lote"			,3},; //4	
                                {0350,"Quantidade"   	,3},; //5  
                                {0420,"QTDE Utilizada"  ,3},;  //6
                                {0480,"U.M."			,3},; //7
                                {0500,"Saldo"			,3}} //8
private _aItOpe				:= {{0035,"Recurso"			,3},; //1
								{0075,"Descrição" 	 	,3},; //2  
		  						{0230,"Operação"		,3},; //3
								{0270,"Descrição"		,3},; //4
                                {0430,""		        ,3},; //5
								{0490,""                ,3},; //6
								{0520,""				,3}}  //7
private _aItApont           := {{0035,"Item"			,3},; //1
								{0060,"Qtde" 	     	,3},; //2  
		  						{0115,"Conferente"		,3},; //3
								{0215,"Resp.Apont."		,3},; //4
                                {0315,"Data"	        ,3},; //5
								{0375,"Observação"		,3}}  //6
private _aItParada          := {{0035,"Inicio"			,3},; //1
								{0090,"Término"	     	,3},; //2  
		  						{0155,"Tipo"	    	,3},; //3
								{0220,"Descrição"		,3},; //4
                                {0360,"Motivo"	        ,3}}  //5
private _aItRefugo          := {{0035,"Cod. Produto"    ,3},; //1
								{0090,"Quantidade"     	,3},; //2  
		  						{0155,"Lote Fabr."   	,3},; //3
								{0220,"Causa"		    ,3},; //4
                                {0360,"Destino"	        ,3}}  //5
_cQuery := "SELECT                                                                                                                      " + ENT
_cQuery += "	SUBSTRING(SC2.C2_EMISSAO,7,2) + '/'+ SUBSTRING(SC2.C2_EMISSAO,5,2) + '/' + SUBSTRING(SC2.C2_EMISSAO,1,4) C2_EMISSAO,    " + ENT
_cQuery += "	SC2.C2_NUM,                                                                                                             " + ENT
_cQuery += "	SC2.C2_ITEM,                                                                                                            " + ENT
_cQuery += "	SC2.C2_SEQUEN,                                                                                                          " + ENT
_cQuery += "	SC2.C2_ITEMGRD,                                                                                                         " + ENT
_cQuery += "	SUBSTRING(SC2.C2_DATPRF,7,2) + '/' + SUBSTRING(SC2.C2_DATPRF,5,2) + '/' + SUBSTRING(SC2.C2_DATPRF,1,4) C2_DATPRF,       " + ENT
_cQuery += "	SC2.C2_PRODUTO,                                                                                                         " + ENT
_cQuery += "	ISNULL(SB1A.B1_DESC,'') DESC_SC2,                                                                                       " + ENT
_cQuery += "    SB1A.B1_TIPO TIPO_SC2,                                                                                                  " + ENT
_cQuery += "	SB1A.B1_OPERPAD,																										" + ENT
_cQuery += "    SB1A.B1_PRVALID,                                                                                                        " + ENT
_cQuery += "    SB1A.B1_REVATU,                                                                                                         " + ENT
_cQuery += "    SB5A.B5_XALERGE,                                                                                                        " + ENT
_cQuery += "    ISNULL(CASE WHEN SB5A.B5_XMODETQ = '1' THEN '2145-P' ELSE '0990-G' END,'') AS B5_XMODETQ,                               " + ENT
_cQuery += "	SC2.C2_PEDIDO,                                                                                                          " + ENT
_cQuery += "	ISNULL(SC5.C5_CLIENTE,'') C5_CLIENTE,                                                                                   " + ENT
_cQuery += "	ISNULL(SC5.C5_LOJACLI,'') C5_LOJACLI,                                                                                   " + ENT
_cQuery += "	ISNULL(SA1.A1_NOME,'') A1_NOME,                                                                                         " + ENT
_cQuery += "    SUBSTRING(SC2.C2_DATRF,7,2) + '/' + SUBSTRING(SC2.C2_DATRF,5,2) + '/' + SUBSTRING(SC2.C2_DATRF,1,4) C2_DATRF,           " + ENT
_cQuery += "	SC2.C2_DESTINA,                                                                                                         " + ENT
_cQuery += "	SC2.C2_ROTEIRO,                                                                                                         " + ENT
_cQuery += "	SUM(SC2.C2_QUJE) C2_QUJE,                                                                                               " + ENT
_cQuery += "    SUM(SC2.C2_PERDA) C2_PERDA,                                                                                             " + ENT
_cQuery += "	SUM(SC2.C2_QUANT) C2_QUANT,                                                                                             " + ENT
_cQuery += "	ISNULL(SB1A.B1_UM,'') UM_SC2,																							" + ENT
_cQuery += "	SUBSTRING(SC2.C2_DATPRI,7,2) + '/' + SUBSTRING(SC2.C2_DATPRI,5,2) + '/' + SUBSTRING(SC2.C2_DATPRI,1,4) C2_DATPRI,       " + ENT
_cQuery += "	SC2.C2_CC,                                                                                                              " + ENT
_cQuery += "	SUBSTRING(SC2.C2_DATAJI,7,2) + '/' + SUBSTRING(SC2.C2_DATAJI,5,2) + '/' + SUBSTRING(SC2.C2_DATAJI,1,4) C2_DATAJI,       " + ENT
_cQuery += "	SUBSTRING(SC2.C2_DATAJF,7,2) + '/' + SUBSTRING(SC2.C2_DATAJF,5,2) + '/' + SUBSTRING(SC2.C2_DATAJF,1,4) C2_DATAJF,       " + ENT
_cQuery += "    SC2.C2_STATUS,                                                                                                          " + ENT
_cQuery += "	SC2.C2_OBS,                                                                                                             " + ENT
_cQuery += "	SC2.C2_TPOP,                                                                                                            " + ENT
_cQuery += "    SC2.C2_NUMPAGS,                                                                                                         " + ENT
_cQuery += "    SC2.C2_XCTRATU,                                                                                                         " + ENT
_cQuery += "    SC2.C2_XCTRTOT,                                                                                                         " + ENT
_cQuery += "    SC2.R_E_C_N_O_ SC2RECNO                                                                                                 " + ENT
_cQuery += "FROM                                                                                                                        " + ENT
_cQuery +=      RetSqlName("SC2") + " AS SC2 (NOLOCK)                                                                                   " + ENT
_cQuery += "	LEFT OUTER JOIN                                                                                                         " + ENT
_cQuery +=          RetSqlName("SB1") + " AS SB1A (NOLOCK)                                                                              " + ENT
_cQuery += "	ON                                                                                                                      " + ENT
_cQuery += "        SB1A.B1_FILIAL = SC2.C2_FILIAL                                                                                      " + ENT
_cQuery += "		AND SB1A.B1_COD = SC2.C2_PRODUTO                                                                                    " + ENT
_cQuery += "		AND SB1A.D_E_L_E_T_ = ''                                                                                            " + ENT
_cQuery += "		AND SB1A.B1_TIPO = 'PA'                                                                                             " + ENT
_cQuery += "	LEFT OUTER JOIN                                                                                                         " + ENT
_cQuery +=          RetSqlName("SB5") + " AS SB5A (NOLOCK)                                                                              " + ENT
_cQuery += "	ON                                                                                                                      " + ENT
_cQuery += "        SB5A.B5_FILIAL = SC2.C2_FILIAL                                                                                      " + ENT
_cQuery += "		AND SB5A.B5_COD = SC2.C2_PRODUTO                                                                                    " + ENT
_cQuery += "		AND SB5A.D_E_L_E_T_ = ''                                                                                            " + ENT
_cQuery += "	LEFT OUTER JOIN                                                                                                         " + ENT
_cQuery +=          RetSqlName("SC5") + " AS SC5 (NOLOCK)                                                                               " + ENT
_cQuery += "	ON                                                                                                                      " + ENT
_cQuery += "		SC5.C5_FILIAL = SC2.C2_FILIAL                                                                                       " + ENT
_cQuery += "		AND SC5.C5_NUM = SC2.C2_PEDIDO                                                                                      " + ENT
_cQuery += "		AND SC5.D_E_L_E_T_ = ''                                                                                             " + ENT
_cQuery += "	LEFT OUTER JOIN                                                                                                         " + ENT
_cQuery +=          RetSqlName("SA1") + " AS SA1 (NOLOCK)                                                                               " + ENT
_cQuery += "	ON                                                                                                                      " + ENT
_cQuery += "        SA1.A1_FILIAL = SC5.C5_FILIAL                                                                                       " + ENT
_cQuery += "		AND SA1.A1_COD = SC5.C5_CLIENTE                                                                                     " + ENT
_cQuery += "		AND SA1.A1_LOJA = SC5.C5_LOJACLI                                                                                    " + ENT
_cQuery += "		AND SA1.D_E_L_E_T_ = ''                                                                                             " + ENT
_cQuery += "WHERE                                                                                                                       " + ENT
_cQuery += "    SC2.C2_FILIAL = '" + FwFilial("SC2") + "'                                                                               " + ENT
if !empty(_cOpIn)
	_cQuery += "	AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN IN ("      + _cOpIn    + ")                                            " + ENT
else
	_cQuery += "	AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN BETWEEN '" + mv_par01  + "' AND '" + mv_par02 + "'                     " + ENT
endif
//_cQuery += "    AND SC2.C2_TPOP = 'F'                                                                                                   " + ENT
_cQuery += "	AND SC2.D_E_L_E_T_ = ''																									" + ENT
_cQuery += "GROUP BY
_cQuery += "	SUBSTRING(SC2.C2_EMISSAO,7,2) + '/'+ SUBSTRING(SC2.C2_EMISSAO,5,2) + '/' + SUBSTRING(SC2.C2_EMISSAO,1,4),               " + ENT
_cQuery += "	SC2.C2_NUM,                                                                                                             " + ENT
_cQuery += "	SC2.C2_ITEM,                                                                                                            " + ENT
_cQuery += "	SC2.C2_SEQUEN,                                                                                                          " + ENT
_cQuery += "	SC2.C2_ITEMGRD,                                                                                                         " + ENT
_cQuery += "	SUBSTRING(SC2.C2_DATPRF,7,2) + '/' + SUBSTRING(SC2.C2_DATPRF,5,2) + '/' + SUBSTRING(SC2.C2_DATPRF,1,4),                 " + ENT
_cQuery += "	SC2.C2_PRODUTO,                                                                                                         " + ENT
_cQuery += "	ISNULL(SB1A.B1_DESC,''),                                                                                                " + ENT
_cQuery += "    SB1A.B1_TIPO,                                                                                                           " + ENT
_cQuery += "	SB1A.B1_OPERPAD,																										" + ENT
_cQuery += "    SB1A.B1_PRVALID,                                                                                                        " + ENT
_cQuery += "    SB1A.B1_REVATU,                                                                                                         " + ENT
_cQuery += "    SB5A.B5_XALERGE,                                                                                                        " + ENT
_cQuery += "	SB5A.B5_XMODETQ,                                                                                                        " + ENT
_cQuery += "	SC2.C2_PEDIDO,                                                                                                          " + ENT
_cQuery += "	ISNULL(SC5.C5_CLIENTE,''),                                                                                              " + ENT
_cQuery += "	ISNULL(SC5.C5_LOJACLI,''),                                                                                              " + ENT
_cQuery += "	ISNULL(SA1.A1_NOME,''),                                                                                                 " + ENT
_cQuery += "    SUBSTRING(SC2.C2_DATRF,7,2) + '/' + SUBSTRING(SC2.C2_DATRF,5,2) + '/' + SUBSTRING(SC2.C2_DATRF,1,4),                    " + ENT
_cQuery += "	SC2.C2_DESTINA,                                                                                                         " + ENT
_cQuery += "	SC2.C2_ROTEIRO,                                                                                                         " + ENT
_cQuery += "	ISNULL(SB1A.B1_UM,''),      																							" + ENT
_cQuery += "	SUBSTRING(SC2.C2_DATPRI,7,2) + '/' + SUBSTRING(SC2.C2_DATPRI,5,2) + '/' + SUBSTRING(SC2.C2_DATPRI,1,4),                 " + ENT
_cQuery += "	SC2.C2_CC,                                                                                                              " + ENT
_cQuery += "	SUBSTRING(SC2.C2_DATAJI,7,2) + '/' + SUBSTRING(SC2.C2_DATAJI,5,2) + '/' + SUBSTRING(SC2.C2_DATAJI,1,4),                 " + ENT
_cQuery += "	SUBSTRING(SC2.C2_DATAJF,7,2) + '/' + SUBSTRING(SC2.C2_DATAJF,5,2) + '/' + SUBSTRING(SC2.C2_DATAJF,1,4),                 " + ENT
_cQuery += "    SC2.C2_STATUS,                                                                                                          " + ENT
_cQuery += "	SC2.C2_OBS,                                                                                                             " + ENT
_cQuery += "	SC2.C2_TPOP,                                                                                                            " + ENT
_cQuery += "    SC2.C2_NUMPAGS,                                                                                                         " + ENT
_cQuery += "    SC2.C2_XCTRATU,                                                                                                         " + ENT
_cQuery += "    SC2.C2_XCTRTOT,                                                                                                         " + ENT
_cQuery += "    SC2.R_E_C_N_O_                                                                                                          " + ENT
_cQuery += "ORDER BY																													" + ENT
_cQuery += "	SC2.C2_NUM,																												" + ENT
_cQuery += "	SC2.C2_ITEM,																											" + ENT
_cQuery += "	SC2.C2_SEQUEN,																											" + ENT
_cQuery += "	SC2.C2_ITEMGRD																											" + ENT
_cQuery := ChangeQuery(_cQuery)
MemoWrite("\2.MemoWrite\" + _cRotina + "_QRY_001.TXT",_cQuery)
if Select(_cTmp) > 0
	(_cTmp)->(dbCloseArea())
endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),(_cTmp),.T.,.F.)
dbSelectArea(_cTmp)
if (_cTmp)->(EOF())
	Aviso('[0002 - ' + AllTrim(_cRotina) + ']','Não existem informações para serem impressas.',{"OK"},3,'Ausência de dados para impressão')
	(_cTmp)->(dbCloseArea())
	return
endif
(_cTmp)->(dbGoTop())
_aTamSX3        := TamSX3("C2_EMISSAO")
AADD(_aFields,{"C2_EMISSAO"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_NUM")
AADD(_aFields,{"C2_NUM"      ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_ITEM")
AADD(_aFields,{"C2_ITEM"     ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_SEQUEN")
AADD(_aFields,{"C2_SEQUEN"   ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_ITEMGRD")
AADD(_aFields,{"C2_ITEMGRD"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_DATPRF")
AADD(_aFields,{"C2_DATPRF"   ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_PRODUTO")
AADD(_aFields,{"C2_PRODUTO"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("B1_DESC")
AADD(_aFields,{"DESC_SC2"    ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("B1_TIPO")
AADD(_aFields,{"TIPO_SC2"    ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("B1_OPERPAD")
AADD(_aFields,{"B1_OPERPAD"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("B1_PRVALID")
AADD(_aFields,{"B1_PRVALID"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("B1_REVATU")
AADD(_aFields,{"B1_REVATU"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("B5_XALERGE")
AADD(_aFields,{"B5_XALERGE"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("B5_XMODETQ")
AADD(_aFields,{"B5_XMODETQ"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_PEDIDO")
AADD(_aFields,{"C2_PEDIDO"   ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C5_CLIENTE")
AADD(_aFields,{"C5_CLIENTE"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C5_LOJACLI")
AADD(_aFields,{"C5_LOJACLI"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("A1_NOME")
AADD(_aFields,{"A1_NOME"     ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_DATRF")
AADD(_aFields,{"C2_DATRF"    ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_DESTINA")
AADD(_aFields,{"C2_DESTINA"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_ROTEIRO")
AADD(_aFields,{"C2_ROTEIRO"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_QUJE")
AADD(_aFields,{"C2_QUJE"     ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_PERDA")
AADD(_aFields,{"C2_PERDA"    ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_QUANT")
AADD(_aFields,{"C2_QUANT"    ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("B1_UM")
AADD(_aFields,{"UM_SC2"      ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_DATPRI")
AADD(_aFields,{"C2_DATPRI"   ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_CC")
AADD(_aFields,{"C2_CC"       ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_DATAJI")
AADD(_aFields,{"C2_DATAJI"   ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_DATAJF")
AADD(_aFields,{"C2_DATAJF"   ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_STATUS")
AADD(_aFields,{"C2_STATUS"   ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_OBS")
AADD(_aFields,{"C2_OBS"      ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_TPOP")
AADD(_aFields,{"C2_TPOP"     ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_NUMPAGS")
AADD(_aFields,{"C2_NUMPAGS"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_XCTRATU")
AADD(_aFields,{"C2_XCTRATU"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3        := TamSX3("C2_XCTRTOT")
AADD(_aFields,{"C2_XCTRTOT"  ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
_aTamSX3		:= {10,0,"N"}
AADD(_aFields,{"SC2RECNO"    ,_aTamSX3[03],_aTamSX3[01],_aTamSX3[02]})
oTempTable      := FWTemporaryTable():New(_cAlias)
oTemptable:SetFields(_aFields)
oTempTable:AddIndex("01",{"C2_NUM","C2_ITEM","C2_SEQUEN","C2_ITEMGRD"})
oTempTable:Create()
while !(_cTmp)->(EOF())
    RecLock((_cAlias),.T.)
    for _nX := 1 to Len(_aFields)
        if ValType((_cAlias)->&(_aFields[_nX,1])) == "D"
            (_cAlias)->&(_aFields[_nX,1]) := CtoD((_cTmp)->&(_aFields[_nX,1]))
        else
            (_cAlias)->&(_aFields[_nX,1]) := (_cTmp)->&(_aFields[_nX,1])
        endif
    next _nX
    (_cAlias)->(MsUnlock())
    (_cTmp)->(dbSkip())
enddo
(_cTmp)->(dbCloseArea())
(_cAlias)->(dbGoTop())
ProcRegua(RecCount())
(_cAlias)->(dbGoTop())
while !(_cAlias)->(EOF()) .AND. (_cAlias)->TIPO_SC2 == 'PA'
    _cOPSC2Ant  := AllTrim((_cAlias)->(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD)) 
    _cNroAtu    := cValToChar((_cAlias)->C2_XCTRATU)
    _cNroTot    := cValToChar((_cAlias)->C2_XCTRTOT)
    _cTpProd    := AllTrim((_cAlias)->TIPO_SC2)  
    _cModetq    := (_cAlias)->B5_XMODETQ  
    _cAlerge    := (_cAlias)->B5_XALERGE 
    IncProc("imprimindo OP " + AllTrim(_cOPSC2Ant) + ", aguarde...")

    while !(_cAlias)->(EOF()) .AND. _cOPSC2Ant == AllTrim((_cAlias)->(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD))
        for _nX := 1 to _nVias
            _cQrySD4    := "SELECT                                                                                      " + ENT
            _cQrySD4    += "    SD4.D4_OP,                                                                              " + ENT
            _cQrySD4    += "    SD4.D4_COD,                                                                             " + ENT
            _cQrySD4    += "    SB1B.B1_DESC DESC_SD4,                                                                  " + ENT
            _cQrySD4    += "    SUM(SD4.D4_QTDEORI) D4_QTDEORI,                                                         " + ENT
            _cQrySD4    += "    SB1B.B1_TIPO TIPO_SD4,                                                                  " + ENT
            _cQrySD4    += "    SB1B.B1_UM UM_SD4,                                                                      " + ENT
            _cQrySD4    += "    SD4.D4_LOCAL,                                                                           " + ENT
            _cQrySD4    += "    ISNULL(NNR.NNR_DESCRI,'') NNR_DESCRI,                                                   " + ENT
            _cQrySD4    += "    SD4.D4_TRT,                                                                             " + ENT
            _cQrySD4    += "    SD4.D4_LOTECTL,                                                                         " + ENT
            _cQrySD4    += "    SD4.D4_NUMLOTE,                                                                         " + ENT
            _cQrySD4    += "    ISNULL(SB5.B5_XEMBPRI,'2') B5_XEMBPRI                                                   " + ENT
            _cQrySD4    += "FROM                                                                                        " + ENT
            _cQrySD4    +=      RetSqlName("SD4") + " AS SD4 (NOLOCK)                                                   " + ENT
            _cQrySD4    += "    LEFT OUTER JOIN                                                                         " + ENT
            _cQrySD4    +=          RetSqlName("SB1") + " AS SB1B (NOLOCK)                                              " + ENT
            _cQrySD4    += "    ON                                                                                      " + ENT
            _cQrySD4    += "        SB1B.B1_FILIAL = SD4.D4_FILIAL                                                      " + ENT
            _cQrySD4    += "        AND SB1B.B1_COD = SD4.D4_COD                                                        " + ENT
            _cQrySD4    += "        AND SB1B.D_E_L_E_T_ = ''                                                            " + ENT
            _cQrySD4    += "    LEFT OUTER JOIN                                                                         " + ENT
            _cQrySD4    +=          RetSqlName("NNR") + " AS NNR  (NOLOCK)                                              " + ENT
            _cQrySD4    += "    ON                                                                                      " + ENT
            _cQrySD4    += "        NNR.NNR_FILIAL = SD4.D4_FILIAL                                                      " + ENT
            _cQrySD4    += "        AND NNR.NNR_CODIGO = SD4.D4_LOCAL                                                   " + ENT
            _cQrySD4    += "        AND NNR.D_E_L_E_T_ = ''                                                             " + ENT

            _cQrySD4    += "    INNER JOIN                                                                              " + ENT
            _cQrySD4    +=          RetSqlName("SB5") + " AS SB5  (NOLOCK)                                              " + ENT
            _cQrySD4    += "    ON                                                                                      " + ENT
            _cQrySD4    += "        SB5.B5_FILIAL = SD4.D4_FILIAL                                                       " + ENT
            _cQrySD4    += "        AND SB5.B5_COD = SD4.D4_COD                                                         " + ENT
            //_cQrySD4    += "        AND SB5.B5_XROTULO = '1'                                                            " + ENT
            _cQrySD4    += "        AND SB5.D_E_L_E_T_ = ''                                                             " + ENT

            _cQrySD4    += "WHERE                                                                                       " + ENT
            _cQrySD4    += "    SD4.D4_OP BETWEEN '" + (_cAlias)->(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD) + "' AND '" + (_cAlias)->(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD) + "' " + ENT
			_cQrySD4 += "       AND SB1B.B1_TIPO = 'EM'                                                             	" + ENT
			//_cQrySD4 += "       AND (B1_DESC LIKE '%ROT%' OR B1_DESC LIKE '%ETI%')                                      " + ENT
            _cQrySD4    += "    AND SD4.D_E_L_E_T_ = ''                                                                 " + ENT
            _cQrySD4    += "GROUP BY                                                                                    " + ENT
            _cQrySD4    += "    SD4.D4_OP,                                                                              " + ENT
            _cQrySD4    += "    SD4.D4_COD,                                                                             " + ENT
            _cQrySD4    += "    SB1B.B1_DESC,                                                                           " + ENT
            _cQrySD4    += "    SB1B.B1_TIPO,                                                                           " + ENT
            _cQrySD4    += "    SB1B.B1_UM,                                                                             " + ENT
            _cQrySD4    += "    SD4.D4_LOCAL,                                                                           " + ENT
            _cQrySD4    += "    ISNULL(NNR.NNR_DESCRI,''),                                                              " + ENT
            _cQrySD4    += "    SD4.D4_TRT,                                                                             " + ENT
            _cQrySD4    += "    SD4.D4_LOTECTL,                                                                         " + ENT
            _cQrySD4    += "    SD4.D4_NUMLOTE,                                                                         " + ENT
            _cQrySD4    += "    ISNULL(SB5.B5_XEMBPRI,'2')                                                              " + ENT
            _cQrySD4    += "ORDER BY                                                                                    " + ENT
            _cQrySD4    += "    SD4.D4_OP,                                                                              " + ENT

			if _nX == 1
                _cQrySD4    += "    SD4.D4_COD                                                                          " + ENT
            else
                _cQrySD4    += "    ISNULL(SB5.B5_XEMBPRI,'2'),                                                          " + ENT
                _cQrySD4    += "    SD4.D4_COD                                                                         " + ENT
                
            endif

            _cQrySD4    := ChangeQuery(_cQrySD4)
            MemoWrite("\2.MemoWrite\" + _cRotina + "_QRY_002.TXT",_cQrySD4)
            _cAlsSD4    := GetNextAlias()
            if Select(_cAlsSD4) > 0
                (_cAlsSD4)->(dbCloseArea())
            endif
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQrySD4),(_cAlsSD4),.T.,.F.)
            dbSelectArea(_cAlsSD4)
            _cOPSD4Ant 	:= AllTrim((_cAlsSD4)->D4_OP)
            if !(_cAlsSD4)->(EOF())
                //******************
                //IMPRESSÃO LOGOTIPO
                //******************
                ImpLogo()
                _nLin 		:= 0100
                //**********************************
                //IMPRESSÃO CABEÇALHO DA OP + QRCODE
                //**********************************
                ImpCabOP()
                _nLin 		+= 0005
                //*******************
                //IMPRESSÃO OPERAÇÕES
                //*******************
                dbSelectArea("SC2")
                SC2->(dbSetOrder(1))
                dbSeek(FWFilial("SC2") + (_cAlias)->(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD))
                dbSelectArea("SB1")
                SB1->(dbSetOrder(1))
                dbSeek(FWFilial("SB1") + (_cAlias)->C2_PRODUTO)        
                ImpOpe()
                
                //******************
                //IMPRESSÃO EMPENHOS
                //******************
                ImpCabEmp(_nX)
                dbSelectArea(_cAlsSD4)
                _cTipEmb := "1"
                _limpCabSec := .F.
                while !(_cAlsSD4)->(EOF()) .AND. _cOPSD4Ant == AllTrim((_cAlsSD4)->D4_OP)
                        while Alltrim(_cTipEmb) == AllTrim((_cAlsSD4)->B5_XEMBPRI)
                            _nLin 		+= 0015
                            ImpEmp()
                            (_cAlsSD4)->(dbSkip())
                        enddo    
                        if !_limpCabSec
                            _nLin 		+= 0030
                            ImpCabSec()
                            _limpCabSec := .T.
                        endif

                        _nLin 		+= 0015
                        ImpEmp()
                    (_cAlsSD4)->(dbSkip())
                enddo
                (_cAlsSD4)->(dbCloseArea())
                _nLin 		+= 0005
                //********************************
                //IMPRESSÃO OBSERVAÇÃO DO PROCESSO
                //********************************
                if _nLin >= 0700
                    oPrn:Say(_nLin+0010 ,0035,"CONTINUA NA PRÓXIMA PÁGINA... "							    ,oFont06N:oFont)
                    ImpRodape()
                    ImpLogo()
                    _nLin 		:= 0110
                endif
                     
				ImpObsProc(2)
                _nLin 		+= 0005
               //*****************************
                //IMPRESSÃO DO RODAPÉ DA PÁGINA
                //*****************************
                ImpRodape()
                //********************************
                //IMPRESSÃO PARA PULAR A PAGINA
                //********************************
                 _nLin 		+= 0250      
                //********************************
                //IMPRESSÃO OBSERVAÇÃO DO PROCESSO
                //********************************
                if _nLin >= 0700
                    //oPrn:Say(_nLin+0010 ,0035,"CONTINUA NA PRÓXIMA PÁGINA... "							    ,oFont06N:oFont)
                    ImpRodape()
                    ImpLogo()
                    _nLin 		:= 0110
                endif              
            endif
        next _nX            
        (_cAlias)->(dbSkip())
    enddo
enddo
oPrn:Preview()
FreeObj(oPrn)
oTempTable:Delete()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpLogo     º Autor ³ Rodrigo Telecio º Data ³  01/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão do logotipo e do titulo do relatório			  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpLogo()
oPrn:StartPage()
//quadro
oPrn:FillRect({0030,0030,0100,0550},oCinBrush)
//logotipo (default, de acordo com o configurado no ERP)
oPrn:SayBitmap(0035,0050,_cLogo,0060,0060)
//titulo
oPrn:Say(0070		,0150,"ORDEM  DE  ROTULOS"							                                    ,oFont16N:oFont)
//primeira linha
oPrn:Say(0040		,0400,"Controle de Impressão"			  							                    ,oFont08:oFont)
//segunda linha
oPrn:Say(0050		,0400,"Data da impressão"				  							                    ,oFont06N:oFont)
oPrn:Say(0060		,0400,_cDtImpres				  									                    ,oFont10:oFont)
oPrn:Say(0050		,0480,"Hora da impressão"				  							                    ,oFont06N:oFont)
oPrn:Say(0060		,0480,_cHrImpres				  									                    ,oFont10:oFont)
//terceira linha
oPrn:Say(0075		,0400,"Controle de Cópia Impressa: " + _cCtrPag                                         ,oFont08:oFont)
//quarta linha
oPrn:Say(0085		,0400,"Controle de Arquivo: " + AllTrim(_cNroAtu) + "/" + AllTrim(_cNroTot)             ,oFont08:oFont)
//quinta linha
oPrn:Say(0100		,0400,"Modelo Etiqueta: " + AllTrim(_cModetq)                                           ,oFont08:oFont)

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpCabec    º Autor ³ Rodrigo Telecio º Data ³  01/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão do cabeçalho da ordem de produção				  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpCabOP()
local cRev := IIF(AllTrim((_cAlias)->B1_REVATU) == "","000",AllTrim((_cAlias)->B1_REVATU))
_nLin += 0010
//código de barras
oPrn:QrCode(_nLin+0105,0030,AllTrim((_cAlias)->(C2_NUM + C2_ITEM + C2_SEQUEN)),0110)
//primeira linha
oPrn:Say(_nLin		,0140,"Ordem de produção"		  									            ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0140,(_cAlias)->C2_NUM + " " + (_cAlias)->C2_ITEM + " " + (_cAlias)->C2_SEQUEN ,oFont14:oFont)
oPrn:Say(_nLin		,0440,"Qtd. Original" 	 											            ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0440,AllTrim(Transform((_cAlias)->C2_QUANT,"@E 999,999,999.9999"))		        ,oFont14:oFont)
//segunda linha
_nLin += 0020
oPrn:Say(_nLin		,0140,"Produto"		  												            ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0140,SubStr(AllTrim((_cAlias)->C2_PRODUTO),1,10)					            ,oFont10:oFont)
oPrn:Say(_nLin		,0230,"Rev."		  												            ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0230,SubStr(AllTrim(cRev),1,3)					                                ,oFont10:oFont)
oPrn:Say(_nLin		,0260,"Descrição"	  												            ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0260,AllTrim((_cAlias)->DESC_SC2)  								            ,oFont10:oFont)
//segunda linha
_nLin += 0020
oPrn:Say(_nLin		,0140,"Emissão"	 	 												            ,oFont06N:oFont)
oPrn:Say(_nLin+0010	,0140,DtoC((_cAlias)->C2_EMISSAO)  								                ,oFont10:oFont)
oPrn:Say(_nLin		,0280,"Previsão inicial"											            ,oFont06N:oFont)
oPrn:Say(_nLin+0010	,0280,DtoC((_cAlias)->C2_DATPRI)									            ,oFont10:oFont)
oPrn:Say(_nLin		,0420,"Entrega"														            ,oFont06N:oFont)
oPrn:Say(_nLin+0010	,0420,DtoC((_cAlias)->C2_DATPRF)									            ,oFont10:oFont)
//bloco do centro de custo
_nLin += 0020
oPrn:Box(_nLin      ,0140       ,_nLin+0050     ,0550)
_cCC  :=  AllTrim((_cAlias)->C2_CC) + ' - ' +  AllTrim(Posicione("CTT",1,FwFilial("CTT") + AllTrim((_cAlias)->C2_CC),"CTT_DESC01"))
oPrn:Say(_nLin+0020	,0150,SubStr("C.C.: " + _cCC,1,35)									            ,oFont14:oFont)
oPrn:Say(_nLin+0040	,0150,SubStr("C.C.: " + _cCC,36,35)									            ,oFont14:oFont)
_nLin += 0055
//bloco da observação da OP
_nLin += 0005
oPrn:Box(_nLin      ,0030       ,_nLin+0025     ,0550)
oPrn:Say(_nLin+0010 ,0040,"Observações da OP"														,oFont06N:oFont)
if !Empty(AllTrim((_cAlias)->C2_OBS))
	oPrn:Say(_nLin+0022	,0040,AllTrim((_cAlias)->C2_OBS)										    ,oFont10:oFont)
endif
_nLin += 0025
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpCabOpe   º Autor ³ Rodrigo Telecio º Data ³  29/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão do cabeçalho das operações						  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpCabOpe()
local _nX			:= 0
oPrn:FillRect({_nLin,0030,_nLin+0030,0550},oCinBrush)
oPrn:Say(_nLin+0015 ,0030,"ROTEIRO DE OPERAÇÕES"		                                            ,oFont14:oFont)
for _nX := 1 to Len(_aItOpe)
	oPrn:Say(_nLin+0025,_aItOpe[_nX,1],_aItOpe[_nX,2]									            ,oFont06N:oFont)
next _nX
_nLin += 0010
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpOpe      º Autor ³ Rodrigo Telecio º Data ³  29/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão das operações									  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpOpe()
    oPrn:Say(_nLin		,0400,"Lote"										                ,oFont06N:oFont)
    oPrn:Say(_nLin+0015	,0400,AllTrim((_cAlias)->C2_NUM)							        ,oFont14:oFont)
    _nLin += 0025
    oPrn:Say(_nLin		,0400,"Validade"			        								,oFont06N:oFont)
    if (_cAlias)->B1_PRVALID <> 0
        _cPrzVld    := cValToChar((_cAlias)->B1_PRVALID / 30) + " Meses"
        //_ddtVld     := DtoC((_cAlias)->C2_EMISSAO + (_cAlias)->B1_PRVALID)
        _ddtVld     := DtoC(StoD(SubStr(DtoS((_cAlias)->C2_DATPRF),1,6) + "28") + (_cAlias)->B1_PRVALID)
        _ddtVld     := SubStr(_ddtVld,4)
        oPrn:Say(_nLin+0015	,0400,_cPrzVld + " - " + _ddtVld                                ,oFont14:oFont)
    endif
    _nLin += 0010
    oPrn:Line(_nLin+0010,_aItOpe[1,1],_nLin+0010,_aItOpe[1,1]+0515)
    _nLin += 0010
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpCabEmp   º Autor ³ Rodrigo Telecio º Data ³  29/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão do cabeçalho dos empenhos						  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpCabEmp(_nTipoEmp)
local _nX			:= 0

        oPrn:FillRect({_nLin,0030,_nLin+0040,0550},oCinBrush)
        oPrn:Say(_nLin+0017 ,0030,"MATERIAIS EMPENHADOS"		                                        ,oFont14:oFont)
        oPrn:Say(_nLin+0030 ,0030,"Embalagem Primária:"		                                            ,oFont12:oFont)

        for _nX := 1 to Len(_aItEmp)
            oPrn:Say(_nLin+037,_aItEmp[_nX,1],_aItEmp[_nX,2]									        ,oFont06N:oFont)
        next _nX

        _nLin += 0015
return

/*/{Protheus.doc} ImpCabSec
    Funcao para imprimir o cabecalho embalagem secundaria.
    @type  Function
    @author Fernando Bombardi
    @since 12/12/2023
    /*/
static function ImpCabSec()
local _nX := 0

    oPrn:FillRect({_nLin,0030,_nLin+0027,0550},oCinBrush)
    oPrn:Say(_nLin+0012 ,0030,"Embalagem Secundária:"		                                            ,oFont12:oFont)

    for _nX := 1 to Len(_aItEmp)
        oPrn:Say(_nLin+0022,_aItEmp[_nX,1],_aItEmp[_nX,2]									            ,oFont06N:oFont)
    next _nX

    _nLin += 0007

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpEmp      º Autor ³ Rodrigo Telecio º Data ³  29/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão dos empenhos									  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpEmp()
//incrementos no _nLin nesta função = 0010 (a cada chamada)
local _cLoteCtl     := ""
if _nLin >= 0700
	oPrn:Say(_nLin+0010 ,0035,"CONTINUA NA PRÓXIMA PÁGINA... "							            ,oFont06N:oFont)
	ImpRodape()
	ImpLogo()
	_nLin 		:= 0110
	ImpCabEmp()
	_nLin 		+= 0020
endif
If _cAlerge == "1"
    oPrn:Say(_nLin+0020,_aItEmp[1,1],AllTrim((_cAlsSD4)->D4_COD)+"*"								    ,oFont08:oFont)
else
    oPrn:Say(_nLin+0020,_aItEmp[1,1],AllTrim((_cAlsSD4)->D4_COD)       								    ,oFont08:oFont)
EndIf
oPrn:Say(_nLin+0020,_aItEmp[2,1],SubStr(AllTrim((_cAlsSD4)->DESC_SD4),1,32)				            ,oFont08:oFont)
oPrn:Say(_nLin+0020,_aItEmp[3,1],AllTrim((_cAlsSD4)->D4_LOCAL)							            ,oFont08:oFont)
if Empty(AllTrim((_cAlsSD4)->D4_LOTECTL))
    _cLoteCtl   := Replicate("_",20)
else
    _cLoteCtl   := AllTrim((_cAlsSD4)->D4_LOTECTL)
endif
oPrn:Say(_nLin+0020,_aItEmp[4,1],_cLoteCtl							                                ,oFont08:oFont)
oPrn:Say(_nLin+0020,_aItEmp[5,1],AllTrim(Transform((_cAlsSD4)->D4_QTDEORI,"@E 9,999,999.999999"))     ,oFont08:oFont)
oPrn:Say(_nLin+0020,_aItEmp[6,1],Replicate("_",14)	                    ,oFont08:oFont)
oPrn:Say(_nLin+0020,_aItEmp[7,1],AllTrim((_cAlsSD4)->UM_SD4)								        ,oFont08:oFont)

dbSelectArea("SB2")
SB2->(dbSetOrder(1))
if SB2->(dbSeek(FwFilial("SB2") + (_cAlsSD4)->D4_COD + (_cAlsSD4)->D4_LOCAL,.T.,.F.))
    if SaldoSB2() >= 0
        oPrn:Say(_nLin+0020,_aItEmp[8,1],AllTrim(Transform(SaldoSB2(),"@E 9,999,999.99"))         ,oFont08:oFont)
    else
        oPrn:Say(_nLin+0020,_aItEmp[8,1],"(" + AllTrim(Transform(SaldoSB2(),"@E 9,999,999.99")) + ")",oFont08N:oFont)
    endif
else
    oPrn:Say(_nLin+0020,_aItEmp[8,1],AllTrim(Transform(0,"@E 9,999,999.99"))	                    ,oFont08:oFont)
endif



return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpObsProc  º Autor ³ Rodrigo Telecio º Data ³  29/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão das observações do processo					  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpObsProc(_nImpr)
//incrementos no _nLin nesta função = 0090
local _cAux         := ""
local _nLinhas      := 0
local _nX           := 0
local _nAv          := 0050
_nLin               += 0020
oPrn:Box(_nLin      ,0030       ,_nLin+0070     ,0550)
oPrn:Say(_nLin+0010 ,0040,"Observações do processo"											        ,oFont06N:oFont)
_nLin           += 0070
if _nImpr == 1
    if !Empty(AllTrim(SB1->B1_OBSM))
        _cAux           := AllTrim(SB1->B1_OBSM)
        _nLinhas        := Len(_cAux) / 85
        if _nLinhas <> Int(Len(_cAux) / 85)
            _nLinhas++
        endif
        for _nX := 1 to _nLinhas
            if _nX == 1
                oPrn:Say(_nLin-_nAv	,0040,SubStr(SB1->B1_OBSM,1,85)						                ,oFont08:oFont)            
            else
                oPrn:Say(_nLin-_nAv	,0040,SubStr(SB1->B1_OBSM,((_nX - 1) * 85) + 1,85)				    ,oFont08:oFont)
            endif
            _nAv        -= 0010
        next _nX
    endif
elseif _nImpr == 2
    //primeira linha
    if !Empty(AllTrim(SB1->B1_COMPOS))
        oPrn:Say(_nLin-0050 ,0040,"Composição: " + AllTrim(SB1->B1_COMPOS)                          ,oFont08:oFont)
    endif
    //segunda linha
    if !Empty(AllTrim(SB1->B1_APLIC))
        oPrn:Say(_nLin-0040 ,0040,"Aplicação: " + AllTrim(SB1->B1_APLIC)                            ,oFont08:oFont)
    endif
    //terceira linha
    if !Empty(AllTrim(SB1->B1_MS))
        oPrn:Say(_nLin-0030 ,0040,"Ministério da Saúde: " + AllTrim(SB1->B1_MS)                     ,oFont08:oFont)
    endif
    //quarta linha
    if !Empty(AllTrim(SB1->B1_DESEMB))
        oPrn:Say(_nLin-0020 ,0040,"Embalagem: " + AllTrim(SB1->B1_DESEMB)                           ,oFont08:oFont)
    endif
    //quinta linha
    oPrn:Say(_nLin-0010 ,0040,"Vol. prim.: "    + AllTrim(Str(SB1->B1_VOPRIN))                      ,oFont08:oFont)        
    oPrn:Say(_nLin-0010 ,0140,"Cod. Barras 1: " + AllTrim(SB1->B1_CODBAR)                           ,oFont08:oFont)
    oPrn:Say(_nLin-0010 ,0300,"Vol. secund.: "  + AllTrim(Str(SB1->B1_VOSEC))                       ,oFont08:oFont)
    oPrn:Say(_nLin-0010 ,0400,"Cod. Barras 2: " + AllTrim(SB1->B1_CODBAR2)                          ,oFont08:oFont)
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpRodape   º Autor ³ Rodrigo Telecio º Data ³  29/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão do rodape do relatório							  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpRodape()
_nLin := 0800
oPrn:FillRect({_nLin,0030,_nLin+0020,0550},oCinBrush)
oPrn:Say(_nLin+0015 ,0430,"OP " + AllTrim(SC2->(C2_NUM + C2_ITEM + C2_SEQUEN))                      ,oFont10:oFont)
oPrn:Say(_nLin+0030 ,0370, "Powered by ALLSS Soluções em Sistemas - https://allss.com.br/"        	,oFont05:oFont)
oPrn:EndPage()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg  ºAutor  ³ Rodrigo Telecio   º Data ³  29/10/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função responsavel por criar as perguntas utilizadas no    º±±
±±º          ³ relatório                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ValidPerg()
local _aAlias 	:= GetArea()
local _aRegs   	:= {}
local _aTam   	:= {}
local _cTit		:= ""
local i,j
_aTam 			:= TamSX3('H8_OP')
_cTit 			:= "Ordem de Producao de?"
AADD(_aRegs,{_cPerg,"01", _cTit, _cTit, _cTit, "mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""                    ,"mv_par01",""           ,"","","","",""         			 ,"","","","",""			,"","","","",""				  ,"","","","",""	  ,"","","","SC2"   ,"","",""})
_aTam 			:= TamSX3('H8_OP')
_cTit 			:= "Ordem de Producao ate?"
AADD(_aRegs,{_cPerg,"02", _cTit, _cTit, _cTit, "mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()"          ,"mv_par02",""           ,"","","","",""                   ,"","","","",""            ,"","","","",""               ,"","","","",""     ,"","","","SC2"   ,"","",""})
_cAliasSX1 		:= "SX1"
OpenSxs( , , , , FWCodEmp(), _cAliasSX1, "SX1", , .F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))
for i := 1 to Len(_aRegs)
    if !(_cAliasSX1)->(dbSeek(_cPerg + Space(Len((_cAliasSX1)->X1_GRUPO) - Len(_cPerg)) + _aRegs[i,2]))
        RecLock(_cAliasSX1,.T.)
        for j := 1 to FCount()
            if j <= Len(_aRegs[i])
                FieldPut(j,_aRegs[i,j])
            endif
        next j
        MsUnlock()
    endif
next i
(_cAliasSX1)->(dbCloseArea())
RestArea(_aAlias)
return
