#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATE007  ºAutor  ³Julio Soares        º Data ³  27/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina criada para filtrar o cadastro de clientes conforme  º±±
±±º          ³código do usuário logado.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Especifico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFATE007(_nTipo)

Local _aSavArea	:= GetArea()
Local _lFiltro  := .T.

Default _nTipo  := 1			//1=Validação de campo		/		2=Consulta padrão

dbSelectArea("SA1")
_aSavSA1 := SA1->(GetArea())
dbSelectArea("SA3")
_aSavSA3 := SA3->(GetArea())
dbSelectArea("SUS")
_aSavSUS := SUS->(GetArea())
If _nTipo == 1													//Se Variável_nTipo for exatamente igual a 1
	dbSelectArea("SA1")                                         //Seleciona tabela de clientes
	SA1->(dbSetOrder(1))                                               //Pocisiona Ordem 1
	SA1->(MsSeek(xFilial("SA1")+M->UA_CLIENTE + M->UA_LOJA,.T.,.F.))   //Pesquisa filial corrente + Cliente na memória + Loja na Memória.
EndIf
dbSelectArea("SA3")																			//Seleciona tabela dos vendedores
SA3->(dbSetOrder(7))	 //Ordem A3_FILIAL + A3_CODUSR                                      //Pocisiona a ordem no código do usuário
If SA3->(MsSeek(xFilial("SA3") + __cUserId,.T.,.F.))                                        //Pesquisa filial corrente + usuário logado
	While !SA3->(EOF()) .AND. SA3->A3_FILIAL == xFilial("SA3") .AND. SA3->A3_CODUSR == __cUserId	//Enquanto não finalizar arquivos e filial for igual filial corrente e código do usuário for igual usuário logado.
//		_lFiltro := (SA1->A1_VEND == SA3->A3_COD .AND. !Empty (SA1->A1_VEND))
//		_lFiltro := (SA1->A1_VEND == SA3->A3_COD .AND. !Empty (SA1->A1_VEND).OR.!EMPTY(SA3->A3_GEREN).AND.SA3->A3_GEREN==SA1->A1_VEND)               //Filtro Vendedor do cliente for igual Código do vendedor e não estiver em branco
		_lFiltro :=(SA1->A1_VEND == SA3->A3_COD .AND. !Empty (SA1->A1_VEND).Or.SA3->A3_GEREN==SA1->A1_VEND .AND.!EMPTY(SA3->A3_GEREN))
		dbSelectArea("SA3")
		SA3->(dbSetOrder(7))	 //Ordem A3_FILIAL + A3_CODUSR 
		SA3->(dbSkip())
	EndDo
EndIf

RestArea(_aSavSA1)
RestArea(_aSavSA3)
RestArea(_aSavSUS)
RestArea(_aSavArea)

Return(_lFiltro)