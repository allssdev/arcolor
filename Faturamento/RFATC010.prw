#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATC010  º Autor ³ Adriano Leonardo   º Data ³  07/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cópia das regras de comissões (produtos por representante) º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Especifico para a empresa Arcolor.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RFATC010()

Local _aSavArea 	:= GetArea()
Local _aSavSZ6 		:= SZ6->(GetArea())
Private _cRotina	:= "RFATC010"
Private _aCpos		:= {}
Private _lContinua 	:= .F.

If Interface()
	Return(Nil)
EndIf
    
//Restauro a área
RestArea(_aSavSZ6)
RestArea(_aSavArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Interface º Autor ³ Adriano Leonardo   º Data ³  08/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Interface da rotina de cópia das regras de comissões.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso  P11  ³ Uso específico Arcolor - Programa principal                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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

  DEFINE MSDIALOG oDlg TITLE "Cópia das regras de comissões" FROM 000, 000  TO 400, 650 COLORS 0, 16777215 PIXEL

    @ 025, 007 GROUP grpOrigem TO 089, 316 PROMPT "Representante a Ser Copiado" OF oDlg COLOR 0, 16777215 PIXEL
    @ 112, 007 GROUP grpDestino TO 172, 315 PROMPT "Novo Representante" OF oDlg COLOR 0, 16777215 PIXEL

    @ 042, 018 SAY lblCodOri PROMPT "Código do Representante:" SIZE 063, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 056, 065 SAY lblNomeOri PROMPT "Nome:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

    @ 130, 017 SAY lblCodDes PROMPT "Código do Representante:" SIZE 072, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 144, 063 SAY lblNomeDes PROMPT "Nome:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

    @ 040, 086 MSGET txtCodOri VAR cxtCodOri F3 "SA3" VALID ValidSA3() SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 085 MSGET txtNomeOri VAR cxtNomeOri SIZE 182, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL

    @ 127, 085 MSGET txtCodDest VAR cxtCodDest F3 "SA3" VALID ValidSZ6() SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 143, 085 MSGET txtNomeDes VAR cxtNomeDes SIZE 182, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL

    @ 180, 202 BUTTON btnOk PROMPT "&Ok" Action(Processar()) SIZE 052, 012 OF oDlg PIXEL
    @ 180, 262 BUTTON btnCancelar PROMPT "&Cancelar" Action IIf(_lContinua,MsgStop("O processo de cópia já foi iniciado, favor aguardar!",_cRotina+"_001"),Close(oDlg)) SIZE 053, 012 OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return(_lContinua)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VALIDSA3 º Autor ³ Adriano Leonardo   º Data ³  07/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para validar o código do representante do qual as   º±±
±±º          ³ regras de comissões serão copiadas.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso  P11  ³ Uso específico Arcolor - Programa principal                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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
	MsgStop("Código inválido!",_cRotina+"_002")
EndIf

RestArea(_aAreaTmp)
	
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VALIDSZ6 º Autor ³ Adriano Leonardo   º Data ³  07/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para validar o código do representante para o qual  º±±
±±º          ³ as regras serão copiados.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso  P11  ³ Uso específico Arcolor - Programa principal                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ValidSZ6()

Local _aAreaTemp := SZ6->(GetArea())
Local lRet       := .T.

dbSelectArea("SZ6")
dbSetOrder(1)
If cxtCodDest==cxtCodOri
	cxtNomeDes := ""
	MsgStop("O representante de origem e destino não podem ser o mesmo!",_cRotina+"_003")
	lRet := .F.
ElseIf MsSeek(xFilial("SZ6") + cxtCodDest,.T.,.F.)
	cxtNomeDes := ""
	MsgStop("Já existem regras cadastradas para esse representante!",_cRotina+"_005")
	lRet := .F.
ElseIf Empty(cxtCodDest)
	lRet := .T.
	cxtNomeDes := ""
Else
	lRet := ValidSA3(cxtCodDest)
EndIf
	
RestArea(_aAreaTemp)
	
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PROCESSAR º Autor ³ Adriano Leonardo   º Data ³  09/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para manipular o retorno do usuário, se o processa_ º±±
±±º          ³ mento for cancelado.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso  P11  ³ Uso específico Arcolor - Programa principal                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Processar()

If Empty(cxtCodDest) .Or. Empty(cxtCodOri)
	MsgStop("Os códigos do representante de origem e destino são obrigatórios!",_cRotina+"_004")
	lRet := .F.
Else
	If MsgYesNo("Será realizada a cópia das regras de comissões do(a) representante: " + AllTrim(cxtNomeOri) + " para o(a) representante: " + AllTrim(cxtNomeDes) + ", deseja continuar? ",_cRotina+"_006")
		MsAguarde({|lEnd| Copiar()},"Aguarde...","Copiando regras, aguarde...",.T.)
	Else
		Return(_lContinua)
	EndIf
EndIf

Return(_lContinua)

Static Function Copiar()

_lContinua := .T.

//Fecho a tela de diálogo
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
		
		//Salvo a área por conta do desposiocionamento provocado pelo RecLock (inclusão)
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
		
		//Restauro a área após inclusão de regitro, para próxima passagem no laço de repetição
		RestArea(_aSavTmp)
		
		dbSelectArea("SZ6")
		dbSetOrder(1)
		dbSkip()
	EndDo
	MsgInfo("Regras copiadas com sucesso!",_cRotina+"_007")
Else
	MsgStop("Não existem regras cadastradas para o representante a ser copiado!",_cRotina+"_008")
EndIf

Return()