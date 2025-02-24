#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} RCOMR035
@description Relatorio de totais COMPRADOS por produto por periodo, mes a mes, baseado nos Documentos de Entrada. O relat�rio apresentar� e somar� quantidades, valores de mercadorias ou valor net de vendas, conforme parametriza��o do usu�rio. Tamb�m conforme parametriza��o, o relat�rio apresentar� Somente Vendas, Somente o que n�o for Venda ou Ambos. Al�m disso, tamb�m conforme parametriza��o, o relat�rio abate ou n�o as devolu��es de vendas.
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 07/12/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RCOMR035()
	private oReport
	private oSection
	private _cRotina  := "RCOMR035"
	private cPerg     := _cRotina
	private _cSD1TMP  := GetNextAlias()
	private _cFormTit := "" //_cFormTit := '"Relat�rio de Totais COMPRADOS por Produto, por Per�odo ("+IIF(MV_PAR12==2,"SOMENTE",IIF(MV_PAR11==1,"SEM","COM"))+" DEVOLU��ES) - em "+SuperGetMV("MV_MOEDAP"+MV_PAR13,,"Reais")'
	private aRegs     := {}
	private _aCpos    := {}
	private _lMoeda   := .F.
	if FindFunction("TRepInUse") .And. TRepInUse()
		ValidPerg()
		if !Pergunte(cPerg,.T.)
			return
		endif
		_cFormTit := '"Relat�rio de Totais COMPRADOS, por Per�odo ("+IIF(MV_PAR12==2,"SOMENTE",IIF(MV_PAR11==1,"SEM","COM"))+" DEVOLU��ES) - em "+SuperGetMV("MV_MOEDAP"+MV_PAR13,,"Reais")'
		// MV_PAR11 := IIF(ValType(MV_PAR11)=="N",cValToChar(MV_PAR11),MV_PAR11)
		// MV_PAR12 := IIF(ValType(MV_PAR12)=="N",cValToChar(MV_PAR12),MV_PAR12)
		if empty(MV_PAR13)
			MV_PAR13 := "1"
		endif
		MV_PAR13 := IIF(ValType(MV_PAR13)=="N",cValToChar(MV_PAR13),MV_PAR13)
		if Select(_cSD1TMP) > 0
			(_cSD1TMP)->(dbCloseArea())
		endif
		oReport  := ReportDef()
		oReport:PrintDialog()
		if Select(_cSD1TMP) > 0
			(_cSD1TMP)->(dbCloseArea())
		endif
		_bPERG := "Pergunte(cPerg,.T.)"
		while MSGBOX("Deseja emitir o relat�rio novamente?",_cRotina+"_001","YESNO")
			if !&(_bPERG)
				return
			endif
			_cFormTit := '"Relat�rio de Totais COMPRADOS, por Per�odo ("+IIF(MV_PAR12==2,"SOMENTE",IIF(MV_PAR11==1,"SEM","COM"))+" DEVOLU��ES) - em "+SuperGetMV("MV_MOEDAP"+MV_PAR13,,"Reais")'
			// MV_PAR11 := IIF(ValType(MV_PAR11)=="N",cValToChar(MV_PAR11),MV_PAR11)
		    // MV_PAR12 := IIF(ValType(MV_PAR12)=="N",cValToChar(MV_PAR12),MV_PAR12)
			if empty(MV_PAR13)
				MV_PAR13 := "1"
			endif
			MV_PAR13 := IIF(ValType(MV_PAR13)=="N",cValToChar(MV_PAR13),MV_PAR13)
			if Select(_cSD1TMP) > 0
				(_cSD1TMP)->(dbCloseArea())
			endif
			oReport  := ReportDef()
			oReport:PrintDialog()
			if Select(_cSD1TMP) > 0
				(_cSD1TMP)->(dbCloseArea())
			endif
		enddo
	endif
return
/*/{Protheus.doc} ReportDef (RCOMR035)
@description A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 06/02/2015
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ReportDef()
	local cTitulo  := &(_cFormTit)
	local _aOrd    := {"Ordem dos Campos"}		//{"Grupo + Produto", "Grupo + Descri��o de Produto"}
	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//��������������������������������������������������������������������������
//	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintRel(oReport)},"Emissao do relat�rio, de acordo com o intervalo informado na op��o de Par�metros.")
	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|| PrintRel()},"Emissao do relat�rio, de acordo com o intervalo informado na op��o de Par�metros.")
	oReport:SetLandscape() 
	oReport:SetTotalInLine(.F.)

	Pergunte(oReport:uParam,.F.)
	//Convers�o de tipo do par�metro de devolu��es
		If Empty(MV_PAR13)
			MV_PAR13 := "1"
		EndIf
		MV_PAR13 := IIF(ValType(MV_PAR13)=="N",cValToChar(MV_PAR13),MV_PAR13)
	//Fim da convers�o de tipo do par�metro de devolu��es
	//Tratamento de permiss�o para emiss�o do relat�rio por valor
		If MV_PAR05 <> 2 .AND. !__cUserId$SuperGetMv("MV_USRVLFT",,"|000000|")
			MsgStop("Aten��o! Emiss�o do relat�rio em valor n�o autorizada. Sendo assim, o relat�rio ser� modificado para emiss�o em quantidade!",_cRotina+"_004")
			MV_PAR05 := 2
		EndIf
	//Fim do tratamento de permiss�o para emiss�o do relat�rio por valor
	//Adequa��o do t�tulo do relat�rio
	//	oReport:cDescription := oReport:cRealTitle := oReport:cTitle := cTitulo := &(_cFormTit)
	//Fim da Adequa��o do t�tulo do relat�rio
	//������������������������������������������������������������������������Ŀ
	//�Criacao da secao utilizada pelo relatorio                               �
	//�TRSection():New                                                         �
	//�ExpO1 : Objeto TReport que a secao pertence                             �
	//�ExpC2 : Descricao da se�ao                                              �
	//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
	//�        sera considerada como principal para a se��o.                   �
	//�ExpA4 : Array com as Ordens do relat�rio                                �
	//�ExpL5 : Carrega campos do SX3 como celulas                              �
	//�        Default : False                                                 �
	//�ExpL6 : Carrega ordens do Sindex                                        �
	//�        Default : False                                                 �
	//��������������������������������������������������������������������������
	//������������������������������������������������������������������������Ŀ
	//�Criacao da celulas da secao do relatorio                                �
	//�TRCell():New                                                            �
	//�ExpO1 : Objeto TSection que a secao pertence                            �
	//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
	//�ExpC3 : Nome da tabela de referencia da celula                          �
	//�ExpC4 : Titulo da celula                                                �
	//�        Default : //X3TITULO()                                            �
	//�ExpC5 : Picture                                                         �
	//�        Default : X3_PICTURE                                            �
	//�ExpC6 : Tamanho                                                         �
	//�        Default : X3_TAMANHO                                            �
	//�ExpL7 : Informe se o tamanho esta em pixel                              �
	//�        Default : False                                                 �
	//�ExpB8 : Bloco de c�digo para impressao.                                 �
	//�        Default : ExpC2                                                 �
	//��������������������������������������������������������������������������
	//������������������������������������������������������������������������Ŀ
	//� Secao dos itens do Pedido de Vendas                                    �
	//��������������������������������������������������������������������������
	oSection := TRSection():New(oReport,"RELAT�RIO DE ITENS COMPRADOS - QTD. E VALOR",{"SD1","SD2","SF1","SB1","SA2","SF4"},_aOrd/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)

	//Identifica��o dos campos em uso, mas identificarmos depois os campos adicionados pelo usu�rio, para que possamos o incluir na query.
	/*_aCpos := {	"B1_GRUPO",;
				"B1_TIPO" ,;
				"B1_COD"  ,;
				"B1_DESC" ,;
				"B1_UM"   }*/
	//Defini��o das colunas do relat�rio
	TRCell():New(oSection,"B1_GRUPO"    ,"SB1"/*Tabela*/,RetTitle("B1_GRUPO"  ),PesqPict  ("SB1","B1_GRUPO"),TamSx3("B1_GRUPO")[1],/*lPixel*/,{|| (_cSD1TMP)->B1_GRUPO 		})	// Grupo de Produto
	//TRCell():New(oSection,"B1_TIPO"   ,"SB1"/*Tabela*/,RetTitle("B1_TIPO"	  ),PesqPict  ("SB1","B1_TIPO" ),TamSx3("B1_TIPO" )[1],/*lPixel*/,{|| (_cSD1TMP)->B1_TIPO   	})	// Tipo de Produto
	TRCell():New(oSection,"B1_COD"      ,"SB1"/*Tabela*/,RetTitle("B1_COD"    ),PesqPict  ("SB1","B1_COD"  ),TamSx3("B1_COD"  )[1],/*lPixel*/,{|| (_cSD1TMP)->B1_COD    	})	// Codigo do Produto
	TRCell():New(oSection,"B1_DESC"     ,"SB1"/*Tabela*/,RetTitle("B1_DESC"   ),PesqPict  ("SB1","B1_DESC" ),TamSx3("B1_DESC" )[1],/*lPixel*/,{|| (_cSD1TMP)->B1_DESC		})	// Descricao do Produto
	TRCell():New(oSection,"B1_UM"       ,"SB1"/*Tabela*/,RetTitle("B1_UM"	  ),PesqPict  ("SB1","B1_UM"   ),TamSx3("B1_UM"   )[1],/*lPixel*/,{|| (_cSD1TMP)->B1_UM         })	// Unidade de Medida
	//TRCell():New(oSection,"D1_QUANT"    ,"SUB"/*Tabela*/,RetTitle("D1_QUANT"  ),PesqPictQt("D1_QUANT"	   ),TamSx3("D1_QUANT")[1],/*lPixel*/,{|| (_cSD1TMP)->D1_QUANT      })	// Quantidade
	//TRCell():New(oSection,"D1_TOTAL"    ,"SUB"/*Tabela*/,RetTitle("D1_TOTAL"  ),PesqPict  ("SD1","D1_TOTAL"),TamSx3("D1_TOTAL")[1],/*lPixel*/,{|| (_cSD1TMP)->D1_TOTAL		})	// Valor Total

	//oBreak := TRBreak():New(oSection,oSection:Cell("B1_COD"),"Sub-Total Produtos")
	//TRFunction():New(oSection:Cell("D1_QUANT"  ),NIL,"SUM",oBreak)
	//TRFunction():New(oSection:Cell("D1_TOTAL"  ),NIL,"SUM",oBreak)

	//������������������������������������������������������������������������Ŀ
	//� Troca descricao do total dos itens                                     �
	//��������������������������������������������������������������������������
	//oReport:Section(1):SetTotalText("T O T A I S ")
	//Efetuo o relacionamento entre as tabelas
	//TRPosition():New(oSection,"SF2",1,{|| FWFilial("SF2") + SD1->D1_DOC+SD1->D1_SERIE})
	//TRPosition():New(oSection,"SB1",1,{|| FWFilial("SB1") + SD1->D1_COD              })
	//oReport:Section(2):SetEdit(.F.) 
	//oReport:Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query

	//������������������������������������������������������������������������Ŀ
	//� Alinhamento a direita as colunas de valor                              �
	//��������������������������������������������������������������������������
	//oSection:Cell("D1_QUANT"  ):SetHeaderAlign("RIGHT")
	//oSection:Cell("D1_TOTAL"  ):SetHeaderAlign("RIGHT")
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
return oReport
/*/{Protheus.doc} PrintRel (RCOMR035)
@description Processamento das informa��es para impress�o (Print).
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 07/12/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
static function PrintRel()
//Declara��o das vari�veis
	//Local oSection := oReport:Section(1)
	Local _cCpoSum := ""
	Local _cCpSuDv := ""
	Local _cOrder  := ""
	Local _cGroup  := ""
	Local _cField  := ""
	Local _cFldDv  := ""
	Local _cTotal  := ""
	Local _cMedia  := ""
	Local _cPivot  := ""
	Local _cMesAno := ""
	Local _cLogPar := ""
	Local _cPerTot := ""
	Local _cMasc   := ""
	Local _cTam    := ""
	Local _cCpoRon := ""
	Local _qDevNF  := "0"
	Local _cFilSF1 := oSection:GetSqlExp("SF1")
	Local _cFilSD1 := oSection:GetSqlExp("SD1")
	Local _cFilSB1 := oSection:GetSqlExp("SB1")
	Local _cFilSA2 := oSection:GetSqlExp("SA2")
	Local _cFilSF4 := oSection:GetSqlExp("SF4")
	Local _cFilSD2 := oSection:GetSqlExp("SD2")
	Local _dData   := STOD("")
	Local _aCols   := {}
	Local _lCMoeda := .F.
	Local _nVMoeda := 0
	Local _nBreak  := 0
	Local _nFator  := 0
	Local _nPerTot := 0
//	Local _p       := 0
	Local _nTotBrk := MV_PAR06		//Total de Breaks permitidos (n�veis)
//Fim da declara��o de vari�veis
//Adequa��o do t�tulo do relat�rio
//	oReport:cDescription := oReport:cRealTitle := oReport:cTitle := cTitulo := &(_cFormTit)
//Fim da Adequa��o do t�tulo do relat�rio
//An�lise do preenchimento dos par�metros
	If MV_PAR01 > MV_PAR02 .OR. MV_PAR03 > MV_PAR04 .OR. MV_PAR07 > MV_PAR09 .OR. MV_PAR08 > MV_PAR10 .OR. (MV_PAR12 == 2 .AND. MV_PAR11 == 1)
		MsgStop("Par�metros informados incorretamente... confira!",_cRotina+"_002_A")
		_cLogPar := "Par�metros" + CRLF
		_cLogPar += "**********" + CRLF
		/*
		for _p := 1 to Len(aRegs)
			_cLogPar += ">>> "                          + ;
						aRegs[_p][02]          + " - " + ;
						AllTrim(aRegs[_p][03]) + ": "  + ;
						IIF(Type("MV_PAR"+aRegs[_p][02])=="C",&("MV_PAR"+aRegs[_p][02]),IIF(Type("MV_PAR"+aRegs[_p][02])=="D",DTOC(&("MV_PAR"+aRegs[_p][02])),IIF(Type("MV_PAR"+aRegs[_p][02])=="N",cValToChar(&("MV_PAR"+aRegs[_p][02])),""))) + CRLF
		next
		*/
		MsgInfo(_cLogPar,_cRotina+"_002_B")
		return
	EndIf
//Fim da an�lise do preenchimento dos par�metros
//Permiss�o para emiss�o do relat�rio por valor
	If MV_PAR05 <> 2 .AND. !__cUserId$SuperGetMv("MV_USRVLFT",,"|000000|000045|000046|000047|000048|000019|000028|")
		MsgStop("Aten��o! Emiss�o do relat�rio em valor n�o autorizada. Sendo assim, o relat�rio ser� modificado para emiss�o em quantidade!",_cRotina+"_005")
		MV_PAR05 := 2
	EndIf
//Fim da verifica��o de permiss�o
// Verifica a moeda selecionada
	If MV_PAR05 <> 2
		If Empty(MV_PAR13)
			MV_PAR13 := "1"
		EndIf
		MV_PAR13 := IIF(ValType(MV_PAR13)=="N",cValToChar(MV_PAR13),MV_PAR13)
		If Empty(MV_PAR13)
			MV_PAR13 := "1"
		ElseIf ValType(MV_PAR13) == "C" .AND. AllTrim(MV_PAR13) <> "1"
			_lCMoeda := .T.
		EndIf
		If _lCMoeda .AND. Empty(MV_PAR14)
			MV_PAR14 := dDataBase
		EndIf
		If _lCMoeda
			If MV_PAR15 == 1		//Data Informada para a Moeda no par�metro MV_PAR14 
				dbUseArea(	.T.,;
							"TOPCONN",;
							TcGenQry(,,"(SELECT TOP 1 (CASE WHEN "+MV_PAR13+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR13+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" (NOLOCK) WHERE M2_DATA = '"+DTOS(MV_PAR14)+"' AND D_E_L_E_T_ = '')"),;
							"SM2TMP",;
							.T.,;
							.F.)	
				dbSelectArea("SM2TMP")
				_nVMoeda := cValToChar(SM2TMP->MOEDA)
				dbSelectArea("SM2TMP")
				SM2TMP->(dbCloseArea())
				If VAL(_nVMoeda) == 0
					_lCMoeda := .F.
					MsgInfo("Aten��o! N�o foi localizada taxa para a moeda '"+UPPER(AllTrim(SuperGetMv("MV_MOEDA"+MV_PAR13,,"N�O LOCALIZADA")))+"' no dia "+DTOC(MV_PAR14)+", conforma par�metros informados. O relat�rio ser� emitido na moeda 1!",_cRotina+"_006")
				EndIf
			EndIf
		EndIf
	EndIf
//Fim da verifica��o da moeda 
//In�cio do tratamento para composi��o das devolu��es vendas vinculadas as Entradas filtradas
	//Deduz Devolu��es? - 1=N�o / 2=Sim, Conforme NF de Devolu��o / 3=Sim, Conforme NF Original
	If MV_PAR11 == 3				//NF DEVOLU��O 
		_qDevNF     := "("
		if MV_PAR05 == 4			//Valor NET
			_qDevNF += " SELECT ISNULL(SUM(D2_TOTAL-D2_VALICM-D2_VALIMP6-D2_VALIMP5-D2_VALIMP4-D2_VALIMP3-D2_VALIMP2-D2_VALIMP1-D2_II),0) "
		elseif MV_PAR05 == 3		//Valor Total
			_qDevNF += " SELECT ISNULL(SUM(D2_TOTAL+D2_ICMSRET+D2_VALIPI+D2_SEGURO+D2_DESPESA+D2_VALFRE),0) "
		elseif MV_PAR05 == 2		//Quantidade
			_qDevNF += " SELECT ISNULL(SUM(D2_QUANT),0) "
		else						//Valor das Mercadorias
			_qDevNF += " SELECT ISNULL(SUM(D2_TOTAL),0) "
		endif
		_qDevNF     += " FROM "+RetSqlName("SD2")+" SD2 (NOLOCK) "
		_qDevNF     += " WHERE SD2.D2_FILIAL  = '"+FWFilial("SD2")+"' "
		_qDevNF     += "   AND SD2.D2_TIPO    = 'D' "
		_qDevNF     += "   AND SD2.D2_CLIENTE = SD1.D1_FORNECE "
		_qDevNF     += "   AND SD2.D2_LOJA    = SD1.D1_LOJA "
		_qDevNF     += "   AND SD2.D2_COD     = SD1.D1_COD "
		_qDevNF     += "   AND SD2.D2_NFORI   = SD1.D1_DOC   "
		_qDevNF     += "   AND SD2.D2_SERIORI = SD1.D1_SERIE "
		_qDevNF     += "   AND SD2.D2_ITEMORI = SD1.D1_ITEM  "
		_qDevNF     +=     _cFilSD2
		_qDevNF     += "   AND SD2.D_E_L_E_T_ = '' "
		_qDevNF     += ")"
	Else
		_qDevNF     := "0"
	EndIf
//Fim do tratamento para composi��o das devolu��es vendas vinculadas as entradas filtradas
//Defini��o do campo de valor a ser apresentado/totalizado
	if MV_PAR05 == 4		//Valor NET
		_cCpoSum := ", (("+IIF(MV_PAR12==2,"0","(D1_TOTAL-D1_VALICM-D1_VALIMP6-D1_VALIMP5-D1_VALIMP4-D1_VALIMP3-D1_VALIMP2-D1_VALIMP1)")+" - "+_qDevNF+" ) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR13+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR13+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D1_DTDIGIT AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
		_cCpSuDv := ", ((D2_TOTAL-D2_VALICM-D2_VALIMP6-D2_VALIMP5-D2_VALIMP4-D2_VALIMP3-D2_VALIMP2-D2_VALIMP1-D2_II) * (-1) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR13+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR13+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D2_EMISSAO AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
	elseif MV_PAR05 == 3		//Valor Total
		_cCpoSum := ", (("+IIF(MV_PAR12==2,"0","D1_VALBRUT")+" - "+_qDevNF+" ) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR13+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR13+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D1_DTDIGIT AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
		_cCpSuDv := ", ((D2_TOTAL+D2_ICMSRET+D2_VALIPI+D2_SEGURO+D2_DESPESA+D2_VALFRE) * (-1) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR13+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR13+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D2_EMISSAO AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
	elseif MV_PAR05 == 2	//Quantidade
		_cCpoSum := ", (CASE WHEN F4_ESTOQUE = 'S'                                       "
		_cCpoSum += "              THEN (("+IIF(MV_PAR12==2,"0","D1_QUANT")+" - "+_qDevNF+")) "
		_cCpoSum += "              ELSE 0 "
		_cCpoSum += "       END)   [VALOR]"
		_cCpSuDv := ", (D2_QUANT * (-1)) [VALOR]"
	else					//Valor das Mercadorias
		_cCpoSum := ", (("+IIF(MV_PAR12==2,"0","D1_TOTAL")+" - "+_qDevNF+" ) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR13+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR13+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D1_DTDIGIT AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
		_cCpSuDv := ", (D2_TOTAL * (-1) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR13+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR13+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D2_EMISSAO AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
	endif
//Fim da Defini��o do campo de valor a ser apresentado/totalizado
//Adequa��o dos filtros de usu�rio
	If !Empty(_cFilSD1)
		_cFilSD1 := "%AND "+_cFilSD1+"%"
	EndIf
	If Empty(_cFilSD1)
		_cFilSD1 := "%%"
	EndIf
	If !Empty(_cFilSF1)
		_cFilSF1 := "%AND "+_cFilSF1+"%"
	EndIf
	If Empty(_cFilSF1)
		_cFilSF1 := "%%"
	EndIf
	If !Empty(_cFilSD2)
		_cFilSD2 := "%AND "+_cFilSD2+"%"
	EndIf
	If Empty(_cFilSD2)
		_cFilSD2 := "%%"
	EndIf
	If !Empty(_cFilSB1)
		_cFilSB1 := "%AND "+_cFilSB1+"%"
	EndIf
	If Empty(_cFilSB1)
		_cFilSB1 := "%%"
	EndIf
	If !Empty(_cFilSA2)
		_cFilSA2 := "%AND "+_cFilSA2+"%"
	EndIf
	If Empty(_cFilSA2)
		_cFilSA2 := "%%"
	EndIf
	If !Empty(_cFilSF4)
		_cFilSF4 := "%AND "+_cFilSF4+"%"
	EndIf
	If Empty(_cFilSF4)
		_cFilSF4 := "%%"
	EndIf
//Fim da adequa��o dos filtros dos usu�rios
//Defini��o da ordem de apresenta��o das informa��es
	/*
	If oReport:Section(1):GetOrder() == 1			//Ordem por Grupo+Produto
		_cOrder := IIF(MV_PAR16==2,"MEDIA DESC, ","")+"B1_GRUPO, B1_COD , B1_DESC"
	ElseIf oReport:Section(1):GetOrder() == 2		//Ordem por Grupo+Descri��o
		_cOrder := "IIF(MV_PAR16==2,"MEDIA DESC, ","")+B1_GRUPO, B1_DESC, B1_COD "
	Else
		_cOrder := "IIF(MV_PAR16==2,"MEDIA DESC, ","")+B1_GRUPO, B1_COD , B1_DESC"
	EndIf
	*/
//Fim da Defini��o da ordem de apresenta��o das informa��es
//Defini��o das colunas de datas (M�s/Ano) NO ARRAY
	_dData   := MV_PAR03
	if !empty(_dData)
		While SubStr(DTOS(_dData),1,6) <= SubStr(DTOS(MV_PAR04),1,6)
			If !Empty(_dData)
				_cMesAno  := "["+SubStr(DTOS(_dData),1,6)+"]"
				_cCMesAno := SubStr(UPPER(cMonth(_dData)),1,3)+"_"+SubStr(DTOS(_dData),1,4)
				_nFator   := 1			//1 + &("MV_PAR"+StrZero(7+Val(SubStr(_cMesAno,6,2)),2)) / 100
				AADD( _aCols, {	_cMesAno                           , ;
								"(IsNull("+_cMesAno+",0)*" + cValToChar(_nFator) + ") "+_cCMesAno, ;
								SubStr(DTOC(_dData),4)             , ;
								_cCMesAno                          } )
			EndIf
			_dData   := LastDay(_dData,0)+1
		EndDo
	else
		_dData := LastDay(dDataBase,0)+1
	endif
//Fim Defini��o das colunas de datas (M�s/Ano)
//Defini��o das colunas de datas (M�s/Ano) NO RELAT�RIO com impacto nos totais, inclusive
	If Len(_aCols) == 0
		MsgStop("Nenhuma data selecionada!",_cRotina+"_003")
		return
	Else
		If MV_PAR17 == 2	//Sim = Organiza os per�odos por meses+ano (para compara��o de mesmo mes entre anos distintos)
			_aCols := aSort(_aCols,,, { |x, y| SubStr(x[01],6,2)+SubStr(x[01],2,4) < SubStr(y[01],6,2)+SubStr(y[01],2,4) })
		EndIf
		//Definicao das mascaras dos campos de valores
			_cMasc    := ""
			_cTam     := ""
			_cCpoRon  := ""
			_cPerTot  := ""
			_nPerTot  := 0
			_aPerTot  := {}
			if MV_PAR05 == 4		//Valor NET
				_cMasc   := "@E 999,999,999,999.99"
				_cTam    := "28"
				_cCpoRon := "D1_TOTAL"
			elseif MV_PAR05 == 3		//Valor Total
				_cMasc   := "@E 999,999,999,999.99"
				_cTam    := "28"
				_cCpoRon := "D1_VALBRUT"
			elseif MV_PAR05 == 2	//Quantidade
				_cMasc   := "@E 999,999,999,999.99"
				_cTam    := "28"
				_cCpoRon := "D1_QUANT"
			else					//Valor das Mercadorias
				_cMasc   := "@E 999,999,999,999.99"
				_cTam    := "28"
				_cCpoRon := "D1_TOTAL"
			endif
		//Fim da Definicao das mascaras dos campos de valores
		//Inclus�o dos campos definidos pelo usu�rio na Query e defini��o da ordem din�mica e sub-totais din�micos para o relat�rio
		for _x := 1 to len(_aCols)
			//Sub-Totaliza��o por per�odo
			If MV_PAR17 == 2	//Sim = Organiza os per�odos por meses+ano (para compara��o de mesmo mes entre anos distintos)
				If _x > 1 .AND. len(_aCols) > 12 .AND. SubStr(_aCols[_x][03],1,2) <> SubStr(_aCols[_x-1][03],1,2)
					AADD(_aPerTot,{_x, "MES"+SubStr(_aCols[_x-1][03],1,2), IIF(_nPerTot == 2, "PMES"+SubStr(_aCols[_x-1][03],1,2), ""), _aCols[_x-2][04], _aCols[_x-1][04]})
					&('TRCell():New(oSection,"MES'+SubStr(_aCols[_x-1][03],1,2)+'", "'+(_cSD1TMP)+'"/*Tabela*/,"M�dia M�s '+SubStr(_aCols[_x-1][03],1,2)+'","'+_cMasc+'" ,'+_cTam+' ,/*lPixel*/,{|| Round(('+_cPerTot+')/'+cValToChar(_nPerTot)+',TamSx3("'+_cCpoRon+'")[02]) })')
					If _nPerTot == 2
						&('TRCell():New(oSection,"PMES'+SubStr(_aCols[_x-1][03],1,2)+'", "'+(_cSD1TMP)+'"/*Tabela*/,"% M�s '+SubStr(_aCols[_x-1][03],1,2)+'","@E 99,999.99" ,10 ,/*lPixel*/,{|| Round(IIF('+_aCols[_x-2][04]+' > 0 .AND. '+_aCols[_x-1][04]+' > 0, ((('+_aCols[_x-1][04]+'/'+_aCols[_x-2][04]+')-1)*100), IIF('+_aCols[_x-1][04]+' > 0, 100, IIF(('+_aCols[_x-2][04]+'+'+_aCols[_x-1][04]+') == 0, 0, -100))), 2) })')
					EndIf
					_nPerTot := 0
					_cPerTot := ""
				EndIf
				If !Empty(_cPerTot)
					_cPerTot += " + "
				EndIf
				_cPerTot += (_cSD1TMP)+"->"+_aCols[_x][04]
				_nPerTot++
	        EndIf
			&('TRCell():New(oSection,"'+_aCols[_x][04]+'", "'+(_cSD1TMP)+'"/*Tabela*/,"'+_aCols[_x][03]+'","'+_cMasc+'" ,'+_cTam+' ,/*lPixel*/,{|| Round('+(_cSD1TMP)+'->'+_aCols[_x][04]+',TamSx3("'+_cCpoRon+'")[02]) })')
	        // Inclus�o de novos totais finais.
			If !Empty(_cTotal)
				_cTotal += "+"
			EndIf
			_cTotal += "(IsNull("+_aCols[_x][01]+",0) * " + IIF(!_lCMoeda;
																	,"1";
																	,IIF(VAL(_nVMoeda)<>0;
																			,_nVMoeda;
																			,"(SELECT TOP 1 (CASE WHEN "+MV_PAR13+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR13+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D1_DTDIGIT AND SM2.D_E_L_E_T_ = '')";
																		);
																) + ") "
			If !Empty(_cPivot)
				_cPivot += ", "
			EndIf
			_cField += ", " + _aCols[_x][02]
			_cFldDv += ", SUM(" + _aCols[_x][04] + ") " + _aCols[_x][04]
			_cPivot +=        _aCols[_x][01]
		next
		//Sub-Totaliza��o por per�odo
		If len(_aCols) > 12 .AND. MV_PAR17 == 2	//Sim = Organiza os per�odos por meses+ano (para compara��o de mesmo mes entre anos distintos)
			AADD(_aPerTot,{_x, "MES"+SubStr(_aCols[_x-1][03],1,2), IIF(_nPerTot == 2, "PMES"+SubStr(_aCols[_x-1][03],1,2), ""), _aCols[_x-2][04], _aCols[_x-1][04]})
			&('TRCell():New(oSection,"MES'+SubStr(_aCols[_x-1][03],1,2)+'", "'+(_cSD1TMP)+'"/*Tabela*/,"M�dia M�s '+SubStr(_aCols[_x-1][03],1,2)+'","'+_cMasc+'" ,'+_cTam+' ,/*lPixel*/,{|| Round(('+_cPerTot+')/'+cValToChar(_nPerTot)+',TamSx3("'+_cCpoRon+'")[02]) })')
			If _nPerTot == 2
				&('TRCell():New(oSection,"PMES'+SubStr(_aCols[_x-1][03],1,2)+'", "'+(_cSD1TMP)+'"/*Tabela*/,"% M�s '+SubStr(_aCols[_x-1][03],1,2)+'","@E 99,999.99" ,10 ,/*lPixel*/,{|| Round(IIF('+_aCols[_x-2][04]+' > 0 .AND. '+_aCols[_x-1][04]+' > 0, ((('+_aCols[_x-1][04]+'/'+_aCols[_x-2][04]+')-1)*100), IIF('+_aCols[_x-1][04]+' > 0, 100, IIF(('+_aCols[_x-2][04]+'+'+_aCols[_x-1][04]+') == 0, 0, -100))), 2) })')
			EndIf
        EndIf
		if MV_PAR05 == 4		//Valor NET
			TRCell():New(oSection,"TOTAL", (_cSD1TMP)/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD1TMP)->TOTAL,TamSx3("D1_TOTAL"  )[02]) })// Valor NET
		elseif MV_PAR05 == 3		//Valor Total
			TRCell():New(oSection,"TOTAL", (_cSD1TMP)/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD1TMP)->TOTAL,TamSx3("D1_VALBRUT")[02]) })// Valor Total
		elseif MV_PAR05 == 2	//Quantidade
			TRCell():New(oSection,"TOTAL", (_cSD1TMP)/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD1TMP)->TOTAL,TamSx3("D1_QUANT"  )[02]) })// Quantidade
		else					//Valor das Mercadorias
			TRCell():New(oSection,"TOTAL", (_cSD1TMP)/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD1TMP)->TOTAL,TamSx3("D1_TOTAL"  )[02]) })// Valor das Mercadorias
		endif
		If !Empty(_cTotal)
			_cMedia := "("+_cTotal+") / "+cValToChar(Len(_aCols))
		EndIf
		If Empty(_cMedia)
			_cMedia := "0"
		EndIf
		if MV_PAR05 == 4		//Valor NET
			TRCell():New(oSection,"MEDIA", (_cSD1TMP)/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD1TMP)->MEDIA,TamSx3("D1_TOTAL"  )[02]) })// Valor NET
		elseif MV_PAR05 == 3		//Valor Total
			TRCell():New(oSection,"MEDIA", (_cSD1TMP)/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD1TMP)->MEDIA,TamSx3("D1_VALBRUT")[02]) })// Valor Total
		elseif MV_PAR05 == 2	//Quantidade
			TRCell():New(oSection,"MEDIA", (_cSD1TMP)/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD1TMP)->MEDIA,TamSx3("D1_QUANT"  )[02]) })// Quantidade
		else					//Valor das Mercadorias
			TRCell():New(oSection,"MEDIA", (_cSD1TMP)/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD1TMP)->MEDIA,TamSx3("D1_TOTAL"  )[02]) })// Valor das Mercadorias
		endif
	    // Inclus�o de novos totais.
		for _x := 1 to len(oSection:aCell)
			If !Empty(oSection:aCell[_x]:cAlias) .AND. AllTrim(oSection:aCell[_x]:cAlias) <> (_cSD1TMP)
				If aScan(_aCpos, AllTrim(oSection:aCell[_x]:cName)) == 0
					If oSection:aCell[_x]:lUserEnabled
						_cCpoSum += ", ISNULL(" + AllTrim(oSection:aCell[_x]:cName) + ","+IIF(TamSx3(AllTrim(oSection:aCell[_x]:cName))[03]=="N","0","''")+") " + AllTrim(oSection:aCell[_x]:cName)
						_cCpSuDv += ", ISNULL(" + AllTrim(oSection:aCell[_x]:cName) + ","+IIF(TamSx3(AllTrim(oSection:aCell[_x]:cName))[03]=="N","0","''")+") " + AllTrim(oSection:aCell[_x]:cName)
						_cField  += ", ISNULL(" + AllTrim(oSection:aCell[_x]:cName) + ","+IIF(TamSx3(AllTrim(oSection:aCell[_x]:cName))[03]=="N","0","''")+") " + AllTrim(oSection:aCell[_x]:cName)
						_cFldDv  += ", ISNULL(" + AllTrim(oSection:aCell[_x]:cName) + ","+IIF(TamSx3(AllTrim(oSection:aCell[_x]:cName))[03]=="N","0","''")+") " + AllTrim(oSection:aCell[_x]:cName)
					Else
						_cCpoSum += ", '' " + AllTrim(oSection:aCell[_x]:cName)
						_cCpSuDv += ", '' " + AllTrim(oSection:aCell[_x]:cName)
						_cField  += ", '' " + AllTrim(oSection:aCell[_x]:cName)
						_cFldDv  += ", '' " + AllTrim(oSection:aCell[_x]:cName)
					EndIf
				EndIf
				If oSection:aCell[_x]:lUserEnabled
					If !Empty(_cOrder)
						_cOrder += ", "
					EndIf
					_cOrder += AllTrim(oSection:aCell[_x]:cName)
					_nBreak++
					If _nTotBrk > 0 .AND. _nBreak <= _nTotBrk
						//Break dos campos segundo a sua ordem definida pelo usu�rio
						&("oBreak"+cValToChar(_nBreak)) := TRBreak():New(oSection,oSection:Cell(AllTrim(oSection:aCell[_x]:cName)),"Sub-Total - " + AllTrim(oSection:aCell[_x]:cTitle))
						//Sub-Totais - Soma das colunas de valores/quantidades
						If Len(_aCols) > 0
							for _k := 1 to len(_aCols)
								_nPos := aScan(_aPerTot,{|x| x[01] == _k})
								If _nPos > 0
									TRFunction():New(oSection:Cell(_aPerTot[_nPos][02]),"T_"+_aPerTot[_nPos][02],"SUM",&("oBreak"+cValToChar(_nBreak)),NIL,"@E 999,999,999,999.99",,.T.,.F.)
									If !Empty(_aPerTot[_nPos][03])
										TRFunction():New(oSection:Cell(_aPerTot[_nPos][03]),"T_"+_aPerTot[_nPos][03],"ONPRINT",&("oBreak"+cValToChar(_nBreak)),NIL,"@E 99,999.99",,.T.,.F.)
										&("oReport:GetFunction('T_"+_aPerTot[_nPos][03]+"'):SetFormula({|| IIF(oReport:GetFunction('T_"+_aPerTot[_nPos][04]+"'):uLastValue <> 0, (((oReport:GetFunction('T_"+_aPerTot[_nPos][05]+"'):uLastValue/oReport:GetFunction('T_"+_aPerTot[_nPos][04]+"'):uLastValue)-1)*100), IIF(oReport:GetFunction('T_"+_aPerTot[_nPos][05]+"'):uLastValue > 0, 100, 0)) })")
									EndIf
								EndIf
								TRFunction():New(oSection:Cell(_aCols[_k][03]),"T_"+_aCols[_k][04],"SUM",&("oBreak"+cValToChar(_nBreak)),NIL,"@E 999,999,999,999.99",,.T.,.F.)
							next
							_nPos := aScan(_aPerTot,{|x| x[01] == _k})
							If _nPos > 0
								TRFunction():New(oSection:Cell(_aPerTot[_nPos][02]),"T_"+_aPerTot[_nPos][02],"SUM",&("oBreak"+cValToChar(_nBreak)),NIL,"@E 999,999,999,999.99",,.T.,.F.)
								If !Empty(_aPerTot[_nPos][03])
									TRFunction():New(oSection:Cell(_aPerTot[_nPos][03]),"T_"+_aPerTot[_nPos][03],"ONPRINT",&("oBreak"+cValToChar(_nBreak)),NIL,"@E 99,999.99",,.T.,.F.)
									&("oReport:GetFunction('T_"+_aPerTot[_nPos][03]+"'):SetFormula({|| IIF(oReport:GetFunction('T_"+_aPerTot[_nPos][04]+"'):uLastValue <> 0, (((oReport:GetFunction('T_"+_aPerTot[_nPos][05]+"'):uLastValue/oReport:GetFunction('T_"+_aPerTot[_nPos][04]+"'):uLastValue)-1)*100), IIF(oReport:GetFunction('T_"+_aPerTot[_nPos][05]+"'):uLastValue > 0, 100, 0)) })")
								EndIf
							EndIf
							TRFunction():New(oSection:Cell("TOTAL"),"T_TOTAL","SUM",&("oBreak"+cValToChar(_nBreak)),NIL,"@E 999,999,999,999.99",,.T.,.F.)
							TRFunction():New(oSection:Cell("MEDIA"),"T_MEDIA","SUM",&("oBreak"+cValToChar(_nBreak)),NIL,"@E 999,999,999,999.99",,.T.,.F.)
						EndIf
					EndIf
				EndIf
			EndIf
			If _nTotBrk == 0
				//Sub-Totais - Soma das colunas de valores/quantidades
				If Len(_aCols) > 0
					for _k := 1 to len(_aCols)
						TRFunction():New(oSection:Cell(_aCols[_k][03]),"TG_"+_aCols[_k][04],"SUM")
						_nPos := aScan(_aPerTot,{|x| x[01] == _k})
						If _nPos > 0
							TRFunction():New(oSection:Cell(_aPerTot[_nPos][02]),"TG_"+_aPerTot[_nPos][02],"SUM")
							If !Empty(_aPerTot[_nPos][03])
								TRFunction():New(oSection:Cell(_aPerTot[_nPos][03]),"TG_"+_aPerTot[_nPos][03],"ONPRINT")
								&("oReport:GetFunction('TG_"+_aPerTot[_nPos][03]+"'):SetFormula({|| IIF(oReport:GetFunction('TG_"+_aPerTot[_nPos][04]+"'):uLastValue <> 0, (((oReport:GetFunction('TG_"+_aPerTot[_nPos][05]+"'):uLastValue/oReport:GetFunction('TG_"+_aPerTot[_nPos][04]+"'):uLastValue)-1)*100), IIF(oReport:GetFunction('TG_"+_aPerTot[_nPos][05]+"'):uLastValue > 0, 100, 0)) })")
							EndIf
						EndIf
					next
					_nPos := aScan(_aPerTot,{|x| x[01] == _k})
					If _nPos > 0
						TRFunction():New(oSection:Cell(_aPerTot[_nPos][02]),"TG_"+_aPerTot[_nPos][02],"SUM")
						If !Empty(_aPerTot[_nPos][03])
							TRFunction():New(oSection:Cell(_aPerTot[_nPos][03]),"TG_"+_aPerTot[_nPos][03],"ONPRINT")
							&("oReport:GetFunction('TG_"+_aPerTot[_nPos][03]+"'):SetFormula({|| IIF(oReport:GetFunction('TG_"+_aPerTot[_nPos][04]+"'):uLastValue <> 0, (((oReport:GetFunction('TG_"+_aPerTot[_nPos][05]+"'):uLastValue/oReport:GetFunction('TG_"+_aPerTot[_nPos][04]+"'):uLastValue)-1)*100), IIF(oReport:GetFunction('TG_"+_aPerTot[_nPos][05]+"'):uLastValue > 0, 100, 0)) })")
						EndIf
					EndIf
					TRFunction():New(oSection:Cell("TOTAL"),"T_TOTAL","SUM")
					TRFunction():New(oSection:Cell("MEDIA"),"T_MEDIA","SUM")
				EndIf
			EndIf
		next
	EndIf
//Fim da Defini��o das colunas de datas (M�s/Ano) NO RELAT�RIO com impacto nos totais, inclusive
//Tratamento final das vari�veis que carregam os campos din�micos, para posterior uso no SQL Embended
	_cTotal  := ", ("+_cTotal+") [TOTAL]"
	_cMedia  := ", ("+_cMedia+") [MEDIA]"
	_cCpoSum := "%" + _cCpoSum + "%"
	_cCpSuDv := "%" + _cCpSuDv + "%"
	_cField  := "%" + _cField  + _cTotal + _cMedia + "%"
	_cFldDv  := "%" + _cFldDv  + ", SUM(TOTAL) [TOTAL], SUM(MEDIA) [MEDIA]"  + "%"
	_cPivot  := "%" + _cPivot  + "%"
	_cGroup  := "%" + IIF(MV_PAR16==2,"MEDIA, ","") + "B1_FILIAL, " + _cOrder  + "%"
	_cOrder  := "%" + IIF(MV_PAR16==2,"MEDIA DESC, ","") + "B1_FILIAL, " + _cOrder  + "%"
//Fim do Tratamento final das vari�veis que carregam os campos din�micos, para posterior uso no SQL Embended
//Par�metros/configura��es espec�ficas da classe do relat�rio
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
//Fim da �rea de Par�metros/configura��es espec�ficas da classe do relat�rio
//Elimina��o dos filtros do usu�rio para evitar duplicidades na query, uma vez que j� estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
	For _x := 1 To Len(oSection:aUserFilter)
		oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
	Next
	oSection:CSQLEXP := ""
//Fim da Elimina��o dos filtros do usu�rio para evitar duplicidades na query, uma vez que j� estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
//Defini��o do Total Geral
	/*
	If Len(_aCols) > 0
		For _x := 1 To Len(_aCols)
			TRFunction():New(oSection:Cell(_aCols[_x][03]),NIL,"SUM")
		Next
	EndIf
	*/
//Fim da Defini��o do Total Geral
//Alinhamento a direita as colunas din�micas de valor
	If Len(_aCols) > 0
		For _x := 1 To Len(_aCols)
			oSection:Cell(_aCols[_x][03]):SetHeaderAlign("RIGHT")
		Next
		oSection:Cell("TOTAL"):SetHeaderAlign("RIGHT")
		oSection:Cell("MEDIA"):SetHeaderAlign("RIGHT")
	EndIf
//Fim do Alinhamento a direita as colunas din�micas de valor
//Troca descricao do total dos itens
	oReport:Section(1):SetTotalText("T O T A I S ")
//Fim da Troca descricao do total dos itens
//PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
	//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
		MakeSqlExpr(oReport:uParam)
	//MakeSqlExpr(cPerg)
		oSection:BeginQuery()
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//OBS. T�CNICA: QUANDO SE FIZER NECESS�RIO REALIZAR ALGUM AJUSTE NAS QUERYS, N�O ESQUECER DE AJUSTAR TODAS AS ABAIXO (NOS ELSEIF) //
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//Deduz Devolu��es? - 1=N�o / 2=Sim, Conforme NF de Devolu��o / 3=Sim, Conforme NF Original
		if MV_PAR11 <> 2		//Sem considerar devolu��es OU as devolu��es vinculadas aos documentos de Entrada do per�odo selecionado
			BeginSql alias _cSD1TMP
				SELECT B1_FILIAL %Exp:_cField%
				FROM (
						SELECT B1_FILIAL, SUBSTRING(F1_DTDIGIT,1,6) [ENTRADA]
								%Exp:_cCpoSum%
						FROM %table:SD1% SD1 (NOLOCK)
							INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
													//  AND SF4.F4_DUPLIC        = %Exp:'S'%
													  AND SF4.F4_CODIGO        = SD1.D1_TES
													  AND SF4.%NotDel%
													  %Exp:_cFilSF4%
							INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
													  AND SB1.B1_COD     BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
													  AND SB1.B1_COD           = SD1.D1_COD
													  AND SB1.%NotDel%
													  %Exp:_cFilSB1%
							INNER JOIN %table:SF1% SF1 (NOLOCK) ON SF1.F1_FILIAL = %xFilial:SF1%
													  AND SF1.F1_TIPO          = 'N'
													  AND SF1.F1_DTDIGIT BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
													  AND SF1.F1_DOC           = SD1.D1_DOC
													  AND SF1.F1_SERIE         = SD1.D1_SERIE
													  AND SF1.F1_FORNECE       = SD1.D1_FORNECE
													  AND SF1.F1_LOJA          = SD1.D1_LOJA
													  AND SF1.F1_TIPO          = SD1.D1_TIPO
													  AND SF1.F1_DTDIGIT       = SD1.D1_DTDIGIT
													  AND SF1.%NotDel%
													  %Exp:_cFilSF1%
							INNER JOIN %table:SA2% SA2 (NOLOCK) ON SA2.A2_FILIAL = %xFilial:SA2%
													  AND SA2.A2_COD     BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR09%
													  AND SA2.A2_LOJA    BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR10%
													  AND SA2.A2_COD           = SF1.F1_FORNECE
													  AND SA2.A2_LOJA          = SF1.F1_LOJA
													  AND SA2.%NotDel%
													  %Exp:_cFilSA2%
						WHERE SD1.D1_FILIAL  = %xFilial:SD1%
						  AND SD1.%NotDel%
						  %Exp:_cFilSD1%
					 ) TMP
				PIVOT ( SUM(TMP.VALOR)
							FOR TMP.ENTRADA IN (%Exp:_cPivot%)
					  )  AS PVT
				ORDER BY %Exp:_cOrder%
			EndSql
		else		//Considera devolu��es tidas no per�odo selecionado
			BeginSql alias _cSD1TMP
				SELECT B1_FILIAL %Exp:_cFldDv%
				FROM (
							SELECT B1_FILIAL %Exp:_cField%
							FROM (
									SELECT B1_FILIAL, SUBSTRING(F1_DTDIGIT,1,6) [ENTRADA]
											%Exp:_cCpoSum%
									FROM %table:SD1% SD1 (NOLOCK)
										INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
																//  AND SF4.F4_DUPLIC        = %Exp:'S'%
																  AND SF4.F4_CODIGO        = SD1.D1_TES
																  AND SF4.%NotDel%
																  %Exp:_cFilSF4%
										INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
																  AND SB1.B1_COD     BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
																  AND SB1.B1_COD           = SD1.D1_COD
																  AND SB1.%NotDel%
																  %Exp:_cFilSB1%
										INNER JOIN %table:SF1% SF1 (NOLOCK) ON SF1.F1_FILIAL = %xFilial:SF1%
																  AND SF1.F1_TIPO          = 'N'
																  AND SF1.F1_DTDIGIT BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
																  AND SF1.F1_DOC           = SD1.D1_DOC
																  AND SF1.F1_SERIE         = SD1.D1_SERIE
																  AND SF1.F1_FORNECE       = SD1.D1_FORNECE
																  AND SF1.F1_LOJA          = SD1.D1_LOJA
																  AND SF1.F1_TIPO          = SD1.D1_TIPO
																  AND SF1.F1_DTDIGIT       = SD1.D1_DTDIGIT
																  AND SF1.%NotDel%
																  %Exp:_cFilSF1%
										INNER JOIN %table:SA2% SA2 (NOLOCK) ON SA2.A2_FILIAL = %xFilial:SA2%
																  AND SA2.A2_COD     BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR09%
																  AND SA2.A2_LOJA    BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR10%
																  AND SA2.A2_COD           = SF1.F1_FORNECE
																  AND SA2.A2_LOJA          = SF1.F1_LOJA
																  AND SA2.%NotDel%
																  %Exp:_cFilSA2%
									WHERE SD1.D1_FILIAL  = %xFilial:SD1%
									  AND SD1.%NotDel%
									  %Exp:_cFilSD1%
								 ) TMP
							PIVOT ( SUM(TMP.VALOR)
										FOR TMP.ENTRADA IN (%Exp:_cPivot%)
								  )  AS PVTl
				
						UNION ALL
				
							SELECT B1_FILIAL %Exp:_cField%
							FROM (
									SELECT B1_FILIAL, SUBSTRING(D2_EMISSAO,1,6) [ENTRADA]
											%Exp:_cCpSuDv%
									FROM %table:SD2% SD2 (NOLOCK)
										INNER JOIN %table:SD1% SD1 (NOLOCK) ON SD1.D1_FILIAL = %xFilial:SD1%
																  AND SD1.D1_TIPO          = 'N'
																  AND SD1.D1_DOC           = SD2.D2_NFORI
																  AND SD1.D1_SERIE         = SD2.D2_SERIORI
																  AND SD1.D1_ITEM          = SD2.D2_ITEMORI
																  AND SD1.D1_COD           = SD2.D2_COD
																  AND SD1.D1_FORNECE       = SD2.D2_CLIENTE
																  AND SD1.D1_LOJA          = SD2.D2_LOJA
																  AND SD1.%NotDel%
																  %Exp:_cFilSD1%
										INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
																 // AND SF4.F4_DUPLIC        = %Exp:'S'%
																  AND SF4.F4_CODIGO        = SD1.D1_TES
																  AND SF4.%NotDel%
																  %Exp:_cFilSF4%
										INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
													  			  AND SB1.B1_COD           = SD1.D1_COD
																  AND SB1.%NotDel%
																  %Exp:_cFilSB1%
										INNER JOIN %table:SF1% SF1 (NOLOCK) ON SF1.F1_FILIAL = %xFilial:SF1%
																  AND SF1.F1_DOC           = SD1.D1_DOC
																  AND SF1.F1_SERIE         = SD1.D1_SERIE
																  AND SF1.F1_FORNECE       = SD1.D1_FORNECE
																  AND SF1.F1_LOJA          = SD1.D1_LOJA
																  AND SF1.F1_TIPO          = SD1.D1_TIPO
																  AND SF1.F1_DTDIGIT       = SD1.D1_DTDIGIT
																  AND SF1.%NotDel%
																  %Exp:_cFilSF1%
										INNER JOIN %table:SA2% SA2 (NOLOCK) ON SA2.A2_FILIAL = %xFilial:SA2%
																  AND SA2.A2_COD           = SF1.F1_FORNECE
																  AND SA2.A2_LOJA          = SF1.F1_LOJA
																  AND SA2.%NotDel%
																  %Exp:_cFilSA2%
									WHERE SD2.D2_FILIAL        = %xFilial:SD2%
									  AND (SD2.D2_TIPO         = %Exp:'D'% OR SD2.D2_TIPO  = %Exp:'B'%)
									  AND SD2.D2_NFORI        <> %Exp:''%
									  AND SD2.D2_EMISSAO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
									  AND SD2.D2_COD     BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
									  AND SD2.D2_CLIENTE BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR09%
									  AND SD2.D2_LOJA    BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR10%
									  AND SD2.%NotDel%
									  %Exp:_cFilSD2%
								 ) TMP
							PIVOT ( SUM(TMP.VALOR)
										FOR TMP.ENTRADA IN (%Exp:_cPivot%)
								  )  AS PVT
					) TOTCONC
				GROUP BY %Exp:_cGroup%
				ORDER BY %Exp:_cOrder%
			EndSql
		endif
		oSection:EndQuery()
		//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",oSection:CQUERY)
//FIM DO PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
//Envia o relat�rio para a tela/impressora
	oSection:Print()
return
/*/{Protheus.doc} ValidPerg (RFATR035)
@description Verifica se as perguntas existem na SX1. Caso n�o existam, as cria.
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 06/02/2015
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	Local _aArea := GetArea()
	Local _aTam  := {}
	Local aRegs := {}
	Local i      := 0
	Local j      := 0

	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	cPerg  := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam  := TamSx3("B1_COD"    )
	AADD(aRegs,{cPerg,"01","Do Produto?"             ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","","SB1"   ,"",""})
	AADD(aRegs,{cPerg,"02","Ao Produto?"             ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","","SB1"   ,"",""})
	_aTam  := TamSx3("F1_DTDIGIT")
	AADD(aRegs,{cPerg,"03","Da Dt. Entrada?"         ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par03",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","",""      ,"",""})
	AADD(aRegs,{cPerg,"04","At� a Dt. Entrada?"      ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"05","Tipo de Informa��o?"     ,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par05","Vlr. Mercadorias" ,"","","","","Quantidade"	    ,"","","","","Vlr. Total"		,"","","","","Valor NET","","","","","","","","",""      ,"",""})
	AADD(aRegs,{cPerg,"06","N�veis para Sub-Totais?" ,"","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","Positivo()","mv_par06",""                 ,"","","","",""				,"","","","",""	   				,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSx3("A2_COD"    )
	AADD(aRegs,{cPerg,"07","Do Fornecedor?"			 ,"","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par07",""                 ,"","","","",""				,"","","","",""	   				,"","","","",""         ,"","","","","","","","","SA1"   ,"",""})
	_aTam  := TamSx3("A2_LOJA"   )
	AADD(aRegs,{cPerg,"08","Da Loja?"				 ,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSx3("A2_COD"    )
	AADD(aRegs,{cPerg,"09","Ao Fornecedor?"			 ,"","","mv_ch9",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par09",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","","SA1"   ,"",""})
	_aTam  := TamSx3("A2_LOJA"   )
	AADD(aRegs,{cPerg,"10","At� a Loja?"			 ,"","","mv_cha",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par10",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"11","Inclui Devolu��o?"		 ,"","","mv_chb",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par11","N�o"              ,"","","","","Sim - NF Devol" ,"","","","","Sim - NF Origem"	,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"12","Apenas as Devolu��es?"	 ,"","","mv_chc",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par12","N�o"              ,"","","","","Sim"            ,"","","","",""	                ,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"13","Qual Moeda?"			 ,"","","mv_chd",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par13",AllTrim(SuperGetMv("MV_MOEDA1",,"Real")),"","","","",AllTrim(SuperGetMv("MV_MOEDA2",,"D�lar")),"","","","",AllTrim(SuperGetMv("MV_MOEDA3",,"Euro")),"","","","",AllTrim(SuperGetMv("MV_MOEDA4",,"Iene")),"","","","",AllTrim(SuperGetMv("MV_MOEDA5",,"Peso")),"","","",""   ,"",""})
	_aTam  := {08,00,"D"}
	AADD(aRegs,{cPerg,"14","Data para convers�o?"	 ,"","","mv_che",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par14",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"15","Data da Moeda?"          ,"","","mv_chf",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par15","Data Informada"   ,"","","","","Emiss�o Docto." ,"","","","",""                 ,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"16","Ordena pela M�dia?"      ,"","","mv_chg",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par16","N�o"              ,"","","","","Sim"            ,"","","","",""	          		,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"17","Compara Per�odos?"	     ,"","","mv_chh",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par17","N�o"              ,"","","","","Sim"            ,"","","","",""	          		,"","","","",""         ,"","","","","","","","",""      ,"",""})
	for i := 1 to len(aRegs)
		If !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
			for j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Else
					Exit
				EndIf
			next
			(_cAliasSX1)->(MsUnLock())
		EndIf
	next
	RestArea(_aArea)
return