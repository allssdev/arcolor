#include "totvs.ch"

#define CLRF CHR(13)+CHR(10)

/*/{Protheus.doc} User Function nomeFunction
    LOCALIZA��O :  fun��o A241GRAVA (Grava��o do movimento) 

    EM QUE PONTO : Ap�s a grava��o dos dados (aCols) no SD3, e tem a finalidade de atualizar algum arquivo ou campo.
    Envia vetor com os par�metros:
    PARAMIXB[1] = N�mero do Documento
    PARAMIXB[2] = Vetor bidimensional com nome campo/valor do campo (somente ser� enviado se o Ponto de Entrada MT241CAB for utilizado).
    @type  Function
    @author Fernando Bombardi 
    @since 17/04/2023
    @version 1.0
    @history 31/08/2023, Diego Rodrigues (diego.rodrigues@allss.com.br) - Adequa��o do fonte para envio do e-mail quando for TM 001 incluir a informa��o "Produto F�sico", TM 002 a informa��o "Saldo Sist�mico"
    /*/
User Function MT241GRV()
Local _cDocMov  := PARAMIXB[1]
Local _cTmBfDev := SuperGetMV("MV_XTMD241"  ,.F.,"001")
Private _cTM      := SD3->D3_TM

     //Envia e-mail de notifica��o de Movimento Interno Nota Fiscal de Devolu��o
    if Alltrim(_cTM) $ Alltrim(_cTmBfDev)
        MT241MAIL(_cDocMov)
    endif


Return

/*/{Protheus.doc} MT241MAIL 
    Fun��o para envio de e-mail de notifica��o Movimento Interno Nota Fiscal de Devolu��o.
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
        _cAssunto       := "[Arcolor] - Movimenta��o Interna Nro: " + _cDocMov + " - Nota Fiscal de Devolu��o - Produto F�sico"
        _cHtml          := "<h2> Movimenta��o Interna Nro: " + _cDocMov + " - Nota Fiscal de Devolu��o - Produto F�sico </h2>" + CLRF
    else
        _cAssunto       := "[Arcolor] - Movimenta��o Interna Nro: " + _cDocMov + " - Nota Fiscal de Devolu��o - Saldo Sist�mico"
        _cHtml          := "<h2> Movimenta��o Interna Nro: " + _cDocMov + " - Nota Fiscal de Devolu��o - Saldo Sist�mico</h2>" + CLRF
    End If
    _cHtml          += "<br><br>"                                                                   + CLRF
    _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                      + CLRF
    _cHtml          += " 	<thead bgcolor='#808080'> "                                             + CLRF
    _cHtml          += " 		<tr border='1'> "                                                   + CLRF
    _cHtml          += " 			<th border='1' align='center' width='50'>C�digo     </th> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='450'>Descri��o  </td> "    + CLRF
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
