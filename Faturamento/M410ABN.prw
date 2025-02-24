#include 'rwmake.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} M410ABN
@description Ponto de Entrada o cancelamento da opção de gravação do pedido, utilizado retirar a flag de Lock da transação.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 08/10/2019
@version 1.0
@type function
@history 22/10/2019, Anderson C. P. Coelho (ALL System Solutions), Retirado o lock customizado do registro que minimizava os riscos na liberação dos pedidos de vendas pois, conforme relatado pela consultora Lívia, o risco foi praticamente eliminado pós migração do release P12.1.17 para o P12.1.25.
@see https://allss.com.br
/*/
user function M410ABN()
//	local _cLockR   := "PEDIDO_"+SC5->C5_NUM+"_"+DTOS(Date())
	//Bloqueio realizado pelos P.E.s MA440VLD e MT410ACE e Desbloqueio realizado pelos P.E.s M440GR, M410STTS e M410ABN
	//UnLockByName(_cLockR)
//	Leave1Code(_cLockR)
return