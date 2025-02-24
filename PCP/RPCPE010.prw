#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} RPCPE010
Execblock chamado por meio de gatilho na condição do campo D4_QTDRECU/003 responsável por atualizar o campo D4_QUANT
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 14/09/2022
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br
@history 14/09/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Versao inicial.
/*/
user function RPCPE010()
local nRetorno      := 0
local nPosEmpAnt    := 0
//Empenho Simples
if AllTrim(FunName()) $ "MATA380"
    nRetorno        := M->D4_EMPANTE
//Empenho Múltiplo
elseif AllTrim(FunName()) $ "MATA381"
    nPosEmpAnt      := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_EMPANTE"})
    nRetorno        := aCols[n,nPosEmpAnt]
endif
return nRetorno
