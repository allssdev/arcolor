#include 'parmtype.ch'
#include "totvs.ch"
/*/{Protheus.doc} MA440MNU
@description Ponto de entrada para adicionar botões no browse das liberações dos pedidos de vendas.
@author Anderson C. P. Coelho (ALLSS Soluções em Sistemas)
@since 30/09/2020
@version 1.0
@type function
@see https://allss.com.br
/*/
user function MA440MNU()
	local   _cRotina := "MA440MNU"
	if !empty(FunName())
		//Ativo a rotina "RFATL001" de log dos pedidos de vendas.
		if ExistBlock("RFATL001")
			SetKey( K_CTRL_F9, { || })
			SetKey( K_CTRL_F9, { || U_RFATL001(SC5->C5_NUM,POSICIONE('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_NUM'),'',"MA440MNU",)})
			AAdd(aRotina,{"Logs do Pedido","U_RFATL001(SC5->C5_NUM,POSICIONE('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_NUM'),'','"+_cRotina+"',)" ,0,6,0 ,NIL})
		endif
		//Ativo a rotina "RFATE031" de alteração de clientes.
		if ExistBlock("RFATE031")
			AAdd(aRotina,{"Altera Cliente","U_RFATE031()" ,0,6,0 ,NIL})
		endif
	endif
return