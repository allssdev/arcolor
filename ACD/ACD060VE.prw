#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"
#include "apvt100.ch"
/*/{Protheus.doc} ACD060VE
Ponto de entrada utilizado para incluir valida��es espec�ficas no in�cio do processo de valida��o do endere�o do produto lido na etiqueta.
N�o permite que seja aceito endere�o diferente daquilo que estiver cadastrado na amarra��o "Produto x Endere�o" (ACDV090) durante o processo de endere�amento via coletor de dados.
@author Rodrigo Telecio - ALLSS Solu��es em Sistemas (rodrigo.telecio@allss.com.br)
@since 05/01/2022
@version P12.1.33
@type Function
@obs Sem observa��es
@see https://allss.com.br
@history 05/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Inicio de desenvolvimento de codigo-fonte (n�o liberado para testes).
@history 12/01/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Realiza��o dos primeiros testes em ambiente de homologa��o (funcionamento pleno para endere�amento de "NF de entrada", "produ��o" e "sem documento") obrigando que o item a ser endere�ado possua um registro em Produto x Endereco.
/*/
user function ACD060VE()
local _lRet     := .T.
local _aArea    := GetArea()
local _aAreaCBJ := CBJ->(GetArea())
local _aAreaSB1 := SB1->(GetArea())
if _lRet
    if len(aHisEti) > 0 //aqui ser� armazenado o c�digo da etiqueta lida - aHisEti[1]: c�digo de barras / aHisEti[2]: c�digo do produto
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
