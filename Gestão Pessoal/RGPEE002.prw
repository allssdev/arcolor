#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RGPEE002 º Autor ³ Adriano Leonardo  º Data ³ 10/04/2014   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina desenvolvida com o objetivo de gerar o cadastro de  º±±
±±º          ³ cliente para todos os funcionários ativos que não estejam  º±±
±±º          ³ vinculados a nenhum código de cliente.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a Arcolor.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RGPEE002()

Local _aSavArea 	:= GetArea()
Local _aSavSRA		:= SRA->(GetArea())
Local _aSavSA1		:= SA1->(GetArea())
Local _lRet			:= .T.

Private _cRotina 	:= "RGPEE002"

//Verifico a existência dos campos necessários para execução da rotina
dbSelectArea("SRA")
If SRA->(FieldPos("RA_CLIENTE"))==0 .Or. SRA->(FieldPos("RA_LOJACLI"))==0
	MsgStop("Falha na criação dos campos RA_CLIENTE e RA_LOJACLI, favor informar ao Administrador do sistema!",_cRotina+"_001")
	Return(_lRet)
EndIf
If MsgYesNo("Esta rotina irá replicar o cadastro dos funcionários ativos como clientes, sendo que os funcionários que já estão vinculados a algum cliente serão ignorados, deseja continuar?",_cRotina+"_002")
	If __cUserId == "000000"
		Processa({||Executa()},"Aguarde...")
	Else
		Alert("Somente o Administrador tem permissão para executar essa rotina!", _cRotina+"_003")
	EndIf
EndIf

//Restauro a área de trabalho original
RestArea(_aSavSRA)
RestArea(_aSavSA1)
RestArea(_aSavArea)

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RGPEE002 º Autor ³ Adriano Leonardo  º Data ³ 10/04/2014   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para replicar o cadastro de funcionário como clienteº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a Arcolor.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Executa()

Local _cRISCOFUN := SuperGetMV("MV_RISCOFUN",,"B")
Local _nLIMITFUN := SuperGetMV("MV_LIMITFUN",,0.25)
Local _cFUNTPCL := SuperGetMV("MV_FUNTPCL",,"F")
Local _cFUNTPPE := SuperGetMV("MV_FUNTPPE",,"F")
Local _cFUNPRIO := SuperGetMV("MV_FUNPRIO",,"9")
Local _cFUNPAIS := SuperGetMV("MV_FUNPAIS",,"105")
Local _cFUNBACE := SuperGetMV("MV_FUNBACE",,"01058")
Local _cFUNINSC := SuperGetMV("MV_FUNINSC",,"ISENTO")
Local _cFUNCART := SuperGetMV("MV_FUNCART",,"FOLHA")
Local _cFUNINS1 := SuperGetMV("MV_FUNINS1",,"01")
Local _cFUNINS2 := SuperGetMV("MV_FUNINS2",,"00")
Local _cFUNPROT := SuperGetMV("MV_FUNPROT",,0)
Local _cFUNVEND := SuperGetMV("MV_FUNVEND",,"000204")
Local _cFUNGRUP := SuperGetMV("MV_FUNGRUP",,"000204")
Local _cFUNTRAN := SuperGetMV("MV_FUNTRAN",,"000198")
Local _cFUNDIVI := SuperGetMV("MV_FUNDIVI",,"0")
Local _cFUNRESP := SuperGetMV("MV_FUNRESP",,"1")
Local _cFUNMAIL := SuperGetMV("MV_FUNMAIL",,"damaris.carvalho@arcolor.com.br")
Local _cFUNVLDS := SuperGetMv("MV_FUNVLDS",,StoD("20491231"))
Local _cFUNATIV := SuperGetMv("MV_FUNATIV",,"ATIVO")
Local _cFUNBCO  := SuperGetMV("MV_FUNBCO",,"FUN/00000/0000000000")
Local _cFUNCOND := SuperGetMV("MV_FUNCOND",,"FOL")
Local _nFUNPRZM := SuperGetMV("MV_FUNPRZM",,0)
Local _cFUNTABE := SuperGetMV("MV_FUNTABE",,"008")
Local _cFUNNATU := SuperGetMV("MV_FUNNATU",,"101010")


dbSelectArea("SRA") //Cadastro de funcionário
SRA->(dbSetOrder(1))		//Filial + Matrícula
SRA->(dbGoTop())
ProcRegua(RecCount()) //Define régua de processamento
While SRA->(!EOF())
	IncProc() //Incrementa régua de processamento
	//Filtra funcionários demitidos
	If !Empty(SRA->RA_DEMISSA)
		dbSelectArea("SRA")
		SRA->(dbSetOrder(1))
		SRA->(dbSkip())
		Loop
	EndIf
	If Empty(SRA->RA_CLIENTE)
		_cCodCli := GETSXENUM("SA1","A1_COD")
		_cLojCli := "01" //No caso de funcionário será sempre loja 01
		RecLock("SA1",.T.)
			SA1->A1_FILIAL	:= xFilial("SA1")
			SA1->A1_COD		:= _cCodCli
			SA1->A1_LOJA	:= _cLojCli
			SA1->A1_CGC		:= SRA->RA_CIC
			SA1->A1_RISCO 	:= _cRISCOFUN
			SA1->A1_LC		:= (SRA->RA_SALARIO * _nLIMITFUN ) //Limite de crédito default igual a 25% do salário do funcionário
			SA1->A1_NOME	:= SRA->RA_NOME
			SA1->A1_NREDUZ	:= IIF(!Empty(SRA->RA_APELIDO),SRA->RA_APELIDO,SRA->RA_NOME)
			SA1->A1_END		:= AllTrim(SRA->RA_ENDEREC) + ", " + AllTrim(SRA->RA_NUMERO)
			SA1->A1_ENDCOB	:= AllTrim(SRA->RA_ENDEREC) + ", " + AllTrim(SRA->RA_NUMERO)
			SA1->A1_BAIRRO	:= SRA->RA_BAIRRO
			SA1->A1_BAIRROC := SRA->RA_BAIRRO
			SA1->A1_COMPLEM	:= SRA->RA_COMPLEM
			SA1->A1_MUN		:= SRA->RA_MUNICIP
			SA1->A1_MUNC	:= SRA->RA_MUNICIP
			SA1->A1_EST		:= SRA->RA_ESTADO 
			SA1->A1_ESTC	:= SRA->RA_ESTADO 
			SA1->A1_DDD		:= SRA->RA_DDDFONE
			SA1->A1_TEL		:= SRA->RA_TELEFON
			SA1->A1_CEP		:= SRA->RA_CEP
			SA1->A1_CEPC	:= SRA->RA_CEP
			SA1->A1_DTNASC  := SRA->RA_NASC
			SA1->A1_COD_MUN	:= SRA->RA_CODMUN
			SA1->A1_CODMUN	:= SRA->RA_CODMUN
			SA1->A1_CDCOB	:= SRA->RA_CODMUN
			//Início - Trecho adicionado por Adriano Leonardo em 02/05/2014 para definir conteúdo default para campos fixos
			SA1->A1_OBSGENR	:= "Este cadastro foi gerado automaticamente com base no cadastro do funcionário " + AllTrim(SRA->RA_MAT)
			SA1->A1_TIPO	:= _cFUNTPCL	  	//Consumidor Final
			SA1->A1_PESSOA	:= _cFUNTPPE	  	//Pessoa Física
			SA1->A1_PRIOR	:= _cFUNPRIO	  	//Prioridade
			SA1->A1_PAIS	:= _cFUNPAIS	  	//Pais
			SA1->A1_CDPAISC := _cFUNPAIS    	//Pais de cobrança
			SA1->A1_CODPAIS := _cFUNBACE  		//Pais Bacen
			SA1->A1_INSCR	:= _cFUNINSC	 	//Inscrição Estadual
			SA1->A1_CDCART	:= _cFUNCART	  	//Carteira
			SA1->A1_INSTRU1	:= _cFUNINS1     	//Instrução 1
			SA1->A1_INSTRU2 := _cFUNINS2		//Instrução 2
			//SA1->A1_PZPROT	:= SuperGetMV("MV_FUNPROT",,"00") 		//Prazo para protesto
			SA1->A1_PRZPROT	:= _cFUNPROT 		//Prazo para protesto
			SA1->A1_DATACAD	:= dDataBase 	//Data do cadastro
			SA1->A1_VEND	:= _cFUNVEND 	//Vendedor (Venda Interna)
			SA1->A1_GRPVEN	:= _cFUNGRUP	//Grupo de venda (Venda Interna)
			SA1->A1_TRANSP	:= _cFUNTRAN 	//Transportadora (Retirar)
			SA1->A1_TPDIV	:= _cFUNDIVI	//Tipo de divisão
			SA1->A1_VENDRES	:= _cFUNRESP	//Vendedor responsável - 1=Não;2=Sim
			SA1->A1_EMAIL	:= _cFUNMAIL	//E-mail faturamento - Damares
			SA1->A1_EMAIL1	:= _cFUNMAIL	//E-mail comercial 	 - Damares
			SA1->A1_EMAIL2	:= _cFUNMAIL	//E-mail financeiro  - Damares
			SA1->A1_VLDSINT := _cFUNVLDS	//Validade do sintegra
			SA1->A1_ATIVO	:= _cFUNATIV	//Situação sintegra
			_cBanco := _cFUNBCO
			_aBanco := Separa(_cBanco,"/")
			If Len(_aBanco)==3
				SA1->A1_BCO1	:= _aBanco[1] //Banco - Especifico
				SA1->A1_AGENCIA	:= _aBanco[2] //Agencia
				SA1->A1_BCCONT	:= _aBanco[3] //Conta
			EndIf
			
			SA1->A1_COND	:= _cFUNCOND	//Condição de pagamento (Específica para folha de pagamento)
			SA1->A1_PRAZOMD	:= _nFUNPRZM 	//Prazo médio
			SA1->A1_TABELA	:= _cFUNTABE	//Tabela de preço - 008
			SA1->A1_NATUREZ	:= _cFUNNATU	//Natureza - 101010
			//Final  - Trecho adicionado por Adriano Leonardo em 02/05/2014 para definir conteúdo default para campos específicos
		SA1->(MsUnlock())
		If ExistBlock("M030INC")
			ExecBlock("M030Inc",.F.,.F., 0)	//o PARAMIXB será alimentado com 0 (ZERO)
		EndIf			
		dbSelectArea("SRA")
		//Gravo o código do cliente no cadastro do funcionário
		RecLock("SRA",.F.)                                                        			
			SRA->RA_CLIENTE := _cCodCli
			SRA->RA_LOJACLI := _cLojCli
		SRA->(MsUnlock())
		ConfirmSx8()
	EndIf
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	SRA->(dbSkip())
EndDo

Return()