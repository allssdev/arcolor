#include "totvs.ch"
#include "protheus.ch"
/*/{Protheus.doc} FIMPFCH
Ponto de entrada para mudar/alterar a chamada de impressão da ficha de registro
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 16/02/2022
@version P12
@type Function
@obs Sem observações
@see https://allss.com.br
@history 16/02/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Versão inicial do ponto de entrada, para impressão da ficha de registro customizada desenvolvida com base no padrão do ERP Protheus.
/*/
user function FIMPFCH()
if existblock("RGPER460")
    cImpFch := "U_RGPER460(.T.)"
endif
return
