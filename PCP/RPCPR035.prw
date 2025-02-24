#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE _CRFL CHR(13) + CHR(10)
/*/{Protheus.doc} RPCPR035
Relatorio de totais PRODUZIDOS por produto por periodo, mes a mes, baseado nos Movimentos Internos de Estoque.
O relat�rio apresentar� e somar� quantidades ou valores dos produtos, conforme parametriza��o do usu�rio.
@author Anderson C. P. Coelho
@since 29/08/2016
@version P12.1.33
@type Function
@obs Sem observa��es
@see https://allss.com.br
@history 27/07/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revis�o para adequa��o de chamadas de tabela em querys sem NOLOCK.
/*/
User Function RPCPR035()

Local  oReport

Private oSection
Private _cRotina  := "RPCPR035"
Private cPerg     := _cRotina
Private _cFormTit := "Relat�rio de Totais PRODUZIDOS por Produto, por Per�odo"
Private aRegs    := {}
Private _aCpos    := {}
Private _lMoeda   := .F.

If FindFunction("TRepInUse") .And. TRepInUse()
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	MV_PAR24 := IIF(ValType(MV_PAR24)=="N",cValToChar(MV_PAR24),MV_PAR24)
	oReport  := ReportDef()
	oReport:PrintDialog()
	/*
	While MSGBOX("Deseja emitir o relat�rio novamente?",_cRotina+"_001","YESNO")
		If !Pergunte(cPerg,.T.)
			Return
		EndIf
		MV_PAR24 := IIF(ValType(MV_PAR24)=="N",cValToChar(MV_PAR24),MV_PAR24)
		oReport  := ReportDef()
		oReport:PrintDialog()
	EndDo
	*/
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Anderson C. P. Coelho  � Data � 06/02/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportDef()

Local oReport
//Local oSection
//Local oBreak
Local cTitulo  := &(_cFormTit)
Local _aOrd    := {"Ordem dos Campos"}		//{"Grupo + Produto", "Grupo + Descri��o de Produto"}

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Emissao do relat�rio, de acordo com o intervalo informado na op��o de Par�metros.")
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)
//Convers�o de tipo do par�metro de devolu��es
	MV_PAR24 := IIF(ValType(MV_PAR24)=="N",cValToChar(MV_PAR24),MV_PAR24)
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
oSection := TRSection():New(oReport,"RELAT�RIO DE ITENS PRODUZIDOS - QTD. E VALOR",{"SB1","SBM","SD3"},_aOrd/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:SetTotalInLine(.F.)

//Identifica��o dos campos em uso, mas identificarmos depois os campos adicionados pelo usu�rio, para que possamos o incluir na query.
//Defini��o das colunas do relat�rio
TRCell():New(oSection,"B1_TIPO"     ,"SB1"/*Tabela*/,RetTitle("B1_TIPO"	  ),PesqPict  ("SB1","B1_TIPO" ),TamSx3("B1_TIPO" )[1],/*lPixel*/,{|| SD2TMP->B1_TIPO   	})	// Tipo de Produto
TRCell():New(oSection,"B1_GRUPO"    ,"SB1"/*Tabela*/,RetTitle("B1_GRUPO"  ),PesqPict  ("SB1","B1_GRUPO"),TamSx3("B1_GRUPO")[1],/*lPixel*/,{|| SD2TMP->B1_GRUPO 		})	// Grupo de Produto
TRCell():New(oSection,"B1_COD"      ,"SB1"/*Tabela*/,RetTitle("B1_COD"    ),PesqPict  ("SB1","B1_COD"  ),TamSx3("B1_COD"  )[1],/*lPixel*/,{|| SD2TMP->B1_COD    	})	// Codigo do Produto
TRCell():New(oSection,"B1_DESC"     ,"SB1"/*Tabela*/,RetTitle("B1_DESC"   ),PesqPict  ("SB1","B1_DESC" ),TamSx3("B1_DESC" )[1],/*lPixel*/,{|| SD2TMP->B1_DESC		})	// Descricao do Produto
TRCell():New(oSection,"B1_UM"       ,"SB1"/*Tabela*/,RetTitle("B1_UM"	  ),PesqPict  ("SB1","B1_UM"   ),TamSx3("B1_UM"   )[1],/*lPixel*/,{|| SD2TMP->B1_UM         })	// Unidade de Medida

/*
oSection:SetEdit(.T.)
oSection:SetUseQuery(.T.)
oSection:SetEditCell(.T.)
//oSection:DelUserCell(.F.)
*/

//oBreak := TRBreak():New(oSection,oSection:Cell("B1_COD"),"Sub-Total Produtos")
//TRFunction():New(oSection:Cell("D2_QUANT"  ),NIL,"SUM",oBreak)
//TRFunction():New(oSection:Cell("D2_TOTAL"  ),NIL,"SUM",oBreak)

//������������������������������������������������������������������������Ŀ
//� Troca descricao do total dos itens                                     �
//��������������������������������������������������������������������������
//oReport:Section(1):SetTotalText("T O T A I S ")
//Efetuo o relacionamento entre as tabelas
//TRPosition():New(oSection,"SF2",1,{|| xFilial("SF2") + SD2->D2_DOC+SD2->D2_SERIE})
//TRPosition():New(oSection,"SB1",1,{|| xFilial("SB1") + SD2->D2_COD              })
//oReport:Section(2):SetEdit(.F.) 
//oReport:Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query

//������������������������������������������������������������������������Ŀ
//� Alinhamento a direita as colunas de valor                              �
//��������������������������������������������������������������������������
//oSection:Cell("D2_QUANT"  ):SetHeaderAlign("RIGHT")
//oSection:Cell("D2_TOTAL"  ):SetHeaderAlign("RIGHT")

Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrintReport�Autor �Anderson C. P. Coelho � Data �  06/02/15 ���
�������������������������������������������������������������������������͹��
���Desc.     �Processamento das informa��es para impress�o (Print).       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PrintReport(oReport)

//Declara��o das vari�veis
	//Local oSection := oReport:Section(1)
	Local _cCpoSum := ""
	Local _cCpSuDv := ""
	Local _cFlOper := ""
	Local _cOrder  := ""
	Local _cField  := ""
	Local _cFldDv  := ""
	Local _cTotal  := ""
	Local _cPivot  := ""
	Local _cMesAno := ""
	Local _cLogPar := ""
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
	Local _nVMoeda := 0
	Local _nBreak  := 0
	Local _nFator  := 0
	Local _nTotBrk := MV_PAR07		//Total de Breaks permitidos (n�veis)
	local _x, _k
//Fim da declara��o de vari�veis
//Adequa��o do t�tulo do relat�rio
//	oReport:cDescription := oReport:cRealTitle := oReport:cTitle := cTitulo := &(_cFormTit)
//Fim da Adequa��o do t�tulo do relat�rio
//An�lise do preenchimento dos par�metros
	If MV_PAR01 > MV_PAR02 .OR. MV_PAR03 > MV_PAR04 .OR. MV_PAR20 > MV_PAR22 .OR. MV_PAR21 > MV_PAR23 .OR. MV_PAR24 > MV_PAR25 .OR. MV_PAR26 > MV_PAR27 .OR. (MV_PAR29 == 2 .AND. MV_PAR28 == 1)
		MsgStop("Par�metros informados incorretamente... confira!",_cRotina+"_002_A")
		_cLogPar := "Par�metros" + _CRFL
		_cLogPar += "**********" + _CRFL
		/*
		For _p := 1 To Len(aRegs)
			_cLogPar += ">>> "                          + ;
						aRegs[_p][02]          + " - " + ;
						AllTrim(aRegs[_p][03]) + ": "  + ;
						IIF(Type("MV_PAR"+aRegs[_p][02])=="C",&("MV_PAR"+aRegs[_p][02]),IIF(Type("MV_PAR"+aRegs[_p][02])=="D",DTOC(&("MV_PAR"+aRegs[_p][02])),IIF(Type("MV_PAR"+aRegs[_p][02])=="N",cValToChar(&("MV_PAR"+aRegs[_p][02])),""))) + _CRFL
		Next
		*/
		MsgInfo(_cLogPar,_cRotina+"_002_B")
		Return
	EndIf
//Fim da an�lise do preenchimento dos par�metros
//Permiss�o para emiss�o do relat�rio por valor
	If MV_PAR05 <> 2 .AND. !__cUserId$SuperGetMv("MV_USRVLFT",,"|000000|000045|000046|000047|000048|000019|000028|")
		MsgStop("Aten��o! Emiss�o do relat�rio em valor n�o autorizada. Sendo assim, o relat�rio ser� modificado para emiss�o em quantidade!",_cRotina+"_005")
		MV_PAR05 := 2
	EndIf
//Fim da verifica��o de permiss�o
// Verifica a moeda selecionada
	If Empty(MV_PAR24)
		MV_PAR24 := "1"
	EndIf
	If Empty(MV_PAR25)
		MV_PAR25 := dDataBase
	EndIf
	dbUseArea(	.T.,;
				"TOPCONN",;
				TcGenQry(,,"(SELECT TOP 1 (CASE WHEN "+MV_PAR24+"='1' THEN 1 ELSE ISNULL(M2_MOEDA"+MV_PAR24+",0) END) [MOEDA] FROM "+RetSqlName("SM2")+" WITH (NOLOCK) WHERE M2_DATA = '"+DTOS(MV_PAR25)+"' AND D_E_L_E_T_ = '')"),;
				"SM2TMP",;
				.T.,;
				.F.)	
	dbSelectArea("SM2TMP")
	_nVMoeda := cValToChar(SM2TMP->MOEDA)
	dbSelectArea("SM2TMP")
	SM2TMP->(dbCloseArea())
	If VAL(_nVMoeda) == 0
		MsgInfo("Aten��o! N�o foi localizada taxa para a moeda '"+UPPER(AllTrim(SuperGetMv("MV_MOEDA"+MV_PAR24,,"N�O LOCALIZADA")))+"' no dia "+DTOC(MV_PAR25)+" (informa��es solicitadas pelo usu�rio)!",_cRotina+"_006")
	EndIf
//Fim da verifica��o da moeda 
//In�cio do tratamento para composi��o das devolu��es vendas vinculadas as sa�das filtradas
	//Deduz Devolu��es? - 1=N�o / 2=Sim, Conforme NF de Devolu��o / 3=Sim, Conforme NF Original
	If MV_PAR28 == 3				//NF DEVOLU��O 
		_qDevNF     := "("
		If MV_PAR05 == 1			//Custo
			_qDevNF += " SELECT ISNULL(SUM(D1_TOTAL+D1_ICMSRET+D1_VALIPI+D1_SEGURO+D1_DESPESA+D1_VALFRE),0) "
		Else						//Qtde.
			_qDevNF += " SELECT ISNULL(SUM(D1_QUANT),0) "
		EndIf
		_qDevNF     += " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK) "
		_qDevNF     += " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"' "
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
		If MV_PAR06 == 1
			_cFlOper := "% AND SD2.D2_TIPOPER      IN " + _cTpOper + "%"
		ElseIf MV_PAR06 == 2
			_cFlOper := "% AND SD2.D2_TIPOPER  NOT IN " + _cTpOper + "%"
		EndIf
	EndIf
	If SA1->(FieldPos("A1_CGCCENT"))<>0
		If !Empty(_cFilSA1)
			_cFilSA1 += " AND "
		EndIf
		_cFilSA1 += " SA1.A1_CGCCENT BETWEEN '"+MV_PAR26+"' AND '"+MV_PAR27+"'"
	EndIf
//Fim das Filtragens espec�fidas para as querys
//Defini��o do campo de valor a ser apresentado/totalizado
	If MV_PAR05 == 1		//Custo
		_cCpoSum := ", (("+IIF(MV_PAR29==2,"0","D2_VALBRUT")+" - "+_qDevNF+" ) * "+_nVMoeda+") [VALOR]"
		_cCpSuDv := ", ((D1_TOTAL+D1_ICMSRET+D1_VALIPI+D1_SEGURO+D1_DESPESA+D1_VALFRE) * (-1) * "+_nVMoeda+") [VALOR]"
	Else					//Quantidade
		If SD2->(FieldPos("D2_SCOA"))<>0
			_cCpoSum := ", (CASE WHEN F4_ESTOQUE = 'S' OR (D2_TES = '601' AND D2_SCOA <> '') "
		Else
			_cCpoSum := ", (CASE WHEN F4_ESTOQUE = 'S'                                       "
		EndIf
		_cCpoSum += "              THEN (("+IIF(MV_PAR29==2,"0","D2_QUANT")+" - "+_qDevNF+")) "
		_cCpoSum += "              ELSE 0 "
		_cCpoSum += "       END)   [VALOR]"
		_cCpSuDv := ", (D1_QUANT * (-1)) [VALOR]"
	EndIf
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
		_cOrder := "B1_GRUPO, B1_COD , B1_DESC"
	ElseIf oReport:Section(1):GetOrder() == 2		//Ordem por Grupo+Descri��o
		_cOrder := "B1_GRUPO, B1_DESC, B1_COD "
	Else
		_cOrder := "B1_GRUPO, B1_COD , B1_DESC"
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
		Return
	Else
		//Inclus�o dos campos definidos pelo usu�rio na Query e defini��o da ordem din�mica e sub-totais din�micos para o relat�rio
		For _x := 1 To Len(_aCols)
			If MV_PAR05 == 1		//Custo
				&('TRCell():New(oSection,"'+_aCols[_x][04]+'", "SD2TMP"/*Tabela*/,"'+_aCols[_x][03]+'","@E 999,999,999,999.99" ,26 ,/*lPixel*/,{|| Round(SD2TMP->'+_aCols[_x][04]+',TamSx3("D2_VALBRUT")[02]) })')	// Valor Total
			Else					//Qtde.
				&('TRCell():New(oSection,"'+_aCols[_x][04]+'", "SD2TMP"/*Tabela*/,"'+_aCols[_x][03]+'","@E 999,999,999,999.99" ,26 ,/*lPixel*/,{|| Round(SD2TMP->'+_aCols[_x][04]+',TamSx3("D2_QUANT"  )[02]) })')	// Quantidade
			EndIf
	        // Inclus�o de novos totais.
			If !Empty(_cTotal)
				_cTotal += "+"
			EndIf
			_cTotal += "IsNull("+_aCols[_x][01]+",0)"
			If !Empty(_cPivot)
				_cPivot += ", "
			EndIf
			_cField += ", " + _aCols[_x][02]
			_cFldDv += ", SUM(" + _aCols[_x][04] + ") " + _aCols[_x][04]
			_cPivot +=        _aCols[_x][01]
		Next
		If MV_PAR05 == 1		//Custo
			TRCell():New(oSection,"TOTAL", "SD2TMP"/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round(SD2TMP->TOTAL,TamSx3("D2_VALBRUT")[02]) })// Valor Total
		Else					//Qtde.
			TRCell():New(oSection,"TOTAL", "SD2TMP"/*Tabela*/,"TOTAL", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round(SD2TMP->TOTAL,TamSx3("D2_QUANT"  )[02]) })// Quantidade
		EndIf
	    // Inclus�o de novos totais.
		For _x := 1 To Len(oSection:aCell)
			If !Empty(oSection:aCell[_x]:cAlias) .AND. AllTrim(oSection:aCell[_x]:cAlias) <> "SD2TMP"
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
							For _k := 1 To Len(_aCols)
								TRFunction():New(oSection:Cell(_aCols[_k][03]),NIL,"SUM",&("oBreak"+cValToChar(_nBreak)))
							Next
							TRFunction():New(oSection:Cell("TOTAL"),NIL,"SUM",&("oBreak"+cValToChar(_nBreak)))
						EndIf
					EndIf
				EndIf
			EndIf
			If _nTotBrk == 0
				//Sub-Totais - Soma das colunas de valores/quantidades
				If Len(_aCols) > 0
					For _k := 1 To Len(_aCols)
						TRFunction():New(oSection:Cell(_aCols[_k][03]),NIL,"SUM")
					Next
					TRFunction():New(oSection:Cell("TOTAL"),NIL,"SUM")
				EndIf
			EndIf
		Next
	EndIf
//Fim da Defini��o das colunas de datas (M�s/Ano) NO RELAT�RIO com impacto nos totais, inclusive
//Tratamento final das vari�veis que carregam os campos din�micos, para posterior uso no SQL Embended
	_cTotal  := ", ("+_cTotal+") [TOTAL]"
	_cCpoSum := "%" + _cCpoSum + "%"
	_cCpSuDv := "%" + _cCpSuDv + "%"
	_cField  := "%" + _cField  + _cTotal  + "%"
	_cFldDv  := "%" + _cFldDv  + ", SUM(TOTAL) [TOTAL]"  + "%"
	_cPivot  := "%" + _cPivot  + "%"
	_cOrder  := "%B1_FILIAL, " + _cOrder  + "%"
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
		If MV_PAR28 <> 2		//Sem considerar devolu��es OU as devolu��es vinculadas aos documentos de sa�da do per�odo selecionado
			BeginSql alias "SD2TMP"
				SELECT B1_FILIAL %Exp:_cField%
				FROM (
						SELECT B1_FILIAL, SUBSTRING(F2_EMISSAO,1,6) [EMISSAO]
								%Exp:_cCpoSum%
						FROM %table:SD2% SD2 (NOLOCK)
							INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL        = %xFilial:SF4%
													  AND SF4.F4_DUPLIC        			= %Exp:'S'%
													  AND SF4.F4_CODIGO        			= SD2.D2_TES
													  AND SF4.%NotDel%
													  %Exp:_cFilSF4%
							INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL        = %xFilial:SB1%
													  AND SB1.B1_COD     				BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
													  AND SB1.B1_COD           			= SD2.D2_COD
													  AND SB1.%NotDel%
													  %Exp:_cFilSB1%
							INNER JOIN %table:SF2% SF2 (NOLOCK) ON SF2.F2_FILIAL        = %xFilial:SF2%
													  AND SF2.F2_DOC           			= SD2.D2_DOC
													  AND SF2.F2_SERIE         			= SD2.D2_SERIE
													  AND SF2.F2_CLIENTE       			= SD2.D2_CLIENTE
													  AND SF2.F2_LOJA          			= SD2.D2_LOJA
													  AND SF2.F2_TIPO          			= SD2.D2_TIPO
													  AND SF2.F2_EMISSAO 				BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
													  AND SF2.%NotDel%
													  %Exp:_cFilSF2%
							INNER JOIN %table:SA1% SA1 (NOLOCK) ON SA1.A1_FILIAL        = %xFilial:SA1%
													  AND SA1.A1_COD     				BETWEEN %Exp:MV_PAR20% AND %Exp:MV_PAR22%
													  AND SA1.A1_LOJA    				BETWEEN %Exp:MV_PAR21% AND %Exp:MV_PAR23%
													  AND SA1.A1_COD           			= SF2.F2_CLIENTE
													  AND SA1.A1_LOJA          			= SF2.F2_LOJA
													  AND SA1.%NotDel%
													  %Exp:_cFilSA1%
							LEFT OUTER JOIN  %table:SA3% SA3 (NOLOCK) ON SA3.A3_FILIAL  = %xFilial:SA3%
													  AND SA3.A3_COD     				BETWEEN %Exp:MV_PAR24% AND %Exp:MV_PAR25%
													  AND SA3.A3_COD           			= SF2.F2_VEND1
													  AND SA3.%NotDel%
													  %Exp:_cFilSA3%
						WHERE SD2.D2_FILIAL  = %xFilial:SD2%
						  AND SD2.D2_TIPO    = 'N'
						  AND SD2.%NotDel%
						  %Exp:_cFilSD2%
					 ) TMP
				PIVOT ( SUM(TMP.VALOR)
							FOR TMP.EMISSAO IN (%Exp:_cPivot%)
					  )  AS PVT
				ORDER BY %Exp:_cOrder%
			EndSql
			/*
			Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
			parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
			pela funcao MakeSqlExpr para serem adicionados a query
			*/
		Else		//Considera devolu��es tidas no per�odo selecionado
			BeginSql alias "SD2TMP"
				SELECT B1_FILIAL %Exp:_cFldDv%
				FROM (
							SELECT B1_FILIAL %Exp:_cField%
							FROM (
									SELECT B1_FILIAL, SUBSTRING(F2_EMISSAO,1,6) [EMISSAO]
											%Exp:_cCpoSum%
									FROM %table:SD2% SD2 (NOLOCK)
										INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL        = %xFilial:SF4%
																  AND SF4.F4_DUPLIC        			= %Exp:'S'%
																  AND SF4.F4_CODIGO        			= SD2.D2_TES
																  AND SF4.%NotDel%
																  %Exp:_cFilSF4%
										INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL        = %xFilial:SB1%
																  AND SB1.B1_COD     				BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
																  AND SB1.B1_COD           			= SD2.D2_COD
																  AND SB1.%NotDel%
																  %Exp:_cFilSB1%
										INNER JOIN %table:SF2% SF2 (NOLOCK) ON SF2.F2_FILIAL        = %xFilial:SF2%
																  AND SF2.F2_DOC           			= SD2.D2_DOC
																  AND SF2.F2_SERIE         			= SD2.D2_SERIE
																  AND SF2.F2_CLIENTE       			= SD2.D2_CLIENTE
																  AND SF2.F2_LOJA          			= SD2.D2_LOJA
																  AND SF2.F2_TIPO          			= SD2.D2_TIPO
																  AND SF2.F2_EMISSAO       			= SD2.D2_EMISSAO
																  AND SF2.%NotDel%
																  %Exp:_cFilSF2%
										INNER JOIN %table:SA1% SA1 (NOLOCK) ON SA1.A1_FILIAL        = %xFilial:SA1%
																  AND SA1.A1_COD     				BETWEEN %Exp:MV_PAR20% AND %Exp:MV_PAR22%
																  AND SA1.A1_LOJA    				BETWEEN %Exp:MV_PAR21% AND %Exp:MV_PAR23%
																  AND SA1.A1_COD           			= SF2.F2_CLIENTE
																  AND SA1.A1_LOJA          			= SF2.F2_LOJA
																  AND SA1.%NotDel%
																  %Exp:_cFilSA1%
										LEFT OUTER JOIN %table:SA3% SA3 (NOLOCK) ON SA3.A3_FILIAL   = %xFilial:SA3%
																  AND SA3.A3_COD     				BETWEEN %Exp:MV_PAR24% AND %Exp:MV_PAR25%
																  AND SA3.A3_COD           			= SF2.F2_VEND1
																  AND SA3.%NotDel%
																  %Exp:_cFilSA3%
									WHERE SD2.D2_FILIAL  = %xFilial:SD2%
									  AND SD2.D2_TIPO    = 'N'
									  AND SD2.%NotDel%
									  %Exp:_cFilSD2%
								 ) TMP
							PIVOT ( SUM(TMP.VALOR)
										FOR TMP.EMISSAO IN (%Exp:_cPivot%)
								  )  AS PVT
				
						UNION ALL
				
							SELECT B1_FILIAL %Exp:_cField%
							FROM (
									SELECT B1_FILIAL, SUBSTRING(D1_DTDIGIT,1,6) [EMISSAO]
											%Exp:_cCpSuDv%
									FROM %table:SD1% SD1 (NOLOCK)
										INNER JOIN %table:SD2% SD2 (NOLOCK) ON SD2.D2_FILIAL        = %xFilial:SD2%
																  AND SD2.D2_TIPO          			= 'N'
																  AND SD2.D2_DOC           			= SD1.D1_NFORI
																  AND SD2.D2_SERIE         			= SD1.D1_SERIORI
																  AND SD2.D2_ITEM          			= SD1.D1_ITEMORI
																  AND SD2.D2_COD           			= SD1.D1_COD
																  AND SD2.D2_CLIENTE       			= SD1.D1_FORNECE
																  AND SD2.D2_LOJA          			= SD1.D1_LOJA
																  AND SD2.%NotDel%
																  %Exp:_cFilSD2%
										INNER JOIN %table:SF4% SF4 (NOLOCK) ON SF4.F4_FILIAL        = %xFilial:SF4%
																  AND SF4.F4_DUPLIC        			= %Exp:'S'%
																  AND SF4.F4_CODIGO        			= SD2.D2_TES
																  AND SF4.%NotDel%
																  %Exp:_cFilSF4%
										INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL        = %xFilial:SB1%
													  			  AND SB1.B1_COD           			= SD2.D2_COD
																  AND SB1.%NotDel%
																  %Exp:_cFilSB1%
										INNER JOIN %table:SF2% SF2 (NOLOCK) ON SF2.F2_FILIAL        = %xFilial:SF2%
																  AND SF2.F2_DOC           			= SD2.D2_DOC
																  AND SF2.F2_SERIE         			= SD2.D2_SERIE
																  AND SF2.F2_CLIENTE       			= SD2.D2_CLIENTE
																  AND SF2.F2_LOJA          			= SD2.D2_LOJA
																  AND SF2.F2_TIPO          			= SD2.D2_TIPO
																  AND SF2.F2_EMISSAO       			= SD2.D2_EMISSAO
																  AND SF2.%NotDel%
																  %Exp:_cFilSF2%
										INNER JOIN %table:SA1% SA1 (NOLOCK) ON SA1.A1_FILIAL        = %xFilial:SA1%
																  AND SA1.A1_COD           			= SF2.F2_CLIENTE
																  AND SA1.A1_LOJA          			= SF2.F2_LOJA
																  AND SA1.%NotDel%
																  %Exp:_cFilSA1%
										LEFT OUTER JOIN %table:SA3% SA3 (NOLOCK) ON SA3.A3_FILIAL   = %xFilial:SA3%
																  AND SA3.A3_COD     				BETWEEN %Exp:MV_PAR24% AND %Exp:MV_PAR25%
																  AND SA3.A3_COD           			= SF2.F2_VEND1
																  AND SA3.%NotDel%
																  %Exp:_cFilSA3%
									WHERE SD1.D1_FILIAL        = %xFilial:SD1%
									  AND SD1.D1_TIPO          = 'D'
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
				GROUP BY %Exp:_cOrder%
				ORDER BY %Exp:_cOrder%
			EndSql
			/*
			Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
			parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
			pela funcao MakeSqlExpr para serem adicionados a query
			*/
		EndIf
		oSection:EndQuery()
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",oSection:CQUERY)
//FIM DO PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
//Envia o relat�rio para a tela/impressora
	oSection:Print()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg �Autor  �Anderson C. P. Coelho � Data �  06/02/15 ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se as perguntas existem na SX1. Caso n�o existam,  ���
���          �as cria.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aTam  := {}
Local i      := 0
local j      := 0

cPerg  := PADR(cPerg,10)
aRegs := {}
_aTam  := TamSx3("B1_COD"    )
AADD(aRegs,{cPerg,"01","Do Produto?"            ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SB1","",""})
AADD(aRegs,{cPerg,"02","Ao Produto?"            ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SB1","",""})
_aTam  := TamSx3("D3_EMISSAO")
AADD(aRegs,{cPerg,"03","Da Emiss�o?"            ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par03",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"04","At� a Emiss�o?"         ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := {01,00,"N"}
AADD(aRegs,{cPerg,"05","Tipo de Informa��o?"    ,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par05","Custo"            ,"","","","","Quantidade"	    ,"","","","",""                 ,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"06","Par�metro desativado!"  ,"","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C",""          ,"mv_par06",""                 ,"","","","",""	            ,"","","","",""	         		,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := {03,00,"N"}
AADD(aRegs,{cPerg,"07","N�veis para Sub-Totais?","","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","Positivo()","mv_par07",""                 ,"","","","",""				,"","","","",""	   				,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := {06,02,"N"}
AADD(aRegs,{cPerg,"08","% Cresc. Janeiro?"		 ,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"09","% Cresc. Fevereiro?"	 ,"","","mv_ch9",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par09",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"10","% Cresc. Mar�o?"		 ,"","","mv_cha",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par10",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"11","% Cresc. Abril?"		 ,"","","mv_chb",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par11",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"12","% Cresc. Maio?"		 ,"","","mv_chc",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par12",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"13","% Cresc. Junho?"		 ,"","","mv_chd",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par13",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"14","% Cresc. Julho?"		 ,"","","mv_che",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par14",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"15","% Cresc. Agosto?"		 ,"","","mv_chf",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par15",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"16","% Cresc. Setembro?"	 ,"","","mv_chg",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par16",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"17","% Cresc. Outubro?"		 ,"","","mv_chh",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par17",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"18","% Cresc. Novembro?"	 ,"","","mv_chi",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par18",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"19","% Cresc. Dezembro?"	 ,"","","mv_chj",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par19",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := TamSx3("B1_GRUPO"  )
AADD(aRegs,{cPerg,"20","Do Grupo?"	    		 ,"","","mv_chk",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par20",""                 ,"","","","",""				,"","","","",""	   				,"","","","","","","","","","","","","","SBM","",""})
AADD(aRegs,{cPerg,"21","Ao Grupo?"				 ,"","","mv_chl",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par21",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SBM","",""})
_aTam  := TamSx3("B1_TIPO"   )
AADD(aRegs,{cPerg,"22","Do Tipo?"  			 ,"","","mv_chm",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par22",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
AADD(aRegs,{cPerg,"23","Ao Tipo?"	    		 ,"","","mv_chn",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par23",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})
_aTam  := {01,00,"N"}
AADD(aRegs,{cPerg,"24","Qual Moeda?"			 ,"","","mv_chu",_aTam[03],_aTam[01]	,_aTam[02]	,1,"C","NAOVAZIO()","mv_par24",AllTrim(SuperGetMv("MV_MOEDA1",,"Real")),"","","","",AllTrim(SuperGetMv("MV_MOEDA2",,"D�lar")),"","","","",AllTrim(SuperGetMv("MV_MOEDA3",,"Euro")),"","","","",AllTrim(SuperGetMv("MV_MOEDA4",,"Iene")),"","","","",AllTrim(SuperGetMv("MV_MOEDA5",,"Peso")),"","","",""   ,"",""})
_aTam  := {08,00,"D"}
AADD(aRegs,{cPerg,"25","Data para convers�o?"	 ,"","","mv_chv",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par25",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""   ,"",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_aArea)

Return
