#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINC140  � Autor �Anderson C. P. Coelho � Data �  20/12/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Instru��es de Cobran�a.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFINC140()

Private cCadastro := "Cadastro de Instru��es de Cobran�a"
Private cString   := "SZI"
Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private aRotina   := {	{"Pesquisar" ,"AxPesqui",0,1} ,;
			            {"Visualizar","AxVisual",0,2} ,;
			            {"Incluir"   ,"AxInclui",0,3} ,;
			            {"Alterar"   ,"AxAltera",0,4} ,;
			            {"Excluir"   ,"AxDeleta",0,5} }

dbSelectArea(cString)
dbSetOrder(1)
mBrowse( 6,1,22,75,cString)

Return