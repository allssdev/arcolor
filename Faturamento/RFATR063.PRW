#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _CRFL CHR(13) + CHR(10)
/*/{Protheus.doc} User Function RFATR063
    LOCALIZAÇÃO : Relatorio baseado no RFATR063 contudo para gerar as informações baseado nos pedidos de venda
    DESCRIÇÃO : 
    @type  Function
    @author Diego Rodrigues
    @since 04/07/2024
    @version 1.0
/*/
user function RFATR063()
	Local   oReport

	Private oSection
	Private _cRotina := "RFATR063"
	Private _cPerg   := _cRotina
	Private _aCpos   := {}
	Private _lMoeda  := .F.

	if FindFunction("TRepInUse") .And. TRepInUse()
		AjPergALL()
		if !Pergunte(_cPerg,.T.)
			return
		endif
		oReport := ReportDef()
		oReport:PrintDialog()
		//while MSGBOX("Deseja processar outro relatório?",_cRotina+"_001","YESNO")
			/* FB - RELEASE 12.1.23
			if !Pergunte(_cPerg,.T.)
				return
			endif
			*/
			//oReport := ReportDef()
			//oReport:PrintDialog()
		//enddo
	endif
return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Anderson C. P. Coelho  ³ Data ³ 06/02/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo uSC5rio.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function ReportDef()
	Local oReport
	//Local oSection
	//Local oBreak
	Local cTitulo  := "VENDAS - Relatório de Totais Vendidos por Produto, por Período"+IIF(!Empty(MV_PAR26)," em "+GetMV("MV_MOEDA"+MV_PAR26+""),"")//+" - Call Center"
	Local _aOrd    := {"Ordem dos Campos"}		//{"Grupo + Produto", "Grupo + Descrição de Produto"}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New(_cRotina,cTitulo,_cPerg,{|oReport| PrtReport(oReport)},"Emissao do relatório, de acordo com o intervalo informado na opção de Parâmetros.")
	oReport:SetLandscape() 
	oReport:SetTotalInLine(.F.)
	Pergunte(oReport:uParam,.F.)
	//Permissão para emissão do relatório por valor
	if MV_PAR05 == 1 .AND. !__cUserId$SuperGetMv("MV_USRVLFT",,"|000000|000045|000046|000047|000048|000019|000028|000171")
		MsgStop("Atenção! Emissão do relatório em valor não autorizada. Sendo assim, o relatório será modificado para emissão em quantidade!",_cRotina+"_004")
		MV_PAR05 := 2
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da secao utilizada pelo relatorio                               ³
	//³TRSection():New                                                         ³
	//³ExpO1 : Objeto TReport que a secao pertence                             ³
	//³ExpC2 : Descricao da seçao                                              ³
	//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
	//³        sera considerada como principal para a seção.                   ³
	//³ExpA4 : Array com as Ordens do relatório                                ³
	//³ExpL5 : Carrega campos do SX3 como celulas                              ³
	//³        Default : False                                                 ³
	//³ExpL6 : Carrega ordens do Sindex                                        ³
	//³        Default : False                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da celulas da secao do relatorio                                ³
	//³                                                                        ³
	//³TRCell():New                                                            ³
	//³ExpO1 : Objeto TSection que a secao pertence                            ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
	//³ExpC3 : Nome da tabela de referencia da celula                          ³
	//³ExpC4 : Titulo da celula                                                ³
	//³        Default : //X3TITULO()                                            ³
	//³ExpC5 : Picture                                                         ³
	//³        Default : X3_PICTURE                                            ³
	//³ExpC6 : Tamanho                                                         ³
	//³        Default : X3_TAMANHO                                            ³
	//³ExpL7 : Informe se o tamanho esta em pixel                              ³
	//³        Default : False                                                 ³
	//³ExpB8 : Bloco de código para impressao.                                 ³
	//³        Default : ExpC2                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Secao dos itens do Pedido de Vendas                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection := TRSection():New(oReport,"RELATÓRIO DE ITENS VENDIDOS - QTD. E VALOR",{"SC6","SC5","SB1","SA1","SA3"},_aOrd/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)
	//Identificação dos campos em uso, mas identificarmos depois os campos adicionados pelo usuário, para que possamos o incluir na query.
	/*
	_aCpos := {	"B1_GRUPO",;
				"B1_TIPO" ,;
				"B1_COD"  ,;
				"B1_DESC" ,;
				"B1_UM"   }
	*/
	//Definição das colunas do relatório
	TRCell():New(oSection,"B1_GRUPO"    ,"SB1"/*Tabela*/,RetTitle("B1_GRUPO"  ),PesqPict  ("SB1","B1_GRUPO"),TamSx3("B1_GRUPO")[1],/*lPixel*/,{|| (_cSC6TMP)->B1_GRUPO       																	})	// Grupo de Produto
	//TRCell():New(oSection,"B1_TIPO"     ,"SB1"/*Tabela*/,RetTitle("B1_TIPO"	  ),PesqPict  ("SB1","B1_TIPO" ),TamSx3("B1_TIPO" )[1],/*lPixel*/,{|| SC6TMP->B1_TIPO        																	})	// Tipo de Produto
	TRCell():New(oSection,"B1_COD"      ,"SB1"/*Tabela*/,RetTitle("B1_COD"    ),PesqPict  ("SB1","B1_COD"  ),TamSx3("B1_COD"  )[1],/*lPixel*/,{|| (_cSC6TMP)->B1_COD         																	})	// Codigo do Produto
	TRCell():New(oSection,"B1_DESC"     ,"SB1"/*Tabela*/,RetTitle("B1_DESC"   ),PesqPict  ("SB1","B1_DESC" ),TamSx3("B1_DESC" )[1],/*lPixel*/,{|| (_cSC6TMP)->B1_DESC      		                                               					})	// Descricao do Produto
	TRCell():New(oSection,"B1_UM"       ,"SB1"/*Tabela*/,RetTitle("B1_UM"	  ),PesqPict  ("SB1","B1_UM"   ),TamSx3("B1_UM"   )[1],/*lPixel*/,{|| (_cSC6TMP)->B1_UM          																	})	// Unidade de Medida
	//TRCell():New(oSection,"C6_QUANT"    ,"SC6"/*Tabela*/,RetTitle("C6_QUANT"  ),PesqPictQt("D2_QUANT"		    ),TamSx3("D2_QUANT"		)[1],/*lPixel*/,{|| SC6TMP->C6_QUANT       																	})	// Quantidade
	//TRCell():New(oSection,"C6_VLRITEM"  ,"SC6"/*Tabela*/,RetTitle("C6_VLRITEM"),PesqPict  ("SD2","D2_TOTAL"		),TamSx3("D2_TOTAL"		)[1],/*lPixel*/,{|| SC6TMP->C6_VLRITEM	     																})	// Valor Total
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
	//oBreak := TRBreak():New(oSection,oSection:Cell("B1_COD"),"SC6-Total Produtos")
	//TRFunction():New(oSection:Cell("C6_QUANT"  ),NIL,"SUM",oBreak)
	//TRFunction():New(oSection:Cell("C6_VLRITEM"),NIL,"SUM",oBreak)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Troca descricao do total dos itens                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oReport:Section(1):SetTotalText("T O T A I S ")
	//Efetuo o relacionamento entre as tabelas
	//TRPosition():New(oSection,"SC5",1,{|| xFilial("SC5") + SC6->C6_NUM    })
	//TRPosition():New(oSection,"SB1",1,{|| xFilial("SB1") + SC6->C6_PRODUTO})
	//oReport:Section(2):SetEdit(.F.) 
	//oReport:Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de uSC5rio no relatorio qdo utiliza query
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alinhamento a direita as colunas de valor                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oSection:Cell("C6_QUANT"  ):SetHeaderAlign("RIGHT")
	//oSection:Cell("C6_VLRITEM"):SetHeaderAlign("RIGHT")
return oReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrtReport  ºAutor ³Anderson C. P. Coelho º Data ³  06/02/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento das informações para impressão (Print).       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function PrtReport(oReport)
	//Local oSection := oReport:Section(1)
    Local _x :=0
    Local _k := 0
	//Local _cTpOper := "%"+FormatIn(SuperGetMv("MV_FATOPER",,"01|ZZ|9"),"|")+"%"
	//Local _cTpCons := "%"+FormatIn(SuperGetMv("MV_XOPECON",,"06"),"|")+"%"
	Local _cCpoSum := ""
	Local _cFlOper := ""
	Local _cOrder  := ""
	Local _cField  := ""
	Local _cTotal  := ""
	Local _cPivot  := ""
	Local _cMesAno := ""
	Local _cMedia  := ""
	Local _cFilSC5 := oSection:GetSqlExp("SC5")
	Local _cFilSC6 := oSection:GetSqlExp("SC6")
	Local _cFilSB1 := oSection:GetSqlExp("SB1")
	Local _cFilSA1 := oSection:GetSqlExp("SA1")
	Local _cFilSA3 := oSection:GetSqlExp("SA3")
	Local _dData   := STOD("")
	Local _aCols   := {}
	Local _nBreak  := 0
	Local _nFator  := 0
	Local _nTotBrk := MV_PAR07		//Total de Breaks permitidos (níveis)
	Private _cSC6TMP := ""


	if MV_PAR01 > MV_PAR02 .OR. MV_PAR03 > MV_PAR04
		MsgStop("Parâmetros informados incorretamente!",_cRotina+"_002")
		return
	endif
	//Permissão para emissão do relatório por valor
	if MV_PAR05 == 1 .AND. !__cUserId$SuperGetMv("MV_USRVLFT",,"|000000|000045|000046|000047|000048|000019|000028|")
		MsgStop("Atenção! Emissão do relatório em valor não autorizada. Sendo assim, o relatório será modificado para emissão em quantidade!",_cRotina+"_005")
		MV_PAR05 := 2
	endif
	// Verifica a moeda selecionada
	if !(Empty(MV_PAR26)) .And. MV_PAR26 <> '1'
		dbSelectArea("SM2")
		SM2->(dbSetOrder(1)) // M2_DATA
		if SM2->(MsSeek(MV_PAR27,.T.,.F.))
			if !Empty(&("M2_MOEDA"+MV_PAR26))
				_lMoeda := .T.
			else
				MSGBOX("Não existe cotação cadastrada para a moeda "+GetMV("MV_MOEDA"+MV_PAR26+"")+" em "+DtoC(MV_PAR27)+". Verifique o cadastro de moedas.",_cRotina+"_000","STOP")
				return
			endif
		endif
	endif
	//Definição do campo a ser apresentado/totalizado
	if MV_PAR05 == 1		//Valor
		if _lMoeda
            _cCpoSum := ", C6_VALOR * ISNULL(SM2.M2_MOEDA,1)"+MV_PAR26+" [VALOR]"
		else
			_cCpoSum := ", C6_VALOR [VALOR]"
		endif
	ElseIf MV_PAR05 == 3
		_cCpoSum := ", C6_QTDVEN * B1_PESO   [VALOR]"
	else
		_cCpoSum := ", C6_QTDVEN   [VALOR]"
	endif
	//Filtragens específicas para a query
	if MV_PAR06 == 1
		_cFlOper := "% AND SC5.C5_TPOPER IN " + FormatIn(SuperGetMv("MV_FATOPER",,"01|ZZ|9"),"|") + "%"
	elseif MV_PAR06 == 2
		_cFlOper := "%	AND SC5.C5_TPOPER  NOT IN " + FormatIn(SuperGetMv("MV_XOPENVE",,"01|ZZ|9|VC"),"|") + "%"
	elseif MV_PAR06 == 3
		_cFlOper := "%	AND SC5.C5_TPOPER  NOT IN " + FormatIn(SuperGetMv("MV_XOPEVCO",,"VC"),"|") + "%"
	elseif MV_PAR06 == 4
		_cFlOper := "%	AND SC5.C5_TPOPER  IN " + FormatIn(SuperGetMv("MV_XOPECON",,"06"),"|") + "%"
	ElseIf MV_PAR06 == 5 
		_cFlOper := "%	AND SC5.C5_TPOPER  IN " + FormatIn(SuperGetMv("MV_XOPEVCO",,"VC"),"|") + "%"
	endif
	if !Empty(_cFilSC5)
		if Empty(_cFlOper)
			_cFilSC5 := "%AND "+_cFilSC5+"%"
		else
			_cFilSC5 := "%AND "+_cFilSC5+" "+StrTran(_cFlOper,"%","")+"%"
		endif
	else
		_cFilSC5 := _cFlOper
	endif
	if Empty(_cFilSC5)
		_cFilSC5 := "%AND 0 = 0%"
	endif
	if !Empty(_cFilSC6)
		_cFilSC6 := "%AND "+_cFilSC6+"%"
	endif
	if Empty(_cFilSC6)
		_cFilSC6 := "%AND 0 = 0%"
	endif
	if !Empty(_cFilSB1)
		_cFilSB1 := "%AND "+_cFilSB1+"%"
	endif
	if Empty(_cFilSB1)
		_cFilSB1 := "%AND 0 = 0%"
	endif
	if !Empty(_cFilSA1)
		_cFilSA1 := "%AND "+_cFilSA1+"%"
	endif
	if Empty(_cFilSA1)
		_cFilSA1 := "%AND 0 = 0%"
	endif
	if !Empty(_cFilSA3)
		_cFilSA3 := "%AND "+_cFilSA3+"%"
	endif
	if Empty(_cFilSA3)
		_cFilSA3 := "%AND 0 = 0%"
	endif
	//Definição da ordem de apresentação das informações
	//Definição das colunas de datas (Mês/Ano)
	_dData   := MV_PAR03
	while SubStr(DTOS(_dData),1,6) <= SubStr (DTOS(MV_PAR04),1,6)
		if !Empty(_dData)
			_cMesAno  := "["+SubStr(DTOS(_dData),1,6)+"]"
			_cCMesAno := SubStr(UPPER(cMonth(_dData)),1,3)+"_"+SubStr(DTOS(_dData),1,4)
			_nFator   := 1 + &("MV_PAR"+StrZero(7+Val(SubStr(_cMesAno,6,2)),2)) / 100
			AADD( _aCols, {	_cMesAno                           , ;
							"(IsNull("+_cMesAno+",0)*" + cValToChar(_nFator) + ") "+_cCMesAno, ;
							SubStr(DTOC(_dData),4)             , ;
							_cCMesAno                          } )
		endif
		_dData   := LastDay(_dData,0)+1
	enddo
	if len(_aCols) == 0
		MsgStop("Nenhuma data selecionada!",_cRotina+"_003")
		return
	else
		//Inclusão dos campos definidos pelo usuário na Query e definição da ordem dinâmica e SC6-totais dinâmicos para o relatório
		for _x := 1 To len(_aCols)			
			if MV_PAR05 == 1	//Valor
				&('TRCell():New(oSection,"'+_aCols[_x][04]+'", _cSC6TMP /*Tabela*/,"'+_aCols[_x][03]+'","@E 99,999,999,999.99"         , 28                  ,/*lPixel*/,{|| Round((_cSC6TMP)->'+_aCols[_x][04]+',TamSx3("D2_TOTAL")[02]) })')	// Valor Total de Mercadorias
			elseif MV_PAR05 == 2	//Quantidade
				&('TRCell():New(oSection,"'+_aCols[_x][04]+'", _cSC6TMP /*Tabela*/,"'+_aCols[_x][03]+'","@E 99,999,999,999.99"         , 28                  ,/*lPixel*/,{|| Round((_cSC6TMP)->'+_aCols[_x][04]+',TamSx3("D2_QUANT")[02]) })')	// Quantidade
			elseif MV_PAR05 == 3	//Peso Liquido
				&('TRCell():New(oSection,"'+_aCols[_x][04]+'", _cSC6TMP /*Tabela*/,"'+_aCols[_x][03]+'","@E 99,999,999,999.99"         , 28                  ,/*lPixel*/,{|| Round((_cSC6TMP)->'+_aCols[_x][04]+',TamSx3("D2_PESO")[02]) })')	// Quantidade
			
			endif
			if !Empty(_cTotal)
				_cTotal += "+"
			endif
			_cTotal += "IsNull("+_aCols[_x][01]+",0)"
			if !Empty(_cPivot)
				_cPivot += ", "
			endif
			_cField += ", " + _aCols[_x][02]
			_cPivot +=        _aCols[_x][01]
		next
		if MV_PAR05 == 1	//Valor
			TRCell():New(oSection,"TOTAL",_cSC6TMP/*Tabela*/,"TOTAL", "@E 999,999,999,999.99"       , 35                    ,/*lPixel*/,{|| Round((_cSC6TMP)->TOTAL,TamSx3("D2_TOTAL")[02]) })	// Valor Total
		elseif MV_PAR05 == 2	//Quantidade
			TRCell():New(oSection,"TOTAL",_cSC6TMP/*Tabela*/,"TOTAL", "@E 999,999,999,999.99"       , 35                    ,/*lPixel*/,{|| Round((_cSC6TMP)->TOTAL,TamSx3("D2_QUANT")[02]) })	// Quantidade
		elseif MV_PAR05 == 3	//Peso
			TRCell():New(oSection,"TOTAL",_cSC6TMP/*Tabela*/,"TOTAL", "@E 999,999,999,999.99"       , 35                    ,/*lPixel*/,{|| Round((_cSC6TMP)->TOTAL,TamSx3("D2_PESO")[02]) })	// Peso Liquido
		endif
		if !Empty(_cTotal)
			_cMedia := "("+_cTotal+") / "+cValToChar(len(_aCols))
		endif
		if Empty(_cMedia)
			_cMedia := "0"
		endif
		if MV_PAR05 == 3		//Valor Total
			TRCell():New(oSection,"MEDIA", _cSC6TMP/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSC6TMP)->MEDIA,TamSx3("D2_VALBRUT")[02]) })// Valor Total
		elseif MV_PAR05 == 2	//Quantidade
			TRCell():New(oSection,"MEDIA", _cSC6TMP/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSC6TMP)->MEDIA,TamSx3("D2_QUANT"  )[02]) })// Quantidade
		elseif MV_PAR05 == 3	//Quantidade
			TRCell():New(oSection,"MEDIA", _cSC6TMP/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSC6TMP)->MEDIA,TamSx3("D2_PESO"  )[02]) })// Peso Liquido
		else					//Valor das Mercadorias
			TRCell():New(oSection,"MEDIA", _cSC6TMP/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSC6TMP)->MEDIA,TamSx3("D2_TOTAL"  )[02]) })// Valor das Mercadorias
		endif
		for _x := 1 To len(oSection:aCell)
			if !Empty(oSection:aCell[_x]:cAlias) .AND. AllTrim(oSection:aCell[_x]:cAlias) <> (_cSC6TMP)
				if aScan(_aCpos, AllTrim(oSection:aCell[_x]:cName)) == 0
					if oSection:aCell[_x]:lUserEnabled
						_cCpoSum += ", " + AllTrim(oSection:aCell[_x]:cName)
						_cField  += ", " + AllTrim(oSection:aCell[_x]:cName)
					else
						_cCpoSum += ", '' " + AllTrim(oSection:aCell[_x]:cName)
						_cField  += ", '' " + AllTrim(oSection:aCell[_x]:cName)
					endif
				endif
				if oSection:aCell[_x]:lUserEnabled
					if !Empty(_cOrder)
						_cOrder += ", "
					endif
					_cOrder  += AllTrim(oSection:aCell[_x]:cName)
					_nBreak++
					if _nTotBrk > 0 .AND. _nBreak <= _nTotBrk
						//Break dos campos segundo a SC5 ordem definida pelo usuário
						&("oBreak"+cValToChar(_nBreak)) := TRBreak():New(oSection,oSection:Cell(AllTrim(oSection:aCell[_x]:cName)),"SC6-Total - " + AllTrim(oSection:aCell[_x]:cTitle))
						//SC6-Totais - Soma das colunas de valores/quantidades
						if len(_aCols) > 0
							for _k := 1 To len(_aCols)
								TRFunction():New(oSection:Cell(_aCols[_k][03]),NIL,"SUM",&("oBreak"+cValToChar(_nBreak)))
							next
							TRFunction():New(oSection:Cell("TOTAL"),NIL,"SUM",&("oBreak"+cValToChar(_nBreak)))
							TRFunction():New(oSection:Cell("MEDIA"),NIL,"SUM",&("oBreak"+cValToChar(_nBreak)))
						endif
					endif
				endif
			endif
			if _nTotBrk == 0
				//SC6-Totais - Soma das colunas de valores/quantidades
				if len(_aCols) > 0
					for _k := 1 To len(_aCols)
						TRFunction():New(oSection:Cell(_aCols[_k][03]),NIL,"SUM")
					next
					TRFunction():New(oSection:Cell("TOTAL"),NIL,"SUM")
					TRFunction():New(oSection:Cell("MEDIA"),NIL,"SUM")
				endif
			endif
		next
	endif
	_cTotal  := ", ("+_cTotal+") [TOTAL]"
	_cMedia  := ", ("+_cMedia+") [MEDIA]"
	_cCpoSum := "%" + _cCpoSum + "%"
	_cField  := "%" + _cField  + _cTotal + _cMedia + "%"
	_cPivot  := "%" + _cPivot  + "%"
	_cOrder  := "%" + IIF(MV_PAR28==2,"MEDIA DESC, ","") + "B1_FILIAL, " + _cOrder  + "%"
	//Elimino os filtros do usuário para evitar duplicidades na query, uma vez que já estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
	for _x := 1 To len(oSection:AUSERFILTER)
		oSection:AUSERFILTER[_x][02] := oSection:AUSERFILTER[_x][03] := ""
	next
	oSection:CSQLEXP := ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alinhamento a direita as colunas de valor                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if len(_aCols) > 0
		for _x := 1 To len(_aCols)
			oSection:Cell(_aCols[_x][03]):SetHeaderAlign("RIGHT")
		next
		oSection:Cell("TOTAL"):SetHeaderAlign("RIGHT")
		oSection:Cell("MEDIA"):SetHeaderAlign("RIGHT")
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Troca descricao do total dos itens                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):SetTotalText("T O T A I S ")
	//PROCESSAMENTO DAS INFORMAÇÕES PARA IMPRESSÃO
	//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
	MakeSqlExpr(oReport:uParam)
	_cSC6TMP := GetNextAlias()
	oSection:BeginQuery()
	BeginSql alias _cSC6TMP
		SELECT B1_FILIAL %Exp:_cField%
		FROM (
				SELECT B1_FILIAL, SubStrING(C5_EMISSAO,1,6) [EMISSAO]
						%Exp:_cCpoSum%
				FROM %table:SC6% SC6 (NOLOCK)
					INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.%notDel%
											AND SB1.B1_FILIAL        = %xFilial:SB1%
											AND SB1.B1_COD     BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
											AND SB1.B1_COD           = SC6.C6_PRODUTO
											%Exp:_cFilSB1%
					INNER JOIN %table:SC5% SC5 (NOLOCK) ON SC5.%notDel%
											AND SC5.C5_FILIAL        = %xFilial:SC5%
											AND SC5.C5_EMISSAO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
											AND SC5.C5_NUM           = SC6.C6_NUM
											%Exp:_cFilSC5%
					INNER JOIN %table:SA1% SA1 (NOLOCK) ON SA1.%notDel%
											AND SA1.A1_FILIAL        = %xFilial:SA1%
											AND SA1.A1_COD     BETWEEN %Exp:mv_par20% AND %Exp:mv_par22%
											AND SA1.A1_LOJA    BETWEEN %Exp:mv_par21% AND %Exp:mv_par23%
											AND SA1.A1_COD           = SC5.C5_CLIENTE
											AND SA1.A1_LOJA          = SC5.C5_LOJACLI
											%Exp:_cFilSA1%
					INNER JOIN %table:SA3% SA3 (NOLOCK) ON SA3.%notDel%
											AND SA3.A3_FILIAL        = %xFilial:SA3%
											AND SA3.A3_COD     BETWEEN %Exp:mv_par24% AND %Exp:mv_par25%
											AND SA3.A3_COD           = SC5.C5_VEND1
											%Exp:_cFilSA3%
					LEFT OUTER JOIN %table:SM2% SM2 (NOLOCK) ON SM2.%notDel%
											AND SM2.M2_DATA          = %Exp:mv_par27%

				WHERE SC6.%notDel%
				  AND SC6.C6_FILIAL  = %xFilial:SC6%
				  %Exp:_cFilSC6%
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
	oSection:EndQuery()
	MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",oSection:CQUERY)
	oSection:Print()
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjPergALL ºAutor  ³Anderson C. P. Coelho º Data ³  06/02/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se as perguntas existem na SX1. Caso não existam,  º±±
±±º          ³as cria.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function AjPergALL()
	Local _aArea   := GetArea()

	_cPerg    := PADR(_cPerg,10)
	_aTam     := TamSx3("B1_COD"    )
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := "SB1"
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o código inicial dos produtos   "
	U_RGENA001(_cPerg, "01" ,"Do Produto?" , "MV_PAR01", "MV_CH1", "C", _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := "NAOVAZIO()"
	_cF3      := "SB1"
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o código inicial dos produtos   "
	U_RGENA001(_cPerg, "02" ,"Ao Produto?" , "MV_PAR02", "MV_CH2", "C", _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := TamSx3("C5_EMISSAO")
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe a data de emissão inicial a ser considerada."
	U_RGENA001(_cPerg, "03" ,"Da Emissão?" , "MV_PAR03", "MV_CH3", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := "NAOVAZIO()"
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe a data de emissão final a ser considerada."
	U_RGENA001(_cPerg, "04" ,"Até a Emissão?" , "MV_PAR04", "MV_CH4", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := {01,00,"N"}
	_cPerg    := _cPerg
	_cValid   := "NAOVAZIO()"
	_cF3      := ""
	_cPicture := ""
	_cDef01   := "Valor Merc."
	_cDef02   := "Quantidade"
	_cDef03   := "Peso Liquido"
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o tipo de valor a ser acumulado por período, sendo: 1) Valor das Mercadorias; 2) Quantidade."
	U_RGENA001(_cPerg, "05" ,"Tipo de Informação?" , "MV_PAR05", "MV_CH5", _aTam[03], _aTam[01], _aTam[02], "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := "NAOVAZIO()"
	_cF3      := ""
	_cPicture := ""
	_cDef01   := "Somente Vendas"
	_cDef02   := "Não Vendas"
	_cDef03   := "Ambos"
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o tipo operação a ser           "  
	_cHelp    += "considerado, sendo:                     " 
	_cHelp    += "  1) Somento Vendas (desconsidera-se os " 
	_cHelp    += "     registros que não geram financeiro," 
	_cHelp    += "     os itenficados como trocas);       " 
	_cHelp    += "  2) Não Vendas (consideram-se aqui     " 
	_cHelp    += "     somente as trocas e os registros   " 
	_cHelp    += "     que não geraram financeiro).       " 
	_cHelp    += "  3) Ambos (consideram-se aqui todas os " 
	_cHelp    += "     documentos de saída com exeção 	  "
	_cHelp    += "     da Operação VC).                   " 
	_cHelp    += "  4) Consignado (consideram-se aqui	  "
	_cHelp    += "     somente as vendas de consignação   " 
	_cHelp    += "     da operação 06) 					  " 
	_cHelp    += "  5) Venda consignada (consideram-se    " 
	_cHelp    += "     somente o faturamento de  	  	  "
	_cHelp    += "     consignação da Operação VC).       " 
	_cHelp    += "*É importante observar que as devoluções" 
	_cHelp    += "não são aqui consideradas.              " 
	U_RGENA001(_cPerg, "06" ,"Operação?" , "MV_PAR06", "MV_CH6", _aTam[03], _aTam[01], _aTam[02], "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := {03,00,"N"}
	_cPerg    := _cPerg
	_cValid   := "Positivo()"
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe, da esquerda para a direita,    " 
	_cHelp    += "quantos níveis serão SC6-totalizados no " 
	_cHelp    += "relatório. Por exemplo: Se as duas      " 
	_cHelp    += "primeiras colunas do relatório forem de " 
	_cHelp    += "'Representante' e, na sequencia, 'Cliente', e" 
	_cHelp    += "você solicitar a SC6-totalização de 2   " 
	_cHelp    += "níveis, o relatório criará um SC6-total " 
	_cHelp    += "por representante e, dentro de cada representante," 
	_cHelp    += "um SC6-total por cliente.               "  
	_cHelp    += "Se não quiser SC6-totais, informe zero. " 
	U_RGENA001(_cPerg, "07" ,"Níveis para SC6-Totais?" , "MV_PAR07", "MV_CH7", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := {06,02,"N"}
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de janeiro        " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "   
	U_RGENA001(_cPerg, "08" ,"% Cresc. Janeiro?" , "MV_PAR08", "MV_CH8", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de fevereiro      " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "09" ,"% Cresc. Fevereiro?" , "MV_PAR09", "MV_CH9", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de março          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "10" ,"% Cresc. Março?" , "MV_PAR09", "MV_CHA", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de abril          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "11" ,"% Cresc. Abril?" , "MV_PAR11", "MV_CHB", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de maio          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "12" ,"% Cresc. Maio?" , "MV_PAR12", "MV_CHC", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de junho          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "13" ,"% Cresc. Junho?" , "MV_PAR13", "MV_CHD", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de julho          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "14" ,"% Cresc. Julho?" , "MV_PAR14", "MV_CHE", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de agosto          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "15" ,"% Cresc. Agosto?" , "MV_PAR15", "MV_CHF", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de setembro          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "16" ,"% Cresc. Setembro?" , "MV_PAR16", "MV_CHG", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de outubro          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "17" ,"% Cresc. Outubro?" , "MV_PAR17", "MV_CHH", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de novembro          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "18" ,"% Cresc. Novembro?" , "MV_PAR18", "MV_CHI", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Se necessário, informe um percentual de " 
	_cHelp    += "incremento a ser considerado para o     " 
	_cHelp    += "faturamento dos meses de dezembro          " 
	_cHelp    += "(utilizado meramente para simulações de " 
	_cHelp    += "crescimento).                           "    
	U_RGENA001(_cPerg, "19" ,"% Cresc. Dezembro?" , "MV_PAR19", "MV_CHJ", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := TamSx3("A1_COD"    )
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := "SA1"
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o código de cliente inicial para processamento." 
	U_RGENA001(_cPerg, "20" ,"Do Cliente?" , "MV_PAR20", "MV_CHL", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := TamSx3("A1_LOJA"   )
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o código da loja do cliente inicial para processamento." 
	U_RGENA001(_cPerg, "21" ,"Da Loja?" , "MV_PAR21", "MV_CHM", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := TamSx3("A1_COD"    )
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := "SA1"
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o código de cliente final para processamento." 
	U_RGENA001(_cPerg, "22" ,"Ao Cliente?" , "MV_PAR22", "MV_CHN", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := TamSx3("A1_LOJA"   )
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o código da loja do cliente final para processamento." 
	U_RGENA001(_cPerg, "23" ,"Até a Loja?" , "MV_PAR23", "MV_CHO", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := TamSx3("A3_COD"    )
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := "SA3"
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o código representante inicial para processamento." 
	U_RGENA001(_cPerg, "24" ,"Do Representante?" , "MV_PAR24", "MV_CHP", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := "NAOVAZIO()"
	_cF3      := "SA3"
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe o código representante final para processamento." 
	U_RGENA001(_cPerg, "25" ,"Ao Representante?" , "MV_PAR25", "MV_CHQ", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := "NAOVAZIO()"
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe em qual moeda o relatório deve ser impresso." 
	U_RGENA001(_cPerg, "26" ,"Moeda para conversão?" , "MV_PAR26", "MV_CHR", "C", 01, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := ""
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Insira a data da cotação da moeda para realização do cálculo de conversão." 
	U_RGENA001(_cPerg, "27" ,"Data da Cotação?"  , "MV_PAR27", "MV_CHS", "D", 08, 0, "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam  := {01,00,"N"}
	_cPerg    := _cPerg
	_cValid   := "NAOVAZIO()"
	_cF3      := ""
	_cPicture := ""
	_cDef01   := "Nao"
	_cDef02   := "Sim"
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""
	_cHelp    := "Informe se deseja ordenar o relatorio pela média mensal ou não (ranking)." 
	U_RGENA001(_cPerg, "28" ,"Ordena pela Média?"  , "MV_PAR28", "MV_CHT", _aTam[03]	,_aTam[01]	,_aTam[02], "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	RestArea(_aArea)
return
