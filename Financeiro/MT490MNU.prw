#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TBICONN.CH'
/*/{Protheus.doc} MT490MNU
@description Ponto de Entrada para manupular as opções aRotina da tela de manutenção da comissão. Foi inserido o botão de Atualiza pagamento da comissão específico do cliente.
@author Anderson C. P. Coelho (ALL System Solutions)
@since 17/04/2017
@version 1.0
@type function
@see https://allss.com.br
/*/
user function MT490MNU()
	If ExistBlock("RFINE033")
		AADD(aRotina, { "&Gera PC"       ,"U_RFINE033()",0,2,0,NIL})
		AADD(aRotina, { "&Imprime PC"    ,"U_RCOMR003()",0,2,0,NIL})
	EndIf
return