#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE012  � Autor �Alessandro Villar   � Data �  16/01/13   ���
�������������������������������������������������������������������������͹��
���Descricao � Demonstrar os logs de conferencia.                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Espec�fico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFATE012()

Local _aSavArea    := GetArea()
Local _cFilCBG     := "CBG_ORDSEP == '" + CB7->CB7_ORDSEP + "' "

Private cDelFunc   := ".F."			// Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cCadastro  := "LOGS DE CONFERENCIA"
Private aRotina    := {	{"Pesquisar" ,"AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2} }

dbSelectArea("CBG")
_aSavCBG := CBG->(GetArea())
dbSetOrder(1)
dbGoTop()
CBG->(dbClearFilter())
CBG->(dbSetFilter( { || &(_cFilCBG) }, _cFilCBG ))

mBrowse( 6,1,22,75,"CBG")

//CBG->(dbClearFilter())

//RestArea(_aSavCBG)
RestArea(_aSavArea)

Return