#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINEBIN  �Autor  �Anderson C. P. Coelho � Data �  20/12/13 ���
���          �          �Autor  � J�lio Soares         � Data �  20/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock de c�lculo ou retorno do nosso n�mero para o     ���
���          �boleto e CNAB do Banco Ita�, independente de sua            ���
���          �carteira.                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINEBIN(_lDig)

Local _aSavArea := GetArea()
Local _aSavSE1  := {}
Local _aSavSEE  := {}
Local _cRotina  := "RFINEBIN"

Private _cRetNN := ""

Default _lDig   := .T.

dbSelectArea("SE1")
_aSavSE1 := SE1->(GetArea())
dbSelectArea("SEE")
_aSavSEE := SEE->(GetArea())
If AllTrim(SEE->EE_NUMAUT)=="N"//.OR.AllTrim(SEE->EE_CODCART)$"112"
	_cRetNN := StrZero(0,8)
ElseIf !Empty(Alltrim(SE1->E1_NUMBCO))		//Se o nosso n�mero estiver preenchido em E1_NUMBCO, colho a informa��o de l�. Caso contr�rio, calculo.
	//_cRetNN := StrZero(Val(Alltrim(SE1->E1_IDCNAB)),08)
	_cRetNN := StrZero(Val(Alltrim(SE1->E1_NUMBCO)),08) 
Else
	//### REG.001 - Composi��o do Nosso N�mero
	NOSSONUM := ""
	_cDVNN   := ""
	_lContin := .T.
	//C�lculo do Nosso N�mero e do D�gito Verificador, quando for o caso
	U_RFINEBIS(@NOSSONUM,@_cDVNN,@_lContin)
	If _lContin
		_cRetNN := NOSSONUM+_cDVNN
	EndIf
	//Fim do C�lculo do Nosso N�mero
EndIf

RestArea(_aSavSE1)
RestArea(_aSavSEE)
RestArea(_aSavArea)

Return(_cRetNN)