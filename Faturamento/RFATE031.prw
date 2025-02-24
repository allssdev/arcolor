#include 'parmtype.ch'
#include "totvs.ch"
/*/{Protheus.doc} RFATE031
@description Rotina utilizada para abrir a tela de alteração do cadastro do cliente dentro da tela de pedido de vendas e liberação do pedido de vendas.
@author Adriano Leonardo 04/09/2013
@since 20/05/2019
@version 1.0
@type function
@see https://allss.com.br
/*/
user function RFATE031()
	local   _aSavArea := GetArea()
	local   _aSavSA1  := SA1->(GetArea())
	local   _aSavSC5  := SC5->(GetArea())
	local   _aSavSC6  := SC6->(GetArea())
	local   _aSavSC9  := SC9->(GetArea())
	local   _cRotina  := "RFATE031"
	local   _cFunName := AllTrim(FunName())
	public 	aRotAuto  := nil

	dbSelectArea("SC5")	
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	if AllTrim(SC5->C5_TIPO)$"D/B/"
		MsgStop("Atenção! Opção não disponível para pedidos de devolução ou beneficiamento!",_cRotina+"_001")
		return
	endif
	if SA1->(MsSeek(FWFilial("SA1") + SC5->(C5_CLIENTE+C5_LOJACLI),.T.,.F.))
		SetFunName('MATA030')
			A030Altera("SA1",SA1->(Recno()),4)
		SetFunName(_cFunName)
	else
		MsgAlert("Cliente não localizado. Contate o Administrator do sistema, passando o print desta mensagem!",_cRotina+"_002")
	endif
	RestArea(_aSavSA1)
	RestArea(_aSavSC9)
	RestArea(_aSavSC6)
	RestArea(_aSavSC5)
	RestArea(_aSavArea)
return