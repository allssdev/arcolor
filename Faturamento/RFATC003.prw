#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC003   � Autor � J�lio Soares      � Data �  14/12/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina criada para a inclus�o de dados no cadastro de      ���
���          � regi�es por CEP                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico Arcolor                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFATC003()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private cCadastro := "Cadastro de regi�es"

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","AxVisual",0,2} ,;
             {"Incluir","AxInclui",0,3} ,;
             {"Alterar","AxAltera",0,4} ,;
             {"Excluir","AxDeleta",0,5} }

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SZ0"

dbSelectArea("SZ0")
dbSetOrder(1)
dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return