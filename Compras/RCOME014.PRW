#include "totvs.ch"

#define CLRF CHR(13)+CHR(10)

/*/{Protheus.doc} User Function RCOME014
    LOCALIZAÇÃO :  Localizado no ponto de entrada MT103FIM E MT140TOK
    Finalidade..: Essa rotina é para envio de e-mail para o departamento responsavel da qualidade após a classificação.
    @type  Function
    @author Diego Rodrigues
    @since 15/11/2023
    @version 1.0
/*/
User Function RCOME014(_cNota,_cSerie,_cCodFor,_cLoja)

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
Local _nPosCod     := aScan(aHeader,{|x|AllTrim(x[02])=="D1_COD"   })
Local _nPosQtd     := aScan(aHeader,{|x|AllTrim(x[02])=="D1_QUANT"   })
Local _nPosLot     := aScan(aHeader,{|x|AllTrim(x[02])=="D1_LOTECTL"   })
Local _nPosDtl     := aScan(aHeader,{|x|AllTrim(x[02])=="D1_DTVALID"   })

    _cMail          := SuperGetMV("MV_XFRO103"  ,.F.,'diego.rodrigues@allss.com.br')
    _cCC 	        := SuperGetMV("MV_XCC103"   ,.F.,'diego.rodrigues@allss.com.br')
    _cBCC           := SuperGetMV("MV_XBCC103"  ,.F.,'diego.rodrigues@allss.com.br')

    _cNomFor := Posicione("SA2",1,XFILIAL("SA2")+ _cCodFor+_cLoja,"A2_NOME")

    _cAssunto       := "[Arcolor] - Nota Fiscal: " + _cNota+ " - CLASSIFICADO - Favor avaliar inspeção de entrada"
    _cHtml          := "<h2> Nota Fiscal: " + _cNota + "-" + _cSerie + "/"+ "Fornecedor: "+_cNomFor+ " - CLASSICADA - Favor avaliar o inspeção de entrada </h2>" + CLRF

    _cHtml          += "<br><br>"                                                                   + CLRF
    _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                      + CLRF
    _cHtml          += " 	<thead bgcolor='#808080'> "                                             + CLRF
    _cHtml          += " 		<tr border='1'> "                                                   + CLRF
    _cHtml          += " 			<th border='1' align='center' width='50'>Produto    </th> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='450'>Descricao  </td> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Quantidade </td> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Lote</td> "    + CLRF
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
