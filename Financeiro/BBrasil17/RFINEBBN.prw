#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINEBBN  �Autor  �Anderson C. P. Coelho � Data �  20/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock de c�lculo ou retorno do nosso n�mero para o     ���
���          �boleto e CNAB do Banco do Brasil, independente de sua       ���
���          �carteira.                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
ElseIf !Empty(SE1->E1_NUMBCO)		//Se o nosso n�mero estiver preenchido em E1_NUMBCO, colho a informa��o de l�. Caso contr�rio, calculo.
	_cRetNN := StrZero(VAL(SEE->EE_CODEMP),7)+StrZero(VAL(SE1->E1_NUMBCO),10)
Else
	//### REG.001 - Composi��o do Nosso N�mero
	NOSSONUM := ""
	_cDVNN   := ""
	_lContin := .T.
	//C�lculo do Nosso N�mero e do D�gito Verificador, quando for o caso
	U_RFINEBBS(@NOSSONUM,@_cDVNN,@_lContin,_cRotina)
	If _lContin
		_cRetNN := NOSSONUM+_cDVNN
	EndIf
	//Fim do C�lculo do Nosso N�mero
EndIf

RestArea(_aSavSE1)
RestArea(_aSavSEE)
RestArea(_aSavArea)

Return(_cRetNN)