#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE011  � Autor �Alessandro Villar   � Data �  16/01/13   ���
�������������������������������������������������������������������������͹��
���Descricao � Demonstrar os itens confereridos.                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFATE011()

Local _aSavArea   := GetArea()
Local _cFilCB9    := "CB9_ORDSEP == '" + CB7->CB7_ORDSEP + "' "

Private cCadastro := "ITENS CONFERIDOS"
Private cDelFunc  := ".F."								// Validacao para a exclusao. Pode-se utilizar ExecBlock
Private aRotina   := {	{"Pesquisar" ,"AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2} }

dbSelectArea("CB9")
_aSavCB9 := CB9->(GetArea())
dbSetOrder(1)
CB9->(dbGoTop())
CB9->(dbClearFilter())
CB9->(dbSetFilter( { || &(_cFilCB9) }, _cFilCB9 ))

mBrowse( 6,1,22,75,"CB9")

//CB9->(dbClearFilter())

//RestArea(_aSavCB9)
RestArea(_aSavArea)

Return