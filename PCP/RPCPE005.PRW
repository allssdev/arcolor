#include "totvs.ch"
#define ENTER (CHR(13)+CHR(10))
/*/{Protheus.doc} RPCPE005
Rotina responsável por fazer Validação para não ter o apontamento maior que a ordem de produação pelos operadores
validação incluida no campo D3_QUANT validação de usuário
@author Diego Rodrigues Pereira (diego.rodrigues@allss.com.br)
@since 18/02/2021
@version P12
@type Function
@obs Sem observações
@see https://allss.com.br
@history 12/11/2021, Rodrigo Telecio (rodrigo.telecio@allss.com.br), Ajustes conforme solicitação do cliente.
@history 11/05/2023, Diego Rodrigues (diego.rodrigues@allss.com.br), Ajuste para posicionamento da ordem de produção no momento da validação das quantidades
/*/
user function RPCPE005()
local   _aSavSD3  	:= SD3->(GetArea())
local   _aSavSC2  	:= SC2->(GetArea())
local   _lRet      	:= .T.
Local   _aUsrPcp	:= SuperGetMv("MV_XUSRPCP" ,,"000000" )
/*
if Upper(AllTrim(__cUserId)) $ _aUsrPcp
	//MSGSTOP('Pressione Enter para confirmar a quantidade','ATENÇÃO')
endif
*/
If funname()=="MATA250"
	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))
	If SC2->(dbSeek(xFilial("SC2")+substr(M->D3_OP,1,11)))
		if M->D3_QUANT > (SC2->C2_QUANT-(SC2->C2_QUJE+SC2->C2_PERDA)) .AND. Upper(AllTrim(__cUserId)) $ _aUsrPcp
			MSGSTOP('O apontamento está com quantidade maior que a quantidade da OP. Favor encaminhar esse apontamento ao Departamento do PCP','ATENÇÃO')
			_lRet      		:= .F.
		endif
	EndIf
EndIf
RestArea(_aSavSC2)
RestArea(_aSavSD3)
return _lRet
