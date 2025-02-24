#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATA011  � Autor � J�lio Soares        � Data �  04/09/13  ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina gerada para criar cadastro de grupos de tributa��o  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Especifico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFATA011()

Private  cCadastro := "Cadastro de Grupo de tributa��o"
Private cDelFunc   := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString    := "SZF"
Private aRotina    := { {"Pesquisar" ,""        ,0,1} ,;
						{"Visualizar","AxVisual",0,2} ,;
			            {"Incluir"   ,"AxInclui",0,3} ,;
			            {"Alterar"   ,"AxAltera",0,4} ,;
			            {"Excluir"   ,"AxDeleta",0,5} }

dbSelectArea("SZF")
SZF->(dbSetOrder(1))
mBrowse( 6,1,22,75,cString)

Return()