#include "totvs.ch"

/*/{Protheus.doc} User Function MA650TOK
    LOCALIZAÇÃO : Function A650TudoOk() - Responsável por validar a Enchoice em relação as datas de início previsto e entrega prevista com prazo de entrega. 
    DESCRIÇÃO : Permite executar a validação do usuário ao confirmar a OP.
    @type  Function
    @author Fernando Bombardi
    @since 10/07/2023
    @version 1.0
    /*/
User Function MA650TOK()
Local _cPrdPai     := M->C2_PRODUTO
Local _nQtdPai     := M->C2_QUANT
Local _cArmz    := "%" + FormatIn(SUPERGETMV( "MV_XARMZPRI",.F.,"01"),"/")+ "%"
Local _cProdExc := SUPERGETMV( "MV_XPROEXS",.F.,"0106")
Local _nNrOps   := Val(IIF(FUNNAME() == 'RPCPA003',cGet5,"0") )
Private _aItSemSld := {}
Private _cPicQtd   := PesqPict("SC2","C2_QUANT")

 _lRet     := IIF(FUNNAME() == 'RPCPA003',_lRet,.T.)
If  IIF(FUNNAME() == 'RPCPA003',_nY == 1,!_lRet)
    BeginSql Alias "ESTRUTURA"
        SELECT G1_FILIAL, G1_REVFIM, G1_COD, G1_COMP, B1_DESC, G1_QUANT, 
        /*CASE
            WHEN (SELECT SUM(B8_SALDO - B8_EMPENHO) 
                  FROM %table:SB8% SB8 
                  WHERE SB8.B8_FILIAL = SG1.G1_FILIAL AND B8_LOCAL IN %Exp:_cArmz% AND SB8.B8_PRODUTO = SG1.G1_COMP AND SB8.D_E_L_E_T_ = '') <> 0 
            THEN (SELECT SUM(B8_SALDO - B8_EMPENHO) 
                  FROM %table:SB8% SB8 
                  WHERE SB8.B8_FILIAL = SG1.G1_FILIAL AND B8_LOCAL IN %Exp:_cArmz% AND SB8.B8_PRODUTO = SG1.G1_COMP AND SB8.D_E_L_E_T_ = '')
            ELSE 0
        END AS SALDO
        */
        CASE
            WHEN (SELECT SUM(B8_SALDO) -ISNULL((SELECT SUM(D4_QUANT) D4QUANT FROM SD4010 SD4 (NOLOCK)
                                                INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' 
                                                AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP AND SUBSTRING(C2_NUM,1,1) <> 'Z' 
                                                WHERE SD4.D_E_L_E_T_ = '' AND SD4.D4_COD = SB8.B8_PRODUTO  
                                                AND D4_QUANT > 0),0)
                    FROM SB8010 SB8 
                WHERE SB8.B8_FILIAL = SG1.G1_FILIAL AND B8_LOCAL IN %Exp:_cArmz% AND SB8.B8_PRODUTO = SG1.G1_COMP AND SB8.D_E_L_E_T_ = ''
				GROUP BY SB8.B8_PRODUTO) > 0 
            THEN (SELECT SUM(B8_SALDO) -ISNULL((SELECT SUM(D4_QUANT) D4QUANT FROM SD4010 SD4 (NOLOCK)
                                                INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' 
                                                AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP AND SUBSTRING(C2_NUM,1,1) <> 'Z'
                                                WHERE SD4.D_E_L_E_T_ = '' AND SD4.D4_COD = SB8.B8_PRODUTO  
                                                AND D4_QUANT > 0),0)
                    FROM SB8010 SB8 
                WHERE SB8.B8_FILIAL = SG1.G1_FILIAL AND B8_LOCAL IN %Exp:_cArmz% AND SB8.B8_PRODUTO = SG1.G1_COMP AND SB8.D_E_L_E_T_ = ''
				GROUP BY SB8.B8_PRODUTO)
            ELSE 0
        END AS SALDO
        FROM %table:SG1% SG1
            INNER JOIN %table:SB1% SB1 
            ON SB1.B1_FILIAL = SG1.G1_FILIAL 
            AND SB1.B1_COD = SG1.G1_COMP 
            AND SB1.B1_TIPO NOT IN ('PI','PA') 
            AND SB1.B1_MSBLQL <> '1'
            AND SB1.D_E_L_E_T_ = ''
        WHERE 
            SG1.G1_FILIAL = %xFilial:SG1%  
            AND SG1.G1_COD = %exp:_cPrdPai%
            AND SG1.D_E_L_E_T_ = ''
        GROUP BY G1_FILIAL, G1_REVFIM, G1_COD, G1_COMP, B1_DESC,G1_QUANT
        HAVING SG1.G1_REVFIM = (SELECT MAX(G1_REVFIM) FROM %table:SG1% WHERE G1_COD = SG1.G1_COD AND D_E_L_E_T_ = '')
    EndSql
    if ESTRUTURA->(!EOF())
        while ESTRUTURA->(!EOF())
            _nQtdNess := ESTRUTURA->G1_QUANT * _nQtdPai * _nNrOps
            if _nQtdNess > ESTRUTURA->SALDO .and. !Alltrim(ESTRUTURA->G1_COMP)$_cProdExc 
                aADD(_aItSemSld,{ESTRUTURA->G1_COMP,ESTRUTURA->B1_DESC,Alltrim(Transform(_nQtdNess,_cPicQtd)),Alltrim(Transform(ESTRUTURA->SALDO,_cPicQtd))})
                _lRet := .F.
            endif
            _nQtdNess := 0
            ESTRUTURA->(dbSkip())
        enddo
    endif
    ESTRUTURA->(dbCloseArea())

    if !_lRet
        FORMERRO(_aItSemSld)
        If MsgYesNo("Deseja continuar a abertura das ordens mesmo sem saldo? ",_cRotina+"_006")
            _lRetSld := .T.
        EndIf
    endif
EndIf
Return(_lRet)

/*/{Protheus.doc} FORMERRO
    Rotina para exibir produtos que não possuem saldo por lote.
    @type  Static Function
    @author Fernando Bombardi
    @since 12/07/2023
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example  (examples)
    @see (links_or_references)
/*/
Static Function FORMERRO(_aBrwErro)
Private oDlgError
Private oBrowse

//Monta o array de campos
aCpoCom := {"Produto", "Descrição", "Qtd. Necessário", "Saldo Lotes"}

Define MsDialog oDlgError From 000,000 To 500,750 Title "Produtos sem saldo por Lote" Pixel

//Monta a barra de botões
Define ButtonBar oBar size 20,20 3D TOP of oDlgError
Define Button Resource "CANCEL" Of oBar Action (::End()) //Prompt "Fechar" ToolTip "Fecha a Tela" 
oBar:bRClicked:={ || AllwaysTrue() }

@ 025,005 Say "Os produtos abaixo não possuem saldos ou quantidades sufientes por Lote para atender a Ordem de Produção: " Pixel Of oDlgError

oBrowse := TWBrowse():New(3.0, 0.5, 370, 190,, aCpoCom, {50,250,50,50}, oDlgError,,,,,,,,,,,, .T.)
oBrowse:SetArray(_aBrwErro)
oBrowse:bLine := {||{ _aBrwErro[oBrowse:nAt,01],;
_aBrwErro[oBrowse:nAt,02],;
_aBrwErro[oBrowse:nAt,03],;
_aBrwErro[oBrowse:nAt,04] } }
oBrowse:Refresh()

Activate MsDialog oDlgError Centered

MsgInfo("Devido a problemas relacionados com os saldos dos produtos a Ordem de Produção não foi gerada.","[MA650TOK_001] - Aviso ")

Return()
