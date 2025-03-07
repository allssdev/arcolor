#INCLUDE "RWMAKE.CH"                                                               
#INCLUDE "PROTHEUS.CH"                                                                        

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RESTC001  �Autor  �Adriano Leonardo    � Data �  09/12/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de cadastro de consumo mensal (espec�fico). SZG       ���
�������������������������������������������������������������������������͹��
���Uso P11   � Uso espec�fico Arcolor                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/                                                                          

User Function RESTC001()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cVldAlt := ".F." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZG"
Private cTitulo := "Consumo Mensal"

dbSelectArea(cString)
(cString)->(dbSetOrder(1))
AxCadastro(cString,cTitulo,cVldExc,cVldAlt)

Return()