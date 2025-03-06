#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"

#DEFINE _lEnt CHR(13) + CHR(10)

/*/{Protheus.doc} RFATR042
@description Relatório de auditoria para tempos de processo por etapa.
@author Júlio Soares
@since 05/07/2016
@version 1.0
@history 22/11/2018, Lívia Della Corte, Tratados os ajustes solicitados por Marco Antonio e Ronie, incluindo aqui a opção de envio por e-mail.
@param lJob, logical, Indica se a rotina está sendo chamada via job ou não.
@type function
@see https://allss.com.br
/*/
user function RFATR042()
	Local	 _cMV_PAR03 := ''
	Local	 _cMV_PAR04 := ''
	Local	 _cMV_PAR05 := ''
	Local	 _cMV_PAR06 := ''
	Local	 _cMV_PAR07 := ''
	Local	 _cMV_PAR08 := ''
	Local	 _cMV_PAR09 := ''
	Local	 _cMV_PAR10 := ''
	Local	 _cMV_PAR11 := ''
	
	private lEnd        := .T.
	Private	 _cMV_PAR01 := ''
	Private	 _cMV_PAR02 := ''
	Private _aSavArea	:= GetArea()
	Private _aColuns	:= {}
	Private _aMail      := {}   
	Private _cRotina	:= "RFATR042"
	Private _cPerg		:= _cRotina
	Private _cTitulo	:= ""
	Private _cTitulo2	:= ""
	Private _cTitulo3	:= ""
	Private _cQry		:= ""
	Private _cCmp		:= ""
	Private _cCmp1		:= ""
	Private _tAlias		:= "TMPRFT42"
	Private _cCampos	:= ""
	Private _lJob       := Type("CFILANT")=="U"     
	Private _lRet		:= .T.
	Private _cFileTMP   := ""
	Private _cFileTMP2  := _cFileTMP
	Private _aPar       := {} 
	Private _cData      := dtos(date())
	Private _cHora      := cValtochar(val(TiME())) + substr(cValtochar(SECONDS()),1,5)
  	Private oExcel      := FWMSEXCEL():New()

	if !_lJob
		ValidPerg()
		lRet := ExistDir('C:\temp\')    

		if  !lRet   	
			nRet := MakeDir( "C:\temp" ) 
			lRet:= .T.	 
		EndIf
		_cFileTMP:= GetTempPath()+"lead_time" + _cData + _cHora  + ".xml"		//"C:\temp\lead_time" + _cData + _cHora  + ".xml"
		If Empty(_cFileTMP)
			If MSGBOX('Deseja cancelar a emissão do relatório?',_cRotina+'_000','YESNO')
				return
			Else
				_cFileTMP := cGetFile ('Arquivo XML|*.xml','Salvar Arquivo',0,'C:\',.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.,.F.)
			EndIf
		EndIf
		IF !Pergunte(_cPerg,.T.)
			If MSGBOX("Deseja cancelar a emissão do relatório?",_cRotina+"_001","YESNO")
				return
			EndIf
		ENDIF
		If !(SubStr(cAcesso,160,1) == "S" .AND. SubStr(cAcesso,168,1) == "S" .AND. SubStr(cAcesso,170,1) == "S")
			MSGBOX("Usuário sem permissão para gerar relatórios em Excel. Informe o Administrador.",_cRotina +"_003","ALERT")
			return nil
		EndIf
		If !ApOleClient('MsExcel')
			MSGBOX("Excel não está instalado nessa estação.",_cRotina +"_004","ALERT")
			return nil
		EndIf
		_cTitulo   := ("Lead Time - Ciclo de Atendimento")
		_cTitulo2  := ("Parâmetros")	
		_cMV_PAR01 := MV_PAR01
		_cMV_PAR02 := MV_PAR02
		Processa({ |lEnd| SelectQry(@lEnd,"1") },_cTitulo,"Selecionando Dados..."        ,.T.)
		Processa({ |lEnd| Geraxls(@lEnd)       },_cTitulo,"Gerando relatório em Excel...",.T.)
		If Select(_tAlias) > 0
		   (_tAlias)->(dbCloseArea())
		EndIf
		RestArea(_aSavArea)
	Else	
		SelectQry(@lEnd,"1")
		Geraxls(@lEnd)
	EndIf	
return nil
/*/{Protheus.doc} SelectQry
@description Montagem do arquivo de trabalho.
@author Júlio Soares
@since 05/07/2016
@version 1.0
@param lEnd, logical , Parâmetro default da função "PROCESSA", indicativa de ação de cancelamento da operação pelo usuário.
@param cTp , caracter, Indica o tipo de infomrações (1=Analítico; 2=Sintético).
@type function
@see https://allss.com.br
/*/
static function SelectQry(lEnd,cTp)
	local _cQry    := ""

	If _lJob
		_cMV_PAR01 := ""
		_cMV_PAR02 := ""
		_cMV_PAR03 := ""
		_cMV_PAR04 := ""
		_cMV_PAR05 := ""
		_cMV_PAR06 := ""
		_cMV_PAR07 := ""
		_cMV_PAR08 := ""
		_cMV_PAR09 := ""
		_cMV_PAR10 := ""
		_cMV_PAR11 := ""
	endIf
	If cTp == "2" 
		_cCmp1 += "(_tAlias)->STATUS , (_tAlias)->STATUSNOME, (_tAlias)->QUANT,(_tAlias)->MEDIA  ,(_tAlias)->VALOR " 
		_cQry  += "Select  TAB.STATUS, TAB.STATUSNOME, count(*) QUANT , sum(DIAS_TOT)/ count(*)  MEDIA "
		If MV_PAR14 == 1	
			_cQry  += ",  SUM(VAL_ATEND) VALOR"
		Else
			_cQry  += ",  0 VALOR"
		EndIf
		_cQry  +=	" from ( " + _lEnt	
	EndIf
	_cCmp += "  (_tAlias)->STATUS,  (_tAlias)->STATUSNOME,"
	_cQry += "	SELECT	case when  ISNULL(C5_EMISSAO,'') = '' then 1 " + _lEnt
	_cQry += "				 when  iSNULL(C5_EMISSAO,'') <> '' and ISNULL(C9_DATALIB,'')= '' and SC5.C5_BLQ = '1'    then  2  " + _lEnt
	_cQry += "				 when  iSNULL(C5_EMISSAO,'') <> '' and ISNULL(C9_DATALIB,'') = ''  and SC5.C5_LIBEROK = ' ' AND  SC5.C5_BLQ <> '1'  then  3  " + _lEnt
	_cQry += "				 when  iSNULL(C5_EMISSAO,'') <> '' and C9_BLCRED NOT in ( '', '10') and C9_BLEST <> '' and C9_NFISCAL = ''     then   4 " + _lEnt
	_cQry += "				 when  iSNULL(C5_EMISSAO,'') <> '' and C9_BLCRED in ( '')  and C9_BLEST = '02'  and C9_NFISCAL = ''   then   5  " + _lEnt
	_cQry += "				 when  C9_BLCRED = '' and C9_BLEST = '' and C9_NFISCAL = '' and   CB7_STATUS <> '2'  then   6   " + _lEnt
	_cQry += "				 when  C9_BLCRED = '10' and C9_BLEST = '10' and C9_NFISCAL <> '' AND  iSNULL(DAI_DATA,'')  = ''   then   7 	" + _lEnt 
	_cQry += "				 when  C9_BLCRED = '10' and C9_BLEST = '10' and C9_NFISCAL <> '' and (iSNULL(DAI_DATA,'') <> ''  OR C9_SERIENF = 'ZZZ')   then   8  	" + _lEnt	 
	_cQry += "				 when  C9_BLCRED = '09'  then   9  	" + _lEnt	 
	_cQry += "			 else  10 end STATUS, " + _lEnt
	_cQry += "			case when  ISNULL(C5_EMISSAO,'') = '' then 'Atendimento' " + _lEnt
	_cQry += "				 when  iSNULL(C5_EMISSAO,'') <> '' and ISNULL(C9_DATALIB,'')= '' and SC5.C5_BLQ = '1'   then  'Comercial'  " + _lEnt
	_cQry += "				 when  iSNULL(C5_EMISSAO,'') <> '' and ISNULL(C9_DATALIB,'') = '' and SC5.C5_LIBEROK  = ' '  and SC5.C5_BLQ <> '1' then  'Fiscal'  " + _lEnt
	_cQry += "				 when  iSNULL(C5_EMISSAO,'') <> '' and C9_BLCRED NOT in ( '', '10') and C9_BLEST <> '' and C9_NFISCAL = ''     then   'Financeiro' " + _lEnt
	_cQry += "				 when  iSNULL(C5_EMISSAO,'') <> '' and C9_BLCRED in ( '')  and C9_BLEST = '02'  and C9_NFISCAL = ''   then   'Pre-Separacao'  " + _lEnt
	_cQry += "				 when  C9_BLCRED = '' and C9_BLEST = '' and C9_NFISCAL = '' and   CB7_STATUS <> '2'  then   'Separação'   " + _lEnt
	_cQry += "				 when  C9_BLCRED = '10' and C9_BLEST = '10' and C9_NFISCAL <> '' and  iSNULL(DAI_DATA,'')  = ''  then   'Expedição' 	" + _lEnt 
	_cQry += "				 when  C9_BLCRED = '10' and C9_BLEST = '10' and C9_NFISCAL <> '' and (iSNULL(DAI_DATA,'') <> ''  OR C9_SERIENF = 'ZZZ')   then   'Entregue'  	" + _lEnt	 
	_cQry += "				 when  C9_BLCRED = '09'  then   'Quarentena'  	" + _lEnt		 
	_cQry += "			 else  'Não Classificado' end STATUSNOME, " + _lEnt
	_cCmp += "(_tAlias)->VEND, (_tAlias)->NOME_VEND, (_tAlias)->CNPJ_CENT,(_tAlias)->CLIENTE, (_tAlias)->LOJA, (_tAlias)->NOME, (_tAlias)->N_ATEND, "
	_cQry += " 	UA_VEND VEND, RTRIM(A3_NOME) NOME_VEND, A1_CGCCENT CNPJ_CENT, UA_CLIENTE CLIENTE, UA_LOJA LOJA, RTRIM(A1_NOME) NOME ," + _lEnt
	_cCmp += " (_tAlias)->AT_EMISS, "
	_cQry += " 			 UA_NUM N_ATEND, ISNULL(SUBSTRING(UA_EMISSAO,7,2)+'/'+SUBSTRING(UA_EMISSAO,5,2)+'/'+SUBSTRING(UA_EMISSAO,1,4),'') AT_EMISS, " + _lEnt
	If MV_PAR14 == 1
		_cCmp += " 	 (_tAlias)->VAL_ATEND,	 "	  
		_cQry += " 	 ISNULL(UA_VALBRUT , 0)	VAL_ATEND, "	  + _lEnt
	EndIf
	If MV_PAR13 == 2
		_cCmp += " (_tAlias)->DIAS_ATEND, "
		_cQry += " 			ISNULL(DATEDIFF(DAY,UA_EMISSAO,C5_EMISSAO),0) DIAS_ATEND," + _lEnt
	EndIf
	_cCmp += " (_tAlias)->N_PEDIDO, (_tAlias)->PD_EMISS ,"
	_cQry += " 			UA_NUMSC5 N_PEDIDO, ISNULL(SUBSTRING(SC5.C5_EMISSAO,7,2)+'/'+SUBSTRING(SC5.C5_EMISSAO,5,2)+'/'+SUBSTRING(SC5.C5_EMISSAO,1,4),'') PD_EMISS," + _lEnt
	If MV_PAR13 == 2
		_cCmp += " (_tAlias)->DIAS_PED, "
		_cQry += " 			ISNULL(DATEDIFF(DAY,C9_DATENT,C5_EMISSAO),0) DIAS_PED," + _lEnt
	EndIf
	If MV_PAR14 == 1
		_cCmp += " 	 (_tAlias)->VAL_PED, "	  
		_cQry += " 	  ISNULL(C6_VALOR , 0)  VAL_PED,  "	  + _lEnt
	EndIf
	_cCmp += " (_tAlias)->PD_LIB ,"
	_cQry += " 			ISNULL(SUBSTRING(C9X.C9_DATENT,7,2)+'/'+SUBSTRING(C9X.C9_DATENT,5,2)+'/'+SUBSTRING(C9X.C9_DATENT,1,4),'') PD_LIB, " + _lEnt
	If MV_PAR13 == 2
		_cCmp += " (_tAlias)->DIAS_LIB , "
		_cQry += " 			ISNULL(DATEDIFF(DAY,C9_DATENT,C9_DATENT),0) DIAS_LIB," + _lEnt
	EndIf
	_cCmp += " (_tAlias)->DT_LIBCRD ,"
	_cQry += " 			 CASE WHEN   C5_DTLIBCR <> ''  then ISNULL(SUBSTRING(C5_DTLIBCR,7,2)+'/'+SUBSTRING(C5_DTLIBCR,5,2)+'/'+SUBSTRING(C5_DTLIBCR,1,4),'')   end	 DT_LIBCRD,  " + _lEnt
	If MV_PAR13 == 2
		_cCmp += " (_tAlias)->DIAS_CRD,"
		_cQry += " 	 	 CASE WHEN  C5_DTLIBCR <> ''  then ISNULL(DATEDIFF(DAY,C9_DATENT, C5_DTLIBCR),0)  end DIAS_CRD	 , " + _lEnt
	EndIf
	If MV_PAR14 == 1
		_cCmp += " 	 (_tAlias)->VAL_CRE, "	  
		_cQry += " 	 CASE WHEN   C5_DTLIBCR <> ''   then ISNULL(C9_XVALOR,0) else 0 end  VAL_CRE,  "	  + _lEnt
	EndIf
	_cCmp += " (_tAlias)->N_ORDSEP , (_tAlias)->OS_EMISS ,"
	_cQry += " 			ISNULL(CB7_ORDSEP,'') N_ORDSEP, ISNULL(SUBSTRING(CB7_DTEMIS,7,2)+'/'+SUBSTRING(CB7_DTEMIS,5,2)+'/'+SUBSTRING(CB7_DTEMIS,1,4),'') OS_EMISS, " + _lEnt
	If MV_PAR13 == 2
		_cCmp += " (_tAlias)->DIAS_SEP, "
		_cQry += " 		ISNULL(DATEDIFF(DAY,(CASE WHEN C9_DTLIBCR = '' AND (C9_BLCRED = '' OR C9_BLCRED = '10') THEN C9_DATALIB ELSE C9_DTLIBCR END),CB7_DTEMIS),0) DIAS_SEP," + _lEnt
	EndIf
	_cCmp += " (_tAlias)->DOC,(_tAlias)->SERIE , "
	_cQry += " 			ISNULL(C9X.C9_NFISCAL,'')DOC, ISNULL(C9X.C9_SERIENF,'')SERIE, " + _lEnt
	_cCmp += " (_tAlias)->EMISS_NOTA ,"
	_cQry += " 			ISNULL(SUBSTRING(C9X.C9_DTEMISS,7,2)+'/'+SUBSTRING(C9X.C9_DTEMISS,5,2)+'/'+SUBSTRING(C9X.C9_DTEMISS,1,4),'') EMISS_NOTA, " + _lEnt
	If MV_PAR13 == 2 
		_cCmp += " (_tAlias)->DIAS_DOC, "
		_cQry += " 		CASE WHEN C9X.C9_DTEMISS = '' THEN 0 ELSE ISNULL(DATEDIFF(DAY,CB7_DTEMIS,C9_DTEMISS),0) END DIAS_DOC," + _lEnt
	EndIf
	_cCmp += " (_tAlias)->CARGA, (_tAlias)->EXP_EMISS ,"
	_cQry += " 			ISNULL(DAI_COD,'') CARGA, ISNULL(SUBSTRING(DAI_DATA,7,2)+'/'+SUBSTRING(DAI_DATA,5,2)+'/'+SUBSTRING(DAI_DATA,1,4),'') EXP_EMISS, " + _lEnt
	If MV_PAR13 == 2
		_cCmp += " (_tAlias)->DIAS_EXP "
		_cQry += " 			ISNULL(DATEDIFF(DAY,C9_DTEMISS,DAI_DATA),0) DIAS_EXP " + _lEnt
	EndIf
	_cCmp += " , (_tAlias)->DIAS_TOT  "
	_cQry += " ,		ISNULL(DATEDIFF(DAY,UA_EMISSAO,DAI_DATA),0) DIAS_TOT " + _lEnt
	_cQry += " FROM "+RetSqlName("SUA")+" SUA (NOLOCK) " + _lEnt
	_cQry += " 	INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) " + _lEnt
	_cQry += " 		ON SA1.A1_FILIAL   = '"+xFilial("SA1")+"' " + _lEnt
	_cQry += " 		AND SA1.A1_COD     = SUA.UA_CLIENTE " + _lEnt
	_cQry += " 		AND SA1.A1_LOJA    = SUA.UA_LOJA " + _lEnt
	_cQry += "		AND SA1.D_E_L_E_T_ = '' " + _lEnt
	_cQry += " 	LEFT JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK) " + _lEnt
	_cQry += " 		ON  SC5.C5_FILIAL  = '"+xFilial("SC5")+"' " + _lEnt
	_cQry += " 		AND SC5.C5_NUM     = SUA.UA_NUMSC5 " + _lEnt
	_cQry += " 		AND SC5.C5_CLIENT  = SUA.UA_CLIENTE " + _lEnt
	_cQry += " 		AND SC5.C5_LOJACLI = SUA.UA_LOJA " + _lEnt
	_cQry += " 		AND SC5.D_E_L_E_T_ = '' " + _lEnt
	_cQry += " 	LEFT JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) " + _lEnt
	_cQry += " 		ON SA3.A3_FILIAL   = '"+xFilial("SA3")+"' " + _lEnt
	_cQry += " 		AND (SA3.A3_COD    = SUA.UA_VEND OR SA3.A3_COD = SC5.C5_VEND1) " + _lEnt
	_cQry += " 		AND SA3.D_E_L_E_T_ = '' " + _lEnt
	_cQry += " 	LEFT JOIN (	SELECT C9_CLIENTE,C9_LOJA,C9_DATALIB,C9_ORDSEP,C9_DTEMISS,C9_PEDIDO,C9_DTLIBCR,C9_CARGA, C9_BLCRED,C9_BLEST, C9_DATENT, C9_NFISCAL,C9_SERIENF " + _lEnt
	If MV_PAR14 == 1 
		_cQry += " , SUM(C9_PRCVEN *C9_QTDLIB) C9_XVALOR ,  sum(C9_QTDLIB)  C9_QTDLIB    "  + _lEnt
	EndIf
	_cQry += " 				FROM "+RetSqlName("SC9")+" SC9 (NOLOCK) " + _lEnt
	_cQry += " 				WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"' " + _lEnt
	_cQry += " 				AND SC9.D_E_L_E_T_  = '' " + _lEnt
	_cQry += " 				GROUP BY  C9_CLIENTE,C9_LOJA,C9_DATALIB,C9_ORDSEP,C9_DTEMISS,C9_PEDIDO,C9_CARGA, C9_BLCRED, C9_DTLIBCR ,C9_DATENT,  C9_BLEST,  C9_NFISCAL,C9_SERIENF "  + _lEnt
	_cQry += " 			  ) C9X " + _lEnt
	_cQry += " 		ON  (C9X.C9_CLIENTE = SUA.UA_CLIENTE ) " + _lEnt
	_cQry += " 		AND (C9X.C9_LOJA    = SUA.UA_LOJA    ) " + _lEnt
	_cQry += " 		AND (C9X.C9_PEDIDO  = SUA.UA_NUMSC5  ) " + _lEnt
	_cQry += " 	LEFT JOIN "+RetSqlName("CB7")+" CB7 (NOLOCK) " + _lEnt
	_cQry += " 		ON CB7_FILIAL      = '"+xFilial("CB7")+"' " + _lEnt
	_cQry += " 		AND (CB7_CLIENT    = SUA.UA_CLIENTE ) " + _lEnt
	_cQry += " 		AND (CB7_LOJA      = SUA.UA_LOJA    ) " + _lEnt
	_cQry += " 		AND (CB7_PEDIDO    = SUA.UA_NUMSC5  ) " + _lEnt
	_cQry += " 		AND CB7.CB7_DTFIN  <= C9X.C9_DTEMISS " + _lEnt
	 //_cQry += " 		AND C9X.C9_DATALIB <= CB7_DTEMIS " + _lEnt 
	_cQry += " 		AND CB7.D_E_L_E_T_ = '' " + _lEnt
	_cQry += " 	LEFT JOIN ( SELECT DAI_CLIENT,DAI_LOJA,DAI_PEDIDO,DAI_COD,DAI_NFISC2,DAI_SERIE2,DAI_DATA " + _lEnt
	_cQry += " 				FROM "+RetSqlName("DAI")+" DAI (NOLOCK) " + _lEnt
	_cQry += " 				WHERE DAI.DAI_FILIAL = '"+xFilial("DAI")+"' " + _lEnt 
	_cQry += " 				AND DAI.D_E_L_E_T_   = '' " + _lEnt
	_cQry += " 				GROUP BY DAI_CLIENT,DAI_LOJA,DAI_PEDIDO,DAI_COD,DAI_NFISC2,DAI_SERIE2,DAI_DATA " + _lEnt
	_cQry += " 			  ) DX " + _lEnt
	_cQry += " 		ON  (DX.DAI_CLIENT = SUA.UA_CLIENTE ) " + _lEnt
	_cQry += " 		AND (DX.DAI_LOJA   = SUA.UA_LOJA    ) " + _lEnt
	_cQry += " 		AND (DX.DAI_PEDIDO = SUA.UA_NUMSC5  ) " + _lEnt
	_cQry += " 		AND (DX.DAI_NFISC2 = C9X.C9_NFISCAL  ) " + _lEnt
	_cQry += " 		AND C9X.C9_DTEMISS <= DAI_DATA " + _lEnt
	If MV_PAR14 == 1
		_cQry += " 		 	LEFT JOIN (	SELECT SC6.C6_LOJA , SC6.C6_CLI ,  C6_NUM, sum(SC6.C6_QTDVEN) C6_QTDVEN , SUM(C6_VALOR) C6_VALOR "  + _lEnt
		_cQry += " 		 				FROM "+RetSqlName("SC6")+"  SC6 (NOLOCK) "  + _lEnt
		_cQry += " 		 				WHERE SC6.C6_FILIAL = '"+xFilial("SC6")+"' "  + _lEnt
		_cQry += " 		 				AND SC6.D_E_L_E_T_  = '' "  + _lEnt
		_cQry += " 		 				GROUP BY C6_NUM ,C6_LOJA , C6_CLI  "  + _lEnt
		_cQry += " 		 			  ) C6X  								"  + _lEnt
		_cQry += " 		 		ON  (C6X.C6_CLI 	= SUA.UA_CLIENTE )   	"  + _lEnt
		_cQry += " 		 		AND (C6X.C6_LOJA    = SUA.UA_LOJA    )   	"  + _lEnt
		_cQry += " 		 		AND (C6X.C6_NUM  	= SUA.UA_NUMSC5  )   	"  + _lEnt
		_cQry += " 		 	LEFT JOIN (	SELECT SFT1.FT_CHVNFE, SFT1.FT_CLIEFOR, SFT1.FT_LOJA, SFT1.FT_NFISCAL, FT_EMISSAO " + _lEnt
		_cQry += " 		 		 		 				FROM "+RetSqlName("SFT")+"  SFT1 (NOLOCK) "   + _lEnt			
		_cQry += " 		 		 		 				WHERE SFT1.FT_FILIAL = '"+xFilial("SFT")+"' " + _lEnt	
		_cQry += " 		 		 		 				AND SFT1.D_E_L_E_T_  = '' AND SFT1.FT_TIPOMOV = 'S'	"  + _lEnt
		_cQry += " 		 		 		 				GROUP BY SFT1.FT_CHVNFE ,  SFT1.FT_CLIEFOR, SFT1.FT_LOJA, SFT1.FT_NFISCAL, FT_EMISSAO "  + _lEnt
		_cQry += " 		 		 		 			  ) FT  	 																 "  + _lEnt							
	 	_cQry += " 		 				 		ON  (FT.FT_CLIEFOR 	= SUA.UA_CLIENTE )   	                                     "  + _lEnt
		_cQry += " 		 		 		 		AND (FT.FT_LOJA     = SUA.UA_LOJA    )   	                                     "  + _lEnt
	 	_cQry += " 		 				 		AND (FT.FT_NFISCAL 	= C9X.C9_NFISCAL ) 											 "  + _lEnt
	EndIf
	_cQry += " WHERE SUA.UA_FILIAL = '"+ xFilial("SUA") +"' " + _lEnt
	_cQry += " AND SUA.UA_EMISSAO  BETWEEN '"+DTOS(MV_PAR01)+"'	AND '"+DTOS(MV_PAR02)+"' " + _lEnt
	_cQry += " AND SUA.UA_CLIENTE  BETWEEN '"+ MV_PAR03 +"'		AND '"+ MV_PAR05 +"' " + _lEnt
	_cQry += " AND SUA.UA_LOJA     BETWEEN '"+ MV_PAR04 +"'		AND '"+ MV_PAR06 +"' " + _lEnt
	_cQry += " AND SUA.UA_NUM      BETWEEN '"+ MV_PAR07 +"'		AND '"+ MV_PAR08 +"' " + _lEnt
	_cQry += " AND SUA.UA_VEND     BETWEEN '"+ MV_PAR09 +"'		AND '"+ MV_PAR10 +"' " + _lEnt
	_cQry += " AND SA1.A1_CGCCENT  BETWEEN '"+ MV_PAR11 +"'		AND '"+ MV_PAR12 +"' " + _lEnt
	_cQry += " AND SUA.UA_STATUS NOT IN ('CAN')" + _lEnt
	_cQry += " AND SUA.UA_CONDPG   <> 'FOL' " + _lEnt
	_cQry += " AND SUA.D_E_L_E_T_  = '' " + _lEnt
	_cQry += " GROUP BY	UA_VEND, A3_NOME, A1_CGCCENT, UA_CLIENTE, UA_LOJA, A1_NOME, UA_NUM, UA_EMISSAO, UA_NUMSC5, C5_EMISSAO, C9_DATALIB, C9_DATENT, " + _lEnt
	_cQry += " 		 	   SC5.C5_LIBEROK, SC5.C5_BLQ,  CB7_STATUS, CB7_ORDSEP,CB7_DTEMIS, CB7_DTFIN, C9_DTEMISS, C9_SERIENF,C5_DTLIBCR, C9_NFISCAL, C9_BLCRED,  DAI_COD, DAI_DATA ,  C9_BLEST , C9_DTLIBCR , SUA.UA_STATUS, C9_ORDSEP " + _lEnt
	If MV_PAR14 == 1
		_cQry += " ,	C9_QTDLIB , UA_VALBRUT,	C9_XVALOR, C6X.C6_QTDVEN, C6_VALOR , FT_CHVNFE,FT_EMISSAO, FT_CLIEFOR, FT_LOJA, FT_NFISCAL " + _lEnt	  
	EndIf
	If cTp == "1"
		_cQry += " ORDER BY	SUA.UA_EMISSAO,SUA.UA_NUM,SUA.UA_CLIENTE,SUA.UA_LOJA,SUA.UA_NUMSC5,C9_SERIENF " + _lEnt
	Else
		_cQry += "  	) TAB  GROUP by TAB.STATUS , TAB.STATUSNOME order  by TAB.STATUS"
	EndIf
	If (Len(_cQry)) >0 .AND. !lEnd
		_cQry := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_tAlias,.T.,.F.)
	Else
		If !_lJob
			MSGBOX("A consulta não foi gerada corretamente, verifique os parâmetros informados.",_cRotina+"_000","ALERT")
	    EndIf		
	EndIf
return nil
/*/{Protheus.doc} Geraxls
@description Gera resultado no Excel (XLS).
@author Júlio Soares
@since 05/07/2016
@version 1.0
@param lEnd, logical , Parâmetro default da função "PROCESSA", indicativa de ação de cancelamento da operação pelo usuário.
@param cTp , caracter, Indica o tipo de infomrações (1=Analítico; 2=Sintético).
@type function
@see https://allss.com.br
/*/
static function Geraxls(lEnd)
	Local   _cSheet1   := (DTOC(MV_PAR01)) + " ~ " + (DTOC(MV_PAR02))
	Local   _cSheet2   := 'Parâmetros'
	Local   _cSheet3   := "Resumo"
	Local   _cFile     := ""
	Local   lTi2Ok     := .F.
	Local   _nCtn3     := 1
	Local   _aResu     := {}
	Local   nCount     := 1
	Local   nRecAlias  := 1
	Local   aMail      := {}

	oExcel:AddWorkSheet(_cSheet1)
	oExcel:AddTable(_cSheet1,_cTitulo)
	// - COLUNAS DO EXCEL
	oExcel:AddColumn(_cSheet1,_cTitulo,'POSICAO'            ,1,1,.F.) // STATUS 1
	oExcel:AddColumn(_cSheet1,_cTitulo,'AREA'               ,1,1,.F.) // STATUS2
	oExcel:AddColumn(_cSheet1,_cTitulo,'REPRESENTANTE'      ,1,1,.F.) // VEND3
	oExcel:AddColumn(_cSheet1,_cTitulo,'NOME REPRESENTANTE' ,1,1,.F.) // NOME_VEND4
	oExcel:AddColumn(_cSheet1,_cTitulo,'CNPJ CENTRAL'       ,1,1,.F.) // CNPJ_CENT45
	oExcel:AddColumn(_cSheet1,_cTitulo,'CLIENTE'            ,1,1,.F.) // CLIENTE6
	oExcel:AddColumn(_cSheet1,_cTitulo,'LOJA'               ,1,1,.F.) // LOJA7
	oExcel:AddColumn(_cSheet1,_cTitulo,'NOME CLIENTE'       ,1,1,.F.) // NOME8
	oExcel:AddColumn(_cSheet1,_cTitulo,'ATENDIMENTO'        ,1,1,.F.) // N_ATEND9
	oExcel:AddColumn(_cSheet1,_cTitulo,'DATA ATENDIMENTO'   ,2,4,.F.) // AT_EMISS10
	If MV_PAR14 == 1
		oExcel:AddColumn(_cSheet1,_cTitulo,'VALOR ATENDENDIMENTO' ,3,2,.F.) //11
	EndIf
	If MV_PAR13 == 2
		oExcel:AddColumn(_cSheet1,_cTitulo,'DIAS ATENDIMENTO'     ,3,1,.F.) // 12
	EndIf
	oExcel:AddColumn(_cSheet1,_cTitulo,'PEDIDO'                   ,1,1,.F.) // N_PEDIDO13
	oExcel:AddColumn(_cSheet1,_cTitulo,'DATA PEDIDO'              ,2,4,.F.) // PD_EMISS14
	If MV_PAR13 == 2
		oExcel:AddColumn(_cSheet1,_cTitulo,'DIAS PEDIDO'          ,3,1,.F.) // 15
	EndIf
	If MV_PAR14 == 1
		oExcel:AddColumn(_cSheet1,_cTitulo,'VALOR PEDIDO'         ,3,2,.F.) //16
	EndIf
	oExcel:AddColumn(_cSheet1,_cTitulo,'DATA LIBERAÇÃO FISCAL'    ,1,1,.F.) // PD_LIB17
	If MV_PAR13 == 2
		oExcel:AddColumn(_cSheet1,_cTitulo,'DIAS LIBERAÇÃO FISCAL',3,1,.F.) //18
	EndIf
	oExcel:AddColumn(_cSheet1,_cTitulo,'DATA CRÉDITO'             ,1,1,.F.) // DT_LIBCRD19
	If MV_PAR13 == 2
		oExcel:AddColumn(_cSheet1,_cTitulo,'DIAS CRÉDITO'         ,3,1,.F.) //20
	EndIf
	If MV_PAR14 == 1
		oExcel:AddColumn(_cSheet1,_cTitulo,'VALOR CRÉDITO'        ,3,2,.F.) //21
	EndIf
	oExcel:AddColumn(_cSheet1,_cTitulo,'SEPARAÇÃO'                ,1,1,.F.) // N_ORDSEP22
	oExcel:AddColumn(_cSheet1,_cTitulo,'DATA SEPARAÇÃO'           ,2,4,.F.) // OS_EMISS23
	If MV_PAR13 == 2
		oExcel:AddColumn(_cSheet1,_cTitulo,'DIAS SEPARAÇÃO'       ,3,1,.F.) // 24
	EndIf
	oExcel:AddColumn(_cSheet1,_cTitulo,'NOTA FISCAL'              ,1,1,.F.) // DOC25
	oExcel:AddColumn(_cSheet1,_cTitulo,'SERIE'                    ,1,1,.F.) // SERIE26
	oExcel:AddColumn(_cSheet1,_cTitulo,'DATA NOTA FISCAL'         ,2,4,.F.) // EMISS_NOTA27
	If MV_PAR13 == 2
		oExcel:AddColumn(_cSheet1,_cTitulo,'DIAS NOTA FISCAL'     ,3,1,.F.) //28
	EndIf
	oExcel:AddColumn(_cSheet1,_cTitulo,'EXPEDIÇÃO'                ,1,1,.F.) // CARGA29
	oExcel:AddColumn(_cSheet1,_cTitulo,'DATA EXPEDIÇÃO'           ,2,4,.F.) // EXP_EMISS30
	If MV_PAR13 == 2
		oExcel:AddColumn(_cSheet1,_cTitulo,'DIAS EXPEDIÇÃO'       ,3,1,.F.) //31
	EndIf
	oExcel:AddColumn(_cSheet1,_cTitulo,'TOTAL DE DIAS'            ,3,1,.F.) // DIAS_TOT32
	dbSelectArea(_tAlias)
	nRecAlias := len((_tAlias))
	ProcRegua(((_tAlias)->(LASTREC())*2)+1)
	(_tAlias)->(dbGoTop())
	// - ACRESCENTA AS LINHAS COM INFORMAÇÕES WHILE ! TEMP ->(EOF())
	While !(_tAlias)->(EOF()) .AND. !lEnd
		If !_lJob
			IncProc('Processando Atendimentos' ) 
		EndIf
		_aAux := StrTokArr(_cCmp,',')
		For _nCtn2 := 1 To Len(_aAux)
		    _aAux[_nCtn2] := &(_aAux[_nCtn2])
		Next
		oExcel:AddRow(_cSheet1, _cTitulo, _aAux )
		(_tAlias)->(dbSkip())
		nCount++
		lTi2Ok := .T.
	EndDo
	_aAux := {}
	If lEnd .and. !_lJob
		If MSGBOX("Deseja cancelar a emissão do relatório?",_cRotina+"_000","YESNO")
			FreeObj(oExcel)
			oExcel := NIL
			return
		EndIf
	EndIf
	if MV_PAR15 == 1 .and. lTi2Ok
		If Select (_tAlias) > 0
		   (_tAlias)->(dbCloseArea())
		EndIf
		_cSheet3 := "Resumo por Área"
		if !_lJob
			Processa({ |lEnd| SelectQry(@lEnd,"2") },_cTitulo3,"Processando Resumo",.T.)
		Else
			SelectQry(@lEnd,"2")		
		EndIf
		oExcel:AddWorkSheet(_cSheet3)
		oExcel:AddTable(_cSheet3,_cTitulo3)
		oExcel:AddColumn(_cSheet3,_cTitulo3,'POSICAO' ,1,1,.F.)
		oExcel:AddColumn(_cSheet3,_cTitulo3,'AREA' ,1,1,.F.)
		oExcel:AddColumn(_cSheet3,_cTitulo3,'QUANTIDADE'  ,1,1,.F.)
		//If MV_PAR14 == 1
			oExcel:AddColumn(_cSheet3,_cTitulo3,'VALORES'  ,3,3,.F.)
		//EndIf
		oExcel:AddColumn(_cSheet3,_cTitulo3,'MEDIA'  ,1,1,.F.)
		_aAux  := {}
		_nCtn2 := 1
		dbSelectArea(_tAlias)
		ProcRegua(((_tAlias)->(LASTREC())*2)+1)
		(_tAlias)->(dbGoTop())
		while !(_tAlias)->(EOF()) .And. !lEnd
			if !_lJob
				IncProc('Processando Resumo')
			EndIf
			_aAux := StrTokArr(_cCmp1,',')
			for _nCtn2 := 1 to len(_aAux)
			    _aAux[_nCtn2] := &(_aAux[_nCtn2])
			next
			If _nCtn3 == _aAux[1]
				oExcel:AddRow(_cSheet3, _cTitulo3, _aAux )
				AADD(_aMail, _aAux)	
				_nCtn3++			
			Else
				While _nCtn3 < _aAux[1]	
					If  _nCtn3 == 1 .and. _nCtn3 < _aAux[1].And.  alltrim(_aAux[2]) <> "Atendimento"		
						_aResu:=  {1,"Atendimento",0,0,0}
						oExcel:AddRow(_cSheet3, _cTitulo3, _aResu )
						AADD(_aMail, _aResu)
						_aResu := {}	
						_nCtn3++
					ElseIf  _nCtn3 == 2 .and. _nCtn3 < _aAux[1].And.  alltrim(_aAux[2]) <> "Comercial"		
						_aResu:=  {2,"Comercial",0,0,0}
						oExcel:AddRow(_cSheet3, _cTitulo3, _aResu )
						AADD(_aMail, _aResu)
						_aResu := {}	
						_nCtn3++
					ElseIf  _nCtn3== 3 .and.  _nCtn3 < _aAux[1] .And. alltrim(_aAux[2]) <> "Fiscal"
						_aResu:=  {3,"Fiscal",0,0,0}
						oExcel:AddRow(_cSheet3, _cTitulo3, _aResu )
						AADD(_aMail, _aResu)
						_aResu := {}	
						_nCtn3++
					ElseIf  _nCtn3== 4 .and. _nCtn3 < _aAux[1]  .And. alltrim(_aAux[2]) <> "Financeiro"
						_aResu:=  {4,"Financeiro",0,0,0}
						oExcel:AddRow(_cSheet3, _cTitulo3, _aResu )
						AADD(_aMail, _aResu)
					 	_aResu := {}	
						_nCtn3++
					ElseIf	 _nCtn3== 5 .and. _nCtn3 < _aAux[1] .And. alltrim(_aAux[2]) <> "Pré-Separação"
						_aResu:=  {5,"Expedição",0,0,0}
						oExcel:AddRow(_cSheet3, _cTitulo3, _aResu )
						AADD(_aMail, _aResu)
						_aResu := {}	
						_nCtn3++
					ElseIf  _nCtn3== 6 .and.  _nCtn3 < _aAux[1] .And. alltrim(_aAux[2]) <> "Separação"
						_aResu :=  {6,"Separação",0,0,0}
						oExcel:AddRow(_cSheet3, _cTitulo3, _aResu )
						AADD(_aMail, _aResu)
						_nCtn3++
					ElseIf _nCtn3== 7 .and.  _nCtn3 < _aAux[1]  .And. alltrim(_aAux[2]) <> "Expedição"
						_aResu :=  {7,"Expedição",0,0,0}
						oExcel:AddRow(_cSheet3, _cTitulo3, _aResu )
						AADD(_aMail, _aResu)
						_aResu := {}	
						_nCtn3++
					ElseIf  _nCtn3== 8 .and.  _nCtn3 < _aAux[1] .And. alltrim(_aAux[2]) <> "Entregue"
						_aResu:=  {8,"Entregue",0,0,0}
						oExcel:AddRow(_cSheet3, _cTitulo3, _aResu )
						AADD(_aMail, _aResu)
						_aResu := {}	
						_nCtn3++
					ElseIf  _nCtn3== 9 .and.  _nCtn3 < _aAux[1] .And. alltrim(_aAux[2]) <> "Quarentena"
						_aResu:=  {9,"Quarentena",0,0,0}
						oExcel:AddRow(_cSheet3, _cTitulo3, _aResu )
						AADD(_aMail, _aResu)
						_aResu := {}	
						_nCtn3++
					EndIf
				EndDo	
				If _nCtn3 == _aAux[1]
					oExcel:AddRow(_cSheet3, _cTitulo3, _aAux )
	        		AADD(_aMail, _aAux)
	        		_nCtn3++
				EndIf
			EndIf
			(_tAlias)->(dbSkip())
		EndDo
	EndIf
	// - INCLUI UMA ABA COM AS INFORMAÇÕES DOS PARAMETROS
	oExcel:AddWorkSheet(_cSheet2)
	oExcel:AddTable(_cSheet2,_cTitulo2)
	oExcel:AddColumn(_cSheet2,_cTitulo2,'DESCRIÇÃO' ,1,1,.F.)
	oExcel:AddColumn(_cSheet2,_cTitulo2,'CONTEÚDO'  ,1,1,.F.)
	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	(_cAliasSX1)->(dbGoTop())
	_cPerg := PADR(_cPerg,10)
	If (_cAliasSX1)->(dbSeek(_cPerg))
		While !(_cAliasSX1)->(EOF()) .AND. (_cAliasSX1)->X1_GRUPO == _cPerg
			//IncProc('PROCESSANDO PARÂMETROS.')
			If AllTrim((_cAliasSX1)->X1_GSC)=="C"
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&("(_cAliasSX1)->X1_DEF"+StrZero(&((_cAliasSX1)->X1_VAR01),2)) })
			Else
				AAdd(_aPar,{ (_cAliasSX1)->X1_PERGUNT,&((_cAliasSX1)->X1_VAR01) })
			EndIf
			dbSelectArea(_cAliasSX1)
			(_cAliasSX1)->(dbSetOrder(1))  //Grupo + Ordem    
			(_cAliasSX1)->(dbSkip())
		EndDo
	EndIf
	If Len(_aPar) > 0
		For _nPosPar := 1 To Len(_aPar)
			oExcel:AddRow(_cSheet2, _cTitulo2, _aPar[_nPosPar])
		Next
	EndIf
	RestArea(_aSavArea)
	If !_lJob
		If  MSGBOX("Deseja enviar por e-mail?",_cRotina+"_002","YESNO")
			envMailLead(_aMail)
		EndIf
		If  MSGBOX("Deseja abrir o arquivo gerado?",_cRotina+"_003","YESNO")
			IncProc("Abrindo o Arquivo...")
			oExcel:Activate()                                                     
		    oExcel:GetXMLFile(_cFileTMP)
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open(_cFileTMP)
			oExcelApp:SetVisible(.T.)
	    	FreeObj(oExcel)
		    oExcel := NIL
	    EndIf
	    MSGBOX("Relatório gerado: " + _cFileTMP  +". ",_cRotina+"_000","ALERT")			
	Else
		envMailLead(_aMail)	
    EndIf
return
/*/{Protheus.doc} ValidPerg
@description Perguntas do usuário.
@author Júlio Soares
@since 05/07/2016
@version 1.0
@param _cPerg , caracter, Grupo de Perguntas no arquivo SX1.
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	Local _sAlias := GetArea()
	Local aRegs   := {}
	Local _x      := 0
	Local _y      := 0
	_cPerg        := PADR(_cPerg,10)

	AADD(aRegs,{_cPerg,"01","De Emissão?"		,"","","mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	AADD(aRegs,{_cPerg,"02","Até Emissão?"		,"","","mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	AADD(aRegs,{_cPerg,"03","De Cliente?"		,"","","mv_ch3","C",06,0,0,"G",""          ,"mv_par03",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","SA1","","","",""})
	AADD(aRegs,{_cPerg,"04","De Loja?"			,"","","mv_ch4","C",02,0,0,"G",""          ,"mv_par04",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	AADD(aRegs,{_cPerg,"05","Até Cliente?"		,"","","mv_ch5","C",06,0,0,"G",""          ,"mv_par05",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","SA1","","","",""})
	AADD(aRegs,{_cPerg,"06","Até Loja?"			,"","","mv_ch6","C",02,0,0,"G",""          ,"mv_par06",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","",""   ,"","","",""})
	AADD(aRegs,{_cPerg,"07","De Atendimento?"	,"","","mv_ch7","C",06,0,0,"G",""          ,"mv_par07",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","SUA","","","",""})
	AADD(aRegs,{_cPerg,"08","Até Atendimento?"	,"","","mv_ch8","C",06,0,0,"G",""          ,"mv_par08",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","SUA","","","",""})

	// Alteração - Fernando Bombardi - ALLSS - 03/03/2022
	//AADD(aRegs,{_cPerg,"09","De Vendedor?"		,"","","mv_ch9","C",06,0,0,"G",""          ,"mv_par09",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","SA3","","","",""})
	//AADD(aRegs,{_cPerg,"10","Até Vendedor?"		,"","","mv_cha","C",06,0,0,"G",""          ,"mv_par10",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","SA3","","","",""})

	AADD(aRegs,{_cPerg,"09","De Representante?"		,"","","mv_ch9","C",06,0,0,"G",""          ,"mv_par09",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","SA3","","","",""})
	AADD(aRegs,{_cPerg,"10","Até Representante?"    ,"","","mv_cha","C",06,0,0,"G",""          ,"mv_par10",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","SA3","","","",""})
	// Fim - Fernando Bombardi - ALLSS - 03/03/2022

	AADD(aRegs,{_cPerg,"11","De CNPJ Central?"	,"","","mv_chb","C",14,0,0,"G",""          ,"mv_par11",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","",""	,"","","",""})
	AADD(aRegs,{_cPerg,"12","Até CNPJ Central?"	,"","","mv_chc","C",14,0,0,"G",""          ,"mv_par12",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","",""	,"","","",""})
	AADD(aRegs,{_cPerg,"13","Tipo relatório?"	,"","","mv_chd","C",01,0,0,"C",""          ,"mv_par13","Sintético"	,"","","","","Analítico","","","","","","","","","","","","","","","","","","",""	,"","","",""})
	AADD(aRegs,{_cPerg,"14","Listar Valores?"	,"","","mv_che","c",01,0,0,"C",""          ,"mv_par14","Sim"	,"","","","","Não","","","","","","","","","","","","","","","","","","",""	,"","","",""})
	AADD(aRegs,{_cPerg,"15","Gera Resumo?"	    ,"","","mv_chf","c",01,0,0,"C",""          ,"mv_par15","Sim"	,"","","","","Não","","","","","","","","","","","","","","","","","","",""	,"","","",""})
	For _x := 1 To Len(aRegs)
		dbSelectArea("SX1")
		SX1->(dbSetOrder(1))
		If !SX1->(MsSeek(_cPerg+aRegs[_x,2],.T.,.F.))
			RecLock("SX1",.T.)
			For _y := 1 To FCount()
				If _y <= Len(aRegs[_x])
					FieldPut(_y,aRegs[_x,_y])
				Else              
					Exit
				EndIf
			Next
			SX1->(MsUnlock())
		EndIf
	Next
	RestArea(_sAlias)
return
/*/{Protheus.doc} envMailLead
@description Envio de e-mail do LeadTime
@author Livia  Della Corte
@since 05/07/2016
@version 1.0
@type function
@see https://allss.com.br
/*/
//static function envMailLead ( lJob, _aMail, _cMvLeadMail)
//static function envMailLead (_)
static function envMailLead ()
	Local	_cMail    := iif(_lJob,SUPERGETMV("MV_LDMAIL",.F.,"anderson.coelho@allss.com.br"), UsrRetMail(RetCodUsr()))  //+  _cMvLeadMail
	Local 	_cMsgMail := ""
	Local	_dData    := SUBSTR( dtos(date()),7,2)+"/"+SUBSTR( dtos(date()),5,2)+"/"+SUBSTR( dtos(date()),1,4) 

	_cMsgMail := ""
	_cMsgMail += '<table   width="80%"><font size="4" face="Arial"><b><br>Lead Time - Ciclo de Atendimento</b></font></TABLE>' 
	_cMsgMail += '<table   width="80%"><font size="3" face="Arial"><br>    De:' + SUBSTR( dtos(_cMV_PAR01),7,2)+"/"+SUBSTR( dtos(_cMV_PAR01),5,2)+"/"+SUBSTR( dtos(_cMV_PAR01),1,4)  +' Até:' + SUBSTR( dtos(_cMV_PAR02),7,2)+"/"+SUBSTR( dtos(_cMV_PAR02),5,2)+"/"+SUBSTR( dtos(_cMV_PAR02),1,4)  + '</font></TABLE>' 
	_cMsgMail += '<table border="1"  width="80%" bgcolor="#FFFFF0">' 
	_cMsgMail += '<tr bgcolor= "#efeff8">'
	_cMsgMail += '   <th width="20%" bgcolor= "#efeff8"><font size="3" face="Arial"><b>Área</b></font></td>' 
	_cMsgMail += '   <th width="35%" bgcolor= "#efeff8"><font size="3" face="Arial"><b>Quantidade</b></font></td>' 
	_cMsgMail += '   <th width="35%" bgcolor= "#efeff8"><font size="3" face="Arial"><b>Valor</b></font></td>' 
	_cMsgMail += '</tr>' 
	for nX := 1 to len(_aMail)
		_cMsgMail += '<tr>' 
		_cMsgMail += '   <td width="20%"><font size="2" face="Arial">' + _aMail[nX][2] + '</font></td>' 
		_cMsgMail += '   <td width="35%"><font size="2" face="Arial">' +  cvaltochar(_aMail[nX][3]) + '</font></td>' 
		_cMsgMail += '   <td width="35%"><font size="2" face="Arial">' +  Transform((_aMail[nX][4]), "@E 999,999,999,999.99") + '</font></td>'
	Next
	_cMsgMail += '</table>'
	_cMsgMail += '<p><b><font size="1" face="Arial">     | E-mail enviado atrav&eacute;s do Protheus | Por favor não responda |</font></b><br></BR>' 
	 If ExistBlock("RCFGM001")
		U_RCFGM001	(	  /*_cTitulo*/		,	;
					_cMsgMail /*_cMsg*/	,	;
					_cMail  /*_cMail*/	,	;
				    _cFileTmp 			,	;
					/*_cFromOri*/		,	;
					/*_cBCC*/			,	;
					" | Arcolor | Lead Time  | Gerado: " + _dData + " |  "+ TiME()+ " | " /*_cAssunto*/,;
					.T. /*_lExcAnex*/	,	;
					.F. /*_lAlert*/			)
	EndIf
return .T.
