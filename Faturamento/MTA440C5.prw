#include 'parmtype.ch'
#include "totvs.ch"
/*/{Protheus.doc} MTA440C5
@description Este ponto de entrada pertence à rotina rotina liberação de pedidos de venda, MATA440(). Está localizado na rotina de liberação manual, A440LIBERA(). A rotina permite que alguns campos do cabeçalho serjam alterados. Este ponto é usado para informar outros campos que também poderão ser alterados. Utilizado para inserir campos na liberação no pedido de vendas.
@author Marcelo Evangelista
@since 27/12/2012
@version 1.0
@return aCampos, array, Relação dos campos que podem ser alterados pela tela de liberação de pedidos de vendas.
@type function
@see https://allss.com.br
/*/
user function MTA440C5() 
	local   aCampos := {	"C5_TIPOCLI",;
							"C5_CLIENT" ,;
							"C5_LOJAENT",;
							"C5_CLIRET" ,;
							"C5_LOJARET",;
							"C5_REDESP" ,;
							"C5_TPFRETE",;
							"C5_MENNOTA",;
							"C5_MENPAD" ,;
							"C5_UFORIG" ,;
							"C5_UFDEST" ,;
							"C5_UFEMB"  ,;
							"C5_LOCEMB" ,;
							"C5_RECFAUT",;
							"C5_RECISS" ,;
							"C5_MUNPRES",;
							"C5_DESCMUN",;
							"C5_CMUNOR" ,;
							"C5_CMUNDE" ,;
							"C5_VEICULO",;
							"C5_TPDIV"  ,;
							"C5_TPOPER" ,;
							"C5_PESOL"  ,;
							"C5_PBRUTO" ,;
							"C5_VOLUME1",;
							"C5_ESPECI1" }
							//"C5_VEND1"  ,;
							//"C5_VENDRES",;
return aCampos