#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A100CABE  ºAutor  ³Anderson C. P. Coelho º Data ³ 05/09/13 º±±
±±º          ³           ºAutor  ³Júlio Soares          º Data ³ 24/03/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada chamado na geração das ordens de separaçãoº±±
±±º          ³ utilizado para a gravação de campos específicos.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Trecho inserido por Júlio Soares para gravar o status do   º±±
±±º          ³ pedido na tabela SUA (Atendimentos CallCenter )            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11 - Específico para a empresa Arcolor            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A100CABE()

Local _aSavArea := GetArea()
Local _aSavSA2  := SA2->(GetArea())
Local _aSavSA1  := SA1->(GetArea())
Local _aSavSUA  := SUA->(GetArea()) 
Local _aSavSC5  := SC5->(GetArea())
Local _aSavCB8  := CB8->(GetArea())
Local _aSavCB7  := CB7->(GetArea())
Local _aSavCB1  := CB1->(GetArea())
Local _cRotina  := "A100CABE"
Local _cObsSep  := ""
Local _cNOMCLI  := ""
Local _cTpPed   := "" 
Local _cLogx    := ""
Local _cNOMOP1  := ""

Private _cLog   := ""
Private _lEnt   := CHR(13) + CHR (10)

dbSelectArea("CB1")
CB1->(dbSetOrder(1))
If MsSeek(xFilial("CB1") + CB7->CB7_CODOPE,.T.,.F.)
	_cNOMOP1 := CB1->CB1_NOME
EndIf
dbSelectArea("SC5")
SC5->(dbSetOrder(1))
If !Empty(CB7->CB7_PEDIDO)
	SC5->(MsSeek(xFilial("SC5") + CB7->CB7_PEDIDO,.T.,.F.))
ElseIf !Empty(SC9->C9_PEDIDO)
	SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO,.T.,.F.))
EndIf
If _cTpPed $ "D/B"
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	If SA2->(MsSeek (xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
		_cNOMCLI := SA2->A2_NOME
	EndIf   
Else
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek (xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.T.,.F.))
		_cNOMCLI := SA1->A1_NOME
	EndIf
EndIf
If !Empty(SC5->C5_OBSSEP) .AND. !(AllTrim(SC5->C5_OBSSEP))$AllTrim(_cObsSep)
	_cObsSep += AllTrim(SC5->C5_OBSSEP) + _lEnt
EndIf
/*
If !Empty(SC5->C5_OBSSEP) .AND. !("Pedido: " + SC5->C5_NUM + " - " + AllTrim(SC5->C5_OBSSEP))$AllTrim(_cObsSep)
	_cObsSep += "Pedido: " + SC5->C5_NUM + " - " + AllTrim(SC5->C5_OBSSEP) + CHR(13) + CHR(10)
EndIf
*/
If !Empty(_cObsSep)
	CB7->CB7_OBS1 := _cObsSep
EndIf
CB7->CB7_NOMCLI   := _cNOMCLI
CB7->CB7_NOMOP1   := _cNOMOP1
CB7->CB7_PEDIDO   := SC5->C5_NUM
CB7->CB7_DTPED    := SC5->C5_EMISSAO
CB7->CB7_PRIORI   := SC5->C5_NPRIORI

// - Trecho inserido em 24/03/2014 por Júlio Soares para gravar o status do pedido na tabela Atendimentos CallCenter (SUA)
_cLogx := "Pedido em processo de separação."
dbSelectArea("SUA")
SUA->(dbOrderNickName("UA_NUMSC5"))
If SUA->(MsSeek(xFilial("SUA") + SC5->C5_NUM,.T.,.F.))
	_cLog := Alltrim(SUA->UA_LOGSTAT)
	while !RecLock("SUA",.F.) ; enddo
		SUA->UA_STATSC9 := "04"
		If SUA->(FieldPos("UA_LOGSTAT"))>0
			SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
			UsrRetName(__cUserId) + _lEnt + _cLogx
		EndIf
	SUA->(MsUnLock())
EndIf
dbSelectArea("SC5")
SC5->(dbSetOrder(1))
_cLog := Alltrim(SC5->C5_LOGSTAT)
If SC5->(FieldPos("C5_LOGSTAT"))>0
	while !RecLock("SC5",.F.) ; enddo
		SC5->C5_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " +;
		UsrRetName(__cUserId) + _lEnt + _cLogx
	SC5->(MsUnLock())
EndIf
//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
If ExistBlock("RFATL001")
	U_RFATL001(	SC5->C5_NUM,;
				SUA->UA_NUM,;
				_cLogx     ,;
				_cRotina    )
EndIf
// - Fim do trecho inserido para gravar o status do pedido na tabela

RestArea(_aSavSC5)
RestArea(_aSavSA1)
RestArea(_aSavSA2)
RestArea(_aSavSUA)
RestArea(_aSavCB1)
RestArea(_aSavCB8)
RestArea(_aSavCB7) 
RestArea(_aSavCB1) 
RestArea(_aSavArea)

Return(NIL)
