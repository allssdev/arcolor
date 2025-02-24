#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa � RFINC002 �Autor  � Adriano L. de Souza � Data �  09/01/2014  ���
��������������������������������������������������������������������������͹��
���Desc.   � Rotina respons�vel por criar um browser para visualiza��o dos ���
���Desc.   � t�tulos a pagar, referentes a substitui��o tribut�ria, confor_���
���Desc.   � me fornecedor padr�o definido no par�metro MV_FORNST.         ���
��������������������������������������������������������������������������͹��
���Uso P11  � Uso espec�fico Arcolor                                       ���
��������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������*/

User Function RFINC002() 

Local aIndex := {} 
Local cFiltro := "E2_FORNECE == '" + SuperGetMv("MV_FORNST" ,,"FAZEND" ) + "'" //Expressao do Filtro 
Private aRotina := {}

aAdd( aRotina,	{ "Pesquisar" , "AxPesqui" 	, 0 , 1,,.F.})  //"Pesquisar"
aAdd( aRotina,	{ "Visualizar", "AxVisual"	, 0 , 2		})  //"Visualizar"

Private bFiltraBrw := { || FilBrowse( "SE2" , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro 
Private cCadastro := "Contas a pagar (ST)" 
Eval( bFiltraBrw ) //Efetiva o Filtro antes da Chamada a mBrowse 

mBrowse( 6 , 1 , 22 , 75 , "SE2",,,,,, Fa040Legenda("SE2"))

EndFilBrw( "SE2" , @aIndex ) //Finaliza o Filtro 

Return()