#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma ณ RFINC002 บAutor  ณ Adriano L. de Souza บ Data ณ  09/01/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.   ณ Rotina responsแvel por criar um browser para visualiza็ใo dos บฑฑ
ฑฑบDesc.   ณ tํtulos a pagar, referentes a substitui็ใo tributแria, confor_บฑฑ
ฑฑบDesc.   ณ me fornecedor padrใo definido no parโmetro MV_FORNST.         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso P11  ณ Uso especํfico Arcolor                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

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