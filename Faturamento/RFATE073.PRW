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
@description Execblock para enviar o e-mail ao comercial e expedição após a produção do produto estar finalizada.
            Esse fonte está agendado no ambiente SCHEDULE.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 28/08/2024
@version 1.0
@return _cNome, caracter, Nome do Motorista
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

    BeginSql Alias "SC2PROD"
        SELECT
            C9_PEDIDO
        FROM SC9010 SC9 (NOLOCK)
        INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.D_E_L_E_T_ = '' AND C5_NUM = C9_PEDIDO AND C5_XLININD = '1'
                                          AND C5_TPOPER = '01'
        WHERE SC9.D_E_L_E_T_ = ''
            AND C9_BLEST <> ''
            AND C9_NFISCAL = ''
            AND C9_BLCRED = ''
            AND C9_ORDSEP = ''
            AND C9_XCTREIN = ''
        GROUP BY C9_PEDIDO,C5_XLININD
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
                    ,(SELECT B8_PRODUTO,SUM(B8_SALDO-B8_EMPENHO) B8_SALDO FROM SB8010 SB8 (NOLOCK) WHERE SB8.D_E_L_E_T_ = '' GROUP BY B8_PRODUTO)SB8X
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
                AADD(_aProd,{SC9PROD->C9_PRODUTO,SC9PROD->B5_CEME,C9_QTDLIB,SC9PROD->C9_PEDIDO})
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
         SC2PROD->(dbSkip())
    EndDo
    SC2PROD->(dbCloseArea())
EndIf
    RESET ENVIRONMENT
return
