#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} GP670CPO
P.E. deve ser utilizado para adicionar, na integração do titulo, campos criados pelo usuario. 
Ele somente será executado quando estiver sendo efetuada a integraçcao do titulo, se isso não ocorrer 
sera apresentado log com os titulos não integrado.
@author Adriano Leonardo
@since 03/06/2014
@version P11
@type Function
@obs Sem observações
@see https://allss.com.br
@history 03/06/2014, Adriano Leonardo, Versão inicial.
@history 13/10/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Incremento campo E2_HIST.
/*/
user function GP670ARR()
local _aSavArea := GetArea()
local _aSavSE2 	:= SE2->(GetArea())
local _aCposUsr	:= {}
local _cHistSE2 := SuperGetMv("MV_XHSTSE2",.F.,"TITULO INTEG. AUTOMATICAMENTE ENTRE SIGAGPE X SIGAFIN")
dbSelectArea("SE2")
if FieldPos("E2_MAT") <> 0
	AAdd(_aCposUsr,{'E2_MAT' , RC1->RC1_MAT	,Nil})
endif
if FieldPos("E2_HIST")
	AADD(_aCposUsr,{'E2_HIST',_cHistSE2		,Nil})
endif
RestArea(_aSavSE2)
RestArea(_aSavArea)
return(_aCposUsr)
