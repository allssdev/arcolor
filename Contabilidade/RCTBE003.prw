#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCTBE003  �Autor  �Anderson C. P. Coelho � Data �  16/02/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock utilizado para retornar o valor a ser utilizado  ���
���          �para a contabiliza��o da folha de pagamento.                ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arc�lor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
			MsgStop("Aten��o! O campo '" + "RV_CC"+ALLTRIM(SRZ->RZ_CC)+"C" + "' n�o existe. Informe o administrador para que n�o tenhamos problemas com as contabiliza��es da folha de pagamento!",_cRotina+"_002")
		EndIf
	Else
		MsgStop("Aten��o! O campo '" + "RV_CC"+ALLTRIM(SRZ->RZ_CC)+"D" + "' n�o existe. Informe o administrador para que n�o tenhamos problemas com as contabiliza��es da folha de pagamento!",_cRotina+"_001")
	EndIf
//EndIf

//RestArea(_aSavSRV)
RestArea(_aSavSRZ)
RestArea(_aSavArea)

Return(_nRet)