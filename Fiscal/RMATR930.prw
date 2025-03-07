//#INCLUDE "Matr930.ch"                
#INCLUDE "FIVEWIN.CH"
STATIC aColunas // Utilizada na Funcao ColF3
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � RMATR930  � Autor � Juan Jose Pereira     � Data � 18.12.96   ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Imprime Registro de Entadas P1 P1A e Saidas P2 P2A           ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
��� Marcos Simidu�14/09/98�09795A� Considerar data de emissao na impressao  ���
���              �14/09/98�09795A� de NF entrada no livro de saida.         ���
��� Marcos Simidu�23/09/98�XXXXXX� Acertos NF form prop nos livros de saida.���
��� Marcos Simidu�11/11/98�XXXXXX� Impressao dos parametros de data nos     ���
���              �11/11/98�XXXXXX� termos de abertura/encerramento.         ���
��� Andreia      �27/01/99�18598A� Tratamento do no. de registros impressos ���
���              �        �      � quando for nota de servico.              ���
��� Andreia      �11/03/99�xxxxxx�Tratamento da especie das notas fiscais   ���
���              �        �      �canceladas atraves do parametro MV_ESPECIE���
��� Andreia      �15/06/99�xxxxxx�Acertos Protheus.                         ���
��� Andreia      �09/08/99�22553A� Criacao de pergunta para escolher se o im���
���              �        �      � posto retido sera impresso na coluna "OB-���
���              �        �      � SERVACAO" ou na coluna "Tributado"       ���
���              �        �      � (mv_par21).              			    ���
��� Andreia      �04/10/99�23914A� Funcao EXISTNF() - Acerto na verificacao ���
���              �        �      � de notas fiscais canceladas.             ���
��� Andreia      �08/10/99�xxxxxx� Tratamento da variavel nColuna na funcao ���
���              �        �      � LivrArrayObs, quando e emitido o relato- ���
���              �        �      � rio MATR920.                             ���
��� Edilaine     �01/06/00�003880� Tratamento de variavel CTIPO. Funcao     ���
���              �        �      � LivrAcumula()                            ���
��� Andre Veiga  �05/05/01�008831� Escrituracao do Mapa Resumo ECF (Portaria���
���              �        �      � CAT 55/98, Conv.ICMS 50/00)              ���
��� Denis Martins�20/09/01�Melhor� Tratamento de Filiais(Exc/Comp.)-F3_MSFIL���
��� Machima      �09/06/06�100780� Implementacao do decreto 22.928/02 art.1 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User FUNCTION RMATR930()

//������������������Ŀ
//� Define Variaveis �
//��������������������
wnRel	  :="RMATR930"
Titulo    :="Regime de Processamento de Dados"
cDesc1    :="Emiss�o dos Registros de Entradas modelos P1 e P1A e Registros de Saidas"
cDesc2    :="modelos P2 e P2A."
cDesc3    :="Ir� imprimir os lan�amentos fiscais conforme os par�metros informados."
aReturn   :={ "Zebrado", 1,"Administra��o", 2, 2, 1, "",1 }
nomeprog  :="RMATR930"
cPerg	  :="MTR930"
cString	  :="SF3"
nPagina	  :=0
nLin	  :=3
nLargMax  :=220
Tamanho	  :="G"
cArqTemp  :=""
dbSelectArea("SF3")
dbSetOrder(1)
aSvArea	  :={Alias(),IndexOrd(),Recno()}
nPosObs	  :=0
aOrd	  :={"Data de Entrada+S�rie+N�mero da NFE","Data de Entrada+N�mero da NFE+S�rie"}
//���������������������������������������Ŀ
//� Variaveis utilizadas no cabecalho     �
//�����������������������������������������
aMeses	  :={"JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"} 
cNome 	  :=SM0->M0_NOMECOM
cInscr	  :=InscrEst()
//�������������������������������������������������������������������������������������������Ŀ
//�Verifica se o campo "CGC" nao esta sendo utilizado para armazenar outro tipo de informacao.�
//���������������������������������������������������������������������������������������������
If SM0->M0_TPINSC == 2 .Or. SM0->M0_TPINSC == 0
	cCGC  :=TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")
Else
	cCGC  :=""	
Endif
//���������������������������������������Ŀ
//� Inicializa grupo de perguntas.        �
//�����������������������������������������
//AjustaSX1()
Pergunte(cPerg,.F.)
//���������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT �
//�����������������������������������������
nLastKey  :=0
wnrel	  :=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)
If nLastKey==27
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey==27
	dbClearFilter()
	Return
Endif

//��������������������������������������������������������������Ŀ
//� Executa relatorio                                            �
//����������������������������������������������������������������
RptStatus({|lEnd| R930Imp(@lEnd,wnRel,cString,Tamanho)},titulo)

If aReturn[5]==1
	Set Printer To
	ourspool(wnrel)
Endif
MS_FLUSH()

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R930Imp  � Autor � Juan Jose Pereira     � Data � 18.12.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Relatorio                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION R930Imp(lEnd,wnRel,cString,Tamanho)

LOCAL 	lMatr931:=(existblock("RMATR931"))
LOCAL 	lMatr932:=(existblock("RMATR932"))
Local	cIndxSF3	:=""
Local	cChave		:=""
Local	aRegSF3     :={}
Local	cIndxSF3b	:=""
Private cArqSF3		:=""
PRIVATE lAbortPrint:=.F.
Private lnfinutil     := .T.
//��������������������������������������������������������������Ŀ
//� Parametros utilizados pelo Programa                          �
//� mv_par01 - A partir da Data                                  �
//� mv_par02 - Ate a Data                                        �
//� mv_par03 - Imprime Modelo                                    �
//� mv_par04 - Imprime  (1) Livros (2) Termos (3) Livros e Termos�
//� mv_par05 - Numero do Livro                                   �
//� mv_par06 - Numero da Pagina Inicial                          �
//� mv_par07 - Qtd. Paginas do Feixe                             �
//� mv_par08 - Reinicia Paginas                                  �
//� mv_par09 - Considera lacuna                                  �
//� mv_par10 - Apuracao de ICMS                                  �
//� mv_par11 - Apuracao de IPI                                   �
//� mv_par12 - Livro Selecionado                                 �
//� mv_par13 - Destaca NFs. de Servicos                          �
//� mv_par14 - Destaca descontos                                 �
//� mv_par15 - Imprime Linhas sem valor                          �
//� mv_par16 - Imprime Total Mensal                              �
//� mv_par17 - Imprime NF. de Entrada                            �
//� mv_par18 - Aglutina NF                                       �
//� mv_par19 - Totaliza por dia - Sim X Nao                      �
//� mv_par20 - Estado Origem no Resumo - Sim X Nao               �  
//� mv_par21 -	Imp. Retido Coluna: ?							 �
//� mv_par22 -	Imp. Oper. Isentas ?							 �
//� mv_par23 -	Considera CIAP ?								 �
//� mv_par24 -	Valor CIAP na Coluna ?							 �
//� mv_par25 -	Totaliza Res.Estado ?							 �
//� mv_par26 -	Totaliza Icm/Ipi/B.Calc. IPI ?					 �
//� mv_par27 -	Totaliza ICMS Entr. ?							 �
//� mv_par28 -	Lista NF origem ?								 �
//� mv_par29 -	Resumo Produtor ?								 �
//� mv_par30 -	Cupom Fiscal ?									 �
//� mv_par31 -	Processa Filiais ?								 �
//� mv_par32 -	Filial de ?								 		 �
//� mv_par33 -	Filial ate ?								 	 �
//� mv_par34 -	Consolida��o na mesma UF ?						 �
//� mv_par35 -	Taxa UFIR ?								 		 �
//� mv_par36 -	Opera��es a imprimir?							 �
//� mv_par37 -	Imprime Mapa Resumo ?							 �
//� mv_par38 -	Imprime Imposto Res/Comp?						 �
//� mv_par39 -	Artigo para Impress�o ?							 �
//� mv_par40 -	Seleciona Filiais ?								 �
//� mv_par41 -	S�rie no Termo ?								 �
//� mv_par42 -	S�rie/SubS�rie ?								 �
//� mv_par43 -	Impr. ICMS/IPI Zerado ?							 �
//����������������������������������������������������������������
PRIVATE dDtIni		:= mv_par01
PRIVATE dDtFim		:= mv_par02
PRIVATE cMV_ESTADO  := GetMv("MV_ESTADO")
PRIVATE nModelo  	:= mv_par03
PRIVATE nImpTerm 	:= mv_par04
PRIVATE cLivro		:= mv_par05
PRIVATE nPagIni     := mv_par06
PRIVATE nPagAnt	    := IIf(nImpTerm<>2,mv_par06,1)
PRIVATE nQtFeixe	:= mv_par07
PRIVATE lReiniPg	:= (mv_par08==1)
PRIVATE lLacuna 	:= (mv_par09==1 .Or. mv_par09==3)
PRIVATE nApurICM	:= mv_par10
PRIVATE nApurIPI	:= mv_par11
PRIVATE cNrLivro	:= mv_par12
PRIVATE lServico	:= (mv_par13==1)
PRIVATE lDesconto	:= (mv_par14==1)
PRIVATE lImpZer		:= (mv_par15==1)
PRIVATE lImpMes   	:= (mv_par16==1)
PRIVATE lEntrada	:= (mv_par17==1)
PRIVATE lAglutina	:= (mv_par18==1)
PRIVATE lTotalDia	:= (mv_par19==1)
PRIVATE lLisEstOri 	:= (mv_par20==1)
PRIVATE nPagina		:= IIf(nPagIni>0,nPagIni-1,1)
PRIVATE cFilterUser := aReturn[7]
PRIVATE nTipoMov	:= If(nModelo==1.or.nModelo==2.or.(nmodelo==5 .And. AllTrim(cMV_ESTADO) == "SP"),1,2)
PRIVATE nColuna 	:= mv_par21
PRIVATE lLisIsenta  := (mv_par22==1)
PRIVATE lEmiteCiap  := (mv_par23==1)
PRIVATE lColCiap    := (mv_par24==1)
PRIVATE lListaNFO   := (mv_par28==1)
PRIVATE lProdutor	:= (mv_par29==1)
PRIVATE lLeiECF		:= (mv_par30==1)
PRIVATE lConsUF		:= (mv_par34==1)
PRIVATE nLegisArt	:= mv_par39
PRIVATE lIcmIpZer	:= (mv_par43==1)

//�������������������Ŀ
//� Recebe parametros �
//���������������������
PRIVATE lCat21		 :=SuperGetMv("MV_CAT21",.F.)
PRIVATE cContaContab :=NIL
//���������������������������Ŀ
//� Limite da pagina em linhas�
//�����������������������������
PRIVATE nLin	     :=80
PRIVATE	nLimPag	     :=58
PRIVATE	nLinNec	     :=0

PRIVATE lMatr930A	:= (ExistBlock("MATR930A"))

nQtFeixe	:=IIf(nQtFeixe>3,nQtFeixe,500)

If nPagAnt==0
	nPagina:=0
Endif

If nTipoMov==1
	cContaContab:=Alltrim(GetMV("MV_CTALFE"))
	// Retira ref. ao Alias SF3 //
	cContaContab	:=	StrTran(cContaContab,"SF3->",)
Else
	cContaContab:=Alltrim(GetMV("MV_CTALFS"))
	// Retira ref. ao Alias SF3 //
	cContaContab	:=	StrTran(cContaContab,"SF3->",)
EndIf

//���������������������������������������������Ŀ
//� Armazena maior tamanho das notas (em linhas)�
//� [1]=Maior Nota da Pagina                    �
//� [2]=Maior Totalizacao de Transporte         �
//� [3]=Maior Totalizacao do Dia                �
//� [4]=Maior Totalizacao de Periodo ICM        �
//� [5]=Maior Totalizacao de Periodo IPI        �
//�����������������������������������������������
PRIVATE nTamNota	:=0
PRIVATE nTamTransp	:=0
PRIVATE nTamPerICM	:=0
PRIVATE nTamPerIPI	:=0 
PRIVATE aTamNotas	:={0,0,0,0,0}
//�������������������������������������������������Ŀ
//� Especifico para os legislacao Fomentar de Goias �
//���������������������������������������������������
PRIVATE cTitLivro :=AvalFomentar()
cTitLivro         :=If(Empty(cTitLivro)," ",cTitLivro)
//����������������������Ŀ
//� Define Totalizadores �
//������������������������
PRIVATE aTotDia 	:=	NIL	// Totalizador diario 
PRIVATE aTotPerICM  :=	NIL	// Totalizador de periodos de apuracao de ICMS
PRIVATE aTotPerIPI  :=	NIL	// Totalizador de periodos de apuracao de IPI
PRIVATE aTransp	    :=	NIL	// Totalizador de transporte de pagina
PRIVATE aTotMes	    :=	NIL	// Totalizador Mensal
PRIVATE aResumo	    :=	NIL	// Totalizador para resumo final
PRIVATE aResCFO	    :=	NIL	// Totalizador para resumo por CFO
PRIVATE nTotIcmDeb  :=  0  // Totalizador de ICMS NORMAL+ICMS ST 
PRIVATE npag 	    :=  1   // Controla impressao manual do cabecalho 

//����������������������������������������������������������������������������Ŀ
//� Cria Arquivo Temporario para Controle de Contribuintes e Nao Contribuintes �
//������������������������������������������������������������������������������
/*
AADD(aRegSF3,{"CHAVE"	,"C",100,0})
AADD(aRegSF3,{"CONTR"	,"C",01,0})
AADD(aRegSF3,{"FILIAL"	,"C",02,0})
AADD(aRegSF3,{"MES"		,"C",02,0})
AADD(aRegSF3,{"ANO"		,"C",04,0})
cArqSF3  :=CriaTrab(aRegSF3)
dbUseArea(.T.,,cArqSF3,cArqSF3,.T.,.F.)
cIndxSF3 :=Substr(CriaTrab(NIL,.F.),1,7)+"A"
cChave:="CONTR+CHAVE"
IndRegua(cArqSF3,cIndxSF3,cChave,,,"Criando Controles") 
dbClearIndex()
cIndxSF3b := CriaTrab(Nil,.F.)
IndRegua(cArqSF3,cIndxSF3b,"CONTR+MES+ANO")
dbClearIndex()
dbSetIndex(cIndxSF3+OrdBagExt())
dbSetIndex(cIndxSF3b+OrdBagExt())
*/

//-------------------
//Criacao do objeto
//-------------------
cArqSF3    := GetNextAlias()
oTempTable := FWTemporaryTable():New( cArqSF3 )

//--------------------------
//Monta os campos da tabela
//--------------------------
AADD(aRegSF3,{"CHAVE"	,"C",100,0})
AADD(aRegSF3,{"CONTR"	,"C",01,0})
AADD(aRegSF3,{"FILIAL"	,"C",02,0})
AADD(aRegSF3,{"MES"		,"C",02,0})
AADD(aRegSF3,{"ANO"		,"C",04,0})

oTemptable:SetFields( aRegSF3 )
oTempTable:AddIndex("indice1", {"CONTR", "CHAVE" })

//------------------
//Criacao da tabela
//------------------
oTempTable:Create()


If GetMv("MV_IMPSX1") == "S"
	ImpParSX1("Imprime pagina de parametros" ,"RMATR930",Tamanho,,.T.)
EndIf

If nModelo==1 .or. nModelo==3 .or. nModelo==5
	If lMatr931
		ExecBlock("RMATR931",.F.,.F.)
	Else
		Matr931()
	Endif
Else
	If lMatr932
		ExecBlock("RMATR932",.F.,.F.)
	Else
		Matr932()
	Endif
Endif

//������������������������������������������������������������������������������������Ŀ
//� Verifica a opcao de impressao de Imposto a ser Ressarcido ou Complementado (CAT17) �
//��������������������������������������������������������������������������������������
VerificaR461()

Return
//��������������������������������������������������������������Ŀ
//�                                                              �
//�           FUNCOES GENERICAS DOS LIVROS FISCAIS               �
//�                                                              �
//����������������������������������������������������������������
/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o    �EmiteLivro� Autor � Juan Jose Pereira             � Data � 13/12/96 ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o �Gera arquivo temporario com lancamentos do SF3 que deverao ser      ���
���          �ser lancados nos registros de entradas e saidas                     ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe   �cArqTemp:=EmiteLivro(cMov,cDtIni,dDtFim,lLacuna,lServico,cNrLivro,  ���
���          �          cFiltroUser)                                              ���
���������������������������������������������������������������������������������Ĵ��
���parametros�cArqTemp:=Alias/Nome do Arquivo gerado                              ���
���          �cMov:="E"ntradas / "S"aidas                                         ���
���          �dDtIni:=Data de Inicio dos Lancamentos                              ���
���          �dDtFim:=Data de Fim dos Lancamentos                                 ���
���          �lLacuna:=Lanca notas canceladas/nao lancadas/excluidas              ���
���          �lServico:=Lanca notas de Servico                                    ���
���          �cNrLivro:=Numero do Livro lancado , (*) Todos - FOMENTAR            ���
���          �cFiltroUser:=Filtro criado pelo usuario para o SF3                  ���
���          �cArqCiap:=Arquivo Ciap                                              ���
���������������������������������������������������������������������������������Ĵ��
��� Uso      �Generico                                                            ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Static Function EmiteLivro(	cMov	,	dDtIni	,	dDtFim	,	lLacuna	,	;
						lServico,lDesconto	,cNrLivro	,cFilterUser,	;
						cArqCiap,nTotIcmsEnt,nLacuna	,nProcFil	,	;
						cFilDe	,cFilAte	,nSubDiv	,cChamOrig, MVIsento	)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local aCampos     	:=	{}
Local aLivro      	:=	{}
Local aFixos      	:=	MatXAfixos()
Local aSeries     	:=	{}
Local aStruSf3		:=	{}
Local aArea			:= 	{}
Local aAreaSM0	 	:= 	SM0->(GetArea())
Local aProcessa		:= 	{}
Local aFilsCalc  	:= 	{}
Local aMapaResumo	:= 	{}							   		// Informacoes do Mapa Resumo
Local aGravaMapRes	:= 	{}							   		// Registros a serem informados no Mapa Resumo
Local aCposTemp		:=	{}							   		// Campos temporarios
Local aSd1			:=	{}
Local aProdutor	  	:= 	{}

Local cCliente    	:=	""
Local cLoja       	:=	""
Local cFiltro     	:=	""
Local cChave	  	:=	""
Local cArqIndxF3  	:=	""
Local cIndxTemp1  	:=	""
Local cIndxTemp2  	:=	""
Local cLivros     	:=	""
Local cLivrEP     	:=	GetMV("MV_LIVRESP")
Local cNFIni      	:=	""
Local cNFFim      	:=	""
Local cEst        	:=	""
Local cEsp        	:=	""
Local cSer		  	:=	""	
Local cCFO        	:=	""
Local cFormula	  	:=	""
Local cCampos		:=	""
Local cAliasSf3		:=	"SF3"
Local cFilProc		:= 	""
Local cFormla       := 	""
Local cSerNf        :=  ""                              	// Serie da Nota Fiscal sobre Cupom
Local cNfCup        :=  ""                              	// Numero da Nota Fiscal sobre Cupom
Local cNumNota		:= 	""
Local cTipoEsp      :=  ""                              	// Especie do registro na SF3
Local cTipoSF2      :=  ""                              	// Especie do registro na SF2
Local cChaveSD1 	:=	""
Local cObserv		:=	""

Local i           	:=	0
Local j           	:=	0
Local nPos        	:=	0
Local nI          	:=	0
Local nx          	:=	0
Local nReg        	:=	0
Local nAliq       	:=	0
Local nMesIni		:= 	0
Local nAnoIni		:= 	0
Local nMesFim		:= 	0
Local nAnoFim		:= 	0       
Local nPosi			:= 	0
Local nMesAux		:= 	0
Local nLenForm      := 	0
Local nSf3			:=	0
Local nF3FCount		:=	0
Local nProc			:= 	0
Local nPosFil		:= 	0
Local nTamNF		:= 	0   
Local nTamSerie		:= 	TamSx3("F2_SERIE")[1]            	// Tamanho da serie da Nota Fiscal sobre Cupom

Local lCanc       	:=	.F.
Local lExist      	:=	.F.
Local lMapResumo	:= 	.F.								   	// Se trabalha com Mapa Resumo
Local lFisLivro		:= 	.F.							   		// Conteudo do parametro MV_LJLVFIS
Local lImpEcf 		:= 	.T.									// Se trabalha com lei ECF

Local dDtCanc     	:=	""
Local dDtCan1     	:=	""
Local _cAliasSX3 := "SX3_"+GetNextAlias()
//
Private cArqTemp  	:=	""
//
Default nLacuna		:=	2
Default	nTotIcmsEnt	:=	2
Default nProcFil	:=  2       
Default cFilDe		:= 	cFilAnt
Default cFilAte		:= 	cFilAnt
Default cChamOrig	:= 	""
Default nSubDiv		:= 	1
Default MVIsento	:= 	2

If Type("lLisIsenta") == "U" .And. MVIsento <> 1
	lLisIsenta := .F.
Else
	lLisIsenta := .T.
Endif

lExist      :=	IIF(SF3->F3_OBSSOL>0,.T.,.F.)
aStruSf3	:=	SF3->(DbStruct ())
nF3FCount	:=	SF3->(FCount ())        

If SuperGetMV("MV_LJLVFIS",,1) == 2
	If FindFunction("MaxRVerFunc")
		If MaxRVerFunc(cChamOrig)
			lFisLivro	:= .T.
		EndIf
    EndIf
EndIf

If lFisLivro
	If Alltrim(cChamOrig) == "RMATR930"
		lMapResumo	:= IIF(mv_par37 == 1,.T.,.F.)
	ElseIf Alltrim(cChamOrig) == "MATR921"
		lMapResumo	:= IIF(mv_par14 == 1,.T.,.F.)		
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Cria Arquivo CIAP Temporario                                 �
//����������������������������������������������������������������
If lEmiteCiap
	dbSelectArea("SF9")
   If ( cArqCiap != NIL ) .And. Select("SF9") > 0
		/*
		cArqCiap := CriaTrab({{"SF3","N",14,0},{"SF9","N",14,0}})
		dbUseArea(.T.,,cArqCiap,"CIAP",.T.,.F.)
		IndRegua("CIAP",cArqCiap,"SF3")
		*/
		//-------------------
		//Criacao do objeto
		//-------------------
		cArqCiap   := GetNextAlias()
		oTmpTab2 := FWTemporaryTable():New( cArqCiap )
		
		oTmpTab2:SetFields( {{"SF3","N",14,0},{"SF9","N",14,0}} )
		oTmpTab2:AddIndex("indice1", {"SF3"} )
		//------------------
		//Criacao da tabela
		//------------------
		oTmpTab2:Create()	  
   EndIf
Endif
//��������������������������������������������������������������Ŀ
//� Cria Arquivo Temporario                                      �
//����������������������������������������������������������������

_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX1",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(1))
While (_cAliasSX3)->X3_ARQUIVO==cAliasSf3 .and.(_cAliasSX3)->(!Eof())
	AADD(aCampos,{(_cAliasSX3)->X3_CAMPO,(_cAliasSX3)->X3_TIPO,(_cAliasSX3)->X3_TAMANHO,(_cAliasSX3)->X3_DECIMAL})
	dbSkip()
EndDo

//��������������������������������������������������������������Ŀ
//� Campo auxiliar para corrigir numeracao nas lacunas           �
//����������������������������������������������������������������
AADD(aCampos,{"NUMNOTA","C",TamSX3("F2_DOC")[1],0})
AADD(aCampos,{"FILCORR","C",FWSizeFilial(),0})

//��������������������������������������Ŀ
//�Para inserir os periodos sem movimento�
//����������������������������������������
AADD(aCampos,{"SEMMOV" ,"L",1,0})
/*
cArqTemp:=CriaTrab(aCampos)
dbUseArea(.T.,,cArqTemp,cArqTemp,.T.,.F.)

If cMov == "S"
	cIndxTemp1:=Substr(CriaTrab(NIL,.F.),1,7)+"A"
	cIndxTemp2:=Substr(CriaTrab(NIL,.F.),1,7)+"B"
	cIndxTemp3:=Substr(CriaTrab(NIL,.F.),1,7)+"C"
	cChave:="F3_FILIAL+F3_SERIE+NUMNOTA+STR(F3_ALIQICM,5,2)+F3_CFO+F3_FORMULA"
	IndRegua(cArqTemp,cIndxTemp1,cChave,,,"Buscando Nts.Canceladas...")
	cChave:="F3_SERIE+F3_TIPO+F3_DOCOR+F3_FILIAL"
	IndRegua(cArqTemp,cIndxTemp2,cChave,,,"Buscando Nts.Canceladas...")
	cChave:="F3_SERIE+NUMNOTA+F3_FILIAL"
	IndRegua(cArqTemp,cIndxTemp3,cChave,,,"Buscando Nts.Canceladas...")
	dbClearIndex()
	DbSetIndex(cIndxTemp1+OrdBagExt())
	DbSetIndex(cIndxTemp2+OrdBagExt())
	DbSetIndex(cIndxTemp3+OrdBagExt())	
	dbSetOrder(1)
EndIf	                              

*/
//-------------------
//Criacao do objeto
//-------------------
cArqTemp := GetNextAlias()
oTempTable := FWTemporaryTable():New( cArqTemp )

oTemptable:SetFields( aCampos )
If cMov == "S"
	oTempTable:AddIndex("indice1", {"F3_FILIAL","F3_SERIE","NUMNOTA","STR(F3_ALIQICM,5,2)","F3_CFO","F3_FORMULA"} )
	oTempTable:AddIndex("indice2", {"F3_SERIE","F3_TIPO","F3_DOCOR","F3_FILIAL"} )
	oTempTable:AddIndex("indice3", {"F3_SERIE","NUMNOTA","F3_FILIAL"} )
endif
//------------------
//Criacao da tabela
//------------------
oTempTable:Create()

//�������������������������������������������������������������������������Ŀ
//�Verifica se o processamento e centralizado, imprimindo mais de uma filial�
//���������������������������������������������������������������������������
If nProcFil <> 1
	cFilDe 	:= cFilAnt
	cFilAte	:= cFilAnt
Elseif If(AllTrim(FunName())=='MATR921',.f., Mv_Par40 == 1) //Selecina Filiais
	//Alterado para passar por todas a Filiais uma vez que 
	//ser� tratado dentro do processamento somente as filiais
	//Selecionadas
	aFilsCalc	:= MatFilCalc( nProcFil == 1 )
	cFilDe 	:=  padr("", FWSizeFilial())
	cFilAte	:=  Replicate("Z",FWSizeFilial())
Endif      

SM0->(dbSeek(cEmpAnt+cFilDe,.T.))

// Sera verificada a configuracao do parametro para cada uma das filiais
cLivrEP := GetMV("MV_LIVRESP")

_uLeiRcf   := Type("lLeiEcf")
_uLegisArt := Type("nLegisArt")

//�������������������������������������������������������������Ŀ
//�Imprime atraves das filiais selecionadas para o processamento�
//���������������������������������������������������������������
Do While !SM0->(Eof()) .and. FWGrpCompany()+FWCodFil() <= cEmpAnt+cFilAte 
					

	cFilAnt	:= FWCodFil()                              
	//Tratamento de Selecao de Filiais
	If nProcFil == 1 .and. If(AllTrim(FunName())=='MATR921',.f., Mv_Par40 == 1)
		nPosFil := aScan( aFilsCalc, {|x| x[2] == FWCodFil() } )
		If nPosFil == 0 //Nao achei a filial corrente no tratamento de filiais (verificando direitos de acesso
			SM0->( dbSkip() ) 
			Loop
		Else
			If !aFilsCalc[nPosFil,1] //A Filial corrente nao foi selecinada
				SM0->( dbSkip() ) 
				Loop
			EndIf
		EndIf
	EndIf
	//�����������������������������������������������������������������������������������������������������������Ŀ
	//�Atendimento ao Art. 121 do ANEXO 5 do RICMS/SC. O mesmo determina que todo prestador de                    �
	//�  servi�o de transporte deve apresentar as obriga��es acess�rias de forma consolidada pelo estabelecimento �
	//�  matriz, e esta consolida��o dever� abranger somente as empresas que estiverem domiciliadas no mesmo      �
	//�  estado do estabelecimento consolidador.                                                                  �
	//�������������������������������������������������������������������������������������������������������������
	If lConsUF .And. (SM0->M0_ESTENT<>cMV_ESTADO)
		SM0->(DbSkip ())
		Loop
	EndIf
	
	// Sera verificada a configuracao do parametro para cada uma das filiais
	//cLivrEP := GetMV("MV_LIVRESP")

	//��������������������������������������������������������������Ŀ
	//� Prepara SF3 para extracao de dados                           �
	//����������������������������������������������������������������
	cAliasSf3 := "SF3"
	dbSelectArea (cAliasSf3) 	
	//
	#IFDEF TOP
		cAliasSf3	:=	"EmiteLivro"
		cCampos		:=	" * "
		//
		cQuery		:=	"SELECT "
		cQuery		+=	cCampos+" FROM "+RetSqlName ("SF3")+" SF3 WHERE "
		
		If FWModeAccess("SF3",3)=="C" .And. SF3->(FieldPos("F3_MSFIL")) > 0 
			cQuery		+=	"SF3.F3_MSFIL='"+cFilAnt+"' AND "
		Else	
			cQuery		+=	"SF3.F3_FILIAL='"+xFilial ("SF3") + "' AND "
		EndIf
		
		IF (GetNewPar("MV_LFMD2DT",.F.)) .And. cMov == "S"
			cQuery  += "SF3.F3_EMISSAO>='"+DTOS (dDtIni)+"' AND SF3.F3_EMISSAO<='"+DTOS (dDtFim)+"' AND "
		Else
			cQuery  += "SF3.F3_ENTRADA>='"+DTOS (dDtIni)+"' AND SF3.F3_ENTRADA<='"+DTOS (dDtFim)+"' AND "		
		EndIf
		cQuery      += "SF3.D_E_L_E_T_=' ' "
		//
		If (cMov=="E")
			If nSubDiv == 1
				cQuery	+=	" AND SUBSTRING(SF3.F3_CFO,1,1)<'5' "
			ElseIf nSubDiv == 2                                 
				cQuery	+=	" AND SUBSTRING(SF3.F3_CFO,1,1)='1' "
			ElseIf nSubDiv == 3
				cQuery	+=	" AND SUBSTRING(SF3.F3_CFO,1,1) IN ('2','3') "
			Endif
		    //
			If !(lServico)
				cQuery	+=	" AND SF3.F3_TIPO<>'S' "
			Endif
			//
			If (cNrLivro!="*")
				cQuery	+=	" AND SF3.F3_NRLIVRO='"+cNrLivro+"' "
			Else
				//��������������������������������������������������������������Ŀ
				//� Filtra notas de Entrada de Ativo p/ Ceara "MV_LIVRESP"       �
				//����������������������������������������������������������������
				cQuery	+=	" AND SF3.F3_NRLIVRO<>'"+cLivrEP+"' "
			Endif
			//�������������������������������������������������������Ŀ
			//�Desconsidera notas canceladas quando considerar lacuna.�
			//���������������������������������������������������������
			If !(lLacuna)
				cQuery	+=	" AND NOT (SF3.F3_DTCANC<>'' AND SF3.F3_FORMUL='S') "
			Endif
			//�������������������������������������������������������������Ŀ
			//�Desconsidera operacoes isentas - MV_PAR22 - Imp. Op. Isentas �
			//���������������������������������������������������������������   
			If !lLisIsenta
				cQuery  +=  " AND F3_ISENICM <= 0 "
			EndIf
		Else
			If !(lEntrada)
				If nSubDiv == 1
					cQuery	+=	" AND SUBSTRING(SF3.F3_CFO,1,1)>='5' "
				ElseIf nSubDiv == 2                                 
					cQuery	+=	" AND SUBSTRING(SF3.F3_CFO,1,1)='5' "
				ElseIf nSubDiv == 3
					cQuery	+=	" AND SUBSTRING(SF3.F3_CFO,1,1) IN ('6','7') "
				Endif
			Else
				If nSubDiv == 1
					cQuery	+=	" AND (SUBSTRING(SF3.F3_CFO,1,1)>='5' OR SF3.F3_FORMUL='S') "
				ElseIf nSubDiv == 2                                 
					cQuery	+=	" AND (SUBSTRING(SF3.F3_CFO,1,1)='5' OR (SF3.F3_FORMUL='S' AND SUBSTRING(SF3.F3_CFO,1,1)='1')) "
				ElseIf nSubDiv == 3
					cQuery	+=	" AND (SUBSTRING(SF3.F3_CFO,1,1) IN ('6','7') OR (SF3.F3_FORMUL='S' AND SUBSTRING(SF3.F3_CFO,1,1) IN ('2','3'))) "
				Endif
			Endif   
			//�������������������������������������������������������������Ŀ
			//�Desconsidera operacoes isentas - MV_PAR22 - Imp. Op. Isentas �
			//���������������������������������������������������������������   
			If !lLisIsenta
				cQuery  +=  " AND F3_ISENICM <= 0 "
			EndIf
			//
			If !(lServico)
				cQuery	+=	" AND SF3.F3_TIPO<>'S' "
			Endif
			//
			If lMapResumo .AND. !lAglutina
				cQuery	+=	" AND SF3.F3_ESPECIE <> 'CF' AND SF3.F3_ESPECIE <> 'ECF'"			
			EndIf

			If (cNrLivro!="*")
				cQuery	+=	" AND SF3.F3_NRLIVRO='"+cNrLivro+"' "
			Endif
		Endif
		//
		If FWModeAccess("SF3",3)=="C" .And. SF3->(FieldPos("F3_MSFIL")) > 0 
			cQuery	+=	" ORDER BY SF3.F3_MSFIL, SF3.F3_ENTRADA, SF3.F3_SERIE, SF3.F3_NFISCAL, SF3.F3_CFO "
		Else	
			cQuery	+=	" ORDER BY SF3.F3_FILIAL, SF3.F3_ENTRADA, SF3.F3_SERIE, SF3.F3_NFISCAL, SF3.F3_CFO "
		EndIf
		//
		cQuery 	:= 	ChangeQuery (cQuery)
	    	//
		DbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSf3, .T., .T.)
		//
		For nSF3 := 1 To (Len (aStruSF3))
			If (aStruSF3[nSF3][2]<>"C") .And. (FieldPos (aStruSF3[nSF3][1])>0)
				TcSetField (cAliasSf3, aStruSF3[nSF3][1], aStruSF3[nSF3][2], aStruSF3[nSF3][3], aStruSF3[nSF3][4])
			EndIf
		Next (nSF3)
	#ELSE
		If cMov=="E"
			If FWModeAccess("SF3",3)=="C" .And. SF3->(FieldPos("F3_MSFIL")) > 0 
				cFiltro:="F3_MSFIL=='"+cFilAnt+"'.AND.DTOS(F3_ENTRADA)>='"+DTOS(dDtIni)+"'.AND.DTOS(F3_ENTRADA)<='"+DTOS(dDtFim)+"' "	
			Else	
				cFiltro:="F3_FILIAL=='"+xFilial()+"'.AND.DTOS(F3_ENTRADA)>='"+DTOS(dDtIni)+"'.AND.DTOS(F3_ENTRADA)<='"+DTOS(dDtFim)+"' "	
			EndIf
			
			If nSubDiv == 1
			    cFiltro +=  ".AND. F3_CFO<'500"+SPACE(LEN(F3_CFO)-3)+"' "
			ElseIf nSubDiv == 2                                          
				cFiltro +=  ".AND. SUBSTR(F3_CFO,1,1) == '1' "
			ElseIf nSubDiv == 3
				cFiltro +=  ".AND. SUBSTR(F3_CFO,1,1) $ '23' "
			Endif
			If !lServico
				cFiltro	+=	".AND.F3_TIPO!='S' "
			Endif
			If cNrLivro!="*"
				cFiltro	+=	".AND.F3_NRLIVRO=='"+cNrLivro+"' "
			Else
				//��������������������������������������������������������������Ŀ
				//� Filtra notas de Entrada de Ativo p/ Ceara "MV_LIVRESP"       �
				//����������������������������������������������������������������
				cFiltro	+=	".AND.F3_NRLIVRO<>'"+cLivrEP+"' "
			Endif
			//�������������������������������������������������������������Ŀ
			//�Desconsidera operacoes isentas - MV_PAR22 - Imp. Op. Isentas �
			//���������������������������������������������������������������    
			If !lLisIsenta
				cFiltro  +=  " .AND. F3_ISENICM <= 0 "
			EndIf
			//�������������������������������������������������������Ŀ
			//�Desconsidera notas canceladas quando considerar lacuna.�
			//���������������������������������������������������������
			If !(lLacuna)
				cFiltro	+=	".AND. !(!Empty (F3_DTCANC) .AND. F3_FORMUL=='S') "
			Endif
		Else
			If FWModeAccess("SF3",3)=="C" .And. SF3->(FieldPos("F3_MSFIL")) > 0 
				IF !(GetNewPar("MV_LFMD2DT",.F.))
					cFiltro:="F3_MSFIL=='"+cFilAnt+"'.AND.DTOS(F3_ENTRADA)>='"+DTOS(dDtIni)+"'.AND.DTOS(F3_ENTRADA)<='"+DTOS(dDtFim)+"' "	
				Else
					cFiltro:="F3_MSFIL=='"+cFilAnt+"'.AND.DTOS(F3_EMISSAO)>='"+DTOS(dDtIni)+"'.AND.DTOS(F3_EMISSAO)<='"+DTOS(dDtFim)+"' "	
				EndIf
			Else	
				IF !(GetNewPar("MV_LFMD2DT",.F.))
					cFiltro:="F3_FILIAL=='"+xFilial()+"'.AND.DTOS(F3_ENTRADA)>='"+DTOS(dDtIni)+"'.AND.DTOS(F3_ENTRADA)<='"+DTOS(dDtFim)+"' "	
				Else
					cFiltro:="F3_FILIAL=='"+xFilial()+"'.AND.DTOS(F3_EMISSAO)>='"+DTOS(dDtIni)+"'.AND.DTOS(F3_EMISSAO)<='"+DTOS(dDtFim)+"' "	
				EndIf
			EndIf
			
			If !lEntrada
				If nSubDiv == 1
			        cFiltro +=  ".AND. F3_CFO>='500"+SPACE(LEN(F3_CFO)-3)+"' "
			 	ElseIf nSubDiv == 2
			 		cFiltro +=  ".AND. SUBSTR(F3_CFO,1,1) == '5' "
			 	ElseIf nSubDiv == 3                           
			 		cFiltro +=  ".AND. SUBSTR(F3_CFO,1,1) $ '67' "
			 	Endif
			Else     
				If nSubDiv == 1
			        cFiltro +=  ".AND.(F3_CFO>='500"+SPACE(LEN(F3_CFO)-3)+"' .OR.F3_FORMUL=='S') "
			 	ElseIf nSubDiv == 2                                                               
			 		cFiltro +=  ".AND.(SUBSTR(F3_CFO,1,1)=='5' .OR. (SUBSTR(F3_CFO,1,1)=='1' .AND. F3_FORMUL=='S')) "
			 	ElseIf nSubDiv == 3                                                                              
			 		cFiltro +=  ".AND.(SUBSTR(F3_CFO,1,1) $ '67' .OR. (SUBSTR(F3_CFO,1,1)$'23' .AND. F3_FORMUL=='S')) "
			 	Endif
			Endif
			If !lServico
				cFiltro	+=	".AND.F3_TIPO!='S'"
			Endif
			
			If lMapResumo .AND. !lAglutina
				cFiltro	+=	" .AND. F3_ESPECIE <> 'CF' .AND. F3_ESPECIE <> 'ECF' "			
			EndIf
			
			//�������������������������������������������������������������Ŀ
			//�Desconsidera operacoes isentas - MV_PAR22 - Imp. Op. Isentas �
			//���������������������������������������������������������������    
			If !lLisIsenta
				cFiltro  +=  " .AND. F3_ISENICM <= 0 "
			EndIf
			If cNrLivro!="*"
				cFiltro	+=	".AND.F3_NRLIVRO=='"+cNrLivro+"'"
			Endif		
		Endif
		//
		If FWModeAccess("SF3",3)=="C" .And. SF3->(FieldPos("F3_MSFIL")) > 0 
			cChave		:=	"F3_MSFIL+DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CFO"
		Else	
			cChave		:=	"F3_FILIAL+DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CFO"
		EndIf
		
		cArqIndxF3	:=	CriaTrab(NIL,.F.)
		IndRegua ("SF3", cArqIndxF3, cChave,, cFiltro, "Filtrando registros...")
		//
		dbClearIndex ()
		dbSetIndex (cArqIndxF3+OrdBagExt ())
	#ENDIF

	//������������������������������������������������������������������������������������������������Ŀ
	//�Verifica os meses a processar. Caso seja necessario imprimir mais de um mes                     �
	//�e entre os meses exista algum sem movimento, devera ser impressa a descricao de "SEM MOVIMENTO".�
	//��������������������������������������������������������������������������������������������������
	nMesIni	:= Month(dDtIni)
	nAnoIni	:= Year(dDtIni)
	nMesFim	:= Month(dDtFim)
	nAnoFim	:= Year(dDtFim)
	nMesAux := nMesFim
	
	For nPosi := nAnoIni to nAnoFim
		If nPosi <> nAnoFim
			nMesFim := 12
		Else             
			nMesFim := nMesAux
		Endif
		Do While nMesIni <= nMesFim
			nProc := aScan(aProcessa,{|x| x[1]==nMesIni .And. x[2]==nPosi})

			//��������������������������������������������������������������Ŀ
			//�Somente adiciona se a referencia nao existir. No processamento�
			//�consolidado, essa rotina sera processada mais que uma vez.    �
			//����������������������������������������������������������������
			If nProc == 0
				Aadd(aProcessa,{nMesIni,nPosi,.F.})
			Endif
		
			If nMesIni == 12
				nMesIni	:= 1
				Exit
			Else
				nMesIni += 1
			Endif
		Enddo	
	Next 
	//��������������������������������������������������������������Ŀ
	//� Alimenta arquivo temporario                                  �
	//����������������������������������������������������������������
	DbSelectArea (cAliasSf3)
	SetRegua(LastRec())
	dbGotop()
	While !(cAliasSf3)->(eof())
		IncRegua()
		If Interrupcao(@lAbortPrint)
			Exit
		Endif
		//��������������������������������������������������������������Ŀ
		//� Considera filtro do usuario                                  �
		//����������������������������������������������������������������
		If !Empty(cFilterUser).and.!(&cFilterUser)
			dbSkip()
			Loop
		Endif
		//����������������������������������������������������Ŀ
		//� Armazena os numeros de livros lancados             �
		//������������������������������������������������������
		If !(F3_NRLIVRO$cLivros)
			cLivros	+=	F3_NRLIVRO+"/"
		Endif
	    //����������������������������������������Ŀ
		//�Para armazenar os per�odos com movimento�
		//������������������������������������������
	    If (cMov=="S" .And. GetNewPar("MV_LFMD2DT",.F.))
		    nPosi := aScan(aProcessa,{|x| x[1]==Month((cAliasSf3)->F3_EMISSAO) .And. x[2]==Year((cAliasSf3)->F3_EMISSAO)})
	    Else
			nPosi := aScan(aProcessa,{|x| x[1]==Month((cAliasSf3)->F3_ENTRADA) .And. x[2]==Year((cAliasSf3)->F3_ENTRADA)})	    
	    Endif

	    aProcessa[nPosi][3] := .T.
		//��������������������������������������������������������������Ŀ
		//� Verifica se os lancamentos serao aglutinados                 �
		//����������������������������������������������������������������
		If nTipomov==1 .or. !lAglutina
			dbSelectArea(cArqTemp)
			//��������������������������������������������������������������Ŀ
			//� Desconsidera item de entrada c/ formul. proprio nos livros   �
			//� de saida qdo ja foi gravado um item do lancto.               �
			//����������������������������������������������������������������
			If cMov=="S".And.lEntrada.And.Val(substr((cAliasSf3)->F3_CFO,1,1))<5.And.(cAliasSf3)->F3_FORMUL=="S".And. ;
				dbSeek((cAliasSf3)->F3_FILIAL+(cAliasSf3)->F3_SERIE+StrZero(Val((cAliasSf3)->F3_NFISCAL)),.F.)
				dbSelectArea (cAliasSf3)
				dbSkip()
				Loop
			Endif
			
			If cMov=="S"
				dbSeek((cAliasSf3)->F3_FILIAL+(cAliasSf3)->F3_SERIE+(cAliasSf3)->F3_NFISCAL+STR((cAliasSf3)->F3_ALIQICM,5,2)+(cAliasSf3)->F3_CFO,.F.)
			endif
			
			// Verifica se eh Nota Fiscal sobre Cupom
			cTipoEsp :=  (cAliasSf3)->F3_ESPECIE                             
			If !Empty((cAliasSf3)->F3_OBSERV) .AND. AllTrim(cTipoEsp)== "NF" .AND. !lAglutina      
				If SubStr((cAliasSf3)->F3_OBSERV, 1 , 9 ) == "CF/SERIE:" 
					DbSelectArea (cAliasSf3)
					DbSkip()
					Loop
			    EndIf   
			EndIf 
			
			If !eof() .and. F3_TIPO =="S"
			    If lServico .AND. lEntrada
	               RecLock(cArqTemp,.T.)
			  	Else
			  	   RecLock(cArqTemp,.F.)
			  	EndIf   
			Else
				RecLock(cArqTemp,.T.)
			EndIf
			For i	:=	1 to FCount()
				nx	:= FieldPos ((cAliasSf3)->(FieldName(i)))
				if nx>0
					FieldPut (nx,(cAliasSf3)->(FieldGet(i)))
				endif
			Next i
			//��������������������������������������������������������������Ŀ
			//� Corrige numeracao da Nota                                    �
			//����������������������������������������������������������������
			If cMov=="S"
				(cArqTemp)->NUMNOTA := STRZERO(VAL((cAliasSf3)->F3_NFISCAL),TamSX3("F2_DOC")[1])
			Endif
			//��������������������������������������������������������������Ŀ
			//� Zera valor de desconto para nao ser escriturado              �
			//����������������������������������������������������������������
			If !lDesconto
				(cArqTemp)->F3_VALOBSE := 0
			Endif                                                             
			
		   	dbSelectArea(cArqSF3)
		    RecLock(cArqSF3,.T.)
	        (cArqSF3)->CHAVE 	:= (cAliasSf3)->F3_FILIAL+DTOS((cAliasSf3)->F3_ENTRADA)+(cAliasSf3)->F3_NFISCAL+(cAliasSf3)->F3_SERIE+(cAliasSf3)->F3_CLIEFOR+(cAliasSf3)->F3_LOJA+(cAliasSf3)->F3_CFO+STR((cAliasSf3)->F3_ALIQICM,5,2)+(cAliasSf3)->F3_FORMULA
	        (cArqSF3)->FILIAL 	:= cFilAnt
	        (cArqSF3)->MES 		:= StrZero(Month((cAliasSf3)->F3_ENTRADA),2)
	        (cArqSF3)->ANO 		:= StrZero(Year((cAliasSf3)->F3_ENTRADA),4)
			(cArqSF3)->(MsUnLock())                                   
		
			DbSelectArea(cArqTemp)  // Caso for Nota Fiscal sobre Cupom grava na Observacao a serie e o numero da nota fiscal 
			SF2->(DbSetOrder(1))    // DOC + SERIE    
			If SF2->(DbSeek (xFilial("SF2")+(cAliasSf3)->F3_NFISCAL+(cAliasSf3)->F3_SERIE ))
			   cTipoSF2 :=  SF2->F2_ESPECIE
				If cPaisLoc == "BRA" .AND. AllTrim(cTipoSF2)== "CF" .AND. !Empty(SF2->(F2_NFCUPOM)) .AND. !lAglutina
					cSerNf := Substr(SF2->(F2_NFCUPOM) , 1, nTamSerie )
					cNfCup := Substr(SF2->(F2_NFCUPOM) , nTamSerie+ 1 , TamSx3("F2_DOC")[1]) 
					(cArqTemp)->F3_OBSERV := "SERIE/NF: "+ cSerNf  + "/" +cNfCup   // Serie e Numero da Nota Fiscal sobre o Cupom
				EndIf 
			EndIf  
			
			//��������������������������������������������������������������Ŀ
			//� Altera registro de notas de Formulario Proprio na Saida e    �
			//� Notas fiscais de Servico                                     �
			//����������������������������������������������������������������
			If cMov=="S".and.((cAliasSf3)->F3_FORMUL=="S".or.(cAliasSf3)->F3_TIPO=="S") .or. !empty((cAliasSf3)->F3_DTCANC)
				For i:=1 to FCount()
					If Valtype(FieldGet(i))=="N"
						FieldPut(i,0)  
					Endif
				Next
				If F3_FORMUL=="S" .And. empty(F3_DTCANC)
					(cArqTemp)->F3_OBSERV := "NT.FISCAL DE ENTRADA"
				Elseif F3_FORMUL=="S" .And. !empty(F3_DTCANC)
					If Empty((cArqTemp)->F3_OBSERV)
					   (cArqTemp)->F3_OBSERV := "CANCELADA"
                    Else  
						If SF3->(FieldPos("F3_CODRSEF")) > 0 .And. (cArqTemp)->F3_CODRSEF$"110,301,302,303,304,305,306" 
						   (cArqTemp)->F3_OBSERV := "NF DENEGADA" //"NF DENEGADA"
						ElseIf SF3->(FieldPos("F3_CODRSEF")) > 0 .And. (cArqTemp)->F3_CODRSEF$"102" //"NF INUTILIZADA"
						   (cArqTemp)->F3_OBSERV := "NF INUTILIZADA"						
						EndIf
					EndIf
				ElseIf !empty(F3_DTCANC	)
					If Empty((cArqTemp)->F3_OBSERV)
						(cArqTemp)->F3_OBSERV := "CANCELADA"
                    Else
						If SF3->(FieldPos("F3_CODRSEF")) > 0 .And. (cArqTemp)->F3_CODRSEF$"110,301,302,303,304,305,306" 
						   (cArqTemp)->F3_OBSERV := "NF DENEGADA" //"NF DENEGADA"
						ElseIf SF3->(FieldPos("F3_CODRSEF")) > 0 .And. (cArqTemp)->F3_CODRSEF$"102" //"NF INUTILIZADA"
						   (cArqTemp)->F3_OBSERV := "NF INUTILIZADA"						
						EndIf
					EndIf
				Else
					(cArqTemp)->F3_OBSERV := "NT.FISCAL DE SERVICO"+" "+(cArqTemp)->F3_OBSERV
				EndIf
				if	empty(F3_DTCANC)	
					(cArqTemp)->F3_CFO	:= "999"
				EndIf		
				If F3_FORMUL<>"S" .Or. (cMov=="S".and.GetNewPar("MV_LFMD2DT",.F.))
					//��������������������������������������������������������������Ŀ
					//� Considera Dt.emissao NF entrada na emissao livro de saidas.  �
					//����������������������������������������������������������������
					(cArqTemp)->F3_ENTRADA := F3_EMISSAO
				Endif
			Endif                                      
			//���������������������������������������������������Ŀ
			//�Grava a filial corrente no momento do processamento�
			//�����������������������������������������������������
			(cArqTemp)->FILCORR := cFilAnt
			MsUnLock()
            //
	        If lEmiteCiap
			   If ( Select("CIAP") != 0 )
				  	dbSelectArea("SD1")
				  	dbSetOrder(1)

					cChaveSD1 :=	xFilial("SD1")+(cAliasSf3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)
					
				If aScan(aSd1, {|aX| aX[1]==cChaveSD1})==0
						aAdd(aSd1,{cChaveSD1})
					
				  		If SD1->(dbSeek(cChaveSD1))
							 
					  		While SD1->(!Eof()) .And. cChaveSD1==SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
					  			dbSelectArea("SF9")
				  	            dbSetOrder(2)
						  		If ( dbSeek(F3Filial("SF9")+Dtos((cAliasSf3)->F3_ENTRADA)+(cAliasSf3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+SD1->(D1_CF+STR(D1_PICM,5,2)))))
							 		While ( !Eof() .And. F3Filial("SF9")==SF9->F9_FILIAL .And.;
									   (cAliasSf3)->F3_ENTRADA	==SF9->F9_DTENTNE	 	.And.;
								 	   (cAliasSf3)->F3_NFISCAL	==SF9->F9_DOCNFE	 	.And.;
									   (cAliasSf3)->F3_SERIE	==SF9->F9_SERNFE	 	.And.;
									   (cAliasSf3)->F3_CLIEFOR	==SF9->F9_FORNECE		.And.;
									   (cAliasSf3)->F3_LOJA		==SF9->F9_LOJAFOR		.And.;
									   SD1->D1_CF				==SF9->F9_CFOENT		.And.;
									   SD1->D1_PICM				==SF9->F9_PICM )
									   RecLock("CIAP",.T.)
									   CIAP->SF3 := &(cArqTemp)->(Recno())
									   CIAP->SF9 := SF9->(Recno())
									   MsUnlock()

									   SF9->(dbSkip())
									EndDo
						  		EndIf
							  	SD1->(dbSkip())
						  	EndDo
						EndIf
				  	EndIF
					 	  
				  dbSelectArea("SF9")
				  dbSetOrder(1)
			   EndIf
			Endif
			dbSelectArea(cAliasSf3)
			dbSkip()
		Else
			//��������������������������������������������������������������Ŀ
			//� Aglutina lancamentos de mesma Data+Serie+CFO                 �
			//����������������������������������������������������������������
			cNFIni	  := F3_NFISCAL
			cNFFim	  := F3_NFISCAL
			dData	  := F3_ENTRADA
			cEst	  := F3_ESTADO
			cEsp	  := F3_ESPECIE 
			dDtCan1   := F3_DTCANC 
		    cCliente  := F3_CLIEFOR
		    cLoja     := F3_LOJA
	        nAliq     := F3_ALIQICM         
		    cSer 	  := F3_SERIE        
		    cFormula  := F3_FORMULA
			cTipo	  := F3_TIPO     
			cFilProc  := F3_FILIAL
			//���������������������������������������������Ŀ
			//� Inicializa array de aglutinacao.            �
			//�����������������������������������������������
			aLivro := Array(Len(aFixos))
			For i:=1 To Len(aFixos)
				aLivro[i] := aFixos[i][2]
			Next
			
			cSeek:=F3_FILIAL+dTos(F3_ENTRADA)+F3_SERIE+F3_CFO+Str(F3_ALIQICM,5,2)+cEst+cEsp+cFormula+cTipo
			While !Eof().And.cSeek==F3_FILIAL+dTos(F3_ENTRADA)+F3_SERIE+F3_CFO+Str(F3_ALIQICM,5,2)+F3_ESTADO+F3_ESPECIE+F3_FORMULA	+F3_TIPO
		        //������������������������������������������Ŀ
				//� Considera Nf's de Entrada                �
				//��������������������������������������������
				If !lEntrada .and. Val(substr(F3_CFO,1,1))<5
					dbSkip()
					Loop
				Endif                                    
				//������������������������������Ŀ
				//� Acumula valores.             �
				//�������������������������������� 
				if empty(F3_DTCANC)
					For i:=1 To Len(aFixos)
						If (cAliasSf3)->(FieldPos(aFixos[i][1])) > 0
							cCampo:=&(aFixos[i,1])
							If ValType(cCampo)$"CD".Or.aFixos[i,1]=="F3_ALIQICM"
								aLivro[i]:=cCampo
							Else
								aLivro[i]+=cCampo
							Endif 
						Endif	
					Next				
	 			    RecLock(cArqSF3,.T.)
	  	            (cArqSF3)->CHAVE 	:= (cAliasSf3)->F3_FILIAL+DTOS((cAliasSf3)->F3_ENTRADA)+(cAliasSf3)->F3_NFISCAL+(cAliasSf3)->F3_SERIE+(cAliasSf3)->F3_CLIEFOR+(cAliasSf3)->F3_LOJA+(cAliasSf3)->F3_CFO+STR((cAliasSf3)->F3_ALIQICM,5,2)+(cAliasSf3)->F3_FORMULA
	  	            (cArqSF3)->FILIAL 	:= cFilAnt
			        (cArqSF3)->MES 		:= StrZero(Month((cAliasSf3)->F3_ENTRADA),2)
			        (cArqSF3)->ANO 		:= StrZero(Year((cAliasSf3)->F3_ENTRADA),4)
					MsUnLock()	
					cNFFim   :=(cAliasSf3)->F3_NFISCAL
					cSer 	 :=(cAliasSf3)->F3_SERIE
					cCFO     :=(cAliasSf3)->F3_CFO
		  		    cFormula :=(cAliasSf3)->F3_FORMULA				
		  		    cFilProc :=(cAliasSf3)->F3_FILIAL
					
					If !lMapResumo
						GravaTemp(cNFIni,cNFFim,aFixos,aLivro,dData,cEst,cEsp,cCliente,cLoja,dDtCan1,cMov,lDesconto,nAliq,cSer,cCFO,cFormula,,cFilProc,cAliasSf3)
					Else
						//�������������������������������������������������������������Ŀ
						//�Caso utilize Mapa Resumo, somente gera o temporario para NF. �
						//�Pois os registros de Mapa Resumo (SFI) serao de acordo com a �
						//�funcao Mtr930Resumo                                          �
						//���������������������������������������������������������������
	            		If Alltrim((cAliasSf3)->F3_ESPECIE) <> "CF" .AND. Alltrim((cAliasSf3)->F3_ESPECIE) <> "ECF"
							GravaTemp(cNFIni,cNFFim,aFixos,aLivro,dData,cEst,cEsp,cCliente,cLoja,dDtCan1,cMov,lDesconto,nAliq,cSer,cCFO,cFormula,,cFilProc,cAliasSf3)
						EndIf	            						
					EndIf
	
	            Else
	               lCanc :=.T.
	               exit 
				EndIf
				dbSelectArea(cAliasSf3)
	            dbSkip()
				//��������������������������������������������������������������Ŀ
				//� Verifica se proxima nota nao esta cancelada.                 �
				//����������������������������������������������������������������
				If (Val(cNFFim)+1) <> Val(F3_NFISCAL)
					Exit
				Endif
			EndDo
			if lCanc
	           //���������������������������������������������Ŀ
			   //� Inicializa array de aglutinacao.            �
			   //�����������������������������������������������
			   aLivro := Array(Len(aFixos))
			   For i:=1 To Len(aFixos)
				   aLivro[i] := aFixos[i][2]
			   Next
			   cNFIni	 := (cAliasSf3)->F3_NFISCAL
			   cNFFim	 := (cAliasSf3)->F3_NFISCAL
			   dData	 := (cAliasSf3)->F3_ENTRADA
			   cEst	     := (cAliasSf3)->F3_ESTADO
			   cEsp	     := (cAliasSf3)->F3_ESPECIE 
			   dDtCan1   := (cAliasSf3)->F3_DTCANC 
			   cCliente  := (cAliasSf3)->F3_CLIEFOR
			   cLoja     := (cAliasSf3)->F3_LOJA
			   cFilProc  := (cAliasSf3)->F3_FILIAL
			   lCanc     :=.F.
	           
			   If !lMapResumo
	           		GravaTemp(cNFIni,cNFFim,aFixos,aLivro,dData,cEst,cEsp,cCliente,cLoja,dDtCan1,cMov,lDesconto,nAliq,cSer,cCFO,,,cFilProc,cAliasSf3)
			   Else
					//�������������������������������������������������������������Ŀ
					//�Caso utilize Mapa Resumo, somente gera o temporario para NF. �
					//�Pois os registros de Mapa Resumo (SFI) serao de acordo com a �
					//�funcao Mtr930Resumo                                          �
					//���������������������������������������������������������������
			   		If Alltrim((cAliasSf3)->F3_ESPECIE) <> "CF" .AND. Alltrim((cAliasSf3)->F3_ESPECIE) <> "ECF"
						GravaTemp(cNFIni,cNFFim,aFixos,aLivro,dData,cEst,cEsp,cCliente,cLoja,dDtCan1,cMov,lDesconto,nAliq,cSer,cCFO,,,cFilProc,cAliasSf3)			        
			   		EndIf
			   EndIf               
			   
			   dbSelectArea(cAliasSf3)
	           dbSkip()		
			endif
			dbSelectArea(cAliasSf3)
		Endif
	End

	//������������������������������������������������������Ŀ
	//�Verifica a necessidade de analisar o aProcessa, devido�
	//�as informacoes de Mapa Resumo aparecerem depois do    �
	//�processamento do SF3                                  �
	//��������������������������������������������������������
	If lMapResumo .AND. cMov=="S"
		/*
		If Type("lLeiEcf") <> "U" 
			If Type("lLeiEcf") == "L" 
				lImpEcf := lLeiECF
			EndIf            
        EndIf
        */
		If _uLeiEcf <> "U" 
			If _uLeiEcf == "L" 
				lImpEcf := lLeiECF
			EndIf            
        EndIf
        
		If lImpEcf
			//������������������������������������������������Ŀ
			//�Alimenta array com as informacoes do Mapa Resumo�
			//��������������������������������������������������
			aMapaResumo		:= 	MaxRMapRes(dDtIni,dDtFim)

			//���������������������������������������������������������Ŀ
			//�Verifica se anteriormente foi inserido registro para data�
			//�sem movimento                                            �
			//�����������������������������������������������������������
			If Len(aProcessa) > 0
				For nX := 1 To Len(aMapaResumo)
					nPosi := aScan(aProcessa,{|x| x[1]==Month(aMapaResumo[nX][1]) .And. x[2]==Year(aMapaResumo[nX][1])})	
				    If nPosi > 0
				    	If !aProcessa[nPosi][3]
							aProcessa[nPosi][3] := .T.		    	
				    	EndIf
				    EndIf
				Next nX
            EndIf
		EndIf
	EndIf
	
	//��������������������������������������������������������������������������
	//�Adiciona um registro no temporario para imprimir o periodo sem movimento�
	//��������������������������������������������������������������������������
	For nPosi := 1 To Len(aProcessa)
		If ! aProcessa[nPosi][3]
			cNFIni		:= ""
			cNFFim		:= ""
			cSer		:= ""
			nAliq		:= 0
			cFormula	:= ""
			dData		:= cToD("01/" + StrZero(aProcessa[nPosi][1],2) + "/" + StrZero(aProcessa[nPosi][2],4))
			cEst		:= ""
			cEsp		:= ""
			dDtCan1		:= cTod("  /  /  ")
			cCliente	:= ""
			cLoja		:= ""
			lCanc		:= .F.
			cFilProc  	:= xFilial("SF3")
	        GravaTemp(cNFIni,cNFFim,aFixos,aLivro,dData,cEst,cEsp,cCliente,cLoja,dDtCan1,cMov,lDesconto,nAliq,cSer,cCFO,cFormula,.T.,cFilProc,cAliasSf3)
		Endif
	Next
	
	#IFDEF TOP
		(cAliasSf3)->(DbCloseArea ())
	#ENDIF
	//��������������������������������������������������������������Ŀ
	//� Reposiciona SF3                                              �
	//����������������������������������������������������������������
	dbSelectArea("SF3")
	dbClearFilter()
	RetIndex("SF3")
	dbSetOrder(1)
	#IFNDEF TOP
		Ferase(cArqIndxF3+OrdBagExt())
	#ENDIF
	//����������������������������������������������������������������������������������Ŀ
	//� Acumula Valores do ICMS Normal + Retido - Instr. Normativa n. 564/02-GSF - Goias �
	//������������������������������������������������������������������������������������
	If nTotIcmsEnt == 1 .And. cMov=="S" .And. lExist
		dbSelectArea("SF3")
		#IFDEF TOP
			cQuery := "SELECT SUM (SF3.F3_OBSICM) F3_OBSICM, SUM (SF3.F3_OBSSOL) F3_OBSSOL "
			cQuery += "FROM "+RetSqlName("SF3")+" SF3 "
			cQuery += "WHERE SF3.F3_FILIAL='"+xFilial("SF3")+"' AND "
			cQuery += "SUBSTRING(SF3.F3_CFO,1,1)<'5' AND "
			cQuery += "SF3.F3_ENTRADA>='"+DTOS(dDtIni)+"' AND SF3.F3_ENTRADA<='"+DTOS(dDtFim)+"' AND "
			cQuery += "SF3.D_E_L_E_T_=' ' "
	
			If !(lServico)
				cQuery	+=	" AND SF3.F3_TIPO<>'S' "
			EndIf
			
			If (cNrLivro!="*")
				cQuery	+=	" AND SF3.F3_NRLIVRO='"+cNrLivro+"' "
			EndIf
			
			cQuery := ChangeQuery(cQuery)
	
			dbUseArea (.T.,"TOPCONN",TcGenQry (,,cQuery),"QUERY")
	
			nTotIcmDeb := QUERY->F3_OBSICM+QUERY->F3_OBSSOL
	
			QUERY->(dbCloseArea ())
		#ELSE
			cFiltro:="F3_FILIAL=='"+xFilial()+"'.AND.DTOS(F3_ENTRADA)>='"+DTOS(dDtIni)+"'.AND.DTOS(F3_ENTRADA)<='"+DTOS(dDtFim)+"'"
			cFiltro +=  ".AND. F3_CFO<'500"+SPACE(LEN(F3_CFO)-3)+"'"
			If !lServico
				cFiltro	+=	".AND.F3_TIPO!='S'"
			Endif
			If cNrLivro!="*"
				cFiltro	+=	".AND.F3_NRLIVRO=='"+cNrLivro+"'"
			Endif
			cChave		:=	"F3_FILIAL+DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CFO"
			cArqIndxF3	:=	CriaTrab(NIL,.F.)
			IndRegua("SF3",cArqIndxF3,cChave,,cFiltro,"Filtrando registros...")
			//
			dbClearIndex()
			dbSetIndex(cArqIndxF3+OrdBagExt())
			//
			SetRegua(LastRec())
			dbGotop()
			While !SF3->(eof())
				IncRegua()
				If Interrupcao(@lAbortPrint)
					Exit
				Endif
				nTotIcmDeb += F3_OBSICM+F3_OBSSOL
				dbSkip()		
			EndDo
			//
			dbSelectArea("SF3")
		dbClearFilter()
			RetIndex("SF3")
			dbSetOrder(1)
			Ferase(cArqIndxF3+OrdBagExt())
		#ENDIF
		//
		dbSelectArea("SF3")
		dbSetOrder(1)
	Endif

	If lMapResumo .AND. lImpEcf .AND. Len(aMapaResumo) > 0
		/*
 		If Type("nLegisArt") == "U" //Verifica se a varivel existe.
			nLegisArt := 0
		EndIf
		*/
 		If _uLegisArt == "U" //Verifica se a varivel existe.
			nLegisArt := 0
		EndIf
		aGravaMapRes	:= 	MaXRAgrupF3(cFilAnt,aMapaResumo,cChamOrig,nLegisArt)
		cArqTemp		:=	MaXRAddArq(2,cArqTemp,/*cAlias*/,aCampos,aGravaMapRes)

	EndIf
	If FWModeAccess("SF3",3)=="C" 
		Exit
	Else
   		SM0->(dbSkip())	
	Endif	

Enddo

//����������������������������������Ŀ
//�Restaura a filial e area corrente �
//������������������������������������
aArea := GetArea()
RestArea(aAreaSM0)
cFilAnt	:= FWCodFil()
RestArea(aArea)

//��������������������������������������������������������������Ŀ
//� Busca notas Fiscais Canceladas/Nao Lancadas/Nf.Servico       �
//����������������������������������������������������������������
If cMov=="S".and.lLacuna.and.!lAbortPrint
	dbSelectArea(cArqTemp)
	dbSetOrder(1)
	dbGotop()
	//��������������������������������������������������������������Ŀ
	//� Busca series lancadas                                        �
	//����������������������������������������������������������������
	aSeries:={}
	SetRegua(LastRec())
	While !eof()
		IncRegua()
		If Interrupcao(@lAbortPrint)
			Exit
		Endif
		If !SEMMOV 
			nPos:=Ascan(aSeries,{|x|x[1]==F3_NRLIVRO.and.x[2]==F3_SERIE.and.x[5]==F3_FILIAL})
			If nPos==0
				nTamNF := Len(AllTrim(F3_NFISCAL))
				AADD(aSeries,{F3_NRLIVRO,F3_SERIE,Val(NUMNOTA),0,F3_FILIAL,FILCORR,nTamNF})
				nPos:=Len(aSeries)
			Endif              
			
			aSeries[nPos,4]:=Max(Max(Val(NUMNOTA),Val(F3_DOCOR)),aSeries[nPos,4])    
			aSeries[nPos,7]:=Iif(Len(Alltrim(F3_NFISCAL))==aSeries[nPos,7],aSeries[nPos,7],TamSX3("F2_DOC")[1])
		Endif
		dbSkip()
	End         
	//��������������������������������������������������������������Ŀ
	//� Verifica Series Lancadas                                     �
	//����������������������������������������������������������������
	dDtCanc	:=	dDtFim
	For i:=1 to Len(aSeries)
		SetRegua(aSeries[i,4]-aSeries[i,3])
		For j:=aSeries[i,3] to aSeries[i,4]
			
			IncRegua()
			If Interrupcao(@lAbortPrint)
				Exit
			Endif
			
			cNumNota 	:=	StrZero(j,aSeries[i,7])+Space(TamSX3("F2_DOC")[1]-aSeries[i,7])
			cSeek		:=	aSeries[i,2]+cNumNota+aSeries[i,5]
			dbSetOrder(3)
			If dbSeek(cSeek,.F.)
				//������������������������������������������Ŀ
				//� Nao considera notas de Lote na sequencia �
				//��������������������������������������������
				If F3_TIPO=="L".And.!Empty(F3_DOCOR)
					j:=Val(F3_DOCOR)
					dbSkip()
					While ( !Eof() .And. J==Val(NUMNOTA) )
						j:=Val(F3_DOCOR)
						dbSkip()
					EndDo
					If j>=aSeries[i,4]
						Exit
					Endif
				Endif
				dDtCanc:=F3_ENTRADA
				Loop
			Else
				dbSetOrder(2)
				cSeek:=aSeries[i,2]+"C"+cNumNota+aSeries[i,5]
				If !dbSeek(cSeek)
					//������������������������������������������Ŀ
					//� Verifica se a nota existe em outro livro �
					//��������������������������������������������
					If !ExistNF(cNumNota,aSeries[i,2],aSeries[i,1],cLivros,aSeries[i,6]) 
     					If nLacuna==1

							cObserv	:= Iif( SF3->(FieldPos("F3_CODRSEF")) > 0 .And. (cArqTemp)->F3_CODRSEF$"110,301,302,303,304,305,306" , "NF DENEGADA" , "CANCELADA" )

	  						//�����������������������������������������������Ŀ
							//� Tratamento para as notas fiscais Inutilizadas �
							//�������������������������������������������������
							If SF3->(FieldPos("F3_CODRSEF")) > 0 .And. (cArqTemp)->F3_CODRSEF$"102"
								cObserv	:= "NF INUTILIZADA"
							EndIf

							RecLock(cArqTemp,.T.)                                              
                           	//�����������������������������������������������������Ŀ
                           	//�Posiciona na filial em que foi processado o registro �
                           	//�������������������������������������������������������
                           	Mtr930Fil(aAreaSM0,aSeries[i,6],1)
					   		(cArqTemp)->F3_FILIAL 	:= xFilial("SF3")
					   		(cArqTemp)->F3_TIPO		:= "C"
					   		(cArqTemp)->F3_NFISCAL 	:= StrZero(j,aSeries[i,7])
					   		(cArqTemp)->F3_DOCOR	:= StrZero(j,aSeries[i,7])
					   		(cArqTemp)->NUMNOTA		:= cNumNota
					   		(cArqTemp)->F3_NRLIVRO 	:= aSeries[i,1]
					   		(cArqTemp)->F3_SERIE	:= aSeries[i,2]
					   		(cArqTemp)->F3_EMISSAO	:= dDtCanc
					   		(cArqTemp)->F3_ENTRADA 	:= dDtCanc
					   		(cArqTemp)->F3_CFO		:= "999"
					   		(cArqTemp)->F3_OBSERV	:= cObserv 
					   		MsUnLock()
   					       	//����������������������������������Ŀ
 	 				       	//�Restaura a filial e area corrente �
				      		//������������������������������������
					   		Mtr930Fil(aAreaSM0,aSeries[i,6],2)
						Endif   
					Else
						If !dbSeek(cSeek,.F.)
          		            //�����������������������������������������������������Ŀ
                     		//�Posiciona na filial em que foi processado o registro	�
                     		//�������������������������������������������������������
							Mtr930Fil(aAreaSM0,aSeries[i,6],1)
							dbSelectArea("SF3")
							dbSetOrder(5)
							If cMov=="S".And.lEntrada.And.dbSeek(xFilial()+aSeries[i,2]+cNumNota,.F.).And.Val(substr(SF3->F3_CFO,1,1))<5.And.(SF3->F3_FORMUL=="S") ;
								.And.(SF3->F3_EMISSAO>=dDtIni.And.SF3->F3_EMISSAO<=dDtFim)
								//��������������������������������������������������������������Ŀ
								//� Altera registro de notas de Formulario Proprio na Saida e    �
								//� Notas fiscais de Servico                                     �
								//����������������������������������������������������������������
								If SF3->(EOF())
								RecLock(cArqTemp,.T.)
								(cArqTemp)->F3_FILIAL 	:= xFilial("SF3")
								(cArqTemp)->F3_NFISCAL 	:=	StrZero(j,aSeries[i,7])
								(cArqTemp)->F3_DOCOR	:=	StrZero(j,aSeries[i,7])
								(cArqTemp)->NUMNOTA		:= cNumNota
								(cArqTemp)->F3_NRLIVRO	:= aSeries[i,1]
								(cArqTemp)->F3_SERIE	:= aSeries[i,2]
								(cArqTemp)->F3_OBSERV	:= "NT.FISCAL DE ENTRADA"
								(cArqTemp)->F3_CFO		:= "999"
								(cArqTemp)->F3_ENTRADA 	:= SF3->F3_EMISSAO
								For nI:=1 to FCount()
									If Valtype(FieldGet(nI))=="N"
										FieldPut(nI,0)
									Endif
								Next
								//��������������������������������������������������������������Ŀ
								//� Considera Dt.emissao NF entrada na emissao livro de saidas.  �
								//����������������������������������������������������������������
								MsUnLock()
							Endif
							//����������������������������������Ŀ
							//�Restaura a filial e area corrente �
							//������������������������������������
							Mtr930Fil(aAreaSM0,aSeries[i,6],2)
						Endif
						Endif
				        dDtCanc:=F3_ENTRADA
						dbSelectArea(cArqTemp)
					Endif
				Else
 				   dDtCanc:=F3_ENTRADA
					RecLock(cArqTemp,.F.)
					If J>Val(F3_DOCOR)
						(cArqTemp)->F3_DOCOR 	:= StrZero(j,aSeries[i,7])
					Endif
					MsUnLock()
				Endif
			Endif
		Next j
		If lAbortPrint
			Exit
		Endif
	Next i
Endif
dbSelectArea(cArqTemp)
If cMov=="S"
	dbClearIndex()
	Ferase(cIndxTemp1+OrdBagExt())
	Ferase(cIndxTemp2+OrdBagExt())
Endif

//��������������������������������������������������������������Ŀ
//� Indice principal de impressao                                �
//����������������������������������������������������������������
If !lAbortPrint
	if aReturn[8]==1
		cChave	:=	"DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CFO+F3_FORMULA+F3_FILIAL"
	else
		cChave	:=	"DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CFO+F3_FORMULA+F3_FILIAL"
	endif
	IndRegua(cArqTemp,cArqTemp,cChave,,,"Ordenando Notas...")
	dbGoTop()
Endif
//��������������������������������������������������������������Ŀ
//� Inicializa array aColunas statico com colunas do SF3         �
//����������������������������������������������������������������
ColF3()

Return (cArqTemp)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � LivrAcumula()�Autor � Juan Jose Pereira    �Data� 17/02/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Acumulador de valores fiscais para o ModP1,ModP1A          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static FUNCTION LivrAcumula(	cArqTemp,;
aTotDia,;
aTotPerICM,;
aTotPerIPI,;
aTotMes,;
aTransp,;
aResumo,;
aResCFO,;
cArqSF3,;
lMatr921)

LOCAL aSF3		:= {}
Local i
Local cSvAlias	:= Alias()
Local nPos
Local nPosCFO
LOCAL cMens		:= ""
Local cCaption	:= " ATENCAO "
LOCAL cClieFor
LOCAL cInscr
LOCAL cTipo
Local lExist 	:= .F.
Local aAreaSM0 	:= SM0->(GetArea())
Local cFilProc	:= ""
Local lCredST	:= SF3->(FieldPos("F3_CREDST")) > 0
Local lP1IcmST		:= GetNewPar("MV_P1ICMST",.F.)
Local lProcST	:= .T.
Local dAuxData	:= cTod("//")
Local lAntiICM	:= SF3->(FieldPos("F3_VALANTI")) > 0  
Local lRed43080 := Iif(SF3->(FieldPos("F3_VL43080")) > 0, .T., .F.) 
Local lIncLeite := Iif(SF3->(FieldPos("F3_VLINCMG")) > 0, .T., .F.) 
Local lRemAmb   := .F. 
Local nFilchave	:= FWSizeFilial()

Default lMatr921 := .F.

Private oDlgAviso  

//�������������������������������������������������������Ŀ
//�Verifica se foi passada a filial pelo cArqSF3 (Matr920)�
//���������������������������������������������������������
If cArqSF3 <> Nil
	cFilProc := (cArqSF3)->FILIAL
Else
	cFilProc := cFilAnt
Endif


//��������������������������������������������������Ŀ
//� Verifica se CFO das NFs sao validos.             �
//����������������������������������������������������
If (Empty(F3_CFO) .Or. ValType(Val(F3_CFO))!="N") .And. FieldPos ("SEMMOV")>0 .And. !SEMMOV
	cMens:="NF "+F3_SERIE+" "+F3_NFISCAL+" possui CFO incorreto ! "
	
	DEFINE MSDIALOG oDlgAviso TITLE OemtoAnsi(cCaption) FROM  165,190 TO 300,440 PIXEL OF oMainWnd
	@ 03, 10 TO 43, 118 LABEL "" OF oDlgAviso  PIXEL
	@ 20, 15 SAY OemToAnsi(cMens) SIZE 100, 8 OF oDlgAviso PIXEL
	DEFINE SBUTTON FROM 50  ,80  TYPE 1 ACTION (oDlgAviso:End()) ENABLE OF oDlgAviso
	ACTIVATE MSDIALOG oDlgAviso
	Return
Endif

If aResCFO==NIL
	aResCFO:={}
Endif
If aResumo==NIL
	aResumo:={}
Endif

dbSelectArea(cArqTemp)
                       
lExist := IIF((cArqTemp)->F3_OBSSOL>0,.T.,.F.)
//������������������������������������������������������������������������Ŀ
//�Verifica o valor do ICMS Retido de acordo com a configuracao da TES     �
//�Quando o campo F3_CREST existir e estiver configurado como "4",         �
//�o valor do ICMS retido nao deve ser apresentado na coluna de observacoes�
//��������������������������������������������������������������������������
lProcST := .T.
If lCredST
	If (cArqTemp)->F3_CREDST == "4" .And. lP1IcmST .And. (cArqTemp)->F3_CFO < "5"
       	lProcST := .T.
 	Elseif (cArqTemp)->F3_CREDST == "4" .And. !lP1IcmST .And. (cArqTemp)->F3_CFO < "5"
 		lProcST	:= .F. 
   	Elseif (cArqTemp)->F3_CREDST == "4" .And. lExist
		lProcST := .F.
	Elseif !lExist
		lProcST := .T.
	Endif
Endif

For i:=1 to FCount()
	If ValType(FieldGet(i))=="N"
		// Quando o ICMS ST nao deve ser apresentado como Retido - ST Transportes
	  	If (Alltrim(FieldName(i)) == "F3_ICMSRET" .Or. AllTrim(FieldName(i)) == "F3_BASERET" .Or. AllTrim(FieldName(i)) == "F3_OBSSOL" .Or. AllTrim(FieldName(i)) == "F3_CRPRST") .And. !lProcST
			AADD(aSF3,0)
	  	Else
			If (AllTrim(FieldName(i)) == "F3_BASERET") .And. !lExist
				AADD(aSF3,FieldGet(i))
			ElseIf (AllTrim(FieldName(i)) == "F3_BASERET") .And. lExist
				AADD(aSF3,0)	
			Else
				AADD(aSF3,FieldGet(i))
			Endif			
		Endif
	Else 
		AADD(aSF3,"NULL")
	Endif
Next

//������������������������������������������������������������������������������������Ŀ
//�Para o relatorio de transcricao MATR921 o tratamento abaixo nao deve ser aplicado   �
//�pois esta zerando os totalizadores do relatorio. (Alinhado com equipe de legislacao)�
//��������������������������������������������������������������������������������������
If !lMatr921
	//verifica se efetura tratamento - Remessa de Venda p/ Fora do Estabelecimento
	If cMV_ESTADO=="SP" .And. Alltrim(F3_CFO)$"1904/2904/5904/6904/"
	    lRemAmb := .T.
	Else
	    lRemAmb := .F.     
	EndIf
EndIf                                                                                   

//����������������������������������������������������������������Ŀ
//�Verifica se o registro nao e do Mapa Resumo do ECF              �
//������������������������������������������������������������������
If substr(F3_CFO,1,3)=="999" .And. (Alltrim(F3_ESPECIE)<>"CF" .AND. Alltrim(F3_ESPECIE)<>"ECF")
	For i:=1 to Len(aSF3)
		aSF3[i]:=If(Valtype(aSF3[i])=="N",0,aSF3[i])
	Next
Endif

If aTotDia==NIL
	aTotDia		:=	Aclone(aSF3)
	aTotPerICM	:=	Aclone(aSF3)
	aTotPerIPI	:=	Aclone(aSF3)
	aTotMes		:=	Aclone(aSF3)
	aTransp		:=	Aclone(aSF3)
Else
	For i:=1 to Len(aSF3)
		If Valtype(aSF3[i])=="N"
			nValor:=aSF3[i]
            If lRemAmb
		 	   aTotDia[i]		:=0
		 	   aTotPerICM[i]	:=0
		 	   aTotPerIPI[i]	:=0
		 	   aTotMes[i] 		:=0
		 	   aTransp[i]		:=0
		 	Else
		 	   aTotDia[i]		+=nValor
		 	   aTotPerICM[i]	+=nValor
		 	   aTotPerIPI[i]	+=nValor
		 	   aTotMes[i] 		+=nValor
		 	   aTransp[i]		+=nValor
		    Endif
        EndIf
	Next i
Endif
//���������������������������������������������������������������������������������������������Ŀ
//� Acumula valores por CFOS                                                                    �
//�����������������������������������������������������������������������������������������������
nPosCFO:=ColF3("F3_CFO")
If !(Subs(F3_CFO,1,3) $ "999#000") .And. Empty(F3_DTCANC) .And. !lRemAmb // nao imprimi resumo por CFOP para transferencias/Canceladas
	nPos:=Ascan(aResCFO,{|x|x[nPosCFO]==F3_CFO})
	If nPos==0
		AADD(aResCFO,AClone(aSF3))
		nPos:=Len(aResCFO)
		aResCFO[nPos,nPosCFO]:=F3_CFO
	Else
		For i:=1 to Len(aSF3)
			If ValType(aSF3[i])=="N"
				aResCFO[nPos,i]+=aSF3[i]
			Endif
		Next i
	Endif
	nPos:=Ascan(aResCFO,{|x|x[nPosCFO]==Substr(F3_CFO,1,1)+"TT"})
	If nPos==0
		AADD(aResCFO,AClone(aSF3))
		nPos:=Len(aResCFO)
		aResCFO[nPos,nPosCFO]:=Substr(F3_CFO,1,1)+"TT"
	Else
		For i:=1 to Len(aSF3)
			If ValType(aSF3[i])=="N"
				aResCFO[nPos,i]+=aSF3[i]
			Endif
		Next i
	Endif
	nPos:=Ascan(aResCFO,{|x|x[nPosCFO]=="TTT"})
	If nPos==0
		AADD(aResCFO,AClone(aSF3))
		nPos:=Len(aResCFO)
		aResCFO[nPos,nPosCFO]:="TTT"
	Else
		For i:=1 to Len(aSF3)
			If ValType(aSF3[i])=="N"
				aResCFO[nPos,i]+=aSF3[i]
			Endif
		Next i
	Endif
EndIf
//���������������������������������������������������������������������������������������������Ŀ
//� Acumula valores de operacoes interestaduais                                                 �
//�����������������������������������������������������������������������������������������������
dAuxData := F3_ENTRADA
_cESTADO := GetMv("MV_ESTADO")
IF Empty(F3_DTCANC) //Nao gera resumo para notas fiscais canceladas 
	IF lAglutina .And. nTipomov <> 1
	   cAliasSF3 :=ALIAS()
	   dbSelectArea("SF3")
	   dbsetorder(1)
	   //�������������������������������������������������������������������������Ŀ
	   //�Verifica se o mes/ano da chave e o mesmo do mes que esta sendo processado�
	   //�para nao aglutinar varios meses em um resumo somente.                    �
	   //���������������������������������������������������������������������������
	   (cArqSF3)->(dbSetOrder(2))
	   (cArqSF3)->(dbGoTop())
	   (cArqSF3)->(dbseek(" " + StrZero(Month(dAuxData),2) + StrZero(Year(dAuxData),4)))
	   While !(cArqSF3)->(EOF()) .And. ;
		   StrZero(Month(dAuxData),2) == (cArqSF3)->MES .And. ;
		   StrZero(Year(dAuxData),4) == (cArqSF3)->ANO
		   //�����������������������������������������������������Ŀ
		   //�Posiciona na filial em que foi processado o registro	�
   		   //�������������������������������������������������������
           Mtr930Fil(aAreaSM0,(cArqSF3)->FILIAL,1)

           //������������������������������������������������������������������������Ŀ
		   //�Verifica o valor do ICMS Retido de acordo com a configuracao da TES     �
		   //�Quando o campo F3_CREST existir e estiver configurado como "4",         �
		   //�o valor do ICMS retido nao deve ser apresentado na coluna de observacoes�
		   //��������������������������������������������������������������������������
           lProcST := .T.
		   If lCredST
				If F3_CREDST == "4" .And. lP1IcmST .And. F3_CFO < "5"
					lProcST := .T.
				Elseif (cArqTemp)->F3_CREDST == "4" .And. !lP1IcmST .And. (cArqTemp)->F3_CFO < "5"
					lProcST	:= .F.  
				Elseif F3_CREDST == "4" .And. lExist
					lProcST := .F. 
				Elseif !lExist
					lProcST := .T.
				Endif
           Endif

	       IF (cArqSF3)->CONTR!="*"
	          dbseek((cArqSF3)->CHAVE)
	          nLenForm	:=	Len(&(AllTrim(IndexKey())))
	          If !Len(AllTrim((cArqSF3)->CHAVE))==(nLenForm-nFilchave)
	          	cFormla	:=	AllTrim(SubStr(AllTrim((cArqSF3)->CHAVE),nLenForm+1))
	          	While !Eof() .And. &(AllTrim(IndexKey()))==SubStr(AllTrim((cArqSF3)->CHAVE),1,Len(&(AllTrim(IndexKey()))))
	          		If cFormla==AllTrim(F3_FORMULA)
	          			Exit
	          		EndIf
					dbSkip()
	          	EndDo 
              Else
				dbSkip()
	          EndIf 
	          If .T. //F3_ESTADO!="EX"
					If F3_FORMUL<>"S"
	 	            cClieFor	:=	F3_CLIEFOR+F3_LOJA
		            If nTipoMov==1
		               If(F3_TIPO$"DB",dbSelectArea("SA1"),dbSelectArea("SA2"))
		            Else
		               If(F3_TIPO$"DB",dbSelectArea("SA2"),dbSelectArea("SA1"))
		            Endif   
		            dbSeek(F3Filial(Alias())+cClieFor) //xFilial()
		            dbSelectArea("SF3")		
		            If nTipoMov==1
			           cInscr	:= If( F3_TIPO$"DB",SA1->A1_INSCR,SA2->A2_INSCR)
			           cTipo   	:= If( F3_TIPO$"DB",SA1->A1_TIPO,SA2->A2_TIPO)
	                else
			           cInscr	:= If( F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)
	 		           cTipo 	:= If( F3_TIPO$"DB",SA2->A2_TIPO,SA1->A1_TIPO)
	                EndIf   
					If (ALLTRIM(F3_CFO)$"618/619/545/645/553/653/751/563/663") .Or. (ALLTRIM(F3_CFO)$"6107/6108/5258/6258/5307/6307/5357/6357") .or. "ISENT" $Upper(cInscr) .or. (empty(cInscr) .and. cTipo != "L")
	                   cContrib := "NC"
		            Else          
			           cContrib :=	"CO"
		            EndIf
		            if nTipoMov==1
			           cContrib :=	"CO"
		            EndIf	
		            nPos:=Ascan(aResumo,{|x|x[1]==cContrib.and.x[2]==F3_ESTADO})
		            If (Subs(F3_CFO,1,3) $ "999#000") // nao imprimi demonstrativo para transferencias	
		               If nPos==0
			              AADD(aResumo,{	cContrib,;					// [1] Flag de Contribuinte
			              F3_ESTADO,;					// [2] Estado
			              0.00,;	// [3] Valor Contabil
			              0.00,;	// [4] Base de Calculo
			              0.00,;	// [5] ICMS Outras
			              0.00,;	// [6] ICMS Retido
			              0.00,;	// [7] ICMS Isento
			           	  0.00,;	// [08] Valor do ICMS 
			           	  0.00,;	// [09] Base de Calculo IPI
			           	  0.00,;	// [10] Valor do IPI  
			           	  0.00,;	// [11] IPI Isento    
                          0.00,;   // [12] IPI Outras 
					      0.00,;  // [13] ICMS NORMAL
					      0.00,;  // [14] ICMS ST. INT.
					      0.00,; 	// [15] CRED PRES ST
					      _cESTADO,; 	// [16] UF onde esta localizada a Matriz/Filial    
					      0.00,;                // [17] Valor antecipacao
					      0.00,;                // [18] Valor ICMS sem debito decreto 43.080/02
					      0.00})				// [19] Valor incentivo a prod.leite-MG					      
		               Endif
		            Else
		               If nPos==0
						If F3_TIPO<>"S"                   
			                   If lRemAmb
			                       AADD(aResumo,{	cContrib,;					// [1] Flag de Contribuinte
			                       F3_ESTADO,;					// [2] Estado
			                       0,;	// [3] Valor Contabil
			                       0,;	// [4] Base de Calculo
			                       0,;	// [5] ICMS Outras             
						           0,;	// [6] ICMS Retido
					   	           0,;	// [7] ICMS Isento
			           	           0,;	// [08] Valor do ICMS 
			           	           0,;	// [09] Base de Calculo IPI
			           	           0,;	// [10] Valor do IPI  
			           	           0,;	// [11] IPI Isento    
			           	           0,; // [12] IPI Outras 
			           	           0,;  // [13] ICMS NORMAL  
			           	           0,;  // [14] ICMS ST. INT.	
			           	           0,; //[15] CRED PRES ST
			           	           _cESTADO ,; 				// [16] UF onde esta localizada a Matriz/Filial
					               0,;	   	// [17] Valor antecipacao			           	  
			                       0,;   	// [18] Valor ICMS sem debito de impsoto decreto 43.080/02			        
			                       0})      // [19] Valor incentivo a prod.leite-MG
			                   Else  
			                       AADD(aResumo,{	cContrib,;					// [1] Flag de Contribuinte
			                       F3_ESTADO,;					// [2] Estado
			                       F3_VALCONT,;	// [3] Valor Contabil
			                       F3_BASEICM,;	// [4] Base de Calculo
			                       F3_OUTRICM,;	// [5] ICMS Outras             
						           Iif(lProcST,F3_ICMSRET-IIF(lExist,F3_OBSSOL,0),0),;	// [6] ICMS Retido
					   	           F3_ISENICM,;	// [7] ICMS Isento
			           	           F3_VALICM,;	// [08] Valor do ICMS 
			           	           F3_BASEIPI,;	// [09] Base de Calculo IPI
			           	           F3_VALIPI,;	// [10] Valor do IPI  
			           	           F3_ISENIPI,;	// [11] IPI Isento    
			           	           F3_OUTRIPI,; // [12] IPI Outras 
			           	           IIF(lExist,F3_OBSICM,0),;  // [13] ICMS NORMAL  
			           	           IIF(lExist,F3_OBSSOL,0),;  // [14] ICMS ST. INT.	
			           	           IIF(lProcST .And. FieldPos ("F3_CRPRST")>0, F3_CRPRST, 0),; //[15] CRED PRES ST
			           	           _cESTADO,; 				// [16] UF onde esta localizada a Matriz/Filial
					               IIF(lAntiICM, F3_VALANTI,0),;	   	// [17] Valor antecipacao			           	  
			                       IIF(lRed43080, F3_VL43080,0),;   	// [18] Valor ICMS sem debito de impsoto decreto 43.080/02			        
			        	           IIF(lIncLeite, F3_VLINCMG,0)})      // [19] Valor incentivo a prod.leite-MG
			        	       EndIf
			        	   Endif
		               Else 
						If F3_TIPO<>"S"
			                   If lRemAmb
			                       aResumo[nPos,3]+=0
			                       aResumo[nPos,4]+=0
			                       aResumo[nPos,5]+=0
				                   aResumo[nPos,6]+=0
				                   aResumo[nPos,7]+=0
		           		           aResumo[nPos,08]+=0
				           	       aResumo[nPos,09]+=0
				           	       aResumo[nPos,10]+=0
					           	   aResumo[nPos,11]+=0
					           	   aResumo[nPos,12]+=0		              
					           	   aResumo[nPos,13]+=0
					           	   aResumo[nPos,14]+=0
					           	   aResumo[nPos,15]+=0
					           	   aResumo[nPos,17]+=0
					           	   aResumo[nPos,18]+=0			           	  
					           	   aResumo[nPos,19]+=0			           	  
							   Else
				                   aResumo[nPos,3]+=F3_VALCONT
				                   aResumo[nPos,4]+=F3_BASEICM
				                   aResumo[nPos,5]+=F3_OUTRICM
					               aResumo[nPos,6]+=Iif(lProcST,F3_ICMSRET-IIF(lExist,F3_OBSSOL,0),0)
					               aResumo[nPos,7]+=F3_ISENICM
			           		       aResumo[nPos,08]+=F3_VALICM
					           	   aResumo[nPos,09]+=F3_BASEIPI
					           	   aResumo[nPos,10]+=F3_VALIPI
					           	   aResumo[nPos,11]+=F3_ISENIPI
					           	   aResumo[nPos,12]+=F3_OUTRIPI		              
					           	   aResumo[nPos,13]+=IIF(lExist,F3_OBSICM,0)
					           	   aResumo[nPos,14]+=IIF(lExist,F3_OBSSOL,0)
					           	   aResumo[nPos,15]+=IIF(lProcST .And. FieldPos ("F3_CRPRST")>0, F3_CRPRST,0)
					           	   aResumo[nPos,17]+=IIF(lAntiICM, F3_VALANTI,0)
					           	   aResumo[nPos,18]+=IIF(lRed43080, F3_VL43080,0)			           	  
					           	   aResumo[nPos,19]+=IIF(lIncLeite, F3_VLINCMG,0)		           	  
					   		   Endif
			               Endif
                       EndIf
		            Endif   
	             Endif     
	          Endif   
	 		  RecLock(cArqSF3,.F.)
	          (cArqSF3)->CONTR :="*"
	          (cArqSF3)->(MsUnLock())
	       Endif   
	       (cArqSF3)->(dbseek(" "))
	       dbSelectArea("SF3")
	       Mtr930Fil(aAreaSM0,(cArqSF3)->FILIAL,2)
	   Enddo
	   (cArqSF3)->(dbSetOrder(1))
	   dbselectarea(cAliasSF3)
	Else                                           
  	   Mtr930Fil(aAreaSM0,cFilProc,1)
	   If .T. //F3_ESTADO!="EX"
		  cClieFor	:=	F3_CLIEFOR+F3_LOJA
		  If nTipoMov==1
		     If(F3_TIPO$"DB",dbSelectArea("SA1"),dbSelectArea("SA2"))
		  Else
		     If(F3_TIPO$"DB",dbSelectArea("SA2"),dbSelectArea("SA1"))
		  Endif   
		  dbSeek(F3Filial(Alias())+cClieFor)   //xFilial()
		  dbSelectArea(cArqTemp)                                                		
          //������������������������������������������������������������������������Ŀ
		  //�Verifica o valor do ICMS Retido de acordo com a configuracao da TES     �
		  //�Quando o campo F3_CREST existir e estiver configurado como "4",         �
		  //�o valor do ICMS retido nao deve ser apresentado na coluna de observacoes�
		  //��������������������������������������������������������������������������
          lProcST := .T.
		  If lCredST
          	 	If F3_CREDST == "4" .And. lP1IcmST .And. F3_CFO < "5"
                  	lProcST := .T.
             	Elseif (cArqTemp)->F3_CREDST == "4" .And. !lP1IcmST .And. (cArqTemp)->F3_CFO < "5"
 					lProcST	:= .F.  
             	Elseif F3_CREDST == "4" .And. lExist
                  	lProcST := .F. 
             	Elseif !lExist
				  	lProcST := .T.
             	Endif
          Endif
		  If nTipoMov==1
			 cInscr	:= If( F3_TIPO$"DB",SA1->A1_INSCR,SA2->A2_INSCR)
			 cTipo   	:= If( F3_TIPO$"DB",SA1->A1_TIPO,SA2->A2_TIPO)
	      else
			 cInscr	:= If( F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)
	 		 cTipo 	:= If( F3_TIPO$"DB",SA2->A2_TIPO,SA1->A1_TIPO)
	      EndIf   
		  If (ALLTRIM(F3_CFO)$"618/619/545/645/553/653/751/563/663") .Or. (ALLTRIM(F3_CFO)$"6107/6108/5258/6258/5307/6307/5357/6357") .or. "ISENT" $Upper(cInscr) .or. (empty(cInscr) .and. cTipo != "L")
	         cContrib := "NC"
		  Else          
			 cContrib :=	"CO"
		  EndIf
		  if nTipoMov==1
			 cContrib :=	"CO"
		  EndIf	
		  nPos:=Ascan(aResumo,{|x|x[1]==cContrib.and.x[2]==F3_ESTADO})
	      If (Subs(F3_CFO,1,3) $ "999#000") // nao imprimi demonstrativo para transferencias	
		     If nPos==0
			    AADD(aResumo,{	cContrib,;					// [1] Flag de Contribuinte
	  		    F3_ESTADO,;					// [2] Estado
			    0.00,;	// [3] Valor Contabil
			    0.00,;	// [4] Base de Calculo
			    0.00,;	// [5] ICMS Outras
			    0.00,;	// [6] ICMS Retido
	           	0.00,;	// [7] ICMS Isento
	   	    	0.00,;	// [08] Valor do ICMS 
		    	0.00,;	// [09] Base de Calculo IPI
		    	0.00,;	// [10] Valor do IPI  
		    	0.00,;	// [11] IPI Isento    
                0.00,;  // [12] IPI Outras 
			    0.00,;  // [13] ICMS NORMAL
		        0.00,;  // [14] ICMS ST. INT.
		        0.00,;  // [15] CRED PRES ST 
		        GetMv("MV_ESTADO"),; 	// [16] UF onde esta localizada a Matriz/Filial
     		    0.00,;					// [17] Valor antecipacao  
     		    0.00,;					// [18] Valor ICMS sem debito de impsoto decreto 43.080/02
     		    0.00})					// [19] Valor incentivo a prod.leite-MG
	         Endif
	      Else
		     If nPos==0
		         If lRemAmb
			         AADD(aResumo,{	cContrib,;					// [1] Flag de Contribuinte
	  		         F3_ESTADO,;					// [2] Estado
  				     0,;	// [3] Valor Contabil
   				     0,;	// [4] Base de Calculo
				     0,;	// [5] ICMS Outras
				     0,;	// [6] ICMS Retido
				     0,;			// [7] ICMS Isento
				     0,;			// [08] Valor do ICMS 
				     0,;			// [09] Base de Calculo IPI
				     0,;			// [10] Valor do IPI  
				     0,;			// [11] IPI Isento    
				     0,;			// [12] IPI Outras 
				     0,;	// [13] ICMS NORMAL   
				     0,;	// [14] ICMS ST. INT.
	            	 0,;//[15] CRED PRES ST
	            	 GetMv("MV_ESTADO"),;  								// [16] UF onde esta localizada a Matriz/Filial
	 		         0,;		// [17] Valor antecipacao
	 		         0,;		// [18] Valor ICMS sem debito de imposto decreto 43.080/02
	 		         0})		// [19] Valor incentivo a prod.leite-MG
			     Else
			         AADD(aResumo,{	cContrib,;					// [1] Flag de Contribuinte
	  		         F3_ESTADO,;					// [2] Estado
  				     aSF3[ColF3("F3_VALCONT")],;	// [3] Valor Contabil
   				     aSF3[ColF3("F3_BASEICM")],;	// [4] Base de Calculo
				     aSF3[ColF3("F3_OUTRICM")],;	// [5] ICMS Outras
				     Iif(lProcST,aSF3[ColF3("F3_ICMSRET")]-IIF(lExist,aSF3[ColF3("F3_OBSSOL")],0),0),;	// [6] ICMS Retido
				     aSF3[ColF3("F3_ISENICM")],;			// [7] ICMS Isento
				     aSF3[ColF3("F3_VALICM")],;			// [08] Valor do ICMS 
				     aSF3[ColF3("F3_BASEIPI")],;			// [09] Base de Calculo IPI
				     aSF3[ColF3("F3_VALIPI")],;			// [10] Valor do IPI  
				     aSF3[ColF3("F3_ISENIPI")],;			// [11] IPI Isento    
				     aSF3[ColF3("F3_OUTRIPI")],;			// [12] IPI Outras 
				     IIF(lExist,aSF3[ColF3("F3_OBSICM")],0),;	// [13] ICMS NORMAL   
				     IIF(lExist,aSF3[ColF3("F3_OBSSOL")],0),;	// [14] ICMS ST. INT.
	            	 IIF(lProcST .And. FieldPos ("F3_CRPRST")>0, aSF3[ColF3("F3_CRPRST")], 0),;//[15] CRED PRES ST
	            	 GetMv("MV_ESTADO"),;  								// [16] UF onde esta localizada a Matriz/Filial
	 		         IIF(lAntiICM, aSF3[ColF3("F3_VALANTI")],0),;		// [17] Valor antecipacao
	 		         IIF(lRed43080, aSF3[ColF3("F3_VL43080")],0),;		// [18] Valor ICMS sem debito de imposto decreto 43.080/02
	 		         IIF(lIncLeite, aSF3[ColF3("F3_VLINCMG")],0)})		// [19] Valor incentivo a prod.leite-MG
			     EndIf
		     Else 
		        If !lRemAmb
			        aResumo[nPos,03]+=aSF3[ColF3("F3_VALCONT")]
			        aResumo[nPos,04]+=aSF3[ColF3("F3_BASEICM")]
			        aResumo[nPos,05]+=aSF3[ColF3("F3_OUTRICM")]
			        aResumo[nPos,06]+=Iif(lProcST,(aSF3[ColF3("F3_ICMSRET")]-IIF(lExist,aSF3[ColF3("F3_OBSSOL")],0)),0)
			        aResumo[nPos,07]+=aSF3[ColF3("F3_ISENICM")]
			        aResumo[nPos,08]+=aSF3[ColF3("F3_VALICM")]
			        aResumo[nPos,09]+=aSF3[ColF3("F3_BASEIPI")]
			        aResumo[nPos,10]+=aSF3[ColF3("F3_VALIPI")]
			        aResumo[nPos,11]+=aSF3[ColF3("F3_ISENIPI")]
			        aResumo[nPos,12]+=aSF3[ColF3("F3_OUTRIPI")]
			        aResumo[nPos,13]+=IIF(lExist,aSF3[ColF3("F3_OBSICM")],0)
			        aResumo[nPos,14]+=IIF(lExist,aSF3[ColF3("F3_OBSSOL")],0)
			        aResumo[nPos,15]+=IIF(lProcST .And. FieldPos ("F3_CRPRST")>0,aSF3[ColF3("F3_CRPRST")],0)
                    aResumo[nPos,17]+=IIF(lAntiICM, aSF3[ColF3("F3_VALANTI")],0)	
                    aResumo[nPos,18]+=IIF(lRed43080, aSF3[ColF3("F3_VL43080")],0)		           	  
	                aResumo[nPos,19]+=IIF(lIncLeite, aSF3[ColF3("F3_VLINCMG")],0)		           	  
		        EndIf
		     Endif
		  Endif   
	   Endif
	   //����������������������������������Ŀ
	   //�Restaura a filial e area corrente �
	   //������������������������������������
	   Mtr930Fil(aAreaSM0,cFilProc,2)
	Endif
Endif
dbSelectArea(cSvAlias)

RETURN
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � LivrArrayObs �Autor � Juan Jose Pereira    �Data� 17/02/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria array com mensagens da coluna de observacoes          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static FUNCTION LivrArrayObs(nTamObs,aArray, lListaNFO)

Local aSF3 		:= SF3->(GetArea())
Local aColObs	:= {}, lArray:=(aArray==NIL), xx:=0, cMensagem := ""
Local aSave		:= {Alias(),IndexOrd(),Recno()}
Local lExist 	:= Iif(lArray,Iif((cArqTemp)->F3_OBSSOL>0,.T.,.F.),Iif(aArray[FieldPos("F3_OBSSOL")]>0,.T.,.F.))
Local aArea 	:= {}
Local aAreaSM0 	:= SM0->(GetArea())
Local lCredST	:= SF3->(FieldPos("F3_CREDST")) > 0
Local lP1IcmST		:= GetNewPar("MV_P1ICMST",.F.)
Local lProcST	:= .F.
// Verifica se o valor do ICMS do frete autonomo devera ser apresentado nas observacoes do livro
Local lIcmAuto	:= GetNewPar("MV_FAUT930",.T.)
Local lAntiICM	:= SF3->(FieldPos("F3_VALANTI")) > 0
Local lRedMG    := Iif(SF3->(FieldPos("F3_DS43080")) > 0, .T. , .F.)      
Local lIncMG    := Iif(SF3->(FieldPos("F3_VLINCMG")) > 0, .T. , .F.)      
Local lMatr930A	:= (ExistBlock("MATR930A"))     

Default lListaNFO	:=	.F.

if type( "nColuna" ) =="U"
	nColuna := 1
EndIF

//�����������������������������������������������������Ŀ
//�Posiciona na filial em que foi processado o registro	�
//�������������������������������������������������������
Mtr930Fil(aAreaSM0,(cArqTemp)->FILCORR,1) 

//�����������������������������������������������������������������������������������������Ŀ
//� Este posicionamento se faz necessario quando da utilizacao dos campos do SF3 na formula �
//�������������������������������������������������������������������������������������������
//dbSelectArea("SF3")
SF3->(dbSetOrder(1))
SF3->(dbSeek(xFilial("SF3")+DTOS((cArqTemp)->F3_ENTRADA)+(cArqTemp)->F3_NFISCAL+(cArqTemp)->F3_SERIE+(cArqTemp)->F3_CLIEFOR+(cArqTemp)->F3_LOJA+(cArqTemp)->F3_CFO+STR((cArqTemp)->F3_ALIQICM,5,2)))

//������������������������������������������������������������������������Ŀ
//�Verifica o valor do ICMS Retido de acordo com a configuracao da TES     �
//�Quando o campo F3_CREST existir e estiver configurado como "4",         �
//�o valor do ICMS retido nao deve ser apresentado na coluna de observacoes�
//��������������������������������������������������������������������������
lProcST := .T.
If lCredST
	If (cArqTemp)->F3_CREDST == "4" .And. lP1IcmST .And. (cArqTemp)->F3_CFO < "5"
		lProcST := .T.
	Elseif (cArqTemp)->F3_CREDST == "4" .And. !lP1IcmST .And. (cArqTemp)->F3_CFO < "5"
 		lProcST	:= .F. 
	Elseif (cArqTemp)->F3_CREDST == "4" .And. lExist
		lProcST := .F.
	Elseif !lExist
		lProcST := .T.
	Endif
Endif

If lArray
   If !Empty(F3_OBSERV)
	   	aArea := GetArea ()
	   	//
   		If nModelo==1 .Or. nModelo==2
	   	   	If (lListaNFO) .And. ("N.F.ORIG.: DIVERSAS"$F3_OBSERV)
		   		cMensagem := Substr (F3_OBSERV, 1, At(":", F3_OBSERV)+1)
	   		    //
   	   			SD1->(DbSetOrder (1), MsSeek (xFilial ("SD1")+(cArqTemp)->F3_NFISCAL+(cArqTemp)->F3_SERIE+(cArqTemp)->F3_CLIEFOR+(cArqTemp)->F3_LOJA))
	   	   		//
   		   		Do While !SD1->(Eof ()) .And. xFilial ("SD1")==SD1->D1_FILIAL .And. (cArqTemp)->F3_NFISCAL==SD1->D1_DOC .And.;
   		   			(cArqTemp)->F3_SERIE==SD1->D1_SERIE .And. (cArqTemp)->F3_CLIEFOR==SD1->D1_FORNECE .And. (cArqTemp)->F3_LOJA==SD1->D1_LOJA
   		   			//
   	   				If !(AllTrim (SD1->D1_NFORI+"/"+SD1->D1_SERIORI)$cMensagem)
	   	   				cMensagem += AllTrim (SD1->D1_NFORI+"/"+SD1->D1_SERIORI)+", "
	   	   			EndIf
	   	   			SD1->(DbSkip ())
   		   		EndDo
   		   		//
		   		cMensagem := SubStr (cMensagem, 1, Len (cMensagem)-2)
		   	Else
				cMensagem := Trim(F3_OBSERV)
		    EndIf
   	  	Else
	   	   	If (lListaNFO) .And. (("Dev. terc. N.F.ORIG.: DIVERSAS"$F3_OBSERV) .Or. ("N.F.ORIG.: DIVERSAS"$F3_OBSERV))
		   		cMensagem := Substr (F3_OBSERV, 1, At(":", F3_OBSERV)+1)
	   		    //
   	   			SD2->(DbSetOrder (3), MsSeek (xFilial ("SD2")+(cArqTemp)->F3_NFISCAL+(cArqTemp)->F3_SERIE+(cArqTemp)->F3_CLIEFOR+(cArqTemp)->F3_LOJA))
	   	   		//
   		   		Do While !SD2->(Eof ()) .And. xFilial ("SD2")==SD2->D2_FILIAL .And. (cArqTemp)->F3_NFISCAL==SD2->D2_DOC .And.;
   		   			(cArqTemp)->F3_SERIE==SD2->D2_SERIE .And. (cArqTemp)->F3_CLIEFOR==SD2->D2_CLIENTE .And. (cArqTemp)->F3_LOJA==SD2->D2_LOJA
   		   			//
   	   				If !(AllTrim (SD2->D2_NFORI+"/"+SD2->D2_SERIORI)$cMensagem)
	   	   				cMensagem += AllTrim (SD2->D2_NFORI+"/"+SD2->D2_SERIORI)+", "
	   	   			EndIf
	   	   			SD2->(DbSkip ())
   		   		EndDo
   		   		//
		   		cMensagem := SubStr (cMensagem, 1, Len (cMensagem)-2)
		   	Else
				cMensagem := Trim(F3_OBSERV)
		    EndIf
   	  	EndIf
	   For xx:=1 to MlCount(cMensagem,nTamObs)
	  	   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx             
	   RestArea (aArea) 	
   Endif
   If !Empty(F3_FORMULA) .And. !( "CANCELADA"$F3_OBSERV .Or. "NF DENEGADA"$F3_OBSERV .Or. "NF INUTILIZADA"$F3_OBSERV  )	//"CANCELADA" ou DENEGADA ou INUTILIZADA
	   cMensagem:=Formula(F3_FORMULA)
		//������������������������������������������������������������Ŀ
		//�Tratamento especifico para escrituracao de Nota sobre Cupom.�
		//��������������������������������������������������������������
       If SuperGetMV("MV_LJLVFIS",,1) <> 2 .And. Valtype(cMensagem)=="C"	   
	      For xx:=1 to MlCount(cMensagem,nTamObs)
		      AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	      Next xx
	   Else
	      If Valtype(cMensagem)=="C"	      
		      If Alltrim(cMensagem) <> "S" .AND. !Empty(cMensagem)
		         For xx:=1 to MlCount(cMensagem,nTamObs)
			        AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
		         Next xx	      
		      EndIf
		  EndIf
	   EndIf
   Endif
   If (cArqTemp)->F3_VALOBSE>0 .And. (cArqTemp)->F3_VALCONT>0
      If FieldPos("F3_DESCZFR")>0 .And. F3_DESCZFR>0
         cMensagem:="DESCONTO.....: "+Alltrim(TransForm(F3_VALOBSE,PesqPict("SF3","F3_VALOBSE")))+" ,SENDO "+Alltrim(TransForm(F3_DESCZFR,PesqPict("SF3","F3_DESCZFR")))+" DESCONTO ZFM"
	  Else                                                                                                    
	     cMensagem:="DESCONTO.....: "+Alltrim(TransForm(F3_VALOBSE,PesqPict("SF3","F3_VALOBSE")))
	  Endif
	  //	   
	  For xx:=1 to MlCount(cMensagem,nTamObs)
	  	AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
  	  Next xx
   Else
       If (cArqTemp)->F3_VALOBSE>0 .And. (cArqTemp)->F3_VALCONT==0
	       cMensagem:="DESCONTO.....: "+Alltrim(TransForm(F3_VALOBSE,PesqPict("SF3","F3_VALOBSE"))) //"DESCONTO.....: "
	       For xx:=1 to MlCount(cMensagem,nTamObs)
		       AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	  	   Next xx
       Else
           If lRedMG 
               If (cArqTemp)->F3_DS43080>0
	               cMensagem:="DESCONTO.....: "+Alltrim(TransForm(F3_DS43080,PesqPict("SF3","F3_DS43080"))) //"DESCONTO.....: "
	               For xx:=1 to MlCount(cMensagem,nTamObs)
		               AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	  	           Next xx
	  	       EndIf    
	       EndIf
	   Endif
   Endif 
      
   If cMV_ESTADO=="SP" .And. (ALLTRIM(F3_CFO)$"1904/2904/5904/6904/")
       cMensagem:="REMESSA P/ VENDA FORA DO ESTABELECIMENTO: "+Alltrim(TransForm(F3_VALCONT,PesqPict("SF3","F3_VALCONT"))) //
       For xx:=1 to MlCount(cMensagem,nTamObs)
       AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
  	   Next xx
   EndIf
       
   If lIncMG
       If (cArqTemp)->F3_VLINCMG > 0
   		   SFT->(DbSetOrder (1), MsSeek (xFilial ("SFT")+Iif((cArqTemp)->F3_TIPO=="D","S","E")+(cArqTemp)->F3_SERIE+(cArqTemp)->F3_NFISCAL+(cArqTemp)->F3_CLIEFOR+(cArqTemp)->F3_LOJA))
   		   Do While !SFT->(Eof ()) .And. xFilial ("SFT")==SFT->FT_FILIAL .And. (cArqTemp)->F3_NFISCAL==SFT->FT_NFISCAL .And.;
   		   	   (cArqTemp)->F3_SERIE==SFT->FT_SERIE .And. (cArqTemp)->F3_CLIEFOR==SFT->FT_CLIEFOR .And. (cArqTemp)->F3_LOJA==SFT->FT_LOJA
 	   			If SFT->(FieldPos("FT_VLINCMG")) > 0 .And. SFT->(FieldPos("FT_PRINCMG")) > 0 
                    If SFT->FT_PRINCMG > 0
                        cMensagem:=Alltrim(TransForm(SFT->FT_PRINCMG,PesqPict("SFT","FT_PRINCMG")))+"% de Incentivo do leite-MG." 
                        For xx:=1 to MlCount(cMensagem,nTamObs)
                            AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
  	                    Next xx
                        Exit
                    EndIf
   	   			EndIf
	   			SFT->(DbSkip ())
		   EndDo
  	   EndIf    
   EndIf

   //
   If F3_IPIOBS>0
	   cMensagem:="IPI..........: "+Alltrim(TransForm(F3_IPIOBS,PesqPict("SF3","F3_IPIOBS")))
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif
   If Empty(cTitLivro) .and. F3_ICMSRET-IIF(lExist,F3_OBSSOL,0) >0  .and. (nColuna == 1 .Or. nColuna == 3) .And. lProcST
	   If !lExist
		   cMensagem:="BASE ICMS RET: "+Alltrim(TransForm(F3_BASERET,PesqPict("SF3","F3_BASERET")))
		   For xx:=1 to MlCount(cMensagem,nTamObs)
		   	   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
		   Next xx
   	   Endif    
	   cMensagem:="ICMS RETIDO..: "+Alltrim(TransForm(F3_ICMSRET-F3_OBSSOL,PesqPict("SF3","F3_ICMSRET")))
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
	   If FieldPos("F3_CRPRST")>0 .And. F3_CRPRST>0
   		cMensagem	:=	"CRED. PRES. ST: "+Alltrim (TransForm (F3_CRPRST, PesqPict ("SF3", "F3_CRPRST")))
	   	For xx:=1 to MlCount (cMensagem, nTamObs)
		   AADD (aColObs, {MemoLine (cMensagem, nTamObs, xx), .T.})
	   	Next xx
	   EndIf
   Endif
   If F3_ICMSCOM>0
	   cMensagem:="ICMS DIF.ALIQ: "+Alltrim(TransForm(F3_ICMSCOM,PesqPict("SF3","F3_ICMSCOM")))
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif
   If lAntiICM .And. F3_VALANTI>0
	   cMensagem:="ANTECI.ICMS"+Alltrim(TransForm(F3_VALANTI,PesqPict("SF3","F3_VALANTI")))
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif
   If F3_ICMAUTO>0 .And. lIcmAuto
	   cMensagem:="ICMS FRET.AUT: "+Alltrim(TransForm(F3_ICMAUTO,PesqPict("SF3","F3_ICMAUTO")))
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif
   If SF3->(FieldPos("F3_VALTST")) > 0 .And. F3_VALTST>0 .And. lIcmAuto
	   cMensagem:="ICMSST FR.AUT: "+Alltrim(TransForm(F3_VALTST,PesqPict("SF3","F3_VALTST")))
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif
   If F3_OBSICM>0
	   cMensagem:="ICMS NORMAL: "+Alltrim(TransForm(F3_OBSICM,PesqPict("SF3","F3_OBSICM")))
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif
   If lExist .and. F3_OBSSOL>0 .And. lProcST .And. (nColuna == 1 .Or. nColuna == 3)
	   	If lAntiICM .And. SuperGetMv("MV_ESTADO") == "SP"
		   	cMensagem:="ICMS ST. INT.: "+Alltrim(TransForm((F3_OBSSOL-F3_VALANTI),PesqPict("SF3","F3_OBSSOL")))
		Elseif lAntiICM .And. SuperGetMv("MV_ESTADO") == "SE"
		   	cMensagem:="" //"ICMS ST. INT.: "
		Else
	   		cMensagem:="ICMS ST. INT.: "+Alltrim(TransForm(F3_OBSSOL,PesqPict("SF3","F3_OBSSOL"))) //"ICMS ST. INT.: "
		Endif
	
		For xx:=1 to MlCount(cMensagem,nTamObs)
			AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   	Next xx
   Endif   
Else
   dbSelectArea(cArqTemp)
   If (aArray[FieldPos("F3_VALOBSE")]>0 .And. aArray[FieldPos("F3_VALCONT")]>0) .And. ((F3_VALOBSE>0 .And. F3_VALCONT>0) .Or. (cArqTemp)->(EOF()))
      cMensagem:="DESCONTO.....: "+Alltrim(TransForm(aArray[FieldPos("F3_VALOBSE")],PesqPict("SF3","F3_VALOBSE"))) //"DESCONTO.....: "
	  //
	  For xx:=1 to MlCount(cMensagem,nTamObs)
	  	 AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	  Next xx
   else
       If (aArray[FieldPos("F3_VALOBSE")]>0 .And. aArray[FieldPos("F3_VALCONT")]==0) .And. ((F3_VALOBSE>0 .And. F3_VALCONT==0) .Or. (cArqTemp)->(EOF()))
           cMensagem:="DESCONTO.....: "+Alltrim(TransForm(aArray[FieldPos("F3_VALOBSE")],PesqPict("SF3","F3_VALOBSE"))) //"DESCONTO.....: "
    	   For xx:=1 to MlCount(cMensagem,nTamObs)
	  	       AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	       Next xx
       Else
	       If lRedMG
	           If (aArray[FieldPos("F3_DS43080")]>0)
	               cMensagem:="DESCONTO.....: "+Alltrim(TransForm(aArray[FieldPos("F3_DS43080")],PesqPict("SF3","F3_DS43080"))) //"DESCONTO.....: "
	    	       For xx:=1 to MlCount(cMensagem,nTamObs)
		  	           AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
		           Next xx
	           EndIf
	       EndIf	       
       Endif
   Endif
   If aArray[FieldPos("F3_IPIOBS")]>0 
	   cMensagem:="IPI..........: "+Alltrim(TransForm(aArray[FieldPos("F3_IPIOBS")],PesqPict("SF3","F3_IPIOBS"))) //"IPI..........: "
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif
   If Empty(cTitLivro).and.aArray[FieldPos("F3_ICMSRET")]-IIF(lExist,aArray[FieldPos("F3_OBSSOL")],0) >0  .and. (nColuna == 1 .Or. nColuna == 3) .And. lProcST
	   If !lExist
		   cMensagem:="BASE ICMS RET: "+Alltrim(TransForm(aArray[FieldPos("F3_BASERET")],PesqPict("SF3","F3_BASERET"))) //"BASE ICMS RET: "
		   For xx:=1 to MlCount(cMensagem,nTamObs)
		  	   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	 	   Next xx
	   Endif	  
	   cMensagem:="ICMS RETIDO..: "+Alltrim(TransForm(aArray[FieldPos("F3_ICMSRET")]-aArray[FieldPos("F3_OBSSOL")],PesqPict("SF3","F3_ICMSRET"))) //"ICMS RETIDO..: "
	   For xx:=1 to MlCount(cMensagem,nTamObs)
	 	  AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
  	   Next xx
   	   If FieldPos("F3_CRPRST")>0 .And. aArray[FieldPos("F3_CRPRST")]>0
	   		cMensagem	:=	"CRED. PRES. ST: "+Alltrim (TransForm (aArray[FieldPos("F3_CRPRST")], PesqPict ("SF3", "F3_CRPRST"))) //"CRED. PRES. ST: "
		   	For xx:=1 to MlCount (cMensagem, nTamObs)
			   AADD (aColObs, {MemoLine (cMensagem, nTamObs, xx), .T.})
		   	Next xx
	   EndIf
   Endif
   If aArray[FieldPos("F3_ICMSCOM")]>0
	   cMensagem:="ICMS DIF.ALIQ: "+Alltrim(TransForm(aArray[FieldPos("F3_ICMSCOM")],PesqPict("SF3","F3_ICMSCOM"))) //"ICMS DIF.ALIQ: "
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
 	   Next xx
   Endif
   If lAntiICM .And. aArray[FieldPos("F3_VALANTI")]>0 
	   cMensagem:="ANTECI.ICMS"+Alltrim(TransForm(aArray[FieldPos("F3_VALANTI")],PesqPict("SF3","F3_VALANTI"))) //"ANTECI.ICMS:"
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
 	   Next xx
   EndIf
   If aArray[FieldPos("F3_ICMAUTO")]>0 .And. lIcmAuto
	   cMensagem:="ICMS FRET.AUT: "+Alltrim(TransForm(aArray[FieldPos("F3_ICMAUTO")],PesqPict("SF3","F3_ICMAUTO"))) //"ICMS FRET.AUT: "
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif
   If SF3->(FieldPos("F3_VALTST")) > 0 .And. aArray[FieldPos("F3_VALTST")]>0 .And. lIcmAuto
	   cMensagem:="ICMSST FR.AUT: "+Alltrim(TransForm(aArray[FieldPos("F3_VALTST")],PesqPict("SF3","F3_VALTST"))) //"ICMSST FR.AUT: "
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif
   If aArray[FieldPos("F3_OBSICM")]>0
	   cMensagem:="ICMS NORMAL: "+Alltrim(TransForm(aArray[FieldPos("F3_OBSICM")],PesqPict("SF3","F3_OBSICM"))) //"ICMS NORMAL: "
	   For xx:=1 to MlCount(cMensagem,nTamObs)
		   AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   Next xx
   Endif   
   If lExist .and. aArray[FieldPos("F3_OBSSOL")]>0 .And. lProcST .And. (nColuna == 1 .Or. nColuna == 3)
		If lAntiICM .And. SuperGetMv("MV_ESTADO") == "SP"
			cMensagem:="ICMS ST. INT.: "+Alltrim(TransForm((aArray[FieldPos("F3_OBSSOL")]-aArray[FieldPos("F3_VALANTI")]),PesqPict("SF3","F3_OBSSOL"))) //"ICMS ST. INT.: "
		Elseif lAntiICM .And. SuperGetMv("MV_ESTADO") == "SE"
			cMensagem:="" //"ICMS ST. INT.: "
		Else
			cMensagem:="ICMS ST. INT.: "+Alltrim(TransForm(aArray[FieldPos("F3_OBSSOL")],PesqPict("SF3","F3_OBSSOL"))) //"ICMS ST. INT.: "
		Endif
	   
		For xx:=1 to MlCount(cMensagem,nTamObs)
			AADD(aColObs,{MemoLine(cMensagem,nTamObs,xx),.T.})
	   	Next xx

   Endif   
Endif   

//����������������������������������Ŀ
//�Restaura a filial e area corrente �
//������������������������������������
Mtr930Fil(aAreaSM0,(cArqTemp)->FILCORR,2)

RestArea(aSF3)
dbSelectArea(aSave[1])
dbSetOrder(aSave[2])
dbGoto(aSave[3])

If lMatr930A
	aAreaPe := getArea()
	aColObs := ExecBlock("MATR930A", .F., .F.,{aColObs})
	RestArea(aAreaPe)
Endif

Return (aColObs)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DefPeriodo   �Autor � Juan Jose Pereira    �Data� 17/02/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Define Periodo de Apuracao                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static FUNCTION DefPeriodo(dData,nApuracao)

Local nPeriodo
Local nMes	:=	Month(dData)
Local nAno	:=	Year(dData)
Local dIniMes
Local dFimMes
Local aPeriodos:={}

dIniMes :=  CTOD("01/"+StrZero(nMes,2)+"/"+Substr(StrZero(nAno,4),3),"ddmmyy")
dFimMes	:=	UltimoDia(dIniMes)
Do Case
	Case nApuracao==1 // Decendial
		AADD(aPeriodos,{dIniMes,dIniMes+9})
		AADD(aPeriodos,{dIniMes+10,dIniMes+19})
		AADD(aPeriodos,{dIniMes+20,dFimMes})
	Case nApuracao==2 // Quinzenal
		AADD(aPeriodos,{dIniMes,dIniMes+14})
		AADD(aPeriodos,{dIniMes+15,dFimMes})
	Otherwise // Mensal
		AADD(aPeriodos,{dIniMes,dFimMes})
EndCase
If dData==CTOD("  /  /  ")
	nPeriodo:=0
Else
	nPeriodo:=Ascan(aPeriodos,{|x|x[1]<=dData.and.x[2]>=dData})
Endif

Return (nPeriodo)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ColSF3       �Autor � Juan Jose Pereira    �Data� 17/02/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Armazena e devolve colunas do SF3                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static FUNCTION ColF3(cColuna)

Local i:=0

If cColuna==NIL
	aColunas:={}
	For i:=1 to FCount()
		AADD(aColunas,FieldName(i))
	Next i
Else
	i:=Ascan(aColunas,Trim(cColuna))
Endif

Return(i)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CtrlPg() � Autor � Juan Jose Pereira     � Data �02/02/1996���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controla numeracao de paginas dos livros fiscais           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static FUNCTION CtrlPg(nPagina,nQtdPag,lReiniPg)

Local lFeixe:=.f.
Local aPaginas:={0,0}

lReiniPg	:=	IIF(lReiniPg==NIL,.f.,lReiniPg)
nQtdPag	:=	IIf(Empty(nQtdPag) .or. nQtdPag<=0,500,nQtdPag)

If nPagAnt <> 0
	nPagina	:=	If(nPagina==1,0,nPagina)
Endif
If (nPagina%nQtdPag==0)
	If lReiniPg
		nPagina:=0
	Endif
	aPaginas[1]:=nPagina
	aPaginas[2]:=nPagina+1
	nPagina:=nPagina+IIf(nPagAnt<>0,2,1)
	lFeixe:=.t.
Else
	nPagina++
	If (nPagina%nQtdPag==0)
		If lReiniPg
			nPagina:=0
		Endif
		aPaginas[1]:=nPagina
		aPaginas[2]:=nPagina+1
		nPagina:=nPagina+IIf(nPagAnt<>0,2,1)
		lFeixe:=.t.
	Endif
Endif
Return(aPaginas)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ImprimeTermo�Autor� Juan Jose Pereira     � Data �02/02/1996���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime termos de abertura e encerramento dos livros fiscais���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static FUNCTION ImprimeTermo(nPagina,nPagIni,nQuebra,cArqTerm,nLargMax,cPerg)

Local cSvAlias := Alias()
Local i
Local aVariaveis := {}
Local w
Local j
Local cCaracter
Local cLinha
Local nPosAcento
Local cAcentos:="��\��\��\"+chr(65533)+"�\��\��\��\��\"+chr(65533)+"�\��\��\��\��\��\��\��\��\��"
Local cAcSubst:="C,\c,\A~\A'\a`\a~\a~\a'\E'\e^\e`\e'\i'\o^\o~\o`\o'\U'"
Local aLayOut:={}
Local cTexto
Local uConteudo
Local cConteudo

If nPagina==0.or.!File(cArqTerm)
	Return
Endif
aadd(aVariaveis,{"VAR_IXB",VAR_IXB})
dbSelectArea("SM0")
For i:=1 to FCount()
	If FieldName(i)=="M0_CGC"
		AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
	ElseIf FieldName(i)=="M0_INSC"
		AADD(aVariaveis,{FieldName(i),InscrEst()})
	Else
		If FieldName(i)=="M0_NOME"
			Loop
		Endif
		AADD(aVariaveis,{FieldName(i),FieldGet(i)})
	Endif
Next

If AliasIndic( "CVB" )
	dbSelectArea( "CVB" )
	CVB->(dbSeek( xFilial( "CVB" ) ))
	For i:=1 to FCount()
		If FieldName(i)=="CVB_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		ElseIf FieldName(i)=="CVB_CPF"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 999.999.999-99")})
		Else
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	Next
EndIf

_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
dbSelectArea(_cAliasSX1)
(_cAliasSX1)->(dbSetOrder(1))
dbSeek( padr( cPerg , Len( (_cAliasSX1)->X1_GRUPO ) , ' ' ) + "01" )
While (_cAliasSX1)->(!Eof()) .And. (_cAliasSX1)->X1_GRUPO  == padr( cPerg , Len( (_cAliasSX1)->X1_GRUPO ) , ' ' )
	uConteudo	:=	&(X1_VAR01)
	If Valtype(uConteudo)=="N"
		cConteudo	:=	Alltrim(Str(uConteudo))
	Elseif Valtype(uConteudo)=="D"
		cConteudo	:=	Alltrim(dToc(uConteudo))
	Else
		cConteudo	:=	Alltrim(uConteudo)
	Endif
	AADD(aVariaveis,{Rtrim(Upper((_cAliasSX1)->X1_VAR01)),cConteudo})
	(_cAliasSX1)->(dbSkip())
End
                        
//��������������������������������������������������������������Ŀ
//� Ordena os arrays colocando primeiro a variavel de tamanho    �
//� maior para que a rotina nao pegue uma variavel menor         �
//� primeiro ( exemplo M0_TEL e M0_TEL_IMP )                     �
//����������������������������������������������������������������
ASort( aVariaveis,,, { |x,y| Len( x[1] ) > Len( y[1] ) } ) 

AADD(aVariaveis,{"__PAGINAINICIAL",Transform(StrZero(nPagIni,6),"@R 999.999")})
AADD(aVariaveis,{"__PAGINAFINAL",Transform(StrZero(nPagina,6),"@R 999.999")})
//��������������������������������������������������������������Ŀ
//� Inclusao de variaveis especificas                            �
//����������������������������������������������������������������
AADD(aVariaveis,{"M_DIA",StrZero(Day(dDataBase),2)})
AADD(aVariaveis,{"M_MES",MesExtenso()})
AADD(aVariaveis,{"M_ANO",StrZero(Year(dDataBase),4)})

cTexto:=MemoRead(cArqTerm)
For w:=1 to len(aVariaveis)
	cTexto	:=	StrTran(cTexto,aVariaveis[w,1],if(valtype(aVariaveis[w,2])<>"C" .and. valtype(aVariaveis[w,2])<>"U",if(valtype(avariaveis[w,2])="D",dtoc(aVariaveis[w,2]),str(aVariaveis[w,2])),aVariaveis[w,2]))
Next
@ 0,0 PSAY AvalImp(nLargMax)

For i:=1 to Mlcount(cTexto,nLargMax)
	
	SysRefresh()
	If Interrupcao(@lAbortPrint)
		Exit
	Endif
	cLinha	:=	MemoLine(cTexto,nLargMax,i)
	cLinha	:=	Strtran(cLinha,chr(13)+chr(10))
	For j:=1 to Len(cLinha)
		cCaracter	:=	Substr(cLinha,j,1)
		nPosAcento	:=	Rat(cAcentos,cCaracter)
		If nPosAcento>0
			cCaracter:=Substr(AcSubst,nPosAcento,2)
			@ i,j PSAY Substr(cCaracter,1,1)
			@ i,j PSAY Substr(cCaracter,2,1)
		Else
			@ i,j PSAY cCaracter
		Endif
	Next j
Next i

dbSelectArea(cSvAlias)

Return (nPagina)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R930CFOTra �Autor�    Marcos Simidu      � Data �23/04/1997���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Analisa CFO de Servicos de Transporte.                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static FUNCTION R930CFOTra(cCFO,cSerie)

Local cAllCFO := "161/162/163/164/165/261/262/263/264/351/352/353/354/561/562/563/661/662/663/1351/1352/1353/1354/1355/1356/2351/2352/2353/2354/3351/3352/3353/3354/5351/5352/5357/6351/6352/6357"
Local cEspecie:= If( At(cCFO,cAllCFO) > 0, "CT" , "NF" )

If ( substr(cCFO,1,3) == "999" ) //Notas Canceladas
	cEspecie := a460Especie(cSerie)
EndIf

Return(cEspecie)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  ExistNF   �Autor�    Marcos Simidu      � Data �09/12/1997���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se existe NF em outro livro.                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ExistNF(cNota,cSerNF,cNumero,cLivros,cFilCorr)
Local lRet	:=.F.
Local cAlias:=Alias()                                  
Local aAreaSM0	:= SM0->(GetArea())

Default cFilCorr := ""

//�����������������������������������������������������Ŀ
//�Posiciona na filial em que foi processado o registro	�
//�������������������������������������������������������
Mtr930Fil(aAreaSM0,cFilCorr,1)

dbSelectArea("SF3")
dbSetOrder(5)
SF3->(dbSeek(xFilial()+cSerNF+cNota,.F.) .And. cNumero$cLivros)

while !eof() .and. xFilial("SF3")+SF3->F3_SERIE+SF3->F3_NFISCAL == xFilial("SF3")+cSerNF+cNota
	If Val(substr(F3_CFO,1,1))<5 .and. F3_FORMUL =="S"
		lRet:= .T.
		Exit
	ElseIf Val(substr(F3_CFO,1,1))>=5 
		lRet:= .T.
		Exit      
	EndIf
	dbSkip()
EndDo

//����������������������������������Ŀ
//�Restaura a filial e area corrente �
//������������������������������������
Mtr930Fil(aAreaSM0,cFilCorr,2)

dbSelectArea(cAlias)

Return(lRet)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  GravaTemp   �Autor �  Edstron             �Data� 06/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Registro no Arquivo Temporario                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GravaTemp(cNFIni,cNFFim,aFixos,aLivro,dData,cEst,cEsp,cCliente,cLoja,dDtCan1,cMov,lDesconto,nAliq,cSer,cCFO,cFormula,lSemMov,cFilProc,cAliasSf3)
Local i:=0
Default cFormula	:=SPACE(03)
Default lSemMov		:=.F.
Default cFilProc	:= xFilial("SF3")
Default cAliasSf3   := "SF3"

If !lSemMov
	dbSelectArea(cArqTemp)
	dbSeek(cFilProc+cSer+STRZERO(VAL(cNFIni),TamSX3("F2_DOC")[1])+Str(nAliq,5,2)+Iif ("S"$F3_TIPO, "999 ", cCFO)+cFormula,.F.)
	If !eof() 
		RecLock(cArqTemp,.F.)
		For i:=1 To Len(aFixos)
		    If aFixos[i,1]<>"XXX"
		       If ValType(aFixos[i,2])$"CD".Or.aFixos[i,1]=="F3_ALIQICM"
			      Replace &(aFixos[i,1]) With aLivro[i]
			   Else
	              If lAglutina .And. nTipomov <> 1
			         Replace &(aFixos[i,1]) With aLivro[i]
	              Else
			         Replace &(aFixos[i,1]) With &(aFixos[i,1])+aLivro[i]
			      Endif   
			   Endif   
			Endif   
		Next
	Else
	   RecLock(cArqTemp,.T.)
	   For i:=1 To Len(aFixos)
		   Replace &(aFixos[i,1]) With aLivro[i]
	   Next
	   (cArqTemp)->F3_FILIAL 	:= cFilProc
	   (cArqTemp)->F3_ENTRADA	:= dData
	   (cArqTemp)->F3_EMISSAO	:= dData
	   (cArqTemp)->F3_NFISCAL	:= cNFIni
	   (cArqTemp)->F3_SERIE  	:= cSer
	   (cArqTemp)->F3_ESTADO	:= cEst
	   (cArqTemp)->F3_ESPECIE	:= cEsp
	   (cArqTemp)->F3_CLIEFOR	:= cCliente
	   (cArqTemp)->F3_LOJA  	:= cLoja
	Endif
	(cArqTemp)->F3_DOCOR	:= If(Empty(SF3->F3_DOCOR),cNFFim,SF3->F3_DOCOR)
	//��������������������������������������������������������������Ŀ
	//� Corrige numeracao da Nota                                    �
	//����������������������������������������������������������������
	If cMov=="S"		//.and.lLacuna
	   (cArqTemp)->NUMNOTA := STRZERO(VAL(cNFIni),TamSX3("F2_DOC")[1])
	Endif
	//��������������������������������������������������������������Ŀ
	//� Zera valor de desconto para nao ser escriturado              �
	//����������������������������������������������������������������
	If !lDesconto
	   (cArqTemp)->F3_VALOBSE := 0
	Endif	
	IF !EMPTY(dDtCan1)
	   (cArqTemp)->F3_DTCANC := dDtCan1
	ENDIF
	//��������������������������������������������������������������Ŀ
	//� Altera registro de notas de Formulario Proprio na Saida e    �
	//� Notas fiscais de Servico                                     �
	//����������������������������������������������������������������
	If F3_FORMUL=="S" .or. F3_TIPO=="S" .or. !Empty(F3_DTCANC)
	   For i:=1 to FCount()
	       If Valtype(FieldGet(i))=="N"
		  	  FieldPut(i,0)
		   Endif
	   Next   
	   If F3_FORMUL=="S" .AND. Empty(F3_DTCANC)		
	 	 (cArqTemp)->F3_OBSERV := "NT.FISCAL DE ENTRADA" //"NT.FISCAL DE ENTRADA"
	   ElseIf F3_FORMUL=="S" .AND. !Empty(F3_DTCANC)
           If SF3->(FieldPos("F3_CODRSEF")) > 0 .And. F3_CODRSEF$"110,301,302,303,304,305,306"
              (cArqTemp)->F3_OBSERV := "NF DENEGADA" //"NF DENEGADA"
           ElseIf SF3->(FieldPos("F3_CODRSEF")) > 0 .And. F3_CODRSEF$"102" //"NF INUTILIZADA"
	          (cArqTemp)->F3_OBSERV := "NF INUTILIZADA"						
           Else
			 (cArqTemp)->F3_OBSERV := "CANCELADA" //"CANCELADA"
           EndIf
	   ElseIf !Empty(F3_DTCANC)
           If SF3->(FieldPos("F3_CODRSEF")) > 0 .And. F3_CODRSEF$"110,301,302,303,304,305,306"
              (cArqTemp)->F3_OBSERV := "NF DENEGADA" //"NF DENEGADA"
           ElseIf SF3->(FieldPos("F3_CODRSEF")) > 0 .And. F3_CODRSEF$"102" //"NF INUTILIZADA"
	          (cArqTemp)->F3_OBSERV := "NF INUTILIZADA"						
           Else
			 (cArqTemp)->F3_OBSERV := "CANCELADA" //"CANCELADA"
           EndIf
	   Else
		 (cArqTemp)->F3_OBSERV := "NT.FISCAL DE SERVICO" + " " + (cArqTemp)->F3_OBSERV
	   EndIf
	   (cArqTemp)->F3_CFO	:= "999"
	   (cArqTemp)->F3_TIPO	:= SF3->F3_TIPO
	Endif
	If (cArqTemp)->(FieldPos("F3_VL43080"))>0
	    (cArqTemp)->F3_VL43080	:= Iif((cAliasSf3)->(FieldPos("F3_VL43080"))>0, (cAliasSf3)->F3_VL43080, 0)                              
	EndIf
	If (cArqTemp)->(FieldPos("F3_DS43080"))>0
     	(cArqTemp)->F3_DS43080	:= Iif((cAliasSf3)->(FieldPos("F3_DS43080"))>0, (cAliasSf3)->F3_DS43080, 0)                              
	EndIf
	
	If cMV_ESTADO=="SP" .And. (ALLTRIM((cArqTemp)->F3_CFO)$"1904/2904/5904/6904/")
        (cArqTemp)->F3_BASEICM	:= 0
        (cArqTemp)->F3_VALICM	:= 0
        (cArqTemp)->F3_ALIQICM	:= 0
        (cArqTemp)->F3_ISENICM	:= 0        
        (cArqTemp)->F3_OUTICM	:= 0                           
        (cArqTemp)->F3_BASEIPI	:= 0
        (cArqTemp)->F3_VALIPI	:= 0
        (cArqTemp)->F3_ALIQIPI	:= 0
        (cArqTemp)->F3_ISENIPI	:= 0        
        (cArqTemp)->F3_OUTIPI	:= 0                           
	EndIf
	If (cArqTemp)->(FieldPos("F3_VLINCMG"))>0
	    (cArqTemp)->F3_VLINCMG	:= Iif((cAliasSf3)->(FieldPos("F3_VLINCMG"))>0, (cAliasSf3)->F3_VLINCMG, 0)                              
	EndIf

	(cArqTemp)->FILCORR := cFilAnt	                                                              	
	MsUnlock()		
Else
	//����������������������������������������������������������Ŀ
	//�Grava o registro para impress�o dos periodos sem movimento�
	//������������������������������������������������������������
	If len(aLivro) == 0
		RecLock(cArqTemp,.T.)
		(cArqTemp)->F3_FILIAL 	:= cFilProc
		(cArqTemp)->F3_ENTRADA	:= dData
		(cArqTemp)->F3_EMISSAO	:= dData
		(cArqTemp)->F3_NFISCAL	:= cNFIni
		(cArqTemp)->F3_SERIE  	:= cSer
		(cArqTemp)->F3_ESTADO	:= cEst
		(cArqTemp)->F3_ESPECIE	:= cEsp
		(cArqTemp)->F3_CLIEFOR	:= cCliente
		(cArqTemp)->F3_LOJA  	:= cLoja
		(cArqTemp)->SEMMOV 		:= .T.
		(cArqTemp)->FILCORR		:= cFilAnt	                                                              
		MsUnLock()
	EndIf
Endif
RETURN(.t.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTR930Apur�Autor  �Mary C. Hergert     � Data � 23/09/2004  ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica os dados da Apuracao de ICMS para impressao        ���
���          �do Resumo do Produtor Rural                                 ���
�������������������������������������������������������������������������͹��
���Uso       �RMATR930                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Mtr930Apur(nApurICM,nAno,nMes,cNrLivro)

	Local aArqApur	:= {}
	Local aCampos	:= {}                  
	Local aProdutor	:= {}
	Local nPeriodo	:= 0       
	Local nX		:= 0
	Local cArqApur	:= ""

	//�������������������������������������������Ŀ
	//�Valores adquiridos na apuracao (aProdutor):�
	//�001 - Estorno de Credito                   �
	//�002 - Saldo Credor do Periodo Anterior     �
	//�003 - Transfer�ncia de Cr�dito             �
	//���������������������������������������������
	AADD(aProdutor,{0,0,0,0})

	//������������������������������Ŀ
	//� Tipos de Apuracao (nApurICM):�
	//� 1 - Decendial                �
	//� 2 - Quinzenal                �
	//� 3 - Mensal                   �
	//��������������������������������
	Do Case
	Case nApurICM == 1 
		AADD(aArqApur,NmArqApur("IC",nAno,nMes,1,1,cNrLivro))
		AADD(aArqApur,NmArqApur("IC",nAno,nMes,1,2,cNrLivro))
		AADD(aArqApur,NmArqApur("IC",nAno,nMes,1,3,cNrLivro))
		AADD(aArqApur,NmArqApur("IC",nAno,nMes,1,4,cNrLivro))
	Case nApurICM == 2
		AADD(aArqApur,NmArqApur("IC",nAno,nMes,1,1,cNrLivro))
		AADD(aArqApur,NmArqApur("IC",nAno,nMes,1,2,cNrLivro))
	Case nApurICM == 3
		AADD(aArqApur,NmArqApur("IC",nAno,nMes,1,0,cNrLivro))
	EndCase
	
	For nX := 1 to Len(aArqApur)

		nPeriodo := nX
		cArqApur := aArqApur[nX]
	
		If (File(cArqApur))
			FT_FUse(cArqApur)
			FT_FGotop()
			aCampos		:=	{.f.,.f.,.f.,.f.,.f.}
			While (!FT_FEof()) 
				cLinha	:= AllTrim(FT_FReadLN())
                Do Case
                Case SubStr(cLinha,86,6) == "003.00" // Estorno de Credito
                	aProdutor[01][01] += Val(StrTran(StrTran(SubStr(cLinha,52,18),".",""),",","."))
                Case SubStr(cLinha,1,3) == "009" // Saldo Credor do Periodo Anterior
                	aProdutor[01][02] += Val(StrTran(StrTran(SubStr(cLinha,52,18),".",""),",","."))
                Case SubStr(cLinha,1,3) == "021" // Transferencia de Credito
	                aProdutor[01][03] += Val(StrTran(StrTran(SubStr(cLinha,52,18),".",""),",","."))
                Case SubStr(cLinha,1,3) == "001" // Por saidas com debito de imposto
	                aProdutor[01][04] += Val(StrTran(StrTran(SubStr(cLinha,52,18),".",""),",","."))
                EndCase
				FT_FSkip()
			Enddo
		EndIf
	Next
	FT_FUse()                   
	
Return(aProdutor)
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AjustaSX1 �Autor  �Mary C. Hergert     � Data � 23/09/2004  ���
�������������������������������������������������������������������������͹��
���Desc.     �Ajusta grupo de perguntas                                   ���
�������������������������������������������������������������������������͹��
���Uso       |RMATR930                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*
Static Function AjustaSX1()    

Local aHelpP  := {}
Local aHelpE  := {}
Local aHelpS  := {}  

Aadd( aHelpP, STR0056) // "Informe se a impress�o do livro dever� "
Aadd( aHelpP, STR0057) // "ser subdividida, ou seja, dever�o ser  " 
Aadd( aHelpP, STR0058) // "impressas: 1-Totalidade das opera��es  "
Aadd( aHelpP, STR0059) // "2-Opera��es estaduais ou 3 - Opera��es " 
Aadd( aHelpP, STR0060) // "interestaduais. No caso das opera��es  " 
Aadd( aHelpP, STR0061) // "estaduais ou interestaduaais, o livro  "
Aadd( aHelpP, STR0062) // "ser� impresso apenas com os movimentos "
Aadd( aHelpP, STR0063) // "estaduais ou interestaduais, sendo que "
Aadd( aHelpP, STR0064) // "o t�tulo do livro ir� indicar o tipo de"
Aadd( aHelpP, STR0065) // "opera��o apresentada. Caso selecione a "
Aadd( aHelpP, STR0066) // "op��o 1 (totalidade) o livro ir� gerar " 
Aadd( aHelpP, STR0067) // "todas as informa��es (estaduais e      " 
Aadd( aHelpP, STR0068) // "interestaduais) juntas, ordenadas por  " 
Aadd( aHelpP, STR0069) // "data e n�mero de documento.            " 
     
aHelpE := aHelpS := aHelpP

If SX1->(DbSeek("MTR930    "+"36"))
	If AllTrim(SX1->X1_DEF01) <> "Totalidade"
		RecLock("SX1",.F.)
			SX1->(DbDelete())
		SX1->(MsUnlock())
		
		PutSx1("MTR930","36",STR0070,STR0070,STR0070,"mv_chz","N",1,0,1,"C","","","","","mv_par36",STR0071,STR0071,STR0071,"",STR0072,STR0072,STR0072,STR0073,STR0073,STR0073,"","","","","","",aHelpP,aHelpE,aHelpS)	// "Opera��es a imprimir?"#"Estaduais"#"Interestaduais#Totalidade"				
	EndIf
Else
	PutSx1("MTR930","36",STR0070,STR0070,STR0070,"mv_chz","N",1,0,1,"C","","","","","mv_par36",STR0071,STR0071,STR0071,"",STR0072,STR0072,STR0072,STR0073,STR0073,STR0073,"","","","","","",aHelpP,aHelpE,aHelpS)	// "Opera��es a imprimir?"#"Estaduais"#"Interestaduais#Totalidade"					
EndIf



aHelpP  := {}
aHelpE  := {}
aHelpS  := {}

//���������Ŀ
//�Portugues�
//�����������
Aadd( aHelpP, "Na obriga��o da escriturac�o do livro ")
Aadd( aHelpP, "de acordo com o Mapa Resumo.  ")
Aadd( aHelpP, "Somente tem validade esta pergunta, se  ")
Aadd( aHelpP, "o par�metro MV_LJLVFIS for igual a 2. ")

//��������Ŀ
//�Espanhol�
//����������
Aadd( aHelpS, "En la obrigaci�n de la escrituraci�n del libro ")
Aadd( aHelpS, "de acuerdo con el Mapa Resumo.  ") 
Aadd( aHelpS, "Solamente tienda validad la pregunta,  ") 
Aadd( aHelpS, "con el parametro MV_LJLVFIS iqual a 2. ") 

//������Ŀ
//�Ingles�
//��������
Aadd( aHelpE, "In the obligation of the bookkeeping of the book ") 
Aadd( aHelpE, "in accordance with the Map Summary. ") 
Aadd( aHelpE, "This question only has validity, if ") 
Aadd( aHelpE, "equal parameter MV_LJLVFIS the 2. ") 

PutSx1("MTR930","37","Imprime Mapa Resumo ?","Emite Mapa Resumo ?","Printed Map Summary ?","mv_chz","N",01,0,2,"C","MatxRValPer(mv_par37)","","","","mv_par37","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpE,aHelpS)

//MV_PAR38
aHelpP  := {}
aHelpE  := {}
aHelpS  := {}

Aadd( aHelpP, "Informe se deseja imprimir Imposto a ser")
Aadd( aHelpP, "Ressarcido ou Complementado conforme")
Aadd( aHelpP, "Modelo 3 da Portaria CAT 17/99 - SP")
Aadd( aHelpE, "Inform if you need to print Tax to be")
Aadd( aHelpE, "Ressarcido or Com				l				plementado conforme")
Aadd( aHelpE, "Modelo 3 da Portaria CAT 17/99 - SP")
Aadd( aHelpS, "Informe se deseja emitir Impuesto a ser")
Aadd( aHelpS, "Ressarcido ou Complementado")
Aadd( aHelpS, "Modelo 3 da Portaria CAT 17/99 - SP")

PutSx1("MTR930","38","Imprime Imposto Res/Comp?","Emite Impuesto Res/Comp?","Print Tax Res/Comp?","mv_chz","N",01,0,2,"C","","","","","mv_par38","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHelpP,aHelpE,aHelpS)

//MV_PAR39
aHelpP  := {}
aHelpE  := {}
aHelpS  := {}
/*
Aadd( aHelpP, STR0076) //"No caso de Cupom Fiscal selecionar"
Aadd( aHelpP, STR0077) //"o artigo da PORTARIA CAT 55/98. "
Aadd( aHelpP, STR0078) //"Dependendo do artigo os campos ficam:"
Aadd( aHelpP, STR0079) //"25 - Especie = CF ,Serie/Subserie = ECF " 
Aadd( aHelpP, STR0080) //"26 - Especie = CF ,Serie/Sub= num. do PDV "
Aadd( aHelpP, STR0081) //"80 - Especie = CMR,Serie/Sub= num. do PDV "
Aadd( aHelpP, STR0082) //"81 - Especie = MRC,Serie/Subserie = CMR"

aHelpE := aHelpS := aHelpP

PutSx1("MTR930","39",STR0083,STR0083,STR0083,;//"Artigo para Impress�o"
"mv_chz","N",01,0,1,"C","","","","","mv_par39",;
STR0084,STR0084,STR0084,""	,;		// Combo 1 "Artigo 25"
STR0085,STR0085,STR0085,	;		// Combo 2 "Artigo 26" 
STR0086,STR0086,STR0086,	;		// Combo 3 "Artigo 80"
STR0087,STR0087,STR0087,	;		// Combo 4 "Artigo 81"
 ""		   , ""		   , "",);		// Combo 5
aHelpP,aHelpE,aHelpS)  

//��������������������Ŀ
//�Seleciona Filiais ? �
//���������������������� 
aHelpP  := {}
aHelpE  := {}
aHelpS  := {}
Aadd( aHelpP, "Informe de deseja efetuar a sele��o das")
Aadd( aHelpP, "Filiais a serem consideradas no ")
Aadd( aHelpP, "Processamento, rotina depende do par�metro")
Aadd( aHelpP, "Processa Filiais igual a SIM.")

Aadd( aHelpS, "Informe de deseja efetuar a sele��o das")
Aadd( aHelpS, "Filiais a serem consideradas no ")
Aadd( aHelpS, "Processamento, rotina depende do par�metro")
Aadd( aHelpS, "Processa Filiais igual a SIM.")

Aadd( aHelpE, "Informe de deseja efetuar a sele��o das")
Aadd( aHelpE, "Filiais a serem consideradas no ")
Aadd( aHelpE, "Processamento, rotina depende do par�metro")
Aadd( aHelpE, "Processa Filiais igual a SIM.")

PutSx1("MTR930","40","Seleciona Filiais ?","Seleciona Filiais ?","Seleciona Filiais ?","mv_chz","N",01,0,2,"C","","","","","mv_par40","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpE,aHelpS)

	//Imprime S�rie no Termo de Abertura: S/N
	aHelpPor	:=	{}
    aHelpEng	:=	{}
    aHelpSpa	:=	{} 

	Aadd( aHelpPor, "Informa se deseja imprimir    ")
	Aadd( aHelpPor, "a S�rie no Termo de Abertura  ")
    
	aHelpSpa := aHelpEng := aHelpPor
	
	PutSx1("MTR930","41","S�rie no Termo ?","S�rie no Termo  ?","S�rie no Termo ?",;
		"mv_chz","N",1,0,2,"C","","","","","mv_par41","Sim","Si","Yes","",;
		"Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)	
		
   //S�rie do Termo de Abertura			
	aHelpPor	:=	{}
	aHelpEng	:=	{}
	aHelpSpa	:=	{}	
	
	Aadd( aHelpPor, "Informe a S�rie/SubS�rie a ser impressa " )
	Aadd( aHelpPor, "no Termo de Abertura                    " )
	
	aHelpSpa := aHelpEng := aHelpPor
	
	PutSx1 ("MTR930","42","S�rie/SubS�rie","S�rie/SubS�rie","S�rie/SubS�rie","mv_chz","C",5,0,0,"G","","","","","mv_par42","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Impr. ICMS/IPI Zerado
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}	

Aadd(aHelpPor,"Se ICMS/IPI Zerado,demonstrando somente ")
Aadd(aHelpPor,"valor cont�bil sem Cod. Valores Fiscais.")

aHelpSpa := aHelpEng := aHelpPor
PutSx1("MTR930","43","Impr. ICMS/IPI Zerado ?","Impr. ICMS/IPI Zerado ?","Impr. ICMS/IPI Zerado ?","mv_chz","N",1,0,0,"C","","","","","mv_par43","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)			                                                                      
                                                                      
Return
*/
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Mtr930Fil �Autor  �Mary C. Hergert     � Data � 08/03/2006  ���
�������������������������������������������������������������������������͹��
���Desc.     �Posiciona a filial que esta sendo processada na filial      ���
���          �corrente do momento da gravacao do registro                 ���
�������������������������������������������������������������������������͹��
���Parametros�aAreaSM0 = Area do SM0 posicionada no processamento         ���
���          �cFilCorr = Filial armazenada na gravacao do registro        ���
���          �nTipo    = 1 - posiciona filial, 2 = retorna na filial      ���
�������������������������������������������������������������������������͹��
���Uso       �RMATR930                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Mtr930Fil(aAreaSM0,cFilCorr,nTipo)
							
Local aArea := GetArea()

If !Empty(cFilCorr)
	If nTipo == 1
		SM0->(dbSeek(cEmpAnt+cFilCorr,.T.))
		cFilAnt	:= FWCodFil()
	Else
		RestArea(aAreaSM0)
		cFilAnt	:= FWCodFil()
	Endif
Endif          

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Funcao   �VerificaR461� Autor � Murilo Alves      � Data � 04/08/2008 ���
�������������������������������������������������������������������������͹��
��� Desc.    � Verifica necessidade de impressao de informacao da ultima  ���
���          | folha do Relatorio de Controle de Estoque - imposto a ser  ���
���          | Ressarcido ou Complementado na  RMATR930					  ���
�������������������������������������������������������������������������͹��
��� Uso      � RMATR930, RMATR931, MATR932                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function VerificaR461()
//��������������������������������������������������������������Ŀ
//� Define variaveis                                             �
//����������������������������������������������������������������
PRIVATE aApurMod1 := array(15,5)
//��������������������������������������������������������������Ŀ
//� Apenas executa quando pergunta 38 for sim, e                 |
//� For modelo de saida P2 ou saida P2A                          �
//����������������������������������������������������������������
if mv_par38==2 .Or. !(mv_par03==3 .Or. mv_par03==4)
   return
endif
//��������������������������������������������������������������Ŀ
//� Cria arquivos temporarios                                    �
//����������������������������������������������������������������
cArqTMP	:=	FSCAT17INI(1)
//��������������������������������������������������������������Ŀ
//� Monta arquivo de Trabalho                                    �
//���������������������������������������������������������������� 
FSCAT17CAL(cArqTMP,mv_par01,mv_par02)
//��������������������������������������������������������������Ŀ
//� Ajusta os dados no Arquivo de Trabalho                       �
//����������������������������������������������������������������
FSCAT17TOT(cArqTMP,aApurMod1)
//��������������������������������������������������������������Ŀ
//� Imprime Controle de Estoque                                  �
//����������������������������������������������������������������
a461Apura(cArqTMP,1)
//��������������������������������������������������������������Ŀ
//� Apaga arquivos temporarios                                   �
//����������������������������������������������������������������
FSCAT17FIM(cArqTMP)

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ImpParSX1 � Autor � Nereu Humberto Junior � Data � 01.08.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de impressao da lista de parametros do SX1 sem cabec���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpListSX1(titulo,nomeprog,tamanho,char,lFirstPage)        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cTitulo - Titulo                                           ���
���          � cNomPrg - Nome do programa                                 ���
���          � nTamanho- Tamanho                                          ���
���          � nchar   - Codigo de caracter                               ���
���          � lFirstpage - Flag que indica se esta na primeira pagina    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ImpParSX1 (cTitulo,cNomPrg,nTamanho,nChar,lFirstPage)

Local cAlias,nLargura,nLin:=0, aDriver := ReadDriver(),nCont:= 0, cVar
Local lWin:=.F.

PRIVATE cSuf:=""

lWin := "DEFAULT"$ FWSFUser(PswRecno(),"PROTHEUSPRINTER","USR_DRIVEIMP")

nLargura   :=IIf(nTamanho=="P",80,IIf(nTamanho=="G",220,132))   
cTitulo    :=IIf(TYPE("NewHead")!="U",NewHead,cTitulo)
lFirstPage :=IIf(lFirstPage==Nil,.F.,lFirstPage)

If lFirstPage
	If GetMv("MV_SALTPAG",,"S") == "N"
		Setprc(0,0)
	EndIf	
	If nChar == NIL
		@ 0,0 PSAY AvalImp(nLargMax) 
	Else
		If nChar == 15
			@ 0,0 PSAY &(if(nTamanho=="P",aDriver[1],if(nTamanho=="G",aDriver[5],aDriver[3])))
		Else
			@ 0,0 PSAY &(if(nTamanho=="P",aDriver[2],if(nTamanho=="G",aDriver[6],aDriver[4])))
		EndIf
	EndIf
EndIf	

cFileLogo := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial
If !File( cFileLogo )
	cFileLogo := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
EndIf

__ChkBmpRlt( cFileLogo ) // Seta o bitmap, mesmo que seja o padr�o da microsiga

If GetMv("MV_IMPSX1") == "S" .And. Substr(cAcesso,101,1) == "S"  // Imprime pergunta no cabecalho
	If npag == 1
		nLin   := 0
		nLin   := SendCabec(lWin, nLargura, cNomPrg, RptParam+" - "+Alltrim(cTitulo), "", "", .F.)
		cAlias := Alias()

		_cAliasSX1 := "SX1"		//"SX1_"+GetNextAlias()
		OpenSxs(,,,,FWCodEmp(),_cAliasSX1,"SX1",,.F.)
		dbSelectArea(_cAliasSX1)
		(_cAliasSX1)->(dbSetOrder(1))
		(_cAliasSX1)->(dbSeek(cPerg))
		While (_cAliasSX1)->(!EOF()) .And. (_cAliasSX1)->X1_GRUPO = cPerg
			cVar := "MV_PAR"+StrZero(Val((_cAliasSX1)->X1_ORDEM),2,0)
			nLin += 1
			@ nLin,5 PSAY RptPerg+" "+ (_cAliasSX1)->X1_ORDEM + " : "+ ALLTRIM((_cAliasSX1)->X1_PERGUNTA)
			If X1_GSC == "C"
				xStr:=StrZero(&(cVar),2)
			EndIf
			@ nLin,Pcol()+3 PSAY IIF((_cAliasSX1)->X1_GSC!='C',&(cVar),IIF(&(cVar)>0,(_cAliasSX1)->X1_DEF==xStr,""))
			(_cAliasSX1)->(dbSkip())
		EndDo

		cFiltro := IIF(!Empty(aReturn[7]),MontDescr(cAlias,aReturn[7]),"")
		nCont := 1
		If !Empty(cFiltro)
			nLin += 2
			@ nLin,5  PSAY OemToAnsi("ICMS DIF.ALIQ: ") + Substr(cFiltro,nCont,nLargura-19)  // "Filtro      : "
			While Len(Alltrim(Substr(cFiltro,nCont))) > (nLargura-19)
				nCont += nLargura - 19
				nLin++
				@ nLin,19  PSAY  Substr(cFiltro,nCont,nLargura-19)
			End	
			nLin++
		EndIf
		nLin++
		@ nLin,00  PSAY REPLI("*",nLargura)
		dbSelectArea(cAlias)
	EndIf
EndIf

npag++

If Subs(__cLogSiga,4,1) == "S"
	__LogPages()
EndIf

Return Nil
