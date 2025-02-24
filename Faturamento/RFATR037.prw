#include "totvs.ch"
/*/{Protheus.doc} RFATR037
@description Relatorio de pedidos pendentes na �rea de cr�dito, para acompanhamento (solicitado por Marco Antonio e Talita).
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 20/11/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFATR037()
	private oReport
	private oSection
	private _cRotina  := "RFATR037"
	private cPerg     := _cRotina
	private _cSC9TMP  := GetNextAlias()
	private cTitulo   := "Relatorio de pedidos pendentes na �rea de cr�dito, para acompanhamento"
	if FindFunction("TRepInUse") .And. TRepInUse()
		ValidPerg()
		if !Pergunte(cPerg,.T.)
			return
		endif
		oReport  := ReportDef()
		oReport:PrintDialog()
	endif
return
/*/{Protheus.doc} ReportDef (RFATR037)
@description A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 20/11/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ReportDef()
	local _aOrd    := {	"Ordem dos Campos" }
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
	//Adequa��o do t�tulo do relat�rio
	//	oReport:cDescription := oReport:cRealTitle := oReport:cTitle := cTitulo
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
	oSection := TRSection():New(oReport,"PEDIDOS PENDENTES DE LIBERA��O DE CR�DITO",{"SC9","SC5","SA3"},_aOrd/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)
	//Defini��o das colunas do relat�rio
//	TRCell():New(oSection,"A3_GEREN"    ,"SA3"/*Tabela*/,RetTitle("A3_GEREN"  ),PesqPict  ("SA3","A3_GEREN"  ),TamSx3("A3_GEREN"  )[1]  ,/*lPixel*/,{|| (_cSC9TMP)->A3_GEREN        })
//	TRCell():New(oSection,"A3_NOMGER"   ,""             ,"Nome Gerente"        ,PesqPict  ("SA3","A3_NOME"   ),TamSx3("A3_NOME"   )[1]  ,/*lPixel*/,{|| POSICIONE("SA3",1,FWFilial("SA3")+(_cSC9TMP)->A3_GEREN,"A3_NOME")})
//	TRCell():New(oSection,"A3_SUPER"    ,"SA3"/*Tabela*/,RetTitle("A3_SUPER"  ),PesqPict  ("SA3","A3_SUPER"  ),TamSx3("A3_SUPER"  )[1]  ,/*lPixel*/,{|| (_cSC9TMP)->A3_SUPER        })
//	TRCell():New(oSection,"A3_NOMSUP"   ,""             ,"Nome Supervisor"     ,PesqPict  ("SA3","A3_NOME"   ),TamSx3("A3_NOME"   )[1]  ,/*lPixel*/,{|| POSICIONE("SA3",1,FWFilial("SA3")+(_cSC9TMP)->A3_SUPER,"A3_NOME")})
	TRCell():New(oSection,"C5_VEND1"    ,"SC5"/*Tabela*/,RetTitle("C5_VEND1"  ),PesqPict  ("SC5","C5_VEND1"  ),TamSx3("C5_VEND1"  )[1]  ,/*lPixel*/,{|| (_cSC9TMP)->C5_VEND1        })
	TRCell():New(oSection,"A3_NOME"     ,"SA3"/*Tabela*/,RetTitle("A3_NOME"   ),PesqPict  ("SA3","A3_NOME"   ),TamSx3("A3_NOME"   )[1]  ,/*lPixel*/,{|| (_cSC9TMP)->A3_NOME         })
	TRCell():New(oSection,"C5_EMISSAO"  ,"SC5"/*Tabela*/,RetTitle("C5_EMISSAO"),PesqPict  ("SC5","C5_EMISSAO"),TamSx3("C5_EMISSAO")[1]  ,/*lPixel*/,{|| (_cSC9TMP)->C5_EMISSAO      })
	TRCell():New(oSection,"C9_PEDIDO"   ,"SC9"/*Tabela*/,RetTitle("C9_PEDIDO" ),PesqPict  ("SC9","C9_PEDIDO" ),TamSx3("C9_PEDIDO" )[1]  ,/*lPixel*/,{|| (_cSC9TMP)->C9_PEDIDO       })
	TRCell():New(oSection,"C5_CLIENTE"  ,"SC5"/*Tabela*/,RetTitle("C5_CLIENTE"),PesqPict  ("SC5","C5_CLIENTE"),TamSx3("C5_CLIENTE")[1]  ,/*lPixel*/,{|| (_cSC9TMP)->C5_CLIENTE      })
	TRCell():New(oSection,"C5_LOJACLI"  ,"SC5"/*Tabela*/,RetTitle("C5_LOJACLI"),PesqPict  ("SC5","C5_LOJACLI"),TamSx3("C5_LOJACLI")[1]  ,/*lPixel*/,{|| (_cSC9TMP)->C5_LOJACLI      })
	TRCell():New(oSection,"C5_NOMCLI"   ,"SC5"/*Tabela*/,RetTitle("C5_NOMCLI" ),PesqPict  ("SC5","C5_NOMCLI" ),TamSx3("C5_NOMCLI" )[1]+5,/*lPixel*/,{|| (_cSC9TMP)->C5_NOMCLI       })
	TRCell():New(oSection,"C9_DATALIB"  ,"SC9"/*Tabela*/,"Lib. Fiscal"         ,PesqPict  ("SC9","C9_DATALIB"),TamSx3("C9_DATALIB")[1]  ,/*lPixel*/,{|| (_cSC9TMP)->C9_DATALIB      })
	TRCell():New(oSection,"DIAS"        ,_cSC9TMP       ,"Dias Pend."          ,""                            ,05                       ,/*lPixel*/,{|| (Date()-(_cSC9TMP)->C9_DATALIB)+1})
	TRCell():New(oSection,"VALOR"       ,_cSC9TMP       ,RetTitle("C6_VALOR"  ),PesqPictQt("C6_VALOR"        ),TamSx3("C6_VALOR"  )[1]+TamSx3("C6_VALOR")[2]+1,/*lPixel*/,{|| (_cSC9TMP)->VALOR})
	//oBreak := TRBreak():New(oSection,oSection:Cell("A3_GEREN"),"Sub-Total Gerente")
	//TRFunction():New(oSection:Cell("VALOR"  ),NIL,"SUM",oBreak)
	//������������������������������������������������������������������������Ŀ
	//� Alinhamento a direita as colunas de valor                              �
	//��������������������������������������������������������������������������
	oSection:Cell("DIAS" ):SetHeaderAlign("CENTER")
	oSection:Cell("VALOR"):SetHeaderAlign("RIGHT")
return oReport
/*/{Protheus.doc} PrintRel (RFATR037)
@description Processamento das informa��es para impress�o (Print).
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 20/11/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
static function PrintRel()
//Declara��o das vari�veis
	local _aCpos   := {}
	local _x       := 0
	local _cCpoSum := ""
	local _cOrder  := ""
	local _cGroup  := ""
	local _cField  := ""
	local _cFilSC9 := oSection:GetSqlExp("SC9")
	local _cFilSC5 := oSection:GetSqlExp("SC5")
	local _cFilSA3 := oSection:GetSqlExp("SA3")
//Fim da declara��o de vari�veis
//An�lise do preenchimento dos par�metros
	if MV_PAR01 > MV_PAR02 .OR. MV_PAR03 > MV_PAR05 .OR. MV_PAR04 > MV_PAR06 .OR. MV_PAR07 > MV_PAR08
		MsgStop("Par�metros informados incorretamente... confira!",_cRotina+"_001")
		return
	endif
//Fim da an�lise do preenchimento dos par�metros
//Adequa��o dos filtros de usu�rio
	if !empty(_cFilSC9)
		_cFilSC9 := "%AND "+_cFilSC9+"%"
	else
		_cFilSC9 := "%%"
	endif
	if !empty(_cFilSC5)
		_cFilSC5 := "%AND "+_cFilSC5+"%"
	else
		_cFilSC5 := "%%"
	endif
	if !empty(_cFilSA3)
		_cFilSA3 := "%AND "+_cFilSA3+"%"
	else
		_cFilSA3 := "%%"
	endif
//Fim da adequa��o dos filtros dos usu�rios
//Defini��o da ordem de apresenta��o das informa��es
/*
	if oReport:Section(1):GetOrder() == 1			//Gerente+Supervisor+Vendedor+Emiss�o
		_cOrder := "C9_FILIAL, A3_GEREN, A3_SUPER , C5_VEND1, C5_EMISSAO, C9_DATALIB, C5_CLIENTE, C5_LOJACLI, C9_PEDIDO"
	elseif oReport:Section(1):GetOrder() == 2		//Gerente+Supervisor+Vendedor+Libera��o
		_cOrder := "C9_FILIAL, A3_GEREN, A3_SUPER , C5_VEND1, C9_DATALIB, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C9_PEDIDO"
	elseif oReport:Section(1):GetOrder() == 3		//Gerente+Supervisor+Vendedor+Cliente+Loja
		_cOrder := "C9_FILIAL, A3_GEREN, A3_SUPER , C5_VEND1, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C9_DATALIB, C9_PEDIDO"
	elseif oReport:Section(1):GetOrder() == 4		//Cliente+Loja+Gerente+Supervisor+Vendedor
		_cOrder := "C9_FILIAL, C5_CLIENTE, C5_LOJACLI, A3_GEREN, A3_SUPER , C5_VEND1, C5_EMISSAO, C9_DATALIB, C9_PEDIDO"
	else
		_cOrder := "C9_FILIAL, A3_GEREN, A3_SUPER , C5_VEND1, C5_EMISSAO, C9_DATALIB, C5_CLIENTE, C5_LOJACLI, C9_PEDIDO"
	endif
*/
//Fim da Defini��o da ordem de apresenta��o das informa��es
// Inclus�o de novos totais.
	for _x := 1 to len(oSection:aCell)
		if !empty(oSection:aCell[_x]:cAlias) .AND. AllTrim(oSection:aCell[_x]:cAlias) <> (_cSC9TMP)
			if aScan(_aCpos, AllTrim(oSection:aCell[_x]:cName)) == 0
				if oSection:aCell[_x]:lUserEnabled
					if TamSx3(AllTrim(oSection:aCell[_x]:cName))[03]=="N"
						_cCpoSum += ", SUM(ISNULL(" + AllTrim(oSection:aCell[_x]:cName) + ", 0)) " + AllTrim(oSection:aCell[_x]:cName)
					else
						_cField  += ",     ISNULL(" + AllTrim(oSection:aCell[_x]:cName) + ",'')  " + AllTrim(oSection:aCell[_x]:cName)
						_cGroup  += ",     ISNULL(" + AllTrim(oSection:aCell[_x]:cName) + ",'')"
					endif
				else
					_cField  += ", '' " + AllTrim(oSection:aCell[_x]:cName)
				endif
			endif
		endif
	next
//Fim da Inclus�o de novos totais.
//Soma espec�fica de valor
	_cCpoSum += ", SUM(C9_PRCVEN*C9_QTDLIB) VALOR "
//Fim da soma espec�fica de valor
//Tratamento final das vari�veis que carregam os campos din�micos, para posterior uso no SQL Embended
	_cField  := "%C9_FILIAL" + _cField+_cCpoSum  + "%"
	_cGroup  := "%C9_FILIAL" + _cGroup + "%"
	_cOrder  := _cGroup
//Fim do Tratamento final das vari�veis que carregam os campos din�micos, para posterior uso no SQL Embended
//Elimina��o dos filtros do usu�rio para evitar duplicidades na query, uma vez que j� estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
	For _x := 1 To Len(oSection:aUserFilter)
		oSection:aUserFilter[_x][02] := oSection:aUserFilter[_x][03] := ""
	Next
	oSection:CSQLEXP := ""
//Fim da Elimina��o dos filtros do usu�rio para evitar duplicidades na query, uma vez que j� estou tratando (este procedimento precisa ser realizado antes da montagem da Query)
//Troca descricao do total dos itens
	oReport:Section(1):SetTotalText("T O T A I S ")
//Fim da Troca descricao do total dos itens
//PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
	//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
		MakeSqlExpr(oReport:uParam)
	//MakeSqlExpr(cPerg)
	oSection:BeginQuery()
		BeginSql alias _cSC9TMP
			SELECT %Exp:_cField%
			FROM %table:SC9% SC9 (NOLOCK)
				INNER JOIN      %table:SC5% SC5 (NOLOCK) ON SC5.C5_FILIAL = SC9.C9_FILIAL 
														AND SC5.C5_NUM    = SC9.C9_PEDIDO
														AND SC5.C5_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
														AND SC5.C5_VEND1   BETWEEN %Exp:MV_PAR07%       AND %Exp:MV_PAR08%
														AND SC5.%NotDel%
														%Exp:_cFilSC5%
				LEFT OUTER JOIN %table:SA3% SA3 (NOLOCK) ON SA3.A3_FILIAL = %xFilial:SA3%
														AND SA3.A3_COD    = SC5.C5_VEND1
														AND SA3.%NotDel%
														%Exp:_cFilSA3%
			WHERE SC9.C9_FILIAL            = %xFilial:SC9%
			  AND SC9.C9_DTLIBCR           = %Exp:''%
			  AND (CASE WHEN SC9.C9_BLCRED = %Exp:''% OR SC9.C9_BLCRED = %Exp:'10'% THEN 0 ELSE 1 END) = 1
			  AND SC9.C9_CLIENTE     BETWEEN %Exp:MV_PAR03%       AND %Exp:MV_PAR05%
			  AND SC9.C9_LOJA        BETWEEN %Exp:MV_PAR04%       AND %Exp:MV_PAR06%
			  AND SC9.%NotDel%
			  %Exp:_cFilSC9%
			GROUP BY %Exp:_cGroup%
			ORDER BY %Exp:_cOrder%
		EndSql
	oSection:EndQuery()
	//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",oSection:CQUERY)
//FIM DO PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
//Envio do relat�rio para a tela/impressora
	oSection:Print()
//Fim do Envio do relat�rio para a tela/impressora
return
/*/{Protheus.doc} ValidPerg (RFATR037)
@description Verifica se as perguntas existem na SX1. Caso n�o existam, as cria.
@author Anderson C. P. Coelho (ALLSS Solu��es em Sistemas)
@since 20/11/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	local _aArea := GetArea()
	local _aTam  := {}
	local aRegs := {}
	local i      := 0
	local j      := 0
	_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
	OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
	dbSelectArea(_cAliasSX1)
	(_cAliasSX1)->(dbSetOrder(1))
	cPerg  := PADR(cPerg,len((_cAliasSX1)->X1_GRUPO))
	_aTam  := TamSx3("C5_EMISSAO")
	AADD(aRegs,{cPerg,"01","Da Emiss�o?"             ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","",""      ,"",""})
	AADD(aRegs,{cPerg,"02","At� a Emiss�o?"          ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSx3("A1_COD"    )
	AADD(aRegs,{cPerg,"03","Do Cliente?"			 ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par03",""                 ,"","","","",""				,"","","","",""	   				,"","","","",""         ,"","","","","","","","","SA1"   ,"",""})
	_aTam  := TamSx3("A1_LOJA"   )
	AADD(aRegs,{cPerg,"04","Da Loja?"				 ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSx3("A1_COD"    )
	AADD(aRegs,{cPerg,"05","Ao Cliente?"			 ,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par05",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","","SA1"   ,"",""})
	_aTam  := TamSx3("A1_LOJA"   )
	AADD(aRegs,{cPerg,"06","At� a Loja?"			 ,"","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par06",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","",""      ,"",""})
	_aTam  := TamSx3("A3_COD"    )

	// Altera��o - Fernando Bombardi - ALLSS - 03/03/2022
	//AADD(aRegs,{cPerg,"07","Do Vendedor?"			 ,"","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par07",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","","SA3"   ,"",""})
	//AADD(aRegs,{cPerg,"08","Ao Vendedor?"			 ,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","","SA3"   ,"",""})

	AADD(aRegs,{cPerg,"07","Do Representante?"	     ,"","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""          ,"mv_par07",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","","SA3"   ,"",""})
	AADD(aRegs,{cPerg,"08","Ao Representante?"		 ,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()","mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","",""         ,"","","","","","","","","SA3"   ,"",""})
	// Fim - Fernando Bombardi - ALLSS - 03/03/2022

	for i := 1 to len(aRegs)
		if !(_cAliasSX1)->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock(_cAliasSX1,.T.) ; enddo
				for j := 1 to FCount()
					if j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					else
						Exit
					endif
				next
			(_cAliasSX1)->(MsUnLock())
		endif
	next
	RestArea(_aArea)
return
