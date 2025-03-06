#include 'totvs.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "tbiConn.ch"
#include "tbiCode.ch"
#include "protheus.ch"

#DEFINE _CRLF   CHR(13)+CHR(10)
/*/{Protheus.doc} RTMKE036
@description Execblock para enviar o e-mail de alerta a equipe comercial referente ao contato com os clientes baseado no follow up.
            Esse fonte está agendado no ambiente SCHEDULE.
@author Diego Rodrigues (ALLSS Soluções em Sistemas)
@since 06/11/2024
@version 1.0
@return 
@type function
@see https://allss.com.br
/*/
User function RTMKE036()

Local 	_aContato     := {}
Local   _cVend        := ""

private lBlind 		  := IsBlind()
private _cRotina 	  := "RTMKE036"

if lBlind
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"  TABLES "SC9", "SC5", "SB5", "SB1", "SB8" 

    //Verificação se existe contatos a serem enviados
    BeginSql Alias "SZDREP"
        SELECT
            ZD_DATAPRO DATA_PROGRAMADA,
            SA3.A3_COD COD_REPRES
        FROM SZD010 SZD (NOLOCK)
        INNER JOIN SA1010 SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = ZD_CODCLI AND A1_LOJA = ZD_LOJA 
        INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.D_E_L_E_T_ = '' AND A1_VEND = A3_COD
        WHERE SZD.D_E_L_E_T_ = ''
                AND ZD_DATAPRO = %Exp:ddatabase%
        GROUP BY ZD_DATAPRO,SA3.A3_COD

    EndSql
    While SZDREP->(!EOF())
        _cVend := SZDREP->COD_REPRES    
            //Distribuição por e-mail adicionando cada cliente por representante
            BeginSql Alias "SC9ALE"
            SELECT
                ZD_CODCLI COD_CLI, ZD_LOJA LOJA_CLI, ZD_NOMECLI NOMECLI, ZD_DATA ULT_CONTATO, ZD_DATAPRO DATA_PROGRAMADA
                ,A1_TEL TELEFONE, A1_TELEENT TEL_CONT
                ,SA3.A3_COD COD_REPRES, SA3.A3_NOME NOME_REPRES
                ,ISNULL(SA3.A3_SUPER,'') COD_SUPER, ISNULL(SA3S.A3_NOME,'') SUPER_NOME, ISNULL(SA3S.A3_EMAIL,'') SUPER_EMAIL
            FROM SZD010 SZD (NOLOCK)
            INNER JOIN SA1010 SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = '' AND A1_COD = ZD_CODCLI AND A1_LOJA = ZD_LOJA 
            INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.D_E_L_E_T_ = '' AND A1_VEND = A3_COD
            LEFT JOIN SA3010 SA3S (NOLOCK) ON SA3S.D_E_L_E_T_ = '' AND SA3.A3_SUPER = SA3S.A3_COD
            WHERE SZD.D_E_L_E_T_ = ''
                AND ZD_DATAPRO = %Exp:ddatabase%
            EndSql
            While SC9ALE->(!EOF()) 
                If _cVend == SC9ALE->COD_REPRES
                    AADD(_aContato,{SC9ALE->COD_CLI,;
                                    SC9ALE->LOJA_CLI,;
                                    SC9ALE->NOMECLI,;
                                    SC9ALE->TELEFONE,;
                                    SC9ALE->TEL_CONT,;
                                    SC9ALE->COD_REPRES})
                EndIf
                SC9ALE->(dbSkip())
            EndDo
            If !Empty(_aContato)
                RTMKEMAIL(_aContato)
                _aContato := {}
            EndiF
            SC9ALE->(dbCloseArea())
        SZDREP->(dbSkip())
    EndDo
    SZDREP->(dbCloseArea())
EndIf
    RESET ENVIRONMENT
return

Static Function RTMKEMAIL(_aContato)
local _cMail          := ""
local _cAnexo         := ""
local _cCC 	          := ""
local _cBCC           := ""
local _cHtml          := ""
local _cAssunto       := ""
Local _cCodCli        := ""
Local _cNomCli        := ""
Local _cVend          := ""
local _cFromOri       := "naoresponda@arcolor.com.br"
local _lExcAnex       := .F.
local _lAlert         := .T.
local _lHtmlOk        := .F.
Local   _nX		   := 0

    _cCC 	        := SuperGetMV("MV_XCC036"   ,.F.,'diego.rodrigues@allss.com.br')
    _cBCC           := SuperGetMV("MV_XBCC036"  ,.F.,'diego.rodrigues@allss.com.br')

    _cCodCli        := _aContato[1][1] +" - "+_aContato[1][2]
    _cNomCli        := _aContato[1][3]
    _cVend          := _aContato[1][6]
    _cEmailRep      := Posicione("SA3",1,XFILIAL("SA3")+_cVend,"A3_EMAIL")

        _cMail          := IIF(Empty(_cEmailRep),'diego.rodrigues@allss.com.br',_cEmailRep)
        _cAssunto       := "[Arcolor] - Alerta de Contato com clientes "
        _cHtml          := "<h2 style=color:blue> Nesta data temos follow ups agendados com os clientes </h2>"   + _CRLF
        _cHtml          += "<br><br>"                                                                   + _CRLF
        _cHtml          += "<table border='1' bgcolor='#FFFFFF'> "                                      + _CRLF
        _cHtml          += " 	<thead bgcolor='#808080'> "                                             + _CRLF
        _cHtml          += " 		<tr border='1'> "                                                   + _CRLF
        _cHtml          += " 			<th border='1' align='center' width='80'> Cliente   </th> "     + _CRLF
        _cHtml          += " 			<td border='1' align='center' width='450'>Nome Cliente  </td> " + _CRLF
        _cHtml          += " 			<td border='1' align='center' width='150'>Telefone </td> "      + _CRLF
        _cHtml          += " 			<td border='1' align='center' width='250'>Telefone_Contato </td> "  + _CRLF
        _cHtml          += " 		</tr> "                                                             + _CRLF
        _cHtml          += " 	</thead> "                                                              + _CRLF
        _cHtml          += " 	<tbody> "   

        for _nX := 1 to Len(_aContato)
            _cHtml   	    += " <tr> "                                                                 + _CRLF
            _cHtml   	    += " <th valign='top' align='center' border='1' width='80'>" + _aContato[_nX][1]+'-'+_aContato[_nX][2] + "</th> "  + _CRLF
            _cHtml   	    += " <td valign='top' align='center' border='1' width='450'>" + _aContato[_nX][3] + "</td> "  + _CRLF
            _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + _aContato[_nX][4] + "</td> "   + _CRLF
            _cHtml   	    += " <td valign='top' align='center' border='1' width='150'>" + _aContato[_nX][5] + "</td> "   + _CRLF
            _cHtml   	    += " </tr> "                                                                + _CRLF
        next
        _cHtml          += "</table><br>"                                                               + _CRLF
    _cHtml := StrTran(_cHtml,_CRLF,"")

    lRetMail := U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    if !lRetMail //Se ocorrer erro uma nova tentativa de envio do e-mail
        U_RCFGM001(/*cTitulo*/"",_cHtml,_cMail,_cAnexo,_cFromOri,_cBCC,_cAssunto,_lExcAnex,_lAlert,_lHtmlOk,_cCC)
    endif

Return

