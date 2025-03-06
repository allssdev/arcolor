#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function RPCPE020
    LOCALIZAÇÃO : Function RPCPE020 -Gatilho responsabel pelo preenchimento do Campo Parcial/Total
    DESCRIÇÃO : Permite executar a validação do usuário no campo H6_QTDPROD/H6_QTPERD
    @type  Function
    @author Diego Rodrigues
    @since 18/02/2025
    @version 1.0
    /*/
User Function RPCPE020(_cOP)

Local   _aSavArea := GetArea()
Local   _aSavSD4  := SD4->(GetArea())
Local   _aSavSB1  := SB1->(GetArea())
Local   _aSavSD3  := SD3->(GetArea())
Local   _aSavSH6  := SH6->(GetArea())
Local   _aSavSC2  := SC2->(GetArea())
//Local _cRotina       := "RPCPE020"
Local _cTotal        := "P"
Local _cAliasSH6     := GetNextAlias()

        //Valida Roteiro
        BeginSql Alias _cAliasSH6
            SELECT
                C2_NUM+C2_ITEM+C2_SEQUEN NROP
                ,C2_QUANT QTDOP
                ,ISNULL(D3_COD,'') D3_COD
                ,ISNULL(SUM(D3_QUANT+D3_PERDA),0) APTO_TOTAL
            FROM SC2010 SC2 (NOLOCK)
            LEFT JOIN SD3010 SD3 (NOLOCK) ON SD3.D_E_L_E_T_ = '' AND  D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN AND D3_CF = 'PR0'
                WHERE SC2.D_E_L_E_T_ = ''
                AND C2_NUM+C2_ITEM+C2_SEQUEN = %Exp:_cOP% 
            GROUP BY C2_NUM+C2_ITEM+C2_SEQUEN,C2_QUANT,D3_COD
        EndSql

        If (_cAliasSH6)->(!EOF()) 
            If (((M->H6_QTDPROD) + (_cAliasSH6)->APTO_TOTAL) >= (_cAliasSH6)->QTDOP  .OR.;
             ((M->H6_QTDPERD) + (_cAliasSH6)->APTO_TOTAL) >= (_cAliasSH6)->QTDOP .OR. ;
             ((M->H6_QTDPROD+M->H6_QTDPERD) + (_cAliasSH6)->APTO_TOTAL) >= (_cAliasSH6)->QTDOP )
                _cTotal := "T"
            EndIF
        (_cAliasSH6)->(dbSkip())
        EndIf
        //Excluo a tabela temporária
        if Select(_cAliasSH6) > 0
            (_cAliasSH6)->(dbCloseArea())   
        endif
RestArea(_aSavSC2)
RestArea(_aSavSD3)
RestArea(_aSavSH6)
RestArea(_aSavSB1)
RestArea(_aSavSD4)
RestArea(_aSavArea)
Return(_cTotal)
