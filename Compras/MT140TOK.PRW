#include "totvs.ch"

#define CLRF CHR(13)+CHR(10)

/*/{Protheus.doc} User Function nomeFunction
    LOCALIZA��O :  Function MA140Tudok() - Respons�vel por validar todos os itens do pr�-documento 
    Finalidade..: Este ponto � executado ap�s verificar se existem itens a serem gravados e tem como objetivo validar todos os itens do pr�-documento
    Envia vetor com os par�metros:
    PARAMIXB[1]			L�gico			.T. dados v�lidos / .F. dados inv�lidos
    @type  Function
    @author Diego Rodrigues
    @since 15/11/2023
    @version 1.0
    
    /*/
User Function MT140TOK

Local lRet := PARAMIXB[1]  
Local _cNota := cNFiscal
Local _cSerie := cSerie 
Local _cCodFor := cA100For
Local _cLoja := cLoja
Local _cTipo      := Alltrim(SuperGetMv("MV_XTIPME" ,,"/MP/EM/PI"))
Local _nPosCod     := aScan(aHeader,{|x|AllTrim(x[02])=="D1_COD"   })
// Inclus�o - Fernando Bombardi - 20/01/24 - Parametro para definir se � realizada a valida��o das MP/EM na NF.
Local _lValIt      := SuperGetMv("MV_XVALIT" ,,.T.)
// Fim Inclus�o
    
     //Envia e-mail de notifica��o de Movimento Interno Nota Fiscal de Devolu��o
    if lRet .and. Posicione("SB1",1,XFILIAL("SB1")+Alltrim(aCols[1][_nPosCod]),"B1_TIPO")$_cTipo
        MT140MAIL(_cNota,_cSerie,_cCodFor,_cLoja)
    /*elseIF 
        MsgStop("Itens da pr�-nota com divergencia","M140TOK_ATEN��O")
        lRet := .F.
    */
    endif
    
    // Inclus�o - Fernando Bombardi - 20/01/24 - Realiza valida��o dos intens da Nf.
    if _lValIt 
        lRet := MT140VAL(lRet)
    endif
    // Fim Inclus�o

Return lRet

/*/{Protheus.doc} MT241MAIL 
    Fun��o para envio de e-mail de notifica��o Movimento Interno Nota Fiscal de Devolu��o.
    @type  Function
    @author Diego Rodrigues
    @since 15/11/2023
    @version 1.0
/*/
Static Function MT140MAIL(_cNota,_cSerie,_cCodFor,_cLoja)
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

    _cMail          := SuperGetMV("MV_XFRO140"  ,.F.,'diego.rodrigues@allss.com.br')
    _cCC 	        := SuperGetMV("MV_XCC140"   ,.F.,'diego.rodrigues@allss.com.br')
    _cBCC           := SuperGetMV("MV_XBCC140"  ,.F.,'diego.rodrigues@allss.com.br')

    _cNomFor := Posicione("SA2",1,XFILIAL("SA2")+ _cCodFor+_cLoja,"A2_NOME")

    _cAssunto       := "[Arcolor] - Nota Fiscal: " + _cNota+ " - Cadastrada como Pr�-Nota - FAVOR CLASSIFICAR"
    _cHtml          := "<h2> Nota Fiscal: " + _cNota + "-" + _cSerie + "/"+ "Fornecedor: "+_cNomFor+ " - Cadastrada como Pr�-Nota - FAVOR CLASSIFICAR </h2>" + CLRF

    _cHtml          += "<br><br>"                                                                   + CLRF
    _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                      + CLRF
    _cHtml          += " 	<thead bgcolor='#808080'> "                                             + CLRF
    _cHtml          += " 		<tr border='1'> "                                                   + CLRF
    _cHtml          += " 			<th border='1' align='center' width='50'>Produto   </th> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='450'>Descricao </td> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Quantidade </td> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Lote</td> "    + CLRF
    _cHtml          += " 			<td border='1' align='center' width='150'>Data de Validade</td> "  + CLRF    
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

/*/{Protheus.doc} MT140VAL
    Fun��o para validar se os intens do tipo MP/EM da Pr� Nota est�o com o Pedido de Compra informados.
    @type  Static Function
    @author Fernando Bombardi
    @since 20/01/2024
    @version 1.0
/*/
Static Function MT140VAL(lRet)
Local _nPosPed  := aScan(aHeader,{|x|AllTrim(x[02])=="D1_PEDIDO" })
Local _nPosItNf := aScan(aHeader,{|x|AllTrim(x[02])=="D1_ITEM"   })
Local _nPosCod  := aScan(aHeader,{|x|AllTrim(x[02])=="D1_COD"    })
Local _nPosDes  := aScan(aHeader,{|x|AllTrim(x[02])=="D1_DESCR"  })
Local _cMsgRet  := ""
Local _nItPreNf := 0
Local _cPrdExc := SUPERGETMV( "MV_XPRDEXS",.F.,"2295")

    for _nItPreNf := 1 to Len(aCols)
        If !GdDeleted(_nItPreNf)
            _cTipPrd := Posicione("SB1",1,XFILIAL("SB1")+Alltrim(acols[_nItPreNf][_nPosCod]),"B1_TIPO")
            if Alltrim(_cTipPrd) $ "MP/EM" .and. !Alltrim(Alltrim(acols[_nItPreNf][_nPosCod]))$_cPrdExc
                if Empty(acols[_nItPreNf][_nPosPed]) 
                    _cMsgRet += acols[_nItPreNf][_nPosItNf] + " | " + acols[_nItPreNf][_nPosCod] + " | " + Alltrim(acols[_nItPreNf][_nPosDes]) + CLRF
                    lRet := .F.
                endif
            endif
        endif
    next

    if !lRet 
        MsgAlert("Os seguintes itens da Nota Fiscal, n�o possuem m�mero do Pedido de Compra informado:" + CLRF + CLRF +;
        "Item | C�digo          | Descricao" + CLRF + ;
        _cMsgRet + CLRF +;
        "Verifique os itens e informe o n�mero do Pedido de Compra.","[MT140TOK_001] - Aten��o")
    endif
Return(lRet)
