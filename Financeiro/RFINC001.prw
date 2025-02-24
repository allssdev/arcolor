#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINC001 � Autor � Thiago S. de Almeida � Data � 21/12/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE, cadastro de filtragem usuarios ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFINC001()

Private cCadastro := "Cadastro de Permiss�es Financeiras"
Private aRotina   := { {"Pesquisar" ,"AxPesqui",0,1} ,;
                       {"Visualizar","AxVisual",0,2} ,;
                       {"Incluir"   ,"AxInclui",0,3} ,;
                       {"Alterar"   ,"AxAltera",0,4} ,;
                       {"Excluir"   ,"AxDeleta",0,5} }

Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString   := "SZ3"

dbSelectArea(cString)
dbSetOrder(1)

mBrowse( 6,1,22,75,cString)

Return