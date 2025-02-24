#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "MATA455.CH"

#DEFINE _CRLF   CHR(13)+CHR(10)
/*#DEFINE STR0001 "Liberacao de Estoque"
#DEFINE STR0002 "Pesquisar"
#DEFINE STR0003 "Ordem"
#DEFINE STR0004 "Automatica"
#DEFINE STR0005 "Manual"
#DEFINE STR0006 "  Este programa  tem  como  objetivo  liberar  automaticamente os pedidos de  "
#DEFINE STR0007 "  venda com bloqueio de estoque                                               "
#DEFINE STR0008 "Liberacao de Estoque"
#DEFINE STR0009 "Pedido"
#DEFINE STR0010 "Cond.Pagto."
#DEFINE STR0011 "Bloqueio"
#DEFINE STR0012 "Cliente"
#DEFINE STR0013 "Risco"
#DEFINE STR0014 "Produto"
#DEFINE STR0015 "Saldo"
#DEFINE STR0016 "Armazem"
#DEFINE STR0017 "Numero Lote"
#DEFINE STR0018 "Endereco"
#DEFINE STR0019 "Qtd.Total Pedido"
#DEFINE STR0020 "Data Ult.Saída"
#DEFINE STR0021 "Qtd.Total 2a.UM"
#DEFINE STR0022 "Qtd.neste item"
#DEFINE STR0023 "Legenda"
#DEFINE STR0024 "Estoque"
#DEFINE STR0025 "Nova Liberacao"
#DEFINE STR0026 "Libera avaliando credito e estoque"
#DEFINE STR0027 "Libera somente avaliando estoque"
#DEFINE STR0028 "Libera sempre"
#DEFINE STR0029 "Aviso"
#DEFINE STR0030 "Alteracao nao permitida pois a liberacao possui reserva."
#DEFINE STR0031 "Ok"
#DEFINE STR0032 "Liberacao manual nao permitida pois o produto possui rastreabilidade ou localizacao fisica"
#DEFINE STR0033 "Lote e Enderecos"
#DEFINE STR0034 "Selecione os Lote e Endereçamento"
#DEFINE STR0035 "Escolha de Lotes"
#DEFINE STR0036 "Qtd.Selecionada"
#DEFINE STR0037 "Qtd.Selecionada"
#DEFINE STR0038 "Data de validade do lote vencida!"
#DEFINE STR0039 "Selecione o Lote!"
#DEFINE STR0040 "Selecione os Enderecos!"
#DEFINE STR0041 "Quantidade selecionada menor que a liberada!"
#DEFINE STR0042 "Nao e possivel escolher mas de um Lote!"
#DEFINE STR0043 "Quantidade do Lote selecionado menor que a liberada!"
#DEFINE STR0044 "Quantidade ja antendida na selecao anterior!"
#DEFINE STR0045 "Endereco nao corresponde ao Lote selecionado!"
#DEFINE STR0046 "Lotes e Enderecos"
#DEFINE STR0047 "Selecione Lotes e Enderecamento"
#DEFINE STR0048 "Este item possui reserva especifica de um lote."
*/
/*/{Protheus.doc} RFATA026
@description MBrowse para administração dos pedidos liberados, sem bloqueio de crédito, não faturados e sem Ordem de Separação Rotina conhecida como "Acompanhamento de Pedido" 
@author Anderson C. P. Coelho (ALL System Solutions)
@since 23/03/2013
@version 1.0
@history 11/01/2015, Anderson C. P. Coelho, Diversas adequações processadas.
@history 06/03/2014, Júlio Soares, Alterada a Query para contemplar a observação de separação do pedido na ordem de separação.
@history 27/12/2018, Júlio Soares / Adriano Leonardo / Anderson Coelho / Arthur Silva / Lívia Della Corte, Diversos ajustes processados e documentados no SVN de 07/03/2014 em diante.
@history 11/07/2019, Anderson Coelho, Correções aplicadas para adequação a migraçao de release. Além disso, alguns trechos não utilizados foram descontinuados. 
@type function
@see https://allss.com.br
/*/
user function RFATA026()
	private _oBrw26
//	private oCombo1
	private cCadastro := "Acompanhamento de Pedidos"
	private _cRotina  := "RFATA026"
	private _cAliTmp  := "SC9TMP"+GetNextAlias()			//"SC9TMP" + replace( time() ,":","")
	private _cTbTmp1  := "TRBTMP"+GetNextAlias()						//"TRBTMP" + replace( time() ,":","")
//	private cPerg	  := _cRotina
	private _cFNBkp   := FunName()
	private _cUsrExp  := SuperGetMv("MV_USEXPPV",,"/000000/000019/000154/000155/000156/000177/900000/900001/900002/000009/000031/000085/")	//16/09/2016 - ID dos usuários que poderão administrar os pedidos no âmbito da expedição (análise de estoque e geração da Ordem de Separação)
	private _cUsrFin  := SuperGetMv("MV_USFINPV",,"/000000/000019/000154/000155/000156/000177/900000/900001/900002/000016/000020/")			//16/09/2016 - ID dos usuários que poderão administrar os pedidos no âmbito financeiro (análise de crédito)
	private _cUsrAdm  := SuperGetMv("MV_USADMPV",,"/000000/900000/900001/900002/000019/")			//16/09/2016 - ID dos usuários que poderão administrar os pedidos no âmbito financeiro (análise de crédito)
//	private _cArq     := ""
//	private _cInd1    := ""
//	private _cInd2    := ""
//	private _cInd3    := ""
//	private _cInd4    := ""
//	private _cInd5    := ""
//	private _cQry	  := ""
	private _cPedC9   := ""
	private _lArq     := .F.
//	private _lTotPv   := .F.
	private INCLUI    := .F.
	private ALTERA    := .F.
	private _lMultFs  := .F.		//Habilita múltiplas teclas Fs (sobrepõe telas)?
	private _lEF02    := .F.
	private _lEF04    := .F.
	private _lEF05    := .F.
	private _lEF06    := .F.
	private _lEF07    := .F.
	private _lEF08    := .F.
	private _lEF09    := .F.
	private _lEF10    := .F.
	private _lEF11    := .F.
	private _lECF9    := .F.
	private _aKey     := {}
	private _aKeyF2   := {}
	private _aKeyF4   := {}
	private _aKeyF5   := {}
	private _aKeyF6   := {}
	private _aKeyF7   := {}
	private _aKeyF8   := {}
	private _aKeyF9   := {}
	private _aKeyF10  := {}
	private _aKeyF11  := {}
	private _aKeyF12  := {}
//	private _aKeyLB   := {}
	private _aStru    := {}
	private aColunas  := {}
	private aRotina   := {}
	private _aTabs    := {"TRBTMP","SC9","SC5","SA1","SA2","SE4"}
	private _aSeek    := {	{ 'Pedido+Emissão+Liberação+Prior+Cliente+Loja'      , {}, 1, .T. },;
							{ 'Prior+Pedido+Emissão+Liberação+Cliente+Loja'      , {}, 2, .T. },;
							{ 'Nome+Pedido+Emissão+Liberação+Prior'              , {}, 3, .T. },;
							{ 'Ordem de Separação+Prior+Pedido+Emissão+Liberação', {}, 4, .T. },; 
							{ 'Cliente+Loja'                                     , {}, 5, .T. },;
							{ 'Liberação+Pedido'                           		 , {}, 6, .T. }}
	//Configuracoes da pergunte AIA106 (Pedidos de Venda), ativado pela tecla F12: (Variáveis Fonte Padrão ACDA100 Para Geração O.S)
	private nConfLote
	private nEmbSimul
	private nEmbalagem
	private nGeraNota
	private nImpNota
	private nImpEtVol
	private nEmbarque
	private nAglutPed
	private nAglutArm
	//Configuracoes da pergunte AIA107 (Notas Fiscais), ativado pela tecla F12: (Variáveis Fonte Padrão ACDA100 Para Geração O.S)
	private nEmbSimuNF
	private nEmbalagNF
	private nImpNotaNF
	private nImpVolNF
	private nEmbarqNF
	//Configuracoes da pergunte AIA108 (Ordens de Producao), ativado pela tecla F12: (Variáveis Fonte Padrão ACDA100 Para Geração O.S)
	private nReqMatOP
	private nAglutArmOP
	private nPreSep
	private _bPAR        := "type('MV_PAR'+StrZero(_nSqPerg,2))"
	/*
	Estrutura do array
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)

	TABELA TEMPORÁRIA
	[n][01] Descrição do campo
	[n][02] Nome do campo
	[n][03] Tipo
	[n][04] Tamanho
	[n][05] Decimal
	[n][06] Picture
	*/
	//                            Título              Campo        Tipo                     Tamanho                  Decimais                 Picture
	if __cUserId $ _cUsrFin
		//_lTotPv ==> ATIVA/DESATIVA o cálculo do valor total do pedido para apresentação no Browse - 17/10/2016 - EM DESENVOLVIMENTO
		//_lTotPv              := .F.//MsgYesNo("Apresenta Valor Total dos pedidos (ou somente o valor das mercadorias)?",_cRotina+"_016")
			private	aColunas := {	{ "Tab."             ,"C5_TABELA" ,TamSX3("C5_TABELA" )[03],TamSX3("C5_TABELA" )[01],TamSX3("C5_TABELA" )[02],""     },;
									{ "Pedido"           ,"C9_PEDIDO" ,TamSX3("C9_PEDIDO" )[03],TamSX3("C9_PEDIDO" )[01],TamSX3("C9_PEDIDO" )[02],""     },;
									{ "Cliente"          ,"C9_CLIENTE",TamSX3("C9_CLIENTE")[03],TamSX3("C9_CLIENTE")[01],TamSX3("C9_CLIENTE")[02],""     },;
									{ "Loja"             ,"C9_LOJA"   ,TamSX3("C9_LOJA"   )[03],TamSX3("C9_LOJA"   )[01],TamSX3("C9_LOJA"   )[02],""     },;
									{ "Nome"             ,"A1_NOME"   ,TamSX3("A1_NOME"   )[03],TamSX3("A1_NOME"   )[01],TamSX3("A1_NOME"   )[02],""     },;
									{ "Num Cd.Pg."       ,"C5_CONDPAG",TamSX3("C5_CONDPAG")[03],TamSX3("C5_CONDPAG")[01],TamSX3("C5_CONDPAG")[02],""     },;
									{ "Carteira"         ,"A1_CDCART" ,TamSX3("A1_CDCART" )[03],TamSX3("A1_CDCART" )[01],TamSX3("A1_CDCART" )[02],""     },;
									{ "Tp Op."           ,"C5_TPOPER" ,TamSX3("C5_TPOPER" )[03],TamSX3("C5_TPOPER" )[01],TamSX3("C5_TPOPER" )[02],""     },;
									{ "Valor"            ,"C9_PRCVEN" ,TamSX3("C9_PRCVEN" )[03],TamSX3("C9_PRCVEN" )[01],TamSX3("C9_PRCVEN" )[02],""     },;
									{ "Banco"            ,"A1_BCO1"   ,TamSX3("A1_BCO1"   )[03],TamSX3("A1_BCO1"   )[01],TamSX3("A1_BCO1"   )[02],""     },;
									{ "Instr.1"          ,"A1_INSTRU1",TamSX3("A1_INSTRU1")[03],TamSX3("A1_INSTRU1")[01],TamSX3("A1_INSTRU1")[02],""     },;
									{ "Instr.2"          ,"A1_INSTRU2",TamSX3("A1_INSTRU2")[03],TamSX3("A1_INSTRU2")[01],TamSX3("A1_INSTRU2")[02],""     },;
									{ "D.P/Prot."        ,"A1_PRZPROT",TamSX3("A1_PRZPROT")[03],TamSX3("A1_PRZPROT")[01],TamSX3("A1_PRZPROT")[02],""     },;
									{ "Obs Sep."         ,"C9_OBSSEP" ,TamSX3("C9_OBSSEP" )[03],TamSX3("C9_OBSSEP" )[01],TamSX3("C9_OBSSEP" )[02],""     },;
									{ "Prior"            ,"C5_NPRIORI",TamSX3("C5_NPRIORI")[03],TamSX3("C5_NPRIORI")[01],TamSX3("C5_NPRIORI")[02],""     },;
									{ "Industrial"       ,"C5_XLININD",TamSX3("C5_XLININD")[03],TamSX3("C5_XLININD")[01],TamSX3("C5_XLININD")[02],""     },;// Campo incluído por Diego Rodrigues em 28/08/2024 para visualização da linha industrial. */
									{ "Emissão"          ,"C5_EMISSAO",TamSX3("C5_EMISSAO")[03],TamSX3("C5_EMISSAO")[01],TamSX3("C5_EMISSAO")[02],""     },;
									{ "Peso Aproximado"  ,"B1_PESO"   ,TamSX3("B1_PESO"   )[03],TamSX3("B1_PESO"   )[01],TamSX3("B1_PESO"   )[02],""     },;	 // C9_PESOL campo de tela não existente na SC9
									{ "Transportadora"   ,"C5_DTRANSP",TamSX3("C5_DTRANSP")[03],TamSX3("C5_DTRANSP")[01],TamSX3("C5_DTRANSP")[02],""     },;	 
									{ "Dt. Lib. Crédito" ,"C5_DTLIBCR",TamSX3("C5_DTLIBCR")[03],TamSX3("C5_DTLIBCR")[01],TamSX3("C5_DTLIBCR")[02],""     },;	// Alterado Por Arthur em 03/08/2016 { "Liberação"        ,"C9_DATALIB",TamSX3("C9_DTLIBCR")[03],TamSX3("C9_DTLIBCR")[01],TamSX3("C9_DTLIBCR")[02],""     },;
									{ "Cond.Pg."         ,"E4_DESCRI" ,TamSX3("E4_DESCRI" )[03],TamSX3("E4_DESCRI" )[01],TamSX3("E4_DESCRI" )[02],""     },;
									{ "Agencia"     	 ,"A1_AGENCIA",TamSX3("A1_AGENCIA")[03],TamSX3("A1_AGENCIA")[01],TamSX3("A1_AGENCIA")[02],""     },;
									{ "Conta"            ,"A1_BCCONT" ,TamSX3("A1_BCCONT" )[03],TamSX3("A1_BCCONT" )[01],TamSX3("A1_BCCONT" )[02],""     },;
									{ "Respons.Repr."    ,"C5_VENDRES",TamSX3("C5_VENDRES")[03],TamSX3("C5_VENDRES")[01],TamSX3("C5_VENDRES")[02],""     },;
									{ "Ord.Sep."         ,"C9_ORDSEP" ,TamSX3("C9_ORDSEP" )[03],TamSX3("C9_ORDSEP" )[01],TamSX3("C9_ORDSEP" )[02],""     },;
									{ "Clf."             ,"C5_TPDIV"  ,TamSX3("C5_TPDIV"  )[03],TamSX3("C5_TPDIV"  )[01],TamSX3("C5_TPDIV"  )[02],""     },;
									{ "UF"			     ,"A1_EST"	  ,TamSX3("A1_EST" 	  )[03],TamSX3("A1_EST"    )[01],TamSX3("A1_EST" 	)[02],""     }} 
	elseIf __cUserId$_cUsrExp
		/* // Novo Ajuste em 08/05/2018 Por Arthur Silva - Conforme solicitação do Sr. Cláudio.
		aColunas := {   { "Prior"            ,"C5_NPRIORI",TamSX3("C5_NPRIORI")[03],TamSX3("C5_NPRIORI")[01],TamSX3("C5_NPRIORI")[02],""     },;
						{ "Pedido"           ,"C9_PEDIDO" ,TamSX3("C9_PEDIDO" )[03],TamSX3("C9_PEDIDO" )[01],TamSX3("C9_PEDIDO" )[02],""     },;
						{ "Cliente"          ,"C9_CLIENTE",TamSX3("C9_CLIENTE")[03],TamSX3("C9_CLIENTE")[01],TamSX3("C9_CLIENTE")[02],""     },;
						{ "Loja"             ,"C9_LOJA"   ,TamSX3("C9_LOJA"   )[03],TamSX3("C9_LOJA"   )[01],TamSX3("C9_LOJA"   )[02],""     },;
						{ "Nome"             ,"A1_NOME"   ,TamSX3("A1_NOME"   )[03],TamSX3("A1_NOME"   )[01],TamSX3("A1_NOME"   )[02],""     },;
						{ "Emissão"          ,"C5_EMISSAO",TamSX3("C5_EMISSAO")[03],TamSX3("C5_EMISSAO")[01],TamSX3("C5_EMISSAO")[02],""     },;
						{ "Liberação"        ,"C9_DTLIBCR",TamSX3("C9_DTLIBCR")[03],TamSX3("C9_DTLIBCR")[01],TamSX3("C9_DTLIBCR")[02],""     },;	// Alterado Por Arthur em 03/08/2016 { "Liberação"        ,"C9_DATALIB",TamSX3("C9_DTLIBCR")[03],TamSX3("C9_DTLIBCR")[01],TamSX3("C9_DTLIBCR")[02],""     },;
						{ "Ord.Sep."         ,"C9_ORDSEP" ,TamSX3("C9_ORDSEP" )[03],TamSX3("C9_ORDSEP" )[01],TamSX3("C9_ORDSEP" )[02],""     },;
						{ "Obs Sep."         ,"C9_OBSSEP" ,TamSX3("C9_OBSSEP" )[03],TamSX3("C9_OBSSEP" )[01],TamSX3("C9_OBSSEP" )[02],""     },;
						{ "Cond.Pg."         ,"E4_DESCRI" ,TamSX3("E4_DESCRI" )[03],TamSX3("E4_DESCRI" )[01],TamSX3("E4_DESCRI" )[02],""     },;
						{ "UF"			     ,"A1_EST"	  ,TamSX3("A1_EST" 	  )[03],TamSX3("A1_EST"    )[01],TamSX3("A1_EST" 	)[02],""     }}   // Campo incluído por Arthur Silva em 25/07/16 conforme solicitação do Sr. Cláudio. */ 
			private	aColunas := {   { "Prior"            ,"C5_NPRIORI",TamSX3("C5_NPRIORI")[03],TamSX3("C5_NPRIORI")[01],TamSX3("C5_NPRIORI")[02],""     },;
									{ "Industrial"       ,"C5_XLININD",TamSX3("C5_XLININD")[03],TamSX3("C5_XLININD")[01],TamSX3("C5_XLININD")[02],""     },;// Campo incluído por Diego Rodrigues em 28/08/2024 para visualização da linha industrial. */
									{ "Pedido"           ,"C9_PEDIDO" ,TamSX3("C9_PEDIDO" )[03],TamSX3("C9_PEDIDO" )[01],TamSX3("C9_PEDIDO" )[02],""     },;
									{ "Nome"             ,"A1_NOME"   ,TamSX3("A1_NOME"   )[03],TamSX3("A1_NOME"   )[01],TamSX3("A1_NOME"   )[02],""     },;
									{ "Emissão"          ,"C5_EMISSAO",TamSX3("C5_EMISSAO")[03],TamSX3("C5_EMISSAO")[01],TamSX3("C5_EMISSAO")[02],""     },;
									{ "Dt. Lib. Crédito" ,"C5_DTLIBCR",TamSX3("C5_DTLIBCR")[03],TamSX3("C5_DTLIBCR")[01],TamSX3("C5_DTLIBCR")[02],""     },;	// Alterado Por Arthur em 03/08/2016 { "Liberação"        ,"C9_DATALIB",TamSX3("C9_DTLIBCR")[03],TamSX3("C9_DTLIBCR")[01],TamSX3("C9_DTLIBCR")[02],""     },;
									{ "UF"			     ,"A1_EST"	  ,TamSX3("A1_EST" 	  )[03],TamSX3("A1_EST"    )[01],TamSX3("A1_EST" 	)[02],""     },;  // Campo incluído por Arthur Silva em 25/07/16 conforme solicitação do Sr. Cláudio.
									{ "Obs Sep."         ,"C9_OBSSEP" ,TamSX3("C9_OBSSEP" )[03],TamSX3("C9_OBSSEP" )[01],TamSX3("C9_OBSSEP" )[02],""     },;
									{ "Cond.Pg."         ,"E4_DESCRI" ,TamSX3("E4_DESCRI" )[03],TamSX3("E4_DESCRI" )[01],TamSX3("E4_DESCRI" )[02],""     },;
									{ "Peso Aproximado"  ,"B1_PESO"   ,TamSX3("B1_PESO")[03]   ,TamSX3("B1_PESO")[01]   ,TamSX3("B1_PESO")[02]   ,""     },;	 // C9_PESOL campo de tela não existente na SC9
									{ "Transportadora"   ,"C5_DTRANSP",TamSX3("C5_DTRANSP")[03],TamSX3("C5_DTRANSP")[01],TamSX3("C5_DTRANSP")[02],""     } }
	ElseIf __cUserId$_cUsrAdm
			private	aColunas := {	{ "Prior"            ,"C5_NPRIORI",TamSX3("C5_NPRIORI")[03],TamSX3("C5_NPRIORI")[01],TamSX3("C5_NPRIORI")[02],""     },;
									{ "Industrial"       ,"C5_XLININD",TamSX3("C5_XLININD")[03],TamSX3("C5_XLININD")[01],TamSX3("C5_XLININD")[02],""     },;// Campo incluído por Diego Rodrigues em 28/08/2024 para visualização da linha industrial. */
									{ "Pedido"           ,"C9_PEDIDO" ,TamSX3("C9_PEDIDO" )[03],TamSX3("C9_PEDIDO" )[01],TamSX3("C9_PEDIDO" )[02],""     },;
									{ "Cliente"          ,"C9_CLIENTE",TamSX3("C9_CLIENTE")[03],TamSX3("C9_CLIENTE")[01],TamSX3("C9_CLIENTE")[02],""     },;
									{ "Loja"             ,"C9_LOJA"   ,TamSX3("C9_LOJA"   )[03],TamSX3("C9_LOJA"   )[01],TamSX3("C9_LOJA"   )[02],""     },;
									{ "Nome"             ,"A1_NOME"   ,TamSX3("A1_NOME"   )[03],TamSX3("A1_NOME"   )[01],TamSX3("A1_NOME"   )[02],""     },;
									{ "Emissão"          ,"C5_EMISSAO",TamSX3("C5_EMISSAO")[03],TamSX3("C5_EMISSAO")[01],TamSX3("C5_EMISSAO")[02],""     },;
									{ "Peso Aproximado"  ,"B1_PESO"   ,TamSX3("B1_PESO"   )[03],TamSX3("B1_PESO"   )[01],TamSX3("B1_PESO"   )[02],""     },;	 // C9_PESOL campo de tela não existente na SC9
									{ "Transportadora"   ,"C5_DTRANSP",TamSX3("C5_DTRANSP")[03],TamSX3("C5_DTRANSP")[01],TamSX3("C5_DTRANSP")[02],""     },;	 
									{ "Dt. Lib. Crédito" ,"C5_DTLIBCR",TamSX3("C5_DTLIBCR")[03],TamSX3("C5_DTLIBCR")[01],TamSX3("C5_DTLIBCR")[02],""     },;	// Alterado Por Arthur em 03/08/2016 { "Liberação"        ,"C9_DATALIB",TamSX3("C9_DTLIBCR")[03],TamSX3("C9_DTLIBCR")[01],TamSX3("C9_DTLIBCR")[02],""     },;
									{ "Cond.Pg."         ,"E4_DESCRI" ,TamSX3("E4_DESCRI" )[03],TamSX3("E4_DESCRI" )[01],TamSX3("E4_DESCRI" )[02],""     },;
									{ "Num Cd.Pg."       ,"C5_CONDPAG",TamSX3("C5_CONDPAG")[03],TamSX3("C5_CONDPAG")[01],TamSX3("C5_CONDPAG")[02],""     },;
									{ "Valor"            ,"C9_PRCVEN" ,TamSX3("C9_PRCVEN" )[03],TamSX3("C9_PRCVEN" )[01],TamSX3("C9_PRCVEN" )[02],""     },;
									{ "Tp Op."           ,"C5_TPOPER" ,TamSX3("C5_TPOPER" )[03],TamSX3("C5_TPOPER" )[01],TamSX3("C5_TPOPER" )[02],""     },;
									{ "Tab."             ,"C5_TABELA" ,TamSX3("C5_TABELA" )[03],TamSX3("C5_TABELA" )[01],TamSX3("C5_TABELA" )[02],""     },;
									{ "Banco"            ,"A1_BCO1"   ,TamSX3("A1_BCO1"   )[03],TamSX3("A1_BCO1"   )[01],TamSX3("A1_BCO1"   )[02],""     },;
									{ "Agencia"     	 ,"A1_AGENCIA",TamSX3("A1_AGENCIA")[03],TamSX3("A1_AGENCIA")[01],TamSX3("A1_AGENCIA")[02],""     },;
									{ "Conta"            ,"A1_BCCONT" ,TamSX3("A1_BCCONT" )[03],TamSX3("A1_BCCONT" )[01],TamSX3("A1_BCCONT" )[02],""     },;
									{ "Carteira"         ,"A1_CDCART" ,TamSX3("A1_CDCART" )[03],TamSX3("A1_CDCART" )[01],TamSX3("A1_CDCART" )[02],""     },;
									{ "Instr.1"          ,"A1_INSTRU1",TamSX3("A1_INSTRU1")[03],TamSX3("A1_INSTRU1")[01],TamSX3("A1_INSTRU1")[02],""     },;
									{ "Instr.2"          ,"A1_INSTRU2",TamSX3("A1_INSTRU2")[03],TamSX3("A1_INSTRU2")[01],TamSX3("A1_INSTRU2")[02],""     },;
									{ "D.P/Prot."        ,"A1_PRZPROT",TamSX3("A1_PRZPROT")[03],TamSX3("A1_PRZPROT")[01],TamSX3("A1_PRZPROT")[02],""     },;
									{ "Respons.Repr."    ,"C5_VENDRES",TamSX3("C5_VENDRES")[03],TamSX3("C5_VENDRES")[01],TamSX3("C5_VENDRES")[02],""     },;
									{ "Ord.Sep."         ,"C9_ORDSEP" ,TamSX3("C9_ORDSEP" )[03],TamSX3("C9_ORDSEP" )[01],TamSX3("C9_ORDSEP" )[02],""     },;
									{ "Obs Sep."         ,"C9_OBSSEP" ,TamSX3("C9_OBSSEP" )[03],TamSX3("C9_OBSSEP" )[01],TamSX3("C9_OBSSEP" )[02],""     },;
									{ "Clf."             ,"C5_TPDIV"  ,TamSX3("C5_TPDIV"  )[03],TamSX3("C5_TPDIV"  )[01],TamSX3("C5_TPDIV"  )[02],""     },;
									{ "UF"			     ,"A1_EST"	  ,TamSX3("A1_EST" 	  )[03],TamSX3("A1_EST"    )[01],TamSX3("A1_EST" 	)[02],""     }} 
	endif
	if __cUserId$_cUsrExp .AND. !__cUserId$_cUsrFin
		aRotina   := {	{ "&Manutenção"      , "U_RFATA26I('E')"       , 0 , 2, 0, NIL },;
						{ "&Impr. Ord.Sep."  , "U_RFATR013('RFATA026')", 0 , 6, 0, NIL },;
						{ "&Adm.Ord.Sep."    , "U_RFATE025('RFATA026')", 0 , 6, 0, NIL },;
						{ "Pick-&List"    	 , "U_RFATR045('RFATA026')", 0 , 6, 0, NIL },;
						{ "&Refresh"         , "U_RFATA26U()"	       , 0 , 3, 0, .F. } }
	//					{ "&Legenda"         , "A450Legend"	           , 0 , 1, 0, .F. },;
	elseif !__cUserId$_cUsrExp .AND. __cUserId$_cUsrFin
		MontAtalho()		//Teclas F...
		aRotina   := {	{ "Adm.&Financ."          , "U_RFATA26I('F')"       , 0 , 2, 0, NIL },;
						{ "Impr.&Pré-Nota"        , "U_RMATR730()"          , 0 , 2, 0, NIL },;
						{ "&Refresh"              , "U_RFATA26U()"	       , 0 , 3, 0, .F. },;
						{ "Incluir Msg. Separação", "U_RFATA027()"	       , 0 , 3, 0, .F. } }
	//elseif __cUserId$_cUsrExp .AND. __cUserId$_cUsrFin
	elseif __cUserId$_cUsrAdm
		MontAtalho()		//Teclas F...
		aRotina   := {	{ "Adm.&Financ."     , "U_RFATA26I('F')"       , 0 , 2, 0, NIL },;
						{ "Impr.&Pré-Nota"   , "U_RMATR730()"          , 0 , 2, 0, NIL },;
						{ "&Manutenção"      , "U_RFATA26I('E')"       , 0 , 2, 0, NIL },;
						{ "&Impr. Ord.Sep."  , "U_RFATR013('RFATA026')", 0 , 2, 0, NIL },;
						{ "&Adm.Ord.Sep."    , "U_RFATE025('RFATA026')", 0 , 6, 0, NIL },;
						{ "Pick-&List"    	 , "U_RFATR045('RFATA026')", 0 , 1, 0, NIL },;
						{ "&Refresh"         , "U_RFATA26U()"	       , 0 , 3, 0, .F. } }
	//					{ "&Legenda"         , "A450Legend"	           , 0 , 1, 0, .F. },;
	else
		aRotina   := {  { "&Refresh"         , "U_RFATA26U()"	       , 0 , 3, 0, .F. } }
	//					{ "&Legenda"         , "A450Legend"	           , 0 , 1, 0, .F. },;
	endif
	if ExistBlock("RFATL001")
		AAdd(aRotina,{"Logs do Pedido","U_RFATL001((_cTbTmp1)->C9_PEDIDO,POSICIONE('SUA',8,xFilial('SUA')+(_cTbTmp1)->C9_PEDIDO,'UA_NUM'),'','"+_cRotina+"',)" ,0,6,0 ,NIL})
	endif
	MontaArq()
	if ExistBlock("RFATA26U")
		SetKey(VK_F5 , {||   })
		SetKey(VK_F5 , {|| IIF(!_lEF05 .OR. !_lMultFs, EVAL( { ||	CarregaAmbiente(_aTabs,"F5")                        , ;
																	_cPedC9   := IIF(type(_cTbTmp1+"->C9_PEDIDO")<>"U", (_cTbTmp1)->C9_PEDIDO, NIL) , ;
																	_cFNamTmp := FunName()                              , ;
																	_lEF05    := .T.                                    , ;
																	U_RFATA26U()                                        , ;
																	_lEF05    := .F.                                    , ;
																	AtuDados("F5")                                      , ;
																	SetFunName(_cFNamTmp)                               , ;
																	MontaArq(_cPedC9)                                   } ;
															),NIL) } )
	endif
	CriaBrowse()
	SetFunName(_cFNBkp)
	//Restauro as teclas de atalho
	SetKey(     VK_F2 , {||   })
	SetKey(     VK_F4 , {||   })
	SetKey(     VK_F5 , {||   })
	SetKey(     VK_F6 , {||   })
	SetKey(     VK_F7 , {||   })
	SetKey(     VK_F8 , {||   })
	SetKey(     VK_F9 , {||   })
	SetKey(     VK_F10, {||   })
	SetKey(     VK_F11, {||   })
	SetKey(  K_CTRL_F9, {||   })
return
/*/{Protheus.doc} MontaArq
@description Montagem e atualização do arquivo de trabalho (tabela temporária TRB) da rotina. 
@author Anderson C. P. Coelho (ALL System Solutions)
@since 23/03/2013
@version 1.0
@param _cNumPed, caracter, Número do Pedido de Vendas
@history 11/02/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Realizada a correção da query da rotina, pois trazia o relacionamento com as tabelas "SC5" e "SB1" por "LEFT OUTER JOIN", quando o correto seria por "INNER JOIN"; pois não filtrava a filial da tabela "SB1" e não colhia apenas registros não deletados da tabela SB1.
@history 11/02/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Criada a view "RFATA026_0101" no banco de dados "P12_VIEWPRODUCAO" (definida pelo parâmetro "AR_VACOPED"), para substituição da query desta rotina, visando melhoria de performance.
@history 11/02/2020, Anderson C. P. Coelho (ALLSS Soluções em Sistemas), Retirado o MsSeek na tabela "SC5", pois a mesma já poderia ser posicionada por Recno, melhorando assim a sua performance.
@type function
@see https://allss.com.br
/*/
static function MontaArq(_cNumPed)
//	Local   _cFilExp           := "%"+IIF(__cUserId$_cUsrExp .AND. !__cUserId$_cUsrFin," AND SC9.C9_BLCRED = '' AND SC9.C9_ORDSEP = ''","")+"%"
	Local   _cFilExp           :=     IIF(__cUserId$_cUsrExp .AND. !__cUserId$_cUsrFin," AND SC9.C9_BLCRED = '' AND SC9.C9_ORDSEP = ''","")
	Local   _cTabView          := AllTrim(SuperGetMv("AR_VACOPED",,"[P12_VIEWPRODUCAO].[dbo].["+_cRotina+"_"+cNumEmp+"]"))		//[P12_VIEWPRODUCAO].[dbo].[RFATA026_0101]
	Local   _cIdArq            := GetNextAlias() +StrTran(Time(),":","")		//"MA"+StrTran(Time(),":","")
	Local   _cQry              := ""
//	Local   aItemPed           := {}
//	Local   aCabPed            := {}
//	Local   _nVlTot            := {}

	Local   _x                 := 0

	Private &("_aKey"+_cIdArq) := {}
	Private _dDTLSC9           := SuperGetMv("MV_DTLSC9",,"20160101")
	Private _lM410PLNF         := ExistBlock("M410PLNF")
	Private lAntPag            := .F. //Cod Pag Antecipado

	Default _cNumPed           := "" //Linha adicionada por Adriano Leonardo em 10/10/2013 para melhoria na rotina

	CarregaAmbiente(_aTabs,_cIdArq)

	if _lArq
		if Select(_cTbTmp1) > 0
			dbSelectArea(_cTbTmp1)
			(_cTbTmp1)->(dbCloseArea())
		endif
		_lArq := .F.
	endif
	//-----------------------------------------------------
	// Criação da Tabela Temporária Temporária (_cTbTmp1 - TRB)
	//-----------------------------------------------------
	/*-----------------------------------------------------
	|              Definições Importantes:                |
	-------------------------------------------------------
	|      _aTam[3]       |    _aTam[1]		  | _aTam[2]  |
	-------------------------------------------------------
	| "C", "D", "N", etc. | Tamanho do Campo  | Decimais  |
	-------------------------------------------------------*/
	_aStru := {}
	AADD(_aStru,{ "C9_STATUS" , "C"    , 02     , 0       } )
	_aTam := TamSX3("C5_NPRIORI")
	AADD(_aStru,{ "C5_NPRIORI",_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("C5_XLININD")
	AADD(_aStru,{ "C5_XLININD",_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("C9_PEDIDO" )
	AADD(_aStru,{ "C9_PEDIDO" ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("C9_CLIENTE")
	AADD(_aStru,{ "C9_CLIENTE",_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("C9_LOJA"   )
	AADD(_aStru,{ "C9_LOJA"   ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("A1_NOME"   )
	AADD(_aStru,{ "A1_NOME"   ,_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("C5_EMISSAO")
	AADD(_aStru,{ "C5_EMISSAO",_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("C5_DTRANSP")
	AADD(_aStru,{ "C5_DTRANSP",_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("B1_PESO" )
	AADD(_aStru,{ "B1_PESO"   ,_aTam[3],_aTam[1],_aTam[2] } )			
	_aTam := TamSX3("C5_DTLIBCR")									// Comentado por Arthur Silva em 03/08/2016  _aTam := TamSX3("C9_DATALIB")
	AADD(_aStru,{ "C5_DTLIBCR",_aTam[3],_aTam[1],_aTam[2] } )		//Comentado por Arthur Silva em 03/08/2016   AADD(_aStru,{ "C9_DATALIB",_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("C9_DTLIBCR")									// Comentado por Arthur Silva em 03/08/2016  _aTam := TamSX3("C9_DATALIB")
	AADD(_aStru,{ "C9_DTLIBCR",_aTam[3],_aTam[1],_aTam[2] } )		//Comentado por Arthur Silva em 03/08/2016   AADD(_aStru,{ "C9_DATALIB",_aTam[3],_aTam[1],_aTam[2] } )
	_aTam := TamSX3("C9_ORDSEP" )
	AADD(_aStru,{ "C9_ORDSEP" ,_aTam[3],_aTam[1],_aTam[2] } )
	// - INSERIDO EM 06/03/2014 POR JÚLIO SOARES PARA IMPLEMENTAR O CAMPO DA OBSERVAÇÃO DE SEPARAÇÃO DO PEDIDO.
	_aTam := TamSX3("C9_OBSSEP" )
	AADD(_aStru,{ "C9_OBSSEP" ,_aTam[3],_aTam[1],_aTam[2] } )
	// - INSERIDO EM 14/03/2014 POR JÚLIO SOARES PARA IMPLEMENTAR O CAMPO DA DESCRIÇÃO DA CONDIÇÃO DE PAGTO.
	_aTam := TamSX3("E4_DESCRI" )
	AADD(_aStru,{ "E4_DESCRI" ,_aTam[3],_aTam[1],_aTam[2] } )
	if __cUserId $ _cUsrFin .or. __cUserId $ _cUsrAdm
		_aTam := TamSX3("C5_CONDPAG" )
		AADD(_aStru,{ "C5_CONDPAG" ,_aTam[3],_aTam[1],_aTam[2] } )
		//---------------------------------------------------------
		_aTam := TamSX3("C9_PRCVEN" )
		AADD(_aStru,{ "C9_PRCVEN"  ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("C5_TPDIV" )
		AADD(_aStru,{ "C5_TPDIV"   ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("C5_TPOPER" )
		AADD(_aStru,{ "C5_TPOPER"  ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("C5_TABELA" )
		AADD(_aStru,{ "C5_TABELA"  ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("A1_BCO1" )
		AADD(_aStru,{ "A1_BCO1"    ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("A1_AGENCIA" )
		AADD(_aStru,{ "A1_AGENCIA" ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("A1_BCCONT" )
		AADD(_aStru,{ "A1_BCCONT"  ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("A1_CDCART" )
		AADD(_aStru,{ "A1_CDCART"  ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("A1_INSTRU1" )
		AADD(_aStru,{ "A1_INSTRU1" ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("A1_INSTRU2" )
		AADD(_aStru,{ "A1_INSTRU2" ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("A1_PRZPROT" )
		AADD(_aStru,{ "A1_PRZPROT" ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("C5_VENDRES" )
		AADD(_aStru,{ "C5_VENDRES" ,_aTam[3],_aTam[1],_aTam[2] } )
		_aTam := TamSX3("UB_NUM" )
		AADD(_aStru,{ "UB_NUM"     ,_aTam[3],_aTam[1],_aTam[2] } )
		//---------------------------------------------------------	
	endif
	_aTam := TamSX3("A1_EST" )
	AADD(_aStru,{ "A1_EST" ,_aTam[3],_aTam[1],_aTam[2] } )
	
	//-------------------
	//Criacao do objeto
	//-------------------
	oTempTable := FWTemporaryTable():New(_cTbTmp1)
	_lArq      := .T.
	oTemptable:SetFields(_aStru)
	oTempTable:AddIndex("indice1", {"C9_PEDIDO" ,"C5_EMISSAO","C5_DTLIBCR","C5_NPRIORI","C9_CLIENTE","C9_LOJA"} )
	oTempTable:AddIndex("indice2", {"C5_NPRIORI","C9_PEDIDO" ,"C5_EMISSAO","C5_DTLIBCR","C9_CLIENTE","C9_LOJA"} )
	oTempTable:AddIndex("indice3", {"A1_NOME"   ,"C9_PEDIDO" ,"C5_EMISSAO","C5_DTLIBCR","C5_NPRIORI"          } )
	oTempTable:AddIndex("indice4", {"C9_ORDSEP" ,"C5_NPRIORI","C9_PEDIDO" ,"C5_EMISSAO","C5_DTLIBCR"          } )
	oTempTable:AddIndex("indice5", {"C9_CLIENTE","C9_LOJA"                                                    } )
	oTempTable:AddIndex("indice6", {"C5_DTLIBCR","C9_PEDIDO"                                                  } )
	//------------------
	//Criacao da tabela
	//------------------
	oTempTable:Create()
	
	dbSelectArea(_cTbTmp1)
	(_cTbTmp1)->(dbSetOrder(1))
	(_cTbTmp1)->(dbGoTop())

	//C9_STATUS: 01=Bl.Crédito;02=Bl.Estoque;05=Bl.WMS;06=Bl.TMS;10=Faturado;99=Liberado
	//INICIO CUSTOM. ALLSS - 11/02/2020 - Anderson C. P. Coelho - Query substituída pela view "RFATA026_0101" criada no banco de dados "P12_VIEWPRODUCAO", objetivando melhoria de performance.
		/*
		BeginSql Alias _cAliTmp
			SELECT C9_PEDIDO,  C5_DTLIBCR, C9_DTLIBCR,  C9_CLIENTE, C9_LOJA, C9_ORDSEP, C9_OBSSEP, C9_DESCPAG, C9_PRCVEN, B1_PESO, UB_NUM, RECSC5
			, ( CASE
					WHEN C9_BLCRED <> ''
						THEN '01'
					WHEN C9_BLEST  <> ''
						THEN '02'
					WHEN C9_BLWMS  <> ''
						THEN '05'
					WHEN C9_BLTMS  <> ''
						THEN '06'
						else '99'
				END ) C9_STATUS
			FROM (
					SELECT 	C9_PEDIDO,  C5_DTLIBCR, C9_DTLIBCR,   C9_CLIENTE, C9_LOJA, LTRIM(RTRIM(C9_OBSSEP)) C9_OBSSEP, C9_DESCPAG
							, MAX(C9_ORDSEP) C9_ORDSEP, MAX(C9_BLCRED) C9_BLCRED, MAX(C9_BLEST) C9_BLEST
							, MAX(C9_BLWMS ) C9_BLWMS , MAX(C9_BLTMS ) C9_BLTMS
							, SUM(C9_QTDLIB*C9_PRCVEN) AS C9_PRCVEN
							, SUM(C9_QTDLIB*B1_PESO) as B1_PESO
							, SUB.UB_NUM UB_NUM
							, SC5.R_E_C_N_O_ RECSC5
					FROM %table:SC9% SC9 (NOLOCK)
								INNER JOIN %table:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
														  AND SB1.B1_COD = SC9.C9_PRODUTO
								//					  	  AND SB1.B1_LOCPAD = SC9.C9_LOCAL
													  	  AND SB1.%NotDel%
								INNER JOIN %table:SC5% SC5 (NOLOCK) ON SC5.C5_FILIAL  = %xFilial:SC5%
														  AND SC5.C5_NUM   = SC9.C9_PEDIDO
														  AND SC5.%NotDel%
								 LEFT JOIN %table:SUB% SUB (NOLOCK) ON SUB.UB_FILIAL  = %xFilial:SUB%
														  AND SUB.UB_NUMPV   = SC9.C9_PEDIDO
														  AND SUB.UB_ITEMPV    = SC9.C9_ITEM
														  AND SUB.UB_PRODUTO = SC9.C9_PRODUTO
														  AND SUB.%NotDel%
					WHERE SC9.C9_FILIAL    = %xFilial:SC9%
					  AND SC9.C9_BLOQUEI   = %Exp:''%
					  AND SC9.C9_NFISCAL   = %Exp:''%
					  AND SC9.C9_DATALIB  >= %Exp:DTOS(_dDTLSC9)%
					  AND SC9.%NotDel%
					  %Exp:_cFilExp%
					GROUP BY C9_PEDIDO, C5_DTLIBCR, C9_DTLIBCR, C9_CLIENTE, C9_LOJA, LTRIM(RTRIM(C9_OBSSEP)), C9_DESCPAG, UB_NUM, SC5.R_E_C_N_O_
				) SC9X
			ORDER BY C9_PEDIDO, C5_DTLIBCR, C9_DTLIBCR, C9_CLIENTE, C9_LOJA, C9_STATUS DESC, C9_ORDSEP DESC
		EndSql
		MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_001.TXT",GetLastQuery()[02])
		*/
		/*
				USE [P12_VIEWPRODUCAO]
				GO
							
				SET ANSI_NULLS ON
				GO
							
				SET QUOTED_IDENTIFIER ON
				GO
							
				CREATE VIEW [dbo].[RFATA026_0101] AS
							
					SELECT   C9_PEDIDO
							,C5_DTLIBCR
							,C9_DTLIBCR
							,C9_DATALIB
							,C9_CLIENTE
							,C9_LOJA
							,C9_ORDSEP
							,C9_OBSSEP
							,C9_DESCPAG
							,C9_PRCVEN
							,B1_PESO
							,UB_NUM
							,RECSC5
							,(CASE 
									WHEN DATALENGTH(LTRIM(RTRIM(SUBSTRING(C9_BLCRED,1,1)))) = 1 THEN '01' 
									WHEN DATALENGTH(LTRIM(RTRIM(SUBSTRING(C9_BLEST ,1,1)))) > 0 THEN '02' 
									WHEN DATALENGTH(LTRIM(RTRIM(SUBSTRING(C9_BLWMS ,1,1)))) > 0 THEN '05' 
									WHEN DATALENGTH(LTRIM(RTRIM(SUBSTRING(C9_BLTMS ,1,1)))) > 0 THEN '06' 
									ELSE '99' 
								END ) C9_STATUS 
					FROM (
							SELECT   C9_PEDIDO
									,C5_DTLIBCR
									,C9_DTLIBCR
									,C9_DATALIB
									,C9_CLIENTE
									,C9_LOJA
									,LTRIM(RTRIM(C9_OBSSEP)) C9_OBSSEP
									,C9_DESCPAG
									,MAX(C9_ORDSEP) C9_ORDSEP
									,MAX(C9_BLCRED) C9_BLCRED
									,MAX(C9_BLEST ) C9_BLEST
									,MAX(C9_BLWMS ) C9_BLWMS
									,MAX(C9_BLTMS ) C9_BLTMS
									,SUM(C9_QTDLIB*C9_PRCVEN) AS C9_PRCVEN
									,SUM(C9_QTDLIB*B1_PESO  ) AS B1_PESO
									,UB_NUM
									,SC5.R_E_C_N_O_ RECSC5
							FROM [P12_PRODUCAO].[dbo].[SC9010] SC9 (NOLOCK)
								INNER JOIN [P12_PRODUCAO].[dbo].[SB1010] SB1 (NOLOCK) ON SB1.B1_FILIAL   = '01'
																					 AND SB1.B1_COD      = SC9.C9_PRODUTO 
								--													 AND SB1.B1_LOCPAD   = SC9.C9_LOCAL
																					 AND SB1.D_E_L_E_T_  = ''
								INNER JOIN [P12_PRODUCAO].[dbo].[SC5010] SC5 (NOLOCK) ON SC5.C5_FILIAL   = '01' 
																					 AND SC5.C5_NUM      = SC9.C9_PEDIDO 
																					 AND SC5.D_E_L_E_T_  = ''
								 LEFT JOIN [P12_PRODUCAO].[dbo].[SUB010] SUB (NOLOCK) ON SUB.UB_FILIAL   = '01' 
																					 AND SUB.UB_NUMPV    = SC9.C9_PEDIDO 
																					 AND SUB.UB_ITEMPV   = SC9.C9_ITEM 
																					 AND SUB.UB_PRODUTO  = SC9.C9_PRODUTO 
																					 AND SUB.D_E_L_E_T_  = ''
							WHERE SC9.C9_FILIAL   = '01' 
								AND SC9.C9_NFISCAL  = '' 
								AND SC9.C9_BLOQUEI  = '' 
								AND SC9.D_E_L_E_T_  = ''
							--AND SC9.C9_DATALIB >= '20191101' 
							GROUP BY C9_PEDIDO, C5_DTLIBCR, C9_DTLIBCR, C9_DATALIB, C9_CLIENTE, C9_LOJA, LTRIM(RTRIM(C9_OBSSEP)), C9_DESCPAG, UB_NUM, SC5.R_E_C_N_O_
						) SC9X
				--ORDER BY  C9_PEDIDO, C5_DTLIBCR, C9_DTLIBCR, C9_CLIENTE, C9_LOJA, C9_STATUS DESC, C9_ORDSEP DESC
				GO
		*/
//		_cQry := " SELECT * FROM "+_cTabView+" AS SC9 WHERE C9_DATALIB >= '"+DTOS(_dDTLSC9)+"' "
		_cQry := " SELECT * FROM "+_cTabView+" AS SC9 WHERE 0=0 "
		if !empty(_cFilExp)
			_cQry += _cFilExp
		endif
		_cQry += " ORDER BY C9_PEDIDO, C5_DTLIBCR, C9_DTLIBCR, C9_CLIENTE, C9_LOJA, C9_STATUS DESC, C9_ORDSEP DESC "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAliTmp,.F.,.F.)
	//FIM CUSTOM. ALLSS - 11/02/2020 - Anderson C. P. Coelho - Query substituída pela view "RFATA026_0101" criada no banco de dados "P12_VIEWPRODUCAO", objetivando melhoria de performance.
	dbSelectArea(_cAliTmp)
	(_cAliTmp)->(dbGoTop())
	if !(_cAliTmp)->(EOF())
		While !(_cAliTmp)->(EOF())
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			//if SC5->(MsSeek(xFilial("SC5") + (_cAliTmp)->C9_PEDIDO,.T.,.F.))
			if (_cAliTmp)->RECSC5 > 0
				SC5->(dbGoTo((_cAliTmp)->RECSC5))
				dbSelectArea("SE4")
				SE4->(dbSetOrder(1))
				SE4->(MsSeek(FWFilial("SE4") + SC5->C5_CONDPAG,.T.,.F.))
				lAntPag  := SE4->E4_CTRADT == "1"
				if _lCli := !SC5->C5_TIPO $ "D/B"
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					if !SA1->(MsSeek(FWFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
						dbSelectArea(_cAliTmp)
						(_cAliTmp)->(dbSkip())
						Loop
					endif
				else
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))
					if !SA2->(MsSeek(FWFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
						dbSelectArea(_cAliTmp)
						(_cAliTmp)->(dbSkip())
						Loop
					endif
				endif
				/*
				if _lTotPv
					BeginSql Alias "SC9LIB"
						SELECT SC6.*
							 , SC9.*
							 , (C9_QTDLIB*C9_PRCVEN) AS VALMERC
						FROM %table:SC9% SC9 (NOLOCK)
							INNER JOIN %table:SC6% SC6 (NOLOCK) ON SC6.C6_FILIAL  = %xFilial:SC6%
													  AND (SC6.C6_QTDVEN-SC6.C6_QTDENT) > 0
													  AND SC6.C6_NUM     = SC9.C9_PEDIDO
													  AND SC6.C6_ITEM    = SC9.C9_ITEM
													  AND SC6.C6_PRODUTO = SC9.C9_PRODUTO
													  AND SC6.%NotDel%												
						WHERE SC9.C9_FILIAL    = %xFilial:SC9%
						  AND SC9.C9_PEDIDO    = %Exp:SC5->C5_NUM%
						  AND SC9.C9_BLOQUEI   = %Exp:''%
						  AND SC9.C9_NFISCAL   = %Exp:''%
						  AND SC9.C9_DATALIB  >= %Exp:DTOS(_dDTLSC9)%
	//					  AND SC9.C9_DATALIB  >= '20180101'
	//					  AND SC9.C9_BLCRED   <> '10'
						  AND SC9.%NotDel%
						  %Exp:_cFilExp%
					EndSql
					//MemoWrite("\2.MemoWrite\"+_cRotina+"_QRY_002.TXT",GetLastQuery()[02])
					dbSelectArea("SC9LIB")
					SC9LIB->(dbGoTop())
					if !SC9LIB->(EOF())
						aItemPed := {}
						aCabPed  := {	SC5->C5_TIPO				,;		//1
										SC5->C5_CLIENTE				,;		//2
										SC5->C5_LOJACLI				,;		//3
										SC5->C5_TRANSP				,;		//4
										SC5->C5_CONDPAG				,;		//5
										SC5->C5_EMISSAO				,;		//6
										SC5->C5_NUM					,;		//7
										SC5->C5_VEND1				,;		//8
										SC5->C5_VEND2				,;		//9
										SC5->C5_VEND3				,;		//10
										SC5->C5_VEND4				,;		//11
										SC5->C5_VEND5				,;		//12
										SC5->C5_COMIS1				,;		//13
										SC5->C5_COMIS2				,;		//14
										SC5->C5_COMIS3				,;		//15
										SC5->C5_COMIS4				,;		//16
										SC5->C5_COMIS5				,;		//17
										SC5->C5_FRETE				,;		//18
										SC5->C5_TPFRETE				,;		//19
										SC5->C5_SEGURO				,;		//20
										SC5->C5_TABELA				,;		//21
										SC5->C5_VOLUME1				,;		//22
										SC5->C5_ESPECI1				,;		//23
										SC5->C5_MOEDA				,;		//24
										SC5->C5_REAJUST				,;		//25
										SC5->C5_BANCO				,;		//26
										SC5->C5_ACRSFIN				,;		//27
										SC5->C5_TPDIV				,;		//28
										SC5->C5_TPOPER				,;		//29					
								   		SC5->C5_NPRIORI				;		//30
										}
						dbSelectArea("SC5")
						MaFisEnd()
						MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,IIF(_lCli,"C","F"),SC5->C5_TIPO,SC5->C5_TIPOCLI,MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1",_cRotina)
						dbSelectArea("SC9LIB")
						While !SC9LIB->(EOF())
							dbSelectArea("SB1")
							SB1->(dbSetOrder(1))
							SB1->(MsSeek(xFilial("SB1") + SC9LIB->C6_PRODUTO,.T.,.F.))
							dbSelectArea("SF4")
							SF4->(dbSetOrder(1))
							SF4->(MsSeek(xFilial("SF4") + SC9LIB->C6_TES,.T.,.F.))
							MaFisAdd(SC9LIB->C6_PRODUTO,SC9LIB->C6_TES,SC9LIB->C9_QTDLIB,SC9LIB->C9_PRCVEN,0,"","",0,0,0,0,0,SC9LIB->VALMERC,0,SB1->(Recno()),SF4->(Recno()))
							aadd(aItemPed,	{	SC9LIB->C6_ITEM		,;		//1
												SC9LIB->C6_PRODUTO	,;		//2
												SC9LIB->C6_DESCRI	,;		//3
												SC9LIB->C6_TES		,;		//4
												SC9LIB->C6_CF		,;		//5
												SC9LIB->C6_UM		,;		//6
												SC9LIB->C9_QTDLIB	,;		//7
												SC9LIB->C9_PRCVEN	,;		//8
												SC9LIB->C6_NOTA		,;		//9
												SC9LIB->C6_SERIE	,;		//10
												SC9LIB->C6_CLI		,;		//11
												SC9LIB->C6_LOJA		,;		//12
												(SC9LIB->C9_QTDLIB*SC9LIB->C9_PRCVEN)	,;		//13
												SC9LIB->C6_ENTREG	,;		//14
												0					,;		//15
												SC9LIB->C6_LOCAL	,;		//16
												0					,;		//17
												0					,;		//18
												0					,;		//19
												SC9LIB->C6_COD_E	,;		//20
												SC9LIB->C6_TPCALC	,;		//21
												SC9LIB->C6_VALDESC	,;		//22
												SC9LIB->C9_PRCVEN	,;		//23
												SC9LIB->C6_NFORI	,;		//24
												SC9LIB->C6_SERIORI	,;		//25
												SC9LIB->C6_ITEMORI	,;		//26
												SC9LIB->C6_IDENTB6	,;		//27
												SC9LIB->C6_CLASFIS	,;		//28
												0					,;      //29
												0					,;      //30
												0					,;      //31
												0					,;      //32
												})
							dbSelectArea("SC9LIB")
							SC9LIB->(dbSkip())
						enddo
						if _lM410PLNF
							U_M410PLNF(aCabPed,aItemPed,"SC5")
						endif
						_nVlTot := MaFisRet(,"NF_TOTAL")
						MaFisEnd()
					endif
					dbSelectArea("SC9LIB")
					SC9LIB->(dbCloseArea())
				endif
				*/
				dbSelectArea(_cTbTmp1)
				while !RecLock(_cTbTmp1,.T.) ; enddo
					for _x := 1 to Len(_aStru)
						//C9_STATUS: 01=Bl.Crédito;02=Bl.Estoque;05=Bl.WMS;06=Bl.TMS;10=Faturado;99=Liberado
						/*if _lTotPv .AND. AllTrim(_aStru[_x][01])=="C9_PRCVEN"
							&(_cTbTmp1+"->"+_aStru[_x][01]) := _nVlTot
						else*/if AllTrim(_aStru[_x][01]) == "C9_OBSSEP"
							&(_cTbTmp1+"->"+_aStru[_x][01]) := SubStr(AllTrim(SC5->C5_OBSSEP),1,Len(SC9->C9_OBSSEP ))
						else
							if SubStr(_aStru[_x][01],1,2)=="C9" .Or.  SubStr(_aStru[_x][01],1,2)=="B1" 
								_cCpo := _cAliTmp+"->"+_aStru[_x][01]
								if _aStru[_x][02] == "D"
									_cCpo := "STOD("+_cCpo+")"
								endif
							else
								_cCpo := "S"+SubStr(_aStru[_x][01],1,2)+"->"+_aStru[_x][01]
							endif
							if !_lCli .AND. "_A1"$_cCpo
								_cCpo := StrTran(_cCpo,"A1","A2")
							endif
							&(_cTbTmp1+"->"+_aStru[_x][01]) := &(_cCpo)					//((IIF(Len(SubStr(_aStru[_x][01],1,AT("_",_aStru[_x][01])-1))==2,"S","")+SubStr(_aStru[_x][01],1,AT("_",_aStru[_x][01])-1))+"->"+_aStru[_x][01])
						endif
					next
				(_cTbTmp1)->(MsUnLock())
			endif
			dbSelectArea(_cAliTmp)
			(_cAliTmp)->(dbSkip())
		enddo
	endif
	dbSelectArea(_cAliTmp)
	(_cAliTmp)->(dbCloseArea())
	//Início - Trecho adicionado por Adriano Leonardo em 10/10/2013 para implementação do refresh da tela
		AtuDados(_cIdArq)
		if type("_oBrw26")=="O"
			_oBrw26:Refresh()
			_oBrw26:ChangeTopBot(.T.)
		endif
		if !Empty(_cNumPed)
			dbSelectArea(_cTbTmp1)
			(_cTbTmp1)->(dbSetOrder(1))
			Set SoftSeek ON
				(_cTbTmp1)->(dbSeek(_cNumPed))
			Set SoftSeek OFF
		endif
	//Fim - Trecho adicionado por Adriano Leonardo em 10/10/2013 para implementação do refresh da tela
	if type("_oBrw26")=="O"
		_oBrw26:nAt := (_cTbTmp1)->(Recno())
		_oBrw26:Refresh()
	endif
return
/*/{Protheus.doc} RFATA26I
@description Chamada da rotina de Liberação de estoque ou de crédito, conforme a rotina chamada. 
@obs Ao chamar esta rotina padrão, o FunName() principal será o RFATA026. Desta forma, por meio do Ponto de Entrada MT455FIL, o pedido de vendas posicionado será filtrado.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 23/03/2013
@version 1.0
@param _cTpLib, caracter, Tipo de Liberação - E=Estoque; F=Financeira
@type function
@see https://allss.com.br
/*/
user function RFATA26I(_cTpLib)
	Local   _aRotBkp   := aClone(aRotina)
	Local   _aPergBkp  := {}
	Local   _aRecSC5   := {}
	Local   _cPvBkp    := (_cTbTmp1)->C9_PEDIDO
	Local   _cCadBkp   := cCadastro
//	Local   _lLibCr    := .F.
	Local   _cLogx     := ""
	Local   _lRet      := .F.
	Local   _cQUpd     := ""
	Local 	_lTpLiC	   := SuperGetMv("AR_FAT026",,.T.)
	Local 	_aProd	   := {}
	

	Local   _p         := 1

	Private _nSqPerg   := 1
	Private cCadastro  := OemToAnsi("Liberação de Crédito")
	Private bFiltraBrw := {|| NIL}

	Default _cTpLib    := ""

	//CarregaAmbiente(_aTabs,"LB")
	While &(_bPAR) <> "U"
		AADD(_aPergBkp,{("MV_PAR"+StrZero(_nSqPerg,2)),&("MV_PAR"+StrZero(_nSqPerg,2))})
		_nSqPerg++
	Enddo
	//C9_STATUS: 01=Bl.Crédito;02=Bl.Estoque;05=Bl.WMS;06=Bl.TMS;10=Faturado;99=Liberado
	dbSelectArea(_cTbTmp1)
	if _cTpLib == "E" .AND. __cUserId$_cUsrExp
		if Empty((_cTbTmp1)->C9_ORDSEP)
			if ((_cTbTmp1)->C9_STATUS=="02" .OR. (_cTbTmp1)->C9_STATUS=="99")
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				if SC5->(MsSeek(xFilial("SC5") + (_cTbTmp1)->C9_PEDIDO,.T.,.F.))
					dbSelectArea("SC9")
					_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + (_cTbTmp1)->C9_PEDIDO + "' .AND. AllTrim(C9_NFISCAL) == '' "
					SC9->(dbClearFilter())
					SC9->(dbSetFilter( { || &(_cFilSC9) }, _cFilSC9 ))
						MATA455()		//Liberação de Estoque
					SetFunName(_cFNBkp)
						dbSelectArea("SC9")
					SC9->(dbClearFilter())
				endif
			else
				MsgAlert("Status do pedido " + (_cTbTmp1)->C9_PEDIDO + " não permite a sua administração!",_cRotina+"_001")
			endif
		else
			//Início - Trecho adicionado por Adriano Leonardo em 10/10/2013 para correção do refresh da tela
			MontaArq((_cTbTmp1)->C9_PEDIDO)
			dbSelectArea(_cTbTmp1)
			if Empty((_cTbTmp1)->C9_ORDSEP)
				if ((_cTbTmp1)->C9_STATUS=="02" .OR. (_cTbTmp1)->C9_STATUS=="99")
					dbSelectArea("SC5")
					SC5->(dbSetOrder(1))
					if SC5->(MsSeek(xFilial("SC5") + (_cTbTmp1)->C9_PEDIDO,.T.,.F.))
						SetFunName("MATA455")
						dbSelectArea("SC9")
							_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + (_cTbTmp1)->C9_PEDIDO + "' .AND. AllTrim(C9_NFISCAL) == '' "
						SC9->(dbClearFilter())
						SC9->(dbSetFilter( { || &(_cFilSC9) }, _cFilSC9 ))
						MATA455()		//Liberação de Estoque
						SetFunName(_cFNBkp)
						SC9->(dbClearFilter())
					endif
				else
					MsgAlert("Status do pedido " + (_cTbTmp1)->C9_PEDIDO + " não permite a sua administração!",_cRotina+"_002")
				endif
			else
				MsgAlert("O pedido " + (_cTbTmp1)->C9_PEDIDO + " já gerou Ordem de Separação. Para utilizar esta manutenção, exclua a Ordem de Separação!",_cRotina+"_003")
			endif
			//Fim - Trecho adicionado por Adriano Leonardo em 10/10/2013 para correção do refresh da tela
		endif
	elseif _cTpLib == "F" .AND. (__cUserId$_cUsrFin .or. __cUserId$_cUsrAdm) .And. empty((_cTbTmp1)->C9_DTLIBCR)
		if ((_cTbTmp1)->C9_STATUS=="01" .OR. (_cTbTmp1)->C9_STATUS=="99")
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			if SC5->(MsSeek(xFilial("SC5") + (_cTbTmp1)->C9_PEDIDO,.T.,.F.))
				_cLogx   := SC5->C5_LOGSTAT + _CRLF + Replicate("-",60) + _CRLF + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) +	_CRLF +  "Crédito Liberado." 
				_aRecSC5 := SC5->(GetArea())
				if !SC5->C5_TIPO $ "/D/B/"
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
				else
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))
					SA2->(MsSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
				endif
				SetFunName("MATA450")
				dbSelectArea("SC9")
				SC9->(dbSetOrder(1))
				_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + (_cTbTmp1)->C9_PEDIDO + "' .AND. AllTrim(C9_NFISCAL) == '' "
				SC9->(dbClearFilter())
				SC9->(dbSetFilter( { || &(_cFilSC9) }, _cFilSC9 ))
				SC9->(dbGoTop())
				
				//Chamada da rotina de vínculo de adiantamento com pedido de venda
				If ExistBlock("RFINE021")
				 	_lRet := U_RFINE021()
				EndIf
				
				If _lRet 
					If _lTpLiC 
						If MsgYesNo("Deseja Liberar o Crédito o Pedido '"+ SC9->C9_PEDIDO +"' ?",_cRotina+"_011") 
							_cQUpd :=" UPDATE  " + RetSqlName("SC9")  +_CRLF
							_cQUpd += " SET C9_DTLIBCR = '" + dtos(dDataBase) + "'  "
							_cQUpd += " 	, C9_BLCRED =  ''  " +_CRLF
							_cQUpd += " 	, C9_BLEST =  '02'  " +_CRLF
							_cQUpd += " WHERE " +_CRLF
							_cQUpd += " 	C9_PEDIDO = '" + (_cTbTmp1)->C9_PEDIDO + "' "+_CRLF
							_cQUpd += " 	AND D_E_L_E_T_ = '' " + _CRLF
							_cQUpd += " 	AND C9_BLEST = '02' " + _CRLF
							_cQUpd += " 	AND C9_BLCRED <> '' " + _CRLF
							_cQUpd += " 	AND C9_NFISCAL = '' " + _CRLF
							If TCSQLExec(_cQUpd) < 0
								MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_001",'STOP')
							EndIf					
							_cQUpd :=" UPDATE  " + RetSqlName("SC5")  +_CRLF
							_cQUpd += " SET C5_DTLIBCR = '" + dtos(dDataBase) + "'  "
							_cQUpd += " 	, C5_LOGSTAT = '" +  _cLogx + "'" 
							_cQUpd += " WHERE " +_CRLF
							_cQUpd += " 	C5_NUM = '" + (_cTbTmp1)->C9_PEDIDO + "' "+_CRLF
							_cQUpd += " 	AND D_E_L_E_T_ = '' " + _CRLF
							If TCSQLExec(_cQUpd) < 0
								MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_002",'STOP')
							EndIf
							_cQUpd :=" UPDATE  " + RetSqlName("SUA")  +_CRLF
							_cQUpd += " SET  UA_LOGSTAT = '" + _cLogx + "'"
							_cQUpd += " WHERE " +_CRLF
							_cQUpd += " 	UA_NUMSC5 = '" + (_cTbTmp1)->C9_PEDIDO + "' "+_CRLF
							_cQUpd += " 	AND D_E_L_E_T_ = '' " + _CRLF
							If TCSQLExec(_cQUpd) < 0
								MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_002",'STOP')
							EndIf	
							If ExistBlock("RFATL001")
								U_RFATL001((_cTbTmp1)->C9_PEDIDO  ,;
									(_cTbTmp1)->UB_NUM,;
									"Crédito Liberado."     ,;
									_cRotina    )
							EndIf	
						//24/07/2024 - Diego Rodrigues - Envio de e-mail para pedidos da linha Industrial
							BeginSql Alias "SC9IND"
							SELECT
								B5_COD,B5_CEME,B5_XLINPRO,C9_QTDLIB
							FROM SC9010 SC9 (NOLOCK)
							INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C9_PRODUTO 
															AND B5_FILIAL = C9_FILIAL AND B5_XLINPRO = '1'
							WHERE SC9.D_E_L_E_T_ = ''
								AND C9_PEDIDO = %Exp:(_cTbTmp1)->C9_PEDIDO%
							GROUP BY B5_COD,B5_CEME,B5_XLINPRO,C9_QTDLIB
							EndSql
							While SC9IND->(!EOF())
								AADD(_aProd,{SC9IND->B5_COD,SC9IND->B5_CEME,C9_QTDLIB})
								SC9IND->(dbSkip())
							EndDo
							SC9IND->(dbCloseArea())
							If ExistBlock("RFATE072") .AND. SC5->C5_XLININD == '1' .AND. SC5->C5_TPOPER == '01'
								U_RFATE072(	(_cTbTmp1)->C9_PEDIDO,2,_aProd)
							EndIf	
						//24/07/2024 - Diego Rodrigues - Envio de e-mail para pedidos da linha Industrial				
						Else
							dbSelectArea(_cTbTmp1)
							MsgStop("Pedido não Liberado '"+(_cTbTmp1)->C9_PEDIDO +"' !",_cRotina+"_013")		
						EndIf
					Else	
						A450LibMan()
						RestArea(_aRecSC5)
						dbSelectArea("SC5")	
						If ExistBlock("RFATL001")
							U_RFATL001((_cTbTmp1)->C9_PEDIDO  ,;
									(_cTbTmp1)->UB_NUM,;
									"Crédito Liberado."     ,;
									_cRotina    )
						EndIf	
						//24/07/2024 - Diego Rodrigues - Envio de e-mail para pedidos da linha Industrial
						BeginSql Alias "SC9IND"
							SELECT
								B5_COD,B5_CEME,B5_XLINPRO,C9_QTDLIB
							FROM SC9010 SC9 (NOLOCK)
							INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C9_PRODUTO 
															AND B5_FILIAL = C9_FILIAL AND B5_XLINPRO = '1'
							WHERE SC9.D_E_L_E_T_ = ''
								AND C9_PEDIDO = %Exp:(_cTbTmp1)->C9_PEDIDO%
							GROUP BY B5_COD,B5_CEME,B5_XLINPRO,C9_QTDLIB
						EndSql
							While SC9IND->(!EOF())
								AADD(_aProd,{SC9IND->B5_COD,SC9IND->B5_CEME,C9_QTDLIB})
								SC9IND->(dbSkip())
							EndDo
							SC9IND->(dbCloseArea())
							If ExistBlock("RFATE072") .AND. SC5->C5_XLININD == '1'
								U_RFATE072(	(_cTbTmp1)->C9_PEDIDO,2,_aProd)
							EndIf	
						//24/07/2024 - Diego Rodrigues - Envio de e-mail para pedidos da linha Industrial								
					EndIf
				EndIf
				
				dbSelectArea(_cTbTmp1)										
				SetFunName(_cFNBkp)
				MontAtalho()				//Teclas F...		
				dbSelectArea("SC9")
				SC9->(dbClearFilter())
			endif
		else
			MsgAlert("Status do pedido '" + (_cTbTmp1)->C9_PEDIDO + "' não permite a sua administração!",_cRotina+"_004")
		endif
	else
		MsgStop("Atenção! Usuário sem acesso a esta funcionalidade!",_cRotina+"_005")
	endif
	SetFunName(_cFNBkp)
	cCadastro := _cCadbkp
	aRotina   := aClone(_aRotBkp)
	for _p    := 1 To Len(_aPergBkp)
		&(_aPergBkp[_p][01]) := _aPergBkp[_p][02]
	next

	MontaArq(_cPvBkp)
return
/*/{Protheus.doc} RFATA26U
@description Rotina responsável por chamar o refresh da tela tela.
@author Adriano Leonardo
@since 10/10/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFATA26U()
	local   _aRotBkp   := aClone(aRotina)
	local   _aPergBkp  := {}
	local   _cCadBkp   := cCadastro
	local   _cFNBkp    := FunName()

	Local   _p         := 1

	private _nSqPerg   := 1

	dbSelectArea(_cTbTmp1)
	MsgRun("Aguarde... Atualizando informações...",_cRotina,{ || MontaArq((_cTbTmp1)->C9_PEDIDO) })
	SetFunName(_cFNBkp)
	cCadastro := _cCadbkp
	aRotina   := aClone(_aRotBkp)
	for _p := 1 to len(_aPergBkp)
		&(_aPergBkp[_p][01]) := _aPergBkp[_p][02]
	next
	if __cUserId$_cUsrFin .or. __cUserId$_cUsrAdm
		MontAtalho()		//Teclas F...
	else
		//Seta atalho para tecla F5 para atualizar a tela
		if ExistBlock("RFATA26U")
			SetKey(VK_F5 , {||   })
			SetKey(VK_F5 , {|| IIF(!_lEF05 .OR. !_lMultFs, EVAL( { ||	CarregaAmbiente(_aTabs,"F5")                        , ;
																		_cPedC9   := IIF(type(_cTbTmp1+"->C9_PEDIDO")<>"U", (_cTbTmp1)->C9_PEDIDO, NIL) , ;
																		_cFNamTmp := FunName()                              , ;
																		_lEF05    := .T.                                    , ;
																		U_RFATA26U()                                        , ;
																		_lEF05    := .F.                                    , ;
																		AtuDados("F5")                                      , ;
																		SetFunName(_cFNamTmp)                               , ;
																		MontaArq(_cPedC9)                                   } ;
																),NIL) } )
		endif
	endif
	if type("_oBrw26")=="O"
		_oBrw26:Refresh()
	endif
return
/*/{Protheus.doc} MontAtalho
@description Montagem das teclas de atalho para o financeiro.
@author Júlio Soares
@since 19/09/16
@version 1.0
@type function
@see https://allss.com.br
/*/
static function MontAtalho()
	local   _cFNamTmp  := FunName()
	_cPedC9            := NIL
	if type("aTmpFil")=="U"
		Public aTmpFil := {}
	endif
	if type("aSelFil")=="U"
		Public aSelFil := {}
	endif
	//Tecla F2 para abertura do Banco de Conhecimento do cliente posicionado, inserido por Arthur Silva em 01/08/2016 conforme solicitação da Sra. Alecssandra
	if ExistBlock("RFINE030") //Rotina chama tela de Banco de conhecimento
		SetKey(VK_F2 , {||   })
		SetKey(VK_F2 , {|| IIF(!_lEF02 .OR. !_lMultFs, EVAL( { ||	_lEF02    := .T.                                    , ;
																	VincConh()                                          , ; //	ComentadoPor Arthur Silva em 24/02/2017 // RestArea(_aSArF02)                                  , ;
																	_lEF02    := .F.                                    } ;
															),NIL) } )
	endif
	SetKey(     VK_F4 , {||   })
	SetKey(     VK_F4 , {|| IIF(!_lEF04 .OR. !_lMultFs, EVAL( { ||	_lEF04    := .T.                                    , ;
																	HISCLITMK()                                         , ;
																	_lEF04    := .F.                                    } ;
															),NIL) } )
	if ExistBlock("RFATA26U")
		SetKey(VK_F5 , {||   })
		SetKey(VK_F5 , {|| IIF(!_lEF05 .OR. !_lMultFs, EVAL( { ||	CarregaAmbiente(_aTabs,"F5")                        , ;
																	_cPedC9   := IIF(type(_cTbTmp1+"->C9_PEDIDO")<>"U", (_cTbTmp1)->C9_PEDIDO, NIL) , ;
																	_cFNamTmp := FunName()                              , ;
																	_lEF05    := .T.                                    , ;
																	U_RFATA26U()                                        , ;
																	_lEF05    := .F.                                    , ;
																	AtuDados("F5")                                      , ;
																	SetFunName(_cFNamTmp)                               , ;
																	MontaArq(_cPedC9)                                   } ;
															),NIL) } )
	endif
	if ExistBlock("RFINE021") //Rotina de Adiantamentos (Pedido de venda)
		SetKey(VK_F6 , {||  })
		SetKey(VK_F6 , {|| IIF(!_lEF06 .OR. !_lMultFs, EVAL( { ||	_lEF06    := .T.                                    , ;
																	VincPVRA()                                          , ;
																	_lEF06    := .F.                                    } ;
															),NIL) } )
	endif
	SetKey(     VK_F7 , {||   })
	SetKey(     VK_F7 , {|| IIF(!_lEF07 .OR. !_lMultFs, EVAL( { ||	CarregaAmbiente(_aTabs,"F7")                        , ;
																	_cPedC9   := IIF(type(_cTbTmp1+"->C9_PEDIDO")<>"U", (_cTbTmp1)->C9_PEDIDO, NIL) , ;
																	_cFNamTmp := FunName()                              , ;
																	_lEF07    := .T.                                    , ;
																	_ALTERPED()                                         , ;
																	_lEF07    := .F.                                    , ;
																	AtuDados("F7")                                      , ;
																	SetFunName(_cFNamTmp)                               , ;
																	MontaArq(_cPedC9)                                   } ;
															),NIL) } )
	SetKey(     VK_F8 , {||   })
	SetKey(     VK_F8 , {|| IIF(!_lEF08 .OR. !_lMultFs, EVAL( { ||	CarregaAmbiente(_aTabs,"F8")                        , ;
																	_cPedC9   := IIF(type(_cTbTmp1+"->C9_PEDIDO")<>"U", (_cTbTmp1)->C9_PEDIDO, NIL) , ;
																	_cFNamTmp := FunName()                              , ;
																	_lEF08    := .T.                                    , ;
																	_ALTER()                                            , ;
																	_lEF08    := .F.                                    , ;
																	AtuDados("F8")                                      , ;
																	SetFunName(_cFNamTmp)                               , ;
																	MontaArq(_cPedC9)                                   } ;
															),NIL) } )
	SetKey(     VK_F9 , {||   })
	SetKey(     VK_F9 , {|| IIF(!_lEF09 .OR. !_lMultFs, EVAL( { ||	_lEF09    := .T.                                    , ;
																	FICHCON("PED")                                      , ;
																	_lEF09    := .F.                                    } ;
															),NIL) } )
	SetKey(     VK_F10, {||   })
	SetKey(     VK_F10, {|| IIF(!_lEF10 .OR. !_lMultFs, EVAL( { ||	_lEF10    := .T.                                    , ;
																	FICHCON("FAT")                                      , ;
																	_lEF10    := .F.                                    } ;
															),NIL) } )
	SetKey(     VK_F11, {||   })
	SetKey(     VK_F11, {|| IIF(!_lEF11 .OR. !_lMultFs, EVAL( { ||	_lEF11    := .T.                                    , ;
																	FICHFINAN()                                         , ;
																	_lEF11    := .F.                                    } ;
															),NIL) } )
	if ExistBlock("RFATL001")
		SetKey( K_CTRL_F9, { || })
		SetKey( K_CTRL_F9, {|| IIF(!_lECF9 .OR. !_lMultFs, EVAL( { ||	_lECF9    := .T.                                    , ;
																		U_RFATL001((_cTbTmp1)->C9_PEDIDO,POSICIONE('SUA',8,xFilial('SUA')+(_cTbTmp1)->C9_PEDIDO,'UA_NUM'),'',_cRotina,), ;
																		_lECF9    := .F.                                    } ;
																),NIL) } )
	endif
return
/*/{Protheus.doc} HISCLITMK
@description Tecla de atalho para acesso ao histórico de clientes.
@author Júlio Soares
@since 29/01/14
@version 1.0
@type function
@see https://allss.com.br
/*/
static function HISCLITMK()
	local   _cFNBkp    := FunName()
	local   _dDtini    := SuperGetMv("MV_HISTMKI",,ctod("01/01/2010"))//Data inicial para considerar no Historico
	local   _dDtFim    := SuperGetMv("MV_HISTMKF",,ctod("31/12/2049"))//Data Final para considerar no Histórico
	if ExistBlock("RCFGASX1")
		U_RCFGASX1("TMKC20    ","01",_dDtini )
		U_RCFGASX1("TMKC20    ","02",_dDtFim )
		U_RCFGASX1("TMKC20    ","03",(_cTbTmp1)->C9_CLIENTE)
		U_RCFGASX1("TMKC20    ","04",(_cTbTmp1)->C9_LOJA)
	endif
//	CarregaAmbiente(_aTabs)
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	if SA1->(MsSeek(xFilial("SA1")+(_cTbTmp1)->C9_CLIENTE+(_cTbTmp1)->C9_LOJA,.T.,.F.))
		TMKC020()
	endif
	SetFunName(_cFNBkp)
	if type("_oBrw26")=="O"
		//_oBrw26:ChangeTopBot(.T.)
		_oBrw26:Refresh()
	endif
return
/*/{Protheus.doc} _ALTERPED
@description Tecla de atalho para realizar a alteração no pedido de vendas posicionado.
@author Júlio Soares
@since 29/01/14
@version 1.0
@type function
@see https://allss.com.br
/*/
static function _ALTERPED()
	Local   _aRotBkp   := aClone(aRotina)
	Local   _aPergBkp  := {}
	Local   _cCadBkp   := cCadastro
	Local   _cFNBkp    := FunName()

	Local _p           := 1

	Private _nSqPerg   := 1

	while &(_bPAR) <> "U"
		AADD(_aPergBkp,{("MV_PAR"+StrZero(_nSqPerg,2)),&("MV_PAR"+StrZero(_nSqPerg,2))})
		_nSqPerg++
	enddo
	if ExistBlock("RFATE035")
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		if SC5->(MsSeek(xFilial("SC5") + (_cTbTmp1)->C9_PEDIDO,.T.,.F.))
			if !SC5->C5_TIPO $ "/D/B/"
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
			else
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				SA2->(MsSeek(xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
			endif
			SetFunName("MATA450")
			_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + (_cTbTmp1)->C9_PEDIDO + "' .AND. AllTrim(C9_NFISCAL) == '' "
		    SC9->(dbClearFilter())
			SC9->(dbSetFilter( { || &(_cFilSC9) }, _cFilSC9 ))
			SC9->(dbGoTop())
			Execblock("RFATE035")
		else
			MSGBOX('Pedido "'+(_cTbTmp1)->C9_PEDIDO+'" não encontrado!',_cRotina+'_012','ALERT')
		endif
	else
		MSGBOX('Função "RFATE035" não encontrada. Informe o administrador do sistema!',_cRotina+'_006','ALERT')
	endif
	dbSelectArea("SC9")
	SC9->(dbClearFilter())
	SetFunName(_cFNBkp)
	cCadastro := _cCadbkp
	aRotina   := aClone(_aRotBkp)
	for _p := 1 to len(_aPergBkp)
		&(_aPergBkp[_p][01]) := _aPergBkp[_p][02]
	next
return
/*/{Protheus.doc} _ALTER
@description Tecla de atalho para realizar a alteração do cadastro (cliente) posicionado.
@author Júlio Soares
@since 23/12/13
@version 1.0
@type function
@see https://allss.com.br
/*/
static function _ALTER()
	local   _aRotBkp   := aClone(aRotina)
	local   _aPergBkp  := {}
	local   _cCadBkp   := cCadastro
	local   _cFNBkp    := FunName()
	local   _lIncui    := INCLUI
	local   _lAltera   := ALTERA
	local   _p         := 0

	private _cCli      := SC5->C5_CLIENTE
	private _cLoja     := SC5->C5_LOJACLI
	private _cNome     := SC5->C5_NOMCLI
	private aRotAuto   := NIL
	private l030Auto   := .F.
	private _nSqPerg   := 1
	private lMvcSA1  :=  SuperGetMv("MV_MVCSA1",,.F.)
	

	If _cRotina == "RFATA026" .OR. lMvcSA1
		//CarregaAmbiente(_aTabs)
		while &(_bPAR) <> "U"
			AADD(_aPergBkp,{("MV_PAR"+StrZero(_nSqPerg,2)),&("MV_PAR"+StrZero(_nSqPerg,2))})
			_nSqPerg++
		enddo
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		if SC5->(MsSeek(xFilial("SC5") + (_cTbTmp1)->C9_PEDIDO,.T.,.F.))
			if !SC5->C5_TIPO $ "/D/B/"
				_cCli    := SC5->C5_CLIENTE
				_cLoja   := SC5->C5_LOJACLI
				_cNome   := SC5->C5_NOMCLI
				SetFunName("MATA030")
				dbSelectArea("SC9")
				_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + (_cTbTmp1)->C9_PEDIDO + "' .AND. AllTrim(C9_NFISCAL) == '' "
				SC9->(dbClearFilter())
				SC9->(dbSetFilter( { || &(_cFilSC9) }, _cFilSC9 ))
				SC9->(dbGoTop())
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				if SA1->(MsSeek(xFilial("SA1")+_cCli+_cLoja,.T.,.F.)) .AND. MSGBOX('Deseja alterar o cadastro do cliente '+ Alltrim(SA1->(A1_COD+A1_LOJA) + " - " + SA1->A1_NOME) +'?',_cRotina + '_007','YESNO')
					INCLUI := .F.
					ALTERA := .T.
					nReg   := SA1->(Recno())
					A030Altera("SA1",nReg,4,143)
					INCLUI := _lIncui
					ALTERA := _lAltera
				endif
			endif
		else
			MsgStop("Atenção! Pedido '"+(_cTbTmp1)->C9_PEDIDO+"' não localizado!",_cRotina+"_013")
		endif
		dbSelectArea("SC9")
		SC9->(dbClearFilter())
		SetFunName(_cFNBkp)
		cCadastro := _cCadbkp
		aRotina   := aClone(_aRotBkp)
		for _p    := 1 to len(_aPergBkp)
			&(_aPergBkp[_p][01]) := _aPergBkp[_p][02]
		next
	
	 Else
		MsgStop("Atenção! Fechar a Ficha Financeira[F11] para Utilizar os outros Atalhos [F8]!",_cRotina+"_013")	
	EndIf
	
return
/*/{Protheus.doc} FICHCON
@description Abri a consulta da posicao do cliente.
@author Júlio Soares
@since 23/12/13
@version 1.0
@type function
@param _Tp, "PED" = Informações de Pedidos; "FAT" = Informações de Faturamento.
@see https://allss.com.br
/*/
static function FICHCON(_Tp)
	local   _aRotBkp   := aClone(aRotina)
	local   _aPergBkp  := {}
	local   _cCadBkp   := cCadastro
	local   _cFNBkp    := FunName()
	local   _cPvBkp    := (_cTbTmp1)->C9_PEDIDO

	local  _x          := 1
	local  _p          := 1

	private _cCli      := SC5->C5_CLIENTE
	private _cLoja     := SC5->C5_LOJACLI
	private _cNome     := SC5->C5_NOMCLI
	private _nSqPerg   := 1

	default _Tp        := "PED"

	//CarregaAmbiente(_aTabs)
	while &(_bPAR) <> "U"
		AADD(_aPergBkp,{("MV_PAR"+StrZero(_nSqPerg,2)),&("MV_PAR"+StrZero(_nSqPerg,2))})
		_nSqPerg++
	enddo
	lPergunte := Pergunte("FIC010",FunName()=="FINC010")
	nBrowse   := 0
	aAlias    := {}
	aGet      := {"","","",""}
	aParam    := {}
	lExibe    := .T. // - Informa se a pesquisa deve ser exibida.
	lRelat    := .F.
	nCasas    := SuperGetMv("MV_CENT",,"2")
	if lPergunte .OR. FunName()<>"FINC010"
		aadd(aParam,MV_PAR01)
		aadd(aParam,MV_PAR02)
		aadd(aParam,MV_PAR03)
		aadd(aParam,MV_PAR04)
		aadd(aParam,MV_PAR05)
		aadd(aParam,MV_PAR06)
		aadd(aParam,MV_PAR07)
		aadd(aParam,MV_PAR08)
		aadd(aParam,MV_PAR09)
		aadd(aParam,MV_PAR10)
		aadd(aParam,MV_PAR11)
		aadd(aParam,MV_PAR12)
		aadd(aParam,MV_PAR13)
		aadd(aParam,MV_PAR14)
		aadd(aParam,MV_PAR15)
	endif
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	if SC5->(MsSeek(xFilial("SC5") + _cPvBkp,.T.,.F.)) .AND. !SC5->C5_TIPO $ "/D/B/"
		_cCli    := SC5->C5_CLIENTE
		_cLoja   := SC5->C5_LOJACLI
		SetFunName("MATA450")
		dbSelectArea("SC9")
		_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + _cPvBkp + "' .AND. AllTrim(C9_NFISCAL) == '' "
		SC9->(dbClearFilter())
		SC9->(dbSetFilter( { || &(_cFilSC9) }, _cFilSC9 ))
		SC9->(dbGoTop())
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if SA1->(MsSeek(xFilial("SA1")+_cCli+_cLoja,.T.,.F.))
			if _Tp == "PED"
				nBrowse := 3
				aAlias  := {}
				Fc010Brow(nBrowse,@aAlias,aParam,.T.,aGet)
				for _x := 1 to len(aAlias)
					dbSelectArea(aAlias[_x][01])
					(aAlias[_x][01])->(dbCloseArea())
					if File(aAlias[_x][02]+OrdBagExt())
						FErase(aAlias[_x][02]+OrdBagExt())
					endif
				next
				nBrowse := 0
				aAlias  := {}
				aParam  := {}
			elseif _Tp == "FAT"
				nBrowse := 4
				aAlias  := {}
				Fc010Brow(nBrowse,@aAlias,aParam,.T.,aGet)
				for _x := 1 to len(aAlias)
					dbSelectArea(aAlias[_x][01])
					(aAlias[_x][01])->(dbCloseArea())
					if File(aAlias[_x][02]+OrdBagExt())
						FErase(aAlias[_x][02]+OrdBagExt())
					endif
				next
				nBrowse := 0
				aAlias  := {}
				aParam  := {}
			endif
		endif
	endif
	dbSelectArea("SC9")
	SC9->(dbClearFilter())
	MontaArq(_cPvBkp)
	SetFunName(_cFNBkp)
	cCadastro := _cCadbkp
	aRotina   := aClone(_aRotBkp)
	for _p    := 1 to len(_aPergBkp)
		&(_aPergBkp[_p][01]) := _aPergBkp[_p][02]
	next
return
/*/{Protheus.doc} FICHFINAN
@description Execblock utilizado para montar a ficha financeira do cliente.
@author Júlio Soares
@since 17/10/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function FICHFINAN()
	Local   _aRotBkp   := aClone(aRotina)
	Local   _aPergBkp  := {}
	Local   _cCadBkp   := cCadastro
	Local   _cFNBkp    := FunName()
	Local   _cPvBkp    := (_cTbTmp1)->C9_PEDIDO

	local   _p         := 1

	Private _nSqPerg   := 1

	//CarregaAmbiente(_aTabs)
	while &(_bPAR) <> "U"
		AADD(_aPergBkp,{("MV_PAR"+StrZero(_nSqPerg,2)),&("MV_PAR"+StrZero(_nSqPerg,2))})
		_nSqPerg++
	enddo
	if ExistBlock("RFINE011")
		Public _cClir   := SC5->C5_CLIENTE
		Public _cLojr   := SC5->C5_LOJACLI
		Public _cNomr   := SC5->C5_NOMCLI
		Public _cCGCr   := SC5->C5_CGCCENT
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		if SC5->(MsSeek(xFilial("SC5") + (_cTbTmp1)->C9_PEDIDO,.T.,.F.)) .AND. !SC5->C5_TIPO $ "/D/B/"
			_cClir   := SC5->C5_CLIENTE
			_cLojr   := SC5->C5_LOJACLI
			_cNomr   := SC5->C5_NOMCLI
			_cCGCr   := SC5->C5_CGCCENT
			SetFunName("MATA450")
			dbSelectArea("SC9")
			_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + (_cTbTmp1)->C9_PEDIDO + "' .AND. AllTrim(C9_NFISCAL) == '' "
			SC9->(dbClearFilter())
			SC9->(dbSetFilter( { || &(_cFilSC9) }, _cFilSC9 ))
			SC9->(dbGoTop())
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			if SA1->(MsSeek(xFilial("SA1")+_cClir+_cLojr,.T.,.F.))
				ExecBlock("RFINE011")
			else
				MSGBOX('CLIENTE "'+_cClir+_cLojr+'" NÃO ENCONTRADO!',_cRotina + '_010','ALERT')
			endif
		endif
	else
		MSGBOX('FUNÇÃO "RFINE011" NÃO ENCONTRADA. INFORME O ADMINISTRADOR DO SISTEMA!',_cRotina + '_009','ALERT')
	endif
	dbSelectArea("SC9")
	SC9->(dbClearFilter())
	MontaArq(_cPvBkp)
	SetFunName(_cFNBkp)
	cCadastro := _cCadbkp
	aRotina   := aClone(_aRotBkp)
	for _p    := 1 To Len(_aPergBkp)
		&(_aPergBkp[_p][01]) := _aPergBkp[_p][02]
	next

	if type("_oBrw26")=="O"
		_oBrw26:Refresh()
	endif
return
/*/{Protheus.doc} VincPVRA
@description Utilizado para chamar a rotina de vínculo entre o pedido de vendas e os títulos do tipo "RA" porventura existentes.
@author Júlio Soares
@since 17/10/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function VincPVRA()
	Local   _aRotBkp   := aClone(aRotina)
	Local   _aPergBkp  := {}
	Local   _cCadBkp   := cCadastro
	Local   _cFNBkp    := FunName()
	Local   _cPvBkp    := (_cTbTmp1)->C9_PEDIDO

	local   _p         := 1

	Private _nSqPerg   := 1

	//CarregaAmbiente(_aTabs)
	while &(_bPAR) <> "U"
		AADD(_aPergBkp,{("MV_PAR"+StrZero(_nSqPerg,2)),&("MV_PAR"+StrZero(_nSqPerg,2))})
		_nSqPerg++
	enddo
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	if SC5->(MsSeek(xFilial("SC5") + (_cTbTmp1)->C9_PEDIDO,.T.,.F.))
		SetFunName("MATA450")
		dbSelectArea("SC9")
		_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + (_cTbTmp1)->C9_PEDIDO + "' .AND. AllTrim(C9_NFISCAL) == '' "
		SC9->(dbClearFilter())
		SC9->(dbSetFilter( { || &(_cFilSC9) }, _cFilSC9 ))
		SC9->(dbGoTop())
		if !SC5->C5_TIPO $ "/D/B/"
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			if SA1->(MsSeek(xFilial("SA1")+SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
				U_RFINE021(.T.)
			else
				MSGBOX('CLIENTE "'+SC5->C5_CLIENTE + SC5->C5_LOJACLI+'" NÃO ENCONTRADO!',_cRotina + '_014','ALERT')
			endif
		else
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			if SA2->(MsSeek(xFilial("SA2")+SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
				U_RFINE021(.T.)
			else
				MSGBOX('FORNECEDOR "'+SC5->C5_CLIENTE + SC5->C5_LOJACLI+'" NÃO ENCONTRADO!',_cRotina + '_015','ALERT')
			endif
		endif
	endif
	dbSelectArea("SC9")
	SC9->(dbClearFilter())
	MontaArq(_cPvBkp)
	SetFunName(_cFNBkp)
	cCadastro := _cCadbkp
	aRotina   := aClone(_aRotBkp)
	for _p    := 1 To Len(_aPergBkp)
		&(_aPergBkp[_p][01]) := _aPergBkp[_p][02]
	next
return
/*/{Protheus.doc} VincConh
@description Utilizado para chamar a rotina de vínculo entre o pedido de vendas e os títulos do tipo "RA" porventura existentes.
@author Júlio Soares
@since 17/10/2013
@version 1.0
@type function
@see https://allss.com.br
/*/
static function VincConh()
	Local   _aRotBkp   := aClone(aRotina)
	Local   _aPergBkp  := {}
	Local   _cCadBkp   := cCadastro
	Local   _cFNBkp    := FunName()
	Local   _cPvBkp    := (_cTbTmp1)->C9_PEDIDO

	Local   _p         := 1

	Private _nSqPerg   := 1

	//CarregaAmbiente(_aTabs)
	while &(_bPAR) <> "U"
		AADD(_aPergBkp,{("MV_PAR"+StrZero(_nSqPerg,2)),&("MV_PAR"+StrZero(_nSqPerg,2))})
		_nSqPerg++
	enddo
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	if SC5->(MsSeek(xFilial("SC5") + (_cTbTmp1)->C9_PEDIDO,.T.,.F.))
		SetFunName("MATA450")
		dbSelectArea("SC9")
		_cFilSC9 := " C9_FILIAL == '" + xFilial("SC9") +"' .AND. C9_PEDIDO == '" + (_cTbTmp1)->C9_PEDIDO + "' .AND. AllTrim(C9_NFISCAL) == '' "
		SC9->(dbClearFilter())
		SC9->(dbSetFilter( { || &(_cFilSC9) }, _cFilSC9 ))
		SC9->(dbGoTop())
		if !SC5->C5_TIPO $ "/D/B/"
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			if SA1->(MsSeek(xFilial("SA1")+SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
				U_RFINE030()
			else
				MSGBOX('CLIENTE "'+SC5->C5_CLIENTE + SC5->C5_LOJACLI+'" NÃO ENCONTRADO!',_cRotina + '_016','ALERT')
			endif
		else
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			if SA2->(MsSeek(xFilial("SA2")+SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
				U_RFINE030()
			else
				MSGBOX('FORNECEDOR "'+SC5->C5_CLIENTE + SC5->C5_LOJACLIC5_LOJACLI+'" NÃO ENCONTRADO!',_cRotina + '_017','ALERT')
			endif
		endif
	endif
	dbSelectArea("SC9")
	SC9->(dbClearFilter())
	MontaArq(_cPvBkp)
	SetFunName(_cFNBkp)
	cCadastro := _cCadbkp
	aRotina   := aClone(_aRotBkp)
	for _p    := 1 To Len(_aPergBkp)
		&(_aPergBkp[_p][01]) := _aPergBkp[_p][02]
	next
return
/*/{Protheus.doc} CarregaAmbiente
@description Carrega ambiente do registro posicionado.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 24/02/2017
@version 1.0
@param _aTabs, Array com as tabelas utilizadas no browse (exemplo: _aTabs := {"TRBTMP","SC9","SC5","SA1","SA2","SE4"})
@param _cId, , Indica por qual tecla de atalho a função foi chamada
@type function
@see https://allss.com.br
/*/
static function CarregaAmbiente(_aTabs,_cId)
	local   _dx     := 0

	default _aTabs  := {}
	default _cId    := ""

	&("_aKey"+_cId) := {}
	if Select(Alias())>0
		AADD(&("_aKey"+_cId), {Alias() ,(Alias())->(IndexOrd()),&(Alias()+"->("+(Alias())->(IndexKey())+")")})
	endif
	for _dx := 1 to len(_aTabs)
		if Select(_aTabs[_dx])>0
			AADD(&("_aKey"+_cId), {_aTabs[_dx], (_aTabs[_dx])->(IndexOrd())   ,&(_aTabs[_dx]+"->("+(_aTabs[_dx])->(IndexKey())+")")})
		endif
	next
return
/*/{Protheus.doc} AtuDados
@description Atualiza a tela conforme o Registro posicionado.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 24/02/2017
@version 1.0
@param _cId, , Indica por qual tecla de atalho a função foi chamada
@type function
@see https://allss.com.br
/*/
static function AtuDados(_cId)
Local _d := 0

default _cId := ""	
If _cRotina == "RFATA026"
	for _d := Len(&("_aKey"+_cId)) to 1 step -1
		if &("_aKey"+_cId)[_d] <> NIL .AND. Select(&("_aKey"+_cId)[_d][01]) > 0
			dbSelectArea(&("_aKey"+_cId)[_d][01])
			(&("_aKey"+_cId)[_d][01])->(dbSetOrder(&("_aKey"+_cId)[_d][02]))
			Set SoftSeek ON
				(&("_aKey"+_cId)[_d][01])->(dbSeek((&("_aKey"+_cId)[_d][03])))
			Set SoftSeek OFF
		endif
	next
EndIf	
return
/*/{Protheus.doc} CriaBrowse
@description Sub-rotina do programa RFATA026, utilizado para a criação do browse principal da rotina.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 24/02/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
static function CriaBrowse()
	if _lArq
		dbSelectArea(_cTbTmp1)
		(_cTbTmp1)->(dbGoTop())
		_oBrw26   := FwMBrowse():New(cCadastro)
		//descrição do browse
		_oBrw26:SetDescription(cCadastro)
		//tabela temporaria
		_oBrw26:SetAlias(_cTbTmp1)
		//seta as colunas para o browse
		_oBrw26:SetFields(aColunas)
		//define as legendas
		_oBrw26:AddLegend( "C5_NPRIORI=='1' .AND. (C9_STATUS=='99' .Or. C9_STATUS=='02')"	,'BR_BRANCO' , 'Alta prioridade'          )
		_oBrw26:AddLegend( "C9_STATUS=='99'"												,'ENABLE'    , 'Item Liberado'            )
		_oBrw26:AddLegend( "C9_STATUS=='10'"												,'DISABLE'   , 'Item Faturado'            )
		_oBrw26:AddLegend( "C9_STATUS=='01'"												,'BR_AZUL'   , 'Item Bloqueado - Credito' )
		_oBrw26:AddLegend( "C9_STATUS=='02'"												,'BR_PRETO'  , 'Item Bloqueado - Estoque' )
		_oBrw26:AddLegend( "C9_STATUS=='05'"												,'BR_AMARELO', 'Item Bloqueado - WMS'     )
		_oBrw26:AddLegend( "C9_STATUS=='06'"												,'BR_LARANJA', 'Item Bloqueado - TMS'     )
		_oBrw26:SetWalkThru(.F.)
		_oBrw26:SetUseFilter(.T.)
		_oBrw26:SetUseCaseFilter(.T.)
		_oBrw26:OptionReport(.T.)
		_oBrw26:SetSeek(.T., _aSeek)
		_oBrw26:Activate()
		if Select(_cTbTmp1) > 0
			dbSelectArea(_cTbTmp1)
			(_cTbTmp1)->(dbCloseArea())
		endif
		_lArq := .F.
	endif
return
