#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} GRVCT3
@description O ponto de entrada verifica se pode ou n�o atualizar saldos do Centro de Custo. Este ponto est� sendo utilizado para otimiza��o de performance das rotinas de contabiliza��o. Contudo, se faz necess�ria a execu��o da rotina de Reprocessamento dos Saldos cont�beis. O �nico tratamento aqui � passar o par�metro falso como retorno.
@obs Para aumentar a performance das rotinas com Contabiliza��o On-Line, Apura��o de Resultado (CTBA211) e nas rotinas de inclus�o de lan�amentos pelo CTB (CTBA101 e CTBA102), podem ser utilizados os seguintes pontos de entrada:
	�    GRVCT3
	�    GRVCT4
	�    GRVCT7
	�    GRVCTI
	Estes pontos de entrada devem efetuar o retorno l�gico .F.

	>>> Importante
		�    Desta forma  as tabelas de saldos n�o ser�o atualizadas no momento da inclus�o do lan�amento, sendo necess�ria a execu��o peri�dica da rotina de Reprocessamento, para que os saldos anteriores exibidos nos relat�rios sejam os corretos.
		�    Utilizar o par�metro MV_ATUSAL definido como 'S' para que o processo de grava��o do CT2 seja mais r�pido
@author Anderson C. P. Coelho
@since 20/07/2015
@version 1.0
@return lRet, ${return_description}
@type function
@see https://allss.com.br
/*/
user function GRVCT3() ; return .F.