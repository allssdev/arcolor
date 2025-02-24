#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271FIL  ºAutor  ³Júlio Soares        º Data ³  19/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para realizar filtragem específica de      º±±
±±º          ³clientes conforme usuário logado                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ºRevisão   ³ Data 14/02/2013                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function TK271FIL()
	Local _aSavArea	:= GetArea()
	Local _aVend    := {}
	Local _cRotina  := "TK271FIL"
	Local _cFiltro  := ""
	Local _x        := 0
	Local _nNivel   := 1
	Local _aRotAdic := {}
	//Local _aUsrAut	:= SuperGetMv("MV_TMKAUT" ,,"" ) // Parametro que define os usuários com acesso a todos os atendimentos - Adriano Leonardo em 19/08/2013
	Private _cRotina := 'TK271FIL'
	/*
	//Início - Trecho adicionado por Adriano Leonardo em 26/05/2014 para contornar limitação na quantidade de rotinas no PE TK271ROTM
	If ValType(aRotina) == "A" //Certifico que o aRotina (variável padrão) está disponível nesse momento
		If ExistBlock("RTMKE022")
			aAdd( _aRotAdic, { 'Busca Avançada','U_RTMKE022', 0 , 1 })
			//Seta atalho para tecla F5 para chamar a tela de busca avançada
			//SetKey(VK_F5,{|| })
			//SetKey(VK_F5,{|| U_RTMKE022() })
		    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
			//SetKey( VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
			SetKey( K_CTRL_F5, { || })
			SetKey( K_CTRL_F5, { || U_RTMKE022()})
		EndIf
		If ValType(_aRotAdic) == "A" .And. Len(_aRotAdic)>0
			AEval(_aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf
	//Final  - Trecho adicionado por Adriano Leonardo em 26/05/2014 para contornar limitação na quantidade de rotinas no PE TK271ROTM
	*/
	If ExistBlock("RTMKE028")
		//Seta atalho para tecla F4 para alterar informações específicas no atendimento Call Center
		//SetKey(VK_F4,{|| })
		//SetKey(VK_F4,{|| U_RTMKE028()})
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F8,{|| MsgAlert( "Tecla [ F8 ] foi alterada para [ Ctrl + F8 ]" , "Protheus11" )})
		SetKey( K_CTRL_F8, { || })
		SetKey( K_CTRL_F8, { || U_RTMKE028()})
	EndIf
	If ExistBlock("RTMKE022")
		//Seta atalho para tecla F5 para chamar a tela de busca avançada
		//SetKey(VK_F5,{|| })
		//SetKey(VK_F5,{|| U_RTMKE022() })
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
		SetKey( K_CTRL_F5, { || })
		SetKey( K_CTRL_F5, { || U_RTMKE022()})
	EndIf
	If ExistBlock("RTMKE025")
		//Seta atalho para tecla F6 para chamar a conferência dos atendimentos
		//SetKey(VK_F6,{|| })
		//SetKey(VK_F6,{|| U_RTMKE025() })
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F6,{|| MsgAlert( "Tecla [ F6 ] foi alterada para [ Ctrl + F6 ]" , "Protheus11" )})
		SetKey( K_CTRL_F6, { || })
		SetKey( K_CTRL_F6, { || U_RTMKE025()})
	EndIf
	If ExistBlock("RFATC011")
		//Seta atalho para tecla F7 para chamar consulta dos pedidos por cliente
		//SetKey(VK_F7,{|| })
		//SetKey(VK_F7,{|| U_RFATC011() })
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F7,{|| MsgAlert( "Tecla [ F7 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
		SetKey( K_CTRL_F7, { || })
		SetKey( K_CTRL_F7, { || U_RFATC011()})
	EndIf
	If ExistBlock("RFATL001")
		SetKey( K_CTRL_9, { || })
		SetKey( K_CTRL_9, { || U_RFATL001(SUA->UA_NUMSC5,POSICIONE('SUA',1,xFilial('SUA')+SUA->UA_NUM,'UA_NUM'),'',_cRotina,)})
		//AAdd(aRotina,{"Logs do Pedido","U_RFATL001(SUA->UA_NUMSC5,POSICIONE('SUA',1,xFilial('SUA')+SUA->UA_NUM,'UA_NUM'),'','"+_cRotina+"',)" ,0,6,0 ,NIL})
	EndIf
	/*
	//Trecho adicionado por Adriano Leonardo em 19/08/2013
	If !Empty(_aUsrAut)
		If __cUserId $ _aUsrAut
			Return(_cFiltro)
		EndIf
	EndIf
	//Final do trecho adicionado por Adriano Leonardo em 19/08/2013
	*/
	/*
	dbSelectArea("SA3")
	_aSavSA3 := SA3->(GetArea())
	SA3->(dbSetOrder(7)) //Ordem A3_FILIAL + A3_CODUSR
	If SA3->(MsSeek(xFilial("SA3") + RetCodUsr(),.T.,.F.))		  //Se a pesquisa encontrar A3_CODUSR + Código do usuário logado
		AADD(_aVend,{SA3->A3_COD,_nNivel})
	EndIf
	While _x < Len(_aVend)
		_x++
		dbSelectArea("SA3")
		SA3->(dbSetOrder(4)SA3->( //Ordem A3_FILIAL + A3_GEREN
		If SA3->(MsSeek(xFilial("SA3") + _aVend[_x][01],.T.,.F.)) //Se a pesquisa encontrar A3_CODUSR + Código do usuário logado
			_nNivel++
			While !SA3->(EOF()) .AND. SA3->A3_FILIAL == xFilial("SA3") .AND. SA3->A3_GEREN == _aVend[_x][01]
				If aScan(_aVend,{|x|AllTrim(x[01])==AllTrim(SA3->A3_COD)}) == 0
					AADD(_aVend,{SA3->A3_COD,_nNivel})
				EndIf
				dbSelectArea("SA3")
				SA3->(dbSetOrder(4)) //Ordem A3_FILIAL + A3_GEREN
				SA3->(dbSkip())
			EndDo
		EndIf
	EndDo
	For _x := 1 To Len(_aVend)
		If _x == 1
			_cFiltro := 'Alltrim(SUA->UA_VEND)$ "/' + Alltrim(_aVend[_x][01])
		Else
			_cFiltro += '/' + Alltrim(_aVend[_x][01])
		EndIf
	Next
	If !Empty(_cFiltro)
		_cFiltro += '/"'
	EndIf
	cFiltro := _cFiltro
	Return(cFiltro)
	*/
return