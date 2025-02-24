#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwprintsetup.ch"
#define DMPAPER_A4 9
#define ENT CHR(13) + CHR(10)
/*/{Protheus.doc} RPCPR008
Rotina para impressão de Ordem de Separação
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 06/07/2023
@version P12.1.2210
@type Function
@obs Sem observações
@see https://allss.com.br
@history 06/07/2023, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Desenvolvimento e disponibilização da primeira versão para utilização/testes.
/*/
user function RPCPR008(cOPIni, cOPFim)
default cOPIni              := ""
default cOPFim              := ""
private _cPerg          	:= AllTrim(FunName())
private _cRotina			:= FunName()
private _cTitulo			:= "Layout Ord. Sep. Produtiva"
private aAreaSB1            := SB1->(GetArea())
private aAreaSB2            := SB2->(GetArea())
//*****************************************************************
//TRATAMENTO PARA IMPRESSÃO QUANDO A CHAMADA VIER DE ROTINA EXTERNA
//*****************************************************************
if !Empty(AllTrim(cOPIni)) .AND. !Empty(AllTrim(cOPFim))
	mv_par01 := cOPIni
	mv_par02 := cOPFim
else
	ValidPerg()
    if !Pergunte(_cPerg,.T.)
        Aviso('[0001 - ' + AllTrim(_cRotina) + ']','Parâmetros cancelados. Nada será impresso.',{"OK"},3,'Ausência de parâmetros para impressão')
        return
	endif
endif
Processa({|_lEnd| ProcRel(_lEnd)},"[" + _cRotina + "] " + _cTitulo)
RestArea(aAreaSB2)
RestArea(aAreaSB1)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ProcRel   º Autor ³ Rodrigo Telecio   º Data ³  06/07/2022 º±±
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
private _cQrySD4            := ""
private _cNomArq			:= ""
private _cOPSD4Ant			:= ""
private _cDtImpres			:= AllTrim(DtoC(Date()))
private _cHrImpres			:= AllTrim(Time())
private _lAdjustToLegacy 	:= .F.
private _lDisableSetup   	:= .F.
private _aDevice            := {}
private _cDevice
private _nPrtType        	:= 2
_cNomArq          			:= "os_" + Lower(AllTrim(FWGrpName())) + '-' +	Lower(AllTrim(FwFilialName())) + "_" + DtoS(dDataBase) + "-" + SubStr(Time(),1,2) + SubStr(Time(),4,2) + SubStr(Time(),7,2) + ".pdf"
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
if oPrn:Canceled()
    return .F.
endif
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
private oFont14T            := TFont():New("Arial Black",14,14,,.F.,,,,,.F.,.F.)
private oFont16N   			:= TFontEx():New(oPrn,"Arial Black",16,16,.T.,.T.,.F.)
private oFont16   			:= TFontEx():New(oPrn,"Arial Black",16,16,.F.,.F.,.F.)
private oFont
private oTempTable
private _cAlsSD4            := ""
private _nLin 				:= 0010
private _cLogo				:= FisxLogo("1")
private _aItEmp 			:= {{0035,"Codigo"			,3},; //1
		  						{0090,"Descrição" 	 	,3},; //2
		  						{0270,"Local"   	    ,3},; //3  
		  						{0300,"Lote"			,3},; //4	
                                {0400,"Quantidade"   	,3},; //5  
                                {0465,"U.M."			,3},; //6
		  						{0495,"Saldo"		    ,3}}  //7
_cQrySD4                    := "SELECT                                                                                                                      " + ENT
_cQrySD4                    += "    SD4.D4_OP,                                                                                                              " + ENT
_cQrySD4                    += "    SD4.D4_COD,                                                                                                             " + ENT
_cQrySD4                    += "    SB1B.B1_DESC DESC_SD4,                                                                                                  " + ENT
_cQrySD4                    += "    SUM(SD4.D4_QTDEORI) D4_QTDEORI,                                                                                         " + ENT
_cQrySD4                    += "    SB1B.B1_TIPO TIPO_SD4,                                                                                                  " + ENT
_cQrySD4                    += "    SB1B.B1_UM UM_SD4,                                                                                                      " + ENT
_cQrySD4                    += "    SD4.D4_PRODUTO,                                                                                                         " + ENT
_cQrySD4                    += "    SB1C.B1_DESC DESC_SB1,                                                                                                  " + ENT
dbSelectArea("SB1")
if FieldPos("B1_COMPOS") > 0
    _cQrySD4                += "	SB1C.B1_COMPOS,                                                                                                         " + ENT
endif
if FieldPos("B1_APLIC") > 0
    _cQrySD4                += "	SB1C.B1_APLIC,                                                                                                          " + ENT
endif
if FieldPos("B1_MS") > 0
    _cQrySD4                += "	SB1C.B1_MS,                                                                                                             " + ENT
endif
if FieldPos("B1_DESEMB") > 0
    _cQrySD4                += "	SB1C.B1_DESEMB,                                                                                                         " + ENT
endif
if FieldPos("B1_VOPRIN") > 0
    _cQrySD4                += "	SB1C.B1_VOPRIN,                                                                                                         " + ENT
endif
if FieldPos("B1_VOSEC") > 0
    _cQrySD4                += "	SB1C.B1_VOSEC,                                                                                                          " + ENT
endif
if FieldPos("B1_CODBAR2") > 0
    _cQrySD4                += "	SB1C.B1_CODBAR2,                                                                                                        " + ENT
endif
_cQrySD4                    += "	SB1C.B1_CODBAR,                                                                                                         " + ENT
_cQrySD4                    += "	SB1C.B1_REVATU,                                                                                                         " + ENT
_cQrySD4                    += "	SC2.C2_QUANT,                                                                                                           " + ENT
_cQrySD4                    += "	SUBSTRING(SC2.C2_EMISSAO,7,2) + '/' + SUBSTRING(SC2.C2_EMISSAO,5,2) + '/' + SUBSTRING(SC2.C2_EMISSAO,1,4) C2_EMISSAO,   " + ENT
_cQrySD4                    += "	SUBSTRING(SC2.C2_DATPRI,7,2) + '/' + SUBSTRING(SC2.C2_DATPRI,5,2) + '/' + SUBSTRING(SC2.C2_DATPRI,1,4) C2_DATPRI,       " + ENT
_cQrySD4                    += "	SUBSTRING(SC2.C2_DATPRF,7,2) + '/' + SUBSTRING(SC2.C2_DATPRF,5,2) + '/' + SUBSTRING(SC2.C2_DATPRF,1,4) C2_DATPRF,       " + ENT
_cQrySD4                    += "	SC2.C2_CC,                                                                                                              " + ENT
_cQrySD4                    += "    SD4.D4_LOCAL,                                                                                                           " + ENT
_cQrySD4                    += "    ISNULL(NNR.NNR_DESCRI,'') NNR_DESCRI,                                                                                   " + ENT
_cQrySD4                    += "    SD4.D4_TRT,                                                                                                             " + ENT
_cQrySD4                    += "    SD4.D4_LOTECTL,                                                                                                         " + ENT
_cQrySD4                    += "    SD4.D4_NUMLOTE                                                                                                          " + ENT
_cQrySD4                    += "FROM                                                                                                                        " + ENT
_cQrySD4                    +=      RetSqlName("SD4") + " AS SD4 (NOLOCK)                                                                                   " + ENT
_cQrySD4                    += "    LEFT OUTER JOIN                                                                                                         " + ENT
_cQrySD4                    +=          RetSqlName("SB1") + " AS SB1B (NOLOCK)                                                                              " + ENT
_cQrySD4                    += "    ON                                                                                                                      " + ENT
//AVALIAR COMPARTILHAMENTO DE TABELA ANTES DE APLICAR PARA TESTES JUNTO AO USUÁRIO!
_cQrySD4                    += "        SB1B.B1_FILIAL      = SD4.D4_FILIAL                                                                                 " + ENT
_cQrySD4                    += "		AND SB1B.B1_FILIAL      = '" + xFilial("SB1") + "'                                                                      " + ENT
_cQrySD4                    += "        AND SB1B.B1_COD = SD4.D4_COD                                                                                        " + ENT
_cQrySD4                    += "        AND SB1B.D_E_L_E_T_ = ''                                                                                            " + ENT
_cQrySD4                    += "    LEFT OUTER JOIN                                                                                                         " + ENT
_cQrySD4                    +=          RetSqlName("SB1") + " AS SB1C (NOLOCK)                                                                              " + ENT
_cQrySD4                    += "    ON                                                                                                                      " + ENT
//AVALIAR COMPARTILHAMENTO DE TABELA ANTES DE APLICAR PARA TESTES JUNTO AO USUÁRIO!
_cQrySD4                    += "        SB1B.B1_FILIAL      = SD4.D4_FILIAL                                                                                 " + ENT
_cQrySD4                    += "		AND SB1C.B1_FILIAL      = '" + xFilial("SB1") + "'                                                                      " + ENT
_cQrySD4                    += "        AND SB1C.B1_COD     = SD4.D4_PRODUTO                                                                                " + ENT
_cQrySD4                    += "        AND SB1C.D_E_L_E_T_ = ''                                                                                            " + ENT
_cQrySD4                    += "    LEFT OUTER JOIN                                                                                                         " + ENT
_cQrySD4                    +=          RetSqlName("NNR") + " AS NNR  (NOLOCK)                                                                              " + ENT
_cQrySD4                    += "    ON                                                                                                                      " + ENT
_cQrySD4                    += "        NNR.NNR_FILIAL      = SD4.D4_FILIAL                                                                                 " + ENT
_cQrySD4                    += "        AND NNR.NNR_CODIGO  = SD4.D4_LOCAL                                                                                  " + ENT
_cQrySD4                    += "        AND NNR.D_E_L_E_T_  = ''                                                                                            " + ENT
_cQrySD4                    += "	LEFT OUTER JOIN                                                                                                         " + ENT
_cQrySD4                    +=          RetSqlName("SC2") + " AS SC2 (NOLOCK)                                                                               " + ENT
_cQrySD4                    += "	ON                                                                                                                      " + ENT
_cQrySD4                    += "		SC2.C2_FILIAL									= SD4.D4_FILIAL                                                     " + ENT
_cQrySD4                    += "		AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN	= SD4.D4_OP                                                         " + ENT
_cQrySD4                    += "		AND SC2.D_E_L_E_T_								= ''                                                                " + ENT
_cQrySD4                    += "WHERE                                                                                                                       " + ENT
_cQrySD4                    += "    SD4.D4_OP           BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'                                                   " + ENT
_cQrySD4                    += "    AND SD4.D_E_L_E_T_  = ''                                                                                                " + ENT
_cQrySD4                    += "GROUP BY                                                                                                                    " + ENT
_cQrySD4                    += "    SD4.D4_OP,                                                                                                              " + ENT
_cQrySD4                    += "    SD4.D4_COD,                                                                                                             " + ENT
_cQrySD4                    += "    SB1B.B1_DESC,                                                                                                           " + ENT
_cQrySD4                    += "    SB1B.B1_TIPO,                                                                                                           " + ENT
_cQrySD4                    += "    SB1B.B1_UM,                                                                                                             " + ENT
_cQrySD4                    += "    SD4.D4_PRODUTO,                                                                                                         " + ENT
_cQrySD4                    += "	SB1C.B1_DESC,                                                                                                           " + ENT
if FieldPos("B1_COMPOS") > 0
    _cQrySD4                += "	SB1C.B1_COMPOS,                                                                                                         " + ENT
endif
if FieldPos("B1_APLIC") > 0
    _cQrySD4                += "	SB1C.B1_APLIC,                                                                                                          " + ENT
endif
if FieldPos("B1_MS") > 0
    _cQrySD4                += "	SB1C.B1_MS,                                                                                                             " + ENT
endif
if FieldPos("B1_DESEMB") > 0
    _cQrySD4                += "	SB1C.B1_DESEMB,                                                                                                         " + ENT
endif
if FieldPos("B1_VOPRIN") > 0
    _cQrySD4                += "	SB1C.B1_VOPRIN,                                                                                                         " + ENT
endif
if FieldPos("B1_VOSEC") > 0
    _cQrySD4                += "	SB1C.B1_VOSEC,                                                                                                          " + ENT
endif
if FieldPos("B1_CODBAR2") > 0
    _cQrySD4                += "	SB1C.B1_CODBAR2,                                                                                                        " + ENT
endif
_cQrySD4                    += "	SB1C.B1_CODBAR,                                                                                                         " + ENT
_cQrySD4                    += "	SB1C.B1_REVATU,                                                                                                         " + ENT
_cQrySD4                    += "	SC2.C2_QUANT,                                                                                                           " + ENT
_cQrySD4                    += "	SC2.C2_EMISSAO,                                                                                                         " + ENT
_cQrySD4                    += "	SC2.C2_DATPRI,                                                                                                          " + ENT
_cQrySD4                    += "	SC2.C2_DATPRF,                                                                                                          " + ENT
_cQrySD4                    += "	SC2.C2_CC,                                                                                                              " + ENT
_cQrySD4                    += "    SD4.D4_LOCAL,                                                                                                           " + ENT
_cQrySD4                    += "    ISNULL(NNR.NNR_DESCRI,''),                                                                                              " + ENT
_cQrySD4                    += "    SD4.D4_TRT,                                                                                                             " + ENT
_cQrySD4                    += "    SD4.D4_LOTECTL,                                                                                                         " + ENT
_cQrySD4                    += "    SD4.D4_NUMLOTE                                                                                                          " + ENT
_cQrySD4                    += "ORDER BY                                                                                                                    " + ENT
_cQrySD4                    += "    SD4.D4_OP,                                                                                                              " + ENT
_cQrySD4                    += "    SD4.D4_COD                                                                                                              " + ENT
_cQrySD4                    := ChangeQuery(_cQrySD4)
MemoWrite("\02. MemoWrite\" + _cRotina + "_QRY_002.TXT",_cQrySD4)
_cAlsSD4                    := GetNextAlias()
if Select(_cAlsSD4) > 0
    (_cAlsSD4)->(dbCloseArea())
endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQrySD4),(_cAlsSD4),.T.,.F.)
dbSelectArea(_cAlsSD4)
ProcRegua(RecCount())
(_cAlsSD4)->(dbGoTop())
if !(_cAlsSD4)->(EOF())
    while !(_cAlsSD4)->(EOF())    
        _cOPSD4Ant 	        := AllTrim((_cAlsSD4)->D4_OP)
        IncProc("imprimindo OP " + AllTrim(_cOPSD4Ant) + ", aguarde...")
        //******************
        //IMPRESSÃO LOGOTIPO
        //******************
        ImpLogo()
        _nLin 		        := 0100
        //**********************************
        //IMPRESSÃO CABEÇALHO DA OS + QRCODE
        //**********************************
        ImpCabOS()
        _nLin 		        += 0005
        //******************
        //IMPRESSÃO EMPENHOS
        //******************
        ImpCabEmp()
        dbSelectArea(_cAlsSD4)
        while !(_cAlsSD4)->(EOF()) .AND. _cOPSD4Ant == AllTrim((_cAlsSD4)->D4_OP)
            _nLin 		    += 0015
            ImpEmp()
            (_cAlsSD4)->(dbSkip())
        enddo
        _nLin 		        += 0015
        //********************************
        //IMPRESSÃO OBSERVAÇÃO DO PROCESSO
        //********************************
        if _nLin >= 0700
            oPrn:Say(_nLin+0010 ,0035,"CONTINUA NA PRÓXIMA PÁGINA... ",oFont06N:oFont)
            ImpRodape()
            ImpLogo()
            _nLin 		    := 0110
        endif
        ImpObsProc(1)
        ImpObsProc(2)
        _nLin 		        += 0005        
        //********************************************
        //IMPRESSÃO DO QUADRO DE CONTROLE DE QUALIDADE
        //********************************************
        if _nLin >= 0670
            oPrn:Say(_nLin+0010 ,0035,"CONTINUA NA PRÓXIMA PÁGINA... ",oFont06N:oFont)
            ImpRodape()
            ImpLogo()
            _nLin 		    := 0110
        endif
        ImpQualid()
        _nLin 		        += 0005
        //*****************************
        //IMPRESSÃO DO RODAPÉ DA PÁGINA
        //*****************************
        ImpRodape()
    enddo
endif
(_cAlsSD4)->(dbCloseArea())
oPrn:Preview()
FreeObj(oPrn)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpLogo   º Autor ³ Rodrigo Telecio   º Data ³  06/07/2023 º±±
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
oPrn:FillRect({0030,0030,0100,0550}                                                                                                     ,oCinBrush)
//logotipo (default, de acordo com o configurado no ERP)
oPrn:SayBitmap(0035,0050,_cLogo,0060,0060)
//titulo
oPrn:Say(0065		,0140,"ORDEM  DE  SEPARAÇÃO"    					                                                                ,oFont16N:oFont)
oPrn:Say(0080		,0200,"PRODUTIVA"    					                                                                            ,oFont16N:oFont)
//primeira linha
oPrn:Say(0050		,0400,"Controle de Impressão"			  							                                                ,oFont08:oFont)
//segunda linha
oPrn:Say(0060		,0400,"Data da impressão"				  							                                                ,oFont06N:oFont)
oPrn:Say(0070		,0400,_cDtImpres				  									                                                ,oFont10:oFont)
oPrn:Say(0060		,0480,"Hora da impressão"				  							                                                ,oFont06N:oFont)
oPrn:Say(0070		,0480,_cHrImpres				  									                                                ,oFont10:oFont)
//terceira linha
oPrn:Say(0080		,0400,"Usuário resp. impressão"				  							                                            ,oFont06N:oFont)
oPrn:Say(0090		,0400,RetCodUsr()				  									                                                ,oFont10:oFont)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpCabOS    º Autor ³ Rodrigo Telecio º Data ³  06/07/2023 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão do cabeçalho da ordem de produção				  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpCabOS()
local cRev  := iif(AllTrim((_cAlsSD4)->B1_REVATU) == "","000",AllTrim((_cAlsSD4)->B1_REVATU))
_nLin           += 0010
//código de barras
oPrn:QrCode(_nLin+0105,0030,AllTrim((_cAlsSD4)->D4_OP),0110)
//primeira linha
oPrn:Say(_nLin		,0140,"Ordem de produção"		  									                                                ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0140,SubStr((_cAlsSD4)->D4_OP,1,6) + " " + SubStr((_cAlsSD4)->D4_OP,7,2) + " " + SubStr((_cAlsSD4)->D4_OP,9,3)     ,oFont14:oFont)
oPrn:Say(_nLin		,0440,"Qtd. Original" 	 											                                                ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0440,AllTrim(Transform((_cAlsSD4)->C2_QUANT,"@E 999,999,999.9999"))		                                        ,oFont14:oFont)
//segunda linha
_nLin           += 0020
oPrn:Say(_nLin		,0140,"Produto"		  												                                                ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0140,SubStr(AllTrim((_cAlsSD4)->D4_PRODUTO),1,10)					                                                ,oFont10:oFont)
oPrn:Say(_nLin		,0230,"Rev."		  												                                                ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0230,SubStr(AllTrim(cRev),1,3)					                                                                    ,oFont10:oFont)
oPrn:Say(_nLin		,0260,"Descrição"	  												                                                ,oFont06N:oFont)
oPrn:Say(_nLin+0012	,0260,AllTrim((_cAlsSD4)->DESC_SB1)  								                                                ,oFont10:oFont)
//segunda linha
_nLin           += 0020
oPrn:Say(_nLin		,0140,"Emissão"	 	 												                                                ,oFont06N:oFont)
oPrn:Say(_nLin+0010	,0140,(_cAlsSD4)->C2_EMISSAO  								                                                        ,oFont10:oFont)
oPrn:Say(_nLin		,0280,"Previsão inicial"											                                                ,oFont06N:oFont)
oPrn:Say(_nLin+0010	,0280,(_cAlsSD4)->C2_DATPRI									                                                        ,oFont10:oFont)
oPrn:Say(_nLin		,0420,"Entrega"														                                                ,oFont06N:oFont)
oPrn:Say(_nLin+0010	,0420,(_cAlsSD4)->C2_DATPRF									                                                        ,oFont10:oFont)
//bloco do centro de custo
_nLin           += 0020
oPrn:Box(_nLin      ,0140       ,_nLin+0050     ,0550)
oPrn:Say(_nLin+0010 ,0150,"Centro de Custo/Setor/Área"											                                        ,oFont06N:oFont)
if !Empty(AllTrim((_cAlsSD4)->C2_CC))
    _cCC        :=  AllTrim((_cAlsSD4)->C2_CC) + ' - ' +  AllTrim(Posicione("CTT",1,xFilial("CTT") + AllTrim((_cAlsSD4)->C2_CC),"CTT_DESC01"))
else
    _cCC        := ""
endif
oPrn:Say(_nLin+0025	,0150,SubStr(_cCC,1,35)									                                                            ,oFont14:oFont)
oPrn:Say(_nLin+0035	,0150,SubStr(_cCC,36,35)									                                                        ,oFont14:oFont)
_nLin           += 0055
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpCabEmp  º Autor ³ Rodrigo Telecio  º Data ³  06/07/2023 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão do cabeçalho dos empenhos						  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpCabEmp()
local _nX       := 0
oPrn:FillRect({_nLin,0030,_nLin+0030,0550}                                                                                              ,oCinBrush)
oPrn:Say(_nLin+0015 ,0030,"MATERIAIS EMPENHADOS"		                                                                                ,oFont14:oFont)
for _nX := 1 to Len(_aItEmp)
	oPrn:Say(_nLin+0025,_aItEmp[_nX,1],_aItEmp[_nX,2]									                                                ,oFont06N:oFont)
next _nX
_nLin           += 0010
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpEmp   º Autor ³ Rodrigo Telecio    º Data ³  06/07/2023 º±±
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
local _cLoteCtl := ""
if _nLin >= 0700
	oPrn:Say(_nLin+0010 ,0035,"CONTINUA NA PRÓXIMA PÁGINA... "							                                                ,oFont06N:oFont)
	ImpRodape()
	ImpLogo()
	_nLin 		:= 0110
	ImpCabEmp()
	_nLin 		+= 0020
endif
oPrn:Say(_nLin+0020,_aItEmp[1,1],AllTrim((_cAlsSD4)->D4_COD)								                                            ,oFont08:oFont)
oPrn:Say(_nLin+0020,_aItEmp[2,1],SubStr(AllTrim((_cAlsSD4)->DESC_SD4),1,32)				                                                ,oFont08:oFont)
oPrn:Say(_nLin+0020,_aItEmp[3,1],AllTrim((_cAlsSD4)->D4_LOCAL)							                                                ,oFont08:oFont)
if Empty(AllTrim((_cAlsSD4)->D4_LOTECTL))
    _cLoteCtl   := Replicate("_",23)
else
    _cLoteCtl   := AllTrim((_cAlsSD4)->D4_LOTECTL)
endif
oPrn:Say(_nLin+0020,_aItEmp[4,1],_cLoteCtl							                                                                    ,oFont08:oFont)
oPrn:Say(_nLin+0020,_aItEmp[5,1],AllTrim(Transform((_cAlsSD4)->D4_QTDEORI,"@E 9,999,999.9999"))                                         ,oFont08:oFont)
oPrn:Say(_nLin+0020,_aItEmp[6,1],AllTrim((_cAlsSD4)->UM_SD4)								                                            ,oFont08:oFont)
dbSelectArea("SB2")
SB2->(dbSetOrder(1))
if SB2->(dbSeek(xFilial("SB2") + (_cAlsSD4)->D4_COD + (_cAlsSD4)->D4_LOCAL,.T.,.F.))
    if SaldoSB2() >= 0
        oPrn:Say(_nLin+0020,_aItEmp[7,1],AllTrim(Transform(SaldoSB2(),"@E 9,999,999.9999"))                                             ,oFont08:oFont)
    else
        oPrn:Say(_nLin+0020,_aItEmp[7,1],"(" + AllTrim(Transform(SaldoSB2(),"@E 9,999,999.9999")) + ")"                                 ,oFont08N:oFont)
    endif
else
    oPrn:Say(_nLin+0020,_aItEmp[7,1],AllTrim(Transform(0,"@E 9,999,999.9999"))	                                                        ,oFont08:oFont)
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpObsProc º Autor ³ Rodrigo Telecio  º Data ³  06/07/2023 º±±
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
local _cAux     := ""
local _nLinhas  := 0
local _nX       := 0
local _nAv      := 0050
dbSelectArea("SB1")
if _nImpr == 1
    _nLin           += 0020
    oPrn:Box(_nLin      ,0030       ,_nLin+0070     ,0550)
    oPrn:Say(_nLin+0010 ,0040,"Observações do produto"											                                         ,oFont06N:oFont)
    _nLin           += 0070
    dbSetOrder(1)
    if dbSeek(xFilial("SB1") + (_cAlsSD4)->D4_PRODUTO)
        if FieldPos("B1_OBSM") > 0
            if !Empty(AllTrim(SB1->B1_OBSM))
                _cAux           := AllTrim(SB1->B1_OBSM)
                _nLinhas        := Len(_cAux) / 85
                if _nLinhas <> Int(Len(_cAux) / 85)
                    _nLinhas++
                endif
                for _nX := 1 to _nLinhas
                    if _nX == 1
                        oPrn:Say(_nLin-_nAv	,0040,SubStr(SB1->B1_OBSM,1,85)						                                         ,oFont08:oFont)
                    else
                        oPrn:Say(_nLin-_nAv	,0040,SubStr(SB1->B1_OBSM,((_nX - 1) * 85) + 1,85)				                             ,oFont08:oFont)
                    endif
                    _nAv        -= 0010
                next _nX
            endif
        endif
    endif
elseif _nImpr == 2
    _nLin           += 0020
    oPrn:Box(_nLin      ,0030       ,_nLin+0070     ,0550)
    oPrn:Say(_nLin+0010 ,0040,"Observações do processo"											                                         ,oFont06N:oFont)
    _nLin           += 0070
    //primeira linha
    if FieldPos("B1_COMPOS") > 0
        if !Empty(AllTrim(SB1->B1_COMPOS))
            oPrn:Say(_nLin-0050 ,0040,"Composição: " + AllTrim((_cAlsSD4)->B1_COMPOS)                                                    ,oFont08:oFont)
        endif
    else
        oPrn:Say(_nLin-0050 ,0040,"Composição: " + ""                                                                                    ,oFont08:oFont)
    endif
    //segunda linha   
    if FieldPos("B1_APLIC") > 0 
        if !Empty(AllTrim(SB1->B1_APLIC))
            oPrn:Say(_nLin-0040 ,0040,"Aplicação: " + AllTrim((_cAlsSD4)->B1_APLIC)                                                      ,oFont08:oFont)
        endif
    else
        oPrn:Say(_nLin-0040 ,0040,"Aplicação: " + ""                                                                                     ,oFont08:oFont)
    endif
    //terceira linha
    if FieldPos("B1_MS") > 0
        if !Empty(AllTrim(SB1->B1_MS))
            oPrn:Say(_nLin-0030 ,0040,"Ministério da Saúde: " + AllTrim((_cAlsSD4)->B1_MS)                                               ,oFont08:oFont)
        endif
    else
        oPrn:Say(_nLin-0030 ,0040,"Ministério da Saúde: " + ""                                                                           ,oFont08:oFont)
    endif
    //quarta linha
    if FieldPos("B1_DESEMB") > 0
        if !Empty(AllTrim(SB1->B1_DESEMB))
            oPrn:Say(_nLin-0020 ,0040,"Embalagem: " + AllTrim((_cAlsSD4)->B1_DESEMB)                                                     ,oFont08:oFont)
        endif
    else
        oPrn:Say(_nLin-0020 ,0040,"Embalagem: " + ""                                                                                     ,oFont08:oFont)
    endif
    //quinta linha
    if FieldPos("B1_VOPRIN") > 0
        oPrn:Say(_nLin-0010 ,0040,"Vol. prim.: "    + AllTrim(Str((_cAlsSD4)->B1_VOPRIN))                                               ,oFont08:oFont)
    else
        oPrn:Say(_nLin-0010 ,0040,"Vol. prim.: " +  ""                                                                                  ,oFont08:oFont)
    endif
    oPrn:Say(_nLin-0010 ,0140,"Cod. Barras 1: " + AllTrim((_cAlsSD4)->B1_CODBAR)                                                        ,oFont08:oFont)
    if FieldPos("B1_VOSEC") > 0
        oPrn:Say(_nLin-0010 ,0300,"Vol. secund.: "  + AllTrim(Str((_cAlsSD4)->B1_VOSEC))                                                ,oFont08:oFont)
    else
        oPrn:Say(_nLin-0010 ,0300,"Vol. secund.: "  + ""                                                                                ,oFont08:oFont)
    endif
    if FieldPos("B1_CODBAR2") > 0
        oPrn:Say(_nLin-0010 ,0400,"Cod. Barras 2: " + AllTrim((_cAlsSD4)->B1_CODBAR2)                                                   ,oFont08:oFont)
    else
        oPrn:Say(_nLin-0010 ,0400,"Cod. Barras 2: " + ""                                                                                ,oFont08:oFont)
    endif
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpQualid  º Autor ³ Rodrigo Telecio  º Data ³  06/07/2023 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Impressão do rodape do relatório							  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function ImpQualid()
//incrementos no _nLin nesta função = 0130
oPrn:FillRect({_nLin,0030,_nLin+0030,0550},oCinBrush)
oPrn:Say(_nLin+0015 ,0030,"SEPARAÇÃO, INSPEÇÃO E CONFERÊNCIA"		                                                                    ,oFont14:oFont)
oPrn:Say(_nLin+0025 ,0040,"Controle na Origem"								                                                            ,oFont06N:oFont)
oPrn:Say(_nLin+0025 ,0290,"Controle no Destino"								                                                            ,oFont06N:oFont)
_nLin           += 0050
//primeira linha
oPrn:Say(_nLin      ,0040,"Entregue por: ________________________________"                                                              ,oFont10:oFont)
oPrn:Say(_nLin      ,0290,"Recebido por: ________________________________"                                                              ,oFont10:oFont)
_nLin           += 0020
//segunda linha
oPrn:Say(_nLin      ,0040,"Data: ____/____/_______"                                                                                     ,oFont10:oFont)
oPrn:Say(_nLin      ,0290,"Data: ____/____/_______"                                                                                     ,oFont10:oFont)
_nLin           += 0020
//terceira linha
oPrn:Say(_nLin      ,0040,"Observações: "                                                                                               ,oFont10:oFont)
oPrn:Say(_nLin      ,0290,"Observações: "                                                                                               ,oFont10:oFont)
_nLin           += 0020
//quarta linha
oPrn:Say(_nLin      ,0040,"________________________________________________"                                                            ,oFont10:oFont)
oPrn:Say(_nLin      ,0290,"________________________________________________"                                                            ,oFont10:oFont)
_nLin           += 0020
//quinta linha
oPrn:Say(_nLin      ,0040,"________________________________________________"                                                            ,oFont10:oFont)
oPrn:Say(_nLin      ,0290,"________________________________________________"                                                            ,oFont10:oFont)

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ ImpRodape  º Autor ³ Rodrigo Telecio  º Data ³  06/07/2023 º±±
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
_nLin           := 0800
oPrn:FillRect({_nLin,0030,_nLin+0020,0550}                                                                                              ,oCinBrush)
oPrn:Say(_nLin+0015 ,0430,"OP " + AllTrim(_cOPSD4Ant)                                                                                   ,oFont10:oFont)
oPrn:Say(_nLin+0030 ,0370, "Powered by ALLSS Soluções em Sistemas - https://allss.com.br/"        	                                    ,oFont05:oFont)
oPrn:EndPage()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg  ºAutor  ³ Rodrigo Telecio   º Data ³  06/07/2023 º±±
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
