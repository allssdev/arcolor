#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFINEBBN  ºAutor  ³Anderson C. P. Coelho º Data ³  20/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock de cálculo ou retorno do nosso número para o     º±±
±±º          ³boleto e CNAB do Banco do Brasil, independente de sua       º±±
±±º          ³carteira.                                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFINEBBN(_lDig)

Local _aSavArea := GetArea()
Local _aSavSE1  := {}
Local _aSavSEE  := {}
Local _cRotina  := "RFINEBBN"

Private _cRetNN := ""

Default _lDig   := .T.

dbSelectArea("SE1")
_aSavSE1 := SE1->(GetArea())
dbSelectArea("SEE")
_aSavSEE := SEE->(GetArea())
If AllTrim(SEE->EE_NUMAUT)=="N".OR.AllTrim(SEE->EE_CODCART)$"11/31/51"
	_cRetNN := StrZero(0,17)
ElseIf !Empty(SE1->E1_NUMBCO)		//Se o nosso número estiver preenchido em E1_NUMBCO, colho a informação de lá. Caso contrário, calculo.
	_cRetNN := StrZero(VAL(SEE->EE_CODEMP),7)+StrZero(VAL(SE1->E1_NUMBCO),10)
Else
	//### REG.001 - Composição do Nosso Número
	NOSSONUM := ""
	_cDVNN   := ""
	_lContin := .T.
	//Cálculo do Nosso Número e do Dígito Verificador, quando for o caso
	U_RFINEBBS(@NOSSONUM,@_cDVNN,@_lContin,_cRotina)
	If _lContin
		_cRetNN := NOSSONUM+_cDVNN
	EndIf
	//Fim do Cálculo do Nosso Número
EndIf

RestArea(_aSavSE1)
RestArea(_aSavSEE)
RestArea(_aSavArea)

Return(_cRetNN)