#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � SIGAPON  �Autor  � Adriano L. de Souza � Data � 05/06/2014   ���
��������������������������������������������������������������������������͹��
���Desc.   � Fun��o desenvolvida aplicar a rotina de busca avan�ada em     ���
���Desc.   � todas as telas do m�dulo Ponto Eletr�nico.                    ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������ͱ����
����������������������������������������������������������������������������*/

User Function SIGAPON()

If ExistBlock("RTMKE022")
	//Defino tecla de atalho para chamada da rotina de busca avan�ada
	//SetKey(K_CTRL_F5,{|| })
	//SetKey(K_CTRL_F5,{|| U_RTMKE022() })
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	//SetKey( VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
	SetKey( K_CTRL_F5, { || })
	SetKey( K_CTRL_F5, { || U_RTMKE022()})
EndIf

Return()