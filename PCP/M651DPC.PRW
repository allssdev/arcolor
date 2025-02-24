#INCLUDE "PROTHEUS.CH"
  
/*/{Protheus.doc} User Function M651DPC
    LOCALIZAÇÃO : Function P.E permite criar validações no duplo click da MarkBrow na tela de Firmar OP [MATA651]
    DESCRIÇÃO : Valida os usuários de acordo com a tabela ZZB para seleção da op a firmar.
    @type  Function
    @author Diego Rodrigues
    @since 01/07/2024
    @version 1.0
/*/
  
User Function M651DPC()
  
Local lRet := .T.
Local _cUsrID := Alltrim(__cUserId)
Local _cUsrProd := SuperGetMV("MV_XUSRPROD",,"000000")

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
            MsgStop("Usuario sem permissão para Firmar OP!  Produto não pertence a este usuário.", "Atenção")      
            lRet   := .F.
    Endif
    OPERCOMP->(dbCloseArea())
EndIf
Return(lRet)
