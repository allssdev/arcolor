#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tmkr3a.ch"
#define ENT (CHR(13)+CHR(10))
/*/{Protheus.doc} RTMKR3A
Emissao do Orcamentos de Vendas
@author Armando M. Tessaroli
@since 26/03/2003
@version P12
@type Function
@obs Sem observa��es
@see https://allss.com.br
@history 17/11/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajustes conforme solicita��o do cliente.
/*/
user function RTMKR3A()
local _lRet			:= .T.
private _cRotina 	:= "RTMKR3A"
if ExistBlock("RTMKR32A")
	ExecBlock("RTMKR32A")
else
	MsgAlert("Funcionalidade n�o dispon�vel, contate o administrador do sistema.")
	_lRet := .F.
endif
if _lRet
	if MsgBox('Deseja processar outro relat�rio?',_cRotina + '_01','YESNO')
		ExecBlock("RTMKR32A")
	endif
endif
return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � RTMKR32A    � Autor �                 � Data �  26/03/2003 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Processamento principal do relatorio						  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Programa principal	                                 	  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function RTMKR32A(cNumAte)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
local wnrel   	:= "RTMKR3A"  	 						// Nome do Arquivo utilizado no Spool
local Titulo 	:= "Relat�rio de Vendas - Televendas" 	//"Emissao do orcamento de Vendas - Televendas"
local cDesc1 	:= "Este programa ira emitir o orcamento de vendas criado no sistema"
local cDesc2 	:= "com ou sem liberacao ou a emissao da nota fiscal."
local cDesc3 	:= "Informe os parametros de selecao para emissao dos orcamentos"
local nomeprog	:= "RTMKR3A.PRX"						// nome do programa
local cString 	:= "SUA"								// Alias utilizado na Filtragem
local lDic    	:= .F. 									// Habilita/Desabilita Dicionario
local lComp   	:= .F. 									// Habilita/Desabilita o Formato Comprimido/Expandido
local lFiltro 	:= .T. 									// Habilita/Desabilita o Filtro
private Tamanho := "M" 									// P/M/G
private Limite  := 220 									// 80/132/220
private aReturn := { "Zebrado"		,;					// [1] Reservado para Formulario	//"Zebrado"
					 1				,;					// [2] Reservado para N� de Vias
					 "Administracao",;					// [3] Destinatario					//"Administracao"
					 2				,;					// [4] Formato => 1-Comprimido 2-Normal	
					 2				,;	    			// [5] Midia   => 1-Disco 2-Impressora
					 1				,;					// [6] Porta ou Arquivo 1-LPT1... 4-COM1...
					 ""				,;					// [7] Expressao do Filtro
					 1 				} 					// [8] Ordem a ser selecionada
					 									// [9]..[10]..[n] Campos a Processar (se houver)
private m_pag   := 1  									// Contador de Paginas
private nLastKey:= 0  									// Controla o cancelamento da SetPrint e SetDefault
private cPerg   := "TMK03A"  							// Pergunta do Relatorio
private aOrdem  := {}  									// Ordem do Relatorio
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)
//���������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                          �
//� mv_par01           // Do Vendedor                             �
//� mv_par02           // Ate o Vendedor                          �
//� mv_par03           // A Partir de                             �
//� mv_par04           // Ate o dia                               �
//� mv_par05           // Da Orcamento                            �
//� mv_par06           // Ate o Orcamento                         �
//�����������������������������������������������������������������
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
if (nLastKey == 27)
	DbSelectArea(cString)
	(cString)->(DbSetOrder(1))
	Set Filter to
	return
endif
SetDefault(aReturn,cString)
if (nLastKey == 27)
	dbSelectArea(cString)
	(cString)->(DbSetOrder(1))
	Set Filter to
	return
endif
RptStatus({|lEnd| TK3AImp(@lEnd,wnRel,cString,nomeprog,Titulo,cNumAte)},Titulo)
return(.T.)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TK3AImp  � Autor � Armando M. Tessaroli  � Data � 26/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Emissao do Orcamento de Vendas                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Televendas                                                 ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
static function TK3AImp(lEnd,wnrel,cString,nomeprog,Titulo,cNumAte)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao Do Cabecalho e Rodape    �
//����������������������������������������������������������������
local nLi		:= 0			// Linha a ser impressa
local nMax		:= 65			// Maximo de linhas suportada pelo relatorio
local cbCont	:= 0			// Numero de Registros Processados
local cbText	:= SPACE(10)	// Mensagem do Rodape
local cCabec1	:= "" 			// Label dos itens
local cCabec2	:= "" 			// Label dos itens
//�������������������������������������������������������Ŀ
//�Declaracao de variaveis especificas para este relatorio�
//���������������������������������������������������������
local cArqTrab	 := ""			// Nome do arquivo temporario
local cCodCli	 := ""			// Dados do cliente ou prospect
local cNome		 := ""			// Dados do cliente ou prospect
local cEnder	 := ""			// Dados do cliente ou prospect
local cCGC		 := ""			// Dados do cliente ou prospect
local cRG		 := ""			// Dados do cliente ou prospect
local cContato	 := ""			// Nome do contato
local cEntidade	 := ""			// Alias da entidade SA1 ou SUS
local cFormPag	 := ""			// Forma de pagamento
local aFatura	 := {}			// Dados da fatura
local nI		 := 0			// Controle
local nIteLin 	 := 0 
//�������������������������������������������������������������������������������������������������Ŀ
//�INICIO																							�
//�ARCOLOR - Para calculo dos impostos, utiliza��o do recurso "MAFIS"								�
//�RODRIGO TELECIO em 17/11/2021																	�
//���������������������������������������������������������������������������������������������������
local _aRelImp   := MaFisRelImp("MT100",{"SF2","SD2"})
local _nDescZF	 := 0
//�������������������������������������������������������������������������������������������������Ŀ
//�FIM																							�
//���������������������������������������������������������������������������������������������������
private _nValtot := 0
if cNumAte <> Nil
	mv_par01 := ""
	mv_par02 := "ZZZZZZ"
	mv_par03 := Ctod("01/01/00")
	mv_par04 := Ctod(("31/12/")+Str(Year(dDataBase),4,0))
	mv_par05 := cNumAte
	mv_par06 := cNumAte
endif
dbSelectArea("SUA")
SetRegua(RecCount())		// Total de Elementos da regua
#IFDEF TOP
	cQuery 		:= " SELECT																									" + ENT
	cQuery 		+= "	UA_BAIRROC, UA_BAIRROE, UA_CEPC, UA_CEPE, UA_CLIENTE, UA_CODCONT, UA_CODOBS, 						" + ENT
	cQuery 		+= "	UA_CONDPG, UA_DTLIM, UA_EMISSAO, UA_ENDCOB, UA_ENDENT, UA_ESTC, UA_ESTE, UA_FILIAL, 				" + ENT
	cQuery 		+= "	UA_FIM, UA_INICIO, UA_LOJA, UA_MUNC, UA_MUNE, UA_NUM, UA_NUMSC5, UA_OPER, UA_OPERADO, 				" + ENT
	cQuery 		+= "	UA_PDESCAB, UA_PROSPEC, UA_TPCARGA, UA_TRANSP, UA_VEND, 											" + ENT
	cQuery 		+= "	UA_DESC1, UA_DESC2, UA_DESC3, UA_DESC4, UA_FATOR, UA_VALBRUT, UA_VLRLIQ, UA_TPDIV, 					" + ENT
	cQuery 		+= "	UA_PEDCLI2,  																						" + ENT
	cQuery 		+= "	CASE WHEN UA_TPFRETE = 'C' 																			" + ENT
	cQuery 		+= "		THEN 'CIF' 																						" + ENT
	cQuery 		+= "		ELSE 																							" + ENT
	cQuery 		+= "			CASE WHEN UA_TPFRETE = 'F' 																	" + ENT
	cQuery 		+= "				THEN 'FOB' 																				" + ENT
	cQuery 		+= "				ELSE 																					" + ENT 
	cQuery 		+= "					CASE WHEN UA_TPFRETE = 'T' 															" + ENT
	cQuery 		+= "						THEN 'Por conta de terceiros' 													" + ENT
	cQuery 		+= "						ELSE 'Sem frete' 																" + ENT
	cQuery 		+= "					END																					" + ENT
	cQuery 		+= "			END																							" + ENT
	cQuery 		+= "	END UA_TPFRETE,																						" + ENT
	cQuery 		+= "	CASE WHEN ISNULL(UA_TPOPER ,'') = '' 																" + ENT
	cQuery 		+= "		THEN 'N�o definido' 																			" + ENT
	cQuery 		+= "		ELSE UA_TPOPER + ' - ' + X5_DESCRI  															" + ENT
	cQuery 		+= "	END UA_TPOPER, 																						" + ENT
	cQuery 		+= "	ROUND(SUM(UB_QUANT*B1_PESBRU),2) B1_PESBRU,															" + ENT
	cQuery 		+= "	ROUND(SUM(UB_QUANT* B1_PESO),2) B1_PESO 															" + ENT
	cQuery 		+= "FROM 																									" + ENT
	cQuery 		+=		RetSqlName("SUA") + " SUA																			" + ENT
	cQuery 		+= "	LEFT JOIN 																							" + ENT
	cQuery 		+= 			RetSqlName("SX5") + " 																			" + ENT
	cQuery 		+= "	ON	 																								" + ENT
	cQuery 		+= "		X5_TABELA = 'DJ' 																				" + ENT
	cQuery 		+= "		AND X5_CHAVE = UA_TPOPER																		" + ENT
	cQuery 		+= "	LEFT JOIN 																							" + ENT
	cQuery 		+= 			RetSqlName("SUB") + " SUB 																		" + ENT
	cQuery 		+= "	ON 																									" + ENT
	cQuery 		+= "		UB_FILIAL = UA_FILIAL 																			" + ENT
	cQuery 		+= "		AND UB_NUM = UA_NUM 																			" + ENT
	cQuery 		+= "		AND SUB.D_E_L_E_T_ = ''																			" + ENT
	cQuery 		+= "	LEFT JOIN 																							" + ENT
	cQuery 		+= 			RetSqlName("SB1") + " SB1																		" + ENT
	cQuery 		+= "	ON 																									" + ENT
	cQuery 		+= "		B1_FILIAL = UB_FILIAL 																			" + ENT
	cQuery 		+= "		AND B1_COD = UB_PRODUTO 																		" + ENT
	cQuery 		+= "		AND SB1.D_E_L_E_T_ = ''																			" + ENT
	cQuery 		+= "WHERE 																									" + ENT
	cQuery 		+= "	SUA.UA_FILIAL = '" + FWFilial("SUA") + "' 															" + ENT
	cQuery 		+= "	AND SUA.UA_CANC = '' 																				" + ENT
	cQuery	 	+= "	AND SUA.UA_VEND BETWEEN '" 		+ mv_par01 			+ "' AND '" + mv_par02 			+ "'			" + ENT
	cQuery 		+= "	AND SUA.UA_EMISSAO BETWEEN '" 	+ DtoS(mv_par03) 	+ "' AND '" + DtoS(mv_par04) 	+ "' 			" + ENT 
	cQuery 		+= "	AND SUA.UA_NUM BETWEEN '" 		+ mv_par05 			+ "' AND '" + mv_par06 			+ "' 			" + ENT
	cQuery 		+= "	AND SUA.D_E_L_E_T_ = ' ' 																			" + ENT
	cQuery 		+= "GROUP BY 																								" + ENT
	cQuery 		+= "	UA_BAIRROC, UA_BAIRROE, UA_CEPC, UA_CEPE, UA_CLIENTE, UA_CODCONT, UA_CODOBS, UA_CONDPG, 			" + ENT
	cQuery 		+= "	UA_DTLIM, UA_EMISSAO, UA_ENDCOB, UA_ENDENT, UA_ESTC, UA_ESTE, UA_FILIAL, 							" + ENT
	cQuery 		+= "	UA_FIM, UA_INICIO, UA_LOJA, UA_MUNC, UA_MUNE, UA_NUM, UA_NUMSC5, UA_OPER, UA_OPERADO,				" + ENT
	cQuery 		+= "	UA_PEDCLI2, UA_PDESCAB, UA_PROSPEC, UA_TPCARGA, UA_TRANSP, UA_VEND, UA_DESC1, UA_DESC2, UA_DESC3, 	" + ENT
	cQuery 		+= "	UA_DESC4, UA_FATOR, UA_VALBRUT, UA_VLRLIQ, UA_TPDIV , UA_TPFRETE, UA_TPOPER, X5_DESCRI				" + ENT
	cQuery 		+= "ORDER BY																								" + ENT
	cQuery 		+= "	UA_FILIAL, UA_VEND, UA_EMISSAO																		" + ENT
	cQuery		:= ChangeQuery(cQuery)
	// MemoWrite("TMKR03.SQL", cQuery)
	dbSelectArea("SUA")
	SUA->(DbCloseArea())
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUA', .F., .T.)
	TCSetField('SUA', 'UA_EMISSAO',	'D')
	TCSetField('SUA', 'UA_PROSPEC',	'L')
	TCSetField('SUA', 'UA_DTLIM',	'D')
#ELSE
	cArqTrab := CriaTrab("",.F.)
	IndRegua(cString,cArqTrab,"SUA->UA_FILIAL + SUA->UA_VEND + DTOS(SUA->UA_EMISSAO)",,,"Selecionando Registros...")
	dbCommit()
	nIndex 		:= RetIndex("SUA")
	dbSetIndex(cArqTrab+OrdBagExt())
	dbSelectArea("SUA")
	SUA->(dbSetOrder(nIndex+1))
	SUA->(msSeek(xFilial("SUA") + (mv_par01),.T.,.F.)) //Vendedor
#ENDIF
while !SUA->(EOF()) .AND. SUA->UA_FILIAL == xFilial("SUA") .AND. SUA->UA_VEND >= mv_par01 .AND. SUA->UA_VEND <= mv_par02
	IncRegua()	
	if lEnd
		@Prow()+1,000 PSay "CANCELADO PELO OPERADOR" //"CANCELADO PELO OPERADOR"
		exit
	endif
	//��������������������������������������������������������������Ŀ
	//� Considera filtro do usuario                                  �
	//����������������������������������������������������������������
	if (!Empty(aReturn[7])) .AND. (!&(aReturn[7]))
		DbSkip()
		loop
	endif
	#IFNDEF TOP
		//�������������������Ŀ
		//�Verifica intervalo.�
		//���������������������
		if (SUA->UA_EMISSAO < mv_par03) .OR. (SUA->UA_EMISSAO > mv_par04)
			dbSkip()
			loop
		endif
		//�������������������������������Ŀ
		//�Verifica o intervalo de codigos�
		//���������������������������������
		if !Empty(mv_par05) .AND. !Empty(mv_par06)
			if SUA->UA_NUM < Mv_Par05 .Or. SUA->UA_NUM > Mv_Par06
				dbSkip()
				loop
			endif
		endif
		//�������������������������������������
		//�Se nao for um ORCAMENTO nao imprime�
		//�������������������������������������
		if SUA->UA_OPER <> "2"
			dbSkip()
			loop
		endif
	#ENDIF
	//�����������������������������Ŀ
	//�Armazena os dados da Empresa.�
	//�������������������������������
	//�������������������������������������������������������������������������������������������������Ŀ
	//�INICIO																							�
	//�ARCOLOR - Para ganho de performance, removidas a fun��o "Posicione()" e aberta tabela para coleta�
	//�das informa��es, de uma s� vez.																	�
	//�RODRIGO TELECIO em 17/11/2021																	�
	//���������������������������������������������������������������������������������������������������	
	if !SUA->UA_PROSPEC
		cEntidade	:=	"SA1"
		dbSelectArea(cEntidade)
		(cEntidade)->(dbSetOrder(1))
		if dbSeek(FWFilial(cEntidade) + SUA->UA_CLIENTE + SUA->UA_LOJA)
			cCodCli		:= AllTrim(SA1->A1_COD) + " - " + AllTrim(SA1->A1_LOJA)
			_cCodigo	:= AllTrim(SA1->A1_COD)
			_cLoja		:= AllTrim(SA1->A1_LOJA)
			cNome		:= AllTrim(SA1->A1_NOME)
			cEnder		:= AllTrim(SA1->A1_END)
			cCGC		:= AllTrim(SA1->A1_CGC)
			cRg			:= AllTrim(SA1->A1_INSCR)
			_cTipo		:= AllTrim(SA1->A1_TIPO)
			if Empty(cRg)
				cRg 	:= AllTrim(SA1->A1_RG)
			endif
		endif
	else
		cEntidade	:=	"SUS"
		dbSelectArea(cEntidade)
		(cEntidade)->(dbSetOrder(1))
		if dbSeek(FWFilial(cEntidade) + SUA->UA_CLIENTE + SUA->UA_LOJA)
			cCodCli		:= AllTrim(SUS->US_COD) + " - " + SUS->US_LOJA
			_cCodigo	:= AllTrim(SUS->US_COD)
			_cLoja		:= AllTrim(SUS->US_LOJA)	
			cNome    	:= AllTrim(SUS->US_NOME)
			cEnder   	:= AllTrim(SUS->US_END)
			cCGC     	:= AllTrim(SUS->US_CGC)
			_cTipo		:= AllTrim(SA1->A1_TIPO)
		endif
	endif
	//�������������������������������������������������������������������������������������������������Ŀ
	//�INICIO																							�
	//�ARCOLOR - Para calculo dos impostos, utiliza��o do recurso "MAFIS"								�
	//�RODRIGO TELECIO em 17/11/2021																	�
	//���������������������������������������������������������������������������������������������������
	MaFisIni(	_cCodigo							,;	// 1-Codigo Cliente/Fornecedor
				_cLoja								,;	// 2-Loja do Cliente/Fornecedor
				"C"									,;	// 3-C:Cliente,F:Fornecedor
				"N"									,;	// 4-Tipo da NF
				_cTipo								,;	// 5-Tipo do Cliente/Fornecedor
				_aRelImp							,;	// 6-Relacao de Impostos que suportados no arquivo
													,;	// 7-Tipo de complemento
													,;	// 8-Permite Incluir Impostos no Rodape .T./.F.
				"SB1"								,;	// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
				"RTMKR3A"							)	// 10-Nome da rotina que esta utilizando a funcao
	//�������������������������������������������������������������������������������������������������Ŀ
	//�FIM																							    �
	//���������������������������������������������������������������������������������������������������
	//��������������������������������������������������������������Ŀ
	//�Monta uma string com as formas de pagamento utilizada na venda�
	//����������������������������������������������������������������
	dbSelectArea("SL4")
	SL4->(DbSetOrder(1))
	cFormPag := ""
	if SL4->(MsSeek(xFilial("SL4") + SUA->UA_NUM + "SIGATMK",.T.,.F.))
		while !SL4->(Eof()) .AND. SL4->L4_FILIAL == xFilial("SL4") .AND. SL4->L4_NUM == SUA->UA_NUM .AND. Trim(SL4->L4_ORIGEM) == "SIGATMK"
			if !(Trim(SL4->L4_FORMA) $ cFormPag)
				cFormPag := cFormPag + Trim(SL4->L4_FORMA) + "/"
			endif
			AADD(aFatura, {SL4->L4_Data, SL4->L4_Valor, SL4->L4_Forma} )
			dbSkip()
		enddo
		cFormPag := SubStr(cFormPag,1,Len(cformPag)-1)
	endif
	//�����������������������������Ŀ
	//�Seleciona contato.           �
	//�������������������������������
	cContato := Posicione("SU5",1,xFilial("SU5")+SUA->UA_CODCONT,"U5_CONTAT")
	//�����������������������������������������������������������Ŀ
	//�Funcao que incrementa a linha e verifica a quebra de pagina�
	//�������������������������������������������������������������
	/*Tk3ALinha(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay __PrtThinLine()*/
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| " + PadR(STR0009,9) + " " + PadR(cCodCli,30) //"Empresa"
	@ nLi,044 PSay "|"
	@ nLi,046 PSay PadR("LOCAL DE ENTREGA",25) //STR0010
	@ nLi,088 PSay "|"
	@ nLi,090 PSay PadR("ENDERECO DE COBRANCA",25) //STR0011
	@ nLi,131 PSay "|"
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| " + PadR(cNome,40) // STR0012 - "Nome"
	@ nLi,044 PSay "|"
	@ nLi,045 PSay Repl("-",43)
	@ nLi,088 PSay "|"
 	@ nLi,089 PSay Repl("-",42)
	@ nLi,131 PSay "|"
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| " + PadR(cEnder,40) // STR0013 - "Endereco"
	@ nLi,044 PSay "|"
	@ nLi,046 PSay SubStr(SUA->UA_ENDENT,1,40)
	@ nLi,088 PSay "|"
	@ nLi,090 PSay SubStr(SUA->UA_ENDCOB,1,40)
	@ nLi,131 PSay "|"
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| " + PadR(cRg,30) // STR0014 - "Inscr./RG"
	@ nLi,044 PSay "|"
	@ nLi,046 PSay Transform(SUA->UA_CEPE, "99999-999") + SubStr(SUA->UA_BAIRROE,1,31)
	@ nLi,088 PSay "|"
	@ nLi,090 PSay Transform(SUA->UA_CEPC, "99999-999") + SubStr(SUA->UA_BAIRROC,1,31)
	@ nLi,131 PSay "|"
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| "		// STR0015 - "CPF/CNPJ"
	@ nLi,002 PSay cCGC Picture IIF(Len(cCGC)==14,'@R 99.999.999/9999-99','@R 999.999.999-99')
	@ nLi,044 PSay "|"
	@ nLi,046 PSay Trim(SubStr(SUA->UA_MUNE,1,35)) + " - " + SUA->UA_ESTE
	@ nLi,088 PSay "|"
	@ nLi,090 PSay Trim(SubStr(SUA->UA_MUNC,1,35)) + " - " + SUA->UA_ESTC
	@ nLi,131 PSay "|"
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay __PrtThinLine()
	//������������������������������Ŀ
	//�Imprime os dados do orcamento.�
	//��������������������������������
	dbSelectArea("SUA")
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "|"
	@ nLi,002 PSay STR0016 + SUA->UA_NUM //"Atendimento : "
	@ nLi,044 PSay "|"
	@ nLi,045 PSay STR0018 + AllTrim(DtoC(SUA->UA_EMISSAO)) //"Emissao     : "
	@ nLi,088 PSay "|"
	@ nLi,089 PSay STR0020 + SUA->UA_INICIO + " / " + SUA->UA_FIM //"Inicio / Fim: "
    @ nLi,131 PSay "|"
    Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "|" 
	@ nLi,002 PSay STR0041 + AllTrim(SUA->UA_TPOPER) //"Opera��o    : "
 	@ nLi,044 PSay "|"
 	@ nLi,045 PSay STR0042 + SUA->UA_TPDIV
	@ nLi,088 PSay "|"
 	@ nLi,089 PSay STR0026 + SubStr(Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME"),1,49) //"Operador    : "
	@ nLi,132 PSay "|"
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
    @ nLi,000 PSay "|" 
	@ nLi,002 PSay STR0024 + SubStr(Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND,"A3_NOME"),1,49) //"Vendedor    : "
  	@ nLi,045 PSay "|"	
  	@ nLi,046 PSay STR0043 + SUA->UA_PEDCLI2
    @ nLi,089 PSay "|"
	@ nLi,090 PSay STR0022 + SubStr(cContato,1,49) //"Contato     : "		
    @ nLi,132 PSay "|"
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay __PrtThinLine()
    Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
    @ nLi,000 PSay "|" 
	@ nLi,002 PSay STR0033 + SUA->UA_TPFRETE //"Tipo de frete : "	
   	@ nLi,044 PSay "|"	 
   	@ nLi,045 PSay STR0039 + Transform(SUA->B1_PESO   ,"@E 99,999,999.99" )
    @ nLi,088 PSay "|"
	@ nLi,089 PSay STR0040 + Transform(SUA->B1_PESBRU ,"@E 99,999,999.99" )
    @ nLi,131 PSay "|"
    Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)  
    @ nLi,000 PSay "|" 
	@ nLi,002 PSay STR0032 + SubStr(Posicione("SA4",1,xFilial("SA4")+SUA->UA_TRANSP,"A4_NOME"),1,49) //"Transportad.: "
   	@ nLi,088 PSay "|"	   
    @ nLi,089 PSay STR0027 + If(SUA->UA_TPCARGA=="1","CARREGA","NAO CARREGA") //"Mapa Carreg.: "###STR0028###STR0029
    @ nLi,131 PSay "|"
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay __PrtThinLine()
	//���������������������������������������������������������������������Ŀ
	//�  Impresssao do campo memo da observacao						        �
	//�����������������������������������������������������������������������
	aLinha := Tk3AMemo(alltrim(SUA->UA_CODOBS), 120)
	if Len(aLinha) > 0
		for nI := 1 to Len(aLinha)
			Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
			@ nLi,000 PSay "|" 
			if nI == 1
				@ nLi,002 PSay  "Observa��o: "
			endif
			@ nLi,13 PSay aLinha[nI]
			@ nLi,131 PSay "|"
		next nI	
	endif
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
    @nLi,000 PSay __PrtThinLine()
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	//In�cio - Trecho adicionado por Adriano Leonardo em 07/02/2014 para adi��o dos descontos do cabe�alho
	_cDescont 	:= "Fator: "  + Transform(SUA->UA_FATOR, "@E 99.99")+ " "
	_cDescont 	+= "   Desc 1: " +  Transform(SUA->UA_DESC1, "@E 9999.99") + " "
	_cDescont 	+= "Desc 2: " + Transform(SUA->UA_DESC2, "@E 9999.99") + " "
	_cDescont 	+= "Desc 3: " + Transform(SUA->UA_DESC3, "@E 9999.99") + " "
	_cDescont 	+= "Desc 4: " + Transform(SUA->UA_DESC4, "@E 9999.99") + " "
    @ nLi,000 PSay "|"
   	@ nLi,002 PSay STR0031 + Transform(SUA->UA_PDESCAB, "@E 9999.99") //"Indenizacao : "     
	//Final  - Trecho adicionado por Adriano Leonardo em 07/02/2014 para adi��o dos descontos do cabe�alho	
  	@ nLi,044 PSay "|"	
  	@ nLi,045 PSay  _cDescont 
    @ nLi,131 PSay "|"
	//����������������������������������������Ŀ
	//�Imprime os produtos/servicos orcamentos.�
	//������������������������������������������
	dbSelectArea("SUB")
	SUB->(dbSetOrder(1))
	if SUB->(MsSeek(xFilial("SUB")+SUA->UA_NUM,.T.,.F.))
		Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay __PrtThinLine()
		Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		_cCabec := "Item Produto        Descricao                    UM         Qtde    Vlr Unit    Vlr Item    Desc   Desc1   Desc2   Desc3   Desc4 "
		@ nLi,001 PSay PadR(_cCabec,Limite)
		Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,002 PSay __PrtThinLine()
		nTotQtd  := 0
		_nQtItF  := 0
		nTotGeral:= 0
		nTotBase := 0
		_nPDiv   := 0
		if SUA->UA_TPDIV == "0"
			_nPDiv := 0
		elseif SUA->UA_TPDIV == "1"
			_nPDiv := 0.3333 //33.33/100
		elseif SUA->UA_TPDIV == "2"
			_nPDiv := 0.5 //50/100
		elseif SUA->UA_TPDIV == "3"
			_nPDiv := 0.6666//66.66/100
		elseif SUA->UA_TPDIV == "4"
			_nPDiv := 1 //100/100
		elseif SUA->UA_TPDIV == "5"
			_nPDiv := 0.5 //100/100
		endif
		dbSelectArea("SUB")
		SUB->(dbSetOrder(1))
		while !SUB->(EOF()) .AND. xFilial("SUB") == SUB->UB_FILIAL .AND. SUA->UA_NUM == SUB->UB_NUM
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+SUB->UB_PRODUTO,.T.,.F.))
			Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	        @ nLi,000 PSay "|"	 	
			@ nLi,002		PSay SUB->UB_ITEM			PICTURE PESQPICT("SUB","UB_ITEM"	)
			@ nLi,PCol()+2	PSay SB1->B1_COD			PICTURE PESQPICT("SB1","B1_COD"		)
			@ nLi,PCol()	PSay Left(SB1->B1_DESC,29)	PICTURE PESQPICT("SB1","B1_DESC"	)
			@ nLi,PCol()	PSay SB1->B1_UM				PICTURE PESQPICT("SB1","B1_UM"		)
			@ nLi,PCol()+2	PSay SUB->UB_QUANT			PICTURE PESQPICT("SUB","UB_QUANT"	)
			@ nLi,PCol()+2	PSay SUB->UB_VRUNIT			PICTURE PESQPICT("SUB","UB_VRUNIT"	)
			@ nLi,PCol()+2	PSay SUB->UB_VLRITEM		PICTURE PESQPICT("SUB","UB_VLRITEM"	)
		    @ nLi,PCol()+2	PSay SUB->UB_DESC   		PICTURE PESQPICT("SUB","UB_DESC"	)	
			@ nLi,PCol()+2	PSay SUB->UB_DESCTV1		PICTURE PESQPICT("SUB","UB_DESCTV1"	)
			@ nLi,PCol()+2	PSay SUB->UB_DESCTV2		PICTURE PESQPICT("SUB","UB_DESCTV2"	)
			@ nLi,PCol()+2	PSay SUB->UB_DESCTV3		PICTURE PESQPICT("SUB","UB_DESCTV3"	)
			@ nLi,PCol()+2	PSay SUB->UB_DESCTV4		PICTURE PESQPICT("SUB","UB_DESCTV4"	)
 	        @ nLi,131 PSay "|" 
			nPrcTot 	:= ROUND(SUB->UB_QUANT  * SUB->UB_VRUNIT,2) * _nPDiv
			nPrcUni 	:= ROUND(SUB->UB_VRUNIT,2) * _nPDiv
			//�������������������������������������������������������������������������������������������������Ŀ
			//�INICIO																							�
			//�ARCOLOR - Demonstra��o de valores do SUFRAMA														�
			//�RODRIGO TELECIO em 17/11/2021																	�
			//���������������������������������������������������������������������������������������������������
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+SUB->UB_TES,.T.,.F.))
			MaFisAdd(	SB1->B1_COD							,;	// 1 - Codigo do Produto ( Obrigatorio )
						SUB->UB_TES							,;	// 2 - Codigo do TES ( Opcional )
						SUB->UB_QUANT						,;	// 3 - Quantidade ( Obrigatorio )
						nPrcUni								,;	// 4 - Preco Unitario ( Obrigatorio )
						0									,;	// 5 - Valor do Desconto ( Opcional )
						""									,;	// 6 - Numero da NF Original ( Devolucao/Benef )
						""									,;	// 7 - Serie da NF Original ( Devolucao/Benef )
						0									,;	// 8 - RecNo da NF Original no arq SD1/SD2
						0									,;	// 9 - Valor do Frete do Item ( Opcional )
						0									,;	// 10- Valor da Despesa do item ( Opcional )
						0									,;	// 11- Valor do Seguro do item ( Opcional )
						0									,;	// 12- Valor do Frete Autonomo ( Opcional )
						nPrcTot								,;	// 13- Valor da Mercadoria ( Obrigatorio )
						0									,;	// 14- Valor da Embalagem ( Opiconal )
						SB1->(Recno())						,;	// 15- RecNo do SB1
						SF4->(Recno())						)	// 16- RecNo do SF4
			//�������������������������������������������������������������������������������������������������Ŀ
			//�FIM																								�
			//���������������������������������������������������������������������������������������������������						
			nTotQtd   	+= SUB->UB_QUANT
			_nQtItF  	+= SUB->UB_QUANT * _nPDiv
			nTotGeral 	+= ROUND(SUB->UB_VLRITEM,2)
			nTotBase 	+= Round((SUB->UB_VLRITEM * _nPDiv),4)
			nIteLin++
			dbSelectArea("SUB")
			SUB->(dbSetOrder(1))
			SUB->(dbSkip())
		enddo
		if nIteLin <= 25	
			for ni := nIteLin to 24
			  	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)      
			   	@ nLi,000 PSay "|"   
			    @ nLi,131 PSay "|"
			   	ni++
			next ni
		endif
		_nTotDiv	:= MaFisRet(1,"NF_TOTAL" )
		_nTotICM	:= MafisRet(1,"NF_VALICM")
		_nTotIPI	:= MaFisRet(1,"NF_VALIPI")
		_nTotST		:= MaFisRet(1,"NF_VALSOL")
		//�������������������������������������������������������������������������������������������������Ŀ
		//�INICIO																							�
		//�ARCOLOR - Demonstra��o de valores do SUFRAMA														�
		//�RODRIGO TELECIO em 17/11/2021																	�
		//���������������������������������������������������������������������������������������������������		
		_nDescZF	:= MaFisRet(1,"NF_DESCZF")
		//�������������������������������������������������������������������������������������������������Ŀ
		//�FIM																								�
		//���������������������������������������������������������������������������������������������������
		//����������������������������������������Ŀ
		//�Imprime os totais de quantidade e valor.�
		//������������������������������������������
		Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay __PrtThinLine()
		Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay "|" 
		@ nLi,003 PSay STR0025 + SubStr(Posicione("SE4",1,xFilial("SE4")+SUA->UA_CONDPG,"E4_DESCRI"),1,48) 	
	    @ nLi,045 PSay "|"
		@ nLi,046 PSay " => TOTAL DAS QUANTIDADES  " + Transform(nTotQtd                       											,"@E 99,999,999.99" ) //"Total das quantidades"
        @ nLi,089 PSay "|"	
		@ nLi,090 PSay "   BASE DO ICMS  R$   " + Transform((nTotBase)                    												,"@E 99,999,999.99" )      
        @ nLi,132 PSay "|"       
  	    Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)      
        @ nLi,000 PSay "|"   
        @ nLi,003 PSay PadR("Vencto                Valor ",Limite) + STR0030 + SubStr(cFormPag,1,49) //"Cond. Pagto : " //STR0038	 		
        @ nLi,045 PSay "|"    
		@ nLi,046 PSay " => TOTAL MERCADORIAS   R$ " + Transform((nTotGeral)                   											,"@E 99,999,999.99" ) //"Valor total do orcamento"		
		@ nLi,089 PSay "|"	
		@ nLi,090 PSay "   VALOR DO ICMS R$   " + Transform((_nTotICM)                   												,"@E 99,999,999.99" )
	    @ nLi,132 PSay "|"
	    nTotLin 	:= iif(len(aFatura) > 5, len(afatura),5)
        if Len(aFatura) > 0		
			for nI := 1 to nTotLin
				if nI == 1							      
			        Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)      
			        @ nLi,000 PSay "|" 
			        if Len(afatura) >=1      
				       	@ nLi,003 PSay "- " +  DtoC(aFatura[nI][1]) + "   R$" + Transform(aFatura[nI][2]								,"@E 999,999.99" )
					endif
					@ nLi,044 PSay "|"
					//�������������������������������������������������������������������������������������������������Ŀ
					//�INICIO																							�
					//�ARCOLOR - Demonstra��o de valores do SUFRAMA														�
					//�RODRIGO TELECIO em 17/11/2021																	�
					//���������������������������������������������������������������������������������������������������
					if _nDescZF > 0
						@ nLi,045 PSay " => DESCONTO ZF         R$ " + Transform((_nDescZF)     										,"@E 99,999,999.99") //Desconto para incentivos � SUFRAMA	(obriga��o legal)
					endif
					//�������������������������������������������������������������������������������������������������Ŀ
					//�FIM																								�
					//���������������������������������������������������������������������������������������������������
			        @ nLi,088 PSay "|"
					@ nLi,089 PSay "   VALOR DO IPI  R$   " + Transform((_nTotIPI)                    									,"@E 99,999,999.99" )
				    @ nLi,131 PSay "|"
				elseif nI == 2
				  	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)      
				  	@ nLi,000 PSay "|"
			        if Len(afatura) >= 2
			        	@ nLi,003 PSay "- " +  DtoC(aFatura[nI][1]) + "   R$" + Transform(aFatura[nI][2]								,"@E 999,999.99")
				    endif
				    @ nLi,044 PSay "|"
					@ nLi,088 PSay "|"
					@ nLi,089 PSay "   VALOR RETIDO  R$   " + Transform((_nTotST)														,"@E 99,999,999.99" )
					@ nLi,131 PSay "|"
				elseif  nI == 3
					Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
				  	@ nLi,000 PSay "|"
			        if Len(afatura) >= 3
			        	@ nLi,003 PSay "- " +  DtoC(aFatura[nI][1]) + "   R$" + Transform(aFatura[nI][2]								,"@E 999,999.99")
			        endif
			        @ nLi,044 PSay "|"	
					@ nLi,088 PSay "|"	
					@ nLi,131 PSay "|"		
				elseif nI == 4
				  	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)      
			        @ nLi,000 PSay "|"
			        if Len(afatura) >= 4
			        	@ nLi,003 PSay "- " +  DtoC(aFatura[nI][1]) + "   R$" + Transform(aFatura[nI][2]								,"@E 999,999.99")
			        endif
			        @ nLi,044 PSay "|"
			        @ nLi,088 PSay "|"
					//�������������������������������������������������������������������������������������������������Ŀ
					//�INICIO																							�
					//�ARCOLOR - Demonstra��o de valores do SUFRAMA														�
					//�RODRIGO TELECIO em 17/11/2021																	�
					//���������������������������������������������������������������������������������������������������					
					if _nDescZF > 0
						@ nLi,089 PSay "    =>  VALOT TOTAL R$  " + Transform((nTotGeral + _nTotIPI + _nTotST - _nDescZF)				,"@E 99,999,999.99" )
					else
			        	@ nLi,089 PSay "    =>  VALOT TOTAL R$  " + Transform((nTotGeral + _nTotIPI + _nTotST)							,"@E 99,999,999.99" )
					endif
					//�������������������������������������������������������������������������������������������������Ŀ
					//�FIM																								�
					//���������������������������������������������������������������������������������������������������					
			        @ nLi,131 PSay "|"
				elseif nI == 5				
					Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
				  	@ nLi,000 PSay "|"
			        if len(afatura) >= 5
			        	@ nLi,003 PSay "- " +  DtoC(aFatura[nI][1]) + "   R$" + Transform(aFatura[nI][2]								,"@E 999,999.99")
			        endif
			        @ nLi,044 PSay "|"	
					@ nLi,088 PSay "|"	
					@ nLi,131 PSay "|"			
				elseif nI > Len(afatura) .AND. nI > 5
					Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
				  	@ nLi,000 PSay "|"
					@ nLi,003 PSay "- " + DtoC(aFatura[nI][1]) + "   R$" + Transform(aFatura[nI][2]										,"@E 999,999.99")
					@ nLi,044 PSay "|"
					@ nLi,088 PSay "|"
					@ nLi,131 PSay "|"
				endif
			next nI		
		else
		    Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)      
	        @ nLi,000 PSay "|"
	  		@ nLi,003 PSay "|"
			@ nLi,044 PSay "|"
			//�������������������������������������������������������������������������������������������������Ŀ
			//�INICIO																							�
			//�ARCOLOR - Demonstra��o de valores do SUFRAMA														�
			//�RODRIGO TELECIO em 17/11/2021																	�
			//���������������������������������������������������������������������������������������������������
			if _nDescZF > 0				
				@ nLi,045 PSay " => DESCONTO ZF         R$ " + Transform((_nDescZF)     												,"@E 99,999,999.99") //Desconto para incentivos � SUFRAMA	(obriga��o legal)
			endif
			//�������������������������������������������������������������������������������������������������Ŀ
			//�FIM																								�
			//���������������������������������������������������������������������������������������������������				
	        @ nLi,088 PSay "|"
			@ nLi,089 PSay "   VALOR DO IPI R$   " + Transform((_nTotIPI)                    											,"@E 99,999,999.99" )
		    @ nLi,131 PSay "|"		
		  	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)      
		  	@ nLi,000 PSay "|"
			@ nLi,003 PSay "|"
			@ nLi,044 PSay "|"
			@ nLi,088 PSay "|"
			@ nLi,089 PSay "   VALOR RETIDO R$   " + Transform((_nTotST)																,"@E 99,999,999.99" )
			@ nLi,131 PSay "|"
		  	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)      
	        @ nLi,000 PSay "|"
			@ nLi,003 PSay "|"
	        @ nLi,044 PSay "|"
	        @ nLi,088 PSay "|"
			//�������������������������������������������������������������������������������������������������Ŀ
			//�INICIO																							�
			//�ARCOLOR - Demonstra��o de valores do SUFRAMA														�
			//�RODRIGO TELECIO em 17/11/2021																	�
			//���������������������������������������������������������������������������������������������������					
			if _nDescZF > 0
				@ nLi,089 PSay "    =>  VALOT TOTAL R$  " + Transform((nTotGeral + _nTotIPI + _nTotST - _nDescZF)						,"@E 99,999,999.99" )
			else
				@ nLi,089 PSay "    =>  VALOT TOTAL R$  " + Transform((nTotGeral + _nTotIPI + _nTotST)									,"@E 99,999,999.99" )
			endif
			//�������������������������������������������������������������������������������������������������Ŀ
			//�FIM																								�
			//���������������������������������������������������������������������������������������������������
	        @ nLi,131 PSay "|"
		endif
		MaFisEnd()      
	endif
	nI			:= 0
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
 	@ nLi,000 PSay __PrtThinLine()
	Tk3ALinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	aFatura   	:= {}
	nTotQtd   	:= 0
	nTotGeral 	:= 0
	_nValtot  	:= 0
	_nValtot  	:= 0
	//�����������������������������Ŀ
	//�Imprime o rodape do relatorio�
	//�������������������������������
	Roda(cbCont,cbText,Tamanho)
	dbSelectArea("SUA")
	dbSkip()
enddo
#IFDEF TOP
	DbSelectArea("SUA")
	DbCloseArea()
	ChkFile("SUA")
#ELSE
	dbSelectArea("SUA")
	RetIndex("SUA")
	Set Filter To
	dbSetOrder(1)
	FErase(cArqTrab+OrdBagExt())
	FErase(cArqTrab)
#ENDIF
Set Device To Screen
if aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
endif
MS_FLUSH()
return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk3AMemo  �Autor  �Armando M. Tessaroli� Data �  25/03/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta o texto conforme foi digitado pelo operador e quebra  ���
���          �as linhas no tamanho especificado sem cortar palavras e     ���
���          �devolve um array com os textos a serem impressos.           ���
�������������������������������������������������������������������������͹��
���Uso       � Call Center                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function Tk3AMemo(cCodigo,nTam)
local cString	:= MSMM(cCodigo,nTam)		// Carrega o memo da base de dados
local nI		:= 0    					// Contador dos caracteres	
local nJ		:= 0    					// Contador dos caracteres	
local nL		:= 0						// Contador das linhas 
local cLinha	:= ""						// Guarda a linha editada no campo memo
local aLinhas	:= {}						// Array com o memo dividido em linhas
for nI := 1 to Len(cString)
	if (MsAscii(SubStr(cString,nI,1)) <> 13) .AND. (nL < nTam)
		// Enquanto n�o houve enter na digitacao e a linha nao atingiu o tamanho maximo
		cLinha	+= SubStr(cString,nI,1)
		nL++
	else
		// Se a linha atingiu o tamanho maximo ela vai entrar no array
		if MsAscii(SubStr(cString,nI,1)) <> 13
			nI--
			for nJ := Len(cLinha) to 1 Step -1
				// Verifica se a ultima palavra da linha foi quebrada, entao retira e passa pra frente
				if SubStr(cLinha,nJ,1) <> " "
					nI--
					nL--
				else
					exit
				endif
			next nJ
			// Se a palavra for maior que o tamanho maximo entao ela vai ser quebrada
			if nL <=0
				nL 	:= Len(cLinha)
			endif
		endif
		// Testa o valor de nL para proteger o fonte e insere a linha no array
		if nL >= 0
			cLinha := SubStr(cLinha,1,nL)
			AAdd(aLinhas, cLinha)
			cLinha 	:= ""
			nL 		:= 0
		endif
	endif
next nI
// Se o nL > 0, eh porque o usuario nao deu enter no fim do memo e eu adiciono a linha no array.
if nL >= 0
	cLinha 	:= SubStr(cLinha,1,nL)
	AAdd(aLinhas, cLinha)
	cLinha 	:= ""
	nL 		:= 0
endif	
return(aLinhas)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk3ALinha �Autor  �Armando M. Tessaroli� Data �  06/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Incrementa o contador de linhas para impress�o nos relato	  ���
���          �rios e verifica se uma nova pagina sera iniciada.           ���
�������������������������������������������������������������������������͹��
���Uso       � Call Center                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function Tk3ALinha(	nLi,		nInc,		nMax,		titulo,;
	   						cCabec1,	cCabec2,	nomeprog,	tamanho)
local nChrComp	:= iif(aReturn[4] == 1,15,18)
nLi				+= nInc
if nLi > nMax .OR. nLi < 5
	nLi := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nChrComp)
	nLi++
endif
return(Nil)
/*
MaFisIni(	cCodCliFor,;	// 1-Codigo Cliente/Fornecedor
			cLoja,;			// 02-Loja do Cliente/Fornecedor
			cCliFor,;		// 03-C:Cliente , F:Fornecedor
			cTipoNF,;		// 04-Tipo da NF( "N","D","B","C","P","I" ) 
			cTpCliFor,;		// 05-Tipo do Cliente/Fornecedor
			aRelImp,;		// 06-Relacao de Impostos que suportados no arquivo
			cTpComp,;		// 07-Tipo de complemento
			lInsere,;		// 08-Permite Incluir Impostos no Rodape .T./.F.
			cAliasP,;		// 09-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			cRotina,;		// 10-Nome da rotina que esta utilizando a funcao
			cTipoDoc,;		// 11-Tipo de documento
			cEspecie,;		// 12-Especie do documento 
		    cCodProsp,;		// 13-Codigo e Loja do Prospect 
		    cGrpCliFor,;	// 14-Grupo Cliente
		    cRecolheISS,;	// 15-Recolhe ISS
		    cCliEnt,;   	// 16-Codigo do cliente de entrega na nota fiscal de saida
		    cLojEnt,;   	// 17-Loja do cliente de entrega na nota fiscal de saida
		    aTransp,;		// 18-Informacoes do transportador [01]-UF,[02]-TPTRANS
			lEmiteNF,;		// 19-Se esta emitindo nota fiscal ou cupom fiscal (Sigaloja)  
			lCalcIPI,;      // 20-Define se calcula IPI (SIGALOJA)
			cPedido)
*/
