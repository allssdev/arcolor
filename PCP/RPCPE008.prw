#include "rwmake.ch"
#include "protheus.ch"
/*/{Protheus.doc} RPCPE008
Execblock chamado por meio de gatilho na condição do campo D4_QTDRECU/001 responsável por atualizar o campo D4_QTDANTE
@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 14/09/2022
@version P12.1.33
@type Function
@obs Sem observações
@see https://allss.com.br
@history 14/09/2022, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Versao inicial.
/*/
user function RPCPE008()
local nRetorno      := 0
local nPosQtdAnt    := 0
//Empenho Simples
if AllTrim(FunName()) $ "MATA380"
    nRetorno        := M->D4_QTDANTE
//Empenho Múltiplo
elseif AllTrim(FunName()) $ "MATA381"
    nPosQtdAnt      := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_QTDANTE"})
    nRetorno        := aCols[n,nPosQtdAnt]
endif
return nRetorno
