#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FR650FIL	ºAutor  ³Thiago S. de Almeida     ºData ³  21/12/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.TOTVS³ O ponto de entrada FR650FIL recebe os Títulos do arquivo de  º±±
±±º          ³ retorno de comunicação bancária.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada executado em substituição à rotina de       º±±
±±º          ³ pesquisa padrão do título do arquivo de retorno do banco,    º±±
±±º          ³ na tabela decontas a receber SE1, que realiza o IDCNAB ou    º±±
±±º          ³ chave do título.                                             º±±
±±º          ³ CNAB - COBRANCA - FILTRO                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor.             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FR650FIL()

Local _cInd    := ""
Local _nRecSE1 := SE1->(Recno())

lHelp          := .T.

dbSelectArea("SE1")
If lHelp .AND. !Empty(cNumTit)
	_cInd := CriaTrab(Nil,.F.)
	IndRegua("SE1",_cInd,"E1_FILIAL+E1_IDCNAB+DTOS(E1_EMISSAO)","D",,"Selecionando títulos...")
	dbSelectArea("SE1")
	dbGoTop()
	If MsSeek(xFilial("SE1")+Padr(cNumTit,Tamsx3("E1_IDCNAB")[1]),.T.,.F.)
		lHelp    := .F.
		If Empty(cNumTit)
			If !Empty(SE1->E1_IDCNAB)
				cNumTit  := Padr(SE1->E1_IDCNAB,Len(cNumTit))
			Else
				cNumTit  := Padr(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),Len(cNumTit))
			EndIf
		EndIf
		cTipo    := SE1->E1_TIPO
		_nRecSE1 := SE1->(Recno())
	Else
		cNumTit  := Space(15)
	EndIf
EndIf
cNossoNum := AllTrim(cNossoNum)
If !Empty(cNossoNum) .AND. SubStr(cNossoNum,3,1) == " "
	cNossoNum := AllTrim(SubStr(cNossoNum,3))
EndIf
If lHelp .AND. !Empty(cNossoNum)
	_cInd     := CriaTrab(Nil,.F.)
	IndRegua("SE1",_cInd,"E1_FILIAL+E1_NUMBCO+DTOS(E1_EMISSAO)","D",,"Selecionando títulos...")
	dbSelectArea("SE1")
	dbGoTop()
	_cChave   := Padr(cNossoNum,Tamsx3("E1_NUMBCO")[1])
	_lAchou   := Len(cNossoNum) >= 15		//Regra especifica para a carteira 18, para que haja a busca aproximada
	If _lAchou
//		Set SoftSeek ON
		MsSeek(xFilial("SE1")+_cChave,.F.,.F.)
//		Set SoftSeek OFF
	Else
		_lAchou := MsSeek(xFilial("SE1")+_cChave,.T.,.F.)
	EndIf
	If _lAchou
		lHelp := .F.
		If Empty(cNumTit)
			If !Empty(SE1->E1_IDCNAB)
				cNumTit  := Padr(SE1->E1_IDCNAB,Len(cNumTit))
			Else
				cNumTit  := Padr(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),Len(cNumTit))
			EndIf
		EndIf
		cTipo    := SE1->E1_TIPO
		_nRecSE1 := SE1->(Recno())
	EndIf
EndIf
If lHelp .AND. !Empty(cNumTit) .AND. !Empty(SubStr(cNumTit,Len(AllTrim(cNumTit))-TamSx3("E1_IDCNAB")[01]+1,TamSx3("E1_IDCNAB")[01]))
	_cInd := CriaTrab(Nil,.F.)
	IndRegua("SE1",_cInd,"E1_FILIAL+E1_IDCNAB+DTOS(E1_EMISSAO)","D",,"Selecionando títulos...")
	dbSelectArea("SE1")
	dbGoTop()
	If MsSeek(xFilial("SE1")+Padr(SubStr(cNumTit,Len(AllTrim(cNumTit))-TamSx3("E1_IDCNAB")[01]+1,TamSx3("E1_IDCNAB")[01]),Tamsx3("E1_IDCNAB")[01]),.T.,.F.)
		lHelp := .F.
		If Empty(cNumTit)
			If !Empty(SE1->E1_IDCNAB)
				cNumTit  := Padr(SE1->E1_IDCNAB,Len(cNumTit))
			Else
				cNumTit  := Padr(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),Len(cNumTit))
			EndIf
		EndIf
		cTipo    := SE1->E1_TIPO
		_nRecSE1 := SE1->(Recno())
	EndIf
EndIf

lAchouTit := !lHelp

fErase(_cInd+OrdBagExt())

dbSelectArea("SE1")
dbGoTo(_nRecSE1)

Return(lAchouTit)