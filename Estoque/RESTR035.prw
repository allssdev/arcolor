#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RESTR035
@description Relatorio de custo dos produtos FATURADOS por periodo, mes a mes, baseado nos Documentos de Sa�da. O relat�rio apresentar� e somar� quantidades ou custos de vendas, conforme parametriza��o do usu�rio. Tamb�m conforme parametriza��o, o relat�rio apresentar� Somente Vendas, Somente o que n�o for Venda ou Ambos. Al�m disso, tamb�m conforme parametriza��o, o relat�rio abate ou n�o as devolu��es de vendas.
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 03/03/2020
@version 1.0
@type function
@history 03/03/2020, Anderson C. P. Coelho (ALLSS Solu��es em Sistemas), Relat�rio "RFATR035" clonado, gerando este aqui, e sendo incrementada a op��o de extra��o do relat�rio por Custo (op��o 2 do relat�rio). A Quantidade (antiga op��o 2 do relat�rio) passou a ser acess�vel pela op��o 5.
@see https://allss.com.br
/*/
user function RESTR035()
	private oReport
	private oSection
	private _cRotina  := "RESTR035"
	private cPerg     := _cRotina
	private _cSD2TMP  := GetNextAlias()
	private _cFormTit := "" //_cFormTit := '"Relat�rio de Custo dos Produtos FATURADOS por Per�odo ("+IIF(MV_PAR33==2,"SOMENTE",IIF(MV_PAR32==1,"SEM","COM"))+" DEVOLU��ES) - em "+SuperGetMV("MV_MOEDAP"+MV_PAR34,,"Reais")'
	private aRegs     := {}
	private _aCpos    := {}
	private _lMoeda   := .F.
	if FindFunction("TRepInUse") .And. TRepInUse()
		ValidPerg()
		if !Pergunte(cPerg,.T.)
			return
		endif
		_cFormTit := '"Relat�rio de Custo dos Produtos FATURADOS por Per�odo ("+IIF(MV_PAR33==2,"SOMENTE",IIF(MV_PAR32==1,"SEM","COM"))+" DEVOLU��ES) - em "+SuperGetMV("MV_MOEDAP"+MV_PAR34,,"Reais")'
		if empty(MV_PAR34)
			MV_PAR34 := "1"
		endif
		MV_PAR34 := IIF(ValType(MV_PAR34)=="N",cValToChar(MV_PAR34),MV_PAR34)
		if Select(_cSD2TMP) > 0
			(_cSD2TMP)->(dbCloseArea())
		endif
		//Tratamento de permiss�o para emiss�o do relat�rio por valor
			if !__cUserId$"|000000|000154|000206|000271|000273|000270|000019|000045|000046|000047|" .AND. !__cUserId$SuperGetMv("MV_USRVLFT",,"|000000|")
				MsgStop("Aten��o! Emiss�o do relat�rio em valor n�o autorizada. Sendo assim, a emiss�o do relat�rio ser� abortada!",_cRotina+"_004")
				return
			endif
		//Fim do tratamento de permiss�o para emiss�o do relat�rio por valor
		oReport  := ReportDef()
		oReport:PrintDialog()
		if Select(_cSD2TMP) > 0
			(_cSD2TMP)->(dbCloseArea())
		endif
	endif
return
/*/{Protheus.doc} ReportDef (RESTR035)
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
		If Empty(MV_PAR34)
			MV_PAR34 := "1"
		EndIf
		MV_PAR34 := IIF(ValType(MV_PAR34)=="N",cValToChar(MV_PAR34),MV_PAR34)
	//Fim da convers�o de tipo do par�metro de devolu��es
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
	oSection := TRSection():New(oReport,"CUSTO DE ITENS FATURADOS - QTD. E CUSTO",{"SD1","SD2","SF2","SB1","SA1","SA3","SF4"},_aOrd/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)

	//Identifica��o dos campos em uso, mas identificarmos depois os campos adicionados pelo usu�rio, para que possamos o incluir na query.
	/*_aCpos := {	"B1_GRUPO",;
				"B1_TIPO" ,;
				"B1_COD"  ,;
				"B1_DESC" ,;
				"B1_UM"   }*/
	//Defini��o das colunas do relat�rio
	TRCell():New(oSection,"B1_GRUPO"    ,"SB1"/*Tabela*/,RetTitle("B1_GRUPO"  ),PesqPict  ("SB1","B1_GRUPO"),TamSx3("B1_GRUPO")[1],/*lPixel*/,{|| (_cSD2TMP)->B1_GRUPO 		})	// Grupo de Produto
	TRCell():New(oSection,"B1_COD"      ,"SB1"/*Tabela*/,RetTitle("B1_COD"    ),PesqPict  ("SB1","B1_COD"  ),TamSx3("B1_COD"  )[1],/*lPixel*/,{|| (_cSD2TMP)->B1_COD    	})	// Codigo do Produto
	TRCell():New(oSection,"B1_DESC"     ,"SB1"/*Tabela*/,RetTitle("B1_DESC"   ),PesqPict  ("SB1","B1_DESC" ),TamSx3("B1_DESC" )[1],/*lPixel*/,{|| (_cSD2TMP)->B1_DESC		})	// Descricao do Produto
	TRCell():New(oSection,"B1_UM"       ,"SB1"/*Tabela*/,RetTitle("B1_UM"	  ),PesqPict  ("SB1","B1_UM"   ),TamSx3("B1_UM"   )[1],/*lPixel*/,{|| (_cSD2TMP)->B1_UM         })	// Unidade de Medida

	//oBreak := TRBreak():New(oSection,oSection:Cell("B1_COD"),"Sub-Total Produtos")
	//TRFunction():New(oSection:Cell("D2_QUANT"  ),NIL,"SUM",oBreak)
	//TRFunction():New(oSection:Cell("D2_CUSTO1" ),NIL,"SUM",oBreak)

	//������������������������������������������������������������������������Ŀ
	//� Troca descricao do total dos itens                                     �
	//��������������������������������������������������������������������������
	//oReport:Section(1):SetTotalText("T O T A I S ")
	//Efetuo o relacionamento entre as tabelas
	//TRPosition():New(oSection,"SF2",1,{|| FWFilial("SF2") + SD2->D2_DOC+SD2->D2_SERIE})
	//TRPosition():New(oSection,"SB1",1,{|| FWFilial("SB1") + SD2->D2_COD              })
	//oReport:Section(2):SetEdit(.F.) 
	//oReport:Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query

	//������������������������������������������������������������������������Ŀ
	//� Alinhamento a direita as colunas de valor                              �
	//��������������������������������������������������������������������������
	//oSection:Cell("D2_QUANT"  ):SetHeaderAlign("RIGHT")
	//oSection:Cell("D2_CUSTO1" ):SetHeaderAlign("RIGHT")
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
return oReport
/*/{Protheus.doc} PrintRel (RESTR035)
@description Processamento das informa��es para impress�o (Print).
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 06/02/2015
@version 1.0
@type function
@see https://allss.com.br
/*/
static function PrintRel()
//Declara��o das vari�veis
	//Local oSection := oReport:Section(1)
	Local _cCpoSum := ""
	Local _cCpSuDv := ""
	Local _cFlOper := ""
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
	Local _cTpOper := FormatIn(SuperGetMv("MV_FATOPER",,"01|ZZ|9"),"|")
	Local _cFilSF2 := oSection:GetSqlExp("SF2")
	Local _cFilSD2 := oSection:GetSqlExp("SD2")
	Local _cFilSB1 := oSection:GetSqlExp("SB1")
	Local _cFilSA1 := oSection:GetSqlExp("SA1")
	Local _cFilSA3 := oSection:GetSqlExp("SA3")
	Local _cFilSF4 := oSection:GetSqlExp("SF4")
	Local _cFilSD1 := oSection:GetSqlExp("SD1")
	Local _dData   := STOD("")
	Local _aCols   := {}
	Local _lCMoeda := .F.
	Local _nVMoeda := 0
	Local _nBreak  := 0
	Local _nFator  := 0
	Local _nPerTot := 0
//	Local _p       := 0
	Local _nTotBrk := MV_PAR07		//Total de Breaks permitidos (n�veis)
//Fim da declara��o de vari�veis
//Adequa��o do t�tulo do relat�rio
//	oReport:cDescription := oReport:cRealTitle := oReport:cTitle := cTitulo := &(_cFormTit)
//Fim da Adequa��o do t�tulo do relat�rio
//An�lise do preenchimento dos par�metros
	If MV_PAR01 > MV_PAR02 .OR. MV_PAR03 > MV_PAR04 .OR. MV_PAR20 > MV_PAR22 .OR. MV_PAR21 > MV_PAR23 .OR. MV_PAR24 > MV_PAR25 .OR. MV_PAR26 > MV_PAR27 .OR. (MV_PAR33 == 2 .AND. MV_PAR32 == 1)
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
// Verifica a moeda selecionada
	If MV_PAR05 <> nil
		If Empty(MV_PAR34)
			MV_PAR34 := "1"
		EndIf
		MV_PAR34 := IIF(ValType(MV_PAR34)=="N",cValToChar(MV_PAR34),MV_PAR34)
		If Empty(MV_PAR34)
			MV_PAR34 := "1"
		ElseIf ValType(MV_PAR34) == "C" .AND. AllTrim(MV_PAR34) <> "1"
			_lCMoeda := .T.
		EndIf
		If _lCMoeda .AND. Empty(MV_PAR35)
			MV_PAR35 := dDataBase
		EndIf
		If _lCMoeda
			If MV_PAR36 == 1		//Data Informada para a Moeda no par�metro MV_PAR35 
				dbUseArea(	.T.,;
							"TOPCONN",;
							TcGenQry(,,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" (NOLOCK) WHERE M2_DATA = '"+DTOS(MV_PAR35)+"' AND D_E_L_E_T_ = '')"),;
							"SM2TMP",;
							.T.,;
							.F.)	
				dbSelectArea("SM2TMP")
				_nVMoeda := cValToChar(SM2TMP->MOEDA)
				dbSelectArea("SM2TMP")
				SM2TMP->(dbCloseArea())
				If VAL(_nVMoeda) == 0
					_lCMoeda := .F.
					MsgInfo("Aten��o! N�o foi localizada taxa para a moeda '"+UPPER(AllTrim(SuperGetMv("MV_MOEDA"+MV_PAR34,,"N�O LOCALIZADA")))+"' no dia "+DTOC(MV_PAR35)+", conforma par�metros informados. O relat�rio ser� emitido na moeda 1!",_cRotina+"_006")
				EndIf
			EndIf
		EndIf
	EndIf
//Fim da verifica��o da moeda 
//In�cio do tratamento para composi��o das devolu��es vendas vinculadas as sa�das filtradas
	//Deduz Devolu��es? - 1=N�o / 2=Sim, Conforme NF de Devolu��o / 3=Sim, Conforme NF Original
	If MV_PAR32 == 3				//NF DEVOLU��O 
		_qDevNF     := "("
		if MV_PAR05 == 5			//Quantidade
			_qDevNF += " SELECT ISNULL(SUM(D1_QUANT),0) "
		elseif MV_PAR05 == 4			//Valor NET
			_qDevNF += " SELECT ISNULL(SUM(D1_TOTAL-D1_VALICM-D1_VALIMP6-D1_VALIMP5-D1_VALIMP4-D1_VALIMP3-D1_VALIMP2-D1_VALIMP1-D1_II),0) "
		elseif MV_PAR05 == 3		//Valor Total
			_qDevNF += " SELECT ISNULL(SUM(D1_TOTAL+D1_ICMSRET+D1_VALIPI+D1_SEGURO+D1_DESPESA+D1_VALFRE),0) "
		elseif MV_PAR05 == 2		//Custo
			if MV_PAR34 == "1"
				_qDevNF += " SELECT ISNULL(SUM(D1_CUSTO),0) "
			else
				_qDevNF += " SELECT ISNULL(SUM(D1_CUSTO"+MV_PAR34+"),0) "
			endif
		else						//Valor das Mercadorias
			_qDevNF += " SELECT ISNULL(SUM(D1_TOTAL),0) "
		endif
		_qDevNF     += " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK) "
		_qDevNF     += " WHERE SD1.D1_FILIAL  = '"+FWFilial("SD1")+"' "
		_qDevNF     += "   AND SD1.D1_TIPO    = 'D' "
		_qDevNF     += "   AND SD1.D1_FORNECE = SD2.D2_CLIENTE "
		_qDevNF     += "   AND SD1.D1_LOJA    = SD2.D2_LOJA "
		_qDevNF     += "   AND SD1.D1_COD     = SD2.D2_COD "
		_qDevNF     += "   AND SD1.D1_NFORI   = SD2.D2_DOC   "
		_qDevNF     += "   AND SD1.D1_SERIORI = SD2.D2_SERIE "
		_qDevNF     += "   AND SD1.D1_ITEMORI = SD2.D2_ITEM  "
		_qDevNF     +=     _cFilSD1
		_qDevNF     += "   AND SD1.D_E_L_E_T_ = ''"
		_qDevNF     += ")"
	Else
		_qDevNF     := "0"
	EndIf
//Fim do tratamento para composi��o das devolu��es vendas vinculadas as sa�das filtradas
//Filtragens espec�ficas para as querys
	If SD2->(FieldPos("D2_TIPOPER"))<>0
/*
		If MV_PAR06 == 1
			_cFlOper := "% AND (SD2.D2_TIPOPER      IN " + _cTpOper + " OR SUBSTRING(SD2.D2_CF,2,3)     IN ('101','401','107','109','108','551'))%"
		ElseIf MV_PAR06 == 2
			_cFlOper := "% AND (SD2.D2_TIPOPER  NOT IN " + _cTpOper + " OR SUBSTRING(SD2.D2_CF,2,3) NOT IN ('101','401','107','109','108','551'))%"
		EndIf
*/
		If MV_PAR06 == 1
			_cFlOper := "% AND SD2.D2_TIPOPER      IN " + _cTpOper +"%"
		ElseIf MV_PAR06 == 2
			_cFlOper := "% AND SD2.D2_TIPOPER  NOT IN " + _cTpOper +"%"
		EndIf
	EndIf
	If SA1->(FieldPos("A1_CGCCENT"))<>0
		If !Empty(_cFilSA1)
			_cFilSA1 += " AND "
		EndIf
		_cFilSA1 += " SA1.A1_CGCCENT BETWEEN '"+MV_PAR26+"' AND '"+MV_PAR27+"'"
	EndIf
//Fim das Filtragens espec�fidas para as querys
/*
	If MV_PAR40 == 1	//Somente com financeiro
		_cFilSF4 := " SF4.F4_DUPLIC = 'S' "
	ElseIf MV_PAR06 == 2
		_cFilSF4 := " SF4.F4_DUPLIC = 'N' "
	EndIf
*/
//Defini��o do campo de valor a ser apresentado/totalizado
	if MV_PAR05 == 5		//Quantidade
		if SD2->(FieldPos("D2_SCOA"))<>0
			_cCpoSum := ", (CASE WHEN F4_ESTOQUE = 'S' OR (D2_TES = '601' AND D2_SCOA <> '') "
		else
			_cCpoSum := ", (CASE WHEN F4_ESTOQUE = 'S'                                       "
		endif
		_cCpoSum += "              THEN (("+IIF(MV_PAR33==2,"0","D2_QUANT")+" - "+_qDevNF+")) "
		_cCpoSum += "              ELSE 0 "
		_cCpoSum += "       END)   [VALOR]"
		_cCpSuDv := ", (D1_QUANT * (-1)) [VALOR]"
	elseif MV_PAR05 == 4		//Valor NET
		_cCpoSum := ", (("+IIF(MV_PAR33==2,"0","(D2_TOTAL-D2_VALICM-D2_VALIMP6-D2_VALIMP5-D2_VALIMP4-D2_VALIMP3-D2_VALIMP2-D2_VALIMP1)")+" - "+_qDevNF+" ) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D2_EMISSAO AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
		_cCpSuDv := ", ((D1_TOTAL-D1_VALICM-D1_VALIMP6-D1_VALIMP5-D1_VALIMP4-D1_VALIMP3-D1_VALIMP2-D1_VALIMP1-D1_II) * (-1) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D1_DTDIGIT AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
	elseif MV_PAR05 == 3		//Valor Total
		_cCpoSum := ", (("+IIF(MV_PAR33==2,"0","D2_VALBRUT")+" - "+_qDevNF+" ) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D2_EMISSAO AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
		_cCpSuDv := ", ((D1_TOTAL+D1_ICMSRET+D1_VALIPI+D1_SEGURO+D1_DESPESA+D1_VALFRE) * (-1) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D1_DTDIGIT AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
	elseif MV_PAR05 == 2	//Custo
		_cCpoSum := ", (("+IIF(MV_PAR33==2,"0","D2_CUSTO"+MV_PAR34)+" - "+_qDevNF+" ) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D2_EMISSAO AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
		if MV_PAR34 == "1"
			_cCpSuDv := ", (D1_CUSTO * (-1) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D1_DTDIGIT AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
		else
			_cCpSuDv := ", (D1_CUSTO"+MV_PAR34+" * (-1) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D1_DTDIGIT AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
		endif
	else					//Valor das Mercadorias
		_cCpoSum := ", (("+IIF(MV_PAR33==2,"0","D2_TOTAL" )+" - "+_qDevNF+" ) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D2_EMISSAO AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
		_cCpSuDv := ", (D1_TOTAL * (-1) * "+IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D1_DTDIGIT AND SM2.D_E_L_E_T_ = '')"))+") [VALOR]"
	endif
//Fim da Defini��o do campo de valor a ser apresentado/totalizado
//Adequa��o dos filtros de usu�rio
	If !Empty(_cFilSD2)
		If Empty(_cFlOper)
			_cFilSD2 := "%AND "+_cFilSD2+"%"
		Else
			_cFilSD2 := "%AND "+_cFilSD2+" "+StrTran(_cFlOper,"%","")+"%"
		EndIf
	Else
		_cFilSD2 := _cFlOper
	EndIf
	If Empty(_cFilSD2)
		_cFilSD2 := "%%"
	EndIf
	If !Empty(_cFilSF2)
		_cFilSF2 := "%AND "+_cFilSF2+"%"
	EndIf
	If Empty(_cFilSF2)
		_cFilSF2 := "%%"
	EndIf
	If !Empty(_cFilSD1)
		_cFilSD1 := "%AND "+_cFilSD1+"%"
	EndIf
	If Empty(_cFilSD1)
		_cFilSD1 := "%%"
	EndIf
	If !Empty(_cFilSB1)
		_cFilSB1 := "%AND "+_cFilSB1+"%"
	EndIf
	If Empty(_cFilSB1)
		_cFilSB1 := "%%"
	EndIf
	If !Empty(_cFilSA1)
		_cFilSA1 := "%AND "+_cFilSA1+"%"
	EndIf
	If Empty(_cFilSA1)
		_cFilSA1 := "%%"
	EndIf
	If !Empty(_cFilSA3)
		_cFilSA3 := "%AND "+_cFilSA3+"%"
	EndIf
	If Empty(_cFilSA3)
		_cFilSA3 := "%%"
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
		_cOrder := IIF(MV_PAR37==2,"MEDIA DESC, ","")+"B1_GRUPO, B1_COD , B1_DESC"
	ElseIf oReport:Section(1):GetOrder() == 2		//Ordem por Grupo+Descri��o
		_cOrder := "IIF(MV_PAR37==2,"MEDIA DESC, ","")+B1_GRUPO, B1_DESC, B1_COD "
	Else
		_cOrder := "IIF(MV_PAR37==2,"MEDIA DESC, ","")+B1_GRUPO, B1_COD , B1_DESC"
	EndIf
	*/
//Fim da Defini��o da ordem de apresenta��o das informa��es
//Defini��o das colunas de datas (M�s/Ano) NO ARRAY
	_dData   := MV_PAR03
	While SubStr(DTOS(_dData),1,6) <= SubStr(DTOS(MV_PAR04),1,6)
		If !Empty(_dData)
			_cMesAno  := "["+SubStr(DTOS(_dData),1,6)+"]"
			_cCMesAno := SubStr(UPPER(cMonth(_dData)),1,3)+"_"+SubStr(DTOS(_dData),1,4)
			_nFator   := 1 + &("MV_PAR"+StrZero(7+Val(SubStr(_cMesAno,6,2)),2)) / 100
			AADD( _aCols, {	_cMesAno                           , ;
							"(IsNull("+_cMesAno+",0)*" + cValToChar(_nFator) + ") "+_cCMesAno, ;
							SubStr(DTOC(_dData),4)             , ;
							_cCMesAno                          } )
		EndIf
		_dData   := LastDay(_dData,0)+1
	EndDo
//Fim Defini��o das colunas de datas (M�s/Ano)
//Defini��o das colunas de datas (M�s/Ano) NO RELAT�RIO com impacto nos totais, inclusive
	If Len(_aCols) == 0
		MsgStop("Nenhuma data selecionada!",_cRotina+"_003")
		return
	Else
		If MV_PAR38 == 2	//Sim = Organiza os per�odos por meses+ano (para compara��o de mesmo mes entre anos distintos)
			_aCols := aSort(_aCols,,, { |x, y| SubStr(x[01],6,2)+SubStr(x[01],2,4) < SubStr(y[01],6,2)+SubStr(y[01],2,4) })
		EndIf
		//Definicao das mascaras dos campos de valores
			_cMasc    := ""
			_cTam     := ""
			_cCpoRon  := ""
			_cPerTot  := ""
			_nPerTot  := 0
			_aPerTot  := {}
			if MV_PAR05 == 5		//Quantidade
				_cMasc   := "@E 999,999,999,999.99"
				_cTam    := "28"
				_cCpoRon := "D2_QUANT"
			elseif MV_PAR05 == 4		//Valor NET
				_cMasc   := "@E 999,999,999,999.99"
				_cTam    := "28"
				_cCpoRon := "D2_TOTAL"
			elseif MV_PAR05 == 3		//Valor Total
				_cMasc   := "@E 999,999,999,999.99"
				_cTam    := "28"
				_cCpoRon := "D2_VALBRUT"
			elseif MV_PAR05 == 2	//Custo
				_cMasc   := "@E 999,999,999,999.99"
				_cTam    := "28"
				_cCpoRon := "D2_CUSTO"+MV_PAR34
			else					//Valor das Mercadorias
				_cMasc   := "@E 999,999,999,999.99"
				_cTam    := "28"
				_cCpoRon := "D2_TOTAL"
			endif
		//Fim da Definicao das mascaras dos campos de valores
		//Inclus�o dos campos definidos pelo usu�rio na Query e defini��o da ordem din�mica e sub-totais din�micos para o relat�rio
		for _x := 1 to len(_aCols)
			//Sub-Totaliza��o por per�odo
			If MV_PAR38 == 2	//Sim = Organiza os per�odos por meses+ano (para compara��o de mesmo mes entre anos distintos)
				If _x > 1 .AND. len(_aCols) > 12 .AND. SubStr(_aCols[_x][03],1,2) <> SubStr(_aCols[_x-1][03],1,2)
					AADD(_aPerTot,{_x, "MES"+SubStr(_aCols[_x-1][03],1,2), IIF(_nPerTot == 2, "PMES"+SubStr(_aCols[_x-1][03],1,2), ""), _aCols[_x-2][04], _aCols[_x-1][04]})
					&('TRCell():New(oSection,"MES'+SubStr(_aCols[_x-1][03],1,2)+'", "'+(_cSD2TMP)+'"/*Tabela*/,"M�dia M�s '+SubStr(_aCols[_x-1][03],1,2)+'","'+_cMasc+'" ,'+_cTam+' ,/*lPixel*/,{|| Round(('+_cPerTot+')/'+cValToChar(_nPerTot)+',TamSx3("'+_cCpoRon+'")[02]) })')
					If _nPerTot == 2
						&('TRCell():New(oSection,"PMES'+SubStr(_aCols[_x-1][03],1,2)+'", "'+(_cSD2TMP)+'"/*Tabela*/,"% M�s '+SubStr(_aCols[_x-1][03],1,2)+'","@E 99,999.99" ,10 ,/*lPixel*/,{|| Round(IIF('+_aCols[_x-2][04]+' > 0 .AND. '+_aCols[_x-1][04]+' > 0, ((('+_aCols[_x-1][04]+'/'+_aCols[_x-2][04]+')-1)*100), IIF('+_aCols[_x-1][04]+' > 0, 100, IIF(('+_aCols[_x-2][04]+'+'+_aCols[_x-1][04]+') == 0, 0, -100))), 2) })')
					EndIf
					_nPerTot := 0
					_cPerTot := ""
				EndIf
				If !Empty(_cPerTot)
					_cPerTot += " + "
				EndIf
				_cPerTot += (_cSD2TMP)+"->"+_aCols[_x][04]
				_nPerTot++
	        EndIf
			&('TRCell():New(oSection,"'+_aCols[_x][04]+'", "'+(_cSD2TMP)+'"/*Tabela*/,"'+_aCols[_x][03]+'","'+_cMasc+'" ,'+_cTam+' ,/*lPixel*/,{|| Round('+(_cSD2TMP)+'->'+_aCols[_x][04]+',TamSx3("'+_cCpoRon+'")[02]) })')
	        // Inclus�o de novos totais finais.
			If !Empty(_cTotal)
				_cTotal += "+"
			EndIf
			_cTotal += "IsNull("+_aCols[_x][01]+",0) * " + IIF(!_lCMoeda,"1",IIF(VAL(_nVMoeda)<>0,_nVMoeda,"(SELECT TOP 1 (CASE WHEN "+MV_PAR34+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR34+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" SM2 (NOLOCK) WHERE SM2.M2_DATA = D2_EMISSAO AND SM2.D_E_L_E_T_ = '')"))
			If !Empty(_cPivot)
				_cPivot += ", "
			EndIf
			_cField += ", " + _aCols[_x][02]
			_cFldDv += ", SUM(" + _aCols[_x][04] + ") " + _aCols[_x][04]
			_cPivot +=        _aCols[_x][01]
		next
		//Sub-Totaliza��o por per�odo
		If len(_aCols) > 12 .AND. MV_PAR38 == 2	//Sim = Organiza os per�odos por meses+ano (para compara��o de mesmo mes entre anos distintos)
			AADD(_aPerTot,{_x, "MES"+SubStr(_aCols[_x-1][03],1,2), IIF(_nPerTot == 2, "PMES"+SubStr(_aCols[_x-1][03],1,2), ""), _aCols[_x-2][04], _aCols[_x-1][04]})
			&('TRCell():New(oSection,"MES'+SubStr(_aCols[_x-1][03],1,2)+'", "'+(_cSD2TMP)+'"/*Tabela*/,"M�dia M�s '+SubStr(_aCols[_x-1][03],1,2)+'","'+_cMasc+'" ,'+_cTam+' ,/*lPixel*/,{|| Round(('+_cPerTot+')/'+cValToChar(_nPerTot)+',TamSx3("'+_cCpoRon+'")[02]) })')
			If _nPerTot == 2
				&('TRCell():New(oSection,"PMES'+SubStr(_aCols[_x-1][03],1,2)+'", "'+(_cSD2TMP)+'"/*Tabela*/,"% M�s '+SubStr(_aCols[_x-1][03],1,2)+'","@E 99,999.99" ,10 ,/*lPixel*/,{|| Round(IIF('+_aCols[_x-2][04]+' > 0 .AND. '+_aCols[_x-1][04]+' > 0, ((('+_aCols[_x-1][04]+'/'+_aCols[_x-2][04]+')-1)*100), IIF('+_aCols[_x-1][04]+' > 0, 100, IIF(('+_aCols[_x-2][04]+'+'+_aCols[_x-1][04]+') == 0, 0, -100))), 2) })')
			EndIf
        EndIf
		if MV_PAR05 == 5		//Quantidade
			TRCell():New(oSection,"TOTAL", (_cSD2TMP)/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->TOTAL,TamSx3("D2_QUANT"  )[02]) })// Quantidade
		elseif MV_PAR05 == 4		//Valor NET
			TRCell():New(oSection,"TOTAL", (_cSD2TMP)/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->TOTAL,TamSx3("D2_TOTAL"  )[02]) })// Valor NET
		elseif MV_PAR05 == 3		//Valor Total
			TRCell():New(oSection,"TOTAL", (_cSD2TMP)/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->TOTAL,TamSx3("D2_VALBRUT")[02]) })// Valor Total
		elseif MV_PAR05 == 2	//Custo
			TRCell():New(oSection,"TOTAL", (_cSD2TMP)/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->TOTAL,TamSx3("D2_CUSTO"+MV_PAR34)[02]) })// Custo
		else					//Valor das Mercadorias
			TRCell():New(oSection,"TOTAL", (_cSD2TMP)/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->TOTAL,TamSx3("D2_TOTAL"  )[02]) })// Valor das Mercadorias
		endif
		If !Empty(_cTotal)
			_cMedia := "("+_cTotal+") / "+cValToChar(Len(_aCols))
		EndIf
		If Empty(_cMedia)
			_cMedia := "0"
		EndIf
		if MV_PAR05 == 5		//Quantidade
			TRCell():New(oSection,"MEDIA", (_cSD2TMP)/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->MEDIA,TamSx3("D2_QUANT"  )[02]) })// Quantidade
		elseif MV_PAR05 == 4		//Valor NET
			TRCell():New(oSection,"MEDIA", (_cSD2TMP)/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->MEDIA,TamSx3("D2_TOTAL"  )[02]) })// Valor NET
		elseif MV_PAR05 == 3		//Valor Total
			TRCell():New(oSection,"MEDIA", (_cSD2TMP)/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->MEDIA,TamSx3("D2_VALBRUT")[02]) })// Valor Total
		elseif MV_PAR05 == 2	//Custo
			TRCell():New(oSection,"MEDIA", (_cSD2TMP)/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->MEDIA,TamSx3("D2_CUSTO"+MV_PAR34)[02]) })// Custo
		else					//Valor das Mercadorias
			TRCell():New(oSection,"MEDIA", (_cSD2TMP)/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSD2TMP)->MEDIA,TamSx3("D2_TOTAL"  )[02]) })// Valor das Mercadorias
		endif
	    // Inclus�o de novos totais.
		for _x := 1 to len(oSection:aCell)
			If !Empty(oSection:aCell[_x]:cAlias) .AND. AllTrim(oSection:aCell[_x]:cAlias) <> (_cSD2TMP)
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
	_cGroup  := "%" + IIF(MV_PAR37==2,"MEDIA, ","") + "B1_FILIAL, " + _cOrder  + "%"
	_cOrder  := "%" + IIF(MV_PAR37==2,"MEDIA DESC, ","") + "B1_FILIAL, " + _cOrder  + "%"
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
		if MV_PAR32 <> 2		//Sem considerar devolu��es OU as devolu��es vinculadas aos documentos de sa�da do per�odo selecionado
			BeginSql alias _cSD2TMP
				SELECT B1_FILIAL %Exp:_cField%
				FROM (
						SELECT B1_FILIAL, SUBSTRING(F2_EMISSAO,1,6) [EMISSAO]
								%Exp:_cCpoSum%
						FROM %table:SD2% SD2 (NOLOCK)
							INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
													//  AND SF4.F4_DUPLIC        = %Exp:'S'%
													  AND SF4.F4_CODIGO        = SD2.D2_TES
													  AND SF4.%NotDel%
													  %Exp:_cFilSF4%
							INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
													  AND SB1.B1_COD     BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
													  AND SB1.B1_COD           = SD2.D2_COD
													  AND SB1.%NotDel%
													  %Exp:_cFilSB1%
							INNER JOIN %table:SF2% SF2 (NOLOCK) ON SF2.F2_FILIAL = %xFilial:SF2%
													  AND SF2.F2_TIPO          = 'N'
													  AND SF2.F2_EMISSAO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
													  AND SF2.F2_VEND1   BETWEEN %Exp:MV_PAR24% AND %Exp:MV_PAR25%
													  AND SF2.F2_DOC           = SD2.D2_DOC
													  AND SF2.F2_SERIE         = SD2.D2_SERIE
													  AND SF2.F2_CLIENTE       = SD2.D2_CLIENTE
													  AND SF2.F2_LOJA          = SD2.D2_LOJA
													  AND SF2.F2_TIPO          = SD2.D2_TIPO
													  AND SF2.F2_EMISSAO       = SD2.D2_EMISSAO
													  AND SF2.%NotDel%
													  %Exp:_cFilSF2%
							INNER JOIN %table:SA1% SA1 (NOLOCK) ON SA1.A1_FILIAL = %xFilial:SA1%
													  AND SA1.A1_COD     BETWEEN %Exp:MV_PAR20% AND %Exp:MV_PAR22%
													  AND SA1.A1_LOJA    BETWEEN %Exp:MV_PAR21% AND %Exp:MV_PAR23%
													  AND SA1.A1_EST     BETWEEN %Exp:MV_PAR28% AND %Exp:MV_PAR29%
													  AND SA1.A1_COD_MUN BETWEEN %Exp:MV_PAR30% AND %Exp:MV_PAR31%
													  AND SA1.A1_COD           = SF2.F2_CLIENTE
													  AND SA1.A1_LOJA          = SF2.F2_LOJA
													  AND SA1.%NotDel%
													  %Exp:_cFilSA1%
					LEFT OUTER JOIN    %table:SA3% SA3 (NOLOCK) ON SA3.A3_FILIAL = %xFilial:SA3%
													  AND SA3.A3_COD     BETWEEN %Exp:MV_PAR24% AND %Exp:MV_PAR25%
													  AND SA3.A3_COD           = SF2.F2_VEND1
													  AND SA3.%NotDel%
													  %Exp:_cFilSA3%
						WHERE SD2.D2_FILIAL  = %xFilial:SD2%
						  AND SD2.%NotDel%
						  %Exp:_cFilSD2%
					 ) TMP
				PIVOT ( SUM(TMP.VALOR)
							FOR TMP.EMISSAO IN (%Exp:_cPivot%)
					  )  AS PVT
				ORDER BY %Exp:_cOrder%
			EndSql
		else		//Considera devolu��es tidas no per�odo selecionado
			BeginSql alias _cSD2TMP
				SELECT B1_FILIAL %Exp:_cFldDv%
				FROM (
							SELECT B1_FILIAL %Exp:_cField%
							FROM (
									SELECT B1_FILIAL, SUBSTRING(F2_EMISSAO,1,6) [EMISSAO]
											%Exp:_cCpoSum%
									FROM %table:SD2% SD2 (NOLOCK)
										INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
																//  AND SF4.F4_DUPLIC        = %Exp:'S'%
																  AND SF4.F4_CODIGO        = SD2.D2_TES
																  AND SF4.%NotDel%
																  %Exp:_cFilSF4%
										INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
																  AND SB1.B1_COD     BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
																  AND SB1.B1_COD           = SD2.D2_COD
																  AND SB1.%NotDel%
																  %Exp:_cFilSB1%
										INNER JOIN %table:SF2% SF2 (NOLOCK) ON SF2.F2_FILIAL = %xFilial:SF2%
																  AND SF2.F2_TIPO          = 'N'
																  AND SF2.F2_EMISSAO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
																  AND SF2.F2_VEND1   BETWEEN %Exp:MV_PAR24% AND %Exp:MV_PAR25%
																  AND SF2.F2_DOC           = SD2.D2_DOC
																  AND SF2.F2_SERIE         = SD2.D2_SERIE
																  AND SF2.F2_CLIENTE       = SD2.D2_CLIENTE
																  AND SF2.F2_LOJA          = SD2.D2_LOJA
																  AND SF2.F2_TIPO          = SD2.D2_TIPO
																  AND SF2.F2_EMISSAO       = SD2.D2_EMISSAO
																  AND SF2.%NotDel%
																  %Exp:_cFilSF2%
										INNER JOIN %table:SA1% SA1 (NOLOCK) ON SA1.A1_FILIAL = %xFilial:SA1%
																  AND SA1.A1_COD     BETWEEN %Exp:MV_PAR20% AND %Exp:MV_PAR22%
																  AND SA1.A1_LOJA    BETWEEN %Exp:MV_PAR21% AND %Exp:MV_PAR23%
																  AND SA1.A1_EST     BETWEEN %Exp:MV_PAR28% AND %Exp:MV_PAR29%
																  AND SA1.A1_COD_MUN BETWEEN %Exp:MV_PAR30% AND %Exp:MV_PAR31%
																  AND SA1.A1_COD           = SF2.F2_CLIENTE
																  AND SA1.A1_LOJA          = SF2.F2_LOJA
																  AND SA1.%NotDel%
																  %Exp:_cFilSA1%
								LEFT OUTER JOIN    %table:SA3% SA3 (NOLOCK) ON SA3.A3_FILIAL = %xFilial:SA3%
																  AND SA3.A3_COD     BETWEEN %Exp:MV_PAR24% AND %Exp:MV_PAR25%
																  AND SA3.A3_COD           = SF2.F2_VEND1
																  AND SA3.%NotDel%
																  %Exp:_cFilSA3%
									WHERE SD2.D2_FILIAL  = %xFilial:SD2%
									  AND SD2.%NotDel%
									  %Exp:_cFilSD2%
								 ) TMP
							PIVOT ( SUM(TMP.VALOR)
										FOR TMP.EMISSAO IN (%Exp:_cPivot%)
								  )  AS PVTl
				
						UNION ALL
				
							SELECT B1_FILIAL %Exp:_cField%
							FROM (
									SELECT B1_FILIAL, SUBSTRING(D1_DTDIGIT,1,6) [EMISSAO]
											%Exp:_cCpSuDv%
									FROM %table:SD1% SD1 (NOLOCK)
										INNER JOIN %table:SD2% SD2 (NOLOCK) ON SD2.D2_FILIAL = %xFilial:SD2%
																  AND SD2.D2_TIPO          = 'N'
																  AND SD2.D2_DOC           = SD1.D1_NFORI
																  AND SD2.D2_SERIE         = SD1.D1_SERIORI
																  AND SD2.D2_ITEM          = SD1.D1_ITEMORI
																  AND SD2.D2_COD           = SD1.D1_COD
																  AND SD2.D2_CLIENTE       = SD1.D1_FORNECE
																  AND SD2.D2_LOJA          = SD1.D1_LOJA
																  AND SD2.%NotDel%
																  %Exp:_cFilSD2%
										INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL = %xFilial:SF4%
																 // AND SF4.F4_DUPLIC        = %Exp:'S'%
																  AND SF4.F4_CODIGO        = SD2.D2_TES
																  AND SF4.%NotDel%
																  %Exp:_cFilSF4%
										INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
													  			  AND SB1.B1_COD           = SD2.D2_COD
																  AND SB1.%NotDel%
																  %Exp:_cFilSB1%
										INNER JOIN %table:SF2% SF2 (NOLOCK) ON SF2.F2_FILIAL = %xFilial:SF2%
																  AND SF2.F2_VEND1   BETWEEN %Exp:MV_PAR24% AND %Exp:MV_PAR25%
																  AND SF2.F2_DOC           = SD2.D2_DOC
																  AND SF2.F2_SERIE         = SD2.D2_SERIE
																  AND SF2.F2_CLIENTE       = SD2.D2_CLIENTE
																  AND SF2.F2_LOJA          = SD2.D2_LOJA
																  AND SF2.F2_TIPO          = SD2.D2_TIPO
																  AND SF2.F2_EMISSAO       = SD2.D2_EMISSAO
																  AND SF2.%NotDel%
																  %Exp:_cFilSF2%
										INNER JOIN %table:SA1% SA1 (NOLOCK) ON SA1.A1_FILIAL = %xFilial:SA1%
																  AND SA1.A1_EST     BETWEEN %Exp:MV_PAR28% AND %Exp:MV_PAR29%
																  AND SA1.A1_COD_MUN BETWEEN %Exp:MV_PAR30% AND %Exp:MV_PAR31%
																  AND SA1.A1_COD           = SF2.F2_CLIENTE
																  AND SA1.A1_LOJA          = SF2.F2_LOJA
																  AND SA1.%NotDel%
																  %Exp:_cFilSA1%
								LEFT OUTER JOIN    %table:SA3% SA3 (NOLOCK) ON SA3.A3_FILIAL = %xFilial:SA3%
																  AND SA3.A3_COD     BETWEEN %Exp:MV_PAR24% AND %Exp:MV_PAR25%
																  AND SA3.A3_COD           = SF2.F2_VEND1
																  AND SA3.%NotDel%
																  %Exp:_cFilSA3%
									WHERE SD1.D1_FILIAL        = %xFilial:SD1%
									  AND (SD1.D1_TIPO         = %Exp:'D'% OR SD1.D1_TIPO  = %Exp:'B'%)
									  AND SD1.D1_NFORI        <> %Exp:''%
									  AND SD1.D1_DTDIGIT BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
									  AND SD1.D1_COD     BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
									  AND SD1.D1_FORNECE BETWEEN %Exp:MV_PAR20% AND %Exp:MV_PAR22%
									  AND SD1.D1_LOJA    BETWEEN %Exp:MV_PAR21% AND %Exp:MV_PAR23%
									  AND SD1.%NotDel%
									  %Exp:_cFilSD1%
								 ) TMP
							PIVOT ( SUM(TMP.VALOR)
										FOR TMP.EMISSAO IN (%Exp:_cPivot%)
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
/*/{Protheus.doc} ValidPerg (RESTR035)
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
	AADD(aRegs,{cPerg,"01","Do Produto?"             ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","SB1"   ,"",""})
	AADD(aRegs,{cPerg,"02","Ao Produto?"             ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","SB1"   ,"",""})
	_aTam  := TamSx3("F2_EMISSAO")
	AADD(aRegs,{cPerg,"03","Da Emiss�o?"             ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par03",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"04","At� a Emiss�o?"          ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"05","Tipo de Informa��o?"     ,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par05","Vlr. Mercadorias" ,"","","","","Custo"	        ,"","","","","Vlr. Total"		,"","","","","Valor NET","","","","","Quantidade","","","",""      ,"",""})
	AADD(aRegs,{cPerg,"06","Opera��o?"               ,"","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par06","Somente Vendas"   ,"","","","","N�o Vendas"	    ,"","","","","Ambos"			,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := {03,00,"N"}
	AADD(aRegs,{cPerg,"07","N�veis para Sub-Totais?" ,"","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","Positivo()","mv_par07",""                 ,"","","","",""				,"","","","",""	   				,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := {06,02,"N"}
	AADD(aRegs,{cPerg,"08","% Cresc. Janeiro?"		 ,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"09","% Cresc. Fevereiro?"	 ,"","","mv_ch9",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par09",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"10","% Cresc. Mar�o?"		 ,"","","mv_cha",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par10",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"11","% Cresc. Abril?"		 ,"","","mv_chb",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par11",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"12","% Cresc. Maio?"          ,"","","mv_chc",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par12",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"13","% Cresc. Junho?"		 ,"","","mv_chd",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par13",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"14","% Cresc. Julho?"		 ,"","","mv_che",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par14",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"15","% Cresc. Agosto?"		 ,"","","mv_chf",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par15",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"16","% Cresc. Setembro?"      ,"","","mv_chg",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par16",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"17","% Cresc. Outubro?"		 ,"","","mv_chh",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par17",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"18","% Cresc. Novembro?"      ,"","","mv_chi",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par18",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	AADD(aRegs,{cPerg,"19","% Cresc. Dezembro?"      ,"","","mv_chj",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par19",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := TamSx3("A1_COD"    )
	AADD(aRegs,{cPerg,"20","Do Cliente?"			 ,"","","mv_chk",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par20",""                 ,"","","","",""				,"","","","",""	   				,"","","","",""         ,"","","","",""          ,"","","","SA1"   ,"",""})
	_aTam  := TamSx3("A1_LOJA"   )
	AADD(aRegs,{cPerg,"21","Da Loja?"				 ,"","","mv_chl",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par21",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := TamSx3("A1_COD"    )
	AADD(aRegs,{cPerg,"22","Ao Cliente?"			 ,"","","mv_chm",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par22",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","SA1"   ,"",""})
	_aTam  := TamSx3("A1_LOJA"   )
	AADD(aRegs,{cPerg,"23","At� a Loja?"			 ,"","","mv_chn",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par23",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := TamSx3("A3_COD"    )

	// Altera��o - Fernando Bombardi - ALLSS - 02/03/2022
	AADD(aRegs,{cPerg,"24","Do Representante?"			 ,"","","mv_cho",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par24",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","SA3"   ,"",""})
	AADD(aRegs,{cPerg,"25","Ao Representante?"			 ,"","","mv_chp",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par25",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","SA3"   ,"",""})

	//AADD(aRegs,{cPerg,"24","Do Vendedor?"			 ,"","","mv_cho",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par24",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","SA3"   ,"",""})
	//AADD(aRegs,{cPerg,"25","Ao Vendedor?"			 ,"","","mv_chp",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par25",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","SA3"   ,"",""})
	// Fim - Fernando Bombardi - ALLSS - 02/03/2022

	If SA1->(FieldPos("A1_CGCCENT"))<>0
		_aTam  := TamSx3("A1_CGCCENT")
		AADD(aRegs,{cPerg,"26","Do CNPJ Central?"	 ,"","","mv_chq",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par26",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
		AADD(aRegs,{cPerg,"27","Ao CNPJ Central?"	 ,"","","mv_chr",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par27",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	Else
		_aTam  := TamSx3("A1_CGC")
		AADD(aRegs,{cPerg,"26","Do CNPJ ?"			 ,"","","mv_chq",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par26",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
		AADD(aRegs,{cPerg,"27","Ao CNPJ?"			 ,"","","mv_chr",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par27",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	EndIf
	_aTam  := TamSx3("A1_EST"    )
	AADD(aRegs,{cPerg,"28","Da UF?"                  ,"","","mv_chs",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par28",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","12"    ,"",""})
	AADD(aRegs,{cPerg,"29","At� a UF?"				 ,"","","mv_cht",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par29",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","12"    ,"",""})
	_aTam  := TamSx3("A1_COD_MUN")
	AADD(aRegs,{cPerg,"30","Do C�d.Munic�pio?"		 ,"","","mv_chu",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par30",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","CC2MUN","",""})
	AADD(aRegs,{cPerg,"31","Ao C�d.Munic�pio?"		 ,"","","mv_chv",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par31",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","","CC2MUN","",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"32","Inclui Devolu��o?"		 ,"","","mv_chw",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par32","N�o"              ,"","","","","Sim - NF Devol" ,"","","","","Sim - NF Origem"	,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"33","Apenas as Devolu��es?"	 ,"","","mv_chx",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par33","N�o"              ,"","","","","Sim"            ,"","","","",""	                ,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"34","Qual Moeda?"			 ,"","","mv_chy",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par34",AllTrim(SuperGetMv("MV_MOEDA1",,"Real")),"","","","",AllTrim(SuperGetMv("MV_MOEDA2",,"D�lar")),"","","","",AllTrim(SuperGetMv("MV_MOEDA3",,"Euro")),"","","","",AllTrim(SuperGetMv("MV_MOEDA4",,"Iene")),"","","","",AllTrim(SuperGetMv("MV_MOEDA5",,"Peso")),"","","",""   ,"",""})
	_aTam  := {08,00,"D"}
	AADD(aRegs,{cPerg,"35","Data para convers�o?"	 ,"","","mv_chz",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par35",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"36","Data da Moeda?"          ,"","","mv_chz",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par36","Data Informada"   ,"","","","","Emiss�o Docto." ,"","","","",""                 ,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"37","Ordena pela M�dia?"      ,"","","mv_chz",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par37","N�o"              ,"","","","","Sim"            ,"","","","",""	          		,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	_aTam  := {01,00,"N"}
	AADD(aRegs,{cPerg,"38","Compara Per�odos?"	     ,"","","mv_chz",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par38","N�o"              ,"","","","","Sim"            ,"","","","",""	          		,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	//_aTam  := {02,00,"N"}
	//AADD(aRegs,{cPerg,"39","Meses por Per�odo?"	 ,"","","mv_chz",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par39",""                 ,"","","","",""               ,"","","","",""	          		,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
	//_aTam  := {01,00,"N"}
	//AADD(aRegs,{cPerg,"40","Quanto ao Financeiro?"	 ,"","","mv_chz",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par40","S� c/Financeiro"  ,"","","","","Sem Financeiro" ,"","","","","Ambos"		,"","","","",""         ,"","","","",""          ,"","","",""      ,"",""})
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
