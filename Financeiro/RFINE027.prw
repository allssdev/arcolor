#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFINE027 �Autor  � J�lio Soares       � Data �  19/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � ExecBlock utilizado para validar o tipo de t�tulo que ser� ���
���          � enviado no arquivo Serasa Relato.                          ���
���          �                                                            ���
���          � Inserir  "IIF(EXISTBLOCK("RFINE027"),U_RFINE027(_Ord),)"   ���
���          � no campo de valida��o para as perguntas MV_PAR07 e MV_PAR08���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Ptorheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// -  
// - a.

User Function RFINE027(_Ord)

If &("MV_PAR0"+(cValToChar(_Ord))) <> "NF"
	If !MSGBOX("Ser�o incluidos no arquivo todos os tipos de t�tulos, deseja posseguir mesmo assim?","RFINE027_001","YESNO")
		If MSGBOX("Deseja alterar o tipo de t�tulo para NF.","RFINE027_002","YESNO")
			&("MV_PAR0"+cValToChar(_ord)) := "NF"
		EndIf
	EndIf
EndIf

Return()