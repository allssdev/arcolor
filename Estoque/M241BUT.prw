#include 'protheus.ch'
#include 'parmtype.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M241BUT   �Autor  �Anderson C. P. Coelho � Data �  01/02/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para adi��o de bot�es adicionais na rotina���
���          �de Movimentos Internos Mod.2.                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arc�lor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function M241BUT()
	Local _aSavArea  := GetArea()
	Local _aSavSB1   := SB1->(GetArea())
	Local _aButt     := {}
	If ExistBlock("RESTE006")
		SetKey( K_CTRL_F10, { || })
		SetKey( K_CTRL_F10, { || U_RESTE006()})
		AADD(_aButt	, {"PRODUTO"   , {|| U_RESTE006()},OemToAnsi("Cod.Bar.Prod."),OemToAnsi("&Cd.Bar.Prod.")})
	EndIf
	If ExistBlock("RESTE007")
		AADD(_aButt	, {"CONTAINR"  , {|| U_RESTE007()},OemToAnsi("NF Devolu��o" ),OemToAnsi("&NF Devolu��o")})	//Sele��o da NF de Devolu��o que esteja vinculada a TES sem atualiza��o de estoque, para preenchimento de seus produtos na getdados
	EndIf
	/*
	If ExistBlock("RESTE007")
		//SetKey(VK_F11, { || U_RESTE007()})
	    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
		//SetKey( VK_F11,{|| MsgAlert( "Tecla [ F11 ] foi alterada para [ Ctrl + F11 ]" , "Protheus11" )})
		SetKey( K_CTRL_F11, { || })
		SetKey( K_CTRL_F11, { || U_RESTE007()})
		AADD(_aButt	, {"CONSUMO OP", {|| U_RESTE007()},OemToAnsi("Consumo OP"),OemToAnsi("&Consumo OP.")})
	EndIf
	*/
	RestArea(_aSavArea)
	RestArea(_aSavSB1)
return(_aButt)