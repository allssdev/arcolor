#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} ACD166VL
@description Ponto de Entrada utilizado para forçar o retorno como "falso", para inibir a pergunta "Deseja estornar a separacao ?" no processo final de separação/conferênvia via coletor RF.
		LOCALIZAÇÃO : Function ACDV166X() - Separação.
		DESCRIÇÃO : É utilizado para desabilitar pergunta ao operador a qual permite alterar ou estornar uma Ordem de Separação encerrada. Obs.: Usado nas rotinas de Expedição (ACDV170) e Separação (ACDV166).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 17/12/2018
@version 1.0
@return lógico, .T. para habilitar ou .F. para desabilitar a pergunta.
@type function
@see https://allss.com.br
/*/
user function ACD166VL() ; return .F.