#include 'protheus.ch'
#include 'parmtype.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M241BUT   ºAutor  ³Anderson C. P. Coelho º Data ³  01/02/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para adição de botões adicionais na rotinaº±±
±±º          ³de Movimentos Internos Mod.2.                               º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcólor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function M241BUT()
	Local _aSavArea  := GetArea()
	Local _aSavSB1   := SB1->(GetArea())
	Local _aButt     := {}
	If ExistBlock("RESTE006")
		SetKey( K_CTRL_F10, { || })
		SetKey( K_CTRL_F10, { || U_RESTE006()})
		AADD(_aButt	, {"PRODUTO"   , {|| U_RESTE006()},OemToAnsi("Cod.Bar.Prod."),OemToAnsi("&Cd.Bar.Prod.")})
	EndIf
	If ExistBlock("RESTE007")
		AADD(_aButt	, {"CONTAINR"  , {|| U_RESTE007()},OemToAnsi("NF Devolução" ),OemToAnsi("&NF Devolução")})	//Seleção da NF de Devolução que esteja vinculada a TES sem atualização de estoque, para preenchimento de seus produtos na getdados
	EndIf
	/*
	If ExistBlock("RESTE007")
		//SetKey(VK_F11, { || U_RESTE007()})
	    // Teclas alterada em 19/08/15 por Júlio Soares para não conflitar com as teclas de atalho padrão.
		//SetKey( VK_F11,{|| MsgAlert( "Tecla [ F11 ] foi alterada para [ Ctrl + F11 ]" , "Protheus11" )})
		SetKey( K_CTRL_F11, { || })
		SetKey( K_CTRL_F11, { || U_RESTE007()})
		AADD(_aButt	, {"CONSUMO OP", {|| U_RESTE007()},OemToAnsi("Consumo OP"),OemToAnsi("&Consumo OP.")})
	EndIf
	*/
	RestArea(_aSavArea)
	RestArea(_aSavSB1)
return(_aButt)