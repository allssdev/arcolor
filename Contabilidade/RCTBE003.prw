#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCTBE003  ºAutor  ³Anderson C. P. Coelho º Data ³  16/02/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Execblock utilizado para retornar o valor a ser utilizado  º±±
±±º          ³para a contabilização da folha de pagamento.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11 - Específico para a empresa Arcólor.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCTBE003()

Local _aSavArea := GetArea()
Local _aSavSRV  := SRV->(GetArea())
Local _aSavSRZ  := SRZ->(GetArea())
Local _cRotina  := "RCTBE003"
Local _nRet     := 0

//If SRZ->RZ_MAT==Replicate("z",TamSx3("RZ_MAT")[01]) .AND. SRZ->RZ_CC<>Replicate("z",TamSx3("RZ_CC")[01]))
	If SRV->(FieldPos("RV_CC"+ALLTRIM(SRZ->RZ_CC)+"D"))<>0
		If SRV->(FieldPos("RV_CC"+ALLTRIM(SRZ->RZ_CC)+"C"))<>0
			dbSelectArea("SRV")
			SRV->(dbSetOrder(1))
			If SRV->(MsSeek(xFilial("SRV") + SRZ->RZ_PD,.T.,.F.))
				If !Empty(&("SRV->RV_CC"+ALLTRIM(SRZ->RZ_CC)+"D+SRV->RV_CC"+ALLTRIM(SRZ->RZ_CC)+"C"))
					_nRet := SRZ->RZ_VAL
				EndIf
			EndIf
		Else
			MsgStop("Atenção! O campo '" + "RV_CC"+ALLTRIM(SRZ->RZ_CC)+"C" + "' não existe. Informe o administrador para que não tenhamos problemas com as contabilizações da folha de pagamento!",_cRotina+"_002")
		EndIf
	Else
		MsgStop("Atenção! O campo '" + "RV_CC"+ALLTRIM(SRZ->RZ_CC)+"D" + "' não existe. Informe o administrador para que não tenhamos problemas com as contabilizações da folha de pagamento!",_cRotina+"_001")
	EndIf
//EndIf

//RestArea(_aSavSRV)
RestArea(_aSavSRZ)
RestArea(_aSavArea)

Return(_nRet)