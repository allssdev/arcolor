#include "rwmake.ch"                                                               
#include "protheus.ch"                                                                        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC001  �Autor  �Adriano Leonardo    � Data �  13/12/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de cadastro de valida��es (tabela SZ1) criado para    ���
���          � defini��o de par�metros para valida��o do pedido de vendas.���
�������������������������������������������������������������������������͹��
���Uso P11   � Uso espec�fico Arcolor                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATC001()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZ1"

dbSelectArea("SZ1")
dbSetOrder(1)
AxCadastro(cString,"Cadastro de valida��es",cVldExc,cVldAlt)

Return()