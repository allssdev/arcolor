#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#include 'apwebsrv.ch'
#include 'restful.ch'
#include 'xmlxfun.ch'
#include 'tbiconn.ch'
#include 'fileio.ch'
#include 'ap5mail.ch'
/*/{Protheus.doc} MGETMOED
@TODO Este ponto de entrada é executado caso o cadastro de moedas da database não esteja preenchido.
@description Ponto de entrada para realizar atualização de cadastro de moedas.Chama rotina customizada.
Usuario deve confirmar o cadastro. Sempre é enviado e-mail com valores obtidos.
@author Livia Della Corte (ALLSS Soluções em Sistemas)
@since 28/11/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
user function MGETMOED()
	local dData := dDataBase     
	if ExistBlock("RFINW004")
		U_RFINW004()
	endif
return .F.