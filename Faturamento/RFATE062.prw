#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

#DEFINE _CLRF CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATE062  � Autor �Anderson C. P. Coelho � Data �  18/01/16 ���
�������������������������������������������������������������������������͹��
���Descricao � Consulta r�pida das NFs de sa�da geradas por Pedido.       ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico para a empresa Arcolor.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATE062()

Local _aSavArea := GetArea()
Local _cRotina  := "RFATE062"
Local _cLog     := ""

Private cPerg   := _cRotina

ValidPerg()
If Pergunte(cPerg,.T.) .AND. !Empty(MV_PAR01)
	BeginSql Alias "NUMPVTMP"
		SELECT DISTINCT D2_EMISSAO, D2_SERIE, D2_DOC 
		FROM %table:SD2% SD2
		WHERE SD2.D2_FILIAL  = %xFilial:SD2%
		  AND SD2.D2_PEDIDO  = %Exp:MV_PAR01%
		  AND SD2.D2_EMISSAO = %Exp:DTOS(dDataBase)%
		  AND SD2.%NotDel%
		ORDER BY D2_EMISSAO, D2_SERIE, D2_DOC
	EndSql
	dbSelectArea("NUMPVTMP")
	While !NUMPVTMP->(EOF())
		_cLog += _CLRF+"Emiss�o: "+DTOC(STOD(NUMPVTMP->D2_EMISSAO))+"  -  Docto.: "+NUMPVTMP->D2_DOC
		NUMPVTMP->(dbSkip())
	EndDo
	NUMPVTMP->(dbCloseArea())
	If !Empty(_cLog)
		MsgInfo("O(s) documento(s) gerado(s) para o pedido '"+MV_PAR01+"' �(s�o):"+_cLog,_cRotina+"_001")
	EndIf
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg � Autor �Anderson C. P. Coelho � Data �  18/01/16 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o respons�vel pela inclus�o de par�metros na rotina.  ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local _sAlias := GetArea()
Local aRegs   := {}
Local _aTam   := TamSx3("C5_NUM")

cPerg         := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Pedido:","","","mv_ch1",_aTam[03],_aTam[01],_aTam[02],0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i := 1 To Len(aRegs)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			EndIf
		Next
		SX1->(MsUnlock())
	EndIf
Next

RestArea(_sAlias)

Return()