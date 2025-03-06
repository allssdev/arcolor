#include 'totvs.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch"
#include "tbiConn.ch"
#include "tbiCode.ch"
#include "protheus.ch"

#DEFINE _CRLF   CHR(13)+CHR(10)
/*/{Protheus.doc} RFATE073
@description Execblock para enviar o e-mail a expedição para os produtos da linha industrial que já possuem saldos liberados.
            Esse fonte está agendado no ambiente SCHEDULE.
@author Diego Rodrigues (ALLSS Soluções em Sistemas)
@since 28/08/2024
@version 1.0
@return 
@type function
@see https://allss.com.br
/*/
user function RFATE073()

Local 	_aProd	    := {}
Local   _cPedido    := ""
Local   _cQUpd     := ""
//local   _aPedidos   := {}
//Local   _Nx         := 0
private lBlind 		:= IsBlind()
private _cRotina 	:= "RFATE073"

if lBlind
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"  TABLES "SC9", "SC5", "SB5", "SB1", "SB8" 
    //Inicio do Bloco de processamento para envio dos e-mails para a expedição.
    BeginSql Alias "SC9PED"
        SELECT
            C9_PEDIDO,C9_DTLIBCR
        FROM SC9010 SC9 (NOLOCK)
        INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C9_PEDIDO AND C5_XLININD = '1'
                                          AND C5_TPOPER = '01'
        WHERE SC9.D_E_L_E_T_ = ''
            AND C9_BLEST <> ''
            AND C9_NFISCAL = ''
            AND C9_BLCRED = ''
            AND C9_ORDSEP = ''
            AND C9_XCTREIN = ''
        GROUP BY C9_PEDIDO,C9_DTLIBCR
        ORDER BY C9_DTLIBCR, C9_PEDIDO
    EndSql
    While SC9PED->(!EOF())
        //_aPedidos   := StrTokArr(AllTrim(SC9PED->C2_XPEDVEN),"/")
        _cPedido := SC9PED->C9_PEDIDO
        //_Nx := 0
        //_cPedidos   := "%" + FormatIn(SC9PED->C2_XPEDVEN,"/")+ "%"
    
        //For _Nx := 1 to Len(_aPedidos)
                //_cPedido := _aPedidos[_Nx]
            BeginSql Alias "SC9PROD"
                SELECT
                    SC9X.C9_PEDIDO, SC9X.C9_PRODUTO,SC9X.B5_CEME,SC9X.C9_QTDLIB,SC9X.C5_XLININD
                FROM
                    (
                    SELECT
                    C9_PEDIDO, C9_PRODUTO,B5_CEME, C9_QTDLIB, B5_XLINPRO, C5_XLININD
                    FROM SC9010 SC9 (NOLOCK)
                    INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C9_PEDIDO AND C5_XLININD = '1'
                                                      AND C5_TPOPER = '01'
                    INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C9_PRODUTO 
                                                      AND B5_FILIAL = C9_FILIAL AND B5_XLINPRO = '1'
                    WHERE SC9.D_E_L_E_T_ = ''
                         AND C9_BLEST <> ''
                         AND C9_NFISCAL = ''
                         AND C9_BLCRED = ''
                         AND C9_ORDSEP = ''
                         AND C9_XCTREIN = ''
                         AND C9_PEDIDO = %Exp:_cPedido%
                    GROUP BY C9_PEDIDO, C9_PRODUTO,B5_CEME, C9_QTDLIB, B5_XLINPRO, C5_XLININD)SC9X
                    ,(SELECT
                        C9_PEDIDO, COUNT(*) AS CONTSC9
                    FROM SC9010 SC9 (NOLOCK)
                    INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C9_PEDIDO AND C5_XLININD = '1'
                                                      AND C5_TPOPER = '01'
                    INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C9_PRODUTO 
                                                      AND B5_FILIAL = C9_FILIAL AND B5_XLINPRO = '1'
                    WHERE SC9.D_E_L_E_T_ = ''
                          AND C9_NFISCAL = ''
                          AND C9_BLCRED = ''
                          AND C9_ORDSEP = ''
                          AND C9_XCTREIN = ''
                    GROUP BY C9_PEDIDO
                    )CONTPED
                    ,(SELECT
                    C9_PEDIDO, COUNT(*) AS CONTSLD
                    FROM SC9010 SC9 (NOLOCK)
                    INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C9_PEDIDO AND C5_XLININD = '1'
                                                      AND C5_TPOPER = '01'
                    INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C9_PRODUTO 
                                                      AND B5_FILIAL = C9_FILIAL AND B5_XLINPRO = '1'
                    ,(SELECT B8_PRODUTO,SUM(B8_SALDO-B8_XEMPIND-B8_EMPENHO) B8_SALDO FROM SB8010 SB8 (NOLOCK) WHERE SB8.D_E_L_E_T_ = '' GROUP BY B8_PRODUTO)SB8X
                    WHERE SC9.D_E_L_E_T_ = ''
                         AND C9_NFISCAL = ''
                         AND C9_BLCRED = ''
                         AND C9_ORDSEP = ''
                         AND C9_XCTREIN = ''
                         AND SB8X.B8_PRODUTO = C9_PRODUTO AND B8_SALDO >= C9_QTDLIB
                    GROUP BY C9_PEDIDO
                    )CONTSALD
                WHERE SC9X.C9_PEDIDO = CONTPED.C9_PEDIDO
                     AND SC9X.C9_PEDIDO = CONTSALD.C9_PEDIDO
                     AND CONTPED.CONTSC9 = CONTSALD.CONTSLD
                ORDER BY SC9X.C9_PEDIDO, SC9X.C9_PRODUTO
            EndSql

            While SC9PROD->(!EOF()) .AND. SC9PROD->C9_PEDIDO == _cPedido
                AADD(_aProd,{SC9PROD->C9_PRODUTO,SC9PROD->B5_CEME,SC9PROD->C9_QTDLIB,SC9PROD->C9_PEDIDO})

                    _cQUpd :=" UPDATE  " + RetSqlName("SB8")                    +_CRLF
                    _cQUpd += " SET B8_XEMPIND = B8_XEMPIND + '" + cValToChar(SC9PROD->C9_QTDLIB) + "' " +_CRLF
                    _cQUpd += " WHERE "                                         +_CRLF
                    _cQUpd += " 	B8_PRODUTO = '" + SC9PROD->C9_PRODUTO + "' "+_CRLF
                    _cQUpd += " 	AND D_E_L_E_T_ = '' "                       +_CRLF
                    _cQUpd += " 	AND (B8_SALDO-B8_XEMPIND) > 0 "  +_CRLF
                    If TCSQLExec(_cQUpd) < 0
                        MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_010",'STOP')
                    EndIf	

                SC9PROD->(dbSkip())
            EndDo
            SC9PROD->(dbCloseArea())

            If ExistBlock("RFATE072") .and. !Empty(_aProd)
                    U_RFATE072(	_cPedido,3,_aProd)
                    _aProd	    := {}
                    _cQUpd :=" UPDATE  " + RetSqlName("SC9")  +_CRLF
                    _cQUpd += " SET C9_XCTREIN = '1'  " +_CRLF
                    _cQUpd += " WHERE " +_CRLF
                    _cQUpd += " 	C9_PEDIDO = '" + _cPedido + "' "+_CRLF
                    _cQUpd += " 	AND D_E_L_E_T_ = '' " + _CRLF
                    _cQUpd += " 	AND C9_BLEST <> '' " + _CRLF
                    _cQUpd += " 	AND C9_BLCRED = '' " + _CRLF
                    _cQUpd += " 	AND C9_NFISCAL = '' " + _CRLF
                    If TCSQLExec(_cQUpd) < 0
                        MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_010",'STOP')
                    EndIf	
            EndIf	
        //Next
         SC9PED->(dbSkip())
    EndDo
    SC9PED->(dbCloseArea())
    //Fim do Bloco de processamento para envio dos e-mails para a expedição.

    //Inicio do bloco para atualização da tabela SB8
        AjustaSB8()
    //Fim do bloco para atualização da tabela SB8
EndIf
    RESET ENVIRONMENT
return

/*/{Protheus.doc} AjustaSB8 (RFATE073)
@description Sub-rotina utilizada para acertar o campo B8_XEMPIND para limpeza das informações de armazenamento do empenho da linha industrial após o faturamento
@author Diego Rodrigues (ALLSS Soluções em Sistemas)
@since 26/11/2024
@version 1.0
@type function
@see https://allss.com.br
/*/
static function AjustaSB8()
	local _cQry := ""
	_cQry := " UPDATE SB8010 SET B8_XEMPIND = B8_SALDO "
	_cQry += " FROM "+RetSqlName("SB8")+" SB8 (NOLOCK) "
	_cQry += " WHERE B8_FILIAL = '" + FWFilial("SB8") + "' "
	_cQry += "   AND B8_SALDO = 0 "
	_cQry += "   AND B8_XEMPIND > 0 "
	_cQry += "   AND SB8.D_E_L_E_T_ = '' "
	TcSqlExec(_cQry)
	_cQry := ""
    
    /*_cQry := " UPDATE SB8010 SET B8_XEMPIND = 0 "
	_cQry += " FROM "+RetSqlName("SB8")+" SB8 (NOLOCK) "
	_cQry += " WHERE B8_FILIAL = '" + FWFilial("SB8") + "' "
	_cQry += "   AND B8_XEMPIND > B8_SALDO "
	_cQry += "   AND SB8.D_E_L_E_T_ = '' "
	TcSqlExec(_cQry)
	_cQry := ""*/
return

    /*COMENTADO DEVIDO AO ALINHAMENTO COMA VALERIA ONDE MENCIONOU QUE TERIA QUE FAZER ALTERAÇÃO NAS QUANTIDADES DAS ORDENS DE PRODUÇÃO.
    //Inicio do Bloco de processamento para envio dos e-mails para o comercial informando que o produto já está programado.
    BeginSql Alias "SC2PROD"
        SELECT
            C9_PEDIDO,C9_DTLIBCR
        FROM SC9010 SC9 (NOLOCK)
        INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C9_PRODUTO 
                                          AND B5_FILIAL = C9_FILIAL AND B5_XLINPRO = '1'
        INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' AND C2_PRODUTO = B5_COD
                                          AND C2_QUJE = 0 AND C2_DATRF = '' AND SUBSTRING(C2_NUM,1,1) <> 'Z' 
                                          AND C2_QUANT >= C2_XQTDIND
        WHERE SC9.D_E_L_E_T_ = ''
            AND C9_BLEST <> ''
            AND C9_NFISCAL = ''
            AND C9_BLCRED = ''
            AND C9_ORDSEP = ''
            AND C9_XCTREIN = ''
        GROUP BY C9_PEDIDO,C9_DTLIBCR
        ORDER BY C9_DTLIBCR, C9_PEDIDO
    EndSql
    While SC2PROD->(!EOF())
        //_aPedidos   := StrTokArr(AllTrim(SC2PROD->C2_XPEDVEN),"/")
        _cPedido := SC2PROD->C9_PEDIDO
        //_Nx := 0
        //_cPedidos   := "%" + FormatIn(SC2PROD->C2_XPEDVEN,"/")+ "%"
    
        //For _Nx := 1 to Len(_aPedidos)
                //_cPedido := _aPedidos[_Nx]
            BeginSql Alias "SC9PROD"
                SELECT
                    SC9X.C9_PEDIDO, SC9X.C9_PRODUTO,SC9X.B5_CEME,SC9X.C9_QTDLIB,SC9X.C2_NUM, SC9X.C2_DATPRF
                FROM
                    (
                    SELECT
                    C9_PEDIDO, C9_PRODUTO,B5_CEME, C9_QTDLIB, B5_XLINPRO, C2_NUM, C2_DATPRF
                    FROM SC9010 SC9 (NOLOCK)
                    INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C9_PEDIDO AND C5_XLININD = '1'
                                                      AND C5_TPOPER = '01'
                    INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C9_PRODUTO 
                                                      AND B5_FILIAL = C9_FILIAL AND B5_XLINPRO = '1'
                    INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' AND C2_PRODUTO = B5_COD
                                                      AND C2_QUJE = 0 AND C2_DATRF = '' AND SUBSTRING(C2_NUM,1,1) <> 'Z' 
                                                      AND C2_QUANT >= C2_XQTDIND
                    WHERE SC9.D_E_L_E_T_ = ''
                         AND C9_BLEST <> ''
                         AND C9_NFISCAL = ''
                         AND C9_BLCRED = ''
                         AND C9_ORDSEP = ''
                         AND C9_XCTREIN = ''
                         AND C9_PEDIDO = %Exp:_cPedido%
                    GROUP BY C9_PEDIDO, C9_PRODUTO,B5_CEME, C9_QTDLIB, B5_XLINPRO, C2_NUM, C2_DATPRF)SC9X
                    ,(SELECT
                        C9_PEDIDO, COUNT(*) AS CONTSC9
                    FROM SC9010 SC9 (NOLOCK)
                    INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C9_PEDIDO AND C5_XLININD = '1'
                                                      AND C5_TPOPER = '01'
                    INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C9_PRODUTO 
                                                      AND B5_FILIAL = C9_FILIAL AND B5_XLINPRO = '1'
                    WHERE SC9.D_E_L_E_T_ = ''
                          AND C9_NFISCAL = ''
                          AND C9_BLCRED = ''
                          AND C9_ORDSEP = ''
                          AND C9_XCTREIN = ''
                    GROUP BY C9_PEDIDO
                    )CONTPED
                    ,(SELECT
                    C9_PEDIDO, COUNT(*) AS CONTSLD
                    FROM SC9010 SC9 (NOLOCK)
                    INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C9_PEDIDO AND C5_XLININD = '1'
                                                      AND C5_TPOPER = '01'
                    INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = C9_PRODUTO 
                                                      AND B5_FILIAL = C9_FILIAL AND B5_XLINPRO = '1'
                    INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' AND C2_PRODUTO = B5_COD
                                                      AND C2_QUJE = 0 AND C2_DATRF = '' AND SUBSTRING(C2_NUM,1,1) <> 'Z' 
                                                      AND C2_QUANT >= C2_XQTDIND
                    WHERE SC9.D_E_L_E_T_ = ''
                         AND C9_NFISCAL = ''
                         AND C9_BLCRED = ''
                         AND C9_ORDSEP = ''
                         AND C9_XCTREIN = ''
                    GROUP BY C9_PEDIDO
                    )CONTSALD
                WHERE SC9X.C9_PEDIDO = CONTPED.C9_PEDIDO
                     AND SC9X.C9_PEDIDO = CONTSALD.C9_PEDIDO
                     AND CONTPED.CONTSC9 = CONTSALD.CONTSLD
                ORDER BY SC9X.C9_PEDIDO, SC9X.C9_PRODUTO
            EndSql

            While SC9PROD->(!EOF()) .AND. SC9PROD->C9_PEDIDO == _cPedido
                AADD(_aProd,{SC9PROD->C9_PRODUTO,SC9PROD->B5_CEME,SC9PROD->C9_QTDLIB,SC9PROD->C9_PEDIDO,Stod(SC9PROD->C2_DATPRF)})

                    _cQUpd :=" UPDATE  " + RetSqlName("SC2")                    +_CRLF
                    _cQUpd += " SET C2_XQTDIND = C2_XQTDIND + '" + cValToChar(SC9PROD->C9_QTDLIB) + "' " +_CRLF
                    _cQUpd += " WHERE "                                         +_CRLF
                    _cQUpd += " 	C2_NUM = '" + SC9PROD->C2_NUM + "' "        +_CRLF
                    _cQUpd += " 	AND D_E_L_E_T_ = '' "                       +_CRLF
                    If TCSQLExec(_cQUpd) < 0
                        MSGBOX("[TCSQLError] " + TCSQLError(),_cRotina+"_010",'STOP')
                    EndIf	
                SC9PROD->(dbSkip())
            EndDo
            SC9PROD->(dbCloseArea())

            If ExistBlock("RFATE072") .and. !Empty(_aProd)
                    U_RFATE072(	_cPedido,5,_aProd)
                    _aProd	    := {}
            EndIf	
        //Next
         SC2PROD->(dbSkip())
    EndDo
    SC2PROD->(dbCloseArea())
    */
