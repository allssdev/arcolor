#INCLUDE "RWMAKE.CH"                                                               
#INCLUDE "PROTHEUS.CH"                                                                        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCOMC001  �Autor  �Adriano Leonardo    � Data �  11/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de cadastro de especifica��es t�cnicas dos produtos   ���
���          � utilizadas nos pedidos de compras.                         ���
�������������������������������������������������������������������������͹��
���Uso P11   � Uso espec�fico Arcolor                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                          

User Function RCOMC001()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZE"

dbSelectArea("SZE")
SZE->(dbSetOrder(1))
AxCadastro(cString,"Cadastro de espec�fica��es t�cnicas",cVldExc,cVldAlt)

Return()