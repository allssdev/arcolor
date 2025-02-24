#include 'protheus.ch'
#include 'parmtype.ch'
#include 'rwmake.CH'
#include 'colors.ch'
/*/{Protheus.doc} MA440COR
@description Ponto de entrada para alterar as cores de status dos pedidos de vendas conforme regras solicitadas pelo cliente. Estas regras foram copiadas do Ponto de Entrada MA410COR.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 28/12/2018
@version 1.0
@return _aCores, Array com as cores das legendas
@type function
@see https://allss.com.br
/*/
user function MA440COR()
	Local _aSavArea	:= GetArea()
	Local _aCores   := {}
	If AllTrim(FWCodEmp()) == '01'
	// Alterado por Júlio Soares em 10/12/2013 para contemplar a legenda de expedição do pedido.
	// - C5_SALDO = R -> ELIMINADO POR RESÍDUO
	// - C5_SALDO = S -> PEDIDO COM SALDO RESTANTE
	// - C5_SALDO = E -> PEDIDO COM TODO SALDO ELIMINADO
	//Após inclusão de índice C9_PEDIDO+C9_NFISCAL esse trecho será colocado na 2ª Posição abaixo.(Arthur Silva)	{ "  C5_SALDO <> 'S'  .And. Empty(C5_LIBEROK) .And.  Empty(C5_NOTA) .And. Empty(C5_BLQ) .AND. EVAL( { || SC9->(dbSetOrder(13)), SC9->(dbSeek(xFilial("+"'"+"SC9"+"'"+") + SC5->C5_NUM + SC5->C5_NOTA)) } ) " ,'BR_AMARELO' },; // Pedido Liberado Parcial (Existe C9, porém com corte em algum item)
	//28/12/2018 - Anderson C. P. Coelho - Copiado do Ponto de Entrada MA410COR.
		_aCores := {{ "  C5_SALDO == 'R' .Or. SUBSTR(C5_NOTA,1,1) == 'X' "                                                                                     ,'BR_CANCEL'  },; // Pedido eliminado por resíduo
					{ "  C5_SALDO <> 'S'  .And. Empty(C5_LIBEROK) .And.  Empty(C5_NOTA) .And. Empty(C5_BLQ)  .and. empty(C5_DTLIBCR) "                         ,'ENABLE'     },; // Pedido em aberto // - Alterado por Renan Santos em 20/09/2016 - conteudo anterior: C5_SALDO <> '' - Estava sobrepondo a legenda de faturamento parcial. 
					{ "  (!Empty(C5_LIBEROK) .Or. !empty(C5_DTLIBCR)) .And.  Empty(C5_NOTA)  .And. Empty(C5_BLQ)  "                                                 ,'BR_AMARELO' },; // Pedido liberado
					{ "  C5_SALDO == 'S' "                                                                                                                     ,'BR_PINK'    },; // Pedido parcialmente faturado
					{ "  C5_SALDO == 'E' .And.!Empty(C5_LIBEROK) .And. !Empty(C5_NOTA)  .And. Empty(C5_CARGA) .And.                           Empty(C5_BLQ)  " ,'DISABLE'    },; // Pedido totalmente faturado
					{ " (C5_SALDO <> 'S' .And.                         !Empty(C5_NOTA)) .Or. ( C5_SALDO <> 'S' .And. C5_LIBEROK == 'E' .And.  Empty(C5_BLQ)) " ,'BR_LARANJA' },; // Pedido expedido
					{ "  C5_BLQ   == '1'          " ,'BR_PRETO'      },; // Pedido bloquedo por regra
					{ "  C5_BLQ   == '2' " ,'BR_CINZA'   }}  // Pedido bloquedo por crédito
	ElseIf AllTrim(FWCodEmp()) == '02'
	// Alterado por Júlio Soares em 10/12/2013 para contemplar a legenda de expedição do pedido.
		_aCores := {{ "  C5_SALDO == 'R' .Or. SUBSTR(C5_NOTA,1,1) == 'X' "                                                                                           ,'BR_CANCEL'  },; // Pedido eliminado por resíduo
					{ "  C5_SALDO <> 'S'  .And. Empty(C5_LIBEROK) .And. Empty(C5_NOTA)  .And.                                                 Empty(C5_BLQ)  "       ,'ENABLE'     },; // Pedido em aberto - Alterado por Renan Santos em 20/09/2016 - conteudo anterior: C5_SALDO <> '' - Estava sobrepondo a legenda de faturamento parcial.
					{ "                       !Empty(C5_LIBEROK) .And. Empty(C5_NOTA)  .And.                                                 Empty(C5_BLQ)  "        ,'BR_AMARELO' },; // Pedido liberado
					{ "  C5_SALDO == 'S' "                                                                                                                           ,'BR_PINK'    },; // Pedido faturado parcialmente
					{ "  C5_SALDO == 'E' "                                                                                                                           ,'BR_LARANJA' },; // Pedido totalmente faturado
					{ "                                                                                                                            C5_BLQ   == '1' " ,'BR_PRETO'   },; // Pedido bloquedo por regra
					{ "                                                                                                                            C5_BLQ   == '2' " ,'BR_CINZA'   }}  // Pedido bloquedo por crédito
	EndIf
return _aCores
/* aCores Original
 aCores := {{ "Empty(C5_LIBEROK) .And. Empty(C5_NOTA) .And. Empty(C5_BLQ)"  ,'ENABLE' },;		//Pedido em Aberto
			{ "!Empty(C5_NOTA) .Or. C5_LIBEROK=='E'  .And. Empty(C5_BLQ)"   ,'DISABLE'},;		   	//Pedido Encerrado
			{ "!Empty(C5_LIBEROK) .And. Empty(C5_NOTA) .And. Empty(C5_BLQ)" ,'BR_AMARELO'},;
			{ "C5_BLQ == '1'"                                               ,'BR_AZUL'},;	//Pedido Bloquedo por regra
			{ "C5_BLQ == '2'"                                               ,'BR_LARANJA'}}	//Pedido Bloquedo por verba
*/