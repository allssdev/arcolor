#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#define ENT (CHR(13)+CHR(10))
/*/{Protheus.doc} RPCPA006
Rotina para alteração da numeração das ordens de produção previstas geradas pelo MRP chamada através do ponto de entrada PA145GER
@author Diego Rodrigues (diego.rodrigues@allss.com.br)
@since 19/01/2024
@version P12
@type Function
@obs Sem observações
@see https://allss.com.br
/*/
user function RPCPA006()
local _lExeFun  := .T.
if _lExeFun
   RPCPA06P()
endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³ RPCPA04P  º Autor ³ Fernando Bombardi º Data ³  08/10/2021 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Processamento principal do rotina						  º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Programa principal	                                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function RPCPA06P()
local _cQry 	    := ""
local _lRet         := .T.
local _cAlDelSD4    := GetNextAlias()
local _cAliasSC2    := GetNextAlias()
local _cDadosAux    := "GETSC2"
local _cAliasSD4    := GetNextAlias()
//
//SD4 - Empenhos (DELEÇÃO)
//O padrão do ERP, após a alteração da numeração das OP's, quando executa-se novamente um novo calculo do MRP Memória,
//deleta a Ordem de Produção (SC2) mas não consegue deletar os Empenhos (SD4), mesmo com todos estes dados sincronizados
//nas tabelas do MRP Memória. Sendo assim, então, deletamos implicitamente todo e qualquer empenho cujo número da OP
//inicia-se com "Z"
//
_cQry 	  := "SELECT                                                                                    "
_cQry 	  += "      SD4.D4_FILIAL, SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL, SD4.D4_DATA, SD4.R_E_C_N_O_     "
_cQry 	  += "FROM                                                                                      "
_cQry 	  +=        RetSqlName("SD4") + " SD4 (NOLOCK)                                                  "
_cQry 	  += "WHERE                                                                                     "
_cQry 	  += "      SD4.D4_FILIAL = '" + FWFilial("SD4") + "'                                           "
_cQry 	  += "      AND SUBSTRING(SD4.D4_OP,1,1) = 'Z'                                                  "
_cQry 	  += "      AND SD4.D_E_L_E_T_ = ''                                                             "
_cQry 	  += "ORDER BY                                                                                  "
_cQry 	  += "      SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL                                                 "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlDelSD4,.F.,.T.)
dbSelectArea(_cAlDelSD4)
(_cAlDelSD4)->(dbGoTop())
while (_cAlDelSD4)->(!EOF())
    dbSelectArea("SD4")
    dbSetOrder(2)
    if dbSeek(FWFilial("SD4") + (_cAlDelSD4)->(D4_OP + D4_COD + D4_LOCAL))
        RecLock("SD4",.F.)
        dbDelete()
        SD4->(MsUnlock())
    endif
    dbSelectArea(_cAlDelSD4)
    (_cAlDelSD4)->(dbSkip())
enddo
(_cAlDelSD4)->(dbCloseArea())
//
//SC2/SD4 - Ordens de Produção/Empenho (ATUALIZAÇÃO)
//Levanta os registros da(s) OP(s) prevista(s) que deve(m) ser atualizado(s)
//
if Select(_cAliasSC2) > 0
    (_cAliasSC2)->(dbCloseArea())
endif
BeginSql Alias _cAliasSC2
    SELECT
        C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN
    FROM 
        %Table:SC2% SC2 (NOLOCK)
    WHERE 
        SC2.C2_FILIAL = %xFilial:SC2%  
        AND SC2.C2_TPOP = 'P'
        AND SUBSTRING(SC2.C2_NUM,1,1) <> 'Z' 
        AND SC2.C2_XLOTE = ''
        AND SC2.%notDel%
    ORDER BY
        C2_NUM, C2_ITEM, C2_SEQUEN
EndSql
if (_cAliasSC2)->(EOF())
	_lRet := .F.
	(_cAliasSC2)->(dbCloseArea())
	return _lRet
endif
(_cAliasSC2)->(dbGoTop())
//Levanta numeração para utilização na ordem de produção prevista
_cQry 	  := "SELECT                                                                                    "
_cQry 	  += "      ISNULL(MAX(C2_NUM),'Z00001') C2_NUM                                                 "
_cQry 	  += "FROM                                                                                      "
_cQry 	  +=        RetSqlName("SC2") + " SC2  (NOLOCK)                                                 "
_cQry 	  += "WHERE                                                                                     "
_cQry 	  += "      SC2.C2_FILIAL  = '" + FWFilial("SC2") + "'                                          "
_cQry 	  += "      AND SC2.C2_EMISSAO > '20210601'                                                     "
_cQry 	  += "      AND SUBSTRING(SC2.C2_NUM,1,1) = 'Z'                                                 "
//_cQry 	  += "      AND D_E_L_E_T_ = ''                                                                 "
if Select(_cDadosAux) > 0
	(_cDadosAux)->(dbCloseArea())
endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cDadosAux,.F.,.T.)
dbSelectArea(_cDadosAux)
if AllTrim((_cDadosAux)->C2_NUM) <> 'Z00001'
    _cRet := Soma1((_cDadosAux)->C2_NUM)
else
    _cRet := 'Z00001'
endif
(_cDadosAux)->(dbCloseArea())
Begin Transaction
while (_cAliasSC2)->(!EOF())  
    _cNumAnt := (_cAliasSC2)->C2_NUM
    while (_cAliasSC2)->(!EOF()) .AND. AllTrim(_cNumAnt) == AllTrim((_cAliasSC2)->C2_NUM)
        dbSelectArea("SC2")
        SC2->(dbSetOrder(1))
        if SC2->(dbSeek(FWFilial("SC2") + (_cAliasSC2)->(C2_NUM + C2_ITEM + C2_SEQUEN)))
            //Atualiza SC2
            Reclock("SC2",.F.)
            SC2->C2_XOP     := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
            SC2->C2_OP      := AllTrim(_cRet) + SubStr(SC2->C2_OP,7,10)
            SC2->C2_NUM     := _cRet
            SC2->(MsUnlock())
            if Select(_cAliasSD4) > 0
                (_cAliasSD4)->(dbCloseArea())
            endif
            //Atualiza SD4
            BeginSql Alias _cAliasSD4
                SELECT
                    SD4.D4_FILIAL, SD4.D4_OP, SD4.D4_COD, SD4.D4_LOCAL
                FROM
                    %table:SD4% SD4 (NOLOCK)
                WHERE 
                    SD4.D4_FILIAL = %xFilial:SD4%
                    AND SD4.D4_OP = %exp:_cNumAnt + SC2->C2_ITEM + SC2->C2_SEQUEN%
                    AND SD4.%notDel%
                ORDER BY
                    D4_OP, D4_COD, D4_LOCAL
            EndSql
            while (_cAliasSD4)->(!EOF())
                dbSelectArea("SD4")
                dbSetOrder(2)
                if dbSeek(xFilial("SD4") + (_cAliasSD4)->D4_OP)
                    Reclock("SD4",.F.)
                    SD4->D4_XOP := SD4->D4_OP
                    SD4->D4_OP  := AllTrim(_cRet) + SC2->C2_ITEM + SC2->C2_SEQUEN
                    if !empty(SD4->D4_OPORIG)
                        SD4->D4_OPORIG := AllTrim(_cRet) + SubStr(SD4->D4_OPORIG,7,10)
                    endif
                    SD4->(MsUnlock())
                endif
                dbSelectArea(_cAliasSD4)
                (_cAliasSD4)->(dbSkip())
            enddo
            (_cAliasSD4)->(dbCloseArea())
        endif
        dbSelectArea(_cAliasSC2)     
        (_cAliasSC2)->(dbSkip())
    enddo
    _cRet := Soma1(_cRet)
enddo
(_cAliasSC2)->(dbCloseArea())
End Transaction
return _lRet
