#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFINEBBS  �Autor  �Anderson C. P. Coelho � Data �  20/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock de c�lculo do Nosso N�mero para o Banco do Brasil���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINEBBS(NOSSONUM,_cDVNN,_lContin,_cRotina)

Local _aSavArea  := GetArea()
Local _aSavSEEs  := SEE->(GetArea())
Local _aSavSE1s  := SE1->(GetArea())
Local _aSeq      := {9,8,7,6,5,4,3,2}
Local _nSeq      := 0
Local _nRegCont  := 0
Local _nSomaDg   := 0
Local _nResto    := ""

Default NOSSONUM := ""
Default _cDVNN   := ""
Default _lContin := .T.
Default _cRotina := "RFINEBBS"

If !Empty(SE1->E1_NUMBCO)
	NOSSONUM := Alltrim(SEE->EE_CODEMP)+AllTrim(SE1->E1_NUMBCO)		//Por hora, sem o d�gito verificador, que ainda ser� calculado
Else
	If Empty(SEE->EE_FAXATU)
		If Empty(SEE->EE_FAXINI)
			MsgAlert("Aten��o! A faixa atual e inicial n�o est�o preenchidas nos par�metros de Bancos. N�o ser� poss�vel definir o Nosso N�mero para o t�tulo " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Solicite a corre��o da informa��o neste cadastro de par�metros de Bancos, antes de prosseguir!",_cRotina+"_008")
			_lContin := .F.
		Else
			dbSelectArea("SEE")
			while !RecLock("SEE",.F.) ; enddo
				SEE->EE_FAXATU := SEE->EE_FAXINI
			SEE->(MSUNLOCK())
		EndIf
	EndIf
	If _lContin
		_nQtPos := Len(AllTrim(SEE->EE_FAXATU))
		_cNewSq := StrZero(VAL(SEE->EE_FAXATU)+1,_nQtPos)
		If Val(_cNewSq) > Val(SEE->EE_FAXFIM)
			MsgStop("A sequ�ncia do Nosso N�mero ir� atingir a faixa m�xima permitida. Portanto, ela ser� reiniciada para " + SEE->EE_FAXINI + "!",_cRotina+"_009")
			If Empty(SEE->EE_FAXINI)
				MsgAlert("Aten��o! A faixa inicial n�o est�o preenchidas nos par�metros de Bancos. N�o ser� poss�vel definir o Nosso N�mero para o t�tulo " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Portanto, este n�o ser� impresso. Solicite a corre��o da informa��o neste cadastro de par�metros de Bancos, antes de prosseguir!",_cRotina+"_010")
				_lContin := .F.
			Else
				_cNewSq := SEE->EE_FAXINI
			EndIf
		EndIf
		If _lContin
			while !RecLock("SEE",.F.) ; enddo
				SEE->EE_FAXATU := _cNewSq
			SEE->(MsUnLock())
			NOSSONUM := Alltrim(SEE->EE_CODEMP)+AllTrim(_cNewSq)			//Por hora, sem o d�gito verificador, que ainda ser� calculado
		EndIf
	EndIf
EndIf
If Empty(NOSSONUM)
	MsgAlert("Aten��o! N�o foi poss�vel calcular o Nosso N�mero para o t�tulo " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Portanto, este n�o ser� impresso!",_cRotina+"_011")
	_lContin  := .F.
ElseIf _lContin .AND. Len(Alltrim(SEE->EE_CODEMP)) > 6		//S� calculo o d�gito verificador para N�meros de Conv�nio com menos de 7 d�gitos
	If VAL(SubStr(NOSSONUM,Len(Alltrim(SEE->EE_CODEMP))+1)) <= 1000000
		_nRegCont := Len(AllTrim(NOSSONUM))
		for _x := 1 To _nRegCont
			If _nSeq==Len(_aSeq)
				_nSeq := 0
			EndIf
			_nSeq++
			_nSomaDg += VAL(SubStr(AllTrim(NOSSONUM),((_nRegCont-_x)+1),1))*_aSeq[_nSeq]
		next
		_nCont1   := INT(_nSomaDg/11)
		_nCont2   := _nCont1 * 11
		_nResto   := _nSomaDg - _nCont2
		If _nResto == 10
			_nResto := "X"
		ElseIf _nResto == 11
			_nResto := "0"
		Else
			_nResto := StrZero(_nResto,1)
		EndIf
	EndIf
	NOSSONUM  := AllTrim(NOSSONUM)
	_cDVNN    := _nResto
EndIf

RestArea(_aSavSE1s)
RestArea(_aSavSEEs)
RestArea(_aSavArea)

Return(NOSSONUM,_cDVNN,_lContin)