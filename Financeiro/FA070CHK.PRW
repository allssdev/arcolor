#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA070CHK  �Autor  �Microsiga           � Data �  07/22/14   ���
�������������������������������������������������������������������������͹��
���Desc.TOTVS� O ponto de entrada FA070CHK sera executado na entrada da   ���
���          � funcao antes de carregar a tela de baixa do contas a       ���
���          � receber.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA070CHK()
Local _aSavArea := GetArea()
Local   _cRotina := 'FA070CHK'
Private _lRet    := .T.
Public  nJuros   := 0

SE1->E1_JUROS := 0                                 
SE1->E1_MULTA := 0

_CTEXT := ''
RestArea(_aSavArea)
Return(_lRet)                        