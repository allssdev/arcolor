#include "totvs.ch"
#include "colors.ch"
/*/{Protheus.doc} TK271COR
@description Ponto de entrada para alterar as cores dos status dos atendimentos conforme regra solicitada pelo cliente.
@author Júlio Soares
@since 19/02/2013
@version 1.0
@type function
@history 20/02/2013, Júlio Soares, Ajustes
@history 04/01/2021, Anderson Coelho (ALLSS Soluções em Sistemas), Ajuste nas legendas
@see https://allss.com.br
/*/
/////////////////////////////////////////////////////////////////////
// Trecho inserido por Júlio Soares para atualização da Tabela SUA //
// 01 - Bloqueio de Regra                                          //
// 02 - Bloqueio de Crédito                                        //
// 03 - Bloqueio de Estoque                                        //
// 04 - Pedido em Separação                                        //
// 05 - Pedido expedido                                            //
/////////////////////////////////////////////////////////////////////
user function TK271COR()
	local   _aSavArea := GetArea()
	local   _aSavSUA  := SUA->(GetArea())
	local   _aCores   := {}
	/*
	_aCores  := {{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '3') .AND.   Empty(SUA->UA_STATSC9)                                    ",'BR_BRANCO' },;	// Atendimento			- BRANCO
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '2') .AND.   Empty(SUA->UA_STATSC9)                                    ",'BR_AZUL'   },;	// Pré pedido 			- AZUL
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND.   Empty(SUA->UA_STATSC9)         .AND.  Empty(SUA->UA_DOC)) ",'ENABLE'    },;	// Pedido de Vendas		- VERDE
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '01')                           ",'BR_PRETO'  },;	// Blq. Negócio			- PRETO
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '02')                           ",'BR_CINZA'  },;	// Blq. Credito			- CINZA
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '03')                           ",'BR_MARROM' },;	// Blq. Estoque			- MARROM
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '04' .AND.  Empty(SUA->UA_DOC)) ",'BR_AMARELO'},;	// Pedido em separação	- AMARELO
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '07')                           ",'BR_PINK'   },;	// Faturado Parcial  	- ROSA
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) <> '05' .AND. !Empty(SUA->UA_DOC)) ",'BR_LARANJA'},;	// Faturado				- LARANJA
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '06').AND. !Empty(SUA->UA_DOC)  ",'BR_MARRON' },;	// Expedido Parcial		- MARRON
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '05').AND. !Empty(SUA->UA_DOC)  ",'DISABLE'   },;	// Expedido				- VERMELHO
				{"!EMPTY(SUA->UA_CODCANC)                                                                                                ",'BR_CANCEL' }}	// Cancelado	 		- X
	*/
	/*
	_aCores  := {{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '3') .AND.   Empty(SUA->UA_STATSC9)                                                                ",'BR_BRANCO' },;	// Atendimento			- BRANCO
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '2') .AND.   Empty(SUA->UA_STATSC9)                                                                ",'BR_AZUL'   },;	// Pré pedido			- AZUL
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND.   Empty(SUA->UA_STATSC9)         .AND.  Empty(SUA->UA_DOC))                             ",'ENABLE'    },;	// Pedido de Vendas		- VERDE
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '01')                                                       ",'BR_PRETO'  },;	// Blq. Negócio			- PRETO
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '02')                                                       ",'BR_CINZA'  },;	// Blq. Credito			- CINZA
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '03')                                                       ",'BR_MARROM' },;	// Blq. Estoque			- MARROM
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '04' .AND.  Empty(SUA->UA_DOC))                             ",'BR_AMARELO'},;	// Pedido em separação	- AMARELO
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '06' .AND.  Empty(SUA->UA_DOC) .AND. Empty(SUA->(UA_CARGA)))",'BR_PINK'   },;	// Faturado Parcial		- ROSA
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '07' .AND. !Empty(SUA->UA_DOC) .AND. Empty(SUA->(UA_CARGA)))",'BR_LARANJA'},;	// Faturado	Total		- LARANJA
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '06').AND.  Empty(SUA->UA_DOC) .AND. !Empty(SUA->(UA_CARGA))",'BR_VIOLETA'},;	// Expedido Parcial		- VIOLETA
				{"(EMPTY(SUA->UA_CODCANC) .AND. (SUA->UA_OPER) == '1'  .AND. AllTrim(SUA->UA_STATSC9) == '05').AND. !Empty(SUA->UA_DOC) .AND. !Empty(SUA->(UA_CARGA))",'DISABLE'   },;	// Expedido	Total		- VERMELHO
				{"!EMPTY(SUA->UA_CODCANC)                                                                                                                            ",'BR_CANCEL' }}	// Cancelado	 		- X
	*/
	_aCores  := {{"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '3')                                                                                    ",'BR_BRANCO' },;	// Atendimento			- BRANCO
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '2')                                                                                    ",'BR_AZUL'   },;	// Pré pedido			- AZUL
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '1' .AND. Empty(SUA->UA_STATSC9))                                                       ",'ENABLE'    },;	// Pedido de Vendas		- VERDE
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '1' .AND. SUA->UA_STATSC9 == '01')                                                      ",'BR_PRETO'  },;	// Blq. Negócio			- PRETO
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '1' .AND. SUA->UA_STATSC9 == '02')                                                      ",'BR_CINZA'  },;	// Blq. Credito			- CINZA
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '1' .AND. SUA->UA_STATSC9 == '03')                                                      ",'BR_MARROM' },;	// Blq. Estoque			- MARROM
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '1' .AND. SUA->UA_STATSC9 == '04')                                                      ",'BR_AMARELO'},;	// Pedido em separação	- AMARELO
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '1' .AND. SUA->UA_STATSC9  > '04' .AND.  Empty(SUA->UA_DOC) .AND.  Empty(SUA->UA_CARGA))",'BR_PINK'   },;	// Faturado Parcial		- ROSA
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '1' .AND. SUA->UA_STATSC9  > '04' .AND.  Empty(SUA->UA_DOC) .AND. !Empty(SUA->UA_CARGA))",'BR_VIOLETA'},;	// Expedido Parcial		- VIOLETA
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '1' .AND. SUA->UA_STATSC9  > '04' .AND. !Empty(SUA->UA_DOC) .AND.  Empty(SUA->UA_CARGA))",'BR_LARANJA'},;	// Faturado	Total		- LARANJA
				 {"(EMPTY(SUA->UA_CODCANC) .AND. SUA->UA_OPER == '1' .AND. SUA->UA_STATSC9  > '04' .AND. !Empty(SUA->UA_DOC) .AND. !Empty(SUA->UA_CARGA))",'DISABLE'   },;	// Expedido	Total		- VERMELHO
				 {"!EMPTY(SUA->UA_CODCANC)                                                                                                               ",'BR_CANCEL' }}	// Cancelado	 		- X
	RestArea(_aSavSUA)
	RestArea(_aSavArea)
return _aCores
