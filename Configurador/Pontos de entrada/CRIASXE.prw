#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} CRIASXE
Ponto de entrada para retornar o próximo número que deve ser utilizado na inicialização da numeração.
Este ponto de entrada é recomendado para casos em que deseja-se alterar a regra padrão de descoberta do próximo número.
A execução deste ponto de entrada, ocorre em casos de perda das tabelas SXE/SXF ( versões legado ) e de reinicialização do License Server.
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 11/03/2022
@version P12
@type Function
@obs Sem observações
@see https://allss.com.br
@history 11/03/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Desenvolvimento e disponibilização da primeira versão para utilização/testes.
/*/
user function CRIASXE()    
local aArea     := GetArea()      
local cAlias_   := paramixb[1]
local cCpoSx8   := paramixb[2]
local cAlias_Sx8:= paramixb[3]
local nOrdSX8   := paramixb[4]
local aTabelas  := {}         //Tabelas que irão permitir a execução do P.E
local cTabela   := ""         //Alias corrente que irá permitir a execução do P.E.      
local nCount    := 0                                                                    
local cQuery    := ""         //Na query eu vejo o ultimo número que tá no banco.
local cProxNum  := Nil        //Retorno da função.
ConOut("[u_CRIASXE] 01 - Entrou no ponto de entrada CRIASXE / Se nao tiver log entre mensagem 01 e 02, nao foi feito nada aqui!")                  
//Definindo as tabelas que irão executar o P.E / Caso precise executar em mais alguma só adicionar no array
aTabelas := {"SA1","SA2","SC7"}
//Percorro array e vejo se tabela corrente deve executar o P.E              
for nCount := 1 to len(aTabelas)
    if(cAlias_ $ aTabelas[nCount])
        cTabela := aTabelas[nCount]                                                              
        ConOut("[u_CRIASXE] ->  TRATATIVA | Sera ajustado via P.E numeracao automatica: " + cAlias_ + " - " + cCpoSx8 + " - " + cAlias_Sx8 + " - " + cValToChar(nOrdSX8))
        exit
    endif    
next nCount              
//Se a tabela corrente estiver na coleção de tabelas E as variáveis dos parâmetros não estiverem com problema.
if(!empty(cTabela) .AND.  !(empty(cAlias_) .AND. empty(cCpoSx8)))        
    ConOut("[u_CRIASXE] ->  Antes de criar consulta para pegar ultimo numero do campo " + cCpoSx8)
    cQuery := " SELECT MAX(" + cCpoSx8 + ") AS ULTIMO_NUM FROM " + RetSqlName(cAlias_) + " AS TMP (NOLOCK) "
    if cTabela $ "SA1"
        cQuery += " WHERE TMP.A1_COD < '999999' AND TMP.D_E_L_E_T_ = '' "
    elseif cTabela $ "SA2"
        cQuery += " WHERE TMP.A2_COD < '999999' AND LEN(TMP.A2_COD) = 6 AND TMP.A2_COD <> '203990' AND TMP.D_E_L_E_T_ = '' "
    elseif cTabela $ "SC7"
        cQuery += " WHERE TMP.C7_NUM < '499999' AND TMP.D_E_L_E_T_ = '' "
    else
        cQuery += " WHERE TMP.D_E_L_E_T_ = '' "
    endif
    cQuery := changeQuery(cQuery)
    TcQuery cQuery New Alias 'TMP_QRY'
    ConOut("[u_CRIASXE] ->  Depois de criar consulta para pegar ultimo número do campo " + cCpoSx8)
    //Caso a query retorne ultimo número
    if(!TMP_QRY->(EOF()))
        cProxNum := Soma1(TMP_QRY->ULTIMO_NUM) //pego ultimo código e somo 1
        ConOut("[u_CRIASXE] ->  Proximo numero do campo  " + cCpoSx8 + " sera " + cProxNum)             
    else
        ConOut("[u_CRIASXE] ->  A query veio vazia ou ocorreu algum problema, nao conseguiu incrementar o proximo numero do campo"+cCpoSx8 )                               
    endif
    TMP_QRY->(dbCloseArea())
endif
ConOut("[u_CRIASXE] 02 - Encerrou taferas no ponto de entrada CRIASXE")      
RestArea(aArea)
return cProxNum
