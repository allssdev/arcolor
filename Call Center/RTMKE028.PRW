#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMKE028  �Autor  �J�lio Soares        � Data �  19/12/12   ���
���Programa  �          �Autor  �J�lio Soares        � Data �  06/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �ExecBlock alterar informa��es espec�ficas no atendimento,   ���
���          �conforme usu�rio logado                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RTMKE028()

Local _aSavArea := GetArea()
Local _cRotina  := 'RTMKE028'

If MSGBOX('Deseja alterar os dados do pedido ' + SUA->UA_NUM +' ?',_cRotina+'_001','YESNO')
	If Empty(SUA->UA_CODCANC) .OR. Empty(SUA->UA_DOC)// - Valida se o pedido n�o est� cancelado ou j� tem nota emitida
//		If Empty(SUA->UA_STATSC9) .OR. SUA->UA_STATSC9 $ '01|02|03|06' // - ALTERADO EM 06/08/2014 PARA ADEQUA��ES
		If Empty(SUA->UA_STATSC9) .OR. SUA->UA_STATSC9 $ '01|02|03|04|06'
			_lRet := .T.
		Else
			_lRet := .F.
			MSGBOX('N�O � POSS�VEL ALTERAR INFORMA��ES DO PEDIDO, VERIFIQUE O STATUS DO MESMO.',_cRotina+'_003','ALERT')
		EndIf
	Else
		_lRet := .F.
		MSGBOX('N�O � POSS�VEL ALTERAR INFORMA��ES DE PEDIDOS CANCELADOS.',_cRotina+'_002','ALERT')
	EndIf
	If _lRet
	 	If ExistBlock('RTMKE019')
			Execblock('RTMKE019')
		Else
			MSGBOX('ROTINA N�O COMPILADA, INFORME O ADMINISTRADOR DO SISTEMA',_cRotina+'_004','ALERT')
		EndIf
	EndIf
EndIf
If ExistBlock("RTMKE028")
	//Seta atalho para tecla F4 para alterar informa��es espec�ficas no atendimento Call Center
	//SetKey(VK_F4,{|| })
	//SetKey(VK_F4,{|| U_RTMKE028()})
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	SetKey( VK_F8,{|| MsgAlert( "Tecla [ F8 ] foi alterada para [ Ctrl + F8 ]" , "Protheus11" )})
	SetKey( K_CTRL_F8, { || })
	SetKey( K_CTRL_F8, { || U_RTMKE028()})
EndIf
If ExistBlock("RTMKE022")
	//Seta atalho para tecla F5 para chamar a tela de busca avan�ada
	//SetKey(VK_F5,{|| })
	//SetKey(VK_F5,{|| U_RTMKE022() })
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	//SetKey( VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
	SetKey( K_CTRL_F5, { || })
	SetKey( K_CTRL_F5, { || U_RTMKE022()})
EndIf
If ExistBlock("RTMKE025")
	//Seta atalho para tecla F6 para chamar a confer�ncia dos atendimentos
	//SetKey(VK_F6,{|| })
	//SetKey(VK_F6,{|| U_RTMKE025() })
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	//SetKey( VK_F6,{|| MsgAlert( "Tecla [ F6 ] foi alterada para [ Ctrl + F6 ]" , "Protheus11" )})
	SetKey( K_CTRL_F6, { || })
	SetKey( K_CTRL_F6, { || U_RTMKE025()})
EndIf
If ExistBlock("RFATC011")
	//Seta atalho para tecla F7 para chamar consulta dos pedidos por cliente
	//SetKey(VK_F7,{|| })
	//SetKey(VK_F7,{|| U_RFATC011() })
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	//SetKey( VK_F7,{|| MsgAlert( "Tecla [ F7 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
	SetKey( K_CTRL_F7, { || })
	SetKey( K_CTRL_F7, { || U_RFATC011()})
EndIf

RestArea(_aSavArea)

Return()