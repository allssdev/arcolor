#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} ACD166VL
@description Ponto de Entrada utilizado para for�ar o retorno como "falso", para inibir a pergunta "Deseja estornar a separacao ?" no processo final de separa��o/confer�nvia via coletor RF.
		LOCALIZA��O : Function ACDV166X() - Separa��o.
		DESCRI��O : � utilizado para desabilitar pergunta ao operador a qual permite alterar ou estornar uma Ordem de Separa��o encerrada. Obs.: Usado nas rotinas de Expedi��o (ACDV170) e Separa��o (ACDV166).
@author Anderson C. P. Coelho (ALL System Solutions)
@since 17/12/2018
@version 1.0
@return l�gico, .T. para habilitar ou .F. para desabilitar a pergunta.
@type function
@see https://allss.com.br
/*/
user function ACD166VL() ; return .F.