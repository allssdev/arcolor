#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} GRVCT3
@description O ponto de entrada verifica se pode ou não atualizar saldos do Centro de Custo. Este ponto está sendo utilizado para otimização de performance das rotinas de contabilização. Contudo, se faz necessária a execução da rotina de Reprocessamento dos Saldos contábeis. O único tratamento aqui é passar o parâmetro falso como retorno.
@obs Para aumentar a performance das rotinas com Contabilização On-Line, Apuração de Resultado (CTBA211) e nas rotinas de inclusão de lançamentos pelo CTB (CTBA101 e CTBA102), podem ser utilizados os seguintes pontos de entrada:
	·    GRVCT3
	·    GRVCT4
	·    GRVCT7
	·    GRVCTI
	Estes pontos de entrada devem efetuar o retorno lógico .F.

	>>> Importante
		·    Desta forma  as tabelas de saldos não serão atualizadas no momento da inclusão do lançamento, sendo necessária a execução periódica da rotina de Reprocessamento, para que os saldos anteriores exibidos nos relatórios sejam os corretos.
		·    Utilizar o parâmetro MV_ATUSAL definido como 'S' para que o processo de gravação do CT2 seja mais rápido
@author Anderson C. P. Coelho
@since 20/07/2015
@version 1.0
@return lRet, ${return_description}
@type function
@see https://allss.com.br
/*/
user function GRVCT3() ; return .F.