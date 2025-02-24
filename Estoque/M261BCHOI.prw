#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} M261BCHOI
@description Ponto de Entrada para adição de botões na tela de Transfer. mod.2.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 25/02/2019
@version 1.0
@return aButtons, array, Retorna os botões adicionados na enchoice.
@type function
@see https://allss.com.br
/*/
user function M261BCHOI()
	local aButtons := {}
	if ExistBlock("RESTE008") .AND. INCLUI
		AADD(aButtons, { 'BITMAP', { || U_RESTE008(1) }, OemtoAnsi('Importa CSV'   ) })
		AADD(aButtons, { 'BITMAP', { || U_RESTE008(2) }, OemtoAnsi('Preenche Itens') })
	endif
return(aButtons)