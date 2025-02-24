#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include 'protheus.ch'
#include 'parmtype.ch'
#DEFINE _CRFL CHR(13) + CHR(10)
/*/{Protheus.doc} RPONR003
//TODO Relat�rio de confer�ncia dos eventos do ponto eletr�nico em determinado per�odo, de determinadas matr�culas e/ou centros de custo
@description Relat�rio de confer�ncia dos eventos do ponto eletr�nico em determinado per�odo, de determinadas matr�culas e/ou centros de custo
@author Anderson Coelho
@since 12/03/2018
@version 1.0
@type function
@see https://www.allss.com.br
/*/
user function RPONR003()
	Private oReport
	Private oSection
	Private _cRotina  := "RPONR003"
	Private cPerg     := _cRotina
	Private aRegs    := {}
//	Private _aCpos    := {}
	If FindFunction("TRepInUse") .And. TRepInUse()
		ValidPerg()
		If !Pergunte(cPerg,.T.)
			return
		EndIf
		oReport  := ReportDef()
		oReport:PrintDialog()
	EndIf
return
static function ReportDef()
	Local cTitulo  := "Rel. de Confer�cia dos Eventos do Ponto Eletr�nico"
	Local _aOrd    := {"Filial+Matr�cula+Data+Evento","Filial+Matr�cula+Evento+Data","Filial+Centro de Custo+Matr�cula+Data+Evento","Filial+Centro de Custo+Matr�cula+Evento+Data"}
	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//��������������������������������������������������������������������������
//	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Emissao do relat�rio, de acordo com o intervalo informado na op��o de Par�metros.")
	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|| PrintReport()},"Emissao do relat�rio, de acordo com o intervalo informado na op��o de Par�metros.")
	oReport:SetLandscape() 
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
	oSection := TRSection():New(oReport,"RELAT�RIO DE OCORR�NCIAS DO PONTO",{"SRA","SPC","SP9","SP6"},_aOrd/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)

	//Defini��o das colunas do relat�rio
	TRCell():New(oSection,"RA_MAT"      ,"SRA"/*Tabela*/,RetTitle("RA_MAT"    ),PesqPict  ("SRA","RA_MAT"   ),TamSx3("RA_MAT"    )[1],/*lPixel*/,{|| SPCTMP->RA_MAT        })
	TRCell():New(oSection,"RA_NOME"     ,"SRA"/*Tabela*/,RetTitle("RA_NOME"   ),PesqPict  ("SRA","RA_NOME"  ),TamSx3("RA_NOME"   )[1],/*lPixel*/,{|| SPCTMP->RA_NOME       })
	TRCell():New(oSection,"RA_CC"       ,"SRA"/*Tabela*/,RetTitle("RA_CC"     ),PesqPict  ("SRA","RA_CC"    ),TamSx3("RA_CC"     )[1],/*lPixel*/,{|| SPCTMP->RA_CC         })
	TRCell():New(oSection,"RA_DEPTO"    ,"SRA"/*Tabela*/,RetTitle("RA_DEPTO"  ),PesqPict  ("SRA","RA_DEPTO" ),TamSx3("RA_DEPTO"  )[1],/*lPixel*/,{|| SPCTMP->RA_DEPTO  	   })
	TRCell():New(oSection,"QB_DESCRIC"  ,"SQB"/*Tabela*/,RetTitle("QB_DESCRIC"),PesqPict  ("SQB","QB_DESCRIC"),TamSx3("QB_DESCRIC" )[1],/*lPixel*/,{|| SPCTMP->QB_DESCRIC  })
	TRCell():New(oSection,"PC_DATA"     ,"SPC"/*Tabela*/,RetTitle("PC_DATA"   ),PesqPict  ("SPC","PC_DATA"  ),TamSx3("PC_DATA"   )[1],/*lPixel*/,{|| SPCTMP->PC_DATA       })
	TRCell():New(oSection,"PC_PD"       ,"SPC"/*Tabela*/,RetTitle("PC_PD"     ),PesqPict  ("SPC","PC_PD"    ),TamSx3("PC_PD"     )[1],/*lPixel*/,{|| SPCTMP->PC_PD         })
	TRCell():New(oSection,"P9_DESC"     ,"SP9"/*Tabela*/,RetTitle("P9_DESC"   ),PesqPict  ("SP9","P9_DESC"  ),TamSx3("P9_DESC"   )[1],/*lPixel*/,{|| SPCTMP->P9_DESC       })
	TRCell():New(oSection,"PC_QUANTC"   ,"SPC"/*Tabela*/,RetTitle("PC_QUANTC" ),PesqPictQt("PC_QUANTC"	    ),TamSx3("PC_QUANTC" )[1],/*lPixel*/,{|| SPCTMP->PC_QUANTC     })
	TRCell():New(oSection,"PC_QTABONO"  ,"SPC"/*Tabela*/,RetTitle("PC_QTABONO"),PesqPictQt("PC_QTABONO"	    ),TamSx3("PC_QTABONO")[1],/*lPixel*/,{|| SPCTMP->PC_QTABONO    })
	TRCell():New(oSection,"PC_ABONO"    ,"SPC"/*Tabela*/,RetTitle("PC_ABONO"  ),PesqPict  ("SPC","PC_ABONO" ),TamSx3("PC_ABONO"  )[1],/*lPixel*/,{|| SPCTMP->PC_ABONO      })
	TRCell():New(oSection,"P6_DESC"     ,"SP6"/*Tabela*/,RetTitle("P6_DESC"   ),PesqPict  ("SP6","P6_DESC"  ),TamSx3("P6_DESC"   )[1],/*lPixel*/,{|| SPCTMP->P6_DESC       })
	TRCell():New(oSection,"P9_CODFOL"   ,"SP9"/*Tabela*/,RetTitle("P9_CODFOL" ),PesqPict  ("SP9","P9_CODFOL"),TamSx3("P9_CODFOL" )[1],/*lPixel*/,{|| SPCTMP->P9_CODFOL     })
	TRCell():New(oSection,"OBS"         ,""   /*Tabela*/,"Obs."                ,"@!"                         ,60                     ,/*lPixel*/,{|| Replicate("_",60)     })
	oBreak := TRBreak():New(oSection,oSection:Cell("RA_MAT"),"Qtd. Registros da Matr�cula")
	TRFunction():New(oSection:Cell("PC_DATA"  ),NIL,"COUNT",oBreak)
	oSection:Cell("PC_DATA"  ):SetHeaderAlign("CENTER")
return(oReport)
//static function PrintReport(oReport)
static function PrintReport()
	//Declara��o das vari�veis
	//Local oSection := oReport:Section(1)
	Local _cOrder  := ""
	Local _cLogPar := ""
	Local _cFilSRA := oSection:GetSqlExp("SRA")
	Local _cFilSPC := oSection:GetSqlExp("SPC")
	Local _cFilSP9 := oSection:GetSqlExp("SP9")
	Local _cFilSP6 := oSection:GetSqlExp("SP6")
	Local _p       := 0
//Fim da declara��o de vari�veis
//An�lise do preenchimento dos par�metros
	If MV_PAR01 > MV_PAR02 .OR. MV_PAR03 > MV_PAR04 .OR. MV_PAR05 > MV_PAR06
		MsgStop("Par�metros informados incorretamente... confira!",_cRotina+"_002_A")
		_cLogPar := "Par�metros" + _CRFL
		_cLogPar += "**********" + _CRFL
			_cLogPar += ">>> "                          + ;
						"01"          + " - " + ;
						AllTrim("Do Funcion�rio?") + ": "  + ;
						ALLTRIM(MV_PAR01) + _CRFL
			_cLogPar += ">>> "                          + ;
						"02"          + " - " + ;
						AllTrim("Ao Funcion�rio?") + ": "  + ;
						ALLTRIM(MV_PAR02) + _CRFL
			_cLogPar += ">>> "                          + ;
						"03"          + " - " + ;
						AllTrim("Do Centro de Custo?") + ": "  + ;
						ALLTRIM(MV_PAR03) + _CRFL
			_cLogPar += ">>> "                          + ;
						"04"          + " - " + ;
						AllTrim("Ao Centro de Custo?") + ": "  + ;
						ALLTRIM(MV_PAR04) + _CRFL
			_cLogPar += ">>> "                          + ;
						"05"          + " - " + ;
						AllTrim("Da Data?") + ": "  + ;
						DTOC(MV_PAR05) + _CRFL
			_cLogPar += ">>> "                          + ;
						"06"          + " - " + ;
						AllTrim("At� a Data?") + ": "  + ;
						DTOC(MV_PAR06) + _CRFL

		/*
		for _p := 1 to Len(aRegs)
			_cLogPar += ">>> "                          + ;
						aRegs[_p][02]          + " - " + ;
						AllTrim(aRegs[_p][03]) + ": "  + ;
						IIF(Type("MV_PAR"+aRegs[_p][02])=="C",&("MV_PAR"+aRegs[_p][02]),IIF(Type("MV_PAR"+aRegs[_p][02])=="D",DTOC(&("MV_PAR"+aRegs[_p][02])),IIF(Type("MV_PAR"+aRegs[_p][02])=="N",cValToChar(&("MV_PAR"+aRegs[_p][02])),""))) + _CRFL
		next
		*/
		MsgInfo(_cLogPar,_cRotina+"_002_B")
		return
	EndIf
//Fim da an�lise do preenchimento dos par�metros
//Adequa��o dos filtros de usu�rio
	If !Empty(_cFilSRA)
		_cFilSRA := "%AND "+_cFilSRA+"%"
	EndIf
	If Empty(_cFilSRA)
		_cFilSRA := "%%"
	EndIf
	If !Empty(_cFilSPC)
		_cFilSPC := "%AND "+_cFilSPC+"%"
	EndIf
	If Empty(_cFilSPC)
		_cFilSPC := "%%"
	EndIf
	If !Empty(_cFilSP9)
		_cFilSP9 := "%AND "+_cFilSP9+"%"
	EndIf
	If Empty(_cFilSP9)
		_cFilSP9 := "%%"
	EndIf
	If !Empty(_cFilSP6)
		_cFilSP6 := "%AND "+_cFilSP6+"%"
	EndIf
	If Empty(_cFilSP6)
		_cFilSP6 := "%%"
	EndIf
//Fim da adequa��o dos filtros dos usu�rios
//Defini��o da ordem de apresenta��o das informa��es
	If oReport:Section(1):GetOrder() == 1		//Filial+Matr�cula+Data+Evento
		_cOrder := "RA_FILIAL, RA_MAT, PC_DATA, PC_PD"
	ElseIf oReport:Section(1):GetOrder() == 2		//Filial+Matr�cula+Evento+Data
		_cOrder := "RA_FILIAL, RA_MAT, PC_PD  , PC_DATA"
	ElseIf oReport:Section(1):GetOrder() == 3		//Filial+Centro de Custo+Matr�cula+Data+Evento									
		_cOrder := "RA_FILIAL, RA_CC, RA_MAT, PC_DATA, PC_PD"
	ElseIf oReport:Section(1):GetOrder() == 4		//Filial+Centro de Custo+Matr�cula+Evento+Data
		_cOrder := "RA_FILIAL, RA_CC, RA_MAT, PC_PD  , PC_DATA"
	EndIf
//Fim da Defini��o da ordem de apresenta��o das informa��es
//Tratamento final das vari�veis que carregam os campos din�micos, para posterior uso no SQL Embended
	_cOrder  := "%" + _cOrder  + "%"
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
//Troca descricao do total dos itens
//	oReport:Section(1):SetTotalText("T O T A I S ")
//Fim da Troca descricao do total dos itens
//PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
	//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
		MakeSqlExpr(oReport:uParam)
	//MakeSqlExpr(cPerg)
		oSection:BeginQuery()
		BeginSql alias "SPCTMP"
			SELECT *,
				SQB.QB_DESCRIC
			FROM %table:SRA% SRA (NOLOCK)
				INNER JOIN %table:SPC% SPC (NOLOCK) ON SPC.PC_FILIAL       = %xFilial:SPC%
												   AND SPC.PC_DATA   BETWEEN %Exp:DTOS(MV_PAR05)% AND %Exp:DTOS(MV_PAR06)%
												   AND SPC.PC_PD          IN ('004','008','010','012','014','020','027','028','210','211','212','213','214','215','220','221','230','231','232','233','234','235','240','241','250','251','252','253','254','255','260','261','270','271','272','273','274','275','280','281','290','310','311','312','313','314','315','320','321','330','331','332','333','334','335','340','341','350','351','352','353','354','355','360','361','370','371','372','373','374','375','380','381','390')
												   AND SPC.PC_MAT          = SRA.RA_MAT
												   AND SPC.%NotDel%
												   %Exp:_cFilSPC%
				INNER JOIN %table:SP9% SP9 (NOLOCK) ON SP9.P9_FILIAL       = %xFilial:SP9%
												   AND SP9.P9_CODIGO       = SPC.PC_PD
												   AND SP9.%NotDel%
												   %Exp:_cFilSP9%
		   LEFT OUTER JOIN %table:SP6% SP6 (NOLOCK) ON SP6.P6_FILIAL       = %xFilial:SP6%
												   AND SP6.P6_CODIGO       = SPC.PC_ABONO
												   AND SP6.%NotDel%
												   %Exp:_cFilSP6%
		   LEFT OUTER JOIN %table:SQB% SQB (NOLOCK) ON SQB.QB_FILIAL       = %xFilial:SQB%
													AND SQB.QB_DEPTO = SRA.RA_DEPTO
													AND SQB.D_E_L_E_T_ = ''
			WHERE SRA.RA_FILIAL = %xFilial:SRA%
			  AND SRA.RA_MAT BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			  AND SRA.RA_CC  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			  AND SQB.QB_DEPTO BETWEEN  %exp:mv_par07% AND %exp:mv_par08%
			  AND SRA.%NotDel%
			  %Exp:_cFilSRA%
			ORDER BY %Exp:_cOrder%
		EndSql
		oSection:EndQuery()
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",oSection:CQUERY)
//FIM DO PROCESSAMENTO DAS INFORMA��ES PARA IMPRESS�O
//Envia o relat�rio para a tela/impressora
	oSection:Print()
return
static function ValidPerg()
	Local _aArea := GetArea()
	Local _aTam  := {}
	Local i      := 0

	cPerg  := PADR(cPerg,10)
	aRegs := {}
	_aTam  := TamSx3("RA_MAT"    )
	AADD(aRegs,{cPerg,"01","Do Funcion�rio?"        ,"","","mv_ch1",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""            ,"mv_par01",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SRA"   ,"",""})
	AADD(aRegs,{cPerg,"02","Ao Funcion�rio?"        ,"","","mv_ch2",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()"  ,"mv_par02",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SRA"   ,"",""})
	_aTam  := TamSx3("RA_CC"     )
	AADD(aRegs,{cPerg,"03","Do Centro de Custo?"    ,"","","mv_ch3",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""            ,"mv_par03",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","CTT"   ,"",""})
	AADD(aRegs,{cPerg,"04","Ao Centro de Custo?"    ,"","","mv_ch4",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()"  ,"mv_par04",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","CTT"   ,"",""})
	_aTam  := TamSx3("PC_DATA")
	AADD(aRegs,{cPerg,"05","Da Data?"               ,"","","mv_ch5",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()"  ,"mv_par05",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""      ,"",""})
	AADD(aRegs,{cPerg,"06","At� a Data?"            ,"","","mv_ch6",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()"  ,"mv_par06",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""      ,"",""})
	_aTam  := TamSx3("RA_DEPTO"     )
	AADD(aRegs,{cPerg,"07","Do Departamento?"    ,"","","mv_ch7",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G",""            ,"mv_par07",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SQB"   ,"",""})
	AADD(aRegs,{cPerg,"08","Ao Departamento?"    ,"","","mv_ch8",_aTam[03],_aTam[01]	,_aTam[02]	,0,"G","NAOVAZIO()"  ,"mv_par08",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SQB"   ,"",""})

/*
	_aTam := {80,00,"C"}
	AADD(aRegs,{cPerg,"07","Eventos a Desconsid.?"  ,"","","mv_ch7",_aTam[03],_aTam[01]    ,_aTam[02]  ,0,"G",""            ,"MV_PAR07",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SP9"   ,"",""})
	AADD(aRegs,{cPerg,"08","Eventos a Considerar?"  ,"","","mv_ch8",_aTam[03],_aTam[01]    ,_aTam[02]  ,0,"G",""            ,"MV_PAR08",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","","SP9"   ,"",""})
	_aTam := {15,00,"C"}
	AADD(aRegs,{cPerg,"09","Situa��es?"             ,"","","mv_ch9",_aTam[03],_aTam[01]    ,_aTam[02]  ,0,"G","fSituacao()" ,"MV_PAR09",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""      ,"",""})
	AADD(aRegs,{cPerg,"10","Categorias?"            ,"","","mv_cha",_aTam[03],_aTam[01]    ,_aTam[02]  ,0,"G","fCategoria()","MV_PAR10",""                 ,"","","","",""				,"","","","",""					,"","","","","","","","","","","","","",""      ,"",""})
*/
	for i := 1 to len(aRegs)
		dbSelectArea("SX1")
		SX1->(dbSetOrder(1))
		If !SX1->(dbSeek(cPerg+aRegs[i,2]))
			RecLock("SX1",.T.)
			for j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Else
					Exit
				EndIf
			next
			SX1->(MsUnlock())
		EndIf
	next
	RestArea(_aArea)
return
