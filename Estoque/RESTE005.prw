#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RESTE005  �Autor  �J�lio Soares        � Data �  25/01/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock criado para alertar o usu�rio que a contagem que ���
���          � est� sendo realizada � acima de duas padr�o para a primeira���
���          � etapa do invent�rio.                                       ���
�������������������������������������������������������������������������͹��
���          � Rotina chamada por execblock no campo B7_COD               ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico ARCOLOR                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RESTE005()

Local _cRotina := 'RESTE005'
Local _cCod    := M->B7_COD
Local _cCont   := M->B7_CONTAGE

If _cCont == '003'
	MSGBOX('ESTA SER� A TERCEIRA CONTAGEM PARA O PRODUTO - ' + _cCod + '' ,_cRotina + '_01','STOP')
ElseIf _cCont == '004'
	MSGBOX('ESTA SER� A QUARTA CONTAGEM PARA O PRODUTO - ' + _cCod + '' ,_cRotina + '_02','STOP')
EndIf

Return()