#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA103OPC �Autor  � Adriano Leonardo     � Data �  19/05/14 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para adicionar bot�es no browse do docu-  ���
���          � mento de entrada, utilizado para adicionar a ferramenta de ���
���          � busca avan�ada.                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 (MATA410) - Espec�fico para a empresa Arcolor. ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function MA103OPC()

Local _cRotina	:= "MA103OPC"
Local _aRotUser	:= {}

//Posi��es esperadas no array
// 1. Nome a aparecer no cabecalho
// 2. Nome da Rotina associada
// 3. Usado pela rotina
// 4. Tipo de Transacao a ser efetuada
//    1 - Pesquisa e Posiciona em um Banco de Dados
//    2 - Simplesmente Mostra os Campos
//    3 - Inclui registros no Bancos de Dados
//    4 - Altera o registro corrente
//    5 - Remove o registro corrente do Banco de Dados
//    6 - Altera determinados campos sem incluir novos Regs
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

Return(_aRotUser)