#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA740BRW  �Autor  �J�lio Soares        � Data �  04/23/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para inserir bot�o no a��es     ���
���          � relacionadas do Fun��es Contas a receber no financeiro a   ���
���          � fim de incluir as chamadas para a rotina customizada de    ���
���          � altera��o das observa��es do t�tulo e a rotina padr�o para ���
���          � a tela de manuten��o de comiss�es.                         ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa ARCOLOR.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function FA740BRW()

Local _aSavArea := GetArea()
Local aBotao 	:= {}
Local _cRotina	:= "FA740BRW"

If ExistBlock("RFINA003")
	AADD(aBotao, {'Altera Obs. Titulo.'	,"U_RFINA003" ,0,3})
EndIf
If ExistBlock("RFINE010")	
	AADD(aBotao, {'Comiss�es'     		,"U_RFINE010" ,0,3})
EndIf
//In�cio - Trecho adicionado por Adriano Leonardo em 27/03/2014 para adi��o de bot�o de busca avan�ada
If ExistBlock("RTMKE022")		//ExistBlock("RFINE017")
	//Defino tecla de atalho para chamada da rotina
	//SetKey(K_CTRL_F5,{|| })
	//SetKey(K_CTRL_F5,{|| U_RTMKE022() })
    // Teclas alterada em 19/08/15 por J�lio Soares para n�o conflitar com as teclas de atalho padr�o.
	//SetKey( VK_F5,{|| MsgAlert( "Tecla [ F5 ] foi alterada para [ Ctrl + F5 ]" , "Protheus11" )})
	SetKey( K_CTRL_F5, { || })
	SetKey( K_CTRL_F5, { || U_RTMKE022()})
	aAdd(aBotao, {"Busca Avan�ada"		,"U_RTMKE022" ,0,1}) //Chamada da tela de busca avan�ada (customizada)
Else
	MsgAlert("A rotina RTMKE022 n�o est� compilada, favor informar ao Administrador do sistema",_cRotina+"_001")
EndIf
//Final  - Trecho adicionado por Adriano Leonardo em 27/03/2014

RestArea(_aSavArea)

Return(aBotao)