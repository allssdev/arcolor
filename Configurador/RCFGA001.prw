#include 'rwmake.ch'
#include 'protheus.ch'
#include 'totvs.ch'
#include 'fileio.ch'
/*/{Protheus.doc} RCFGA001
@description Seleçao de diretorio para salvar arquivos (utilizado em diversas rotinas e validações de campos/parâmetros).
@author Arthur Silva (ALL System Solutions)
@since 26/03/2018
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RCFGA001()
	local _cTipo    := "Arquivos| *.*"
	local _cCaminho := cGetFile(_cTipo, "Informe onde deseja gravar o arquivo. ",0,"C:\",.F.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
return _cCaminho