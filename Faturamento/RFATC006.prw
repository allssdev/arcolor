#include "rwmake.ch"
#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC006  �Autor  �Adriano Leonardo    � Data �  08/01/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de cadastro de n�vel de acesso por grupo de usu�rios  ���
���          � para defini��o da permiss�o de altera��o de campos.        ���
�������������������������������������������������������������������������͹��
���Uso P11   � Uso espec�fico Arcolor                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATC006()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZ5"

dbSelectArea("SZ5")
dbSetOrder(1)
AxCadastro(cString,"N�vel de Acesso Campos","Execblock('RFATE013')","Execblock('RFATE013')")
                                                            
Return()