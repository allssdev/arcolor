#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA030ROT � Autor �Adriano Leonardo      � Data �  18/03/14 ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada para adi��o de bot�es no browse do cadas- ���
���          � tro de clientes.                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MA030ROT()

Local _aSavArea := GetArea()
Local _cRotina  := "MA030ROT"
Local _aRet	    := {}

If ExistBlock("RTMKE022")
	AAdd(_aRet,{ "Busca Avan�ada", "U_RTMKE022", 1, 0 } )
	//Seta atalho para tecla F5 para chamar a tela de busca avan�ada
	//SetKey(VK_F5,{|| })
	//SetKey(VK_F5,{|| U_RTMKE022() })
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	//SetKey(VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
	SetKey( K_CTRL_F5, { || })
	SetKey( K_CTRL_F5, { || U_RTMKE022()})
EndIf

RestArea(_aSavArea)

Return(_aRet)