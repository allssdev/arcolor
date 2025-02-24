#include "totvs.ch"

/*/{Protheus.doc} User Function RCPPE013
    LOCALIZAÇÃO : Function RPCPE013 - Responsável por validar os saldos antes de converter a numeração das ordens previstas para as firmes.
    DESCRIÇÃO : Permite executar a validação do usuário ao confirmar a OP.
    @type  Function
    @author Diego Rodrigues
    @since 06/12/2023
    @version 1.0
    /*/
User Function RPCPE013(_cOP,_nQtdPrd,_nQtdAnt)

Local _cRotina       := "RPCPE013"
Local _cArmz         := "%" + FormatIn(SUPERGETMV( "MV_XARMZPRI",.F.,"01"),"/")+ "%"
Local _cProdExc      := SUPERGETMV( "MV_XPROEXS",.F.,"0106")
Local _nNvEmp        := 0
Private _aItSemSld   := {}
Private _cPicQtd     := PesqPict("SC2","C2_QUANT")

//Atualiza empenho 
BeginSql Alias "EMPENHO"
    SELECT
        SD4.D4_FILIAL, SD4.D4_DATA, SD4.D4_OP, SD4.D4_COD, SB1.B1_DESC, SD4.D4_LOCAL, SD4.D4_TRT, SD4.D4_LOTECTL, SB1.B1_TIPO
    FROM %table:SD4% SD4 (NOLOCK) 
    INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = '' AND SB1.B1_COD = SD4.D4_COD AND SB1.B1_TIPO NOT IN ('PI','PA') 
    WHERE SD4.D4_OP = %exp:_cOp% 
        AND SD4.%notDel%
    ORDER BY SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL
EndSql

while EMPENHO->(!EOF())
    dbSelectArea("SD4")
    dbSetOrder(1) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
    if SD4->(MsSeek(xFilial("SD4")+ EMPENHO->D4_COD+EMPENHO->D4_OP+EMPENHO->D4_TRT+EMPENHO->D4_LOTECTL, .T.,.F.))
        _nNvEmp := IF(EMPENHO->B1_TIPO == 'EM',NOROUND((SD4->D4_QUANT/_nQtdAnt) * (_nQtdPrd),0),((SD4->D4_QUANT/_nQtdAnt) * (_nQtdPrd)))
        
        BeginSql Alias "SALDOS"
            SELECT B8_PRODUTO, SUM(B8_SALDO) B8_SALDO, SUM(B8_EMPENHO) B8_EMPENHO
            ,ISNULL((SELECT SUM(D4_QUANT) FROM SD4010 SD4 (NOLOCK)
                    INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP //AND C2_TPOP = 'F' 
                                            AND SUBSTRING(C2_NUM,1,1) <> 'Z'
                    WHERE SD4.D_E_L_E_T_ = '' AND SD4.D4_COD = SB8.B8_PRODUTO /*AND D4_LOTECTL = B8_LOTECTL*/ AND D4_QUANT > 0),0) EMPSD4
            FROM SB8010 SB8 (NOLOCK)
            WHERE SB8.D_E_L_E_T_ = '' 
                  AND B8_LOCAL IN %Exp:_cArmz% 
                  AND B8_PRODUTO = %Exp:EMPENHO->D4_COD%
                  AND (CASE WHEN B8_SALDO = 0 THEN 1 ELSE 0 END) = 0
                 /*AND (B8_SALDO - ISNULL((SELECT SUM(D4_QUANT) FROM SD4010 SD4 (NOLOCK)
                    INNER JOIN SC2010 SC2 (NOLOCK) ON SC2.D_E_L_E_T_ = '' AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP AND C2_TPOP = 'F'
                                            AND SUBSTRING(C2_NUM,1,1) <> 'Z'
                    WHERE SD4.D_E_L_E_T_ = '' AND SD4.D4_COD = SB8.B8_PRODUTO AND D4_LOTECTL = B8_LOTECTL AND D4_QUANT > 0),0)) > 0 */
            GROUP BY B8_FILIAL,B8_PRODUTO,B8_LOCAL
            ORDER BY B8_FILIAL,B8_PRODUTO,B8_LOCAL 
        EndSql
    EndIF

     //While SALDOS->(!EOF()) .and. ((SD4->D4_QUANT * IIf(_nOP == 1, Val(_cCboQtd), (Val(_cCboQtd)-_nOP+1))) > (SALDOS->B8_SALDO - SALDOS->EMPSD4)) .AND. !Alltrim(SALDOS->B8_PRODUTO)$_cProdExc 
    While SALDOS->(!EOF()) .and. ((_nNvEmp * IIf(_nOP == 1, Val(_cCboQtd), (Val(_cCboQtd)-_nOP+1))) > (SALDOS->B8_SALDO - SALDOS->EMPSD4)) .AND. !Alltrim(SALDOS->B8_PRODUTO)$_cProdExc 
            aADD(_aItSemSld,{EMPENHO->D4_COD,EMPENHO->B1_DESC,Alltrim(Transform((SD4->D4_QUANT * Val(_cCboQtd)),_cPicQtd)),Alltrim(Transform((SALDOS->B8_SALDO - SALDOS->EMPSD4),_cPicQtd))})
            _lRetSld := .F.
            SALDOS->(dbSkip())
     EndDo
     SALDOS->(dbCloseArea())    
   EMPENHO->(dbSkip())
enddo
EMPENHO->(dbCloseArea())     

if !_lRetSld
    FORMERRO(_aItSemSld)
    If MsgYesNo("Deseja continuar a abertura das ordens mesmo sem saldo? ",_cRotina+"_006")
        _lRetSld := .T.
    EndIf
endif


Return(_lRetSld)

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

Return()
