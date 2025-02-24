#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} MTC050MNU
@description Ponto de Entrada para adição de menu na rotina de consulta de produtos,
neste caso estamos utilizando para trazer a consulta F4
@author Diego Rodrigues(ALL System Solutions)
@since 05/01/2020
@version 1.0
@return aButtons, array, Retorna os botões adicionados na enchoice.
@type function
@see https://allss.com.br
/*/

User Function MTC050MNU

	Set key VK_F4 TO MT010F4()

Return Nil

Static Function MT010F4()
	Local cFilBkp := cFilAnt
	Set Key VK_F4 TO
	If FWModeAccess("SB1")=="E"
		cFilAnt := SB1->B1_FILIAL
	EndIf
	MaViewSB2(SB1->B1_COD)
	cFilAnt := cFilBkp
	Set Key VK_F4 TO MT010F4()
Return Nil
