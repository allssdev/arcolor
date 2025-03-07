/*/{Protheus.doc} CBINV02
O ponto de entrada 'CBINV02' Permite validar o localiza��o f�sica definida pelo operador no invent�rio.
Neste ponto de entrada estamos validando o endere�o no momento do invent�rio.
@author Diego Rodrigues Pereira
@since 21/09/2023
@version 1.0
@type function
@see https://allss.com.br
/*/


User Function CBINV02

Local cArmazem  := PARAMIXB[1]
Local cEndereco := PARAMIXB[2]
local _lRet     := .T.
local _aArea    := GetArea()
local _aAreaCBJ := CBJ->(GetArea())
local _aAreaSB1 := SB1->(GetArea())
if _lRet .and. !Empty(aProdEnd)
    if len(aProdEnd[1][1]) > 0 //aqui ser� armazenado o c�digo da etiqueta lida - aHisEti[1]: c�digo de barras / aHisEti[2]: c�digo do produto
        dbSelectArea("CBJ")
        CBJ->(dbSetOrder(1))
        if !CBJ->(dbSeek(FwFilial("CBJ") + aProdEnd[1][1] + cArmazem + cEndereco)) //CBJ_FILIAL+CBJ_CODPRO+CBJ_ARMAZ+CBJ_ENDERE
            //VTAlert("O endereco " + AllTrim(cEndereco) + " informado para o produto " + aProdEnd[1][1] + " nao encontrado em Produto x Endereco. Tente novamente.","Alerta",.T.,4000)
            VTAlert("O endereco incorreto para o produto ","Alerta",.T.,4000)
            _lRet := .F.
        endif
    endif
endif
RestArea(_aAreaSB1)
RestArea(_aAreaCBJ)
RestArea(_aArea)


Return  _lRet
