#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
#include "protheus.ch"
/*/{Protheus.doc} RPCPE015
Fonte para controlar a numerçaão das fichas pallets de forma sequencial.
@author Diego Rodrigues(ALL System Solutions)
@since 21/05/2024
@version P12
@type function
@see https://allss.com.br
/*/

User Function RPCPE015(_cOp)

Local   _aSavArea := GetArea()
Local   _aSavSD4  := SD4->(GetArea())
Local   _aSavSB1  := SB1->(GetArea())
Local   _aSavSD3  := SD3->(GetArea())
Local   _aSavSH6  := SH6->(GetArea())
Local   _aSavSC2  := SC2->(GetArea())
Local _cNrFicha  := "01"

If FunName() == "MATA250" .OR. FunName() == "MATA681"
    BeginSql Alias "FICHA"
        SELECT
           ISNULL(CAST(MAX(D3_XNRFICH)+1 AS VARCHAR),'') AS D3_XNRFICH
        FROM SD3010 SD3 (NOLOCK)
        WHERE SD3.D_E_L_E_T_ = ''
        AND SD3.D3_OP = %Exp:_cOp%
        AND SD3.D3_ESTORNO = ''
        AND SD3.D3_CF = 'PR0'
    EndSql

    if FICHA->(!EOF()) .and. !Empty(FICHA->D3_XNRFICH)
        _cNrFicha := FICHA->D3_XNRFICH 
    Else
        _cNrFicha := '1'
    EndIF

    FICHA->(dbCloseArea())
EndIF
RestArea(_aSavSC2)
RestArea(_aSavSD3)
RestArea(_aSavSH6)
RestArea(_aSavSB1)
RestArea(_aSavSD4)
RestArea(_aSavArea)

Return(_cNrFicha)
