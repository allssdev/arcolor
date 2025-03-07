#INCLUDE "PROTHEUS.CH"
  
/*/{Protheus.doc} User Function M651DPC
    LOCALIZA��O : Function P.E permite criar valida��es no duplo click da MarkBrow na tela de Firmar OP [MATA651]
    DESCRI��O : Valida os usu�rios de acordo com a tabela ZZB para sele��o da op a firmar.
    @type  Function
    @author Diego Rodrigues
    @since 01/07/2024
    @version 1.0
/*/
  
User Function M651DPC()
  
Local lRet := .T.
Local _cUsrID := Alltrim(__cUserId)
Local _cUsrProd := SuperGetMV("MV_XUSRPROD",,"000000")

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+SC2->C2_PRODUTO,.T.,.F.))
    If !Empty(SB1->B1_OPERPAD)
        If !__cUserId$_cUsrProd
        BeginSql Alias "OPERCOMP"
                SELECT
                    ZZB_CODUSR, ZZB_USRNOM, ZZB_OPERAC, ZZB_PRODUT,ZZB_CCUSTO, B1_OPERPAD
                FROM ZZB010 ZZB (NOLOCK) 
                INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND B1_COD = ZZB_PRODUT
                WHERE ZZB.D_E_L_E_T_ = ''
                AND ZZB.ZZB_ATIVO = '1'
                AND ZZB_CODUSR = %Exp:_cUsrID%
                AND ZZB_PRODUT = %Exp:SC2->C2_PRODUTO%
            EndSql
        
            if OPERCOMP->(EOF()) 
                    MsgStop("Usuario sem permiss�o para Firmar OP!  Produto n�o pertence a este usu�rio.", "Aten��o")      
                    lRet   := .F.
            Endif
            OPERCOMP->(dbCloseArea())
        EndIf
    EndIf
EndIf
Return(lRet)
