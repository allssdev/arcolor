#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RESTR004
@description Relatório Necessidades Materiais, conforme PMP.
@author Arthur F. Silva (ALL System Solutions)
@since 19/09/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RESTR004()
	private oReport, oSection
	private cTitulo  := OemToAnsi("Relatório de análise de necessidades de materiais conforme Plano Mestre de Produção(PMP)")
	private _cRotina := "RESTR004"
	private cPerg    := _cRotina
	private _cUser   := __cUserId
	private _cView   := "V_ESTRUTURA_"+RetSqlName("SG1")+"_"+AllTrim(SM0->M0_CODFIL)+"_ALL"
	private _cTABTMP := GetNextAlias()
	if FindFunction("TRepInUse") .And. TRepInUse()
		ValidPerg()
		if !Pergunte(cPerg,.T.)
			return
		endif
		if Select(_cTABTMP) > 0
			(_cTABTMP)->(dbCloseArea())
		endif
		oReport := ReportDef()
		oReport:PrintDialog()
		if Select(_cTABTMP) > 0
			(_cTABTMP)->(dbCloseArea())
		endif
	endif
return
/*/{Protheus.doc} RUNREPORT (RESTR004)
@description Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 19/09/2017
@version 1.0
@type function
@return oReport, objeto, Objeto do relatório
@see https://allss.com.br
/*/
static function ReportDef()
	local _aOrd    := {"Produto + Descrição"}		//{"Solicitação + Produto","Nome + ..."}
	local _cPermi  := SuperGetMv('MV_FATR022',,'000000')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Relatório de Necessidades(MRP)")
	oReport:SetLandscape()			//Paisagem
	oReport:SetTotalInLine(.F.)
	Pergunte(oReport:uParam,.F.)

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
	oSection := TRSection():New(oReport,"Tabelas",{_cView,"SB1","SHC"},_aOrd/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)
	//Definição das colunas do relatório
	TRCell():New(oSection,"COD_COMP"        ,_cTABTMP,"Produto"         ,PesqPict  ("SG1","G1_COMP" ),TamSx3("G1_COMP"  )[1] ,/*lPixel*/,{|| (_cTABTMP)->PRODUTO 		})	// PRODUTO
	TRCell():New(oSection,"B1_DESC"         ,_cTABTMP,"Descrição Prod." ,PesqPict  ("SB1","B1_DESC" ),TamSx3("B1_DESC"  )[1] ,/*lPixel*/,{|| (_cTABTMP)->DESCRICAO 		})	// DESCRICAO
	TRCell():New(oSection,"NECESSIDADE"     ,_cTABTMP,"Necessidade"     ,"@E 999,999,999.99"         ,12 					 ,/*lPixel*/,{|| (_cTABTMP)->NECESSIDADE	})	// NECESSIDADE
	TRCell():New(oSection,"B1_UM"           ,_cTABTMP,"Uni Medida"      ,PesqPict  ("SB1","B1_UM"   ),TamSx3("B1_UM"    )[1] ,/*lPixel*/,{|| (_cTABTMP)->UNIDADE_MEDIDA	})	// UM
	if _cUser $ _cPermi
		TRCell():New(oSection,"B1_UPRC"     ,_cTABTMP,"Preço"           ,PesqPict  ("SB1","B1_UPRC" ),TamSx3("B1_UPRC"  )[1] ,/*lPixel*/,{|| (_cTABTMP)->PRECO	        })	// UM
	endif
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
	//oBreak := TRBreak():New(oSection,oSection:Cell("CAMPO"),"Descrição SubTotal")
	//TRFunction():New(oSection:Cell("CAMPO"),NIL,"COUNT",oBreak) // Totalizador
	//TRFunction():New(oSection:Cell("CAMPO"),NIL,"SUM"	 ,oBreak) // Totalizador

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Troca descricao do total dos itens                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oReport:Section(1):SetTotalText("Total")
	//oReport:Section(1):SetEdit(.T.) 
	//oReport:Section(1):SetUseQuery(.T.) // Novo componente tReport para adcionar campos de usuario no relatorio qdo utiliza query

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alinhamento a direita as colunas de valor                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oSection:Cell("CAMPO"):SetHeaderAlign("RIGHT")
return(oReport)
/*/{Protheus.doc} PrintReport (RESTR004)
@description Funcao auxiliar de impressão.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 19/09/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function PrintReport(oReport)
	local _cOrder  := ""
//	local _cField  := ""
//	local _cFilSB1 := oSection:GetSqlExp("SB1")
//	local _cQry	   := ""

	//Definição da ordem de apresentação das informações
	if oReport:Section(1):GetOrder() == 1			//Ordem por Nome
		_cOrder := "COD_COMP, B1_DESC"
	//ElseIf oReport:Section(1):GetOrder() == 2		//Ordem por Nome + ...
	//	_cOrder := "Definir aqui a segunda ordem almejada..."
	endif
	//_cField  := "%" + _cField  + "%"
	_cOrder  := "%" + _cOrder  + "%"
	_cView   := "%" + _cView   + "%"
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
	//Elimino os filtros do usuário para evitar duplicidades na query, uma vez que já estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
	for _x := 1 to len(oSection:aUserFilter)
		oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
	next
	oSection:CSQLEXP := ""
	//PROCESSAMENTO DAS INFORMAÇÕES PARA IMPRESSÃO
	//Transforma parâmetros do tipo Range em expressao SQL para ser utilizada na query 
	MakeSqlExpr(oReport:uParam)
	MakeSqlExpr(cPerg)
	oSection:BeginQuery()
			BeginSql Alias _cTABTMP
				SELECT XXX.COD_COMP PRODUTO, B1_DESC DESCRICAO, SUM(HC_QUANT*QTD) NECESSIDADE, B1_UM UNIDADE_MEDIDA, B1_UPRC*(SUM(HC_QUANT*QTD)) PRECO
				FROM %Table:SHC% SHC (NOLOCK)
					INNER JOIN %Exp:_cView% XXX ON XXX.CODIGO = SHC.HC_PRODUTO
															AND XXX.FILIAL= SHC.HC_FILIAL
															AND XXX.COD_COMP BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%          
					INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
									AND SB1.B1_COD     = XXX.COD_COMP
									AND SB1.B1_MSBLQL  = '2'
									AND SB1.B1_TIPO   <> 'PI'
									AND SB1.%NotDel%
				WHERE SHC.HC_FILIAL    = %xFilial:SHC%
					AND SHC.HC_DATA    = %Exp:DTOS(MV_PAR03)%
					AND SHC.HC_DOC     = %Exp:MV_PAR04%
				//	AND SHC.HC_PRODUTO = 'PA0800'
					AND SHC.%NotDel%
				GROUP BY XXX.COD_COMP , B1_DESC, B1_UM,B1_UPRC
				ORDER BY XXX.COD_COMP 
			EndSql
		/*
		Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
		parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
		pela funcao MakeSqlExpr para serem adicionados a query
		*/
		//MemoWrite("\"+_cRotina+"_QRY_001",oSection:CQUERY)
	oSection:EndQuery()
	oSection:Print()
return
/*/{Protheus.doc} ValidPerg
@description Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).
@author Arthur Farias da Silva (ALL System Solutions)
@since 17/04/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _sArea     := GetArea()
	local aRegs      := {}
	local _aTam      := {}
	local i          := 0
	local j          := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))

	_aTam  := TamSx3("G1_COMP" )
	AADD(aRegs,{cPerg,"01","De Produto?"	,"","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G",""			,"mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SB1"   ,"",""})
	_aTam  := TamSx3("G1_COMP" )
	AADD(aRegs,{cPerg,"02","Até Produto?"	,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SB1"   ,"",""})
	_aTam  := TamSx3("HC_DATA")
	AADD(aRegs,{cPerg,"03","Data PMP?"		,"","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""	   ,"",""})
	_aTam  := TamSx3("HC_DOC" )
	AADD(aRegs,{cPerg,"04","Documento PMP?	","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""     ,"",""})
	for i := 1 to len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_sArea)
return