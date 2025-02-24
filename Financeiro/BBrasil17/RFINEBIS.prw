#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CalcDignNum �Autor  � J�lio Soares      � Data �  10/12/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock de c�lculo do Nosso N�mero para o Banco Ita�     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINEBIS(NOSSONUM,_cDVNN,_lContin)

Local _aSavArea  := GetArea()
Local _aSeq      := {2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1}
Local _nSeq      := 0
Local _nRegCont  := 0
Local _nSomaDg   := 0
Local _nSomaTot  := 0
Local _nResto    := 0
local _cRotina   := "" // Inclusa a Declara��o de variavel pois apresentava erro em 03/05/2017 - variable does not exist _CROTINA on U_RFINEBIS(RFINEBIS.PRW) 28/12/2016 11:21:12 line : 32
//local _cAg		 := ""
//Local _cCC		 := "" 
Default NOSSONUM := ""
Default _cDVNN   := ""
Default _lContin := .T.
Default _cRotina := "RFINEBIS" 

dbSelectArea("SE1")
_aSavSE1 := SE1->(GetArea())
dbSelectArea("SEE")
_aSavSEE := SEE->(GetArea())
If type("_cAg")=="U"
	_cAg := ""
EndIf
If type("_cCC")=="U"
	_cCC := ""
EndIf
// - Verifico se j� n�o existe nosso n�mero no t�tulo
If !Empty(Alltrim(SE1->E1_NUMBCO))
	NOSSONUM := Substr(AllTrim(SE1->E1_NUMBCO),1,8)
Else
	// - Verifico se a faixa atual a ser utilizada est� preenchida no cadastro de Par�metros Banco
	If Empty(SEE->EE_FAXATU)
		If Empty(SEE->EE_FAXINI)
			MSGBOX('Aten��o! A faixa atual e inicial n�o est�o preenchidas nos par�metros de Bancos.'+;
			'N�o ser� poss�vel definir o Nosso N�mero para o t�tulo' + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + '.'+;
			' Solicite a corre��o da informa��o neste cadastro de par�metros de Bancos, antes de prosseguir!',_cRotina+'_008','ALERT')
			_lContin := .F.
		Else
			dbSelectArea("SEE")
			RecLock("SEE",.F.)
				SEE->(EE_FAXATU) := SEE->(EE_FAXINI)
			SEE->(MsUnlock())
		EndIf
	EndIf
	If _lContin
		_nQtPos := Len(AllTrim(SEE->EE_FAXATU))
		_cNewSq := StrZero(VAL(SEE->EE_FAXATU)+1,_nQtPos)
		If Val(_cNewSq) >= Val(SEE->EE_FAXFIM)
			MSGBOX('A sequ�ncia do Nosso N�mero ir� atingir a faixa m�xima permitida. Portanto, ela ser� reiniciada para ' + SEE->EE_FAXINI + '.',_cRotina+'_009','ALERT')
			If Empty(SEE->EE_FAXINI)
				MsgAlert("Aten��o! A faixa inicial n�o est�o preenchidas nos par�metros de Bancos. N�o ser� poss�vel definir o Nosso N�mero para o t�tulo " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Portanto, este n�o ser� impresso. Solicite a corre��o da informa��o neste cadastro de par�metros de Bancos, antes de prosseguir!",_cRotina+"_010")
				_lContin := .F.
			Else
				_cNewSq := SEE->EE_FAXINI
			EndIf
		EndIf
		If _lContin
			RecLock("SEE",.F.)
				SEE->EE_FAXATU := _cNewSq
			SEE->(MsUnLock())
			NOSSONUM := AllTrim(_cNewSq)
			/*
			NOSSONUM := StrZero(VAL(SubStr(_cAg,1,AT("-",_cAg)-1)),04);
						 +StrZero(VAL(SubStr(_cCC,1,AT("-",_cCC)-1)),05);
						 +StrZero(VAL(SEE->EE_CODCART),03);
						 +Strzero(Val(Alltrim(_cNewSq)),08)
			*/
		EndIf
	EndIf
EndIf
// - Realizo a verifica��o do nosso n�mero.
If Empty(Alltrim(NOSSONUM))
	MsgAlert("Aten��o! N�o foi poss�vel calcular o Nosso N�mero para o t�tulo " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Portanto, este n�o ser� impresso!",_cRotina+"_011")
	_lContin  := .F.
Else
	_cNum := StrZero(VAL(SubStr(_cAg,1,AT("-",_cAg)-1)),04);
			+StrZero(VAL(SubStr(_cCC,1,AT("-",_cCC)-1)),05);
			+StrZero(VAL(SEE->EE_CODCART),03);
			+Strzero(Val(Alltrim(NOSSONUM)),08)
	//_nRegCont := Len(AllTrim(NOSSONUM))// - Alterado em 25/04/2016
	_nRegCont := Len(_cNum)
	For _x := 1 To _nRegCont
		If _nSeq==Len(_aSeq)
			_nSeq := 0
		EndIf
		_nSeq++
		//_nSomaDg := VAL(SubStr(AllTrim(NOSSONUM),((_nRegCont-_x)+1),1))*_aSeq[_nSeq]
		_nSomaDg := VAL(SubStr(AllTrim(_cNum),((_nRegCont-_x)+1),1))*_aSeq[_nSeq]
		// - Tratamento para separar os n�meros maior que 9 pois devem ser somados separadamente.
		If _nSomaDg <= 9
			_nSomaTot += _nSomaDg
		Else	
			_nSomaTot += Val(Substr(cValToChar(_nSomaDg),1,1)) + Val(Substr(cValToChar(_nSomaDg),2,1))
		EndIf
	Next
	// - Inserido trecho para tratar o resto igual a zero que permanecer� como 0
	If MOD(_nSomaTot,10) <> 0
		_nResto := (10-(MOD(_nSomaTot,10)))
	Else
		_nResto := 0
	EndIf
EndIf
NOSSONUM  := AllTrim(NOSSONUM)
_cDVNN    := StrZero(_nResto,1)

RestArea(_aSavSEE)
RestArea(_aSavSE1)
RestArea(_aSavArea)

Return(NOSSONUM,_cDVNN)