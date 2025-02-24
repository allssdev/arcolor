#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCTBE004  �Autor  �Anderson C. P. Coelho � Data �  27/04/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock utilizado nos lan�amento padr�o cont�beis, utili-���
���          �zado para processar o posicionamento correto do sistema na  ���
���          �tabela "SED" de Naturezas Financeiras nas contabiliza��es   ���
���          �off-line.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RCTBE004(_cNat,_cTpRet)

Local _cRet								//     := Padr("",TamSx3("ED_CONTA")[01])
Local _aSavArea := GetArea()
Local _aSavSA1  := SA1->(GetArea())
Local _aSavSA2  := SA2->(GetArea())
Local _aSavSB1  := SB1->(GetArea())
Local _aSavSD2  := SD2->(GetArea())
Local _aSavSED  := SED->(GetArea())
Local _aSavSF2  := SF2->(GetArea())
Local _aSavSF4  := SF4->(GetArea())
Local _aSavCT5  := CT5->(GetArea())

Default _cNat   := ""
Default _cTpRet := "ED_CONTA"

_cRet           := CriaVar(_cTpRet)

If !Empty(_cNat)
	dbSelectArea("SED")
	SED->(dbSetOrder(1))
	If SED->(MsSeek(xFilial("SED") + Padr(_cNat,TamSx3("ED_CODIGO")[01]), .T., .F.))
		_cRet := &("SED->"+_cTpRet)
	EndIf
EndIf

RestArea(_aSavSA1 )
RestArea(_aSavSA2 )
RestArea(_aSavSB1 )
RestArea(_aSavSD2 )
RestArea(_aSavSED )
RestArea(_aSavCT5 )
RestArea(_aSavSF2 )
RestArea(_aSavSF4 )
RestArea(_aSavArea)

Return(_cRet)