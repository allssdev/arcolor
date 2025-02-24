#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  TLVENT   �Autor  �Renan Felipe        � Data �  29/12/12     ���
�������������������������������������������������������������������������͹��
���Desc.     �Na abertura do browse do televenda para verificar se o      ���
��           �or�amento se trata de uma c�pia.                            ���
��		   	 �PONTO DE ENTRADA APOS O CARREGAMENTO DE UM ATENDIMENTO PARA ���
���           ALTERA��O NA  ROTINA DE TELEVENDAS (ANTES DE APRESENTAR O   ���
���           ACOLS, MAS COM ESTE JA MONTADO).                            ���  
�������������������������������������������������������������������������͹��
���Uso       � AP11 -Espec�fico para a empresa Arcolor                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TLVENT(_cNumAt)

Local _aArea    := GetArea()
Local _nPVerRn  := aScan(aHeader,{|x|AllTrim(x[02])=="UB_VERIFRN"})

If ExistBlock("RTMKE007")
	If AllTrim(SUA->UA_COPY) == "S" .AND. (SuperGetMV("MV_ATUCPY",,.F.) .OR. (SUA->UA_CLIENTE <> SUA->UA_CLIORCP .AND. SUA->UA_LOJA <> SUA->UA_LJORCP))
		ExecBlock("RTMKE007")
	Else
		If ALTERA .AND. _nPVerRn > 0
			For _x := 1 To Len(aCols)
				aCols[_x][_nPVerRn] := ""
			Next
		EndIf
	EndIf
EndIf

RestArea(_aArea)
	
Return()