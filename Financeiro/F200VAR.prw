#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} F200VAR
Ponto de entrada do CNAB a receber sera executado apos carregar os dados do arquivo de recepcao bancaria e sera
utilizado para alterar os dados recebidos. Neste caso, é utilizado para inserir conteúdo na variável cNumTit, quando
estiver sem, para que os títulos sem número no arquivo de retorno também tentem ser processados.
CNAB - COBRANCA - FILTRO
@author Anderson C. P. Coelho
@since 30/04/2013
@version P11
@type Function
@obs Sem observações
@see https://allss.com.br
@history 03/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Revisão de código-fonte em função da migração de release P12.1.33.
/*/
user function F200VAR()
if Empty(cNumTit)
	cNumTit := "NAO ENCONTRADO!"
endif
return
