#include 'totvs.ch'
#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RTMKR006
@description Relat�rio de Chamados do SAC.
@author Arthur Silva (ALL System Solutions)
@since 06/07/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RTMKR006()
	private oReport, oSection
	private cTitulo  := OemToAnsi("Relat�rio de Chamados - SAC ")
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
	Local _aOrd    := {"N�mero Chamado"}		//{"Solicita��o + Produto","Nome + ..."}
	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//��������������������������������������������������������������������������
	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Relat�rio de Chamados - SAC - ARCOLOR!")
	oReport:SetLandscape()			//Paisagem
	oReport:SetTotalInLine(.F.)
	Pergunte(oReport:uParam,.F.)

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
	//�                                                                        �
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
	oSection := TRSection():New(oReport,"Informa��es",{"ADE","ADF","SB1","SC2","SU9","SU5"},_aOrd/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)

	TRCell():New(oSection,"ADE_CODIGO"    	,_cAliTMP,RetTitle("ADE_CODIGO"	) ,PesqPict  ("ADE","ADE_CODIGO" )	,TamSx3("ADE_CODIGO" )[1],/*lPixel*/,{|| (_cAliTMP)->CHAMADO       })	// Numero Chamado
	TRCell():New(oSection,"ADE_CODSB1"    	,_cAliTMP,RetTitle("ADE_CODSB1"	) ,PesqPict  ("ADE","ADE_CODSB1"  )	,TamSx3("ADE_CODSB1" )[1],/*lPixel*/,{|| (_cAliTMP)->C�DIGO       	})	// Codigo Prod.
	TRCell():New(oSection,"B1_DESC"    		,_cAliTMP,RetTitle("B1_DESC"	)	  ,PesqPict  ("SB1","B1_DESC"  )	,TamSx3("B1_DESC"    )[1],/*lPixel*/,{|| (_cAliTMP)->DESCRI��O     })	// Descri��o Prod.
	TRCell():New(oSection,"ADE_QTDPRO"    	,_cAliTMP,RetTitle("ADE_QTDPRO")	  ,PesqPict  ("ADE","ADE_QTDPRO")	,TamSx3("ADE_QTDPRO" )[1],/*lPixel*/,{|| (_cAliTMP)->QTDE			})	// Quantidade
	TRCell():New(oSection,"ADE_DATA"  		,_cAliTMP,RetTitle("ADE_DATA"	)	  ,"@D"                           	,TamSx3("ADE_DATA"   )[1],/*lPixel*/,{|| (_cAliTMP)->DATA_INCL  	})	// Data Chamado
	TRCell():New(oSection,"C2_DATPRF"  		,_cAliTMP,"Data Fabrica��o Prod." 	  ,PesqPict  ("SC2","C2_DATPRF"  )	,TamSx3("C2_DATPRF"	 )[1],/*lPixel*/,{|| (_cAliTMP)->DATA_FABRIC   })	// Data Fabrica��o Prod.
	TRCell():New(oSection,"ADF_CODSU9"  	,_cAliTMP,RetTitle("ADF_CODSU9"	) ,PesqPict  ("ADF","ADF_CODSU9"  )	,TamSx3("ADF_CODSU9" )[1],/*lPixel*/,{|| (_cAliTMP)->C�D_OCORRE  	})	// C�digo Ocorr�ncia
	TRCell():New(oSection,"U9_DESC"  		,_cAliTMP,RetTitle("U9_DESC"	)	  ,PesqPict  ("SU9","U9_DESC"  )	,TamSx3("U9_DESC"	 )[1],/*lPixel*/,{|| (_cAliTMP)->DESC_PROB    	})	// Descri��o do Problema
	TRCell():New(oSection,"ADE_LTESB1"  	,_cAliTMP,RetTitle("ADE_LTESB1"	) ,PesqPict  ("ADE","ADE_LTESB1"  )	,TamSx3("ADE_LTESB1" )[1],/*lPixel*/,{|| (_cAliTMP)->LOTE     		})	// N�mero Lote
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

	//������������������������������������������������������������������������Ŀ
	//� Troca descricao do total dos itens                                     �
	//��������������������������������������������������������������������������

	//oReport:Section(1):SetTotalText("Descri��o Totalizador")

	//oReport:Section(1):SetEdit(.T.) 
	//oReport:Section(1):SetUseQuery(.T.) // Novo componente tReport para adcionar campos de usuario no relatorio qdo utiliza query

	//������������������������������������������������������������������������Ŀ
	//� Alinhamento a direita as colunas de valor                              �
	//��������������������������������������������������������������������������
	//oSection:Cell("CAMPO"):SetHeaderAlign("RIGHT")
return oReport
/*/{Protheus.doc} PrintReport
@description Processamento das informa��es para impress�o (Print).
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
		MsgStop("Par�metros informados incorretamente!",_cRotina+"_001")
		Return
	EndIf

	//Defini��o da ordem de apresenta��o das informa��es
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
	//Elimino os filtros do usu�rio para evitar duplicidades na query, uma vez que j� estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
	For _x := 1 To Len(oSection:aUserFilter)
		oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
	Next

	oSection:CSQLEXP := ""
	//PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
	//Transforma par�metros do tipo Range em expressao SQL para ser utilizada na query 
	MakeSqlExpr(oReport:uParam)
	MakeSqlExpr(cPerg)

	oSection:BeginQuery()
	BeginSql Alias _cAliTMP
		SELECT	  ADE_CODIGO CHAMADO
				, ADE_CODSB1 C�DIGO
				, B1_DESC DESCRI��O
				, ADE_QTDPRO QTDE
				, ISNULL(SUBSTRING( ADE_DATA,7,2)+'/'+SUBSTRING( ADE_DATA,5,2)+'/'+SUBSTRING( ADE_DATA,1,4),'') DATA_INCL
				, ISNULL(SUBSTRING( C2_DATPRF,7,2)+'/'+SUBSTRING( C2_DATPRF,5,2)+'/'+SUBSTRING( C2_DATPRF,1,4),'') DATA_FABRIC
				, ADF_CODSU9 C�D_OCORRE
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
@description Valida se as perguntas j� existem no arquivo SX1 e caso n�o encontre as cria no arquivo.
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
	AADD(aRegs,{cPerg,"02","At� Data?"    ,"","","mv_ch2" ,_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""     ,"","","",""})
	_aTam            := TamSx3("ADE_CODSB1")
	AADD(aRegs,{cPerg,"03","De Produto?"  ,"","","mv_ch3" ,_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"  ,"","","",""})
	AADD(aRegs,{cPerg,"04","At� Produto?" ,"","","mv_ch4" ,_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"  ,"","","",""})
	_aTam            := TamSx3("ADE_GRUPO" )
	AADD(aRegs,{cPerg,"05","De Grupo?"    ,"","","mv_ch5" ,_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SU0"  ,"","","",""})
	AADD(aRegs,{cPerg,"06","At� Grupo?"   ,"","","mv_ch6" ,_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SU0"  ,"","","",""})
	_aTam            := TamSx3("A1_COD"    )
	AADD(aRegs,{cPerg,"07","De Cliente?"  ,"","","mv_ch7" ,_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA1"	,"","","",""})
	_aTam            := TamSx3("A1_LOJA"   )
	AADD(aRegs,{cPerg,"08","De Loja?"     ,"","","mv_ch8" ,_aTam[3],_aTam[1],_aTam[2],0,"G",""          ,"mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""   	,"","","",""})
	_aTam            := TamSx3("A1_COD"    )
	AADD(aRegs,{cPerg,"09","At� Cliente?" ,"","","mv_ch9" ,_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SA1"	,"","","",""})
	_aTam            := TamSx3("A1_LOJA"   )
	AADD(aRegs,{cPerg,"10","At� Loja?"    ,"","","mv_ch10",_aTam[3],_aTam[1],_aTam[2],0,"G","NaoVazio()","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""  	,"","","",""})
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