#include "totvs.ch"

#define CLRF CHR(13)+CHR(10)

/*/{Protheus.doc} User Function nomeFunction
    LOCALIZAÇÃO :  Chamado no ponto de entrada MA440VLD para envio de e-mail após a liberação do pedido e credito
    @type  Function
    @author Diego Rodrigues 
    @since 19/07/2024
    @version 1.0
/*/

User Function RFATE072(_cPedido,_nTp,_aProd)
local _cMail          := ""
local _cAnexo         := ""
local _cCC 	          := ""
local _cBCC           := ""
local _cHtml          := ""
local _cAssunto       := ""
Local _cCodCli        := ""
Local _cNomCli        := ""
Local _cVend          := ""
Local _cSuper         := ""
local _cFromOri       := "naoresponda@arcolor.com.br"
local _lExcAnex       := .F.
local _lAlert         := .T.
local _lHtmlOk        := .F.
Local   _nX		   := 0

    _cCC 	        := SuperGetMV("MV_XCC072"   ,.F.,'diego.rodrigues@allss.com.br')
    _cBCC           := SuperGetMV("MV_XBCC072"  ,.F.,'diego.rodrigues@allss.com.br')

    _cCodCli        := Posicione("SC5",1,XFILIAL("SC5")+_cPedido,"C5_CLIENTE")+ " - "+Posicione("SC5",1,XFILIAL("SC5")+_cPedido,"C5_LOJACLI")
    _cNomCli        := Posicione("SC5",1,XFILIAL("SC5")+_cPedido,"C5_NOMCLI")
    _cVend          := Posicione("SC5",1,XFILIAL("SC5")+_cPedido,"C5_VEND1")
    _cSuper         := Posicione("SA3",1,XFILIAL("SA3")+_cVend,"A3_SUPER")
    _cNomSup        := If(Empty(_cSuper),Posicione("SA3",1,XFILIAL("SA3")+_cVend,"A3_NOME"),Posicione("SA3",1,XFILIAL("SA3")+_cSuper,"A3_NOME"))
    _cEmailSup      := If(Empty(_cSuper),Posicione("SA3",1,XFILIAL("SA3")+_cVend,"A3_EMAIL"),Posicione("SA3",1,XFILIAL("SA3")+_cSuper,"A3_EMAIL"))

    If _nTp == 1
        _cMail          := SuperGetMV("MV_XFROFIN"  ,.F.,'diego.rodrigues@allss.com.br')+IIF(Empty(_cEmailSup),"",";"+_cEmailSup)
        _cAssunto       := "[Arcolor] - Financeiro - Pedido de Venda  " + _cPedido + " com produtos de Linha Industrial"
        _cHtml          := "<h2> Pedido de Venda " + _cPedido + " - com produtos de Linha Industrial aguardando Liberação do Financeiro </h2>" + CLRF
        _cHtml          += "<br><br>"                                                                                                           + CLRF
    elseIf _nTp == 2
        _cMail          := SuperGetMV("MV_XFROPRD"  ,.F.,'diego.rodrigues@allss.com.br')+IIF(Empty(_cEmailSup),"",";"+_cEmailSup)
        _cAssunto       := "[Arcolor] - Produção - Pedido de Venda  " + _cPedido + " com produtos de Linha Industrial"
        _cHtml          := "<h2 style=color:blue> Pedido de Venda " + _cPedido +  " Liberado para a produção </h2>"   + CLRF
        _cHtml          += "<h3> Cliente " + _cCodCli + " - " +Alltrim(_cNomCli)+          "</h3>"      + CLRF
        _cHtml          += "<h4> Supervisora " + Alltrim(_cNomSup)+                        "</h4>"      + CLRF
        _cHtml          += "<br><br>"                                                                   + CLRF
        _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                      + CLRF
        _cHtml          += " 	<thead bgcolor='#808080'> "                                             + CLRF
        _cHtml          += " 		<tr border='1'> "                                                   + CLRF
        _cHtml          += " 			<th border='1' align='center' width='50'>Código     </th> "     + CLRF
        _cHtml          += " 			<td border='1' align='center' width='450'>Descrição  </td> "    + CLRF
        _cHtml          += " 			<td border='1' align='center' width='150'>Quantidade </td> "    + CLRF
        _cHtml          += " 		</tr> "                                                             + CLRF
        _cHtml          += " 	</thead> "                                                              + CLRF
        _cHtml          += " 	<tbody> "   

        for _nX := 1 to Len(_aProd)
            _cHtml   	    += " <tr> "                                                                 + CLRF
            _cHtml   	    += " <th valign='top' align='center' border='1' width='50'>" + _aProd[_nX][1] + "</th> "                                                        + CLRF
            _cHtml   	    += " <td valign='top' align='center' border='1' width='450'>" + Posicione("SB1",1,XFILIAL("SB1")+Alltrim(_aProd[_nX][1]),"B1_DESC") + "</td> "  + CLRF
            _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + Transform(_aProd[_nX][3]  , "@E 999,999,999,999.99") + "</td> "                 + CLRF
            _cHtml   	    += " </tr> "                                                                + CLRF
        next
        _cHtml          += "</table><br>"                                                               + CLRF
    ElseIf _nTp == 3
        _cMail          := SuperGetMV("MV_XFROEXP"  ,.F.,'diego.rodrigues@allss.com.br')+IIF(Empty(_cEmailSup),"",";"+_cEmailSup)
        _cAssunto       := "[Arcolor] - Expedição - Pedido de Venda  " + _cPedido + " com produtos de Linha Industrial"
        _cHtml          := "<h2 style=color:green> Pedido de Venda " + _cPedido +  " Liberado para o faturamento. Produção Finalizada.</h2>"      + CLRF
        _cHtml          += "<h3> Cliente " + _cCodCli + " - " +Alltrim(_cNomCli)+          "</h3>"      + CLRF
        _cHtml          += "<h4> Supervisora " + Alltrim(_cNomSup)+                        "</h4>"      + CLRF
        _cHtml          += "<br><br>"                                                                   + CLRF
        _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                      + CLRF
        _cHtml          += " 	<thead bgcolor='#808080'> "                                             + CLRF
        _cHtml          += " 		<tr border='1'> "                                                   + CLRF
        _cHtml          += " 			<th border='1' align='center' width='50'>Código     </th> "     + CLRF
        _cHtml          += " 			<td border='1' align='center' width='450'>Descrição  </td> "    + CLRF
        _cHtml          += " 			<td border='1' align='center' width='150'>Quantidade </td> "    + CLRF
        _cHtml          += " 		</tr> "                                                             + CLRF
        _cHtml          += " 	</thead> "                                                              + CLRF
        _cHtml          += " 	<tbody> "   

        for _nX := 1 to Len(_aProd)
            _cHtml   	    += " <tr> "                                                                 + CLRF
            _cHtml   	    += " <th valign='top' align='center' border='1' width='50'>" + _aProd[_nX][1] + "</th> "                                                        + CLRF
            _cHtml   	    += " <td valign='top' align='center' border='1' width='450'>" + Posicione("SB1",1,XFILIAL("SB1")+Alltrim(_aProd[_nX][1]),"B1_DESC") + "</td> "  + CLRF
            _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + Transform(_aProd[_nX][3]  , "@E 999,999,999,999.99") + "</td> "                 + CLRF
            _cHtml   	    += " </tr> "                                                                + CLRF
        next
        _cHtml          += "</table><br>"                                                                                                         + CLRF
    EndIf
    _cHtml := StrTran(_cHtml,CLRF,"")

    lRetMail := U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    if !lRetMail //Se ocorrer erro uma nova tentativa de envio do e-mail
        U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    endif

Return
