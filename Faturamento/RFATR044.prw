#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RFATR044
@description Relat�rio de Auditoria de tempos de separa��es.
@author Arthur Silva (ALL System Solutions)
@since 17/04/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFATR044()
	Private oReport, oSection
	Private cTitulo  := OemToAnsi("Relat�rio de Auditoria de tempos de Separa��o/Confer�ncia")
	Private _cRotina := "RFATR044"
	Private cPerg    := _cRotina
	if FindFunction("TRepInUse") .And. TRepInUse()
		ValidPerg()
		if !Pergunte(cPerg,.T.)
			return
		endif
		oReport := ReportDef()
		oReport:PrintDialog()
	endif
return
/*/{Protheus.doc} ReportDef
@description Funcionando na rotina 'RFATR044', esta sub-funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.
@author Arthur Silva (ALL System Solutions)
@since 17/04/2017
@version 1.0
@type function
@return oReport, objeto, Objeto do relat�rio.
@see https://allss.com.br
/*/
static function ReportDef()
	Local _aOrd    := {"Separador + Ordem Separa��o"}		//{"Solicita��o + Produto","Nome + ..."}
	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//��������������������������������������������������������������������������
	//oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Relat�rio de Auditoria."+CHR(13)+CHR(10)+"Bons Neg�cios!"+CHR(13)+CHR(10)+"ARCOLOR")
	oReport := TReport():New(_cRotina,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Relat�rio de Auditoria.")
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
	oSection := TRSection():New(oReport,"Informa��es",{"CB7"},_aOrd/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection:SetTotalInLine(.F.)
	//Defini��o das colunas do relat�rio
	TRCell():New(oSection,"CB7_CODOPE"    	,"CB7TMP","C�digo Separador" ,PesqPict  ("CB7","CB7_CODOPE" )	,TamSx3("CB7_CODOPE"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_CODOPE 		})	// CODIGO OPERADOR
	TRCell():New(oSection,"CB7_NOMOP1"    	,"CB7TMP","Nome Separador" 	 ,PesqPict  ("CB7","CB7_NOMOP1" )	,TamSx3("CB7_NOMOP1"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_NOMOP1 		})	// NOME OPERADOR
	TRCell():New(oSection,"CB7_ORDSEP" 		,"CB7TMP","Ordem Separa��o"  ,PesqPict  ("CB7","CB7_ORDSEP"  )	,TamSx3("CB7_ORDSEP"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_ORDSEP		})	// DATA INICIO SEPARA��O
	TRCell():New(oSection,"CB7_NF" 		    ,"CB7TMP","Nota Fiscal" ,PesqPict  ("CB7","CB7_NF"  )	,TamSx3("C9_NFISCAL"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_NF		})	// DATA INICIO SEPARA��O
	TRCell():New(oSection,"CB7_DTISEP" 		,"CB7TMP","Data In�cio Sep." ,PesqPict  ("CB7","CB7_DTISEP"  )	,TamSx3("CB7_DTISEP"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_DTISEP		})	// DATA INICIO SEPARA��O
	TRCell():New(oSection,"CB7_HRISOS" 		,"CB7TMP","Hora In�cio Sep." ,PesqPict  ("CB7","CB7_HRISOS"  )	,TamSx3("CB7_HRISOS"  )[1] ,/*lPixel*/,{|| CB7TMP->HORA_INICIO		})	// HORA INICIO SEPARA��O
	TRCell():New(oSection,"CB7_DTFSEP" 		,"CB7TMP","Data Final Sep."  ,PesqPict  ("CB7","CB7_DTFSEP"  )	,TamSx3("CB7_DTFSEP"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_DTFSEP		})	// DATA FIM SEPARA��O
	TRCell():New(oSection,"CB7_HRFSOS" 		,"CB7TMP","Hora Final Sep."  ,PesqPict  ("CB7","CB7_HRFSOS"  )	,TamSx3("CB7_HRFSOS"  )[1] ,/*lPixel*/,{|| CB7TMP->HORA_FINAL		})	// HORA FINAL SEPARA��O
	TRCell():New(oSection,"TEMPO_SEPARACAO" ,"CB7TMP","Tempo Separa��o"  ,"99:99:99"						,TamSx3("CB7_HRFSOS"  )[1] ,/*lPixel*/,{|| CB7TMP->TEMPO_SEPARACAO	})	// TEMPO TOTAL DE SEPARA��O
	TRCell():New(oSection,"CB7_CODOP2"    	,"CB7TMP","C�digo Conferente",PesqPict  ("CB7","CB7_CODOP2" )	,TamSx3("CB7_CODOP2"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_CODOP2 		})	// CODIGO OPERADOR CONFERENTE
	TRCell():New(oSection,"CB7_NOMOP2"    	,"CB7TMP","Nome Conferente"  ,PesqPict  ("CB7","CB7_NOMOP2" )	,TamSx3("CB7_NOMOP2"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_NOMOP2 		})	// NOME OPERADOR
	TRCell():New(oSection,"CB7_DTINIS" 		,"CB7TMP","Data In�cio Conf.",PesqPict  ("CB7","CB7_DTINIS"  )	,TamSx3("CB7_DTINIS"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_DTINIS		})	// DATA INICIO CONFERENCIA
	TRCell():New(oSection,"CB7_HRINIS" 		,"CB7TMP","Hora In�cio Conf.",									,10						   ,/*lPixel*/,{|| CB7TMP->CB7_HRINIS		})	// HORA INICIO CONFERENCIA
	TRCell():New(oSection,"CB7_DTFIMS" 		,"CB7TMP","Data Final Conf." ,PesqPict  ("CB7","CB7_DTFIMS"  )	,TamSx3("CB7_DTFIMS"  )[1] ,/*lPixel*/,{|| CB7TMP->CB7_DTFIMS		})	// DATA FIM CONFERENCIA
	TRCell():New(oSection,"CB7_HRFIMS" 		,"CB7TMP","Hora Final Conf." ,									,10						   ,/*lPixel*/,{|| CB7TMP->CB7_HRFIMS		})	// HORA FINAL CONFERENCIA
	TRCell():New(oSection,"TEMPO_CONF" 		,"CB7TMP","Tempo Conferencia","99:99:99"						,TamSx3("CB7_HRFSOS"  )[1] ,/*lPixel*/,{|| CB7TMP->TEMPO_CONF		})	// TEMPO TOTAL DE SEPARA��O
	/*
	oSection:SetEdit(.T.)
	oSection:SetUseQuery(.T.)
	oSection:SetEditCell(.T.)
	//oSection:DelUserCell(.F.)
	*/
	oBreak := TRBreak():New(oSection,oSection:Cell("CB7_CODOPE"),"Sub-Total Por Operador ")
	TRFunction():New(oSection:Cell("CB7_CODOPE"),NIL,"COUNT",oBreak) // Totalizador
	//TRFunction():New(oSection:Cell("TEMPO_SEPARACAO"),NIL,"SUM",oBreak) // Totalizador
	//������������������������������������������������������������������������Ŀ
	//� Troca descricao do total dos itens                                     �
	//��������������������������������������������������������������������������
	oReport:Section(1):SetTotalText("Total")
	oReport:Section(1):SetEdit(.T.)
	//oReport:Section(1):SetUseQuery(.T.) // Novo componente tReport para adcionar campos de usuario no relatorio qdo utiliza query
	//������������������������������������������������������������������������Ŀ
	//� Alinhamento a direita as colunas de valor                              �
	//��������������������������������������������������������������������������
	//oSection:Cell("CAMPO"):SetHeaderAlign("RIGHT")
return oReport
/*/{Protheus.doc} PrintReport
@description Funcionando na rotina 'RFATR044', esta sub-rotina � relativa ao processamento das informa��es para impress�o (Print).
@author Arthur Silva (ALL System Solutions)
@since 17/04/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function PrintReport(oReport)
	Local _x       := 0
//	Local _cQry	   := ""
	Local _cOrder  := ""
	Local _cField  := ""
//	Local _cFilCB7 := oSection:GetSqlExp("CB7")
	if MV_PAR01 > MV_PAR02 .OR. MV_PAR03 > MV_PAR04
		MsgStop("Par�metros informados incorretamente!",_cRotina+"_002")
		return
	endif
	//Defini��o da ordem de apresenta��o das informa��es
	If oReport:Section(1):GetOrder() == 1			//Ordem por Nome
		_cOrder := "CB7_CODOPE, CB7_NOMOP1"
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
		BeginSql Alias "CB7TMP"
			SELECT	 CB7_DTFSEP
					,CB7_DTISEP
					,DIF [DIFERENCA DE TEMPO EM SEGUNDOS]
					,CB7_HRISOS HORA_INICIO 																																																													,CB7_HRFSOS HORA_FINAL
					,CASE WHEN CB7_DTFSEP = '' THEN 'NAO FINALIZADO' ELSE ISNULL((REPLICATE('0',2-LEN(HORA))+HORA	+ ':' +	REPLICATE('0',2-LEN(MINUTO))+MINUTO	+ ':' +	REPLICATE('0',2-LEN(SEGUNDOS))+SEGUNDOS),'NAO FINALIZADO') END TEMPO_SEPARACAO
					,(DIF_CONFERENCIA) DIF_CONF
					,CASE WHEN CB7_DTFIMS = '' THEN 'PENDENTE' ELSE ISNULL((REPLICATE('0',2-LEN(HORA_CONF))+HORA_CONF	+ ':' +	REPLICATE('0',2-LEN(MINUTO_CONF))+MINUTO_CONF	+ ':' +	REPLICATE('0',2-LEN(SEGUNDOS_CONF))+SEGUNDOS_CONF),'NAO FINALIZADO')END  TEMPO_CONF 			
					,CB7_ORDSEP 			
					,CB7_NOMOP1 			
					,CB7_CODOPE 			
					,CB7_CODOP2 			
					,CB7_NOMOP2 			
					,CB7_DTINIS 			
					,CASE WHEN CB7_HRINIS = '' THEN '' ELSE ISNULL(SUBSTRING(CB7_HRINIS,1,2)+':'+SUBSTRING(CB7_HRINIS,3,2)+':'+SUBSTRING(CB7_HRINIS,5,2),'')END CB7_HRINIS 			
					,CB7_DTFIMS 			
					,CASE WHEN CB7_HRFIMS = '' THEN '' ELSE ISNULL(SUBSTRING(CB7_HRFIMS,1,2)+':'+SUBSTRING(CB7_HRFIMS,3,2)+':'+SUBSTRING(CB7_HRFIMS,5,2),'')END CB7_HRFIMS 				
					, CB7_NF
					FROM ( SELECT 						
								DIF
								,CB7_HRISOS 						
								,CB7_HRFSOS 						
								,(DIF/60) DIF_MIN 						
								,CAST(CAST((((DIF)/60)/60) AS INT) AS NVARCHAR(999)) HORA 						
								,CAST(( CAST(((DIF)/60) AS INT) - (CAST((((DIF)/60)/60) AS INT) * 60) ) AS NVARCHAR(999)) MINUTO 						
								,CAST(((DIF) - (  (CAST((((DIF)/60)/60) AS INT) * 60 * 60) + (( CAST(((DIF)/60) AS INT) - (CAST((((DIF)/60)/60) AS INT) * 60) ) * 60)  )) AS NVARCHAR(999)) SEGUNDOS 						
								,DIF_CONFERENCIA 						
								,(((DIF_CONFERENCIA)/60)) DIF_MIN_SEP 						
								, CAST(CAST((((DIF_CONFERENCIA)/60)/60) AS INT) AS NVARCHAR(999)) HORA_CONF 						
								, CAST(( CAST(((DIF_CONFERENCIA)/60) AS INT) - (CAST((((DIF_CONFERENCIA)/60)/60) AS INT) * 60) ) AS NVARCHAR(999)) MINUTO_CONF 						
								, CAST(((DIF_CONFERENCIA) - (  (CAST((((DIF_CONFERENCIA)/60)/60) AS INT) * 60 * 60) + (( CAST(((DIF_CONFERENCIA)/60) AS INT) - (CAST((((DIF_CONFERENCIA)/60)/60) AS INT) * 60) ) * 60)  )) AS NVARCHAR(999)) SEGUNDOS_CONF 						
								,CB7_ORDSEP 						
								,CB7_NOMOP1 						
								,CB7_CODOPE 						
								,CB7_DTFSEP 						
								,CB7_CODOP2 						
								,CB7_NOMOP2 						
								,CB7_DTINIS 						
								,CB7_HRINIS 						
								,CB7_DTFIMS 						
								,CB7_HRFIMS 						
								,CB7_DTISEP 
								,CB7_NF						
								FROM (SELECT 	
										CASE WHEN CB7_DTISEP = '' OR CB7_DTFSEP = '' 										 
											 THEN (DATEDIFF(SECOND,'2049-01-01 00:00:00','2049-01-01 00:00:00'))
											 ELSE (DATEDIFF (SECOND,CONVERT(DATETIME,CB7_DTISEP+' '+CB7_HRISOS),CONVERT(DATETIME,CB7_DTFSEP+' '+CB7_HRFSOS))) END DIF
										,CASE WHEN CB7_DTINIS = '' OR CB7_DTFIMS = '' 										 
											 THEN (DATEDIFF(SECOND,'2049-01-01 00:00:00','2049-01-01 00:00:00')) 
											 ELSE (DATEDIFF (SECOND,CONVERT(DATETIME,CB7_DTINIS+' '+ISNULL(SUBSTRING(CB7_HRINIS,1,2)+':'+SUBSTRING(CB7_HRINIS,3,2)+':'+SUBSTRING(CB7_HRINIS,5,2),'')),CONVERT(DATETIME,CB7_DTFIMS+' '+ISNULL(SUBSTRING(CB7_HRFIMS,1,2)+':'+SUBSTRING(CB7_HRFIMS,3,2)+':'+SUBSTRING(CB7_HRFIMS,5,2),''))))END DIF_CONFERENCIA 
												  ,CB7_HRISOS 									
												  ,CB7_HRFSOS 									
												  ,CB7_ORDSEP 									
												  ,CB7_NOMOP1 									
												  ,CB7_CODOPE 									
												  ,CB7_DTFSEP 									
												  ,CB7_DTISEP 									
												  ,CB7_CODOP2 									
												  ,CB7_NOMOP2 									
												  ,CB7_DTINIS 									
												  ,CB7_HRINIS 									
												  ,CB7_DTFIMS 									
												  ,CB7_HRFIMS 									
												  ,CB7_STATUS
												  , (select DISTINCT C9_NFISCAL from %table:SC9% SC9  (NOLOCK)  WHERE SC9.C9_ORDSEP = CB7.CB7_ORDSEP AND SC9.%NotDel% )  CB7_NF								
												FROM %table:CB7% CB7 (NOLOCK)
												WHERE CB7.CB7_FILIAL = %xFilial:CB7%
												  AND CB7.CB7_DTISEP BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
												  AND CB7.CB7_CODOPE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
												  AND (CASE WHEN %Exp:MV_PAR05% = 1 OR (CB7.CB7_HRFSOS <> '' AND CB7.CB7_DTFIMS <> '') THEN 'V' ELSE 'F' END ) = 'V' 
												  AND CB7.%NotDel%
												) XXX
											) YYY
			ORDER BY CB7_CODOPE
		EndSql
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
	oSection:EndQuery()
	//if __cUserID == "000000"
		//MemoWrite("\"+_cRotina+"_QRY_001.txt",oSection:CQUERY)
	//endif
	oSection:Print()
return
/*/{Protheus.doc} ValidPerg
@description Funcionando na rotina 'RFATR044', esta sub-rotina verifica se as perguntas existem na SX1. Caso n�o existam, as cria.
@author Arthur Silva (ALL System Solutions)
@since 17/04/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function ValidPerg()
	Local _aArea := GetArea()
	Local aRegs  := {}
	Local _aTam  := {}
	Local i      := 0
	Local j      := 0

	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	cPerg  := PADR(cPerg,len(SX1->X1_GRUPO))
	_aTam  := TamSx3("CB7_DTISEP" )
	AADD(aRegs,{cPerg,"01","Da Data?				","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par01",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	_aTam  := TamSx3("CB7_DTISEP" )
	AADD(aRegs,{cPerg,"02","At� Data?				","","","mv_ch2",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par02",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","",""   ,"",""})
	_aTam  := TamSx3("CB7_CODOPE")
	AADD(aRegs,{cPerg,"03","Do Operador?			","","","mv_ch3",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par03",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","CB1","",""})
	_aTam  := TamSx3("CB7_CODOPE" )
	AADD(aRegs,{cPerg,"04","At� o Operador?			","","","mv_ch4",_aTam[03],_aTam[01],_aTam[02],0,"G","","mv_par04",""     ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","CB1","",""})
	AADD(aRegs,{cPerg,"05","Pendentes?				","","","mv_ch5","N"	  ,01       ,0        ,0,"C","","mv_par05","Sim"  ,"","","","","N�o"  ,"","","","",""     ,"","","","","","","","","","","","","","   ","",""})
	For i := 1 To Len(aRegs)
		If !SX1->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock("SX1",.T.) ; enddo
				For j := 1 To FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Else
						Exit
					EndIf
				Next
			SX1->(MsUnLock())
		EndIf
	Next
	RestArea(_aArea)
return