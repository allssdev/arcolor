#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC009  �Autor  �Adriano Leonardo    � Data �  29/03/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de cadastro de cadastro de s�cios (SZB).              ���
�������������������������������������������������������������������������͹��
���Uso P11   � Uso espec�fico Arcolor                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RFATC009()
	
	Local cVldAlt  	:= ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock
	Local cVldExc  	:= ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock
	Local aRotAdic 	:= {}
	Private cString := "SZB"
	
	dbSelectArea(cString)
	dbSetOrder(1)
	
	aAdd(aRotAdic,{ "Busca Avan�ada","U_RTMKE022", 0 , 1 }) //Chamada da tela de busca avan�ada (customizada)
	
	//Adiciono tecla de atalho para chamada da rotina de busca avan�ada
	SetKey(VK_F5,{|| })
	SetKey(VK_F5,{|| U_RTMKE022() })
	
	AxCadastro(cString, "Cadastro de S�cios", cVldExc, cVldAlt, aRotAdic, , , , , , , , , )
	
Return()