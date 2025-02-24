#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC008  � Autor �Anderson C. P. Coelho � Data �  19/03/13 ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro dos fatores de desconto para aplica��o do desconto���
���          �l�quido nas regras de desconto padr�o do sistema.           ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFATC008()

Private cCadastro := "Cadastro de Fatores de Desconto Efetivo"
Private aRotina   := {	{"Pesquisar" ,"AxPesqui",0,1} ,;
			            {"Visualizar","AxVisual",0,2} ,;
			            {"Incluir"   ,"AxInclui",0,3} ,;
			            {"Alterar"   ,"AxAltera",0,4} ,;
			            {"Excluir"   ,"AxDeleta",0,5} }

Private cDelFunc := ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString  := "SZA"

dbSelectArea(cString)
dbSetOrder(1)

mBrowse( 6,1,22,75,cString)

Return