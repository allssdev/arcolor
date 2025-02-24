#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} GP670CPO
P.E. para integração/gravação de campos de usuário na tabela 'SE2', contas a pagar. 
Verificar também o ponto de entrada GP670ARR, para o envio dos campos criados pelo usuáario.
Esse ponto de entrada somente será executado quando estiver sendo efetuada a integraçcao do titulo,
se isso não ocorrer sera apresentado log com os titulos não integrado.
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 13/10/2021
@version P12
@type Function
@obs Sem observações
@see https://allss.com.br
@history 13/10/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Versão inicial.
/*/
user function GP670CPO()
local _aAreaSE2 := SE2->(GetArea())
local _aAreaRC1 := RC1->(GetArea())
if FieldPos("E2_HIST") <> 0
    SE2->E2_HIST := SuperGetMv("MV_XHSTSE2",.F.,"TITULO INTEG. AUTOMATICAMENTE ENTRE SIGAGPE X SIGAFIN")
endif
RestArea(_aAreaRC1)
RestArea(_aAreaSE2)
return
