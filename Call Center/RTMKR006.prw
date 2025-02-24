#include 'totvs.ch'
#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RTMKR006
@description Relatório de Chamados do SAC.
@author Arthur Silva (ALL System Solutions)
@since 06/07/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RTMKR006()
	private oReport, oSection
	private cTitulo  := OemToAnsi("Relatório de Chamados - SAC ")
	private _cAliTMP := GetNextAlias()
	private _cRotina := "RTMKR006"
	private cPerg    := _cRotina
	if FindFunction("TRepInUse") .AND. TRepInUse()
		ValidPerg()
		if !Pergunte(cPerg,.T.)
			return
		endif
		oReport := ReportDef()
		oReport:PrintDialog()
	endif
return
/*/{Protheus.doc} ReportDef
@description A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.
@author Arthur Silva (ALL System Solutions)
@since 06/07/2017
@version 1.0
@type function
@return oReport, objeto, Objeto do TReport.
@see https://allss.com.br
/*/
static function ReportDef()
	Local _aOrd    := {"Número Chamado"}		//{"Solicitação + Produto","Nome + ..."}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Relatório de Chamados - SAC - ARCOLOR!")
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
	oSection := TRSection():New(oReport,"Informações",{"ADE","ADF","SB1","SC2","SU9","SU5"},_aOrd/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)

	TRCell():New(oSection,"ADE_CODIGO"    	,_cAliTMP,RetTitle("ADE_CODIGO"	) ,PesqPict  ("ADE","ADE_CODIGO" )	,TamSx3("ADE_CODIGO" )[1],/*lPixel*/,{|| (_cAliTMP)->CHAMADO       })	// Numero Chamado
	TRCell():New(oSection,"ADE_CODSB1"    	,_cAliTMP,RetTitle("ADE_CODSB1"	) ,PesqPict  ("ADE","ADE_CODSB1"  )	,TamSx3("ADE_CODSB1" )[1],/*lPixel*/,{|| (_cAliTMP)->CÓDIGO       	})	// Codigo Prod.
	TRCell():New(oSection,"B1_DESC"    		,_cAliTMP,RetTitle("B1_DESC"	)	  ,PesqPict  ("SB1","B1_DESC"  )	,TamSx3("B1_DESC"    )[1],/*lPixel*/,{|| (_cAliTMP)->DESCRIÇÃO     })	// Descrição Prod.
	TRCell():New(oSection,"ADE_QTDPRO"    	,_cAliTMP,RetTitle("ADE_QTDPRO")	  ,PesqPict  ("ADE","ADE_QTDPRO")	,TamSx3("ADE_QTDPRO" )[1],/*lPixel*/,{|| (_cAliTMP)->QTDE			})	// Quantidade
	TRCell():New(oSection,"ADE_DATA"  		,_cAliTMP,RetTitle("ADE_DATA"	)	  ,"@D"                           	,TamSx3("ADE_DATA"   )[1],/*lPixel*/,{|| (_cAliTMP)->DATA_INCL  	})	// Data Chamado
	TRCell():New(oSection,"C2_DATPRF"  		,_cAliTMP,"Data Fabricação Prod." 	  ,PesqPict  ("SC2","C2_DATPRF"  )	,TamSx3("C2_DATPRF"	 )[1],/*lPixel*/,{|| (_cAliTMP)->DATA_FABRIC   })	// Data Fabricação Prod.
	TRCell():New(oSection,"ADF_CODSU9"  	,_cAliTMP,RetTitle("ADF_CODSU9"	) ,PesqPict  ("ADF","ADF_CODSU9"  )	,TamSx3("ADF_CODSU9" )[1],/*lPixel*/,{|| (_cAliTMP)->CÓD_OCORRE  	})	// Código Ocorrência
	TRCell():New(oSection,"U9_DESC"  		,_cAliTMP,RetTitle("U9_DESC"	)	  ,PesqPict  ("SU9","U9_DESC"  )	,TamSx3("U9_DESC"	 )[1],/*lPixel*/,{|| (_cAliTMP)->DESC_PROB    	})	// Descrição do Problema
	TRCell():New(oSection,"ADE_LTESB1"  	,_cAliTMP,RetTitle("ADE_LTESB1"	) ,PesqPict  ("ADE","ADE_LTESB1"  )	,TamSx3("ADE_LTESB1" )[1],/*lPixel*/,{|| (_cAliTMP)->LOTE     		})	// Número Lote
	TRCell():New(oSection,"ADE_DTVALI"  	,_cAliTMP,RetTitle("ADE_DTVALI"	) ,PesqPict  ("ADE","ADE_DTVALI"  )	,TamSx3("ADE_DTVALI" )[1],/*lPixel*/,{|| (_cAliTMP)->DT_VALIDADE   })	// Data Validade
	TRCell():New(oSection,"U5_CONTAT"  		,_cAliTMP,RetTitle("U5_CONTAT"	)	  ,PesqPict  ("SU5","U5_CONTAT"  )	,TamSx3("U5_CONTAT"	 )[1],/*lPixel*/,{|| (_cAliTMP)->CONTATO     	})	// Contato Cliente
//	TRCell():New(oSection,"ADE_ENVTIP"  	,_cAliTMP,RetTitle("ADE_ENVTIP"	) ,PesqPict  ("ADE","ADE_ENVTIP"  )	,TamSx3("ADE_ENVTIP" )[1],/*lPixel*/,{|| (_cAliTMP)->ENVIO     	})	// Tipo de Envio

	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/

	//oBreak := TRBreak():New(oSection,oSection:Cell("CAMPO"),"Descric...")

	//TRFunction():New(oSection:Cell("CAMPO"),NIL,"COUNT",oBreak) // Totalizador

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Troca descricao do total dos itens                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//oReport:Section(1):SetTotalText("Descrição Totalizador")

	//oReport:Section(1):SetEdit(.T.) 
	//oReport:Section(1):SetUseQuery(.T.) // Novo componente tReport para adcionar campos de usuario no relatorio qdo utiliza query

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alinhamento a direita as colunas de valor                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oSection:Cell("CAMPO"):SetHeaderAlign("RIGHT")
return oReport
/*/{Protheus.doc} PrintReport
@description Processamento das informações para impressão (Print).
@author Arthur Silva (ALL System Solutions)
@since 06/07/2017
@version 1.0
@type function
@param oReport, objeto, Objeto do TReport.
@see https://allss.com.br
/*/
static function PrintReport(oReport)
	Local _cOrder  := ""
	Local _cField  := ""
//	Local _cFilADE := oSection:GetSqlExp("ADE")
//	Local _cFilADF := oSection:GetSqlExp("ADF")


	If MV_PAR01 > MV_PAR02 
		MsgStop("Parâmetros informados incorretamente!",_cRotina+"_001")
		Return
	EndIf

	//Definição da ordem de apresentação das informações
	If oReport:Section(1):GetOrder() == 1			//Ordem por Nome
		_cOrder := "ADE_CODIGO"
		//ElseIf oReport:Section(1):GetOrder() == 2		//Ordem por Nome + ...
		//	_cOrder := "Definir aqui a segunda ordem almejada..."
	EndIf

	_cField  := "%" + _cField  + "%"
	_cOrder  := "%" + _cOrder  + "%"
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
	//Elimino os filtros do usuário para evitar duplicidades na query, uma vez que já estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
	For _x := 1 To Len(oSection:aUserFilter)
		oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
	Next

	oSection:CSQLEXP := ""
	//PROCESSAMENTO DAS INFORMAÇÕES PARA IMPRESSÃO
	//Transforma parâmetros do tipo Range em expressao SQL para ser utilizada na query 
	MakeSqlExpr(oReport:uParam)
	MakeSqlExpr(cPerg)

	oSection:BeginQuery()
	BeginSql Alias _cAliTMP
		SELECT	  ADE_CODIGO CHAMADO
				, ADE_CODSB1 CÓDIGO
				, B1_DESC DESCRIÇÃO
				, ADE_QTDPRO QTDE
				, ISNULL(SUBSTRING( ADE_DATA,7,2)+'/'+SUBSTRING( ADE_DATA,5,2)+'/'+SUBSTRING( ADE_DATA,1,4),'') DATA_INCL
				, ISNULL(SUBSTRING( C2_DATPRF,7,2)+'/'+SUBSTRING( C2_DATPRF,5,2)+'/'+SUBSTRING( C2_DATPRF,1,4),'') DATA_FABRIC
				, ADF_CODSU9 CÓD_OCORRE
				, U9_DESC DESC_PROB
				, ADE_LTESB1 LOTE
				, ISNULL(SUBSTRING( ADE_DTVALI ,7,2)+'/'+SUBSTRING( ADE_DTVALI ,5,2)+'/'+SUBSTRING( ADE_DTVALI ,1,4),'') DT_VALIDADE
				, U5_CONTAT CONTATO
		FROM %table:ADE% ADE
				INNER JOIN %table:ADF% ADF ON ADF.ADF_FILIAL = %xFilial:ADF%
					AND ADF.ADF_CODIGO = ADE.ADE_CODIGO
					AND ADF.%NotDel%
				INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1% 
					AND  SB1.B1_COD    = ADE.ADE_CODSB1
					AND SB1.%NotDel%
				INNER JOIN %table:SU9% SU9 ON SU9.U9_CODIGO = ADF.ADF_CODSU9
					AND SU9.%NotDel%
				LEFT JOIN %table:SC2% SC2  ON SC2.C2_NUM = ADE.ADE_LTESB1
					AND SC2.C2_FILIAL = %xFilial:SC2%
					AND SC2.%NotDel%
				INNER JOIN %table:SU5% SU5 ON SU5.U5_CODCONT = ADE.ADE_CODCON
					AND SU5.U5_FILIAL = %xFilial:SU5%
					AND SU5.%NotDel%
		WHERE ADE.ADE_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%  // DATA EMISSAO
				AND ADE.ADE_CODSB1 BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% // CODIGO PRODUTO
				AND ADE.ADE_GRUPO  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%  // GRUPO
				AND	ADE.ADE_OPERAD BETWEEN %Exp:MV_PAR11% AND %Exp:MV_PAR12%   // CODIGO OPERADOR
				AND ADE.ADE_CHAVE  BETWEEN %Exp:MV_PAR07+MV_PAR08% AND %Exp:MV_PAR09+MV_PAR10% // CLIENTE+LOJA
				AND	ADE.ADE_CODIGO BETWEEN %Exp:MV_PAR13% AND %Exp:MV_PAR14%   // NUMERO CHAMADO
				AND ADE.%NotDel%   
		ORDER BY CHAMADO
	EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
	oSection:EndQuery()
	oSection:Print()
return
/*/{Protheus.doc} ValidPerg
@description Valida se as perguntas já existem no arquivo SX1 e caso não encontre as cria no arquivo.
@author Arthur Silva (ALL System Solutions)
@since 06/07/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aAlias    := GetArea()
	local aRegs     := {}
	local _aTam      := {}
	local _x         := 0
	local _y         := 0
	local _cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()

	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))

	cPerg            := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam            := TamSx3("ADE_DATA"  )
	AADD(aRegs,{cPerg,"01","De Data?"     ,"","","mv_ch1" ,_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""     ,"","","",""})
	AADD(aRegs,{cPerg,"02","Até Data?"    ,"","","mv_ch2" ,_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""     ,"","","",""})
	_aTam            := TamSx3("ADE_CODSB1")
	AADD(aRegs,{cPerg,"03","De Produto?"  ,"","","mv_ch3" ,_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"  ,"","","",""})
	AADD(aRegs,{cPerg,"04","Até Produto?" ,"","","mv_ch4" ,_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"  ,"","","",""})
	_aTam            := TamSx3("ADE_GRUPO" )
	AADD(aRegs,{cPerg,"05","De Grupo?"    ,"","","mv_ch5" ,_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SU0"  ,"","","",""})
	AADD(aRegs,{cPerg,"06","Até Grupo?"   ,"","","mv_ch6" ,_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SU0"  ,"","","",""})
	_aTam            := TamSx3("A1_COD"    )
	AADD(aRegs,{cPerg,"07","De Cliente?"  ,"","","mv_ch7" ,_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA1"	,"","","",""})
	_aTam            := TamSx3("A1_LOJA"   )
	AADD(aRegs,{cPerg,"08","De Loja?"     ,"","","mv_ch8" ,_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""   	,"","","",""})
	_aTam            := TamSx3("A1_COD"    )
	AADD(aRegs,{cPerg,"09","Até Cliente?" ,"","","mv_ch9" ,_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SA1"	,"","","",""})
	_aTam            := TamSx3("A1_LOJA"   )
	AADD(aRegs,{cPerg,"10","Até Loja?"    ,"","","mv_ch10",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""  	,"","","",""})
	_aTam            := TamSx3("ADE_OPERAD")
	AADD(aRegs,{cPerg,"11","Do Operador?" ,"","","mv_ch11",_aTam[3],_aTam[1],_aTam[2],0,"G",""			 ,"mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SU7"	,"","","",""})
	AADD(aRegs,{cPerg,"12","Ao Operador?" ,"","","mv_ch12",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SU7"	,"","","",""})
	_aTam            := TamSx3("ADE_CODIGO")
	AADD(aRegs,{cPerg,"13","Do Chamado?"  ,"","","mv_ch13",_aTam[3],_aTam[1],_aTam[2],0,"G",""			 ,"mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","SU7"	,"","","",""})
	AADD(aRegs,{cPerg,"14","Ao Chamado?"  ,"","","mv_ch14",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","SU7"	,"","","",""})
	for _x := 1 To Len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[_x,2],.T.,.F.))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for _y := 1 to FCount()
					if _y <= len(aRegs[_x])
						FieldPut(_y,aRegs[_x,_y])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	if select(_cAliasSX1)>0
		(_cAliasSX1)->(dbCloseArea())
	endif
	RestArea(_aAlias)
return