#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
#include "protheus.ch"
/*/{Protheus.doc} RPCPE015
Fonte para controlar e inserir o numero de inseri na tabela QPK, chamado pelo ponto de entrada SD3250I
@author Diego Rodrigues(ALL System Solutions)
@since 21/05/2024
@version P12
@type function
@see https://allss.com.br
/*/

User Function RPCPE015(_cOp)

Local _aSavSD3	 := SD3->(GetArea())
Local _cNrFicha  := "01"

If FunName() == "MATA250"
    BeginSql Alias "FICHA"
        SELECT
           ISNULL('0'+CAST(MAX(D3_XNRFICH)+1 AS VARCHAR),'') AS D3_XNRFICH
        FROM SD3010 SD3 (NOLOCK)
        WHERE SD3.D_E_L_E_T_ = ''
        AND SD3.D3_OP = %Exp:_cOp%
        AND SD3.D3_ESTORNO = ''
        AND SD3.D3_CF = 'PR0'
    EndSql

    if FICHA->(!EOF()) .and. !Empty(FICHA->D3_XNRFICH)
        _cNrFicha := FICHA->D3_XNRFICH 
    Else
        _cNrFicha := '01'
    EndIF

    FICHA->(dbCloseArea())
EndIF
RestArea(_aSavSD3)

Return(_cNrFicha)
