#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} FtNRunFlCx
@description A finalidade do ponto de entrada FtNRunFlCx, é permitir ou não a geração do processamento de Fluxo de caixa, no final da inclusão de um pedido de venda.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 12/11/2019
@version 1.0
@return _lRet, lógico, .T. - Executa o processamento de fluxo de caixa - .F. - Não executa o processamento de fluxo de caixa.
@type function
@see https://allss.com.br
/*/
user function FtNRunFlCx()
	local _lRet := .F.
return _lRet