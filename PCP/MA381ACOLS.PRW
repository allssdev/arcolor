#include "totvs.ch"

/*/{Protheus.doc} User Function MA381ACOLS
    LOCALIZA��O : Function MA381ACOLS - permite manipula��o / ordena��o do aCols, antes da montagem da GetDados.LOCALIZA��O: Na fun��o A381Manut(), ap�s a montagem do aCols.
    DESCRI��O : Filtra os empenhos na tela de acordo com o cadastro da tabela ZZB
    @type  Function
    @author Diego Rodrigues
    @since 01/07/2024
    @version 1.0
    /*/

User Function MA381COLS()

Local nOpc := ParamIxb[1]
Local _nX := 0
Local _nPosEmp := 0
Local _cUsrProd := SuperGetMV("MV_XUSRPROD",,"000000")
//Local _cQryZZB := GetNextAlias()
Local nPosProd := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_COD"})
Local nPosOpe := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_OPERAC"})//- Manipula��o E ordena��o do aCols conforme necessidade do usu�rio

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+SC2->C2_PRODUTO,.T.,.F.))
    If !Empty(SB1->B1_OPERPAD)
        If nOpc == 4 .and. !__cUserId$_cUsrProd .and. FUNNAME()=="MATA381"
            BeginSql Alias "TABZZB"
                SELECT
                    D4_COD, D4_QUANT, D4_ROTEIRO, D4_OPERAC, ISNULL(GF_OPERAC,'') GF_OPERAC
                FROM SD4010 SD4 (NOLOCK)
                LEFT JOIN SGF010 SGF (NOLOCK) ON SGF.D_E_L_E_T_ = '' AND GF_PRODUTO = D4_PRODUTO AND GF_COMP = D4_COD
                WHERE SD4.D_E_L_E_T_ = ''
                AND D4_OP = %Exp:COP%
                AND NOT EXISTS (SELECT TOP 1 1
                                FROM ZZB010 ZZB(NOLOCK)
                                WHERE ZZB.D_E_L_E_T_ = ''
                                AND ZZB_CODUSR = %Exp:__cUserId%
                                AND ZZB_PRODUT =  D4_PRODUTO
                                AND ZZB_OPERAC = D4_OPERAC
                                AND ZZB_ATIVO = '1')
                ORDER BY D4_COD
            EndSql

            For _nX := 1 to Len(Acols)
                If _nx <= Len(Acols)
                    TABZZB->(dbGoTop())
                    While TABZZB->(!EOF())
                        If TABZZB->D4_COD == acols[_nX][nPosProd] .AND. TABZZB->D4_OPERAC == acols[_nX][nPosOpe]//.AND. TABZZB->ZZB_CODUSR == __cUserId
                                //aTail(aCols[_nX]) := .T.
                                _nPosEmp := _nX
                            If _nPosEmp > 0
                                aDel(ACols,_nPosEmp)
                                aSize(ACols, Len(ACols) - 1)
                            EndIf
                        EndIf
                    TABZZB->(dbSkip())
                    enddo
                EndIf
            Next
            TABZZB->(dbCloseArea())
        EndIf
    EndIf
EndIf

Return Nil
