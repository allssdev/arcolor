#include "totvs.ch"

#define CLRF CHR(13)+CHR(10)

/*/{Protheus.doc} User Function nomeFunction
    LOCALIZAÇÃO :  Chamado no ponto de entrada MA440VLD para envio de e-mail após a liberação do pedido e credito
    @type  Function
    @author Diego Rodrigues 
    @since 14/08/2024
    @version 1.0
/*/

User Function RESTE013(_cProduto,_cDesc)
local _cMail          := ""
local _cAnexo         := ""
local _cCC 	          := ""
local _cBCC           := ""
local _cHtml          := ""
local _cAssunto       := ""
local _cFromOri       := "naoresponda@arcolor.com.br"
local _lExcAnex       := .F.
local _lAlert         := .T.
local _lHtmlOk        := .F.


    _cMail          := SuperGetMV("MV_XFRO013"  ,.F.,'diego.rodrigues@allss.com.br')
    _cCC 	        := SuperGetMV("MV_XCC013"   ,.F.,'diego.rodrigues@allss.com.br')
    _cBCC           := SuperGetMV("MV_XBCC013"  ,.F.,'diego.rodrigues@allss.com.br')

        _cAssunto       := "[Arcolor] - Novo Cadastro de Produto  " + _cProduto + " "
        _cHtml          := "<h2> Novo Produto Cadastrado " + _cProduto + " - "+ _cDesc + ". Cadastrar a especificação do produto. </h2>" + CLRF

    _cHtml          += "<br><br>"                                                                   + CLRF
    _cHtml := StrTran(_cHtml,CLRF,"")

    lRetMail := U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    if !lRetMail //Se ocorrer erro uma nova tentativa de envio do e-mail
        U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    endif

Return
