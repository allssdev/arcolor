#include "rwmake.ch"                                                               
#include "protheus.ch"                                                                        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC004  �Autor  �Adriano Leonardo    � Data �  13/12/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de cadastro de permiss�es (tabela SZ4) utilizada para ���
���          � definir quais tipos de produtos um grupo pode visualizar.  ���
�������������������������������������������������������������������������͹��
���Uso P11   � Uso espec�fico Arcolor                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                          

User Function RFATC004()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZ4"

dbSelectArea("SZ4")
dbSetOrder(1)
AxCadastro(cString,"Permiss�es visualizar produtos",cVldExc,cVldAlt)               

Return()