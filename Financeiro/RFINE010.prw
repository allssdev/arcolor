#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFINE010 ºAutor  ³Adriano Leonardo    º Data ³  18/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina responsável por incluir a manutenção de comissões noº±±
±±º          ³ botão de ações relacionadas do funções contas a receber.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function RFINE010()

Local _cCadastro := "Rastrear comissões"

l490Auto   := .F.

aRotina := {	{ _cCadastro    ,"AxPesqui"		, 0 , 1 , 0 , .F.},;  // "Pesquisar"
				{ "Visualizar"	,"AxVisual"		, 0 , 2 , 0 , NIL},;  // "Visualizar"
				{ "Incluir"		,"A490Inclui"	, 0 , 3 , 0 , NIL},;  // "Incluir"
				{ "Alterar"		,"A490Altera"	, 0 , 4 , 0 , NIL},;  // "Alterar"
				{ "Excluir"		,"A490Deleta"	, 0 , 5 , 0 , NIL},;  // "Excluir"
				{ "Legenda"		,"A490Legend"	, 0 , 6 , 0 , .F.} }  // "Legenda"

dbSelectArea("SE1")

_cFiltro := "SE3->E3_NUM=='" + SE1->E1_NUM + "' .AND. SE3->E3_PREFIXO=='" + SE1->E1_PREFIXO + "' .AND. SE3->E3_TIPO=='" + SE1->E1_TIPO + "' .AND. SE3->E3_PARCELA=='" + SE1->E1_PARCELA + "'"

Private _aIndexSE3 := {}
Private bFiltraBrw := { || FilBrowse( "SE3" , @_aIndexSE3 , @_cFiltro ) }

Eval( bFiltraBrw )

MBrowse(6, 1, 22, 75, "SE3",,"E3_DATA")

Return()