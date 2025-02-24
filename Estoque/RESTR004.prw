#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RESTR004
@description Relat�rio Necessidades Materiais, conforme PMP.
@author Arthur F. Silva (ALL System Solutions)
@since 19/09/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RESTR004()
	private oReport, oSection
	private cTitulo  := OemToAnsi("Relat�rio de an�lise de necessidades de materiais conforme Plano Mestre de Produ��o(PMP)")
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
@return oReport, objeto, Objeto do relat�rio
@see https://allss.com.br
/*/
static function ReportDef()
	local _aOrd    := {"Produto + Descri��o"}		//{"Solicita��o + Produto","Nome + ..."}
	local _cPermi  := SuperGetMv('MV_FATR022',,'000000')
	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//��������������������������������������������������������������������������
	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Relat�rio de Necessidades(MRP)")
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
	oSection := TRSection():New(oReport,"Tabelas",{_cView,"SB1","SHC"},_aOrd/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)
	//Defini��o das colunas do relat�rio
	TRCell():New(oSection,"COD_COMP"        ,_cTABTMP,"Produto"         ,PesqPict  ("SG1","G1_COMP" ),TamSx3("G1_COMP"  )[1] ,/*lPixel*/,{|| (_cTABTMP)->PRODUTO 		})	// PRODUTO
	TRCell():New(oSection,"B1_DESC"         ,_cTABTMP,"Descri��o Prod." ,PesqPict  ("SB1","B1_DESC" ),TamSx3("B1_DESC"  )[1] ,/*lPixel*/,{|| (_cTABTMP)->DESCRICAO 		})	// DESCRICAO
	TRCell():New(oSection,"NECESSIDADE"     ,_cTABTMP,"Necessidade"     ,"@E 999,999,999.99"         ,12 					 ,/*lPixel*/,{|| (_cTABTMP)->NECESSIDADE	})	// NECESSIDADE
	TRCell():New(oSection,"B1_UM"           ,_cTABTMP,"Uni Medida"      ,PesqPict  ("SB1","B1_UM"   ),TamSx3("B1_UM"    )[1] ,/*lPixel*/,{|| (_cTABTMP)->UNIDADE_MEDIDA	})	// UM
	if _cUser $ _cPermi
		TRCell():New(oSection,"B1_UPRC"     ,_cTABTMP,"Pre�o"           ,PesqPict  ("SB1","B1_UPRC" ),TamSx3("B1_UPRC"  )[1] ,/*lPixel*/,{|| (_cTABTMP)->PRECO	        })	// UM
	endif
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
	//oBreak := TRBreak():New(oSection,oSection:Cell("CAMPO"),"Descri��o SubTotal")
	//TRFunction():New(oSection:Cell("CAMPO"),NIL,"COUNT",oBreak) // Totalizador
	//TRFunction():New(oSection:Cell("CAMPO"),NIL,"SUM"	 ,oBreak) // Totalizador

	//������������������������������������������������������������������������Ŀ
	//� Troca descricao do total dos itens                                     �
	//��������������������������������������������������������������������������
	//oReport:Section(1):SetTotalText("Total")
	//oReport:Section(1):SetEdit(.T.) 
	//oReport:Section(1):SetUseQuery(.T.) // Novo componente tReport para adcionar campos de usuario no relatorio qdo utiliza query

	//������������������������������������������������������������������������Ŀ
	//� Alinhamento a direita as colunas de valor                              �
	//��������������������������������������������������������������������������
	//oSection:Cell("CAMPO"):SetHeaderAlign("RIGHT")
return(oReport)
/*/{Protheus.doc} PrintReport (RESTR004)
@description Funcao auxiliar de impress�o.
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

	//Defini��o da ordem de apresenta��o das informa��es
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
	//Elimino os filtros do usu�rio para evitar duplicidades na query, uma vez que j� estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
	for _x := 1 to len(oSection:aUserFilter)
		oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
	next
	oSection:CSQLEXP := ""
	//PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
	//Transforma par�metros do tipo Range em expressao SQL para ser utilizada na query 
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
	AADD(aRegs,{cPerg,"02","At� Produto?"	,"","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","naovazio()","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","SB1"   ,"",""})
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