#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _CRFL CHR(13) + CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATR029  ºAutor  ³Anderson C. P. Coelho º Data ³  06/02/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de totais vendidos por produto por periodo, mes  º±±
±±º          ³a mes, baseado nos atendimentos do Call Center de qualquer  º±±
±±º          ³status. O relatório apresentará e somará quantidades ou     º±±
±±º          ³valores de mercadorias conforme parametrização do usuário.  º±±
±±º          ³Também conforme parametrização, o relatório apresentará     º±±
±±º          ³Somente Vendas, Somente o que não for Venda ou Ambos.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Especifico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function RFATR029()
	Local   oReport

	Private oSection
	Private _cRotina := "RFATR029"
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
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
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
	Local cTitulo  := "CALL CENTER - Relatório de Totais Vendidos por Produto, por Período"+IIF(!Empty(MV_PAR26)," em "+GetMV("MV_MOEDA"+MV_PAR26+""),"")//+" - Call Center"
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
	oSection := TRSection():New(oReport,"RELATÓRIO DE ITENS VENDIDOS - QTD. E VALOR",{"SUB","SUA","SB1","SA1","SA3"},_aOrd/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
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
	TRCell():New(oSection,"B1_GRUPO"    ,"SB1"/*Tabela*/,RetTitle("B1_GRUPO"  ),PesqPict  ("SB1","B1_GRUPO"),TamSx3("B1_GRUPO")[1],/*lPixel*/,{|| (_cSUBTMP)->B1_GRUPO       																	})	// Grupo de Produto
	//TRCell():New(oSection,"B1_TIPO"     ,"SB1"/*Tabela*/,RetTitle("B1_TIPO"	  ),PesqPict  ("SB1","B1_TIPO" ),TamSx3("B1_TIPO" )[1],/*lPixel*/,{|| SUBTMP->B1_TIPO        																	})	// Tipo de Produto
	TRCell():New(oSection,"B1_COD"      ,"SB1"/*Tabela*/,RetTitle("B1_COD"    ),PesqPict  ("SB1","B1_COD"  ),TamSx3("B1_COD"  )[1],/*lPixel*/,{|| (_cSUBTMP)->B1_COD         																	})	// Codigo do Produto
	TRCell():New(oSection,"B1_DESC"     ,"SB1"/*Tabela*/,RetTitle("B1_DESC"   ),PesqPict  ("SB1","B1_DESC" ),TamSx3("B1_DESC" )[1],/*lPixel*/,{|| (_cSUBTMP)->B1_DESC      		                                               					})	// Descricao do Produto
	TRCell():New(oSection,"B1_UM"       ,"SB1"/*Tabela*/,RetTitle("B1_UM"	  ),PesqPict  ("SB1","B1_UM"   ),TamSx3("B1_UM"   )[1],/*lPixel*/,{|| (_cSUBTMP)->B1_UM          																	})	// Unidade de Medida
	//TRCell():New(oSection,"UB_QUANT"    ,"SUB"/*Tabela*/,RetTitle("UB_QUANT"  ),PesqPictQt("D2_QUANT"		    ),TamSx3("D2_QUANT"		)[1],/*lPixel*/,{|| SUBTMP->UB_QUANT       																	})	// Quantidade
	//TRCell():New(oSection,"UB_VLRITEM"  ,"SUB"/*Tabela*/,RetTitle("UB_VLRITEM"),PesqPict  ("SD2","D2_TOTAL"		),TamSx3("D2_TOTAL"		)[1],/*lPixel*/,{|| SUBTMP->UB_VLRITEM	     																})	// Valor Total
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
	//oBreak := TRBreak():New(oSection,oSection:Cell("B1_COD"),"Sub-Total Produtos")
	//TRFunction():New(oSection:Cell("UB_QUANT"  ),NIL,"SUM",oBreak)
	//TRFunction():New(oSection:Cell("UB_VLRITEM"),NIL,"SUM",oBreak)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Troca descricao do total dos itens                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oReport:Section(1):SetTotalText("T O T A I S ")
	//Efetuo o relacionamento entre as tabelas
	//TRPosition():New(oSection,"SUA",1,{|| xFilial("SUA") + SUB->UB_NUM    })
	//TRPosition():New(oSection,"SB1",1,{|| xFilial("SB1") + SUB->UB_PRODUTO})
	//oReport:Section(2):SetEdit(.F.) 
	//oReport:Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alinhamento a direita as colunas de valor                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oSection:Cell("UB_QUANT"  ):SetHeaderAlign("RIGHT")
	//oSection:Cell("UB_VLRITEM"):SetHeaderAlign("RIGHT")
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
	Local _cTpOper := "%"+FormatIn(SuperGetMv("MV_FATOPER",,"01|ZZ|9"),"|")+"%"
	Local _cTpCons := "%"+FormatIn(SuperGetMv("MV_XOPECON",,"06"),"|")+"%"
	Local _cTpVC   := "%"+FormatIn(SuperGetMv("MV_XOPEVCO",,"VC"),"|")+"%"
	Local _cTpNVen := "%"+FormatIn(SuperGetMv("MV_XOPENVE",,"01|ZZ|9|VC"),"|")+"%" //Não venda
	Local _cCpoSum := ""
	Local _cFlOper := ""
	Local _cOrder  := ""
	Local _cField  := ""
	Local _cTotal  := ""
	Local _cPivot  := ""
	Local _cMesAno := ""
	Local _cMedia  := ""
	Local _cFilSUA := oSection:GetSqlExp("SUA")
	Local _cFilSUB := oSection:GetSqlExp("SUB")
	Local _cFilSB1 := oSection:GetSqlExp("SB1")
	Local _cFilSA1 := oSection:GetSqlExp("SA1")
	Local _cFilSA3 := oSection:GetSqlExp("SA3")
	Local _dData   := STOD("")
	Local _aCols   := {}
	Local _nBreak  := 0
	Local _nFator  := 0
	Local _nTotBrk := MV_PAR07		//Total de Breaks permitidos (níveis)
	Private _cSUBTMP := ""


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
			_cCpoSum := ", UB_VLRITEM * ISNULL(SM2.M2_MOEDA,1)"+MV_PAR26+" [VALOR]"
		else
			_cCpoSum := ", UB_VLRITEM [VALOR]"
		endif
	ElseIf MV_PAR05 == 3
		_cCpoSum := ", UB_QUANT * B1_PESO   [VALOR]"
	else
		_cCpoSum := ", UB_QUANT   [VALOR]"
	endif
	//Filtragens específicas para a query
	if MV_PAR06 == 1
		_cFlOper := "% AND SUA.UA_TPOPER IN " + FormatIn(SuperGetMv("MV_FATOPER",,"01|ZZ|9"),"|") + "%"
	elseif MV_PAR06 == 2
		_cFlOper := "%	AND SUA.UA_TPOPER  NOT IN " + FormatIn(SuperGetMv("MV_XOPENVE",,"01|ZZ|9|VC"),"|") + "%"
	elseif MV_PAR06 == 3
		_cFlOper := "%	AND SUA.UA_TPOPER  NOT IN " + FormatIn(SuperGetMv("MV_XOPEVCO",,"VC"),"|") + "%"
	elseif MV_PAR06 == 4
		_cFlOper := "%	AND SUA.UA_TPOPER  IN " + FormatIn(SuperGetMv("MV_XOPECON",,"06"),"|") + "%"
	ElseIf MV_PAR06 == 5 
		_cFlOper := "%	AND SUA.UA_TPOPER  IN " + FormatIn(SuperGetMv("MV_XOPEVCO",,"VC"),"|") + "%"
	endif
	if !Empty(_cFilSUA)
		if Empty(_cFlOper)
			_cFilSUA := "%AND "+_cFilSUA+"%"
		else
			_cFilSUA := "%AND "+_cFilSUA+" "+StrTran(_cFlOper,"%","")+"%"
		endif
	else
		_cFilSUA := _cFlOper
	endif
	if Empty(_cFilSUA)
		_cFilSUA := "%AND 0 = 0%"
	endif
	if !Empty(_cFilSUB)
		_cFilSUB := "%AND "+_cFilSUB+"%"
	endif
	if Empty(_cFilSUB)
		_cFilSUB := "%AND 0 = 0%"
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
	/*
	if oReport:Section(1):GetOrder() == 1			//Ordem por Grupo+Produto
		_cOrder := "MEDIA DESC, B1_GRUPO, B1_COD , B1_DESC"
	elseif oReport:Section(1):GetOrder() == 2		//Ordem por Grupo+Descrição
		_cOrder := "MEDIA DESC, B1_GRUPO, B1_DESC, B1_COD "
	else
		_cOrder := "MEDIA DESC, B1_GRUPO, B1_COD , B1_DESC"
	endif
	*/
	//Definição das colunas de datas (Mês/Ano)
	_dData   := MV_PAR03
	while SubStr(DTOS(_dData),1,6) <= SubStr(DTOS(MV_PAR04),1,6)
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
		//Inclusão dos campos definidos pelo usuário na Query e definição da ordem dinâmica e sub-totais dinâmicos para o relatório
		for _x := 1 To len(_aCols)			
			if MV_PAR05 == 1	//Valor
	//			&('TRCell():New(oSection,"'+_aCols[_x][04]+'", "SUBTMP"/*Tabela*/,"'+_aCols[_x][03]+'",PesqPict  ("SD2","D2_TOTAL"),TamSx3("D2_TOTAL")[1],/*lPixel*/,{|| SUBTMP->'+_aCols[_x][04]+'   })')	// Valor Total de Mercadorias
				&('TRCell():New(oSection,"'+_aCols[_x][04]+'", _cSUBTMP /*Tabela*/,"'+_aCols[_x][03]+'","@E 99,999,999,999.99"         , 28                  ,/*lPixel*/,{|| Round((_cSUBTMP)->'+_aCols[_x][04]+',TamSx3("D2_TOTAL")[02]) })')	// Valor Total de Mercadorias
			elseif MV_PAR05 == 2	//Quantidade
	//			&('TRCell():New(oSection,"'+_aCols[_x][04]+'", "SUBTMP"/*Tabela*/,"'+_aCols[_x][03]+'",PesqPictQt("D2_QUANT"      ),TamSx3("D2_QUANT")[1],/*lPixel*/,{|| SUBTMP->'+_aCols[_x][04]+'   })')	// Quantidade
				&('TRCell():New(oSection,"'+_aCols[_x][04]+'", _cSUBTMP /*Tabela*/,"'+_aCols[_x][03]+'","@E 99,999,999,999.99"         , 28                  ,/*lPixel*/,{|| Round((_cSUBTMP)->'+_aCols[_x][04]+',TamSx3("D2_QUANT")[02]) })')	// Quantidade
			elseif MV_PAR05 == 3	//Peso Liquido
	//			&('TRCell():New(oSection,"'+_aCols[_x][04]+'", "SUBTMP"/*Tabela*/,"'+_aCols[_x][03]+'",PesqPictQt("D2_QUANT"      ),TamSx3("D2_QUANT")[1],/*lPixel*/,{|| SUBTMP->'+_aCols[_x][04]+'   })')	// Quantidade
				&('TRCell():New(oSection,"'+_aCols[_x][04]+'", _cSUBTMP /*Tabela*/,"'+_aCols[_x][03]+'","@E 99,999,999,999.99"         , 28                  ,/*lPixel*/,{|| Round((_cSUBTMP)->'+_aCols[_x][04]+',TamSx3("D2_PESO")[02]) })')	// Quantidade
			
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
			TRCell():New(oSection,"TOTAL",_cSUBTMP/*Tabela*/,"TOTAL", "@E 999,999,999,999.99"       , 35                    ,/*lPixel*/,{|| Round((_cSUBTMP)->TOTAL,TamSx3("D2_TOTAL")[02]) })	// Valor Total
		elseif MV_PAR05 == 2	//Quantidade
			TRCell():New(oSection,"TOTAL",_cSUBTMP/*Tabela*/,"TOTAL", "@E 999,999,999,999.99"       , 35                    ,/*lPixel*/,{|| Round((_cSUBTMP)->TOTAL,TamSx3("D2_QUANT")[02]) })	// Quantidade
		elseif MV_PAR05 == 3	//Peso
			TRCell():New(oSection,"TOTAL",_cSUBTMP/*Tabela*/,"TOTAL", "@E 999,999,999,999.99"       , 35                    ,/*lPixel*/,{|| Round((_cSUBTMP)->TOTAL,TamSx3("D2_PESO")[02]) })	// Peso Liquido
		endif
		if !Empty(_cTotal)
			_cMedia := "("+_cTotal+") / "+cValToChar(len(_aCols))
		endif
		if Empty(_cMedia)
			_cMedia := "0"
		endif
		if MV_PAR05 == 3		//Valor Total
			TRCell():New(oSection,"MEDIA", _cSUBTMP/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSUBTMP)->MEDIA,TamSx3("D2_VALBRUT")[02]) })// Valor Total
		elseif MV_PAR05 == 2	//Quantidade
			TRCell():New(oSection,"MEDIA", _cSUBTMP/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSUBTMP)->MEDIA,TamSx3("D2_QUANT"  )[02]) })// Quantidade
		elseif MV_PAR05 == 3	//Quantidade
			TRCell():New(oSection,"MEDIA", _cSUBTMP/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSUBTMP)->MEDIA,TamSx3("D2_PESO"  )[02]) })// Peso Liquido
		else					//Valor das Mercadorias
			TRCell():New(oSection,"MEDIA", _cSUBTMP/*Tabela*/,"MEDIA", "@E 999,999,999,999.99", 31, /*lPixel*/,{|| Round((_cSUBTMP)->MEDIA,TamSx3("D2_TOTAL"  )[02]) })// Valor das Mercadorias
		endif
		for _x := 1 To len(oSection:aCell)
			if !Empty(oSection:aCell[_x]:cAlias) .AND. AllTrim(oSection:aCell[_x]:cAlias) <> (_cSUBTMP)
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
						//Break dos campos segundo a sua ordem definida pelo usuário
						&("oBreak"+cValToChar(_nBreak)) := TRBreak():New(oSection,oSection:Cell(AllTrim(oSection:aCell[_x]:cName)),"Sub-Total - " + AllTrim(oSection:aCell[_x]:cTitle))
						//Sub-Totais - Soma das colunas de valores/quantidades
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
				//Sub-Totais - Soma das colunas de valores/quantidades
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
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
	//Elimino os filtros do usuário para evitar duplicidades na query, uma vez que já estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
	for _x := 1 To len(oSection:AUSERFILTER)
		oSection:AUSERFILTER[_x][02] := oSection:AUSERFILTER[_x][03] := ""
	next
	oSection:CSQLEXP := ""
	/*
	//Total Geral
	if len(_aCols) > 0
		for _x := 1 To len(_aCols)
			TRFunction():New(oSection:Cell(_aCols[_x][03]),NIL,"SUM")
		next
	endif
	*/
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
	//MakeSqlExpr(_cPerg)
	_cSUBTMP := GetNextAlias()
	oSection:BeginQuery()
	BeginSql alias _cSUBTMP
		SELECT B1_FILIAL %Exp:_cField%
		FROM (
				SELECT B1_FILIAL, SUBSTRING(UA_EMISSAO,1,6) [EMISSAO]
						%Exp:_cCpoSum%
				FROM %table:SUB% SUB (NOLOCK)
					INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.%notDel%
											AND SB1.B1_FILIAL        = %xFilial:SB1%
											AND SB1.B1_COD     BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
											AND SB1.B1_COD           = SUB.UB_PRODUTO
											%Exp:_cFilSB1%
					INNER JOIN %table:SUA% SUA (NOLOCK) ON SUA.%notDel%
											AND SUA.UA_FILIAL        = %xFilial:SUA%
											AND SUA.UA_EMISSAO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
											AND SUA.UA_NUM           = SUB.UB_NUM
											%Exp:_cFilSUA%
					INNER JOIN %table:SA1% SA1 (NOLOCK) ON SA1.%notDel%
											AND SA1.A1_FILIAL        = %xFilial:SA1%
											AND SA1.A1_COD     BETWEEN %Exp:mv_par20% AND %Exp:mv_par22%
											AND SA1.A1_LOJA    BETWEEN %Exp:mv_par21% AND %Exp:mv_par23%
											AND SA1.A1_COD           = SUA.UA_CLIENTE
											AND SA1.A1_LOJA          = SUA.UA_LOJA
											%Exp:_cFilSA1%
					INNER JOIN %table:SA3% SA3 (NOLOCK) ON SA3.%notDel%
											AND SA3.A3_FILIAL        = %xFilial:SA3%
											AND SA3.A3_COD     BETWEEN %Exp:mv_par24% AND %Exp:mv_par25%
											AND SA3.A3_COD           = SUA.UA_VEND
											%Exp:_cFilSA3%
					LEFT OUTER JOIN %table:SM2% SM2 (NOLOCK) ON SM2.%notDel%
											AND SM2.M2_DATA          = %Exp:mv_par27%

				WHERE SUB.%notDel%
				  AND SUB.UB_FILIAL  = %xFilial:SUB%
				  %Exp:_cFilSUB%
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
	Local aRegs    := {}
	Local _aTam    := {}
	Local _aHlpPor := {}
	Local _aHlpEng := {}
	Local _aHlpSpa := {}
	/* FB - RELEASE 12.1.23
	_cPerg         := PADR(_cPerg,len(SX1->X1_GRUPO))
	*/
	_cPerg         := PADR(_cPerg,10)
	//PutSX1(< cGrupo>, < cOrdem>, < cPergunt>, < cPergSpa>, < cPergEng>, < cVar>, < cTipo>, < nTamanho>, [ nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ _aHlpPor], [ _aHlpEng], [ _aHlpSpa], [ cHelp] )
	_aTam    := TamSx3("B1_COD"    )
	/* FB - RELEASE 12.1.23
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe o código inicial dos produtos   " )
	PutSx1(_cPerg,"01","Do Produto?"			,"","","mv_ch1",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,"SB1","030","","mv_par01",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"01.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/* FB - RELEASE 12.1.23
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe o código final dos produtos.    " )
	PutSx1(_cPerg,"02","Ao Produto?"			,"","","mv_ch2",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()" ,"SB1","030","","mv_par02",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"02.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	_aTam    := TamSx3("UA_EMISSAO")
	/* FB - RELEASE 12.1.23
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe a data de emissão inicial a ser " ) 
	Aadd( _aHlpPor, "considerada.                            " )
	PutSx1(_cPerg,"03","Da Emissão?"			,"","","mv_ch3",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()" ,""	  ,""   ,"","mv_par03",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"03.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/* FB - RELEASE 12.1.23
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe a data de emissão final a ser   " ) 
	Aadd( _aHlpPor, "considerada.                            " )
	PutSx1(_cPerg,"04","Até a Emissão?"			,"","","mv_ch4",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()" ,""   ,""   ,"","mv_par04",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"04.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe o tipo de valor a ser acumulado " ) 
	Aadd( _aHlpPor, "por período, sendo:                     " )
	Aadd( _aHlpPor, "  1) Valor das Mercadorias;             " )
	Aadd( _aHlpPor, "  2) Quantidade.                        " )
	PutSx1(_cPerg,"05","Tipo de Informação?"	,"","","mv_ch5",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"C","NAOVAZIO()" ,""   ,""   ,"","mv_par05","Valor"			,"","","","","Quantidade"	,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"05.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe o tipo operação a ser           " ) 
	Aadd( _aHlpPor, "considerado, sendo:                     " )
	Aadd( _aHlpPor, "  1) Somento Vendas (desconsidera-se os " )
	Aadd( _aHlpPor, "     registros que não geram financeiro," )
	Aadd( _aHlpPor, "     os itenficados como trocas);       " )
	Aadd( _aHlpPor, "  2) Não Vendas (consideram-se aqui     " )
	Aadd( _aHlpPor, "     somente as trocas e os registros   " )
	Aadd( _aHlpPor, "     que não geraram financeiro).       " )
	Aadd( _aHlpPor, "  2) Ambos (consideram-se aqui todas os " )
	Aadd( _aHlpPor, "     documentos de saída).              " )
	Aadd( _aHlpPor, "                                        " )
	Aadd( _aHlpPor, "*É importante observar que as devoluções" )
	Aadd( _aHlpPor, "não são aqui consideradas.              " )
	PutSx1(_cPerg,"06","Operação?"				,"","","mv_ch6",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"C","NAOVAZIO()" ,""   ,""   ,"","mv_par06","Somente Vendas"	,"","","","","Não Vendas"	,"","","","","Ambos","","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"06.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	_cHelp    += "  2) Ambos (consideram-se aqui todas os " 
	_cHelp    += "     documentos de saída).              " 
	_cHelp    += "*É importante observar que as devoluções" 
	_cHelp    += "não são aqui consideradas.              " 
	U_RGENA001(_cPerg, "06" ,"Operação?" , "MV_PAR06", "MV_CH6", _aTam[03], _aTam[01], _aTam[02], "C", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := {03,00,"N"}
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe, da esquerda para a direita,    " )
	Aadd( _aHlpPor, "quantos níveis serão sub-totalizados no " )
	Aadd( _aHlpPor, "relatório. Por exemplo: Se as duas      " )
	Aadd( _aHlpPor, "primeiras colunas do relatório forem de " )
	Aadd( _aHlpPor, "'Vendedor' e, na sequencia, 'Cliente', e" )
	Aadd( _aHlpPor, "você solicitar a sub-totalização de 2   " )
	Aadd( _aHlpPor, "níveis, o relatório criará um sub-total " )
	Aadd( _aHlpPor, "por vendedor e, dentro de cada vendedor," )
	Aadd( _aHlpPor, "um sub-total por cliente.               " ) 
	Aadd( _aHlpPor, "Se não quiser sub-totais, informe zero. " )
	Aadd( _aHlpPor, "                                        " )
	PutSx1(_cPerg,"07","Níveis para Sub-Totais?","","","mv_ch7",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G","Positivo()" ,""   ,""   ,"","mv_par07",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"07.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	_cHelp    += "quantos níveis serão sub-totalizados no " 
	_cHelp    += "relatório. Por exemplo: Se as duas      " 
	_cHelp    += "primeiras colunas do relatório forem de " 
	//_cHelp    += "'Vendedor' e, na sequencia, 'Cliente', e" 
	_cHelp    += "'Representante' e, na sequencia, 'Cliente', e" 
	_cHelp    += "você solicitar a sub-totalização de 2   " 
	_cHelp    += "níveis, o relatório criará um sub-total " 
	//_cHelp    += "por vendedor e, dentro de cada vendedor," 
	_cHelp    += "por representante e, dentro de cada representante," 
	_cHelp    += "um sub-total por cliente.               "  
	_cHelp    += "Se não quiser sub-totais, informe zero. " 
	U_RGENA001(_cPerg, "07" ,"Níveis para Sub-Totais?" , "MV_PAR07", "MV_CH7", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	_aTam    := {06,02,"N"}
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de janeiro        " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"08","% Cresc. Janeiro?"		,"","","mv_ch8",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par08",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"08.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de fevereiro      " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"09","% Cresc. Fevereiro?"	,"","","mv_ch9",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par09",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"09.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de março          " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"10","% Cresc. Março?"		,"","","mv_cha",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par10",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"10.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de abril          " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"11","% Cresc. Abril?"		,"","","mv_chb",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par11",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"11.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de maio           " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"12","% Cresc. Maio?"			,"","","mv_chc",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par12",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"12.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de junho          " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"13","% Cresc. Junho?"		,"","","mv_chd",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par13",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"13.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de julho          " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"14","% Cresc. Julho?"		,"","","mv_che",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par14",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"14.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de agosto         " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"15","% Cresc. Agosto?"		,"","","mv_chf",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par15",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"15.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de setembro       " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"16","% Cresc. Setembro?"		,"","","mv_chg",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par16",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"16.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de outubro        " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"17","% Cresc. Outubro?"		,"","","mv_chh",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par17",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"17.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de novembro       " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"18","% Cresc. Novembro?"		,"","","mv_chi",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par18",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"18.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Se necessário, informe um percentual de " )
	Aadd( _aHlpPor, "incremento a ser considerado para o     " )
	Aadd( _aHlpPor, "faturamento dos meses de dezembro       " )
	Aadd( _aHlpPor, "(utilizado meramente para simulações de " )
	Aadd( _aHlpPor, "crescimento).                           " )
	PutSx1(_cPerg,"19","% Cresc. Dezembro?"		,"","","mv_chj",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par19",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"19.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe o código de cliente inicial para" )
	Aadd( _aHlpPor, "processamento.                          " )
	PutSx1(_cPerg,"20","Do Cliente?"			,"","","mv_chk",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,"SA1",""   ,"","mv_par20",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"20.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe a loja de cliente inicial para  " )
	Aadd( _aHlpPor, "processamento.                          " )
	PutSx1(_cPerg,"21","Da Loja?"				,"","","mv_chl",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,""   ,""   ,"","mv_par21",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"21.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe o código de cliente final para  " )
	Aadd( _aHlpPor, "processamento.                          " )
	PutSx1(_cPerg,"22","Ao Cliente?"			,"","","mv_chm",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()" ,"SA1",""   ,"","mv_par22",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"22.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	Aadd( _aHlpPor, "Informe a loja de cliente final para    " )
	Aadd( _aHlpPor, "processamento.                          " )
	PutSx1(_cPerg,"23","Até a Loja?"			,"","","mv_chn",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()" ,""   ,""   ,"","mv_par23",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"23.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe o código vendedor inicial para  " )
	Aadd( _aHlpPor, "processamento.                          " )
	PutSx1(_cPerg,"24","Do Vendedor?"			,"","","mv_cho",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G",""			,"SA3",""   ,"","mv_par24",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"24.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
	_cPerg    := _cPerg
	_cValid   := ""
	_cF3      := "SA3"
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""

	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	_cHelp    := "Informe o código representante inicial para processamento." 
	U_RGENA001(_cPerg, "24" ,"Do Representante?" , "MV_PAR24", "MV_CHP", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)

	//_cHelp    := "Informe o código vendedor inicial para processamento." 
	//U_RGENA001(_cPerg, "24" ,"Do Vendedor?" , "MV_PAR24", "MV_CHP", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	// Fim - Fernando Bombardi - ALLSS - 02/03/2022


	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	Aadd( _aHlpPor, "Informe o código de vendedor final para " )
	Aadd( _aHlpPor, "processamento.                          " )
	PutSx1(_cPerg,"25","Ao Vendedor?"			,"","","mv_chp",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()" ,"SA3",""   ,"","mv_par25",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"25.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
	_cPerg    := _cPerg
	_cValid   := "NAOVAZIO()"
	_cF3      := "SA3"
	_cPicture := ""
	_cDef01   := ""
	_cDef02   := ""
	_cDef03   := ""
	_cDef04   := ""
	_cDef05   := ""

	// Alteração - Fernando Bombardi - ALLSS - 02/03/2022
	//_cHelp    := "Informe o código vendedor final para processamento." 
	//U_RGENA001(_cPerg, "25" ,"Ao Vendedor?" , "MV_PAR25", "MV_CHQ", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)


	_cHelp    := "Informe o código representante final para processamento." 
	U_RGENA001(_cPerg, "25" ,"Ao Representante?" , "MV_PAR25", "MV_CHQ", _aTam[03], _aTam[01], _aTam[02], "G", _cValid ,_cF3, _cPicture, _cDef01, _cDef02, _cDef03, _cDef04, _cDef05, _cHelp)
	// Fim - Fernando Bombardi - ALLSS - 02/03/2022


	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	AAdd(_aHlpPor,"Informe em qual moeda o relatório deve"  )
	AAdd(_aHlpPor,"ser impresso.                         "  )
	PutSx1(_cPerg,"26","Moeda para conversão?"  ,"","","mv_chq","C"			,01			,0			,0,"G","NAOVAZIO()"	,""   ,""   ,"","mv_par26",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"26.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	AAdd(_aHlpPor,"Insira a data da cotação da moeda para"  )
	AAdd(_aHlpPor,"realização do cálculo de conversão."     )
	PutSx1(_cPerg,"27","Data da Cotação?"       ,"","","mv_chr","D"			,08			,0			,0,"G",""			,""   ,""   ,"","mv_par27",""				,"","","","",""				,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"27.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
	/*
	_aHlpPor := _aHlpEng := _aHlpSpa := {}
	AAdd(_aHlpPor,"Informe se o relatório deverá ser  "     )
	AAdd(_aHlpPor,"ordenado pela média mensal."             )
	*/
	_aTam  := {01,00,"N"}
	/*
	PutSx1(_cPerg,"28","Ordena pela Média?"    ,"","","mv_chs",_aTam[03]	,_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()" ,"",""   ,"","mv_par28","Não"				,"","","","","Sim"			,"","","","",""		,"","","","","",_aHlpPor,_aHlpEng,_aHlpSpa)
	PutSX1Help("P."+AllTrim(_cPerg)+"28.",_aHlpPor,_aHlpEng,_aHlpSpa)
	*/
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
