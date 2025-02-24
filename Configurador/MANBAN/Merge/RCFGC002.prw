#INCLUDE "RWMAKE.CH"                                                               
#INCLUDE "PROTHEUS.CH"                                                                        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCFGC002  �Autor  �Adriano Leonardo    � Data �  14/02/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de cadastro de tabelas que far�o parte do processo de ���
���          � merge. (Sincronia de dados entre servidores).              ���
�������������������������������������������������������������������������͹��
���Uso       �Protheus 11 - Espec�fico para a empresa Arcolor.(CD Control)���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RCFGC002()

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZ8"

dbSelectArea("SZ8")
dbSetOrder(1)
AxCadastro(cString,"Rela��o de tabelas para merge",cVldExc,cVldAlt)

Return()