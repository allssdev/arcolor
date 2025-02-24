#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _lEnt CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMK150EXC ºAutor  ³Microsiga           º Data ³  10/06/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc TOTVS³ Ponto de entrada para validação da exclusão de um          º±±
±±º          ³ atendimento do tipo faturamento no Televendas.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Ponto de entrada utilizado para validar a exclusão do      º±±
±±º          ³ atendimento se esse está vinculado a um pedido.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico empresa ARCOLOR                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMK150EXC()

Local _aSavArea  := GetArea()
Local _aSavSUA   := SUA->(GetArea())
Local _lRet      := .T.
Local _cRotina   := "TMK150EXC"

If !Empty(SUA->UA_NUMSC5)
	//Precisa inserir o numero do pedido para verificar se não irá ter problemas com o posicionamento.
	_cLog := Alltrim(SUA->UA_LOGSTAT)
	If SUA->(FieldPos("UA_LOGSTAT"))>0
		RecLock("SUA",.F.)
			SUA->UA_LOGSTAT := _cLog + _lEnt + Replicate("-",60) + _lEnt + DTOC(Date()) + " - " + Time() + " - " + UsrRetName(__cUserId) +;
								_lEnt + "CANCELAMENTO DO ATENDIMENTO VINCULADO AO PEDIDO N°"+ALLTRIM(SUA->UA_NUMSC5)+"."
		SUA->(MsUnLock())
	EndIf
	//16/11/2016 - Anderson Coelho - Novo Log para os Pedidos Inserido
	If ExistBlock("RFATL001")
		U_RFATL001(	SUA->UA_NUMSC5,;
					SUA->UA_NUM,;
					"Cancelamento do Atendimento.",;
					_cRotina)
	EndIf
EndIf
RestArea(_aSavSUA)
RestArea(_aSavArea)

Return(_lRet)