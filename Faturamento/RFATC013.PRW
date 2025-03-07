#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC013  � Autor � Adriano Leonardo   � Data �  11/02/2015 ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de regras de neg�cios Arc�lor.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFATC013()

Private cCadastro := "Regras de Neg�cios Arc�lor - Descontos"
Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString   := "SZS"
Private aRotina   := {	{"Pesquisar"       ,"AxPesqui"               ,0,1},;
	  		            {"Copiar Regras"   ,"ExecBlock('RFATC010')"  ,0,2},;
			            {"Visualizar"      ,"Execblock('RFATE018')"  ,0,3},;
	        		    {"Incluir"         ,"Execblock('RFATE015')"  ,0,4},;
			            {"Alterar"         ,"Execblock('RFATE016')"  ,0,5},;
	        		    {"Excluir"         ,"Execblock('RFATE021')"  ,0,6},;
	        		    {"Replicar regras" ,"Execblock('RFATE053')"  ,0,7} }
dbSelectArea(cString)
SZ6->(dbSetOrder(1))
mBrowse(6,1,22,75,cString)

Return()