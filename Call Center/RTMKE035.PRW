#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function RTMKE035
    LOCALIZAÇÃO : Function RTMKE035 - Responsável por validar se existe produto do tipo Industrial
    chamada nas rotinas TK271CPY/TK271END - IIF(EXISTBLOCK("RTMKE035"),EXECBLOCK("RTMKE035"),.T.) 
    DESCRIÇÃO : Permite executar a validação do usuário ao confirmar a OP.
    @type  Function
    @author Diego Rodrigues
    @since 15/08/2024
    @version 1.0
    /*/
  
USER FUNCTION RTMKE035()

Local _lRet := .F.
//Private _cInd := ""

     BeginSql Alias "LIND"
        SELECT
            B5_XLINPRO
        FROM SUB010 SUB (NOLOCK)
        INNER JOIN SB5010 SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = '' AND B5_COD = UB_PRODUTO 
                                        AND B5_FILIAL = UB_FILIAL AND B5_XLINPRO = '1'
        WHERE SUB.D_E_L_E_T_ = ''
            AND UB_NUM = %Exp:SUA->UA_NUM%
        GROUP BY B5_XLINPRO
    EndSql

    if LIND->(!EOF())
        _cInd := LIND->B5_XLINPRO
        _lRet := .T.
    endif
    LIND->(dbCloseArea())

Return _lRet


