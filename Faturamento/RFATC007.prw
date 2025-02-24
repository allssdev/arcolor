#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATC007  º Autor ³ Adriano Leonardo   º Data ³  14/01/2013 º±±
±±ºPrograma  ³RFATE053  º Autor ³ Júlio Soares       º Data ³  14/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de regras de comissões.                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Inserido botão para chamar rotina de replicação de regras. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcolor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RFATC007()

Private cCadastro := "Regras de Comissões"
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