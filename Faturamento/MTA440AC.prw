#include 'parmtype.ch'
#include "totvs.ch"
/*/{Protheus.doc} MTA440AC
@description Ponto de entrada  utilizado para inserir campos na liberação do pedido de vendas.
@author Marcelo Evangelista
@since 27/12/2012
@version 1.0
@return aCampos, array, Relação dos campos que podem ser alterados pela tela de liberação de pedidos de vendas.
@type function
@see https://allss.com.br
/*/
user function MTA440AC()
	local aCampos := {"C6_OPER","C6_ENTREG", "C6_TES", "C6_CLASFIS"}
return aCampos