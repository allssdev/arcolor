#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFINE020  �Autor  �J�lio Soares        � Data �  06/05/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � ExecBlock criado para que no momento da altera��o da       ���
���          � responsabilidade do cliente seja alterado, conforme        ���
���          � informa��es da empresa, o risco do mesmo.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus11 - Espec�fico empresa ARCOLOR                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFINE020()

Local := _cRisca := SA1->A1_RISCO
Local := _cRiscb := ""

If M->A1_VENDRES == '2'
	_cRiscb := 'E'
Else
	If !Empty(_cRisca)
		_cRiscb := _cRisca
	Else
		_cRiscb := 'E'
	EndIf
EndIf

Return(_cRiscb)