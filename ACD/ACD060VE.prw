#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"
#include "apvt100.ch"
/*/{Protheus.doc} ACD060VE
Ponto de entrada utilizado para incluir validações específicas no início do processo de validação do endereço do produto lido na etiqueta.
Não permite que seja aceito endereço diferente daquilo que estiver cadastrado na amarração "Produto x Endereço" (ACDV090) durante o processo de endereçamento via coletor de dados.
@author Rodrigo Telecio - ALLSS Soluções em Sistemas (rodrigo.telecio@allss.com.br)
@since 05/01/2022
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br
@history 05/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Inicio de desenvolvimento de codigo-fonte (não liberado para testes).
@history 12/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Realização dos primeiros testes em ambiente de homologação (funcionamento pleno para endereçamento de "NF de entrada", "produção" e "sem documento") obrigando que o item a ser endereçado possua um registro em Produto x Endereco.
/*/
user function ACD060VE()
local _lRet     := .T.
local _aArea    := GetArea()
local _aAreaCBJ := CBJ->(GetArea())
local _aAreaSB1 := SB1->(GetArea())
if _lRet
    if len(aHisEti) > 0 //aqui será armazenado o código da etiqueta lida - aHisEti[1]: código de barras / aHisEti[2]: código do produto
        dbSelectArea("CBJ")
        CBJ->(dbSetOrder(1))
        if !CBJ->(dbSeek(FwFilial("CBJ") + aHisEti[1,2] + cArmazem + cEndereco)) //CBJ_FILIAL+CBJ_CODPRO+CBJ_ARMAZ+CBJ_ENDERE
            VTAlert("O endereco " + AllTrim(cEndereco) + " informado para o produto " + AllTrim(SB1->B1_COD) + " nao encontrado em Produto x Endereco. Tente novamente.","Alerta",.T.,4000)
            _lRet := .F.
        endif
    endif
endif
RestArea(_aAreaSB1)
RestArea(_aAreaCBJ)
RestArea(_aArea)
return _lRet
