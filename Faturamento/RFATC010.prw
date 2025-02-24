#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATC010  � Autor � Adriano Leonardo   � Data �  07/08/2013 ���
�������������������������������������������������������������������������͹��
���Descricao � C�pia das regras de comiss�es (produtos por representante) ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11 - Especifico para a empresa Arcolor.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RFATC010()

Local _aSavArea 	:= GetArea()
Local _aSavSZ6 		:= SZ6->(GetArea())
Private _cRotina	:= "RFATC010"
Private _aCpos		:= {}
Private _lContinua 	:= .F.

If Interface()
	Return(Nil)
EndIf
    
//Restauro a �rea
RestArea(_aSavSZ6)
RestArea(_aSavArea)

Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Interface � Autor � Adriano Leonardo   � Data �  08/08/2013 ���
�������������������������������������������������������������������������͹��
���Descricao � Interface da rotina de c�pia das regras de comiss�es.      ���
�������������������������������������������������������������������������͹��
���Uso  P11  � Uso espec�fico Arcolor - Programa principal                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function Interface()

Local btnCancelar
Local btnOk
Local grpDestino
Local grpOrigem
Local lblCodDes
Local lblCodOri
Local lblNomeDes
Local lblNomeOri
Local txtCodDest
Local txtCodOri
Local txtNomeDes
Local txtNomeOri
Private cxtCodDest := Space(TamSX3("A3_COD")[01])
Private cxtCodOri  := SZ6->Z6_REPRES //Space(TamSX3("A3_COD")[01])
Private cxtNomeDes := Space(TamSX3("A3_NOME")[01])
Private cxtNomeOri := SZ6->Z6_NOMERE //Space(TamSX3("A3_NOME")[01])
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "C�pia das regras de comiss�es" FROM 000, 000  TO 400, 650 COLORS 0, 16777215 PIXEL

    @ 025, 007 GROUP grpOrigem TO 089, 316 PROMPT "Representante a Ser Copiado" OF oDlg COLOR 0, 16777215 PIXEL
    @ 112, 007 GROUP grpDestino TO 172, 315 PROMPT "Novo Representante" OF oDlg COLOR 0, 16777215 PIXEL

    @ 042, 018 SAY lblCodOri PROMPT "C�digo do Representante:" SIZE 063, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 056, 065 SAY lblNomeOri PROMPT "Nome:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

    @ 130, 017 SAY lblCodDes PROMPT "C�digo do Representante:" SIZE 072, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 144, 063 SAY lblNomeDes PROMPT "Nome:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

    @ 040, 086 MSGET txtCodOri VAR cxtCodOri F3 "SA3" VALID ValidSA3() SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 085 MSGET txtNomeOri VAR cxtNomeOri SIZE 182, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL

    @ 127, 085 MSGET txtCodDest VAR cxtCodDest F3 "SA3" VALID ValidSZ6() SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 143, 085 MSGET txtNomeDes VAR cxtNomeDes SIZE 182, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL

    @ 180, 202 BUTTON btnOk PROMPT "&Ok" Action(Processar()) SIZE 052, 012 OF oDlg PIXEL
    @ 180, 262 BUTTON btnCancelar PROMPT "&Cancelar" Action IIf(_lContinua,MsgStop("O processo de c�pia j� foi iniciado, favor aguardar!",_cRotina+"_001"),Close(oDlg)) SIZE 053, 012 OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return(_lContinua)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � VALIDSA3 � Autor � Adriano Leonardo   � Data �  07/08/2013 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o para validar o c�digo do representante do qual as   ���
���          � regras de comiss�es ser�o copiadas.                        ���
�������������������������������������������������������������������������͹��
���Uso  P11  � Uso espec�fico Arcolor - Programa principal                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ValidSA3(_cCodigo)
 
Local _aAreaTmp := SA3->(GetArea())
Local lRet      := .T.

dbSelectArea("SA3")
dbSetOrder(1)
If MsSeek(xFilial("SA3") + IIF(_cCodigo==Nil,cxtCodOri,cxtCodDest),.T.,.F.)
 	If _cCodigo <> Nil                
 		cxtNomeDes := SA3->A3_NOME
 	Else
 		cxtNomeOri := SA3->A3_NOME
 	EndIf
ElseIf Empty(IIF(_cCodigo==Nil,cxtCodOri,cxtCodDest))
	If _cCodigo <> Nil                
 		cxtNomeDes := ""
 	Else
 		cxtNomeOri := ""
 	EndIf
Else
	lRet := .F.
	MsgStop("C�digo inv�lido!",_cRotina+"_002")
EndIf

RestArea(_aAreaTmp)
	
Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � VALIDSZ6 � Autor � Adriano Leonardo   � Data �  07/08/2013 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o para validar o c�digo do representante para o qual  ���
���          � as regras ser�o copiados.                                  ���
�������������������������������������������������������������������������͹��
���Uso  P11  � Uso espec�fico Arcolor - Programa principal                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ValidSZ6()

Local _aAreaTemp := SZ6->(GetArea())
Local lRet       := .T.

dbSelectArea("SZ6")
dbSetOrder(1)
If cxtCodDest==cxtCodOri
	cxtNomeDes := ""
	MsgStop("O representante de origem e destino n�o podem ser o mesmo!",_cRotina+"_003")
	lRet := .F.
ElseIf MsSeek(xFilial("SZ6") + cxtCodDest,.T.,.F.)
	cxtNomeDes := ""
	MsgStop("J� existem regras cadastradas para esse representante!",_cRotina+"_005")
	lRet := .F.
ElseIf Empty(cxtCodDest)
	lRet := .T.
	cxtNomeDes := ""
Else
	lRet := ValidSA3(cxtCodDest)
EndIf
	
RestArea(_aAreaTemp)
	
Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PROCESSAR � Autor � Adriano Leonardo   � Data �  09/08/2013 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o para manipular o retorno do usu�rio, se o processa_ ���
���          � mento for cancelado.                                       ���
�������������������������������������������������������������������������͹��
���Uso  P11  � Uso espec�fico Arcolor - Programa principal                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function Processar()

If Empty(cxtCodDest) .Or. Empty(cxtCodOri)
	MsgStop("Os c�digos do representante de origem e destino s�o obrigat�rios!",_cRotina+"_004")
	lRet := .F.
Else
	If MsgYesNo("Ser� realizada a c�pia das regras de comiss�es do(a) representante: " + AllTrim(cxtNomeOri) + " para o(a) representante: " + AllTrim(cxtNomeDes) + ", deseja continuar? ",_cRotina+"_006")
		MsAguarde({|lEnd| Copiar()},"Aguarde...","Copiando regras, aguarde...",.T.)
	Else
		Return(_lContinua)
	EndIf
EndIf

Return(_lContinua)

Static Function Copiar()

_lContinua := .T.

//Fecho a tela de di�logo
Close(oDlg)


_cAliasSX3 := "SX3_"+GetNextAlias()
OpenSxs(,,,,FWCodEmp(),_cAliasSX3,"SX3",,.F.)
dbSelectArea(_cAliasSX3)
(_cAliasSX3)->(dbSetOrder(1))

If (_cAliasSX3)->(MsSeek("SZ6",.T.,.F.))
	While (_cAliasSX3)->(!EOF()) .AND. AllTrim((_cAliasSX3)->X3_ARQUIVO) == "SZ6"
		If AllTrim((_cAliasSX3)->X3_CONTEXT) <> "V" .AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "Z6_REPRES" .AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "Z6_NOMERE" .AND. AllTrim((_cAliasSX3)->X3_CAMPO) <> "Z6_FILIAL" .AND. AllTrim((_cAliasSX3)->X3_PROPRI)<>'L'
			dbSelectArea("SZ6")
			AADD(_aCpos,{(AllTrim((_cAliasSX3)->X3_ARQUIVO)+"->"+AllTrim((_cAliasSX3)->X3_CAMPO)),Nil})
		EndIf
		dbSelectArea(_cAliasSX3)
		dbSetOrder(1)
		dbSkip()
	EndDo
EndIf
dbSelectArea("SZ6")
dbSetOrder(1)
If MsSeek(xFilial("SZ6")+cxtCodOri,.T.,.F.)
	While !EOF() .And. SZ6->Z6_REPRES==cxtCodOri
	
		For _nCont := 1 To Len(_aCpos)
			
			_cMacro := _aCpos[_nCont][01]
			
			_aCpos[_nCont][02] := &_cMacro
		Next
		
		//Salvo a �rea por conta do desposiocionamento provocado pelo RecLock (inclus�o)
		_aSavTmp := SZ6->(GetArea())
		
		while !RecLock("SZ6",.T.) ; enddo
			SZ6->Z6_FILIAL	:= xFilial("SZ6")
			SZ6->Z6_REPRES	:= cxtCodDest
			SZ6->Z6_NOMERE	:= cxtNomeDes
			
			For _nCont2 := 1 To Len(_aCpos)
				_cCpo 	:= _aCpos[_nCont2][01]
				_cValor := _aCpos[_nCont2][02]
				
				&_cCpo := _cValor
			Next
		SZ6->(MsUnlock())
		
		//Restauro a �rea ap�s inclus�o de regitro, para pr�xima passagem no la�o de repeti��o
		RestArea(_aSavTmp)
		
		dbSelectArea("SZ6")
		dbSetOrder(1)
		dbSkip()
	EndDo
	MsgInfo("Regras copiadas com sucesso!",_cRotina+"_007")
Else
	MsgStop("N�o existem regras cadastradas para o representante a ser copiado!",_cRotina+"_008")
EndIf

Return()