#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA050ROT � Autor �Adriano Leonardo      � Data �  27/03/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada para adi��o de bot�es na tela de cadastro ���
���          � de transportadoras.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MA050ROT()  

Local _aSavArea := GetArea()
Local _aBotao 	:= {}  
Local _cRotina	:= "MA050ROT"

If ExistBlock("RTMKE022")
	//Defino tecla de atalho para chamada da rotina
	//SetKey(VK_F5,{|| })
	//SetKey(VK_F5,{|| U_RTMKE022() }) //Chamada da rotina de busca avan�ada
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	//SetKey(VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Control + F5 ]" , "Protheus11" )})
	SetKey( K_CTRL_F5, { || })
	SetKey( K_CTRL_F5, { || U_RTMKE022()})
	aAdd(_aBotao , { "Busca Avan�ada",'U_RTMKE022', 0 , 1} )
Else
	MsgAlert("A rotina RTMKE022 n�o est� compilada, favor informar ao Administrador",_cRotina+"_001")
EndIf

RestArea(_aSavArea)

Return(_aBotao)