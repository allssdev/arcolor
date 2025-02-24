#include "totvs.ch"
/*/{Protheus.doc} MA455MNU
@description Ponto de Entrada para inserir botoes na tela de Liberacao de Estoque do sistema.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 21/03/2013
@version 1.0
@return aRotina, array, Array com as funções do aRotina.
@type function
@see https://allss.com.br
/*/
user function MA455MNU()
	local _aSavArea := GetArea()
	aRotina := {	{ "&Pesquisar"       , "PesqBrw"                 , 0 , 1, 0, .F. },;
					{ "&Reavalia"        , "U_RFATE057()"            , 0 , 0, 0, NIL },;
					{ "&Ajusta Item"     , "U_RFATE061('A455LibAlt')", 0 , 0, 0, NIL },;
					{ "Libera &Item"     , "A455LibMan"              , 0 , 0, 0, NIL },;
					{ "Libera &Todos"    , "A456LibMan"              , 0 , 0, 0, NIL },;
					{ "&Gera  Ordem Sep.", "U_RFATA005('MA455MNU')"  , 0 , 2, 0, NIL },;
					{ "&Impr. Ordem Sep.", "U_RFATR013('MA455MNU')"  , 0 , 2, 0, NIL },;
					{ "&Adm.Ordem Sep."  , "ACDA100()"               , 0 , 2, 0, NIL },;
					{ "&Legenda"         , "A450Legend"              , 0 , 3, 0, .F. } }
	//				{ "&Ajusta Item"     , "A455LibAlt"              , 0 , 4, 0, NIL },;
	//				{ "&Ajusta Item"     , "U_RFATE061('A455LibAlt')", 0 , 0, 0, NIL },;
	RestArea(_aSavArea)
return aRotina