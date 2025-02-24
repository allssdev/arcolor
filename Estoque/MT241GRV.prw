#include "totvs.ch"

#define CLRF CHR(13)+CHR(10)

/*/{Protheus.doc} User Function nomeFunction
    LOCALIZAÇÃO :  função A241GRAVA (Gravação do movimento) 

    EM QUE PONTO : Após a gravação dos dados (aCols) no SD3, e tem a finalidade de atualizar algum arquivo ou campo.
    Envia vetor com os parâmetros:
    PARAMIXB[1] = Número do Documento
    PARAMIXB[2] = Vetor bidimensional com nome campo/valor do campo (somente será enviado se o Ponto de Entrada MT241CAB for utilizado).
    @type  Function
    @author Fernando Bombardi 
    @since 17/04/2023
    @version 1.0
    @history 31/08/2023, Diego Rodrigues (diego.rodrigues@allss.com.br) - Adequação do fonte para envio do e-mail quando for TM 001 incluir a informação "Produto Físico", TM 002 a informação "Saldo Sistêmico"
    /*/
User Function MT241GRV()
Local _cDocMov  := PARAMIXB[1]
Local _cTmBfDev := SuperGetMV("MV_XTMD241"  ,.F.,"001")
Private _cTM      := SD3->D3_TM

     //Envia e-mail de notificação de Movimento Interno Nota Fiscal de Devolução
    if Alltrim(_cTM) $ Alltrim(_cTmBfDev)
        MT241MAIL(_cDocMov)
    endif


Return

/*/{Protheus.doc} MT241MAIL 
    Função para envio de e-mail de notificação Movimento Interno Nota Fiscal de Devolução.
    @type  Function
    @author Fernando Bombardi
    @since 17/04/2023
    @version 1.0
/*/
Static Function MT241MAIL(_cDocMov)
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
Local _nItMov         := 0
Local _nPosCod     := aScan(aHeader,{|x|AllTrim(x[02])=="D3_COD"   })
Local _nPosQtd     := aScan(aHeader,{|x|AllTrim(x[02])=="D3_QUANT"   })
Local _nPosLot     := aScan(aHeader,{|x|AllTrim(x[02])=="D3_LOTECTL"   })
Local _nPosDtl     := aScan(aHeader,{|x|AllTrim(x[02])=="D3_DTVALID"   })

    _cMail          := SuperGetMV("MV_XFRO241"  ,.F.,'fernando.bombardi@allss.com.br')
    _cCC 	        := SuperGetMV("MV_XCC241"   ,.F.,'fernando.bombardi@allss.com.br')
    _cBCC           := SuperGetMV("MV_XBCC241"  ,.F.,'fernando.bombardi@allss.com.br')

    If Alltrim(_cTM) == "001"
        _cAssunto       := "[Arcolor] - Movimentação Interna Nro: " + _cDocMov + " - Nota Fiscal de Devolução - Produto Físico"
        _cHtml          := "<h2> Movimentação Interna Nro: " + _cDocMov + " - Nota Fiscal de Devolução - Produto Físico </h2>" + CLRF
    else
        _cAssunto       := "[Arcolor] - Movimentação Interna Nro: " + _cDocMov + " - Nota Fiscal de Devolução - Saldo Sistêmico"
        _cHtml          := "<h2> Movimentação Interna Nro: " + _cDocMov + " - Nota Fiscal de Devolução - Saldo Sistêmico</h2>" + CLRF
    End If
    _cHtml          += "<br><br>"                                                                   + CLRF
    _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                      + CLRF
    _cHtml          += " 	<thead bgcolor='#808080'> "                                             + CLRF
    _cHtml          += " 		<tr border='1'> "                                                   + CLRF
    _cHtml          += " 			<th border='1' align='center' width='50'>Código     </th> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='450'>Descrição  </td> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Quantidade </td> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Lote       </td> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Data Validade</td> "  + CLRF    
    _cHtml          += " 		</tr> "                                                             + CLRF
    _cHtml          += " 	</thead> "                                                              + CLRF
    _cHtml          += " 	<tbody> "                                                               + CLRF

    for _nItMov := 1 to Len(aCols)

        _cHtml   	    += " <tr> " + CLRF
        _cHtml   	    += " <th valign='top' align='center' border='1' width='50'>" + aCols[_nItMov][_nPosCod] + "</th> "    + CLRF
        _cHtml   	    += " <td valign='top' align='center' border='1' width='450'>" + Posicione("SB1",1,XFILIAL("SB1")+Alltrim(aCols[_nItMov][_nPosCod]),"B1_DESC") + "</td> " + CLRF
        _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + Transform(aCols[_nItMov][_nPosQtd]  , "@E 999,999,999,999.99") + "</td> " + CLRF
        _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + aCols[_nItMov][_nPosLot] + "</td> " + CLRF
        _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + DTOC(aCols[_nItMov][_nPosDtl]) + "</td> " + CLRF
        _cHtml   	    += " </tr> " + CLRF

    next

    _cHtml += "</table><br>" + CLRF
    _cHtml := StrTran(_cHtml,CLRF,"")

    lRetMail := U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    if !lRetMail //Se ocorrer erro uma nova tentativa de envio do e-mail
        U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    endif

Return
