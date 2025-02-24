#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CalcDignNum ºAutor  ³ Júlio Soares      º Data ³  10/12/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock de cálculo do Nosso Número para o Banco Itaú     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFINEBIS(NOSSONUM,_cDVNN,_lContin)

Local _aSavArea  := GetArea()
Local _aSeq      := {2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1}
Local _nSeq      := 0
Local _nRegCont  := 0
Local _nSomaDg   := 0
Local _nSomaTot  := 0
Local _nResto    := 0
local _cRotina   := "" // Inclusa a Declaração de variavel pois apresentava erro em 03/05/2017 - variable does not exist _CROTINA on U_RFINEBIS(RFINEBIS.PRW) 28/12/2016 11:21:12 line : 32
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
// - Verifico se já não existe nosso número no título
If !Empty(Alltrim(SE1->E1_NUMBCO))
	NOSSONUM := Substr(AllTrim(SE1->E1_NUMBCO),1,8)
Else
	// - Verifico se a faixa atual a ser utilizada está preenchida no cadastro de Parâmetros Banco
	If Empty(SEE->EE_FAXATU)
		If Empty(SEE->EE_FAXINI)
			MSGBOX('Atenção! A faixa atual e inicial não estão preenchidas nos parâmetros de Bancos.'+;
			'Não será possível definir o Nosso Número para o título' + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + '.'+;
			' Solicite a correção da informação neste cadastro de parâmetros de Bancos, antes de prosseguir!',_cRotina+'_008','ALERT')
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
			MSGBOX('A sequência do Nosso Número irá atingir a faixa máxima permitida. Portanto, ela será reiniciada para ' + SEE->EE_FAXINI + '.',_cRotina+'_009','ALERT')
			If Empty(SEE->EE_FAXINI)
				MsgAlert("Atenção! A faixa inicial não estão preenchidas nos parâmetros de Bancos. Não será possível definir o Nosso Número para o título " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Portanto, este não será impresso. Solicite a correção da informação neste cadastro de parâmetros de Bancos, antes de prosseguir!",_cRotina+"_010")
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
// - Realizo a verificação do nosso número.
If Empty(Alltrim(NOSSONUM))
	MsgAlert("Atenção! Não foi possível calcular o Nosso Número para o título " + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA + ". Portanto, este não será impresso!",_cRotina+"_011")
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
		// - Tratamento para separar os números maior que 9 pois devem ser somados separadamente.
		If _nSomaDg <= 9
			_nSomaTot += _nSomaDg
		Else	
			_nSomaTot += Val(Substr(cValToChar(_nSomaDg),1,1)) + Val(Substr(cValToChar(_nSomaDg),2,1))
		EndIf
	Next
	// - Inserido trecho para tratar o resto igual a zero que permanecerá como 0
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