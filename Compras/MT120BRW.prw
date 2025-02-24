#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT120BRW �Autor  � J�lio Soares       � Data �  10/02/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada na inicializa��o do browse dos pedidos de ���
���          � compras.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT120BRW()

Local _aSavArea := GetArea()
Local _aRotUser	:= {}

If ExistBlock("RCOME010")
	//SetKey(VK_F6,{ || U_RCOME010()}) // - Tecla de atalho para alterar o fornecedor do pedido de compras.
	// Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	//SetKey( VK_F6,{|| MsgAlert( "Tecla [ F6 ] foi alterada para [ Ctrl + F7 ]" , "Protheus11" )})
	SetKey( K_CTRL_F7, { || })
	SetKey( K_CTRL_F7, { || U_RCOME010()})
EndIf
//RestArea(_aSavArea)
//Inicio - Trecho adicionado por Adriano Leonardo em 19/05/2014
If ExistBlock("RTMKE022")
	AAdd(_aRotUser, { "Busca Avan�ada", "U_RTMKE022", 0, 1 })
	//Seta atalho para tecla F5 para chamar a tela de busca avan�ada
	//SetKey(VK_F5,{|| })
	//SetKey(VK_F5,{|| U_RTMKE022() })
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	//SetKey( VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
	SetKey( K_CTRL_F5, { || })
	SetKey( K_CTRL_F5, { || U_RTMKE022()})
EndIf
//Final  - Trecho adicionado por Adriano Leonardo em 19/05/2014

Return()
