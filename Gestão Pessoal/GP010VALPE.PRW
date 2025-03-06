#include "totvs.ch"
/*/{Protheus.doc} GP010VALPE
@description Ponto de entrada para validar as operações de inclusão e alteração do cadastro de funcionários, utilizado para replicar o cadastro para o cadastro de clientes (controle interno de vendas para funcionários).
@author Adriano Leonardo
@since 24/03/2014
@version 1.0
@type function
@return _lRet, lógico, Funcionário válido para a inclusão/alteração.
@history 06/01/2021, Diego Rodrigues Pereira, Ajuste no fonte para fazer alteração no cadastro de cliente quando
alterar o cadastro de funcionario nos campos que não são incluidos por parametro.
@see https://allss.com.br
/*/
user function GP010VALPE()
	local   _aSavArea  := GetArea()
	local   _aSavSA1   := SA1->(GetArea())
	local   _aSavSRA   := SRA->(GetArea())
	local   _cRotina   := "GP010VALPE"
	local   _cCodCli   := ""
	local   _cLojCli   := ""
	local   _lRet      := .T.
	local   _lAtuCli   := .F.
	//Incluido por Fernando Bombardi - ALLSS - 22/01/20 - Implementacao cadastro de cliente por Execauto
	local   _aSA1Auto   := {}
//	local   _aAI0Auto   := {}
	local   _nOpcAuto   := 3

	private lMsErroAuto := .F.
	//Fim FB

	//Verifico a existência dos campos necessários para execução da rotina
	if SRA->(FieldPos("RA_CLIENTE"))==0 .Or. SRA->(FieldPos("RA_LOJACLI"))==0
		MsgStop("Atenção! Campos RA_CLIENTE e RA_LOJACLI não existem. Por favor, informe o administrador do sistema!",_cRotina+"_001")
		RestArea(_aSavSRA)
		RestArea(_aSavSA1)
		RestArea(_aSavArea)
		return _lRet
	endif
	if AllTrim(M->RA_SITFOLH)<>"D"
		if Empty(M->RA_CLIENTE)
			_lAtuCli := .T.
		endif
		if !_lAtuCli
			dbSelectArea("SA1")
			SA1->(dbOrderNickName("A1_CGC")) //SA1->(dbSetOrder(3))
			if SA1->(dbSeek(xFilial("SA1")+Padr(M->RA_CIC,TamSx3("A1_CGC")[01]))) .OR. (M->RA_CLIENTE+M->RA_LOJACLI) <> (SA1->A1_COD+SA1->A1_LOJA)
				_lAtuCli := .T.
			endif
		endif
		if _lAtuCli
			if Empty(M->RA_CIC)
				MsgStop("Atenção! O CPF não foi informado para este funcionário. O cadastro de clientes não será gerado!",_cRotina+"_006")
			else
				//Alterado por Arthur Silva em 31/08/2015, alterado os campos da tabela SRA para campos de Memória (Exemplo: era SRA->RA_NOME foi alterado para M->RA_NOME) 
				dbSelectArea("SA1")
				SA1->(dbOrderNickName("A1_CGC"))		//SA1->(dbSetOrder(3))
				if SA1->(dbSeek(xFilial("SA1")+Padr(M->RA_CIC,TamSx3("A1_CGC")[01])))
					_cCodCli := M->RA_CLIENTE := SA1->A1_COD
					_cLojCli := M->RA_LOJACLI := SA1->A1_LOJA
					/*Alterado por Fernando Bombardi - ALLSS - 22/01/2020 - Implementacao cadastro de cliente por Execauto
					RecLock("SA1",.F.)
					*/
					//Incluido por Fernando Bombardi - ALLSS - 22/01/2020 - Implementacao cadastro de cliente por Execauto
					_nOpcAuto := 4
					//Fim FB
				else
					BeginSql Alias "SA1NUM"
						SELECT 
							MAX(A1_COD) A1_COD
						FROM SA1010 SA1 (NOLOCK)
						WHERE SA1.D_E_L_E_T_ = ''
							  AND A1_COD NOT IN ('999999')
						ORDER BY A1_COD
					EndSql

					If SA1NUM->(!EOF())
						_cCodCli := cValToChar(Strzero(Val(SA1NUM->A1_COD)+1,6))
					EndIf
					SA1NUM->(DbCloseArea())
					//_cCodCli := Padr(GETSXENUM("SA1","A1_COD"), TamSx3("A1_COD")[01])
					_cLojCli := Padr("01", TamSx3("A1_LOJA")[01])
					SA1->(ConfirmSx8())
						/* Alterado por Fernando Bombardi - ALLSS - 22/01/202 - Implementacao cadastro de cliente por Execauto
						while !RecLock("SA1",.T.) ; enddo
						SA1->A1_FILIAL	:= xFilial("SA1")
						SA1->A1_COD		:= _cCodCli
						SA1->A1_LOJA	:= _cLojCli
						SA1->A1_CGC		:= M->RA_CIC
						A1_CGCCENT		:= M->RA_CIC
						*/
						//Incluido por Fernando Bombardi - ALLSS - 22/01/2020 - Implementacao cadastro de cliente por Execauto
						_nOpcAuto := 3
						aAdd(_aSA1Auto,{"A1_COD"     ,_cCodCli               ,Nil})
						aAdd(_aSA1Auto,{"A1_LOJA"    ,_cLojCli               ,Nil})
						aAdd(_aSA1Auto,{"A1_CGC"     ,StrTran(StrTran(StrTran(M->RA_CIC,".",""),"-",""),"/",""),Nil})
						aAdd(_aSA1Auto,{"A1_CGCCENT" ,StrTran(StrTran(StrTran(M->RA_CIC,".",""),"-",""),"/",""),Nil})
						//Fim FB
				endif
				/* Alterado por Fernando Bombardi - ALLSS - 22/01/2020 - Implementacao cadastro de cliente por Execauto
				SA1->A1_MSBLQL  := "2"
				SA1->A1_RISCO 	:= SuperGetMV("MV_RISCFUN",,"B")
				*/
				//Incluido por Fernando Bombardi - ALLSS - 22/01/2020 - Implementacao cadastro de cliente por Execauto
				aAdd(_aSA1Auto,{"A1_MSBLQL","2"                           ,Nil})
				aAdd(_aSA1Auto,{"A1_RISCO" ,SuperGetMV("MV_RISCFUN",,"B") ,Nil})
				//Fim FB
				// Alterado por Fernando Bombardi - ALLSS - 22/01/2020 - Alteracao da forma de calculo do limite de credito 
				//SA1->A1_LC	:= (M->RA_SALARIO*SuperGetMV("MV_LIMIFUN",,0.25)) //Limite de crédito default igual a 25% do salário do funcionário
				if SuperGetMV("MV_XMODCAL",,"P") == "P" //Percentual
					aAdd(_aSA1Auto,{"A1_LC" ,(M->RA_SALARIO*SuperGetMV("MV_XVLRMOD",,0.0)) ,Nil})
				else
					aAdd(_aSA1Auto,{"A1_LC" ,SuperGetMV("MV_XVLRMOD",,0.0)                 ,Nil})
				endif
				
	//Incluido por Diego - ALLSS - 06/01/21
				If _nOpcAuto = 4 .AND. !Empty(M->RA_CLIENTE)
					
					RecLock("SA1", .F.)
					SA1->A1_NOME	:= M->RA_NOME
					SA1->A1_NREDUZ	:= IIF(!Empty(M->RA_APELIDO),M->RA_APELIDO,M->RA_NOME)
					SA1->A1_END		:= AllTrim(M->RA_ENDEREC) + ", " + AllTrim(M->RA_NUMENDE)
					SA1->A1_ENDCOB	:= AllTrim(M->RA_ENDEREC) + ", " + AllTrim(M->RA_NUMENDE)
					SA1->A1_BAIRRO	:= M->RA_BAIRRO
					SA1->A1_BAIRROC := M->RA_BAIRRO
					SA1->A1_COMPLEM	:= M->RA_COMPLEM
					SA1->A1_MUN		:= M->RA_MUNICIP
					SA1->A1_MUNC	:= M->RA_MUNICIP
					SA1->A1_EST		:= M->RA_ESTADO 
					SA1->A1_ESTC	:= M->RA_ESTADO
					SA1->A1_DDD		:= IIF(! EMPTY(M->RA_DDDFONE),M->RA_DDDFONE,"011" )
					SA1->A1_TEL		:= IIF(! EMPTY(M->RA_TELEFON),M->RA_TELEFON,"21912444")
					SA1->A1_CEP		:= M->RA_CEP
					SA1->A1_CEPC	:= M->RA_CEP
					SA1->A1_DTNASC  := M->RA_NASC
					SA1->A1_COD_MUN	:= M->RA_CODMUN
					SA1->A1_CODMUN	:= M->RA_CODMUN
					SA1->A1_CDCOB	:= M->RA_CODMUN
				
					MsUnLock()

					MsgInfo("Este funcionário foi alterado automaticamente como cliente no código " + _cCodCli + " - " + _cLojCli,_cRotina+"_002")
				
				Else 
				
				// Fim FB
				/* Alterado por Fernando Bombardi - ALLSS - 22/01/2020 - Implementacao cadastro de cliente por Execauto
				SA1->A1_MOEDALC := VAL(GetMV("MV_MCUSTO"))
				SA1->A1_NOME	:= M->RA_NOME
				SA1->A1_NREDUZ	:= IIF(!Empty(M->RA_APELIDO),M->RA_APELIDO,M->RA_NOME)
				SA1->A1_END		:= AllTrim(M->RA_ENDEREC) + ", " + AllTrim(M->RA_NUMERO)
				SA1->A1_ENDCOB	:= AllTrim(M->RA_ENDEREC) + ", " + AllTrim(M->RA_NUMERO)
				SA1->A1_BAIRRO	:= M->RA_BAIRRO
				SA1->A1_BAIRROC := M->RA_BAIRRO
				SA1->A1_COMPLEM	:= M->RA_COMPLEM
				SA1->A1_MUN		:= M->RA_MUNICIP
				SA1->A1_MUNC	:= M->RA_MUNICIP
				SA1->A1_EST		:= M->RA_ESTADO 
				SA1->A1_ESTC	:= M->RA_ESTADO
				SA1->A1_DDD		:= IIF(! EMPTY(M->RA_DDDFONE),M->RA_DDDFONE,"011" )
				SA1->A1_TEL		:= IIF(! EMPTY(M->RA_TELEFON),M->RA_TELEFON,"21912444")
				SA1->A1_CEP		:= M->RA_CEP
				SA1->A1_CEPC	:= M->RA_CEP
				SA1->A1_DTNASC  := M->RA_NASC
				SA1->A1_COD_MUN	:= M->RA_CODMUN
				SA1->A1_CODMUN	:= M->RA_CODMUN
				SA1->A1_CDCOB	:= M->RA_CODMUN
				//Início - Trecho adicionado por Adriano Leonardo em 02/05/2014 para definir conteúdo default para campos fixos
				SA1->A1_OBSGENR	:= "Este cadastro foi gerado automaticamente com base no cadastro do funcionário " + AllTrim(M->RA_MAT)
				SA1->A1_TIPO	:= SuperGetMV("MV_FUNTPCL",,"F")	  	//Consumidor Final
				SA1->A1_PESSOA	:= SuperGetMV("MV_FUNTPPE",,"F")	  	//Pessoa Física
				SA1->A1_PRIOR	:= SuperGetMV("MV_FUNPRIO",,"9")	  	//Prioridade
				SA1->A1_PAIS	:= SuperGetMV("MV_FUNPAIS",,"105")	  	//Pais
				SA1->A1_CDPAISC := SuperGetMV("MV_FUNPAIS",,"105")    	//Pais de cobrança
				SA1->A1_CODPAIS := SuperGetMV("MV_FUNBACE",,"01058")  	//Pais Bacen
				SA1->A1_INSCR	:= SuperGetMV("MV_FUNINSC",,"ISENTO") 	//Inscrição Estadual
				SA1->A1_CDCART	:= SuperGetMV("MV_FUNCART",,"VALE")  	//Carteira
				SA1->A1_INSTRU1	:= SuperGetMV("MV_FUNINS1",,"01")     	//Instrução 1
				SA1->A1_INSTRU2 := SuperGetMV("MV_FUNINS2",,"00")		//Instrução 2
				SA1->A1_PZPROT	:= SuperGetMV("MV_FUNPROT",,"00") 		//Prazo para protesto
				//SA1->A1_PRZPROT	:= SuperGetMV("MV_FUNPROT",,0) 		//Prazo para protesto
				SA1->A1_DATACAD	:= dDataBase 	//Data do cadastro
				SA1->A1_VEND	:= SuperGetMV("MV_FUNVEND",,"000204") 	//Vendedor (Venda Interna)
				SA1->A1_GRPVEN	:= SuperGetMV("MV_FUNGRUP",,"000204")	//Grupo de venda (Venda Interna)
				SA1->A1_TRANSP	:= SuperGetMV("MV_FUNTRAN",,"000198") 	//Transportadora (Retirar)
				SA1->A1_TPDIV	:= SuperGetMV("MV_FUNDIVI",,"0")		//Tipo de divisão
				SA1->A1_VENDRES	:= SuperGetMV("MV_FUNRESP",,"1") 		//Vendedor responsável - 1=Não;2=Sim
				SA1->A1_EMAIL	:= SuperGetMV("MV_FUNMAIL",,"katia.oliveira@arcolor.com.br")	//E-mail faturamento - Katia
				SA1->A1_EMAIL1	:= SuperGetMV("MV_FUNMAIL",,"katia.oliveira@arcolor.com.br")	//E-mail comercial 	 - Katia  
				SA1->A1_EMAIL2	:= SuperGetMV("MV_FUNMAIL",,"katia.oliveira@arcolor.com.br")	//E-mail financeiro  - Katia  
				SA1->A1_VLDSINT := SuperGetMv("MV_FUNVLDS",,StoD("20491231"))	//Validade do sintegra
				SA1->A1_ATIVO	:= SuperGetMv("MV_FUNATIV",,"ATIVO")			//Situação sintegra			
				_cBanco         := SuperGetMV("MV_FUNBCO",,"FUN/00000/0000000000")
				_aBanco         := Separa(_cBanco,"/")
				if Len(_aBanco)==3
					SA1->A1_BCO1	:= _aBanco[1] //Banco - Especifico
					SA1->A1_AGENCIA	:= _aBanco[2] //Agencia
					SA1->A1_BCCONT	:= _aBanco[3] //Conta
				endif
				SA1->A1_COND	:= SuperGetMV("MV_FUNCOND",,"FOL") 		//Condição de pagamento (Específica para folha de pagamento)
				SA1->A1_PRAZOMD	:= SuperGetMV("MV_FUNPRZM",,0) 			//Prazo médio
				SA1->A1_TABELA	:= SuperGetMV("MV_FUNTABE",,"016")		//Tabela de preço - 008
				SA1->A1_NATUREZ	:= SuperGetMV("MV_FUNNATU",,"101010")		//Natureza - 101010
				SA1->A1_SIMPNAC := "2"
				SA1->A1_CONTRIB := "2"
				SA1->A1_CONTA   := SuperGetMV("MV_FUNCTB",,"110201001")
				//Final  - Trecho adicionado por Adriano Leonardo em 02/05/2014 para definir conteúdo default para campos específicos
				SA1->(MsUnlock())
				if ExistBlock("M030INC")
					ExecBlock("M030Inc",.F.,.F., 0)	//o PARAMIXB será alimentado com 0 (ZERO)
				endif
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				if SA1->(dbSeek(xFilial("SA1") + _cCodCli + _cLojCli))
					M->RA_CLIENTE := _cCodCli
					M->RA_LOJACLI := _cLojCli
					MsgInfo("Este funcionário foi cadastrado automaticamente como cliente com o código " + _cCodCli + " - " + _cLojCli,_cRotina+"_003")
				else
					MsgStop("Falha na criação do funcionário como cliente. Contate o administrador, dizendo que o código gerado é " + _cCodCli + ", loja " + _cLojCli,_cRotina+"_005")
				endif
				*/
				//Incluido por Fernando Bombardi - ALLSS - 22/01/2020 - Implementacao cadastro de cliente por Execauto
				aAdd(_aSA1Auto,{"A1_MOEDALC",VAL(GetMV("MV_MCUSTO"))                                 ,Nil})
				aAdd(_aSA1Auto,{"A1_NOME"   ,Padr(M->RA_NOME,len(SA1->A1_NOME))                      ,Nil})
				aAdd(_aSA1Auto,{"A1_NREDUZ" ,Padr(IIF(!Empty(M->RA_APELIDO),M->RA_APELIDO,M->RA_NOME)  ,len(SA1->A1_NREDUZ)) ,Nil})
				aAdd(_aSA1Auto,{"A1_NOMECGC",Padr(IIF(!Empty(M->RA_APELIDO),M->RA_APELIDO,M->RA_NOME)  ,len(SA1->A1_NREDUZ)) ,Nil})
				aAdd(_aSA1Auto,{"A1_END"    ,Padr(AllTrim(M->RA_ENDEREC) + ", " + AllTrim(M->RA_NUMENDE),len(SA1->A1_END   )) ,Nil})
				aAdd(_aSA1Auto,{"A1_ENDCOB" ,Padr(AllTrim(M->RA_ENDEREC) + ", " + AllTrim(M->RA_NUMENDE),len(SA1->A1_ENDCOB)) ,Nil})
				aAdd(_aSA1Auto,{"A1_BAIRRO" ,Padr(M->RA_BAIRRO ,len(SA1->A1_BAIRRO ))                ,Nil})
				aAdd(_aSA1Auto,{"A1_BAIRROC",Padr(M->RA_BAIRRO ,len(SA1->A1_BAIRROC))                ,Nil})
				aAdd(_aSA1Auto,{"A1_COMPLEM",Padr(M->RA_COMPLEM,len(SA1->A1_COMPLEM))                ,Nil})
				aAdd(_aSA1Auto,{"A1_MUN"    ,Padr(M->RA_MUNICIP,len(SA1->A1_MUN    ))                ,Nil})
				aAdd(_aSA1Auto,{"A1_MUNC"   ,Padr(M->RA_MUNICIP,len(SA1->A1_MUNC   ))                ,Nil})
				aAdd(_aSA1Auto,{"A1_EST"    ,Padr(M->RA_ESTADO ,len(SA1->A1_EST    ))                ,Nil})
				aAdd(_aSA1Auto,{"A1_ESTC"   ,Padr(M->RA_ESTADO ,len(SA1->A1_ESTC   ))                ,Nil})
				aAdd(_aSA1Auto,{"A1_DDD"    ,Padr(StrTran(StrTran(StrTran(IIF(!EMPTY(M->RA_DDDFONE),M->RA_DDDFONE,"011"     ),"-",""),".","")," ",""),len(SA1->A1_DDD))     ,Nil})
				aAdd(_aSA1Auto,{"A1_TEL"    ,Padr(StrTran(StrTran(StrTran(IIF(!EMPTY(M->RA_TELEFON),M->RA_TELEFON,"21912444"),"-",""),".","")," ",""),len(SA1->A1_TEL))     ,Nil})
				aAdd(_aSA1Auto,{"A1_CEP"    ,Padr(StrTran(StrTran(StrTran(M->RA_CEP,"-",""),".","")," ",""),len(SA1->A1_CEP))                        ,Nil})
				aAdd(_aSA1Auto,{"A1_CEPC"   ,Padr(StrTran(StrTran(StrTran(M->RA_CEP,"-",""),".","")," ",""),len(SA1->A1_CEPC))                       ,Nil})
				aAdd(_aSA1Auto,{"A1_DTNASC" ,M->RA_NASC                                              ,Nil})
				aAdd(_aSA1Auto,{"A1_COD_MUN",Padr(M->RA_CODMUN,len(SA1->A1_COD_MUN))                 ,Nil})
//				aAdd(_aSA1Auto,{"A1_CODMUN" ,Padr(M->RA_CODMUN,len(SA1->A1_CODMUN ))                 ,Nil})
//				aAdd(_aSA1Auto,{"A1_CDCOB"  ,Padr(M->RA_CODMUN,len(SA1->A1_CDCOB  ))                 ,Nil})
				aAdd(_aSA1Auto,{"A1_OBSGENR","Este cadastro foi gerado automaticamente com base no cadastro do funcionário " + AllTrim(M->RA_MAT)            ,Nil})
				aAdd(_aSA1Auto,{"A1_TIPO"   ,Padr(SuperGetMV("MV_FUNTPCL",,"F")     ,len(SA1->A1_TIPO   )),Nil}) //Consumidor Final
				aAdd(_aSA1Auto,{"A1_PESSOA" ,Padr(SuperGetMV("MV_FUNTPPE",,"F")     ,len(SA1->A1_PESSOA )),Nil}) //Pessoa Física
				aAdd(_aSA1Auto,{"A1_PRIOR"  ,Padr(SuperGetMV("MV_FUNPRIO",,"9")     ,len(SA1->A1_PRIOR  )),Nil}) //Prioridade
				aAdd(_aSA1Auto,{"A1_PAIS"   ,Padr(SuperGetMV("MV_FUNPAIS",,"105")   ,len(SA1->A1_PAIS   )),Nil}) //Pais
//				aAdd(_aSA1Auto,{"A1_CDPAISC",Padr(SuperGetMV("MV_FUNPAIS",,"105")   ,len(SA1->A1_CDPAISC)),Nil}) //Pais de cobrança
//				aAdd(_aSA1Auto,{"A1_CODPAIS",Padr(SuperGetMV("MV_FUNBACE",,"01058") ,len(SA1->A1_CODPAIS)),Nil}) //Pais Bacen
				aAdd(_aSA1Auto,{"A1_INSCR"  ,Padr(SuperGetMV("MV_FUNINSC",,"ISENTO"),len(SA1->A1_INSCR  )),Nil}) //Inscrição Estadual
				aAdd(_aSA1Auto,{"A1_CDCART" ,Padr(SuperGetMV("MV_FUNCART",,"VALE")  ,len(SA1->A1_CDCART )),Nil}) //Carteira
				aAdd(_aSA1Auto,{"A1_INSTRU1",Padr(SuperGetMV("MV_FUNINS1",,"01")    ,len(SA1->A1_INSTRU1)),Nil}) //Instrução 1
				aAdd(_aSA1Auto,{"A1_INSTRU2",Padr(SuperGetMV("MV_FUNINS2",,"00")    ,len(SA1->A1_INSTRU2)),Nil}) //Instrução 2
				aAdd(_aSA1Auto,{"A1_PZPROT" ,Padr(SuperGetMV("MV_FUNPROT",,"00")    ,len(SA1->A1_PZPROT )),Nil}) //Prazo para protesto
				aAdd(_aSA1Auto,{"A1_DATACAD",dDataBase                                                    ,Nil}) //Data do cadastro
				aAdd(_aSA1Auto,{"A1_VEND"   ,Padr(SuperGetMV("MV_FUNVEND",,"000204"),len(SA1->A1_VEND   )),Nil}) //Vendedor (Venda Interna)
				aAdd(_aSA1Auto,{"A1_GRPVEN" ,Padr(SuperGetMV("MV_FUNGRUP",,"000204"),len(SA1->A1_GRPVEN )),Nil}) //Grupo de venda (Venda Interna)
				aAdd(_aSA1Auto,{"A1_TRANSP" ,Padr(SuperGetMV("MV_FUNTRAN",,"000198"),len(SA1->A1_TRANSP )),Nil}) //Transportadora (Retirar)
				aAdd(_aSA1Auto,{"A1_TPDIV"  ,Padr(SuperGetMV("MV_FUNDIVI",,"0")     ,len(SA1->A1_TPDIV  )),Nil}) //Tipo de divisão
				aAdd(_aSA1Auto,{"A1_VENDRES",Padr(SuperGetMV("MV_FUNRESP",,"1")     ,len(SA1->A1_VENDRES)),Nil}) //Vendedor responsável - 1=Não;2=Sim
				aAdd(_aSA1Auto,{"A1_EMAIL"  ,Padr(SuperGetMV("MV_FUNMAIL",,"katia.oliveira@arcolor.com.br"),len(SA1->A1_EMAIL )),Nil}) //E-mail faturamento - Katia
				aAdd(_aSA1Auto,{"A1_EMAIL1" ,Padr(SuperGetMV("MV_FUNMAIL",,"katia.oliveira@arcolor.com.br"),len(SA1->A1_EMAIL1)),Nil}) //E-mail comercial 	 - Katia
				aAdd(_aSA1Auto,{"A1_EMAIL2" ,Padr(SuperGetMV("MV_FUNMAIL",,"katia.oliveira@arcolor.com.br"),len(SA1->A1_EMAIL2)),Nil}) //E-mail financeiro  - Katia
				aAdd(_aSA1Auto,{"A1_VLDSINT",SuperGetMv("MV_FUNVLDS",,StoD("20491231"))                   ,Nil}) //Validade do sintegra
				aAdd(_aSA1Auto,{"A1_ATIVO"  ,Padr(SuperGetMv("MV_FUNATIV",,"ATIVO"),len(SA1->A1_ATIVO))   ,Nil}) //Situação sintegra	
				_cBanco         := SuperGetMV("MV_FUNBCO",,"FUN/00000/0000000000")
				_aBanco         := Separa(_cBanco,"/")
				if Len(_aBanco) == 3
					/*
					SA1->A1_BCO1	:= _aBanco[1] //Banco - Especifico
					SA1->A1_AGENCIA	:= _aBanco[2] //Agencia
					SA1->A1_BCCONT	:= _aBanco[3] //Conta
					*/
					aAdd(_aSA1Auto,{"A1_BCO1"    ,Padr(_aBanco[1],len(SA1->A1_BCO1   )),Nil}) //Banco - Especifico
					aAdd(_aSA1Auto,{"A1_AGENCIA" ,Padr(_aBanco[2],len(SA1->A1_AGENCIA)),Nil}) //Agencia
					aAdd(_aSA1Auto,{"A1_BCCONT"  ,Padr(_aBanco[3],len(SA1->A1_BCCONT )),Nil}) //Conta
				endif
				aAdd(_aSA1Auto,{"A1_COND"    ,Padr(SuperGetMV("MV_FUNCOND",,"FOL"   ),len(SA1->A1_COND   )),Nil}) //Condição de pagamento (Específica para folha de pagamento)
				aAdd(_aSA1Auto,{"A1_PRAZOMD" ,SuperGetMV("MV_FUNPRZM",,0)                                  ,Nil}) //Prazo médio
				aAdd(_aSA1Auto,{"A1_TABELA"  ,Padr(SuperGetMV("MV_FUNTABE",,"016"   ),len(SA1->A1_TABELA )),Nil}) //Tabela de preço - 008
				aAdd(_aSA1Auto,{"A1_NATUREZ" ,Padr(SuperGetMV("MV_FUNNATU",,"101010"),len(SA1->A1_NATUREZ)),Nil}) //Natureza - 101010
				aAdd(_aSA1Auto,{"A1_SIMPNAC" ,"2"                                                          ,Nil}) 
				aAdd(_aSA1Auto,{"A1_CONTRIB" ,"2"                                                          ,Nil}) 
				aAdd(_aSA1Auto,{"A1_CONTA"   ,Padr(SuperGetMV("MV_FUNCTB",,"110201001"),len(SA1->A1_CONTA)),Nil}) 
				aAdd(_aSA1Auto,{"A1_CENTEC"  ,"2"                                                          ,Nil}) 
				//------------------------------------
				// Chamada para cadastrar o cliente.
				//------------------------------------
				lMsErroAuto := .F.
				//MSExecAuto({|a,b,c| CRMA980(a,b,c)}, _aSA1Auto, _nOpcAuto, _aAI0Auto)
				MSExecAuto({|a,b| MATA030(a,b)}, _aSA1Auto, _nOpcAuto)
				if lMsErroAuto  
					MostraErro()
					MsgStop("Falha na criação do funcionário como cliente. Contate o administrador, dizendo que o código gerado é " + _cCodCli + ", loja " + _cLojCli,_cRotina+"_005")
				else
					SA1->(dbSetOrder(1))
					if SA1->(dbSeek(xFilial("SA1") + _cCodCli + _cLojCli))
						while !RecLock("SA1",.F.) ; enddo
							if !empty(M->RA_CODMUN)
								SA1->A1_COD_MUN := Padr(M->RA_CODMUN,len(SA1->A1_COD_MUN))
								SA1->A1_CODMUN  := Padr(M->RA_CODMUN,len(SA1->A1_CODMUN ))
								SA1->A1_CDCOB   := Padr(M->RA_CODMUN,len(SA1->A1_CDCOB  ))
							endif
							SA1->A1_PAIS    := Padr(SuperGetMV("MV_FUNPAIS",,"105")   ,len(SA1->A1_PAIS   ))
							SA1->A1_CDPAISC := Padr(SuperGetMV("MV_FUNPAIS",,"105")   ,len(SA1->A1_CDPAISC))
							SA1->A1_CODPAIS := Padr(SuperGetMV("MV_FUNBACE",,"01058") ,len(SA1->A1_CODPAIS))
						SA1->(MSUNLOCK())
						M->RA_CLIENTE := _cCodCli
						M->RA_LOJACLI := _cLojCli
						if M->RA_MAT == SRA->RA_MAT
							if RecLock("SRA")
								SRA->RA_CLIENTE := _cCodCli
								SRA->RA_LOJACLI := _cLojCli
							else
								while !RecLock("SRA",.F.) ; enddo
									SRA->RA_CLIENTE := _cCodCli
									SRA->RA_LOJACLI := _cLojCli
								SRA->(MSUNLOCK())
							endif
						endif
						MsgInfo("Este funcionário foi cadastrado automaticamente como cliente com o código " + _cCodCli + " - " + _cLojCli,_cRotina+"_003")
					endif
				endif
				//Fim FB
				Endif
				//Fim Diego
			endif
		endif
	elseif AllTrim(M->RA_SITFOLH)=="D" /*.And. !Empty(M->RA_CLIENTE)*/ //Avalio se o funcionário está sendo desligado da empresa e bloqueio o cadastro do cliente vinculado a ele
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if SA1->(dbSeek(xFilial("SA1")+Padr(M->RA_CLIENTE,TamSx3("A1_COD")[01])+Padr(M->RA_LOJACLI,TamSx3("A1_LOJA")[01])))
			/*
			dbSelectArea("SA1")
			SA1->(dbOrderNickName("A1_CGC"))		//SA1->(dbSetOrder(3))
			if SA1->(dbSeek(xFilial("SA1")+Padr(M->RA_CIC,TamSx3("A1_CGC")[01])))
			*/
			M->RA_CLIENTE := SA1->A1_COD
			M->RA_LOJACLI := SA1->A1_LOJA
			if AllTrim(SA1->A1_MSBLQL) <> "1"
				while !RecLock("SA1",.F.) ; enddo
					SA1->A1_MSBLQL  := "1" //Bloqueado
					SA1->A1_OBSGENR := AllTrim(SA1->A1_OBSGENR) + IIF(!Empty(AllTrim(SA1->A1_OBSGENR))," - ","") + "Cliente bloqueado em " + DTOS(dDataBase) + " - Funcionário desligado."
				SA1->(MsUnLock())
				MsgInfo("O cliente: " + AllTrim(SA1->A1_COD) + "-" + AllTrim(SA1->A1_LOJA) + " vinculado a este funcionário foi automaticamente bloqueado para uso!",_cRotina+"_004")
			endif
		endif
	endif
	RestArea(_aSavSRA)
	RestArea(_aSavSA1)
	RestArea(_aSavArea)
return _lRet
