#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} TK271ROTM
@description Rotina criada para permitir busca avançada na tela do atendimento do Call Center.
@obs Há uma limitação no padrão onde só é permitido adicionar dois botões customizados, foi feito um chamado na Totvs solicitando melhoria nesse ponto de entrada, mas não houve retorno, porém foi localizada uma abertura no ponto TK271FIL, onde a variável aRotina está disponível e pode ser manipulada, logo, há botões sendo adicionados por esses dois pontos de entrada.
@author Adriano Leonardo
@since 17/03/2014
@version 1.0
@return _aRotina, array, Funções adicionais ao browse.
@type function
@see https://allss.com.br
/*/
user function TK271ROTM()
	local _aSavArea := GetArea()
	local _cRotina  := "TK271ROTM"
	local _aRotina  := {}	//IIF(Type("aRotina")=="A",aClone(aRotina),{})
	//Adiciona rotina customizada aos botoes do browse
	if ExistBlock("RTMKE028")
		//Seta atalho para tecla F4 para alterar informações específicas no atendimento Call Center
		//SetKey(VK_F4,{|| })
		//SetKey(VK_F4,{|| U_RTMKE028()})
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F8,{|| MsgAlert( "Tecla [ F8 ] foi alterada para [ Ctrl + F8 ]" , "Protheus11" )})
		SetKey( K_CTRL_F8, { || })
		SetKey( K_CTRL_F8, { || U_RTMKE028()})
	endif
	if ExistBlock("RTMKE025")
		aAdd( _aRotina, { 'Confer. Pedido','U_RTMKE025', 0 , 2 })
		//SetKey(VK_F6,{|| })
		//SetKey(VK_F6,{|| U_RTMKE025() })
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F6,{|| MsgAlert( "Tecla [ F6 ] foi alterada para [ Ctrl + F6 ]" , "Protheus11" )})
		SetKey( K_CTRL_F6, { || })
		SetKey( K_CTRL_F6, { || U_RTMKE025()})
	endif
	if ExistBlock("RFATC011")
		aAdd( _aRotina, { 'Consulta Pedidos','U_RFATC011', 0 , 7 })
		//SetKey(VK_F7,{|| })
		//SetKey(VK_F7,{|| U_RFATC011() })
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F7,{|| MsgAlert( "Tecla [ F7 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
		SetKey( K_CTRL_F7, { || })
		SetKey( K_CTRL_F7, { || U_RFATC011()})
	endif
	if ExistBlock("RFATL001")
	//	AAdd(_aRotina,{"Logs do Pedido","U_RFATL001(SUA->UA_NUMSC5,POSICIONE('SUA',8,xFilial('SUA')+SUA->UA_NUMSC5,'UA_NUM'),'','"+_cRotina+"',)" ,0,6,0 ,NIL})
		SetKey( K_CTRL_F9, { || })
		SetKey( K_CTRL_F9, { || U_RFATL001(SUA->UA_NUMSC5,SUA->UA_NUM,'',_cRotina,)})
	endif
	RestArea(_aSavArea)
return _aRotina