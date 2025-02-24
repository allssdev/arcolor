#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณACD100M  บAutor  ณAlessandro Villar บ Data      ณ  09/01/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada chamado na gera็ใo das Ordens de Separa็ใo,บฑฑ
ฑฑบ          ณpara substituir o botใo padrใo de impressใo.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Arcolor            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ACD100M()
 
/*aRotina := {	
			{STR0001	 ,"AxPesqui", 0,1},;   //"Pesquisar"
			{STR0002	 ,"ACDA100Vs",0,2},;   //"Visualizar"
			{STR0003	 ,"ACDA100Al",0,3},;   //"Alterar"
			{STR0004	 ,"ACDA100Et",0,5,5},; //"Estornar"
			{STR0005	 ,"ACDA100Gr",0,3},;   //"Gerar"
			{STR0116	 ,"ACDA100Re",0,4},;   //"Impressao"
			{STR0006	 ,"ACDA100Lg",0,3}}    //"Legenda"

			A Posi็ใo aRotina[6,1] ้ a Mensagem Impressao
			A Posi็ใo aRotina[6,2] ้ a Fun็ใo ACDA100Re
			A Posi็ใo aRotina[6,3] ้ o N๚mero 0
			A Posi็ใo aRotina[6,4] ้ o N๙mero 4. */

aRotina := {{"&Pesquisar"          ,"AxPesqui"              ,0,1  },;
			{"&Visualizar"         ,"ACDA100Vs"             ,0,2  },;
			{"&Alterar"            ,"ACDA100Al"             ,0,3  },;
			{"&Estornar"           ,"ACDA100Et"             ,0,5, },;
			{"&Gerar"              ,"ACDA100Gr"             ,0,3  },;
			{"&Impressao"          ,"U_RFATR013('ACD100M')" ,0,4  },;
			{"&Finalizar"          ,"U_RFATE009()"          ,0,2  },;
			{"&Reiniciar Conf."    ,"U_RACDE001()"          ,0,4  },;
			{"&Consulta de Logs"   ,"U_RFATE012()"          ,0,2  },;
			{"&Itens Conferidos"   ,"U_RFATE011()"          ,0,2  },;
			{"&Legenda"            ,"ACDA100Lg"             ,0,3  }}

Return(aRotina)