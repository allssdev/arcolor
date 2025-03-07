#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA020FIL  �Autor  � J�lio Soares       � Data �  24/07/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para criar uma tecla de atalho. ���
���          �                                                            ���
���          � LOCALIZA��O : Function MATA020 - Fun��o principal do       ���
���          � programa de inclus�o, altera��o e exclus�o de Fornecedores ���.
���          � EM QUE PONTO: No in�cio da Fun��o, antes de montar a tela d���
���          � browse dos fornecedores, deve ser usado para adicionar um  ���
���          � FILTRO para os registros do cadastro de fornecedores       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA020FIL()

Local _aSavArea  := GetArea()
Local _aSavSC5   := SC5->(GetArea())
Local _aSavSA1   := SA1->(GetArea())

Private _cRotina := "MA020FIL"
// DESATIVADO ALTERA��O EM 21/08/15 POR J�LIO SOARES AP�S SOLICITA��O DO SR. MARIO
SetKey(VK_F11, { || FICHFINAN() }) // - Tecla de atalho para abrir a ficha financeira (customizada) do cliente

RestArea(_aSavSC5 )
RestArea(_aSavSA1 )
RestArea(_aSavArea)

Return()
/*
/�����������������������������������������������������������������������������/�����������������������������������������������������������������������������/�������������������������������������������������������������������������ͻ��/���Programa  � FICHFINAN �Autor  �J�lio Soares       � Data �  17/10/13   ���/�������������������������������������������������������������������������͹��/���Desc.     � Execblock utilizado para montar a ficha financeira do      ���/���          � cliente.                                                   ���/�������������������������������������������������������������������������͹��/���Uso       � Programa Principal.                                        ���/�������������������������������������������������������������������������ͼ��/�����������������������������������������������������������������������������/����������������������������������������������������������������������������
*/

Static Function FICHFINAN()
// - F11
If ExistBlock("RFINE016")
	U_RFINE016("F11")
Else
	MSGBOX('FUN��O N�O ENCONTRADA. INFORME O ADMINISTRADOR DO SISTEMA!',_cRotina + '_001','ALERT')
EndIf
Return()