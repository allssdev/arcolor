#INCLUDE "totvs.ch"
#INCLUDE "COLORS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK271LEG  บAutor  ณJ๚lio Soares        บ Data ณ  19/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada para alterar as descri็๕es das legendas    บฑฑ
ฑฑบ          ณpara as cores alteradas pelo ponto de entrada TK271COR      บฑฑ
ฑฑบ          ณconforme solicita็ใo do cliente                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico - ARCOLOR                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TK271LEG(cPasta)

Local _aCores 	:= {}					// Array Default com as definicoes de cores

Default cPasta	:= TkGetTipoAte()		// Parametro com a pasta que sera inicializada

Do Case
	Case (TkGetTipoAte() == "1") //Telemarketing                
		If Len(_aCores) == 0
			_aCores := { {"BR_AZUL"    ,'Atendimento Planejado'},;	//"Atendimento Planejado"
						 {"BR_VERMELHO",'Atendimento Pendente' },;	//"Atendimento Pendente"
						 {"BR_VERDE"   ,'Atendimento Encerrado'},;	//"Atendimento Encerrado"
						 {"BR_PRETO"   ,'Atendimento Cancelado'}}	//"Atendimento Cancelado"
		EndIf
	Case (TkGetTipoAte() == "2") //Televendas
		If Len(_aCores) == 0
			_aCores := {{'BR_BRANCO' ,'Atendimento'        },;
						{'BR_AZUL'   ,'Pr้ pedido'         },;
						{'ENABLE'    ,'Pedido'             },;
						{'BR_PRETO'  ,'Blq. neg๓cio'       },;
			 			{'BR_CINZA'  ,'Blq. cr้dito'       },;
			 			{'BR_MARROM' ,'Blq. estoque'       },;
		 				{'BR_AMARELO','Pedido em separa็ใo'},;
		 				{'BR_PINK'   ,'Pedido fat. parcial'},;
		 				{'BR_LARANJA','Pedido fat. total'  },;
		 				{'BR_VIOLETA','Expedido parcial'   },;
		 				{'DISABLE'   ,'Expedido total'     },;
						{'BR_CANCEL' ,'Pedido cancelado'   }}
		EndIf
	Case (TkGetTipoAte() == "3") //Telecobranca
		If Len(_aCores) == 0
			_aCores :=  {{"BR_AZUL"    ,'Atendimento'},;		//"Atendimento"
						 {"BR_VERDE"   ,'Cobran็a'   },;		//"Cobran็a"
						 {"BR_VERMELHO",'Encerrado'  },;		//"Encerrado"
						 {"BR_CINZA"   ,'Cancelado'  }}		//"Cancelado"	
		EndIf
EndCase

Return(_aCores)
