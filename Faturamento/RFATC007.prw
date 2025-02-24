#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC007  � Autor � Adriano Leonardo   � Data �  14/01/2013 ���
���Programa  �RFATE053  � Autor � J�lio Soares       � Data �  14/01/2013 ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de regras de comiss�es.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���          � Inserido bot�o para chamar rotina de replica��o de regras. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFATC007()

Private cCadastro := "Regras de Comiss�es"
Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString   := "SZ6"
/*
Private aRotina   := {	{"Pesquisar"       ,"AxPesqui"               ,0,1},;
	  		            {"Copiar Regras"   ,"ExecBlock('RFATC010')"  ,0,2},;
			            {"Visualizar"      ,"Execblock('RFATE018')"  ,0,3},;
	        		    {"Incluir"         ,"Execblock('RFATE015')"  ,0,4},;
			            {"Alterar"         ,"Execblock('RFATE016')"  ,0,5},;
	        		    {"Excluir"         ,"Execblock('RFATE021')"  ,0,6},;
	        		    {"Replicar regras" ,"Execblock('RFATE053')"  ,0,7} }
*/
Private aRotina   := {	{"Pesquisar"       ,"AxPesqui"               ,0,1},;
	  		            {"Copiar Regras"   ,"ExecBlock('RFATC010')"  ,0,3},;
			            {"Visualizar"      ,"Execblock('RFATE016')"  ,0,2},;
	        		    {"Incluir"         ,"Execblock('RFATE016')"  ,0,3},;
			            {"Alterar"         ,"Execblock('RFATE016')"  ,0,4},;
	        		    {"Excluir"         ,"Execblock('RFATE016')"  ,0,5},;
	        		    {"Replicar regras" ,"Execblock('RFATE053')"  ,0,3} }
dbSelectArea(cString)
SZ6->(dbSetOrder(1))
mBrowse( 6,1,22,75,cString)

Return()